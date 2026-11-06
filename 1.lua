-- ============================================
-- DeepSeek Studio (主线程纯净 · 多选阵营过滤)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. 安全容器
local container = game:GetService("CoreGui")
pcall(function() if gethui then container = gethui() end end)

local mainGui = Instance.new("ScreenGui")
mainGui.Name = tostring(math.random(100000, 999999))
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = container

local Config = { 
    ESP = false, 
    Highlight = false,
    Filters = {
        ["平民"] = true, ["警察"] = true, ["医生"] = true,
        ["消防员"] = true, ["厨师"] = true, ["快递员"] = true,
        ["农夫"] = true, ["囚犯"] = true, ["其他"] = true
    }
}

local Colors = {
    Bg = Color3.fromRGB(240, 242, 245),
    Panel = Color3.fromRGB(255, 255, 255),
    Sidebar = Color3.fromRGB(235, 237, 240),
    TextDark = Color3.fromRGB(30, 30, 30),
    TextLight = Color3.fromRGB(120, 120, 120),
    AccentBlue = Color3.fromRGB(0, 110, 255),
    ToggleOff = Color3.fromRGB(200, 200, 200),
}

-- ==========================================
-- 2. UI 构建
-- ==========================================
local Main = Instance.new("Frame")
Main.AnchorPoint = Vector2.new(0.5, 0)
Main.Position = UDim2.new(0.5, 0, 0, 10)
Main.Size = UDim2.fromOffset(0, 0) 
Main.BackgroundColor3 = Colors.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Parent = mainGui
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(1, 0)

local CapsuleText = Instance.new("TextLabel")
CapsuleText.Size = UDim2.new(1, 0, 1, 0)
CapsuleText.BackgroundTransparency = 1
CapsuleText.Text = "DeepSeek"
CapsuleText.TextColor3 = Colors.TextDark
CapsuleText.Font = Enum.Font.GothamBold
CapsuleText.TextSize = 13
CapsuleText.Parent = Main

local CapsuleBtn = Instance.new("TextButton")
CapsuleBtn.Size = UDim2.fromScale(1, 1)
CapsuleBtn.BackgroundTransparency = 1
CapsuleBtn.Text = ""
CapsuleBtn.Parent = Main

local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.fromScale(1, 1)
MainContent.BackgroundTransparency = 1
MainContent.Visible = false
MainContent.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(200, 30)
Title.Position = UDim2.fromOffset(16, 5)
Title.BackgroundTransparency = 1
Title.Text = "DeepSeek Studio"
Title.TextColor3 = Colors.TextDark
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainContent

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(32, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Colors.TextLight
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.ZIndex = 10
CloseBtn.Parent = MainContent

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(120, 250)
Sidebar.Position = UDim2.fromOffset(8, 40)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainContent
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(1, 0, 1, 0)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = Sidebar
local NavLayout = Instance.new("UIListLayout", NavContainer)
NavLayout.Padding = UDim.new(0, 4)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -136, 1, -50)
ContentFrame.Position = UDim2.fromOffset(128, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainContent

local Pages = {}
local NavButtons = {}

local function CreatePage(name)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Colors.ToggleOff
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Parent = ContentFrame
    sf.Visible = false
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 8)
    Pages[name] = sf
    return sf
end

local function SwitchPage(name)
    for pName, pFrame in pairs(Pages) do pFrame.Visible = (pName == name) end
    for bName, btn in pairs(NavButtons) do
        btn.BackgroundColor3 = (bName == name) and Colors.Panel or Colors.Sidebar
        btn.TextColor3 = (bName == name) and Colors.AccentBlue or Colors.TextLight
    end
end

local function CreateNavBtn(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.Position = UDim2.fromOffset(6, 8)
    btn.BackgroundColor3 = Colors.Sidebar
    btn.Text = "  " .. name
    btn.TextColor3 = Colors.TextLight
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = NavContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() SwitchPage(name) end)
    NavButtons[name] = btn
end

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
    
    local isOn = Config[toggleKey] or false
    if isOn then track.BackgroundColor3 = Colors.AccentBlue; knob.Position = UDim2.fromOffset(20, 2) end

    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if toggleKey then Config[toggleKey] = isOn end
        if isOn then
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Colors.AccentBlue}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(20, 2)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ToggleOff}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(2, 2)}):Play()
        end
    end)
