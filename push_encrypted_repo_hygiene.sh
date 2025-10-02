#!/usr/bin/env bash
#
# Usage:
#   ./push_encrypted_repo_hygiene_https.sh /path/to/source /path/to/workdir REMOTE_URL [chunk_size] [upload_mode] [sleep_seconds]
#
# Example REMOTE_URL values:
#   https://github.com/YOU/encrypted-repo.git
#   https://github.com/YOU/encrypted-repo.git   (use GIT_TOKEN env var to avoid interactive prompts)
#
# Optional environment:
#   export GIT_TOKEN="ghp_xxx..."  # Personal access token (preferred to provide at runtime)
#
set -euo pipefail
IFS=$'\n\t'

SRC_REPO="${1:-}"
WORKDIR="${2:-}"
REMOTE_URL="${3:-}"
CHUNK_SIZE="${4:-1M}"
UPLOAD_MODE="${5:-per_chunk}"   # options: per_chunk | bulk
SLEEP_SECONDS="${6:-5}"

if [[ -z "$SRC_REPO" || -z "$WORKDIR" || -z "$REMOTE_URL" ]]; then
  echo "Usage: $0 /path/to/source /path/to/workdir REMOTE_URL [chunk_size] [upload_mode] [sleep_seconds]"
  exit 2
fi

# Tools check
for tool in tar gzip gpg split git openssl; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Required tool '$tool' not found in PATH."; exit 3; }
done

# If REMOTE_URL is HTTPS and GIT_TOKEN is set, create an authenticated URL
AUTH_REMOTE_URL="$REMOTE_URL"
if [[ "$REMOTE_URL" =~ ^https:// ]]; then
  if [[ -n "${GIT_TOKEN:-}" ]]; then
    # Insert token right after https://
    # Be careful with special characters in token (they should be URL-safe)
    AUTH_REMOTE_URL="$(echo "$REMOTE_URL" | sed -E "s#https://#https://${GIT_TOKEN}@#")"
    echo "Using provided GIT_TOKEN to form authenticated HTTPS remote URL."
  else
    echo "REMOTE_URL is HTTPS and no GIT_TOKEN found; git may prompt for credentials or use credential helper."
  fi
fi

SRC_REPO="$(realpath "$SRC_REPO")"
WORKDIR="$(realpath "$WORKDIR")"
mkdir -p "$WORKDIR"

TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
TARFILE="$WORKDIR/snapshot_${TIMESTAMP}.tar.gz"
ENCRYPTED_ASC="$WORKDIR/snapshot_${TIMESTAMP}.tar.gz.asc"
PART_PREFIX="$WORKDIR/snapshot_${TIMESTAMP}.asc.part"
PASSPHRASE_FILE="$WORKDIR/.repo_passphrase"

cleanup() {
  rm -f "$TARFILE" "$ENCRYPTED_ASC"
}
trap cleanup EXIT

echo "Creating tarball (gzip -6) from: $SRC_REPO"
tar -C "$SRC_REPO" -cf - . | gzip -6 > "$TARFILE"

# Passphrase handling
if [[ -f "$PASSPHRASE_FILE" ]]; then
  echo "Using existing passphrase file at $PASSPHRASE_FILE"
  chmod 600 "$PASSPHRASE_FILE"
  PASSPHRASE_ARGS=(--batch --yes --passphrase-file "$PASSPHRASE_FILE")
else
  echo "No passphrase file found; generating a random passphrase in $PASSPHRASE_FILE"
  openssl rand -base64 32 > "$PASSPHRASE_FILE"
  chmod 600 "$PASSPHRASE_FILE"
  PASSPHRASE_ARGS=(--batch --yes --passphrase-file "$PASSPHRASE_FILE")
fi

echo "Encrypting tarball with GPG (AES256) and ASCII armor -> $ENCRYPTED_ASC"
gpg "${PASSPHRASE_ARGS[@]}" --symmetric --cipher-algo AES256 --armor -o "$ENCRYPTED_ASC" "$TARFILE"

echo "Cleaning any preexisting part files with the same prefix..."
rm -f "${PART_PREFIX}"*

echo "Splitting $ENCRYPTED_ASC into chunks of $CHUNK_SIZE ..."
split -b "$CHUNK_SIZE" -d -a 3 "$ENCRYPTED_ASC" "${PART_PREFIX}"

# Initialize git repo if needed
if [[ ! -d "$WORKDIR/.git" ]]; then
  echo "Initializing git repo in $WORKDIR..."
  git -C "$WORKDIR" init -q
fi

# Use AUTH_REMOTE_URL when configuring remote (if token provided)
if ! git -C "$WORKDIR" remote get-url origin >/dev/null 2>&1; then
  echo "Adding remote origin..."
  git -C "$WORKDIR" remote add origin "$AUTH_REMOTE_URL"
else
  CURRENT_REMOTE="$(git -C "$WORKDIR" remote get-url origin)"
  if [[ "$CURRENT_REMOTE" != "$AUTH_REMOTE_URL" && -n "$AUTH_REMOTE_URL" ]]; then
    echo "Updating remote origin from $CURRENT_REMOTE to $AUTH_REMOTE_URL"
    git -C "$WORKDIR" remote set-url origin "$AUTH_REMOTE_URL"
  fi
fi

cd "$WORKDIR"

# Remove previously tracked snapshot parts and leftovers
git rm -f --ignore-unmatch snapshot_*.asc.part* || true
rm -f snapshot_*.asc.part*

PART_FILES=( "${PART_PREFIX}"* )
if [[ ${#PART_FILES[@]} -eq 0 || "${PART_FILES[0]}" == "${PART_PREFIX}*" ]]; then
  echo "No part files found after split; aborting."
  exit 4
fi

COMMIT_PREFIX="update snapshot ${TIMESTAMP}"

# Helper to push (using AUTH_REMOTE_URL if set; git push will pick credentials accord. to configured remote)
do_push() {
  # git push may prompt for username/password if HTTPS and no token nor credential helper is configured.
  # If you provided GIT_TOKEN, the remote was set to include it.
  git push origin main
}

if [[ "$UPLOAD_MODE" == "per_chunk" ]]; then
  echo "Uploading parts one-by-one with $SLEEP_SECONDS second interval (per_chunk mode)."
  for fullpath in "${PART_PREFIX}"*; do
    fname="$(basename "$fullpath")"
    echo "Adding part: $fname"
    git add "$fname"
    git commit -m "${COMMIT_PREFIX} - ${fname}" || {
      echo "No change to commit for $fname; continuing."
    }
    echo "Pushing commit for $fname ..."
    do_push
    echo "Sleeping ${SLEEP_SECONDS}s ..."
    sleep "$SLEEP_SECONDS"
  done
elif [[ "$UPLOAD_MODE" == "bulk" ]]; then
  echo "Bulk mode: adding all parts in one commit and pushing once."
  git add "${PART_PREFIX}"*
  git commit -m "${COMMIT_PREFIX}" || {
    echo "No changes to commit; creating an empty timestamped commit."
    git commit --allow-empty -m "${COMMIT_PREFIX} (empty)"
  }
  echo "Pushing bulk commit ..."
  do_push
else
  echo "Unknown upload mode: $UPLOAD_MODE. Use per_chunk or bulk."
  exit 5
fi

echo "Done. Encrypted parts pushed. Passphrase file location (keep secure): $PASSPHRASE_FILE"
echo "If you used GIT_TOKEN, consider unsetting it after the operation: unset GIT_TOKEN"

