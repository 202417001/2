-- ============================================
-- Ninja Panel v4
-- 移除传送；角色扫描器加强
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local LP         = Players.LocalPlayer
local Camera     = workspace.CurrentCamera

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

-- ---------- GUI ----------
local old = LP:WaitForChild("PlayerGui"):FindFirstChild("NinjaPanel")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NinjaPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 500)
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

-- 最小化图标
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
local stroke = Instance.new("UIStroke", icon)
stroke.Color = Color3.fromRGB(0, 180, 120)
stroke.Thickness = 2

icon.MouseButton1Click:Connect(function()
    main.Visible = true
    icon.Visible = false
end)

local function minimize()
    main.Visible = false
    icon.Visible = true
end

-- 标题栏
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0
title.Text = "Ninja Panel v4"
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
    local b
    b = addButton((CFG[key] and "[ON] " or "[OFF] ") .. name, function()
        CFG[key] = not CFG[key]
        b.Text = (CFG[key] and "[ON] " or "[OFF] ") .. name
        b.BackgroundColor3 = CFG[key] and Color3.fromRGB(0, 140, 80) or Color3.fromRGB(50, 50, 60)
    end)
    if CFG[key] then b.BackgroundColor3 = Color3.fromRGB(0, 140, 80) end
    return b
end

-- ---------- 角色读取 ----------
local function getRoleLabel(plr)
    if ROLE_MAP[plr.Name] then return ROLE_MAP[plr.Name] end

    local function check(obj)
        if not obj then return nil end
        for k, v in pairs(obj:GetAttributes()) do
            local kn = k:lower()
            if kn:find("role") or kn:find("job") or kn:find("职业") or kn:find("角色") or kn:find("class") or kn:find("team") then
                if type(v) == "string" and v ~= "" then return v end
            end
        end
        for _, tag in ipairs(CollectionService:GetTags(obj)) do
            if tag:lower():find("role") or tag:lower():find("job") then return tag end
        end
        for _, c in ipairs(obj:GetChildren()) do
            if c:IsA("StringValue") then
                local n = c.Name:lower()
                if n:find("role") or n:find("job") or n:find("职业") or n:find("角色") or n:find("class") or n:find("team") then
                    if c.Value ~= "" then return c.Value end
                end
            end
        end
        return nil
    end

    return check(plr.Character) or check(plr)
end

-- ---------- 深度扫描器（加强） ----------
local function deepScan(plr, root, depth, prefix, out)
    if depth > 4 or not root then return end
    for _, c in ipairs(root:GetChildren()) do
        local full = prefix .. c.Name
        local cls = c.ClassName
        if c:IsA("StringValue") then
            table.insert(out, full .. "  [" .. cls .. "] = " .. tostring(c.Value))
        elseif c:IsA("TextLabel") then
            if c.Text ~= "" then
                table.insert(out, full .. "  [" .. cls .. "] text = " .. tostring(c.Text))
            end
        elseif c:IsA("IntValue") or c:IsA("NumberValue") or c:IsA("BoolValue") then
            table.insert(out, full .. "  [" .. cls .. "] = " .. tostring(c.Value))
        end
        if depth < 4 then
            deepScan(plr, c, depth + 1, full .. ".", out)
        end
    end
end

local function scanRoles()
    print("===== 深度角色扫描开始 =====")

    -- 1. 全局服务里找
    local services = { "ReplicatedStorage", "ServerStorage", "Workspace", "Players", "Teams" }
    for _, sn in ipairs(services) do
        local svc = game:GetService(sn)
        if svc then
            local found = {}
            for _, d in ipairs(svc:GetDescendants()) do
                if d:IsA("StringValue") then
                    local n = d.Name:lower()
                    if n:find("role") or n:find("job") or n:find("职业") or n:find("角色") then
                        table.insert(found, d:GetFullName() .. " = " .. tostring(d.Value))
                        if #found >= 30 then break end
                    end
                end
            end
            if #found > 0 then
                print("--- [" .. sn .. "] 中找到 " .. #found .. " 个可疑 StringValue ---")
                for _, line in ipairs(found) do print("  " .. line) end
            end
        end
    end

    -- 2. Teams 检查
    local Teams = game:GetService("Teams")
    print("--- Teams 队伍列表 ---")
    for _, t in ipairs(Teams:GetTeams()) do
        print("  [Team] " .. t.Name .. " / Color=" .. tostring(t.TeamColor))
    end

    -- 3. 每个玩家深挖
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            print("========== " .. p.Name .. " (" .. p.DisplayName .. ") ==========")
            print("  Team = " .. tostring(p.Team and p.Team.Name))
            print("  Neutral = " .. tostring(p.Neutral))
            for k, v in pairs(p:GetAttributes()) do
                print("  [Player Attr] " .. k .. " = " .. tostring(v))
            end
            for _, tag in ipairs(CollectionService:GetTags(p)) do
                print("  [Player Tag] " .. tag)
            end

            local char = p.Character
            if char then
                local out = {}
                deepScan(p, char, 1, "", out)
                for _, line in ipairs(out) do
                    print("  " .. line)
                end
                for k, v in pairs(char:GetAttributes()) do
                    print("  [Char Attr] " .. k .. " = " .. tostring(v))
                end
                for _, tag in ipairs(CollectionService:GetTags(char)) do
                    print("  [Char Tag] " .. tag)
                end
            else
                print("  (无角色)")
            end
        end
    end
    print("===== 扫描结束，请复制控制台全部内容 =====")
end

-- ---------- 功能按钮 ----------
addToggle("ESP 玩家名字", "ESP")
addToggle("ESP 血条", "ESPHealth")
addToggle("ESP 角色前缀", "ESPRole")

addButton("深度扫描角色", scanRoles, Color3.fromRGB(120, 80, 160))

addButton("手动设置角色", function()
    -- 简单输入框
    local Input = Instance.new("TextBox")
    Input.Size = UDim2.fromOffset(280, 36)
    Input.Position = UDim2.fromScale(0.5, 0.5)
    Input.AnchorPoint = Vector2.new(0.5, 0.5)
    Input.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Input.TextColor3 = Color3.new(1, 1, 1)
    Input.PlaceholderText = "玩家名=角色，如: Bob=Policeman"
    Input.Text = ""
    Input.Parent = gui
    Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 6)

    Input.FocusLost:Connect(function()
        local txt = Input.Text
        local name, role = txt:match("^(.-)=(.*)$")
        if name and role and name ~= "" then
            ROLE_MAP[name] = role
            print("[Role] 已设置 " .. name .. " = " .. role)
        end
        Input:Destroy()
    end)
end, Color3.fromRGB(80, 120, 80))

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
    g.Size = UDim2.fromOffset(160, 50)
    g.AlwaysOnTop = true
    g.Enabled = false
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

    espCache[plr] = { gui = g, name = name, dist = dist, bar = bar, barBg = barBg }
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
        if not plr.Character then
            data.gui.Enabled = false
        else
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                data.gui.Enabled = true
                data.gui.Adornee = hrp
                data.dist.Text = string.format("%d studs", (hrp.Position - Camera.CFrame.Position).Magnitude)
                local role = CFG.ESPRole and getRoleLabel(plr) or nil
                data.name.Text = role and ("[" .. role .. "] " .. plr.Name) or plr.Name
                data.barBg.Visible = CFG.ESPHealth
                if CFG.ESPHealth then
                    data.bar.Size = UDim2.fromScale(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 1)
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

print("[Ninja Panel v4] loaded")