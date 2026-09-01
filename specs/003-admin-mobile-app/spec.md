# Feature Specification: Admin Mobile App

**Feature Branch**: `003-admin-mobile-app`

**Created**: 2026-08-28

**Status**: Draft

**Input**: User description: "Admin mobile app: oversight dashboard, urgent dispute approvals, system health, rapid moderation"

## Clarifications

### Session 2026-08-31

- Q: When a new urgent dispute comes in, should this feature actually build the "admin gets notified" mechanism Story 1 is framed around, or is Story 1 scoped to work purely by an admin opening the app and checking (no push trigger)? → A: Defer it explicitly — this feature is pull/polling only (open app → see current disputes); an all-admins broadcast notification is out of scope, left for a later spec.
- Q: Should the disputes/oversight screens auto-refresh on a fixed interval while open, or only refresh on manual pull-to-refresh / screen entry? → A: Auto-refresh every 10s while the screen is open, matching the existing 10s polling precedent already used elsewhere in this codebase (web's FleetMap/AdminMap).
- Q: What should count as an "abnormal" spike in failed notifications or payments for FR-004's alert flag? → A: More than 5 failures in the last 24 hours (a launch-default threshold, same pattern as this project's other launch-default numbers, e.g. the 15% payout commission).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Resolve an urgent dispute from a phone (Priority: P1)

An admin, away from their desk, gets notified of an urgent service
dispute (e.g. a customer disputing a fare or a job outcome) and needs to
review it and mark it resolved from their phone, without waiting until
they're back at the admin web console.

**Why this priority**: This is the specific reason the role matrix calls
out "mobile" for admin at all ("urgent dispute approvals") — disputes are
time-sensitive and the whole point of a mobile presence is not being
blocked on desk access. Without this, the app has no reason to exist
separately from the existing admin web console.

**Independent Test**: Can be fully tested by logging in as an admin on
mobile, opening an open dispute, reviewing its detail, and resolving it —
and confirming that resolution is reflected the same way it would be from
the web console — independent of oversight/moderation/system-health
screens.

This applies uniformly to every open dispute, not just especially
"urgent" ones — the app has no separate urgency-triage tier; "urgent" in
this story's name describes why mobile access matters, not a distinct
requirement (all open disputes are listed newest-first, per the Dispute
key entity).

**Acceptance Scenarios**:

1. **Given** an admin with one or more open disputes, **When** they open
   the disputes list on mobile, **Then** they see each dispute's key
   detail (which job, who raised it, reason) without needing the web
   console.
2. **Given** an open dispute, **When** the admin resolves it from
   mobile, **Then** its status updates immediately and matches what
   resolving it from the web console would produce.
3. **Given** a dispute already resolved by another admin, **When** this
   admin opens it, **Then** they see it as resolved (who resolved it, and
   how) rather than being able to resolve it again.

---

### User Story 2 - Check system health and act on it (Priority: P2)

An admin opens the app to get a quick read on whether the platform is
healthy right now — order volume, active jobs, notification delivery
issues, anything abnormal — so they know whether something needs
attention before it becomes a bigger problem.

**Why this priority**: "System health" oversight matters for catching
problems early, but it's a monitoring capability, not a blocking action —
the app is still useful for its primary job (Story 1) without it.

**Independent Test**: Can be fully tested by opening the oversight/health
view and confirming the figures shown (active jobs, recent order volume,
any flagged delivery/notification failures) match the platform's actual
current state — independent of dispute resolution and moderation.

**Acceptance Scenarios**:

1. **Given** an admin on the oversight view, **When** the platform is
   operating normally, **Then** they see current key figures (e.g. active
   jobs, recent orders) with no alerts.
2. **Given** a genuine problem exists (e.g. a spike in failed
   notifications or payment failures), **When** the admin opens the
   oversight view, **Then** that problem is visibly flagged, not buried
   in ordinary figures.

---

### User Story 3 - Take rapid moderation action (Priority: P3)

An admin needs to act quickly on a moderation matter — for example
suspending a user or provider account, or triggering an off-cycle payout
for an urgent case — without the multi-step depth of the full web
console.

