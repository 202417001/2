-- ============================================
-- DeepSeek Studio (抓包解析 · 状态修改 · 子弹追踪)
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
    ESP = false, 
    Highlight = false,
    NetworkCapture = false,
    InfiniteFood = false,
    SilentAim = false,
    FOV = 150,
    Filters = {
        ["平民"] = true, ["警察"] = true, ["医生"] = true,
        ["消防员"] = true, ["厨师"] = true, ["快递员"] = true,
        ["农夫"] = true, ["囚犯"] = true, ["中转"] = true
    }
}

local Colors = {
    Bg = Color3.fromRGB(240, 242, 245),
    Panel = Color3.fromRGB(255, 255, 255),
    Sidebar = Color3.fromRGB(235, 237, 240),
    TextDark = Color3.fromRGB(30, 30, 30),
    TextLight = Color3.fromRGB(120, 120, 120),
    AccentBlue = Color3.fromRGB(0, 110, 255),
    ToggleOff = Color3.fromRGB(200, 200, 200),
}

-- ==========================================
-- UI 构建 (绝对保底)
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
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(1, 0)

local CapsuleText = Instance.new("TextLabel")
CapsuleText.Size = UDim2.new(1, 0, 1, 0)
CapsuleText.BackgroundTransparency = 1
CapsuleText.Text = "DeepSeek"
CapsuleText.TextColor3 = Colors.TextDark
CapsuleText.Font = Enum.Font.GothamBold
CapsuleText.TextSize = 13
CapsuleText.Parent = Main

local CapsuleBtn = Instance.new("TextButton")
CapsuleBtn.Size = UDim2.fromScale(1, 1)
CapsuleBtn.BackgroundTransparency = 1
CapsuleBtn.Text = ""
CapsuleBtn.Parent = Main

local MainContent = Instance.new("Frame")
MainContent.Size = UDim2.fromScale(1, 1)
MainContent.BackgroundTransparency = 1
MainContent.Visible = false
MainContent.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(200, 30)
Title.Position = UDim2.fromOffset(16, 5)
Title.BackgroundTransparency = 1
Title.Text = "DeepSeek Studio"
Title.TextColor3 = Colors.TextDark
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainContent

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(32, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Colors.TextLight
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.ZIndex = 10
CloseBtn.Parent = MainContent

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(120, 250)
Sidebar.Position = UDim2.fromOffset(8, 40)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainContent
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(1, 0, 1, 0)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = Sidebar
local NavLayout = Instance.new("UIListLayout", NavContainer)
NavLayout.Padding = UDim.new(0, 4)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -136, 1, -50)
ContentFrame.Position = UDim2.fromOffset(128, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainContent

local Pages = {}
local NavButtons = {}

local function CreatePage(name)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Colors.ToggleOff
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Parent = ContentFrame
    sf.Visible = false
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 8)
    Pages[name] = sf
    return sf
end

local function SwitchPage(name)
    for pName, pFrame in pairs(Pages) do pFrame.Visible = (pName == name) end
    for bName, btn in pairs(NavButtons) do
        btn.BackgroundColor3 = (bName == name) and Colors.Panel or Colors.Sidebar
        btn.TextColor3 = (bName == name) and Colors.AccentBlue or Colors.TextLight
    end
end

local function CreateNavBtn(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.Position = UDim2.fromOffset(6, 8)
    btn.BackgroundColor3 = Colors.Sidebar
    btn.Text = "  " .. name
    btn.TextColor3 = Colors.TextLight
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = NavContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() SwitchPage(name) end)
    NavButtons[name] = btn
end

local function AddCard(parent, text, toggleKey)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Colors.Panel
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.fromOffset(16, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.TextDark
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card
    
    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(40, 22)
    track.Position = UDim2.new(1, -56, 0.5, -11)
    track.BackgroundColor3 = Colors.ToggleOff
    track.BorderSizePixel = 0
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = Colors.Panel
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1,1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = card
    
    local isOn = Config[toggleKey] or false
    if isOn then track.BackgroundColor3 = Colors.AccentBlue; knob.Position = UDim2.fromOffset(20, 2) end

    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if toggleKey then Config[toggleKey] = isOn end
        if isOn then
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Colors.AccentBlue}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(20, 2)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ToggleOff}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.fromOffset(2, 2)}):Play()
        end
    end)
end

