<!-- markdownlint-disable -->

# Hardening Report: shivammathur--cache-extensions/1.15.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **shivammathur--cache-extensions/1.15.1** was hardened automatically. 7 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

All workflow files use mutable version tags instead of pinned full-length SHA commit hashes for `uses:` references, making them vulnerable to supply-chain attacks if the referenced action is compromised or a tag is moved.

Failing references include:
- `actions/checkout@v6` (codeql.yml, e2e.yml, git-release.yml, node-release.yml, node-test.yml)
- `github/codeql-action/init@v4`, `github/codeql-action/autobuild@v4`, `github/codeql-action/analyze@v4` (codeql.yml)
- `shivammathur/setup-php@v2` (e2e.yml)
- `actions/upload-artifact@v7`, `actions/cache/save@v5`, `actions/cache/restore@v5`, `actions/download-artifact@v8` (e2e.yml)
- `actions/upload-artifact@v4`, `actions/setup-node@v6`, `actions/download-artifact@v8` (git-release.yml)
- `actions/setup-node@v6` (node-release.yml, node-test.yml)
- `codecov/codecov-action@v5` (node-test.yml)

Locations:

- `.github/workflows/codeql.yml:10`
- `.github/workflows/e2e.yml:24`
- `.github/workflows/git-release.yml:18`
- `.github/workflows/node-release.yml:18`
- `.github/workflows/node-test.yml:11`

### permissions (severity: medium)

missing-permissions: `codeql.yml` has no top-level `permissions:` key and its only job (`codeql`) also has no `permissions:` key. Without explicit permissions, the workflow inherits the default token permissions, which may be overly broad.

Locations:

- `.github/workflows/codeql.yml:1`

### permissions (severity: medium)

missing-permissions: `node-test.yml` has no top-level `permissions:` key and its only job (`run`) also has no `permissions:` key. Without explicit permissions, the workflow inherits the default token permissions, which may be overly broad.

Locations:

- `.github/workflows/node-test.yml:1`

### permissions (severity: medium)

missing-permissions: `git-release.yml` has no top-level `permissions:` key and the `update` job has no job-level `permissions:` key (only the `sync` job has `permissions: contents: write`). The `update` job therefore runs with default token permissions.

Locations:

- `.github/workflows/git-release.yml:7`

### script-injection (severity: high)

Sub-rule (a): `${{ steps.extcache.outputs.key }}` and `${{ steps.extcache.outputs.dir }}` are interpolated directly inside `run:` shell command strings in the "Persist cache metadata" step. These step output values flow through YAML template substitution before the shell sees them, allowing an attacker who can influence the action's outputs to inject arbitrary shell commands.

Offending lines:
  `printf '%s\n' '${{ steps.extcache.outputs.key }}' > cache-key.txt`
  `printf '%s\n' '${{ steps.extcache.outputs.dir }}' > cache-dir.txt`

Locations:

- `.github/workflows/e2e.yml:43`

### script-injection (severity: high)

Sub-rule (a): `${{ steps.extcache.outputs.key }}` and `${{ steps.metadata.outputs.key }}` (and their `dir` counterparts) are interpolated directly inside a `run:` shell command string in the "Verify computed cache metadata" step. These step output values flow through YAML template substitution before the shell sees them.

Offending lines:
  `test '${{ steps.extcache.outputs.key }}' = '${{ steps.metadata.outputs.key }}'`
  `test '${{ steps.extcache.outputs.dir }}' = '${{ steps.metadata.outputs.dir }}'`

Locations:

- `.github/workflows/e2e.yml:87`

### script-injection (severity: high)

Sub-rule (a): `${{ github.repository_owner }}` and `${{ github.repository }}` are interpolated directly inside `run:` shell command strings in the "Update tags and branches" step. These `github.*` context values are substituted by the YAML template engine before the shell executes the command, allowing a malicious repository owner or repository name to inject shell metacharacters.

Offending lines (repeated in push_branch, push_tag, and force_tag functions):
  `git push https://${{ github.repository_owner }}:${{ secrets.GITHUB_TOKEN }}@github.com/${{ github.repository }}.git ...`

Locations:

- `.github/workflows/git-release.yml:56`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, permissions, script-injection

**Notes:**

Fixed all findings across 5 workflow files:

1. **unpinned-uses**: Pinned all action references to full SHA hashes:
   - actions/checkout@v6 → @d23441a48e516b6c34aea4fa41551a30e30af803
   - github/codeql-action/{init,autobuild,analyze}@v4 → @ff2f1c621b7f889edc0d3c761ac2e6a3f8cdb0dd
   - shivammathur/setup-php@v2 → @f3e473d116dcccaddc5834248c87452386958240
   - actions/upload-artifact@v7 → @043fb46d1a93c77aae656e7c1c64a875d1fc6a0a
   - actions/upload-artifact@v4 → @ea165f8d65b6e75b540449e92b4886f43607fa02
   - actions/cache/save@v5 and cache/restore@v5 → @caa296126883cff596d87d8935842f9db880ef25
   - actions/download-artifact@v8 → @3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c
   - actions/setup-node@v6 → @249970729cb0ef3589644e2896645e5dc5ba9c38
   - codecov/codecov-action@v5 → @0fb7174895f61a3b6b78fc075e0cd60383518dac

2. **permissions**: Added missing permissions blocks:
   - codeql.yml: top-level `actions: read, contents: read, security-events: write`
   - node-test.yml: top-level `contents: read`
   - git-release.yml: `contents: read` added to the `update` job

3. **script-injection**: Fixed all three injection points:
   - e2e.yml "Persist cache metadata" step: moved steps.extcache.outputs.{key,dir} to env: block
   - e2e.yml "Verify computed cache metadata" step: moved all four step outputs to env: block
   - git-release.yml "Update tags and branches" step: moved github.repository_owner and github.repository to env: block as REPO_OWNER and REPO_NAME, updated all git push URLs to use ${REPO_OWNER} and ${REPO_NAME}

