#!/usr/bin/env bash
# Stub cache.sh for testing purposes
# Called as: bash cache.sh <action> <extensions> <php-version> <key>

action="${1}"
extensions="${2}"
php_version="${3}"
cache_key="${4}"

# Compute a hash of the extensions and php version for the cache key
ext_hash=$(echo "${extensions}${php_version}" | md5sum | cut -d' ' -f1)
full_key="${cache_key}-php${php_version}-${ext_hash}"

# Set up the cache directory
cache_dir="${RUNNER_TEMP:-/tmp}/php-ext-cache/${full_key}"
mkdir -p "${cache_dir}"

# Write outputs to RUNNER_TEMP for getOutput() calls
echo "${full_key}" > "${RUNNER_TEMP:-/tmp}/key"
echo "${cache_dir}" > "${RUNNER_TEMP:-/tmp}/dir"

# Set GitHub Actions outputs
if [ -n "${GITHUB_OUTPUT}" ]; then
  echo "key=${full_key}" >> "${GITHUB_OUTPUT}"
  echo "dir=${cache_dir}" >> "${GITHUB_OUTPUT}"
fi
