-- ============================================
-- Ninja Panel v34 (原地杀戮 · 范围可调 · 伤害翻倍)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CFG = {
    ESP = false, ESPHealth = false, ESPRole = false,
    Speed = false, SpeedVal = 18, 
    FakeSpeed = false,
    KillAura = false, KillRange = 50, DamageMult = 1,
    Scale = 1.0,
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

local main = Instance.new("Frame"); main.Size = UDim2.fromOffset(300, 480); main.Position = UDim2.fromScale(0.02, 0.2)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true; main.Parent = mainGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local uiScale = Instance.new("UIScale"); uiScale.Scale = 1; uiScale.Parent = main

local icon = Instance.new("TextButton"); icon.Size = UDim2.fromOffset(46, 46); icon.Position = UDim2.fromOffset(12, 240)
icon.BackgroundColor3 = Color3.fromRGB(40, 40, 52); icon.Text = "N"; icon.TextColor3 = Color3.new(1, 1, 1); icon.Font = Enum.Font.GothamBold; icon.TextSize = 20
icon.Visible = false; icon.Active = true; icon.Draggable = true; icon.Parent = mainGui; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)
local function minimize() main.Visible = false; icon.Visible = true end

local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, 0, 0, 32); title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0; title.Text = "Ninja v34 (杀戮版)"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = Enum.Font.GothamBold; title.TextSize = 16; title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local function mkTitleBtn(text, xoff, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(28, 28); b.Position = UDim2.new(1, xoff, 0, 2)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 75); b.BorderSizePixel = 0; b.Text = text; b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold; b.TextSize = 14; b.Parent = main; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb); return b
end
mkTitleBtn("−", -94, function() uiScale.Scale = math.max(0.6, uiScale.Scale - 0.1) end)
mkTitleBtn("+", -64, function() uiScale.Scale = math.min(1.8, uiScale.Scale + 0.1) end)
mkTitleBtn("▁", -32, minimize)

local scroll = Instance.new("ScrollingFrame"); scroll.Size = UDim2.new(1, -12, 1, -80); scroll.Position = UDim2.fromOffset(6, 38)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 4; scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = main
local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 6); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = scroll

local statusBar = Instance.new("TextLabel"); statusBar.Size = UDim2.new(1, -12, 0, 36); statusBar.Position = UDim2.new(0, 6, 1, -42)
statusBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40); statusBar.BorderSizePixel = 0; statusBar.Text = "运行正常"
statusBar.TextColor3 = Color3.fromRGB(0, 255, 150); statusBar.Font = Enum.Font.GothamBold; statusBar.TextSize = 12
statusBar.Parent = main; Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 6)

local function addButton(text, cb, color)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -6, 0, 34); b.BackgroundColor3 = color or Color3.fromRGB(50, 50, 60)
    b.BorderSizePixel = 0; b.Text = text; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.Gotham; b.TextSize = 14; b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6); b.MouseButton1Click:Connect(cb); return b
end

local function addToggle(name, key)
    local b; b = addButton((CFG[key] and "[开] " or "[关] ") .. name, function()
        CFG[key] = not CFG[key]; b.Text = (CFG[key] and "[开] " or "[关] ") .. name
        b.BackgroundColor3 = CFG[key] and Color3.fromRGB(0, 140, 80) or Color3.fromRGB(50, 50, 60)
    end)
    if CFG[key] then b.BackgroundColor3 = Color3.fromRGB(0, 140, 80) end; return b
end

-- ==========================================
-- 暴力杀戮核心
-- ==========================================
local function getTargetPlayers()
    local targets = {}
    local myChar = LP.Character
    if not myChar then return targets end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return targets end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tgtHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            local tgtHum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tgtHRP and tgtHum and tgtHum.Health > 0 then
                local dist = (myHRP.Position - tgtHRP.Position).Magnitude
                if dist <= CFG.KillRange then
                    table.insert(targets, {plr = plr, char = plr.Character, hrp = tgtHRP, hum = tgtHum})
                end
            end
        end
    end
    return targets
end

