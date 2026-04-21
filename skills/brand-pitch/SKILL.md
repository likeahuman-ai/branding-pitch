---
name: brand-pitch
description: Pitch a brand end-to-end — analyze the brand's visual DNA, generate an AI photography + video campaign (~6 images + 2 videos), build a polished editorial landing page served locally. For agencies, freelancers, or founders presenting a brand or product concept. Triggers on "brand pitch", "pitch this brand", "build a brand page", "analyze and pitch", "make a landing page for", "branding pitch", or similar brand-to-page requests.
argument-hint: "[brand name or URL]"
user-invocable: true
---

# Brand Pitch — Analyze, Generate, Pitch

Take a brand (name, URL, Instagram, or rough concept) and produce a complete pitch package in one flow:

1. **Extract the brand's visual DNA** (fonts, colors, photography style, personality)
2. **Generate an AI photography campaign** (~6 stills + 2 videos, the AI decides the exact split based on category)
3. **Build a polished editorial landing page** that feels like the brand designed it themselves
4. **Serve it locally** for you to show the client

---

## Required companion plugins

This skill composes two existing tools. **Both must be installed** for `/brand-pitch` to run end-to-end:

| Plugin | Used for | Install |
|--------|---------|---------|
| **[Krea.ai skill](https://github.com/likeahuman-ai/krea-ai)** (or equivalent image-gen setup) | AI image + video generation | Requires `KREA_API_TOKEN` env var and `uv` installed. See the krea-ai README for setup. |
| **[impeccable](https://github.com/pbakaus/impeccable)** | `/frontend-design`, `/high-end-visual-design`, `/typeset`, `/polish`, `/critique` | `/plugin install pbakaus/impeccable` |

If either is missing, `brand-pitch` will fail at the corresponding phase — check Phase 5 (generation) or Phase 6 (landing page) output for guidance.

---

## Quick mode (DEFAULT for time-boxed pitches)

**Target wall-clock:** ~5–6 minutes from "go" to served landing page.

**Trigger when user says:** "quick", "fast", "demo mode", "--fast", "--lite", or when the context is clearly time-boxed (live audience, client call, tight deadline).

**What's different from the full pipeline:**

| Step | Full pipeline | Quick mode |
|------|---------------|------------|
| Brand research | `visual-dna-analyst` agent + browser automation + CSS extract | **ONE `WebFetch` on the homepage**, grep the CSS bundle inline |
| Direction question | 4 options (A/B/C/D) | **1 recommended direction** derived from the CSS, one-line confirm |
| Shot count | 6–8 stills + 2 videos | **4 stills + 1 video** (hero, detail, lifestyle, macro + 1 rotation video) |
| Landing page sections | 10–12 | **8** — hero · intro · logic I · logic II · magic · video · spec · CTA |
| Polish loop | `/typeset` → `/polish` → `/critique` | **Skip.** `/frontend-design` + `/high-end-visual-design` output is the deliverable |
| WORKFLOW.md | Full reproducibility | **Skip** |

**Quick mode flow:**

1. User: "pitch Brand X" (may attach image or paste URL)
2. `WebFetch` the brand homepage once. Grep fonts + colors from the HTML/CSS. Present a 3-line DNA summary:
   > **[Brand]** — [display font] / [body font], palette `#XXXXXX` `#YYYYYY` `#ZZZZZZ`. Direction: **[one line concept]**. Go, or tweak?
3. User: "go" (or specifies a tweak)
4. Write 4 still prompts + 1 video prompt using the 7-Pillar formula (below)
5. Dispatch all 5 generations in parallel:
   ```bash
   mkdir -p logs images video
   uv run ~/.claude/skills/krea-ai/scripts/generate_image.py \
     --prompt "$(cat prompts/01-hero.txt)" \
     --filename "images/01-hero.png" \
     --model nano-banana-pro --width 1280 --height 1024 \
     > logs/01.log 2>&1 &
   # ... 3 more stills + 1 video in background ...
   wait
   ```
   (Path to `generate_image.py` depends on where the krea-ai plugin is installed. Check `~/.claude/plugins/` or `~/.claude/skills/` for the actual location.)
6. **While gens run**, draft the 8-section `index.html` using `/frontend-design` with brand tokens hardcoded from the WebFetch result
7. When gens land: `ls images/` to verify, start `python3 -m http.server 8888`, hand over the URL
8. Done. No WORKFLOW.md, no polish loop.

**Skip Quick mode when:**
- Brand needs a character sheet (founder, chef, model across multiple shots)
- Production-grade campaign for real client delivery
- Extended multi-page campaign (20+ images)
- User explicitly asks for the full build

---

## Full pipeline

```
Brand Research → Visual DNA → Design Language → Shot Plan →
Parallel Image Gen → Videos in Background →
/frontend-design + /high-end-visual-design (build page) →
/typeset → /polish → /critique → Serve
```

### Default target output

- **~6 images + 2 videos** (AI decides exact split based on category — physical product may need 8 stills, service shoot may need 4 + 2 videos, etc.)
- **One landing page** with 10–12 sections, built live in ~2–3 minutes after assets land
- **Served at** `http://localhost:8888` (or next free port)

---

## Phase 0: Brand Research

Before any creative work, deeply understand the brand. Run these **in parallel**:

### Step 1: Browse the brand

Use browser automation (`mcp__claude-in-chrome`) or `WebFetch` to visit:
- Instagram profile — grid aesthetic, bio, tone
- Website — hero, navigation, overall feel
- Extract CSS: fonts loaded, color values, backgrounds

### Step 2: Visual DNA agent (background)

If available, spawn the `visual-dna-analyst` agent to research the brand's visual identity:
```
Agent({
  subagent_type: "visual-dna-analyst",
  description: "Extract visual DNA for [brand]",
  prompt: "Analyze the visual identity of [brand]. Extract: fonts, color palette, photography style, brand personality, what makes them distinctive.",
  run_in_background: true
})
```

If the agent isn't installed, do the analysis inline from WebFetch results.

### Step 3: Explore agent (background)

Search for design case studies, Behance portfolios, brand guidelines:
```
Agent({
  subagent_type: "Explore",
  description: "Research [brand] design assets",
  prompt: "Search for [brand] brand guidelines, logo SVG, design case studies on Behance/Dribbble, published visual identity documentation.",
  run_in_background: true
})
```

### Step 4: Synthesize + download assets

When research completes, consolidate:
- **Fonts** — exact families, weights, roles
- **Colors** — primary, secondary, accent (hex)
- **Photography style** — from Instagram + research
- **Brand personality** — 3–5 adjectives
- **Logo** — download SVG/PNG from the website

### Step 5: Lock the design language

Present a summary table:

| Element | Value |
|---------|-------|
| Display font | [extracted] |
| Body font | [extracted] |
| Accent font | [if any] |
| Primary colors | [hex values] |
| Photography style | [description] |
| Brand personality | [adjectives] |

Then ask the brand personality question (4 options derived from the extracted DNA — NOT a fixed lookup table). Lock the creative brief.

---

## Phase 1: Creative brief (2 questions max)

**Question 1 — What are we shooting?** Open-ended:
- Physical product (bag, shoe, watch, device)
- Food/beverage (restaurant, drink, ingredients)
- Space/venue (hotel, co-working, retail)
- Service/experience (private chef, event, consultancy)
- Tech/SaaS (app, platform, tool)

**Question 2 — Brand personality direction.** Derive 4 options FROM the visual DNA:
- **A)** Most faithful to existing brand identity
- **B)** Fresh interpretation that amplifies what's there
- **C)** Contrasting direction that challenges expectations
- **D)** Hybrid mixing brand DNA with a different aesthetic

