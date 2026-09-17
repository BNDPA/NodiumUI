local NodiumUI = {}
NodiumUI.__index = NodiumUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function tween(object, info, properties)
    local anim = TweenService:Create(object, info, properties)
    anim:Play()
    return anim
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Функция создания окна
-- config может быть строкой (название) или таблицей с настройками (Theme, Font, Icon, Title)
function NodiumUI.CreateWindow(config)
    local self = setmetatable({}, NodiumUI)
    
    local options = {
        Title = "NodiumUI",
        Icon = "rbxassetid://6031280882",
        Font = Enum.Font.SourceSansBold,
        
        -- Настройки темы по умолчанию (пользователь может переопределить)
        BackgroundColor = Color3.fromRGB(16, 16, 22),
        TopBarColor = Color3.fromRGB(22, 22, 30),
        CardColor = Color3.fromRGB(24, 24, 32),
        AccentColor = Color3.fromRGB(115, 100, 235),
        TextColor = Color3.fromRGB(230, 230, 240),
        SubTextColor = Color3.fromRGB(130, 130, 145)
    }

    if typeof(config) == "string" then
        options.Title = config
    elseif typeof(config) == "table" then
        for k, v in pairs(config) do
            options[k] = v
        end
    end

    self.Options = options

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NodiumUI_" .. options.Title
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local camera = workspace.CurrentCamera
    local viewportSize = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local windowWidth = isMobile and math.min(380, viewportSize.X - 20) or 740
    local windowHeight = isMobile and math.min(300, viewportSize.Y - 20) or 440

    -- Главный фрейм (MainFrame)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(windowWidth, windowHeight)
    mainFrame.Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    mainFrame.BackgroundColor3 = options.BackgroundColor
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = mainFrame

    -- Система перетаскивания (Drag System)
    local function makeDraggable(frame, handle)
        handle = handle or frame
        local dragging, dragStart, startPos
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
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
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    makeDraggable(mainFrame)

    -- Верхняя панель (TopBar)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 42)
    topBar.BackgroundColor3 = options.TopBarColor
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 14)
    topCorner.Parent = topBar

    -- Правый блок кнопок управления (- и ✕)
    local controlButtons = Instance.new("Frame")
    controlButtons.Name = "ControlButtons"
    controlButtons.Size = UDim2.new(0, 60, 1, 0)
    controlButtons.Position = UDim2.new(1, -65, 0, 0)
    controlButtons.BackgroundTransparency = 1
    controlButtons.Parent = topBar

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    btnLayout.Padding = UDim.new(0, 4)
    btnLayout.Parent = controlButtons

    -- Кнопка Сворачивания (-)
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = options.SubTextColor
    minimizeBtn.Font = options.Font
    minimizeBtn.TextSize = 14
    minimizeBtn.Parent = controlButtons

    -- Кнопка Закрытия (✕)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = options.SubTextColor
    closeBtn.Font = options.Font
    closeBtn.TextSize = 15
    closeBtn.Parent = controlButtons

    -- Контейнер для вкладок
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, -75, 1, 0)
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

    -- =========================================================================
    -- СВЁРНУТАЯ МИНИ-ПЛАШКА (Mini Bar Widget как на фото)
    -- =========================================================================
    local miniBar = Instance.new("Frame")
    miniBar.Name = "MiniBar"
    miniBar.Size = UDim2.new(0, 210, 0, 42)
    -- Размещается в самом верху экрана по центру с небольшим отступом
    miniBar.Position = UDim2.new(0.5, -105, 0, 15)
    miniBar.BackgroundColor3 = options.TopBarColor
    miniBar.BorderSizePixel = 0
    miniBar.Visible = false
    miniBar.ClipsDescendants = true
    miniBar.Parent = screenGui

    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(1, 0) -- Форма капсулы (pill-shape)
    miniCorner.Parent = miniBar

    local miniStroke = Instance.new("UIStroke")
    miniStroke.Color = options.AccentColor
    miniStroke.Thickness = 1.5
    miniStroke.Transparency = 0.4
    miniStroke.Parent = miniBar

    -- Иконка перетаскивания (Drag Icon) слева
    local dragIcon = Instance.new("TextLabel")
    dragIcon.Size = UDim2.new(0, 30, 1, 0)
    dragIcon.Position = UDim2.new(0, 8, 0, 0)
    dragIcon.Text = "✥"
    dragIcon.TextColor3 = options.SubTextColor
    dragIcon.TextSize = 16
    dragIcon.Font = Enum.Font.SourceSans
    dragIcon.BackgroundTransparency = 1
    dragIcon.Parent = miniBar

    -- Разделительная линия
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0, 1, 0, 20)
    divider.Position = UDim2.new(0, 38, 0.5, -10)
    divider.BackgroundColor3 = options.SubTextColor
    divider.BackgroundTransparency = 0.7
    divider.BorderSizePixel = 0
    divider.Parent = miniBar

    -- Кнопка с Иконкой + Названием
    local miniContent = Instance.new("TextButton")
    miniContent.Size = UDim2.new(1, -45, 1, 0)
    miniContent.Position = UDim2.new(0, 45, 0, 0)
    miniContent.BackgroundTransparency = 1
    miniContent.Text = ""
    miniContent.Parent = miniBar

    local miniIconImg = Instance.new("ImageLabel")
    miniIconImg.Size = UDim2.new(0, 20, 0, 20)
    miniIconImg.Position = UDim2.new(0, 2, 0.5, -10)
    miniIconImg.Image = options.Icon
    miniIconImg.ImageColor3 = options.AccentColor
    miniIconImg.BackgroundTransparency = 1
    miniIconImg.Parent = miniContent

    local miniTitleLbl = Instance.new("TextLabel")
    miniTitleLbl.Size = UDim2.new(1, -30, 1, 0)
    miniTitleLbl.Position = UDim2.new(0, 28, 0, 0)
    miniTitleLbl.Text = options.Title
    miniTitleLbl.TextColor3 = options.TextColor
    miniTitleLbl.Font = options.Font
    miniTitleLbl.TextSize = 14
    miniTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    miniTitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    miniTitleLbl.BackgroundTransparency = 1
    miniTitleLbl.Parent = miniContent

    makeDraggable(miniBar, dragIcon)

    -- Логика свертывания и развертывания
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniBar.Visible = true
    end)

    miniContent.MouseButton1Click:Connect(function()
        miniBar.Visible = false
        mainFrame.Visible = true
    end)

    -- =========================================================================
    -- ОКНО ПОДТВЕРЖДЕНИЯ ЗАКРЫТИЯ (Prompt Dialog)
    -- =========================================================================
    local overlay = Instance.new("Frame")
    overlay.Name = "ConfirmOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.Visible = false
    overlay.ZIndex = 10
    overlay.Parent = mainFrame

    local dialogBox = Instance.new("Frame")
    dialogBox.Name = "DialogBox"
    dialogBox.Size = UDim2.new(0, isMobile and 270 or 310, 0, 130)
    dialogBox.Position = UDim2.new(0.5, isMobile and -135 or -155, 0.5, -65)
    dialogBox.BackgroundColor3 = options.TopBarColor
    dialogBox.BorderSizePixel = 0
    dialogBox.ZIndex = 11
    dialogBox.Parent = overlay

    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 12)
    dialogCorner.Parent = dialogBox

    local dialogTitle = Instance.new("TextLabel")
    dialogTitle.Size = UDim2.new(1, -20, 0, 50)
    dialogTitle.Position = UDim2.new(0, 10, 0, 10)
    dialogTitle.Text = "Are you sure you want to close?"
    dialogTitle.TextColor3 = options.TextColor
    dialogTitle.Font = options.Font
    dialogTitle.TextSize = isMobile and 14 or 15
    dialogTitle.TextWrapped = true
    dialogTitle.BackgroundTransparency = 1
    dialogTitle.ZIndex = 12
    dialogTitle.Parent = dialogBox

    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0.42, 0, 0, 32)
    noBtn.Position = UDim2.new(0.06, 0, 1, -44)
    noBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    noBtn.Text = "No"
    noBtn.TextColor3 = options.TextColor
    noBtn.Font = options.Font
    noBtn.TextSize = 14
    noBtn.ZIndex = 12
    noBtn.Parent = dialogBox

    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 8)
    noCorner.Parent = noBtn

    local closeConfirmBtn = Instance.new("TextButton")
    closeConfirmBtn.Size = UDim2.new(0.42, 0, 0, 32)
    closeConfirmBtn.Position = UDim2.new(0.52, 0, 1, -44)
    closeConfirmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
    closeConfirmBtn.Text = "Close Window"
    closeConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeConfirmBtn.Font = options.Font
    closeConfirmBtn.TextSize = 13
    closeConfirmBtn.ZIndex = 12
    closeConfirmBtn.Parent = dialogBox

    local closeConfirmCorner = Instance.new("UICorner")
    closeConfirmCorner.CornerRadius = UDim.new(0, 8)
    closeConfirmCorner.Parent = closeConfirmBtn

    closeBtn.MouseButton1Click:Connect(function()
        overlay.Visible = true
        tween(overlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.5})
    end)

    noBtn.MouseButton1Click:Connect(function()
        tween(overlay, TweenInfo.new(0.15), {BackgroundTransparency = 1})
        task.delay(0.15, function() overlay.Visible = false end)
    end)

    closeConfirmBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.Container = container
    self.TopBar = topBar
    self.Tabs = {}

    return self
