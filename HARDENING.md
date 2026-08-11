<!-- markdownlint-disable -->

# Hardening Report: shivammathur--cache-extensions/1.15.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **shivammathur--cache-extensions/1.15.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

All `uses:` references across all workflow files are pinned to mutable version tags rather than immutable 40-character SHA digests, making the action vulnerable to supply-chain attacks if any upstream action is compromised or a tag is moved. Failing references include: actions/checkout@v6, actions/checkout@v6, actions/upload-artifact@v7, shivammathur/setup-php@v2, actions/cache/save@v5, actions/download-artifact@v8, actions/cache/restore@v5, github/codeql-action/init@v4, github/codeql-action/autobuild@v4, github/codeql-action/analyze@v4, actions/upload-artifact@v4, actions/setup-node@v6, actions/download-artifact@v8, actions/setup-node@v6, actions/setup-node@v6, codecov/codecov-action@v5, and others.

Locations:

- `.github/workflows/codeql.yml:10`
- `.github/workflows/codeql.yml:16`
- `.github/workflows/codeql.yml:21`
- `.github/workflows/codeql.yml:25`
- `.github/workflows/e2e.yml:24`
- `.github/workflows/e2e.yml:33`
- `.github/workflows/e2e.yml:50`
- `.github/workflows/e2e.yml:57`
- `.github/workflows/e2e.yml:66`
- `.github/workflows/e2e.yml:67`
- `.github/workflows/e2e.yml:78`
- `.github/workflows/e2e.yml:83`
- `.github/workflows/e2e.yml:96`
- `.github/workflows/e2e.yml:107`
- `.github/workflows/git-release.yml:22`
- `.github/workflows/git-release.yml:31`
- `.github/workflows/git-release.yml:36`
- `.github/workflows/git-release.yml:40`
- `.github/workflows/node-release.yml:18`
- `.github/workflows/node-release.yml:21`
- `.github/workflows/node-release.yml:29`
- `.github/workflows/node-release.yml:40`
- `.github/workflows/node-test.yml:12`
- `.github/workflows/node-test.yml:17`
- `.github/workflows/node-test.yml:30`

### script-injection (severity: high)

Rule (a): GitHub Actions expressions are interpolated directly inside `run:` shell command strings. In e2e.yml, the 'Persist cache metadata' step uses `printf '%s\n' '${{ steps.extcache.outputs.key }}'` and `printf '%s\n' '${{ steps.extcache.outputs.dir }}'` — the `steps.*.outputs.*` values are substituted by the template engine before the shell sees them, enabling injection. The 'Verify computed cache metadata' step similarly uses `test '${{ steps.extcache.outputs.key }}' = '${{ steps.metadata.outputs.key }}'` and `test '${{ steps.extcache.outputs.dir }}' = '${{ steps.metadata.outputs.dir }}'` directly in shell. In git-release.yml, the 'Update tags and branches' step embeds `${{ github.repository_owner }}` and `${{ github.repository }}` directly inside git push URLs in the run block.

Locations:

- `.github/workflows/e2e.yml:44`
- `.github/workflows/e2e.yml:88`
- `.github/workflows/git-release.yml:57`

### missing-permissions (severity: medium)

Several workflow files lack both a top-level `permissions:` key and job-level `permissions:` keys on all jobs, meaning they run with the default (potentially broad) token permissions. codeql.yml has no top-level permissions and its single job `codeql` has no job-level permissions. node-test.yml has no top-level permissions and its single job `run` has no job-level permissions. git-release.yml has no top-level permissions and its `update` job has no job-level permissions (only the `sync` job does).

Locations:

- `.github/workflows/codeql.yml:1`
- `.github/workflows/node-test.yml:1`
- `.github/workflows/git-release.yml:7`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, missing-permissions

**Notes:**

Fixed all findings across 5 workflow files:

1. unpinned-uses: Pinned all uses: references to full 40-char SHAs with tag comments in codeql.yml, e2e.yml, git-release.yml, node-release.yml, and node-test.yml.

2. script-injection: In e2e.yml, moved steps.extcache.outputs.key/dir expressions from run: shell strings into env: blocks (Persist cache metadata and Verify computed cache metadata steps). In git-release.yml, moved github.repository_owner and github.repository from inline git push URLs into env: block as REPO_OWNER and REPO_NAME, referenced as ${REPO_OWNER}/${REPO_NAME} in the shell.

3. missing-permissions: Added top-level permissions: {contents: read, security-events: write} to codeql.yml (security-events: write needed for CodeQL to upload SARIF results). Added top-level permissions: {contents: read} to node-test.yml. Added top-level permissions: {contents: read} to git-release.yml and explicit permissions: {contents: read} to the update job (sync job already had contents: write).

