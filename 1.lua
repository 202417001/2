-- ============================================
-- Ninja Panel (装备触发 · 攻击倍率/范围可调)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CFG = { 
    ESP = false, ESPHealth = false, ESPRole = false,
    KillAura = false, KillRange = 30, Cooldown = 1.0, HitCount = 3 -- 新增 HitCount 攻击次数
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
-- 极简暗黑主面板
-- ==========================================
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(280, 400); main.Position = UDim2.fromScale(0.1, 0.2)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30); main.BackgroundTransparency = 0.1 
main.BorderSizePixel = 0; main.Active = true; main.Draggable = true; main.Parent = mainGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(60, 60, 70); stroke.Thickness = 1
local uiScale = Instance.new("UIScale"); uiScale.Scale = 1; uiScale.Parent = main

local icon = Instance.new("TextButton"); icon.Size = UDim2.fromOffset(40, 40); icon.Position = UDim2.fromOffset(12, 240)
icon.BackgroundColor3 = Color3.fromRGB(30, 30, 35); icon.Text = "N"; icon.TextColor3 = Color3.new(1, 1, 1); icon.Font = Enum.Font.GothamBold; icon.TextSize = 18
icon.Visible = false; icon.Active = true; icon.Draggable = true; icon.Parent = mainGui; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)
local function minimize() main.Visible = false; icon.Visible = true end

local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, 0, 0, 40); title.BackgroundTransparency = 1
title.Text = "Ninja Panel"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = Enum.Font.GothamBold; title.TextSize = 15; title.Parent = main

local function mkTitleBtn(text, xoff, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(24, 24); b.Position = UDim2.new(1, xoff, 0, 8)
    b.BackgroundTransparency = 1; b.Text = text; b.TextColor3 = Color3.fromRGB(200, 200, 200); b.Font = Enum.Font.GothamBold; b.TextSize = 18; b.Parent = main
    b.MouseButton1Click:Connect(cb); return b
end
mkTitleBtn("−", -80, function() uiScale.Scale = math.max(0.6, uiScale.Scale - 0.1) end)
mkTitleBtn("+", -50, function() uiScale.Scale = math.min(1.8, uiScale.Scale + 0.1) end)
mkTitleBtn("×", -25, minimize)

local scroll = Instance.new("ScrollingFrame"); scroll.Size = UDim2.new(1, -16, 1, -55); scroll.Position = UDim2.fromOffset(8, 45)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = main
local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = scroll

-- ==========================================
-- UI 组件
-- ==========================================
local function addToggle(parent, name, key)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 42); row.BorderSizePixel = 0; row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.fromOffset(12, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

    local track = Instance.new("Frame"); track.Size = UDim2.fromOffset(36, 20); track.Position = UDim2.new(1, -48, 0.5, -10)
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

-- ==========================================
-- 核心：装备触发杀戮 + 连续多段打击
-- ==========================================
local lastAttackTime = 0

local function executeWeaponKill(tool)
    if not CFG.KillAura then return end
    
    -- 5. 全局冷却，防秒切
    local currentTime = tick()
    if currentTime - lastAttackTime < CFG.Cooldown then return end
    lastAttackTime = currentTime

    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    -- 4. 记录已经打过的目标
    local hitTargets = {}

    -- 3. 扫圈内敌人
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tgtHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            local tgtHum = plr.Character:FindFirstChildOfClass("Humanoid")
            
            if tgtHRP and tgtHum and tgtHum.Health > 0 then
                local dist = (myHRP.Position - tgtHRP.Position).Magnitude
                
                -- 2. 范围判定
                if dist <= CFG.KillRange then
                    if not hitTargets[plr.Character] then
                        hitTargets[plr.Character] = true
                        
                        -- 🔥 新功能：根据设定的倍率，连续攻击多次
                        task.spawn(function()
                            for i = 1, CFG.HitCount do
                                -- 触发武器动作
                                pcall(function() tool:Activate() end)
                                
                                -- 触碰扣血
                                local handle = tool:FindFirstChild("Handle")
                                if handle and firetouchinterest then
                                    for _, part in ipairs(plr.Character:GetChildren()) do
                                        if part:IsA("BasePart") then
                                            pcall(function()
                                                firetouchinterest(handle, part, 0)
                                                task.wait(0.01)
                                                firetouchinterest(handle, part, 1)
                                            end)
                                        end
                                    end
                                end
                                -- 稍微给服务器一点反应时间，防止瞬间发包过载被踢
                                task.wait(0.05) 
                            end
                        end)
                    end
                end
            end
        end
    end
end

-- 1. 监听 Equipped 事件
local function onCharacterAdded(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.1)
            executeWeaponKill(child)
        end
    end)
    
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        executeWeaponKill(currentTool)
    end
