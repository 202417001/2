-- ============================================
-- DeepSeek Studio (UI补全 · 真实伪造包杀戮)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local container = game:GetService("CoreGui")
pcall(function() if gethui then container = gethui() end end)

local mainGui = Instance.new("ScreenGui")
mainGui.Name = tostring(math.random(100000, 999999))
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = container

local Config = { 
    ESP = false, Highlight = false, NetworkCapture = false, InfiniteFood = false, KillAura = false, KillRange = 50,
    Filters = { ["平民"] = true, ["警察"] = true, ["医生"] = true, ["消防员"] = true, ["厨师"] = true, ["快递员"] = true, ["农夫"] = true, ["囚犯"] = true, ["中转"] = true }
}

local Colors = { Bg = Color3.fromRGB(240, 242, 245), Panel = Color3.fromRGB(255, 255, 255), Sidebar = Color3.fromRGB(235, 237, 240), TextDark = Color3.fromRGB(30, 30, 30), TextLight = Color3.fromRGB(120, 120, 120), AccentBlue = Color3.fromRGB(0, 110, 255), ToggleOff = Color3.fromRGB(200, 200, 200) }

-- ==========================================
-- UI 构建 (补全所有元素)
-- ==========================================
local Main = Instance.new("Frame")
Main.AnchorPoint = Vector2.new(0.5, 0)
Main.Position = UDim2.new(0.5, 0, 0, 10)
Main.Size = UDim2.fromOffset(0, 0) 
Main.BackgroundColor3 = Colors.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Parent = mainGui
local MainCorner = Instance.new("UICorner", Main); MainCorner.CornerRadius = UDim.new(1, 0)

local CapsuleText = Instance.new("TextLabel", Main); CapsuleText.Size = UDim2.new(1, 0, 1, 0); CapsuleText.BackgroundTransparency = 1; CapsuleText.Text = "DeepSeek"; CapsuleText.TextColor3 = Colors.TextDark; CapsuleText.Font = Enum.Font.GothamBold; CapsuleText.TextSize = 13
local CapsuleBtn = Instance.new("TextButton", Main); CapsuleBtn.Size = UDim2.fromScale(1, 1); CapsuleBtn.BackgroundTransparency = 1; CapsuleBtn.Text = ""

local MainContent = Instance.new("Frame", Main); MainContent.Size = UDim2.fromScale(1, 1); MainContent.BackgroundTransparency = 1; MainContent.Visible = false

-- 【补全】标题和关闭按钮
local Title = Instance.new("TextLabel", MainContent); Title.Size = UDim2.fromOffset(200, 30); Title.Position = UDim2.fromOffset(16, 5); Title.BackgroundTransparency = 1; Title.Text = "DeepSeek Studio"; Title.TextColor3 = Colors.TextDark; Title.Font = Enum.Font.GothamBold; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left
local CloseBtn = Instance.new("TextButton", MainContent); CloseBtn.Size = UDim2.fromOffset(32, 32); CloseBtn.Position = UDim2.new(1, -40, 0, 4); CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "×"; CloseBtn.TextColor3 = Colors.TextLight; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 20; CloseBtn.ZIndex = 10

-- 侧边栏
local Sidebar = Instance.new("Frame", MainContent); Sidebar.Size = UDim2.fromOffset(120, 250); Sidebar.Position = UDim2.fromOffset(8, 40); Sidebar.BackgroundColor3 = Colors.Sidebar; Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
local NavContainer = Instance.new("Frame", Sidebar); NavContainer.Size = UDim2.new(1, 0, 1, 0); NavContainer.BackgroundTransparency = 1; Instance.new("UIListLayout", NavContainer).Padding = UDim.new(0, 4)

