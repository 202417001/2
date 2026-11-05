-- ============================================
-- DeepSeek UI + 终极隔离级透视
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- 1. 确认容器 (只取一次，局部变量)
-- ==========================================
local container = (gethui and gethui()) or game:GetService("CoreGui")

-- 所有内容只认这个唯一的父级，名字随机去特征
local mainGui = Instance.new("ScreenGui")
mainGui.Name = tostring(math.random(100000, 999999))
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = container

-- ==========================================
-- 2. 配置项
-- ==========================================
local Config = {
    ESP = false
}

-- ==========================================
-- 3. DeepSeek 胶囊面板 (并入同一父级)
-- ==========================================
local mainFrame = Instance.new("Frame")
mainFrame.AnchorPoint = Vector2.new(0.5, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0, 30) 
mainFrame.Size = UDim2.fromOffset(110, 32)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = false
mainFrame.Parent = mainGui

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(1, 0) 

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(60, 60, 70)
stroke.Thickness = 1.5

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 0, 32)
titleText.BackgroundTransparency = 1
titleText.Text = "DeepSeek"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.ZIndex = 2
titleText.Parent = mainFrame

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -60)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundTransparency = 1
content.Visible = false
content.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout", content)
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

local isOpen = false
local isAnimating = false

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.fromScale(1, 1)
openBtn.BackgroundTransparency = 1
openBtn.Text = ""
openBtn.ZIndex = 3
openBtn.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1, 0, 0, 44)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = ""
closeBtn.ZIndex = 4
closeBtn.Visible = false
closeBtn.Parent = mainFrame

-- UI 开关组件
local function addToggle(text, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 34, 0, 18)
    track.Position = UDim2.new(1, -44, 0.5, -9)
    track.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    track.BorderSizePixel = 0
    track.Parent = btn
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local isToggled = false
    local function updateUI()
        if isToggled then
            TweenService:Create(fill, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 1, 0)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1)}):Play()
        else
            TweenService:Create(fill, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
    end
    btn.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        Config[key] = isToggled
        updateUI()
    end)
    updateUI()
end

addToggle("开启深度透视", "ESP")

