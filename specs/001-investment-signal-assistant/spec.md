# Feature Specification: Investment Signal Assistant

**Feature Branch**: `001-investment-signal-assistant`

**Created**: 2026-08-20

**Status**: Draft

**Input**: User description: "I want an assistant which tells me signals for stocks or ETFs, it will help me in investing according to data. It should be able to get news, macro, historical data, correlated assets, and analysis using all these dimensions."

## Overview

An assistant that produces **evidence-backed signals** for individual stocks and ETFs. A signal is
the output of a cross-dimension analysis that reads four evidence dimensions — news, macro
conditions, the instrument's own price history, and the behaviour of correlated assets — and
reconciles them into a single directional read with an explicit confidence and a traceable
explanation.

The **cross-dimension analysis is the product**. The four dimensions are inputs that exist to feed
it. A system that fetches all four dimensions but hands the user four disconnected readouts has not
delivered this feature. Equally, a system that emits a combined number the user cannot decompose
back into its evidence has not delivered it either.

Per the project constitution, output is decision support: it informs the user's judgement and never
instructs a trade.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Get a reconciled cross-dimension signal (Priority: P1)

The user names an instrument. The assistant reads all four evidence dimensions as of a specific
point in time, reconciles what they say — including where they disagree — and returns one signal
carrying a direction, a confidence that reflects how much evidence actually supported it, and a
summary of which dimensions pushed which way.

**Why this priority**: This is the feature. Every other story is either an input to this one or a
way of inspecting it. Nothing ships without it.

**Independent Test**: Request a signal for a liquid, well-covered instrument during a period for
which all four dimensions have data. Verify a single reconciled signal is returned, that it names
the contribution of each of the four dimensions, and that the stated confidence changes when a
dimension is withheld.

**Acceptance Scenarios**:

1. **Given** an instrument with all four dimensions available and fresh, **When** the user requests
   a signal, **Then** the assistant returns exactly one signal for that instrument containing a
   direction, a confidence value, and a per-dimension breakdown naming all four dimensions.
2. **Given** two dimensions pointing one way and two pointing the opposite way, **When** a signal is
   produced, **Then** the signal explicitly reports that the dimensions conflicted, names which
   dimensions took which side, and reports a lower confidence than an otherwise identical case in
   which all four agreed.
3. **Given** the same instrument and the same as-of time, **When** the signal is requested twice,
   **Then** both signals are identical in direction, confidence, and per-dimension breakdown.
4. **Given** a signal has been produced, **When** its output is inspected, **Then** it contains no
   instruction to buy, sell, or size a position, and no statement asserting a future price or
   guaranteed outcome.
5. **Given** only two of four dimensions returned data, **When** a signal is produced, **Then** the
   signal names the two missing dimensions, and its confidence is strictly lower than the same
   analysis run with all four present.

---

### User Story 2 - Interrogate the reasoning behind a signal (Priority: P1)

The user does not accept a signal at face value. They open it and walk down from the headline read
to the individual pieces of evidence — this news item published at this time, this macro release of
this vintage, this stretch of price history, this correlated asset's move — each with the source it
came from and the time it was true as of.

**Why this priority**: Constitution Principles I and III make an uninterrogable signal a defect, not
a limitation. A signal the user cannot audit is unusable for a decision they own.

**Independent Test**: Take any produced signal and enumerate its complete input set. Verify every
listed input carries a source identity, a retrieval time, and an as-of time, and that removing any
listed input and re-running changes the signal.

**Acceptance Scenarios**:

1. **Given** any produced signal, **When** the user requests its inputs, **Then** every input is
   listed with source identity, retrieval timestamp, and as-of timestamp, with no field blank.
2. **Given** a signal whose computation used an estimated, interpolated, or substituted value,
   **When** the explanation is displayed, **Then** that value is visibly labelled as not directly
   observed.
3. **Given** a signal from a prior date, **When** the user asks why it read the way it did, **Then**
   the assistant reproduces the explanation from the recorded inputs and the recorded logic version
   in force at that time, not from current data or current logic.
4. **Given** a dimension contributed to the signal, **When** its contribution is inspected, **Then**
   the user can see the direction and relative weight that dimension carried in the reconciliation.

---

### User Story 3 - News dimension read (Priority: P2)

For a named instrument, the assistant assembles the news bearing on it over a defined lookback,
judges the direction and materiality of that coverage, and hands the result to the analysis as one
dimension.

