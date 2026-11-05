-- ============================================
-- DeepSeek Capsule UI (不可拖动版)
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

local function getHiddenGui(name)
    local g = Instance.new("ScreenGui"); g.Name = name; g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    if syn and syn.protect_gui then syn.protect_gui(g); g.Parent = game:GetService("CoreGui")
    elseif gethui then g.Parent = gethui() else g.Parent = LP:WaitForChild("PlayerGui") end
    return g
end

local gui = getHiddenGui("DeepSeekUI_" .. math.random(1000, 9999))

-- 基础容器
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.AnchorPoint = Vector2.new(0.5, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0, 30) -- 固定在中上方
mainFrame.Size = UDim2.fromOffset(140, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = false -- 不可拖动
mainFrame.Parent = gui

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(1, 0) -- 初始完全圆角（胶囊）

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(60, 60, 70)
stroke.Thickness = 1.5

-- 胶囊文字
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, 0, 0, 40)
titleText.Position = UDim2.new(0, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DeepSeek"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 15
titleText.ZIndex = 2
titleText.Parent = mainFrame

-- 内容区域（初始隐藏）
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -60)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundTransparency = 1
content.Visible = false
content.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout", content)
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 状态
local isOpen = false
local isAnimating = false

-- 点击区域 (覆盖整个面板用于触发动画)
local clickBtn = Instance.new("TextButton")
clickBtn.Size = UDim2.fromScale(1, 1)
clickBtn.BackgroundTransparency = 1
clickBtn.Text = ""
clickBtn.ZIndex = 3
clickBtn.Parent = mainFrame

-- 添加占位功能按钮
local function addDemoButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
end
addDemoButton("功能占位 1")
addDemoButton("功能占位 2")
addDemoButton("功能占位 3")

-- 展开/收起动画逻辑
clickBtn.MouseButton1Click:Connect(function()
    if isAnimating then return end
    isAnimating = true
    isOpen = not isOpen

    if isOpen then
        -- 展开动画
        content.Visible = true
        
        local goalSize = UDim2.fromOffset(280, 320)
        local goalCorner = UDim.new(0, 12)
        
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(mainFrame, tweenInfo, {Size = goalSize}):Play()
        TweenService:Create(uiCorner, tweenInfo, {CornerRadius = goalCorner}):Play()
        
        task.wait(0.4)
        
    else
        -- 收起动画
        content.Visible = false
        
        local goalSize = UDim2.fromOffset(140, 40)
        local goalCorner = UDim.new(1, 0)
        
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        TweenService:Create(mainFrame, tweenInfo, {Size = goalSize}):Play()
        TweenService:Create(uiCorner, tweenInfo, {CornerRadius = goalCorner}):Play()
        
        task.wait(0.4)
    end
    
    isAnimating = false
end)

print("[DeepSeek UI] 不可拖动版加载完毕")