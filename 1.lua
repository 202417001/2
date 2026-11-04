-- ============================================
-- Ninja Panel (侧边栏导航 · 固定大小)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CFG = { 
    ESP = false, ESPHealth = false, ESPRole = false,
    KillAura = false, KillRange = 30, Cooldown = 1.0, HitCount = 3
}
local CN_ROLE_MAP = { ["Chef"]="厨师",["Civilian"]="平民",["Delivery"]="快递员",["Farmer"]="农夫",["Fire"]="消防员",["Medical"]="医生",["Police"]="警察",["Prisoner"]="囚犯",["Road Service"]="路政",["Transit"]="公交司机" }

local function getHiddenGui(name)
    local g = Instance.new("ScreenGui"); g.Name = name; g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    if syn and syn.protect_gui then syn.protect_gui(g); g.Parent = game:GetService("CoreGui")
    elseif gethui then g.Parent = gethui() else g.Parent = LP:WaitForChild("PlayerGui") end
    return g
end

local mainGui = getHiddenGui("MainPanel_" .. math.random(1000, 9999))
local espGui = getHiddenGui("EspRender_" .. math.random(1000, 9999))

-- ==========================================
-- 固定大小主面板
-- ==========================================
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 260); main.Position = UDim2.fromScale(0.1, 0.2)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30); main.BackgroundTransparency = 0.1 
main.BorderSizePixel = 0; main.Active = true; main.Draggable = true; main.Parent = mainGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(60, 60, 70); stroke.Thickness = 1

local icon = Instance.new("TextButton"); icon.Size = UDim2.fromOffset(40, 40); icon.Position = UDim2.fromOffset(12, 240)
icon.BackgroundColor3 = Color3.fromRGB(30, 30, 35); icon.Text = "N"; icon.TextColor3 = Color3.new(1, 1, 1); icon.Font = Enum.Font.GothamBold; icon.TextSize = 18
icon.Visible = false; icon.Active = true; icon.Draggable = true; icon.Parent = mainGui; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)
local function minimize() main.Visible = false; icon.Visible = true end

-- 标题栏
local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, 0, 0, 36); title.BackgroundTransparency = 1
title.Text = "Ninja Panel"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = Enum.Font.GothamBold; title.TextSize = 15; title.Parent = main
local titleLine = Instance.new("Frame"); titleLine.Size = UDim2.new(1, 0, 0, 1); titleLine.Position = UDim2.fromOffset(0, 36)
titleLine.BackgroundColor3 = Color3.fromRGB(50, 50, 60); titleLine.BorderSizePixel = 0; titleLine.Parent = main

local function mkTitleBtn(text, xoff, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(24, 24); b.Position = UDim2.new(1, xoff, 0, 6)
    b.BackgroundTransparency = 1; b.Text = text; b.TextColor3 = Color3.fromRGB(200, 200, 200); b.Font = Enum.Font.GothamBold; b.TextSize = 18; b.Parent = main
    b.MouseButton1Click:Connect(cb); return b
end
mkTitleBtn("×", -25, minimize)

-- ==========================================
-- 左侧导航栏
-- ==========================================
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 80, 1, -37); sidebar.Position = UDim2.fromOffset(0, 37)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25); sidebar.BackgroundTransparency = 0.5
sidebar.BorderSizePixel = 0; sidebar.Parent = main

local navLayout = Instance.new("UIListLayout", sidebar)
navLayout.Padding = UDim.new(0, 4); navLayout.SortOrder = Enum.SortOrder.LayoutOrder
local navPad = Instance.new("UIPadding", sidebar); navPad.PaddingTop = UDim.new(0, 8)