**Why this priority**: News is the dimension most likely to explain a move the other three cannot,
and the one most likely to be missing or duplicated. It is also independently valuable on its own.

**Independent Test**: Request the news read for an instrument with known coverage in a known window
and verify the returned items fall entirely inside the window, are attributed, and are deduplicated
across syndication.

**Acceptance Scenarios**:

1. **Given** a lookback window ending at the as-of time, **When** the news read is produced, **Then**
   every included item has a publication time inside that window and no item published after the
   as-of time is included.
2. **Given** the same story republished by several outlets, **When** the news read is produced,
   **Then** the duplicates are collapsed and the materiality of the story is not inflated by the
   number of republications.
3. **Given** an instrument with no qualifying news in the window, **When** the news read is produced,
   **Then** the dimension reports "no coverage" as a distinct state from "neutral coverage".
4. **Given** a news item, **When** it is attributed to an instrument, **Then** the basis for that
   attribution is recorded so the user can dispute it.

---

### User Story 4 - Macro dimension read (Priority: P2)

The assistant reads the macro environment relevant to the instrument as it stood at the as-of time,
using the data vintage that was actually published then, and expresses it as one dimension.

**Why this priority**: Macro is what makes a signal about an ETF or a rate-sensitive stock mean
anything, and it is the dimension where revisions most easily corrupt historical evaluation.

**Independent Test**: Produce a macro read for a past date on a series that was subsequently revised,
and verify the read uses the original vintage rather than the revised figure.

**Acceptance Scenarios**:

1. **Given** a macro series revised after the as-of time, **When** the macro read is produced for
   that as-of time, **Then** the pre-revision vintage is used and the vintage identity is recorded.
2. **Given** a scheduled macro release that has not yet occurred at the as-of time, **When** the
   macro read is produced, **Then** the dimension reports the release as pending rather than using
   the prior period's value as if current.
3. **Given** a macro input older than its staleness threshold, **When** the macro read is produced,
   **Then** the dimension is marked stale and reports the age of the data.
4. **Given** a macro read, **When** it is inspected, **Then** the basis for treating each included
   macro factor as relevant to this specific instrument is stated.

---

### User Story 5 - Historical price behaviour read (Priority: P2)

The assistant examines the instrument's own price and volume history up to the as-of time and
expresses what that history says as one dimension.

**Why this priority**: It is the only dimension that is always available for a listed instrument,
and the baseline the other three are read against.

**Independent Test**: Produce the historical read for an instrument across a known corporate action
and verify the history is adjusted consistently and that no data after the as-of time is used.

**Acceptance Scenarios**:

1. **Given** an as-of time, **When** the historical read is produced, **Then** no price or volume
   observation timestamped after the as-of time contributes to it.
2. **Given** an instrument that underwent a split or distribution inside the lookback, **When** the
   historical read is produced, **Then** the series is adjusted consistently and the adjustment is
   recorded as applied.
3. **Given** an instrument whose available history is shorter than the lookback the analysis
   requires, **When** the historical read is produced, **Then** the dimension reports insufficient
   history rather than computing over the short window as if it were complete.
4. **Given** a gap in the price series inside the lookback, **When** the historical read is produced,
   **Then** the gap is reported and any value used in its place is labelled as filled.

---

### User Story 6 - Correlated assets read (Priority: P2)

The assistant identifies assets whose behaviour has related to this instrument's, reports what those
assets are currently doing, and expresses the divergence or confirmation as one dimension.

**Why this priority**: Correlated assets are the dimension that catches what a single-name view
misses, and the one that fails most dangerously, because a broken correlation still returns a
confident-looking number.

**Independent Test**: Produce the correlated-assets read for an instrument, verify each named peer
carries the measured strength and the window it was measured over, and verify a peer whose
relationship has decayed is reported as such.

**Acceptance Scenarios**:

1. **Given** a correlated-assets read, **When** it is inspected, **Then** every named peer carries
   the measured strength of the relationship and the measurement window used.
2. **Given** a peer whose measured relationship over the recent sub-window has diverged materially
   from its longer-window value, **When** the read is produced, **Then** the read flags the
   relationship as unstable and reduces that peer's influence.
3. **Given** an instrument for which no peer meets the minimum relationship strength, **When** the
   read is produced, **Then** the dimension reports "no reliable peers" rather than returning the
   strongest available weak relationships as if they were meaningful.