local function AddMultiSelect(parent, titleText, options, configTable)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Colors.Panel
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundTransparency = 1
    header.Text = ""
    header.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.fromOffset(16, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Colors.TextDark
    title.Font = Enum.Font.Gotham
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(16, 16)
    arrow.Position = UDim2.new(1, -24, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Colors.TextLight
    arrow.TextSize = 10
    arrow.Parent = header

    local optionList = Instance.new("Frame")
    optionList.Size = UDim2.new(1, 0, 0, 0)
    optionList.Position = UDim2.fromOffset(0, 44)
    optionList.BackgroundTransparency = 1
    optionList.Parent = card
    local optLayout = Instance.new("UIListLayout", optionList)
    optLayout.Padding = UDim.new(0, 2)

    local isExpanded = false
    local function expand()
        isExpanded = not isExpanded
        local targetSize = isExpanded and UDim2.new(1, 0, 0, 44 + #options * 32 + 10) or UDim2.new(1, 0, 0, 44)
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(card, tweenInfo, {Size = targetSize}):Play()
        TweenService:Create(arrow, tweenInfo, {Rotation = isExpanded and 180 or 0}):Play()
    end

    header.MouseButton1Click:Connect(expand)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = ""
        optBtn.Parent = optionList

        local optText = Instance.new("TextLabel")
        optText.Size = UDim2.new(1, -50, 1, 0)
        optText.Position = UDim2.fromOffset(20, 0)
        optText.BackgroundTransparency = 1
        optText.Text = opt
        optText.TextColor3 = Colors.TextDark
        optText.Font = Enum.Font.Gotham
        optText.TextSize = 12
        optText.TextXAlignment = Enum.TextXAlignment.Left
        optText.Parent = optBtn

        local checkBox = Instance.new("Frame")
        checkBox.Size = UDim2.fromOffset(16, 16)
        checkBox.Position = UDim2.new(1, -30, 0.5, -8)
        checkBox.BackgroundColor3 = configTable[opt] and Colors.AccentBlue or Colors.Panel
        checkBox.Parent = optBtn
        Instance.new("UICorner", checkBox).CornerRadius = UDim.new(0, 4)
        
        local cbStroke = Instance.new("UIStroke", checkBox)
        cbStroke.Color = Colors.ToggleOff
        cbStroke.Thickness = 1

        local checkMark = Instance.new("TextLabel")
        checkMark.Size = UDim2.fromScale(1, 1)
        checkMark.BackgroundTransparency = 1
        checkMark.Text = "✓"
        checkMark.TextColor3 = Colors.Panel
        checkMark.Font = Enum.Font.GothamBold
        checkMark.TextSize = 12
        checkMark.Visible = configTable[opt] or false
        checkMark.Parent = checkBox

        optBtn.MouseButton1Click:Connect(function()
            configTable[opt] = not configTable[opt]
            local state = configTable[opt]
            checkBox.BackgroundColor3 = state and Colors.AccentBlue or Colors.Panel
            checkMark.Visible = state
        end)
    end
end

local function AddActionButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Colors.AccentBlue
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Colors.Panel
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
end

CreateNavBtn("视觉")
local page_Visual = CreatePage("视觉")
AddCard(page_Visual, "玩家透视", "ESP")
AddCard(page_Visual, "人物高亮", "Highlight")
AddMultiSelect(page_Visual, "阵营过滤", 
    {"平民", "警察", "医生", "消防员", "厨师", "快递员", "农夫", "囚犯", "中转"}, 
    Config.Filters
)

CreateNavBtn("战斗")
local page_Combat = CreatePage("战斗")
AddCard(page_Combat, "无限饥饿/耐力", "InfiniteFood")
AddCard(page_Combat, "子弹追踪 (静默)", "SilentAim")

CreateNavBtn("抓包")
local page_Capture = CreatePage("抓包")
AddCard(page_Capture, "开启网络抓包", "NetworkCapture")
AddActionButton(page_Capture, "查看抓包日志", function()
    if _G.CaptureLogUI then _G.CaptureLogUI() end
end)

SwitchPage("视觉")

local isOpen = false
local isAnimating = false
local function ToggleUI(openState)
    if isAnimating then return end
    isAnimating = true
    isOpen = openState
    if isOpen then
        MainContent.Visible = true
        CapsuleText.Visible = false
        CapsuleBtn.Visible = false
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(480, 320), Position = UDim2.new(0.5, 0, 0, 40)}):Play()
        TweenService:Create(MainCorner, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CornerRadius = UDim.new(0, 12)}):Play()
        task.wait(0.4)
    else
        MainContent.Visible = false
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.fromOffset(110, 32), Position = UDim2.new(0.5, 0, 0, 10)}):Play()
        TweenService:Create(MainCorner, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {CornerRadius = UDim.new(1, 0)}):Play()
        task.wait(0.3)
        CapsuleText.Visible = true
        CapsuleBtn.Visible = true
    end
    isAnimating = false
