# Elvan Niril (எல்வன் நிறிள்)

Welcome to the **Elvan Niril** project! This repository follows a strict, highly organized **Pure Tanglish (Navil Vili)** architectural pattern. 

Whether you are a human developer or an AI coding agent, you **MUST** adhere to the naming conventions and structural rules outlined below. This ensures the codebase remains natively understandable and perfectly structured.

## Architecture Map (English -> Tanglish)

This project has transitioned away from standard English Flutter conventions into a domain-specific Senthamizh (Pure Tamil) terminology, transliterated gracefully into English letters.

### 🏛️ The Three Pillars (`lib/src/`)
1. **`adippadai/` (Core)**: The fundamental building blocks (Database, Networking, Localization, Routing).
2. **`cheyalpaadugal/` (Features)**: Encapsulated business domains (Auth, Settings, Billing, Reports).
3. **`koorugal/` (Widgets/Components)**: Shared, reusable UI elements.

### 📂 Folder Name Mappings (Inside Features)
When creating new features, use these exact folder names:
- **Presentation / View Layer** ➔ `kaatchi/`
- **Pages / Screens** ➔ `thiraigal/`
- **Widgets / Components** ➔ `koorugal/`
- **Models / Entities** ➔ `tharavuru/`
- **State / Providers** ➔ `nilaimai/`
- **Repositories** ➔ `kalanjiyam/`
- **Data Source** ➔ `tharavu_moolam/`

### 📱 Platform & Context Mappings
- **Desktop** ➔ `kanini/`
- **Mobile** ➔ `kaipaesi/`
- **Reports** ➔ `arikkaigal/`
- **Onboarding** ➔ `varavaerpu_padigal/`

---

## File Naming Conventions

We do not use standard English suffixes (`_page.dart`, `_widget.dart`). Instead, use the appropriate Tanglish suffix to describe the file's purpose:

| English Suffix | Tanglish Suffix | Example |
| :--- | :--- | :--- |
| `*_page.dart` / `*_screen.dart` | `*_thirai.dart` | `mugappu_thirai.dart` (Home Page) |
| `*_widget.dart` / `*_component.dart` | `*_kooru.dart` | `elvan_pothan.dart` (Elvan Button) |
| `*_model.dart` / `*_entity.dart` | `*_tharavuru.dart` | `payanar_tharavuru.dart` (User Model) |
| `*_dialog.dart` / `*_modal.dart` | `*_meladukku.dart` | `urudhi_meladukku.dart` (Confirm Dialog) |
| `*_editor.dart` | `*_thiruthi.dart` | `pattiyal_thiruthi.dart` (Invoice Editor) |

### 🛠️ Working with Agents
This repository contains a specialized `.agents/AGENTS.md` ruleset. When invoking AI agents (like Cursor, Copilot, or Gemini), they will automatically read the `.agents/AGENTS.md` and follow these rules. 

**Rule of Thumb:**
If an AI agent accidentally generates a file with an English name (e.g. `settings_page.dart`), you must immediately instruct the AI to rename it according to the Tanglish rules (`amaippugal_thirai.dart`).

---
*Built with ❤️ using Flutter and Pure Tanglish Engineering.*