4. **Given** a peer that has itself been halted or has no data at the as-of time, **When** the read
   is produced, **Then** that peer is excluded and the exclusion is recorded.

---

### User Story 7 - Review how signals actually performed (Priority: P3)

The user looks back at signals the assistant previously produced and sees how they resolved, so they
can decide how much weight to give the next one.

**Why this priority**: Without it, the user has no way to calibrate trust, and the system cannot
improve. It depends on signals having been produced and recorded first, so it follows P1/P2.

**Independent Test**: Produce signals over a historical window using only point-in-time data, then
evaluate them and verify the evaluation reports its window, the universe as of that window, and the
logic version evaluated.

**Acceptance Scenarios**:

1. **Given** a set of past signals, **When** the user requests a review, **Then** the review states
   the evaluation window, the instrument universe as it stood in that window, and the logic version
   under which the signals were produced.
2. **Given** a historical evaluation, **When** it runs, **Then** it uses only data whose as-of time
   precedes each signal's own as-of time, and this is verifiable from the recorded inputs.
3. **Given** the signal logic has changed since a past signal was emitted, **When** that signal is
   reviewed, **Then** it is reported under its original logic version and its original explanation
   is unaltered.

---

### Edge Cases

**Market state**

- Market closed, pre-market, post-market, and holiday sessions: does the signal refer to the last
  close or to the next open, and does it say which? A signal produced at 03:00 must not read as
  though it describes live conditions.
- Instrument halted or suspended at the as-of time: the assistant must report the halt rather than
  extending the last observed price as current.
- Instrument delisted, acquired, or renamed inside the lookback window.

**Thin and unusual instruments**

- Illiquid instruments where recent price moves reflect a handful of trades: price-derived readings
  must be flagged as low-reliability rather than presented at normal confidence.
- Newly listed instruments and recently launched ETFs with history shorter than the analysis
  lookback.
- ETFs whose behaviour is driven by holdings rather than single-name news, where the news dimension
  is structurally sparse and its absence is expected rather than a failure.
- Instruments sharing an ambiguous ticker across venues, or whose name collides with an unrelated
  company in news matching.

**Missing and failing dimensions**

- One dimension returns nothing at all, versus returns an explicit neutral reading — these are
  different states and must not be collapsed.
- A dimension times out or errors partway, leaving partial data.
- All four dimensions unavailable: the assistant must withhold the signal rather than emit an
  empty-but-confident one.
- Coverage falls below the minimum needed for a meaningful signal (see FR-011).

**Conflict and regime**

- Dimensions in direct opposition — strong positive news against deteriorating price behaviour, or
  supportive macro against peer-group breakdown.
- A single dimension is extreme while the other three are neutral: does one dimension get to carry
  the signal alone, and if so under what threshold?
- Correlation regime shift: relationships that held across the measurement window break down in the
  recent sub-window. Historic correlation strength must not be used to justify present-day influence
  once the relationship has decayed.
- Broad market-wide move where every instrument and every peer moves together and the correlated
  dimension carries no instrument-specific information.

**Data integrity**

- Macro figure revised after a signal referencing it was emitted: the emitted signal's explanation
  must not silently change.
- Late-arriving or backdated news whose publication time precedes its availability time.
- Corrections and retractions of a news item that already contributed to an emitted signal.
- Duplicate or contradictory records for the same fact from different sources.
- A source's data shape changes and previously parsed content becomes unreadable.

## Requirements *(mandatory)*

### Cross-Dimension Analysis (the centerpiece)

- **FR-001**: The system MUST produce, for a requested instrument and as-of time, exactly one signal
  that reconciles all four evidence dimensions — news, macro, historical price behaviour, and
  correlated assets — into a single output. Returning four independent per-dimension readouts
  without a reconciled result does not satisfy this requirement.
- **FR-002**: Every signal MUST report a per-dimension breakdown naming, for each of the four
  dimensions, its individual read, its availability state, and the relative influence it carried in
  the reconciled result.
- **FR-003**: The system MUST detect when dimensions disagree and MUST report the disagreement
  explicitly in the signal, naming which dimensions took which side.
- **FR-004**: A signal produced from conflicting dimensions MUST carry a strictly lower confidence
  than an otherwise identical signal produced from agreeing dimensions.
