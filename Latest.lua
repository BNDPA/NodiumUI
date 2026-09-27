-- promt by @mopscode
-- language: Lua, file: NodiumUI.lua, target: Roblox (any executor, low-end safe)
-- layout: topbar tabs · subtitle pills · section cards · footer status+config
-- alwaysOnTop: window rendered above Roblox CoreUI (chat, topbar, notifications)

local NodiumUI = {}
NodiumUI.__index = NodiumUI

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

local THEME = {
    bg          = Color3.fromRGB(10, 10, 12),
    card        = Color3.fromRGB(18, 18, 22),
    row         = Color3.fromRGB(24, 24, 28),
    row_hover   = Color3.fromRGB(32, 32, 38),
    topbar      = Color3.fromRGB(10, 10, 12),
    footer      = Color3.fromRGB(10, 10, 12),
    border      = Color3.fromRGB(34, 34, 40),
    border_soft = Color3.fromRGB(26, 26, 32),
    text        = Color3.fromRGB(238, 238, 242),
    text_dim    = Color3.fromRGB(150, 150, 160),
    text_mute   = Color3.fromRGB(96, 96, 106),
    accent      = Color3.fromRGB(255, 108, 42),
    accent_dim  = Color3.fromRGB(120, 52, 22),
    danger      = Color3.fromRGB(230, 80, 90),
    ok          = Color3.fromRGB(110, 200, 140),
    track       = Color3.fromRGB(46, 46, 52),
    shadow      = Color3.fromRGB(0, 0, 0),
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

-- promt by @mopscode — parent resolution: gethui > CoreGui > PlayerGui
local function resolveParent()
    local gui = new("ScreenGui", {
        Name = "NodiumUI_" .. tostring(math.random(100000, 999999)),
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, DisplayOrder = 2147483647, -- top of everything
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

-- promt by @mopscode — kick CoreGui layers above Roblox's own (chat/topbar/notifications)
local function enforceOnTop(gui)
    pcall(function() gui.DisplayOrder = 2147483647 end)
    pcall(function() gui.IgnoreGuiInset = true end)
    -- some executors expose protect_gui / syn.protect_gui; call if present
    if protect_gui then pcall(protect_gui, gui) end
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
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
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local function confirmModal(gui, text, onYes)
    local overlay = new("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.shadow,
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 500,
    }, gui)
    tween(overlay, 0.12, { BackgroundTransparency = 0.4 })

    local box = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(300, 150), BackgroundColor3 = THEME.card,
        BorderSizePixel = 0, ZIndex = 501,
    }, overlay)
    corner(box, 12); stroke(box, THEME.border, 1, 0)

    new("TextLabel", {
        Size = UDim2.new(1, -28, 0, 22), Position = UDim2.fromOffset(16, 18),
        BackgroundTransparency = 1, Font = FONT_BOLD, Text = "Подтверждение",
        TextColor3 = THEME.text, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 502,
    }, box)
    new("TextLabel", {
        Size = UDim2.new(1, -28, 0, 20), Position = UDim2.fromOffset(16, 44),
        BackgroundTransparency = 1, Font = FONT_REG, Text = text,
        TextColor3 = THEME.text_dim, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 502,
    }, box)

    local function mkBtn(label, xScale, bg, fg, cb)
        local b = new("TextButton", {
            Size = UDim2.new(0.5, -20, 0, 34),
            Position = UDim2.new(xScale, 14, 1, -50),
            BackgroundColor3 = bg, BorderSizePixel = 0,
            Font = FONT_MED, Text = label, TextColor3 = fg,
            TextSize = 13, AutoButtonColor = false, ZIndex = 502,
        }, box)
        corner(b, 6)
        b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = bg:Lerp(Color3.new(1,1,1), 0.08) }) end)
        b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = bg }) end)
        b.MouseButton1Click:Connect(function() overlay:Destroy(); if cb then cb() end end)
    end
    mkBtn("Отмена", 0,   THEME.row, THEME.text)
    mkBtn("Да",     0.5, THEME.accent, Color3.fromRGB(20,20,20), onYes)
end