-- ==========================================
-- 右侧内容区
-- ==========================================
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -80, 1, -37); content.Position = UDim2.fromOffset(80, 37)
content.BackgroundTransparency = 1; content.Parent = main

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Size = UDim2.new(1, 0, 1, 0)
contentScroll.BackgroundTransparency = 1; contentScroll.BorderSizePixel = 0; contentScroll.ScrollBarThickness = 2
contentScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0); contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; contentScroll.Parent = content
local contentLayout = Instance.new("UIListLayout", contentScroll); contentLayout.Padding = UDim.new(0, 8); contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
local contentPad = Instance.new("UIPadding", contentScroll); contentPad.PaddingTop = UDim.new(0, 8); contentPad.PaddingLeft = UDim.new(0, 8); contentPad.PaddingRight = UDim.new(0, 8)

-- ==========================================
-- 导航 Tab 切换逻辑
-- ==========================================
local currentTab = ""
local navBtns = {}

local function clearContent()
    for _, child in ipairs(contentScroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

local function updateNavUI()
    for name, btn in pairs(navBtns) do
        if name == currentTab then
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.TextColor3 = Color3.new(1, 1, 1)
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
            btn.TextColor3 = Color3.fromRGB(150, 150, 160)
        end
    end
end

local function switchTab(tabName)
    currentTab = tabName
    updateNavUI()
    clearContent()

    if tabName == "透视" then
        local lbl1 = Instance.new("TextLabel"); lbl1.Size = UDim2.new(1, 0, 0, 20); lbl1.BackgroundTransparency = 1; lbl1.Text = "── 视觉透视 ──"
        lbl1.TextColor3 = Color3.fromRGB(150, 150, 160); lbl1.Font = Enum.Font.GothamBold; lbl1.TextSize = 12; lbl1.TextXAlignment = Enum.TextXAlignment.Left; lbl1.Parent = contentScroll
        
        addToggle(contentScroll, "玩家名字透视", "ESP")
        addToggle(contentScroll, "血条比例透视", "ESPHealth")
        addToggle(contentScroll, "中文职业透视", "ESPRole")

    elseif tabName == "战斗" then
        local lbl2 = Instance.new("TextLabel"); lbl2.Size = UDim2.new(1, 0, 0, 20); lbl2.BackgroundTransparency = 1; lbl2.Text = "── 装备触发杀戮 ──"
        lbl2.TextColor3 = Color3.fromRGB(150, 150, 160); lbl2.Font = Enum.Font.GothamBold; lbl2.TextSize = 12; lbl2.TextXAlignment = Enum.TextXAlignment.Left; lbl2.Parent = contentScroll

        addToggle(contentScroll, "开启装备秒杀", "KillAura")
        addSlider(contentScroll, "杀戮范围 (米)", 10, 150, CFG.KillRange, function(val) CFG.KillRange = val end)
        addSlider(contentScroll, "攻击次数 (倍率)", 1, 20, CFG.HitCount, function(val) CFG.HitCount = val end)
        addSlider(contentScroll, "全局冷却 (秒)", 0.1, 3.0, CFG.Cooldown, function(val) CFG.Cooldown = val end)
    end
end

local function createNavBtn(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 36); btn.Position = UDim2.fromOffset(4, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    btn.Text = name; btn.TextColor3 = Color3.fromRGB(150, 150, 160)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    navBtns[name] = btn
end

createNavBtn("透视")
createNavBtn("战斗")

-- ==========================================
-- UI 组件生成
-- ==========================================
local function addToggle(parent, name, key)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 42); row.BorderSizePixel = 0; row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.fromOffset(12, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

    local track = Instance.new("Frame"); track.Size = UDim2.fromOffset(36, 20); track.Position = UDim2.new(1, -44, 0.5, -10)
    track.BackgroundColor3 = Color3.fromRGB(20, 20, 25); track.BorderSizePixel = 0; track.Parent = row; Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame"); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 170, 100); fill.BorderSizePixel = 0; fill.Parent = track; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(16, 16); knob.Position = UDim2.new(0, 2, 0.5, -8); knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200); knob.Parent = track; Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton"); btn.Size = UDim2.fromScale(1,1); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = row
    
    local function updateUI()
        if CFG[key] then
            TweenService:Create(fill, TweenInfo.new(0.15), {Size = UDim2.fromScale(1,1)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.new(1,1,1)}):Play()
        else
            TweenService:Create(fill, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
    end
    btn.MouseButton1Click:Connect(function() CFG[key] = not CFG[key]; updateUI() end)
    updateUI()
end

local function addSlider(parent, name, minVal, maxVal, defaultVal, callback)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 42); row.BorderSizePixel = 0; row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 0, 20); lbl.Position = UDim2.fromOffset(12, 4)
    lbl.BackgroundTransparency = 1; lbl.Text = name .. ": " .. defaultVal; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

    local track = Instance.new("Frame"); track.Size = UDim2.new(1, -24, 0, 6); track.Position = UDim2.new(0, 12, 1, -14)
    track.BackgroundColor3 = Color3.fromRGB(20, 20, 25); track.BorderSizePixel = 0; track.Parent = row; Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((defaultVal-minVal)/(maxVal-minVal), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 170, 100); fill.BorderSizePixel = 0; fill.Parent = track; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(16, 16); knob.Position = UDim2.new((defaultVal-minVal)/(maxVal-minVal), -8, 0.5, 0); knob.AnchorPoint = Vector2.new(0, 0.5); knob.BackgroundColor3 = Color3.new(1,1,1); knob.Parent = track; Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local touchArea = Instance.new("TextButton"); touchArea.Size = UDim2.new(1, 0, 1, 0); touchArea.BackgroundTransparency = 1; touchArea.Text = ""; touchArea.Parent = row
    local isDragging = false
    local function updateVal(xPos)
        local relX = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * relX
        if maxVal <= 5 then val = math.floor(val * 10) / 10 else val = math.floor(val) end
        fill.Size = UDim2.new(relX, 0, 1, 0); knob.Position = UDim2.new(relX, -8, 0.5, 0)
        lbl.Text = name .. ": " .. val; callback(val)
    end
    touchArea.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true; updateVal(input.Position.X) end end)
    UIS.InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then updateVal(input.Position.X) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
