-- ============================================
-- Ninja Panel v6 (全中文 & 状态读取版)
-- 已根据扫描结果适配圣奥里团队职业
-- ============================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local LP                = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

local CFG = {
    ESP = false,
    ESPHealth = false,
    ESPRole = false,
    Speed = false, SpeedVal = 20,
    Jump = false, JumpVal = 60,
    Noclip = false,
    Scale = 1.0,
}

local ROLE_MAP = {}

-- ---------- GUI 根 ----------
local old = LP:WaitForChild("PlayerGui"):FindFirstChild("NinjaPanel")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NinjaPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LP:WaitForChild("PlayerGui")

-- ---------- 主窗口 ----------
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 520)
main.Position = UDim2.fromScale(0.02, 0.2)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = main

-- ---------- 最小化图标 ----------
local icon = Instance.new("TextButton")
icon.Size = UDim2.fromOffset(46, 46)
icon.Position = UDim2.fromOffset(12, 240)
icon.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
icon.Text = "N"
icon.TextColor3 = Color3.new(1, 1, 1)
icon.Font = Enum.Font.GothamBold
icon.TextSize = 20
icon.Visible = false
icon.Active = true
icon.Draggable = true
icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
local iconStroke = Instance.new("UIStroke", icon)
iconStroke.Color = Color3.fromRGB(0, 180, 120)
iconStroke.Thickness = 2

icon.MouseButton1Click:Connect(function()
    main.Visible = true
    icon.Visible = false
end)

local function minimize()
    main.Visible = false
    icon.Visible = true
end

-- ---------- 标题栏 ----------
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0
title.Text = "Ninja 面板 v6"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

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
mkTitleBtn("▁", -32, minimize)

-- ---------- 内容滚动区 ----------
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -80)
scroll.Position = UDim2.fromOffset(6, 38)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

-- ---------- 底部状态栏 (显示自身饥饿/耐力) ----------
local statusBar = Instance.new("TextLabel")
statusBar.Size = UDim2.new(1, -12, 0, 36)
statusBar.Position = UDim2.new(0, 6, 1, -42)
statusBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statusBar.BorderSizePixel = 0
statusBar.Text = "正在读取状态..."
statusBar.TextColor3 = Color3.fromRGB(0, 255, 150)
statusBar.Font = Enum.Font.GothamBold
statusBar.TextSize = 12
statusBar.Parent = main
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 6)

-- ---------- 基础控件 ----------
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
    local b
    b = addButton((CFG[key] and "[开] " or "[关] ") .. name, function()
        CFG[key] = not CFG[key]
        b.Text = (CFG[key] and "[开] " or "[关] ") .. name
        b.BackgroundColor3 = CFG[key] and Color3.fromRGB(0, 140, 80) or Color3.fromRGB(50, 50, 60)
    end)
    if CFG[key] then b.BackgroundColor3 = Color3.fromRGB(0, 140, 80) end
    return b
end

