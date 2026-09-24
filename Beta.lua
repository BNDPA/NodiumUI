local Library = {}
Library.__index = Library

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function Library.new(scriptName, iconUrl, customTheme)
    local self = setmetatable({}, Library)
    
    -- Тема в стиле Neverlose (nl) / Vertex: темный графит, неоновый фиолетово-синий/мятный акцент
    self.Theme = customTheme or {
        Background = Color3.fromRGB(13, 13, 16),
        TopBar = Color3.fromRGB(17, 17, 21),
        Accent = Color3.fromRGB(114, 91, 238), -- Фирменный фиолетовый Neverlose (можно заменить на бирюзовый Vertex)
        AccentGlow = Color3.fromRGB(140, 120, 255),
        Text = Color3.fromRGB(240, 240, 245),
        DarkText = Color3.fromRGB(120, 120, 135),
        Stroke = Color3.fromRGB(30, 30, 38),
        ElementBg = Color3.fromRGB(19, 19, 24)
    }

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NeverloseStyle_UI"
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Главное окно
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.MainFrame.Size = UDim2.new(0, 600, 0, 400)

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = self.MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = self.MainFrame
    MainStroke.Color = self.Theme.Stroke
    MainStroke.Thickness = 1.5

    -- Шапка в стиле NV/Vertex
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Parent = self.MainFrame
    self.TopBar.BackgroundColor3 = self.Theme.TopBar
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Size = UDim2.new(1, 0, 0, 40)

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = self.TopBar

    local TopFix = Instance.new("Frame")
    TopFix.Parent = self.TopBar
    TopFix.BackgroundColor3 = self.Theme.TopBar
    TopFix.BorderSizePixel = 0
    TopFix.Position = UDim2.new(0, 0, 1, -6)
    TopFix.Size = UDim2.new(1, 0, 0, 6)

    -- Название скрипта с неоновой точкой-индикатором
    self.Title = Instance.new("TextLabel")
    self.Title.Parent = self.TopBar
    self.Title.BackgroundTransparency = 1
    self.Title.Position = UDim2.new(0, 16, 0, 0)
    self.Title.Size = UDim2.new(0, 300, 1, 0)
    self.Title.Font = Enum.Font.GothamBold
    self.Title.Text = "  " .. (scriptName or "Neverlose Style")
    self.Title.TextColor3 = self.Theme.Text
    self.Title.TextSize = 13
    self.Title.TextXAlignment = Enum.TextXAlignment.Left

    local DotIndicator = Instance.new("Frame")
    DotIndicator.Parent = self.Title
    DotIndicator.BackgroundColor3 = self.Theme.Accent
    DotIndicator.Position = UDim2.new(0, 0, 0.5, -3)
    DotIndicator.Size = UDim2.new(0, 6, 0, 6)
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = DotIndicator

    -- Кнопки управления (Закрыть / Свернуть) в стиле NV
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = self.TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -35, 0, 0)
    CloseButton.Size = UDim2.new(0, 35, 1, 0)
    CloseButton.Font = Enum.Font.GothamMedium
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = self.Theme.DarkText
    CloseButton.TextSize = 13

    CloseButton.MouseEnter:Connect(function() TweenService:Create(CloseButton, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play() end)
    CloseButton.MouseLeave:Connect(function() TweenService:Create(CloseButton, TweenInfo.new(0.15), {TextColor3 = self.Theme.DarkText}):Play() end)
    CloseButton.MouseButton1Click:Connect(function() self.ScreenGui:Destroy() end)

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Parent = self.TopBar
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
    MinimizeButton.Size = UDim2.new(0, 35, 1, 0)
    MinimizeButton.Font = Enum.Font.GothamMedium
    MinimizeButton.Text = "—"
    MinimizeButton.TextColor3 = self.Theme.DarkText
    MinimizeButton.TextSize = 12

    MinimizeButton.MouseEnter:Connect(function() TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {TextColor3 = self.Theme.Text}):Play() end)
    MinimizeButton.MouseLeave:Connect(function() TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {TextColor3 = self.Theme.DarkText}):Play() end)

    -- Плавающая круглая кнопка для развертывания
    self.FloatingButton = Instance.new("ImageButton")
    self.FloatingButton.Name = "FloatingLogo"
    self.FloatingButton.Parent = self.ScreenGui
    self.FloatingButton.BackgroundColor3 = self.Theme.TopBar
    self.FloatingButton.Position = UDim2.new(0, 30, 0.5, -25)
    self.FloatingButton.Size = UDim2.new(0, 46, 0, 46)
    self.FloatingButton.Visible = false
    self.FloatingButton.AutoButtonColor = false

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0)
    FloatCorner.Parent = self.FloatingButton

    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Parent = self.FloatingButton
    FloatStroke.Color = self.Theme.Accent
    FloatStroke.Thickness = 2

    if iconUrl then self.FloatingButton.Image = iconUrl end

    MinimizeButton.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = false
        self.FloatingButton.Visible = true
    end)

    self.FloatingButton.MouseButton1Click:Connect(function()
        self.FloatingButton.Visible = false
        self.MainFrame.Visible = true
    end)

    -- Перетаскивание главного окна
    local dragging, dragInput, dragStart, startPos
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    self.TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Перетаскивание плавающей кнопки
    local fDragging, fInput, fStart, fPos
    self.FloatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fDragging = true; fStart = input.Position; fPos = self.FloatingButton.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then fDragging = false end end)
        end
    end)
    self.FloatingButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then fInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == fInput and fDragging then
            local delta = input.Position - fStart
            self.FloatingButton.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + delta.X, fPos.Y.Scale, fPos.Y.Offset + delta.Y)
        end
    end)

    -- Сайдбар вкладок слева (стиль Neverlose / Vertex)
    self.TabList = Instance.new("ScrollingFrame")
    self.TabList.Parent = self.MainFrame
    self.TabList.BackgroundTransparency = 1
    self.TabList.Position = UDim2.new(0, 12, 0, 52)
    self.TabList.Size = UDim2.new(0, 140, 1, -64)
    self.TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabList.ScrollBarThickness = 0

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = self.TabList
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)

    -- Контейнер страниц
    self.PagesContainer = Instance.new("Folder")
    self.PagesContainer.Parent = self.MainFrame

    self.FirstTab = true
    return self
