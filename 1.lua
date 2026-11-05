-- ============================================
-- DeepSeek Studio (胶囊置顶 · 面板正常居中)
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
-- 1. 高亮池
-- ==========================================
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

-- ==========================================
-- 2. 角色逻辑
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
    if not rawRole then
        for _, v in ipairs(plr:GetChildren()) do
            if (v:IsA("StringValue") or v:IsA("IntValue")) and (v.Name:lower():find("role") or v.Name:lower():find("job") or v.Name:lower():find("team")) then
                rawRole = tostring(v.Value); break
            end
        end
    end
    if not rawRole and plr.Character then
        for _, v in ipairs(plr.Character:GetChildren()) do
            if (v:IsA("StringValue") or v:IsA("IntValue")) and (v.Name:lower():find("role") or v.Name:lower():find("job")) then
                rawRole = tostring(v.Value); break
            end
        end
    end

    if rawRole then
        if RoleDict[rawRole] then return RoleDict[rawRole] end
        local lr = rawRole:lower()
        if lr:find("police") then return "警察"
        elseif lr:find("civilian") then return "平民"
        elseif lr:find("medical") or lr:find("doctor") then return "医生"
        elseif lr:find("fire") then return "消防员"
        elseif lr:find("chef") then return "厨师"
        elseif lr:find("farmer") then return "农夫"
        elseif lr:find("prisoner") then return "囚犯"
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

local function isRoleVisible(roleName)
    return Config.Filters[roleName] == true
end

-- ==========================================
-- 3. Fluent UI (独立位置控制)
-- ==========================================
local Main = Instance.new("Frame")
Main.AnchorPoint = Vector2.new(0.5, 0)
Main.Position = UDim2.new(0.5, 0, 0, 10) -- 初始胶囊在最上方
Main.Size = UDim2.fromOffset(110, 32)
Main.BackgroundColor3 = Colors.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = mainGui
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(1, 0)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(200, 200, 200)
MainStroke.Thickness = 1

local isOpen = false
local isAnimating = false

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

