-- promt by @mopscode
-- language: Lua, file: VantaUI.lua, target: Roblox (any executor, low-end safe)
-- changes v2: player name in title, CoreGui→gethui→PlayerGui fallback chain,
-- resolution-safe scale, tab click guard, no external deps, no heavy tweens

local VantaUI = {}
VantaUI.__index = VantaUI

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer

-- promt by @mopscode — palette
local THEME = {
    bg         = Color3.fromRGB(16, 16, 20),
    bg_alt     = Color3.fromRGB(22, 22, 28),
    sidebar    = Color3.fromRGB(12, 12, 16),
    border     = Color3.fromRGB(40, 40, 50),
    text       = Color3.fromRGB(232, 232, 238),
    text_dim   = Color3.fromRGB(142, 142, 154),
    accent     = Color3.fromRGB(120, 160, 255),
    accent_dim = Color3.fromRGB(52, 78, 138),
    danger     = Color3.fromRGB(230, 80, 90),
    track      = Color3.fromRGB(42, 42, 52),
    shadow     = Color3.fromRGB(0, 0, 0),
    ok         = Color3.fromRGB(110, 200, 140),
}

local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED  = Enum.Font.GothamMedium
local FONT_REG  = Enum.Font.Gotham

-- promt by @mopscode — safe tween (skip if TweenService unavailable, just snap)
local function tween(obj, time, props)
    local ok = pcall(function()
        TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
    if not ok then
        for k, v in pairs(props) do obj[k] = v end
    end
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(obj, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, obj)
end

local function stroke(obj, color, thick, trans)
    return new("UIStroke", {
        Color = color or THEME.border,
        Thickness = thick or 1,
        Transparency = trans or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

-- promt by @mopscode — parent resolution across injectors (Synapse, Script-Ware, Krnl, Fluxus, Delta, AWP, Xeno, Solara, etc.)
local function resolveParent()
    local name = "VantaUI_" .. tostring(math.random(100000, 999999))
    local gui = new("ScreenGui", {
        Name = name,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 9999,
    })

    -- 1) gethui is the safest when present (avoids CoreGui detection)
    if gethui then
        local ok = pcall(function() gui.Parent = gethui() end)
        if ok and gui.Parent then return gui end
    end

    -- 2) CoreGui
    local ok = pcall(function() gui.Parent = CoreGui end)
    if ok and gui.Parent then return gui end

    -- 3) PlayerGui (works everywhere, may be visible to anticheat — acceptable floor)
    ok = pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
    if ok and gui.Parent then return gui end

    -- 4) last resort: first available of the above by direct assignment
    gui.Parent = CoreGui
    return gui
end

-- promt by @mopscode — resolution-aware sizing (never bigger than the viewport)
local function viewport()
    local cam = workspace.CurrentCamera
    if cam then return cam.ViewportSize end
    return Vector2.new(1280, 720)
end

-- promt by @mopscode — drag with viewport clamp
local function draggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- promt by @mopscode — confirm modal (centered, viewport-clamped)
local function confirmModal(gui, text, onYes)
    local overlay = new("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = THEME.shadow,
        BackgroundTransparency = 1,
        Text = "", AutoButtonColor = false, ZIndex = 200,
    }, gui)
    tween(overlay, 0.12, { BackgroundTransparency = 0.5 })

    local box = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(280, 140),
        BackgroundColor3 = THEME.bg_alt,
        BorderSizePixel = 0, ZIndex = 201,
    }, overlay)
    corner(box, 10)
    stroke(box, THEME.border, 1, 0)

    new("TextLabel", {
        Size = UDim2.new(1, -24, 0, 24),
        Position = UDim2.fromOffset(14, 16),
        BackgroundTransparency = 1,
        Font = FONT_MED, Text = text, TextColor3 = THEME.text,
        TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202,
    }, box)

    local function mkBtn(label, xScale, bg, cb)
        local b = new("TextButton", {
            Size = UDim2.new(0.5, -18, 0, 32),
            Position = UDim2.new(xScale, 12, 1, -48),
            BackgroundColor3 = bg, BorderSizePixel = 0,
            Font = FONT_MED, Text = label, TextColor3 = THEME.text,
            TextSize = 13, AutoButtonColor = false, ZIndex = 202,
        }, box)
        corner(b, 6)
        b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = bg:Lerp(Color3.new(1,1,1), 0.1) }) end)
        b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = bg }) end)
        b.MouseButton1Click:Connect(function()
            overlay:Destroy()
            if cb then cb() end
        end)
    end

    mkBtn("Нет", 0,   THEME.bg)
    mkBtn("Да",  0.5, THEME.danger, onYes)
