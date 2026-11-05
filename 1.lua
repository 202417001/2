-- ============================================
-- DeepSeek Studio (Fluent Light UI)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local container = (gethui and gethui()) or game:GetService("CoreGui")

local mainGui = Instance.new("ScreenGui")
mainGui.Name = tostring(math.random(100000, 999999))
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = container

local Config = {
    ESP = false
}

-- 颜色配置 (Fluent 浅色模式)
local Colors = {
    Bg = Color3.fromRGB(240, 242, 245),
    Panel = Color3.fromRGB(255, 255, 255),
    Sidebar = Color3.fromRGB(230, 233, 238),
    TextDark = Color3.fromRGB(30, 30, 30),
    TextLight = Color3.fromRGB(120, 120, 120),
    AccentBlue = Color3.fromRGB(0, 110, 255),
    AccentRed = Color3.fromRGB(255, 90, 90),
    ToggleOff = Color3.fromRGB(200, 200, 200),
    ToggleOn = Color3.fromRGB(0, 110, 255)
}

-- ==========================================
-- 主面板
-- ==========================================
local Main = Instance.new("Frame")
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(650, 420)
Main.BackgroundColor3 = Colors.Bg
Main.BorderSizePixel = 0
Main.Parent = mainGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(200, 200, 200)
MainStroke.Thickness = 1

-- ==========================================
-- 顶部栏
-- ==========================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Main

-- 左上角 Logo / 项目名
local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(200, 40)
Title.Position = UDim2.fromOffset(20, 5)
Title.BackgroundTransparency = 1
Title.Text = "DeepSeek Studio"
Title.TextColor3 = Colors.TextDark
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- 顶部右侧操作区
local TopActionFrame = Instance.new("Frame")
TopActionFrame.Size = UDim2.fromOffset(300, 40)
TopActionFrame.Position = UDim2.new(1, -320, 0, 5)
TopActionFrame.BackgroundTransparency = 1
TopActionFrame.Parent = TopBar

-- 初始化按钮 (主开关)
local InitBtn = Instance.new("TextButton")
InitBtn.Size = UDim2.fromOffset(80, 32)
InitBtn.Position = UDim2.fromOffset(0, 4)
InitBtn.BackgroundColor3 = Colors.AccentBlue
InitBtn.Text = "初始化"
InitBtn.TextColor3 = Color3.new(1,1,1)
InitBtn.Font = Enum.Font.GothamBold
InitBtn.TextSize = 13
InitBtn.Parent = TopActionFrame
Instance.new("UICorner", InitBtn).CornerRadius = UDim.new(0, 8)

-- 退出按钮
local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.fromOffset(60, 32)
ExitBtn.Position = UDim2.fromOffset(90, 4)
ExitBtn.BackgroundColor3 = Colors.AccentRed
ExitBtn.BackgroundTransparency = 0.8
ExitBtn.Text = "退出"
ExitBtn.TextColor3 = Colors.AccentRed
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.TextSize = 13
ExitBtn.Parent = TopActionFrame
Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)

-- 版本号
local VerLabel = Instance.new("TextLabel")
VerLabel.Size = UDim2.fromOffset(100, 32)
VerLabel.Position = UDim2.fromOffset(160, 4)
VerLabel.BackgroundColor3 = Colors.Panel
VerLabel.Text = "V1.0.0"
VerLabel.TextColor3 = Colors.TextDark
VerLabel.Font = Enum.Font.GothamBold
VerLabel.TextSize = 12
VerLabel.Parent = TopActionFrame
Instance.new("UICorner", VerLabel).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- 左侧导航栏
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -60)
Sidebar.Position = UDim2.fromOffset(10, 50)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

-- 左下角用户信息
local UserFrame = Instance.new("Frame")
UserFrame.Size = UDim2.new(1, -20, 0, 50)
UserFrame.Position = UDim2.new(0, 10, 1, -60)
UserFrame.BackgroundColor3 = Colors.Panel
UserFrame.BorderSizePixel = 0
UserFrame.Parent = Sidebar
Instance.new("UICorner", UserFrame).CornerRadius = UDim.new(0, 8)

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.fromOffset(34, 34)
Avatar.Position = UDim2.fromOffset(8, 8)
Avatar.BackgroundColor3 = Colors.Bg
Avatar.Parent = UserFrame
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

