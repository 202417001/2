-- ---------- 深度扫描器（结果打在面板里） ----------
local function scanRoles()
    local L = {}
    local function w(s) table.insert(L, tostring(s)) end

    w("===== 深度角色扫描开始 =====")

    -- 1. 全局服务里找可疑 StringValue
    local services = { "ReplicatedStorage", "Workspace", "Players", "Teams" }
    for _, sn in ipairs(services) do
        local ok, svc = pcall(function() return game:GetService(sn) end)
        if ok and svc then
            local found = {}
            local ok2, desc = pcall(function() return svc:GetDescendants() end)
            if ok2 then
                for _, d in ipairs(desc) do
                    if d:IsA("StringValue") then
                        local n = d.Name:lower()
                        if n:find("role") or n:find("job") or n:find("职业") or n:find("角色") then
                            table.insert(found, d:GetFullName() .. " = " .. tostring(d.Value))
                            if #found >= 30 then break end
                        end
                    end
                end
            end
            if #found > 0 then
                w("--- [" .. sn .. "] 可疑 StringValue " .. #found .. " 个 ---")
                for _, line in ipairs(found) do w("  " .. line) end
            end
        end
    end

    -- 2. Teams
    w("--- Teams 队伍列表 ---")
    local okT, Teams = pcall(function() return game:GetService("Teams") end)
    if okT and Teams then
        for _, t in ipairs(Teams:GetTeams()) do
            w("  [Team] " .. t.Name .. " / Color=" .. tostring(t.TeamColor))
        end
    end

    -- 3. 每个玩家深挖
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            w("========== " .. p.Name .. " (" .. p.DisplayName .. ") ==========")
            w("  Team = " .. tostring(p.Team and p.Team.Name))
            w("  Neutral = " .. tostring(p.Neutral))
            for k, v in pairs(p:GetAttributes()) do
                w("  [Player Attr] " .. k .. " = " .. tostring(v))
            end
            for _, tag in ipairs(CollectionService:GetTags(p)) do
                w("  [Player Tag] " .. tag)
            end

            local char = p.Character
            if char then
                -- 四层内所有 StringValue / 有文字的 TextLabel / 数值
                local function walk(node, depth, prefix)
                    if depth > 4 then return end
                    for _, c in ipairs(node:GetChildren()) do
                        local full = prefix .. c.Name
                        if c:IsA("StringValue") then
                            w("  " .. full .. " = " .. tostring(c.Value))
                        elseif c:IsA("TextLabel") and c.Text ~= "" then
                            w("  " .. full .. " [text] = " .. tostring(c.Text))
                        elseif c:IsA("IntValue") or c:IsA("NumberValue") or c:IsA("BoolValue") then
                            w("  " .. full .. " = " .. tostring(c.Value))
                        end
                        walk(c, depth + 1, full .. ".")
                    end
                end
                walk(char, 1, "")
                for k, v in pairs(char:GetAttributes()) do
                    w("  [Char Attr] " .. k .. " = " .. tostring(v))
                end
                for _, tag in ipairs(CollectionService:GetTags(char)) do
                    w("  [Char Tag] " .. tag)
                end
            else
                w("  (无角色)")
            end
        end
    end
    w("===== 扫描结束 =====")

    -- ---------- 弹出结果窗口 ----------
    local oldWin = gui:FindFirstChild("ScanWindow")
    if oldWin then oldWin:Destroy() end

    local win = Instance.new("Frame")
    win.Name = "ScanWindow"
    win.Size = UDim2.fromOffset(360, 320)
    win.Position = UDim2.fromScale(0.5, 0.5)
    win.AnchorPoint = Vector2.new(0.5, 0.5)
    win.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    win.Parent = gui
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)

    local wtitle = Instance.new("TextLabel")
    wtitle.Size = UDim2.new(1, 0, 0, 30)
    wtitle.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    wtitle.BorderSizePixel = 0
    wtitle.Text = "扫描结果（长按文字可复制）"
    wtitle.TextColor3 = Color3.new(1, 1, 1)
    wtitle.Font = Enum.Font.GothamBold
    wtitle.TextSize = 14
    wtitle.Parent = win
    Instance.new("UICorner", wtitle).CornerRadius = UDim.new(0, 8)

    local wclose = Instance.new("TextButton")
    wclose.Size = UDim2.fromOffset(28, 28)
    wclose.Position = UDim2.new(1, -30, 0, 1)
    wclose.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    wclose.Text = "×"
    wclose.TextColor3 = Color3.new(1, 1, 1)
    wclose.Font = Enum.Font.GothamBold
    wclose.TextSize = 14
    wclose.Parent = win
    Instance.new("UICorner", wclose).CornerRadius = UDim.new(0, 6)
    wclose.MouseButton1Click:Connect(function() win:Destroy() end)

    local wscroll = Instance.new("ScrollingFrame")
    wscroll.Size = UDim2.new(1, -12, 1, -40)
    wscroll.Position = UDim2.fromOffset(6, 34)
    wscroll.BackgroundTransparency = 1
    wscroll.BorderSizePixel = 0
    wscroll.ScrollBarThickness = 4
    wscroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    wscroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    wscroll.Parent = win

    local wtext = Instance.new("TextLabel")
    wtext.Size = UDim2.new(1, -6, 0, 0)
    wtext.AutomaticSize = Enum.AutomaticSize.Y
    wtext.BackgroundTransparency = 1
    wtext.Text = table.concat(L, "\n")
    wtext.TextColor3 = Color3.fromRGB(220, 220, 230)
    wtext.Font = Enum.Font.Code
    wtext.TextSize = 11
    wtext.TextXAlignment = Enum.TextXAlignment.Left
    wtext.TextYAlignment = Enum.TextYAlignment.Top
    wtext.TextWrapped = true
    wtext.Parent = wscroll

    print(table.concat(L, "\n"))
end