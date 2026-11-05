-- ============================================
-- DeepSeek Studio (Fluent Light + 胶囊展开)
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

local container = (gethui and gethui()) or game:GetService("CoreGui")

local mainGui = Instance.new("ScreenGui")
mainGui.Name = tostring(math.random(100000, 999999))
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = container

local Config = { ESP = false }

-- 颜色配置 (Fluent 浅色模式)
local Colors = {
    Bg = Color3.fromRGB(245, 246, 248),
    Panel = Color3.fromRGB(255, 255, 255),
    Sidebar = Color3.fromRGB(235, 237, 240),
    TextDark = Color3.fromRGB(30, 30, 30),
    TextLight = Color3.fromRGB(120, 120, 120),
    AccentBlue = Color3.fromRGB(0, 110, 255),
    ToggleOff = Color3.fromRGB(200, 200, 200),
    ToggleOn = Color3.fromRGB(0, 110, 255)
}

-- ==========================================
-- 主容器 (胶囊与面板的合体)
-- ==========================================
local Main = Instance.new("Frame")
Main.AnchorPoint = Vector2.new(0.5, 0)
Main.Position = UDim2.new(0.5, 0, 0, 30)
Main.Size = UDim2.fromOffset(110, 32) -- 初始胶囊尺寸
Main.BackgroundColor3 = Colors.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = mainGui
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(1, 0) -- 完全圆角

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(200, 200, 200)
MainStroke.Thickness = 1

-- 状态
local isOpen = false
local isAnimating = false

-- ==========================================
-- 胶囊状态 (收起时显示)
-- ==========================================
local CapsuleText = Instance.new("TextLabel")
CapsuleText.Size = UDim2.new(1, 0, 1, 0)
CapsuleText.BackgroundTransparency = 1
CapsuleText.Text = "DeepSeek"
CapsuleText.TextColor3 = Colors.TextDark
CapsuleText.Font = Enum.Font.GothamBold
CapsuleText.TextSize = 13
CapsuleText.ZIndex = 2
CapsuleText.Parent = Main

local CapsuleBtn = Instance.new("TextButton")
CapsuleBtn.Size = UDim2.fromScale(1, 1)
CapsuleBtn.BackgroundTransparency = 1
CapsuleBtn.Text = ""
CapsuleBtn.ZIndex = 3
CapsuleBtn.Parent = Main

-- ==========================================
-- 完整面板状态 (展开时显示)
-- ==========================================
local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.fromScale(1, 1)
MainContent.BackgroundTransparency = 1
MainContent.Visible = false
MainContent.Parent = Main

-- 顶部栏
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainContent

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(200, 30)
Title.Position = UDim2.fromOffset(16, 5)
Title.BackgroundTransparency = 1
Title.Text = "DeepSeek Studio"
Title.TextColor3 = Colors.TextDark
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- 关闭按钮 (收回胶囊)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(24, 24)
CloseBtn.Position = UDim2.new(1, -32, 0, 8)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Colors.TextLight
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.Parent = TopBar

-- ==========================================
-- 左侧导航栏
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(120, 250)
Sidebar.Position = UDim2.fromOffset(8, 40)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainContent
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

-- 左下角用户信息
local UserFrame = Instance.new("Frame")
UserFrame.Size = UDim2.new(1, -16, 0, 44)
UserFrame.Position = UDim2.new(0, 8, 1, -52)
UserFrame.BackgroundColor3 = Colors.Panel
UserFrame.BorderSizePixel = 0
UserFrame.Parent = Sidebar
Instance.new("UICorner", UserFrame).CornerRadius = UDim.new(0, 8)

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.fromOffset(30, 30)
Avatar.Position = UDim2.fromOffset(7, 7)
Avatar.BackgroundColor3 = Colors.Bg
Avatar.Parent = UserFrame
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    local success, url = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if success then Avatar.Image = url end
end)

local UserName = Instance.new("TextLabel")
UserName.Size = UDim2.new(1, -44, 0, 14)
UserName.Position = UDim2.fromOffset(44, 7)
UserName.BackgroundTransparency = 1
UserName.Text = LP.DisplayName
UserName.TextColor3 = Colors.TextDark
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 11
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.Parent = UserFrame

local UserStatus = Instance.new("TextLabel")
UserStatus.Size = UDim2.new(1, -44, 0, 12)
UserStatus.Position = UDim2.fromOffset(44, 22)
UserStatus.BackgroundTransparency = 1
UserStatus.Text = "已授权"
UserStatus.TextColor3 = Colors.TextLight
UserStatus.Font = Enum.Font.Gotham
UserStatus.TextSize = 9
UserStatus.TextXAlignment = Enum.TextXAlignment.Left
UserStatus.Parent = UserFrame

