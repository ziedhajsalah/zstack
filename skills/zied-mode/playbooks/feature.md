### Feature

**You own the design. Plan, review, verify.** Delegate implementation. Stay in the lead.

1. `/zstack:how` over the affected subsystem.
2. Settle the design before code. Write the caller's usage first, then types, signatures and a module map. When two or more shapes are plausible, spawn two `zstack:zied-agent` sketches in parallel, each with `isolation: "worktree"` and a different `model`, then compare them side by side and pick or graft.
3. Write the throughput checkpoint as four todo items. A dimension that genuinely does not apply (single file, no fan-out) keeps its item with `n/a: <reason>` rather than being dropped:
   - **Blocking first steps.** Gates run before fan-out.
   - **Independent workstreams.** Disjoint files, services, or layers parallelize. Shared writes serialize.
   - **Shared mutable state.** Default to splitting the target (**Separate Before Serializing Shared State**). Serialize only for real invariants.
   - **Smallest safe decomposition.** If one worker is best, name why.
4. Delegate code-writing to a `zstack:zied-agent` on the `code` model with a specific scope: file paths, the named data shape and its organizing structure per **Model the Domain** (a state machine over scattered booleans, a table or registry over branching, a typed model over repeated shape assumptions), chosen before the delegate writes logic, and success criteria. The delegate owns the diff. You own the review. Comments per **Comments**. Surgical edits. Port shared-primitive improvements to all consumers and verify each. Commit liberally.
5. Verify on the matching surface (see **Verification surfaces**). "Inconclusive" or wrong-surface is not a pass. Flag it. For a refactor, rerun the behavior you recorded before the change and show it is unchanged.
6. Rebase into small, ordered commits. Stack follow-ups. Use **Sequence Work into Verifiable Units**, building, verifying, and committing each small unit before the next.
7. If the design is contested, or you don't fully trust the diff, run `/zstack:interrogate` before shipping.
8. Run **Opening a PR**.

Code-coupled work (one feature, one migration) goes to a single owner with the checkpoint inline. Parent-level fan-out is for slices that produce independent artifacts (audits, cross-subsystem investigations, competing experiments). Rewrite the checkpoint at phase boundaries. Spawn a fresh owner rather than chaining follow-ups.

**Reply:** what you built, what you chose and why, the throughput checkpoint, open decisions. Tables for design alternatives.
