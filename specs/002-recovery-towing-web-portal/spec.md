# Feature Specification: Recovery & Towing Web Portal

**Feature Branch**: `002-recovery-towing-web-portal`

**Created**: 2026-08-28

**Status**: Draft

**Input**: User description: "Recovery and towing web portal: fleet dispatch overview, multi-tow tracking, fare estimator, driver performance management"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See and track every active tow at a glance (Priority: P1)

A recovery/towing operator (an individual driver, or someone coordinating
a small fleet of recovery drivers) opens the web portal and sees every
active recovery/towing job at once — where each vehicle is, its status,
and who's handling it — rather than checking one job at a time on a
phone.

**Why this priority**: This is the "fleet dispatch portal" / "multi-tow
overview" the role matrix promises, and it's the reason a *web* portal is
worth building at all for a role whose mobile app already handles a
single active job well — a multi-job overview only makes sense on a
bigger screen.

**Independent Test**: Can be fully tested by logging in as a recovery
operator with 2+ active tow jobs and confirming the portal shows all of
them simultaneously with correct live status and position, distinct from
each other — demoable before performance metrics or a fare estimator
exist.

**Acceptance Scenarios**:

1. **Given** a recovery operator with multiple active tow jobs, **When**
   they open the portal, **Then** they see all active jobs at once, each
   with its current status and the recovery vehicle's live position.
2. **Given** an active tow job shown on the portal, **When** its status
   changes (e.g. en route → loaded → in transit → delivered), **Then**
   the portal reflects the new status without the operator refreshing.
3. **Given** a completed or cancelled tow job, **When** it finishes,
   **Then** it drops off the active-jobs view (and remains visible in
   history/performance elsewhere).

---

### User Story 2 - Estimate a tow's fare before committing (Priority: P2)

Before accepting or dispatching a towing job, the operator checks an
estimated fare based on pickup and drop-off locations, so they know the
job's value before committing time and a vehicle to it.

