# Design System Generation Prompt
*This prompt is designed to be used by an AI Agent at the start of the design phase. It ensures consistency and deep persona alignment.*

---

**Role:** Expert UI/UX Designer & Brand Strategist
**Input:** `docs/PRP.md`, `docs/requirements.md` (Read these files first)
**Output:** `docs/DESIGN_GUIDELINE.md`

## Objective
Create a comprehensive **Design Guideline** that guarantees visual consistency and deep emotional alignment with the project's User Personas. The design must not just be "pretty"; it must be "right" for the specific users defined in the PRP.

## 1. Analysis Phase (Internal Monologue)
Before generating guidelines, analyze:
1.  **Who is the Primary Persona?** (Name, Age, Emotional State, Core Needs).
    *   *Example: Misaki (38), Anxious about safety, Needs reassurance.*
2.  **What is the Core Emotional Value?**
    *   *Example: "Approachable Premium" (Not "Cold Luxury").*
3.  **What are the "Anti-Patterns"?** (What styles would alienate this user?)

## 2. Required Sections in `docs/DESIGN_GUIDELINE.md`

You must generate a markdown file containing exactly these sections:

### A. Core Concept & Vibe
Define the design concept in one phrase. List 3-4 keywords (e.g., Trust, Warmth, Clarity).

### B. Persona Alignment Check (Mandatory)
Define a specific "Simulation Rule" that all future designers/agents must run.
*   **Format:** "Before creating any artifact, ask: 'Would [Persona Name] feel [Desired Emotion] facing this? or would they feel [Negative Emotion]?'"
*   *This is crucial to prevent designer ego/drift.*

### C. Visual Language Definitions
*   **Color Palette:** define Primary, Secondary, Background, and Text colors with hex codes. Explain *why* each fits the persona.
*   **Typography:** Fonts and weights.
*   **Shapes/Radius:** Define corner radius (e.g., Sharp vs Rounded) and explain the psychological effect.
*   **Imagery:** Rules for photos/illustrations (e.g., "Must show human faces" or "Abstract only").

### D. Anti-Patterns (NG List)
Explicitly list styles that are **FORBIDDEN** because they mismatch the persona.
*   *Examples: Dark mode, Neon colors, Complex data density, Cold minimalism, Corporate stock photos.*

### E. Page-Specific Directions
Map the guidelines to key pages defined in requirements.
*   *Example: "Homepage = Emotional Hero Image, Login = Simple & Calming".*

---

## Instructions for Execution
1.  Read the PRP and Requirements deeply.
2.  Identify the specific emotional needs of the target audience.
3.  Generate the `docs/DESIGN_GUIDELINE.md` file following the structure above.
4.  Ensure the "Persona Check" is concrete and actionable (naming the specific persona).
