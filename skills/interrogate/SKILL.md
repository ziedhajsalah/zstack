---
name: interrogate
description: "Use for \"interrogate\", \"adversarial review\", \"multi-model review\", \"challenge this\", \"stress test this code\", \"find blind spots\", or \"tear this apart\". Reviewers on different model families (Claude, Codex, Devin, Copilot, Cursor agent) challenge a diff independently, then a lead sorts the findings."
---

# Interrogate

Run one reviewer per configured entry to adversarially review code changes. The adversarial signal comes from model diversity, not assigned personas. The deliverable is a synthesized verdict. Do NOT auto-apply changes.

## Step 1, Scope

Identify what to review from context:

- If the user points at specific files or a diff, use that.
- If on a feature branch, run `git diff main...HEAD` (or the appropriate base branch) for the full changeset.
- If the user's message references recent work, gather the relevant files.

Package the diff or file contents with any surrounding context files the reviewers need to understand the code.

## Step 2, Intent

Before spawning reviewers, state the intent in one clear paragraph from the user's message, commit messages, the PR description if one exists, and the code. If you're unsure about the intent, ask the user before proceeding.

## Step 3, Build the panel

The panel comes from the `interrogate reviewers` line of a `zstack models` rule in context. Without that line, use the default panel `opus, codex, devin`.

Each entry is one reviewer, labeled Reviewer A, B, and so on:

- `opus`, `sonnet`, `haiku`, `fable`, or `inherit` → a Claude reviewer. Spawn it with the Agent tool, `subagent_type: "zstack:reader"`, and that `model` (omit `model` for `inherit`).
- `codex`, `devin`, `copilot`, or `cursor`, optionally with `:<model>` (for example `devin:swe-2-high`) → an external CLI reviewer, run by `scripts/second-opinion.sh` in this plugin.

Run `bash <plugin-root>/scripts/second-opinion.sh list` first, where `<plugin-root>` is two directories above this skill's base directory. For each external entry whose CLI is missing, replace it with a Claude reviewer on a model the panel does not use yet (`sonnet`, then `haiku`), and say so in the output. A panel of only one model family loses most of the signal. Say that too when it happens.

## Step 4, Run the reviewers

Read `references/reviewer-prompt.md` and fill in the same template for every reviewer with the stated intent, the diff or file contents, the rubric from `references/rubric.md`, and the code-quality lens from `references/code-quality-review.md`.

Launch every reviewer in one message so they run in parallel:

- **Claude reviewers.** Pass the filled template as the Agent prompt.
- **External reviewers.** Write the filled template to a file in a fresh temporary directory outside the repository (`mktemp -d`). Run `bash <plugin-root>/scripts/second-opinion.sh <cli> <prompt-file> <out-file> [model]` from the repository root, in the background. The script runs the CLI in its read-only mode. Then read `<out-file>`.

Script exit codes:

- `3` (CLI not installed) or `5` (CLI failed, for example an expired login or a rejected model) → replace that reviewer with a Claude reviewer as in Step 3 and run it. Name the substitution and the reason (one line from the log tail) in the Reviewers section.
- `4` (the reviewer changed the working tree) → discard its findings, show the user `git status`, and do not revert anything without asking.

## Step 5, Synthesize

As results come back, build a unified picture. Parse every reviewer's findings. Merge findings that describe the same issue differently, and note which models raised each one. Findings two or more models raised independently are the highest signal. Read a lone model's finding, but weight it accordingly. Note disagreements. If one model flags something and another explicitly says the opposite, that is context for the verdict.

## Step 6, Lead Judgment

You are the lead reviewer, a pragmatic senior engineer, not a neutral aggregator. Read `references/lead-judgment.md` for the full framework. Put every finding in one of four buckets, with the model(s) that raised it and a one-line rationale.

- **Act on**. Real issues affecting correctness, security, or maintainability given the actual goals. They would block a real PR.
- **Consider**. Legitimate, but you're not sure they outweigh the cost of addressing them now. Worth the user's attention.
- **Noted**. Technically valid but not actionable. Context-dependent, premature optimization, or low-impact at this stage.
- **Dismissed**. Wrong, nitpicky, or missing context, with a brief reason.

## Output Format

### Intent
> [The stated intent paragraph from Step 2]

### Reviewers
- Reviewer [label]: [model or CLI and model], [N findings] (one bullet per reviewer, plus any substitutions and why)

### Act On
[Each: description, which models raised it, why it matters.]

### Consider
[Each: description, which models raised it, the tradeoff.]

### Noted
[Brief list.]

### Dismissed
[Each with a brief rationale.]

### Agreement Map
[Where models agreed and diverged, and what that pattern tells us.]
