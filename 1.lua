-- ============================================
-- Ninja 执行器通用面板
-- 纯 Instance GUI，不依赖第三方库
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local LP         = Players.LocalPlayer
local Camera     = workspace.CurrentCamera

-- ---------- 状态 ----------
local CFG = {
    ESP       = false,
    ESPBox    = false,
    ESPHealth = true,
    Speed     = false,
    SpeedVal  = 60,
    Jump      = false,
    JumpVal   = 120,
    Noclip    = false,
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
main.Size = UDim2.fromOffset(320, 420)
main.Position = UDim2.fromScale(0.02, 0.2)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0
title.Text = "Ninja Panel"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.new(1, -32, 0, 0)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 22
close.Parent = main
close.MouseButton1Click:Connect(function()
    gui.Enabled = not gui.Enabled
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -44)
scroll.Position = UDim2.fromOffset(6, 38)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
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

-- ---------- ESP ----------
local espCache = {}

local function clearESP()
    for _, v in pairs(espCache) do
        if v.gui and v.gui.Parent then v.gui:Destroy() end
    end
    espCache = {}
end

local function buildESP(plr)
    if plr == LP then return end
    local gui2 = Instance.new("BillboardGui")
    gui2.Name = "esp_" .. plr.Name
    gui2.Size = UDim2.fromOffset(100, 50)
    gui2.AlwaysOnTop = true
    gui2.Adornee = nil
    gui2.Parent = LP:WaitForChild("PlayerGui")

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 16)
    name.BackgroundTransparency = 1
    name.TextColor3 = Color3.new(1, 1, 1)
    name.TextStrokeTransparency = 0
    name.TextSize = 12
    name.Font = Enum.Font.GothamBold
    name.Text = plr.Name
    name.Parent = gui2

    local dist = Instance.new("TextLabel")
    dist.Size = UDim2.new(1, 0, 0, 14)
    dist.Position = UDim2.fromOffset(0, 16)
    dist.BackgroundTransparency = 1
    dist.TextColor3 = Color3.fromRGB(200, 200, 200)
    dist.TextStrokeTransparency = 0
    dist.TextSize = 11
    dist.Parent = gui2

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, 0, 0, 4)
    barBg.Position = UDim2.fromOffset(0, 32)
    barBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    barBg.BorderSizePixel = 0
    barBg.Parent = gui2

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromScale(1, 1)
    bar.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
    bar.BorderSizePixel = 0
    bar.Parent = barBg

    espCache[plr] = { gui = gui2, name = name, dist = dist, bar = bar, barBg = barBg }
end

Players.PlayerAdded:Connect(function(p) task.wait(1) buildESP(p) end)
for _, p in ipairs(Players:GetPlayers()) do buildESP(p) end
Players.PlayerRemoving:Connect(function(p)
    if espCache[p] and espCache[p].gui then espCache[p].gui:Destroy() end
    espCache[p] = nil
end)

RunService.RenderStepped:Connect(function()
    if not CFG.ESP then
        for _, v in pairs(espCache) do if v.gui.Parent then v.gui.Enabled = false end end
        return
    end
    for plr, data in pairs(espCache) do
        if not plr.Parent or not plr.Character then
            data.gui.Enabled = false
        else
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                data.gui.Enabled = true
                data.gui.Adornee = hrp
                data.dist.Text = string.format("%d studs", (hrp.Position - Camera.CFrame.Position).Magnitude)
                data.bar.Size = UDim2.fromScale(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 1)
                data.bar.BackgroundColor3 = Color3.fromHSV(math.clamp(hum.Health / hum.MaxHealth, 0, 1) * 0.33, 0.8, 0.9)
            else
                data.gui.Enabled = false
            end
        end
    end
end)

-- ---------- 功能 ----------
addToggle("ESP 玩家名字", "ESP")
addToggle("ESP 血条", "ESPHealth")

addButton("传送到最近玩家", function()
    local closest, cd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LP.Character then
            local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
            local h = p.Character.HumanoidRootPart
            if myHRP then
                local d = (h.Position - myHRP.Position).Magnitude
                if d < cd then cd, closest = d, h end
            end
        end
    end
    if closest and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = closest.CFrame * CFrame.new(0, 3, 0)
    end
end)

addButton("刷新角色", function()
    if LP.Character then
        LP.Character:BreakJoints()
    end
end)

addToggle("加速", "Speed")
addToggle("高跳", "Jump")
addToggle("穿墙 Noclip", "Noclip")

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
listLabel.Text = "玩家列表"
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
            local b = addButton(p.Name, function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                end
            end, Color3.fromRGB(45, 55, 80))
            b:SetAttribute("isPlayer", true)
        end
    end
end
refreshList()
Players.PlayerAdded:Connect(function() task.wait(1) refreshList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) refreshList() end)

-- 收尾
task.wait(0.2)
print("[Ninja Panel] loaded")