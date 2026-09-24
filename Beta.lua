local Library = {}
Library.__index = Library

-- Функция инициализации библиотеки и создания главного окна
function Library.new(titleText)
    local self = setmetatable({}, Library)
    
    -- Главный контейнер (ScreenGui)
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CustomLibrary"
    self.ScreenGui.Parent = game.CoreGui
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Основное окно
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    self.MainFrame.Size = UDim2.new(0, 450, 0, 300)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.MainFrame

    -- Шапка/Заголовок
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Parent = self.MainFrame
    self.TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.TopBar.Size = UDim2.new(1, 0, 0, 35)
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = self.TopBar

    self.Title = Instance.new("TextLabel")
    self.Title.Parent = self.TopBar
    self.Title.BackgroundTransparency = 1
    self.Title.Position = UDim2.new(0, 12, 0, 0)
    self.Title.Size = UDim2.new(1, -24, 1, 0)
    self.Title.Font = Enum.Font.GothamBold
    self.Title.Text = titleText or "UI Library"
    self.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Title.TextSize = 14
    self.Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Контейнер для элементов (вкладок/тумблеров)
    self.Container = Instance.new("ScrollingFrame")
    self.Container.Parent = self.MainFrame
    self.Container.Active = true
    self.Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.Container.BorderSizePixel = 0
    self.Container.Position = UDim2.new(0, 10, 0, 45)
    self.Container.Size = UDim2.new(1, -20, 1, -55)
    self.Container.CanvasSize = UDim2.new(0, 0, 2, 0)
    self.Container.ScrollBarThickness = 4

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = self.Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)

    return self
end

-- Метод для добавления переключателя (Toggle)
function Library:AddToggle(toggleText, callback)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = self.Container
    ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleButton.Size = UDim2.new(1, 0, 0, 32)
    ToggleButton.AutoButtonColor = false
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Text = "  " .. toggleText
    ToggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleButton.TextSize, ToggleButton.TextXAlignment = 13, Enum.TextXAlignment.Left

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleButton

    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Parent = ToggleButton
    StatusIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    StatusIndicator.Position = UDim2.new(1, -26, 0.5, -8)
    StatusIndicator.Size = UDim2.new(0, 16, 0, 16)

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 4)
    IndicatorCorner.Parent = StatusIndicator

    local toggled = false
    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        StatusIndicator.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
        pcall(callback, toggled)
    end)
end

return Library
