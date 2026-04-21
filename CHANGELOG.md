# Changelog

All notable changes to `branding-pitch` will be documented in this file.

## [1.0.0] — 2026-04-20

Initial release.

### Added
- `/brand-pitch` slash command — end-to-end brand analysis → AI campaign → landing page
- **Full pipeline** (~15 min) — visual DNA extraction, creative brief, 6 stills + 2 videos, 10–12 section landing page, polish loop
- **Quick mode** (~5–6 min) — single WebFetch, 4 stills + 1 video, 8-section page, no polish loop. For live demos and time-boxed pitches.
- **7-Pillars prompt formula** for AI image generation (mood · subject · placement · camera · lighting · texture · imperfections + anti-AI)
- **Category-aware shot planning** — physical products, food/beverage, service/experience, tech/SaaS, extended multi-page campaigns
- **Character sheet workflow** for brands featuring people (founder, chef, model) — composite reference + `nano-banana-flash` face preservation
- **Brand-DNA-driven landing page** composition — each page derived from the brand's actual fonts, colors, photography style, personality
- Integration with `/frontend-design`, `/high-end-visual-design`, `/typeset`, `/polish`, `/critique` from the impeccable plugin
- Integration with Krea.ai image + video generation (nano-banana-pro, nano-banana-flash, kling-2.5)

### Requires
- Krea.ai plugin or compatible image-gen setup (`KREA_API_TOKEN` + `uv`)
- impeccable plugin (`/frontend-design`, `/high-end-visual-design`, `/typeset`, `/polish`, `/critique`)
