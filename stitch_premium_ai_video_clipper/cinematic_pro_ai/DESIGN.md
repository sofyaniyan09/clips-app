---
name: Cinematic Pro AI
colors:
  surface: '#131316'
  surface-dim: '#131316'
  surface-bright: '#39393c'
  surface-container-lowest: '#0e0e11'
  surface-container-low: '#1b1b1e'
  surface-container: '#1f1f22'
  surface-container-high: '#2a2a2d'
  surface-container-highest: '#353438'
  on-surface: '#e4e1e6'
  on-surface-variant: '#cbc3d7'
  inverse-surface: '#e4e1e6'
  inverse-on-surface: '#303033'
  outline: '#958ea0'
  outline-variant: '#494454'
  surface-tint: '#d0bcff'
  primary: '#d0bcff'
  on-primary: '#3c0091'
  primary-container: '#a078ff'
  on-primary-container: '#340080'
  inverse-primary: '#6d3bd7'
  secondary: '#4cd7f6'
  on-secondary: '#003640'
  secondary-container: '#03b5d3'
  on-secondary-container: '#00424e'
  tertiary: '#2fd9f4'
  on-tertiary: '#00363e'
  tertiary-container: '#009fb4'
  on-tertiary-container: '#002f36'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#d0bcff'
  on-primary-fixed: '#23005c'
  on-primary-fixed-variant: '#5516be'
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#a2eeff'
  tertiary-fixed-dim: '#2fd9f4'
  on-tertiary-fixed: '#001f25'
  on-tertiary-fixed-variant: '#004e5a'
  background: '#131316'
  on-background: '#e4e1e6'
  surface-variant: '#353438'
typography:
  headline-lg:
    fontFamily: Montserrat
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Montserrat
    fontSize: 26px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Montserrat
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  headline-sm:
    fontFamily: Montserrat
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '500'
    lineHeight: '1'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  margin-mobile: 20px
  gutter-mobile: 16px
---

## Brand & Style
The design system is engineered to evoke the high-end atmosphere of a professional film production suite. It targets content creators and digital editors who require a sophisticated, high-performance environment for AI-driven video manipulation.

The aesthetic blends **Modern Corporate** precision with **Glassmorphism** and **High-Contrast** accents. By utilizing a deep obsidian foundation, the interface recedes to let video content take center stage, while vibrant gradient accents provide a sense of AI-powered energy and motion. The emotional response is one of "power-user efficiency"—a tool that feels expensive, fast, and intellectually sharp.

## Colors
The palette is rooted in deep space blacks and obsidian greys to minimize eye strain and maximize the vibrance of video previews. 

- **Background & Surface:** Use `#0F0F12` for the main canvas. UI containers and cards utilize `#1A1A22` to create subtle depth.
- **Primary Gradient:** A linear 135-degree gradient from Violet (`#8B5CF6`) to Cyan (`#06B6D4`) is reserved for high-intent actions and progress indicators.
- **Accents:** Cyan (`#22D3EE`) acts as a high-visibility marker for active states and selection highlights.
- **Feedback:** Use Success Green (`#10B981`) sparingly for completed AI tasks or export confirmations.

## Typography
The typography system uses a pairing of **Montserrat** for display roles and **Inter** for functional roles. 

- **Headlines:** Use Montserrat Bold. Headlines should feel cinematic and authoritative. Apply negative letter spacing to larger sizes to maintain a tight, modern "poster" feel.
- **Body:** Use Inter for all reading contexts. It provides the necessary neutrality and legibility against dark backgrounds.
- **Labels:** Use Inter Bold in uppercase for small metadata, button labels, and category tags to ensure they don't get lost in the dark UI.

## Layout & Spacing
This design system employs a **Fluid Grid** model optimized for mobile-first video editing. 

- **Rhythm:** An 8px base unit governs all dimensions.
- **Mobile Layout:** 4-column grid with 20px side margins and 16px gutters.
- **Safe Areas:** Ensure bottom navigation and action buttons account for the home indicator on modern mobile devices.
- **Content Reflow:** On larger viewports (tablets), the layout shifts to a 12-column grid, allowing video previews to expand while tools dock to the side.

## Elevation & Depth
Depth is conveyed through **Glassmorphism** and **Tonal Layering** rather than traditional drop shadows.

- **Surface Levels:** The base layer is `#0F0F12`. Secondary containers use `#1A1A22`. 
- **Glassmorphism:** For overlays, modals, and top navigation bars, use a background blur (20px) with a semi-transparent fill (`#1A1A22` at 70% opacity). 
- **Glow Borders:** High-priority cards or active AI processing states should feature a 1px inner border with a subtle gradient stroke and a faint outer glow (blur: 15px, opacity: 0.2) matching the primary gradient colors.
- **Shadows:** If used for floating action buttons, use a sharp, high-spread shadow with 0% offset to create a "lifted" look without traditional light-source bias.

## Shapes
The shape language is consistently **Rounded**, striking a balance between technical precision and approachable modern software.

- **Primary Elements:** Buttons and Input fields use a 0.5rem (8px) radius.
- **Large Containers:** Cards and video preview containers use `rounded-lg` (16px) to soften the edges of the obsidian-dark UI.
- **Interactive Indicators:** Page dots and small status pips are fully circular (pill-shaped).

## Components
Consistent component styling reinforces the "Production Studio" narrative.

- **Buttons:** 
  - *Primary:* Full-width with the Violet-to-Cyan gradient background and white text.
  - *Secondary:* Transparent with a 1px Cyan border (ghost style).
- **Glassmorphic Cards:** Used for video clips and AI suggestions. Features a subtle 1px border (`#FFFFFF` at 10% opacity) and background blur.
- **Input Fields:** Dark fills (`#0F0F12`) with a subtle 1px border that glows Cyan when focused.
- **Lists:** Items separated by thin, low-opacity lines (`#FFFFFF` at 5%). Leading icons should use the accent Cyan color.
- **AI Progress:** Use a glowing, animated gradient bar for "AI Clipping" or "Rendering" states.
- **Page Indicators:** Small dots where the active state is a Cyan-glowing pill shape and inactive states are dark grey circles.