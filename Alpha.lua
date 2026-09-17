local NodiumUI = {}
NodiumUI.__index = NodiumUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local function tween(object, info, properties)
    local anim = TweenService:Create(object, info, properties)
    anim:Play()
    return anim
end

-- Проверка на мобильное устройство
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

function NodiumUI.CreateWindow(title)
    local self = setmetatable({}, NodiumUI)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NodiumUI_" .. (title or "GUI")
    screenGui.ResetOnSpawn = false
    
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Динамический размер окна для ПК и Телефонов
    local windowWidth = isMobile and 420 or 720
    local windowHeight = isMobile and 280 or 440

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(windowWidth, windowHeight)
    mainFrame.Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    -- Большие скругления как на фото
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = mainFrame

    -- Система перетаскивания (Drag)
    local dragging, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
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
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Верхняя панель (TopBar)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 14)
    topCorner.Parent = topBar

    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, -20, 1, 0)
    tabsContainer.Position = UDim2.new(0, 10, 0, 0)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = topBar

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabsLayout.Padding = UDim.new(0, 14)
    tabsLayout.Parent = tabsContainer

    -- Контейнер содержимого
    local container = Instance.new("Frame")
    container.Name = "ContentContainer"
    container.Size = UDim2.new(1, -20, 1, -50)
    container.Position = UDim2.new(0, 10, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.Container = container
    self.TopBar = topBar
    self.Tabs = {}

    return self
end

function NodiumUI:AddTab(iconAssetId)
    local tabButton = Instance.new("ImageButton")
    tabButton.Name = "TabIcon"
    tabButton.Size = UDim2.new(0, 20, 0, 20)
    tabButton.BackgroundTransparency = 1
    tabButton.Image = iconAssetId or "rbxassetid://6031094678"
    tabButton.ImageColor3 = Color3.fromRGB(110, 110, 125)
    tabButton.Parent = self.TopBar.TabsContainer

    local page = Instance.new("ScrollingFrame")
    page.Name = "TabPage"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = self.Container

    -- 2 колонки на телефонах, 3 на ПК
    local columnCount = isMobile and 2 or 3
    local columns = {}

    for i = 1, columnCount do
        local col = Instance.new("Frame")
        col.Name = "Column_" .. i
        col.Size = UDim2.new(1 / columnCount - 0.02, 0, 1, 0)
        col.Position = UDim2.new((i - 1) * (1 / columnCount + 0.01), 0, 0, 0)
        col.BackgroundTransparency = 1
        col.Parent = page

        local colLayout = Instance.new("UIListLayout")
        colLayout.SortOrder = Enum.SortOrder.LayoutOrder
        colLayout.Padding = UDim.new(0, 8)
        colLayout.Parent = col

        colLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local maxH = 0
            for _, c in pairs(columns) do
                if c.UIListLayout.AbsoluteContentSize.Y > maxH then
                    maxH = c.UIListLayout.AbsoluteContentSize.Y
                end
            end
            page.CanvasSize = UDim2.new(0, 0, 0, maxH + 15)
        end)

        table.insert(columns, col)
    end

    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Page.Visible = false
            tween(tab.Button, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(110, 110, 125)})
        end
        page.Visible = true
        tween(tabButton, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(115, 100, 235)})
    end)

    local tabObj = { Button = tabButton, Page = page, Columns = columns }
    table.insert(self.Tabs, tabObj)

    if #self.Tabs == 1 then
        page.Visible = true
        tabButton.ImageColor3 = Color3.fromRGB(115, 100, 235)
    end

    -- Добавление карточки модуля
    function tabObj:AddModule(moduleName, columnIndex)
        local targetCol = columns[columnIndex or 1] or columns[1]

        local moduleFrame = Instance.new("Frame")
        moduleFrame.Name = "ModuleFrame"
        moduleFrame.Size = UDim2.new(1, 0, 0, 34)
        moduleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        moduleFrame.BorderSizePixel = 0
        moduleFrame.ClipsDescendants = true
        moduleFrame.Parent = targetCol

        local modCorner = Instance.new("UICorner")
        modCorner.CornerRadius = UDim.new(0, 10) -- Большие закругления карточек
        modCorner.Parent = moduleFrame

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 34)
        header.BackgroundTransparency = 1
        header.Parent = moduleFrame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -50, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.Text = moduleName or "Module"
        titleLabel.TextColor3 = Color3.fromRGB(225, 225, 235)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextSize = isMobile and 13 or 14
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = header

        -- Акцентный тумблер карточки
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 28, 0, 14)
        toggleBtn.Position = UDim2.new(1, -36, 0.5, -7)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        toggleBtn.Text = ""
        toggleBtn.AutoButtonColor = false
        toggleBtn.Parent = header

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleBtn

        local toggleCircle = Instance.new("Frame")
        toggleCircle.Size = UDim2.new(0, 10, 0, 10)
        toggleCircle.Position = UDim2.new(0, 2, 0.5, -5)
        toggleCircle.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
        toggleCircle.BorderSizePixel = 0
        toggleCircle.Parent = toggleBtn

        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = toggleCircle

        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, -16, 0, 0)
        content.Position = UDim2.new(0, 8, 0, 34)
        content.BackgroundTransparency = 1
        content.Parent = moduleFrame

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 5)
        contentLayout.Parent = content

        local isEnabled = false
        toggleBtn.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            if isEnabled then
                tween(toggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(115, 100, 235)})
                tween(toggleCircle, TweenInfo.new(0.15), {Position = UDim2.new(1, -12, 0.5, -5), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            else
                tween(toggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)})
                tween(toggleCircle, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -5), BackgroundColor3 = Color3.fromRGB(180, 180, 190)})
            end
        end)

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local h = contentLayout.AbsoluteContentSize.Y
            moduleFrame.Size = UDim2.new(1, 0, 0, 34 + h + (h > 0 and 8 or 0))
        end)

        local moduleObj = {}

        -- Toggle с подзаголовком
        function moduleObj:AddToggle(text, subtext, default, callback)
            if typeof(subtext) == "boolean" then
                callback = default
                default = subtext
                subtext = nil
            end

            callback = callback or function() end
            local state = default or false

            local containerFrame = Instance.new("Frame")
            containerFrame.Size = UDim2.new(1, 0, 0, subtext and 30 or 22)
            containerFrame.BackgroundTransparency = 1
            containerFrame.Parent = content

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -26, 0, subtext and 14 or 22)
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(170, 170, 185)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = isMobile and 12 or 13
            lbl.BackgroundTransparency = 1
            lbl.Parent = containerFrame

            if subtext then
                local subLbl = Instance.new("TextLabel")
                subLbl.Size = UDim2.new(1, -26, 0, 12)
                subLbl.Position = UDim2.new(0, 0, 0, 14)
                subLbl.Text = subtext
                subLbl.TextColor3 = Color3.fromRGB(110, 110, 125)
                subLbl.TextXAlignment = Enum.TextXAlignment.Left
                subLbl.Font = Enum.Font.SourceSans
                subLbl.TextSize = 11
                subLbl.BackgroundTransparency = 1
                subLbl.Parent = containerFrame
            end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 22, 0, 12)
            btn.Position = UDim2.new(1, -22, 0.5, -6)
            btn.BackgroundColor3 = state and Color3.fromRGB(115, 100, 235) or Color3.fromRGB(45, 45, 55)
            btn.Text = ""
            btn.Parent = containerFrame

            local c1 = Instance.new("UICorner")
            c1.CornerRadius = UDim.new(1, 0)
            c1.Parent = btn

            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.Position = state and UDim2.new(1, -9, 0.5, -4) or UDim2.new(0, 1, 0.5, -4)
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dot.BorderSizePixel = 0
            dot.Parent = btn

            local c2 = Instance.new("UICorner")
            c2.CornerRadius = UDim.new(1, 0)
            c2.Parent = dot

            btn.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    tween(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(115, 100, 235)})
                    tween(dot, TweenInfo.new(0.12), {Position = UDim2.new(1, -9, 0.5, -4)})
                else
                    tween(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)})
                    tween(dot, TweenInfo.new(0.12), {Position = UDim2.new(0, 1, 0.5, -4)})
                end
                callback(state)
            end)
        end

        -- Выпадающий список (Dropdown)
        function moduleObj:AddDropdown(text, list, default, callback)
            callback = callback or function() end
            local selected = default or list[1]
            local expanded = false

            local ddFrame = Instance.new("Frame")
            ddFrame.Size = UDim2.new(1, 0, 0, 36)
            ddFrame.BackgroundTransparency = 1
            ddFrame.ClipsDescendants = true
            ddFrame.Parent = content

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 14)
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(110, 110, 125)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 12
            lbl.BackgroundTransparency = 1
            lbl.Parent = ddFrame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.Position = UDim2.new(0, 0, 0, 15)
            btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
            btn.Text = "  " .. tostring(selected)
            btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 12
            btn.Parent = ddFrame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            local listContainer = Instance.new("Frame")
            listContainer.Size = UDim2.new(1, 0, 0, #list * 18)
            listContainer.Position = UDim2.new(0, 0, 0, 36)
            listContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            listContainer.Parent = ddFrame

            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 6)
            listCorner.Parent = listContainer

            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = listContainer

            for _, item in ipairs(list) do
                local itemBtn = Instance.new("TextButton")
                itemBtn.Size = UDim2.new(1, 0, 0, 18)
                itemBtn.BackgroundTransparency = 1
                itemBtn.Text = "  " .. tostring(item)
                itemBtn.TextColor3 = Color3.fromRGB(160, 160, 175)
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                itemBtn.Font = Enum.Font.SourceSans
                itemBtn.TextSize = 11
                itemBtn.Parent = listContainer

                itemBtn.MouseButton1Click:Connect(function()
                    selected = item
                    btn.Text = "  " .. tostring(selected)
                    expanded = false
                    tween(ddFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 36)})
                    callback(selected)
                end)
            end

            btn.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    tween(ddFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 36 + #list * 18)})
                else
                    tween(ddFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 36)})
                end
            end)
        end

        return moduleObj
    end

    return tabObj
end

return NodiumUI