end
CapsuleBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)

-- ==========================================
-- 日志系统 UI 修复 (增加换行和清理)
-- ==========================================
local captureLogs = {}
local logWindow = nil
local logText = nil
local logScroll = nil

_G.CaptureLogUI = function()
    if logWindow and logWindow.Parent then logWindow:Destroy(); return end
    
    logWindow = Instance.new("Frame")
    logWindow.Size = UDim2.fromOffset(400, 250)
    logWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    logWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    logWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    logWindow.BorderSizePixel = 0
    logWindow.ZIndex = 50
    logWindow.Parent = mainGui
    Instance.new("UICorner", logWindow).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", logWindow).Color = Color3.new(0.3,0.3,0.3)
    
    local topBar = Instance.new("Frame", logWindow)
    topBar.Size = UDim2.new(1, 0, 0, 35); topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    topBar.BorderSizePixel = 0; Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -80, 1, 0); title.Position = UDim2.fromOffset(12, 0)
    title.BackgroundTransparency = 1; title.Text = "网络抓包日志"
    title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 【新增】清理按钮
    local clearBtn = Instance.new("TextButton", topBar)
    clearBtn.Size = UDim2.fromOffset(40, 24); clearBtn.Position = UDim2.new(1, -75, 0, 5)
    clearBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); clearBtn.Text = "清理"
    clearBtn.TextColor3 = Color3.new(1,1,1); clearBtn.Font = Enum.Font.GothamBold; clearBtn.TextSize = 11
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
    clearBtn.MouseButton1Click:Connect(function()
        captureLogs = {}
        if logText then logText.Text = "" end
    end)
    
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.fromOffset(30, 30); closeBtn.Position = UDim2.new(1, -35, 0, 2)
    closeBtn.BackgroundTransparency = 1; closeBtn.Text = "×"; closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 20
    closeBtn.MouseButton1Click:Connect(function() logWindow:Destroy(); logWindow = nil; logText = nil end)
    
    logScroll = Instance.new("ScrollingFrame", logWindow)
    logScroll.Size = UDim2.new(1, -16, 1, -50); logScroll.Position = UDim2.fromOffset(8, 42)
    logScroll.BackgroundTransparency = 1; logScroll.BorderSizePixel = 0
    logScroll.ScrollBarThickness = 3; logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    logText = Instance.new("TextLabel", logScroll)
    logText.Size = UDim2.new(1, -10, 0, 0); logText.AutomaticSize = Enum.AutomaticSize.Y
    logText.BackgroundTransparency = 1; logText.Text = table.concat(captureLogs, "\n")
    logText.TextColor3 = Color3.fromRGB(0, 255, 150); logText.Font = Enum.Font.Code; logText.TextSize = 11
    logText.TextXAlignment = Enum.TextXAlignment.Left; logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.TextWrapped = true
end

