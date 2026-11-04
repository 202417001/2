-- ============================================
-- Ninja Panel (深度混淆 · 彻底修复显示与距离)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 变量名深度混淆
local _Z1 = { _V1 = false, _V2 = false, _V3 = false, _V4 = false, _V5 = 30, _V6 = 1.0, _V7 = 3 }
local _Z2 = { ["Chef"]="厨师",["Civilian"]="平民",["Delivery"]="快递员",["Farmer"]="农夫",["Fire"]="消防员",["Medical"]="医生",["Police"]="警察",["Prisoner"]="囚犯",["Road Service"]="路政",["Transit"]="公交司机" }

local function _F_Gui(name)
    local g = Instance.new("ScreenGui"); g.Name = name; g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    if syn and syn.protect_gui then syn.protect_gui(g); g.Parent = game:GetService("CoreGui")
    elseif gethui then g.Parent = gethui() else g.Parent = LP:WaitForChild("PlayerGui") end
    return g
end

local _G1 = _F_Gui(tostring(math.random(10000,99999)))
local _G2 = _F_Gui(tostring(math.random(10000,99999)))

-- ==========================================
-- 主面板
-- ==========================================
local _M = Instance.new("Frame")
_M.Size = UDim2.fromOffset(320, 260); _M.Position = UDim2.fromScale(0.1, 0.2)
_M.BackgroundColor3 = Color3.fromRGB(25, 25, 30); _M.BackgroundTransparency = 0.1 
_M.BorderSizePixel = 0; _M.Active = true; _M.Draggable = true; _M.Parent = _G1
Instance.new("UICorner", _M).CornerRadius = UDim.new(0, 8)
local _S = Instance.new("UIStroke", _M); _S.Color = Color3.fromRGB(60, 60, 70); _S.Thickness = 1

local _Icon = Instance.new("TextButton"); _Icon.Size = UDim2.fromOffset(40, 40); _Icon.Position = UDim2.fromOffset(12, 240)
_Icon.BackgroundColor3 = Color3.fromRGB(30, 30, 35); _Icon.Text = "N"; _Icon.TextColor3 = Color3.new(1, 1, 1); _Icon.Font = Enum.Font.GothamBold; _Icon.TextSize = 18
_Icon.Visible = false; _Icon.Active = true; _Icon.Draggable = true; _Icon.Parent = _G1; Instance.new("UICorner", _Icon).CornerRadius = UDim.new(1, 0)
_Icon.MouseButton1Click:Connect(function() _M.Visible = true; _Icon.Visible = false end)
local function _Min() _M.Visible = false; _Icon.Visible = true end

local _Title = Instance.new("TextLabel"); _Title.Size = UDim2.new(1, 0, 0, 36); _Title.BackgroundTransparency = 1
_Title.Text = "Ninja"; _Title.TextColor3 = Color3.new(1, 1, 1); _Title.Font = Enum.Font.GothamBold; _Title.TextSize = 15; _Title.Parent = _M
local _Line = Instance.new("Frame"); _Line.Size = UDim2.new(1, 0, 0, 1); _Line.Position = UDim2.fromOffset(0, 36)
_Line.BackgroundColor3 = Color3.fromRGB(50, 50, 60); _Line.BorderSizePixel = 0; _Line.Parent = _M

local function _T_Btn(text, xoff, cb)
    local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(24, 24); b.Position = UDim2.new(1, xoff, 0, 6)
    b.BackgroundTransparency = 1; b.Text = text; b.TextColor3 = Color3.fromRGB(200, 200, 200); b.Font = Enum.Font.GothamBold; b.TextSize = 18; b.Parent = _M
    b.MouseButton1Click:Connect(cb); return b
end
_T_Btn("×", -25, _Min)

local _Nav = Instance.new("Frame"); _Nav.Size = UDim2.new(0, 70, 1, -37); _Nav.Position = UDim2.fromOffset(0, 37)
_Nav.BackgroundColor3 = Color3.fromRGB(20, 20, 25); _Nav.BackgroundTransparency = 0.3; _Nav.BorderSizePixel = 0; _Nav.Parent = _M
local _NavL = Instance.new("UIListLayout", _Nav); _NavL.Padding = UDim.new(0, 4); _NavL.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", _Nav).PaddingTop = UDim.new(0, 8)

