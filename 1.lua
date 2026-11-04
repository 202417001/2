-- ============================================
-- Ninja Panel v50 (准心优先 · 掩体判断 · 按住开火)
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
    Aimbot = false, HoldToAim = false, ShowFOV = true, WallCheck = true,
    AimPart = "Head", FOV = 150, Smoothness = 0.4,
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
-- FOV 范围框
-- ==========================================
local fovCircle = nil
if Drawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.Color = Color3.fromRGB(0, 255, 150)
    fovCircle.Transparency = 0.6
    fovCircle.Filled = false
    fovCircle.Visible = false
end

-- ==========================================
-- 液态玻璃主面板
-- ==========================================
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 480); main.Position = UDim2.fromScale(0.1, 0.2)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30); main.BackgroundTransparency = 0.3
main.BorderSizePixel = 0; main.Active = true; main.Draggable = true; main.Parent = mainGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 255, 255); stroke.Transparency = 0.5; stroke.Thickness = 1.2

local grad = Instance.new("UIGradient", main)
grad.Rotation = 90
grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 150))}
grad.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.65),NumberSequenceKeypoint.new(0.5, 1),NumberSequenceKeypoint.new(1, 0.8)}

local uiScale = Instance.new("UIScale"); uiScale.Scale = 1; uiScale.Parent = main

local icon = Instance.new("TextButton"); icon.Size = UDim2.fromOffset(46, 46); icon.Position = UDim2.fromOffset(12, 240)
icon.BackgroundColor3 = Color3.fromRGB(30, 30, 40); icon.Text = "N"; icon.TextColor3 = Color3.new(1, 1, 1); icon.Font = Enum.Font.GothamBold; icon.TextSize = 20
icon.Visible = false; icon.Active = true; icon.Draggable = true; icon.Parent = mainGui; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)
local function minimize() main.Visible = false; icon.Visible = true end

local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, 0, 0, 44); title.BackgroundTransparency = 1
title.Text = "NINJA PANEL"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = Enum.Font.GothamBold; title.TextSize = 16; title.Parent = main; title.ZIndex = 10

local function mkTitleBtn(text, xoff, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(28, 28); b.Position = UDim2.new(1, xoff, 0, 8)
    b.BackgroundTransparency = 1; b.Text = text; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamBold; b.TextSize = 20; b.Parent = main; b.ZIndex = 10
    b.MouseButton1Click:Connect(cb); return b
end
mkTitleBtn("−", -94, function() uiScale.Scale = math.max(0.6, uiScale.Scale - 0.1) end)
mkTitleBtn("+", -64, function() uiScale.Scale = math.min(1.8, uiScale.Scale + 0.1) end)
mkTitleBtn("×", -32, minimize)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 32); tabBar.Position = UDim2.fromOffset(8, 50)
tabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25); tabBar.BackgroundTransparency = 0.5
tabBar.BorderSizePixel = 0; tabBar.Parent = main; tabBar.ZIndex = 5
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center; tabLayout.Padding = UDim.new(0, 4)

local pages = {}
local function createPage(index)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, -16, 1, -150); sf.Position = UDim2.fromOffset(8, 90)
    sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 2; sf.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    sf.CanvasSize = UDim2.new(0, 0, 0, 0); sf.AutomaticCanvasSize = Enum.AutomaticSize.Y; sf.Parent = main; sf.ZIndex = 5
    sf.Visible = (index == 1)
    local l = Instance.new("UIListLayout", sf); l.Padding = UDim.new(0, 8); l.SortOrder = Enum.SortOrder.LayoutOrder
    pages[index] = sf; return sf
end
local page1 = createPage(1); local page2 = createPage(2); local page3 = createPage(3)