**Why this priority**: Named explicitly in the role matrix ("fare
estimator") and materially affects which jobs an operator chooses to
take — but the dispatch/tracking core (Story 1) delivers value without
it on day one, since a fare is already computed automatically once a job
exists.

**Independent Test**: Can be fully tested by entering/selecting a pickup
and drop-off pair for a pending tow request and confirming the estimate
shown matches the same fare the job is created with — independent of the
live multi-tow view.

**Acceptance Scenarios**:

1. **Given** a pending tow request with pickup and drop-off locations,
   **When** the operator views it before accepting, **Then** they see an
   estimated fare for that job.
2. **Given** a tow job that has since completed, **When** the operator
   compares its estimate to the final settled fare, **Then** both are
   visible together so any difference is explainable, not hidden.

---

### User Story 3 - Review driver/vehicle performance over time (Priority: P3)

A fleet coordinator reviews how each recovery driver/vehicle has
performed over a period — completed tows, ratings, response times — to
identify who's performing well and who may need support.

**Why this priority**: Explicitly named ("driver performance mgmt") but
it's a periodic management task, not something blocking day-to-day
dispatch — the portal is fully useful for running today's tows without
it.

**Independent Test**: Can be fully tested by selecting a driver and a
date range and confirming the shown completed-tow count, average rating,
and response-time figures match that driver's actual job history for the
period — independent of the live dispatch view and the fare estimator.

**Acceptance Scenarios**:

1. **Given** a recovery operator/fleet coordinator, **When** they open the
   performance view for a specific driver, **Then** they see that
   driver's completed tow count, average customer rating, and typical
   response time for a selectable period.
2. **Given** a driver with no completed tows in the selected period,
   **When** their performance is viewed, **Then** the portal shows an
   empty state rather than an error or zero-filled chart that looks
   broken.

### Edge Cases

- What happens when two active tows' routes visually overlap on the map?
  Each job MUST remain individually selectable and identifiable, not
  merged or ambiguous.
- What happens when a recovery vehicle's live position hasn't updated
  recently (driver's connection dropped)? The portal MUST indicate the
  position is stale rather than silently showing an old point as current.
- What happens when a fare estimate is requested for a drop-off in an
  area with poor road-network data? The portal MUST still show a fare
  estimate (via whatever fallback the platform already uses) rather than
  failing outright.
- What happens when a single operator account is used for more than one
  physical recovery vehicle? The portal MUST distinguish jobs by vehicle/
  driver, not merge them into one undifferentiated stream.
- What happens when a performance query covers a period with only
  cancelled tows and no completed ones? The portal MUST make that
  distinction visible (cancelled ≠ completed) rather than showing 0 with
  no context.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The portal MUST require the user to be logged in with a
  verified recovery/towing account before showing any operational
  content.
- **FR-002**: The portal MUST show all of the operator's currently active
  tow jobs simultaneously, each with status and live vehicle position.
- **FR-003**: The portal MUST update an active job's displayed status and
  position as they change, without requiring a manual refresh.
- **FR-004**: The portal MUST remove a job from the active view once it
  completes or is cancelled, while keeping it accessible in history.
- **FR-005**: The portal MUST show an estimated fare for a pending tow
  request given its pickup and drop-off locations, before the operator
  commits to it.
- **FR-006**: The portal MUST show, for a completed tow, both its original
  estimate and its final settled fare together.
- **FR-007**: The portal MUST let the operator view a specific driver's
  performance (completed tow count, average rating, typical response
  time) over a selectable period.
- **FR-008**: The portal MUST distinguish between "no completed tows in
  this period" and "no data available" when showing performance figures.
- **FR-009**: The portal MUST only show the logged-in operator jobs and
  performance data they are authorized to see (their own, or their
  fleet's) — never another operator's or another role's data.
- **FR-010**: Job status changes made from the portal MUST be reflected in
  the customer's own tracking view without the customer needing to
  refresh manually.

### Key Entities

- **Recovery operator profile**: The logged-in operator's identity,
  availability, and (if applicable) the set of drivers/vehicles they
  coordinate.
- **Tow job (service request)**: A recovery/towing job — status, pickup
  and drop-off locations, assigned driver, estimated fare, final fare.
- **Live position**: A recovery vehicle's current location as of its last
  update, including how stale that update is.
- **Fare estimate**: A computed estimate for a pickup/drop-off pair, shown
  before job commitment and compared against the final fare afterward.
- **Driver performance record**: Aggregated completed-tow count, average
  rating, and response-time figures for a driver over a period.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An operator can see the status and position of every one of
  their active tows within 5 seconds of opening the portal.
- **SC-002**: 100% of job status/position changes appear in the portal
  within 5 seconds of occurring.
- **SC-003**: An operator can get a fare estimate for a pending tow in
  under 10 seconds of opening that job.
- **SC-004**: An operator can pull up a specific driver's performance for
  a chosen period in 3 or fewer interactions.
- **SC-005**: Zero active tows are ever shown merged or misattributed to
  the wrong job when two or more are active at once.

## Assumptions

- Recovery/towing operators already have verified accounts and a mobile
  app they use today for handling one active job at a time — this portal
  adds the desktop, multi-job, and management views on top of that same
  identity, not a new registration flow.
- Fare estimation, live position tracking, and fare settlement already
  exist as platform capability (used today by the mobile app and the
  customer's tracking view) — this feature surfaces that existing data,
  it does not define a new fare formula or tracking mechanism.
- "Fleet" here can mean a single operator/driver acting alone, or one
  account coordinating several drivers/vehicles — the portal must support
  the single-operator case at minimum; multi-driver coordination is
  P1-compatible but its full management (e.g. assigning jobs to specific
  drivers) is not separately specified here beyond the performance view
  in Story 3.
- Driver ratings already exist as platform capability (customers already
  rate completed jobs) — this feature aggregates and displays them, it
  does not introduce a new rating mechanism.