local _Content = Instance.new("Frame"); _Content.Size = UDim2.new(1, -70, 1, -37); _Content.Position = UDim2.fromOffset(70, 37)
_Content.BackgroundTransparency = 1; _Content.Parent = _M
local _Scroll = Instance.new("ScrollingFrame"); _Scroll.Size = UDim2.new(1, 0, 1, 0)
_Scroll.BackgroundTransparency = 1; _Scroll.BorderSizePixel = 0; _Scroll.ScrollBarThickness = 2; _Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
_Scroll.CanvasSize = UDim2.new(0, 0, 0, 0); _Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; _Scroll.Parent = _Content
local _List = Instance.new("UIListLayout", _Scroll); _List.Padding = UDim.new(0, 6); _List.SortOrder = Enum.SortOrder.LayoutOrder
local _Pad = Instance.new("UIPadding", _Scroll); _Pad.PaddingTop = UDim.new(0, 8); _Pad.PaddingLeft = UDim.new(0, 6); _Pad.PaddingRight = UDim.new(0, 8)

-- ==========================================
-- UI 组件生成
-- ==========================================
local function _AddToggle(parent, name, key)
    local r = Instance.new("Frame"); r.Size = UDim2.new(1, 0, 0, 38)
    r.BackgroundColor3 = Color3.fromRGB(35, 35, 42); r.BorderSizePixel = 0; r.Parent = parent; Instance.new("UICorner", r).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -50, 1, 0); l.Position = UDim2.fromOffset(10, 0)
    l.BackgroundTransparency = 1; l.Text = name; l.TextColor3 = Color3.fromRGB(220, 220, 220); l.Font = Enum.Font.Gotham; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = r

    local t = Instance.new("Frame"); t.Size = UDim2.fromOffset(34, 18); t.Position = UDim2.new(1, -42, 0.5, -9)
    t.BackgroundColor3 = Color3.fromRGB(20, 20, 25); t.BorderSizePixel = 0; t.Parent = r; Instance.new("UICorner", t).CornerRadius = UDim.new(1, 0)
    local f = Instance.new("Frame"); f.Size = UDim2.new(0, 0, 1, 0); f.BackgroundColor3 = Color3.fromRGB(0, 170, 100); f.BorderSizePixel = 0; f.Parent = t; Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
    local k = Instance.new("Frame"); k.Size = UDim2.fromOffset(14, 14); k.Position = UDim2.new(0, 2, 0.5, -7); k.BackgroundColor3 = Color3.fromRGB(200, 200, 200); k.Parent = t; Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
    
    local b = Instance.new("TextButton"); b.Size = UDim2.fromScale(1,1); b.BackgroundTransparency = 1; b.Text = ""; b.Parent = r
    local function u()
        if _Z1[key] then
            TweenService:Create(f, TweenInfo.new(0.15), {Size = UDim2.fromScale(1,1)}):Play()
            TweenService:Create(k, TweenInfo.new(0.15), {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1)}):Play()
        else
            TweenService:Create(f, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            TweenService:Create(k, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        end
    end
    b.MouseButton1Click:Connect(function() _Z1[key] = not _Z1[key]; u() end)
    u()
end

local function _AddSlider(parent, name, min, max, def, cb)
    local r = Instance.new("Frame"); r.Size = UDim2.new(1, 0, 0, 48)
    r.BackgroundColor3 = Color3.fromRGB(35, 35, 42); r.BorderSizePixel = 0; r.Parent = parent; Instance.new("UICorner", r).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.fromOffset(10, 4)
    l.BackgroundTransparency = 1; l.Text = name .. ": " .. def; l.TextColor3 = Color3.fromRGB(220, 220, 220); l.Font = Enum.Font.Gotham; l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = r

    local t = Instance.new("Frame"); t.Size = UDim2.new(1, -20, 0, 6); t.Position = UDim2.new(0, 10, 1, -12)
    t.BackgroundColor3 = Color3.fromRGB(20, 20, 25); t.BorderSizePixel = 0; t.Parent = r; Instance.new("UICorner", t).CornerRadius = UDim.new(1, 0)
    local f = Instance.new("Frame"); f.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); f.BackgroundColor3 = Color3.fromRGB(0, 170, 100); f.BorderSizePixel = 0; f.Parent = t; Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
    local k = Instance.new("Frame"); k.Size = UDim2.fromOffset(14, 14); k.Position = UDim2.new((def-min)/(max-min), -7, 0.5, 0); k.AnchorPoint = Vector2.new(0, 0.5); k.BackgroundColor3 = Color3.new(1,1,1); k.Parent = t; Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)

    local ta = Instance.new("TextButton"); ta.Size = UDim2.new(1, 0, 1, 0); ta.BackgroundTransparency = 1; ta.Text = ""; ta.Parent = r
    local drag = false
    local function u(x)
        local rx = math.clamp((x - t.AbsolutePosition.X) / t.AbsoluteSize.X, 0, 1)
        local v = min + (max - min) * rx
        if max <= 5 then v = math.floor(v * 10) / 10 else v = math.floor(v) end
        f.Size = UDim2.new(rx, 0, 1, 0); k.Position = UDim2.new(rx, -7, 0.5, 0)
        l.Text = name .. ": " .. v; cb(v)
    end
    ta.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; u(i.Position.X) end end)
    UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then u(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
end

-- ==========================================
-- 导航
-- ==========================================
local _Tab = ""; local _NavBtns = {}
local function _Switch(t)
    _Tab = t
    for n, b in pairs(_NavBtns) do
        if n == _Tab then b.BackgroundColor3 = Color3.fromRGB(40, 40, 50); b.TextColor3 = Color3.new(1, 1, 1)
        else b.BackgroundColor3 = Color3.fromRGB(20, 20, 25); b.TextColor3 = Color3.fromRGB(150, 150, 160) end
    end
    for _, c in ipairs(_Scroll:GetChildren()) do if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end end

    if t == "A" then
        _AddToggle(_Scroll, "名字", "_V1")
        _AddToggle(_Scroll, "血条", "_V2")
        _AddToggle(_Scroll, "职业", "_V3")
    elseif t == "B" then
        _AddToggle(_Scroll, "装备触发", "_V4")
        _AddSlider(_Scroll, "范围", 10, 150, _Z1._V5, function(v) _Z1._V5 = v end)
        _AddSlider(_Scroll, "次数", 1, 20, _Z1._V7, function(v) _Z1._V7 = v end)
        _AddSlider(_Scroll, "冷却", 0.1, 3.0, _Z1._V6, function(v) _Z1._V6 = v end)
    end
end

local function _CreateNav(n)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -8, 0, 36); b.Position = UDim2.fromOffset(4, 0)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 25); b.Text = n; b.TextColor3 = Color3.fromRGB(150, 150, 160)
    b.Font = Enum.Font.GothamBold; b.TextSize = 13; b.Parent = _Nav; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() _Switch(n) end)
    _NavBtns[n] = b