-- 【补全】左下角用户信息
local UserFrame = Instance.new("Frame", Sidebar); UserFrame.Size = UDim2.new(1, -16, 0, 44); UserFrame.Position = UDim2.new(0, 8, 1, -52); UserFrame.BackgroundColor3 = Colors.Panel; Instance.new("UICorner", UserFrame).CornerRadius = UDim.new(0, 8)
local Avatar = Instance.new("ImageLabel", UserFrame); Avatar.Size = UDim2.fromOffset(30, 30); Avatar.Position = UDim2.fromOffset(7, 7); Avatar.BackgroundColor3 = Colors.Bg; Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
task.spawn(function() local ok, url = pcall(function() return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end) if ok then Avatar.Image = url end end)
local UserName = Instance.new("TextLabel", UserFrame); UserName.Size = UDim2.new(1, -44, 0, 14); UserName.Position = UDim2.fromOffset(44, 7); UserName.BackgroundTransparency = 1; UserName.Text = LP.DisplayName; UserName.TextColor3 = Colors.TextDark; UserName.Font = Enum.Font.GothamBold; UserName.TextSize = 11; UserName.TextXAlignment = Enum.TextXAlignment.Left

-- 内容区
local ContentFrame = Instance.new("Frame", MainContent); ContentFrame.Size = UDim2.new(1, -136, 1, -50); ContentFrame.Position = UDim2.fromOffset(128, 40); ContentFrame.BackgroundTransparency = 1
local Pages, NavButtons = {}, {}
local function CreatePage(name)
    local sf = Instance.new("ScrollingFrame", ContentFrame); sf.Size = UDim2.new(1, 0, 1, 0); sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 3; sf.CanvasSize = UDim2.new(0, 0, 0, 0); sf.AutomaticCanvasSize = Enum.AutomaticSize.Y; sf.Visible = false
    local layout = Instance.new("UIListLayout", sf); layout.Padding = UDim.new(0, 8)
    local padding = Instance.new("UIPadding", sf); padding.PaddingRight = UDim.new(0, 10); padding.PaddingTop = UDim.new(0, 5)
    Pages[name] = sf; return sf
end
local function SwitchPage(name)
    for pName, pFrame in pairs(Pages) do pFrame.Visible = (pName == name) end
    for bName, btn in pairs(NavButtons) do btn.BackgroundColor3 = (bName == name) and Colors.Panel or Colors.Sidebar; btn.TextColor3 = (bName == name) and Colors.AccentBlue or Colors.TextLight end
end
local function CreateNavBtn(name)
    local btn = Instance.new("TextButton", NavContainer); btn.Size = UDim2.new(1, -12, 0, 32); btn.Position = UDim2.fromOffset(6, 8); btn.BackgroundColor3 = Colors.Sidebar; btn.Text = "  " .. name; btn.TextColor3 = Colors.TextLight; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6); btn.MouseButton1Click:Connect(function() SwitchPage(name) end); NavButtons[name] = btn
end
local function AddCard(parent, text, toggleKey)
    local card = Instance.new("Frame", parent); card.Size = UDim2.new(1, -10, 0, 44); card.BackgroundColor3 = Colors.Panel; Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel", card); lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.fromOffset(16, 0); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Colors.TextDark; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local track = Instance.new("Frame", card); track.Size = UDim2.fromOffset(40, 22); track.Position = UDim2.new(1, -56, 0.5, -11); track.BackgroundColor3 = Colors.ToggleOff; Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", track); knob.Size = UDim2.fromOffset(18, 18); knob.Position = UDim2.fromOffset(2, 2); knob.BackgroundColor3 = Colors.Panel; Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local btn = Instance.new("TextButton", card); btn.Size = UDim2.fromScale(1,1); btn.BackgroundTransparency = 1; btn.Text = ""
    local isOn = Config[toggleKey] or false; if isOn then track.BackgroundColor3 = Colors.AccentBlue; knob.Position = UDim2.fromOffset(20, 2) end
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn; Config[toggleKey] = isOn
        TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = isOn and Colors.AccentBlue or Colors.ToggleOff}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = isOn and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)}):Play()
    end)
end
local function AddActionButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -10, 0, 40); btn.BackgroundColor3 = Colors.AccentBlue; btn.Text = text; btn.TextColor3 = Colors.Panel; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); btn.MouseButton1Click:Connect(callback)
end

CreateNavBtn("视觉"); local page_Visual = CreatePage("视觉"); AddCard(page_Visual, "玩家透视", "ESP"); AddCard(page_Visual, "人物高亮", "Highlight")
CreateNavBtn("战斗"); local page_Combat = CreatePage("战斗"); AddCard(page_Combat, "无限状态", "InfiniteFood"); AddCard(page_Combat, "拔出枪即范围杀戮", "KillAura")
CreateNavBtn("抓包"); local page_Capture = CreatePage("抓包"); AddCard(page_Capture, "开启网络抓包", "NetworkCapture"); AddActionButton(page_Capture, "查看深度抓包日志", function() if _G.CaptureLogUI then _G.CaptureLogUI() end end)
SwitchPage("视觉")