end

-- 【核心新增】多选下拉框生成器
local function AddMultiSelect(parent, titleText, options, configTable)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Colors.Panel
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundTransparency = 1
    header.Text = ""
    header.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.fromOffset(16, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Colors.TextDark
    title.Font = Enum.Font.Gotham
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(16, 16)
    arrow.Position = UDim2.new(1, -24, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Colors.TextLight
    arrow.TextSize = 10
    arrow.Parent = header

    local optionList = Instance.new("Frame")
    optionList.Size = UDim2.new(1, 0, 0, 0)
    optionList.Position = UDim2.fromOffset(0, 44)
    optionList.BackgroundTransparency = 1
    optionList.Parent = card
    local optLayout = Instance.new("UIListLayout", optionList)
    optLayout.Padding = UDim.new(0, 2)

    local isExpanded = false
    local function expand()
        isExpanded = not isExpanded
        local targetSize = isExpanded and UDim2.new(1, 0, 0, 44 + #options * 32 + 10) or UDim2.new(1, 0, 0, 44)
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(card, tweenInfo, {Size = targetSize}):Play()
        TweenService:Create(arrow, tweenInfo, {Rotation = isExpanded and 180 or 0}):Play()
    end

    header.MouseButton1Click:Connect(expand)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = ""
        optBtn.Parent = optionList

        local optText = Instance.new("TextLabel")
        optText.Size = UDim2.new(1, -50, 1, 0)
        optText.Position = UDim2.fromOffset(20, 0)
        optText.BackgroundTransparency = 1
        optText.Text = opt
        optText.TextColor3 = Colors.TextDark
        optText.Font = Enum.Font.Gotham
        optText.TextSize = 12
        optText.TextXAlignment = Enum.TextXAlignment.Left
        optText.Parent = optBtn

        local checkBox = Instance.new("Frame")
        checkBox.Size = UDim2.fromOffset(16, 16)
        checkBox.Position = UDim2.new(1, -30, 0.5, -8)
        checkBox.BackgroundColor3 = configTable[opt] and Colors.AccentBlue or Colors.Panel
        checkBox.Parent = optBtn
        Instance.new("UICorner", checkBox).CornerRadius = UDim.new(0, 4)
        
        local cbStroke = Instance.new("UIStroke", checkBox)
        cbStroke.Color = Colors.ToggleOff
        cbStroke.Thickness = 1

        local checkMark = Instance.new("TextLabel")
        checkMark.Size = UDim2.fromScale(1, 1)
        checkMark.BackgroundTransparency = 1
        checkMark.Text = "✓"
        checkMark.TextColor3 = Colors.Panel
        checkMark.Font = Enum.Font.GothamBold
        checkMark.TextSize = 12
        checkMark.Visible = configTable[opt] or false
        checkMark.Parent = checkBox

        optBtn.MouseButton1Click:Connect(function()
            configTable[opt] = not configTable[opt]
            local state = configTable[opt]
            checkBox.BackgroundColor3 = state and Colors.AccentBlue or Colors.Panel
            checkMark.Visible = state
        end)
    end
end

CreateNavBtn("视觉")
local page_Visual = CreatePage("视觉")
AddCard(page_Visual, "玩家透视", "ESP")
AddCard(page_Visual, "人物高亮", "Highlight")
AddMultiSelect(page_Visual, "阵营过滤 (点击展开)", 
    {"平民", "警察", "医生", "消防员", "厨师", "快递员", "农夫", "囚犯", "其他"}, 
    Config.Filters
)
SwitchPage("视觉")

local isOpen = false
local isAnimating = false
local function ToggleUI(openState)
    if isAnimating then return end
    isAnimating = true
    isOpen = openState
    if isOpen then
        MainContent.Visible = true
        CapsuleText.Visible = false
        CapsuleBtn.Visible = false
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(480, 320), Position = UDim2.new(0.5, 0, 0, 40)}):Play()
        TweenService:Create(MainCorner, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CornerRadius = UDim.new(0, 12)}):Play()
        task.wait(0.4)
    else
        MainContent.Visible = false
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.fromOffset(110, 32), Position = UDim2.new(0.5, 0, 0, 10)}):Play()
        TweenService:Create(MainCorner, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {CornerRadius = UDim.new(1, 0)}):Play()
        task.wait(0.3)
        CapsuleText.Visible = true
        CapsuleBtn.Visible = true
    end
    isAnimating = false
