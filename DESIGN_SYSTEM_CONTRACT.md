# Design System Architecture Contract

## Source of Truth
All reusable design tokens live under:
`lib/core/design_system/tokens/`

All global theme construction lives under:
`lib/core/design_system/theme/`

## Compatibility
`lib/app/theme/` contains export-only compatibility facades.
Do not add new tokens there.

`lib/app/widgets/app_button.dart` is a compatibility facade only.
New UI code should use:
`lib/core/design_system/components/app_button.dart`

## Rule
New reusable colors, spacing, radius, typography, shadows, sizes, and components
must be added to the Design System first and then consumed by feature code.
Do not create a second token system inside a feature.