local isOpen, isAnimating = false, false
local function ToggleUI(openState)
    if isAnimating then return end; isAnimating = true; isOpen = openState
    if isOpen then MainContent.Visible = true; CapsuleText.Visible = false; CapsuleBtn.Visible = false; TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(480, 320), Position = UDim2.new(0.5, 0, 0, 40)}):Play(); TweenService:Create(MainCorner, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CornerRadius = UDim.new(0, 12)}):Play(); task.wait(0.4)
    else MainContent.Visible = false; TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.fromOffset(110, 32), Position = UDim2.new(0.5, 0, 0, 10)}):Play(); TweenService:Create(MainCorner, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {CornerRadius = UDim.new(1, 0)}):Play(); task.wait(0.3); CapsuleText.Visible = true; CapsuleBtn.Visible = true end
    isAnimating = false
end
CapsuleBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)

-- ==========================================
-- 日志系统
-- ==========================================
local captureLogs = {}
local logWindow, logText, logScroll = nil, nil, nil
_G.CaptureLogUI = function()
    if logWindow and logWindow.Parent then logWindow:Destroy(); return end
    logWindow = Instance.new("Frame", mainGui); logWindow.Size = UDim2.fromOffset(400, 250); logWindow.Position = UDim2.new(0.5, 0, 0.5, 0); logWindow.AnchorPoint = Vector2.new(0.5, 0.5); logWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 25); logWindow.ZIndex = 50; Instance.new("UICorner", logWindow).CornerRadius = UDim.new(0, 12)
    local topBar = Instance.new("Frame", logWindow); topBar.Size = UDim2.new(1, 0, 0, 35); topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)
    local title = Instance.new("TextLabel", topBar); title.Size = UDim2.new(1, -80, 1, 0); title.Position = UDim2.fromOffset(12, 0); title.BackgroundTransparency = 1; title.Text = "深度抓包日志"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left
    local clearBtn = Instance.new("TextButton", topBar); clearBtn.Size = UDim2.fromOffset(40, 24); clearBtn.Position = UDim2.new(1, -75, 0, 5); clearBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); clearBtn.Text = "清理"; clearBtn.TextColor3 = Color3.new(1,1,1); clearBtn.Font = Enum.Font.GothamBold; clearBtn.TextSize = 11; Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
    clearBtn.MouseButton1Click:Connect(function() captureLogs = {}; if logText then logText.Text = "" end end)
    local closeBtn = Instance.new("TextButton", topBar); closeBtn.Size = UDim2.fromOffset(30, 30); closeBtn.Position = UDim2.new(1, -35, 0, 2); closeBtn.BackgroundTransparency = 1; closeBtn.Text = "×"; closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 20; closeBtn.MouseButton1Click:Connect(function() logWindow:Destroy(); logWindow = nil; logText = nil end)
    logScroll = Instance.new("ScrollingFrame", logWindow); logScroll.Size = UDim2.new(1, -16, 1, -50); logScroll.Position = UDim2.fromOffset(8, 42); logScroll.BackgroundTransparency = 1; logScroll.BorderSizePixel = 0; logScroll.ScrollBarThickness = 3; logScroll.CanvasSize = UDim2.new(0, 0, 0, 0); logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    logText = Instance.new("TextLabel", logScroll); logText.Size = UDim2.new(1, -10, 0, 0); logText.AutomaticSize = Enum.AutomaticSize.Y; logText.BackgroundTransparency = 1; logText.Text = table.concat(captureLogs, "\n"); logText.TextColor3 = Color3.fromRGB(0, 255, 150); logText.Font = Enum.Font.Code; logText.TextSize = 11; logText.TextXAlignment = Enum.TextXAlignment.Left; logText.TextYAlignment = Enum.TextYAlignment.Top; logText.TextWrapped = true
end

