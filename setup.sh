#!/bin/bash 

set -e

rpath() {
  if command realpath > /dev/null 2>&1
  then
    realpath "$1"
  else
    echo "$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
  fi
}

skip_bootstrap=''
skip_brewfile=''
while [[ $# -gt 0 ]] ; do
  case "$1" in
    --skip-bootstrap) skip_bootstrap=1 ;;
    --skip-brewfile)  skip_brewfile=1 ;;
    -h|--help)
      cat <<EOF
Usage: $(basename $0) [options]

Links the dotfiles in this repo into \$HOME, then installs the tooling they
assume. Existing non-symlink dotfiles are moved to ~/.dotfiles-backup first.

  --skip-bootstrap  only link dotfiles; install nothing (fast, no network)
  --skip-brewfile   install Homebrew and the version managers, but do not
                    install the packages listed in brew/Brewfile
  -h, --help        this message
EOF
      exit 0 ;;
    *)
      echo "Unknown option: $1 (try --help)" >&2
      exit 1 ;;
  esac
  shift
done

basedir="$(rpath $(dirname $0))"

if [[ -z "${basedir}" ]]
then
  echo "Could not determine base directory for env repo"
  exit 1
fi

cd $HOME

backupdir="${HOME}/.dotfiles-backup"
mkdir -p $backupdir

# Files matching the globs below that must NOT be swept into the backup dir:
# either intentional machine-local overrides (sourced by the tracked configs
# but deliberately untracked) or live shell/editor state.
keep_local=" .bashrc.local .bashrc.claude_env .gitconfig.local .bash_history .bash_sessions .viminfo .vimtags "

shopt -s nullglob
for file in .bash* .{g,}vim* .git*
do
  case "${keep_local}" in
    *" ${file} "*) continue ;;
  esac
  if [ ! -L $file ] ; then mv ${file} ${backupdir}; fi
done

for file in ${basedir}/.bash* ${basedir}/git/.??* ${basedir}/vimfiles/.{g,}vim*; do
  ln -sfn $file $HOME/
done

