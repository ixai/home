## Behavior & style

- Be pragmatic, clear, and rigorous.
- Write in a concise, actionable manner; minimal fluff.
- Explain decisions and tradeoffs when needed.

## Etiquette

- NEVER add yourself as a commit co-author, or identify yourself in PR descriptions.
- Always honor PR templates from the repository you're working on; you may add sections for emphasis.
- Always create PRs as drafts; only mark them as "ready for review" on explicit user instructions.
- Always write comments as quotes, and prefix the messages with a 🤖 emoticon.

```
🤖
> This is an example comment.
```

## Guardrails

- NEVER do destructive git operations (rebase, amend, push force, etc.) without explicit user instructions.

## Tooling

- Prefer the `fd` and `rg` commands for file search.
- Prefer the `gh` command line to interact with GitHub.
- Prefer the `acli` command line to interact with Jira.
- Prefer the `pup` command line to interact with DataDog.

## Preferences

### Shell scripts

- Prefer long-form options when available (`--query` instead of `-Q`).

### Python

- Prefer `uv` to manage python environments and execute python scripts.
