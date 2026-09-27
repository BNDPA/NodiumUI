-- promt by @mopscode
-- language: Lua, file: NodiumUI.lua, target: Roblox executor
-- topbar tabs, subtab pills, section cards, footer status; always-on-top

local NodiumUI = {}
NodiumUI.__index = NodiumUI

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer

local C = {
    bg        = Color3.fromRGB(10, 10, 12),
    card      = Color3.fromRGB(18, 18, 22),
    row       = Color3.fromRGB(24, 24, 28),
    border    = Color3.fromRGB(34, 34, 40),
    border_s  = Color3.fromRGB(26, 26, 32),
    text      = Color3.fromRGB(238, 238, 242),
    text_dim  = Color3.fromRGB(150, 150, 160),
    text_mute = Color3.fromRGB(96, 96, 106),
    accent    = Color3.fromRGB(255, 108, 42),
    accent_d  = Color3.fromRGB(120, 52, 22),
    danger    = Color3.fromRGB(230, 80, 90),
    ok        = Color3.fromRGB(110, 200, 140),
    track     = Color3.fromRGB(46, 46, 52),
    shadow    = Color3.fromRGB(0, 0, 0),
}
local FB = Enum.Font.GothamBold
local FM = Enum.Font.GothamMedium
local FR = Enum.Font.Gotham

