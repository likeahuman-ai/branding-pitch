# branding-pitch

> A Claude Code plugin that takes a brand — name, URL, Instagram, or rough concept — and produces a complete pitch package: visual DNA extraction, AI photography + video campaign (~6 images + 2 videos), polished editorial landing page, served locally. In one flow.

**Built by [LikeAHuman.ai](https://likeahuman.ai)** — Stefan Staats, Jasper Staats, Tim Weeda.

---

## What it does

You point `/pitch` at a brand. You get a served landing page in 5–15 minutes.

1. **Extracts the brand's visual DNA** — fonts, colors, photography signature, implied technical choices, and the emotional *why* behind the brand — all from the brand's own website + optional deeper web research
2. **Plans a photography campaign** — ~6 stills + 2 videos, category-appropriate (products get hero/three-quarter/macro/flat-lay/environment/lifestyle; food gets spreads/macros/ingredients/environment; service shoots use a character sheet)
3. **Generates everything with Krea.ai** in parallel — `nano-banana-pro` for stills, `nano-banana-flash` for locked characters, `kling-2.5` or `seedance` for video
4. **Keeps visual consistency via reference images** — product locked across shots, character locked across shots+videos, and the **still-first → animate** pattern ensures product videos match the product stills exactly
5. **Builds the landing page with `/frontend-design`** — the brand's actual fonts + colors drive every decision, so the page feels like the brand's in-house team made it
6. **Runs a critique-first quality loop** — `/critique` first, then targeted fix only if it flags issues (`/polish`, `/typeset`, `/animate`, etc.) — no wasted time running every polish skill by default
7. **Serves it locally** at `http://localhost:8888` — ready to show the client

---

## Why this over DIY prompting

Three patterns make this plugin genuinely different from "prompt Krea yourself":

### 1. The visual-DNA phase actually understands the brand

Most AI branding tools grab a hex color and a Google Font, call it "extracted brand", and move on. `/pitch` goes further:

- **Photographic signature** — lighting choice, color grading, composition, subject scale, texture treatment
- **Implied technical choices** — what camera/lens/aperture would a real photographer use to shoot this brand? (Patagonia → Leica Q3 28mm f/2.8. Aesop → Hasselblad X2D 80mm f/4.)
- **The *why*** — the emotional signal the brand is trying to send ("we're too serious to perform", "our product is the statement")
- **Style principles** — 3–5 reusable rules that get fed into every image prompt

This happens inline — no external "visual-DNA-analyst" agent needed.

### 2. Reference images are used strategically, not universally

The skill has an explicit decision tree for when `--image-url` helps vs hurts:

- **Product across 8 shots** → use product reference on each (consistency)
- **Detail macro / flat lay** → no reference (composition needs freedom)
- **Character across campaign** → mandatory character-sheet reference
- **Brand mood lock** → NEVER use `--image-url` (it drags the whole composition, kills variety)

### 3. Video uses the still-first → animate pattern

The trick most people miss: if you want a video with a specific product or character, **text-to-video alone generates a similar-but-wrong version every time**. The skill:

1. Generates the hero still FIRST with `--image-url` locked to the actual product
2. Feeds THAT generated still as the **starting frame** to Kling/Seedance
3. Video animates from the exact frame — zero product drift

Plus: smart routing between video engines — **Kling** for realistic physics + camera push-ins, **Seedance** for fluid motion (liquid, fabric, dance, rotation), **Hailuo** as rate-limit fallback.

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

This skill composes **three existing plugins**. All three must be installed for the end-to-end flow:

| Plugin | Used for | Install |
|--------|----------|---------|
| **Krea.ai skills** (image + video generation) | AI stills + videos (`nano-banana-pro`, `nano-banana-flash`, `kling-2.5`, `seedance`, `hailuo-2.3`) | `npx skills add krea-ai/skills` — then set `KREA_API_TOKEN` env var and install [`uv`](https://github.com/astral-sh/uv). See [krea.ai docs](https://krea.ai) for token setup. |
| **frontend-design** (Anthropic official) | `/frontend-design` — builds the landing page from the brand's DNA | `/plugin marketplace add anthropics/claude-plugins-official` → `/plugin install frontend-design` |
| **[impeccable](https://github.com/pbakaus/impeccable)** (pbakaus) | `/critique`, `/polish`, `/typeset`, `/animate`, `/bolder`, `/adapt`, `/colorize`, `/distill`, `/quieter` — the targeted-fix toolkit | `/plugin marketplace add pbakaus/impeccable` → `/plugin install impeccable` |

**Optional:**
- `/high-end-visual-design` — if you have it, run after `/frontend-design` for extra agency-feel details. If not, `/polish` covers most of the same ground.

Without the three required plugins, `/pitch` surfaces a clear error pointing at the missing dep — it does NOT silently degrade.

**Tools used (available to every Claude Code install by default):**
`WebFetch` · `WebSearch` · `Explore` subagent · `Bash`. No custom MCP servers or personal agents required.

**Optional browsing upgrades for JS-heavy brand sites:** Claude for Chrome, `surf-cli`, or Playwright MCP. See the [skill docs](./skills/pitch/SKILL.md#optional-enhanced-browsing-if-the-user-has-the-tools) for details. `WebFetch` covers ~80% of brands on its own.

---

## Usage

### Full pitch (default — ~10–15 min)

```bash
/pitch
```

Interactive flow:
1. What brand are we pitching? (name, URL, or attach an image)
2. What's the product/concept?
3. Pick brand personality direction from 4 options derived from the brand's DNA
4. Grab a coffee while Claude generates 6 stills + 2 videos in parallel
5. Landing page builds in the background using the first assets that land
6. `/critique` runs → targeted fix if needed → served at `http://localhost:8888`

### Quick mode (~5–6 min)

```bash
/pitch --quick
# or say "quick", "fast", "demo mode"
```

Single WebFetch for brand research · 4 stills + 1 video · 8-section page · skips the critique loop. For live demos and time-boxed client calls.

### Full polish loop (opt-in — adds ~3–5 min)

```bash
/pitch --full-polish
```

Runs `/typeset` → `/polish` → `/critique` after the page builds, instead of the default critique-first loop. Use for production-grade client deliverables.

### One-shot with brief

```bash
/pitch "Patagonia Cumbre — sustainable hiking boot, mountain editorial direction"
```

---

## Pipeline

```
Brand Research (WebFetch + inline visual DNA) → Design Language → Shot Plan →
Reference Strategy → Parallel Image Gen → Videos (still-first → animate) →
/frontend-design (build page) → /critique → targeted fix if needed → Serve
```

### The 7 phases

| Phase | What happens |
|-------|--------------|
| **0. Brand research + visual DNA** | WebFetch homepage, extract typography + palette, deconstruct photographic signature (lighting · grading · composition · scale · texture), identify implied camera/lens/aperture, name the brand's *why*, compress into 3–5 style principles. Optional `Explore` subagent for wider context. |
| **1. Creative brief** | 2 questions max — what are we shooting, which of 4 brand-personality directions (A faithful / B amplified / C contrarian / D hybrid) |
| **2. Character sheet** | Only if people are in the shoot. Composite 4 reference photos → 2×2 grid → `nano-banana-flash` character sheet. Used as `--image-url` for every shot featuring that person. |
| **3. Shot planning** | Category-appropriate template (product / food / service / extended campaign). Default 6 stills + 2 videos, AI adjusts per category. |
| **4. Prompt formula** | Eight-part skeleton: mood · subject · placement · camera · lighting · texture · imperfections · anti-AI. Every shot varies mood, camera, lighting temp, and imperfection set — no two identical. |
| **4B. Reference strategy** | Decide per shot: does this need `--image-url`? (hero product yes, detail macro no, character always, brand mood never). Videos use the **still-first → animate** pattern for product consistency. |
| **5. Generation** | Parallel Krea calls. Stills via `nano-banana-pro` (default) or `nano-banana-flash` (character). Videos via `kling-2.5` (physics), `seedance` (fluid motion), or `hailuo-2.3` (fallback). |
| **6. Landing page** | `/frontend-design` with brand DNA as context. Then `/critique` → targeted fix. Served at localhost. |

### Video engine routing at a glance

| Need | Engine | Why |
|------|--------|-----|
| Realistic physics, camera push-ins, human action | `kling-2.5` | Default. Best physics. |
| Fluid motion — liquid pouring, fabric flow, dance, smooth rotation | `seedance` | Smoother continuous motion than Kling |
| Rate-limit fallback | `hailuo-2.3` | When Kling returns 402 |

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

Default save location: `./[brand-slug]/` in the current working directory. Override with `--out`.

---

## Cost reference (Krea.ai CU)

| Asset | Model | CU each |
|-------|-------|---------|
| Product / location still | `nano-banana-pro` | 119 |
| Character still (with face ref) | `nano-banana-flash` | 48 |
| Character sheet (2×2 composite) | `nano-banana-flash` | 48 |
| Video 5s — physics / push-in | `kling-2.5` | 282 |
| Video 5s — fluid motion | `seedance` | varies |
| Video 5s — fallback | `hailuo-2.3` | 180 |
| **Standard pitch** (6 stills + 2 videos) | | **~1,280 CU** |
| **Extended campaign** (32 stills + 4 videos) | | **~5,000 CU** |

See [krea.ai pricing](https://krea.ai) for current USD-per-CU rates.

---

## Philosophy

> "The landing page should feel like the brand's in-house team designed it, not like a template got filled in. The photography should look like 6 editorial moments, not 6 variants of the same hero. The videos should match the stills exactly, not similar-but-wrong."

Most AI branding tools skip the hard parts:
- They extract a color and a font and call it "brand analysis" — they don't deconstruct the *why*
- They run text-to-video with no reference — products drift every time
- They run every polish skill by default — it's slow, usually overkill
- They use a fixed template — every output looks the same

`/pitch` does the opposite on each: inline visual-DNA deconstruction, strategic reference-image use, still-first → animate video pattern, critique-first lean polish loop, and authentic brand-driven layouts from `/frontend-design`.

---

## Contributing

Issues and PRs welcome at [github.com/likeahuman-ai/branding-pitch](https://github.com/likeahuman-ai/branding-pitch).

Particularly interested in:
- New category shot plans (fashion collections, architecture, interior design, beauty, real estate)
- Alternative image-gen backend support (swap Krea for another provider)
- Multi-language brand research (currently English/Dutch friendly)
- Deploy-to-Vercel auto-publish after the pitch is built

---

## Licence

[MIT](./LICENSE) — use freely in client work, personal projects, or agency presentations.

---

## Works with Claude Design (claude.ai/design)

[Claude Design](https://claude.ai/design) (Anthropic Labs) is the visual-editor conversational design studio. `/pitch` is a different tool with a different shape:

| You want | Use |
|----------|-----|
| Visual editing with inline knobs, live tweaks, Canva/PPTX export | **Claude Design** |
| Full AI-photography-plus-page pipeline with brand-DNA research, real photography, and served code | **`/pitch`** |
| A Claude Design handoff bundle needs production photography + code | **Both** — design in Claude Design, bring the handoff into Claude Code, then invoke `/pitch` to add the shoot + landing page |

`/pitch` runs in Claude Code (CLI, web app, IDE extensions) — the same surface where Claude Design handoffs land. Claude Design doesn't expose a public plugin API yet, so there's no native integration — the two products compose via the shared Claude Code surface.

---

## Related plugins

- **[font-hunt](https://github.com/likeahuman-ai/font-hunt)** — when you want to steer a brand AWAY from its default fonts (or help a new brand pick). Often run before `/pitch` to lock fonts.
- **[coding-standards](https://github.com/likeahuman-ai/coding-standards)** — to enforce code quality on the generated landing page
- **[impeccable](https://github.com/pbakaus/impeccable)** — the design skill suite this plugin composes
- **[frontend-design](https://github.com/anthropics/claude-plugins-official)** — Anthropic's official landing-page skill
