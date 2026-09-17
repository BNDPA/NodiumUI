local NodiumUI = {}
NodiumUI.__index = NodiumUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Вспомогательная функция анимации
local function tween(object, info, properties)
    local anim = TweenService:Create(object, info, properties)
    anim:Play()
    return anim
end

-- Создание главного окна
function NodiumUI.CreateWindow(title)
    local self = setmetatable({}, NodiumUI)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NodiumUI_" .. (title or "GUI")
    screenGui.ResetOnSpawn = false
    
    -- Безопасный родитель (CoreGui или PlayerGui)
    local success, _ = pcall(function()
        screenGui.Parent = CoreGui
    end)
    if not success then
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 780, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -390, 0.5, -240)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame

    -- Реализация перетаскивания окна (Drag System)
    local dragging, dragInput, dragStart, startPos
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

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Верхняя панель вкладок (Только иконки)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 42)
    topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 8)
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
    tabsLayout.Padding = UDim.new(0, 16)
    tabsLayout.Parent = tabsContainer

    -- Контейнер контента
    local container = Instance.new("Frame")
    container.Name = "ContentContainer"
    container.Size = UDim2.new(1, -20, 1, -52)
    container.Position = UDim2.new(0, 10, 0, 47)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.TopBar = topBar
    self.Container = container
    self.Tabs = {}

    return self
end

