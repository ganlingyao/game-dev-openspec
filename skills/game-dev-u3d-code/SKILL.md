---
name: game-dev-u3d-code
description: Provides Unity C# coding standards, unit testing patterns, and code review guidelines. Use when writing or reviewing Unity scripts.
disable-model-invocation: true
---

# Code Unity Skill

Unity C# coding capability ensuring code quality, standardization, and testability.

---

## Reference Files

For detailed standards, see these files:

| File | Content |
|------|---------|
| [reference/naming-conventions.md](reference/naming-conventions.md) | Naming rules, file headers, XML docs |
| [reference/class-structure.md](reference/class-structure.md) | Class member order, code format |
| [reference/unity-practices.md](reference/unity-practices.md) | Best practices, prohibitions, common fixes |
| [reference/testing-guide.md](reference/testing-guide.md) | Test structure, examples, principles |

---

## Quick Reference

### Naming Conventions

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

## Coding Workflow

```
1. Read task and related design
       |
2. Write code (follow standards)
       |
3. Check compilation (MANDATORY: read_console)
       |
4. Self-check against standards
       |
5. Write tests (if required)
       |
6. Run tests (test-unity skill)
       |
7. Mark task complete
```

### Mandatory Post-Script Actions

When using UnityMCP to create or modify scripts:

**You MUST call `read_console` after EVERY script creation/modification:**

```
1. Create/modify script via UnityMCP
2. Wait for domain reload (check editor_state.isCompiling if needed)
3. Call read_console to check for errors
4. If errors exist: fix immediately before proceeding
5. Only continue to next task after successful compilation
```

---

## Self-Check List

### Standards Check
- [ ] Naming follows conventions (_camelCase for private)
- [ ] Use [SerializeField] instead of public
- [ ] Class members arranged in prescribed order
- [ ] No magic numbers

### Unity Check
- [ ] Component references cached in Awake
- [ ] No Find/GetComponent used in Update
- [ ] Events unsubscribed in OnDisable
- [ ] Use object pooling for frequently created objects

### Performance Check
- [ ] No memory allocation in Update
- [ ] No unnecessary GetComponent calls
- [ ] Expensive operations use interval checks or coroutines

### Maintainability Check
- [ ] Public APIs have documentation comments
- [ ] Complex logic has explanatory comments
- [ ] Methods do not exceed 30 lines
- [ ] Classes do not exceed 300 lines

---

## Code Quality Metrics

| Metric | Target |
|--------|--------|
| Method Lines | < 30 |
| Class Lines | < 300 |
| Nesting Depth | < 3 |
| Parameter Count | < 5 |
| Cyclomatic Complexity | < 10 |