function NodiumUI:Window(cfg)
    cfg = cfg or {}
    local title      = cfg.title      or "NodiumUI"
    local subtitle   = cfg.subtitle   or "v1.0"
    local footerLeft = cfg.footerLeft or "Connected"
    local footerMid  = cfg.footerMid  or "MM2"
    local alwaysOnTop = (cfg.alwaysOnTop ~= false)
    local vp = viewport()

    local width  = math.min(cfg.width  or 860, vp.X - 40)
    local height = math.min(cfg.height or 520, vp.Y - 40)
    width  = math.max(width,  620)
    height = math.max(height, 380)

    local gui = resolveParent()
    if alwaysOnTop then enforceOnTop(gui) end
    local win = { tabs = {}, gui = gui, visible = true, width = width, height = height }

    local panel = new("Frame", {
        Name = "Panel",
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = THEME.bg, BorderSizePixel = 0, ClipsDescendants = true,
        ZIndex = 100,
    }, gui)
    corner(panel, 12); stroke(panel, THEME.border, 1, 0)
    win.panel = panel

    -- promt by @mopscode — if alwaysOnTop, re-raise the gui every frame in case something tries to overtake it
    if alwaysOnTop then
        RunService.RenderStepped:Connect(function()
            if gui.Parent then
                pcall(function() gui.DisplayOrder = 2147483647 end)
            end
        end)
    end

    local topbar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = THEME.topbar, BorderSizePixel = 0,
        ZIndex = 101,
    }, panel)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = THEME.border_soft, BorderSizePixel = 0, ZIndex = 101,
    }, topbar)

    local titleLbl = new("TextLabel", {
        Position = UDim2.fromOffset(18, 6),
        Size = UDim2.new(0, 240, 0, 24), BackgroundTransparency = 1,
        Font = FONT_BOLD, Text = title, TextColor3 = THEME.text,
        TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 102,
    }, topbar)
    local subLbl = new("TextLabel", {
        Position = UDim2.fromOffset(80, 28),
        Size = UDim2.new(0, 200, 0, 14), BackgroundTransparency = 1,
        Font = FONT_REG, Text = subtitle, TextColor3 = THEME.text_mute,
        TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102,
    }, topbar)
    task.defer(function()
        subLbl.Position = UDim2.new(0, 18 + titleLbl.TextBounds.X + 6, 0, 28)
    end)

    local tabsRow = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, width - 380, 1, 0), BackgroundTransparency = 1, ZIndex = 102,
    }, topbar)
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabsRow)

    local function ctrlBtn(glyph, xOffset, hoverColor)
        local b = new("TextButton", {
            Position = UDim2.new(1, -xOffset, 0.5, -13),
            Size = UDim2.fromOffset(26, 26),
            BackgroundColor3 = THEME.topbar, BorderSizePixel = 0,
            Font = FONT_MED, Text = glyph, TextColor3 = THEME.text_dim,
            TextSize = 14, AutoButtonColor = false, ZIndex = 103,
        }, topbar)
        corner(b, 6)
        b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = hoverColor, TextColor3 = THEME.text }) end)
        b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = THEME.topbar, TextColor3 = THEME.text_dim }) end)
        return b
    end
    ctrlBtn("?", 90, THEME.row)
    local btnMin   = ctrlBtn("–", 56, THEME.row)
    local btnClose = ctrlBtn("×", 22, THEME.danger)

    local body = new("Frame", {
        Position = UDim2.fromOffset(0, 46),
        Size = UDim2.new(1, 0, 1, -46 - 42),
        BackgroundTransparency = 1, ZIndex = 101,
    }, panel)

    local footer = new("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = THEME.footer, BorderSizePixel = 0, ZIndex = 101,
    }, panel)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = THEME.border_soft, BorderSizePixel = 0, ZIndex = 101,
    }, footer)

    local dot = new("Frame", {
        Position = UDim2.fromOffset(18, 17), Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = THEME.ok, BorderSizePixel = 0, ZIndex = 102,
    }, footer)
    corner(dot, 4)
    new("TextLabel", {
        Position = UDim2.fromOffset(34, 0), Size = UDim2.new(0, 160, 1, 0),
        BackgroundTransparency = 1, Font = FONT_MED, Text = footerLeft,
        TextColor3 = THEME.text_dim, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102,
    }, footer)
    new("TextLabel", {
        Position = UDim2.fromOffset(180, 0), Size = UDim2.new(0, 200, 1, 0),
        BackgroundTransparency = 1, Font = FONT_REG, Text = footerMid,
        TextColor3 = THEME.text_mute, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102,
    }, footer)

    local function footerBtn(label, xOffset, bg, fg, cb)
        local b = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -xOffset, 0.5, 0),
            Size = UDim2.fromOffset(110, 28),
            BackgroundColor3 = bg, BorderSizePixel = 0,
            Font = FONT_MED, Text = label, TextColor3 = fg,
            TextSize = 12, AutoButtonColor = false, ZIndex = 102,
        }, footer)
        corner(b, 6); stroke(b, THEME.border, 1, 0.4)
        b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = bg:Lerp(Color3.new(1,1,1), 0.08) }) end)
        b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = bg }) end)
        b.MouseButton1Click:Connect(function() if cb then cb() end end)
        return b
    end

    local nameBox = new("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -250, 0.5, 0),
        Size = UDim2.fromOffset(140, 28),
        BackgroundColor3 = THEME.row, BorderSizePixel = 0,
        Font = FONT_REG, Text = "Default", PlaceholderText = "Config name",
        TextColor3 = THEME.text, PlaceholderColor3 = THEME.text_mute,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false, ZIndex = 102,
    }, footer)
    corner(nameBox, 6); stroke(nameBox, THEME.border, 1, 0.4)
    new("UIPadding", { PaddingLeft = UDim.new(0, 10) }, nameBox)

    local btnReset = footerBtn("Reset",       146, THEME.row,    THEME.text_dim, cfg.onReset)
    local btnSave  = footerBtn("Save config", 22,  THEME.accent, Color3.fromRGB(20,20,20), cfg.onSave)
    win.btnSave = btnSave; win.btnReset = btnReset; win.nameBox = nameBox

    draggable(panel, topbar)

    local minimized = false
    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(panel, 0.18, { Size = minimized and UDim2.fromOffset(width, 46) or UDim2.fromOffset(width, height) })
        body.Visible = not minimized
        footer.Visible = not minimized
    end)
    btnClose.MouseButton1Click:Connect(function()
        confirmModal(gui, "Точно закрыть окно?", function() gui:Destroy() end)
    end)

    local pages = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 101 }, body)

    function win:CreateTab(name)
        name = name or "Tab"

        local btn = new("TextButton", {
            Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = THEME.topbar, BorderSizePixel = 0,
            Font = FONT_MED, Text = name, TextColor3 = THEME.text_dim,
            TextSize = 13, AutoButtonColor = false, ZIndex = 103,
        }, tabsRow)
        new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, btn)
        corner(btn, 6)

        local page = new("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 101,
        }, pages)

        local header = new("Frame", {
            Position = UDim2.fromOffset(18, 14),
            Size = UDim2.new(1, -36, 0, 40), BackgroundTransparency = 1, ZIndex = 101,
        }, page)
        new("TextLabel", {
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(0, 220, 1, 0), BackgroundTransparency = 1,
            Font = FONT_BOLD, Text = name, TextColor3 = THEME.text,
            TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102,
        }, header)

        local pillsRow = new("Frame", {
            Position = UDim2.fromOffset(230, 0),
            Size = UDim2.new(1, -230, 1, 0), BackgroundTransparency = 1, ZIndex = 102,
        }, header)
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
        }, pillsRow)

        local contentHolder = new("Frame", {
            Position = UDim2.fromOffset(18, 66),
            Size = UDim2.new(1, -36, 1, -66 - 14),
            BackgroundTransparency = 1, ZIndex = 101,
        }, page)

        local defaultContent = new("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 101,
        }, contentHolder)
        new("UIListLayout", {
            Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder,
        }, defaultContent)

        local function activatePage()
            for _, t in ipairs(win.tabs) do
                t.page.Visible = false
                t.btn.TextColor3 = THEME.text_dim
                t.btn.BackgroundColor3 = THEME.topbar
            end
            page.Visible = true
            btn.TextColor3 = THEME.text
            btn.BackgroundColor3 = THEME.row
        end
        btn.MouseButton1Click:Connect(activatePage)
        if #win.tabs == 0 then activatePage() end

        local tab = {
            __index = getmetatable(win).__index,
            page = page, btn = btn, win = win,
            subtabs = {}, holder = contentHolder,
            defaultContent = defaultContent,
            pillsRow = pillsRow, name = name,
        }
        table.insert(win.tabs, tab)

        function tab:CreateSubTab(subName, twoColumns)
            subName = subName or "Sub"

            local pill = new("TextButton", {
                Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = THEME.card, BorderSizePixel = 0,
                Font = FONT_MED, Text = subName, TextColor3 = THEME.text_dim,
                TextSize = 12, AutoButtonColor = false, ZIndex = 103,
            }, pillsRow)
            new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, pill)
            corner(pill, 6); stroke(pill, THEME.border_soft, 1, 0.5)

            local subContent = new("Frame", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 101,
            }, contentHolder)

            if twoColumns then
                new("UIGridLayout", {
                    CellSize = UDim2.new(0.5, -6, 0, 0),
                    CellPadding = UDim2.new(0, 12, 0, 12),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    FillDirectionMaxCells = 2,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                }, subContent)
            else
                new("UIListLayout", {
                    Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder,
                }, subContent)
            end

            local sub = {
                __index = getmetatable(tab).__index,
                frame = subContent, tab = tab, pill = pill,
                name = subName, twoColumns = twoColumns,
            }

            local function activateSub()
                for _, s in ipairs(tab.subtabs) do
                    s.frame.Visible = false
                    s.pill.BackgroundColor3 = THEME.card
                    s.pill.TextColor3 = THEME.text_dim
                end
                defaultContent.Visible = false
                subContent.Visible = true
                pill.BackgroundColor3 = THEME.row
                pill.TextColor3 = THEME.text
            end
            pill.MouseButton1Click:Connect(activateSub)
            if #tab.subtabs == 0 then activateSub() end
            table.insert(tab.subtabs, sub)

            function sub:CreateSection(secName)
                return NodiumUI._section(sub, secName or "Section")
            end
            return sub
        end

        function tab:CreateSection(secName)
            if #tab.subtabs > 0 then
                return NodiumUI._section(tab.subtabs[1], secName or "Section")
            end
            return NodiumUI._section(tab, secName or "Section")
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