-- 导航按钮容器
local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(1, 0, 1, -60)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = Sidebar
local NavLayout = Instance.new("UIListLayout", NavContainer)
NavLayout.Padding = UDim.new(0, 4)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==========================================
-- 右侧内容区
-- ==========================================
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -136, 1, -50)
ContentFrame.Position = UDim2.fromOffset(128, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainContent

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, 0, 0, 24)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "主页"
PageTitle.TextColor3 = Colors.TextLight
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextSize = 12
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = ContentFrame

local CardList = Instance.new("Frame")
CardList.Size = UDim2.new(1, 0, 1, -24)
CardList.Position = UDim2.fromOffset(0, 24)
CardList.BackgroundTransparency = 1
CardList.Parent = ContentFrame
local CardLayout = Instance.new("UIListLayout", CardList)
CardLayout.Padding = UDim.new(0, 8)

-- 清空右侧
local function ClearCards()
    for _, v in ipairs(CardList:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
end

-- ==========================================
-- UI 组件生成器
-- ==========================================
local function AddCard(text, toggleKey)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 40)
    card.BackgroundColor3 = Colors.Panel
    card.BorderSizePixel = 0
    card.Parent = CardList
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.fromOffset(12, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.TextDark
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card
    
    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(36, 20)
    track.Position = UDim2.new(1, -48, 0.5, -10)
    track.BackgroundColor3 = Colors.ToggleOff
    track.BorderSizePixel = 0
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = Colors.Panel
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1,1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = card
    
    local isOn = false
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if toggleKey then Config[toggleKey] = isOn end
        if isOn then
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ToggleOn}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(18, 2)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ToggleOff}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(2, 2)}):Play()
        end
    end)
end

-- 导航切换逻辑
local function AddNav(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.Position = UDim2.fromOffset(6, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = Colors.TextLight
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = NavContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        -- 导航高亮
        for _, v in ipairs(NavContainer:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundTransparency = 1
                v.TextColor3 = Colors.TextLight
            end
        end
        btn.BackgroundColor3 = Colors.Panel
        btn.TextColor3 = Colors.AccentBlue
        
        -- 切换内容
        PageTitle.Text = name
        ClearCards()
        if name == "主页" then
            AddCard("玩家信息", nil)
        elseif name == "视觉" then
            AddCard("玩家名字", "ESP")
            AddCard("血条显示", "ESPHealth")
            AddCard("中文职业", "ESPRole")
        elseif name == "战斗" then
            AddCard("装备秒杀", "KillAura")
            AddCard("杀戮冷却限制", "Cooldown")
        end
    end)
end

-- ==========================================
-- 动画与初始化
-- ==========================================
local openTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local function ToggleUI(openState)
    if isAnimating then return end
    isAnimating = true
    isOpen = openState

    if isOpen then
        MainContent.Visible = true
        CapsuleText.Visible = false
        CapsuleBtn.Visible = false
        
        -- 展开动画：平滑放大到 480x300，圆角变 12
        TweenService:Create(Main, openTweenInfo, {
            Size = UDim2.fromOffset(480, 300),
            Position = UDim2.new(0.5, 0, 0, 40)
        }):Play()
        TweenService:Create(MainCorner, openTweenInfo, {CornerRadius = UDim.new(0, 12)}):Play()
        
        task.wait(0.4)
    else
        MainContent.Visible = false
        
        -- 收起动画：缩回胶囊
        TweenService:Create(Main, closeTweenInfo, {
            Size = UDim2.fromOffset(110, 32),
            Position = UDim2.new(0.5, 0, 0, 30)
        }):Play()
        TweenService:Create(MainCorner, closeTweenInfo, {CornerRadius = UDim.new(1, 0)}):Play()
        
        task.wait(0.35)
        CapsuleText.Visible = true
        CapsuleBtn.Visible = true
    end
    isAnimating = false
end

CapsuleBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)

-- 初始填充
AddNav("主页")
AddNav("视觉")
AddNav("战斗")
NavContainer:GetChildren()[1].BackgroundColor3 = Colors.Panel
NavContainer:GetChildren()[1].TextColor3 = Colors.AccentBlue
AddCard("玩家信息", nil)
AddCard("坐标读取", nil)

print("[DeepSeek] 胶囊 + Fluent 面板已加载")