**DO NOT use a fixed category lookup table.** Every brand gets unique options from its actual DNA.

**Lock:** brand + what they do · fonts · colors · key visual · chosen direction · 1-line concept · location.

---

## Phase 2: Character sheet (only if people are in the shoot)

When needed: chefs, founders, models across multiple shots.

1. User provides 3–6 reference photos (front, angle, profile, full body)
2. Save to `project/reference/`
3. Stitch 4 best face photos into 2×2 composite via Pillow
4. Generate character sheet via `nano-banana-flash` with composite as `--image-url`
5. Use approved sheet as `--image-url` for all shots featuring this person

Key settings:
- **Model:** `nano-banana-flash` (best face preservation from references)
- **Composite reference** beats single photo
- **flux-kontext** goes cartoon — avoid for character sheets
- For shots with the character: prefix "This exact man/woman from the reference image..."

---

## Phase 3: Shot planning by category

Default target is 6 images + 2 videos — adjust per category.

### Physical products (bag, shoe, watch, etc.)

| # | Shot | Angle |
|---|------|-------|
| 1 | Hero front/side | 15° tilt |
| 2 | Three-quarter / open | 45° elevated |
| 3 | Detail macro | Close-up key detail |
| 4 | Flat lay with props | Top-down |
| 5 | Product in environment | Location |
| 6 | Lifestyle with model | Editorial |
| 7–8 | Video: rotation + lifestyle action | 5s each |

