--[[
    UUI - UU's UI Library
    Version: 1.0.0
    Modern, lightweight, highly customizable UI framework for Roblox
]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--[[
    THEME
]]
local Theme = {
    Background = Color3.fromRGB(18, 18, 24),
    BackgroundAlt = Color3.fromRGB(22, 22, 32),
    Surface = Color3.fromRGB(28, 28, 38),
    SurfaceLight = Color3.fromRGB(34, 34, 46),
    Element = Color3.fromRGB(38, 38, 50),
    ElementLight = Color3.fromRGB(42, 42, 56),
    ElementHover = Color3.fromRGB(52, 52, 68),
    Accent = Color3.fromRGB(100, 130, 255),
    AccentHover = Color3.fromRGB(130, 155, 255),
    Text = Color3.fromRGB(235, 235, 245),
    TextDim = Color3.fromRGB(155, 155, 170),
    TextMuted = Color3.fromRGB(110, 110, 130),
    Danger = Color3.fromRGB(255, 75, 75),
    Success = Color3.fromRGB(75, 200, 120),
    Warning = Color3.fromRGB(255, 195, 60),
    Shadow = Color3.fromRGB(0, 0, 0),
    Overlay = Color3.fromRGB(0, 0, 0),
    ToggleOff = Color3.fromRGB(55, 55, 70),
    ToggleOn = Color3.fromRGB(100, 130, 255),
    ScrollBar = Color3.fromRGB(55, 55, 70),
    Stroke = Color3.fromRGB(50, 50, 65),
    Glow = Color3.fromRGB(120, 145, 255),
}

--[[
    TWEEN PRESETS
]]
local TweenPresets = {
    Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Gentle = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Slide = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Linear = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
}

--[[
    UTILITY FUNCTIONS
]]
local function Create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function Clamp(v, mn, mx)
    return math.max(mn, math.min(mx, v))
end

local function AddShadow(parent, transparency)
    return Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageTransparency = transparency or 0.65,
        ImageColor3 = Theme.Shadow,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 23, 23),
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = parent,
    })
end

local function AddGradient(frame, from, to, rotation)
    return Create("UIGradient", {
        Color = ColorSequence.new(from or Theme.Background, to or Theme.BackgroundAlt),
        Rotation = rotation or 90,
        Parent = frame,
    })
end

local function AddCorner(frame, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = frame,
    })
end

local function AddStroke(frame, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0.85,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = frame,
    })
end

local function MakeTextLabel(text, size, font, textSize, color, align)
    return Create("TextLabel", {
        Text = text or "",
        Size = size or UDim2.new(0, 100, 0, 20),
        BackgroundTransparency = 1,
        Font = font or Enum.Font.Gotham,
        TextSize = textSize or 14,
        TextColor3 = color or Theme.Text,
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        RichText = true,
    })
end

-- Lighten a color by a small amount
local function LightenColor(c, amount)
    return Color3.new(
        Clamp(c.R + amount, 0, 1),
        Clamp(c.G + amount, 0, 1),
        Clamp(c.B + amount, 0, 1)
    )
end

-- Darken a color by a small amount
local function DarkenColor(c, amount)
    return Color3.new(
        Clamp(c.R - amount, 0, 1),
        Clamp(c.G - amount, 0, 1),
        Clamp(c.B - amount, 0, 1)
    )
end

