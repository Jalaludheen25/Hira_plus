# Design Document

## Overview

This design outlines the reorganization of the manager_screen folder structure to improve code maintainability, readability, and developer experience. The current structure has some inconsistencies in naming conventions and organization that will be addressed through systematic reorganization and sorting.

## Architecture

The reorganized manager_screen folder will follow Flutter best practices with clear separation of concerns:

```
lib/screens/manager_screen/
├── models/
│   ├── core/           # Core business models
│   ├── food/           # Food-related models
│   ├── meeting/        # Meeting-related models
│   ├── transportation/ # Transportation models
│   └── user/           # User-related models
├── providers/          # State management (sorted alphabetically)
├── services/           # API services (sorted alphabetically)
├── views/              # UI screens organized by feature
│   ├── dashboard/      # Dashboard-related screens
│   ├── food/           # Food management screens
│   ├── meeting/        # Meeting management screens
│   ├── transportation/ # Transportation screens
│   ├── user/           # User management screens
│   └── shared/         # Shared/common screens
└── widgets/            # Reusable UI components (sorted alphabetically)
```

## Components and Interfaces

### 1. Models Reorganization

**Current Issues:**

- `meating_model.dart` has a typo (should be `meeting_model.dart`)
- Models are not grouped by domain/functionality
- Some models have inconsistent naming patterns

**New Structure:**

```
models/
├── core/
│   ├── department_model.dart
│   └── message_model.dart
├── food/
│   ├── manager_guest_meal_model.dart
│   ├── meal_users_model.dart
│   └── menu_model.dart
├── meeting/
│   └── meeting_model.dart (renamed from meating_model.dart)
├── transportation/
│   ├── route_model.dart
│   └── vehicle_model.dart
└── user/
    ├── user_marking_model.dart
    ├── user_model.dart
    └── users_list_model.dart
```

### 2. Providers Reorganization

**Current State:** Files are mostly well-organized but need alphabetical sorting
**New Structure:** All provider files sorted alphabetically with consistent naming:

```
providers/
├── banner_upload_provider.dart
├── department_provider.dart
├── manager_bulk_food_provider.dart
├── meeting_provider.dart
├── menu_provider.dart
├── messages_provider.dart
├── transportation_provider.dart
├── user_marking_provider.dart
├── users_by_meals_provider.dart
└── users_provider.dart
```

### 3. Services Reorganization

**Current Issues:**

- Limited number of service files
- Could benefit from more granular separation

**New Structure:** Alphabetically sorted with potential for expansion:

```
services/
├── meeting_service.dart
├── menu_service.dart
├── transportation_service.dart
└── users_service.dart
```

### 4. Views Reorganization

**Current Issues:**

- `user_list_screem` has a typo (should be `user_list_screen`)
- Files are not grouped by functionality
- Some screens could be better categorized

**New Structure:**

```
views/
├── dashboard/
│   └── manager_screen.dart
├── food/
│   ├── food_menu_add_screen.dart
│   ├── food_menu_list_screen.dart
│   ├── manager_bulk_food_list_screen.dart
│   └── manager_bulk_food_mark_screen.dart
├── meeting/
│   └── meeting_management_screen.dart
├── shared/
│   ├── banner_dialog.dart
│   ├── messages_screen.dart
│   └── settings_screen.dart
├── transportation/
│   ├── add_route_screen.dart
│   ├── add_vehicle_screen.dart
│   ├── driver_selection_screen.dart
│   └── transportation_screen.dart
└── user/
    ├── add_user_screen.dart
    ├── marking_list_screen.dart
    └── users_list_screen.dart
```

### 5. Widgets Reorganization

**Current State:** Small number of widgets, well-organized
**New Structure:** Alphabetically sorted:

```
widgets/
├── delete_confirm_dialog.dart
├── user_action_button.dart
└── user_edit_bottom_sheet.dart
```

## Data Models

### Model Categories

1. **Core Models**: Basic system models (department, message)
2. **Food Models**: Meal and menu related data structures
3. **Meeting Models**: Meeting/event related models
4. **Transportation Models**: Vehicle and route models
5. **User Models**: User management and marking models

### Naming Conventions

- All model files end with `_model.dart`
- Use descriptive names that clearly indicate the model's purpose
- Fix typos (e.g., `meating_model.dart` → `meeting_model.dart`)
- Group related models in subdirectories

## Error Handling

### Import Path Updates

- All import statements will be systematically updated
- Use relative imports where appropriate
- Ensure no broken imports after reorganization
- Test all import paths after changes

### Validation Strategy

1. **Pre-move validation**: Identify all files that import from manager_screen
2. **Move execution**: Systematically move files to new locations
3. **Import updates**: Update all import statements
4. **Post-move validation**: Verify no broken imports exist

## Testing Strategy

### Verification Steps

1. **Static Analysis**: Run `flutter analyze` to check for import errors
2. **Build Test**: Ensure `flutter build` completes successfully
3. **Functionality Test**: Verify all manager screen features work correctly
4. **Import Verification**: Check that all external references are updated

### Rollback Plan

- Keep track of all moved files and their original locations
- Maintain a mapping of old paths to new paths
- Be prepared to revert changes if critical issues arise

## Implementation Phases

### Phase 1: Model Reorganization

- Create new model subdirectories
- Move and rename model files
- Update model imports

### Phase 2: Provider and Service Sorting

- Sort provider files alphabetically
- Sort service files alphabetically
- Update related imports

### Phase 3: View Restructuring

- Create new view subdirectories
- Move view files to appropriate categories
- Fix directory name typos
- Update view imports

### Phase 4: Widget Organization

- Sort widget files alphabetically
- Update widget imports

### Phase 5: Global Import Updates

- Update all external files that import from manager_screen
- Verify all imports are working correctly
- Run comprehensive tests

## Migration Considerations

### Backward Compatibility

- Ensure all existing functionality continues to work
- Update all references from other parts of the application
- Maintain API contracts between components

### Performance Impact

- No performance impact expected from reorganization
- Import paths may be slightly longer but more descriptive
- Better organization should improve development performance