### Food/beverage

| # | Shot | Type |
|---|------|------|
| 1 | Hero spread | The money shot |
| 2 | Star dish beauty | Single dish close-up |
| 3 | Texture macro | Pour, bubble, grain |
| 4 | Ingredients flat lay | Raw ingredients |
| 5 | Environment context | Restaurant, market, terrace |
| 6 | Person + food | Chef, server, customer |
| 7–8 | Video: pour / plating | 5s each |

### Service/experience (private chef, events)

- Shots 1–4: food/product (same as food)
- Shots 5–8: the person (with character sheet ref)
- Videos: action + ambient environment

### Extended campaign (~20+ images, multi-page)

Split into themed chapters with 6 images each. Each chapter gets its own landing page, linked from a hero index.

---

## Phase 4: Prompt formula (7 Pillars)

```
[MOOD] atmosphere,
[SUBJECT: exact description with materials, colors, brand details],
[PLACEMENT] on/in [SURFACE/SETTING],
[CAMERA: body + lens + aperture],
[LIGHTING: color temp K + direction + modifier],
[TEXTURE DETAILS],
[STRATEGIC IMPERFECTIONS: film grain, dust, condensation, wear],
[ANTI-AI: NOT CGI, NOT retouched, natural imperfections]
```

For character-referenced shots, prefix:
> "This exact man/woman from the reference image [doing action]..."

### Camera assignments

| Shot | Camera | Lens | Aperture |
|------|--------|------|----------|
| Hero product | Hasselblad X2D / Phase One | 80mm | f/2.8–4 |
| Three-quarter | Hasselblad X2D | 65mm | f/3.5 |
| Macro | Any | 135mm macro | f/4 |
| Flat lay | Canon EOS R5 | 35mm | f/5.6 |
| Location wide | ARRI Alexa / Leica Q3 | 28–35mm | f/2–2.8 |
| Location portrait | RED Komodo | 85mm | f/2 |
| Moody/intimate | Leica SL2 | 50mm | f/1.4 |
| Action/sport | RED Komodo / Sony A7IV | 50–85mm | f/1.8–2 |

### Lighting variation (never the same twice across a shoot)

| Mood | Color temp | Direction |
|------|-----------|-----------|
| Golden hour | 3200–3800K | Backlight / sidelight |
| Candlelight | 2800–3200K | Multiple point sources |
| Overcast | 5800–6500K | Even, soft |
| Morning window | 4200–4800K | Directional from left/right |
| Fluorescent office | 5600K | Overhead harsh |
| Blue hour | 7000–7500K | Cool ambient + warm accent |
| Tungsten interior | 3000K | Warm overhead |

---

## Phase 5: Generation

**Model selection:**
- **Stills:** `nano-banana-pro` (119 CU, best photorealism) — default
- **Character shots:** `nano-banana-flash` (48 CU) — when using face reference
- **Videos:** `kling-2.5` (282 CU, 5s, realistic physics)
- **Fallback video:** `hailuo-2.3` if kling returns 402