end

-- promt by @mopscode — library entry
function VantaUI:Window(cfg)
    cfg = cfg or {}
    local title  = cfg.title or "VANTA"
    local vp     = viewport()

    -- promt by @mopscode — clamp window to viewport (weak PC / small screen safe)
    local width  = math.min(cfg.width  or 540, vp.X - 40)
    local height = math.min(cfg.height or 360, vp.Y - 40)
    width  = math.max(width,  360)
    height = math.max(height, 260)

    -- promt by @mopscode — player name tag (top-left, always shown)
    local playerName = LocalPlayer and LocalPlayer.Name or "player"
    local tag = string.format("%s · %s", title, playerName)

    local gui = resolveParent()

    local win = {}
    win.tabs     = {}
    win.gui      = gui
    win.visible  = true
    win.width    = width
    win.height   = height

    -- promt by @mopscode — main panel
    local panel = new("Frame", {
        Name = "Panel",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    corner(panel, 10)
    stroke(panel, THEME.border, 1, 0)
    win.panel = panel

    -- promt by @mopscode — title bar
    local titlebar = new("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = THEME.bg_alt,
        BorderSizePixel = 0,
    }, panel)
    corner(titlebar, 10)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = THEME.bg_alt, BorderSizePixel = 0,
        ZIndex = titlebar.ZIndex + 1,
    }, titlebar)

    -- accent dot
    new("Frame", {
        Position = UDim2.fromOffset(10, 14),
        Size = UDim2.fromOffset(6, 8),
        BackgroundColor3 = THEME.accent, BorderSizePixel = 0,
    }, titlebar)

    -- promt by @mopscode — title text with player name (top-left anchor)
    new("TextLabel", {
        Position = UDim2.fromOffset(22, 0),
        Size = UDim2.new(1, -110, 1, 0),
        BackgroundTransparency = 1,
        Font = FONT_BOLD,
        Text = tag,
        TextColor3 = THEME.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, titlebar)

    -- promt by @mopscode — controls
    local function ctrlBtn(glyph, xOffset, hoverColor)
        local b = new("TextButton", {
            Position = UDim2.new(1, -xOffset, 0, 8),
            Size = UDim2.fromOffset(20, 20),
            BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
            Font = FONT_MED, Text = glyph, TextColor3 = THEME.text_dim,
            TextSize = 13, AutoButtonColor = false, ZIndex = titlebar.ZIndex + 2,
        }, titlebar)
        corner(b, 5)
        b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = hoverColor, TextColor3 = THEME.text }) end)
        b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = THEME.bg, TextColor3 = THEME.text_dim }) end)
        return b
    end
    local btnMin   = ctrlBtn("–", 32, THEME.accent_dim)
    local btnClose = ctrlBtn("×", 58, THEME.danger)

    -- promt by @mopscode — body
    local body = new("Frame", {
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 1, -36),
        BackgroundTransparency = 1,
    }, panel)
    win.body = body

    local sidebar = new("Frame", {
        Size = UDim2.fromOffset(132, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        BackgroundColor3 = THEME.sidebar, BorderSizePixel = 0,
    }, body)
    new("Frame", {
        Size = UDim2.fromOffset(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = THEME.border, BorderSizePixel = 0,
    }, sidebar)

    local sidebarList = new("Frame", {
        Size = UDim2.new(1, 0, 1, -12),
        Position = UDim2.fromOffset(0, 6),
        BackgroundTransparency = 1,
    }, sidebar)
    new("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, sidebarList)

    local content = new("Frame", {
        Position = UDim2.fromOffset(132, 0),
        Size = UDim2.new(1, -132, 1, 0),
        BackgroundTransparency = 1,
    }, body)
    win.content = content

    -- promt by @mopscode — collapse / close
    local minimized = false
    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(panel, 0.18, { Size = minimized and UDim2.fromOffset(width, 36) or UDim2.fromOffset(width, height) })
        body.Visible = not minimized
    end)

    btnClose.MouseButton1Click:Connect(function()
        confirmModal(gui, "Точно закрыть окно?", function()
            gui:Destroy()
        end)
    end)

    draggable(panel, titlebar)

    -- promt by @mopscode — public: tab
    function win:Tab(tabCfg)
        tabCfg = tabCfg or {}
        local name = tabCfg.name or "tab"

        local btn = new("TextButton", {
            Size = UDim2.new(1, -8, 0, 26),
            BackgroundColor3 = THEME.sidebar, BorderSizePixel = 0,
            Font = FONT_MED, Text = "  " .. name, TextColor3 = THEME.text_dim,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
        }, sidebarList)
        corner(btn, 6)

        local page = new("ScrollingFrame", {
            Size = UDim2.new(1, -16, 1, -16),
            Position = UDim2.fromOffset(8, 8),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, content)
        new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)
        new("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingRight = UDim.new(0, 4) }, page)

        local tab = { __index = getmetatable(win).__index, page = page, btn = btn, win = win, groups = {} }

        local function activate()
            for _, t in ipairs(win.tabs) do
                t.page.Visible = false
                t.btn.BackgroundColor3 = THEME.sidebar
                t.btn.TextColor3 = THEME.text_dim
            end
            page.Visible = true
            btn.BackgroundColor3 = THEME.bg
            btn.TextColor3 = THEME.text
        end

        btn.MouseButton1Click:Connect(activate)
        if #win.tabs == 0 then activate() end
        table.insert(win.tabs, tab)

        -- promt by @mopscode — public: section
        function tab:Section(secCfg)
            secCfg = secCfg or {}
            local secName = secCfg.name or "Section"

            local wrap = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = THEME.bg_alt, BorderSizePixel = 0,
            }, page)
            corner(wrap, 8)
            stroke(wrap, THEME.border, 1, 0.3)
            new("UIPadding", {
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            }, wrap)
            new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)

            new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Font = FONT_BOLD, Text = secName,
                TextColor3 = THEME.text_dim, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, wrap)

            local section = { __index = getmetatable(tab).__index, frame = wrap, tab = tab, win = win }
            table.insert(tab.groups, section)

            -- promt by @mopscode — Toggle
            function section:Toggle(optCfg)
                optCfg = optCfg or {}
                local label = optCfg.name or "Toggle"
                local state = optCfg.default or false
                local cb    = optCfg.callback

                local row = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
                }, wrap)

                new("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = label, TextColor3 = THEME.text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                }, row)

                local track = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(34, 16),
                    BackgroundColor3 = THEME.track, BorderSizePixel = 0,
                }, row)
                corner(track, 8)

                local knob = new("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.fromOffset(12, 12),
                    BackgroundColor3 = THEME.text_dim, BorderSizePixel = 0,
                }, track)
                corner(knob, 6)

                local function render()
                    tween(track, 0.12, { BackgroundColor3 = state and THEME.accent_dim or THEME.track })
                    tween(knob,  0.12, {
                        Position = state and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                        BackgroundColor3 = state and THEME.accent or THEME.text_dim,
                    })
                end
                render()

                row.MouseButton1Click:Connect(function()
                    state = not state; render()
                    if cb then cb(state) end
                end)

                return {
                    Set = function(_, v) state = v; render() end,
                    Get = function() return state end,
                }
            end

            -- promt by @mopscode — Button
            function section:Button(optCfg)
                optCfg = optCfg or {}
                local label = optCfg.name or "Button"
                local cb    = optCfg.callback

                local b = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
                    Font = FONT_MED, Text = label, TextColor3 = THEME.text,
                    TextSize = 12, AutoButtonColor = false,
                }, wrap)
                corner(b, 6)
                stroke(b, THEME.border, 1, 0.4)
                b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = THEME.bg_alt }) end)
                b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = THEME.bg }) end)
                b.MouseButton1Click:Connect(function() if cb then cb() end end)
                return b
            end

            -- promt by @mopscode — Slider
            function section:Slider(optCfg)
                optCfg = optCfg or {}
                local label = optCfg.name or "Slider"
                local min   = optCfg.min or 0
                local max   = optCfg.max or 100
                local step  = optCfg.step or 1
                local value = optCfg.default or min
                local cb    = optCfg.callback

                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                }, wrap)

                new("TextLabel", {
                    Size = UDim2.new(1, -50, 0, 14), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = label, TextColor3 = THEME.text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                }, row)
                local valLbl = new("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.fromOffset(48, 14), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = tostring(value), TextColor3 = THEME.accent,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
                }, row)

                local bar = new("Frame", {
                    Position = UDim2.new(0, 0, 1, -12),
                    Size = UDim2.new(1, 0, 0, 6),
                    BackgroundColor3 = THEME.track, BorderSizePixel = 0,
                }, row)
                corner(bar, 3)

                local fill = new("Frame", {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = THEME.accent, BorderSizePixel = 0,
                }, bar)
                corner(fill, 3)

                local dragging = false

                local function setFromX(x)
                    local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
                    local raw = min + (max - min) * rel
                    value = math.floor(raw / step + 0.5) * step
                    value = math.clamp(value, min, max)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    valLbl.Text = tostring(value)
                    if cb then cb(value) end
                end

                local function render()
                    local rel = (value - min) / math.max(max - min, 1e-6)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    valLbl.Text = tostring(value)
                end
                render()

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        setFromX(input.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        setFromX(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                return {
                    Set = function(_, v) value = math.clamp(v, min, max); render() end,
                    Get = function() return value end,
                }
            end

            -- promt by @mopscode — Keybind
            function section:Keybind(optCfg)
                optCfg = optCfg or {}
                local label   = optCfg.name or "Keybind"
                local default = optCfg.default or Enum.KeyCode.E
                local cb      = optCfg.callback
                local current = default
                local listening = false

                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                }, wrap)

                new("TextLabel", {
                    Size = UDim2.new(1, -90, 1, 0), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = label, TextColor3 = THEME.text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                }, row)

                local keyBtn = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(84, 22),
                    BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
                    Font = FONT_MED, Text = current.Name, TextColor3 = THEME.text,
                    TextSize = 12, AutoButtonColor = false,
                }, row)
                corner(keyBtn, 6)
                stroke(keyBtn, THEME.border, 1, 0.4)

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    keyBtn.TextColor3 = THEME.accent
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe then return end
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        current = input.KeyCode
                        keyBtn.Text = current.Name
                        keyBtn.TextColor3 = THEME.text
                        listening = false
                    elseif not listening and input.KeyCode == current then
                        if cb then cb() end
                    end
                end)

                return {
                    Set = function(_, k) current = k; keyBtn.Text = k.Name end,
                    Get = function() return current end,
                }
            end

            -- promt by @mopscode — Textbox (added for completeness)
            function section:Textbox(optCfg)
                optCfg = optCfg or {}
                local label   = optCfg.name or "Input"
                local default = optCfg.default or ""
                local cb      = optCfg.callback

                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1,
                }, wrap)

                new("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = label, TextColor3 = THEME.text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                }, row)

                local box = new("TextBox", {
                    Position = UDim2.new(0, 0, 1, -20),
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
                    Font = FONT_REG, Text = default, PlaceholderText = "...",
                    TextColor3 = THEME.text, PlaceholderColor3 = THEME.text_dim,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                }, row)
                corner(box, 5)
                stroke(box, THEME.border, 1, 0.4)
                new("UIPadding", { PaddingLeft = UDim.new(0, 6) }, box)

                box.FocusLost:Connect(function(enter)
                    if cb then cb(box.Text, enter) end
                end)

                return {
                    Set = function(_, v) box.Text = v end,
                    Get = function() return box.Text end,
                }
            end

            return section
        end

        return tab
    end

    -- promt by @mopscode — global show/hide (RightShift)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            win.visible = not win.visible
            panel.Visible = win.visible
        end
    end)

    return setmetatable(win, win)
end

return VantaUI
