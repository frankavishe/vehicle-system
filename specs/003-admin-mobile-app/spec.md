# Feature Specification: Admin Mobile App

**Feature Branch**: `003-admin-mobile-app`

**Created**: 2026-08-28

**Status**: Draft

**Input**: User description: "Admin mobile app: oversight dashboard, urgent dispute approvals, system health, rapid moderation"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Resolve an urgent dispute from a phone (Priority: P1)

An admin, away from their desk, gets notified of an urgent service
dispute (e.g. a customer disputing a fare or a job outcome) and needs to
review and resolve it — approve, reject, or escalate — from their phone,
without waiting until they're back at the admin web console.

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

**Acceptance Scenarios**:

1. **Given** an admin with one or more open disputes, **When** they open
   the disputes list on mobile, **Then** they see each dispute's key
   detail (which job, who raised it, reason) without needing the web
   console.
2. **Given** an open dispute, **When** the admin resolves it (approve/
   reject) from mobile, **Then** its status updates immediately and
   matches what resolving it from the web console would produce.
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
1 + 2) without this.

**Independent Test**: Can be fully tested by locating a specific user/
provider account from mobile and taking one moderation action (e.g.
suspend) or triggering one manual/off-cycle payout, and confirming the
result matches what the same action would produce from the web console —
independent of the other two stories.

**Acceptance Scenarios**:

1. **Given** an admin who has located a specific user or provider
   account, **When** they take a moderation action (e.g. suspend/
   reinstate), **Then** that account's state changes accordingly and is
   consistent with the same action taken from the web console.
2. **Given** an urgent, off-cycle payout case, **When** the admin triggers
   a manual payout for a specific provider from mobile, **Then** it is
   recorded and processed the same way a web-console-triggered payout
   would be.
3. **Given** an ambiguous or high-impact action, **When** the admin
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

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST require the user to be logged in with an admin
  account before showing any administrative content.
- **FR-002**: The app MUST show a list of open disputes with enough detail
  (job, complainant, reason) to act on without switching to the web
  console.
- **FR-003**: The app MUST let the admin resolve a dispute (approve/
  reject), and MUST prevent resolving a dispute that another admin has
  already resolved.
- **FR-004**: The app MUST show current platform oversight figures (at
  minimum: active jobs, recent order volume) and MUST visibly flag
  abnormal conditions (e.g. notification/payment failure spikes) rather
  than presenting them identically to normal figures.
- **FR-005**: The app MUST let the admin locate a specific user or
  provider account and take a moderation action on it (at minimum:
  suspend/reinstate).
- **FR-006**: The app MUST let the admin trigger a manual/off-cycle payout
  for a specific provider.
- **FR-007**: The app MUST require explicit confirmation before applying
  any moderation action or manual payout — no single-tap destructive
  actions.
- **FR-008**: Any action taken from the app (dispute resolution,
  moderation, manual payout) MUST produce the same resulting state as the
  equivalent action taken from the existing admin web console — the two
  surfaces MUST stay consistent, never diverge.
- **FR-009**: The app MUST indicate when shown data may be stale (e.g. no
  current connectivity) rather than presenting cached data as live.

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
  conflicting state for the same entity.

## Assumptions

- Admins already have accounts and today use the existing admin web
  console for the full range of administrative work — this app is an
  additional, mobile-first surface for the time-sensitive subset of that
  work (disputes, health, rapid moderation), not a replacement for the
  web console or a new admin role.
- Dispute records, oversight/analytics figures, account moderation state,
  and payout processing already exist as platform capability (the web
  console already does all of this) — this feature is a new way to view
  and act on that existing capability, not a new backend system of
  record.
- "Rapid moderation" in scope for this feature means account-level
  actions (suspend/reinstate) and manual/off-cycle payouts, matching what
  the role matrix names — deeper moderation workflows (e.g. bulk actions,
  full audit-log review) are out of scope unless a later spec extends
  this one.
- Push notifications alerting an admin to a new urgent dispute are a
  reasonable and expected companion to this app, but the underlying
  notification delivery mechanism is existing platform capability, not
  something this feature defines from scratch.