--[[
    NOTIFICATION SYSTEM
]]
local NotifyFn
do
    local Queue = {}
    local Active = false
    local Container = nil
    local MaxVisible = 4

    local function GetContainer()
        if not Container or not Container.Parent then
            Container = Create("ScreenGui", {
                Name = "UUI_Notifications",
                DisplayOrder = 999,
                IgnoreGuiInset = true,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                Parent = CoreGui,
            })
        end
        return Container
    end

    local function ShowNext()
        if #Queue == 0 then
            Active = false
            return
        end
        Active = true
        local config = table.remove(Queue, 1)
        ShowNotification(config)
    end

    local function ShowNotification(config)
        local container = GetContainer()
        local duration = config.Duration or 4

        local accentColor = Theme.Accent
        if config.Type == "success" then
            accentColor = Theme.Success
        elseif config.Type == "error" then
            accentColor = Theme.Danger
        elseif config.Type == "warning" then
            accentColor = Theme.Warning
        end

        -- Count visible notifications for stacking
        local offset = 0
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("Frame") and child.Name == "NotificationHolder" then
                offset = offset + 1
            end
        end

        if offset >= MaxVisible then
            table.insert(Queue, config)
            Active = false
            ShowNext()
            return
        end

        local holder = Create("Frame", {
            Name = "NotificationHolder",
            Size = UDim2.new(0, 360, 0, 0),
            Position = UDim2.new(1, -16, 1, -16 - (offset * 82)),
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            Parent = container,
        })

        local frame = Create("Frame", {
            Name = "Notification",
            Size = UDim2.new(0, 360, 0, 0),
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = holder,
        })
        AddCorner(frame, 10)
        AddStroke(frame, Theme.Stroke, 1, 0.8)
        AddGradient(frame, Theme.Surface, LightenColor(Theme.Surface, 0.02), 90)

        local accentBar = Create("Frame", {
            Name = "AccentBar",
            Size = UDim2.new(0, 4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = frame,
        })
        AddCorner(accentBar, 2)

        Create("UIPadding", {
            PaddingTop = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 18),
            PaddingRight = UDim.new(0, 14),
            Parent = frame,
        })

        local title = MakeTextLabel(config.Title or "Notification", UDim2.new(1, -32, 0, 18), Enum.Font.GothamSemibold, 15, Theme.Text, Enum.TextXAlignment.Left)
        title.Position = UDim2.new(0, 8, 0, 0)
        title.Parent = frame

        local content = MakeTextLabel(config.Content or "", UDim2.new(1, -32, 0, 16), Enum.Font.Gotham, 13, Theme.TextDim, Enum.TextXAlignment.Left)
        content.Position = UDim2.new(0, 8, 0, 22)
        content.TextWrapped = true
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Parent = frame

        local closeBtn = Create("ImageButton", {
            Name = "Close",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -6, 0, 6),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7072725342",
            ImageColor3 = Theme.TextDim,
            ImageTransparency = 0.4,
            Parent = frame,
        })

        local progressBar = Create("Frame", {
            Name = "ProgressBar",
            Size = UDim2.new(1, -4, 0, 2),
            Position = UDim2.new(0, 2, 1, -4),
            BackgroundColor3 = accentColor,
            BackgroundTransparency = 0.5,
            Parent = frame,
        })
        AddCorner(progressBar, 1)

        local textHeight = content.TextBounds.Y
        local totalHeight = math.max(textHeight + 50, 64)

        -- Animate in
        local openTween = TweenService:Create(frame, TweenPresets.Smooth, {
            Size = UDim2.new(0, 360, 0, totalHeight),
            BackgroundTransparency = 0,
        })
        openTween:Play()

        task.wait(0.1)

        local progressTween = TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 2),
        })
        progressTween:Play()

        local dismissed = false
        local function Dismiss()
            if dismissed then return end
            dismissed = true
            if not frame or not frame.Parent then return end

            progressTween:Cancel()

            local closeTween = TweenService:Create(frame, TweenPresets.Quick, {
                Size = UDim2.new(0, 360, 0, 0),
                BackgroundTransparency = 1,
            })
            closeTween:Play()

            closeTween.Completed:Connect(function()
                holder:Destroy()
                ShowNext()
            end)
        end

        task.delay(duration, Dismiss)
        closeBtn.MouseButton1Click:Connect(Dismiss)

        if config.Callback then
            local clickDetector = Create("ImageButton", {
                Name = "ClickDetector",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Parent = frame,
            })
            clickDetector.MouseButton1Click:Connect(function()
                config.Callback()
                Dismiss()
            end)
        end
    end

    NotifyFn = function(config)
        table.insert(Queue, config)
        if not Active then
            ShowNext()
        end
    end
end

--[[
    WINDOW CLASS
]]
local WindowClass = {}
WindowClass.__index = WindowClass