end

-- 默认打开透视页
switchTab("透视")

-- ==========================================
-- 核心逻辑 (动态追踪 & 隐蔽杀戮)
-- ==========================================
local lastAttackTime = 0

local function executeWeaponKill(tool)
    if not CFG.KillAura then return end
    local currentTime = tick()
    if currentTime - lastAttackTime < CFG.Cooldown then return end
    lastAttackTime = currentTime

    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local hitTargets = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tgtHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            local tgtHum = plr.Character:FindFirstChildOfClass("Humanoid")
            
            if tgtHRP and tgtHum and tgtHum.Health > 0 then
                local dist = (myHRP.Position - tgtHRP.Position).Magnitude
                if dist <= CFG.KillRange then
                    if not hitTargets[plr.Character] then
                        hitTargets[plr.Character] = true
                        
                        task.spawn(function()
                            for i = 1, CFG.HitCount do
                                pcall(function() tool:Activate() end)
                                local handle = tool:FindFirstChild("Handle")
                                if handle and firetouchinterest then
                                    for _, part in ipairs(plr.Character:GetChildren()) do
                                        if part:IsA("BasePart") then
                                            pcall(function()
                                                firetouchinterest(handle, part, 0)
                                                task.wait(math.random(10, 35) / 1000)
                                                firetouchinterest(handle, part, 1)
                                            end)
                                        end
                                    end
                                end
                                task.wait(math.random(20, 60) / 1000)
                            end
                        end)
                    end
                end
            end
        end
    end
end

local function onCharacterAdded(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.1)
            executeWeaponKill(child)
        end
    end)
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then executeWeaponKill(currentTool) end
end
if LP.Character then onCharacterAdded(LP.Character) end
LP.CharacterAdded:Connect(onCharacterAdded)

