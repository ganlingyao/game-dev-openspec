# Unity C# Naming Conventions

## Quick Reference

| Type | Style | Example |
|------|-------|---------|
| Class/Struct/Enum | PascalCase | `PlayerController`, `GameData` |
| Interface | IPascalCase | `IDamageable`, `IInteractable` |
| Public Member | PascalCase | `public int MaxHealth;`, `public void Fire()` |
| Private/Protected Field | _camelCase | `private float _movementSpeed;` |
| Local Variable/Parameter | camelCase | `int tempScore;`, `void SetHealth(int newHealth)` |
| Boolean | is/has/can + PascalCase | `public bool IsAlive;`, `private bool _canJump;` |
| Constant | ALL_CAPS_SNAKE_CASE | `public const int MAX_AMMO = 100;` |
| Coroutine Method | PascalCaseCoroutine | `private IEnumerator FadeOutCoroutine()` |

---

## File Header Comments (Required)

```csharp
/*
 * File:      PlayerHealth.cs
 * Author:    XDTS
 * Date:      2025-08-06
 * Version:   1.0
 *
 * Description:
 *   Manages the player's health, damage intake, and death event.
 *
 *   Classes:
 *     - PlayerHealth: Handles player's health state and damage processing.
 *         - TakeDamage(): Applies damage to the player and checks for death.
 *         - Heal(): Restores a specified amount of health.
 *
 * History:
 *   1.0 (2025-08-06) - Initial creation.
 */
```

---

## XML Documentation Comments (Required for all members)

```csharp
/// <summary>
/// Calculates the final damage value after applying armor and buffs.
/// </summary>
/// <param name="baseDamage">The initial, unmodified damage amount.</param>
/// <param name="armor">The target's armor rating.</param>
/// <returns>The calculated damage to be applied.</returns>
private float CalculateFinalDamage(float baseDamage, float armor)
{
    // Use squared magnitude for performance, avoids costly square root.
    // ...
}
```
