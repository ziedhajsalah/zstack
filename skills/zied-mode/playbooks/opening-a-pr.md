### Opening a PR

Invoked at the end of every other playbook.

**Worktree.** Work from a git worktree off the base branch. Parallel delegates on the same branch each get their own worktree (`isolation: "worktree"`). Dirty branch with unrelated work: patch it out, use a fresh worktree, apply. Snarled worktree: reset from the base branch and redo minimally.

**Commits.** Commit liberally. Rebase into small, ordered commits before opening PRs. Each commit is a future PR: landable, ordered to tell the story. Amend when the fix belongs in a just-made commit. New commit when separable. Commit bodies don't restate the subject.

**Cleanup.** Before commit, run the `deslop` pass (Non-negotiables). Before review, run the **Comments** pass. Write every PR title, description, and commit body per **Writing the reply**.

**Titles.** Conventional Commits `type(scope): subject`, no trailing period. Type such as `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, or `perf`. Scope is the area. Subject is short, imperative, and names a real symbol when one carries the change, for example `fix(export): retry csv writer on partial flush`.

**Descriptions.** The PR body is a one-minute briefing for a reviewer who has the diff. It says why the change exists, what it leaves out, what it could break, and how you proved it works. Short, simple sentences, few identifiers, no walls of text. Keep it under about 40 lines. Use `##` headings in this order, and drop a section with nothing to say:

- `## Why`: the problem and approach, 1–3 short sentences.
- `## What changed`: 1–3 short bullets. Name a real symbol or path only when it carries the change.
- `## Scope`: always. 1–3 short items on what it covers and what it deliberately leaves out.
- `## Tradeoffs`: only rejected alternatives a reviewer would otherwise ask about.
- `## Blast Radius`: 1–2 sentences on who or what it touches and why that is safe or risky.
- `## Verification`: 1–3 bullets, each a real run path and its outcome. Perf: one primary number with its unit, `before → after`.

After the sections, attach screenshots or videos when they prove a claim.

**Forge.** Use the GitHub CLI (`gh`). When the session provides a built-in PR tool, create and edit PRs through it instead.

**Size and stacks.** Prefer five narrow PRs to one large PR. A stack is a base-branch chain. The root PR targets trunk. Each child branch rebases onto its parent's exact tip and its PR targets the parent branch (`gh pr create --base <parent-branch>`). Branch from trunk only for independent work. Rebase on trunk before substantial stack work.

**Readiness.** Open every PR ready, never as a draft. Run `gh pr view <number>` before you refer to PR status.

**After opening.** Post the URL and keep building. Finish the phase or stack first. Watching CI and answering review comments is a separate pass the user asks for. Never merge unless the user asks.

A subagent that opens a PR runs the cleanup passes and posts the URL. It returns to the parent without watching the PR.
