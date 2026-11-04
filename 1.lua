-- ============================================
-- Ninja Panel v8 (隐身绘制 · 中文职业 · 状态抓取)
-- ============================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local LP                = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

if not Drawing then
    return game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "错误",
        Text = "你的执行器不支持 Drawing 库，无法隐身，请换用支持的执行器",
        Duration = 10
    })
end

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

-- 职业英文转中文映射
local CN_ROLE_MAP = {
    ["Chef"] = "厨师",
    ["Civilian"] = "平民",
    ["Delivery"] = "快递员",
    ["Farmer"] = "农夫",
    ["Fire"] = "消防员",
    ["Medical"] = "医生",
    ["Police"] = "警察",
    ["Prisoner"] = "囚犯",
    ["Road Service"] = "路政",
    ["Transit"] = "公交司机",
    ["Neutral"] = "无"
}

-- ---------- GUI 隐藏处理 ----------
local function getHiddenGui(name)
    local g = Instance.new("ScreenGui")
    g.Name = name
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    if syn and syn.protect_gui then
        syn.protect_gui(g)
        g.Parent = game:GetService("CoreGui")
    elseif gethui then
        g.Parent = gethui()
    else
        g.Parent = LP:WaitForChild("PlayerGui")
    end
    return g
end

local gui = getHiddenGui("NinjaPanel_" .. tostring(math.random(1000,9999)))

-- ---------- 主面板 UI ----------
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 420)
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

icon.MouseButton1Click:Connect(function()
    main.Visible = true
    icon.Visible = false
end)

local function minimize()
    main.Visible = false
    icon.Visible = true
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0
title.Text = "Ninja v8 (隐身·中文)"
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

-- ---------- Drawing ESP ----------
local espData = {}

local function createDrawingESP(plr)
    if plr == LP then return end
    local data = {
        name = Drawing.new("Text"),
        dist = Drawing.new("Text"),
        role = Drawing.new("Text"),
        barBg = Drawing.new("Line"),
        bar = Drawing.new("Line"),
        health = Drawing.new("Text"),
    }
    data.name.Size = 14
    data.name.Center = true
    data.name.Outline = true
    data.name.Color = Color3.new(1, 1, 1)

    data.dist.Size = 12
    data.dist.Center = true
    data.dist.Outline = true
    data.dist.Color = Color3.fromRGB(200, 200, 200)

    data.role.Size = 12
    data.role.Center = true
    data.role.Outline = true
    data.role.Color = Color3.fromRGB(255, 150, 150)

    data.barBg.Thickness = 4
    data.barBg.Color = Color3.fromRGB(50, 50, 50)
    
    data.bar.Thickness = 4
    data.bar.Color = Color3.fromRGB(0, 255, 100)

    data.health.Size = 11
    data.health.Outline = true
    data.health.Color = Color3.new(1, 1, 1)

    espData[plr] = data
end

local function removeDrawingESP(plr)
    if espData[plr] then
        for _, obj in pairs(espData[plr]) do
            obj:Remove()
        end
        espData[plr] = nil
    end
end

Players.PlayerAdded:Connect(function(p) task.wait(1) createDrawingESP(p) end)
for _, p in ipairs(Players:GetPlayers()) do createDrawingESP(p) end
Players.PlayerRemoving:Connect(function(p) removeDrawingESP(p) end)

-- ---------- 职业/状态读取 ----------
local function getRoleLabel(plr)
    if ROLE_MAP[plr.Name] then return ROLE_MAP[plr.Name] end
    if plr.Team and plr.Team.Name ~= "" and plr.Team.Name ~= "Neutral" then
        local tName = plr.Team.Name
        return CN_ROLE_MAP[tName] or tName
    end
    return nil
end

