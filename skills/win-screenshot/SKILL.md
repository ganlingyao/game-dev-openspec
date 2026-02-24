---
name: win-screenshot
description: Capture screenshots of application windows (Unreal Editor, Unity) or custom windows. Use when the user needs to take a screenshot of an editor window, capture game engine UI, or screenshot any specific window.
---

# Window Screenshot

Capture screenshots of specific windows using regex pattern matching. Supports Unreal Editor, Unity Editor, and custom window patterns.

- **IMPORTANT:** All file paths must use forward slashes (`/`) instead of backslashes (`\`)

## Prerequisites

- Windows 10 or later (uses Windows Graphics Capture API)
- The target window must be open and visible

## Included Scripts

| File | Description |
| ---- | ----------- |
| `scripts/win-shot.exe` | Window screenshot tool with regex matching, auto-resize, and PNG output |

## Steps

### Step 1: Determine Target Editor and Restore Minimized Windows

**CRITICAL: This step MUST be executed before EVERY list. DO NOT skip this step. DO NOT proceed to Step 2 without first restoring windows.**

Use AskQuestion tool to ask the user which editor they want to capture:

| Editor | Process Filter | Title Pattern |
| ------ | -------------- | ------------- |
| Unreal Editor | `UnrealEditor.exe` | `.*` |
| Unity Editor | `Unity.exe` | `.*` |
| Custom | User-provided | User-provided |

```bash
{{skill-dir}}/scripts/win-shot.exe -r -p "Unity.exe"
```

### Step 2: List All Windows

**CRITICAL: This step MUST be executed before EVERY capture. DO NOT skip this step. DO NOT proceed to Step 3 without first listing windows.**

List all windows belonging to the target process:

```bash
# Unreal Editor - list all windows
{{skill-dir}}/scripts/win-shot.exe -l ".*" -p "UnrealEditor.exe"

# Unity Editor - list all windows (excluding Hub)
{{skill-dir}}/scripts/win-shot.exe -l ".*" -p "Unity.exe"
```

**If no windows found:**

- Inform the user: "No matching windows found. Please open the editor first."
- Stop execution

**If windows found:**

- Display the list to the user
- Try to infer which window to capture:
  - Main editor window (contains project name)
  - Blueprint/Material editor windows
  - Prefab/Scene windows
- If cannot infer, use AskQuestion tool to ask the user which window to capture
- Use the exact window title or a refined regex for capture

### Step 3: Capture Screenshot

Once a single window is identified, capture the screenshot with both `-t` and `-p`:

```bash
{{skill-dir}}/scripts/win-shot.exe -t "{{window-title-regex}}" -p "{{process}}" -o "{{skill-dir}}/screenshot.png"
```

### Step 4: Report Result

Tell the user:

- The window that was captured
- Original dimensions
- Final dimensions (if resized)
- Output file path

## Defaults

- **Output path:** `{{skill-dir}}/screenshot.png`
- **Max width:** 1440px
- **Max height:** 900px
- Aspect ratio preserved, only downscales (never upscales)

## Notes

- Screenshots are saved in PNG format
- The regex supporting look-ahead/look-behind assertions
- Minimized windows are automatically restored before capture
- If win-shot.exe fails to execute, verify that the system is running Windows 10 1903 (Build 18362) or later (the tool requires Windows Graphics Capture API)
