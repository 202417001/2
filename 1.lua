-- ============================================
-- Ninja Panel v2
-- 新增：面板缩放、反作弊友好传送
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP         = Players.LocalPlayer
local Camera     = workspace.CurrentCamera

local CFG = {
    ESP = false, ESPHealth = true,
    Speed = false, SpeedVal = 60,
    Jump = false, JumpVal = 120,
    Noclip = false,
    Scale = 1.0,
    TeleMode = "fast",   -- fast / slow
}

-- ---------- GUI ----------
local old = LP:WaitForChild("PlayerGui"):FindFirstChild("NinjaPanel")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NinjaPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 480)
main.Position = UDim2.fromScale(0.02, 0.2)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- 关键：UIScale 挂在 main 上，缩放整个面板
local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0
title.Text = "Ninja Panel v2"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- 缩放按钮（标题栏右侧）
local function mkTitleBtn(text, xoff, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(28, 28)
    b.Position = UDim2.new(1, xoff, 0, 2)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Parent = main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function applyScale(v)
    CFG.Scale = math.clamp(v, 0.6, 1.8)
    uiScale.Scale = CFG.Scale
end

mkTitleBtn("−", -94, function() applyScale(CFG.Scale - 0.1) end)
mkTitleBtn("+", -64, function() applyScale(CFG.Scale + 0.1) end)
mkTitleBtn("×", -32, function() gui.Enabled = false end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -44)
scroll.Position = UDim2.fromOffset(6, 38)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 700)
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function addButton(text, cb, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -6, 0, 34)
    b.BackgroundColor3 = color or Color3.fromRGB(50, 50, 60)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function addToggle(name, key)
    local b = addButton((CFG[key] and "[ON] " or "[OFF] ") .. name, function()
        CFG[key] = not CFG[key]
        b.Text = (CFG[key] and "[ON] " or "[OFF] ") .. name
        b.BackgroundColor3 = CFG[key] and Color3.fromRGB(0, 140, 80) or Color3.fromRGB(50, 50, 60)
    end)
    if CFG[key] then b.BackgroundColor3 = Color3.fromRGB(0, 140, 80) end
    return b
end

-- ---------- 反作弊友好传送 ----------
-- 思路：把大位移拆成多帧小步，每帧位移压在阈值内
-- fast: 每帧约 12 studs，60fps 下 ~720 studs/s（能过部分检测）
-- slow: 每帧约 3 studs，60fps 下 ~180 studs/s（接近正常跑步，几乎不触发）

local function getHRP()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function smoothTeleport(targetCFrame)
    local hrp = getHRP()
    if not hrp then return end

    local startPos = hrp.Position
    local targetPos = targetCFrame.Position
    local dist = (targetPos - startPos).Magnitude
    if dist < 1 then return end

    local stepSize = (CFG.TeleMode == "slow") and 3 or 12
    local steps = math.max(1, math.ceil(dist / stepSize))

    for i = 1, steps do
        local cur = getHRP()
        if not cur then return end
        local t = i / steps
        local pos = startPos:Lerp(targetPos, t)
        -- 保留目标朝向，位置插值
        cur.CFrame = CFrame.new(pos, targetPos + (targetCFrame.LookVector * 5))
        RunService.Heartbeat:Wait()
    end
end

-- 传送到最近玩家
local function tpToNearestPlayer()
    local myHRP = getHRP()
    if not myHRP then return end
    local closest, cd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then
                local d = (h.Position - myHRP.Position).Magnitude
                if d < cd then cd, closest = d, h end
            end
        end
    end
    if closest then
        smoothTeleport(closest.CFrame * CFrame.new(0, 3, 0))
    end
end

-- 传送到指定玩家
local function tpToPlayer(plr)
    if not plr or plr == LP then return end
    local char = plr.Character
    if not char then return end
    local h = char:FindFirstChild("HumanoidRootPart")
    if not h then return end
    smoothTeleport(h.CFrame * CFrame.new(0, 3, 0))
end

-- ---------- 功能按钮 ----------
addToggle("ESP 玩家名字", "ESP")
addToggle("ESP 血条", "ESPHealth")