**Run all images in parallel** (up to 6–8 simultaneous `uv run` commands).

**Run videos in background** (`run_in_background: true`) while building the landing page.

```bash
# Still (product)
uv run scripts/generate_image.py \
  --prompt "..." --filename "01-hero.png" \
  --model nano-banana-pro --width 1280 --height 1024

# Still with character reference
uv run scripts/generate_image.py \
  --prompt "This exact person from the reference image..." \
  --image-url "reference/character-sheet.png" \
  --filename "05-chef-plating.png" \
  --model nano-banana-flash --width 1024 --height 1280

# Video
uv run scripts/generate_video.py \
  --prompt "..." --filename "07-hero.mp4" \
  --model kling-2.5 --duration 5 --aspect-ratio 16:9
```

Resolve the Krea script path at invocation — it may live at `~/.claude/skills/krea-ai/scripts/` or `~/.claude/plugins/*/krea-ai/scripts/` depending on how the user installed the krea-ai plugin.

---

## Phase 6: Landing page

**One HTML file per shoot.** Each brand gets a UNIQUE layout derived from its visual DNA.

### Step 1: Design from the brand DNA

Phase 0 research and the Phase 1 brief give you everything you need. The landing page should feel like the brand's in-house team built it — not a template.

Let the brand drive EVERY decision:
- Their fonts → your font stack (their actual fonts, not "similar")
- Their colors → your CSS tokens (exact hex values)
- Their photography style → your layout rhythm (documentary → scroll story; luxury → editorial grid; tech → product-first)
- Their personality → copy tone, spacing density, animation restraint

**What makes each page unique is the BRAND, not an archetype template.**

Common layout approaches (inspiration, not templates):
- Scroll story — single-column narrative with full-bleed images
- Editorial magazine — asymmetric splits, varied heights, strong type hierarchy
- Product-first — product hero, specs immediately, story below
- Immersive full-bleed — every section fills the viewport, minimal text
- Split-screen — image/text dialogue

### Step 2: Build with `/frontend-design` + `/high-end-visual-design`

Pass the brand DNA as context, not rigid constraints. Let the design skills interpret.

**Brief template:**

```
/frontend-design Build a landing page for [Brand] — [product/concept].

BRAND DNA (extracted from [domain]):
- Fonts: [display font] for headings, [body font] for copy, [accent if any]
- Palette: [primary hex], [secondary hex], [accent hex]
- Photography: [style description]
- Website structure: [observed pattern — single-column / editorial / product-first / etc.]
- Personality: [3–5 adjectives]

CREATIVE DIRECTION: [chosen from Phase 1 — e.g. "Documentary Editorial — push their 
understated documentary style further toward magazine editorial"]

The page should feel like [Brand] designed it, but for a premium editorial feature — 
not their standard catalog page.

Images at: [paths]. Videos at: [paths].
Save to [output path]/index.html
```

Then run `/high-end-visual-design` over the output to enforce expensive-feel details: fluid spacing, exponential easing, proper kerning, metric-matched font fallbacks, no pure black/white, focus-visible states.

**Principle:** describe the brand, don't dictate the CSS. The design skills make intelligent decisions FROM brand context.

### Step 3: Refine with impeccable skills

After the base page is built, run in this order:

1. **`/typeset`** — Type scale consistent, hierarchy clear, line lengths 45–75ch, no text <12px, font-display + fallbacks.
2. **`/polish`** — Alignment, spacing, interaction states, lazy loading, aria labels, reduced motion, video poster frames.
3. **`/critique`** — AI-slop check, visual hierarchy, persona red flags, priority fixes. Score should be ≥30/40.

**Optional power-ups based on `/critique` findings:**
- `/bolder` — too safe or generic
- `/animate` — needs purposeful motion
- `/adapt` — mobile layout needs work
- `/colorize` — palette feels off
- `/distill` — too cluttered

### Step 4: Serve + verify

```bash
cd [project directory]
python3 -m http.server 8888
```

Open http://localhost:8888 and verify:
- All images load
- Videos autoplay (requires local server, not `file://`)
- Scroll reveals animate
- Mobile responsive (resize browser)
- No AI-slop tells