-- 暴力循环：0.1秒执行一次，防止卡死
task.spawn(function()
    while task.wait(0.1) do
        if CFG.KillAura then
            local char = LP.Character
            if not char then continue end
            local tool = char:FindFirstChildOfClass("Tool")
            local targets = getTargetPlayers()
            
            if #targets > 0 then
                -- 1. 如果有武器，疯狂触发
                if tool then
                    pcall(function() tool:Activate() end)
                    
                    -- 强行改伤害数值 (如果有的话)
                    for _, obj in ipairs(tool:GetDescendants()) do
                        if (obj:IsA("NumberValue") or obj:IsA("IntValue")) and obj.Name:lower():find("damage") then
                            pcall(function() obj.Value = obj.Value * CFG.DamageMult end)
                        end
                    end
                    
                    -- 强制将武器触碰目标
                    local handle = tool:FindFirstChild("Handle")
                    if handle and firetouchinterest then
                        for _, t in ipairs(targets) do
                            for _, part in ipairs(t.char:GetChildren()) do
                                if part:IsA("BasePart") then
                                    pcall(function()
                                        firetouchinterest(handle, part, 0)
                                        firetouchinterest(handle, part, 1)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 速度与防检测逻辑
-- ==========================================
local oldIndex
local function setupFakeSpeed()
    if not hookmetamethod then return end
    pcall(function()
        oldIndex = hookmetamethod(game, "__index", function(t, k)
            if CFG.FakeSpeed and not checkcaller() then
                if k == "WalkSpeed" and t:IsA("Humanoid") then return 16 end
                if k == "Velocity" and t:IsA("BasePart") and t.Name == "HumanoidRootPart" then
                    local v = oldIndex(t, k)
                    if v.Magnitude > 0 then return v.Unit * 16 end
                end
            end
            return oldIndex(t, k)
        end)
    end)
end
setupFakeSpeed()

RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if CFG.Speed then hum.WalkSpeed = CFG.SpeedVal end
end)

-- ==========================================
-- ESP 与 UI 构建
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
    local g = Instance.new("BillboardGui"); g.Name = "e_" .. math.random(10000, 99999); g.Size = UDim2.fromOffset(160, 50); g.AlwaysOnTop = true; g.Enabled = false; g.Parent = espGui
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
                data.gui.Enabled = true; data.gui.Adornee = hrp; data.dist.Text = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude) .. " studs"
                if CFG.ESPRole then data.name.Text = "[" .. getRoleLabel(plr) .. "] " .. plr.Name else data.name.Text = plr.Name end
                data.barBg.Visible = CFG.ESPHealth; data.hpText.Visible = CFG.ESPHealth
                if CFG.ESPHealth then
                    local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    data.bar.Size = UDim2.fromScale(hpRatio, 1); data.bar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 0); data.hpText.Text = math.floor(hpRatio * 100) .. "%"
                end
            else data.gui.Enabled = false end
        end
    end
end)

-- ==========================================
-- UI 按钮添加
-- ==========================================
addToggle("透视 玩家名字", "ESP")
addToggle("透视 血条比例", "ESPHealth")
addToggle("透视 中文职业", "ESPRole")

local lbl1 = Instance.new("TextLabel"); lbl1.Size = UDim2.new(1, -6, 0, 22); lbl1.BackgroundTransparency = 1; lbl1.Text = "── 杀戮 (需手持武器) ──"
lbl1.TextColor3 = Color3.fromRGB(160, 160, 180); lbl1.Font = Enum.Font.GothamBold; lbl1.TextSize = 13; lbl1.TextXAlignment = Enum.TextXAlignment.Left; lbl1.Parent = scroll

addToggle("开启原地杀戮 (Aura)", "KillAura")

-- 范围调整
local rangeBtn
rangeBtn = addButton("攻击范围: " .. CFG.KillRange .. " 米", function()
    CFG.KillRange = CFG.KillRange + 10
    if CFG.KillRange > 150 then CFG.KillRange = 10 end
    rangeBtn.Text = "攻击范围: " .. CFG.KillRange .. " 米"
end, Color3.fromRGB(80, 80, 120))

-- 伤害倍数调整
local dmgBtn
dmgBtn = addButton("伤害倍数: " .. CFG.DamageMult .. "x", function()
    CFG.DamageMult = CFG.DamageMult + 1
    if CFG.DamageMult > 10 then CFG.DamageMult = 1 end
    dmgBtn.Text = "伤害倍数: " .. CFG.DamageMult .. "x"
end, Color3.fromRGB(120, 80, 80))

local lbl2 = Instance.new("TextLabel"); lbl2.Size = UDim2.new(1, -6, 0, 22); lbl2.BackgroundTransparency = 1; lbl2.Text = "── 速度突破 ──"
lbl2.TextColor3 = Color3.fromRGB(160, 160, 180); lbl2.Font = Enum.Font.GothamBold; lbl2.TextSize = 13; lbl2.TextXAlignment = Enum.TextXAlignment.Left; lbl2.Parent = scroll

addToggle("强制奔跑 (速度 18)", "Speed")
addToggle("开启速度欺骗 (免耗耐力)", "FakeSpeed")

print("[Ninja Panel v34] 杀戮版已加载")