end

function NodiumUI:AddTab(iconAssetId)
    local options = self.Options
    
    local tabButton = Instance.new("ImageButton")
    tabButton.Name = "TabIcon"
    tabButton.Size = UDim2.new(0, 22, 0, 22)
    tabButton.BackgroundTransparency = 1
    tabButton.Image = iconAssetId or "rbxassetid://6031094678"
    tabButton.ImageColor3 = options.SubTextColor
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

    local columnCount = isMobile and 1 or 3
    local columns = {}

    for i = 1, columnCount do
        local col = Instance.new("Frame")
        col.Name = "Column_" .. i
        col.Size = UDim2.new(1 / columnCount - (isMobile and 0 or 0.02), 0, 1, 0)
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
            tween(tab.Button, TweenInfo.new(0.2), {ImageColor3 = options.SubTextColor})
        end
        page.Visible = true
        tween(tabButton, TweenInfo.new(0.2), {ImageColor3 = options.AccentColor})
    end)

    local tabObj = { Button = tabButton, Page = page, Columns = columns, ParentUI = self }
    table.insert(self.Tabs, tabObj)

    if #self.Tabs == 1 then
        page.Visible = true
        tabButton.ImageColor3 = options.AccentColor
    end

    function tabObj:AddModule(moduleName, columnIndex)
        local parentOptions = self.ParentUI.Options
        local targetCol = columns[columnIndex or 1] or columns[1]

        local moduleFrame = Instance.new("Frame")
        moduleFrame.Name = "ModuleFrame"
        moduleFrame.Size = UDim2.new(1, 0, 0, 36)
        moduleFrame.BackgroundColor3 = parentOptions.CardColor
        moduleFrame.BorderSizePixel = 0
        moduleFrame.ClipsDescendants = true
        moduleFrame.Parent = targetCol

        local modCorner = Instance.new("UICorner")
        modCorner.CornerRadius = UDim.new(0, 10)
        modCorner.Parent = moduleFrame

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 36)
        header.BackgroundTransparency = 1
        header.Parent = moduleFrame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -50, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.Text = moduleName or "Module"
        titleLabel.TextColor3 = parentOptions.TextColor
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Font = parentOptions.Font
        titleLabel.TextSize = isMobile and 14 or 15
        titleLabel.BackgroundTransparency = 1
        titleLabel.Parent = header

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 32, 0, 16)
        toggleBtn.Position = UDim2.new(1, -40, 0.5, -8)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
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
                tween(toggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = parentOptions.AccentColor})
                tween(toggleCircle, TweenInfo.new(0.15), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            else
                tween(toggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)})
                tween(toggleCircle, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(180, 180, 190)})
            end
        end)

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local h = contentLayout.AbsoluteContentSize.Y
            moduleFrame.Size = UDim2.new(1, 0, 0, 36 + h + (h > 0 and 8 or 0))
        end)

        local moduleObj = {}

        function moduleObj:AddToggle(text, subtext, default, callback)
            if typeof(subtext) == "boolean" then
                callback = default
                default = subtext
                subtext = nil
            end

            callback = callback or function() end
            local state = default or false

            local containerFrame = Instance.new("Frame")
            containerFrame.Size = UDim2.new(1, 0, 0, subtext and 32 or 24)
            containerFrame.BackgroundTransparency = 1
            containerFrame.Parent = content

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -34, 0, subtext and 16 or 24)
            lbl.Text = text
            lbl.TextColor3 = parentOptions.TextColor
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = isMobile and 13 or 14
            lbl.BackgroundTransparency = 1
            lbl.Parent = containerFrame

            if subtext then
                local subLbl = Instance.new("TextLabel")
                subLbl.Size = UDim2.new(1, -34, 0, 12)
                subLbl.Position = UDim2.new(0, 0, 0, 16)
                subLbl.Text = subtext
                subLbl.TextColor3 = parentOptions.SubTextColor
                subLbl.TextXAlignment = Enum.TextXAlignment.Left
                subLbl.Font = Enum.Font.SourceSans
                subLbl.TextSize = 11
                subLbl.BackgroundTransparency = 1
                subLbl.Parent = containerFrame
            end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 26, 0, 14)
            btn.Position = UDim2.new(1, -26, 0.5, -7)
            btn.BackgroundColor3 = state and parentOptions.AccentColor or Color3.fromRGB(45, 45, 55)
            btn.Text = ""
            btn.Parent = containerFrame

            local c1 = Instance.new("UICorner")
            c1.CornerRadius = UDim.new(1, 0)
            c1.Parent = btn

            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 10, 0, 10)
            dot.Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dot.BorderSizePixel = 0
            dot.Parent = btn

            local c2 = Instance.new("UICorner")
            c2.CornerRadius = UDim.new(1, 0)
            c2.Parent = dot

            btn.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    tween(btn, TweenInfo.new(0.12), {BackgroundColor3 = parentOptions.AccentColor})
                    tween(dot, TweenInfo.new(0.12), {Position = UDim2.new(1, -12, 0.5, -5)})
                else
                    tween(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)})
                    tween(dot, TweenInfo.new(0.12), {Position = UDim2.new(0, 2, 0.5, -5)})
                end
                callback(state)
            end)
        end

        function moduleObj:AddDropdown(text, list, default, callback)
            callback = callback or function() end
            local selected = default or list[1]
            local expanded = false

            local ddFrame = Instance.new("Frame")
            ddFrame.Size = UDim2.new(1, 0, 0, 40)
            ddFrame.BackgroundTransparency = 1
            ddFrame.ClipsDescendants = true
            ddFrame.Parent = content

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 14)
            lbl.Text = text
            lbl.TextColor3 = parentOptions.SubTextColor
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 12
            lbl.BackgroundTransparency = 1
            lbl.Parent = ddFrame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 22)
            btn.Position = UDim2.new(0, 0, 0, 16)
            btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
            btn.Text = "  " .. tostring(selected)
            btn.TextColor3 = parentOptions.TextColor
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 12
            btn.Parent = ddFrame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            local listContainer = Instance.new("Frame")
            listContainer.Size = UDim2.new(1, 0, 0, #list * 20)
            listContainer.Position = UDim2.new(0, 0, 0, 40)
            listContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            listContainer.Parent = ddFrame

            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 6)
            listCorner.Parent = listContainer

            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = listContainer

            for _, item in ipairs(list) do
                local itemBtn = Instance.new("TextButton")
                itemBtn.Size = UDim2.new(1, 0, 0, 20)
                itemBtn.BackgroundTransparency = 1
                itemBtn.Text = "  " .. tostring(item)
                itemBtn.TextColor3 = parentOptions.TextColor
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                itemBtn.Font = Enum.Font.SourceSans
                itemBtn.TextSize = 12
                itemBtn.Parent = listContainer

                itemBtn.MouseButton1Click:Connect(function()
                    selected = item
                    btn.Text = "  " .. tostring(selected)
                    expanded = false
                    tween(ddFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 40)})
                    callback(selected)
                end)
            end

            btn.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    tween(ddFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 40 + #list * 20)})
                else
                    tween(ddFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 40)})
                end
            end)
        end

        return moduleObj
    end

    return tabObj
end

return NodiumUI

