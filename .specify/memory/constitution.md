<!--
SYNC IMPACT REPORT
Version change: (unversioned template) → 1.0.0
Bump rationale: Initial ratification. All placeholder tokens replaced with project-specific
governance for a multi-source investment signal system.

Modified principles:
  [PRINCIPLE_1_NAME] → I. Decision Support, Never Advice
  [PRINCIPLE_2_NAME] → II. No Look-Ahead Bias (NON-NEGOTIABLE)
  [PRINCIPLE_3_NAME] → III. Provenance On Every Input
  [PRINCIPLE_4_NAME] → IV. Degrade Visibly, Never Silently
  [PRINCIPLE_5_NAME] → V. Reproducibility & Versioned Reasoning

Added sections:
  Testing & Quality Standards (was [SECTION_2_NAME])
  Development Workflow & Quality Gates (was [SECTION_3_NAME])
  Governance (populated)

Removed sections: none

Deferred TODOs: none
-->

# optionchain Constitution

## Core Principles

### I. Decision Support, Never Advice

Every signal this system emits is an input to a human decision, never a recommendation to
transact. The following are non-negotiable:

- A signal MUST surface the reasoning that produced it and the evidence each part of that
  reasoning rests on. A signal the user cannot interrogate is not shippable.
- The system MUST NOT present any output as a guaranteed outcome, an assured return, a
  "recommended trade", or an instruction to buy, sell, or size a position.
- Language that implies certainty about future prices is prohibited in signal output.
  Confidence MUST be expressed as a stated, bounded uncertainty, not as conviction language.
- Every signal-bearing surface MUST carry a visible statement that the output is informational
  and that the user owns the decision.
- Automated order placement is out of scope for this project. Any future proposal to act on a
  signal without a human in the loop requires a MAJOR constitutional amendment.

Rationale: The product's value is in making the user's reasoning better, not in replacing it.
A system that quietly shifts from "here is what the data says" to "here is what to do" acquires
liability and loses the auditability that makes it worth trusting.

### II. No Look-Ahead Bias (NON-NEGOTIABLE)

Any evaluation, backtest, or historical replay MUST use only data that was actually observable
at the timestamp being evaluated.

- Every stored data point MUST distinguish its **as-of time** (the moment the fact became true
  or was published) from its **retrieval time** (the moment this system obtained it). Queries
  used in historical evaluation MUST filter on as-of time and MUST NOT admit records whose
  publication postdates the evaluation timestamp.
- Revisable series (macro releases, fundamentals, restated estimates) MUST be stored as an
  append-only history of vintages. Evaluation MUST read the vintage in force at the evaluation
  timestamp, never the latest revision.
- News and event data MUST be filtered by publication time, not by the time an article refers
  to, and never by ingestion time alone.
- Instrument universes, index memberships, and any survivorship-sensitive list MUST be
  reconstructed as of the evaluation date. Evaluating a past date against today's universe is
  a defect.
- Point-in-time correctness is a correctness requirement, not an optimization. A component that
  cannot answer "what did we know at time T" MUST NOT be used as an evaluation input.

Rationale: Look-ahead bias does not produce a slightly optimistic result; it produces a result
that is meaningless while looking excellent. It is the single failure mode most capable of
making this entire system confidently wrong.

### III. Provenance On Every Input

Every data point entering the system MUST carry, at minimum: its source identity, its retrieval
timestamp, and its as-of timestamp.

- Provenance MUST survive every transformation. Derived values (aggregates, correlations,
  scores, normalizations) MUST reference the identifiers of the inputs they were computed from.
- A signal MUST be able to enumerate its complete input set on demand. A signal that cannot
  name its inputs is a bug, not a limitation, and MUST NOT be emitted.
- Where a value was estimated, imputed, interpolated, or defaulted, that fact MUST be recorded
  alongside it and MUST be visible in any explanation that depends on it.
- Provenance records MUST be retained for at least as long as the signals that reference them,
  so that any past signal remains explainable.

Rationale: The user's only defense against a plausible-sounding wrong answer is the ability to
trace it back to what it was built from. Provenance is what converts an opaque score into
something a person can audit and disagree with.

### IV. Degrade Visibly, Never Silently

When any analytical dimension is unavailable, incomplete, or stale, the system says so and its
confidence reflects it.

- Every signal MUST report which dimensions contributed, which were unavailable, and which were
  stale, along with the staleness interval for each.
- Confidence MUST be a function of coverage and freshness. A signal built on fewer or older
  legs MUST NOT report the same confidence as one built on complete, fresh inputs.
- Missing inputs MUST NOT be silently replaced with zeros, neutral values, last-known values,
  or defaults in order to complete a computation. Substitution is permitted only when it is
  explicitly labeled as such in the output (see Principle III).
- The system MUST define, per dimension, a staleness threshold beyond which data is treated as
  unavailable rather than current, and MUST enforce it rather than leaving it advisory.
- When coverage falls below the minimum required for a meaningful signal, the system MUST
  withhold the signal and explain the gap. Emitting a low-quality signal is worse than
  emitting none.

Rationale: A confident-looking signal built on missing legs is the most dangerous output this
system can produce, because it is indistinguishable from a good one at the point of use.

### V. Reproducibility & Versioned Reasoning

The same inputs evaluated at the same as-of time MUST produce the same signal.

- Signal generation MUST be deterministic given (input set, as-of time, logic version). Any
  non-deterministic element MUST be seeded and the seed recorded.