addButton("传送：最近玩家", function() tpToNearestPlayer() end, Color3.fromRGB(0, 120, 80))

local modeBtn
modeBtn = addButton("传送模式：快速", function()
    CFG.TeleMode = (CFG.TeleMode == "fast") and "slow" or "fast"
    modeBtn.Text = "传送模式：" .. (CFG.TeleMode == "fast" and "快速" or "隐蔽")
end, Color3.fromRGB(80, 80, 120))

addButton("刷新角色", function()
    if LP.Character then LP.Character:BreakJoints() end
end)

addToggle("加速", "Speed")
addToggle("高跳", "Jump")
addToggle("穿墙 Noclip", "Noclip")

-- ---------- ESP ----------
local espCache = {}
local function buildESP(plr)
    if plr == LP then return end
    local g = Instance.new("BillboardGui")
    g.Name = "esp_" .. plr.Name
    g.Size = UDim2.fromOffset(100, 50)
    g.AlwaysOnTop = true
    g.Parent = LP:WaitForChild("PlayerGui")

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 16)
    name.BackgroundTransparency = 1
    name.TextColor3 = Color3.new(1, 1, 1)
    name.TextStrokeTransparency = 0
    name.TextSize = 12
    name.Font = Enum.Font.GothamBold
    name.Text = plr.Name
    name.Parent = g

    local dist = Instance.new("TextLabel")
    dist.Size = UDim2.new(1, 0, 0, 14)
    dist.Position = UDim2.fromOffset(0, 16)
    dist.BackgroundTransparency = 1
    dist.TextColor3 = Color3.fromRGB(200, 200, 200)
    dist.TextStrokeTransparency = 0
    dist.TextSize = 11
    dist.Parent = g

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, 0, 0, 4)
    barBg.Position = UDim2.fromOffset(0, 32)
    barBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    barBg.BorderSizePixel = 0
    barBg.Parent = g

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromScale(1, 1)
    bar.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
    bar.BorderSizePixel = 0
    bar.Parent = barBg

    espCache[plr] = { gui = g, name = name, dist = dist, bar = bar }
end

Players.PlayerAdded:Connect(function(p) task.wait(1) buildESP(p) end)
for _, p in ipairs(Players:GetPlayers()) do buildESP(p) end
Players.PlayerRemoving:Connect(function(p)
    if espCache[p] and espCache[p].gui then espCache[p].gui:Destroy() end
    espCache[p] = nil
end)

RunService.RenderStepped:Connect(function()
    for plr, data in pairs(espCache) do
        if not CFG.ESP or not plr.Character then
            data.gui.Enabled = false
        else
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                data.gui.Enabled = true
                data.gui.Adornee = hrp
                data.dist.Text = string.format("%d studs", (hrp.Position - Camera.CFrame.Position).Magnitude)
                if CFG.ESPHealth then
                    data.bar.Parent.Visible = true
                    data.bar.Size = UDim2.fromScale(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 1)
                else
                    data.bar.Parent.Visible = false
                end
            else
                data.gui.Enabled = false
            end
        end
    end
end)

-- ---------- 状态循环 ----------
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if CFG.Speed then hum.WalkSpeed = CFG.SpeedVal end
    if CFG.Jump  then hum.JumpPower = CFG.JumpVal end

    if CFG.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ---------- 玩家列表 ----------
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -6, 0, 20)
listLabel.BackgroundTransparency = 1
listLabel.Text = "玩家列表（点击传送）"
listLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
listLabel.Font = Enum.Font.GothamBold
listLabel.TextSize = 13
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = scroll

local function refreshList()
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("TextButton") and c:GetAttribute("isPlayer") then c:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local b = addButton(p.Name, function() tpToPlayer(p) end, Color3.fromRGB(45, 55, 80))
            b:SetAttribute("isPlayer", true)
        end
    end
end
refreshList()
Players.PlayerAdded:Connect(function() task.wait(1) refreshList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) refreshList() end)

print("[Ninja Panel v2] loaded")