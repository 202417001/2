-- ============================================
-- Ninja Panel v11 (中文修复 · 核心级隐身 · 深度扫描恢复)
-- ============================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local LP                = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

local CFG = {
    ESP = false, ESPHealth = false, ESPRole = false,
    Speed = false, SpeedVal = 20, Jump = false, JumpVal = 60,
    Noclip = false, Scale = 1.0,
}

-- 职业中英文映射
local CN_ROLE_MAP = {
    ["Chef"] = "厨师", ["Civilian"] = "平民", ["Delivery"] = "快递员",
    ["Farmer"] = "农夫", ["Fire"] = "消防员", ["Medical"] = "医生",
    ["Police"] = "警察", ["Prisoner"] = "囚犯", ["Road Service"] = "路政",
    ["Transit"] = "公交司机"
}

-- ---------- 核心级 GUI 隐藏处理 (防封) ----------
local function getHiddenGui(name)
    local g = Instance.new("ScreenGui")
    g.Name = name
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    -- 优先塞进 CoreGui 并保护
    if syn and syn.protect_gui then
        syn.protect_gui(g)
        g.Parent = game:GetService("CoreGui")
    elseif gethui then
        g.Parent = gethui()
    else
        g.Parent = LP:WaitForChild("PlayerGui") -- 兜底
    end
    return g
end

local mainGui = getHiddenGui("MainPanel_" .. math.random(1000, 9999))
local espGui = getHiddenGui("EspRender_" .. math.random(1000, 9999))

-- ---------- 主面板 UI ----------
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 420)
main.Position = UDim2.fromScale(0.02, 0.2)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0; main.Active = true; main.Draggable = true; main.Parent = mainGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local uiScale = Instance.new("UIScale"); uiScale.Scale = 1; uiScale.Parent = main

local icon = Instance.new("TextButton")
icon.Size = UDim2.fromOffset(46, 46); icon.Position = UDim2.fromOffset(12, 240)
icon.BackgroundColor3 = Color3.fromRGB(40, 40, 52); icon.Text = "N"
icon.TextColor3 = Color3.new(1, 1, 1); icon.Font = Enum.Font.GothamBold; icon.TextSize = 20
icon.Visible = false; icon.Active = true; icon.Draggable = true; icon.Parent = mainGui
Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)

local function minimize() main.Visible = false; icon.Visible = true end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32); title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0; title.Text = "Ninja v11"; title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold; title.TextSize = 16; title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local function mkTitleBtn(text, xoff, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(28, 28); b.Position = UDim2.new(1, xoff, 0, 2)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 75); b.BorderSizePixel = 0
    b.Text = text; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamBold; b.TextSize = 14
    b.Parent = main; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb); return b
end

mkTitleBtn("−", -94, function() uiScale.Scale = math.max(0.6, uiScale.Scale - 0.1) end)
mkTitleBtn("+", -64, function() uiScale.Scale = math.min(1.8, uiScale.Scale + 0.1) end)
mkTitleBtn("▁", -32, minimize)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -80); scroll.Position = UDim2.fromOffset(6, 38)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = scroll

local statusBar = Instance.new("TextLabel")
statusBar.Size = UDim2.new(1, -12, 0, 36); statusBar.Position = UDim2.new(0, 6, 1, -42)
statusBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40); statusBar.BorderSizePixel = 0
statusBar.Text = "状态抓取中..."; statusBar.TextColor3 = Color3.fromRGB(0, 255, 150)
statusBar.Font = Enum.Font.GothamBold; statusBar.TextSize = 12; statusBar.Parent = main
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 6)

local function addButton(text, cb, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -6, 0, 34); b.BackgroundColor3 = color or Color3.fromRGB(50, 50, 60)
    b.BorderSizePixel = 0; b.Text = text; b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham; b.TextSize = 14; b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb); return b
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
    l.Size = UDim2.new(1, -6, 0, 22); l.BackgroundTransparency = 1; l.Text = text
    l.TextColor3 = Color3.fromRGB(160, 160, 180); l.Font = Enum.Font.GothamBold
    l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = scroll
    return l
