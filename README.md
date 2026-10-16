# zstack

Rigorous agent workflows for Claude Code. If you want to go fast, go deep first.

zstack is a Claude Code port of [pstack](https://github.com/cursor/plugins/tree/main/pstack) by Lauren Tan. You start a task with `/zstack:zied-mode` and say what you want plus how to check it is done. zstack picks a playbook, copies its steps into the todo list, delegates code to subagents, reviews their work, and proves the result on the real app before it opens a PR.

## Install

```bash
claude plugin marketplace add <git-url-or-path-of-this-repo>
claude plugin install zstack@zstack
```

Start a new session after installing.

## Use it

```text
/zstack:zied-mode after a retry, users receive the same email twice. reproduce it first, then fix it and show me proof.
```

The mode stays on for the rest of the session. A hook reminds Claude on every turn. Say `new task` when you change topic, and `stop zied mode` to turn it off.

A good prompt has up to five parts: the goal, a done-check that can pass or fail, the proof you want to see, what you already know, and hard constraints such as "repro first" or "don't change any code yet". Leave out the how, your guess of the cause, and lists of skills.

## What is in this version

| Part | What it does |
|---|---|
| `/zstack:zied-mode` | The front door. Routes the task to a playbook and applies the principles. |
| Playbooks | Investigation, Bug fix, Feature (also refactors), Opening a PR. |
| Principles | 24 named rules in `skills/zied-mode/principles/`. Say a name to steer the agent, for example "apply prove it works". |
| `/zstack:how` | Explains how a subsystem works, with read-only explorers and an explainer. |
| `/zstack:interrogate` | Adversarial review of a diff by different model families (Claude, Codex, Devin, Copilot, Cursor), then a sorted verdict. |
| `zstack:zied-agent` | The delegate that writes code during a run. |
| `zstack:reader` | A read-only agent for `how` and `interrogate`. |

## Multi-model review

`/zstack:interrogate` mixes a Claude reviewer with external CLIs. Each one runs through `scripts/second-opinion.sh` in its read-only mode, and the script fails the review if the CLI changed your working tree.

| Reviewer | CLI | Read-only mode | Setup |
|---|---|---|---|
| `codex` | `codex` | `codex exec -s read-only` | `codex login` |
| `devin` | `devin` | `devin -p --permission-mode auto` | `devin` login |
| `copilot` | `copilot` | `copilot -p --deny-tool write --deny-tool shell` | `copilot` login (GitHub Copilot plan) |
| `cursor` | `agent` | `agent -p --mode ask` | `agent login` (Cursor plan). Not tested yet. |

External reviewers send the diff, and any repository files they choose to read, to OpenAI (Codex), Cognition (Devin), GitHub (Copilot) or Cursor. Check your client agreements before using them on client code, and drop them from the panel when you can't.

A missing or failing CLI is replaced by a Claude reviewer on another model, and the review says so. Run `bash scripts/second-opinion.sh list` to see which CLIs you have.

## Configure models

Copy the example rule and edit it. Claude Code loads every file in `~/.claude/rules/`.

```bash
cp examples/zstack-models.md ~/.claude/rules/zstack-models.md
```

Without the rule, code delegates run on `sonnet`, judgment and the hardest tasks on `opus`, and the review panel is `opus, codex, devin` with each CLI's own default model. Pin a model per CLI in the rule when its default does not work with your account.

## Proof on the real app

zied-mode proves changes where a user meets them. It prefers a project skill named `verify-*`. Without one it drives React Native apps through the argent tools, web apps through Playwright or the browser tools, APIs through real HTTP calls and database reads, and CLIs by running the real command.

## Roadmap

1. Verification-skill generator, plus Babysit and Shipping playbooks.
2. `/arena`, `/swarm`, `/why`, overnight runs with a decision log, `/automate-me`, `/correct`, and a `/zstack:setup` command that writes the model rule.

## License

MIT. See `LICENSE` and `NOTICE` for the pstack credit.
