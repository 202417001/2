-- ============================================
-- Ninja Panel v16 (闭包变量 & 像素级捕捉)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CFG = { ESP = false, ESPHealth = false, ESPRole = false, Speed = false, SpeedVal = 20, Jump = false, JumpVal = 60, Noclip = false, Scale = 1.0 }
local CN_ROLE_MAP = { ["Chef"]="厨师",["Civilian"]="平民",["Delivery"]="快递员",["Farmer"]="农夫",["Fire"]="消防员",["Medical"]="医生",["Police"]="警察",["Prisoner"]="囚犯",["Road Service"]="路政",["Transit"]="公交司机" }

local function getHiddenGui(name)
    local g = Instance.new("ScreenGui"); g.Name = name; g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    if syn and syn.protect_gui then syn.protect_gui(g); g.Parent = game:GetService("CoreGui")
    elseif gethui then g.Parent = gethui() else g.Parent = LP:WaitForChild("PlayerGui") end
    return g
end

local mainGui = getHiddenGui("MainPanel_" .. math.random(1000, 9999))
local espGui = getHiddenGui("EspRender_" .. math.random(1000, 9999))

local main = Instance.new("Frame"); main.Size = UDim2.fromOffset(300, 420); main.Position = UDim2.fromScale(0.02, 0.2)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true; main.Parent = mainGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local uiScale = Instance.new("UIScale"); uiScale.Scale = 1; uiScale.Parent = main

local icon = Instance.new("TextButton"); icon.Size = UDim2.fromOffset(46, 46); icon.Position = UDim2.fromOffset(12, 240)
icon.BackgroundColor3 = Color3.fromRGB(40, 40, 52); icon.Text = "N"; icon.TextColor3 = Color3.new(1, 1, 1); icon.Font = Enum.Font.GothamBold; icon.TextSize = 20
icon.Visible = false; icon.Active = true; icon.Draggable = true; icon.Parent = mainGui; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)
local function minimize() main.Visible = false; icon.Visible = true end

local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, 0, 0, 32); title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0; title.Text = "Ninja v16 (终极捕获)"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = Enum.Font.GothamBold; title.TextSize = 16; title.Parent = main
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
statusBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40); statusBar.BorderSizePixel = 0; statusBar.Text = "等待操作..."; statusBar.TextColor3 = Color3.fromRGB(0, 255, 150)
statusBar.Font = Enum.Font.GothamBold; statusBar.TextSize = 12; statusBar.Parent = main; Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 6)

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

local function addLabel(text)
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -6, 0, 22); l.BackgroundTransparency = 1; l.Text = text
    l.TextColor3 = Color3.fromRGB(160, 160, 180); l.Font = Enum.Font.GothamBold; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = scroll; return l
end

local function getRoleLabel(plr)
    if plr.Team then
        local tName = plr.Team.Name
        if tName and tName ~= "" and tName ~= "Neutral" and tName ~= "???" and not tName:find("%?") then return CN_ROLE_MAP[tName] or tName end
    end
    return "平民"
end

-- ---------- 终极双路捕捉 (闭包 + UI像素) ----------
local uiCache = {}
local upCache = {}

local function captureData()
    uiCache = {}
    upCache = {}
    
    -- 1. 扫 UI 像素和文本 (强力抓 AbsoluteSize 和 Offset)
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetDescendants()) do
            local key = obj:GetFullName()
            local d = {}
            if obj:IsA("TextLabel") then d.text = obj.Text end
            if obj:IsA("Frame") or obj:IsA("ImageLabel") then
                d.absX = obj.AbsoluteSize.X
                d.offX = obj.Size.X.Offset
                d.scaleX = obj.Size.X.Scale
                if obj:IsA("ImageLabel") then
                    d.rectX = obj.ImageRectSize.X
                    d.rectOffX = obj.ImageRectOffset.X
                end
            end
            uiCache[key] = d
        end
    end
    
    -- 2. 扫内存闭包变量 (Upvalues)
    for i, v in pairs(getgc()) do
        if type(v) == "function" then
            local ok, ups = pcall(function() return debug.getupvalues and debug.getupvalues(v) or getupvalues(v) end)
            if ok and ups then
                for k, val in pairs(ups) do
                    if type(val) == "number" and val >= 0 and val <= 100 then
                        upCache[i] = upCache[i] or {}
                        upCache[i][k] = val
                    end
                end
            end
        end
    end
end

