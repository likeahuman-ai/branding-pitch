# Changelog

All notable changes to `branding-pitch` will be documented in this file.

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
