-- ============================================
-- Ninja Panel v10 (绝对流畅 · 问号修复 · 状态后台抓取)
-- ============================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local LP                = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

if not Drawing then
    return game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "错误", Text = "执行器不支持 Drawing", Duration = 5
    })
end

local CFG = {
    ESP = false, ESPHealth = false, ESPRole = false,
    Speed = false, SpeedVal = 20, Jump = false, JumpVal = 60,
    Noclip = false, Scale = 1.0,
}

local ROLE_MAP = {}
local CN_ROLE_MAP = {
    ["Chef"] = "厨师", ["Civilian"] = "平民", ["Delivery"] = "快递员",
    ["Farmer"] = "农夫", ["Fire"] = "消防员", ["Medical"] = "医生",
    ["Police"] = "警察", ["Prisoner"] = "囚犯", ["Road Service"] = "路政",
    ["Transit"] = "公交司机"
}

-- 猜测的 CharacterId 对应职业 (根据你的扫描图推测，如果是错的你告诉我)
local CID_MAP = {
    [1] = "平民", [2] = "警察", [3] = "医生", [4] = "消防员", 
    [5] = "农夫", [6] = "厨师", [7] = "囚犯"
}

-- ---------- GUI 隐藏处理 ----------
local function getHiddenGui(name)
    local g = Instance.new("ScreenGui")
    g.Name = name; g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    if syn and syn.protect_gui then syn.protect_gui(g); g.Parent = game:GetService("CoreGui")
    elseif gethui then g.Parent = gethui()
    else g.Parent = LP:WaitForChild("PlayerGui") end
    return g
end

local gui = getHiddenGui("NinjaPanel_v10")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 420)
main.Position = UDim2.fromScale(0.02, 0.2)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0; main.Active = true; main.Draggable = true; main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local uiScale = Instance.new("UIScale"); uiScale.Scale = 1; uiScale.Parent = main

local icon = Instance.new("TextButton")
icon.Size = UDim2.fromOffset(46, 46); icon.Position = UDim2.fromOffset(12, 240)
icon.BackgroundColor3 = Color3.fromRGB(40, 40, 52); icon.Text = "N"
icon.TextColor3 = Color3.new(1, 1, 1); icon.Font = Enum.Font.GothamBold; icon.TextSize = 20
icon.Visible = false; icon.Active = true; icon.Draggable = true; icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)

local function minimize() main.Visible = false; icon.Visible = true end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32); title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0; title.Text = "Ninja v10 (流畅版)"; title.TextColor3 = Color3.new(1, 1, 1)
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

-- ---------- 身份读取 (彻底删掉问号) ----------
local function getRoleLabel(plr)
    if ROLE_MAP[plr.Name] then return ROLE_MAP[plr.Name] end
    
    -- 1. 读 Team (第一优先)
    if plr.Team then
        local tName = plr.Team.Name
        if tName and tName ~= "" and tName ~= "Neutral" and not tName:find("?") then
            return CN_ROLE_MAP[tName] or tName
        end
    end
    
    -- 2. 读 CharacterId (第二优先)
    local cid = plr:GetAttribute("CharacterId")
    if cid then return CID_MAP[cid] or ("ID:" .. tostring(cid)) end
    
    -- 3. 都没就显示平民
    return "平民"
end

-- ---------- 状态抓取 (绝不卡顿) ----------
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

local function getAttributeStat(plr, keywords)
    local char = plr.Character
    if char then
        for k, v in pairs(char:GetAttributes()) do
            for _, kw in ipairs(keywords) do if k:lower():find(kw) then return v end end
        end
    end
    for k, v in pairs(plr:GetAttributes()) do
        for _, kw in ipairs(keywords) do if k:lower():find(kw) then return v end end
    end
    return nil
end

-- 放到后台协程，每秒查一次，不占渲染资源
task.spawn(function()
    while task.wait(1) do
        local hunger = getAttributeStat(LP, {"hunger", "food", "饥饿", "饱食"}) or getStatUI({"hunger", "food", "饥饿", "饱食", "肉"}) or "未知"
        local stamina = getAttributeStat(LP, {"stamina", "energy", "耐力", "体力", "精力"}) or getStatUI({"stamina", "energy", "耐力", "体力", "精力", "鞋"}) or "未知"
        
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

-- ---------- Drawing ESP ----------
local espData = {}
local function createDrawingESP(plr)
    if plr == LP then return end
    espData[plr] = {
        name = Drawing.new("Text"), dist = Drawing.new("Text"), role = Drawing.new("Text"),
        barBg = Drawing.new("Line"), bar = Drawing.new("Line"), health = Drawing.new("Text"),
    }
    espData[plr].name.Size = 14; espData[plr].name.Center = true; espData[plr].name.Outline = true
    espData[plr].dist.Size = 12; espData[plr].dist.Center = true; espData[plr].dist.Outline = true
    espData[plr].role.Size = 12; espData[plr].role.Center = true; espData[plr].role.Outline = true; espData[plr].role.Color = Color3.fromRGB(255, 150, 150)
    espData[plr].barBg.Thickness = 4; espData[plr].barBg.Color = Color3.fromRGB(50, 50, 50)
    espData[plr].bar.Thickness = 4; espData[plr].health.Size = 11; espData[plr].health.Outline = true
end

local function removeDrawingESP(plr)
    if espData[plr] then
        for _, obj in pairs(espData[plr]) do obj:Remove() end
        espData[plr] = nil
    end
end

Players.PlayerAdded:Connect(function(p) task.wait(1) createDrawingESP(p) end)
for _, p in ipairs(Players:GetPlayers()) do createDrawingESP(p) end
Players.PlayerRemoving:Connect(function(p) removeDrawingESP(p) end)

-- ---------- 渲染循环 (降频防卡) ----------
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    if frameCount % 2 ~= 0 then return end -- 每2帧刷新1次，降低负载

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
                    data.name.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                    data.dist.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                    
                    if CFG.ESPRole then
                        local role = getRoleLabel(plr)
                        data.role.Visible = true
                        data.role.Text = "[" .. role .. "]"
                        data.role.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
                    else data.role.Visible = false end

                    data.name.Text = plr.Name
                    data.dist.Text = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude) .. " studs"

                    if CFG.ESPHealth then
                        local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        local barX = screenPos.X - 25
                        local barY = screenPos.Y - 5
                        
                        data.barBg.Visible = true
                        data.barBg.From = Vector2.new(barX, barY)
                        data.barBg.To = Vector2.new(barX + 50, barY)

                        data.bar.Visible = true
                        data.bar.From = Vector2.new(barX, barY)
                        data.bar.To = Vector2.new(barX + (50 * hpRatio), barY)
                        data.bar.Color = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 0)

                        data.health.Visible = true
                        data.health.Text = math.floor(hum.Health) .. " HP"
                        data.health.Position = Vector2.new(barX + 55, barY - 6)
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
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

-- ---------- 按钮构建 ----------
addLabel("── 透视功能 ──")
addToggle("透视 玩家名字", "ESP")
addToggle("透视 血条", "ESPHealth")
addToggle("透视 中文职业", "ESPRole")

addLabel("── 自身修改 ──")
addToggle("移动加速", "Speed")
addToggle("高跳", "Jump")
addToggle("穿墙 (Noclip)", "Noclip")

print("[Ninja Panel v10] 已加载，享受丝滑")