- **FR-005**: The system MUST reconcile the four dimensions using a defined, inspectable method.
  [NEEDS CLARIFICATION: how are the four dimensions weighted and reconciled when they disagree —
  fixed weights per dimension, weights that vary by instrument type or market regime, weights fitted
  from historical performance, strongest-signal-wins, or a rule hierarchy where one dimension can
  veto another? This is the core design decision of the feature and no reasonable default exists.]
- **FR-006**: The reconciliation method's parameters MUST be recorded with each emitted signal such
  that the reconciliation can be re-derived from the per-dimension reads after the fact.
- **FR-007**: A signal MUST be expressed as a defined output shape. [NEEDS CLARIFICATION: what
  concretely constitutes a "signal" as delivered output — a direction only (bullish / bearish /
  neutral), a graded conviction score, a suggested position size, entry and exit levels, prose
  reasoning, or some combination? Sizing and entry/exit levels in particular move the product toward
  advice and require an explicit decision.]
- **FR-008**: Every signal MUST state the time horizon it speaks to. [NEEDS CLARIFICATION: what
  horizon does a signal describe — intraday, multi-day swing, multi-week to multi-month position, or
  a user-selected horizon per request? The horizon determines the lookback windows and the
  evaluation method for every dimension, so it cannot be deferred to the plan.]
- **FR-009**: Signal output MUST NOT contain instructions to transact, assertions of guaranteed
  outcomes, or claims of certainty about future prices, per constitution Principle I.
- **FR-010**: Every signal MUST carry a visible statement that it is informational and that the
  investment decision belongs to the user.

### Availability, Staleness, and Degradation

- **FR-011**: The system MUST define a minimum dimension coverage below which no signal is emitted,
  and MUST withhold the signal and explain the gap when coverage falls below it.
- **FR-012**: The system MUST distinguish, per dimension, between four states: available and fresh,
  available but stale, returned-empty, and unavailable. These MUST NOT be collapsed into a single
  "no data" state.
- **FR-013**: Confidence MUST be a monotonic function of dimension coverage and freshness: removing
  a dimension or increasing its staleness MUST NOT increase confidence.
- **FR-014**: The system MUST NOT substitute zeros, neutral values, last-known values, or defaults
  for missing inputs unless the substitution is labelled as such in the signal explanation.
- **FR-015**: The system MUST define and enforce a per-dimension staleness threshold beyond which
  data is treated as unavailable rather than current.
- **FR-016**: The system MUST report the market state (open, closed, pre-open, post-close, halted,
  holiday) at the as-of time as part of every signal.
- **FR-017**: The system MUST flag reduced reliability for instruments whose recent trading activity
  is too thin to support price-derived readings.

### Evidence, Provenance, and Explanation

- **FR-018**: Every data point contributing to a signal MUST carry source identity, retrieval
  timestamp, and as-of timestamp, per constitution Principle III.
- **FR-019**: A signal MUST be able to enumerate its complete input set on demand, and a signal
  whose inputs cannot be enumerated MUST NOT be emitted.
- **FR-020**: Derived values MUST reference the identifiers of the inputs they were computed from,
  so an explanation can be traced from headline read to individual evidence item.
- **FR-021**: Estimated, interpolated, imputed, or substituted values MUST be labelled as such
  wherever they appear in an explanation.

### Point-in-Time Correctness and Reproducibility

- **FR-022**: No data whose as-of time is later than a signal's as-of time may contribute to that
  signal, in live or historical execution, per constitution Principle II.
- **FR-023**: Revisable inputs MUST be stored as an append-only history of vintages, and evaluation
  MUST read the vintage in force at the evaluation timestamp.
- **FR-024**: The same instrument, as-of time, input set, and logic version MUST produce an
  identical signal on repeated execution.
- **FR-025**: Every signal MUST record the version of the reconciliation logic, per-dimension logic,
  and parameters that produced it, and those version identifiers MUST be immutable once referenced.
- **FR-026**: Changes to signal logic MUST NOT alter the recorded explanation of already-emitted
  signals.
- **FR-027**: As-of time MUST be an explicit input to signal generation rather than read from
  ambient clock state, so live and historical execution follow the same path.

### News Dimension

- **FR-028**: The news read MUST include only items whose publication time falls inside the lookback
  window and at or before the as-of time.
- **FR-029**: The news read MUST deduplicate syndicated or republished versions of the same story so
  that repetition does not inflate materiality.
