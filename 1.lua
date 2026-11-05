-- ============================================
-- DeepSeek Capsule UI + 双轨透视引擎
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function getHiddenGui(name)
    local g = Instance.new("ScreenGui"); g.Name = name; g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    if syn and syn.protect_gui then syn.protect_gui(g); g.Parent = game:GetService("CoreGui")
    elseif gethui then g.Parent = gethui() else g.Parent = LP:WaitForChild("PlayerGui") end
    return g
end

local gui = getHiddenGui("DeepSeekUI_" .. math.random(1000, 9999))

-- ==========================================
-- 1. 配置项
-- ==========================================
local Config = {
    ESP = false
}

-- ==========================================
-- 2. DeepSeek UI (胶囊 + 菜单)
-- ==========================================
local mainFrame = Instance.new("Frame")
mainFrame.AnchorPoint = Vector2.new(0.5, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0, 30) 
mainFrame.Size = UDim2.fromOffset(110, 32)
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

addToggle("开启双轨透视", "ESP")

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
-- 3. 透视引擎 (完全遵循你的架构)
-- ==========================================
local hasDrawing = pcall(function() return Drawing ~= nil end)
if hasDrawing then hasDrawing = Drawing end

-- 检测中文
local function hasChinese(str)
    for _, code in utf8.codes(str) do
        if code > 127 then return true end
    end
    return false
end

local espCache = {}

-- 初始化玩家 (收敛创建，不重建)
local function initPlayer(plr)
    if plr == LP or espCache[plr] then return end
    
    local isCN = hasChinese(plr.Name)
    local data = { isCN = isCN }
    
    -- 中文名：走 BillboardGui (防乱码)
    if isCN then
        local bg = Instance.new("BillboardGui")
        bg.Name = tostring(math.random(10000, 99999))
        bg.Size = UDim2.new(0, 200, 0, 40)
        bg.AlwaysOnTop = true
        bg.Enabled = false
        bg.Parent = gui
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 0, 20)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1,1,1)
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.Text = plr.Name
        txt.Parent = bg
        
        data.bg = bg
    end
    
    -- 英文/数字名、方框、距离：走 Drawing (轻量)
    if hasDrawing then
        data.square = Drawing.new("Square")
        data.square.Thickness = 1
        data.square.Color = Color3.fromRGB(0, 255, 100)
        data.square.Filled = false
        
        if not isCN then
            data.nameTxt = Drawing.new("Text")
            data.nameTxt.Center = true
            data.nameTxt.Outline = true
            data.nameTxt.Size = 14
            data.nameTxt.Color = Color3.new(1,1,1)
        end
        
        data.distTxt = Drawing.new("Text")
        data.distTxt.Center = true
        data.distTxt.Outline = true
        data.distTxt.Size = 12
        data.distTxt.Color = Color3.fromRGB(200,200,200)
    end
    
    espCache[plr] = data
end

Players.PlayerAdded:Connect(initPlayer)
for _, p in ipairs(Players:GetPlayers()) do initPlayer(p) end

Players.PlayerRemoving:Connect(function(plr)
    local d = espCache[plr]
    if d then
        if d.bg then d.bg:Destroy() end
        if d.square then d.square:Remove() end
        if d.nameTxt then d.nameTxt:Remove() end
        if d.distTxt then d.distTxt:Remove() end
        espCache[plr] = nil
    end
end)

-- 渲染循环 (pcall 保护，极致抗卡)
RunService.RenderStepped:Connect(function()
    for plr, data in pairs(espCache) do
        pcall(function()
            if not Config.ESP or not plr.Character then
                if data.bg then data.bg.Enabled = false end
                if data.square then data.square.Visible = false end
                if data.nameTxt then data.nameTxt.Visible = false end
                if data.distTxt then data.distTxt.Visible = false end
                return
            end
            
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            
            if not hrp or not hum or hum.Health <= 0 then
                if data.bg then data.bg.Enabled = false end
                if data.square then data.square.Visible = false end
                if data.nameTxt then data.nameTxt.Visible = false end
                if data.distTxt then data.distTxt.Visible = false end
                return
            end
            
            -- 1. BillboardGui (中文名) 跟随头上
            if data.bg then
                data.bg.Adornee = hrp
                data.bg.Enabled = true
            end
            
            -- 2. Drawing (投影方框、距离、英文名)
            if hasDrawing then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2, 0))
                
                if onScreen then
                    local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude / 3)
                    
                    -- 方框
                    data.square.Visible = true
                    data.square.Size = Vector2.new(40, 60)
                    data.square.Position = Vector2.new(pos.X - 20, pos.Y - 30)
                    
                    -- 距离
                    data.distTxt.Visible = true
                    data.distTxt.Text = tostring(dist) .. "m"
                    data.distTxt.Position = Vector2.new(pos.X, pos.Y + 35)
                    
                    -- 英文/数字名
                    if not data.isCN and data.nameTxt then
                        data.nameTxt.Visible = true
                        data.nameTxt.Text = plr.Name
                        data.nameTxt.Position = Vector2.new(pos.X, pos.Y - 45)
                    end
                else
                    data.square.Visible = false
                    data.distTxt.Visible = false
                    if data.nameTxt then data.nameTxt.Visible = false end
                end
            end
        end)
    end
end)

print("[DeepSeek] 双轨透视加载完毕")