# D9B — Three Functional Actor-First UI Variants

**Feature slug:** `actor-first-factory-ui-variants-d9b`
**Mode:** RECON/DESIGN-ONLY. No frontend, backend, schema, or data changes were made. Only this artifact was written.
**Builds on:** `ai/recon/d9a-actor-first-factory-ui-current-flow-recon.md`

---

## 0. Authority Correction — Transcript Now Present

D9A found no transcript anywhere in the repository. The operator has since added one:

> `source-materials/latest-transcripts/call-with-abhilash-kothapalli-3.docx`

("Call with Abhilash Kothapalli," 2026-07-01, 1h26m, Vasu Rao ↔ Abhilash Kothapalli.) This directory did not exist at D9A recon time; it was created by the operator after D9A completed. **This supersedes D9A's "no transcript" finding.** The file was converted to plain text (`textutil -convert txt`, a read-only local conversion — the source `.docx` was not modified) and read in full (685 lines / ~12,800 words). Nothing in this document is reconstructed or guessed beyond what the transcript, D9A, and the operator's explicit direction actually state.

The operator also supplied an explicit **canon insertion** resolving two items D9A flagged as needing a decision. Both are treated as settled for this and all future work:

- **QC authority**: Manager/QC sign-off authority is distinct from generic Supervisor authority. Do not collapse QC sign-off into "Supervisor." *(Note: the transcript itself doesn't use these exact words — this decision is the operator's own call, consistent with the original source-material's RBAC section that D9A already found: "QC sign-off is its own distinct named authority, not merely a permission every supervisor holds." Recorded here as operator-settled, not as a transcript quote.)*
- **`docs/mock-data-contract-d4.md`'s bogus stage table**: confirmed a documentation defect, to be ignored as stage authority. *(Also not discussed in the transcript — an operator decision on a D9A documentation-hygiene finding.)*

Canonical stage/authority order for this document and onward: **current code + `docs/factory-flow-model.md` + original source-materials + this transcript.**

---

## 1. Transcript Extraction

*(Every point below is grounded in a specific transcript line; timestamps are call-time, not real time.)*

### 1.1 What the call actually was

Vasu screen-shared the **exact current D8C prototype** (the same app D9A reconned) and walked Abhilash through it live — the unit list, 14-stage spine, order ID, "assembly active" badge, unit detail fields, part allocations, and Action Panel are all things Abhilash is reacting to on-screen (lines 12–24). Several of Abhilash's comments are direct critiques of what D9A already documented — e.g. confirming stages aren't clickable yet ("these are not clickable yet," line 34; "not yet clickable," line 36), matching D9A's finding that `StageSpine.tsx` is a pure, non-interactive display component.

### 1.2 The stage-numbering moment — read carefully, it is NOT a settled renumbering request

Early in the call, Abhilash muses about renumbering: *"parts allocated is... maybe parts received instead of allocated because from a factory perspective, parts are received at the workstation"* (line 31), then: *"5 is where actually the factory steps started... maybe we want to say that is 01... one through four... are existing preconditions... maybe we want to say one is assembly"* (lines 37–40).

Read in context, this resolves into something more specific two minutes later — Vasu asks directly: *"are we saying each of these stages will be access controlled... let's say I'm an assembler and the device is in stage five, so I can only see what the device is doing in the assembly stage"* (line 70), and Abhilash confirms: *"Correct... why do we even care about 6, 7, 8, 9, 10 while assembly is still in progress... The only thing from an assembler's point of view is: have I received the parts? That's the only precondition"* (line 71–75).

**Conclusion**: the "renumber stage 5 to stage 1" idea was Abhilash thinking out loud toward a UI/visibility problem, not toward a data-model change — the settled point (repeated, confirmed, and acted on for the rest of the call) is **scoped visibility per actor** ("I only see what's relevant to my current stage"), not a change to the canonical 14-stage backend numbering. This document treats the canonical stage model as unchanged (per D9A §6, still ratified by `docs/factory-flow-model.md`), and treats "assembler sees an assembly-scoped view, not the whole spine" as the real, actionable requirement.

### 1.3 Actors — now fully settled

> *"So we have three actors. We have this factory cloud, we have the device software, and then we have the human in the loop, the assembly [guy]... Any other humans except the assembly guy?"* / *"this is a factory floor manager"* / *"so that we have two humans... two logins."* (lines 262–266)

**Two human login actors are in scope for this app, immediately**: **Assembler** and **Floor Manager**. No auth/login is being built yet (see §1.7), but the app is to be functionally scoped around exactly these two.

A literal third "super admin" role was explicitly raised and explicitly deferred: *"let's put the super admin aside for a second because... I don't have a wrap-around what his use case is"* (line 101). It resolves, later in the call, into the floor manager absorbing minimal admin duties rather than a separate persona: *"let's keep the floor manager as admin... there could be multiple floor managers"* (line 269); *"he should be able to add floor managers, remove floor managers, and then probably add and remove assemblers... if neither of the floor managers are available, he should be able to do it... let's lock those two requirements for that user"* (lines 271–277). **There is no separate "super admin" actor to design for right now** — "add/remove assembler" and "add/remove floor manager" are Floor-Manager-tier capabilities.

Non-actor **viewers**, explicitly named as outside the factory and lower priority: *"Vijay should have a real-time dashboard, the sales guy should have his own real-time dashboard"* (line 285); customer status visibility (line 283); inventory notification when a part fails/gets reassigned (lines 287–296). Abhilash's own words: *"these are the non-actors, just... viewers"* (Vasu, line 286, confirmed by Abhilash: "Correct, they're outside of the factory," line 287). **Confirmed secondary/later scope, not an immediate D9B target**, matching the operator's canon item 4.

### 1.4 Floor Manager — job to be done, in Abhilash's own priority order

1. *"How many devices are being manufactured today, and the current stage they are in... units in the queue. As a floor manager, that's my day with no drama."* (lines 105–113)
2. *"What needs my attention"* — specifically, an assembler stuck because a part is bad and needs supervisor approval to pull a replacement: *"there should be an attention panel that should pop up, or the whole focus should shift to that attention panel... I go triage the problem, and then the assembly should continue. That's pretty much my only job — just make sure the factory is flowing smoothly."* (lines 111–125)
3. Secondary, non-urgent-but-useful information, elicited when Vasu asked "are these four things?": incoming order count (for forecasting/staffing decisions, line 129–133); stock/inventory level ("it doesn't have to be right in front of me... but that's useful information I can look at," lines 133–137); resource/assembler availability, including who's on leave tomorrow (lines 143–151).
4. Admin-lite: add/remove assemblers, add/remove floor managers (lines 267–277, see §1.3).
5. Explicitly **out of scope**: any HR/leave-tracking system integration — *"we don't want to build anything that does not add value to us... we're not building our own factory, we're contracting the manufacturing... we don't care about HR processes... but if we're able to fetch the data and show it here, that's a good thing"* (lines 155–171). Treat as: show it later **if** an external feed exists; never build it ourselves.
6. Explicit design principle: *"we want information proactively coming to the users instead of them having to go look in 10 different places"* (line 139).

### 1.5 Assembler — job to be done

1. *"The most important thing is the unit that is under assembly."* (line 175) — full-focus, single-current-unit framing.
2. Readily-available secondary info: *"how many of the [units] that are assigned to me are being blocked or on hold, and what new units are assigned or assembled to me"* (line 177).
3. An assembler can have **multiple** units in flight simultaneously, with one as current focus: *"even though I have worked on [unit] 002, 003 is assigned to me... [unit] 004 is assigned to me but is blocked. So I think the focus should be what I'm currently working on"* (lines 49–53).
4. Work-mode per stage, from the assembler's chair (exact stage-to-percentage numbers were approximate in the live conversation — Abhilash himself says *"I now don't remember how much time an assembler spends,"* line 191 — treat the **pattern**, not the precise numbers, as the requirement):
   - **Assembly (S-05)**: 100% hands-on human time.
   - **SW/FW install & cloud update (S-06/07)**: mostly "start it and walk away" — *"I say download, and then I don't have to spend my time looking at the screens doing the download and install"* (line 189).
   - **Hardware checks (S-09)**: partly human — some checks need immediate attention (button/key checks), others (e.g. a filter-wheel test) run longer and don't need the assembler present (lines 191–201).
   - **Calibration (S-10)**: "start it and walk away," **but** with a real interruption point — sample switching between reference standards currently requires a human, prompted by the sample name shown on screen (lines 201–206, 237). *(A fully automated sample-carousel was raised as a future idea and explicitly deferred: "for now, let's say it's a human doing the switching," line 237 — not an implementation target.)*
   - **QC (S-11)**: described as *"100% time of the assembler"* (line 207) — this is about **time-on-task at the gate**, not sign-off authority; the operator's QC-authority correction (§0) still applies — whoever has hands-on time at the QC bench is not necessarily who is authorized to sign off.
   - **Cloud backup (S-12)**: "start it, go away, come back, it's done or not done" (line 207).
   - **Package (S-13)**: 100% human work (line 211).
5. Explicit design mandate — **declutter, touch-first, information-on-demand**: *"the whole idea... at a point in time I should only see... the unit that I'm assembling"* (lines 43–48); *"assume this is a touchscreen-driven UI... bigger icons and only show [the] icon that is reflecting the context rather than showing too much information... add a small question mark or i-button somewhere so you click on it, then there's more detail"* (lines 79–91); *"the details only matter if something goes wrong"* (line 87).
6. Corrective-action model: when something fails, *"he gets immediate notification and he does whatever action needs to be taken"* (line 225); the underlying truth model is device → cloud → user: *"the device knows why something failed. It sends that information up to the factory cloud. And now the factory cloud should show the user what action he has to take to fix the problem... it should be based on the failure mode... the device has to figure out what the failure is... the cloud has to kind of know: okay, this is the failure, and this maps to this problem, so I present this solution to the user"* (lines 239–246). Failure modes are assumed enumerable/finite for now (*"let's assume that's the case for now,"* line 247) — i.e., this is meant as a **lookup/mapping table** (failure code → instruction), not open-ended reasoning, and it needs to be explicitly programmed in, not inferred: *"we have to program that in"* (line 250).

### 1.6 Real device/cloud truth — a concrete, actionable correction

> *"Everybody should be looking at real-time information. It should not be some human generating the information... when the device is in calibration, the cloud knows it's in calibration... When the device is in the calibration screen, that doesn't mean calibration is happening. Right, when calibration is actually in process, that is when we show calibration. Like, for example, right next to calibration you can have a pill just like gate and block. Instead of blocked, you show 'in progress.' ... without [that], it is in calibration [screen] but it's not actually been in the process of calibration. That's the stage you are in [vs. what's actually running]."* (lines 303–311)

This is a precise, actionable finding: today's `calibration_in_progress`/similar status strings (confirmed by D9A backend recon: static labels set once by the last action call, no real async lifecycle) conflate **"the unit is at the calibration stage"** (a location fact) with **"calibration is actively running right now"** (a live device-truth fact). Abhilash's own proposed UI treatment: a distinct **"IN PROGRESS" badge**, next to the existing GATE/CLOUD-BLOCK badge vocabulary the current app already uses. Real device telemetry to drive this badge does not exist yet (confirmed by D9A §11 — this remains a mocked boolean) — but the **UI concept** (a stage badge and a separate live-activity badge) is a real, transcript-sourced design requirement that can be designed for now, even while the underlying telemetry is still mocked.

### 1.7 Practical build-order constraints (Vasu's own stated plan, confirmed by Abhilash)

> *"I will not jump into auth and logins and things like that right now, but... slash assembler slash [floor-manager], just keep it simple"* (lines 484–486, Abhilash: *"Yes, who cares?"*) — *"it's just going to be wide open on my computer"* (line 486).
> *"the function part of it... I'll have two use cases, the floor manager and the assembly guy... I'll have that separated out"* (lines 490–493).

Confirms D9A Invariant 6 (no premature auth) from the product side too — simple path-based actor separation (e.g. `/assembler`, `/floor-manager`), no login, is the intended near-term mechanism, not a role-switcher-with-accounts system.

### 1.8 Screen/device assumptions

Touchscreen-primary, mouse-compatible: *"assume the UI is a touchscreen-based system, which could also possibly [be] driven by a mouse"* (lines 89–91, 387–389). Physical screen size settled at **11 to 21 inches** diagonal (lines 391–400) — desktops/touchscreens/tablets on the factory floor, explicitly **not** phone-sized. This refines (does not replace) D8C's existing responsive breakpoints — D9B variants should treat ~11" as the smallest realistic target, not a phone viewport.

### 1.9 Attention levels — build the foundation, not the taxonomy

> *"We can later classify immediate attention [into] different attention levels... but for now, let's put all attentions into the immediate category... build a foundation around the thinking that there'll be different levels... but let's just focus on one attention [level] at the moment."* (lines 497–507)

Design should leave room for a future severity taxonomy (e.g. immediate/medium/low) but should **not** attempt to invent that taxonomy now — everything today is "immediate."

### 1.10 Boundary confirmations (reinforces D9A)

*"The eStore is going to be in its own domain, its own boundaries... eStore is never going to talk to factory... once the order is approved, then parts in the inventory is assigned to the order, and once [that's] done, then the order is queued into the factory... there should be restricted boundaries... separate applications, separate boundaries."* (lines 421–425). eStore/Inventory business requirements are explicitly **not yet written** (*"next I'm going to work on the eStore specification,"* line 417) — Factory Cloud must not absorb or anticipate them.

**One nuance worth flagging precisely**: the order narrative Abhilash walks through (customer customizes → adds to cart → sales approves the sale → customer pays → **once payment is received, the order "really becomes an order"** → inventory assigns serialized parts → **order is enqueued into the factory**, lines 429–461) places **serialized-part assignment upstream of the factory queue**, in the Inventory system, before Stage 3 ("Order received by factory"). This is stronger and more specific than D9A could establish from the original source material alone (D9A: "source material silent on payment," "Stage 4 allocation is itself factory-owned"). Two things follow from this, **neither of which is an implementation change today**:
- It supports Abhilash's very first instinct at the top of the call — that Factory Cloud's Stage 4 might be better understood/labeled as **"parts received/confirmed at the factory bench"** rather than "parts allocated," since real allocation (reserving specific serials) may already be complete before the factory even sees the order. This reinforces D9A's flagged gap (§5, §6, §17) with real transcript support — but it is still a **future data-model question**, not something to change in D9B.
- Payment is confirmed to be a real step in the overall Astra X sales flow, but it lives entirely inside the (not-yet-built) eStore application, outside Factory Cloud's boundary — no Factory Cloud UI variant should reference or model payment.

### 1.11 Explicitly out of scope for D9B (raised in the call, explicitly deferred)

- CAD/3D assembly-instruction viewer, screw-torque specs (lines 543–561): *"let's get the basic things going, and then we can plug all of these... it's not a luxury, it's a proper optimization"* — real interest, explicitly sequenced **after** the basics.
- Automated calibration sample-carousel (lines 229–237) — future hardware idea, not a software requirement today.
- VLA models / robotic assembly / "thinking robots" (lines 573–616) — pure future speculation, zero relevance to D9B.
- A generic, product-agnostic MES platform (lines 521–530) — explicitly rejected by Vijay and independently by Claude's own advice per Abhilash: build for the actual use case now, generalize later only if funded/planned.
- HR/leave-tracking integration (see §1.4).

### 1.12 "Three variants" — the literal instruction

> *"Let's stick to three options... three designs focusing on three different things... Not the visual theming and coloring thing. What is the focus?"* / Vasu: *"No, the function."* / Abhilash: *"Correct, the focus of the function... then we can show it to Vijay and pick... what's his take on it."* (lines 475–481) — *"we'll follow the same practice with factory as well, right?"* / *"Yes... all three applications should be the same thing."* (lines 482–483)

Confirms: **three complete, functionally-distinct design options**, each covering both the assembler and floor-manager experiences, presented together for Vijay to choose from — not three separate single-actor apps, not three color palettes.

---

## 2. Crosswalk: Transcript vs. D9A Recon

| D9A finding | Transcript verdict |
|---|---|
| Current UI is an engineering console, not actor-first | **Confirmed directly** — Abhilash's own reaction to the live screen-share (declutter, bigger icons, hide detail behind an i-button, scope to current context) |
| No per-actor scoping/queue exists | **Confirmed as the central ask** — "focus of the screen should be the unit I'm assembling"; assembler has multiple assigned units with one as focus |
| No attention/triage surface for floor manager | **Confirmed as the floor manager's stated #1 and #2 priorities**, with a specific UI mechanism proposed (attention panel takeover) |
| `calibration_in_progress` etc. are static labels, not live device truth | **Confirmed and sharpened** — Abhilash proposes a distinct "in progress" badge separate from the stage badge |
| QC authority conflict (Supervisor vs. Manager/QC tier) | **Not addressed by the transcript** — resolved instead by direct operator instruction (§0) |
| No transcript exists (D9A's own finding) | **Superseded** — transcript now supplied and read in full |
| "Factory work starts at assembly" hypothesis | **Nuanced, not confirmed as a data-model change** — was an exploratory remark that resolved into a scoped-visibility requirement, not stage renumbering (§1.2) |
| "Parts allocated may need to become parts received/confirmed" gap | **Reinforced with stronger evidence** — the transcript's order-flow narrative places serialized-part assignment upstream of the factory queue, supporting (but not yet implementing) a future Stage-4 relabeling |
| Payment step — source material silent | **Filled in** — payment is real, but lives entirely in the not-yet-built eStore app, outside Factory Cloud's boundary |
| Vijay/leadership, sales, customer, inventory viewers not grounded in any artifact | **Now grounded, and explicitly confirmed as later/secondary scope** — matches operator canon item 4 |
| "Super admin" actor — directive asked about it, no source-material support | **Now grounded and resolved**: no separate super-admin persona; floor-manager tier absorbs the two minimal admin actions (add/remove assembler, add/remove floor manager) |
| Screen-size assumptions (D8C's Tailwind breakpoints) | **Refined, not contradicted** — real target hardware is 11"–21" diagonal touchscreens, consistent with D8C's existing compact/standard breakpoints |

---

## 3. What Must Stay Constant Across All Three Variants

Carried forward from D9A §13, now confirmed by the transcript rather than merely proposed:

- Backend remains sole workflow authority — no variant reimplements transition legality, calibration-cap/disposition logic, QC separation-of-duty, cloud hard-stop semantics, or terminal immutability.
- The ratified 14-stage model and its current ownership boundaries are unchanged (the "parts received" relabeling idea in §1.10 is flagged as a **future** data-model question, explicitly not resolved or implemented here).
- No auth, RBAC, or tenanting — actor separation is simple path-based routing (`/assembler`, `/floor-manager`), matching Vasu's own stated plan (§1.7).
- Exactly **two** actor-scoped experiences are designed for: **Assembler** and **Floor Manager**. Vijay/sales/customer/inventory dashboards, a distinct super-admin surface, CAD/3D viewers, and any real device/cloud telemetry integration are explicitly out of scope for all three variants.
- The D8C responsive/touch-target/theme substrate (48×48px touch targets, `[data-theme]` token system, existing Tailwind breakpoints) is preserved and extended, not replaced — now additionally validated against an 11"–21" real-hardware range.
- The existing API contract and demo-reset mechanism are unchanged.
- "Attention" stays a single, undifferentiated severity tier in all three variants (§1.9) — no variant should invent a 3-tier priority system.
- Every variant must hide/declutter raw engineering-console artifacts identified in D9A §12 (raw endpoint-path text, free-text actor-ID fields with no user picker, forced-open detail sections, the generic "Dev — Backend-Guarded Transition" panel) from both actor-scoped experiences — that console can remain reachable separately (e.g. at the existing root route) as an engineering/demo view, but must not be what an assembler or floor manager sees.

## 4. What Can Differ

Which of the three dimensions below is dominant is exactly what makes the three variants genuinely different, per Abhilash's "three different things, not three themes" instruction:

- **Attention-first vs. workflow-first vs. dashboard-first** structural priority.
- Whether the Attention surface is a **full takeover** or a **persistent badge/panel**.
- Whether the assembler's default view is a **single current unit** (with others as a side list) or a **queue with one item expanded**.
- How much of the floor manager's secondary information (orders, stock, resources) is **always visible** vs. **tucked behind a tab/drawer**.
- Navigation model: full route swap between panes vs. simultaneous multi-region layout.

---

## 5. Variant A — "Attention-First / Interrupt-Driven"

**Core idea**: the app's default state is calm and minimal; the moment something needs a human, the relevant Attention surface takes over the whole screen until it's resolved. This is the most literal implementation of Abhilash's repeated words — *"the whole focus should shift to that attention panel"* (floor manager) and *"he gets immediate notification and he does whatever action needs to be taken"* (assembler).

**Assembler (`/assembler`)**
- **Calm state**: one large card — the current unit, its stage, a single big-icon primary action (start scan / start calibration / sign QC checklist / etc.), and a compact strip below showing assigned-but-not-current units (with a BLOCKED chip where relevant).
- **Interrupt state**: whenever the current unit (or any assigned unit) hits a blocked/failed/attention-needed condition, the screen replaces itself with a full-bleed Attention card: what failed (failure-mode-derived instruction text, per §1.5.6), a single clear corrective action button, and a "back to my unit" affordance once resolved.
- New/reassigned units arrive as a small toast + an added chip in the assigned-units strip — not a takeover (only *blocking* problems take over the whole screen).
- The calibration "in progress" vs. "at this stage" distinction (§1.6) is shown as two separate badges on the current-unit card at all times.

**Floor Manager (`/floor-manager`)**
- **Calm state**: the queue (all units in production today, grouped by stage) fills most of the screen; an always-visible but small Attention counter sits at the top.
- **Interrupt state**: the instant the attention count is non-zero, the top of the screen becomes a triage list (blocked units needing a decision — part-replacement approvals, calibration-cap dispositions), and clicking an item opens the existing (already-backend-supported) approval form full-screen.
- Secondary info (incoming orders, stock, assembler availability) lives in a lightweight side rail or bottom tab — visible but never competing with the queue or an active attention item, matching *"it doesn't need my immediate attention, but that's useful information I can look at."*

**Strengths**: most faithful to the literal, most-repeated transcript language; guarantees nothing gets missed; simplest possible "what do I do right now" answer for both actors.
**Trade-offs**: a very quiet day (nothing blocked) and a very busy day (everything blocked) look extremely different — needs careful handling of the calm→interrupt transition so it doesn't feel jarring; a fast-moving floor manager who wants to scan the whole queue at a glance has to actively dismiss/collapse the attention state first.

---

## 6. Variant B — "Current-Unit / Single-Task Workflow-First"

**Core idea**: the app is built around "what is the one thing I'm doing right now," with everything else demoted to a secondary strip or badge rather than a takeover. This most literally implements *"the focus of the screen should be the unit I'm assembling"* and *"units in the queue... that's my day."*

**Assembler (`/assembler`)**
- Full-screen, step-oriented view of the **one current unit**: current stage, one large primary action appropriate to that stage (scan, start calibration, sign QC, etc.), and — only if relevant right now — a corrective-instruction panel (hidden entirely when nothing's wrong, per *"details only matter if something goes wrong"*).
- A persistent bottom strip (not a takeover) lists the assembler's other assigned units with a status chip each (in-progress / blocked / new); tapping one switches the "current unit" focus deliberately — the assembler chooses when to switch, rather than being interrupted.
- Blocked-state and "in progress vs. at-stage" badges are shown inline on the current card, same as Variant A, but without ever forcing a full-screen takeover — the assembler always sees (and controls) the same single-task layout.

**Floor Manager (`/floor-manager`)**
- Default view is the **queue**, organized by stage, exactly as Abhilash described first ("how many devices are being manufactured today, and the current stage they're in" — leftmost/primary screen).
- An attention **count badge** (not a takeover) sits above the queue; clicking it expands an in-place triage list, then collapses back to the queue once handled.
- Secondary info (orders/stock/resources) is a clearly-labeled tab next to the queue, one tap away, never overlaid on top of it.

**Strengths**: simplest, calmest mental model — "one screen, one job" for the assembler, and "my whole day at a glance" for the floor manager; least likely to feel disruptive; very touch-friendly (few, large, stable regions).
**Trade-offs**: attention items are visible but not forced — depends on the actor noticing and clicking the badge; closest of the three to "just don't miss the badge" rather than "impossible to miss," which is a slightly weaker match to the transcript's most emphatic language, though still fully consistent with every explicit requirement.

---

## 7. Variant C — "Dashboard / Command-Center-First"

**Core idea**: keep a persistent, multi-region, always-visible layout — closest in spirit to the current D8C `FactoryFlowBoard` grid — but re-prioritized (attention and current-task content promoted to the top, engineering-console noise removed) rather than replaced with a new interaction pattern. Matches *"a smooth flowing operational day... no drama"* and lets secondary info stay genuinely glanceable rather than hidden.

**Assembler (`/assembler`)**
- A single persistent screen with clearly separated, always-visible regions, top to bottom: (1) Attention banner (only rendered when non-empty), (2) current unit + its one primary action, (3) assigned/blocked units strip, (4) collapsed-by-default supporting detail (parts, calibration history, etc.) behind explicit disclosure — actually collapsed this time, unlike the current app's markup-only disclosure (D9A §4.5).
- No route/pane switching — everything relevant is on one screen, sized and ordered for an 11"+ touchscreen.

**Floor Manager (`/floor-manager`)**
- Same persistent-region philosophy: (1) Attention/triage region at top, (2) today's queue, (3) a secondary-info rail (orders, stock, assembler availability) always present but visually quieter (smaller, muted) than the top two regions.
- Everything the floor manager might want is on screen simultaneously; nothing requires a tab switch, at the cost of a busier screen than Variants A/B.

**Strengths**: lowest engineering risk/most incremental relative to the existing D8C grid substrate (reuses the multi-region layout pattern already built and verified); best fit for a supervisor who wants to scan everything at once without navigating; secondary info is always glanceable exactly as described ("doesn't need my immediate attention, but useful information I can look at").
**Trade-offs**: closest of the three to the current app's shape, so it carries the highest risk of quietly reverting toward "engineering console" feel if discipline around hiding raw/noisy content (§3) slips; busiest screen of the three, which cuts against the "declutter, bigger icons, only show what's relevant" instruction more than A or B do.

---

## 8. Comparison

| Dimension | A — Attention-First | B — Current-Unit Workflow-First | C — Dashboard/Command-Center |
|---|---|---|---|
| Default assembler view | One current unit (calm) | One current unit (calm) | One current unit + all context, always |
| Default floor-manager view | Queue, attention count only | Queue, attention badge | Queue + attention + secondary, all at once |
| How attention is surfaced | Full-screen takeover | Non-blocking badge, in-place expand | Always-visible top banner |
| Navigation model | State-driven (calm ⇄ interrupt) | Actor-driven pane focus switch | Single persistent multi-region screen |
| Risk of missing something urgent | Lowest | Slightly higher (depends on noticing badge) | Low (always visible, but competes for attention with everything else) |
| Closest to current D8C codebase shape | Least | Medium | Most |
| Best for a very busy/chaotic day | Strongest | Good | Can feel cluttered |
| Best for a calm, "no drama" day | Good | Strongest | Good |
| Novelty / redesign effort | Highest | Medium | Lowest |

All three: two actor routes only (no auth), preserve D8C touch/theme substrate, hide all engineering-console noise from D9A §12, keep backend as sole workflow authority, keep attention as a single severity tier, keep the 14-stage model unchanged.

---

## 9. Guidance for Operator Selection (not a recommendation to pick one)

- If the priority is **never missing a blocked unit or a needed approval**, even at the cost of some interface "jumpiness," **Variant A** most literally matches the transcript's most repeated language.
- If the priority is **the calmest possible daily experience** for both actors, with attention still guaranteed visible but never forced, **Variant B** is the safest, simplest build.
- If the priority is **minimizing implementation risk and reusing the existing D8C layout investment**, while still meaningfully decluttering and re-prioritizing it, **Variant C** is the shortest path from today's code to an actor-first feel.

A hybrid is also plausible after review (e.g., Variant B's calm single-task assembler view + Variant A's full-takeover attention behavior for the floor manager) — worth naming as an option when this is shown to Vijay, since the transcript's instruction was to compare three *functional* approaches, not to commit irreversibly to exactly one as-is.

---

## 10. Explicitly Deferred / Out of Scope (unchanged by this document)

Leadership (Vijay) dashboard, sales dashboard, customer status view, inventory notification flow, real device/cloud telemetry integration, CAD/3D assembly-instruction viewer, automated calibration sample-carousel, any HR/leave-system integration, a distinct super-admin persona, multi-level attention severity, and any auth/RBAC/tenanting system. None of these are designed, scoped, or implied to be built by this document.

## 11. Open Items for Operator Confirmation Before Implementation

1. Which of the three variants (or hybrid) to build.
2. Exact route naming (`/assembler` + `/floor-manager` assumed, per Vasu's own stated plan — confirm before implementation).
3. Whether the existing engineering-console view (current `FactoryFlowBoard`) should remain reachable at its current root route for demo/engineering purposes alongside the new actor-scoped routes, or be retired.
4. Whether to begin scoping the "parts received/confirmed at bench" relabeling (§1.10) as a tracked future data-model question, independent of which UI variant is chosen.
5. Confirmation that no further transcript content exists beyond this one file before implementation begins.

---

**Files read for this document:** `source-materials/latest-transcripts/call-with-abhilash-kothapalli-3.docx` (converted read-only to text for extraction; source file untouched), `ai/recon/d9a-actor-first-factory-ui-current-flow-recon.md`.

**Engineering journal:** no entry appended, for the same reason as D9A (§18 of that document) — this is a design/recon artifact, not a completed, `RELEASE_APPROVED` capability advancing the state machine in `ai/state_registry.json`.

**D9B STATUS — COMPLETE | IMPLEMENTATION — NONE | VARIANTS — THREE FUNCTIONAL OPTIONS | NEXT — OPERATOR SELECTION**