- **FR-030**: The news read MUST record the basis on which each item was attributed to the
  instrument.
- **FR-031**: The news read MUST distinguish "no coverage found" from "coverage found and judged
  neutral".
- **FR-032**: A retraction or correction of an item MUST be recorded as a new observation and MUST
  NOT retroactively alter the explanation of a signal already emitted.

### Macro Dimension

- **FR-033**: The macro read MUST use the data vintage published at or before the as-of time,
  ignoring later revisions, and MUST record which vintage was used.
- **FR-034**: A scheduled release that has not occurred at the as-of time MUST be reported as
  pending and MUST NOT be represented by the prior period's value presented as current.
- **FR-035**: The macro read MUST state the basis on which each macro factor is treated as relevant
  to the specific instrument under analysis.

### Historical Price Dimension

- **FR-036**: The historical read MUST exclude every observation timestamped after the as-of time.
- **FR-037**: The historical read MUST apply consistent adjustment for corporate actions inside the
  lookback and MUST record that the adjustment was applied.
- **FR-038**: When available history is shorter than the required lookback, the historical read MUST
  report insufficient history rather than computing over the truncated window as if complete.
- **FR-039**: Gaps in the price series MUST be reported, and any value used in place of a gap MUST
  be labelled as filled.

### Correlated Assets Dimension

- **FR-040**: The correlated-assets read MUST report, for every named peer, the measured strength of
  the relationship and the window over which it was measured.
- **FR-041**: The read MUST compare relationship strength over the recent sub-window against the
  full measurement window and MUST flag and down-weight relationships that have materially decayed.
- **FR-042**: When no peer meets a defined minimum relationship strength, the read MUST report "no
  reliable peers" rather than returning the strongest weak relationships as if meaningful.
- **FR-043**: Peers with no data or a trading halt at the as-of time MUST be excluded, and the
  exclusion MUST be recorded.
- **FR-044**: The read MUST identify when peer movement is explained by a broad market-wide move
  rather than by an instrument-specific relationship.

### Scope, Cadence, and Delivery

- **FR-045**: The system MUST define the set of instruments it covers. [NEEDS CLARIFICATION: what is
  the instrument universe and how is it chosen — a user-maintained watchlist, an index or set of
  indices, everything tradable on named venues, or any instrument supplied ad hoc at request time?
  This determines whether the system is pull-based on a handful of names or must maintain coverage
  across thousands.]
- **FR-046**: The system MUST define when signals are produced. [NEEDS CLARIFICATION: is the cadence
  on-demand per user request, scheduled at fixed times such as pre-open and post-close, or continuous
  and event-triggered as new evidence arrives? This determines whether the system is a request-response
  assistant or a monitoring service.]
- **FR-047**: The system MUST define how signals reach the user. [NEEDS CLARIFICATION: what is the
  delivery surface — conversational request-response, a report the user reads, alerts pushed when a
  signal changes, or a browsable dashboard?]
- **FR-048**: The system MUST define what persists between runs. [NEEDS CLARIFICATION: is any state
  retained across runs — the history of emitted signals, the fetched evidence, the user's watchlist
  and preferences — or is each run self-contained and stateless? Constitution Principles III and V
  require emitted signals and their provenance to remain explainable after the fact, which implies
  some retention, but its scope and duration are undecided.]
- **FR-049**: The system MUST record every emitted signal together with its inputs, provenance, and
  logic version for long enough to satisfy FR-026 and User Story 7.

### Evaluation and Feedback

- **FR-050**: The system MUST define how signal quality is assessed after the fact.
  [NEEDS CLARIFICATION: how is a signal judged correct or incorrect once time has passed — directional
  accuracy over the stated horizon, magnitude-weighted outcome, risk-adjusted return of a notional
  position, or calibration of stated confidence against realised hit rate? Without this the system
  cannot report on itself and the user cannot calibrate trust.]
- **FR-051**: Any reported accuracy or performance figure MUST state its evaluation window, the
  instrument universe as of that window, and the logic version evaluated.
- **FR-052**: Historical evaluation MUST be verifiably free of look-ahead: for each evaluated signal
  it MUST be demonstrable from recorded inputs that every input predates that signal's as-of time.

### Key Entities

- **Instrument**: A stock or ETF under analysis, identified unambiguously across venues and across
  renames, with its listing status and trading state at a given time.
