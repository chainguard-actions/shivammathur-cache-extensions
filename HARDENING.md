<!-- markdownlint-disable -->

# Hardening Report: shivammathur--cache-extensions/1.14.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **shivammathur--cache-extensions/1.14.5** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): GitHub Actions expressions are interpolated directly inside run: shell command strings. In e2e.yml, the 'Persist cache metadata' step uses `printf '%s\n' '${{ steps.extcache.outputs.key }}'` and `printf '%s\n' '${{ steps.extcache.outputs.dir }}'` directly in the shell script. The 'Verify computed cache metadata' step uses `test '${{ steps.extcache.outputs.key }}' = '${{ steps.metadata.outputs.key }}'` and `test '${{ steps.extcache.outputs.dir }}' = '${{ steps.metadata.outputs.dir }}'` directly in the shell script. In git-release.yml, the 'Update tags and branches' step embeds `${{ github.repository_owner }}`, `${{ secrets.GITHUB_TOKEN }}`, and `${{ github.repository }}` directly inside git push URLs in the run: block. All of these are YAML-template-substituted before the shell sees them, enabling script injection.

Locations:

- `.github/workflows/e2e.yml:47`
- `.github/workflows/e2e.yml:48`
- `.github/workflows/e2e.yml:97`
- `.github/workflows/e2e.yml:98`
- `.github/workflows/git-release.yml:60`
- `.github/workflows/git-release.yml:65`
- `.github/workflows/git-release.yml:70`

### unpinned-uses (severity: high)

All workflow files reference external actions using mutable tag-based refs instead of immutable full 40-character SHA digests, making the workflows vulnerable to supply-chain attacks if any referenced action tag is moved or compromised. Failing references include: codeql.yml: actions/checkout@v6, github/codeql-action/init@v4, github/codeql-action/autobuild@v4, github/codeql-action/analyze@v4. e2e.yml: actions/checkout@v6, shivammathur/setup-php@v2, actions/upload-artifact@v7, actions/cache/save@v5, actions/download-artifact@v8, actions/cache/restore@v5. git-release.yml: actions/upload-artifact@v4, actions/checkout@v6, actions/setup-node@v6, actions/download-artifact@v8. node-release.yml: actions/checkout@v6, actions/setup-node@v6 (×2). node-test.yml: actions/checkout@v6, actions/setup-node@v6, codecov/codecov-action@v5.

Locations:

- `.github/workflows/codeql.yml:10`
- `.github/workflows/codeql.yml:15`
- `.github/workflows/codeql.yml:20`
- `.github/workflows/codeql.yml:23`
- `.github/workflows/e2e.yml:26`
- `.github/workflows/e2e.yml:35`
- `.github/workflows/e2e.yml:55`
- `.github/workflows/e2e.yml:65`
- `.github/workflows/e2e.yml:79`
- `.github/workflows/e2e.yml:88`
- `.github/workflows/git-release.yml:21`
- `.github/workflows/git-release.yml:32`
- `.github/workflows/git-release.yml:36`
- `.github/workflows/git-release.yml:40`
- `.github/workflows/node-release.yml:18`
- `.github/workflows/node-release.yml:24`
- `.github/workflows/node-release.yml:37`
- `.github/workflows/node-test.yml:12`
- `.github/workflows/node-test.yml:17`
- `.github/workflows/node-test.yml:30`

### missing-permissions (severity: medium)

Several workflow files lack permissions declarations on one or more jobs, meaning they run with the default (potentially broad) GITHUB_TOKEN permissions. git-release.yml has no top-level permissions block and the 'update' job has no job-level permissions key (only the 'sync' job has permissions). codeql.yml has no top-level permissions block and no job-level permissions on the 'codeql' job. node-test.yml has no top-level permissions block and no job-level permissions on the 'run' job.

Locations:

- `.github/workflows/git-release.yml:7`
- `.github/workflows/codeql.yml:7`
- `.github/workflows/node-test.yml:3`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all three finding categories across five workflow files:

1. script-injection (e2e.yml + git-release.yml): Moved all ${{ }} expressions out of run: shell strings into step-level env: blocks. In e2e.yml, steps.extcache.outputs.key/dir and steps.metadata.outputs.key/dir are now env vars EXTCACHE_KEY, EXTCACHE_DIR, METADATA_KEY, METADATA_DIR. In git-release.yml, github.repository_owner, secrets.GITHUB_TOKEN, and github.repository are now env vars REPO_OWNER, PUSH_TOKEN, REPO_NAME used in git push URLs.

2. unpinned-uses: All action references pinned to full 40-char SHAs with original tag as comment: actions/checkout@v6→d23441a, shivammathur/setup-php@v2→f3e473d, actions/upload-artifact@v7→043fb46, actions/upload-artifact@v4→ea165f8, actions/cache/save@v5→caa2961, actions/download-artifact@v8→3e5f45b, actions/cache/restore@v5→caa2961, github/codeql-action/{init,autobuild,analyze}@v4→e4fba86, actions/setup-node@v6→249970, codecov/codecov-action@v5→0fb7174.

3. missing-permissions: Added top-level 'permissions: {}' to git-release.yml, codeql.yml, and node-test.yml. Added job-level permissions: update job gets 'contents: read', codeql job gets 'actions: read / contents: read / security-events: write', run job gets 'contents: read'.

