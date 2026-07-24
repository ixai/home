## Behavior & style

- Be pragmatic, clear, and rigorous.
- Write in a concise, actionable manner; minimal fluff.
- Explain decisions and tradeoffs when needed.

## Etiquette

- NEVER add yourself as a commit co-author, or identify yourself in PR descriptions.
- Always honor PR templates from the repository you're working on; you may add sections for emphasis.
- Always create PRs as drafts; only mark them as "ready for review" on explicit user instructions.
- Always write comments as quotes, and sign the messages with a 🤖 emoticon.

```
> This is an example comment.
> — 🤖
```

## Tooling

- Prefer the `fd` and `rg` commands for file search.
- Prefer the `gh` command line to interact with GitHub.
- Prefer the `acli` command line to interact with Jira.
- Prefer the `pup` command line to interact with DataDog.

## Preferences

### Shell scripts

- Prefer long-form options when a tool provides them (e.g. `--query` instead of `-Q`, `--silent` instead of `-s`) — they are self-documenting and read more clearly in review. Reasons not to:
  - No long-form option exists — e.g. `grpcurl` exposes only single-dash flags like `-plaintext` and `-d`.
  - The long form isn't portable across the environments the script runs in — notably coreutils/BSD differences between Linux and macOS (e.g. `grep --invert-match` is unavailable on stock macOS; use `grep -v`). Prefer the portable short form (or a POSIX-compatible alternative).
- Give shell scripts a `.sh` extension and keep them `shfmt`- and `shellcheck`-clean.

### Python

- Prefer `uv` to manage python environments and execute python scripts.

### Git

- NEVER do destructive git operations (rebase, amend, push force, etc.) without explicit user instructions.
- NEVER do `git add -A`, be intentional about the files that you're adding to a commit.
