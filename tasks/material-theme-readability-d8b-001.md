# Task: Implement MD3 CSS token system and theme toggle in FactoryFlowBoard

## Parent Spec
specs/material-theme-readability-d8b.md

## Phase
phase-demo-readiness

## Status
done

## Layer
frontend-tokens

## Description
Write the complete Material Design 3 CSS variable token system into
`frontend/src/styles.css`. Define both `[data-theme="light"]` and
`[data-theme="dark"]` blocks with all --mds-* and --factory-* tokens.
Define all semantic CSS helper classes (.app-bg, .surf, .surf-low, .surf-container,
.surf-high, .t-on-surface, .t-on-surface-var, .b-outline, .b-outline-var,
.surf-primary, .t-on-primary, .b-primary, .t-primary, .surf-error, .t-on-error,
.b-error, .surf-gate, .t-on-gate, .b-gate, .surf-cloud, .t-on-cloud, .b-cloud,
.surf-success, .t-on-success, .b-success, .surf-supervisor, .t-on-supervisor,
.b-supervisor, .mdc-card, .mdc-card-container, .mdc-input, .mdc-select,
.mdc-divider).

In `frontend/tailwind.config.js`, disable media-query darkMode with `darkMode: false`
to prevent system preference from overriding our data-theme approach.

In `frontend/index.html`, add the inline theme-init script (no FOUC) in `<head>`,
add meta tags: `app-d8b="material-theme-toggle"` and `app-d8b-theme="true"`.
Retain all existing D8/D8A meta tags.

In `frontend/src/components/FactoryFlowBoard.tsx`, add `useState<'light'|'dark'>`
initialized from localStorage, `useEffect` to set data-theme on document.documentElement,
add toggle button in header, apply `app-bg` to the root div, replace
`data-theme="light-review"` with `data-d8b-material-theme="true"`, keep
`data-d8-demo-readiness="true"` and `data-d8a-readability="true"`.

## Acceptance Criteria
- [ ] styles.css has [data-theme="light"] block with all --mds-* and --factory-* tokens
- [ ] styles.css has [data-theme="dark"] block with matching tokens
- [ ] All semantic CSS helper classes defined (.app-bg through .mdc-divider)
- [ ] tailwind.config.js has darkMode: false
- [ ] index.html has inline theme-init script before </head>
- [ ] index.html has app-d8b="material-theme-toggle" meta tag
- [ ] index.html retains app-d8a="light-review" and app-d8="demo-readiness" meta tags
- [ ] FactoryFlowBoard root div has data-d8b-material-theme="true"
- [ ] FactoryFlowBoard has useState theme with localStorage init
- [ ] FactoryFlowBoard useEffect sets document.documentElement data-theme attribute
- [ ] Toggle button in FactoryFlowBoard header (shows "Light" or "Dark")
- [ ] Root div uses app-bg class (not hardcoded bg-[#FAFAF7])

## Files Likely Affected
- frontend/src/styles.css (REWRITE)
- frontend/tailwind.config.js (UPDATE)
- frontend/index.html (UPDATE)
- frontend/src/components/FactoryFlowBoard.tsx (UPDATE)

## Blocked By
- none