### Default landing page sections

1. Hero — full viewport image, brand title, tagline
2. Scrolling ticker — brand keywords marquee
3. Intro split — image + editorial copy
4. Product/food grid — asymmetric: 1 large spanning 2 rows + 2 smaller
5. Full-bleed editorial — location shot with overlay text
6. Chef / triptych / feature strip — 2–3 panel grid
7. Detail section — macro shot with specs or story
8. Second full-bleed — another location/experience
9. Video section — with editorial captions, gradient overlays, poster fallback
10. Experience pair — 2 side-by-side with captions
11. CTA — price/booking + button with focus-visible state
12. Footer — "Shot entirely with AI — [tools used]" + back-to-top

### Must-haves (enforced by `/high-end-visual-design` + `/polish`)

- Fluid spacing with `clamp()` — breathes on larger screens
- Exponential easing (`ease-out-expo`) — not generic `ease`
- Type scale in `rem` — respects user font size
- `prefers-reduced-motion` support
- `font-kerning: normal` + `text-rendering: optimizeLegibility` on headings
- `text-wrap: balance` on headings
- `loading="lazy"` on below-fold images, `fetchpriority="high"` on hero
- Video poster frames — no black flash
- `aria-label` on section landmarks
- Focus-visible states on interactive elements
- `::selection` color matching brand palette
- No pure black (#000) or pure white (#fff) — tint toward brand
- Metric-matched font fallbacks (no Inter, Roboto, system defaults)
- Responsive: adapted for mobile, not shrunk — touch targets 44px+

---

## Output structure

```
project-name/
├── index.html
├── style.css                    # multi-page only
├── chapter-*.html               # multi-page only
├── WORKFLOW.md                  # all prompts for reproduction
├── reference/                   # if character sheet
│   ├── original-photos/
│   ├── composite-reference.png
│   └── character-sheet.png
└── images/
    ├── studio/ or food/   (01–04+)
    ├── location/ or chef/ (05–08+)
    ├── experience/        (09–12, service shoots)
    └── video/             (09–10+)
```

Default save location: `./[brand-slug]/` in the current working directory. Users can override with `--out`.

---

## Cost reference

| Asset | Model | CU each | Notes |
|-------|-------|---------|-------|
| Product still | nano-banana-pro | 119 | Default for products |
| Character still | nano-banana-flash | 48 | With face reference |
| Character sheet | nano-banana-flash | 48 | 1280×1280, 2×2 grid |
| Video 5s | kling-2.5 | 282 | 16:9 or 9:16 |
| **Standard pitch** (6 stills + 2 videos) | | **~1,280 CU** | |
| **Extended campaign** (32 stills + 4 videos) | | **~5,000 CU** | |

(Krea.ai pricing is per CU — see their pricing page for current USD rates.)

---

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Same mood opener every prompt | Each MUST open differently: "Intimate...", "Cinematic...", "Moody atmospheric...", "Dawn..." |
| Missing camera specs | ALWAYS: camera body + lens mm + aperture + color temp K |
| No imperfections | Every prompt: "film grain, dust particles, NOT CGI, natural imperfections" |
| Same lighting everywhere | Vary: golden hour, overcast, tungsten, candlelight, blue hour |
| Flat compositions | "Shot through foreground X creating depth/bokeh" |
| Character face doesn't match | Composite reference (4 faces stitched) + `nano-banana-flash` |
| `flux-kontext` for character sheets | Goes cartoon — use `nano-banana-flash` |
| Videos don't play from `file://` | Serve via `python3 -m http.server 8888` |
| Landing page images broken | Relative paths, verify directory structure |
| "Character sheet" triggers illustration | Add "photorealistic, NOT cartoon, NOT illustration, NOT stylized" |

---

## Non-goals

- This skill does NOT host the landing page — it serves locally. Deploy separately (Vercel, Netlify, etc.).
- This skill does NOT bundle its own image-gen — it requires the Krea.ai plugin.
- This skill does NOT replace `/frontend-design` or `/critique` — it orchestrates them.
