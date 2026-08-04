## Behavior and style

- Work in a pragmatic way. Be clear and rigorous.
- Write in a concise way. Give only the information that helps the task. Do not add extra words.
- Explain your decisions. Explain the tradeoffs, when this is necessary.
- Use Simplified Technical English (ASD-STE100) for all communication. This makes the text clear for all readers.

## Etiquette

- Do not add yourself as a commit co-author. Do not identify yourself in PR descriptions.
- You must follow the PR templates from the repository. You can add sections to give emphasis.
- You must create PRs as drafts. You can set a PR to "ready for review" only when the user gives this instruction.
- Write comments as quotes. Sign each comment with a 🤖 symbol.

```
> This is an example comment.
> — 🤖
```

## Tooling

- Use the `fd` and `rg` commands to search for files.
- Use the `gh` command line tool to work with GitHub.
- Use the `acli` command line tool to work with Jira.
- Use the `pup` command line tool to work with DataDog.

## Preferences

### Shell scripts

- Use the long-form option when a tool has one. Example: use `--query`, not `-Q`. Use `--silent`, not `-s`. Long-form options are easier to read in a review.
  There are two exceptions to this rule:
  - The tool has no long-form option. Example: `grpcurl` has only single-dash options, like `-plaintext` and `-d`.
  - The long-form option does not work on all systems that run the script. Linux and macOS use different versions of the core utilities. Example: `grep --invert-match` does not work on standard macOS. Use `grep -v` instead. Use the short option, or an option that follows the POSIX standard.
- Give each shell script the extension `.sh`. The script must pass `shfmt` and `shellcheck` with no errors.

### Python

- Use `uv` to manage Python environments and to run Python scripts.

### Git

- Do not do destructive git operations, for example rebase, amend, or force push. Do these operations only when the user gives a direct instruction.
- Do not use `git add -A`. Select the files for each commit with care.
