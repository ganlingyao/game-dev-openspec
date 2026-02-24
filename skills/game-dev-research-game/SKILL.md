---
name: research-game
description: Game market research capability. Used for game genre analysis, competitor research, risk assessment, and best practices collection. Automatically triggered during the research phase.
---

# Research Game Skill - Game Market Research

Used for the **research phase** of the openspec workflow, producing `research.md`.

---

## Tools Used

- **WebSearch** - Search for game market information, competitor data, and user reviews.

---

## Research Steps

### 1. Game Genre Analysis

Use WebSearch to find successful games in the genre:

```
WebSearch: "[Game Genre] game successful examples 2024"
WebSearch: "[Game Genre] game market trends"
```

Analyze content:
- Common features of similar games
- Success factors
- Market trends

### 2. Competitor Analysis

Select 3-5 similar games for analysis:

```
WebSearch: "[Game Name] review gameplay features"
WebSearch: "[Game Name] steam reviews user feedback"
```

Analyze each game:
- Core mechanics
- Pros and Cons
- User reviews (Steam/App Store comments)
- Differentiating features

### 3. Risk Assessment

```
WebSearch: "[Game Genre] game development common bugs issues"
WebSearch: "[Game Genre] game design pitfalls"
```

Assess content:
- **Technical Risks**: Performance, compatibility, implementation difficulty
- **Design Risks**: Balance, player experience
- **Common Bugs**: Typical issues for this genre
- **Failure Cases**: Learn from past mistakes

### 4. Best Practices Collection

```
WebSearch: "[Game Genre] game development best practices"
WebSearch: "[Game Engine] [Game Genre] optimization tips"
```

Collect content:
- Recommended design patterns
- Performance optimization strategies
- Player retention mechanisms

---

## Output Format

Output in English

```markdown
# Research: [游戏名称]

## 游戏品类分析

[品类特征、成功要素、市场趋势]

## 竞品分析

### 竞品 1: [名称]
- **核心机制**: ...
- **优点**: ...
- **缺点**: ...
- **用户评价**: ...

### 竞品 2: [名称]
...

### 竞品 3: [名称]
...

## 风险评估

### 技术风险

| 风险 | 描述 | 缓解措施 |
|------|------|----------|
| ... | ... | ... |

### 设计风险

| 风险 | 描述 | 缓解措施 |
|------|------|----------|
| ... | ... | ... |

### 常见 Bug 类型
- ...

## 最佳实践

### 推荐的设计模式
- ...

### 性能优化策略
- ...

### 玩家留存机制
- ...

## 平台考量
- ...

## References
- [Source Title](URL)
- ...
```

---

## Trigger Conditions

This Skill is automatically triggered in the following situations:
- During the **research phase** of openspec
- When the user requests game market research
- When competitor analysis or risk assessment is needed

---

## Important Notes

1. **Must Cite Sources** - WebSearch results must be listed as reference links at the end of the document.
2. **Focus on Real Data** - Prioritize specific data such as download counts, ratings, etc.
3. **Risks Must Have Mitigation** - Every risk must provide a corresponding solution.