**Why this priority**: Explicitly named ("rapid moderation") and
complements Story 1, but it's for less time-critical or lower-frequency
actions than an active dispute — the app delivers its core value (Story
1 + 2) without this. "Rapid" here means fewer steps than the full web
console (per this story's own body), not a separate timing target the
way Story 1 has SC-001 — moderation actions aren't time-critical in the
same sense a live dispute is.

**Independent Test**: Can be fully tested by locating a specific user/
provider account from mobile and taking one moderation action (e.g.
suspend) or triggering one manual/off-cycle payout, and confirming the
result matches what the same action would produce from the web console —
independent of the other two stories.

**Acceptance Scenarios**:

1. **Given** an admin who has located a specific user or provider
   account, **When** they take a moderation action (e.g. suspend/
   reinstate), **Then** that account's state changes accordingly — and,
   for the payout scenario below where an equivalent web console action
   already exists, matches what that action would produce (account
   moderation itself has no existing web console equivalent yet — see
   Assumptions — so "consistent" here means the underlying account state
   any surface reads stays correct, not parity against a prior web
   action).
2. **Given** an urgent, off-cycle payout case, **When** the admin triggers
   a manual payout for a specific provider from mobile, **Then** it is
   recorded and processed the same way a web-console-triggered payout
   would be.
3. **Given** any moderation action or manual payout (there is no
   lower-risk subset that skips this — see FR-007), **When** the admin
   attempts it, **Then** the app requires an explicit confirmation step
   before applying it — no destructive action fires on a single
   accidental tap.

### Edge Cases

- What happens when two admins try to resolve the same dispute at nearly
  the same time? Only one resolution MUST take effect; the second admin
  MUST see it as already resolved rather than silently overwriting the
  first admin's decision.
- What happens when the admin has no connectivity and opens the app?
  Previously loaded oversight/dispute data MUST be clearly marked as
  possibly stale rather than presented as live.
- What happens when an admin tries to take a moderation action on an
  account that was already deactivated by someone else? The app MUST
  reflect the account's current state rather than letting the admin act
  on stale information.
- What happens when there are zero open disputes? The disputes view MUST
  show a clear "nothing pending" state, not an empty screen that looks
  like a loading failure.
- What happens when a manual payout is triggered for a provider who has
  no outstanding completed jobs to pay out? The app MUST prevent or
  clearly explain a zero/invalid payout rather than silently creating one.
- What happens when a moderation action or manual payout fails on the
  server after the admin has already confirmed it (e.g. lost
  connectivity mid-request)? The app MUST clearly report the failure as
  a failure — never show it as succeeded — and leave the admin able to
  safely retry without double-applying the action.
- What happens when two admins suspend/reinstate the same account at
  nearly the same time? Unlike dispute resolution (a one-way, one-time
  transition), an account's active/suspended status is freely reversible
  either direction — both requests succeed and the account ends up in
  whichever state the later request set, with no error and no risk of a
  lost/conflicting update.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST require the user to be logged in with an admin
  account before showing any administrative content.
- **FR-002**: The app MUST show a list of open disputes with enough detail
  (job, complainant, reason) to act on without switching to the web
  console. A resolved dispute MUST show its resolution status; the app
  MUST NOT present resolved disputes as actionable.
- **FR-003**: The app MUST let the admin mark an open dispute resolved
  (a single terminal outcome — the platform does not currently record a
  separate approve/reject verdict or an escalate state; see Assumptions),
  and MUST prevent resolving a dispute that another admin has already
  resolved — showing instead which admin resolved it (matching
  Acceptance Scenario 3).
- **FR-004**: The app MUST show current platform oversight figures (at
  minimum: active jobs, recent order volume) and MUST visibly flag an
  abnormal condition — defined as more than 5 failed notifications or
  more than 5 failed payments in the trailing 24 hours (a launch-default
  threshold, tunable later) — rather than presenting it identically to
  normal figures.
- **FR-005**: The app MUST let the admin search for a user or provider
  account by name or email (showing enough identifying detail — name,
  email, role, active/verification status — to tell similarly-named
  accounts apart and to confirm the located account before acting) and
  take a moderation action on it: suspend or reinstate. This is the full
  set of moderation actions for this feature (see Assumptions — deeper
  workflows are separately-scoped future work, not an open-ended "at
  least this" list). A search with no matches MUST be shown clearly, not
  as an empty/broken screen. ADMIN-role accounts MUST NOT be a
  moderation target through this app, to prevent an admin from locking
  out another admin — or themselves — by mistake.
- **FR-006**: The app MUST let the admin trigger a manual, off-cycle
  payout for a specific provider — "off-cycle" meaning outside the
  platform's existing scheduled/automatic payout batch.
- **FR-007**: The app MUST require explicit confirmation before applying
  any moderation action or manual payout — no single-tap destructive
  actions.
- **FR-008**: Any *mutation* this app makes to shared platform data
  (dispute resolution, account active/inactive state, a payout record)
  MUST leave that data in the same state the equivalent web console
  action would leave it in — the two surfaces MUST never diverge on the
  underlying data. This governs shared data, not UI parity — a
  read-only figure this app computes and shows (e.g. the oversight alert
  flag) has no requirement to exist on the web console too, and isn't a
  divergence. The deployed admin web console's actual current behavior
  is the reference for "equivalent action," including for account
  moderation, where it currently has no such action at all (see
  Assumptions).
- **FR-009**: The app MUST indicate when shown *list/summary* data may be
  stale (e.g. no current connectivity) rather than presenting cached data
  as live, and MUST recover automatically once connectivity returns
  (via the same periodic refresh that populated it — no separate
  manual-recovery step required of the admin). Staleness only affects
  what's displayed, never what's acted on: every mutating action (resolve/
  suspend/reinstate/trigger payout) is always sent as a fresh request and
  validated against the server's current state, so a stale list can
  cause an admin to see outdated figures but never an incorrect mutation.

### Key Entities

- **Admin profile**: The logged-in admin's identity and authorization
  level.
- **Dispute**: An open or resolved service dispute — the job it relates
  to, who raised it, its reason, its status, and who resolved it.
- **Oversight snapshot**: A point-in-time read of platform health figures
  (active jobs, recent order volume, flagged abnormal conditions).
- **User/provider account**: Any platform account an admin can view and
  take a moderation action against, and its current state.
- **Manual payout**: An admin-triggered, off-cycle payout for a specific
  provider.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An admin can go from opening the app to resolving an open
  dispute in under 60 seconds.
- **SC-002**: Zero disputes are ever resolved twice — a dispute already
  resolved is never shown as actionable to a second admin.
- **SC-003**: An admin can identify whether the platform currently has a
  flagged abnormal condition within 5 seconds of opening the oversight
  view.
- **SC-004**: 100% of moderation actions and manual payouts taken from the
  app require an explicit confirmation step before taking effect.
- **SC-005**: An action taken from the app is reflected in the admin web
  console (and vice versa) within 5 seconds — the two never show
  conflicting state for the same entity. Met by the disputes and
  oversight screens auto-refreshing on a fixed 10-second interval while
  open (matching the existing 10s live-polling precedent already used
  elsewhere in this codebase), not by requiring the admin to manually
  refresh.

## Assumptions

- Admins already have accounts and today use the existing admin web
  console for the full range of administrative work — this app is an
  additional, mobile-first surface for the time-sensitive subset of that
  work (disputes, health, rapid moderation), not a replacement for the
  web console or a new admin role.
- Dispute records, oversight/analytics figures, and payout processing
  already exist as platform capability, with the web console already
  exposing all three — this feature is a new way to view and act on that
  existing capability for those three, not a new backend system of
  record. Dispute resolution itself is, and stays, a single terminal
  outcome (open → resolved) — the platform records no separate approve/
  reject verdict and no escalate state; an admin who needs to escalate a
  case today does so outside the app (e.g. by not resolving it and
  following up directly), not through a distinct in-app action.
- Account moderation state is **not** pre-existing platform capability in
  the same way — confirmed during planning: the underlying active/
  suspended status already existed on every account, but no way to
  change it existed yet — not through the API, and not through the web
  console, which has no account/user management page at all today. This
  feature is, in effect, the first surface to expose account suspend/
  reinstate, not a mobile mirror of an existing web action. FR-008's
  "never diverge from the web console" requirement therefore applies to
  that active/suspended status staying consistent across whichever
  surfaces read or write it (mobile today, potentially web later) — not
  to matching an existing web action, since none exists yet to match
  against.
- "Rapid moderation" in scope for this feature means account-level
  actions (suspend/reinstate) and manual/off-cycle payouts, matching what
  the role matrix names — deeper moderation workflows (e.g. bulk actions,
  full audit-log review) are out of scope unless a later spec extends
  this one.
- A push notification alerting an admin to a new dispute is explicitly
  **out of scope** for this feature: no admin-broadcast notification
  mechanism exists in the platform today (confirmed — dispute creation
  currently only notifies the *other* participant, never any admin), and
  building one is separate, follow-up scope. Story 1 is satisfied by an
  admin opening the app and seeing current open disputes (pull, not
  push).
- Accessibility requirements are out of scope for this feature. No
  accessibility requirements convention exists yet anywhere in this
  codebase (`web/` or `mobile/`); a platform-wide accessibility pass, if
  undertaken, is a separate cross-cutting initiative, not something one
  portal feature should define unilaterally.
- Localization/language requirements are out of scope. The existing
  `web/` and `mobile/` apps are English-only today with no i18n
  convention established; this feature follows that existing precedent
  rather than introducing localization scope no other part of the
  platform has yet.
- This feature does not add a per-action audit trail recording which
  admin suspended/reinstated an account or triggered which manual
  payout. This matches the platform's existing behavior today (its
  pre-existing account-role-change action and its automatic payout batch
  are equally unattributed); a full audit trail is reasonable future
  scope across the whole admin surface, not a gap introduced by, or
  unique to, this feature.
- No specific scale target (concurrent open disputes, searchable
  accounts) is defined for this feature — it relies on the same
  pagination the platform's existing list views already provide
  everywhere else, at the platform's current early-launch scale.
