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

-- Вспомогательные иконки
local IconSVGs = {
    Sword = "rbxassetid://10747373151",
    Shield = "rbxassetid://10747372072",
    Settings = "rbxassetid://10734950309",
    User = "rbxassetid://10747372072",
    Search = "rbxassetid://10734939222",
    Sparkles = "rbxassetid://10734950309",
    Zap = "rbxassetid://10734950309"
}

function NodiumUI.CreateWindow(config)
    local self = setmetatable({}, NodiumUI)
    
    local options = {
        Title = "Nodium",
        Font = Enum.Font.SourceSansBold,
        BackgroundColor = Color3.fromRGB(15, 15, 20),
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
    
    local windowWidth = isMobile and math.clamp(math.floor(viewportSize.X * 0.75), 340, 500) or 750
    local windowHeight = isMobile and math.clamp(math.floor(viewportSize.Y * 0.72), 280, 400) or 480

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(windowWidth, windowHeight)
    mainFrame.Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    mainFrame.BackgroundColor3 = options.BackgroundColor
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- Drag System
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

    -- TopBar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 42)
    topBar.BackgroundColor3 = options.TopBarColor
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = topBar

    local titleContainer = Instance.new("Frame")
    titleContainer.Size = UDim2.new(0, isMobile and 110 : 160, 1, 0)
    titleContainer.Position = UDim2.new(0, 12, 0, 0)
    titleContainer.BackgroundTransparency = 1
    titleContainer.Parent = topBar

    local logoIcon = Instance.new("Frame")
    logoIcon.Size = UDim2.new(0, 16, 0, 16)
    logoIcon.Position = UDim2.new(0, 0, 0.5, -8)
    logoIcon.BackgroundColor3 = options.AccentColor
    logoIcon.BorderSizePixel = 0
    logoIcon.Parent = titleContainer

    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 4)
    logoCorner.Parent = logoIcon

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -24, 1, 0)
    titleLbl.Position = UDim2.new(0, 22, 0, 0)
    titleLbl.Text = options.Title
    titleLbl.TextColor3 = options.TextColor
    titleLbl.Font = options.Font
    titleLbl.TextSize = isMobile and 12 or 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = titleContainer

    -- Правые кнопки
    local rightControls = Instance.new("Frame")
    rightControls.Size = UDim2.new(0, 60, 1, 0)
    rightControls.Position = UDim2.new(1, -65, 0, 0)
    rightControls.BackgroundTransparency = 1
    rightControls.Parent = topBar

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.FillDirection = Enum.FillDirection.Horizontal
    rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    rightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rightLayout.Padding = UDim.new(0, 4)
    rightLayout.Parent = rightControls

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = options.SubTextColor
    minimizeBtn.Font = options.Font
    minimizeBtn.TextSize = 13
    minimizeBtn.Parent = rightControls

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = options.SubTextColor
    closeBtn.Font = options.Font
    closeBtn.TextSize = 14
    closeBtn.Parent = rightControls

    -- Контейнер для вкладок (сверху в центре)
    local tabsContainer = Instance.new("ScrollingFrame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, -190, 1, 0)
    tabsContainer.Position = UDim2.new(0, 125, 0, 0)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.ScrollBarThickness = 0
    tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsContainer.Parent = topBar

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabsLayout.Padding = UDim.new(0, 8)
    tabsLayout.Parent = tabsContainer

    tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabsContainer.CanvasSize = UDim2.new(0, tabsLayout.AbsoluteContentSize.X + 10, 0, 0)
    end)

    -- Контейнер страниц
    local container = Instance.new("Frame")
    container.Name = "ContentContainer"
    container.Size = UDim2.new(1, -16, 1, -52)
    container.Position = UDim2.new(0, 8, 0, 46)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

    -- Уведомления (Notifications Holder)
    local notifyHolder = Instance.new("Folder")
    notifyHolder.Name = "Notifications"
    notifyHolder.Parent = screenGui

    local notifyLayout = Instance.new("UIListLayout")
    notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifyLayout.Padding = UDim.new(0, 6)
    notifyLayout.Parent = notifyHolder

    -- Сворачивание
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    self.ScreenGui = screenGui
    self.Container = container
    self.TabsContainer = tabsContainer
    self.Tabs = {}

    return self
end

