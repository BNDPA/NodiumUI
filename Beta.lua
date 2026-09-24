local Library = {}
Library.__index = Library

-- Сервисы
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Словарь иконок
local Icons = {
    Sword = "rbxassetid://6023426915",
    Settings = "rbxassetid://6031280882",
    Home = "rbxassetid://6031302932"
}

function Library.new(titleText)
    local self = setmetatable({}, Library)
    
    -- Главный экран
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NodiumUI_Expensive"
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Основное окно (стиль Expensive / Obsidian: темно-серый, тонкая граница)
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    self.MainFrame.Size = UDim2.new(0, 500, 0, 340)

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = self.MainFrame

    -- Тонкая обводка окна (в стиле читов)
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = self.MainFrame
    MainStroke.Color = Color3.fromRGB(45, 45, 55)
    MainStroke.Thickness = 1

    -- Верхняя панель (для перетаскивания и названия)
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Parent = self.MainFrame
    self.TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Size = UDim2.new(1, 0, 0, 35)

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 6)
    TopCorner.Parent = self.TopBar

    -- Исправление нижних углов шапки, чтобы они были прямыми
    local TopFix = Instance.new("Frame")
    TopFix.Parent = self.TopBar
    TopFix.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    TopFix.BorderSizePixel = 0
    TopFix.Position = UDim2.new(0, 0, 1, -5)
    TopFix.Size = UDim2.new(1, 0, 0, 5)

    -- Название чита/хуба в шапке
    self.Title = Instance.new("TextLabel")
    self.Title.Parent = self.TopBar
    self.Title.BackgroundTransparency = 1
    self.Title.Position = UDim2.new(0, 12, 0, 0)
    self.Title.Size = UDim2.new(0, 200, 1, 0)
    self.Title.Font = Enum.Font.GothamBold
    self.Title.Text = titleText or "Nodium | Expensive Style"
    self.Title.TextColor3 = Color3.fromRGB(220, 220, 230)
    self.Title.TextSize = 13
    self.Title.TextXAlignment = Enum.TextXAlignment.Left

    -- ЛОГИКА ПЕРЕТАСКИВАНИЯ ОКНА МЫШКОЙ / ПАЛЬЦЕМ
    local dragging, dragInput, dragStart, startPos
    
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self.TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Панель для вкладок (справа от названия в шапке)
    self.TabBar = Instance.new("ScrollingFrame")
    self.TabBar.Name = "TabBar"
    self.TabBar.Parent = self.TopBar
    self.TabBar.BackgroundTransparency = 1
    self.TabBar.Position = UDim2.new(0, 220, 0, 4)
    self.TabBar.Size = UDim2.new(1, -230, 1, -4)
    self.TabBar.CanvasSize = UDim2.new(2, 0, 0, 0)
    self.TabBar.ScrollBarThickness = 0
    self.TabBar.ScrollingDirection = Enum.ScrollingDirection.Horizontal

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = self.TabBar
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

    -- Контейнер для страниц
    self.PagesContainer = Instance.new("Frame")
    self.PagesContainer.Name = "PagesContainer"
    self.PagesContainer.Parent = self.MainFrame
    self.PagesContainer.BackgroundTransparency = 1
    self.PagesContainer.Position = UDim2.new(0, 10, 0, 45)
    self.PagesContainer.Size = UDim2.new(1, -20, 1, -55)

    return self
end

-- Метод создания вкладки с иконкой
function Library:AddTab(iconName)
    local TabButton = Instance.new("ImageButton")
    TabButton.Parent = self.TabBar
    TabButton.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    TabButton.Size = UDim2.new(0, 28, 0, 28)
    TabButton.AutoButtonColor = false
    TabButton.Image = Icons[iconName] or Icons.Home
    TabButton.ImageColor3 = Color3.fromRGB(150, 150, 160)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = TabButton

    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Parent = self.PagesContainer
    TabContent.Active = true
    TabContent.BackgroundTransparency = 1
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Visible = false
    TabContent.CanvasSize = UDim2.new(0, 0, 2, 0)
    TabContent.ScrollBarThickness = 2
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = TabContent
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)

    TabButton.MouseButton1Click:Connect(function()
        for _, content in pairs(self.PagesContainer:GetChildren()) do
            if content:IsA("ScrollingFrame") then
                content.Visible = false
            end
        end
        for _, btn in pairs(self.TabBar:GetChildren()) do
            if btn:IsA("ImageButton") then
                TweenService:Create(btn, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 160)}):Play()
            end
        end
        TabContent.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(0, 170, 255)}):Play()
    end)

    if #self.PagesContainer:GetChildren() == 1 then
        TabContent.Visible = true
        TabButton.ImageColor3 = Color3.fromRGB(0, 170, 255)
    end

    local TabObj = {}
    function TabObj:AddToggle(toggleText, callback)
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = TabContent
        ToggleButton.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        ToggleButton.Size = UDim2.new(1, 0, 0, 30)
        ToggleButton.AutoButtonColor = false
        ToggleButton.Font = Enum.Font.Gotham
        ToggleButton.Text = "  " .. toggleText
        ToggleButton.TextColor3 = Color3.fromRGB(190, 190, 200)
        ToggleButton.TextSize = 12
        ToggleButton.TextXAlignment = Enum.TextXAlignment.Left

        local TCorner = Instance.new("UICorner")
        TCorner.CornerRadius = UDim.new(0, 4)
        TCorner.Parent = ToggleButton

        -- Тонкая рамка элемента управления в стиле Expensive
        local TStroke = Instance.new("UIStroke")
        TStroke.Parent = ToggleButton
        TStroke.Color = Color3.fromRGB(35, 35, 45)
        TStroke.Thickness = 1

        local StatusIndicator = Instance.new("Frame")
        StatusIndicator.Parent = ToggleButton
        StatusIndicator.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        StatusIndicator.Position = UDim2.new(1, -24, 0.5, -7)
        StatusIndicator.Size = UDim2.new(0, 14, 0, 14)

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 3)
        IndicatorCorner.Parent = StatusIndicator

        local toggled = false
        ToggleButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            TweenService:Create(StatusIndicator, TweenInfo.new(0.15), {
                BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 55)
            }):Play()
            pcall(callback, toggled)
        end)
    end

    return TabObj
end

return Library
