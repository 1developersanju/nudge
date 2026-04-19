# Design System Specification: The Obsidian Sanctuary

## 1. Overview & Creative North Star
The creative North Star for this design system is **"The Obsidian Sanctuary."** 

This is not a generic productivity tool; it is a private, high-end digital environment designed for deep reflection and intellectual growth. We are moving away from the "standard SaaS" look—characterized by thin borders and flat white backgrounds—to an editorial, local-first experience that feels like a premium physical vault.

The system breaks the "template" look through **Tonal Depth** and **Intentional Asymmetry**. We prioritize "Humane Tech" principles: quiet notifications, reduced visual noise, and a focus on the user’s internal headspace. Every interaction should feel frictionless and weighted with purpose.

---

## 2. Color & Atmospheric Theory
Our palette is rooted in a "Soft Dark" philosophy. We use dark tones not to be "edgy," but to reduce ocular strain and create a sense of privacy.

### The "No-Line" Rule
**Explicit Instruction:** You are prohibited from using 1px solid borders to section content. Boundaries must be defined through:
1.  **Background Color Shifts:** Placing a `surface_container_low` card on a `surface` background.
2.  **Generous Whitespace:** Using the 8pt grid to create "voids" that act as natural separators.
3.  **Tonal Transitions:** Subtle shifts in elevation via the `surface_container` tiers.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. We use Material-style container tokens to define "nesting" depth:
*   **Base Layer:** `surface` (#131315) – The foundation of the app.
*   **Section Layer:** `surface_container_low` (#1b1b1d) – For large background areas or grouped content.
*   **Interaction Layer:** `surface_container` (#201f21) or `surface_container_high` (#2a2a2c) – For individual cards and interactive elements.

### The "Glass & Gradient" Rule
To achieve a signature feel, floating elements (like the Capture Console) should use **Glassmorphism**:
*   **Background:** Use `surface_container_highest` at 70% opacity.
*   **Blur:** Apply a `backdrop-filter: blur(20px)`.
*   **Signature Polish:** Use a linear gradient for Primary CTAs transitioning from `primary` (#d2ceff) to `primary_container` (#b4b0fb) at a 135-degree angle. This provides a "soul" that flat hex codes cannot mimic.

---

## 3. Typography: Editorial Authority
We utilize **Manrope** for its clean, geometric, yet humane qualities. The hierarchy is designed to feel like a modern academic journal.

*   **Display & Headlines:** Use `display-md` or `headline-lg` for session starts and empty states. These should feel bold and confident, commanding the user's focus.
*   **Numbers:** Spaced repetition relies on data. Use `title-lg` for numeric streaks and counts. Ensure these are high-contrast using the `primary` color to celebrate progress quietly.
*   **Body Text:** `body-lg` is your workhorse. Use a comfortable line-height (1.6x) to ensure long-form notes are readable and calming.
*   **Labels:** Use `label-md` in `on_surface_variant` (#c8c5d1) for secondary metadata. Keep them small but legible.

---

## 4. Elevation & Depth
In "The Obsidian Sanctuary," depth is achieved through **Tonal Layering**, not structural lines.

### The Layering Principle
Stacking defines priority. An active study card should sit on `surface_container_high`, while the background behind it recedes into `surface_dim`.

### Ambient Shadows
Shadows must be "atmospheric." 
*   **Configuration:** Large blur (32px–64px), low opacity (4%–8%).
*   **Tinting:** Never use pure black shadows. Tint the shadow with a hint of our primary violet (#B4B0FB) to mimic the way light behaves in a dark, tinted room.

### The "Ghost Border" Fallback
If accessibility or extreme contrast is required, use a **Ghost Border**:
*   **Token:** `outline_variant` (#474650) at **15% opacity**.
*   **Rule:** It should be felt rather than seen.

---

## 5. Components & Interaction Patterns

### The Thumb-First Capture Console
The primary input method is a bottom-anchored console.
*   **Shape:** `xl` roundedness (3rem/48px) on top corners.
*   **Visual:** Glassmorphism with `surface_container_highest`.
*   **Interaction:** Soft haptics on trigger.

### Cards (The Core Unit)
*   **Corner Radius:** 24px (`md`) to 32px (`lg`). Avoid sharp corners; they feel aggressive.
*   **Structure:** No dividers. Use `title-md` for the question and `body-lg` for the answer, separated by 24px of vertical whitespace.

### Buttons
*   **Primary:** Gradient fill (`primary` to `primary_container`), `on_primary` text. Use for "Correct" or "Start Session."
*   **Secondary:** Ghost style with `surface_container_high` background. No border.
*   **Tertiary:** Text-only with `primary` color for low-priority actions.

### Quiet Progress Rings
*   **Visual:** Small, 24px diameter rings using `primary` for the stroke and `surface_container_highest` for the track.
*   **Philosophy:** Progress is a whisper, not a shout. Streaks should be represented by a single `title-sm` number next to a subtle violet dot.

### Input Fields
*   **State:** Default state uses `surface_container_lowest` to create a "hollow" feeling.
*   **Focus State:** Transition to `surface_container_high` with a subtle `primary` glow (4px spread, 10% opacity).

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use asymmetrical padding to create visual interest (e.g., more top padding than bottom in a hero header).
*   **Do** allow content to "breathe." If you think you have enough whitespace, add 8px more.
*   **Do** use `tertiary` (#ebd36b) sparingly for "Warning" or "Hard" states to provide a sophisticated contrast to the violet.

### Don’t:
*   **Don’t** use pure black (#000000). It kills the "Soft Dark" depth. Use `surface` (#131315).
*   **Don’t** use standard 1px dividers. If you need to separate content, use a 8px height `surface_container_lowest` block or simply more space.
*   **Don’t** use high-velocity animations. All transitions should be "Humane"—slightly longer durations (300ms-400ms) with smooth exponential easing.