-- ==========================================
-- 无限状态本地锁 (双保险)
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if Config.InfiniteFood then
            pcall(function()
                local p = LP
                local char = p.Character
                local keys = {"Stamina", "Energy", "Endurance", "Hunger", "Food", "stamina", "food"}
                for _, k in ipairs(keys) do
                    if type(p:GetAttribute(k)) == "number" then p:SetAttribute(k, 100) end
                    if char and type(char:GetAttribute(k)) == "number" then char:SetAttribute(k, 100) end
                end
                if char then
                    for _, v in ipairs(char:GetDescendants()) do
                        if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find("stamina") or v.Name:lower():find("food")) then
                            v.Value = 100
                        end
                    end
                end
            end)
        end
    end
end)

-- ==========================================
-- 真实伪造包杀戮 & 状态拦截
-- ==========================================
local lastKillTime = 0
local PE = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 5) and game:GetService("ReplicatedStorage").Remote:FindFirstChild("PlayerEvent") or nil

-- 主动伪造发包逻辑
local function ExecuteKillAura()
    if not Config.KillAura or not PE then return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tool = myChar and myChar:FindFirstChildOfClass("Tool")
    if not myHRP or not tool then return end
    
    local now = tick()
    if now - lastKillTime < 0.2 then return end
    lastKillTime = now
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tgtHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            local tgtHead = plr.Character:FindFirstChild("Head")
            local tgtHum = plr.Character:FindFirstChildOfClass("Humanoid")
            
            if tgtHRP and tgtHead and tgtHum and tgtHum.Health > 0 then
                local dist = (myHRP.Position - tgtHRP.Position).Magnitude
                if dist <= (Config.KillRange * 3) then
                    -- 构造伪造的 bullet 包
                    local fakeBullet = {
                        weaponName = tool.Name,
                        posDestroyX = math.random(3000, 3500),
                        pos = tgtHead.Position
                    }
                    pcall(function()
                        PE:FireServer("bullet", fakeBullet)
                    end)
                end
            end
        end
    end
end

-- 循环执行杀戮
task.spawn(function()
    while task.wait(0.2) do
        pcall(ExecuteKillAura)
    end
end)

-- Hook 拦截状态包和你的原本开枪包
local hasHooked = false
local function SetupHook()
    if hasHooked or not hookmetamethod then return end
    hasHooked = true
    local oldNamecall
    
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if not checkcaller() and method == "FireServer" and self.Name == "PlayerEvent" then
            local args = {...}
            local action = args[1]
            
            -- 1. 拦截状态
            if Config.InfiniteFood and action == "setStaminaOrFood" then
                if args[2] == "stamina" or args[2] == "food" then
                    args[3] = 100
                end
                return oldNamecall(self, unpack(args))
            end
            
            -- 2. 拦截你的子弹包改方向
            if Config.KillAura and action == "bullet" then
                local bulletData = args[2]
                if type(bulletData) == "table" and bulletData.pos then
                    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        local targetsHit = false
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LP and plr.Character then
                                local tgtHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                                local tgtHead = plr.Character:FindFirstChild("Head")
                                local tgtHum = plr.Character:FindFirstChildOfClass("Humanoid")
                                if tgtHRP and tgtHead and tgtHum and tgtHum.Health > 0 then
                                    local dist = (myHRP.Position - tgtHRP.Position).Magnitude
                                    if dist <= (Config.KillRange * 3) then
                                        targetsHit = true
                                        local newData = {}
                                        for k, v in pairs(bulletData) do newData[k] = v end
                                        newData.pos = tgtHead.Position
                                        task.spawn(function() pcall(function() self:FireServer("bullet", newData) end) end)
                                        task.wait(0.01)
                                    end
                                end
                            end
                        end
                        if targetsHit then return end
                    end
                end
            end
            
            -- 3. 抓包
            if Config.NetworkCapture then
                if action ~= "charRot" and action ~= "humFloor" and action ~= "humState" then
                    task.spawn(function()
                        pcall(function()
                            local argStr = ""
                            for i = 1, math.min(#args, 4) do 
                                local v = args[i]
                                if typeof(v) == "Instance" then argStr = argStr .. v.Name .. ", "
                                elseif typeof(v) == "Vector3" then argStr = argStr .. string.format("V3(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z) .. ", "
                                elseif typeof(v) == "table" then argStr = argStr .. "table, "
                                elseif typeof(v) == "string" then argStr = argStr .. '"' .. v .. '", '
                                else argStr = argStr .. tostring(v) .. ", " end
                            end
                            local logLine = "[" .. self.Name .. "] " .. argStr
                            table.insert(captureLogs, 1, logLine)
                            if #captureLogs > 30 then table.remove(captureLogs) end
                            if logText and logWindow and logWindow.Parent then logText.Text = table.concat(captureLogs, "\n") end
                        end)
                    end)
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
end
SetupHook()

-- ==========================================
-- 启动动画与透视
-- ==========================================
local function PlayIntroAnimation()
    local particles = {}
    for i = 1, 70 do
        local dot = Instance.new("Frame", mainGui); dot.BackgroundColor3 = Color3.new(1, 1, 1); dot.BorderSizePixel = 0; dot.ZIndex = 100
        local size = math.random(2, 5); dot.Size = UDim2.fromOffset(size, size); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local edge = math.random(1, 3); local startX, startY
        if edge == 1 then startX = 0; startY = math.random(0, 100) / 100 elseif edge == 2 then startX = 1; startY = math.random(0, 100) / 100 else startX = math.random(0, 100) / 100; startY = 1 end
        dot.Position = UDim2.new(startX, 0, startY, 0)
        table.insert(particles, dot)
        task.delay(math.random(0, 30) / 100, function() if dot and dot.Parent then TweenService:Create(dot, TweenInfo.new(math.random(30, 60) / 100, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0.05, 0), BackgroundTransparency = 1}):Play() end end)
    end
    task.delay(1.0, function()
        for _, dot in ipairs(particles) do if dot then dot:Destroy() end end
        Main.Visible = true; TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(110, 32)}):Play()
    end)