end

-- ---------- 身份读取 ----------
local function getRoleLabel(plr)
    if plr.Team then
        local tName = plr.Team.Name
        if tName and tName ~= "" and tName ~= "Neutral" and tName ~= "???" then
            return CN_ROLE_MAP[tName] or tName
        end
    end
    return "平民"
end

-- ---------- 状态抓取 (肉/鞋) ----------
local function getStatUI(keywords)
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return nil end
    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible and obj.Text ~= "" then
            local text = obj.Text:lower()
            for _, kw in ipairs(keywords) do
                if obj.Name:lower():find(kw) or text:find(kw) then
                    local num = text:match("(%d+)")
                    if num then return tonumber(num) end
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    while task.wait(1) do
        -- 肉/饥饿
        local hunger = getStatUI({"hunger", "food", "饥饿", "饱食", "肉"}) or "未知"
        -- 鞋/耐力
        local stamina = getStatUI({"stamina", "energy", "耐力", "体力", "精力", "鞋"}) or "未知"
        
        local function format(v)
            if type(v) == "number" then
                if v > 0 and v <= 1 then return math.floor(v * 100) .. "%"
                else return math.floor(v) .. "%" end
            end
            return tostring(v)
        end
        statusBar.Text = "🍗 饥饿: " .. format(hunger) .. "  |  ⚡ 耐力: " .. format(stamina)
    end
end)

-- ---------- 深度扫描 ----------
local function deepScanSelf()
    local L = {}
    local function w(s) table.insert(L, tostring(s)) end
    w("===== 自身状态深度扫描 =====")
    local char = LP.Character
    if char then
        w("--- Character 内的值 ---")
        for _, c in ipairs(char:GetDescendants()) do
            if c:IsA("NumberValue") or c:IsA("IntValue") or c:IsA("StringValue") then
                w("  " .. c.Name .. " = " .. tostring(c.Value))
            end
        end
    end
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        w("--- PlayerGui 界面上的数字 ---")
        for _, c in ipairs(pg:GetDescendants()) do
            if c:IsA("TextLabel") and c.Text ~= "" then
                if c.Text:match("%d") then w("  [" .. c.Name .. "] = " .. tostring(c.Text)) end
            end
        end
    end
    w("===== 扫描结束 =====")
    
    local oldWin = mainGui:FindFirstChild("ScanStatWin")
    if oldWin then oldWin:Destroy() end

    local win = Instance.new("Frame")
    win.Name = "ScanStatWin"
    win.Size = UDim2.fromOffset(320, 300)
    win.Position = UDim2.fromScale(0.5, 0.5); win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.BackgroundColor3 = Color3.fromRGB(15, 15, 20); win.BorderSizePixel = 0
    win.Active = true; win.Draggable = true; win.Parent = mainGui
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)

    local wtitle = Instance.new("TextLabel")
    wtitle.Size = UDim2.new(1, 0, 0, 30); wtitle.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    wtitle.BorderSizePixel = 0; wtitle.Text = "深度扫描结果"; wtitle.TextColor3 = Color3.new(1, 1, 1)
    wtitle.Font = Enum.Font.GothamBold; wtitle.Parent = win
    Instance.new("UICorner", wtitle).CornerRadius = UDim.new(0, 8)

    local wclose = Instance.new("TextButton")
    wclose.Size = UDim2.fromOffset(28, 28); wclose.Position = UDim2.new(1, -30, 0, 1)
    wclose.BackgroundColor3 = Color3.fromRGB(120, 40, 40); wclose.Text = "×"
    wclose.TextColor3 = Color3.new(1, 1, 1); wclose.Parent = win
    Instance.new("UICorner", wclose).CornerRadius = UDim.new(0, 6)
    wclose.MouseButton1Click:Connect(function() win:Destroy() end)

    local wscroll = Instance.new("ScrollingFrame")
    wscroll.Size = UDim2.new(1, -12, 1, -40); wscroll.Position = UDim2.fromOffset(6, 34)
    wscroll.BackgroundTransparency = 1; wscroll.ScrollBarThickness = 4
    wscroll.CanvasSize = UDim2.new(0, 0, 0, 0); wscroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    wscroll.Parent = win

    local wtext = Instance.new("TextLabel")
    wtext.Size = UDim2.new(1, -6, 0, 0); wtext.AutomaticSize = Enum.AutomaticSize.Y
    wtext.BackgroundTransparency = 1; wtext.Text = table.concat(L, "\n")
    wtext.TextColor3 = Color3.fromRGB(220, 220, 230); wtext.Font = Enum.Font.Code; wtext.TextSize = 11
    wtext.TextXAlignment = Enum.TextXAlignment.Left; wtext.TextYAlignment = Enum.TextYAlignment.Top
    wtext.TextWrapped = true; wtext.Parent = wscroll