- Every emitted signal MUST record the version of the rules, models, weights, and parameters
  that produced it. Version identifiers MUST be immutable once a signal has referenced them.
- Changes to signal logic MUST be additive-versioned, never retroactive. Superseding a rule
  MUST NOT alter the explanation of signals already emitted under the prior version.
- The system MUST be able to reconstruct and explain any past signal after the fact from its
  recorded inputs, provenance, and logic version.
- Wall-clock time, "now", and other ambient state MUST NOT be read directly by signal logic.
  As-of time MUST be an explicit parameter so that live and historical execution follow the
  same code path.

Rationale: A signal that cannot be reproduced cannot be evaluated, debugged, or defended. If
changing the code silently rewrites history, the track record becomes fiction and post-hoc
learning becomes impossible.

## Testing & Quality Standards

These standards derive from the principles above and are enforced on every change.

**Point-in-time testing (mandatory).** Every component that reads historical data MUST have
tests that assert no future data leaks into a past evaluation. At minimum: a test that injects
a record whose as-of time postdates the evaluation timestamp and asserts it is excluded, and a
test over a revisable series asserting the correct vintage is selected.

**Provenance testing (mandatory).** Every ingestion and transformation path MUST have a test
asserting that source, retrieval time, and as-of time are present and correctly propagated to
derived outputs.

**Degradation testing (mandatory).** Every dimension MUST have tests covering: source
unavailable, source returns empty, source returns stale data past threshold, and source returns
partial data. Each test MUST assert the signal reports the gap and that confidence is reduced
relative to the complete-data baseline.

**Determinism testing (mandatory).** Signal generation MUST have a test that executes the same
inputs and as-of time twice and asserts byte-identical signal output excluding generation
timestamp.

**Golden-case regression.** A fixed set of recorded historical scenarios MUST be maintained.
Changes to signal logic MUST report the diff against these goldens. An unexplained diff blocks
merge; an explained diff requires a logic version bump.

**Contract tests at dimension boundaries.** Each data dimension MUST be exercised against a
recorded fixture of its external contract so that upstream shape changes fail fast in tests
rather than degrading signals in production.

**No live external dependencies in the default test suite.** Tests MUST run deterministically
offline against fixtures. Tests that exercise live sources MUST be separately labeled and MUST
NOT gate normal development.

**Evaluation honesty.** Any reported performance, hit rate, or accuracy figure MUST state its
evaluation window, universe as of that window, and the logic version evaluated. Figures without
these are not publishable inside or outside the project.

## Development Workflow & Quality Gates

**Spec-driven order.** Work follows the Spec Kit workflow: constitution → specify → (clarify) →
plan → tasks → (analyze) → implement. Production code is written only against tasks derived from
an approved plan.

**Ambiguity surfaces as questions.** Specifications MUST mark genuine unknowns with
`[NEEDS CLARIFICATION: <specific question>]` rather than resolving them by assumption. A plan
MUST NOT be generated from a spec carrying unresolved markers on decisions the plan depends on.

**Technology-agnostic specs.** Specifications describe WHAT and WHY. Vendors, APIs, protocols,
languages, schemas, and libraries are plan-phase decisions and MUST NOT appear in a spec.

**Constitution check before implementation.** Every plan MUST include an explicit check against
these five principles, naming for each how the design satisfies it. A design that cannot satisfy
a principle MUST either be changed or trigger the amendment process — it MUST NOT proceed on
the assumption that the principle is negotiable.

**Review gates.** A change MUST NOT merge if it: introduces a path where future data can reach a
historical evaluation; drops or fails to propagate provenance; substitutes a default for a
missing input without labeling it; makes signal output non-deterministic; or mutates the
interpretation of already-emitted signals.

**Staleness beats existence.** A downstream artifact older than the upstream artifact it derives
from is stale and MUST be regenerated before use, not treated as satisfying its gate.

**Complexity justification.** Any added dimension, model, or dependency MUST state what
decision it improves and how its contribution will be measured. Unmeasurable additions are
rejected.

## Governance

This constitution supersedes all other development practices in this repository. Where a
process document, prompt, template, or convention conflicts with it, this document wins.

**Amendment procedure.** Amendments MUST be proposed as a written change to this file stating:
the principle affected, the motivating problem, the proposed new text, and the migration impact
on existing specs, plans, and emitted signals. Amendments take effect only once merged. Verbal,
in-conversation, or agent-initiated agreement does not amend this document.

**Versioning policy.** This constitution is versioned MAJOR.MINOR.PATCH:

- **MAJOR** — a principle is removed, or redefined in a way that invalidates prior compliance.
- **MINOR** — a principle or governance section is added, or existing guidance is materially
  expanded.
- **PATCH** — clarification, wording, or formatting that does not change obligations.

Every amendment MUST update the version line and the Last Amended date, and MUST prepend a Sync
Impact Report recording the change.

**Compliance review.** Every plan carries a Constitution Check section, and every review
verifies it. Violations found after merge are defects and are prioritized as correctness bugs,
not as cleanup. Recurring violations of the same principle are a signal that the principle is
either wrong or unimplementable, and MUST be resolved by amendment rather than by tolerated
drift.

**Runtime guidance.** Agent- and contributor-facing operational guidance lives in the
`.specify/` templates and repository skill definitions. Those files implement this constitution;
they do not override it.

**Version**: 1.0.0 | **Ratified**: 2026-08-20 | **Last Amended**: 2026-08-20