-- 加强版状态抓取：查属性、查数值对象、查 UI 文本
local function getStat(plr, keywords)
    local char = plr.Character
    local isLocal = (plr == LP)
    
    -- 1. 查 Character / Player 属性
    if char then
        for k, v in pairs(char:GetAttributes()) do
            for _, kw in ipairs(keywords) do
                if k:lower():find(kw) then return v end
            end
        end
    end
    for k, v in pairs(plr:GetAttributes()) do
        for _, kw in ipairs(keywords) do
            if k:lower():find(kw) then return v end
        end
    end

    -- 2. 查 Character 下数值
    if char then
        for _, c in ipairs(char:GetDescendants()) do
            if c:IsA("NumberValue") or c:IsA("IntValue") then
                for _, kw in ipairs(keywords) do
                    if c.Name:lower():find(kw) then return c.Value end
                end
            end
        end
    end
    
    -- 3. 如果是本地玩家，查 PlayerGui 里的 TextLabel (很多游戏状态写在这)
    if isLocal then
        local pg = LP:FindFirstChild("PlayerGui")
        if pg then
            for _, obj in ipairs(pg:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Text ~= "" then
                    local text = obj.Text:lower()
                    for _, kw in ipairs(keywords) do
                        if obj.Name:lower():find(kw) or text:find(kw) then
                            -- 提取文本里的数字，比如 "Hunger: 85%"
                            local num = text:match("(%d+)")
                            if num then return tonumber(num) end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function updateStats()
    -- 抓取关键字扩充：饥饿、食物、耐力、体力、精力
    local hunger = getStat(LP, {"hunger", "food", "饥饿", "饱食"}) or "未知"
    local stamina = getStat(LP, {"stamina", "energy", "耐力", "体力", "精力"}) or "未知"
    
    if type(hunger) == "number" then 
        hunger = (hunger <= 1 and hunger > 0) and math.floor(hunger*100).."%" or math.floor(hunger).."%" 
    end
    if type(stamina) == "number" then 
        stamina = (stamina <= 1 and stamina > 0) and math.floor(stamina*100).."%" or math.floor(stamina).."%"
    end
    
    statusBar.Text = "🍗 饥饿: " .. tostring(hunger) .. "  |  ⚡ 耐力: " .. tostring(stamina)
end

-- 深度扫描自身状态按钮逻辑
local function deepScanSelf()
    local L = {}
    local function w(s) table.insert(L, tostring(s)) end
    w("===== 自身状态扫描 =====")
    local char = LP.Character
    if char then
        w("--- Character 内的值和文本 ---")
        for _, c in ipairs(char:GetDescendants()) do
            if c:IsA("NumberValue") or c:IsA("IntValue") or c:IsA("StringValue") then
                w("  " .. c.Name .. " = " .. tostring(c.Value))
            end
        end
    end
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        w("--- PlayerGui 内的文本 ---")
        for _, c in ipairs(pg:GetDescendants()) do
            if c:IsA("TextLabel") and c.Text ~= "" then
                -- 只打印带数字的，过滤无用信息
                if c.Text:match("%d") then
                    w("  [" .. c.Name .. "] = " .. tostring(c.Text))
                end
            end
        end
    end
    w("===== 扫描结束 =====")
    
    -- 在屏幕上弹窗显示
    local oldWin = gui:FindFirstChild("ScanStatWin")
    if oldWin then oldWin:Destroy() end

    local win = Instance.new("Frame")
    win.Name = "ScanStatWin"
    win.Size = UDim2.fromOffset(320, 300)
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
    wtitle.Text = "状态扫描结果"
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

-- ---------- 渲染循环 ----------
RunService.RenderStepped:Connect(function()
    updateStats()
    local myChar = LP.Character
    if not myChar then return end

    for plr, data in pairs(espData) do
        local char = plr.Character
        if not CFG.ESP or not char then
            data.name.Visible = false; data.dist.Visible = false; data.role.Visible = false
            data.barBg.Visible = false; data.bar.Visible = false; data.health.Visible = false
        else
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                if onScreen then
                    local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                    data.name.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                    data.dist.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                    
                    local role = CFG.ESPRole and getRoleLabel(plr)
                    if role then
                        data.role.Visible = true
                        data.role.Text = "[" .. role .. "]"
                        data.role.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
                    else
                        data.role.Visible = false
                    end

                    data.name.Text = plr.Name
                    data.dist.Text = tostring(dist) .. " studs"

                    if CFG.ESPHealth then
                        local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        local barWidth = 50
                        local barX = screenPos.X - barWidth / 2
                        local barY = screenPos.Y - 5
                        
                        data.barBg.Visible = true
                        data.barBg.From = Vector2.new(barX, barY)
                        data.barBg.To = Vector2.new(barX + barWidth, barY)

                        data.bar.Visible = true
                        data.bar.From = Vector2.new(barX, barY)
                        data.bar.To = Vector2.new(barX + (barWidth * hpRatio), barY)
                        data.bar.Color = Color3.fromHSV(hpRatio * 0.33, 0.8, 0.9)

                        data.health.Visible = true
                        data.health.Text = math.floor(hum.Health) .. " HP"
                        data.health.Position = Vector2.new(barX + barWidth + 5, barY - 6)
                    else
                        data.barBg.Visible = false; data.bar.Visible = false; data.health.Visible = false
                    end
                    data.name.Visible = true; data.dist.Visible = true
                else
                    data.name.Visible = false; data.dist.Visible = false; data.role.Visible = false
                    data.barBg.Visible = false; data.bar.Visible = false; data.health.Visible = false
                end
            else
                data.name.Visible = false; data.dist.Visible = false; data.role.Visible = false
                data.barBg.Visible = false; data.bar.Visible = false; data.health.Visible = false
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
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
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

print("[Ninja Panel v8] 隐身绘制·中文职业版已加载")