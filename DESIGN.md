# Squadar — Design Language

Scope: visual and frontend design language only. Product behavior is owned by `REQUIREMENTS.md`.
`style-guide.html` is the reference implementation of everything below; a change here changes that
file in the same commit.

## Required Design Inputs
- Brand personality: professorial, professional, teacher, respectful
- Primary audience: Administrators (manage the skill catalog, exams and user accounts), Assessors (managers or leads who run assessments and record scores for their team), Team Members (take exams and view their own scores), and Viewers (read-only access to team charts) — per `REQUIREMENTS.md`.
- Platform targets (web / mobile / both): both
- Light / dark mode: both
- Existing brand assets: REQUIREMENTS.md only

## Brand and Logo

**Brand direction.** Squadar measures people and shows the result to those people. The design language
is therefore calm, exact and unshowy: an instrument, not a scoreboard. Charts and scores are the loudest
things on any screen; the interface around them recedes. Nothing gamifies a low score, and no visual
device ranks a person as a whole — only skills, on their stated 1–10 scale.

**The mark.** `logo.svg` is a six-axis radar grid with a filled, irregular skill profile plotted on it.
The hexagonal outline is the 1–10 scale at full extent; the inner ring is a midpoint gridline; the teal
polygon is one assessed profile, deliberately uneven, because real profiles are. It is the product's
core artifact (FR-7.1) drawn at logo scale — no metaphor, no mascot, no initial letter.