-- Система уведомлений
function NodiumUI:Notify(config)
    local options = self.Options or {TopBarColor = Color3.fromRGB(22, 22, 30), TextColor = Color3.fromRGB(230, 230, 240), AccentColor = Color3.fromRGB(115, 100, 235)}
    
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 3

    local notifyFrame = Instance.new("Frame")
    notifyFrame.Size = UDim2.new(0, 240, 0, 55)
    notifyFrame.BackgroundColor3 = options.TopBarColor
    notifyFrame.BorderSizePixel = 0
    notifyFrame.BackgroundTransparency = 1
    notifyFrame.Parent = self.ScreenGui.Notifications

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notifyFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = options.AccentColor
    stroke.Transparency = 0.5
    stroke.Thickness = 1
    stroke.Parent = notifyFrame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -16, 0, 20)
    titleLbl.Position = UDim2.new(0, 8, 0, 6)
    titleLbl.Text = title
    titleLbl.TextColor3 = options.TextColor
    titleLbl.Font = Enum.Font.SourceSansBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = notifyFrame

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -16, 0, 20)
    descLbl.Position = UDim2.new(0, 8, 0, 26)
    descLbl.Text = content
    descLbl.TextColor3 = Color3.fromRGB(170, 170, 185)
    descLbl.Font = Enum.Font.SourceSans
    descLbl.TextSize = 12
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.BackgroundTransparency = 1
    descLbl.Parent = notifyFrame

    tween(notifyFrame, TweenInfo.new(0.25), {BackgroundTransparency = 0.1})

    task.delay(duration, function()
        tween(notifyFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1})
        task.wait(0.25)
        notifyFrame:Destroy()
    end)
end

-- Создание вкладки
function NodiumUI:CreateTab(tabName)
    local options = self.Options
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName .. "_Btn"
    tabBtn.Size = UDim2.new(0, 85, 0, 28)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = options.SubTextColor
    tabBtn.Font = options.Font
    tabBtn.TextSize = 12
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = self.TabsContainer

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabBtn

    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "_Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = self.Container

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.Parent = page

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 15)
    end)

    tabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Page.Visible = false
            tween(tab.Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 40), TextColor3 = options.SubTextColor})
        end
        page.Visible = true
        tween(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = options.AccentColor, TextColor3 = Color3.fromRGB(255, 255, 255)})
    end)

    local tabObj = { Button = tabBtn, Page = page, ParentUI = self }
    table.insert(self.Tabs, tabObj)

    if #self.Tabs == 1 then
        page.Visible = true
        tabBtn.BackgroundColor3 = options.AccentColor
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    -- Элементы внутри вкладки
    function tabObj:CreateToggle(config)
        local parentOptions = self.ParentUI.Options
        local name = config.Name or "Toggle"
        local default = config.CurrentValue or false
        local callback = config.Callback or function() end

        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 38)
        toggleFrame.BackgroundColor3 = parentOptions.CardColor
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = page

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = toggleFrame

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -60, 1, 0)
        titleLbl.Position = UDim2.new(0, 12, 0, 0)
        titleLbl.Text = name
        titleLbl.TextColor3 = parentOptions.TextColor
        titleLbl.Font = parentOptions.Font
        titleLbl.TextSize = 13
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.BackgroundTransparency = 1
        titleLbl.Parent = toggleFrame

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 36, 0, 18)
        toggleBtn.Position = UDim2.new(1, -48, 0.5, -9)
        toggleBtn.BackgroundColor3 = default and parentOptions.AccentColor or Color3.fromRGB(45, 45, 55)
        toggleBtn.Text = ""
        toggleBtn.AutoButtonColor = false
        toggleBtn.Parent = toggleFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(1, 0)
        btnCorner.Parent = toggleBtn

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 14, 0, 14)
        circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        circle.Parent = toggleBtn

        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circle

        local state = default
        toggleBtn.MouseButton1Click:Connect(function()
            state = not state
            if state then
                tween(toggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = parentOptions.AccentColor})
                tween(circle, TweenInfo.new(0.15), {Position = UDim2.new(1, -16, 0.5, -7)})
            else
                tween(toggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)})
                tween(circle, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7)})
            end
            pcall(callback, state)
        end)
    end

    function tabObj:CreateButton(config)
        local parentOptions = self.ParentUI.Options
        local name = config.Name or "Button"
        local callback = config.Callback or function() end

        local btnFrame = Instance.new("TextButton")
        btnFrame.Size = UDim2.new(1, 0, 0, 38)
        btnFrame.BackgroundColor3 = parentOptions.CardColor
        btnFrame.BorderSizePixel = 0
        btnFrame.AutoButtonColor = false
        btnFrame.Text = ""
        btnFrame.Parent = page

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btnFrame

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -20, 1, 0)
        titleLbl.Position = UDim2.new(0, 12, 0, 0)
        titleLbl.Text = name
        titleLbl.TextColor3 = parentOptions.TextColor
        titleLbl.Font = parentOptions.Font
        titleLbl.TextSize = 13
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.BackgroundTransparency = 1
        titleLbl.Parent = btnFrame

        btnFrame.MouseButton1Click:Connect(function()
            tween(btnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)})
            task.delay(0.1, function()
                tween(btnFrame, TweenInfo.new(0.1), {BackgroundColor3 = parentOptions.CardColor})
            end)
            pcall(callback)
        end)
    end

    return tabObj
end

return NodiumUI