end
_CreateNav("透视"); _CreateNav("战斗")
_Switch("透视")

-- ==========================================
-- 杀戮逻辑
-- ==========================================
local _LastTime = 0
local function _Kill(tool)
    if not _Z1._V4 then return end
    local now = tick()
    if now - _LastTime < _Z1._V6 then return end
    _LastTime = now

    local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hits = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local thum = plr.Character:FindFirstChildOfClass("Humanoid")
            if thrp and thum and thum.Health > 0 then
                if (hrp.Position - thrp.Position).Magnitude <= _Z1._V5 then
                    if not hits[plr.Character] then
                        hits[plr.Character] = true
                        task.spawn(function()
                            for i = 1, _Z1._V7 do
                                pcall(function() tool:Activate() end)
                                local handle = tool:FindFirstChild("Handle")
                                if handle and firetouchinterest then
                                    for _, p in ipairs(plr.Character:GetChildren()) do
                                        if p:IsA("BasePart") then
                                            pcall(function()
                                                firetouchinterest(handle, p, 0)
                                                task.wait(math.random(15, 40) / 1000)
                                                firetouchinterest(handle, p, 1)
                                            end)
                                        end
                                    end
                                end
                                task.wait(math.random(30, 80) / 1000)
                            end
                        end)
                    end
                end
            end
        end
    end
end

local function _OnChar(c)
    c.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.1); _Kill(ch) end end)
    local t = c:FindFirstChildOfClass("Tool"); if t then _Kill(t) end
end
if LP.Character then _OnChar(LP.Character) end
LP.CharacterAdded:Connect(_OnChar)

-- ==========================================
-- ESP 终极修复版 (防漏防重叠，精确距离)
-- ==========================================
local _ESP = {}

