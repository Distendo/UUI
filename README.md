# UUI — UU's UI Library

A modern, lightweight, and highly customizable UI framework for Roblox.

```
██╗   ██╗██╗   ██╗██╗
██║   ██║██║   ██║██║
██║   ██║██║   ██║██║
██║   ██║██║   ██║██║
╚██████╔╝╚██████╔╝██║
 ╚═════╝  ╚═════╝  ╚═╝
```

> Premium next-gen Roblox UI library — smooth, modern, production-ready.

---

## Features

- **Window system** — Draggable, fade+scale open/close, overlay backdrop, keybind toggle
- **Tab system** — Animated side navigation with spring indicator
- **UI Elements** — Button, Toggle, Slider, Dropdown, Label, Separator
- **Notification system** — Stackable toast-style with progress bar and types
- **All animations via TweenService** — Sine, Quad, Expo, Elastic easing; no instant state changes
- **Dark modern theme** — UICorner rounding, subtle gradients, soft shadows
- **Fully responsive** — PC + mobile touch support, auto-layout via UIListLayout
- **No external dependencies** — Pure Luau, no asset IDs required
- **Customizable theme** — `SetTheme()` / `GetTheme()` API

---

## Quick Start

```lua
local UI = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

local Window = UI:CreateWindow("My Hub", {
    Keybind = "RightControl"
})

local Tab = Window:CreateTab("Main")

Tab:CreateButton("Click Me", function()
    print("Clicked!")
end)

Tab:CreateToggle("Enable Feature", true, function(state)
    print("Toggled:", state)
end)

Tab:CreateSlider("Volume", 0, 100, 50, function(value)
    print("Volume:", value)
end, "%")

Tab:CreateDropdown("Mode", {"Easy", "Normal", "Hard"}, function(selected)
    print("Selected:", selected)
end)

Tab:CreateLabel("Information text here")
Tab:CreateSeparator()

UI:Notify({
    Title = "Welcome",
    Content = "UUI loaded successfully",
    Duration = 4,
    Type = "success"
})
```

---

## API Reference

### UI Module

| Method | Description |
|--------|-------------|
| `CreateWindow(title, settings)` | Creates a new window. `settings.Keybind` accepts `Enum.KeyCode` or string name. `settings.Size` accepts `Vector2`. |
| `Notify(config)` | Shows a toast notification. |
| `SetTheme(overrides)` | Override theme colors. |
| `GetTheme()` | Returns a copy of the current theme. |

### Window

| Method | Description |
|--------|-------------|
| `CreateTab(name)` | Creates a new tab and returns it. |
| `ToggleVisibility()` | Toggle window show/hide with animation. |
| `Destroy()` | Close window with exit animation. |

### Tab

| Method | Description |
|--------|-------------|
| `CreateButton(text, callback)` | Button element. |
| `CreateToggle(text, default, callback)` | Toggle switch. `callback(state)` |
| `CreateSlider(text, min, max, default, callback, suffix)` | Drag slider. `callback(value)` |
| `CreateDropdown(text, options, callback, default)` | Animated dropdown. `callback(selected)` |
| `CreateLabel(text)` | Section label. |
| `CreateSeparator()` | Horizontal divider. |

### Notification Config

| Field | Type | Description |
|-------|------|-------------|
| `Title` | string | Notification title |
| `Content` | string | Body text |
| `Duration` | number | Seconds before auto-dismiss (default: 4) |
| `Type` | string | `"success"`, `"error"`, `"warning"`, or nil |
| `Callback` | function | Fired on notification click |

---

## Theme Customization

```lua
UI:SetTheme({
    Accent = Color3.fromRGB(255, 100, 100),
    Background = Color3.fromRGB(10, 10, 15),
})
```

See `UUI.lua` top-level `Theme` table for all available keys.

---

## Architecture

```
UUI.lua
├── Services & Theme
├── Tween Presets
├── Utility Functions
├── Notification System
├── Window Class
│   ├── AnimateOpen / Dragging / Keybind / Mobile
│   └── CreateTab
├── Tab Class
│   ├── BuildContainer
│   ├── CreateButton
│   ├── CreateToggle
│   ├── CreateSlider
│   ├── CreateDropdown
│   ├── CreateLabel
│   └── CreateSeparator
└── Module Exports
```

- All UI instances use `UIListLayout` for auto-positioning
- No hardcoded pixel positions — fully responsive out of the box
- Clean OOP via metatables

---

## License

MIT License — see [LICENSE](LICENSE).

---

*Built with Lua (Roblox Luau). No external dependencies.*