local function addLabel(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -6, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(160, 160, 180)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = scroll
    return l
end

-- ---------- 角色读取 (圣奥里专属: Team) ----------
local function getRoleLabel(plr)
    if ROLE_MAP[plr.Name] then return ROLE_MAP[plr.Name] end
    -- 圣奥里职业直接绑在 Team 上
    if plr.Team and plr.Team.Name ~= "" and plr.Team.Name ~= "Neutral" then
        return plr.Team.Name
    end
    return nil
end

-- ---------- 状态读取 (饥饿/耐力) ----------
local function getStat(plr, keywords)
    local char = plr.Character
    -- 查 Character 属性
    if char then
        for k, v in pairs(char:GetAttributes()) do
            for _, kw in ipairs(keywords) do
                if k:lower():find(kw) then return v end
            end
        end
    end
    -- 查 Player 属性
    for k, v in pairs(plr:GetAttributes()) do
        for _, kw in ipairs(keywords) do
            if k:lower():find(kw) then return v end
        end
    end
    -- 查 Character 下的数值对象
    if char then
        for _, c in ipairs(char:GetDescendants()) do
            if c:IsA("NumberValue") or c:IsA("IntValue") then
                for _, kw in ipairs(keywords) do
                    if c.Name:lower():find(kw) then return c.Value end
                end
            end
        end
    end
    return nil
end

local function updateStats()
    local hunger = getStat(LP, {"hunger", "food", "饥饿"}) or "未知"
    local stamina = getStat(LP, {"stamina", "energy", "耐力", "体力"}) or "未知"

    if type(hunger) == "number" then hunger = math.floor(hunger) .. "%" end
    if type(stamina) == "number" then stamina = math.floor(stamina) .. "%" end

    statusBar.Text = "🍗 饥饿: " .. tostring(hunger) .. "  |  ⚡ 耐力: " .. tostring(stamina)
end

-- ---------- 深度扫描 ----------
local function scanRoles()
    local L = {}
    local function w(s) table.insert(L, tostring(s)) end

    w("===== 深度角色扫描 =====")
    w("--- Teams ---")
    local okT, Teams = pcall(function() return game:GetService("Teams") end)
    if okT and Teams then
        for _, t in ipairs(Teams:GetTeams()) do
            w("  [Team] " .. t.Name)
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            w("========== " .. p.Name .. " ==========")
            w("  Team = " .. tostring(p.Team and p.Team.Name))
            for k, v in pairs(p:GetAttributes()) do
                w("  [Attr] " .. k .. " = " .. tostring(v))
            end
            local char = p.Character
            if char then
                local function walk(node, depth, prefix)
                    if depth > 3 then return end
                    for _, c in ipairs(node:GetChildren()) do
                        local full = prefix .. c.Name
                        if c:IsA("StringValue") then
                            w("  " .. full .. " = " .. tostring(c.Value))
                        elseif c:IsA("IntValue") or c:IsA("NumberValue") then
                            w("  " .. full .. " = " .. tostring(c.Value))
                        end
                        walk(c, depth + 1, full .. ".")
                    end
                end
                walk(char, 1, "")
            end
        end
    end
    w("===== 扫描结束 =====")

    local oldWin = gui:FindFirstChild("ScanWindow")
    if oldWin then oldWin:Destroy() end

    local win = Instance.new("Frame")
    win.Name = "ScanWindow"
    win.Size = UDim2.fromOffset(340, 300)
    win.Position = UDim2.fromScale(0.5, 0.5)
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    win.Parent = gui
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)

    local wtitle = Instance.new("TextLabel")
    wtitle.Size = UDim2.new(1, 0, 0, 30)
    wtitle.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    wtitle.BorderSizePixel = 0
    wtitle.Text = "扫描结果"
    wtitle.TextColor3 = Color3.new(1, 1, 1)
    wtitle.Font = Enum.Font.GothamBold
    wtitle.Parent = win
    Instance.new("UICorner", wtitle).CornerRadius = UDim.new(0, 8)

    local wclose = Instance.new("TextButton")
    wclose.Size = UDim2.fromOffset(28, 28)
    wclose.Position = UDim2.new(1, -30, 0, 1)
    wclose.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    wclose.Text = "×"
    wclose.TextColor3 = Color3.new(1, 1, 1)
    wclose.Parent = win
    Instance.new("UICorner", wclose).CornerRadius = UDim.new(0, 6)
    wclose.MouseButton1Click:Connect(function() win:Destroy() end)

    local wscroll = Instance.new("ScrollingFrame")
    wscroll.Size = UDim2.new(1, -12, 1, -40)
    wscroll.Position = UDim2.fromOffset(6, 34)
    wscroll.BackgroundTransparency = 1
    wscroll.ScrollBarThickness = 4
    wscroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    wscroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    wscroll.Parent = win

    local wtext = Instance.new("TextLabel")
    wtext.Size = UDim2.new(1, -6, 0, 0)
    wtext.AutomaticSize = Enum.AutomaticSize.Y
    wtext.BackgroundTransparency = 1
    wtext.Text = table.concat(L, "\n")
    wtext.TextColor3 = Color3.fromRGB(220, 220, 230)
    wtext.Font = Enum.Font.Code
    wtext.TextSize = 11
    wtext.TextXAlignment = Enum.TextXAlignment.Left
    wtext.TextYAlignment = Enum.TextYAlignment.Top
    wtext.TextWrapped = true
    wtext.Parent = wscroll
end

-- ---------- 手动设置角色 ----------
local function openRoleInput()
    local oldIn = gui:FindFirstChild("RoleInput")
    if oldIn then oldIn:Destroy() end

    local box = Instance.new("Frame")
    box.Name = "RoleInput"
    box.Size = UDim2.fromOffset(280, 110)
    box.Position = UDim2.fromScale(0.5, 0.5)
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    box.BorderSizePixel = 0
    box.Active = true
    box.Draggable = true
    box.Parent = gui
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 24)
    lbl.Position = UDim2.fromOffset(10, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = "格式：玩家名=角色"
    lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = box

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 34)
    input.Position = UDim2.fromOffset(10, 32)
    input.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    input.BorderSizePixel = 0
    input.TextColor3 = Color3.new(1, 1, 1)
    input.PlaceholderText = "如 Bob=Police"
    input.Text = ""
    input.ClearTextOnFocus = false
    input.Parent = box
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

    local ok = Instance.new("TextButton")
    ok.Size = UDim2.fromOffset(120, 28)
    ok.Position = UDim2.new(0.5, -125, 1, -34)
    ok.BackgroundColor3 = Color3.fromRGB(0, 130, 80)
    ok.Text = "确认"
    ok.TextColor3 = Color3.new(1, 1, 1)
    ok.Parent = box
    Instance.new("UICorner", ok).CornerRadius = UDim.new(0, 6)

    local cancel = Instance.new("TextButton")
    cancel.Size = UDim2.fromOffset(120, 28)
    cancel.Position = UDim2.new(0.5, 5, 1, -34)
    cancel.BackgroundColor3 = Color3.fromRGB(90, 45, 45)
    cancel.Text = "取消"
    cancel.TextColor3 = Color3.new(1, 1, 1)
    cancel.Parent = box
    Instance.new("UICorner", cancel).CornerRadius = UDim.new(0, 6)

    ok.MouseButton1Click:Connect(function()
        local name, role = input.Text:match("^(.-)%s*=%s*(.*)$")
        if name and role and name ~= "" and role ~= "" then
            ROLE_MAP[name] = role
        end
        box:Destroy()
    end)
    cancel.MouseButton1Click:Connect(function() box:Destroy() end)
