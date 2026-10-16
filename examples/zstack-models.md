# zstack models

zstack skills read this rule. One line per role. Delete a line to use the skill default.
Claude roles take `opus`, `sonnet`, `haiku`, `fable`, or `inherit` (run on the chat's model).
Panel lines are lists. External reviewers are `codex`, `devin`, `copilot`, or `cursor`, with an optional `:<model>`.

code: sonnet
hardest tasks: opus
judgment and prose: opus
trivial edits: haiku
how explorer: sonnet
how explainer: opus
interrogate reviewers: opus, codex:gpt-5.6-sol, devin:swe-2-high

# On a machine with GitHub Copilot, add it as a fourth reviewer:
# interrogate reviewers: opus, codex:gpt-5.6-sol, devin:swe-2-high, copilot