function WindowClass.new(title, settings)
    local self = setmetatable({}, WindowClass)
    self.Title = title or "UUI"
    self.Settings = settings or {}
    self.Tabs = {}
    self.Visible = true
    self.Size = self.Settings.Size or Vector2.new(560, 440)

    -- Keybind
    local kb = self.Settings.Keybind
    if type(kb) == "string" then
        kb = Enum.KeyCode[kb]
    end
    self.Keybind = kb or Enum.KeyCode.RightControl

    -- Main GUI
    self.Gui = Create("ScreenGui", {
        Name = "UUI_" .. self.Title:gsub("%s+", "_"),
        DisplayOrder = 100,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })

    -- Overlay
    self.Overlay = Create("Frame", {
        Name = "Overlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Overlay,
        BackgroundTransparency = 1,
        Parent = self.Gui,
    })

    -- Main window frame
    self.Frame = Create("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, self.Size.X, 0, self.Size.Y),
        Position = UDim2.new(0.5, -self.Size.X / 2, 0.5, -self.Size.Y / 2),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.Gui,
    })
    AddCorner(self.Frame, 12)
    AddStroke(self.Frame, Theme.Stroke, 1, 0.75)
    AddGradient(self.Frame, Theme.Background, Color3.fromRGB(22, 22, 32), 90)

    -- Subtle inner glow
    Create("Frame", {
        Name = "InnerGlow",
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = Color3.fromRGB(40, 40, 55),
        BackgroundTransparency = 0.96,
        Parent = self.Frame,
    })

    -- Titlebar
    self.Titlebar = Create("Frame", {
        Name = "Titlebar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0,
        Parent = self.Frame,
    })
    AddCorner(self.Titlebar, 12)
    AddGradient(self.Titlebar, Theme.Surface, Color3.fromRGB(32, 32, 45), 90)

    -- Mask bottom corners of titlebar
    local mask = Create("Frame", {
        Name = "CornerMask",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 1,
        Parent = self.Titlebar,
    })

    -- Title
    self.TitleLabel = MakeTextLabel(self.Title, UDim2.new(0, 200, 1, 0), Enum.Font.GothamSemibold, 16, Theme.Text, Enum.TextXAlignment.Left)
    self.TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    self.TitleLabel.Parent = self.Titlebar

    local subtitle = MakeTextLabel("by UU", UDim2.new(0, 60, 1, 0), Enum.Font.Gotham, 11, Theme.TextMuted, Enum.TextXAlignment.Left)
    subtitle.Position = UDim2.new(0, 0, 0, 0)
    subtitle.Parent = self.TitleLabel

    -- Window control buttons
    local btnFrame = Create("Frame", {
        Name = "WindowButtons",
        Size = UDim2.new(0, 64, 0, 26),
        Position = UDim2.new(1, -76, 0.5, -13),
        BackgroundTransparency = 1,
        Parent = self.Titlebar,
    })

    -- Minimize button
    local minBtn = Create("ImageButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.4,
        Parent = btnFrame,
    })
    AddCorner(minBtn, 7)
    local minIcon = MakeTextLabel("─", UDim2.new(1, 0, 1, 0), Enum.Font.Gotham, 18, Theme.Text, Enum.TextXAlignment.Center)
    minIcon.TextTransparency = 0.3
    minIcon.Parent = minBtn

    -- Close button
    local closeBtn = Create("ImageButton", {
        Name = "Close",
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -26, 0, 0),
        BackgroundColor3 = Theme.Danger,
        BackgroundTransparency = 0.35,
        Parent = btnFrame,
    })
    AddCorner(closeBtn, 7)
    local closeIcon = MakeTextLabel("×", UDim2.new(1, 0, 1, 0), Enum.Font.Gotham, 20, Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Center)
    closeIcon.TextTransparency = 0.2
    closeIcon.Parent = closeBtn

    -- Tab bar (left sidebar)
    self.TabBar = Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(0, 46, 1, 0),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.2,
        Parent = self.Frame,
    })

    -- Logo
    local logoArea = Create("Frame", {
        Name = "Logo",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Parent = self.TabBar,
    })
    local logoText = MakeTextLabel("U", UDim2.new(1, 0, 1, 0), Enum.Font.GothamBlack, 24, Theme.Accent, Enum.TextXAlignment.Center)
    logoText.TextTransparency = 0.1
    logoText.Parent = logoArea

    -- Tab buttons scrolling frame
    self.TabButtons = Create("ScrollingFrame", {
        Name = "TabButtons",
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.TabBar,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = self.TabButtons,
    })

    -- Tab content area
    self.TabContent = Create("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, -46, 1, 0),
        Position = UDim2.new(0, 46, 0, 0),
        BackgroundTransparency = 1,
        Parent = self.Frame,
    })

    -- Separator
    Create("Frame", {
        Name = "Separator",
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(0, 46, 0, 0),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.6,
        Parent = self.Frame,
    })

    -- Window controls
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    minBtn.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)

    -- Button hover animations
    local function setupBtnHover(btn, isClose)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenPresets.Quick, {
                BackgroundTransparency = isClose and 0.15 or 0.2,
                Size = UDim2.new(0, 28, 0, 28),
                Position = isClose and UDim2.new(1, -28, 0, -1) or UDim2.new(0, -1, 0, -1),
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenPresets.Quick, {
                BackgroundTransparency = isClose and 0.35 or 0.4,
                Size = UDim2.new(0, 26, 0, 26),
                Position = isClose and UDim2.new(1, -26, 0, 0) or UDim2.new(0, 0, 0, 0),
            }):Play()
        end)
    end
    setupBtnHover(minBtn, false)
    setupBtnHover(closeBtn, true)

    -- Setup interactions
    self:DraggingSetup()
    self:KeybindSetup()
    self:MobileSetup()
    self:AnimateOpen()

    return self
end

function WindowClass:AnimateOpen()
    self.Overlay.BackgroundTransparency = 1
    self.Frame.BackgroundTransparency = 1
    self.Frame.Size = UDim2.new(0, self.Size.X * 0.92, 0, self.Size.Y * 0.92)
    self.Frame.Position = UDim2.new(0.5, -self.Size.X * 0.46, 0.5, -self.Size.Y * 0.46)

    task.wait(0.03)

    TweenService:Create(self.Frame, TweenPresets.Slide, {
        BackgroundTransparency = 0,
        Size = UDim2.new(0, self.Size.X, 0, self.Size.Y),
        Position = UDim2.new(0.5, -self.Size.X / 2, 0.5, -self.Size.Y / 2),
    }):Play()

    TweenService:Create(self.Overlay, TweenPresets.Gentle, {
        BackgroundTransparency = 0.55,
    }):Play()
end

function WindowClass:DraggingSetup()
    local dragging = false
    local dragStart
    local startPos

    self.Titlebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self.Titlebar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                self.Frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end

function WindowClass:KeybindSetup()
    self._keybindCon = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.Keybind then
            self:ToggleVisibility()
        end
    end)