end
CapsuleBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)

-- ==========================================
-- 3. 启动动画：三面星尘汇聚 (主线程)
-- ==========================================
local function PlayIntroAnimation()
    local particles = {}
    local PARTICLE_COUNT = 70
    
    local targetX = 0.5
    local targetY = 0.05 
    
    for i = 1, PARTICLE_COUNT do
        local dot = Instance.new("Frame")
        dot.BackgroundColor3 = Color3.new(1, 1, 1)
        dot.BorderSizePixel = 0
        dot.ZIndex = 100
        dot.Parent = mainGui
        
        local size = math.random(2, 5)
        dot.Size = UDim2.fromOffset(size, size)
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        
        local startX, startY
        local edge = math.random(1, 3)
        if edge == 1 then startX = 0; startY = math.random(0, 100) / 100
        elseif edge == 2 then startX = 1; startY = math.random(0, 100) / 100
        else startX = math.random(0, 100) / 100; startY = 1 end
        
        dot.Position = UDim2.new(startX, 0, startY, 0)
        
        local endX = targetX + (math.random(-20, 20) / 1000)
        local endY = targetY + (math.random(-20, 20) / 1000)
        
        local delayTime = math.random(0, 30) / 100
        local travelTime = math.random(30, 60) / 100
        
        table.insert(particles, dot)
        
        task.delay(delayTime, function()
            if dot and dot.Parent then
                local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                TweenService:Create(dot, tweenInfo, {
                    Position = UDim2.new(endX, 0, endY, 0),
                    BackgroundTransparency = 1
                }):Play()
            end
        end)
    end
    
    task.delay(1.0, function()
        for _, dot in ipairs(particles) do
            if dot then dot:Destroy() end
        end
        
        Main.Visible = true
        Main.Size = UDim2.fromOffset(0, 0)
        local popInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(Main, popInfo, {Size = UDim2.fromOffset(110, 32)}):Play()
    end)
end

PlayIntroAnimation()

-- ==========================================
-- 4. 角色逻辑与底层透视
-- ==========================================
local RoleDict = {
    ["Civilian"] = "平民", ["Police"] = "警察", ["Medical"] = "医生",
    ["Chef"] = "厨师", ["Delivery"] = "快递员", ["Farmer"] = "农夫",
    ["Fire"] = "消防员", ["Prisoner"] = "囚犯", ["Road Service"] = "其他",
    ["Transit"] = "其他", ["Neutral"] = "其他", ["???"] = "其他"
}

local function getRoleName(plr)
    local rawRole = nil
    local roleAttr = plr:GetAttribute("Role") or plr:GetAttribute("RoleId")
    if roleAttr then rawRole = tostring(roleAttr) end
    if not rawRole and plr.Team and plr.Team.Name ~= "" then rawRole = plr.Team.Name end
    if rawRole then
        if RoleDict[rawRole] then return RoleDict[rawRole] end
        local lr = rawRole:lower()
        if lr:find("police") then return "警察"
        elseif lr:find("civilian") then return "平民"
        elseif lr:find("medical") or lr:find("doctor") then return "医生"
        elseif lr:find("fire") then return "消防员"
        end
        return "其他"
    end
    return "平民"
end

local function getRoleColor(roleName)
    if roleName == "警察" then return Color3.fromRGB(0, 85, 255)
    elseif roleName == "医生" then return Color3.fromRGB(255, 30, 30)
    elseif roleName == "消防员" then return Color3.fromRGB(255, 140, 0)
    elseif roleName == "平民" then return Color3.fromRGB(255, 255, 255)
    elseif roleName == "农夫" then return Color3.fromRGB(60, 255, 60)
    elseif roleName == "囚犯" then return Color3.fromRGB(255, 100, 0)
    end
    return Color3.fromRGB(200, 200, 200)
end

local HIGHLIGHT_POOL_SIZE = 20
local highlightPool = {}
local hlFolder = Instance.new("Folder")
hlFolder.Name = tostring(math.random(10000, 99999))
pcall(function() hlFolder.Parent = container end)
if not hlFolder.Parent then hlFolder.Parent = workspace end

