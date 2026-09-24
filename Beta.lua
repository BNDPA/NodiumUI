local Library = {}
Library.__index = Library

-- Базовый словарь иконок из репозитория (можно расширять ID картинок)
local Icons = {
    Sword = "rbxassetid://6023426915", -- Пример Asset ID для меча
    Settings = "rbxassetid://6031280882",
    Home = "rbxassetid://6031302932"
}

function Library.new(titleText)
    local self = setmetatable({}, Library)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NodiumUI"
    self.ScreenGui.Parent = game.CoreGui
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    self.MainFrame.Size = UDim2.new(0, 500, 0, 350)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.MainFrame

    -- Панель для верхних вкладок (Tabs)
    self.TabBar = Instance.new("ScrollingFrame")
    self.TabBar.Name = "TabBar"
    self.TabBar.Parent = self.MainFrame
    self.TabBar.BackgroundTransparency = 1
    self.TabBar.Position = UDim2.new(0, 10, 0, 10)
    self.TabBar.Size = UDim2.new(1, -20, 0, 40)
    self.TabBar.CanvasSize = UDim2.new(2, 0, 0, 0)
    self.TabBar.ScrollBarThickness = 0

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = self.TabBar
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 8)

    -- Контейнер для страниц
    self.PagesContainer = Instance.new("Frame")
    self.PagesContainer.Name = "PagesContainer"
    self.PagesContainer.Parent = self.MainFrame
    self.PagesContainer.BackgroundTransparency = 1
    self.PagesContainer.Position = UDim2.new(0, 10, 0, 60)
    self.PagesContainer.Size = UDim2.new(1, -20, 1, -70)

    return self
end

-- Метод для создания вкладки с иконкой (например, "Sword")
function Library:AddTab(iconName)
    local TabButton = Instance.new("ImageButton")
    TabButton.Parent = self.TabBar
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabButton.Size = UDim2.new(0, 40, 0, 40)
    TabButton.AutoButtonColor = false
    
    -- Подставляем картинку из словаря по имени или используем дефолт
    TabButton.Image = Icons[iconName] or "rbxassetid://6031302932"

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = TabButton

    -- Контейнер содержимого вкладки
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Parent = self.PagesContainer
    TabContent.Active = true
    TabContent.BackgroundTransparency = 1
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Visible = false
    TabContent.CanvasSize = UDim2.new(0, 0, 2, 0)
    TabContent.ScrollBarThickness = 4

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = TabContent
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)

    -- Логика переключения
    TabButton.MouseButton1Click:Connect(function()
        for _, content in pairs(self.PagesContainer:GetChildren()) do
            if content:IsA("ScrollingFrame") then
                content.Visible = false
            end
        end
        TabContent.Visible = true
    end)

    -- Если это первая вкладка — делаем видимой по умолчанию
    if #self.PagesContainer:GetChildren() == 1 then
        TabContent.Visible = true
    end

    -- Объект вкладки для добавления элементов внутрь
    local TabObj = {}
    function TabObj:AddToggle(toggleText, callback)
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = TabContent
        ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        ToggleButton.Size = UDim2.new(1, 0, 0, 32)
        ToggleButton.AutoButtonColor = false
        ToggleButton.Font = Enum.Font.Gotham
        ToggleButton.Text = "  " .. toggleText
        ToggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        ToggleButton.TextSize, ToggleButton.TextXAlignment = 13, Enum.TextXAlignment.Left

        local TCorner = Instance.new("UICorner")
        TCorner.CornerRadius = UDim.new(0, 6)
        TCorner.Parent = ToggleButton

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

    return TabObj
end

return Library