**Usage.**
- Clear space: at least the width of one hexagon "radius" (25% of the mark's width) on all four sides,
  free of other elements.
- Minimum display size: 24 px square. Below 32 px, drop the inner gridline and the six vertex dots and
  keep the outer hexagon, the profile polygon and the centre dot.
- Backgrounds: designed for light backgrounds (`background`, `surface`). On dark backgrounds, redraw the
  navy strokes in `text` (dark-mode value) and keep the teal profile; do not place the light-mode file
  on a dark field.

**Incorrect usage.** Do not recolor the mark outside the documented palette, stretch it to a
non-square aspect, rotate it, add effects (shadow, gradient, bevel, outline), place it on a photograph
or a busy field, enclose it in a badge or circle that is not part of the mark, or set the wordmark
"Squadar" in a font other than the primary family.

## Color Palette

Restrained by intent: one navy for structure and authority, one teal for plotted data and primary
action, and neutrals for everything else. Error and success are used only for form feedback and system
state — never to characterize a person's score.

### Light mode (default)

| Token | Hex | Use |
| --- | --- | --- |
| `primary` | `#1F3A5F` | Headers, chart axes and grid, primary emphasis, logo structure |
| `secondary` | `#0F6F6C` | Primary action, links, plotted data series, logo profile |
| `background` | `#F7F8FA` | Page ground |
| `surface` | `#FFFFFF` | Cards, panels, inputs, chart canvas |
| `text` | `#14181F` | Body and heading text |
| `text-muted` | `#525C6B` | Secondary text, labels, helper text |
| `border` | `#D3D8E0` | Input and card borders, dividers |
| `error` | `#B3261E` | Validation failure, destructive confirmation |
| `success` | `#1B6B3A` | Saved, submitted, passed state |

### Dark mode

| Token | Hex | Use |
| --- | --- | --- |
| `primary` | `#9FBAD9` | As above, inverted for legibility on dark |
| `secondary` | `#4FC4BE` | Primary action, links, plotted data series |
| `background` | `#11151B` | Page ground |
| `surface` | `#1A2029` | Cards, panels, inputs, chart canvas |
| `text` | `#EDF0F4` | Body and heading text |
| `text-muted` | `#A6B0BE` | Secondary text, labels, helper text |
| `border` | `#333C49` | Borders and dividers |
| `error` | `#F2B8B4` | Validation failure |
| `success` | `#7FD6A0` | Saved, submitted, passed state |

### Logo colors

`logo.svg` uses exactly two: `#1F3A5F` (`primary` — outer hexagon, inner gridline at 35% opacity,
centre dot) and `#0F6F6C` (`secondary` — profile stroke, vertex dots, and the same color at 22% fill
opacity for the profile area).

### Contrast

All pairings below meet or exceed WCAG 2.2 AA (4.5:1 body text, 3:1 large text and non-text).

| Pairing | Ratio | Meets |
| --- | --- | --- |
| `text` on `background` (light) | 16.8:1 | AA / AAA body |
| `text` on `surface` (light) | 17.8:1 | AA / AAA body |
| `text-muted` on `surface` (light) | 6.8:1 | AA body |
| `secondary` on `surface` (light) | 6.0:1 | AA body |
| `primary` on `surface` (light) | 11.5:1 | AA body |
| `surface` on `secondary` (light, button) | 6.0:1 | AA body |
| `surface` on `primary` (light, button) | 11.5:1 | AA body |
| `error` on `surface` (light) | 6.5:1 | AA body |
| `success` on `surface` (light) | 6.5:1 | AA body |
| `border` on `surface` (light) | 1.4:1 | decorative only — never the sole indicator of state |
| `text` on `background` (dark) | 16.0:1 | AA / AAA body |
| `text-muted` on `surface` (dark) | 7.5:1 | AA body |
| `secondary` on `surface` (dark) | 7.8:1 | AA body |
| `error` on `surface` (dark) | 9.6:1 | AA body |

Chart series are distinguished by shape and line pattern in addition to hue (see Accessibility), so the
series palette carries no contrast obligation of its own beyond 3:1 against the chart canvas.

## Typography

**Primary family.** The platform system UI stack, applied as one family:

```
-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif
```

**Numeric and code.** `ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace` — used for
1–10 scores in tables, so digits align in columns.

**Why.** System fonts need no network request, no license, and no font-loading fallback flash; they
render at native hinting quality on every platform target; and they are the neutral, unbranded choice
appropriate while the broader typography direction is unsettled.

**Broader typography direction: TO BE DECIDED.** Whether Squadar adopts a distinct open-licensed brand
face (a humanist serif for headings would suit "professorial") is open. The system stack above is the
provisional default and is what `style-guide.html` renders today.

**Type scale** (1.25 ratio, 16 px base):

| Step | Size | Line height | Weight | Use |
| --- | --- | --- | --- | --- |
| Display | 39 px / 2.441rem | 1.2 | 600 | Page title, one per screen |
| H1 | 31 px / 1.953rem | 1.25 | 600 | Section heading |
| H2 | 25 px / 1.563rem | 1.3 | 600 | Subsection heading |
| H3 | 20 px / 1.25rem | 1.4 | 600 | Card and panel heading |
| Body | 16 px / 1rem | 1.6 | 400 | Default text |
| Small | 14 px / 0.875rem | 1.5 | 400 | Helper text, table labels |
| Caption | 12.8 px / 0.8rem | 1.4 | 500 | Chart axis labels, metadata |

**Weights.** 400 (body), 500 (labels, emphasis), 600 (headings, buttons). No other weights; no italic
for headings; never set body text below 14 px.

## Layout and Spacing

**Spacing scale** (4 px base, used for padding, margin and gap — no ad-hoc values):

`4, 8, 12, 16, 24, 32, 48, 64, 96` px — referenced as `space-1` … `space-9`.

**Grid.** 12 columns with a 24 px gutter at desktop, 8 columns at tablet, 4 columns at mobile. Content
column max width 1200 px, centred, with a minimum 16 px page gutter at every width. Long-form text
(requirements, help, exam questions) caps at 72 characters per line.

**Density.** Forms and detail views are comfortable (16–24 px internal padding); score tables are
compact (8–12 px cell padding) because comparison across rows is the point.

**Breakpoints.**

| Name | Range | Behavior |
| --- | --- | --- |
| Mobile | < 600 px | Single column; chart above its controls; score table scrolls horizontally in its own container |
| Tablet | 600–1023 px | Two columns; chart and controls stack |
| Desktop | ≥ 1024 px | Chart and its selection/legend panel side by side |

The radar chart is square and scales with its container, never below 280 px on a side; below that,
show the tabular score view instead (FR-6.2 carries the same information).

**Elevation.** One level only: `surface` on `background`, separated by a 1 px `border`. No shadows
except a subtle one on transient overlays (menus, dialogs).

## Components

**Buttons.** Three variants: primary (filled `secondary`, `surface`-colored label — the single main
action per view), secondary (transparent, 1 px `border`, `text` label), and destructive (filled
`error`) reserved for deletion and deactivation. Minimum hit target 44×44 px. Hover darkens the fill
or border by a perceptible step; active depresses it further; disabled drops opacity and removes the
pointer cursor, and is never the only signal that an action is unavailable — say why in adjacent text.
Buttons that start a slow action (exam submission, chart render) show a busy state and stay disabled
until it resolves, rather than being clickable twice.

**Inputs.** Every input has a persistent visible label above it — placeholders are never the label.
1 px `border` on `surface`, rounded 4 px, 16 px text so mobile browsers do not zoom on focus. Helper
text sits below in Small/`text-muted`. Required fields are marked in the label, not by color alone.
Score entry accepts only integers 1–10 (FR-4.2) and states that range in helper text before the user
errs. Selection of team members and skills for a chart uses checkable list items with a visible count
of the current selection against its limit (FR-7.6, FR-7.7).

**Links.** `secondary`, underlined in body text and on hover; underline is never removed in prose.
Navigation and control links may drop the underline when their role is unambiguous from position, but
must then show another non-color affordance on hover.

**Focus states.** Every interactive element shows a 2 px `secondary` outline with a 2 px offset on
keyboard focus, visible against both `surface` and `background` and never clipped by an ancestor's
overflow. Focus is never removed without an equivalent replacement, and mouse interaction does not
suppress it for subsequent keyboard use.

**Form feedback and errors.** Validate on submit, and on blur only for a field the user has already
completed — never on first keystroke. An error shows three things at once: the field border in `error`,
an icon or symbol next to the message, and message text in `error` naming what is wrong and what
to do ("Score must be a whole number from 1 to 10"), programmatically tied to its input. On submit
failure, focus moves to the first invalid field and a summary lists every error with links to the
fields. Success is confirmed in text in `success`, not by color alone, and the confirmation persists
until the user moves on rather than vanishing on a timer.

**Charts.** The radar chart gets its own conventions: one axis per selected skill labelled at its
vertex in Caption, rings at 2/4/6/8/10, and each team member's series drawn with a distinct hue plus a
distinct line pattern and vertex shape. A legend names every series, and each legend entry toggles its
series (FR-7.11). Skills with no score for a member break the polygon at that axis and are marked in
the legend rather than plotted as a value (FR-7.9). Empty state (no selection) shows the bare grid and
a sentence saying what to select (FR-7.10).

## Accessibility

Target conformance: **WCAG 2.2 AA**, for every screen, on both platform targets and in both modes.

- **Contrast.** Text meets 4.5:1 (3:1 for text at 24 px, or 19 px bold and above). UI boundaries,
  focus rings, chart lines and icons that carry meaning meet 3:1 against their adjacent color.
- **Visible focus.** Keyboard focus is always visible, at least 2 px thick with a 2 px offset, and
  meets 3:1 against both the component and the background. Focus order follows reading order, and it
  never falls behind a sticky header or overlay.
- **Keyboard.** Everything a pointer can do, a keyboard can do — including selecting team members and
  skills, toggling chart series, taking and submitting an exam, and paging score tables. No keyboard
  trap; dialogs return focus to the element that opened them; a skip link precedes the main content.
- **Not color alone.** Score, state and chart series are always distinguishable without color:
  a number, a label, an icon, a line pattern or a shape accompanies every hue.
- **Text and zoom.** Layout survives 200% zoom and 320 px width without horizontal scrolling of the
  page; only tables and the chart may scroll inside their own container.
- **Reduced motion.** Under `prefers-reduced-motion: reduce`, all non-essential animation and
  transition is removed — chart series appear at their final position rather than animating in, and
  no content moves, parallaxes or auto-advances. Nothing flashes more than three times per second
  under any setting.
- **Names and structure.** Every control has an accessible name; headings are nested in order; the
  chart carries a text alternative and is backed by the equivalent score table (FR-6.2), which is the
  accessible route to the same data rather than an afterthought.