local function _BuildESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not _ESP[plr] then
            local g = Instance.new("BillboardGui"); g.Name = tostring(math.random(1000,9999)); g.Size = UDim2.fromOffset(160, 50)
            g.AlwaysOnTop = true; g.Enabled = false; g.MaxDistance = 10000; g.Parent = _G2
            
            local n = Instance.new("TextLabel"); n.Size = UDim2.new(1, 0, 0, 16); n.BackgroundTransparency = 1; n.TextColor3 = Color3.new(1, 1, 1); n.TextStrokeTransparency = 0; n.Font = Enum.Font.GothamBold; n.TextSize = 12; n.Text = plr.Name; n.Parent = g
            local d = Instance.new("TextLabel"); d.Size = UDim2.new(1, 0, 0, 14); d.Position = UDim2.fromOffset(0, 16); d.BackgroundTransparency = 1; d.TextColor3 = Color3.fromRGB(200, 200, 200); d.TextStrokeTransparency = 0; d.TextSize = 11; d.Parent = g
            
            local bb = Instance.new("Frame"); bb.Size = UDim2.fromOffset(24, 3); bb.Position = UDim2.new(0.5, -16, 0, 32); bb.BackgroundColor3 = Color3.fromRGB(60, 60, 60); bb.BorderSizePixel = 0; bb.Visible = false; bb.Parent = g
            local b = Instance.new("Frame"); b.Size = UDim2.fromScale(1, 1); b.BackgroundColor3 = Color3.fromRGB(0, 220, 100); b.BorderSizePixel = 0; b.Parent = bb
            local h = Instance.new("TextLabel"); h.Size = UDim2.fromOffset(30, 14); h.Position = UDim2.new(0.5, 10, 0, 27); h.BackgroundTransparency = 1; h.TextColor3 = Color3.new(1, 1, 1); h.TextStrokeTransparency = 0; h.TextSize = 9; h.Font = Enum.Font.GothamBold; h.Text = "100%"; h.TextXAlignment = Enum.TextXAlignment.Left; h.Visible = false; h.Parent = g
            
            _ESP[plr] = { gui = g, name = n, dist = d, bar = b, barBg = bb, hp = h }
        end
    end
end

local function _GetRole(plr)
    if plr.Team then
        local tn = plr.Team.Name
        if tn and tn ~= "" and tn ~= "Neutral" and tn ~= "???" and not tn:find("%?") then return _Z2[tn] or tn end
    end
    return "平民"
end

Players.PlayerRemoving:Connect(function(p) if _ESP[p] and _ESP[p].gui then _ESP[p].gui:Destroy() end; _ESP[p] = nil end)

local _fc = 0
RunService.RenderStepped:Connect(function()
    _fc = _fc + 1; if _fc % 2 ~= 0 then return end
    _BuildESP()

    -- 获取自己最新坐标
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    for plr, data in pairs(_ESP) do
        -- 如果没开透视，或者对方不在游戏，或者没模型，直接隐藏
        if not _Z1._V1 or not plr.Parent or not plr.Character then 
            data.gui.Enabled = false
            continue
        end

        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        
        if not hrp or not hum or hum.Health <= 0 then
            data.gui.Enabled = false
            continue
        end

        -- 【核心修复 1】强制重新绑定，防止重生后UI留在原地
        data.gui.Adornee = hrp 
        data.gui.Enabled = true
        
        -- 【核心修复 2】计算真实物理距离，而不是相机距离，并且单位转换为米
        local displayDist = 0
        if myHRP then
            local rawDist = (myHRP.Position - hrp.Position).Magnitude
            displayDist = math.floor(rawDist / 3) -- 除以3，把 studs 换算成正常的“米”
        end
        data.dist.Text = displayDist .. " 米"

        -- 更新职业和名字
        if _Z1._V3 then 
            data.name.Text = "[" .. _GetRole(plr) .. "] " .. plr.Name 
        else 
            data.name.Text = plr.Name 
        end
        
        -- 更新血量
        data.barBg.Visible = _Z1._V2; data.hp.Visible = _Z1._V2
        if _Z1._V2 then
            local mhp = math.max(hum.MaxHealth, 1) 
            local r = math.clamp(hum.Health / mhp, 0, 1)
            data.bar.Size = UDim2.fromScale(r, 1)
            data.bar.BackgroundColor3 = Color3.fromRGB(255 * (1 - r), 255 * r, 0)
            data.hp.Text = math.floor(r * 100) .. "%"
        end
    end
end)

print("[Ninja] 终极防漏防重叠修复版已加载")