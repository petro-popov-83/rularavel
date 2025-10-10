#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--push[=<branch>]] [--github[=<owner/repo>]] [--github-askpass] [--upstream=<url>] [--ssh-key=<path>] [--ssh-key-env[=<VAR>]] <origin-url> [upstream-url]

Configures Git remotes for the translation repository.
- <origin-url>   URL of your writable fork (e.g. git@github.com:you/laravel-docs-ru.git)
- [upstream-url] Optional URL of the canonical repository to pull updates from.
- --push         (Optional) Immediately push the current branch to origin.
                 You may pass a branch name as --push=<branch>.
- --github       (Optional) Derive origin URLs from GitHub env vars.
                 Uses GITHUB_TOKEN and either the provided owner/repo slug or
                 the GITHUB_REPOSITORY environment variable.
- --github-askpass (Optional) Create an askpass helper backed by GITHUB_TOKEN
                 so that Git can authenticate without embedding credentials
                 into remote URLs.
- --upstream     (Optional) Explicitly set the upstream URL without relying on
                 positional arguments (useful together with --github).
- --ssh-key      (Optional) Configure Git to use the provided private deploy
                 key for SSH operations (sets core.sshCommand for the repo).
- --ssh-key-env  (Optional) Write the private deploy key stored in the given
                 environment variable (defaults to DEPLOY_KEY) to a temporary
                 file and configure Git to use it. Incompatible with --ssh-key.

The script is idempotent: existing remotes will be updated with new URLs.
USAGE
}

PUSH_REQUESTED=false
PUSH_BRANCH=""
GITHUB_SLUG=""
UPSTREAM_OVERRIDE=""
SSH_KEY=""
SSH_KEY_ENV=""
CONFIGURE_ASKPASS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --push)
      PUSH_REQUESTED=true
      shift
      ;;
    --push=*)
      PUSH_REQUESTED=true
      PUSH_BRANCH="${1#*=}"
      shift
      ;;
    --github)
      if [[ -z "${GITHUB_REPOSITORY:-}" ]]; then
        echo "Error: --github requires either GITHUB_REPOSITORY env var or --github=<owner/repo>." >&2
        exit 1
      fi
      GITHUB_SLUG="$GITHUB_REPOSITORY"
      shift
      ;;
    --github=*)
      GITHUB_SLUG="${1#*=}"
      shift
      ;;
    --github-askpass)
      CONFIGURE_ASKPASS=true
      shift
      ;;
    --upstream=*)
      UPSTREAM_OVERRIDE="${1#*=}"
      shift
      ;;
    --ssh-key)
      if [[ $# -lt 2 ]]; then
        echo "Error: --ssh-key requires a path argument." >&2
        exit 1
      fi
      SSH_KEY="$2"
      shift 2
      ;;
    --ssh-key=*)
      SSH_KEY="${1#*=}"
      shift
      ;;
    --ssh-key-env)
      SSH_KEY_ENV="DEPLOY_KEY"
      shift
      ;;
    --ssh-key-env=*)
      SSH_KEY_ENV="${1#*=}"
      shift
      ;;
    --)
      shift
      break
      ;;
    --*)
      echo "Error: unknown option $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -gt 2 ]]; then
  echo "Error: unexpected number of arguments" >&2
  usage >&2
  exit 1
fi

ORIGIN_URL=""
UPSTREAM_URL=""

case $# in
  0)
    ;;
  1)
    ORIGIN_URL=$1
    ;;
  2)
    ORIGIN_URL=$1
    UPSTREAM_URL=$2
    ;;
esac

if [[ -n "$UPSTREAM_OVERRIDE" ]]; then
  UPSTREAM_URL="$UPSTREAM_OVERRIDE"
fi

if [[ -n "$SSH_KEY" && -n "$SSH_KEY_ENV" ]]; then
  echo "Error: --ssh-key and --ssh-key-env cannot be used together." >&2
  exit 1
fi

TEMP_KEY_PATH=""

if [[ -n "$SSH_KEY_ENV" ]]; then
  if [[ -z "${!SSH_KEY_ENV:-}" ]]; then
    echo "Error: environment variable $SSH_KEY_ENV is not set or empty." >&2
    exit 1
  fi

  TEMP_KEY_PATH="$REPO_ROOT/.git/deploy-key-${SSH_KEY_ENV,,}"
  install -m 700 -d "$(dirname "$TEMP_KEY_PATH")"
  umask 177
  printf '%s\n' "${!SSH_KEY_ENV}" >"$TEMP_KEY_PATH"
  chmod 600 "$TEMP_KEY_PATH"
  SSH_KEY="$TEMP_KEY_PATH"
fi