for i = 1, HIGHLIGHT_POOL_SIZE do
    local hl = Instance.new("Highlight")
    hl.Name = tostring(math.random(10000, 99999))
    hl.DepthMode = Enum.HighlightDepthMode.Occluded
    hl.OutlineTransparency = 1
    hl.FillTransparency = 0.5
    hl.Adornee = nil
    hl.Parent = hlFolder
    table.insert(highlightPool, hl)
end

local espCache = {}
local function initPlayer(plr)
    if plr == LP or espCache[plr] then return end
    local box = Instance.new("Frame"); box.BackgroundTransparency = 1; box.BorderSizePixel = 1; box.BorderColor3 = Color3.fromRGB(0, 255, 100); box.Visible = false; box.Parent = mainGui
    local nameTxt = Instance.new("TextLabel"); nameTxt.BackgroundTransparency = 1; nameTxt.TextColor3 = Color3.new(1, 1, 1); nameTxt.TextStrokeTransparency = 0; nameTxt.Font = Enum.Font.SourceSansBold; nameTxt.TextSize = 14; nameTxt.Visible = false; nameTxt.Parent = mainGui
    local distTxt = Instance.new("TextLabel"); distTxt.BackgroundTransparency = 1; distTxt.TextColor3 = Color3.fromRGB(200, 200, 200); distTxt.TextStrokeTransparency = 0; distTxt.Font = Enum.Font.SourceSansBold; distTxt.TextSize = 12; distTxt.Visible = false; distTxt.Parent = mainGui
    espCache[plr] = { box = box, nameTxt = nameTxt, distTxt = distTxt }
end
for _, p in ipairs(Players:GetPlayers()) do initPlayer(p) end
Players.PlayerAdded:Connect(initPlayer)
Players.PlayerRemoving:Connect(function(plr) 
    if espCache[plr] then 
        espCache[plr].box:Destroy(); espCache[plr].nameTxt:Destroy(); espCache[plr].distTxt:Destroy(); espCache[plr] = nil 
    end 
end)

task.spawn(function()
    while task.wait(0.02) do 
        -- 高亮渲染
        if Config.Highlight then
            local validTargets = {}
            for plr, _ in pairs(espCache) do
                if plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local rName = getRoleName(plr)
                        if Config.Filters[rName] then
                            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                            table.insert(validTargets, {plr = plr, dist = dist})
                        end
                    end
                end
            end
            table.sort(validTargets, function(a, b) return a.dist < b.dist end)
            for i = 1, HIGHLIGHT_POOL_SIZE do
                local hl = highlightPool[i]
                local target = validTargets[i]
                if target and i <= 15 then 
                    hl.Adornee = target.plr.Character
                    hl.FillColor = getRoleColor(getRoleName(target.plr))
                else
                    hl.Adornee = nil
                end
            end
        else
            for i = 1, HIGHLIGHT_POOL_SIZE do highlightPool[i].Adornee = nil end
        end
        
        -- 透视渲染
        if not Config.ESP then
            for _, d in pairs(espCache) do d.box.Visible = false; d.nameTxt.Visible = false; d.distTxt.Visible = false end
        else
            for plr, data in pairs(espCache) do
                pcall(function()
                    if plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        local head = plr.Character:FindFirstChild("Head")
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if hrp and head and hum and hum.Health > 0 then
                            local rName = getRoleName(plr)
                            if Config.Filters[rName] then
                                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                                if onScreen then
                                    local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude / 3)
                                    data.box.Visible = true; data.box.Size = UDim2.fromOffset(40, 60); data.box.Position = UDim2.fromOffset(headPos.X - 20, headPos.Y + 10)
                                    data.nameTxt.Visible = true; data.nameTxt.Text = "[" .. rName .. "] " .. plr.Name; data.nameTxt.TextColor3 = getRoleColor(rName); data.nameTxt.Position = UDim2.fromOffset(headPos.X, headPos.Y - 10)
                                    data.distTxt.Visible = true; data.distTxt.Text = tostring(distance) .. "m"; data.distTxt.Position = UDim2.fromOffset(headPos.X, headPos.Y + 75)
                                else
                                    data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                                end
                            else
                                data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                            end
                        else
                            data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                        end
                    else
                        data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                    end
                end)
            end
        end
    end
end)

print("[DeepSeek] 纯净多选阵营版加载完毕")