end

-- ---------- 原生 BillboardGui ESP (塞进 CoreGui 防封) ----------
local espData = {}

local function buildESP(plr)
    if plr == LP then return end
    if espData[plr] then return end

    local g = Instance.new("BillboardGui")
    g.Name = "e_" .. math.random(1000, 9999)
    g.Size = UDim2.fromOffset(160, 50)
    g.AlwaysOnTop = true
    g.Enabled = false
    g.Parent = espGui -- 挂在核心 GUI 里

    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1, 0, 0, 16)
    nm.BackgroundTransparency = 1
    nm.TextColor3 = Color3.new(1, 1, 1)
    nm.TextStrokeTransparency = 0
    nm.Font = Enum.Font.GothamBold
    nm.TextSize = 12
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

    espData[plr] = { gui = g, name = nm, dist = ds, bar = bar, barBg = barBg }
end

Players.PlayerAdded:Connect(function(p) task.wait(1) buildESP(p) end)
for _, p in ipairs(Players:GetPlayers()) do buildESP(p) end
Players.PlayerRemoving:Connect(function(p)
    if espData[p] and espData[p].gui then espData[p].gui:Destroy() end
    espData[p] = nil
end)

-- ---------- 渲染循环 (降频) ----------
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    if frameCount % 2 ~= 0 then return end -- 每2帧刷新

    for plr, data in pairs(espData) do
        if not CFG.ESP or not plr.Character then
            data.gui.Enabled = false
        else
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                data.gui.Enabled = true
                data.gui.Adornee = hrp
                data.dist.Text = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude) .. " studs"
                
                if CFG.ESPRole then
                    local role = getRoleLabel(plr)
                    data.name.Text = "[" .. role .. "] " .. plr.Name
                else
                    data.name.Text = plr.Name
                end

                data.barBg.Visible = CFG.ESPHealth
                if CFG.ESPHealth then
                    local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    data.bar.Size = UDim2.fromScale(hpRatio, 1)
                    data.bar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 0)
                end
            else
                data.gui.Enabled = false
            end
        end
    end
end)

-- ---------- 主循环 ----------
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if CFG.Speed then hum.WalkSpeed = CFG.SpeedVal end
    if CFG.Jump  then hum.JumpPower = CFG.JumpVal end
    if CFG.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

-- ---------- 按钮构建 ----------
addLabel("── 透视功能 ──")
addToggle("透视 玩家名字", "ESP")
addToggle("透视 血条", "ESPHealth")
addToggle("透视 中文职业", "ESPRole")

addLabel("── 自身状态 ──")
addButton("深度扫描自身状态", deepScanSelf, Color3.fromRGB(120, 80, 160))

addLabel("── 自身修改 ──")
addToggle("移动加速", "Speed")
addToggle("高跳", "Jump")
addToggle("穿墙 (Noclip)", "Noclip")

print("[Ninja Panel v11] 已加载，中文职业修复版")