local function switchTab(index)
    for i, p in ipairs(pages) do p.Visible = (i == index) end
    for _, btn in ipairs(tabBar:GetChildren()) do
        if btn:IsA("TextButton") then
            if btn:GetAttribute("tabIndex") == index then btn.BackgroundTransparency = 0.2; btn.TextColor3 = Color3.fromRGB(0, 255, 150)
            else btn.BackgroundTransparency = 1; btn.TextColor3 = Color3.fromRGB(200, 200, 200) end
        end
    end
end

local function createTabBtn(name, index)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(0.3, 0, 0, 26); b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    b.Text = name; b.TextColor3 = Color3.fromRGB(200, 200, 200); b.Font = Enum.Font.GothamBold; b.TextSize = 12
    b.Parent = tabBar; b:SetAttribute("tabIndex", index); Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() switchTab(index) end)
end
createTabBtn("视觉", 1); createTabBtn("战斗", 2); createTabBtn("移动", 3)

local statusBar = Instance.new("TextLabel"); statusBar.Size = UDim2.new(1, -16, 0, 36); statusBar.Position = UDim2.new(0, 8, 1, -44)
statusBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15); statusBar.BackgroundTransparency = 0.4; statusBar.BorderSizePixel = 0
statusBar.Text = "系统就绪"; statusBar.TextColor3 = Color3.fromRGB(0, 255, 150); statusBar.Font = Enum.Font.GothamBold; statusBar.TextSize = 12
statusBar.Parent = main; statusBar.ZIndex = 5; Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- UI 组件
-- ==========================================
local function createGlassRow(parent, height)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, height)
    row.BackgroundColor3 = Color3.fromRGB(40, 40, 50); row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0; row.Parent = parent; row.ZIndex = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", row); s.Color = Color3.new(1,1,1); s.Transparency = 0.85
    return row
end

local function addGlassToggle(parent, name, key)
    local row = createGlassRow(parent, 44)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -70, 1, 0); lbl.Position = UDim2.fromOffset(12, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row; lbl.ZIndex = 6

    local track = Instance.new("Frame"); track.Size = UDim2.fromOffset(40, 22); track.Position = UDim2.new(1, -54, 0.5, -11)
    track.BackgroundColor3 = Color3.fromRGB(30, 30, 40); track.BorderSizePixel = 0; track.Parent = row; Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0); track.ZIndex = 6
    local fill = Instance.new("Frame"); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 180, 100); fill.BorderSizePixel = 0; fill.Parent = track; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0); fill.ZIndex = 7
    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(18, 18); knob.Position = UDim2.new(0, 2, 0.5, -9); knob.BackgroundColor3 = Color3.new(1,1,1); knob.Parent = track; Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0); knob.ZIndex = 8

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

local function addGlassSlider(parent, name, minVal, maxVal, defaultVal, callback)
    local row = createGlassRow(parent, 56)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 0, 20); lbl.Position = UDim2.fromOffset(12, 6)
    lbl.BackgroundTransparency = 1; lbl.Text = name .. ": " .. defaultVal; lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row; lbl.ZIndex = 6

    local track = Instance.new("Frame"); track.Size = UDim2.new(1, -24, 0, 6); track.Position = UDim2.new(0, 12, 1, -16)
    track.BackgroundColor3 = Color3.fromRGB(30, 30, 40); track.BorderSizePixel = 0; track.Parent = row; Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0); track.ZIndex = 6
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((defaultVal-minVal)/(maxVal-minVal), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 180, 100); fill.BorderSizePixel = 0; fill.Parent = track; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0); fill.ZIndex = 7
    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(16, 16); knob.Position = UDim2.new((defaultVal-minVal)/(maxVal-minVal), -8, 0.5, 0); knob.AnchorPoint = Vector2.new(0, 0.5); knob.BackgroundColor3 = Color3.new(1,1,1); knob.Parent = track; Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0); knob.ZIndex = 8

    local touchArea = Instance.new("TextButton"); touchArea.Size = UDim2.new(1, 0, 1, 0); touchArea.BackgroundTransparency = 1; touchArea.Text = ""; touchArea.ZIndex = 9; touchArea.Parent = row
    local isDragging = false
    local function updateVal(xPos)
        local relX = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * relX
        if maxVal <= 2 then val = math.floor(val * 100) / 100 else val = math.floor(val) end
        fill.Size = UDim2.new(relX, 0, 1, 0); knob.Position = UDim2.new(relX, -8, 0.5, 0)
        lbl.Text = name .. ": " .. val; callback(val)
    end
    touchArea.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true; updateVal(input.Position.X) end end)
    UIS.InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then updateVal(input.Position.X) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