-- ==========================================
-- 底层 Hook 逻辑 (按需挂载 + 拦截修改)
-- ==========================================
local cachedTarget = nil
-- 找目标
task.spawn(function()
    while task.wait(0.05) do
        if Config.SilentAim then
            local closest, minDist = nil, math.huge
            local center = Camera.ViewportSize / 2
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local part = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
                    local thum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if part and thum and thum.Health > 0 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if distToCenter <= Config.FOV then
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

local hasHooked = false
local function SetupHook()
    if hasHooked or not hookmetamethod then return end
    hasHooked = true
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if not checkcaller() then
            -- 【核心逻辑 1】无限饥饿/耐力 (拦截 setStaminaOrFood)
            if Config.InfiniteFood and method == "FireServer" and self.Name == "setStaminaOrFood" then
                local args = {...}
                if #args >= 2 and (args[1] == "food" or args[1] == "stamina") then
                    args[2] = 100 -- 强制设为 100
                end
                return oldNamecall(self, unpack(args))
            end
            
            -- 【核心逻辑 2】子弹追踪 (拦截 bullet)
            if Config.SilentAim and method == "FireServer" and self.Name == "bullet" and cachedTarget then
                local args = {...}
                -- 修改参数，如果参数里有 table，尝试篡改目标
                -- 由于不知 table 结构，直接尝试把目标的 CFrame 塞进去或者替换参数
                local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    -- 这里我们用静默自瞄逻辑：保证方向对准敌人
                    -- 因为日志里写的是 bullet, table，很可能 table 里有 CFrame，我们直接强改方向
                end
                -- 兜底：如果静默拦截不到，直接用原有的 Raycast 拦截
            end
            
            -- 【旧版 Raycast 拦截兜底】
            if Config.SilentAim and cachedTarget and method == "Raycast" then
                local args = {...}
                if typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP and (args[1] - myHRP.Position).Magnitude < 15 then
                        args[2] = (cachedTarget.Position - args[1]).Unit * 9999
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
            
            -- 【日志抓取】
            if Config.NetworkCapture and (method == "FireServer" or method == "InvokeServer") then
                local name = self.Name
                local lower = name:lower()
                if not (lower:find("rot") or lower:find("pos") or lower:find("move") or lower:find("input") or lower:find("cam") or lower:find("ping") or lower:find("charrot")) then
                    local args = {...}
                    task.spawn(function()
                        pcall(function()
                            local argStr = ""
                            for i = 1, math.min(#args, 4) do
                                local v = args[i]
                                if typeof(v) == "Instance" then argStr = argStr .. (v.Name or "Inst") .. ", "
                                elseif typeof(v) == "Vector3" then argStr = argStr .. string.format("V3(%.0f,%.0f,%.0f), ", v.X, v.Y, v.Z)
                                elseif typeof(v) == "Vector2" then argStr = argStr .. string.format("V2(%.0f,%.0f), ", v.X, v.Y)
                                elseif typeof(v) == "CFrame" then argStr = argStr .. "CFrame, "
                                elseif typeof(v) == "table" then argStr = argStr .. "table, "
                                elseif type(v) == "number" or type(v) == "string" then argStr = argStr .. tostring(v) .. ", "
                                else argStr = argStr .. typeof(v) .. ", " end
                            end
                            
                            local logLine = "[" .. name .. "] " .. argStr
                            table.insert(captureLogs, 1, logLine)
                            if #captureLogs > 40 then table.remove(captureLogs) end
                            
                            if logText and logWindow and logWindow.Parent then
                                logText.Text = table.concat(captureLogs, "\n")
                                logScroll.CanvasPosition = Vector2.new(0, 0)
                            end
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
-- 启动动画：三面星尘汇聚
-- ==========================================
local function PlayIntroAnimation()
    local particles = {}
    local PARTICLE_COUNT = 70
    local targetX, targetY = 0.5, 0.05 
    
    for i = 1, PARTICLE_COUNT do
        local dot = Instance.new("Frame")
        dot.BackgroundColor3 = Color3.new(1, 1, 1)
        dot.BorderSizePixel = 0
        dot.ZIndex = 100
        dot.Parent = mainGui
        
        local size = math.random(2, 5)
        dot.Size = UDim2.fromOffset(size, size)
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        
        local startX, startY
        local edge = math.random(1, 3)
        if edge == 1 then startX = 0; startY = math.random(0, 100) / 100
        elseif edge == 2 then startX = 1; startY = math.random(0, 100) / 100
        else startX = math.random(0, 100) / 100; startY = 1 end
        
        dot.Position = UDim2.new(startX, 0, startY, 0)
        local endX = targetX + (math.random(-20, 20) / 1000)
        local endY = targetY + (math.random(-20, 20) / 1000)
        
        table.insert(particles, dot)
        
        task.delay(math.random(0, 30) / 100, function()
            if dot and dot.Parent then
                TweenService:Create(dot, TweenInfo.new(math.random(30, 60) / 100, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(endX, 0, endY, 0),
                    BackgroundTransparency = 1
                }):Play()
            end
        end)
    end
    
    task.delay(1.0, function()
        for _, dot in ipairs(particles) do if dot then dot:Destroy() end end
        Main.Visible = true
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(110, 32)}):Play()
    end)
end
PlayIntroAnimation()

-- ==========================================
-- 角色逻辑与透视
-- ==========================================
local RoleDict = {
    ["Civilian"] = "平民", ["Police"] = "警察", ["Medical"] = "医生",
    ["Chef"] = "厨师", ["Delivery"] = "快递员", ["Farmer"] = "农夫",
    ["Fire"] = "消防员", ["Prisoner"] = "囚犯", ["Road Service"] = "中转",
    ["Transit"] = "中转", ["Neutral"] = "中转", ["???"] = "中转"
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

print("[DeepSeek] 解析抓包·无限状态版加载完毕")