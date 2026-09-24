local Library = {}
Library.__index = Library

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function Library.new(scriptName, iconUrl)
    local self = setmetatable({}, Library)
    
    -- Главный экран
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "NodiumScript_UI"
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Основное окно (стиль Expensive / Obsidian)
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    self.MainFrame.Size = UDim2.new(0, 450, 0, 300)

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = self.MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = self.MainFrame
    MainStroke.Color = Color3.fromRGB(45, 45, 55)
    MainStroke.Thickness = 1

    -- Шапка
    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Parent = self.MainFrame
    self.TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Size = UDim2.new(1, 0, 0, 32)

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 6)
    TopCorner.Parent = self.TopBar

    local TopFix = Instance.new("Frame")
    TopFix.Parent = self.TopBar
    TopFix.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    TopFix.BorderSizePixel = 0
    TopFix.Position = UDim2.new(0, 0, 1, -5)
    TopFix.Size = UDim2.new(1, 0, 0, 5)

    -- Название скрипта в шапке
    self.Title = Instance.new("TextLabel")
    self.Title.Parent = self.TopBar
    self.Title.BackgroundTransparency = 1
    self.Title.Position = UDim2.new(0, 12, 0, 0)
    self.Title.Size = UDim2.new(1, -100, 1, 0)
    self.Title.Font = Enum.Font.GothamBold
    self.Title.Text = scriptName or "Script Hub"
    self.Title.TextColor3 = Color3.fromRGB(220, 220, 230)
    self.Title.TextSize = 13
    self.Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Кнопка закрытия (×)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = self.TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(150, 150, 160)
    CloseButton.TextSize = 16

    CloseButton.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)

    -- Кнопка сворачивания (-)
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Parent = self.TopBar
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
    MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(150, 150, 160)
    MinimizeButton.TextSize = 16

    -- Создание круглой плавающей кнопки (логотипа) для развертывания
    local FloatingButton = Instance.new("ImageButton")
    FloatingButton.Name = "FloatingLogo"
    FloatingButton.Parent = self.ScreenGui
    FloatingButton.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    FloatingButton.Position = UDim2.new(0, 30, 0.5, -25)
    FloatingButton.Size = UDim2.new(0, 45, 0, 45)
    FloatingButton.Visible = false
    FloatingButton.AutoButtonColor = false

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0) -- Делает кнопку идеально круглой
    FloatCorner.Parent = FloatingButton

    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Parent = FloatingButton
    FloatStroke.Color = Color3.fromRGB(0, 170, 255)
    FloatStroke.Thickness = 2

    -- Загрузка картинки из репозитория (прямая ссылка, например на logo.png)
    if iconUrl then
        pcall(function()
            if writefile and syn and syn.request then
                -- Если эксплойт поддерживает скачивание файлов локально для getcustomasset
                local response = syn.request({Url = iconUrl, Method = "GET"})
                if response.StatusCode == 200 then
                    local fileName = "nodium_logo_" .. math.random(1000, 9999) .. ".png"
                    writefile(fileName, response.Body)
                    FloatingButton.Image = getcustomasset(fileName)
                end
            else
                -- Универсальный метод через текстурные ссылки / обход
                FloatingButton.Image = iconUrl
            end
        end)
    end

    -- Логика свернуть / развернуть
    MinimizeButton.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = false
        FloatingButton.Visible = true
    end)

    FloatingButton.MouseButton1Click:Connect(function()
        FloatingButton.Visible = false
        self.MainFrame.Visible = true
    end)

    -- Перетаскивание главного окна
    local dragging, dragInput, dragStart, startPos
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Перетаскивание круглой плавающей кнопки по экрану мобилы/ПК
    local fDragging, fInput, fStart, fPos
    FloatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fDragging = true
            fStart = input.Position
            fPos = FloatingButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then fDragging = false end
            end)
        end
    end)

    FloatingButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            fInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == fInput and fDragging then
            local delta = input.Position - fStart
            FloatingButton.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + delta.X, fPos.Y.Scale, fPos.Y.Offset + delta.Y)
        end
    end)

    -- Контейнер для элементов скрипта (без вкладок)
    self.Container = Instance.new("ScrollingFrame")
    self.Container.Parent = self.MainFrame
    self.Container.Active = true
    self.Container.BackgroundTransparency = 1
    self.Container.Position = UDim2.new(0, 10, 0, 42)
    self.Container.Size = UDim2.new(1, -20, 1, -50)
    self.Container.CanvasSize = UDim2.new(0, 0, 2, 0)
    self.Container.ScrollBarThickness = 2
    self.Container.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = self.Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)

    return self
end

-- Метод добавления тумблера
function Library:AddToggle(toggleText, callback)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = self.Container
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

    local TStroke = Instance.new("UIStroke")
    TStroke.Parent = ToggleButton
    TStroke.Color = Color3.fromRGB(35, 35, 45)
    TStroke.Thickness = 1

    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Parent = ToggleButton
    StatusIndicator.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    StatusIndicator.Position = UDim2.new(1, -24, 0.5, -7)
    StatusIndicator.Size = Instance.new("Frame") and UDim2.new(0, 14, 0, 14)

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

return Library