if [[ -n "$SSH_KEY" ]]; then
  if [[ "${SSH_KEY:0:2}" == "~/" ]]; then
    SSH_KEY="${HOME}/${SSH_KEY:2}"
  fi
  if [[ ! -f "$SSH_KEY" ]]; then
    echo "Error: SSH key not found at $SSH_KEY" >&2
    exit 1
  fi
  if [[ ! -r "$SSH_KEY" ]]; then
    echo "Error: SSH key at $SSH_KEY is not readable." >&2
    exit 1
  fi
  if [[ "$SSH_KEY" != /* ]]; then
    SSH_KEY="$(cd "$(dirname "$SSH_KEY")" && pwd)/$(basename "$SSH_KEY")"
  fi
fi

if [[ -z "$ORIGIN_URL" && -z "$GITHUB_SLUG" ]]; then
  echo "Error: origin URL is required unless --github provides it." >&2
  usage >&2
  exit 1
fi

ORIGIN_PUSH_URL=""

if [[ -n "$GITHUB_SLUG" ]]; then
  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo "Error: GITHUB_TOKEN must be set when using --github." >&2
    exit 1
  fi

  GITHUB_FETCH_URL="https://github.com/${GITHUB_SLUG}.git"
  GITHUB_PUSH_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_SLUG}.git"

  if [[ -z "$ORIGIN_URL" ]]; then
    ORIGIN_URL="$GITHUB_FETCH_URL"
  fi
  ORIGIN_PUSH_URL="$GITHUB_PUSH_URL"
fi

if [[ -z "$ORIGIN_URL" ]]; then
  echo "Error: unable to determine origin URL." >&2
  usage >&2
  exit 1
fi

cd "$REPO_ROOT"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  :
else
  echo "Error: $REPO_ROOT is not a Git repository" >&2
  exit 2
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$ORIGIN_URL"
else
  git remote add origin "$ORIGIN_URL"
fi

if [[ -n "$ORIGIN_PUSH_URL" ]]; then
  git remote set-url --push origin "$ORIGIN_PUSH_URL"
fi

echo "Configured origin fetch -> $ORIGIN_URL"
if [[ -n "$ORIGIN_PUSH_URL" ]]; then
  echo "Configured origin push  -> <token-redacted>"
fi

if [[ -n "$UPSTREAM_URL" ]]; then
  if git remote get-url upstream >/dev/null 2>&1; then
    git remote set-url upstream "$UPSTREAM_URL"
  else
    git remote add upstream "$UPSTREAM_URL"
  fi
  echo "Configured upstream -> $UPSTREAM_URL"
fi

if [[ -z "$UPSTREAM_URL" ]]; then
  echo "Tip: provide an upstream URL to track the canonical documentation repo." >&2
fi

if $CONFIGURE_ASKPASS; then
  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo "Error: --github-askpass requires GITHUB_TOKEN to be set." >&2
    exit 1
  fi

  ASKPASS_DIR="$REPO_ROOT/.git"
  install -m 700 -d "$ASKPASS_DIR"
  ASKPASS_PATH="$ASKPASS_DIR/github-askpass.sh"

  ASKPASS_USER="${GITHUB_USERNAME:-}"
  if [[ -z "$ASKPASS_USER" && -n "$GITHUB_SLUG" ]]; then
    ASKPASS_USER="${GITHUB_SLUG%%/*}"
  fi
  if [[ -z "$ASKPASS_USER" ]]; then
    ASKPASS_USER="$(git config user.name || true)"
  fi
  if [[ -z "$ASKPASS_USER" ]]; then
    ASKPASS_USER="git"
  fi

  umask 177
  printf -v ASKPASS_USER_ESCAPED '%q' "$ASKPASS_USER"
  printf -v GITHUB_TOKEN_ESCAPED '%q' "$GITHUB_TOKEN"
  cat >"$ASKPASS_PATH" <<SCRIPT
#!/usr/bin/env bash
case "\$1" in
  *Username*)
    printf '%s\n' ${ASKPASS_USER_ESCAPED}
    ;;
  *Password*)
    printf '%s\n' ${GITHUB_TOKEN_ESCAPED}
    ;;
  *)
    printf '\n'
    ;;
esac
SCRIPT
  chmod 700 "$ASKPASS_PATH"
  git config core.askPass "$ASKPASS_PATH"
  echo "Configured core.askPass helper at $ASKPASS_PATH"
fi

if [[ -n "$SSH_KEY" ]]; then
  git config core.sshCommand "ssh -i $SSH_KEY -o IdentitiesOnly=yes"
  if [[ -n "$SSH_KEY_ENV" ]]; then
    echo "Configured core.sshCommand to use deploy key from env var $SSH_KEY_ENV"
  else
    echo "Configured core.sshCommand to use deploy key at $SSH_KEY"
  fi
fi

if $PUSH_REQUESTED; then
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$CURRENT_BRANCH" == "HEAD" ]]; then
    echo "Error: cannot determine current branch (detached HEAD)." >&2
    exit 3
  fi

  if [[ -z "$PUSH_BRANCH" ]]; then
    PUSH_BRANCH=$CURRENT_BRANCH
  fi

  git push --set-upstream origin "${CURRENT_BRANCH}:${PUSH_BRANCH}"
  echo "Pushed $CURRENT_BRANCH -> origin/$PUSH_BRANCH"
fi

exit 0