end

-- ---------- ESP ----------
local espCache = {}

local function buildESP(plr)
    if plr == LP then return end
    local g = Instance.new("BillboardGui")
    g.Name = "esp_" .. plr.Name
    g.Size = UDim2.fromOffset(160, 50)
    g.AlwaysOnTop = true
    g.Enabled = false
    g.Parent = LP:WaitForChild("PlayerGui")

    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1, 0, 0, 16)
    nm.BackgroundTransparency = 1
    nm.TextColor3 = Color3.new(1, 1, 1)
    nm.TextStrokeTransparency = 0
    nm.Font = Enum.Font.GothamBold
    nm.Text = plr.Name
    nm.Parent = g

    local ds = Instance.new("TextLabel")
    ds.Size = UDim2.new(1, 0, 0, 14)
    ds.Position = UDim2.fromOffset(0, 16)
    ds.BackgroundTransparency = 1
    ds.TextColor3 = Color3.fromRGB(200, 200, 200)
    ds.TextStrokeTransparency = 0
    ds.TextSize = 11
    ds.Parent = g

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, 0, 0, 4)
    barBg.Position = UDim2.fromOffset(0, 32)
    barBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    barBg.BorderSizePixel = 0
    barBg.Visible = false
    barBg.Parent = g

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromScale(1, 1)
    bar.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
    bar.BorderSizePixel = 0
    bar.Parent = barBg

    espCache[plr] = { gui = g, name = nm, dist = ds, bar = bar, barBg = barBg }
end

Players.PlayerAdded:Connect(function(p) task.wait(1) buildESP(p) end)
for _, p in ipairs(Players:GetPlayers()) do buildESP(p) end
Players.PlayerRemoving:Connect(function(p)
    if espCache[p] and espCache[p].gui then espCache[p].gui:Destroy() end
    espCache[p] = nil
end)

RunService.RenderStepped:Connect(function()
    if not CFG.ESP then
        for _, v in pairs(espCache) do
            if v.gui.Parent then v.gui.Enabled = false end
        end
        return
    end
    for plr, data in pairs(espCache) do
        if plr.Parent and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                data.gui.Enabled = true
                data.gui.Adornee = hrp
                data.dist.Text = string.format("%d studs", math.floor((hrp.Position - Camera.CFrame.Position).Magnitude))
                local role = CFG.ESPRole and getRoleLabel(plr) or nil
                data.name.Text = role and ("[" .. role .. "] " .. plr.Name) or plr.Name
                data.barBg.Visible = CFG.ESPHealth
                if CFG.ESPHealth then
                    data.bar.Size = UDim2.fromScale(math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1), 1)
                end
            else
                data.gui.Enabled = false
            end
        else
            data.gui.Enabled = false
        end
    end
end)

-- ---------- 主循环 (自身状态/加速/穿墙) ----------
RunService.Heartbeat:Connect(function()
    -- 状态读取
    updateStats()

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

-- ---------- UI 按钮构建 ----------
addLabel("── 透视功能 ──")
addToggle("透视 玩家名字", "ESP")
addToggle("透视 血条", "ESPHealth")
addToggle("透视 角色前缀", "ESPRole")

addLabel("── 角色工具 ──")
addButton("扫描角色属性", scanRoles, Color3.fromRGB(120, 80, 160))
addButton("手动设置身份", openRoleInput, Color3.fromRGB(80, 120, 80))
addButton("刷新角色", function()
    if LP.Character then LP.Character:BreakJoints() end
end)

addLabel("── 自身修改 ──")
addToggle("移动加速", "Speed")
addToggle("高跳", "Jump")
addToggle("穿墙 (Noclip)", "Noclip")

print("[Ninja Panel v6] 已加载")