-- promt by @mopscode — widget factory shared by tab and subtab
function NodiumUI._section(parent, secName)
    local hostFrame = parent.frame or parent.defaultContent

    local wrap = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = THEME.card, BorderSizePixel = 0, ZIndex = 102,
    }, hostFrame)
    corner(wrap, 10); stroke(wrap, THEME.border_soft, 1, 0.3)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
    }, wrap)
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)

    local head = new("Frame", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, ZIndex = 103,
    }, wrap)
    local ring = new("Frame", {
        Position = UDim2.fromOffset(0, 5),
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = THEME.accent_dim, BorderSizePixel = 0, ZIndex = 103,
    }, head)
    corner(ring, 4)
    new("TextLabel", {
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -14, 1, 0), BackgroundTransparency = 1,
        Font = FONT_BOLD, Text = string.upper(secName),
        TextColor3 = THEME.text_mute, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103,
    }, head)

    local section = { __index = getmetatable(parent).__index, frame = wrap, parent = parent }

    local function rowScaffold(label, height)
        local row = new("Frame", {
            Size = UDim2.new(1, 0, 0, height or 26),
            BackgroundTransparency = 1, ZIndex = 103,
        }, wrap)
        new("TextLabel", {
            Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1,
            Font = FONT_MED, Text = label, TextColor3 = THEME.text,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 104,
        }, row)
        return row
    end

    function section:CreateToggle(name, default, callback)
        local state = default or false
        local row = rowScaffold(name or "Toggle", 26)
        local track = new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(38, 20),
            BackgroundColor3 = THEME.track, BorderSizePixel = 0, ZIndex = 104,
        }, row)
        corner(track, 10)
        local knob = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            BackgroundColor3 = Color3.fromRGB(210, 210, 216), BorderSizePixel = 0, ZIndex = 105,
        }, track)
        corner(knob, 8)
        local function render()
            tween(track, 0.12, { BackgroundColor3 = state and THEME.accent or THEME.track })
            tween(knob, 0.12, {
                Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(210,210,216),
            })
        end
        render()
        local click = new("TextButton", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, ZIndex = 106,
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

    function section:CreateSlider(name, min, max, default, callback)
        min, max = min or 0, max or 100
        local step, value = 1, default or min

        local row = new("Frame", {
            Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, ZIndex = 103,
        }, wrap)
        new("TextLabel", {
            Size = UDim2.new(1, -110, 0, 16), BackgroundTransparency = 1,
            Font = FONT_MED, Text = name or "Slider", TextColor3 = THEME.text,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 104,
        }, row)

        local valueBox = new("Frame", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(56, 22),
            BackgroundColor3 = THEME.row, BorderSizePixel = 0, ZIndex = 104,
        }, row)
        corner(valueBox, 5); stroke(valueBox, THEME.border_soft, 1, 0.5)
        local valLbl = new("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Font = FONT_MED, Text = tostring(value), TextColor3 = THEME.text,
            TextSize = 12, ZIndex = 105,
        }, valueBox)

        local bar = new("Frame", {
            Position = UDim2.new(0, 0, 1, -8),
            Size = UDim2.new(1, -70, 0, 4),
            BackgroundColor3 = THEME.track, BorderSizePixel = 0, ZIndex = 104,
        }, row)
        corner(bar, 2)
        local fill = new("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = THEME.accent, BorderSizePixel = 0, ZIndex = 105,
        }, bar)
        corner(fill, 2)
        local dot = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(10, 10),
            BackgroundColor3 = Color3.fromRGB(240, 240, 245), BorderSizePixel = 0, ZIndex = 106,
        }, bar)
        corner(dot, 5)

        local dragging = false
        local function setFromX(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            local raw = min + (max - min) * rel
            value = math.clamp(math.floor(raw / step + 0.5) * step, min, max)
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
                setFromX(input.Position
