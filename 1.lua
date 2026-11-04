-- ============================================
-- Ninja Panel v45 (纯正液态玻璃 · 完美点击)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CFG = {
    ESP = false, ESPHealth = false, ESPRole = false,
    Speed = false, SpeedVal = 18, 
    FakeSpeed = false,
    SilentAim = false, AimPart = "Head", FOV = 150,
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

-- ==========================================
-- 核心：一体化液态玻璃结构
-- ==========================================
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 480); main.Position = UDim2.fromScale(0.1, 0.2)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30); main.BackgroundTransparency = 0.3
main.BorderSizePixel = 0; main.Active = true; main.Draggable = true; main.Parent = mainGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

-- 玻璃边缘高光
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 255, 255); stroke.Transparency = 0.5; stroke.Thickness = 1.2

-- 玻璃渐变色
local grad = Instance.new("UIGradient", main)
grad.Rotation = 90
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 150))
}
grad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.65),
    NumberSequenceKeypoint.new(0.5, 1),
    NumberSequenceKeypoint.new(1, 0.8)
}

local uiScale = Instance.new("UIScale"); uiScale.Scale = 1; uiScale.Parent = main

-- 最小化图标
local icon = Instance.new("TextButton"); icon.Size = UDim2.fromOffset(46, 46); icon.Position = UDim2.fromOffset(12, 240)
icon.BackgroundColor3 = Color3.fromRGB(30, 30, 40); icon.Text = "N"; icon.TextColor3 = Color3.new(1, 1, 1); icon.Font = Enum.Font.GothamBold; icon.TextSize = 20
icon.Visible = false; icon.Active = true; icon.Draggable = true; icon.Parent = mainGui; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)
local function minimize() main.Visible = false; icon.Visible = true end

-- 标题栏
local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, 0, 0, 44); title.BackgroundTransparency = 1
title.Text = "NINJA PANEL"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = Enum.Font.GothamBold; title.TextSize = 16; title.Parent = main
title.ZIndex = 10

local function mkTitleBtn(text, xoff, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(28, 28); b.Position = UDim2.new(1, xoff, 0, 8)
    b.BackgroundTransparency = 1; b.Text = text; b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold; b.TextSize = 20; b.Parent = main; b.ZIndex = 10
    b.MouseButton1Click:Connect(cb); return b
end
mkTitleBtn("−", -94, function() uiScale.Scale = math.max(0.6, uiScale.Scale - 0.1) end)
mkTitleBtn("+", -64, function() uiScale.Scale = math.min(1.8, uiScale.Scale + 0.1) end)
mkTitleBtn("×", -32, minimize)

local scroll = Instance.new("ScrollingFrame"); scroll.Size = UDim2.new(1, -16, 1, -100); scroll.Position = UDim2.fromOffset(8, 50)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 2; scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = main; scroll.ZIndex = 5
local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = scroll

local statusBar = Instance.new("TextLabel"); statusBar.Size = UDim2.new(1, -16, 0, 36); statusBar.Position = UDim2.new(0, 8, 1, -44)
statusBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15); statusBar.BackgroundTransparency = 0.4; statusBar.BorderSizePixel = 0
statusBar.Text = "系统就绪"; statusBar.TextColor3 = Color3.fromRGB(0, 255, 150); statusBar.Font = Enum.Font.GothamBold; statusBar.TextSize = 12
statusBar.Parent = main; statusBar.ZIndex = 5; Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- UI 组件生成器
-- ==========================================
local function createGlassRow(height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, height)
    row.BackgroundColor3 = Color3.fromRGB(40, 40, 50); row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0; row.Parent = scroll; row.ZIndex = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", row); s.Color = Color3.new(1,1,1); s.Transparency = 0.85
    return row
end