local function compareData()
    local L = {"===== 终极抓取结果 ====="}
    local found = false
    
    -- 1. 对比 UI
    for k, d in pairs(uiCache) do
        local obj = LP.PlayerGui:FindFirstChild(k, true) or game:GetService("CoreGui"):FindFirstChild(k, true)
        if obj then
            for prop, oldVal in pairs(d) do
                local newVal
                if prop == "text" then newVal = obj.Text
                elseif prop == "absX" then newVal = obj.AbsoluteSize.X
                elseif prop == "offX" then newVal = obj.Size.X.Offset
                elseif prop == "scaleX" then newVal = obj.Size.X.Scale
                elseif prop == "rectX" then newVal = obj.ImageRectSize.X
                elseif prop == "rectOffX" then newVal = obj.ImageRectOffset.X
                end
                
                if newVal and tostring(oldVal) ~= tostring(newVal) then
                    -- 忽略那些乱七八糟的距离导航和聊天
                    if not k:lower():find("navigation") and not k:lower():find("chat") and not k:lower():find("quantity") then
                        found = true
                        table.insert(L, "[UI变动] " .. k)
                        table.insert(L, "  属性: " .. prop .. " | " .. tostring(oldVal) .. " -> " .. tostring(newVal))
                    end
                end
            end
        end
    end
    
    -- 2. 对比闭包
    for i, v in pairs(getgc()) do
        if type(v) == "function" and upCache[i] then
            local ok, ups = pcall(function() return debug.getupvalues and debug.getupvalues(v) or getupvalues(v) end)
            if ok and ups then
                for k, val in pairs(ups) do
                    if type(val) == "number" and upCache[i][k] and upCache[i][k] ~= val then
                        found = true
                        table.insert(L, "[闭包变量] 函数ID:" .. tostring(i) .. " | 变量:" .. tostring(k))
                        table.insert(L, "  变化: " .. tostring(upCache[i][k]) .. " -> " .. tostring(val))
                    end
                end
            end
        end
    end
    
    if not found then
        table.insert(L, "仍然没抓到！这说明饥饿/耐力根本没下发到客户端，完全在服务端运算。")
    end
    
    -- 弹窗
    local oldWin = mainGui:FindFirstChild("Win"); if oldWin then oldWin:Destroy() end
    local win = Instance.new("Frame"); win.Size = UDim2.fromOffset(340, 320); win.Position = UDim2.fromScale(0.5, 0.5); win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.BackgroundColor3 = Color3.fromRGB(15, 15, 20); win.Parent = mainGui; Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)
    local wtitle = Instance.new("TextLabel"); wtitle.Size = UDim2.new(1, 0, 0, 30); wtitle.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    wtitle.Text = "捕获结果 (截图发我)"; wtitle.TextColor3 = Color3.new(1, 1, 1); wtitle.Font = Enum.Font.GothamBold; wtitle.Parent = win
    Instance.new("UICorner", wtitle).CornerRadius = UDim.new(0, 8)
    local wclose = Instance.new("TextButton"); wclose.Size = UDim2.fromOffset(28, 28); wclose.Position = UDim2.new(1, -30, 0, 1)
    wclose.BackgroundColor3 = Color3.fromRGB(120, 40, 40); wclose.Text = "×"; wclose.TextColor3 = Color3.new(1, 1, 1); wclose.Parent = win
    Instance.new("UICorner", wclose).CornerRadius = UDim.new(0, 6); wclose.MouseButton1Click:Connect(function() win:Destroy() end)
    local wscroll = Instance.new("ScrollingFrame"); wscroll.Size = UDim2.new(1, -12, 1, -40); wscroll.Position = UDim2.fromOffset(6, 34)
    wscroll.BackgroundTransparency = 1; wscroll.CanvasSize = UDim2.new(0, 0, 0, 0); wscroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; wscroll.Parent = win
    local wtext = Instance.new("TextLabel"); wtext.Size = UDim2.new(1, -6, 0, 0); wtext.AutomaticSize = Enum.AutomaticSize.Y
    wtext.BackgroundTransparency = 1; wtext.Text = table.concat(L, "\n"); wtext.TextColor3 = Color3.fromRGB(220, 220, 230)
    wtext.Font = Enum.Font.Code; wtext.TextSize = 11; wtext.TextXAlignment = Enum.TextXAlignment.Left; wtext.TextYAlignment = Enum.TextYAlignment.Top
    wtext.TextWrapped = true; wtext.Parent = wscroll
end

-- ---------- 原生 BillboardGui ESP (极短血条) ----------
local espData = {}
local function buildESP(plr)
    if plr == LP then return end; if espData[plr] then return end
    local g = Instance.new("BillboardGui"); g.Name = "e_" .. math.random(1000, 9999); g.Size = UDim2.fromOffset(160, 50); g.AlwaysOnTop = true; g.Enabled = false; g.Parent = espGui
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

RunService.Heartbeat:Connect(function()
    local char = LP.Character; if not char then return end; local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if CFG.Speed then hum.WalkSpeed = CFG.SpeedVal end; if CFG.Jump then hum.JumpPower = CFG.JumpVal end
    if CFG.Noclip then for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end
end)

addLabel("── 透视功能 ──")
addToggle("透视 玩家名字", "ESP")
addToggle("透视 血条百分比", "ESPHealth")
addToggle("透视 中文职业", "ESPRole")

addLabel("── 终极抓取 ──")
addButton("1. 拍快照 (别动)", function()
    statusBar.Text = "正在深度拍照..."
    captureData()
    statusBar.Text = "✔ 快照完成，去跑步消耗耐力！"
end, Color3.fromRGB(50, 150, 200))

addButton("2. 对比变动 (跑完点)", function()
    statusBar.Text = "正在对比..."
    compareData()
    statusBar.Text = "对比完成"
end, Color3.fromRGB(180, 50, 100))

addLabel("── 自身修改 ──")
addToggle("移动加速", "Speed")
addToggle("高跳", "Jump")
addToggle("穿墙 (Noclip)", "Noclip")

print("[Ninja Panel v16] 终极版已加载")