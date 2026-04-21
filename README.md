# branding-pitch

> A Claude Code plugin that takes a brand — name, URL, Instagram, rough concept — and produces a complete pitch package: visual DNA extraction, AI photography + video campaign (~6 images + 2 videos), polished editorial landing page, served locally. In one flow.

**Built by [LikeAHuman.ai](https://likeahuman.ai).**

---

## What it does

You point `/brand-pitch` at a brand. It returns a served landing page in 5–15 minutes.

1. **Extracts the brand's visual DNA** — fonts, colors, photography style, personality (from the brand's own website + research)
2. **Plans a photography campaign** — ~6 stills + 2 videos, category-appropriate (products get flat lays, food gets macros, service shoots get character references)
3. **Generates everything with Krea.ai** — `nano-banana-pro` for stills, `nano-banana-flash` for faces, `kling-2.5` for video, all in parallel
4. **Builds the landing page with `/frontend-design` + `/high-end-visual-design`** — the brand's actual fonts + colors drive every decision, so the page feels like the brand's in-house team made it
5. **Runs the impeccable polish loop** — `/typeset` → `/polish` → `/critique` — AI-slop checks, typography pass, accessibility, reduced motion, focus states
6. **Serves it locally** at `http://localhost:8888` — ready to show the client

---

## Install

**Via the LikeAHuman.ai plugin marketplace** (recommended):

```bash
/plugin marketplace add likeahuman-ai/claude-plugins
/plugin install branding-pitch
```

**Directly:**

```bash
/plugin install likeahuman-ai/branding-pitch
```

---

## Requires

This skill composes two existing plugins. **Both must be installed** for the end-to-end flow:

| Plugin | Used for | Install |
|--------|----------|---------|
| **Krea.ai** (or compatible image-gen) | AI image + video generation | Requires `KREA_API_TOKEN` env var and `uv` installed. See [Krea.ai docs](https://krea.ai). |
| **[impeccable](https://github.com/pbakaus/impeccable)** | `/frontend-design`, `/high-end-visual-design`, `/typeset`, `/polish`, `/critique` | `/plugin install pbakaus/impeccable` |

Without these, `brand-pitch` will fail at generation (Phase 5) or landing-page build (Phase 6) with a clear message pointing at the missing dependency.

---

## Usage

### Full pitch (default — ~10–15 min)

```bash
/brand-pitch
```

Interactive flow:
1. What brand are we pitching? (name, URL, or attach an image)
2. What's the product/concept?
3. Pick brand personality direction from 4 options derived from the brand's DNA
4. Grab a coffee while Claude generates 6 stills + 2 videos in parallel
5. Landing page builds in the background using the first assets that land
6. `/typeset` → `/polish` → `/critique` for final quality
7. Served at `http://localhost:8888`

### Quick mode (~5–6 min)

```bash
/brand-pitch --quick
# or just say "quick", "fast", "demo mode"
```

Single WebFetch for brand research · 4 stills + 1 video · 8-section page · skips the polish loop. Perfect for live demos and time-boxed client calls.

### One-shot with brief

```bash
/brand-pitch "Patagonia Cumbre — sustainable hiking boot, mountain editorial direction"
```

---

## How it works

```
Brand Research → Visual DNA → Design Language → Shot Plan →
Parallel Image Gen (~6) → Videos in Background (~2) →
/frontend-design + /high-end-visual-design (build page) →
/typeset → /polish → /critique → Serve locally
```

### Phase 0 — Brand research

- Browse the brand's website (WebFetch or Chrome automation)
- Extract fonts from `document.fonts`, colors from CSS bundle
- Optional: spawn `visual-dna-analyst` agent + `Explore` agent in parallel for deeper research (Behance, Dribbble, brand guidelines)
- Download logo SVG/PNG

### Phase 1 — Creative brief (2 questions max)

- What are we shooting? (product, food, space, service, tech)
- Brand personality direction (4 options derived from the extracted DNA — NOT a fixed lookup)

### Phase 2 — Character sheet (if people)

Composite 4 reference photos into a 2×2 grid, generate a character sheet with `nano-banana-flash`, use it as `--image-url` for every shot featuring that person.

### Phase 3 — Shot planning

Category-appropriate: physical products get hero/three-quarter/macro/flat-lay/environment/lifestyle. Food gets hero spread + star dish + texture + ingredients + environment + person. Service shoots lean on the character sheet for the human shots.

### Phase 4 — 7-Pillars prompt formula

```
[MOOD] atmosphere,
[SUBJECT],
[PLACEMENT] on/in [SURFACE/SETTING],
[CAMERA: body + lens + aperture],
[LIGHTING: color temp K + direction + modifier],
[TEXTURE DETAILS],
[STRATEGIC IMPERFECTIONS: film grain, dust, condensation, wear],
[ANTI-AI: NOT CGI, NOT retouched, natural imperfections]
```

Each prompt varies mood opener, camera body, lens, lighting, and strategic imperfections. No two shots in a shoot should share the same stack.

### Phase 5 — Generation

All stills dispatched in parallel, videos run in background via `run_in_background: true`. Default models: `nano-banana-pro` (stills), `nano-banana-flash` (character), `kling-2.5` (video).

### Phase 6 — Landing page

- `/frontend-design` with brand DNA as context (fonts, colors, photography style, personality, chosen direction)
- `/high-end-visual-design` for expensive-feel details (fluid spacing, exponential easing, metric-matched font fallbacks, no pure black/white)
- `/typeset` → `/polish` → `/critique` for typography, polish, and AI-slop detection
- Optional: `/bolder`, `/animate`, `/adapt`, `/colorize`, `/distill` based on critique findings

---

## Output structure

```
[brand-slug]/
├── index.html
├── WORKFLOW.md                  # all prompts for reproduction
├── reference/                   # if character sheet
│   ├── original-photos/
│   ├── composite-reference.png
│   └── character-sheet.png
└── images/
    ├── studio/ or food/   (01–04+)
    ├── location/ or chef/ (05–08+)
    └── video/             (07–08+)
```

Default save location is `./[brand-slug]/` in the current working directory. Override with `--out`.

---

## Cost reference (Krea.ai CU)

| Asset | Model | CU each |
|-------|-------|---------|
| Product still | `nano-banana-pro` | 119 |
| Character still | `nano-banana-flash` | 48 |
| Video 5s | `kling-2.5` | 282 |
| **Standard pitch** (6 stills + 2 videos) | | **~1,280 CU** |
| **Extended campaign** (32 stills + 4 videos) | | **~5,000 CU** |

See Krea.ai pricing for current USD-per-CU rates.

---

## Philosophy

> "The landing page should feel like the brand's in-house team designed it, not like a template got filled in."

Most AI landing-page generators output the same product-page-with-a-hero-and-three-feature-cards. That's because they reach for archetype templates instead of doing the brand research first.

`brand-pitch` does the opposite: spend the first 2 minutes deeply understanding the brand's real fonts, colors, photography, and personality — then let `/frontend-design` make *authentic* decisions from that context. A Patagonia page naturally looks nothing like an Aesop page because the brands ARE nothing alike.

Same logic for the photography: the 7-Pillars formula forces varied mood openers, camera bodies, lighting temperatures, and strategic imperfections — so a 6-image shoot looks like 6 different editorial moments, not 6 variants of the same hero.

---

## Contributing

Issues and PRs welcome at [github.com/likeahuman-ai/branding-pitch](https://github.com/likeahuman-ai/branding-pitch).

Particularly interested in:
- New category shot plans (fashion collections, architecture, interior design, beauty)
- Alternative image-gen backend support (so you can swap Krea for another provider)
- Multi-language support for brand research (currently assumes English/Dutch content)
- Deploy-to-Vercel auto-publish after the pitch is built

---

## Licence

[MIT](./LICENSE) — use freely in client work, personal projects, or agency presentations.

## Related plugins

- [font-hunt](https://github.com/likeahuman-ai/font-hunt) — for when you want to steer the brand AWAY from its default fonts (or help a new brand pick)
- [coding-standards](https://github.com/likeahuman-ai/coding-standards) — to enforce code quality on the generated landing page
- [impeccable](https://github.com/pbakaus/impeccable) — the design skill suite this plugin composes
