# Unity Project Architecture Template

## Feature-Based Structure

```
Assets/
│
├── XDUF/                        # XDUF Framework (Git Submodule, if using L1/L2)
│
├── Scripts/                     # All script code
│   │
│   ├── Core/                    # Core systems (reusable across projects)
│   │   ├── Bootstrap/           # Initialization (GameInitializer)
│   │   ├── Events/              # Event definitions (GameEvents)
│   │   ├── Managers/            # Managers (GameManager, AudioManager, UIManager)
│   │   └── Utils/               # Utilities (Timer, Extensions)
│   │
│   ├── Gameplay/                # Gameplay logic (project specific)
│   │   ├── Player/              # Player system
│   │   ├── Enemies/             # Enemy system
│   │   ├── Items/               # Item system
│   │   ├── Combat/              # Combat system
│   │   ├── Level/               # Level system
│   │   └── {Feature}/           # Other feature modules
│   │
│   ├── UI/                      # UI scripts
│   │   ├── Views/               # View controllers
│   │   ├── Components/          # Reusable components
│   │   ├── Popups/              # Popups
│   │   └── Widgets/             # Widgets
│   │
│   ├── Data/                    # Data definitions
│   │   ├── ScriptableObjects/   # SO class definitions
│   │   ├── Constants/           # Constants
│   │   ├── Enums/               # Enum definitions
│   │   └── SaveData/            # Save/Load data structures
│   │
│   ├── Editor/                  # Editor extensions (optional)
│   │   ├── Tools/
│   │   ├── Inspectors/
│   │   └── Windows/
│   │
│   └── Tests/                   # Test code
│       ├── EditMode/
│       └── PlayMode/
│
├── Art/                         # Art assets
│   ├── Sprites/
│   ├── Animations/
│   ├── Materials/
│   ├── Shaders/
│   └── Textures/
│
├── Prefabs/                     # Prefabs
│   ├── Characters/
│   ├── Environment/
│   ├── Items/
│   ├── Effects/
│   └── UI/
│
├── Scenes/
│   ├── Main/
│   ├── Levels/
│   └── Test/
│
├── ScriptableObjects/           # SO asset instances
│   ├── Config/
│   ├── GameData/
│   └── Events/
│
├── Audio/
│   ├── Music/
│   ├── SFX/
│   └── Mixers/
│
├── Fonts/
├── ThirdParty/
├── Resources/                   # Use sparingly
└── StreamingAssets/
```

## Design Principles

1. **Feature Module Separation**
   - `Scripts/` - All code centralized, separated by feature
   - `Art/` - All art assets centralized, separated by type
   - `Prefabs/` - All prefabs centralized, classified by feature

2. **Clear Hierarchy**
   - `Core/` - Reusable infrastructure, no game logic dependencies
   - `Gameplay/` - Project-specific game logic
   - `Data/` - Pure data definitions, no behavioral logic

3. **Test Friendly**
   - `Scripts/Tests/` - Test code at same level as source
   - `EditMode/` and `PlayMode/` separated

4. **Asset Management**
   - `Resources/` - Only for truly dynamic runtime loading
   - `ThirdParty/` - Isolate third-party for easy upgrade
   - Prefer Addressables over Resources

5. **Naming Conventions**
   - PascalCase for folders
   - Match code namespaces (e.g., `Scripts/Gameplay/Player/` → `namespace Game.Gameplay.Player`)