end

-- ==========================================
-- 战斗核心：准心优先 & 掩体判断
-- ==========================================
local isFiring = false
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isFiring = true end
end)
UIS.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isFiring = false end
end)

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function getClosestTarget()
    local closest = nil
    local minScreenDist = math.huge -- 核心修改：用屏幕距离判定，而非 3D 距离
    local center = Camera.ViewportSize / 2
    local myChar = LP.Character
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local part = plr.Character:FindFirstChild(CFG.AimPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    -- 优先锁准心附近的敌人
                    if distToCenter <= CFG.FOV and distToCenter < minScreenDist then
                        if CFG.WallCheck then
                            local origin = Camera.CFrame.Position
                            local dir = (part.Position - origin)
                            rayParams.FilterDescendantsInstances = {myChar}
                            local hit = workspace:Raycast(origin, dir, rayParams)
                            
                            if not hit or (hit.Instance and hit.Instance:IsDescendantOf(plr.Character)) then
                                minScreenDist = distToCenter
                                closest = part
                            end
                        else
                            minScreenDist = distToCenter
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if fovCircle then
        if CFG.Aimbot and CFG.ShowFOV then
            fovCircle.Visible = true
            fovCircle.Position = Camera.ViewportSize / 2
            fovCircle.Radius = CFG.FOV
        else
            fovCircle.Visible = false
        end
    end

    if CFG.Aimbot and (not CFG.HoldToAim or isFiring) then
        local target = getClosestTarget()
        if target then
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, CFG.Smoothness)
            if fovCircle then fovCircle.Color = Color3.fromRGB(255, 50, 50) end
        else
            if fovCircle then fovCircle.Color = Color3.fromRGB(0, 255, 150) end
        end
    else
        if fovCircle then fovCircle.Color = Color3.fromRGB(0, 255, 150) end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LP.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if CFG.Speed then hum.WalkSpeed = CFG.SpeedVal end
end)

-- ESP 渲染
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
                    data.bar.Size = UDim2.fromScale(hpRatio, 1); data.bar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 0); hpText.Text = math.floor(hpRatio * 100) .. "%"
                end
            else data.gui.Enabled = false end
        end
    end
end)

-- ==========================================
-- 构建 UI
-- ==========================================
addGlassToggle(page1, "玩家名字透视", "ESP")
addGlassToggle(page1, "血条比例透视", "ESPHealth")
addGlassToggle(page1, "中文职业透视", "ESPRole")

addGlassToggle(page2, "开启准心优先自瞄", "Aimbot")
addGlassToggle(page2, "开启掩体判断 (不锁墙后)", "WallCheck")
addGlassToggle(page2, "显示 FOV 范围框", "ShowFOV")
addGlassToggle(page2, "按住开火才生效", "HoldToAim")
addGlassSlider(page2, "瞄准范围 (FOV)", 10, 500, CFG.FOV, function(val) CFG.FOV = val end)
addGlassSlider(page2, "吸附速度 (越小越慢)", 0.05, 1.0, CFG.Smoothness, function(val) CFG.Smoothness = val end)

addGlassToggle(page3, "强制奔跑 (18)", "Speed")
addGlassToggle(page3, "速度欺骗 (免耗耐)", "FakeSpeed")

print("[Ninja Panel v50] 准心优先版加载完毕")