<!-- markdownlint-disable -->

# Hardening Report: shivammathur--cache-extensions/1.14.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **shivammathur--cache-extensions/1.14.6** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

All uses: references across all workflow files use mutable tags instead of full 40-character SHA commit digests, making the workflows vulnerable to supply-chain attacks if the referenced action tags are moved or compromised.

codeql.yml: actions/checkout@v6, github/codeql-action/init@v4, github/codeql-action/autobuild@v4, github/codeql-action/analyze@v4
e2e.yml: actions/checkout@v6, shivammathur/setup-php@v2, actions/upload-artifact@v7, actions/cache/save@v5, actions/download-artifact@v8, actions/cache/restore@v5
git-release.yml: actions/upload-artifact@v4, actions/checkout@v6, actions/setup-node@v6, actions/download-artifact@v8
node-release.yml: actions/checkout@v6 (×2), actions/setup-node@v6 (×2)
node-test.yml: actions/checkout@v6, actions/setup-node@v6, codecov/codecov-action@v5

Locations:

- `.github/workflows/codeql.yml:10`
- `.github/workflows/e2e.yml:24`
- `.github/workflows/git-release.yml:17`
- `.github/workflows/node-release.yml:20`
- `.github/workflows/node-test.yml:11`

### missing-permissions (severity: medium)

Several workflow files lack a top-level permissions: block and have jobs without job-level permissions, meaning they run with the default (potentially broad) GITHUB_TOKEN permissions.

- codeql.yml: No top-level permissions and no job-level permissions on the 'codeql' job.
- node-test.yml: No top-level permissions and no job-level permissions on the 'run' job.
- git-release.yml: No top-level permissions; the 'update' job has no job-level permissions (only the 'sync' job has permissions: contents: write).

Locations:

- `.github/workflows/codeql.yml:1`
- `.github/workflows/node-test.yml:1`
- `.github/workflows/git-release.yml:7`

### script-injection (severity: high)

GitHub Actions expressions (${{ ... }}) are interpolated directly inside run: shell command strings, violating sub-rule (a). YAML template substitution occurs before the shell parses the string, so an attacker-controlled or mutable value can inject arbitrary shell commands.

git-release.yml — 'Update tags and branches' step: ${{ github.repository_owner }}, ${{ secrets.GITHUB_TOKEN }}, and ${{ github.repository }} are embedded directly inside shell URL strings used in git push commands (e.g., `git push https://${{ github.repository_owner }}:${{ secrets.GITHUB_TOKEN }}@github.com/${{ github.repository }}.git ...`). Even though secrets.GITHUB_TOKEN is a secret, the ${{ }} interpolation still occurs at the YAML level before the shell sees it.

e2e.yml — 'Persist cache metadata' step: ${{ steps.extcache.outputs.key }} and ${{ steps.extcache.outputs.dir }} are interpolated directly inside a run: bash script (printf '%s\n' '${{ steps.extcache.outputs.key }}' > cache-key.txt). Single-quoting does not prevent YAML template substitution.

e2e.yml — 'Verify computed cache metadata' step: ${{ steps.extcache.outputs.key }}, ${{ steps.extcache.outputs.dir }}, ${{ steps.metadata.outputs.key }}, and ${{ steps.metadata.outputs.dir }} are interpolated directly inside run: shell test commands.

Locations:

- `.github/workflows/git-release.yml:56`
- `.github/workflows/e2e.yml:44`
- `.github/workflows/e2e.yml:96`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions, script-injection

**Notes:**

Fixed all three finding types across five workflow files:

1. unpinned-uses: Pinned all 10 distinct action references to full 40-char SHA digests with tag comments in codeql.yml, e2e.yml, git-release.yml, node-release.yml, and node-test.yml.

2. missing-permissions: Added top-level permissions blocks to codeql.yml (actions:read, contents:read, security-events:write for CodeQL), node-test.yml (contents:read), and git-release.yml (empty top-level {}). Added job-level permissions:actions:write to the git-release.yml 'update' job so it can upload artifacts.

3. script-injection: In git-release.yml 'Update tags and branches' step, moved github.repository_owner, secrets.GITHUB_TOKEN, and github.repository into env vars (REPO_OWNER, GIT_TOKEN, REPO_NAME) and replaced inline ${{ }} interpolations with ${VAR} references. In e2e.yml 'Persist cache metadata' step, moved steps.extcache.outputs.key and steps.extcache.outputs.dir into env vars. In e2e.yml 'Verify computed cache metadata' step, moved all four step output expressions into env vars.

