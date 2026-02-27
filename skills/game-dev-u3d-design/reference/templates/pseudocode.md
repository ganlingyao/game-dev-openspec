# Pseudocode Format Standards

## Basic Format

```
class ClassName:
    # Properties
    - propertyName: Type
    - anotherProperty: Type = defaultValue

    # Methods
    method MethodName(param1: Type, param2: Type) -> ReturnType:
        ...
```

## Complete Example

```
class GameManager:
    # State
    - state: GameState (Menu, Playing, Paused, GameOver)
    - score: int = 0
    - lives: int = 3

    # Dependencies (Constructor Injection)
    - readonly events: IEventManager

    # Singleton
    - static instance: GameManager

    constructor(events: IEventManager):
        this.events = events ?? throw ArgumentNullException

    method Initialize():
        instance = this
        state = Menu

    method StartGame():
        state = Playing
        score = 0
        lives = 3
        events.Publish(in new GameStarted())
        SpawnPlayer()

    method Update():
        if state != Playing: return
        UpdateGameLogic()
        CheckWinCondition()
        CheckLoseCondition()

    method AddScore(points: int):
        score += points
        events.Publish(in new ScoreChanged(score))

    method GameOver():
        state = GameOver
        events.Publish(in new GameOver(score))
```

## Control Flow

```
# Condition
if condition:
    DoSomething()
elif otherCondition:
    DoOther()
else:
    DoDefault()

# Loop
for item in collection:
    Process(item)

for i = 0 to count - 1:
    Process(i)

while condition:
    DoSomething()

# Early Return
method Attack(target: Enemy):
    if target == null: return
    if not CanAttack(): return

    damage = CalculateDamage()
    target.TakeDamage(damage)
```

## Events (XDUF Style)

```
# Event Definition (readonly struct)
struct ScoreChanged:
    - readonly NewScore: int
    - readonly OldScore: int

# Publisher
class Player:
    - readonly events: IEventManager

    method AddScore(points: int):
        oldScore = score
        score += points
        events.Publish(in new ScoreChanged(score, oldScore))

# Subscriber
class ScoreUI:
    - subscription: IDisposable

    method Initialize():
        subscription = events.Subscribe<ScoreChanged>(OnScoreChanged)

    method Shutdown():
        subscription?.Dispose()

    method OnScoreChanged(in evt: ScoreChanged):
        UpdateDisplay(evt.NewScore)
```

## Coroutine / Async

```
method SpawnLoop():
    while true:
        yield WaitForSeconds(spawnInterval)
        if CanSpawn():
            SpawnEnemy()

method WaitForAnimation(animName: string, onComplete: Action):
    yield return null  # Wait one frame for Animator.Play to take effect
    yield WaitUntil(() => animator.GetCurrentAnimatorStateInfo(0).IsName(animName))
    yield WaitUntil(() => animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1.0)
    onComplete?.Invoke()
```

## Dependencies Notation

```
class MyService : IManager
    # Dependencies (Constructor Injection)
    - readonly events: IEventManager
    - readonly pooling: IPoolingService

    # Subscriptions (IDisposable)
    - inputSub: IDisposable
    - damageSub: IDisposable

    constructor(events: IEventManager, pooling: IPoolingService):
        this.events = events ?? throw ArgumentNullException
        this.pooling = pooling ?? throw ArgumentNullException

    method Initialize():
        inputSub = events.Subscribe<InputReceived>(OnInput)
        damageSub = events.Subscribe<DamageReceived>(OnDamage)

    method Shutdown():
        inputSub?.Dispose()
        damageSub?.Dispose()
```