local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.fromScale(1, 1)
MainContent.BackgroundTransparency = 1
MainContent.Visible = false
MainContent.ZIndex = 1 
MainContent.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 2
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
Title.ZIndex = 2
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(32, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Colors.TextLight
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.ZIndex = 10
CloseBtn.Parent = TopBar

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(120, 250)
Sidebar.Position = UDim2.fromOffset(8, 40)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2
Sidebar.Parent = MainContent
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local UserFrame = Instance.new("Frame")
UserFrame.Size = UDim2.new(1, -16, 0, 44)
UserFrame.Position = UDim2.new(0, 8, 1, -52)
UserFrame.BackgroundColor3 = Colors.Panel
UserFrame.BorderSizePixel = 0
UserFrame.ZIndex = 2
UserFrame.Parent = Sidebar
Instance.new("UICorner", UserFrame).CornerRadius = UDim.new(0, 8)

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.fromOffset(30, 30)
Avatar.Position = UDim2.fromOffset(7, 7)
Avatar.BackgroundColor3 = Colors.Bg
Avatar.ZIndex = 3
Avatar.Parent = UserFrame
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
task.spawn(function()
    local success, url = pcall(function() return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
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
UserName.ZIndex = 3
UserName.Parent = UserFrame

local NavBtn = Instance.new("TextButton")
NavBtn.Size = UDim2.new(1, -12, 0, 32)
NavBtn.Position = UDim2.fromOffset(6, 8)
NavBtn.BackgroundColor3 = Colors.Panel
NavBtn.Text = "  视觉"
NavBtn.TextColor3 = Colors.AccentBlue
NavBtn.Font = Enum.Font.GothamBold
NavBtn.TextSize = 12
NavBtn.TextXAlignment = Enum.TextXAlignment.Left
NavBtn.ZIndex = 3
NavBtn.Parent = Sidebar
Instance.new("UICorner", NavBtn).CornerRadius = UDim.new(0, 6)

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -136, 1, -50)
ContentFrame.Position = UDim2.fromOffset(128, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 2
ContentFrame.Parent = MainContent

local CardList = Instance.new("ScrollingFrame")
CardList.Size = UDim2.new(1, 0, 1, 0)
CardList.BackgroundTransparency = 1
CardList.BorderSizePixel = 0
CardList.ScrollBarThickness = 3
CardList.ScrollBarImageColor3 = Colors.ToggleOff
CardList.CanvasSize = UDim2.new(0, 0, 0, 0)
CardList.AutomaticCanvasSize = Enum.AutomaticSize.Y
CardList.ZIndex = 2
CardList.Parent = ContentFrame

local CardLayout = Instance.new("UIListLayout", CardList)
CardLayout.Padding = UDim.new(0, 8)
CardLayout.SortOrder = Enum.SortOrder.LayoutOrder
local CardPad = Instance.new("UIPadding", CardList)
CardPad.PaddingRight = UDim.new(0, 8)

-- ==========================================
-- 组件生成器
-- ==========================================
local function AddCard(text, toggleKey)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Colors.Panel
    card.BorderSizePixel = 0
    card.ZIndex = 3
    card.Parent = CardList
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
    lbl.ZIndex = 4
    lbl.Parent = card
    
    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(40, 22)
    track.Position = UDim2.new(1, -56, 0.5, -11)
    track.BackgroundColor3 = Colors.ToggleOff
    track.BorderSizePixel = 0
    track.ZIndex = 4
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = Colors.Panel
    knob.ZIndex = 5
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1,1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 6
    btn.Parent = card
    
    local isOn = Config[toggleKey] or false
    if isOn then
        track.BackgroundColor3 = Colors.AccentBlue
        knob.Position = UDim2.fromOffset(20, 2)
    end

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

local function AddMultiSelectDropdown(titleText, options, configTable)
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, 0, 0, 44)
    dropdown.BackgroundColor3 = Colors.Panel
    dropdown.BorderSizePixel = 0
    dropdown.ClipsDescendants = true
    dropdown.ZIndex = 3
    dropdown.Parent = CardList
    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 8)

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundTransparency = 1
    header.Text = ""
    header.ZIndex = 4
    header.Parent = dropdown

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.fromOffset(16, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Colors.TextDark
    title.Font = Enum.Font.Gotham
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 5
    title.Parent = header
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(16, 16)
    arrow.Position = UDim2.new(1, -24, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Colors.TextLight
    arrow.TextSize = 10
    arrow.ZIndex = 5
    arrow.Parent = header

    local optionList = Instance.new("Frame")
    optionList.Size = UDim2.new(1, 0, 0, 0)
    optionList.Position = UDim2.fromOffset(0, 44)
    optionList.BackgroundTransparency = 1
    optionList.ZIndex = 4
    optionList.Parent = dropdown
    local optLayout = Instance.new("UIListLayout", optionList)
    optLayout.Padding = UDim.new(0, 2)

    local isExpanded = false
    local function expand()
        isExpanded = not isExpanded
        local targetSize = isExpanded and UDim2.new(1, 0, 0, 44 + #options * 34 + 10) or UDim2.new(1, 0, 0, 44)
        TweenService:Create(dropdown, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Size = targetSize}):Play()
        TweenService:Create(arrow, TweenInfo.new(0.35), {Rotation = isExpanded and 180 or 0}):Play()
    end

    header.MouseButton1Click:Connect(expand)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 32)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = ""
        optBtn.ZIndex = 5
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
        optText.ZIndex = 6
        optText.Parent = optBtn

        local checkBox = Instance.new("Frame")
        checkBox.Size = UDim2.fromOffset(16, 16)
        checkBox.Position = UDim2.new(1, -30, 0.5, -8)
        checkBox.BackgroundColor3 = configTable[opt] and Colors.AccentBlue or Colors.Panel
        checkBox.ZIndex = 6
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
        checkMark.ZIndex = 7
        checkMark.Visible = configTable[opt] or false
        checkMark.Parent = checkBox

        optBtn.MouseButton1Click:Connect(function()
            configTable[opt] = not configTable[opt]
            local state = configTable[opt]
            checkBox.BackgroundColor3 = state and Colors.AccentBlue or Colors.Panel
            checkMark.Visible = state
            TweenService:Create(checkBox, TweenInfo.new(0.1), {BackgroundColor3 = checkBox.BackgroundColor3}):Play()
        end)
    end
end

AddCard("玩家透视", "ESP")
AddCard("人物高亮", "Highlight")
AddMultiSelectDropdown("透视阵营选择", 
    {"平民", "警察", "医生", "消防员", "厨师", "快递员", "农夫", "囚犯", "其他"}, 
    Config.Filters
)

local openTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local function ToggleUI(openState)
    if isAnimating then return end
    isAnimating = true
    isOpen = openState
    if isOpen then
        MainContent.Visible = true
        CapsuleText.Visible = false
        CapsuleBtn.Visible = false
        -- 展开时，下移到 Y=40，保持正常显示位置
        TweenService:Create(Main, openTweenInfo, {Size = UDim2.fromOffset(480, 320), Position = UDim2.new(0.5, 0, 0, 40)}):Play()
        TweenService:Create(MainCorner, openTweenInfo, {CornerRadius = UDim.new(0, 12)}):Play()
        task.wait(0.5)
    else
        MainContent.Visible = false
        -- 收起时，回到顶部 Y=10 变回胶囊
        TweenService:Create(Main, closeTweenInfo, {Size = UDim2.fromOffset(110, 32), Position = UDim2.new(0.5, 0, 0, 10)}):Play()
        TweenService:Create(MainCorner, closeTweenInfo, {CornerRadius = UDim.new(1, 0)}):Play()
        task.wait(0.4)
        CapsuleText.Visible = true
        CapsuleBtn.Visible = true
    end
    isAnimating = false
end

CapsuleBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)

-- ==========================================
-- 4. 底层透视与高亮逻辑
-- ==========================================
local espCache = {}

local function initPlayer(plr)
    if plr == LP or espCache[plr] then return end
    local data = {}
    local box = Instance.new("Frame"); box.Name = tostring(math.random(10000, 99999)); box.BackgroundTransparency = 1; box.BorderSizePixel = 1; box.BorderColor3 = Color3.fromRGB(0, 255, 100); box.Visible = false; box.ZIndex = 2; box.Parent = mainGui
    local nameTxt = Instance.new("TextLabel"); nameTxt.Name = tostring(math.random(10000, 99999)); nameTxt.BackgroundTransparency = 1; nameTxt.TextColor3 = Color3.new(1, 1, 1); nameTxt.TextStrokeTransparency = 0; nameTxt.Font = Enum.Font.SourceSansBold; nameTxt.TextSize = 14; nameTxt.Visible = false; nameTxt.ZIndex = 2; nameTxt.Parent = mainGui
    local distTxt = Instance.new("TextLabel"); distTxt.Name = tostring(math.random(10000, 99999)); distTxt.BackgroundTransparency = 1; distTxt.TextColor3 = Color3.fromRGB(200, 200, 200); distTxt.TextStrokeTransparency = 0; distTxt.Font = Enum.Font.SourceSansBold; distTxt.TextSize = 12; distTxt.Visible = false; distTxt.ZIndex = 2; distTxt.Parent = mainGui
    data.box = box; data.nameTxt = nameTxt; data.distTxt = distTxt
    espCache[plr] = data
end

Players.PlayerAdded:Connect(initPlayer)
for _, p in ipairs(Players:GetPlayers()) do initPlayer(p) end
Players.PlayerRemoving:Connect(function(plr)
    local d = espCache[plr]
    if d then
        if d.box then d.box:Destroy() end
        if d.nameTxt then d.nameTxt:Destroy() end
        if d.distTxt then d.distTxt:Destroy() end
        espCache[plr] = nil
    end
end)

local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    if frameCount % 3 == 0 then
        if Config.Highlight then
            local validTargets = {}
            for plr, _ in pairs(espCache) do
                if plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local roleName = getRoleName(plr)
                        if isRoleVisible(roleName) then
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
            for i = 1, HIGHLIGHT_POOL_SIZE do
                highlightPool[i].Adornee = nil
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.01) do 
        if not Config.ESP then
            for _, d in pairs(espCache) do
                d.box.Visible = false; d.nameTxt.Visible = false; d.distTxt.Visible = false
            end
            continue
        end
        
        for plr, data in pairs(espCache) do
            pcall(function()
                if not plr.Character then
                    data.box.Visible = false; data.nameTxt.Visible = false; d.distTxt.Visible = false
                    return
                end
                
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local head = plr.Character:FindFirstChild("Head")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                
                if not hrp or not head or not hum or hum.Health <= 0 then
                    data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                    return
                end
                
                local roleName = getRoleName(plr)
                if not isRoleVisible(roleName) then
                    data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                    return
                end

                local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local footPos, footOnScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                if headOnScreen and footOnScreen then
                    local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude / 3)
                    local boxHeight = math.abs(footPos.Y - headPos.Y)
                    local boxWidth = boxHeight * 0.65
                    local centerY = (headPos.Y + footPos.Y) / 2
                    
                    data.box.Visible = true
                    data.box.AnchorPoint = Vector2.new(0.5, 0.5)
                    data.box.Size = UDim2.fromOffset(boxWidth, boxHeight)
                    data.box.Position = UDim2.fromOffset(headPos.X, centerY)
                    
                    data.nameTxt.Visible = true
                    data.nameTxt.AnchorPoint = Vector2.new(0.5, 1)
                    data.nameTxt.Size = UDim2.fromOffset(200, 20)
                    data.nameTxt.Position = UDim2.fromOffset(headPos.X, headPos.Y - 2)
                    data.nameTxt.Text = "[" .. roleName .. "] " .. plr.Name
                    data.nameTxt.TextColor3 = getRoleColor(roleName)
                    
                    data.distTxt.Visible = true
                    data.distTxt.AnchorPoint = Vector2.new(0.5, 0)
                    data.distTxt.Size = UDim2.fromOffset(100, 20)
                    data.distTxt.Position = UDim2.fromOffset(headPos.X, footPos.Y + 2)
                    data.distTxt.Text = tostring(distance) .. "m"
                else
                    data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                end
            end)
        end
    end
end)

print("[DeepSeek] 胶囊置顶/面板居中版加载完毕")