end

function WindowClass:ToggleVisibility()
    if not self.Frame then return end

    if self.Visible then
        local tween = TweenService:Create(self.Frame, TweenPresets.Quick, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, self.Size.X * 0.92, 0, self.Size.Y * 0.92),
            Position = UDim2.new(0.5, -self.Size.X * 0.46, 0.5, -self.Size.Y * 0.46),
        })
        tween:Play()
        TweenService:Create(self.Overlay, TweenPresets.Quick, {
            BackgroundTransparency = 1,
        }):Play()
        tween.Completed:Connect(function()
            if self.Frame then
                self.Frame.Visible = false
            end
        end)
        self.Visible = false
    else
        self.Frame.Visible = true
        self.Frame.BackgroundTransparency = 1
        self.Frame.Size = UDim2.new(0, self.Size.X * 0.92, 0, self.Size.Y * 0.92)
        self.Frame.Position = UDim2.new(0.5, -self.Size.X * 0.46, 0.5, -self.Size.Y * 0.46)

        TweenService:Create(self.Frame, TweenPresets.Smooth, {
            BackgroundTransparency = 0,
            Size = UDim2.new(0, self.Size.X, 0, self.Size.Y),
            Position = UDim2.new(0.5, -self.Size.X / 2, 0.5, -self.Size.Y / 2),
        }):Play()
        TweenService:Create(self.Overlay, TweenPresets.Gentle, {
            BackgroundTransparency = 0.55,
        }):Play()
        self.Visible = true
    end
end

function WindowClass:Destroy()
    if self._destroyed then return end
    self._destroyed = true

    local tween = TweenService:Create(self.Frame, TweenPresets.Smooth, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, self.Size.X * 0.88, 0, self.Size.Y * 0.88),
        Position = UDim2.new(0.5, -self.Size.X * 0.44, 0.5, -self.Size.Y * 0.44),
    })
    tween:Play()
    TweenService:Create(self.Overlay, TweenPresets.Gentle, {
        BackgroundTransparency = 1,
    }):Play()

    if self._keybindCon then
        self._keybindCon:Disconnect()
    end
    if self._mobileCon then
        self._mobileCon:Disconnect()
    end

    tween.Completed:Connect(function()
        self.Gui:Destroy()
    end)
end

function WindowClass:MobileSetup()
    if not UserInputService.TouchEnabled then return end

    self._mobileCon = RunService.RenderStepped:Connect(function()
        if not self.Frame then return end
        local vs = workspace.CurrentCamera.ViewportSize
        local pos = self.Frame.AbsolutePosition
        local size = self.Frame.AbsoluteSize
        local padding = 8

        local newX = self.Frame.Position.X.Offset
        local newY = self.Frame.Position.Y.Offset

        if pos.X < padding then
            newX = padding
        end
        if pos.Y < padding then
            newY = padding
        end
        if pos.X + size.X > vs.X - padding then
            newX = vs.X - size.X - padding
        end
        if pos.Y + size.Y > vs.Y - padding then
            newY = vs.Y - size.Y - padding
        end

        if newX ~= self.Frame.Position.X.Offset or newY ~= self.Frame.Position.Y.Offset then
            self.Frame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

function WindowClass:CreateTab(name)
    local tab = TabClass.new(self, name)
    table.insert(self.Tabs, tab)

    if #self.Tabs == 1 then
        tab:Select()
    end

    return tab
end

--[[
    TAB CLASS
]]
local TabClass = {}
TabClass.__index = TabClass

function TabClass.new(window, name)
    local self = setmetatable({}, TabClass)
    self.Window = window
    self.Name = name
    self.Elements = {}
    self.Selected = false

    local shortName = name:sub(1, 1):upper()

    -- Tab button
    self.Button = Create("ImageButton", {
        Name = name,
        Size = UDim2.new(1, -8, 0, 36),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 1,
        Parent = window.TabButtons,
    })
    AddCorner(self.Button, 9)

    -- Icon (first letter)
    local iconLabel = MakeTextLabel(shortName, UDim2.new(0, 18, 1, 0), Enum.Font.GothamSemibold, 13, Theme.TextDim, Enum.TextXAlignment.Center)
    iconLabel.Position = UDim2.new(0, 0, 0, 0)
    iconLabel.Parent = self.Button

    -- Indicator
    self.Indicator = Create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Parent = self.Button,
    })
    AddCorner(self.Indicator, 2)

    -- Content frame (visible toggled for tab transitions)
    self.Container = Create("Frame", {
        Name = name .. "_Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = window.TabContent,
    })

    -- Scrolling frame for elements
    self.Scrolling = Create("ScrollingFrame", {
        Name = "ElementList",
        Size = UDim2.new(1, -16, 1, -14),
        Position = UDim2.new(0, 8, 0, 7),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.ScrollBar,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Container,
    })

    Create("UIListLayout", {
        Name = "ElementLayout",
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Scrolling,
    })

    -- Hover
    self.Button.MouseEnter:Connect(function()
        if not self.Selected then
            TweenService:Create(self.Button, TweenPresets.Quick, {
                BackgroundTransparency = 0.85,
            }):Play()
            TweenService:Create(iconLabel, TweenPresets.Quick, {
                TextColor3 = Theme.Text,
            }):Play()
        end
    end)

    self.Button.MouseLeave:Connect(function()
        if not self.Selected then
            TweenService:Create(self.Button, TweenPresets.Quick, {
                BackgroundTransparency = 1,
            }):Play()
            TweenService:Create(iconLabel, TweenPresets.Quick, {
                TextColor3 = Theme.TextDim,
            }):Play()
        end
    end)

    self.Button.MouseButton1Click:Connect(function()
        self:Select()
    end)

    return self