-- 获取真实头像
task.spawn(function()
    local success, url = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if success then Avatar.Image = url end
end)

local UserName = Instance.new("TextLabel")
UserName.Size = UDim2.new(1, -50, 0, 16)
UserName.Position = UDim2.fromOffset(50, 8)
UserName.BackgroundTransparency = 1
UserName.Text = LP.DisplayName
UserName.TextColor3 = Colors.TextDark
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 12
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.Parent = UserFrame

local UserStatus = Instance.new("TextLabel")
UserStatus.Size = UDim2.new(1, -50, 0, 14)
UserStatus.Position = UDim2.fromOffset(50, 24)
UserStatus.BackgroundTransparency = 1
UserStatus.Text = "剩余 999天"
UserStatus.TextColor3 = Colors.TextLight
UserStatus.Font = Enum.Font.Gotham
UserStatus.TextSize = 10
UserStatus.TextXAlignment = Enum.TextXAlignment.Left
UserStatus.Parent = UserFrame

-- 导航按钮容器
local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(1, 0, 1, -80)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = Sidebar
local NavLayout = Instance.new("UIListLayout", NavContainer)
NavLayout.Padding = UDim.new(0, 4)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==========================================
-- 右侧内容区
-- ==========================================
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -170, 1, -60)
ContentFrame.Position = UDim2.fromOffset(160, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = Main

-- ==========================================
-- UI 组件生成器
-- ==========================================
local function AddNav(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.fromOffset(10, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = Colors.TextLight
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = NavContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    -- 默认选中状态
    if name == "主页" then
        btn.BackgroundColor3 = Colors.Panel
        btn.TextColor3 = Colors.AccentBlue
    end
    
    btn.MouseButton1Click:Connect(function()
        -- 切换状态
        for _, v in ipairs(NavContainer:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundTransparency = 1
                v.TextColor3 = Colors.TextLight
            end
        end
        btn.BackgroundColor3 = Colors.Panel
        btn.TextColor3 = Colors.AccentBlue
    end)
end

-- 右侧卡片生成器
local function AddCard(parent, text, toggleKey)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Colors.Panel
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.fromOffset(16, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.TextDark
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card
    
    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(40, 22)
    track.Position = UDim2.new(1, -56, 0.5, -11)
    track.BackgroundColor3 = Colors.ToggleOff
    track.BorderSizePixel = 0
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
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
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(20, 2)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ToggleOff}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(2, 2)}):Play()
        end
    end)
end

-- ==========================================
-- 填充界面
-- ==========================================
AddNav("主页")
AddNav("绘制")
AddNav("追踪")
AddNav("自瞄")
AddNav("物资")
AddNav("功能")

-- 右侧主页内容
local HomePage = Instance.new("Frame")
HomePage.Size = UDim2.fromScale(1,1)
HomePage.BackgroundTransparency = 1
HomePage.Parent = ContentFrame

local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(1, 0, 0, 30)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "解密设置"
PageTitle.TextColor3 = Colors.TextLight
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextSize = 12
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = HomePage

local CardList = Instance.new("Frame")
CardList.Size = UDim2.new(1, 0, 1, -30)
CardList.Position = UDim2.fromOffset(0, 30)
CardList.BackgroundTransparency = 1
CardList.Parent = HomePage
local CardLayout = Instance.new("UIListLayout", CardList)
CardLayout.Padding = UDim.new(0, 10)

AddCard(CardList, "玩家透视", "ESP")
AddCard(CardList, "坐标读取", nil)
AddCard(CardList, "模型读取", nil)
AddCard(CardList, "密钥解密", nil)

-- 初始化按钮点击逻辑
InitBtn.MouseButton1Click:Connect(function()
    if Config.ESP then
        Config.ESP = false
        InitBtn.Text = "初始化"
        InitBtn.BackgroundColor3 = Colors.AccentBlue
    else
        Config.ESP = true
        InitBtn.Text = "已开启"
        InitBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    end
end)

-- 退出按钮点击逻辑
ExitBtn.MouseButton1Click:Connect(function()
    mainGui:Destroy()
end)

print("[DeepSeek Studio] Fluent 风格 UI 加载完毕")