end

if LP.Character then onCharacterAdded(LP.Character) end
LP.CharacterAdded:Connect(onCharacterAdded)

-- ==========================================
-- 透视渲染逻辑
-- ==========================================
local function getRoleLabel(plr)
    if plr.Team then
        local tName = plr.Team.Name
        if tName and tName ~= "" and tName ~= "Neutral" and tName ~= "???" and not tName:find("%?") then return CN_ROLE_MAP[tName] or tName end
    end
    return "平民"
end

local espData = {}
local function buildESP(plr)
    if plr == LP then return end; if espData[plr] then return end
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

Players.PlayerAdded:Connect(function(p) task.wait(1) buildESP(p) end)
for _, p in ipairs(Players:GetPlayers()) do buildESP(p) end
Players.PlayerRemoving:Connect(function(p) if espData[p] and espData[p].gui then espData[p].gui:Destroy() end; espData[p] = nil end)

local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1; if frameCount % 2 ~= 0 then return end
    for plr, data in pairs(espData) do
        if not CFG.ESP or not plr.Character then data.gui.Enabled = false
        else
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart"); local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                data.gui.Enabled = true; data.gui.Adornee = hrp
                data.dist.Text = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude) .. " studs"
                
                if CFG.ESPRole then data.name.Text = "[" .. getRoleLabel(plr) .. "] " .. plr.Name 
                else data.name.Text = plr.Name end
                
                data.barBg.Visible = CFG.ESPHealth; data.hpText.Visible = CFG.ESPHealth
                if CFG.ESPHealth then
                    local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    data.bar.Size = UDim2.fromScale(hpRatio, 1)
                    data.bar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 0)
                    hpText.Text = math.floor(hpRatio * 100) .. "%"
                end
            else data.gui.Enabled = false end
        end
    end
end)

-- 构建 UI
local lbl1 = Instance.new("TextLabel"); lbl1.Size = UDim2.new(1, -6, 0, 20); lbl1.BackgroundTransparency = 1; lbl1.Text = "── 视觉透视 ──"
lbl1.TextColor3 = Color3.fromRGB(150, 150, 160); lbl1.Font = Enum.Font.GothamBold; lbl1.TextSize = 12; lbl1.TextXAlignment = Enum.TextXAlignment.Left; lbl1.Parent = scroll
addToggle(scroll, "玩家名字透视", "ESP")
addToggle(scroll, "血条比例透视", "ESPHealth")
addToggle(scroll, "中文职业透视", "ESPRole")

local lbl2 = Instance.new("TextLabel"); lbl2.Size = UDim2.new(1, -6, 0, 20); lbl2.BackgroundTransparency = 1; lbl2.Text = "── 装备触发杀戮 ──"
lbl2.TextColor3 = Color3.fromRGB(150, 150, 160); lbl2.Font = Enum.Font.GothamBold; lbl2.TextSize = 12; lbl2.TextXAlignment = Enum.TextXAlignment.Left; lbl2.Parent = scroll
addToggle(scroll, "开启装备秒杀", "KillAura")
addSlider(scroll, "杀戮范围 (米)", 10, 150, CFG.KillRange, function(val) CFG.KillRange = val end)
addSlider(scroll, "攻击次数 (倍率)", 1, 20, CFG.HitCount, function(val) CFG.HitCount = val end)
addSlider(scroll, "全局冷却 (秒)", 0.1, 3.0, CFG.Cooldown, function(val) CFG.Cooldown = val end)

print("[Ninja Panel] 极简·装备触发杀戮版加载完毕")