end

function TabClass:Select()
    if self.Selected then return end

    for _, tab in ipairs(self.Window.Tabs) do
        if tab.Selected then
            tab.Selected = false

            TweenService:Create(tab.Button, TweenPresets.Quick, {
                BackgroundTransparency = 1,
            }):Play()
            TweenService:Create(tab.Indicator, TweenPresets.Quick, {
                Size = UDim2.new(0, 3, 0, 0),
                BackgroundTransparency = 1,
            }):Play()

            for _, child in ipairs(tab.Button:GetChildren()) do
                if child:IsA("TextLabel") then
                    TweenService:Create(child, TweenPresets.Quick, {
                        TextColor3 = Theme.TextDim,
                    }):Play()
                    break
                end
            end

            -- Hide content with delay for smooth transition feel
            if tab.Container then
                task.delay(0.12, function()
                    if tab.Container then
                        tab.Container.Visible = false
                    end
                end)
            end
        end
    end

    self.Selected = true

    -- Animate indicator
    self.Indicator.BackgroundTransparency = 1
    self.Indicator.Size = UDim2.new(0, 3, 0, 0)
    TweenService:Create(self.Indicator, TweenPresets.Spring, {
        Size = UDim2.new(0, 3, 0, 20),
        BackgroundTransparency = 0,
    }):Play()

    -- Highlight button
    TweenService:Create(self.Button, TweenPresets.Quick, {
        BackgroundTransparency = 0.88,
    }):Play()

    for _, child in ipairs(self.Button:GetChildren()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenPresets.Quick, {
                TextColor3 = Theme.Accent,
            }):Play()
            break
        end
    end

    -- Show content
    if self.Container then
        self.Container.Visible = true
    end
end

-- Element container builder
function TabClass:BuildContainer(height)
    local frame = Create("Frame", {
        Name = "Element",
        Size = UDim2.new(1, 0, 0, height or 38),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.25,
        Parent = self.Scrolling,
    })
    AddCorner(frame, 9)
    AddStroke(frame, Theme.Stroke, 1, 0.82)
    AddGradient(frame, Theme.Element, LightenColor(Theme.Element, 0.02), 90)

    return frame
end

--[[
    BUTTON ELEMENT
]]
function TabClass:CreateButton(text, callback)
    local container = self:BuildContainer(38)
    container.ClipsDescendants = false

    local hover = Create("Frame", {
        Name = "Hover",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Parent = container,
    })
    AddCorner(hover, 9)

    local label = MakeTextLabel(text, UDim2.new(1, -42, 1, 0), Enum.Font.Gotham, 14, Theme.Text, Enum.TextXAlignment.Left)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.Parent = container

    local arrow = MakeTextLabel("→", UDim2.new(0, 24, 1, 0), Enum.Font.Gotham, 16, Theme.Accent, Enum.TextXAlignment.Center)
    arrow.Position = UDim2.new(1, -32, 0, 0)
    arrow.TextTransparency = 0.4
    arrow.Parent = container

    local click = Create("ImageButton", {
        Name = "ClickArea",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = container,
    })

    click.MouseButton1Click:Connect(function()
        if callback then
            local ok, err = pcall(callback)
            if not ok then
                warn("UUI Button callback error:", err)
            end
        end

        local flash = TweenService:Create(container, TweenPresets.Quick, {
            BackgroundTransparency = 0.5,
        })
        flash:Play()
        flash.Completed:Connect(function()
            TweenService:Create(container, TweenPresets.Quick, {
                BackgroundTransparency = 0.25,
            }):Play()
        end)
    end)

    click.MouseEnter:Connect(function()
        TweenService:Create(hover, TweenPresets.Quick, {
            BackgroundTransparency = 0.92,
        }):Play()
        TweenService:Create(label, TweenPresets.Quick, {
            TextColor3 = Theme.AccentHover,
        }):Play()
        TweenService:Create(arrow, TweenPresets.Quick, {
            TextTransparency = 0.1,
            Position = UDim2.new(1, -30, 0, 0),
        }):Play()
        TweenService:Create(container, TweenPresets.Quick, {
            Size = UDim2.new(1, 4, 0, 38),
            Position = UDim2.new(0, -2, 0, 0),
        }):Play()
    end)

    click.MouseLeave:Connect(function()
        TweenService:Create(hover, TweenPresets.Quick, {
            BackgroundTransparency = 1,
        }):Play()
        TweenService:Create(label, TweenPresets.Quick, {
            TextColor3 = Theme.Text,
        }):Play()
        TweenService:Create(arrow, TweenPresets.Quick, {
            TextTransparency = 0.4,
            Position = UDim2.new(1, -32, 0, 0),
        }):Play()
        TweenService:Create(container, TweenPresets.Quick, {
            Size = UDim2.new(1, 0, 0, 38),
            Position = UDim2.new(0, 0, 0, 0),
        }):Play()
    end)

    local element = {
        Type = "Button",
        Text = text,
        Object = container,
        UpdateText = function(newText)
            label.Text = newText
        end,
        Destroy = function()
            container:Destroy()
        end,
    }

    table.insert(self.Elements, element)
    return element