-- 展开/收起动画
local openTweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local function toggleUI(openState)
    if isAnimating then return end
    isAnimating = true
    isOpen = openState

    if isOpen then
        content.Visible = true; openBtn.Visible = false; closeBtn.Visible = true
        TweenService:Create(mainFrame, openTweenInfo, {Size = UDim2.fromOffset(280, 200)}):Play()
        TweenService:Create(uiCorner, openTweenInfo, {CornerRadius = UDim.new(0, 12)}):Play()
        TweenService:Create(titleText, openTweenInfo, {TextSize = 15, Position = UDim2.new(0, 0, 0, 4)}):Play()
        task.wait(0.45)
    else
        content.Visible = false; closeBtn.Visible = false
        TweenService:Create(mainFrame, closeTweenInfo, {Size = UDim2.fromOffset(110, 32)}):Play()
        TweenService:Create(uiCorner, closeTweenInfo, {CornerRadius = UDim.new(1, 0)}):Play()
        TweenService:Create(titleText, closeTweenInfo, {TextSize = 13, Position = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.4)
        openBtn.Visible = true
    end
    isAnimating = false
end

openBtn.MouseButton1Click:Connect(function() toggleUI(true) end)
closeBtn.MouseButton1Click:Connect(function() toggleUI(false) end)

-- ==========================================
-- 4. 透视核心逻辑 (纯屏幕空间 TextLabel)
-- ==========================================
local espCache = {}

-- 实例只建一次
local function initPlayer(plr)
    if plr == LP or espCache[plr] then return end
    
    local data = {}
    
    -- 空心方框 (用 BorderSizePixel 拼)
    local box = Instance.new("Frame")
    box.Name = tostring(math.random(10000, 99999))
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 1
    box.BorderColor3 = Color3.fromRGB(0, 255, 100)
    box.Visible = false
    box.Parent = mainGui
    
    -- 名字 (强制统一用 SourceSansBold 支持中文)
    local nameTxt = Instance.new("TextLabel")
    nameTxt.Name = tostring(math.random(10000, 99999))
    nameTxt.BackgroundTransparency = 1
    nameTxt.TextColor3 = Color3.new(1, 1, 1)
    nameTxt.TextStrokeTransparency = 0
    nameTxt.Font = Enum.Font.SourceSansBold
    nameTxt.TextSize = 14
    nameTxt.Visible = false
    nameTxt.Parent = mainGui
    
    -- 距离
    local distTxt = Instance.new("TextLabel")
    distTxt.Name = tostring(math.random(10000, 99999))
    distTxt.BackgroundTransparency = 1
    distTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
    distTxt.TextStrokeTransparency = 0
    distTxt.Font = Enum.Font.SourceSansBold
    distTxt.TextSize = 12
    distTxt.Visible = false
    distTxt.Parent = mainGui
    
    data.box = box
    data.nameTxt = nameTxt
    data.distTxt = distTxt
    
    espCache[plr] = data
end

Players.PlayerAdded:Connect(initPlayer)
for _, p in ipairs(Players:GetPlayers()) do initPlayer(p) end

-- 离开时清理干净
Players.PlayerRemoving:Connect(function(plr)
    local d = espCache[plr]
    if d then
        if d.box then d.box:Destroy() end
        if d.nameTxt then d.nameTxt:Destroy() end
        if d.distTxt then d.distTxt:Destroy() end
        espCache[plr] = nil
    end
end)

-- ==========================================
-- 5. 渲染更新循环 (10毫秒降频更新)
-- ==========================================
task.spawn(function()
    while task.wait(0.01) do -- 用户要求的 10 毫秒
        if not Config.ESP then
            for _, d in pairs(espCache) do
                d.box.Visible = false; d.nameTxt.Visible = false; d.distTxt.Visible = false
            end
            continue
        end
        
        for plr, data in pairs(espCache) do
            pcall(function()
                if not plr.Character then
                    data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                    return
                end
                
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                
                if not hrp or not hum or hum.Health <= 0 then
                    data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                    return
                end
                
                -- 获取屏幕坐标
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2, 0))
                
                if onScreen then
                    -- 计算距离 (3 studs = 1m)
                    local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude / 3)
                    
                    -- 根据距离算方框尺寸 (越远越小，给个合理缩放)
                    local boxHeight = math.clamp(6000 / distance, 30, 100)
                    local boxWidth = boxHeight * 0.6
                    
                    -- 1. 更新框 (居中)
                    data.box.Visible = true
                    data.box.AnchorPoint = Vector2.new(0.5, 0.5)
                    data.box.Size = UDim2.fromOffset(boxWidth, boxHeight)
                    data.box.Position = UDim2.fromOffset(pos.X, pos.Y)
                    
                    -- 2. 更新名字 (框上方)
                    data.nameTxt.Visible = true
                    data.nameTxt.AnchorPoint = Vector2.new(0.5, 1)
                    data.nameTxt.Size = UDim2.fromOffset(200, 20)
                    data.nameTxt.Position = UDim2.fromOffset(pos.X, pos.Y - (boxHeight / 2) - 2)
                    data.nameTxt.Text = plr.Name
                    
                    -- 3. 更新距离 (框下方)
                    data.distTxt.Visible = true
                    data.distTxt.AnchorPoint = Vector2.new(0.5, 0)
                    data.distTxt.Size = UDim2.fromOffset(100, 20)
                    data.distTxt.Position = UDim2.fromOffset(pos.X, pos.Y + (boxHeight / 2) + 2)
                    data.distTxt.Text = tostring(distance) .. "m"
                else
                    data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                end
            end)
        end
    end
end)

print("[DeepSeek] 隔离级 10ms 刷新透视加载完毕")