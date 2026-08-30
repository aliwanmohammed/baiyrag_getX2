# DESIGN SYSTEM FOUNDATION

## 1. Architecture Overview
The Design System Foundation establishes a **Single Source of Truth** for the application's visual language and core UI components. It relies strictly on a layered architecture:

```text
Tokens (Primitive -> Semantic)
        ↓
Theme (Material 3 / Light & Dark)
        ↓
Generic Components (Buttons, Inputs, Icons, Feedback)
        ↓
Patterns (Responsive, Adaptive, RTL, Accessibility)
        ↓
Domain Components (Feature specific)
```

## 2. Tokens (`lib/core/design_system/tokens/`)

### Colors (`app_colors.dart`)
- **Primitive Tokens**: Hardcoded hex values representing the exact Brand Identity and grayscale (`AppPrimitiveColors`).
- **Light Semantic Tokens**: Meaningful mappings (e.g., `primary`, `surface`, `error`) used across the application (`AppColors`).
- **Dark Semantic Tokens**: Dark mode mapping (`AppDarkColors`).

### Typography (`app_typography.dart`)
- Based on `Cairo` font for Arabic-first compatibility.
- Follows Material 3 hierarchy (`display`, `headline`, `title`, `body`, `label`).
- Adheres to Flutter's text scaling for accessibility.

### Spacing & Sizes (`app_spacing.dart`, `app_sizes.dart`)
- **Spacing**: Defined on an extracted scale (`xs`, `sm`, `md`, `lg`, `xl`, `xxl`).
- **Sizes**: Standardized shared constraints (e.g., `buttonHeightMd`, `iconMd`) and accessibility targets like `minimumTouchTarget` (48.0).

### Radius, Borders, Shadows & Motion (`app_radius.dart`, `app_borders.dart`, `app_shadows.dart`, `app_motion.dart`)
- **Radius**: Semantic border radius scales mapped to components.
- **Borders**: Provides semantic BorderSide factories (e.g., `AppBorders.focusedSide(context)`).
- **Shadows**: Custom shadows (`xs` to `xxl`).
- **Motion**: Standard durations (fast, normal, slow) and curves (standard, emphasized, decelerate, accelerate).

## 3. Theme Integration (`lib/core/design_system/theme/app_theme.dart`)
- **Material 3**: Fully integrated.
- **Light & Dark Theme**: Built dynamically by consuming the Semantic Tokens (`AppColors` & `AppDarkColors`).

## 4. Core Components (`lib/core/design_system/components/`)

### Buttons (`app_button.dart`)
- Takes `variant` (primary, secondary, outlined, text), `size`, and `state` (default, loading, disabled). No arbitrary colors.

### Inputs (`app_text_field.dart`)
- Takes `state` (default, focused, error, disabled, readOnly).

### Icons (`app_icon.dart`)
- Enforces Google Material Icons.
- Automatically handles RTL directional flipping (for arrows/chevrons) and semantics.

### Feedback (`feedback/`)
- Unified components: `AppLoading`, `AppEmptyState`, `AppErrorState`.
- Decoupled from Domain APIs (e.g., takes simple strings and callbacks, not Domain Models).

## 5. Patterns (`lib/core/design_system/patterns/`)

### Responsive & Adaptive Layouts (`app_breakpoints.dart`, `app_responsive.dart`)
- Breakpoints are determined by **Available Width**, not device type (Compact: < 600, Medium: < 840, Expanded: > 840).
- `AppConstrainedContent`: Ensures content doesn't stretch infinitely.
- `AppAdaptiveGrid`: Dynamically calculates columns based on available width and minimum item width.

### RTL Handling (`app_rtl.dart`)
- Use `AppRTL.isRTL(context)` and `AppRTL.flipForRTL()`.
- Use `EdgeInsetsDirectional` over `EdgeInsets.only(left/right)`.

### Accessibility (`app_accessibility.dart`)
- Text scaling is allowed to scale dynamically.
- Interactive elements ensure minimum touch targets (48x48) are met.
- Informational Icons are wrapped in semantics; decorative icons use `ExcludeSemantics`.

## 6. Data/UI Separation
- The Design System has **zero** knowledge of Domain logic.
- Do not import Models (e.g., `ProductModel`), Providers, or Repositories into the `design_system` module.

## 7. Compatibility Facades
- Legacy integrations (`lib/app/theme/` and `lib/core/widgets/`) have been maintained as **Compatibility Facades**. They re-export the unified components and tokens from `lib/core/design_system/` to ensure zero compilation errors in untouched features.

## 8. Migration Rules
- When migrating features, replace usage of `CustomButton` with `AppButton`, `empty_state` with `AppEmptyState`, etc.
- Never duplicate a design system component inside a feature.
- Ensure all new components follow the Variant/Size/State API rule.
