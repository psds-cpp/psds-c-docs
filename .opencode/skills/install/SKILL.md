---
name: install
description: Compiling and installing PDF documents in this project
---

# When to use

When finishing task and checking if everything is on order.
Same actions will run in release workflow (see `.github/workflows/release.yml`).

# Install all documents

To compile and install all documents in this project:

1. Add all relevant files to a Git index with `git add`.

2. Build Nix derivation:
  ```shell
  nix build . > /tmp/opencode/nix-build.out 2>&1
  ```
  The LLM gateway rejects request bodies over ~1 MiB with HTTP 413:
  never let the build output flow into the tool result.
  Inspect only small windows afterwards:
  ```shell
  tail -n 30 /tmp/opencode/nix-build.out
  grep -n -E "^error|error:" /tmp/opencode/nix-build.out
  ```

Use `build` skill to debug possible errors.

## Installation artifacts

* `result/presentations/*.pdf`: symlink to compiled documents in Nix storage.
