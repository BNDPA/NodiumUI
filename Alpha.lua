local NodiumUI = {}
NodiumUI.__index = NodiumUI

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function NodiumUI.CreateWindow(config)
    local self = setmetatable({}, NodiumUI)
    local title = type(config) == "string" and config or (config.Title or "Nodium")

    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "Nodium_" .. title
    sg.ResetOnSpawn = false

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.fromOffset(500, 350)
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    -- TopBar
    local top = Instance.new("TextLabel", main)
    top.Size = UDim2.new(1, 0, 0, 35)
    top.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    top.Text = "  " .. title
    top.TextColor3 = Color3.fromRGB(240, 240, 255)
    top.Font = Enum.Font.SourceSansBold
    top.TextSize = 14
    top.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)

    -- Tabs Holder
    local tabsH = Instance.new("ScrollingFrame", main)
    tabsH.Size = UDim2.new(0, 120, 1, -45)
    tabsH.Position = UDim2.new(0, 5, 0, 40)
    tabsH.BackgroundTransparency = 1
    tabsH.ScrollBarThickness = 0
    local tLayout = Instance.new("UIListLayout", tabsH)
    tLayout.Padding = UDim.new(0, 5)

    -- Pages Holder
    local pagesH = Instance.new("Folder", main)
    self.Tabs = {}

    function self:CreateTab(name)
        local btn = Instance.new("TextButton", tabsH)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(150, 150, 165)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local page = Instance.new("ScrollingFrame", pagesH)
        page.Size = UDim2.new(1, -135, 1, -45)
        page.Position = UDim2.new(0, 130, 0, 40)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 3
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
            togg.Size = UDim2.new(1, 0, 0, 32)
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
            box.Size = UDim2.new(0, 32, 0, 16)
            box.Position = UDim2.new(1, -40, 0.5, -8)
            box.BackgroundColor3 = status and Color3.fromRGB(115, 100, 235) or Color3.fromRGB(45, 45, 55)
            Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)

            togg.MouseButton1Click:Connect(function()
                status = not status
                box.BackgroundColor3 = status and Color3.fromRGB(115, 100, 235) or Color3.fromRGB(45, 45, 55)
                pcall(cfg.Callback, status)
            end)
        end

        function tabObj:CreateButton(cfg)
            local btnElem = Instance.new("TextButton", page)
            btnElem.Size = UDim2.new(1, 0, 0, 32)
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
