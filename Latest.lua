-- promt by @mopscode
-- language: Lua, file: VantaUI.lua, target: Roblox (any executor, low-end safe)
-- v4.4: added Dropdown element (WindUI style)

local VantaUI = {}
VantaUI.__index = VantaUI

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

local THEME = {
    bg         = Color3.fromRGB(16, 16, 20),
    bg_alt     = Color3.fromRGB(22, 22, 28),
    sidebar    = Color3.fromRGB(12, 12, 16),
    border     = Color3.fromRGB(40, 40, 50),
    text       = Color3.fromRGB(232, 232, 238),
    text_dim   = Color3.fromRGB(142, 142, 154),
    text_mute  = Color3.fromRGB(90, 90, 102),
    accent     = Color3.fromRGB(120, 160, 255),
    accent_bg  = Color3.fromRGB(32, 44, 74),
    accent_dim = Color3.fromRGB(52, 78, 138),
    danger     = Color3.fromRGB(230, 80, 90),
    track      = Color3.fromRGB(42, 42, 52),
    shadow     = Color3.fromRGB(0, 0, 0),
    row        = Color3.fromRGB(24, 24, 30),
}

local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED  = Enum.Font.GothamMedium
local FONT_REG  = Enum.Font.Gotham

local function tween(obj, time, props)
    local ok = pcall(function()
        TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
    if not ok then for k, v in pairs(props) do obj[k] = v end end
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
        Color = color or THEME.border, Thickness = thick or 1,
        Transparency = trans or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

local function resolveParent()
    local gui = new("ScreenGui", {
        Name = "VantaUI_" .. tostring(math.random(100000, 999999)),
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, DisplayOrder = 9999,
    })
    if gethui then
        local ok = pcall(function() gui.Parent = gethui() end)
        if ok and gui.Parent then return gui end
    end
    local ok = pcall(function() gui.Parent = CoreGui end)
    if ok and gui.Parent then return gui end
    ok = pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
    if ok and gui.Parent then return gui end
    gui.Parent = CoreGui
    return gui
end

local function viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function draggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function confirmModal(gui, text, onYes)
    local overlay = new("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.shadow,
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 200,
    }, gui)
    tween(overlay, 0.12, { BackgroundTransparency = 0.5 })

    local box = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(280, 140), BackgroundColor3 = THEME.bg_alt,
        BorderSizePixel = 0, ZIndex = 201,
    }, overlay)
    corner(box, 10); stroke(box, THEME.border, 1, 0)

    new("TextLabel", {
        Size = UDim2.new(1, -24, 0, 24), Position = UDim2.fromOffset(14, 16),
        BackgroundTransparency = 1, Font = FONT_MED, Text = text,
        TextColor3 = THEME.text, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202,
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
        b.MouseButton1Click:Connect(function() overlay:Destroy(); if cb then cb() end end)
    end
    mkBtn("Нет", 0,   THEME.bg)
    mkBtn("Да",  0.5, THEME.danger, onYes)
end

function VantaUI:Window(cfg)
    cfg = cfg or {}
    local title = cfg.title or "VANTA UI"
    local vp    = viewport()

    local width  = math.min(cfg.width  or 720, vp.X - 40)
    local height = math.min(cfg.height or 420, vp.Y - 40)
    width  = math.max(width,  480)
    height = math.max(height, 300)

    local gui = resolveParent()
    local win = { tabs = {}, gui = gui, visible = true, width = width, height = height }

    local panel = new("Frame", {
        Name = "Panel",
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = THEME.bg, BorderSizePixel = 0, ClipsDescendants = true,
    }, gui)
    corner(panel, 10); stroke(panel, THEME.border, 1, 0)
    win.panel = panel

    local topbar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = THEME.bg_alt, BorderSizePixel = 0,
        ZIndex = 5,
    }, panel)
    corner(topbar, 10)
    
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = THEME.bg_alt, BorderSizePixel = 0, ZIndex = 6,
    }, topbar)

    new("Frame", {
        Position = UDim2.fromOffset(14, 15),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = THEME.accent, BorderSizePixel = 0,
        ZIndex = 7,
    }, topbar)

    new("TextLabel", {
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -120, 1, 0), BackgroundTransparency = 1,
        Font = FONT_BOLD, Text = title, TextColor3 = THEME.text,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 7,
    }, topbar)

    local function ctrlBtn(glyph, xOffset, hoverColor)
        local b = new("TextButton", {
            Position = UDim2.new(1, -xOffset, 0, 8),
            Size = UDim2.fromOffset(20, 20),
            BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
            Font = FONT_MED, Text = glyph, TextColor3 = THEME.text_dim,
            TextSize = 13, AutoButtonColor = false, ZIndex = 8,
        }, topbar)
        corner(b, 5)
        b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = hoverColor, TextColor3 = THEME.text }) end)
        b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = THEME.bg, TextColor3 = THEME.text_dim }) end)
        return b
    end
    local btnMin   = ctrlBtn("–", 32, THEME.accent_dim)
    local btnClose = ctrlBtn("×", 58, THEME.danger)

    local sidebar = new("Frame", {
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(0, 160, 1, -36),
        BackgroundColor3 = THEME.sidebar, BorderSizePixel = 0,
        ZIndex = 2,
    }, panel)
    
    new("Frame", {
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = THEME.border, BorderSizePixel = 0,
        ZIndex = 3,
    }, sidebar)

    local tabList = new("ScrollingFrame", {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
    }, sidebar)
    new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)

    local content = new("Frame", {
        Position = UDim2.new(0, 160, 0, 36),
        Size = UDim2.new(1, -160, 1, -36),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, panel)
    win.content = content

    draggable(panel, topbar)

    local minimized = false
    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(panel, 0.18, { Size = minimized and UDim2.fromOffset(width, 36) or UDim2.fromOffset(width, height) })
        sidebar.Visible = not minimized
        content.Visible = not minimized
    end)
    btnClose.MouseButton1Click:Connect(function()
        confirmModal(gui, "Точно закрыть окно?", function() gui:Destroy() end)
    end)

    function win:CreateTab(name)
        name = name or "tab"

        local btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = THEME.sidebar, BorderSizePixel = 0,
            Font = FONT_MED, Text = "  " .. name, TextColor3 = THEME.text_dim,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            ZIndex = 4,
        }, tabList)
        corner(btn, 6)

        local page = new("ScrollingFrame", {
            Size = UDim2.new(1, -16, 1, -16),
            Position = UDim2.fromOffset(8, 8),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 3,
        }, content)
        new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)

        local tab = { page = page, btn = btn, win = win, sections = {} }
        setmetatable(tab, win)

        local function activate()
            for _, t in ipairs(win.tabs) do
                t.page.Visible = false
                t.btn.BackgroundColor3 = THEME.sidebar
                t.btn.TextColor3 = THEME.text_dim
            end
            page.Visible = true
            btn.BackgroundColor3 = THEME.accent_bg
            btn.TextColor3 = THEME.text
        end

        btn.MouseButton1Click:Connect(activate)
        if #win.tabs == 0 then activate() end
        table.insert(win.tabs, tab)

        function tab:CreateSection(name)
            name = name or "Section"

            local wrap = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = THEME.bg_alt, BorderSizePixel = 0,
                ZIndex = 4,
            }, page)
            corner(wrap, 8)
            stroke(wrap, THEME.border, 1, 0.35)
            new("UIPadding", {
                PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
            }, wrap)
            new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)

            new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
                Font = FONT_BOLD, Text = string.upper(name),
                TextColor3 = THEME.text_mute, TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, wrap)

            local section = { frame = wrap, tab = tab, win = win }
            setmetatable(section, tab)
            table.insert(tab.sections, section)

            local function rowScaffold(label, height)
                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, height or 22),
                    BackgroundTransparency = 1,
                    ZIndex = 5,
                }, wrap)
                new("TextLabel", {
                    Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = label, TextColor3 = THEME.text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                }, row)
                return row
            end

            function section:CreateToggle(name, default, callback)
                local state = default or false
                local row = rowScaffold(name or "Toggle", 22)

                local track = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(30, 16),
                    BackgroundColor3 = THEME.track, BorderSizePixel = 0,
                    ZIndex = 6,
                }, row)
                corner(track, 8)
                local knob = new("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.fromOffset(12, 12),
                    BackgroundColor3 = THEME.text_dim, BorderSizePixel = 0,
                    ZIndex = 7,
                }, track)
                corner(knob, 6)

                local function render()
                    tween(track, 0.12, { BackgroundColor3 = state and THEME.accent_dim or THEME.track })
                    tween(knob, 0.12, {
                        Position = state and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                        BackgroundColor3 = state and THEME.accent or THEME.text_dim,
                    })
                end
                render()

                local click = new("TextButton", {
                    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
                    Text = "", AutoButtonColor = false, ZIndex = 8,
                }, row)
                click.MouseButton1Click:Connect(function()
                    state = not state; render()
                    if callback then callback(state) end
                end)
                return {
                    Set = function(_, v) state = v; render() end,
                    Get = function() return state end,
                }
            end

            function section:CreateButton(name, callback)
                local row = rowScaffold(name or "Button", 22)
                local b = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(90, 18),
                    BackgroundColor3 = THEME.row, BorderSizePixel = 0,
                    Font = FONT_MED, Text = "Нажать", TextColor3 = THEME.text_dim,
                    TextSize = 11, AutoButtonColor = false,
                    ZIndex = 6,
                }, row)
                corner(b, 4); stroke(b, THEME.border, 1, 0.4)
                b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = THEME.bg_alt, TextColor3 = THEME.text }) end)
                b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = THEME.row, TextColor3 = THEME.text_dim }) end)
                b.MouseButton1Click:Connect(function() if callback then callback() end end)
                return b
            end

            -- ДОБАВЛЕНО: Выпадающий список (Dropdown) в стиле WindUI
            function section:CreateDropdown(name, options, default, callback)
                options = options or {}
                local selected = default or options[1] or "Выбрать"
                local opened = false

                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
                    ZIndex = 5,
                }, wrap)
                
                new("TextLabel", {
                    Size = UDim2.new(1, -110, 0, 26), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = name or "Dropdown", TextColor3 = THEME.text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                }, row)

                local mainBtn = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 3),
                    Size = UDim2.fromOffset(100, 20),
                    BackgroundColor3 = THEME.row, BorderSizePixel = 0,
                    Font = FONT_MED, Text = tostring(selected) .. " ▾", TextColor3 = THEME.text_dim,
                    TextSize = 11, AutoButtonColor = false,
                    ZIndex = 6, ClipsDescendants = true,
                }, row)
                corner(mainBtn, 4); stroke(mainBtn, THEME.border, 1, 0.4)

                local listFrame = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
                    Visible = false, ZIndex = 50,
                }, win.gui) -- Создаем поверх окна, чтобы список не обрезался
                corner(listFrame, 6); stroke(listFrame, THEME.border, 1, 0)
                new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, listFrame)
                new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, listFrame)

                local function updateDropdownPos()
                    local absPos = mainBtn.AbsolutePosition
                    local absSize = mainBtn.AbsoluteSize
                    listFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 4)
                    listFrame.Size = UDim2.fromOffset(absSize.X, 0)
                end

                local function closeList()
                    if not opened then return end
                    opened = false
                    listFrame.Visible = false
                end

                local function openList()
                    if opened then return end
                    opened = true
                    updateDropdownPos()
                    listFrame.Visible = true
                end

                mainBtn.MouseButton1Click:Connect(function()
                    if opened then closeList() else openList() end
                end)

                -- Очистка и заполнение опций
                local function refreshOptions()
                    for _, child in ipairs(listFrame:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end

                    for _, opt in ipairs(options) do
                        local optBtn = new("TextButton", {
                            Size = UDim2.new(1, 0, 0, 20),
                            BackgroundColor3 = (opt == selected) and THEME.accent_bg or THEME.row,
                            BorderSizePixel = 0, Font = FONT_MED,
                            Text = tostring(opt), TextColor3 = (opt == selected) and THEME.text or THEME.text_dim,
                            TextSize = 11, AutoButtonColor = false, ZIndex = 51,
                        }, listFrame)
                        corner(optBtn, 4)

                        optBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            mainBtn.Text = tostring(selected) .. " ▾"
                            closeList()
                            if callback then callback(selected) end
                            refreshOptions()
                        end)
                    end
                end
                refreshOptions()

                return {
                    Set = function(_, v)
                        selected = v
                        mainBtn.Text = tostring(selected) .. " ▾"
                        refreshOptions()
                    end,
                    Get = function() return selected end,
                    Refresh = function(_, newOpts)
                        options = newOpts
                        refreshOptions()
                    end
                }
            end

            function section:CreateSlider(name, min, max, default, callback)
                min, max = min or 0, max or 100
                local step  = 1
                local value = default or min

                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1,
                    ZIndex = 5,
                }, wrap)
                new("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 14), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = name or "Slider", TextColor3 = THEME.text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                }, row)
                local valLbl = new("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.fromOffset(56, 14), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = tostring(value),
                    TextColor3 = THEME.accent, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 6,
                }, row)

                local bar = new("Frame", {
                    Position = UDim2.new(0, 0, 1, -10),
                    Size = UDim2.new(1, 0, 0, 4),
                    BackgroundColor3 = THEME.track, BorderSizePixel = 0,
                    ZIndex = 6,
                }, row)
                corner(bar, 2)
                local fill = new("Frame", {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = THEME.accent, BorderSizePixel = 0,
                    ZIndex = 7,
                }, bar)
                corner(fill, 2)
                local dot = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.fromOffset(8, 8),
                    BackgroundColor3 = THEME.text, BorderSizePixel = 0,
                    ZIndex = 8,
                }, bar)
                corner(dot, 4)

                local dragging = false
                local function setFromX(x)
                    local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
                    local raw = min + (max - min) * rel
                    value = math.floor(raw / step + 0.5) * step
                    value = math.clamp(value, min, max)
                    local r2 = (value - min) / math.max(max - min, 1e-6)
                    fill.Size = UDim2.new(r2, 0, 1, 0)
                    dot.Position = UDim2.new(r2, 0, 0.5, 0)
                    valLbl.Text = tostring(value)
                    if callback then callback(value) end
                end
                local function render()
                    local r2 = (value - min) / math.max(max - min, 1e-6)
                    fill.Size = UDim2.new(r2, 0, 1, 0)
                    dot.Position = UDim2.new(r2, 0, 0.5, 0)
                    valLbl.Text = tostring(value)
                end
                render()

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; setFromX(input.Position.X)
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

            return section
        end

        return tab
    end

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
