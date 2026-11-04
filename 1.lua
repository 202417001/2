local P,U,R,L,St=game:GetService("Players"),game:GetService("UserInputService"),game:GetService("RunService"),game:GetService("Lighting"),game:GetService("Stats")
local lp=P.LocalPlayer local pg=lp:WaitForChild("PlayerGui")
for _,v in pairs(pg:GetChildren()) do if v.Name=="DataGrabber" then v:Destroy() end end

local G=Instance.new("ScreenGui",pg) G.Name="DataGrabber" G.IgnoreGuiInset=true G.ResetOnSpawn=false
local M=Instance.new("Frame",G) M.Size=UDim2.new(0,200,0,380) M.Position=UDim2.new(0,20,0,80) M.BackgroundColor3=Color3.fromRGB(20,20,25) M.BackgroundTransparency=0.2 M.BorderSizePixel=0
Instance.new("UICorner",M).CornerRadius=UDim.new(0,8)
local Sk=Instance.new("UIStroke",M) Sk.Color=Color3.fromRGB(58,115,253) Sk.Thickness=1.5

local TL=Instance.new("TextLabel",M) TL.Size=UDim2.new(1,0,0,30) TL.BackgroundColor3=Color3.fromRGB(58,115,253) TL.BackgroundTransparency=0.8 TL.Text="📊 通用数据抓取器" TL.TextColor3=Color3.new(1,1,1) TL.Font=Enum.Font.GothamBold TL.TextSize=13
local LL=Instance.new("Frame",M) LL.Size=UDim2.new(1,-20,1,-40) LL.Position=UDim2.new(0,10,0,35) LL.BackgroundTransparency=1
Instance.new("UIListLayout",LL).Padding=UDim.new(0,4)
local Lb={}
local function Add(id, name)
    local F=Instance.new("Frame",LL) F.Size=UDim2.new(1,0,0,22) F.BackgroundTransparency=1
    local T=Instance.new("TextLabel",F) T.Size=UDim2.new(0.5,0,1,0) T.BackgroundTransparency=1 T.Text=name.."：" T.TextColor3=Color3.fromRGB(150,150,160) T.Font=Enum.Font.Gotham T.TextSize=12 T.TextXAlignment=Enum.TextXAlignment.Left
    local V=Instance.new("TextLabel",F) V.Size=UDim2.new(0.5,0,1,0) V.Position=UDim2.new(0.5,0,0,0) V.BackgroundTransparency=1 V.Text="加载中" V.TextColor3=Color3.fromRGB(0,220,255) V.Font=Enum.Font.GothamBold V.TextSize=12 V.TextXAlignment=Enum.TextXAlignment.Right
    Lb[id]=V
end

Add("Speed","移动速度")
Add("Jump","跳跃高度")
Add("Health","当前血量")
Add("Pos","人物坐标")
Add("State","动作状态")
Add("FPS","屏幕帧率")
Add("Ping","网络延迟")
Add("Mem","占用内存")
Add("Gravity","世界重力")
Add("FOV","视野角度")
Add("Players","服务器人数")
Add("Time","游戏内时间")

local fps, frames, lastT = 0, 0, tick()
R.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastT >= 1 then fps = math.floor(frames / (tick() - lastT)); frames = 0; lastT = tick() end
end)

R.Heartbeat:Connect(function()
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp then
        Lb["Speed"].Text = math.floor(hum.WalkSpeed) .. " 格/秒"
        Lb["Jump"].Text = math.floor(hum.JumpPower) .. " 格"
        Lb["Health"].Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
        Lb["Pos"].Text = string.format("%d, %d, %d", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
        
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Running then Lb["State"].Text = "奔跑"
        elseif state == Enum.HumanoidStateType.Jumping then Lb["State"].Text = "跳跃"
        elseif state == Enum.HumanoidStateType.Freefall then Lb["State"].Text = "下落"
        elseif state == Enum.HumanoidStateType.Swimming then Lb["State"].Text = "游泳"
        elseif state == Enum.HumanoidStateType.Landed then Lb["State"].Text = "站立"
        elseif state == Enum.HumanoidStateType.Seated then Lb["State"].Text = "坐下"
        else Lb["State"].Text = tostring(state):gsub("HumanoidStateType%.","") end
    else
        Lb["Speed"].Text = "无角色"; Lb["Jump"].Text = "无角色"; Lb["Health"].Text = "无角色"; Lb["Pos"].Text = "无角色"; Lb["State"].Text = "无角色"
    end

    Lb["FPS"].Text = fps .. " FPS"
    pcall(function() Lb["Ping"].Text = math.floor(St.Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms" end)
    pcall(function() Lb["Mem"].Text = math.floor(St:GetTotalMemoryUsageMb()) .. " MB" end)
    Lb["Gravity"].Text = math.floor(workspace.Gravity)
    Lb["FOV"].Text = math.floor(workspace.CurrentCamera.FieldOfView) .. " °"
    Lb["Players"].Text = #P:GetPlayers() .. " 人"
    Lb["Time"].Text = string.format("%.1f 点", L.ClockTime)
end)