- **Evidence Item**: A single observed fact from any dimension, carrying its value, source identity,
  retrieval timestamp, as-of timestamp, and — where the underlying series is revisable — its vintage.
- **Dimension Read**: One dimension's assessment for an instrument at an as-of time, carrying its
  direction, its availability state (fresh / stale / empty / unavailable), its lookback window, and
  the evidence items behind it.
- **Signal**: The reconciled cross-dimension result for an instrument at an as-of time, carrying
  direction, confidence, per-dimension breakdown with influence, conflict report, market state,
  horizon, logic version, and the full set of dimension reads it was built from.
- **Peer Relationship**: A measured association between the instrument and another asset, carrying
  strength, measurement window, recent-sub-window strength, and a stability assessment.
- **Logic Version**: An immutable identifier for the reconciliation rules, per-dimension rules, and
  parameters in force when a signal was emitted.
- **Signal Outcome**: The post-hoc assessment of an emitted signal against what subsequently
  happened, scoped to the horizon the signal claimed.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of emitted signals report a per-dimension breakdown covering all four dimensions,
  each with an explicit availability state.
- **SC-002**: 100% of emitted signals can enumerate their complete input set, with source identity,
  retrieval time, and as-of time present and non-empty on every input.
- **SC-003**: Repeating any signal request with the same instrument, as-of time, and logic version
  reproduces an identical result in 100% of trials.
- **SC-004**: In an audit of historical evaluations, zero evaluated signals contain an input whose
  as-of time postdates the signal's as-of time.
- **SC-005**: In every test where a dimension is withheld or aged past its staleness threshold, the
  resulting confidence is lower than the full-data baseline — no exceptions.
- **SC-006**: 100% of signals produced under dimension conflict explicitly name the conflicting
  dimensions and the side each took.
- **SC-007**: Zero emitted signals contain transaction instructions, guaranteed-outcome claims, or
  assertions of certainty about future prices, verified by review of a sampled set.
- **SC-008**: When all four dimensions are unavailable, the system withholds a signal and explains
  the gap in 100% of cases; it never emits a signal with no supporting evidence.
- **SC-009**: A user can trace any headline signal read down to at least one named, timestamped
  piece of underlying evidence without leaving the explanation.
- **SC-010**: Re-running the explanation of a signal emitted under a superseded logic version
  reproduces the original explanation unchanged in 100% of cases.
- **SC-011**: For instruments flagged as thin or as having insufficient history, 100% of emitted
  signals carry the corresponding reliability flag.
- **SC-012**: Every published accuracy figure carries its evaluation window, point-in-time universe,
  and logic version; figures lacking any of the three are not published.

## Assumptions

- The user is an individual investor making their own decisions; the assistant informs those
  decisions and does not execute or authorise anything.
- Analysis is per instrument. Portfolio-level construction, position sizing across holdings,
  risk budgeting, and tax treatment are out of scope for this feature.
- Options, futures, FX, crypto, and fixed income instruments are out of scope; the user named stocks
  and ETFs only.
- Order placement and any form of automated execution are out of scope, per constitution
  Principle I.
- The four named dimensions — news, macro, historical price, correlated assets — are the complete
  set for this feature. Additional dimensions (fundamentals, positioning, options-derived measures,
  sentiment beyond news) are deferred.
- "Correlated assets" means other tradable assets whose price behaviour has related to the
  instrument's, not fundamental peers selected by sector classification alone.
- Evidence sourcing, storage, and delivery mechanisms are plan-phase decisions. This spec constrains
  what the data must carry (provenance, vintage, point-in-time correctness), not where it comes from.
- Signals are produced for one instrument at a time; batch or screen-wide ranking across the
  universe is out of scope unless the universe clarification (FR-045) implies otherwise.
- The system is single-user; multi-user accounts, sharing, and permissions are out of scope.

## Dependencies

- Access to news, macro, price history, and cross-asset data with sufficient timestamp fidelity to
  distinguish as-of time from retrieval time. A source that cannot supply publication or release
  timestamps cannot satisfy FR-018 and FR-022.
- Access to historical vintages for revisable macro series. Without vintage history, FR-023 and
  User Story 7 cannot be satisfied and post-hoc evaluation is not trustworthy.
- A calendar of market sessions, holidays, and halts sufficient to determine market state at an
  arbitrary as-of time (FR-016).
- Corporate action history covering splits and distributions across the analysis lookback (FR-037).