end
PlayIntroAnimation()

local RoleDict = {
    ["Civilian"] = "平民", ["Police"] = "警察", ["Medical"] = "医生", ["Chef"] = "厨师", ["Delivery"] = "快递员", ["Farmer"] = "农夫",
    ["Fire"] = "消防员", ["Prisoner"] = "囚犯", ["Road Service"] = "中转", ["Transit"] = "中转", ["Neutral"] = "中转", ["???"] = "中转"
}

local function getRoleName(plr)
    local rawRole = nil
    local roleAttr = plr:GetAttribute("Role") or plr:GetAttribute("RoleId")
    if roleAttr then rawRole = tostring(roleAttr) end
    if not rawRole and plr.Team and plr.Team.Name ~= "" then rawRole = plr.Team.Name end
    if rawRole then
        if RoleDict[rawRole] then return RoleDict[rawRole] end
        local lr = rawRole:lower()
        if lr:find("police") then return "警察"
        elseif lr:find("civilian") then return "平民"
        elseif lr:find("medical") or lr:find("doctor") then return "医生"
        elseif lr:find("fire") then return "消防员"
        end
        return "中转"
    end
    return "平民"
end

local function getRoleColor(roleName)
    if roleName == "警察" then return Color3.fromRGB(0, 85, 255)
    elseif roleName == "医生" then return Color3.fromRGB(255, 30, 30)
    elseif roleName == "消防员" then return Color3.fromRGB(255, 140, 0)
    elseif roleName == "平民" then return Color3.fromRGB(255, 255, 255)
    elseif roleName == "农夫" then return Color3.fromRGB(60, 255, 60)
    elseif roleName == "囚犯" then return Color3.fromRGB(255, 100, 0)
    elseif roleName == "中转" then return Color3.fromRGB(150, 150, 150)
    end
    return Color3.fromRGB(200, 200, 200)
end

local HIGHLIGHT_POOL_SIZE = 20
local highlightPool = {}
local hlFolder = Instance.new("Folder")
hlFolder.Name = tostring(math.random(10000, 99999))
pcall(function() hlFolder.Parent = container end)
if not hlFolder.Parent then hlFolder.Parent = workspace end

for i = 1, HIGHLIGHT_POOL_SIZE do
    local hl = Instance.new("Highlight")
    hl.Name = tostring(math.random(10000, 99999))
    hl.DepthMode = Enum.HighlightDepthMode.Occluded
    hl.OutlineTransparency = 1
    hl.FillTransparency = 0.5
    hl.Adornee = nil
    hl.Parent = hlFolder
    table.insert(highlightPool, hl)