mkdir -p ${HOME}/bin
for file in ${basedir}/bin/*; do
  ln -sfn $file ${HOME}/bin/
done

# Shell completions: sourced by .bashrc.custom, not executed, so they stay off
# of PATH rather than living in bin/.
ln -sfn ${basedir}/completions $HOME/.completions

# Genesis: ~/.genesis is a live directory (binary, lib/, logs/) managed by
# genesis itself, so link only the config file into it, not the directory.
mkdir -p ${HOME}/.genesis
if [ -e "${HOME}/.genesis/config" ] && [ ! -L "${HOME}/.genesis/config" ]; then
  mv "${HOME}/.genesis/config" "${backupdir}/genesis-config"
fi
ln -sfn ${basedir}/genesis/config ${HOME}/.genesis/config

mkdir -p $HOME/tmp/vim-backups

# =============================================================================
# Bootstrap: package manager, language/version managers
# -----------------------------------------------------------------------------
# Every step below is a no-op when the tool is already installed. Nothing here
# is required for the dotfiles themselves -- the symlinking above is done, so a
# failure past this point leaves you with a working shell either way.
#
# NOTE: these are the vendors' documented `curl | bash` installers. That means
# trusting the URL at run time; pin/verify yourself if that isn't acceptable.
# -----------------------------------------------------------------------------

have() { command -v "$1" > /dev/null 2>&1 ; }

warn() { echo "  ! $*" >&2 ; }

if [[ -n "${skip_bootstrap}" ]] ; then
  echo "Skipping bootstrap (--skip-bootstrap)"
else

  # --- Homebrew -------------------------------------------------------------
  if have brew ; then
    echo "Homebrew: already installed ($(command -v brew))"
  else
    echo "Homebrew: installing..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ; then
      # Put brew on PATH for the rest of THIS run; .bashrc.macosx handles
      # subsequent shells.
      for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew ; do
        [[ -x "$candidate" ]] && eval "$("$candidate" shellenv)" && break
      done
    else
      warn "Homebrew install failed - skipping Brewfile"
    fi
  fi

  # --- Brewfile -------------------------------------------------------------
  # brew/Brewfile is CURATED and hand-maintained -- do NOT regenerate it with
  # `brew bundle dump`. Doing so re-adds every transitive dependency, re-adds
  # the runtimes owned by rvm/nvm/rustup/uv, and DROPS the tap-sourced packages
  # (which dump cannot see unless the taps are trusted first).
  if [[ -n "${skip_brewfile}" ]] ; then
    echo "Skipping Brewfile (--skip-brewfile)"
  elif ! have brew ; then
    warn "No brew on PATH - skipping Brewfile"
  elif [[ ! -f "${basedir}/brew/Brewfile" ]] ; then
    warn "No ${basedir}/brew/Brewfile - skipping"
  else
    # Homebrew 6+ refuses to load formulae from untrusted third-party taps.
    # Without this, the tap-sourced packages fail -- and `brew bundle dump`
    # silently omits them from any future snapshot, so the loss is invisible.
    for t in cloudfoundry-community/cf cloudfoundry/tap hashicorp/tap oven-sh/bun atlassian/acli ; do
      brew trust "$t" > /dev/null 2>&1 || warn "could not trust tap $t"
    done

    echo "Homebrew: installing from Brewfile (this is the slow part)..."
    brew bundle install --file="${basedir}/brew/Brewfile" || \
      warn "Some Brewfile entries failed; re-run 'brew bundle install --file=${basedir}/brew/Brewfile'"
  fi

  # --- GitHub CLI auth ------------------------------------------------------
  # gh itself is installed from the Brewfile; this is only about its keyring.
  # ~/.bashrc.local sets GITHUB_AUTH_TOKEN="$(gh auth token)", and genesis
  # reads that variable directly (Service/Github.pod). Unauthenticated it does
  # not fail -- it silently drops to 60 API requests/hr instead of 5000.
  #
  # `gh auth login` needs a browser and a TTY, so it cannot be scripted: run it
  # when someone is watching, otherwise just say what is missing.
  if ! have gh ; then
    warn "gh not on PATH - skipping auth check"
  elif gh auth status > /dev/null 2>&1 ; then
    echo "gh: already authenticated ($(gh api user --jq .login 2>/dev/null))"
  elif [ -t 0 ] ; then
    echo "gh: not authenticated - launching 'gh auth login'..."
    gh auth login || warn "gh auth login failed; re-run it by hand"
  else
    warn "gh is not authenticated: run 'gh auth login' or genesis stays capped at 60 API req/hr"
  fi

  # --- perlbrew -------------------------------------------------------------
  if [[ -d "$HOME/perl5/perlbrew" ]] || have perlbrew ; then
    echo "perlbrew: already installed"
  else
    echo "perlbrew: installing..."
    curl -L https://install.perlbrew.pl | bash || warn "perlbrew install failed"
  fi

  # --- rvm ------------------------------------------------------------------
  if [[ -d "$HOME/.rvm" ]] || have rvm ; then
    echo "rvm: already installed"
  else
    echo "rvm: installing..."
    # rvm's installer verifies its own signature; import the release keys first
    # or it refuses to proceed.
    if have gpg ; then
      gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys \
        409B6B1796C275462A1703113804BB82D39DC0E3 \
        7D2BAF1CF37B13E2069D6956105BD0E739499BDB || warn "rvm key import failed"
    else
      warn "gpg not found - rvm installer may refuse to verify itself"
    fi
    curl -sSL https://get.rvm.io | bash -s stable || warn "rvm install failed"
  fi

  # --- nvm ------------------------------------------------------------------
  # Bump NVM_VERSION as new releases land; the installer has no "latest" URL.
  NVM_VERSION="${NVM_VERSION:-v0.40.3}"
  if [[ -d "$HOME/.nvm" ]] ; then
    echo "nvm: already installed"
  else
    echo "nvm: installing ${NVM_VERSION}..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash || \
      warn "nvm install failed"
  fi

  # --- rustup ---------------------------------------------------------------
  # The official installer, deliberately not brew: brew's rustup-init formula
  # was renamed upstream, which left ~/.cargo/bin full of symlinks pointing at
  # a binary that no longer existed.
  #
  # --no-modify-path because .bash_profile already sources ~/.cargo/env; without
  # it the installer appends its own line to the shell profiles as well.
  if have rustup && have cargo ; then
    echo "rustup: already installed"
  else
    # A leftover bin/ of dangling symlinks confuses the installer. Report it
    # rather than deleting anything automatically.
    if [ -d "$HOME/.cargo/bin" ] ; then
      broken=0
      for f in "$HOME"/.cargo/bin/* ; do [ -e "$f" ] || broken=$((broken+1)) ; done
      [ "$broken" -gt 0 ] && \
        warn "$HOME/.cargo/bin has $broken dangling symlink(s); consider removing it first"
    fi
    echo "rustup: installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
      sh -s -- -y --no-modify-path || warn "rustup install failed"
  fi

  # --- Python (uv) ----------------------------------------------------------
  # uv itself comes from the Brewfile. Brew's python@3.x formulae exist to
  # satisfy other formulae and should not be used for development, so install
  # a uv-managed interpreter here instead -- otherwise a fresh machine has no
  # dev Python at all, only whatever brew pulled in as a dependency.
  #
  # This drops a versioned executable (e.g. ~/.local/bin/python3.13) which
  # .bashrc.custom appends to PATH. Deliberately NOT --default: that would ALSO
  # claim the bare `python` and `python3` names and shadow brew's python3.
  UV_PYTHON_VERSION="${UV_PYTHON_VERSION:-3.13}"
  if ! have uv ; then
    warn "uv not on PATH - skipping Python install"
  else
    echo "uv: installing Python ${UV_PYTHON_VERSION}..."
    uv python install "${UV_PYTHON_VERSION}" || \
      warn "uv python install ${UV_PYTHON_VERSION} failed"
  fi

  # --- vault (last MPL release) ---------------------------------------------
  # openbao (from the Brewfile) is the maintained MPL fork and provides `bao`.
  # This is the genuine article at its final MPL-2.0 version, for talking to
  # older servers. It cannot come from brew: homebrew/core dropped vault after
  # the BUSL relicense, and hashicorp/tap only carries BUSL 2.x. So fetch the
  # official release binary and verify it against the published checksum.
  VAULT_MPL_VERSION="${VAULT_MPL_VERSION:-1.14.4}"
  if [ -x "$HOME/bin/vault" ] ; then
    echo "vault: already present at ~/bin/vault ($("$HOME/bin/vault" version 2>/dev/null | awk '{print $2}'))"
  else
    case "$OSTYPE" in
      darwin*) vault_os=darwin ;;
      linux*)  vault_os=linux ;;
      *)       vault_os='' ;;
    esac
    case "$(uname -m)" in
      arm64|aarch64) vault_arch=arm64 ;;
      x86_64)        vault_arch=amd64 ;;
      *)             vault_arch='' ;;
    esac

    if [ -z "$vault_os" ] || [ -z "$vault_arch" ] ; then
      warn "unsupported platform for vault ${VAULT_MPL_VERSION}; skipping"
    else
      vault_zip="vault_${VAULT_MPL_VERSION}_${vault_os}_${vault_arch}.zip"
      vault_base="https://releases.hashicorp.com/vault/${VAULT_MPL_VERSION}"
      vault_tmp="$(mktemp -d)"
      echo "vault: fetching ${VAULT_MPL_VERSION} (${vault_os}/${vault_arch})..."
      if curl -fsSL -o "${vault_tmp}/${vault_zip}" "${vault_base}/${vault_zip}" && \
         curl -fsSL -o "${vault_tmp}/SHA256SUMS" "${vault_base}/vault_${VAULT_MPL_VERSION}_SHA256SUMS" ; then
        want="$(grep " ${vault_zip}\$" "${vault_tmp}/SHA256SUMS" | awk '{print $1}')"
        if command -v shasum > /dev/null 2>&1 ; then
          got="$(shasum -a 256 "${vault_tmp}/${vault_zip}" | awk '{print $1}')"
        else
          got="$(sha256sum "${vault_tmp}/${vault_zip}" | awk '{print $1}')"
        fi
        if [ -n "$want" ] && [ "$want" = "$got" ] ; then
          mkdir -p "$HOME/bin"
          unzip -q -o "${vault_tmp}/${vault_zip}" vault -d "$HOME/bin" && \
            chmod +x "$HOME/bin/vault" && \
            echo "vault: installed ${VAULT_MPL_VERSION} to ~/bin/vault"
        else
          warn "vault checksum mismatch (want ${want:-<none>}, got ${got}); NOT installing"
        fi
      else
        warn "vault ${VAULT_MPL_VERSION} download failed"
      fi
      rm -rf "${vault_tmp}"
    fi
  fi

  # --- Linux distro extras --------------------------------------------------
  # Homebrew covers macOS; on Debian/Ubuntu pull the handful of things the
  # dotfiles assume from apt rather than from a pinned .deb URL.
  if [[ "$OSTYPE" == linux* ]] && have apt-get ; then
    echo "Debian/Ubuntu: installing extras via apt..."
    sudo apt-get update && \
      sudo apt-get install -y bat ruby-dev vim-gtk3 silversearcher-ag tig htop tree || \
      warn "apt install failed"
    # Debian ships bat as batcat to avoid a name clash.
    if have batcat && ! have bat ; then
      mkdir -p "$HOME/bin" && ln -sfn "$(command -v batcat)" "$HOME/bin/bat"
    fi
  fi

fi

#TODO check required libraries and run this
echo
echo "Setup complete. Run ~/.vim/update_bundles to install vim plugins."
