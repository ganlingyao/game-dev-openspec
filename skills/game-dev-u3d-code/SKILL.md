---
name: game-dev-u3d-code
description: |
  Unity C# coding capability with framework integration. Use this skill when:
  - Writing Unity C# scripts or components
  - Implementing tasks from design.md or tasks.md
  - Creating or modifying .cs files in a Unity project
  - Working on Unity game development code
---

# Unity Code Skill

Unity C# coding capability ensuring code quality, framework integration, and compilation verification.

**Important**: This skill MUST be followed when writing any Unity C# code.

---

## Step 0: Pre-Coding Checks (MANDATORY)

Before writing ANY code, check design.md for integration level annotations:

```
# Look for these markers in pseudocode comments:
# Reference: ../XDUF/Assets/Framework/...
# Integration Level: L1 (Copy-Adapt) | L2 (Wrap-Integrate) | L3 (Reference-Design)
```

### Integration Level Actions

| Level | Meaning | Required Action |
|-------|---------|-----------------|
| **L1 Copy-Adapt** | Copy XDUF source, adapt namespace | **MUST** read XDUF source, copy and adapt |
| **L2 Wrap-Integrate** | Wrap XDUF component, add project interface | **MUST** read XDUF source, create wrapper |
| **L3 Reference-Design** | Learn design pattern, simplify implementation | **MAY** read source for reference |
| **Custom** | Fully custom implementation | Use design.md pseudocode directly |

### XDUF Source Location

XDUF framework is located at `../XDUF` relative to the Unity project root:

```
Parent Directory/
├── XDUF/                    # XDUF Framework
│   └── Assets/Framework/    # Source files to reference
└── YourProject/             # Current Unity project
    └── Assets/
```

**To read XDUF source:**
```
# From project root, XDUF is at ../XDUF
Read: "../XDUF/Assets/Framework/[path-from-design.md]"
```

---

## Step 1: Source Extraction (L1/L2 Only)

When design.md specifies L1 or L2 integration:

1. **Read the reference source file**
   ```
   Read: "../XDUF/Assets/Framework/Events/EventManager.cs"
   ```

2. **Understand the implementation**
   - Class structure and dependencies
   - Key methods and their logic
   - Edge case handling
   - Performance optimizations (e.g., zero GC)

3. **Copy and adapt**
   - Change namespace: `XDUF.*` → `{ProjectName}.*`
   - Apply simplifications from design.md "Adaptation Notes"
   - Preserve core functionality and patterns
   - Keep edge case handling

4. **Verify completeness**
   - Compare with original features
   - Ensure no critical functionality is lost

---

## Step 2: Write Code (MANDATORY)

  **MUST read these reference files before writing any code:**
  - reference/naming-conventions.md
  - reference/class-structure.md
  - reference/unity-practices.md
  - refrence/testing-guide.md

- [reference/naming-conventions.md](reference/naming-conventions.md) - Naming rules
- [reference/class-structure.md](reference/class-structure.md) - Member order, format
- [reference/unity-practices.md](reference/unity-practices.md) - Best practices
- [reference/testing-guide.md](reference/testing-guide.md) - Test patterns

### Quick Reference

| Type | Style | Example |
|------|-------|---------|
| Class/Struct | PascalCase | `PlayerController` |
| Interface | IPascalCase | `IDamageable` |
| Public Member | PascalCase | `public int MaxHealth;` |
| Private Field | _camelCase | `private float _speed;` |
| Constant | ALL_CAPS | `const int MAX_AMMO = 100;` |

### Key Rules

- Use `[SerializeField] private` instead of `public` fields
- Cache component references in `Awake()`, not in `Update()`
- Unsubscribe events in `OnDisable()` to prevent memory leaks
- No `Find()`/`GetComponent()` in `Update()` - cache references
- No `new` allocations in `Update()` - use object pooling

---

## Step 3: Compilation Check (MANDATORY)

**After EVERY script creation or modification:**

1. **Wait for Unity compilation**
   - Check `editor_state.isCompiling` if available
   - Or wait 2-3 seconds for domain reload

2. **Read console for errors**
   ```
   mcp__UnityMCP__read_console(types=["error", "warning"])
   ```

3. **Handle results**
   - **Errors**: Fix immediately. Do NOT proceed to next task.
   - **Warnings**: Evaluate and fix if necessary.
   - **No errors**: Continue to next step.

**Prohibited**: Continuing to other tasks while compilation errors exist.

---

## Step 4: Self-Check

### Source Extraction Check (L1/L2)
- [ ] Read XDUF reference source
- [ ] Namespace correctly adapted
- [ ] Core functionality preserved
- [ ] Design.md adaptations applied

### Coding Standards Check
- [ ] Naming follows conventions
- [ ] Using [SerializeField] instead of public
- [ ] Class members in correct order
- [ ] No magic numbers

### Unity Practices Check
- [ ] Component references cached in Awake
- [ ] No Find/GetComponent in Update
- [ ] Events unsubscribed in OnDisable
- [ ] Object pooling for frequent allocations

### Compilation Check
- [ ] Called read_console
- [ ] No compilation errors
- [ ] Warnings evaluated/fixed

---

## Workflow Summary

```
1. Read task and design.md
       ↓
2. Check integration level (L1/L2/L3/Custom)
       ↓
3. If L1/L2: Read XDUF source from ../XDUF/Assets/Framework/...
       ↓
4. Write code following standards
       ↓
5. Check compilation (read_console) - MANDATORY
       ↓
6. Self-check against checklist
       ↓
7. Mark task complete
```

---

## Code Quality Metrics

| Metric | Target |
|--------|--------|
| Method Lines | < 30 |
| Class Lines | < 300 |
| Nesting Depth | < 3 |
| Parameter Count | < 5 |
| Cyclomatic Complexity | < 10 |

---

## Example: L1 Integration

**design.md annotation:**
```
class EventBus implements IEventBus:
    # Reference: ../XDUF/Assets/Framework/Events/EventManager.cs
    # Integration Level: L1 (Copy-Adapt)
    # Adaptation Notes:
    #   - Namespace: XDUF.Events → Plants.Core.Events
    #   - Simplify: Remove thread safety (single-threaded is sufficient)
```

**Correct approach:**
```
1. Read "../XDUF/Assets/Framework/Events/EventManager.cs"
2. Copy the implementation
3. Change namespace XDUF.Events → Plants.Core.Events
4. Remove thread safety code as specified
5. Write to "Assets/Scripts/Core/Events/EventBus.cs"
6. Run read_console to verify compilation
```

**Incorrect approach:**
```
❌ Write simplified version from pseudocode only
❌ Skip reading XDUF source
❌ Skip compilation check
```