-- Создание вкладки (принимает только ID иконки)
function NodiumUI:AddTab(iconAssetId)
    local tabButton = Instance.new("ImageButton")
    tabButton.Name = "TabIcon"
    tabButton.Size = UDim2.new(0, 22, 0, 22)
    tabButton.BackgroundTransparency = 1
    tabButton.Image = iconAssetId or "rbxassetid://6031094678"
    tabButton.ImageColor3 = Color3.fromRGB(120, 120, 135)
    tabButton.Parent = self.TopBar.TabsContainer

    -- Вкладка состоит из 3-х колонок для карточек (как на скриншоте)
    local page = Instance.new("ScrollingFrame")
    page.Name = "TabPage"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = self.Container

    -- Создаем 3 колонки
    local columns = {}
    for i = 1, 3 do
        local col = Instance.new("Frame")
        col.Name = "Column_" .. i
        col.Size = UDim2.new(0.32, 0, 1, 0)
        col.Position = UDim2.new((i - 1) * 0.34, 0, 0, 0)
        col.BackgroundTransparency = 1
        col.Parent = page

        local colLayout = Instance.new("UIListLayout")
        colLayout.SortOrder = Enum.SortOrder.LayoutOrder
        colLayout.Padding = UDim.new(0, 10)
        colLayout.Parent = col

        colLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local maxH = 0
            for _, c in pairs(columns) do
                if c.UIListLayout.AbsoluteContentSize.Y > maxH then
                    maxH = c.UIListLayout.AbsoluteContentSize.Y
                end
            end
            page.CanvasSize = UDim2.new(0, 0, 0, maxH + 20)
        end)

        table.insert(columns, col)
    end

    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Page.Visible = false
            tween(tab.Button, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(120, 120, 135)})
        end
        page.Visible = true
        tween(tabButton, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(115, 100, 235)})
    end)

    local tabObj = {
        Button = tabButton,
        Page = page,
        Columns = columns,
        CurrentColumn = 1
    }

    table.insert(self.Tabs, tabObj)

    if #self.Tabs == 1 then
        page.Visible = true
        tabButton.ImageColor3 = Color3.fromRGB(115, 100, 235)
    end

    -- Добавление модуля (Карточки)
    function tabObj:AddModule(moduleName, columnIndex)
        local targetCol = columns[columnIndex or 1] or columns[1]

        local moduleFrame = Instance.new("Frame")
        moduleFrame.Name = "ModuleFrame"
        moduleFrame.Size = UDim2.new(1, 0, 0, 36)
        moduleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        moduleFrame.BorderSizePixel = 0
        moduleFrame.ClipsDescendants = true
        moduleFrame.Parent = targetCol

        local modCorner = Instance.new("UICorner")
        modCorner.CornerRadius = UDim.new(0, 6)
        modCorner.Parent = moduleFrame

        -- Шапка модуля
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 36)
        header.BackgroundTransparency = 1
        header.Parent = moduleFrame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -70, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.Text = moduleName or "Module"
        titleLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextSize = 15
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = header

        -- Переключатель включения модуля
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 30, 0, 16)
        toggleBtn.Position = UDim2.new(1, -40, 0.5, -8)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        toggleBtn.Text = ""
        toggleBtn.AutoButtonColor = false
        toggleBtn.Parent = header

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleBtn

        local toggleCircle = Instance.new("Frame")
        toggleCircle.Size = UDim2.new(0, 12, 0, 12)
        toggleCircle.Position = UDim2.new(0, 2, 0.5, -6)
        toggleCircle.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
        toggleCircle.BorderSizePixel = 0
        toggleCircle.Parent = toggleBtn

        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = toggleCircle

        -- Контейнер элементов управления модуля
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, -16, 0, 0)
        content.Position = UDim2.new(0, 8, 0, 36)
        content.BackgroundTransparency = 1
        content.Parent = moduleFrame

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.Parent = content

        local isEnabled = false
        toggleBtn.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            if isEnabled then
                tween(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(115, 100, 235)})
                tween(toggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            else
                tween(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)})
                tween(toggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(180, 180, 190)})
            end
        end)

        local function updateModuleSize()
            local h = contentLayout.AbsoluteContentSize.Y
            moduleFrame.Size = UDim2.new(1, 0, 0, 36 + h + (h > 0 and 10 or 0))
        end

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateModuleSize)

        local moduleObj = {}

        -- 1. Элемент: Toggle
        function moduleObj:AddToggle(text, default, callback)
            callback = callback or function() end
            local state = default or false

            local containerFrame = Instance.new("Frame")
            containerFrame.Size = UDim2.new(1, 0, 0, 24)
            containerFrame.BackgroundTransparency = 1
            containerFrame.Parent = content

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -30, 1, 0)
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 14
            lbl.BackgroundTransparency = 1
            lbl.Parent = containerFrame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 24, 0, 12)
            btn.Position = UDim2.new(1, -24, 0.5, -6)
            btn.BackgroundColor3 = state and Color3.fromRGB(115, 100, 235) or Color3.fromRGB(40, 40, 50)
            btn.Text = ""
            btn.Parent = containerFrame

            local c1 = Instance.new("UICorner")
            c1.CornerRadius = UDim.new(1, 0)
            c1.Parent = btn

            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.Position = state and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4)
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dot.BorderSizePixel = 0
            dot.Parent = btn

            local c2 = Instance.new("UICorner")
            c2.CornerRadius = UDim.new(1, 0)
            c2.Parent = dot

            btn.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(115, 100, 235)})
                    tween(dot, TweenInfo.new(0.15), {Position = UDim2.new(1, -10, 0.5, -4)})
                else
                    tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)})
                    tween(dot, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -4)})
                end
                callback(state)
            end)
        end

        -- 2. Элемент: Slider
        function moduleObj:AddSlider(text, min, max, default, callback)
            callback = callback or function() end
            local value = default or min

            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 36)
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.Parent = content

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -40, 0, 18)
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 14
            lbl.BackgroundTransparency = 1
            lbl.Parent = sliderFrame

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0, 40, 0, 18)
            valLbl.Position = UDim2.new(1, -40, 0, 0)
            valLbl.Text = tostring(value)
            valLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Font = Enum.Font.SourceSans
            valLbl.TextSize = 13
            valLbl.BackgroundTransparency = 1
            valLbl.Parent = sliderFrame

            local track = Instance.new("TextButton")
            track.Size = UDim2.new(1, 0, 0, 6)
            track.Position = UDim2.new(0, 0, 0, 22)
            track.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            track.Text = ""
            track.AutoButtonColor = false
            track.Parent = sliderFrame

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = track

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(115, 100, 235)
            fill.BorderSizePixel = 0
            fill.Parent = track

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill

            local sliding = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + ((max - min) * pos))
                valLbl.Text = tostring(value)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                callback(value)
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    updateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
        end

        -- 3. Элемент: Keybind
        function moduleObj:AddKeybind(text, defaultKey, callback)
            callback = callback or function() end
            local currentKey = defaultKey or Enum.KeyCode.E

            local bindFrame = Instance.new("Frame")
            bindFrame.Size = UDim2.new(1, 0, 0, 24)
            bindFrame.BackgroundTransparency = 1
            bindFrame.Parent = content

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -70, 1, 0)
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 14
            lbl.BackgroundTransparency = 1
            lbl.Parent = bindFrame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 60, 0, 18)
            btn.Position = UDim2.new(1, -60, 0.5, -9)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            btn.Text = currentKey.Name
            btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 12
            btn.Parent = bindFrame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn

            local listening = false
            btn.MouseButton1Click:Connect(function()
                listening = true
                btn.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    currentKey = input.KeyCode
                    btn.Text = currentKey.Name
                    callback(currentKey)
                end
            end)
        end

        -- 4. Элемент: Dropdown (Выпадающий список)
        function moduleObj:AddDropdown(text, list, default, callback)
            callback = callback or function() end
            local selected = default or list[1]
            local expanded = false

            local ddFrame = Instance.new("Frame")
            ddFrame.Size = UDim2.new(1, 0, 0, 42)
            ddFrame.BackgroundTransparency = 1
            ddFrame.ClipsDescendants = true
            ddFrame.Parent = content

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 16)
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 14
            lbl.BackgroundTransparency = 1
            lbl.Parent = ddFrame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 22)
            btn.Position = UDim2.new(0, 0, 0, 18)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            btn.Text = "  " .. tostring(selected)
            btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 13
            btn.Parent = ddFrame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn

            local listContainer = Instance.new("Frame")
            listContainer.Size = UDim2.new(1, 0, 0, #list * 20)
            listContainer.Position = UDim2.new(0, 0, 0, 42)
            listContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            listContainer.Parent = ddFrame

            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = listContainer

            for _, item in ipairs(list) do
                local itemBtn = Instance.new("TextButton")
                itemBtn.Size = UDim2.new(1, 0, 0, 20)
                itemBtn.BackgroundTransparency = 1
                itemBtn.Text = "  " .. tostring(item)
                itemBtn.TextColor3 = Color3.fromRGB(170, 170, 185)
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                itemBtn.Font = Enum.Font.SourceSans
                itemBtn.TextSize = 12
                itemBtn.Parent = listContainer

                itemBtn.MouseButton1Click:Connect(function()
                    selected = item
                    btn.Text = "  " .. tostring(selected)
                    expanded = false
                    tween(ddFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 42)})
                    callback(selected)
                end)
            end

            btn.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    tween(ddFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 42 + #list * 20)})
                else
                    tween(ddFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 42)})
                end
            end)
        end

        return moduleObj
    end

    return tabObj
end

return NodiumUI