local function tw(o, t, p)
    pcall(function()
        TweenService:Create(o, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
    end)
end

local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function rnd(o, r) return mk("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o) end
local function strk(o, col, th, tr)
    return mk("UIStroke", { Color = col or C.border, Thickness = th or 1,
        Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o)
end

local function resolveGui()
    local g = mk("ScreenGui", {
        Name = "NodiumUI_" .. tostring(math.random(100000, 999999)),
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, DisplayOrder = 2147483647,
    })
    if gethui then
        local ok = pcall(function() g.Parent = gethui() end)
        if ok and g.Parent then return g end
    end
    local ok = pcall(function() g.Parent = CoreGui end)
    if ok and g.Parent then return g end
    ok = pcall(function() g.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
    if ok and g.Parent then return g end
    g.Parent = CoreGui
    return g
end

local function vpsize()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function drag(frame, handle)
    handle = handle or frame
    local d, s, p
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; s = i.Position; p = frame.Position
            local c
            c = i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then d = false; if c then c:Disconnect() end end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local dd = i.Position - s
            frame.Position = UDim2.new(p.X.Scale, p.X.Offset + dd.X, p.Y.Scale, p.Y.Offset + dd.Y)
        end
    end)
end

function NodiumUI:Window(cfg)
    cfg = cfg or {}
    local title = cfg.title or "NodiumUI"
    local sub   = cfg.subtitle or "v1.0"
    local fl    = cfg.footerLeft or "Connected"
    local fm    = cfg.footerMid  or "MM2"
    local top   = (cfg.alwaysOnTop ~= false)

    local vp = vpsize()
    local w = math.max(math.min(cfg.width  or 860, vp.X - 40), 620)
    local h = math.max(math.min(cfg.height or 520, vp.Y - 40), 380)

    local gui = resolveGui()
    if top and protect_gui then pcall(protect_gui, gui) end

    local win = { tabs = {}, gui = gui, visible = true, w = w, h = h }

    local panel = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(w, h), BackgroundColor3 = C.bg,
        BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 100,
    }, gui)
    rnd(panel, 12); strk(panel, C.border, 1, 0)
    win.panel = panel

    if top then
        RunService.RenderStepped:Connect(function()
            pcall(function() gui.DisplayOrder = 2147483647 end)
        end)
    end

    local topbar = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = C.bg, BorderSizePixel = 0, ZIndex = 101,
    }, panel)
    mk("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.border_s, BorderSizePixel = 0, ZIndex = 101 }, topbar)

    local tLbl = mk("TextLabel", {
        Position = UDim2.fromOffset(18, 6), Size = UDim2.new(0, 240, 0, 24),
        BackgroundTransparency = 1, Font = FB, Text = title, TextColor3 = C.text,
        TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 102,
    }, topbar)
    local sLbl = mk("TextLabel", {
        Position = UDim2.fromOffset(80, 28), Size = UDim2.new(0, 200, 0, 14),
        BackgroundTransparency = 1, Font = FR, Text = sub, TextColor3 = C.text_mute,
        TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102,
    }, topbar)
    task.defer(function()
        sLbl.Position = UDim2.new(0, 18 + tLbl.TextBounds.X + 6, 0, 28)
    end)

    local tabsRow = mk("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, w - 380, 1, 0), BackgroundTransparency = 1, ZIndex = 102,
    }, topbar)
    mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tabsRow)

    local function ctrl(glyph, x, hov)
        local b = mk("TextButton", {
            Position = UDim2.new(1, -x, 0.5, -13), Size = UDim2.fromOffset(26, 26),
            BackgroundColor3 = C.bg, BorderSizePixel = 0, Font = FM, Text = glyph,
            TextColor3 = C.text_dim, TextSize = 14, AutoButtonColor = false, ZIndex = 103,
        }, topbar)
        rnd(b, 6)
        b.MouseEnter:Connect(function() tw(b, 0.1, { BackgroundColor3 = hov, TextColor3 = C.text }) end)
        b.MouseLeave:Connect(function() tw(b, 0.1, { BackgroundColor3 = C.bg, TextColor3 = C.text_dim }) end)
        return b
    end
    ctrl("?", 90, C.row)
    local btnMin = ctrl("-", 56, C.row)
    local btnX   = ctrl("x", 22, C.danger)

    local body = mk("Frame", {
        Position = UDim2.fromOffset(0, 46), Size = UDim2.new(1, 0, 1, -88),
        BackgroundTransparency = 1, ZIndex = 101,
    }, panel)

    local footer = mk("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = C.bg,
        BorderSizePixel = 0, ZIndex = 101,
    }, panel)
    mk("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.border_s,
        BorderSizePixel = 0, ZIndex = 101 }, footer)
    local dot = mk("Frame", { Position = UDim2.fromOffset(18, 17), Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = C.ok, BorderSizePixel = 0, ZIndex = 102 }, footer)
    rnd(dot, 4)
    mk("TextLabel", { Position = UDim2.fromOffset(34, 0), Size = UDim2.new(0, 160, 1, 0),
        BackgroundTransparency = 1, Font = FM, Text = fl, TextColor3 = C.text_dim,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102 }, footer)
    mk("TextLabel", { Position = UDim2.fromOffset(180, 0), Size = UDim2.new(0, 200, 1, 0),
        BackgroundTransparency = 1, Font = FR, Text = fm, TextColor3 = C.text_mute,
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102 }, footer)

    local function fbtn(label, x, bg, fg, cb)
        local b = mk("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -x, 0.5, 0),
            Size = UDim2.fromOffset(110, 28), BackgroundColor3 = bg, BorderSizePixel = 0,
            Font = FM, Text = label, TextColor3 = fg, TextSize = 12,
            AutoButtonColor = false, ZIndex = 102,
        }, footer)
        rnd(b, 6); strk(b, C.border, 1, 0.4)
        b.MouseButton1Click:Connect(function() if cb then cb() end end)
        return b
    end
    local nameBox = mk("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -250, 0.5, 0),
        Size = UDim2.fromOffset(140, 28), BackgroundColor3 = C.row, BorderSizePixel = 0,
        Font = FR, Text = "Default", PlaceholderText = "Config name", TextColor3 = C.text,
        PlaceholderColor3 = C.text_mute, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 102,
    }, footer)
    rnd(nameBox, 6); strk(nameBox, C.border, 1, 0.4)
    mk("UIPadding", { PaddingLeft = UDim.new(0, 10) }, nameBox)
    fbtn("Reset", 146, C.row, C.text_dim, cfg.onReset)
    fbtn("Save config", 22, C.accent, Color3.fromRGB(20,20,20), cfg.onSave)

    drag(panel, topbar)

    local mini = false
    btnMin.MouseButton1Click:Connect(function()
        mini = not mini
        tw(panel, 0.18, { Size = mini and UDim2.fromOffset(w, 46) or UDim2.fromOffset(w, h) })
        body.Visible = not mini
        footer.Visible = not mini
    end)
    btnX.MouseButton1Click:Connect(function()
        local ov = mk("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.shadow,
            BackgroundTransparency = 0.4, Text = "", AutoButtonColor = false, ZIndex = 500 }, gui)
        local bx = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(300, 150), BackgroundColor3 = C.card,
            BorderSizePixel = 0, ZIndex = 501 }, ov)
        rnd(bx, 12); strk(bx, C.border, 1, 0)
        mk("TextLabel", { Size = UDim2.new(1, -28, 0, 22), Position = UDim2.fromOffset(16, 18),
            BackgroundTransparency = 1, Font = FB, Text = "Подтверждение", TextColor3 = C.text,
            TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 502 }, bx)
        mk("TextLabel", { Size = UDim2.new(1, -28, 0, 20), Position = UDim2.fromOffset(16, 44),
            BackgroundTransparency = 1, Font = FR, Text = "Точно закрыть окно?", TextColor3 = C.text_dim,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 502 }, bx)
        local nb = mk("TextButton", { Size = UDim2.new(0.5, -20, 0, 34), Position = UDim2.new(0, 14, 1, -50),
            BackgroundColor3 = C.row, BorderSizePixel = 0, Font = FM, Text = "Отмена",
            TextColor3 = C.text, TextSize = 13, AutoButtonColor = false, ZIndex = 502 }, bx)
        rnd(nb, 6)
        nb.MouseButton1Click:Connect(function() ov:Destroy() end)
        local yb = mk("TextButton", { Size = UDim2.new(0.5, -20, 0, 34), Position = UDim2.new(0.5, 14, 1, -50),
            BackgroundColor3 = C.accent, BorderSizePixel = 0, Font = FM, Text = "Да",
            TextColor3 = Color3.fromRGB(20,20,20), TextSize = 13, AutoButtonColor = false, ZIndex = 502 }, bx)
        rnd(yb, 6)
        yb.MouseButton1Click:Connect(function() ov:Destroy(); gui:Destroy() end)
    end)

    local pages = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 101 }, body)

    function win:CreateTab(name)
        name = name or "Tab"
        local btn = mk("TextButton", {
            Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = C.bg, BorderSizePixel = 0, Font = FM, Text = name,
            TextColor3 = C.text_dim, TextSize = 13, AutoButtonColor = false, ZIndex = 103,
        }, tabsRow)
        mk("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, btn)
        rnd(btn, 6)

        local page = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Visible = false, ZIndex = 101 }, pages)
        local header = mk("Frame", { Position = UDim2.fromOffset(18, 14),
            Size = UDim2.new(1, -36, 0, 40), BackgroundTransparency = 1, ZIndex = 101 }, page)
        mk("TextLabel", { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(0, 220, 1, 0),
            BackgroundTransparency = 1, Font = FB, Text = name, TextColor3 = C.text,
            TextSize = 22, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102 }, header)
        local pills = mk("Frame", { Position = UDim2.fromOffset(230, 0),
            Size = UDim2.new(1, -230, 1, 0), BackgroundTransparency = 1, ZIndex = 102 }, header)
        mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, pills)
        local holder = mk("Frame", { Position = UDim2.fromOffset(18, 66),
            Size = UDim2.new(1, -36, 1, -80), BackgroundTransparency = 1, ZIndex = 101 }, page)
        local defContent = mk("Frame", { Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1, ZIndex = 101 }, holder)
        mk("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, defContent)

        local function act()
            for _, t in ipairs(win.tabs) do
                t.page.Visible = false; t.btn.TextColor3 = C.text_dim; t.btn.BackgroundColor3 = C.bg
            end
            page.Visible = true; btn.TextColor3 = C.text; btn.BackgroundColor3 = C.row
        end
        btn.MouseButton1Click:Connect(act)
        if #win.tabs == 0 then act() end

        local tab = { __index = getmetatable(win).__index, page = page, btn = btn,
            win = win, subtabs = {}, defContent = defContent, name = name }
        table.insert(win.tabs, tab)

        function tab:CreateSubTab(sname)
            sname = sname or "Sub"
            local pill = mk("TextButton", { Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = C.card, BorderSizePixel = 0, Font = FM, Text = sname,
                TextColor3 = C.text_dim, TextSize = 12, AutoButtonColor = false, ZIndex = 103 }, pills)
            mk("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, pill)
            rnd(pill, 6); strk(pill, C.border_s, 1, 0.5)
            local sc = mk("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
                Visible = false, ZIndex = 101 }, holder)
            mk("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, sc)
            local s = { __index = getmetatable(tab).__index, frame = sc, tab = tab, pill = pill, name = sname }
            local function as()
                for _, x in ipairs(tab.subtabs) do
                    x.frame.Visible = false; x.pill.BackgroundColor3 = C.card; x.pill.TextColor3 = C.text_dim
                end
                defContent.Visible = false; sc.Visible = true
                pill.BackgroundColor3 = C.row; pill.TextColor3 = C.text
            end
            pill.MouseButton1Click:Connect(as)
            if #tab.subtabs == 0 then as() end
            table.insert(tab.subtabs, s)
            function s:CreateSection(n) return NodiumUI._sec(s, n or "Section") end
            return s
        end

        function tab:CreateSection(n)
            if #tab.subtabs > 0 then return NodiumUI._sec(tab.subtabs[1], n or "Section") end
            return NodiumUI._sec(tab, n or "Section")
        end
        return tab
    end

    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            win.visible = not win.visible; panel.Visible = win.visible
        end
    end)
    return setmetatable(win, win)
end

function NodiumUI._sec(parent, secName)
    local host = parent.frame or parent.defContent
    local wrap = mk("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.card, BorderSizePixel = 0, ZIndex = 102 }, host)
    rnd(wrap, 10); strk(wrap, C.border_s, 1, 0.3)
    mk("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, wrap)
    mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)

    local head = mk("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, ZIndex = 103 }, wrap)
    local ring = mk("Frame", { Position = UDim2.fromOffset(0, 5), Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = C.accent_d, BorderSizePixel = 0, ZIndex = 103 }, head)
    rnd(ring, 4)
    mk("TextLabel", { Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -14, 1, 0),
        BackgroundTransparency = 1, Font = FB, Text = string.upper(secName),
        TextColor3 = C.text_mute, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103 }, head)

    local S = { __index = getmetatable(parent).__index }

    local function row(label, h)
        local r = mk("Frame", { Size = UDim2.new(1, 0, 0, h or 26),
            BackgroundTransparency = 1, ZIndex = 103 }, wrap)
        mk("TextLabel", { Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1,
            Font = FM, Text = label, TextColor3 = C.text, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 104 }, r)
        return r
    end

    function S:CreateToggle(name, default, cb)
        local on = default or false
        local r = row(name or "Toggle", 26)
        local tr = mk("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(38, 20), BackgroundColor3 = C.track,
            BorderSizePixel = 0, ZIndex = 104 }, r)
        rnd(tr, 10)
        local kn = mk("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.fromRGB(210, 210, 216),
            BorderSizePixel = 0, ZIndex = 105 }, tr)
        rnd(kn, 8)
        local function render()
            tw(tr, 0.12, { BackgroundColor3 = on and C.accent or C.track })
            tw(kn, 0.12, { Position = on and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(210,210,216) })
        end
        render()
        local cl = mk("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, ZIndex = 106 }, r)
        cl.MouseButton1Click:Connect(function()
            on = not on; render()
            if cb then cb(on) end
        end)
        return { Set = function(_, v) on = v; render() end, Get = function() return on end }
    end

    function S:CreateSlider(name, min, max, default, cb)
        min, max = min or 0, max or 100
        local val = default or min
        local r = mk("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, ZIndex = 103 }, wrap)
        mk("TextLabel", { Size = UDim2.new(1, -110, 0, 16), BackgroundTransparency = 1,
            Font = FM, Text = name or "Slider", TextColor3 = C.text, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 104 }, r)
        local vb = mk("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(56, 22), BackgroundColor3 = C.row,
            BorderSizePixel = 0, ZIndex = 104 }, r)
        rnd(vb, 5); strk(vb, C.border_s, 1, 0.5)
        local vl = mk("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Font = FM, Text = tostring(val), TextColor3 = C.text, TextSize = 12, ZIndex = 105 }, vb)
        local bar = mk("Frame", { Position = UDim2.new(0, 0, 1, -8), Size = UDim2.new(1, -70, 0, 4),
            BackgroundColor3 = C.track, BorderSizePixel = 0, ZIndex = 104 }, r)
        rnd(bar, 2)
        local fill = mk("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.accent,
            BorderSizePixel = 0, ZIndex = 105 }, bar)
        rnd(fill, 2)
        local dot = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(10, 10), BackgroundColor3 = Color3.fromRGB(240, 240, 245),
            BorderSizePixel = 0, ZIndex = 106 }, bar)
        rnd(dot, 5)
        local drg = false
        local function sfx(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            val = math.clamp(math.floor((min + (max - min) * rel) + 0.5), min, max)
            local p = (val - min) / math.max(max - min, 1e-6)
            fill.Size = UDim2.new(p, 0, 1, 0)
            dot.Position = UDim2.new(p, 0, 0.5, 0)
            vl.Text = tostring(val)
            if cb then cb(val) end
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drg = true; sfx(i.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                sfx(i.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drg = false
            end
        end)
        return { Set = function(_, v) val = math.clamp(v, min, max); sfx(bar.AbsolutePosition.X + bar.AbsoluteSize.X * ((val - min) / math.max(max - min, 1))) end,
                 Get = function() return val end }
    end

    function S:CreateKeybind(name, default, cb)
        local cur = default or Enum.KeyCode.V
        local lis = false
        local r = row(name or "Keybind", 26)
        local kb = mk("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(40, 22), BackgroundColor3 = C.row, BorderSizePixel = 0,
            Font = FM, Text = cur.Name, TextColor3 = C.text_dim, TextSize = 11,
            AutoButtonColor = false, ZIndex = 104 }, r)
        rnd(kb, 5); strk(kb, C.border_s, 1, 0.5)
        kb.MouseButton1Click:Connect(function()
            lis = true; kb.Text = "..."; kb.TextColor3 = C.accent
        end)
        UserInputService.InputBegan:Connect(function(i, gpe)
            if gpe then return end
            if lis and i.UserInputType == Enum.UserInputType.Keyboard then
                cur = i.KeyCode; kb.Text = cur.Name; kb.TextColor3 = C.text_dim; lis = false
            elseif not lis and i.KeyCode == cur then
                if cb then cb() end
            end
        end)
        return { Set = function(_, k) cur = k; kb.Text = k.Name end, Get = function() return cur end }
    end

    function S:CreateButton(name, cb)
        local r = row(name or "Button", 26)
        local b = mk("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(70, 22), BackgroundColor3 = C.row, BorderSizePixel = 0,
            Font = FM, Text = "run", TextColor3 = C.text_dim, TextSize = 11,
            AutoButtonColor = false, ZIndex = 104 }, r)
        rnd(b, 5); strk(b, C.border_s, 1, 0.5)
        b.MouseEnter:Connect(function() tw(b, 0.1, { BackgroundColor3 = C.row, TextColor3 = C.text }) end)
        b.MouseButton1Click:Connect(function() if cb then cb() end end)
        return b
    end

    function S:CreateTextbox(name, default, cb)
        local r = mk("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, ZIndex = 103 }, wrap)
        mk("TextLabel", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
            Font = FM, Text = name or "Input", TextColor3 = C.text, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 104 }, r)
        local bx = mk("TextBox", { Position = UDim2.new(0, 0, 1, -20), Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = C.row, BorderSizePixel = 0, Font = FR, Text = default or "",
            PlaceholderText = "...", TextColor3 = C.text, PlaceholderColor3 = C.text_mute,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false, ZIndex = 104 }, r)
        rnd(bx, 5); strk(bx, C.border_s, 1, 0.4)
        mk("UIPadding", { PaddingLeft = UDim.new(0, 6) }, bx)
        bx.FocusLost:Connect(function(enter) if cb then cb(bx.Text, enter) end end)
        return { Set = function(_, v) bx.Text = v end, Get = function() return bx.Text end }
    end
