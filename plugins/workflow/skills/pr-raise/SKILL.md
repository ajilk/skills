---
name: pr:raise
description: >
  Analyzes branch changes, generates a structured PR with summary and
  key files to review, confirms with the user, then creates the PR.
allowed-tools:
  - Bash(git status)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git branch *)
  - Bash(git rev-parse *)
  - Bash(git remote *)
  - Bash(git push *)
  - Bash(gh pr *)
  - AskUserQuestion
disable-model-invocation: true
---

# PR Raise

Analyze all commits on the current branch, generate a PR description, and create the PR after confirmation.

## Steps

1. **Gather context**

   Run these commands to understand the branch:

   - `git branch --show-current` — current branch name
   - `git rev-parse --abbrev-ref HEAD@{upstream}` — check if tracking a remote
   - `git log --oneline main..HEAD` — all commits since diverging from base
   - `git diff main..HEAD --stat` — file-level change summary
   - `git diff main..HEAD` — full diff for analysis

   If the base branch is not `main`, try `master`. Use whatever exists.

2. **Analyze and present**

   Study all commits and the full diff, then produce this structured output:

   ```
   ## PR Title

   <short title under 70 chars>

   ## Base Branch

   <detected base> (e.g. main)

   ## Summary

   <2-4 sentence description of what this PR does and why>

   ## Key Files to Review

   | File              | Why                          |
   |-------------------|------------------------------|
   | path/to/file.ts   | Core logic change            |
   | path/to/other.ts  | New utility added            |

   ## Notes

   <Anything worth calling out — breaking changes, migrations,
   dependencies, follow-up work, or "None">
   ```

   - Focus the summary on the **why**, not just the what.
   - Key files should highlight the most important files a reviewer should focus on — not every file changed.
   - Notes should flag anything a reviewer needs to be aware of.

3. **Confirm**

   Ask the user to confirm or request edits via AskUserQuestion:

   - Create PR as-is
   - Edit title or description
   - Change base branch

4. **Push if needed**

   If the branch has not been pushed to the remote, ask the user for confirmation before pushing with `git push -u origin <branch>`.

5. **Create PR**

   Create the PR using `gh pr create`:

   ```bash
   gh pr create --title "<title>" --base "<base>" --body "$(cat <<'EOF'
   ## Summary

   <summary content>

   ## Key Files to Review

   | File              | Why                          |
   |-------------------|------------------------------|
   | ...               | ...                          |

   ## Notes

   <notes content>
   EOF
   )"
   ```

   Print the PR URL when done.

## Rules

- Analyze ALL commits on the branch, not just the latest one.
- Do NOT force push.
- Do NOT merge the PR.
- Do NOT modify any files — this skill is read-only except for git/gh commands.