end

-- Создание вкладки
function Library:AddTab(tabName, iconText)
    local tabObj = {}

    local TabButton = Instance.new("TextButton")
    TabButton.Parent = self.TabList
    TabButton.BackgroundColor3 = self.Theme.ElementBg
    TabButton.Size = UDim2.new(1, 0, 0, 38)
    TabButton.AutoButtonColor = false
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.Text = "    " .. (iconText or "▪") .. "    " .. tabName
    TabButton.TextColor3 = self.Theme.DarkText
    TabButton.TextSize = 12
    TabButton.TextXAlignment = Enum.TextXAlignment.Left

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Parent = TabButton
    TabStroke.Color = self.Theme.Stroke
    TabStroke.Thickness = 1

    -- Страница
    local PageContent = Instance.new("ScrollingFrame")
    PageContent.Parent = self.PagesContainer
    PageContent.Active = true
    PageContent.BackgroundTransparency = 1
    PageContent.Position = UDim2.new(0, 164, 0, 52)
    PageContent.Size = UDim2.new(1, -176, 1, -64)
    PageContent.Visible = false
    PageContent.CanvasSize = UDim2.new(0, 0, 2, 0)
    PageContent.ScrollBarThickness = 3
    PageContent.ScrollBarImageColor3 = self.Theme.Accent

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = PageContent
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)

    if self.FirstTab then
        PageContent.Visible = true
        TabButton.TextColor3 = self.Theme.Text
        TabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        TabStroke.Color = self.Theme.Accent
        self.FirstTab = false
    end

    TabButton.MouseButton1Click:Connect(function()
        for _, page in pairs(self.PagesContainer:GetChildren()) do if page:IsA("ScrollingFrame") then page.Visible = false end end
        for _, btn in pairs(self.TabList:GetChildren()) do
            if btn:IsA("TextButton") then
                TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = self.Theme.DarkText, BackgroundColor3 = self.Theme.ElementBg}):Play()
                btn.UIStroke.Color = self.Theme.Stroke
            end
        end
        PageContent.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = self.Theme.Text, BackgroundColor3 = Color3.fromRGB(24, 24, 32)}):Play()
        TabStroke.Color = self.Theme.Accent
    end)

    -- Элемент: Toggle
    function tabObj:AddToggle(text, callback)
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Parent = PageContent
        ToggleBtn.BackgroundColor3 = self.Theme.ElementBg
        ToggleBtn.Size = UDim2.new(1, -10, 0, 38)
        ToggleBtn.AutoButtonColor = false
        ToggleBtn.Font = Enum.Font.Gotham
        ToggleBtn.Text = "  " .. text
        ToggleBtn.TextColor3 = self.Theme.Text
        ToggleBtn.TextSize = 12
        ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = ToggleBtn

        local Stroke = Instance.new("UIStroke")
        Stroke.Parent = ToggleBtn
        Stroke.Color = self.Theme.Stroke
        Stroke.Thickness = 1

        local Indicator = Instance.new("Frame")
        Indicator.Parent = ToggleBtn
        Indicator.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        Indicator.Position = UDim2.new(1, -32, 0.5, -9)
        Indicator.Size = UDim2.new(0, 18, 0, 18)

        local IndCorner = Instance.new("UICorner")
        IndCorner.CornerRadius = UDim.new(0, 4)
        IndCorner.Parent = Indicator

        local state = false
        ToggleBtn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(Indicator, TweenInfo.new(0.15), {
                BackgroundColor3 = state and self.Theme.Accent or Color3.fromRGB(28, 28, 36)
            }):Play()
            pcall(callback, state)
        end)
    end

    -- Элемент: Slider (ползунок)
    function tabObj:AddSlider(text, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Parent = PageContent
        SliderFrame.BackgroundColor3 = self.Theme.ElementBg
        SliderFrame.Size = UDim2.new(1, -10, 0, 52)

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = SliderFrame

        local Stroke = Instance.new("UIStroke")
        Stroke.Parent = SliderFrame
        Stroke.Color = self.Theme.Stroke
        Stroke.Thickness = 1

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Parent = SliderFrame
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Position = UDim2.new(0, 10, 0, 8)
        TitleLabel.Size = UDim2.new(1, -20, 0, 18)
        TitleLabel.Font = Enum.Font.Gotham
        TitleLabel.Text = text
        TitleLabel.TextColor3 = self.Theme.Text
        TitleLabel.TextSize = 12
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = SliderFrame
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(0, 10, 0, 8)
        ValueLabel.Size = UDim2.new(1, -20, 0, 18)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(default or min)
        ValueLabel.TextColor3 = self.Theme.Accent
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

        local Track = Instance.new("Frame")
        Track.Parent = SliderFrame
        Track.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        Track.Position = UDim2.new(0, 10, 0, 34)
        Track.Size = UDim2.new(1, -20, 0, 6)

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track

        local Fill = Instance.new("Frame")
        Fill.Parent = Track
        Fill.BackgroundColor3 = self.Theme.Accent
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill

        local dragging = false
        local function update(input)
            local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + ((max - min) * pos))
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            ValueLabel.Text = tostring(val)
            pcall(callback, val)
        end

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
        end)
    end

    -- Элемент: Dropdown (выпадающий список)
    function tabObj:AddDropdown(text, options, callback)
        local opened = false
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Parent = PageContent
        DropdownFrame.BackgroundColor3 = self.Theme.ElementBg
        DropdownFrame.Size = UDim2.new(1, -10, 0, 38)
        DropdownFrame.ClipsDescendants = true

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = DropdownFrame

        local Stroke = Instance.new("UIStroke")
        Stroke.Parent = DropdownFrame
        Stroke.Color = self.Theme.Stroke
        Stroke.Thickness = 1

        local DropBtn = Instance.new("TextButton")
        DropBtn.Parent = DropdownFrame
        DropBtn.BackgroundTransparency = 1
        DropBtn.Size = UDim2.new(1, 0, 0, 38)
        DropBtn.Font = Enum.Font.Gotham
        DropBtn.Text = "  " .. text .. " : " .. (options[1] or "")
        DropBtn.TextColor3 = self.Theme.Text
        DropBtn.TextSize = 12
        DropBtn.TextXAlignment = Enum.TextXAlignment.Left

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Parent = DropdownFrame
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 2)

        local totalHeight = 40
        for _, opt in ipairs(options) do
            totalHeight = totalHeight + 32
            local OptBtn = Instance.new("TextButton")
            OptBtn.Parent = DropdownFrame
            OptBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            OptBtn.Size = UDim2.new(1, 0, 0, 30)
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.Text = "    " .. opt
            OptBtn.TextColor3 = self.Theme.DarkText
            OptBtn.TextSize = 11
            OptBtn.TextXAlignment = Enum.TextXAlignment.Left

            OptBtn.MouseEnter:Connect(function() TweenService:Create(OptBtn, TweenInfo.new(0.1), {TextColor3 = self.Theme.Text}):Play() end)
            OptBtn.MouseLeave:Connect(function() TweenService:Create(OptBtn, TweenInfo.new(0.1), {TextColor3 = self.Theme.DarkText}):Play() end)

            OptBtn.MouseButton1Click:Connect(function()
                DropBtn.Text = "  " .. text .. " : " .. opt
                opened = false
                TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 38)}):Play()
                pcall(callback, opt)
            end)
        end

        DropBtn.MouseButton1Click:Connect(function()
            opened = not opened
            TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {
                Size = opened and UDim2.new(1, -10, 0, totalHeight) or UDim2.new(1, -10, 0, 38)
            }):Play()
        end)
    end

    return tabObj
end

return Library
