<!-- markdownlint-disable -->

# Hardening Report: shivammathur--cache-extensions/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **shivammathur--cache-extensions/v1** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files reference GitHub Actions using mutable version tags instead of full 40-character SHA commit hashes. This exposes the workflow to supply-chain attacks if a tag is moved or a repository is compromised. Affected references include: actions/checkout@v6, shivammathur/setup-php@v2, actions/upload-artifact@v7, actions/cache/save@v5, actions/download-artifact@v8, actions/cache/restore@v5, actions/setup-node@v6, github/codeql-action/init@v4, github/codeql-action/autobuild@v4, github/codeql-action/analyze@v4, codecov/codecov-action@v5, actions/upload-artifact@v4.

Locations:

- `.github/workflows/e2e.yml:1`
- `.github/workflows/git-release.yml:1`
- `.github/workflows/node-release.yml:1`
- `.github/workflows/codeql.yml:1`
- `.github/workflows/node-test.yml:1`

### missing-permissions (severity: medium)

codeql.yml has no top-level `permissions:` key and no job-level `permissions:` on its only job (`codeql`), granting the default (broad) token permissions to the workflow.

Locations:

- `.github/workflows/codeql.yml:1`

### missing-permissions (severity: medium)

node-test.yml has no top-level `permissions:` key and no job-level `permissions:` on its only job (`run`), granting the default (broad) token permissions to the workflow.

Locations:

- `.github/workflows/node-test.yml:1`

### missing-permissions (severity: medium)

git-release.yml has no top-level `permissions:` key, and the `update` job has no job-level `permissions:` block (only the `sync` job does). The `update` job therefore runs with default broad token permissions.

Locations:

- `.github/workflows/git-release.yml:1`

### script-injection (severity: high)

Rule (a) violation: The 'Persist cache metadata' step in the seed-cache job directly interpolates `${{ steps.extcache.outputs.key }}` and `${{ steps.extcache.outputs.dir }}` inside a `run:` shell command. These step output expressions are substituted by the Actions template engine before the shell sees them, allowing injection of shell metacharacters if the action produces a malicious output value. Offending lines: `printf '%s\n' '${{ steps.extcache.outputs.key }}' > cache-key.txt` and `printf '%s\n' '${{ steps.extcache.outputs.dir }}' > cache-dir.txt`.

Locations:

- `.github/workflows/e2e.yml:43`

### script-injection (severity: high)

Rule (a) violation: The 'Verify computed cache metadata' step in the restore-cache job directly interpolates `${{ steps.extcache.outputs.key }}`, `${{ steps.extcache.outputs.dir }}`, `${{ steps.metadata.outputs.key }}`, and `${{ steps.metadata.outputs.dir }}` inside a `run:` shell command. These expressions are substituted before the shell parses the command, enabling script injection. Offending lines: `test '${{ steps.extcache.outputs.key }}' = '${{ steps.metadata.outputs.key }}'` and `test '${{ steps.extcache.outputs.dir }}' = '${{ steps.metadata.outputs.dir }}'`.

Locations:

- `.github/workflows/e2e.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions, script-injection

**Notes:**

Fixed all findings across 5 workflow files:

1. unpinned-uses: Pinned all 12 action references to full 40-char SHAs with original tag as comment in e2e.yml, git-release.yml, node-release.yml, codeql.yml, and node-test.yml.

2. missing-permissions (codeql.yml): Added top-level permissions block with `contents: read` and `security-events: write` (required for CodeQL to upload SARIF results).

3. missing-permissions (node-test.yml): Added top-level `permissions: contents: read`.

4. missing-permissions (git-release.yml): Added `permissions: contents: read` to the `update` job which previously had no permissions block.

5. script-injection (e2e.yml, seed-cache/Persist cache metadata): Moved `${{ steps.extcache.outputs.key }}` and `${{ steps.extcache.outputs.dir }}` to the step's `env:` block as EXTCACHE_KEY and EXTCACHE_DIR, referenced as plain env vars in the shell script.

6. script-injection (e2e.yml, restore-cache/Verify computed cache metadata): Moved all four step output expressions to the step's `env:` block as EXTCACHE_KEY, EXTCACHE_DIR, METADATA_KEY, METADATA_DIR, referenced as plain env vars in the shell script.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in .github/workflows/git-release.yml at lines 69, 75, and 81. The three git push URLs that directly interpolated ${{ github.repository_owner }}, ${{ secrets.GITHUB_TOKEN }}, and ${{ github.repository }} in the run: block were updated to use environment variable references instead. GITHUB_REPOSITORY_OWNER and GITHUB_REPOSITORY are standard GitHub Actions env vars already available; PUSH_TOKEN was added to the step's env: block (mapped to ${{ secrets.GITHUB_TOKEN }}) and referenced as ${PUSH_TOKEN} in the shell script. The URLs are now double-quoted shell strings, preventing any template-engine injection.

