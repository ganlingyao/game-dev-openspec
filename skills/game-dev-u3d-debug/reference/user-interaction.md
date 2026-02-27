# User Interaction Patterns

Use `AskUserQuestion` tool for interaction confirmation, NOT polling.

---

## Core Principles

### 1. Use AskUserQuestion for User Actions

When user needs to perform actions in Unity:
1. Clearly explain the steps
2. Use AskUserQuestion to provide confirmation options
3. Continue processing based on user response

### 2. Batch Operations

| Scenario | Approach |
|----------|----------|
| Simple consecutive operations | One explanation, one confirmation |
| Step-by-step verification needed | Batch by batch, one confirmation per batch |
| Complex debugging flow | Divide by phases, confirm each phase |

### 3. Auto-detection First

For auto-detectable results (scene switch, log output, etc.), prefer using tools for detection without user confirmation.

---

## Pattern 1: Single Step Confirmation

For scenarios requiring user to perform a single action.

```
[Tool: AskUserQuestion]
  questions:
    - question: "Please click the START button in Unity Game view, then select an option below"
      header: "Action Confirmation"
      options:
        - label: "Done"
          description: "Button clicked, waiting for result check"
        - label: "Problem encountered"
          description: "Button cannot be clicked or other issues"
        - label: "Skip"
          description: "Skip this step"
      multiSelect: false
```

---

## Pattern 2: Batch Operation Confirmation

For scenarios requiring user to perform a series of actions.

```
[Tool: AskUserQuestion]
  questions:
    - question: "Please complete the following:\n1. Click START button to enter game\n2. Move snake using arrow keys\n3. Try to eat a food item\n\nSelect result after completion"
      header: "Batch Actions"
      options:
        - label: "All succeeded"
          description: "All steps completed successfully"
        - label: "Partial failure"
          description: "Some steps failed"
        - label: "Need help"
          description: "Not sure how to proceed"
      multiSelect: false
```

---

## Pattern 3: Observation Confirmation

For scenarios requiring user to observe and report results.

```
[Tool: AskUserQuestion]
  questions:
    - question: "Please observe the Game view and answer:\n- Is the border fully visible?\n- Is the snake head visible?\n- Are there any abnormal lines or graphics?"
      header: "Visual Check"
      options:
        - label: "Display normal"
          description: "Everything looks correct"
        - label: "Has issues"
          description: "Found visual problems (please describe)"
        - label: "Not sure"
          description: "Cannot determine"
      multiSelect: false
```

---

## Pattern 4: Error Handling

When user reports an error or problem.

```
[Tool: AskUserQuestion]
  questions:
    - question: "What happened when you clicked the button?"
      header: "Error Details"
      options:
        - label: "No response"
          description: "Nothing happened at all"
        - label: "Error message"
          description: "Saw an error popup or console message"
        - label: "Partial response"
          description: "Something happened but not expected result"
        - label: "Game crashed"
          description: "Unity became unresponsive"
      multiSelect: false
```
