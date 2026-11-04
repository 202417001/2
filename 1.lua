-- ============================================
-- Ninja Panel v55 (底层极致光学模拟 · 纯净透视)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CFG = { ESP = false, ESPHealth = false, ESPRole = false }
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
-- 底层光学材质主面板
-- ==========================================
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 360); main.Position = UDim2.fromScale(0.1, 0.2)
-- 调整了底色，增强了吸光感，不再是个完全透明的空壳
main.BackgroundColor3 = Color3.fromRGB(18, 20, 26); main.BackgroundTransparency = 0.15 
main.BorderSizePixel = 0; main.Active = true; main.Draggable = true; main.Parent = mainGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

-- 1. 菲涅尔边缘高光 (底层硬边)
local fStroke = Instance.new("UIStroke", main)
fStroke.Color = Color3.new(1,1,1); fStroke.Transparency = 0.15; fStroke.Thickness = 1.5

-- 2. 色散模拟 (底层光学错位 0.1~0.2)
local caRed = Instance.new("UIStroke", main)
caRed.Thickness = 1.5; caRed.Color = Color3.fromRGB(255, 60, 60); caRed.Transparency = 0.9; caRed.Offset = Vector2.new(1.2, 0)
local caBlue = Instance.new("UIStroke", main)
caBlue.Thickness = 1.5; caBlue.Color = Color3.fromRGB(60, 60, 255); caBlue.Transparency = 0.9; caBlue.Offset = Vector2.new(-1.2, 0)

-- 3. 流体波纹与折射 (底层动态渐变)
local fluidGrad = Instance.new("UIGradient", main)
fluidGrad.Rotation = 45
fluidGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(140, 160, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 90, 120)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(140, 160, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
fluidGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.75),
    NumberSequenceKeypoint.new(0.2, 0.9),
    NumberSequenceKeypoint.new(0.5, 0.95),
    NumberSequenceKeypoint.new(0.8, 0.9),
    NumberSequenceKeypoint.new(1, 0.75)
}

-- 让流体在底层动起来
task.spawn(function()
    while task.wait(0.03) do
        if main.Visible then
            local rot = fluidGrad.Rotation + 1
            if rot > 360 then rot = 0 end
            fluidGrad.Rotation = rot
        end
    end
end)

local uiScale = Instance.new("UIScale"); uiScale.Scale = 1; uiScale.Parent = main

-- 最小化图标
local icon = Instance.new("TextButton"); icon.Size = UDim2.fromOffset(46, 46); icon.Position = UDim2.fromOffset(12, 240)
icon.BackgroundColor3 = Color3.fromRGB(30, 30, 40); icon.Text = "N"; icon.TextColor3 = Color3.new(1, 1, 1); icon.Font = Enum.Font.GothamBold; icon.TextSize = 20
icon.Visible = false; icon.Active = true; icon.Draggable = true; icon.Parent = mainGui; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)
local function minimize() main.Visible = false; icon.Visible = true end

-- 标题栏
local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, 0, 0, 44); title.BackgroundTransparency = 1
title.Text = "NINJA PANEL"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = Enum.Font.GothamBold; title.TextSize = 16; title.Parent = main; title.ZIndex = 10
local titleStroke = Instance.new("UIStroke", title); titleStroke.Color = Color3.new(0,0,0); titleStroke.Transparency = 0.6; titleStroke.Thickness = 2

local function mkTitleBtn(text, xoff, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(28, 28); b.Position = UDim2.new(1, xoff, 0, 8)
    b.BackgroundTransparency = 1; b.Text = text; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamBold; b.TextSize = 20; b.Parent = main; b.ZIndex = 10
    b.MouseButton1Click:Connect(cb); return b
end
mkTitleBtn("−", -94, function() uiScale.Scale = math.max(0.6, uiScale.Scale - 0.1) end)
mkTitleBtn("+", -64, function() uiScale.Scale = math.min(1.8, uiScale.Scale + 0.1) end)
mkTitleBtn("×", -32, minimize)

local scroll = Instance.new("ScrollingFrame"); scroll.Size = UDim2.new(1, -16, 1, -60); scroll.Position = UDim2.fromOffset(8, 50)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 2; scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = main; scroll.ZIndex = 10
local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 10); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = scroll

-- ==========================================
-- 组件 (分层渲染)
-- ==========================================
local function createGlassRow(parent, height)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, height)
    -- 组件的底色加深，使其不透明
    row.BackgroundColor3 = Color3.fromRGB(30, 35, 45); row.BackgroundTransparency = 0.1
    row.BorderSizePixel = 0; row.Parent = parent; row.ZIndex = 10
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
    
    -- 组件高光
    local s = Instance.new("UIStroke", row); s.Color = Color3.new(1,1,1); s.Transparency = 0.7
    -- 组件轻微色散
    local r = Instance.new("UIStroke", row); r.Color = Color3.fromRGB(255,80,80); r.Transparency = 0.95; r.Offset = Vector2.new(1, 0)
    local b = Instance.new("UIStroke", row); b.Color = Color3.fromRGB(80,80,255); b.Transparency = 0.95; b.Offset = Vector2.new(-1, 0)
    return row
end

local function addGlassToggle(parent, name, key)
    local row = createGlassRow(parent, 46)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -70, 1, 0); lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row; lbl.ZIndex = 11
    local lStroke = Instance.new("UIStroke", lbl); lStroke.Color = Color3.new(0,0,0); lStroke.Transparency = 0.5

    local track = Instance.new("Frame"); track.Size = UDim2.fromOffset(42, 24); track.Position = UDim2.new(1, -56, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(15, 15, 20); track.BorderSizePixel = 0; track.Parent = row; Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0); track.ZIndex = 11
    local tStroke = Instance.new("UIStroke", track); tStroke.Color = Color3.new(1,1,1); tStroke.Transparency = 0.6

    local fill = Instance.new("Frame"); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 200, 120); fill.BorderSizePixel = 0; fill.Parent = track; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0); fill.ZIndex = 12
    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(20, 20); knob.Position = UDim2.new(0, 2, 0.5, -10); knob.BackgroundColor3 = Color3.new(1,1,1); knob.Parent = track; Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0); knob.ZIndex = 13
    local kStroke = Instance.new("UIStroke", knob); kStroke.Color = Color3.new(1,1,1); kStroke.Transparency = 0.5

    local btn = Instance.new("TextButton"); btn.Size = UDim2.fromScale(1,1); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 14; btn.Parent = row
    local function updateUI()
        if CFG[key] then
            TweenService:Create(fill, TweenInfo.new(0.2), {Size = UDim2.fromScale(1,1)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -22, 0.5, -10)}):Play()
        else
            TweenService:Create(fill, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
        end
    end
    btn.MouseButton1Click:Connect(function() CFG[key] = not CFG[key]; updateUI() end)
    updateUI()
end

-- ==========================================
-- 透视渲染底层
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
addGlassToggle(scroll, "玩家名字透视", "ESP")
addGlassToggle(scroll, "血条比例透视", "ESPHealth")
addGlassToggle(scroll, "中文职业透视", "ESPRole")

print("[Ninja Panel v55] 底层光学渲染优化加载完毕")