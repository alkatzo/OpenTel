#!/usr/bin/env bash
#
# Usage:
#   ./pull_decrypt_repo_hygiene.sh git@github.com:YOU/encrypted-repo.git /path/to/workdir /path/to/passphrase_file
#
# Behavior:
#  - Clones or pulls the repo
#  - Reassembles snapshot_*.asc.partNNN into snapshot_<TIMESTAMP>.tar.gz.asc
#  - Decrypts (GPG --decrypt) and extracts the tar.gz
#
set -euo pipefail
IFS=$'\n\t'

REMOTE_URL="${1:-}"
WORKDIR="${2:-}"
PASSPHRASE_FILE="${3:-}"

if [[ -z "$REMOTE_URL" || -z "$WORKDIR" || -z "$PASSPHRASE_FILE" ]]; then
  echo "Usage: $0 git@github.com:YOU/encrypted-repo.git /path/to/workdir /path/to/passphrase_file"
  exit 2
fi

# Required tools
for tool in git gpg cat tar gzip; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Required tool '$tool' not found in PATH."; exit 3; }
done

if [[ ! -f "$PASSPHRASE_FILE" ]]; then
  echo "Passphrase file not found at $PASSPHRASE_FILE"
  exit 4
fi
chmod 600 "$PASSPHRASE_FILE"

if [[ ! -d "$WORKDIR" ]]; then
  echo "Cloning $REMOTE_URL into $WORKDIR ..."
  git clone "$REMOTE_URL" "$WORKDIR"
else
  echo "Updating existing repo at $WORKDIR ..."
  git -C "$WORKDIR" pull --ff-only
fi

cd "$WORKDIR"

# Find the newest snapshot prefix by listing snapshot_*.asc.part* and grouping by timestamp
shopt -s nullglob
PART_FILES=( snapshot_*.asc.part* )

if [[ ${#PART_FILES[@]} -eq 0 ]]; then
  echo "No part files (snapshot_*.asc.partNNN) found in repo. Exiting."
  exit 5
fi

# Determine the snapshot prefix (use the most recent timestamped prefix)
# Example filename: snapshot_20251003T... .asc.part000
# Extract prefixes before .partNNN
declare -A prefixes
for f in "${PART_FILES[@]}"; do
  # remove .partNNN suffix
  prefix="${f%.*part[0-9][0-9][0-9]}"
  prefixes["$prefix"]=1
done

# pick the lexicographically largest prefix (timestamps in name ensure recency)
selected_prefix=""
for p in "${!prefixes[@]}"; do
  if [[ -z "$selected_prefix" || "$p" > "$selected_prefix" ]]; then
    selected_prefix="$p"
  fi
done

if [[ -z "$selected_prefix" ]]; then
  echo "Failed to determine snapshot prefix. Exiting."
  exit 6
fi

RECONSTRUCT_ASC="${selected_prefix}part"   # used to reassemble parts, then we will trim trailing "part"
# Actually reconstruct by concatenating the ordered parts.
# The parts are expected to have suffixes .part000 .part001 ...
RECONSTRUCT_FILE="${selected_prefix}.reconstructed.asc"
echo "Reassembling parts for prefix: $selected_prefix -> $RECONSTRUCT_FILE"

# Ensure we concatenate in correct numeric order
ls -1 "${selected_prefix}"*.part* | sort | xargs cat > "$RECONSTRUCT_FILE"

# The reconstructed file should be an ASCII-armored GPG file (.asc)
DECRYPTED_TAR="${WORKDIR}/reconstructed_${TIMESTAMP:-$(date -u +"%Y%m%dT%H%M%SZ")}.tar.gz"
echo "Decrypting $RECONSTRUCT_FILE -> $DECRYPTED_TAR"
gpg --batch --yes --passphrase-file "$PASSPHRASE_FILE" -o "$DECRYPTED_TAR" -d "$RECONSTRUCT_FILE"

DEST_DIR="${WORKDIR}/decrypted_${TIMESTAMP:-$(date -u +"%Y%m%dT%H%M%SZ")}"
mkdir -p "$DEST_DIR"
echo "Extracting $DECRYPTED_TAR -> $DEST_DIR/"
tar -xzf "$DECRYPTED_TAR" -C "$DEST_DIR"

echo "Extraction complete. Files available in: $(realpath "$DEST_DIR")"
# Optionally remove the big reconstructed and decrypted tar if desired:
# rm -f "$RECONSTRUCT_FILE" "$DECRYPTED_TAR"

