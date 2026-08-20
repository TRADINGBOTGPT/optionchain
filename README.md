# optionchain

Working repo set up for spec-driven development with **[Spec Kit](https://github.com/github/spec-kit)**
and parallel agent sessions with **[claude-squad](https://github.com/smtg-ai/claude-squad)**.

The previous Azure Functions timer-trigger scaffold has been removed; this is a
clean slate.

## What's here

```
.specify/                 Spec Kit templates, scripts, and project memory
  memory/constitution.md  Project principles (still the unfilled template)
  templates/              spec / plan / tasks / checklist templates
  scripts/bash/           Helper scripts the agent runs
.claude/skills/speckit-*  Spec Kit skills, exposed as /speckit-* commands
scripts/install-squad.sh  Reproducible claude-squad installer
```

## Spec Kit

Installed with the `claude` integration and `sh` scripts:

```bash
uvx --from git+https://github.com/github/spec-kit.git \
  specify init --here --integration claude --script sh
```

Spec Kit ships as skills rather than prompt files for this integration, so the
workflow runs as slash commands inside Claude Code:

| Command | Purpose |
| --- | --- |
| `/speckit-constitution` | Establish project principles (run once) |
| `/speckit-specify` | Write the feature specification |
| `/speckit-clarify` | *(optional)* De-risk ambiguity before planning |
| `/speckit-plan` | Produce the implementation plan |
| `/speckit-tasks` | Break the plan into actionable tasks |
| `/speckit-analyze` | *(optional)* Cross-artifact consistency check |
| `/speckit-implement` | Execute the tasks |

`/speckit-checklist` and `/speckit-converge` are also available. Start with
`/speckit-constitution` — `.specify/memory/constitution.md` is still the stock
template with `[PLACEHOLDER]` fields.

## claude-squad

`cs` runs several agents at once, each in its own tmux session and git worktree.

```bash
./scripts/install-squad.sh   # installs to ~/.local/bin/cs
cs                           # open the UI; press `n` for a new instance
cs -p "codex"                # launch with a different agent
```

Requires **tmux**; the GitHub CLI (`gh`) is optional but needed for its
push/PR shortcuts. Because `cs` is a machine-level binary rather than a project
dependency, it is not committed here — the script reinstalls it on any machine
or fresh container.

The installer prefers the upstream release installer and falls back to a Go
build from source when the GitHub releases API is unreachable.