end

--[[
    TOGGLE ELEMENT
]]
function TabClass:CreateToggle(text, default, callback)
    local container = self:BuildContainer(40)
    container.ClipsDescendants = false

    local hover = Create("Frame", {
        Name = "Hover",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Parent = container,
    })
    AddCorner(hover, 9)

    local label = MakeTextLabel(text, UDim2.new(1, -74, 1, 0), Enum.Font.Gotham, 14, Theme.Text, Enum.TextXAlignment.Left)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.Parent = container

    -- Switch background
    local switchBg = Create("Frame", {
        Name = "SwitchBG",
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = Theme.ToggleOff,
        Parent = container,
    })
    AddCorner(switchBg, 12)

    -- Knob
    local knob = Create("Frame", {
        Name = "Knob",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Theme.Text,
        Parent = switchBg,
    })
    AddCorner(knob, 9)

    -- Knob shadow
    Create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageTransparency = 0.75,
        ImageColor3 = Theme.Shadow,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 23, 23),
        Size = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0, -3, 0, -3),
        ZIndex = knob.ZIndex - 1,
        Parent = knob,
    })

    -- Knob glow
    local knobGlow = Create("Frame", {
        Name = "KnobGlow",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, -3, 0.5, -12),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Parent = switchBg,
    })
    AddCorner(knobGlow, 12)

    local state = default or false

    local function SetState(newState, animate)
        state = newState
        if animate ~= false then
            if state then
                TweenService:Create(switchBg, TweenPresets.Smooth, {
                    BackgroundColor3 = Theme.ToggleOn,
                }):Play()
                TweenService:Create(knob, TweenPresets.Spring, {
                    Position = UDim2.new(0, 23, 0.5, -9),
                }):Play()
                TweenService:Create(knob, TweenPresets.Quick, {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                }):Play()
                TweenService:Create(knobGlow, TweenPresets.Quick, {
                    BackgroundTransparency = 0.85,
                }):Play()
            else
                TweenService:Create(switchBg, TweenPresets.Smooth, {
                    BackgroundColor3 = Theme.ToggleOff,
                }):Play()
                TweenService:Create(knob, TweenPresets.Spring, {
                    Position = UDim2.new(0, 3, 0.5, -9),
                }):Play()
                TweenService:Create(knob, TweenPresets.Quick, {
                    BackgroundColor3 = Theme.Text,
                }):Play()
                TweenService:Create(knobGlow, TweenPresets.Quick, {
                    BackgroundTransparency = 1,
                }):Play()
            end
        else
            switchBg.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
            knob.Position = state and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            knob.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Theme.Text
        end
    end

    if state then
        SetState(true, false)
    end

    local click = Create("ImageButton", {
        Name = "ClickArea",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = container,
    })

    click.MouseButton1Click:Connect(function()
        SetState(not state)
        if callback then
            callback(state)
        end
    end)

    click.MouseEnter:Connect(function()
        TweenService:Create(hover, TweenPresets.Quick, {
            BackgroundTransparency = 0.92,
        }):Play()
    end)

    click.MouseLeave:Connect(function()
        TweenService:Create(hover, TweenPresets.Quick, {
            BackgroundTransparency = 1,
        }):Play()
    end)

    local element = {
        Type = "Toggle",
        Text = text,
        Object = container,
        State = state,
        Set = SetState,
        Destroy = function()
            container:Destroy()
        end,
    }

    table.insert(self.Elements, element)
    return element
end