local function addGlassToggle(name, key)
    local row = createGlassRow(44)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -70, 1, 0); lbl.Position = UDim2.fromOffset(12, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
    lbl.ZIndex = 6

    local track = Instance.new("Frame"); track.Size = UDim2.fromOffset(40, 22); track.Position = UDim2.new(1, -54, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(30, 30, 40); track.BorderSizePixel = 0; track.Parent = row; Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    track.ZIndex = 6
    
    local fill = Instance.new("Frame"); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 180, 100); fill.BorderSizePixel = 0; fill.Parent = track; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    fill.ZIndex = 7
    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(18, 18); knob.Position = UDim2.new(0, 2, 0.5, -9); knob.BackgroundColor3 = Color3.new(1,1,1); knob.Parent = track; Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.ZIndex = 8
    
    -- 点击层置顶
    local btn = Instance.new("TextButton"); btn.Size = UDim2.fromScale(1,1); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 9; btn.Parent = row
    
    local function updateUI()
        if CFG[key] then
            TweenService:Create(fill, TweenInfo.new(0.2), {Size = UDim2.fromScale(1,1)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
        else
            TweenService:Create(fill, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
    end
    btn.MouseButton1Click:Connect(function() CFG[key] = not CFG[key]; updateUI() end)
    updateUI()
end

local function addGlassSlider(name, minVal, maxVal, defaultVal, callback)
    local row = createGlassRow(56)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 0, 20); lbl.Position = UDim2.fromOffset(12, 6)
    lbl.BackgroundTransparency = 1; lbl.Text = name .. ": " .. defaultVal; lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row
    lbl.ZIndex = 6

    local track = Instance.new("Frame"); track.Size = UDim2.new(1, -24, 0, 6); track.Position = UDim2.new(0, 12, 1, -16)
    track.BackgroundColor3 = Color3.fromRGB(30, 30, 40); track.BorderSizePixel = 0; track.Parent = row; Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    track.ZIndex = 6
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((defaultVal-minVal)/(maxVal-minVal), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 180, 100); fill.BorderSizePixel = 0; fill.Parent = track; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    fill.ZIndex = 7
    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(16, 16); knob.Position = UDim2.new((defaultVal-minVal)/(maxVal-minVal), -8, 0.5, 0); knob.AnchorPoint = Vector2.new(0, 0.5); knob.BackgroundColor3 = Color3.new(1,1,1); knob.Parent = track; Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.ZIndex = 8

    local touchArea = Instance.new("TextButton")
    touchArea.Size = UDim2.new(1, 0, 1, 0); touchArea.BackgroundTransparency = 1; touchArea.Text = ""; touchArea.ZIndex = 9
    touchArea.Parent = row

    local isDragging = false
    local function updateVal(xPos)
        local relX = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * relX)
        fill.Size = UDim2.new(relX, 0, 1, 0); knob.Position = UDim2.new(relX, -8, 0.5, 0)
        lbl.Text = name .. ": " .. val; callback(val)
    end
    
    touchArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isDragging = true; updateVal(input.Position.X) 
        end 
    end)
    UIS.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then 
            updateVal(input.Position.X) 
        end 
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isDragging = false 
        end 
    end)
end

local function addSection(name)
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -6, 0, 24); l.BackgroundTransparency = 1; l.Text = name
    l.TextColor3 = Color3.fromRGB(200, 200, 210); l.Font = Enum.Font.GothamBold; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = scroll
    l.ZIndex = 6
end

-- ==========================================
-- 核心逻辑 (静默 + 速度)
-- ==========================================
local cachedTarget = nil
task.spawn(function()
    while task.wait(0.1) do
        if CFG.SilentAim then
            local closest, minDist = nil, math.huge
            local center = Camera.ViewportSize / 2
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local part = plr.Character:FindFirstChild(CFG.AimPart) or plr.Character:FindFirstChild("HumanoidRootPart")
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if part and hum and hum.Health > 0 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if distToCenter <= CFG.FOV then
                                local dist3D = (Camera.CFrame.Position - part.Position).Magnitude
                                if dist3D < minDist then minDist = dist3D; closest = part end
                            end
                        end
                    end
                end
            end
            cachedTarget = closest
        else
            cachedTarget = nil
        end
    end
end)

local function setupSilentAim()
    if not hookmetamethod then statusBar.Text = "不支持静默" return end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if CFG.SilentAim and not checkcaller() and cachedTarget then
            if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
                local args = {...}
                local isCameraRay = false
                if method == "Raycast" then
                    if type(args[2]) == "RaycastParams" and args[2].FilterDescendantsInstances then
                        for _, v in ipairs(args[2].FilterDescendantsInstances) do
                            if v == Camera then isCameraRay = true end
                        end
                    end
                end
                if not isCameraRay then
                    if method == "Raycast" then
                        args[2] = (cachedTarget.Position - args[1].Origin).Unit * (args[1].Origin - cachedTarget.Position).Magnitude
                    else
                        local ray = args[1]
                        args[1] = Ray.new(ray.Origin, (cachedTarget.Position - ray.Origin).Unit * (ray.Origin - cachedTarget.Position).Magnitude)
                    end
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    statusBar.Text = "✔ 静默已注入"
end
setupSilentAim()

local oldIndex
local function setupFakeSpeed()
    if not hookmetamethod then return end
    pcall(function()
        oldIndex = hookmetamethod(game, "__index", function(t, k)
            if CFG.FakeSpeed and not checkcaller() and k == "WalkSpeed" and t:IsA("Humanoid") then return 16 end
            return oldIndex(t, k)
        end)
    end)
end
setupFakeSpeed()

RunService.Heartbeat:Connect(function()
    local char = LP.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if CFG.Speed then hum.WalkSpeed = CFG.SpeedVal end
end)

-- ==========================================
-- ESP 渲染
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
-- 生成 UI
-- ==========================================
addSection("── 视觉透视 ──")
addGlassToggle("玩家名字透视", "ESP")
addGlassToggle("血条比例透视", "ESPHealth")
addGlassToggle("中文职业透视", "ESPRole")

addSection("── 战斗辅助 ──")
addGlassToggle("开启真·静默瞄准", "SilentAim")
addGlassSlider("瞄准范围 (FOV)", 10, 500, CFG.FOV, function(val) CFG.FOV = val end)

addSection("── 移动与耐力 ──")
addGlassToggle("强制奔跑 (18)", "Speed")
addGlassToggle("速度欺骗 (免耗耐)", "FakeSpeed")

print("[Ninja Panel v45] 终极液态玻璃加载完毕")