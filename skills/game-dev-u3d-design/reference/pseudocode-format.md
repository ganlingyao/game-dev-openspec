# Pseudocode Format Standards

## 基本格式

```
class ClassName:
    # Properties
    - propertyName: Type
    - anotherProperty: Type = defaultValue

    # Methods
    method MethodName(param1: Type, param2: Type) -> ReturnType:
        ...
```

---

## 依赖注入标注

**重要**：所有外部依赖必须通过构造函数注入，使用 `readonly` 标记：

```
class PlantGrowthSystem:
    # Dependencies (Constructor Injection) - 依赖接口，不依赖实现
    - readonly events: IEventBus
    - readonly config: IConfigProvider
    - readonly resource: IResourceLoader

    # State
    - currentStage: int = 0
    - totalNutrients: int = 0

    # Subscriptions
    - nutrientSub: IDisposable

    constructor(events: IEventBus, config: IConfigProvider, resource: IResourceLoader):
        this.events = events ?? throw ArgumentNullException
        this.config = config ?? throw ArgumentNullException
        this.resource = resource ?? throw ArgumentNullException

    method Initialize():
        nutrientSub = events.Subscribe<NutrientChanged>(OnNutrientChanged)
        LoadStageConfig()

    method Shutdown():
        nutrientSub?.Dispose()
```

---

## 事件定义

使用 `readonly struct` 定义事件，避免 GC：

```
# Event Definition (readonly struct)
struct NutrientChanged:
    - readonly OldValue: int
    - readonly NewValue: int
    - readonly Source: InputType

struct PlantStageChanged:
    - readonly OldStage: int
    - readonly NewStage: int
```

---

## 事件发布/订阅

```
# Publisher
class NutrientManager:
    - readonly events: IEventBus

    method AddNutrient(amount: int, source: InputType):
        oldValue = nutrients
        nutrients += amount
        events.Publish(in new NutrientChanged(oldValue, nutrients, source))

# Subscriber
class PlantGrowthSystem:
    - nutrientSub: IDisposable

    method Initialize():
        nutrientSub = events.Subscribe<NutrientChanged>(OnNutrientChanged)

    method Shutdown():
        nutrientSub?.Dispose()

    method OnNutrientChanged(in evt: NutrientChanged):
        CheckGrowthCondition(evt.NewValue)
```

---

## 控制流

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

# Early Return (Guard Clause)
method ProcessInput(input: InputEvent):
    if input == null: return
    if not isActive: return

    # Main logic
    HandleInput(input)
```

---

## 配置读取

通过接口读取配置，不硬编码：

```
class PlantGrowthSystem:
    - readonly config: IConfigProvider
    - stageConfigs: List<StageConfig>

    method LoadStageConfig():
        stageConfigs = config.GetConfig<GrowthConfig>().Stages

    method CheckGrowthCondition(nutrients: int):
        # 配置驱动，不硬编码阈值
        for stage in stageConfigs:
            if nutrients >= stage.RequiredNutrients and currentStage < stage.Id:
                TransitionToStage(stage.Id)
                break
```

---

## 资源加载

通过接口异步加载：

```
class PlantVisualController:
    - readonly resource: IResourceLoader
    - currentSprite: Sprite

    async method LoadStageVisual(stageId: int):
        key = $"plant_stage_{stageId}"
        currentSprite = await resource.LoadAsync<Sprite>(key)
        UpdateVisual(currentSprite)
```

---

## 协程 / 异步

```
method GrowthAnimation():
    # 播放动画
    animator.Play("Growth")

    # 等待动画完成
    yield WaitUntil(() => animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1.0)

    # 发布完成事件
    events.Publish(in new GrowthAnimationComplete())

async method LoadAndApplyVisual(stageId: int):
    sprite = await resource.LoadAsync<Sprite>($"stage_{stageId}")
    spriteRenderer.sprite = sprite
```

---

## 完整示例

```
class PlantGrowthSystem:
    # Dependencies (Constructor Injection)
    - readonly events: IEventBus
    - readonly config: IConfigProvider
    - readonly time: ITimeProvider

    # State
    - currentStage: int = 0
    - internalLevel: int = 0  # 内部等级，不显示给玩家
    - totalNutrients: int = 0

    # Config (loaded at runtime)
    - stageConfigs: List<StageConfig>
    - levelConfigs: List<LevelConfig>

    # Subscriptions
    - nutrientSub: IDisposable

    constructor(events: IEventBus, config: IConfigProvider, time: ITimeProvider):
        this.events = events ?? throw ArgumentNullException
        this.config = config ?? throw ArgumentNullException
        this.time = time ?? throw ArgumentNullException

    method Initialize():
        LoadConfigs()
        nutrientSub = events.Subscribe<NutrientChanged>(OnNutrientChanged)

    method Shutdown():
        nutrientSub?.Dispose()

    method LoadConfigs():
        growthConfig = config.GetConfig<GrowthConfig>()
        stageConfigs = growthConfig.Stages
        levelConfigs = growthConfig.Levels

    method OnNutrientChanged(in evt: NutrientChanged):
        totalNutrients = evt.NewValue
        CheckStageTransition()
        CheckLevelUp()

    method CheckStageTransition():
        for stage in stageConfigs:
            if totalNutrients >= stage.RequiredNutrients and currentStage < stage.Id:
                TransitionToStage(stage.Id)
                return

    method CheckLevelUp():
        # 内部等级逻辑，用于绑定果实
        for level in levelConfigs:
            if totalNutrients >= level.RequiredNutrients and internalLevel < level.Id:
                internalLevel = level.Id
                events.Publish(in new PlantLevelChanged(internalLevel))
                return

    method TransitionToStage(newStage: int):
        oldStage = currentStage
        currentStage = newStage
        events.Publish(in new PlantStageChanged(oldStage, newStage))

    method GetCurrentLevel() -> int:
        return internalLevel
```