-- ESP 渲染
local espData = {}
local function checkAndBuildESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not espData[plr] then
            local g = Instance.new("BillboardGui")
            g.Name = "e_" .. math.random(10000, 99999); g.Size = UDim2.fromOffset(160, 50)
            g.AlwaysOnTop = true; g.Enabled = false; g.Parent = espGui
            
            local nm = Instance.new("TextLabel"); nm.Size = UDim2.new(1, 0, 0, 16); nm.BackgroundTransparency = 1; nm.TextColor3 = Color3.new(1, 1, 1); nm.TextStrokeTransparency = 0; nm.Font = Enum.Font.GothamBold; nm.TextSize = 12; nm.Text = plr.Name; nm.Parent = g
            local ds = Instance.new("TextLabel"); ds.Size = UDim2.new(1, 0, 0, 14); ds.Position = UDim2.fromOffset(0, 16); ds.BackgroundTransparency = 1; ds.TextColor3 = Color3.fromRGB(200, 200, 200); ds.TextStrokeTransparency = 0; ds.TextSize = 11; ds.Parent = g
            
            local barBg = Instance.new("Frame"); barBg.Size = UDim2.fromOffset(24, 3); barBg.Position = UDim2.new(0.5, -16, 0, 32); barBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60); barBg.BorderSizePixel = 0; barBg.Visible = false; barBg.Parent = g
            local bar = Instance.new("Frame"); bar.Size = UDim2.fromScale(1, 1); bar.BackgroundColor3 = Color3.fromRGB(0, 220, 100); bar.BorderSizePixel = 0; bar.Parent = barBg
            local hpText = Instance.new("TextLabel"); hpText.Size = UDim2.fromOffset(30, 14); hpText.Position = UDim2.new(0.5, 10, 0, 27); hpText.BackgroundTransparency = 1; hpText.TextColor3 = Color3.new(1, 1, 1); hpText.TextStrokeTransparency = 0; hpText.TextSize = 9; hpText.Font = Enum.Font.GothamBold; hpText.Text = "100%"; hpText.TextXAlignment = Enum.TextXAlignment.Left; hpText.Visible = false; hpText.Parent = g
            
            espData[plr] = { gui = g, name = nm, dist = ds, bar = bar, barBg = barBg, hpText = hpText }
        end
    end
end

local function getRoleLabel(plr)
    if plr.Team then
        local tName = plr.Team.Name
        if tName and tName ~= "" and tName ~= "Neutral" and tName ~= "???" and not tName:find("%?") then return CN_ROLE_MAP[tName] or tName end
    end
    return "平民"
end

Players.PlayerRemoving:Connect(function(p) 
    if espData[p] and espData[p].gui then espData[p].gui:Destroy() end; espData[p] = nil 
end)

local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1; if frameCount % 2 ~= 0 then return end
    checkAndBuildESP()

    for plr, data in pairs(espData) do
        if not CFG.ESP or not plr.Parent or not plr.Character then 
            data.gui.Enabled = false; continue
        end
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        
        if not hrp or not hum or hum.Health <= 0 then
            data.gui.Enabled = false; continue
        end

        data.gui.Enabled = true; data.gui.Adornee = hrp
        data.dist.Text = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude) .. " studs"
        
        if CFG.ESPRole then data.name.Text = "[" .. getRoleLabel(plr) .. "] " .. plr.Name 
        else data.name.Text = plr.Name end
        
        data.barBg.Visible = CFG.ESPHealth; data.hpText.Visible = CFG.ESPHealth
        if CFG.ESPHealth then
            local maxHp = math.max(hum.MaxHealth, 1) 
            local hpRatio = math.clamp(hum.Health / maxHp, 0, 1)
            data.bar.Size = UDim2.fromScale(hpRatio, 1)
            data.bar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 0)
            hpText.Text = math.floor(hpRatio * 100) .. "%"
        end
    end
end)

print("[Ninja Panel] 侧边栏导航版加载完毕")