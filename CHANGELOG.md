# Changelog

All notable changes to `branding-pitch` will be documented in this file.

## [1.1.0] — 2026-04-21

Claude Design compatibility + modern skill schema.

### Added
- **`when_to_use` frontmatter field** following the latest Agent Skills schema — improves automatic triggering, especially when users say things like "turn this handoff into a landing page" or "generate brand assets" without explicitly saying "brand pitch".
- **Claude Design (claude.ai/design) interop section in README.** `brand-pitch` is documented as a pipeline-style alternative to Claude Design's visual editor, and as a complement when a Claude Design handoff bundle needs production photography + a full landing page. No native plugin API on claude.ai/design yet — this skill runs in Claude Code which is the surface where Claude Design handoffs land.

## [1.0.2] — 2026-04-20

Major production-knowledge release. No breaking changes.

### Added
- **Phase 4B: Reference strategy.** Comprehensive decision tree for when to use `--image-url` and when to skip it, per shot type. Covers product locks, character sheets, logo refs, and why brand-style references contaminate output.
- **The "still-first → animate" pattern for videos.** Critical workflow for consistent product/character videos: generate the locked still first (with `--image-url` product reference), then feed THAT still as the starting frame to the video model. Zero product drift across still + video pairs.
- **Complete model decision tree** covering all Krea models: `nano-banana-pro` / `nano-banana-flash` / `flux-kontext` for stills; `kling-2.5` / `seedance` / `hailuo-2.3` for video, with explicit guidance on when each video engine is appropriate (Seedance for fluid motion, Kling for physics, Hailuo as fallback).
- **Video engine routing.** When to pick Kling vs Seedance — Kling for realistic physics and push-ins, Seedance for fluid dynamics (liquid, fabric, dance, rotation), Hailuo only as rate-limit fallback.

### Why this matters
Earlier versions told users which models to use at a high level but didn't codify WHEN to use image references or the still-first video pattern — which are the two biggest levers for campaign consistency. Without the still-first pattern, product videos generate similar-but-wrong products every time.

## [1.0.1] — 2026-04-20

Correction + portability release. No breaking changes.

### Fixed
- **Dependencies corrected.** `/frontend-design` is from Anthropic's official `claude-plugins-official` marketplace, not impeccable. Previous docs conflated them. Now lists three required plugins correctly: Krea.ai + frontend-design (Anthropic) + impeccable (pbakaus).
- **Removed personal-agent references.** Stripped mentions of `visual-dna-analyst` and `mcp__claude-in-chrome__*` which are not universally available. The plugin is now fully self-contained, relying only on tools available to every Claude Code install (`WebFetch`, `WebSearch`, `Explore`, `Bash`) plus the three listed dependency plugins.
- **Inlined visual DNA analysis.** Phase 0 now walks through the visual-deconstruction steps directly (photographic signature · implied technical choices · the *why* · style principles) instead of delegating to an external agent. Works identically for every user.

### Changed
- **Quality loop is critique-first.** `/frontend-design` → `/critique` → only targeted fixes based on what `/critique` flags. Default ships in ~2 minutes of post-generation work instead of the full 5+ minute `/typeset` → `/polish` → `/critique` loop. Full loop remains opt-in via `--full-polish` flag.
- **Optional browsing enhancements documented.** Claude for Chrome, surf-cli, and Playwright MCP are now listed as optional upgrades for live JS-rendered sites. Plain `WebFetch` handles ~80% of brands.

## [1.0.0] — 2026-04-20

Initial release.

### Added
- `/brand-pitch` slash command — end-to-end brand analysis → AI campaign → landing page
- **Full pipeline** (~10–15 min) — visual DNA extraction, creative brief, 6 stills + 2 videos, 10–12 section landing page, quality loop
- **Quick mode** (~5–6 min) — single WebFetch, 4 stills + 1 video, 8-section page, no polish loop. For live demos and time-boxed pitches.
- **Category-aware shot planning** — physical products, food/beverage, service/experience, tech/SaaS, extended multi-page campaigns
- **Character sheet workflow** for brands featuring people (founder, chef, model) — composite reference + `nano-banana-flash` face preservation
- **Brand-DNA-driven landing page** composition — each page derived from the brand's actual fonts, colors, photography style, personality
- Integration with `/frontend-design`, `/critique`, `/typeset`, `/polish` and optional `/animate`, `/bolder`, `/adapt`, `/colorize`, `/distill`, `/quieter`
- Integration with Krea.ai image + video generation (`nano-banana-pro`, `nano-banana-flash`, `kling-2.5`)

### Requires
- Krea.ai plugin (`KREA_API_TOKEN` + `uv`)
- frontend-design from Anthropic's `claude-plugins-official` marketplace
- impeccable plugin
