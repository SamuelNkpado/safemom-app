# SafeMom Design System

Maintain visual consistency across all screens. Every team member must use these exact values. Do not introduce new colours, fonts, or sizes without team agreement.

The tokens below are implemented in code under `lib/core/` — reference the Dart constants, don't hardcode values in widget files.

## Colours

### Primary palette (60-30-10 rule)

| Role | Hex | Where to use |
| --- | --- | --- |
| Cream (60%) | `#FAF7F2` | App background, default surface |
| Teal (30%) | `#2E7D7D` | Primary buttons, active states, headers, brand elements |
| Coral (10%) | `#E76F51` | Non-emergency CTAs, accents, the "Get Started" button |

### Semantic colours

| Role | Hex | Where to use |
| --- | --- | --- |
| Emergency Red | `#C0392B` | Emergency button, danger banners, SOS button. Never use this colour for anything else. |
| Success Green | `#27AE60` | Confirmation messages, "Help arrived" status |
| Warning Amber | `#F39C12` | Warning banners, pregnancy-week tags |
| Info Blue | `#185FA5` | Informational badges, links |

### Text colours

| Role | Hex | Where to use |
| --- | --- | --- |
| Primary text | `#1A1A1A` | All headings, primary body copy |
| Secondary text | `#5F5E5A` | Subtitles, captions, helper text |
| Tertiary text | `#888780` | Placeholder text, disabled labels |
| On-colour white | `#FFFFFF` | Text on teal, coral, or red backgrounds |

### Surface colours

| Role | Hex | Where to use |
| --- | --- | --- |
| Card surface | `#FFFFFF` | White cards on cream background |
| Soft teal | `#E1F0F0` | Selected states, avatar backgrounds, hero circles |
| Soft coral | `#FCE5DD` | Selected danger states, warning surfaces |
| Border default | `#E1E0DA` | Card borders, input borders, divider lines |

Implemented in `lib/core/constants/app_colors.dart` (`AppColors`).

## Typography

Font family: **Inter** (via `google_fonts`), broad language support including Swahili.

| Style | Size | Weight | Where to use |
| --- | --- | --- | --- |
| Heading 1 | 28 | Bold (700) | Main screen titles, "Karibu, Mama" |
| Heading 2 | 20 | Semibold (600) | Section headings, "Today's check-in" |
| Heading 3 | 16 | Semibold (600) | Card titles |
| Body | 16 | Regular (400) | All body copy |
| Body Small | 14 | Regular (400) | Helper text, metadata |
| Button | 14 | Semibold (600) | All button labels |
| Caption | 12 | Regular (400) | Timestamps, fine print |

Line height: headings 1.2x, body 1.5x. Implemented in `lib/core/theme/app_text_styles.dart` (`AppTextStyles`).

## Spacing

8-point scale. Use for all padding, margins and gaps. Implemented in `lib/core/constants/app_spacing.dart` (`AppSpacing`).

| Token | Value | Use |
| --- | --- | --- |
| `xs` | 4 | Icon-to-text gap |
| `sm` | 8 | Inside tight elements |
| `md` | 16 | Default gap between elements |
| `lg` | 24 | Section padding |
| `xl` | 32 | Between major sections |
| `xxl` | 48 | Top/bottom of pages |

## Corner radius

Implemented in `lib/core/constants/app_radius.dart` (`AppRadius`).

| Token | Value | Use |
| --- | --- | --- |
| `sm` | 4 | Small chips, tags |
| `md` | 8 | Default inputs, cards |
| `lg` | 12 | Larger cards |
| `xl` | 16 | Hero cards |
| `pill` | 28 | Pill-shaped buttons (half the button height) |

## Components

Shared widgets live in `lib/core/widgets/` (import via `widgets.dart`).

- **PrimaryButton** — teal, white label, 56px, pill radius, full width.
- **SecondaryButton** — white, 2px teal border, teal label, 56px, pill.
- **EmergencyButton** — emergencyRed, white bold label with icon, 56px, pill.
- **AppTextField** — white, 1px border (2px teal focused), 52px, radius 8.
- **AppCard** — white, 1px border, radius 12, 16 padding.

Icons: **Lucide** (`lucide_icons`). Default size 24, stroke 2, outline style; filled variant only for active/selected states.

## Layout rules

- Mobile-first: design for ~390px wide screens.
- Safe area: respect device notches and home indicators.
- Bottom nav bar: 80px tall, white background, fixed at bottom.
- Page padding: 16px horizontal, 24px top of content.

## Hard rules — don't break these

1. Never use Flutter's `Colors.red`. Use `AppColors.emergencyRed`, and only for actual emergencies.
2. Never hardcode colours in widget files. Always reference `AppColors.xxx`. If you need a colour that isn't here, raise it with the team first.
3. Never use the default Flutter font. Always use `GoogleFonts.inter()` or one of the `AppTextStyles`.
4. Never use default Material `AppBar` styling. The app theme sets the standard header; use it.
5. Stick to the 8-point spacing scale. If you're using `EdgeInsets.all(13)`, you're off-scale.

## Setup checklist for each team member

Before writing UI code:

1. `flutter pub get` (design deps `google_fonts` and `lucide_icons` are already in `pubspec.yaml`).
2. Import tokens from `lib/core/constants/` and `lib/core/theme/`.
3. Build screens inside your feature's `presentation/pages/` and `presentation/widgets/` folders.
4. Keep widgets stateless where possible; manage state with BLoC/Cubit.