--[[
    SLIDER ELEMENT
]]
function TabClass:CreateSlider(text, min, max, default, callback, suffix)
    min = min or 0
    max = max or 100
    default = default or min
    suffix = suffix or ""

    if min >= max then
        max = min + 1
    end

    local container = self:BuildContainer(50)
    container.ClipsDescendants = false

    local hover = Create("Frame", {
        Name = "Hover",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Parent = container,
    })
    AddCorner(hover, 9)

    local label = MakeTextLabel(text, UDim2.new(0.65, -12, 0, 18), Enum.Font.Gotham, 14, Theme.Text, Enum.TextXAlignment.Left)
    label.Position = UDim2.new(0, 14, 0, 6)
    label.Parent = container

    local val = default
    local valLabel = MakeTextLabel(tostring(val) .. suffix, UDim2.new(0.35, -12, 0, 18), Enum.Font.Gotham, 13, Theme.Accent, Enum.TextXAlignment.Right)
    valLabel.Position = UDim2.new(0.65, 0, 0, 6)
    valLabel.Parent = container

    -- Track
    local track = Create("Frame", {
        Name = "Track",
        Size = UDim2.new(1, -28, 0, 4),
        Position = UDim2.new(0, 14, 0, 34),
        BackgroundColor3 = DarkenColor(Theme.Element, 0.04),
        Parent = container,
    })
    AddCorner(track, 2)

    -- Fill
    local fill = Create("Frame", {
        Name = "Fill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        Parent = track,
    })
    AddCorner(fill, 2)

    -- Knob
    local knob = Create("Frame", {
        Name = "Knob",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = Theme.Text,
        Parent = container,
    })
    AddCorner(knob, 8)

    -- Knob shadow
    Create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageTransparency = 0.7,
        ImageColor3 = Theme.Shadow,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 23, 23),
        Size = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0, -3, 0, -3),
        ZIndex = knob.ZIndex - 1,
        Parent = knob,
    })

    local range = max - min
    local currentValue = val
    local dragging = false

    local function UpdateSlider(inputPos)
        local tPos = track.AbsolutePosition.X
        local tSize = track.AbsoluteSize.X
        local mouseX = inputPos.X

        local ratio = Clamp((mouseX - tPos) / tSize, 0, 1)
        local newVal = min + ratio * range
        newVal = math.floor(newVal * 100 + 0.5) / 100

        currentValue = newVal
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, -8, 0.5, -8)
        valLabel.Text = tostring(newVal) .. suffix

        if callback then
            callback(newVal)
        end
    end

    local initRatio = range > 0 and (default - min) / range or 0
    fill.Size = UDim2.new(initRatio, 0, 1, 0)
    knob.Position = UDim2.new(initRatio, -8, 0.5, -8)

    local click = Create("ImageButton", {
        Name = "ClickArea",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = container,
    })

    local function StartDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
            TweenService:Create(knob, TweenPresets.Quick, {
                Size = UDim2.new(0, 20, 0, 20),
            }):Play()
        end
    end

    click.InputBegan:Connect(StartDrag)

    click.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            TweenService:Create(knob, TweenPresets.Quick, {
                Size = UDim2.new(0, 16, 0, 16),
            }):Play()
        end
    end)

    local inputCon = UserInputService.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                UpdateSlider(input)
            end
        end
    end)

    click.MouseEnter:Connect(function()
        TweenService:Create(hover, TweenPresets.Quick, {
            BackgroundTransparency = 0.92,
        }):Play()
        if not dragging then
            TweenService:Create(knob, TweenPresets.Quick, {
                Size = UDim2.new(0, 18, 0, 18),
            }):Play()
        end
    end)

    click.MouseLeave:Connect(function()
        TweenService:Create(hover, TweenPresets.Quick, {
            BackgroundTransparency = 1,
        }):Play()
        if not dragging then
            TweenService:Create(knob, TweenPresets.Quick, {
                Size = UDim2.new(0, 16, 0, 16),
            }):Play()
        end
    end)

    -- Cleanup
    container.Destroying:Connect(function()
        inputCon:Disconnect()
    end)

    local element = {
        Type = "Slider",
        Text = text,
        Object = container,
        Value = currentValue,
        SetValue = function(newVal)
            newVal = Clamp(newVal, min, max)
            currentValue = newVal
            local r = range > 0 and (newVal - min) / range or 0
            fill.Size = UDim2.new(r, 0, 1, 0)
            knob.Position = UDim2.new(r, -8, 0.5, -8)
            valLabel.Text = tostring(newVal) .. suffix
        end,
        Destroy = function()
            container:Destroy()
        end,
    }

    table.insert(self.Elements, element)
    return element
end

