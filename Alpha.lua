local NodiumUI = {}
NodiumUI.__index = NodiumUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function NodiumUI.CreateWindow(config)
    local self = setmetatable({}, NodiumUI)
    local title = type(config) == "string" and config or (config.Title or "Nodium")

    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "Nodium_" .. title
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 99999

    -- Основное окно (центрировано)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.fromOffset(520, 360)
    main.Position = UDim2.new(0.5, -260, 0.5, -180)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    -- Верхняя панель (TopBar)
    local top = Instance.new("Frame", main)
    top.Size = UDim2.new(1, 0, 0, 38)
    top.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    top.BorderSizePixel = 0
    Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)

    -- Перетаскивание (Dragging) за верхнюю панель
    local dragging, dragInput, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Текст названия в шапке
    local titleLbl = Instance.new("TextLabel", top)
    titleLbl.Size = UDim2.new(1, -90, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 240, 255)
    titleLbl.Font = Enum.Font.SourceSansBold
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd

    -- Кнопки закрытия и сворачивания
    local closeBtn = Instance.new("TextButton", top)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(160, 160, 175)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 14

    local minimizeBtn = Instance.new("TextButton", top)
    minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    minimizeBtn.Position = UDim2.new(1, -64, 0.5, -14)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Color3.fromRGB(160, 160, 175)
    minimizeBtn.Font = Enum.Font.SourceSansBold
    minimizeBtn.TextSize = 14

    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)

    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        for _, child in ipairs(main:GetChildren()) do
            if child ~= top then
                child.Visible = not minimized
            end
        end
        main.Size = minimized and UDim2.fromOffset(520, 38) or UDim2.fromOffset(520, 360)
    end)

    -- Контейнер для вкладок (слева)
    local tabsH = Instance.new("ScrollingFrame", main)
    tabsH.Size = UDim2.new(0, 130, 1, -48)
    tabsH.Position = UDim2.new(0, 8, 0, 42)
    tabsH.BackgroundTransparency = 1
    tabsH.ScrollBarThickness = 0
    local tLayout = Instance.new("UIListLayout", tabsH)
    tLayout.Padding = UDim.new(0, 5)

    -- Контейнер страниц (справа)
    local pagesH = Instance.new("Folder", main)
    self.Tabs = {}
    self.ScreenGui = sg

    function self:CreateTab(name)
        local btn = Instance.new("TextButton", tabsH)
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        btn.Text = " " .. name
        btn.TextColor3 = Color3.fromRGB(150, 150, 165)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local page = Instance.new("ScrollingFrame", pagesH)
        page.Size = UDim2.new(1, -150, 1, -48)
        page.Position = UDim2.new(0, 144, 0, 42)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
        
        local pLayout = Instance.new("UIListLayout", page)
        pLayout.Padding = UDim.new(0, 6)
        pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 10)
        end)

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Page.Visible = false
                t.Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
                t.Btn.TextColor3 = Color3.fromRGB(150, 150, 165)
            end
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(115, 100, 235)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        if #self.Tabs == 0 then
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(115, 100, 235)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local tabObj = {Btn = btn, Page = page}
        table.insert(self.Tabs, tabObj)

        function tabObj:CreateToggle(cfg)
            local togg = Instance.new("TextButton", page)
            togg.Size = UDim2.new(1, -6, 0, 36)
            togg.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            togg.Text = "  " .. cfg.Name
            togg.TextColor3 = Color3.fromRGB(220, 220, 235)
            togg.Font = Enum.Font.SourceSans
            togg.TextSize = 13
            togg.TextXAlignment = Enum.TextXAlignment.Left
            togg.AutoButtonColor = false
            Instance.new("UICorner", togg).CornerRadius = UDim.new(0, 6)

            local status = cfg.CurrentValue or false
            local box = Instance.new("Frame", togg)
            box.Size = UDim2.new(0, 34, 0, 18)
            box.Position = UDim2.new(1, -42, 0.5, -9)
            box.BackgroundColor3 = status and Color3.fromRGB(115, 100, 235) or Color3.fromRGB(45, 45, 55)
            Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame", box)
            circle.Size = UDim2.new(0, 14, 0, 14)
            circle.Position = status and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            togg.MouseButton1Click:Connect(function()
                status = not status
                box.BackgroundColor3 = status and Color3.fromRGB(115, 100, 235) or Color3.fromRGB(45, 45, 55)
                circle.Position = status and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                pcall(cfg.Callback, status)
            end)
        end

        function tabObj:CreateButton(cfg)
            local btnElem = Instance.new("TextButton", page)
            btnElem.Size = UDim2.new(1, -6, 0, 36)
            btnElem.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            btnElem.Text = "  " .. cfg.Name
            btnElem.TextColor3 = Color3.fromRGB(220, 220, 235)
            btnElem.Font = Enum.Font.SourceSans
            btnElem.TextSize = 13
            btnElem.TextXAlignment = Enum.TextXAlignment.Left
            btnElem.AutoButtonColor = false
            Instance.new("UICorner", btnElem).CornerRadius = UDim.new(0, 6)

            btnElem.MouseButton1Click:Connect(function()
                pcall(cfg.Callback)
            end)
        end

        return tabObj
    end

    function self:Notify(cfg)
        print("[" .. (cfg.Title or "Notify") .. "] " .. (cfg.Content or ""))
    end

    return self
end

return NodiumUI
