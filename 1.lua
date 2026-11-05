-- ============================================
-- DeepSeek Capsule UI (极致丝滑 · 精准点击版)
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local function getHiddenGui(name)
    local g = Instance.new("ScreenGui"); g.Name = name; g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    if syn and syn.protect_gui then syn.protect_gui(g); g.Parent = game:GetService("CoreGui")
    elseif gethui then g.Parent = gethui() else g.Parent = LP:WaitForChild("PlayerGui") end
    return g
end

local gui = getHiddenGui("DeepSeekUI_" .. math.random(1000, 9999))

-- 主容器 (固定中上方，不可拖动)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.AnchorPoint = Vector2.new(0.5, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0, 30) 
mainFrame.Size = UDim2.fromOffset(110, 32) -- 缩小后的胶囊尺寸
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = false
mainFrame.Parent = gui

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(1, 0) 

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(60, 60, 70)
stroke.Thickness = 1.5

-- 标题文字
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, 0, 0, 32)
titleText.Position = UDim2.new(0, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DeepSeek"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
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

-- 状态机
local isOpen = false
local isAnimating = false

-- ==========================================
-- 交互层：区分展开与收起
-- ==========================================

-- 1. 胶囊展开按钮 (仅在未展开时生效)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.fromScale(1, 1)
openBtn.BackgroundTransparency = 1
openBtn.Text = ""
openBtn.ZIndex = 3
openBtn.Parent = mainFrame

-- 2. 标题关闭按钮 (仅在展开时生效，覆盖在文字上方)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1, 0, 0, 44) -- 覆盖顶部标题区域
closeBtn.Position = UDim2.new(0, 0, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = ""
closeBtn.ZIndex = 4
closeBtn.Visible = false
closeBtn.Parent = mainFrame

-- 占位功能按钮
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

-- ==========================================
-- 动画核心
-- ==========================================
local openTweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local function toggleUI(openState)
    if isAnimating then return end
    isAnimating = true
    isOpen = openState

    if isOpen then
        -- 准备展开
        content.Visible = true
        openBtn.Visible = false
        closeBtn.Visible = true
        
        -- 执行展开动画
        TweenService:Create(mainFrame, openTweenInfo, {Size = UDim2.fromOffset(280, 320)}):Play()
        TweenService:Create(uiCorner, openTweenInfo, {CornerRadius = UDim.new(0, 12)}):Play()
        TweenService:Create(titleText, openTweenInfo, {TextSize = 15, Position = UDim2.new(0, 0, 0, 4)}):Play()
        
        task.wait(0.45)
        
    else
        -- 准备收起
        content.Visible = false
        closeBtn.Visible = false
        
        -- 执行收起动画
        TweenService:Create(mainFrame, closeTweenInfo, {Size = UDim2.fromOffset(110, 32)}):Play()
        TweenService:Create(uiCorner, closeTweenInfo, {CornerRadius = UDim.new(1, 0)}):Play()
        TweenService:Create(titleText, closeTweenInfo, {TextSize = 13, Position = UDim2.new(0, 0, 0, 0)}):Play()
        
        task.wait(0.4)
        openBtn.Visible = true
    end
    
    isAnimating = false
end

-- 绑定事件
openBtn.MouseButton1Click:Connect(function() toggleUI(true) end)
closeBtn.MouseButton1Click:Connect(function() toggleUI(false) end)

print("[DeepSeek UI] 丝滑展开/收起 版加载完毕")