--[[
    DROPDOWN ELEMENT
]]
function TabClass:CreateDropdown(text, options, callback, default)
    options = options or {}

    local container = self:BuildContainer(40)
    container.ClipsDescendants = false

    local hover = Create("Frame", {
        Name = "Hover",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Parent = container,
    })
    AddCorner(hover, 9)

    local header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = container,
    })

    local label = MakeTextLabel(text, UDim2.new(1, -74, 1, 0), Enum.Font.Gotham, 14, Theme.Text, Enum.TextXAlignment.Left)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.Parent = header

    local selLabel = MakeTextLabel(default or options[1] or "Select...", UDim2.new(0, 120, 1, 0), Enum.Font.Gotham, 13, Theme.TextDim, Enum.TextXAlignment.Right)
    selLabel.Position = UDim2.new(1, -132, 0, 0)
    selLabel.Parent = header

    local arrow = MakeTextLabel("▾", UDim2.new(0, 20, 1, 0), Enum.Font.Gotham, 14, Theme.TextDim, Enum.TextXAlignment.Center)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.Parent = header

    -- Dropdown list
    local listFrame = Create("Frame", {
        Name = "DropdownList",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = container,
    })
    AddCorner(listFrame, 8)
    AddStroke(listFrame, Theme.Stroke, 1, 0.75)
    AddGradient(listFrame, Theme.Surface, LightenColor(Theme.Surface, 0.02), 90)

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        Parent = listFrame,
    })

    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = listFrame,
    })

    local open = false
    local currentValue = default or (options[1] or "")

    -- Create option buttons
    for _, opt in ipairs(options) do
        local optBtn = Create("TextButton", {
            Name = opt,
            Text = "  " .. opt,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = listFrame,
        })
        AddCorner(optBtn, 6)

        optBtn.MouseEnter:Connect(function()
            TweenService:Create(optBtn, TweenPresets.Quick, {
                BackgroundTransparency = 0.6,
            }):Play()
        end)

        optBtn.MouseLeave:Connect(function()
            TweenService:Create(optBtn, TweenPresets.Quick, {
                BackgroundTransparency = 1,
            }):Play()
        end)

        optBtn.MouseButton1Click:Connect(function()
            currentValue = opt
            selLabel.Text = opt

            TweenService:Create(listFrame, TweenPresets.Smooth, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
            }):Play()
            TweenService:Create(arrow, TweenPresets.Quick, {
                Rotation = 0,
                TextColor3 = Theme.TextDim,
            }):Play()
            container.Size = UDim2.new(1, 0, 0, 40)
            container.ClipsDescendants = false
            open = false

            if callback then
                callback(opt)
            end
        end)
    end

    local listHeight = #options * 32 + 8

    local click = Create("ImageButton", {
        Name = "ClickArea",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = header,
    })

    click.MouseButton1Click:Connect(function()
        if not open then
            container.ClipsDescendants = true
            container.Size = UDim2.new(1, 0, 0, 40 + listHeight + 4)

            TweenService:Create(listFrame, TweenPresets.Smooth, {
                Size = UDim2.new(1, 0, 0, listHeight),
                BackgroundTransparency = 0,
            }):Play()
            TweenService:Create(arrow, TweenPresets.Quick, {
                Rotation = 180,
                TextColor3 = Theme.Accent,
            }):Play()
            open = true
        else
            TweenService:Create(listFrame, TweenPresets.Smooth, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
            }):Play()
            TweenService:Create(arrow, TweenPresets.Quick, {
                Rotation = 0,
                TextColor3 = Theme.TextDim,
            }):Play()

            task.delay(0.3, function()
                if container and container.Parent then
                    container.Size = UDim2.new(1, 0, 0, 40)
                    container.ClipsDescendants = false
                end
            end)
            open = false
        end
    end)

    click.MouseEnter:Connect(function()
        TweenService:Create(hover, TweenPresets.Quick, {
            BackgroundTransparency = 0.92,
        }):Play()
    end)

    click.MouseLeave:Connect(function()
        TweenService:Create(hover, TweenPresets.Quick, {
            BackgroundTransparency = 1,
        }):Play()
    end)

    local element = {
        Type = "Dropdown",
        Text = text,
        Options = options,
        Object = container,
        Value = currentValue,
        SetValue = function(newVal)
            for _, opt in ipairs(options) do
                if opt == newVal then
                    currentValue = newVal
                    selLabel.Text = newVal
                    return
                end
            end
        end,
        Destroy = function()
            container:Destroy()
        end,
    }

    table.insert(self.Elements, element)
    return element
end

--[[
    LABEL ELEMENT
]]
function TabClass:CreateLabel(text)
    local label = MakeTextLabel(text, UDim2.new(1, -24, 0, 18), Enum.Font.Gotham, 12, Theme.TextMuted, Enum.TextXAlignment.Left)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.Parent = self.Scrolling

    local element = {
        Type = "Label",
        Text = text,
        Object = label,
        UpdateText = function(newText)
            label.Text = newText
        end,
        Destroy = function()
            label:Destroy()
        end,
    }

    table.insert(self.Elements, element)
    return element
end

--[[
    SEPARATOR ELEMENT
]]
function TabClass:CreateSeparator()
    local sep = Create("Frame", {
        Name = "Separator",
        Size = UDim2.new(1, -28, 0, 1),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.6,
        Parent = self.Scrolling,
    })

    local element = {
        Type = "Separator",
        Object = sep,
        Destroy = function()
            sep:Destroy()
        end,
    }

    table.insert(self.Elements, element)
    return element
end

--[[
    MAIN MODULE
]]
local UUIModule = {}

function UUIModule.CreateWindow(title, settings)
    return WindowClass.new(title, settings)
end

function UUIModule.Notify(config)
    NotifyFn(config)
end

function UUIModule.SetTheme(overrides)
    if type(overrides) ~= "table" then return end
    for k, v in pairs(overrides) do
        if Theme[k] ~= nil then
            Theme[k] = v
        end
    end
end

function UUIModule.GetTheme()
    local copy = {}
    for k, v in pairs(Theme) do
        copy[k] = v
    end
    return copy
end

-- Version info
UUIModule.Version = "1.0.0"
UUIModule.Name = "UUI - UU's UI Library"

return UUIModule
