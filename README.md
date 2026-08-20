# optionchain

Working repo set up for spec-driven development with **[Spec Kit](https://github.com/github/spec-kit)**
and a persistent AI agent team with **[Squad](https://github.com/bradygaster/squad)**.

The previous Azure Functions timer-trigger scaffold has been removed; this is a
clean slate.

## What's here

```
.specify/                     Spec Kit templates, scripts, and project memory
  memory/constitution.md      Project principles (still the unfilled template)
  templates/                  spec / plan / tasks / checklist templates
  scripts/bash/               Helper scripts the agent runs
.claude/skills/speckit-*      Spec Kit skills, exposed as /speckit-* commands
.claude/agents/               Claude Code subagents (speckit-manager)
.squad/                       Squad team: roster, routing, charters, decisions
.github/agents/squad.agent.md Copilot agent prompt for the Squad coordinator
.github/skills/               Squad skills (collaboration, git workflow, ...)
.github/workflows/squad-*     Label-driven agent dispatch and triage
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

### speckit-manager agent

`.claude/agents/speckit-manager.md` defines a subagent that manages the
workflow rather than executing it. Ask it where the project stands and it
determines the phase from the artifacts on disk, enforces the gates between
phases, and names the next command. It edits spec artifacts but deliberately
does not write production code — that stays with `/speckit-implement`, so work
never gets written around the task list.

## Squad

Squad puts a persistent, file-backed agent team in the repo. `.squad/` holds the
roster (`team.md`), assignment rules (`routing.md`), a shared `decisions.md`, and
per-agent `charter.md` + `history.md` — so the team's accumulated context is
inspectable in git and survives across sessions.

Initialized with the built-in base roles:

```bash
npm install -g @bradygaster/squad-cli
squad init --roles
```

Base agents seeded: `scribe`, `ralph`, `Rai`, `fact-checker`. The roster table in
`.squad/team.md` is still empty — add members there (or via `squad`'s own
commands) to make them routable.

Useful commands:

```bash
squad status     # active squad and its reasoning
squad doctor     # diagnose setup problems
squad triage     # dispatch agents against open issues
squad upgrade    # update without touching team state
```

**Runtime requirement:** Squad's agent runtime is the GitHub Copilot CLI —
`copilot --agent squad`. It does not run on Claude Code. The team files, skills,
and workflows are committed here and are readable by any agent, but driving the
team as Squad intends requires Copilot. Claude Code's own subagent for this repo
is `speckit-manager` above.

`squad init` also wrote `.mcp.json` (a `squad_state` MCP server run via `npx`),
`.copilot/mcp-config.json`, `.vscode/settings.json`, and `.gitattributes` (union
merge for the append-only team logs).

### Workflows

Four GitHub Actions workflows are installed and become live on push:

| Workflow | Trigger |
| --- | --- |
| `sync-squad-labels.yml` | push touching `.squad/team.md` — syncs `squad:*` labels |
| `squad-triage.yml` | issue labeled `squad` — routes it via the lead agent |
| `squad-issue-assign.yml` | issue labeled `squad:{member}` — dispatches that member |
| `squad-heartbeat.yml` | issue/PR closed or labeled, or manual dispatch |

All are label- or issue-driven; none run on a schedule. Delete them, or re-run
`squad init --no-workflows` on a fresh checkout, if you do not want agent
dispatch wired into CI.
