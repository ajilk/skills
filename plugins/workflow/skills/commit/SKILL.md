---
name: commit
description: >
  Analyzes staged changes, shows a colored summary table with file stats
  and a conventional commit message, then commits after confirmation.
  Use when the user wants to commit their work.
allowed-tools:
  - Bash(git status)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git add *)
  - Bash(git commit *)
  - Bash(zsh scripts/changes.zsh)
  - AskUserQuestion
---

# Commit

Analyze git changes and present a structured summary for review before committing.

## Steps

1. **Gather context**

   Run these commands to understand the current state:

   - `git status` — staged/unstaged changes
   - `git diff --staged --stat` — file-level change stats
   - `git diff --staged` — full diff for analysis
   - `git log --oneline -5` — recent commits for style reference

   If nothing is staged, automatically stage all tracked and untracked files using `git add .`, then re-run the diff commands above.

2. **Analyze and present**

   Study the diff and present in this exact format:

   ```
   commit: <type>(<scope>): <description>

   <2-3 sentence plain-English summary of what changed and why>
   ```

   Then run the changes table script:

   ```bash
   zsh scripts/changes.zsh
   ```

   Guidelines:
   - Infer `<type>`: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `perf`, `ci`, `build`
   - Infer `<scope>` from the primary area of change (omit parentheses if unclear)
   - Write a concise `<description>` under 72 characters
   - Match the tone/style of recent commits when possible

3. **Confirm**

   Ask the user to confirm or request edits via AskUserQuestion:

   - Commit as-is
   - Edit message (user provides updated message)

4. **Commit**

   Run the commit using a HEREDOC:

   ```bash
   git commit -m "$(cat <<'EOF'
   <final message>

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

## Rules

- Always append `Co-Authored-By: Claude <noreply@anthropic.com>` as a trailer.
- Do NOT push — only commit locally.
- Do NOT amend existing commits.
- Do NOT use `--no-verify`.
