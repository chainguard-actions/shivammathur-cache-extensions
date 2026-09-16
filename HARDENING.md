<!-- markdownlint-disable -->

# Hardening Report: shivammathur--cache-extensions/1.14.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **shivammathur--cache-extensions/1.14.3** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

All `uses:` references across all workflow files use mutable tag-based refs instead of full 40-character SHA commit digests, making the workflows vulnerable to supply-chain attacks if the referenced action tags are moved or compromised. Failing references include: codeql.yml: actions/checkout@v6, github/codeql-action/init@v4, github/codeql-action/autobuild@v4, github/codeql-action/analyze@v4; e2e.yml: actions/checkout@v6, shivammathur/setup-php@v2, actions/upload-artifact@v7, actions/cache/save@v5, actions/download-artifact@v8, actions/cache/restore@v5; git-release.yml: actions/upload-artifact@v4, actions/checkout@v6, actions/setup-node@v6, actions/download-artifact@v8; node-release.yml: actions/checkout@v6 (×2), actions/setup-node@v6 (×2); node-test.yml: actions/checkout@v6, actions/setup-node@v6, codecov/codecov-action@v5.

Locations:

- `.github/workflows/codeql.yml:10`
- `.github/workflows/e2e.yml:28`
- `.github/workflows/git-release.yml:20`
- `.github/workflows/node-release.yml:13`
- `.github/workflows/node-test.yml:10`

### missing-permissions (severity: medium)

Three workflow files lack adequate permissions declarations: (1) codeql.yml has no top-level `permissions:` key and no job-level `permissions:` on its only job, so it runs with the default (broad) token permissions. (2) node-test.yml has no top-level `permissions:` key and no job-level `permissions:` on its only job. (3) git-release.yml has no top-level `permissions:` key and its `update` job has no job-level `permissions:` block (only the `sync` job does), so the `update` job runs with default broad permissions.

Locations:

- `.github/workflows/codeql.yml:1`
- `.github/workflows/node-test.yml:1`
- `.github/workflows/git-release.yml:7`

### script-injection (severity: high)

Multiple `run:` blocks directly interpolate `${{ ... }}` expressions into shell command strings (sub-rule a), allowing expression values to be interpreted as shell code before the shell ever sees them.

(1) e2e.yml 'Persist cache metadata' step: `printf '%s\n' '${{ steps.extcache.outputs.key }}' > cache-key.txt` and `printf '%s\n' '${{ steps.extcache.outputs.dir }}' > cache-dir.txt` — step output values are interpolated directly into the shell command.

(2) e2e.yml 'Verify computed cache metadata' step: `test '${{ steps.extcache.outputs.key }}' = '${{ steps.metadata.outputs.key }}'` and `test '${{ steps.extcache.outputs.dir }}' = '${{ steps.metadata.outputs.dir }}'` — step output values are interpolated directly into shell test commands.

(3) git-release.yml 'Update tags and branches' step: `git push https://${{ github.repository_owner }}:${{ secrets.GITHUB_TOKEN }}@github.com/${{ github.repository }}.git ...` — github context values are interpolated directly into shell commands inside function bodies.

Locations:

- `.github/workflows/e2e.yml:54`
- `.github/workflows/e2e.yml:100`
- `.github/workflows/git-release.yml:66`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions, script-injection

**Notes:**

Fixed all findings across 5 workflow files:

1. unpinned-uses: Pinned all action references to full SHA digests:
   - actions/checkout@v6 → @d23441a48e516b6c34aea4fa41551a30e30af803
   - github/codeql-action/{init,autobuild,analyze}@v4 → @ff2f1c621b7f889edc0d3c761ac2e6a3f8cdb0dd
   - shivammathur/setup-php@v2 → @f3e473d116dcccaddc5834248c87452386958240
   - actions/upload-artifact@v7 → @043fb46d1a93c77aae656e7c1c64a875d1fc6a0a
   - actions/upload-artifact@v4 → @ea165f8d65b6e75b540449e92b4886f43607fa02
   - actions/cache/save@v5 → @caa296126883cff596d87d8935842f9db880ef25
   - actions/cache/restore@v5 → @caa296126883cff596d87d8935842f9db880ef25
   - actions/download-artifact@v8 → @3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c
   - actions/setup-node@v6 → @249970729cb0ef3589644e2896645e5dc5ba9c38
   - codecov/codecov-action@v5 → @0fb7174895f61a3b6b78fc075e0cd60383518dac

2. missing-permissions:
   - codeql.yml: Added top-level permissions (actions: read, contents: read, security-events: write)
   - node-test.yml: Added top-level permissions (contents: read)
   - git-release.yml update job: Added job-level permissions (contents: read)

3. script-injection:
   - e2e.yml 'Persist cache metadata': Moved steps.extcache.outputs.{key,dir} to env block
   - e2e.yml 'Verify computed cache metadata': Moved all four step output expressions to env block
   - git-release.yml 'Update tags and branches': Moved github.repository_owner, secrets.GITHUB_TOKEN, and github.repository to env block as REPO_OWNER, GITHUB_TOKEN, REPO_NAME; updated push functions to use these env vars

