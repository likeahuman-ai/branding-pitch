---
name: pitch
description: >
  Pitch a brand end-to-end — analyze the brand's visual DNA, generate an AI
  photography + video campaign (~6 images + 2 videos), build a polished editorial
  landing page served locally. For agencies, freelancers, or founders presenting
  a brand or product concept. Use when the user says "pitch", "pitch this brand",
  "brand pitch", "build a brand page", "analyze and pitch", "make a landing page
  for [brand]", "creative director for", "turn this brand into a page", or
  "generate brand assets + landing page". Requires uv (Python runner) and a
  KREA_API_TOKEN environment variable.
argument-hint: "[brand name or URL]"
user-invocable: true
---

# Pitch — Analyze, Generate, Present

Take a brand (name, URL, Instagram, or rough concept) and produce a complete pitch package in one flow:

1. **Extract the brand's visual DNA** (fonts, colors, photography style, personality)
2. **Generate an AI photography campaign** (~6 stills + 2 videos, the AI decides the exact split based on category)
3. **Build a polished editorial landing page** that feels like the brand designed it themselves
4. **Serve it locally** for you to show the client

---

## Prerequisites

Before starting, the skill runs `scripts/preflight.sh` to verify:
- **uv** — Python script runner (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- **KREA_API_TOKEN** — get one from https://krea.ai/settings/api

No other plugins are required. All design guidance and generation scripts are bundled.

---

## Quick mode (for time-boxed pitches)

**Target wall-clock:** ~5–6 minutes from "go" to served landing page.

**Trigger when user says:** "quick", "fast", "demo mode", "--fast", "--lite", or when the context is clearly time-boxed (live audience, client call, tight deadline).

**What's different from the full pipeline:**

| Step | Full pipeline | Quick mode |
|------|---------------|------------|
| Brand research | `WebFetch` homepage + `Explore` agent for case studies in parallel | **Single `WebFetch`** on the homepage, grep CSS inline |
| Direction question | 4 options (A/B/C/D) | **1 recommended direction** derived from the CSS, one-line confirm |
| Shot count | 6 stills + 2 videos | **4 stills + 1 video** (hero, detail, lifestyle, macro + 1 rotation video) |
| Landing page sections | 10–12 | **8** — hero · intro · logic I · logic II · magic · video · spec · CTA |
| Polish loop | Quality check against design guidelines | **Skip.** First build output is the deliverable |
| WORKFLOW.md | Full reproducibility | **Skip** |

**Quick mode flow:**

1. User: "pitch Brand X" (may attach image or paste URL)
2. `WebFetch` the brand homepage once. Grep fonts + colors from the HTML/CSS. Present a 3-line DNA summary:
   > **[Brand]** — [display font] / [body font], palette `#XXXXXX` `#YYYYYY` `#ZZZZZZ`. Direction: **[one line concept]**. Go, or tweak?
3. User: "go" (or specifies a tweak)
4. Write 4 still prompts + 1 video prompt using the prompt formula (below)
5. Dispatch all 5 generations in parallel:
   ```bash
   mkdir -p logs images video
   uv run ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/generate_image.py \
     --prompt "$(cat prompts/01-hero.txt)" \
     --filename "images/01-hero.png" \
     --model nano-banana-pro --width 1280 --height 1024 \
     > logs/01.log 2>&1 &
   # ... 3 more stills + 1 video in background ...
   wait
   ```
6. **While gens run**, draft the 8-section `index.html` using the bundled design guidelines with brand tokens hardcoded from the WebFetch result
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
Brand Research (WebFetch + inline visual DNA) → Design Language → Shot Plan →
Parallel Image Gen → Videos in Background →
Build page (design guidelines) → Quality check → Serve
```

(Full quality check loop is opt-in via `--full-polish` — saves ~3–5 minutes by default.)

### Default target output

- **~6 images + 2 videos** (AI decides exact split based on category — physical product may need 8 stills, service shoot may need 4 + 2 videos, etc.)
- **One landing page** with 10–12 sections, built live in ~2–3 minutes after assets land
- **Served at** `http://localhost:8888` (or next free port)

---

## Phase 0: Brand research + visual DNA

**Step 0: Preflight check**

Run the preflight script to verify environment requirements:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/preflight.sh
```
If it fails, stop and show the user the error message. Do not proceed without uv and KREA_API_TOKEN.

Before any creative work, understand the brand deeply. This phase has two halves: **technical extraction** (what's on the page) and **visual DNA analysis** (what the design choices *mean*). Both run on standard Claude Code tools — no custom agents required.

### Step 1: Fetch the brand homepage (technical extraction)

`WebFetch` the brand's website and pull:
- **Typography** — `<link rel="stylesheet" href="fonts.googleapis.com/...">`, `@font-face` rules, `font-family` declarations. Identify display vs body vs accent roles.
- **Palette** — hex codes in CSS, `color:` / `background:` / `fill:` values. Separate into primary / secondary / accent.
- **Layout pattern** — how is the homepage structured? Single-column narrative? Editorial asymmetric grid? Product-first? Full-bleed immersion? Split-screen?
- **Hero copy + positioning** — what story are they telling in their own words? What tone?

### Step 2: Visual DNA analysis (done inline — no external agent needed)

Deconstruct the brand's visual signature. For each dimension, name what you observe AND the *why* behind it:

**A. Photographic signature.** From the brand's hero image(s) + any in-page imagery:
- **Lighting choice** — hard studio / soft diffused / golden hour / overcast / mixed sources. What color temperature is implied?
- **Color grading** — desaturated cinematic / warm natural / cool editorial / high-contrast mono / saturated commercial
- **Composition** — subject-centered / rule-of-thirds / negative-space heavy / maximalist / architectural
- **Subject scale** — human as hero / human small in landscape / product-only / texture-only
- **Texture treatment** — pristine CGI-polished / film grain natural / matte editorial / sharp commercial

**B. Implied technical choices.** What camera/lens/aperture would a real photographer use to shoot this brand? Translate the feel into gear:
- Documentary desaturated → Leica Q3, 28mm, f/2.8
- Luxury pristine product → Hasselblad X2D, 80mm, f/4
- Golden-hour editorial → ARRI Alexa / Sony A7IV, 50–85mm, f/1.8
- Moody intimate interior → Leica SL2, 50mm, f/1.4

**C. The *why* behind the feeling.** Name the emotional signal the brand is trying to send. Examples:
- Patagonia's understated documentary = "we're too serious to perform"
- Aesop's stark product isolation = "our product is the statement"
- Kinfolk's soft golden-hour interiors = "life is slower than you think"
- Off-White's high-contrast industrial = "design as a system, not decoration"

**D. Style principles (3–5 bullets).** Compress A/B/C into reusable rules you'll feed to the prompt formula:
- e.g. "Always golden hour, never noon. Always one human, small in frame. Always film grain, never pristine. Always warm cream tones, never pure white."

These principles become the *persistent style preamble* for every image prompt in Phase 4.

### Step 3: Optional wider research (parallel via Explore)

If the homepage didn't give you enough, spawn an `Explore` subagent for external context:

```
Agent({
  subagent_type: "Explore",
  description: "Research [brand] visual identity",
  prompt: "Research the visual identity of [brand]. Find: design case studies, Behance/Dribbble portfolios, interviews with their design team, logo SVG sources. Summarise typography, colors, photography style, and brand personality in 3-5 bullet points each.",
  run_in_background: true
})
```

`Explore` is built into Claude Code — no plugin needed.

### Step 4: Optional Instagram grid check

If the brand has a public Instagram URL, `WebFetch` the profile page to see the grid aesthetic. Many profiles block public fetch — if it 403s, skip and rely on Steps 1–3. Don't block the flow.

### Optional: enhanced browsing (if the user has the tools)

`WebFetch` works for 80% of brands, but occasionally you need live JS-rendered content (React / Vue / Next.js apps that only reveal fonts + colors after hydration). If the user has any of these installed, use them instead of `WebFetch`:

| Tool | What it adds | Install |
|------|-------------|---------|
| **[Claude for Chrome](https://claude.ai/chrome)** | Live browser automation — clicks, scrolls, inspects rendered DOM, takes screenshots | Browser extension from Anthropic |
| **[surf-cli](https://github.com/davidteather/surf)** | Headless browsing with JS execution from the CLI | `npm install -g surf-cli` |
| **Playwright MCP** | Programmatic browser via MCP | `npm install -g @modelcontextprotocol/server-playwright` |

If none of these are installed, fall back to `WebFetch` + `curl` on the CSS bundle directly. That's usually enough — most brand websites serve static HTML + fonts + colors on initial load.

### Step 5: Synthesize + present

Consolidate everything into a summary table:

| Element | Value |
|---------|-------|
| Display font | [extracted] |
| Body font | [extracted] |
| Accent font | [if any] |
| Primary colors | [hex values] |
| Photography signature | [from Step 2A] |
| Implied gear | [from Step 2B] |
| Brand *why* | [from Step 2C] |
| Style principles | [3–5 bullets from Step 2D] |
| Brand personality | [3–5 adjectives] |

### Step 6: Creative direction

Based on this DNA, generate **4 creative direction options** specific to THIS brand (NOT a fixed category lookup):

- **A)** Most faithful to existing brand identity
- **B)** Fresh interpretation that amplifies what's there
- **C)** Contrasting direction that challenges expectations
- **D)** Hybrid mixing brand DNA with a different aesthetic

User picks one. Lock the creative brief.

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

## Phase 4: The prompt formula

Every image prompt follows the same eight-part skeleton. No two shots in a shoot should share the same mood opener, camera body, lens, lighting temperature, and imperfection set.

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

## Phase 4B: Reference strategy (our opinionated guidance)

> The official `krea-ai/skills` repo documents the `--image-url` (stills) and `--start-image` (videos) parameters but doesn't prescribe WHEN to use them per shot type. The guidance below is our production-tested strategy from running real client pitches — use it as a starting point, not gospel.

**The parameter split — don't mix these up:**

| Param | Script | Use |
|-------|--------|-----|
| `--image-url` | `generate_image.py` | Image-to-image — pass a reference photo to lock product / character / logo |
| `--start-image` | `generate_video.py` | Image-to-video — the starting frame of the video animation |
| `--end-image` | `generate_video.py` | Optional — ending frame for interpolation-style motion |

Reference images lock specific visual elements across generations. Use them when you need **consistency** (same product across 8 shots, same face across a campaign); skip them when you need **variety** (location B-roll, texture macros, abstract moods).

### Should this shot use `--image-url`?

| Scenario | Use ref? | Reference type |
|----------|---------|----------------|
| Hero product shot — must show THE actual product | **Yes** | Clean product photo (brand-provided or prior gen) |
| Product in environment (multiple angles/locations) | **Yes — for the product, not the location** | Product photo only |
| Detail macro, texture | No | Let the prompt describe materials / weave / grain |
| Flat lay composition | No | Composition needs freedom to arrange props |
| Character/person across ≥2 shots | **Yes — mandatory** | Character sheet (from Phase 2) |
| Logo placement shot | **Yes**, but expect imperfection | Logo SVG → PNG 1024×1024 |
| Location / environment only | No | — |
| Brand mood / style lock | **No** — describe mood in prompt instead | Ref drags composition + lighting too hard |

### Preparing references

**Product reference.** User provides a clean product photo (ideally studio with neutral background). Save to `reference/product-clean.png`. Feed as `--image-url "reference/product-clean.png"` to every shot that must lock THIS product. Prompt prefix: `"This exact product from the reference image, shown in [context]..."`

**Logo reference.** Download SVG from brand site → convert to PNG at 1024×1024 with solid background (`npx sharp-cli` or Figma export). Feed as `--image-url` where the logo must appear. **Warning:** generative models rarely render text/logos perfectly. Treat logo-in-shot as supplementary, not hero.

**Character sheet.** See Phase 2 — composite + `nano-banana-flash`.

**Brand-style reference — DON'T.** Feeding a styled brand image as `--image-url` contaminates the generated image's composition, lighting, and color grade along with the subject. Describe the style in the prompt instead. Image-ref is for specific SUBJECTS (product, face, logo), not mood.

### Video-specific: the "still-first → animate" pattern

Video models (Kling, Seedance, Hailuo) support two modes:

**Text-to-video (no reference).** Good for: ambient scenes, location B-roll, abstract motion, textures, environmental video. Prompt-only.

**Image-to-video (via `--start-image`).** Good for: animating a specific product, keeping character consistency across video+still, preserving a hero frame's exact color grade. This is the critical pattern for consistent campaigns. Note: the video param is `--start-image`, NOT `--image-url` (that's the stills param — don't mix them up).

**The workflow when you need a consistent product or character in a video:**

1. **Generate the starting still first** — with `nano-banana-pro` (or `nano-banana-flash` for character) + `--image-url "reference/product.png"` as product reference. This locks the generated still to the brand's actual product.
2. **Feed THAT generated still as the starting frame to the video model** — so the video animates from the exact frame you already approved. Zero product drift.
3. **Result** — the product in the video is identical to the hero still. Same lighting, same angle, same branding.

Example command sequence:

```bash
# Step 1: locked still with product reference
uv run ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/generate_image.py \
  --prompt "Hero product shot..." \
  --image-url "reference/product-clean.png" \
  --filename "images/01-hero-still.png" \
  --model nano-banana-pro --width 1280 --height 1024

# Step 2: animate from that still (note: --start-image, NOT --image-url)
uv run ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/generate_video.py \
  --prompt "Gentle camera push-in, product stays in frame, subtle material shimmer..." \
  --start-image "images/01-hero-still.png" \
  --filename "video/01-hero.mp4" \
  --model kling-2.5 --duration 5 --aspect-ratio 16:9

# Optional: add --end-image for interpolation-style motion
# --end-image "images/01-hero-final.png"
```

**Never skip the still-first step for product videos.** Text-to-video alone will generate a similar-but-wrong product every time.

### Model selection — complete decision tree

| Need | Model | CU | Notes |
|------|-------|-----|-------|
| **Stills** | | | |
| Hero product (pristine photorealism) | `nano-banana-pro` | 119 | Default for product / food / still life |
| Character still (face lock from ref) | `nano-banana-flash` | 48 | Mandatory when using character sheet |
| Character sheet composite (2×2 face grid) | `nano-banana-flash` | 48 | Phase 2 only |
| Detail macro, texture, flat lay | `nano-banana-pro` | 119 | Prompt-driven, no ref |
| Logo composition | `nano-banana-pro` + logo ref | 119 | Expect imperfect text rendering |
| Style transfer / heavy manipulation | `flux-kontext` | varies | Avoid for character sheets (goes cartoon) |
| **Videos** | | | |
| Ambient / location B-roll (text-to-video) | `kling` (or `veo-3.1-fast`) | ~282 | No reference — prompt-only, 5s |
| Product animation (still-first pattern) | `kling` image-to-video | ~282 | Starting frame = approved still |
| Character action (still-first pattern) | `kling` image-to-video | ~282 | Starting frame = character sheet or prior shot |
| Alternative engine (fluid motion) | `wan` or `seedance` | varies | When Kling feels wrong — these handle fluid motion (liquid, fabric, dance, rotation) more smoothly |
| High-fidelity cinematic | `veo-3.1-fast` / `veo-3` | varies | Google's video model when you want the most polished look |
| Fallback (if primary returns 402) | `hailuo-2.3` | ~180 | Rate-limit / outage only |

**Re-run `list_models.py` if any of the above returns a "model not found" error.** Version tags may have shifted since this doc was written.

### Which video engine for what

(Engine names below reflect what's in the catalog at write time — run `list_models.py` first to confirm current names.)

- **Kling** — realistic physics, strong camera moves, good for product push-ins and human action. Default pick.
- **Seedance / Wan** — smoother continuous motion, better for fluid dynamics (liquid pouring, fabric flow, dance, rotation). Alternatives when Kling's output feels stiff.
- **Veo 3 / Veo 3.1 fast** — Google's cinematic engine. When you want the most polished, film-like look (budget permitting).
- **Hailuo 2.3** — fallback only when the primary engine is rate-limited.

If in doubt: generate a 5s Kling first. If the result feels stiff or the motion breaks the product/character, re-run on Wan/Seedance with the same starting frame.

---

## Phase 5: Generation

### The full Krea.ai toolkit

The bundled scripts (at `${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/`) include **7 tools**. This skill primarily uses 2 (stills + video), but you should know the whole surface:

| Script | Purpose | When `/pitch` uses it |
|--------|---------|------------------------|
| `list_models.py` | Fetch the **live** catalog of available models (names, CU costs, per-model accepted params) from the Krea OpenAPI spec | **ALWAYS run first** — before writing prompts, confirm which models exist right now |
| `generate_image.py` | Text-to-image + image-to-image stills | Every still in Phase 5 |
| `generate_video.py` | Text-to-video + image-to-video (starting/ending frame) | Every video in Phase 5 |
| `enhance_image.py` | Upscale to 22K via Topaz (standard/generative/bloom) with creativity, face-enhance, sharpening, denoising controls | **Phase 6 optional** — upscale the hero still to 4K before publishing the landing page |
| `train_style.py` | Train a custom LoRA on 3–2000 brand reference images with configurable trigger words | **Extended campaigns** — if the brand has 20+ past campaign images, train a brand-specific LoRA and pass `--style-id` to every generation for maximum consistency |
| `pipeline.py` | Orchestrate multi-step workflows (generate → enhance → animate) in a single command with branching, template variables, parallel execution, resume capability | **Advanced** — chain full sequences in one spec instead of N separate shell invocations |
| `get_job.py` | Poll async job status by UUID | Rarely called directly — other scripts use it internally |

**Krea's official agent docs:** [docs.krea.ai/CLAUDE](https://docs.krea.ai/CLAUDE) · [github.com/krea-ai/skills](https://github.com/krea-ai/skills)

### CRITICAL — runtime model discovery

Krea's model catalog drifts. Version numbers change. New engines land. **The skill MUST run `list_models.py` before hardcoding model names in prompts.** This is explicit guidance from Krea's own agent docs: *"Do NOT invent model names. Run `list_models.py` to get the **live** list."*

Before Phase 5 begins, run:

```bash
uv run ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/list_models.py --json > /tmp/krea-models.json
```

Parse the JSON to confirm:
- Which image models are currently available (`nano-banana-pro`, `flux`, `imagen-4-ultra`, `gpt-image`, etc.)
- Which video models are currently available (`kling`, `veo-3.1-fast`, `veo-3`, `hailuo-2.3`, `wan`, etc.)
- Current CU cost per model
- Per-model accepted parameter names — some models accept `--quality`, some `--mode`, some neither

If the model names below don't appear in the live list, pick the closest equivalent from `list_models.py` output.

### Model selection (examples — not exhaustive, confirm via `list_models.py`)
- **Stills:** `nano-banana-pro` (119 CU, best photorealism) — default
- **Character shots:** `nano-banana-flash` (48 CU) — when using face reference
- **Videos:** `kling-2.5` (282 CU, 5s, realistic physics)
- **Fallback video:** `hailuo-2.3` if kling returns 402

**Run all images in parallel** (up to 6–8 simultaneous `uv run` commands).

**Run videos in background** (`run_in_background: true`) while building the landing page.

```bash
# Still (product)
uv run ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/generate_image.py \
  --prompt "..." --filename "01-hero.png" \
  --model nano-banana-pro --width 1280 --height 1024

# Still with character reference
uv run ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/generate_image.py \
  --prompt "This exact person from the reference image..." \
  --image-url "reference/character-sheet.png" \
  --filename "05-chef-plating.png" \
  --model nano-banana-flash --width 1024 --height 1280

# Video — text-to-video (ambient / no reference)
uv run ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/generate_video.py \
  --prompt "..." --filename "07-hero.mp4" \
  --model kling-2.5 --duration 5 --aspect-ratio 16:9

# Video — image-to-video (still-first → animate)
uv run ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/generate_video.py \
  --prompt "Gentle camera push-in, product stays in frame..." \
  --start-image "images/01-hero-still.png" \
  --filename "video/01-hero.mp4" \
  --model kling-2.5 --duration 5 --aspect-ratio 16:9
```

**Parameter reference:**
- **Stills** (`generate_image.py`): `--prompt`, `--filename`, `--model`, `--width`, `--height`, `--aspect-ratio`, `--image-url` (for image-to-image with a reference), `--style-id`, `--style-strength`, `--seed`, `--steps`, `--guidance-scale`, `--quality`, `--batch-size`, `--output-dir`.
- **Videos** (`generate_video.py`): `--prompt`, `--filename`, `--model`, `--duration`, `--aspect-ratio`, `--start-image` (for image-to-video starting frame — NOT `--image-url`), `--end-image` (optional — ending frame for interpolation-style videos), `--resolution`, `--mode`, `--generate-audio`, `--output-dir`.

---

### Optional: upscale before publish (`enhance_image.py`)

For the hero still that goes at the top of the landing page, consider upscaling before embedding:

```bash
uv run ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/enhance_image.py \
  --input "images/01-hero.png" \
  --output "images/01-hero@4k.png" \
  --model topaz-standard-enhance \
  --creativity 0.15 \
  --face-enhance true
```

Topaz enhancers: `topaz-standard-enhance` (safe default), `topaz-generative-enhance` (fills in detail), `topaz-bloom-enhance` (softer, editorial). For hero stills at 1280×1024 bumped to 4K, `topaz-standard-enhance` at `--creativity 0.15` is the safe pick — more creativity invents detail, less is literal.

### Optional: train a brand LoRA (`train_style.py`)

For extended campaigns or returning clients, train a brand-specific LoRA once and use its `--style-id` across every generation for maximum consistency:

```bash
uv run ${CLAUDE_PLUGIN_ROOT}/skills/pitch/scripts/train_style.py \
  --images "reference/brand-archive/*.jpg" \
  --trigger-word "brandname_v1" \
  --steps 1500 \
  --type Style
```

Returns a style ID. Pass it as `--style-id <id>` to every `generate_image.py` call for that brand. One-time cost, unlimited brand-locked generations afterwards.

### Optional: one-shot pipeline (`pipeline.py`)

For the full campaign in a single command, use `pipeline.py` with a YAML/JSON spec that chains generate → enhance → animate → output. See [krea-ai/skills PIPELINES.md](https://github.com/krea-ai/skills/blob/main/PIPELINES.md) for the format. `/pitch` generates commands inline by default — use `pipeline.py` only when you want to hand off a reproducible spec to the user.

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

### Step 2: Build the landing page

Read `${CLAUDE_PLUGIN_ROOT}/skills/pitch/references/design-guidelines.md` for the design principles, then build the landing page directly as a single `index.html` file. Follow the design guidelines strictly — especially the absolute bans (no side-stripe borders, no gradient text) and the AI slop test.

For deeper guidance on specific aspects, read the relevant reference files:
- Typography: `references/design-typography.md`
- Colour: `references/design-colour.md`
- Layout: `references/design-spatial.md`
- Motion: `references/design-motion.md`
- Interaction: `references/design-interaction.md`
- Responsive: `references/design-responsive.md`
- Copy: `references/design-ux-writing.md`

Pass the brand DNA as context, not rigid constraints. Let the brand drive the design.

**Brief structure:**

```
Build a landing page for [Brand] — [product/concept].

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

**Principle:** describe the brand, don't dictate the CSS. Make intelligent design decisions FROM brand context.

### Quality check

After building the page, self-assess against `references/design-guidelines.md`:

1. Run the **AI Slop Test**: If someone saw this and said "AI made this," would they believe it immediately? If yes, fix it.
2. Check the **absolute bans**: no side-stripe borders (border-left > 1px), no gradient text (background-clip: text with gradient).
3. Verify **font selection**: no fonts from the reflex reject list (Inter, Roboto, DM Sans, Space Grotesk, etc.).
4. Check **colour**: no pure black/white, no purple-to-blue gradients, neutrals tinted toward brand hue.
5. Check **layout**: not everything centred, varied spacing, no identical card grids.

Fix any violations before serving.

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

### Must-haves (enforced by quality check)

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
- This skill does NOT require any custom MCP server or personal agent. Everything runs on tools available to every Claude Code install plus the bundled scripts and design references.
