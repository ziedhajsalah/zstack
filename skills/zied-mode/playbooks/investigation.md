### Investigation

**You own the answer. Plan, route, write.**

Investigation requests are read-only. They produce a cited explanation or a recommendation, not a code change.

1. Route through the `/zstack:how` skill. For motivation questions ("why was this built this way"), also dig through history yourself: `git log -S`, `git blame`, and the PRs and issues they link to (`gh pr view`, `gh issue view`). Separate direct evidence from inference, and report a null result when nobody wrote down why.
2. Throughput checkpoint stays one line: `throughput checkpoint: n/a, read-only investigation`.
3. Produce the `how`-shaped output (Overview / Key Concepts / How It Works / Where Things Live / Gotchas), or a recommendation with a tradeoffs table if the request is a decision between alternatives.
4. Write the reply per **Writing the reply**.

No PR and no code changes. If the investigation precedes a code change, hand back to the user and re-route to Bug fix or Feature.

**Reply:** the investigation output. For "are we sure?" answers, include your real judgment with reasons. Push back if the premise is wrong (see Autonomy).