end

local espCache = {}
local function initPlayer(plr)
    if plr == LP or espCache[plr] then return end
    local box = Instance.new("Frame"); box.BackgroundTransparency = 1; box.BorderSizePixel = 1; box.BorderColor3 = Color3.fromRGB(0, 255, 100); box.Visible = false; box.Parent = mainGui
    local nameTxt = Instance.new("TextLabel"); nameTxt.BackgroundTransparency = 1; nameTxt.TextColor3 = Color3.new(1, 1, 1); nameTxt.TextStrokeTransparency = 0; nameTxt.Font = Enum.Font.SourceSansBold; nameTxt.TextSize = 14; nameTxt.Visible = false; nameTxt.Parent = mainGui
    local distTxt = Instance.new("TextLabel"); distTxt.BackgroundTransparency = 1; distTxt.TextColor3 = Color3.fromRGB(200, 200, 200); distTxt.TextStrokeTransparency = 0; distTxt.Font = Enum.Font.SourceSansBold; distTxt.TextSize = 12; distTxt.Visible = false; distTxt.Parent = mainGui
    espCache[plr] = { box = box, nameTxt = nameTxt, distTxt = distTxt }
end
for _, p in ipairs(Players:GetPlayers()) do initPlayer(p) end
Players.PlayerAdded:Connect(initPlayer)
Players.PlayerRemoving:Connect(function(plr) 
    if espCache[plr] then 
        espCache[plr].box:Destroy(); espCache[plr].nameTxt:Destroy(); espCache[plr].distTxt:Destroy(); espCache[plr] = nil 
    end 
end)

task.spawn(function()
    while task.wait(0.02) do 
        if Config.Highlight then
            local validTargets = {}
            for plr, _ in pairs(espCache) do
                if plr.Character and plr.Character:IsDescendantOf(workspace) then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 and not hum.Sit then
                        local rName = getRoleName(plr)
                        if Config.Filters[rName] then
                            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                            table.insert(validTargets, {plr = plr, dist = dist})
                        end
                    end
                end
            end
            table.sort(validTargets, function(a, b) return a.dist < b.dist end)
            for i = 1, HIGHLIGHT_POOL_SIZE do
                local hl = highlightPool[i]
                local target = validTargets[i]
                if target and i <= 15 then 
                    hl.Adornee = target.plr.Character
                    hl.FillColor = getRoleColor(getRoleName(target.plr))
                else
                    hl.Adornee = nil
                end
            end
        else
            for i = 1, HIGHLIGHT_POOL_SIZE do highlightPool[i].Adornee = nil end
        end
        
        if not Config.ESP then
            for _, d in pairs(espCache) do d.box.Visible = false; d.nameTxt.Visible = false; d.distTxt.Visible = false end
        else
            for plr, data in pairs(espCache) do
                pcall(function()
                    if not plr.Character or not plr.Character:IsDescendantOf(workspace) then
                        data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                        return
                    end
                    
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    local head = plr.Character:FindFirstChild("Head")
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    
                    if not hrp or not head or not hum or hum.Health <= 0 or hum.Sit then
                        data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                        return
                    end
                    
                    local rName = getRoleName(plr)
                    if Config.Filters[rName] then
                        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen and headPos.Z > 0 then
                            local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude / 3)
                            data.box.Visible = true; data.box.Size = UDim2.fromOffset(40, 60); data.box.Position = UDim2.fromOffset(headPos.X - 20, headPos.Y + 10)
                            data.nameTxt.Visible = true; data.nameTxt.Text = "[" .. rName .. "] " .. plr.Name; data.nameTxt.TextColor3 = getRoleColor(rName); data.nameTxt.Position = UDim2.fromOffset(headPos.X, headPos.Y - 10)
                            data.distTxt.Visible = true; data.distTxt.Text = tostring(distance) .. "m"; data.distTxt.Position = UDim2.fromOffset(headPos.X, headPos.Y + 75)
                        else
                            data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                        end
                    else
                        data.box.Visible = false; data.nameTxt.Visible = false; data.distTxt.Visible = false
                    end
                end)
            end
        end
    end
end)

print("[DeepSeek] 伪造杀戮+UI补全版加载完毕")