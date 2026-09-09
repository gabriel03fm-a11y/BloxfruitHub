-- ============================================
--  LEGACY MARU - Blox Fruits (Inspirado no Maru Hub)
--  Funções: Auto Farm, Auto Raid, Auto Boss, Auto Stats, Teleports
--  Compatível: Delta / Xeno / Synapse Z
-- ============================================

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local TweenService = game:GetService("TweenService")
local VU = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

VU:CaptureController()

-- ============================================
--  VARIÁVEIS DE CONTROLE (STATUS)
-- ============================================
local status = {
    Farm = false,
    Boss = false,
    Raid = false,
    FastAttack = false,
    AutoStats = false,
    StatType = "Melee" -- Melee, Defense, Sword, Gun
}

-- ============================================
--  FUNÇÕES PRINCIPAIS (O CORAÇÃO DO MARU)
-- ============================================

-- Encontra o mob mais próximo pelo nível
function GetNearestMob()
    local target, minDist = nil, math.huge
    local myLevel = player.Data.Level.Value
    
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local level = tonumber(v.Name:match("(%d+)")) or 0
            if level > 0 and level <= myLevel + 20 and level >= myLevel - 10 then
                local dist = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    target = v
                end
            end
        end
    end
    return target
end

-- Encontra o Boss mais próximo
function GetNearestBoss()
    local target, minDist = nil, math.huge
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("Boss") then
            local dist = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                target = v
            end
        end
    end
    return target
end

-- Teleporte suave
function TeleportTo(pos)
    if not pos then return end
    local tween = TweenService:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- Ataque Automático (Fast Attack)
local isClicking = false
function StartClickSpam()
    if isClicking then return end
    isClicking = true
    spawn(function()
        while isClicking and status.FastAttack do
            VU:Button1Down(Vector2.new(0,0))
            task.wait(0.01)
            VU:Button1Up(Vector2.new(0,0))
            task.wait(0.01)
        end
    end)
end

function StopClickSpam()
    isClicking = false
    VU:Button1Up(Vector2.new(0,0))
end

-- Loop de Farm (Mobs)
function FarmLoop()
    while status.Farm do
        task.wait(0.5)
        if not player.Character or hum.Health <= 0 then
            task.wait(2)
            player.CharacterAdded:Wait()
            char = player.Character
            hrp = char:WaitForChild("HumanoidRootPart")
            hum = char:WaitForChild("Humanoid")
        end
        
        local mob = GetNearestMob()
        if mob then
            TeleportTo(mob.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
            task.wait(0.3)
            VU:Button1Down(Vector2.new(0,0))
            task.wait(1.5)
            VU:Button1Up(Vector2.new(0,0))
        else
            task.wait(2)
        end
    end
    StopClickSpam()
end

-- Loop de Farm (Boss)
function BossLoop()
    while status.Boss do
        task.wait(0.5)
        if not player.Character or hum.Health <= 0 then
            task.wait(2)
            player.CharacterAdded:Wait()
            char = player.Character
            hrp = char:WaitForChild("HumanoidRootPart")
            hum = char:WaitForChild("Humanoid")
        end
        
        local boss = GetNearestBoss()
        if boss then
            TeleportTo(boss.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
            task.wait(0.3)
            VU:Button1Down(Vector2.new(0,0))
            repeat task.wait(1) until not boss.Parent or boss.Humanoid.Health <= 0
            VU:Button1Up(Vector2.new(0,0))
            task.wait(1)
        else
            task.wait(3)
        end
    end
    StopClickSpam()
end

-- Loop de Auto Stats (Distribui pontos)
function StatsLoop()
    while status.AutoStats do
        task.wait(0.5)
        local statsGUI = player.PlayerGui:FindFirstChild("Stats")
        if statsGUI then
            for _, btn in pairs(statsGUI:GetDescendants()) do
                if btn.Name == status.StatType and btn:IsA("TextButton") then
                    pcall(function() btn:Activate() end)
                end
            end
        end
    end
end

-- Loop de Auto Raid (simples)
function RaidLoop()
    while status.Raid do
        task.wait(0.5)
        TeleportTo(Vector3.new(-5550, 50, -4900))
        task.wait(1)
        
        local found = false
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local dist = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
                if dist < 200 then
                    TeleportTo(v.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                    VU:Button1Down(Vector2.new(0,0))
                    task.wait(1)
                    VU:Button1Up(Vector2.new(0,0))
                    found = true
                    break
                end
            end
        end
        if not found then
            task.wait(3)
        end
    end
    StopClickSpam()
end

-- ============================================
--  CRIAÇÃO DA INTERFACE (GUI) - ESTILO MARU
-- ============================================
local screen = Instance.new("ScreenGui")
screen.Name = "LegacyMaruGUI"
screen.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 470)
frame.Position = UDim2.new(0.02, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.15
frame.Active = true
frame.Draggable = true
frame.Parent = screen

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "⚡ LEGACY MARU"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local y = 45
local btnSize = 35

function CreateToggle(text, yPos, statusRef, toggleFunction)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, btnSize)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text .. " 🔴"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        statusRef = not statusRef
        if statusRef then
            btn.Text = text .. " 🟢"
            btn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
            if toggleFunction then toggleFunction() end
        else
            btn.Text = text .. " 🔴"
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            StopClickSpam()
        end
        return statusRef
    end)
    return btn, statusRef
end

local farmBtn, farmStatus = CreateToggle("Auto Farm", y, status.Farm, function() spawn(FarmLoop) end)
y = y + btnSize + 5

local bossBtn, bossStatus = CreateToggle("Auto Boss", y, status.Boss, function() spawn(BossLoop) end)
y = y + btnSize + 5

local raidBtn, raidStatus = CreateToggle("Auto Raid", y, status.Raid, function() spawn(RaidLoop) end)
y = y + btnSize + 5

local fastBtn, fastStatus = CreateToggle("Fast Attack", y, status.FastAttack, function() StartClickSpam() end)
y = y + btnSize + 5

local statBtn = Instance.new("TextButton")
statBtn.Size = UDim2.new(0.9, 0, 0, btnSize)
statBtn.Position = UDim2.new(0.05, 0, 0, y)
statBtn.Text = "Auto Stats: " .. status.StatType .. " 🔴"
statBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
statBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
statBtn.Font = Enum.Font.GothamSemibold
statBtn.TextSize = 13
statBtn.Parent = frame

local statOptions = {"Melee", "Defense", "Sword", "Gun"}
local statIndex = 1

statBtn.MouseButton1Click:Connect(function()
    if not status.AutoStats then
        status.AutoStats = true
        statBtn.Text = "Auto Stats: " .. status.StatType .. " 🟢"
        statBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        spawn(StatsLoop)
    else
        statIndex = statIndex % #statOptions + 1
        status.StatType = statOptions[statIndex]
        statBtn.Text = "Auto Stats: " .. status.StatType .. " 🟢"
    end
end)

statBtn.MouseButton2Click:Connect(function()
    status.AutoStats = false
    statBtn.Text = "Auto Stats: " .. status.StatType .. " 🔴"
    statBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
end)

y = y + btnSize + 10

local tpLabel = Instance.new("TextLabel")
tpLabel.Size = UDim2.new(1, 0, 0, 20)
tpLabel.Position = UDim2.new(0, 0, 0, y)
tpLabel.Text = "📍 TELEPORTES"
tpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
tpLabel.BackgroundTransparency = 1
tpLabel.Font = Enum.Font.GothamBold
tpLabel.TextSize = 14
tpLabel.Parent = frame
y = y + 25

local tps = {
    {"🏝️ Jungle", Vector3.new(-1200, 20, -2500)},
    {"🏚️ Pirate Village", Vector3.new(-700, 10, -1000)},
    {"🏝️ Ice Island", Vector3.new(1200, 20, -5000)},
    {"🏰 Castle on Sea", Vector3.new(-5550, 50, -4900)},
    {"🔥 Hot & Cold", Vector3.new(-3000, 20, 6000)},
    {"🌊 Sea of Treats", Vector3.new(-3300, 10, 7150)},
    {"🚢 Docks (Second Sea)", Vector3.new(-100, 10, 0)}
}

for _, tp in ipairs(tps) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.43, 0, 0, 28)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = tp[1]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        TeleportTo(tp[2])
    end)
    
    y = y + 32
end

local stopAll = Instance.new("TextButton")
stopAll.Size = UDim2.new(0.9, 0, 0, 35)
stopAll.Position = UDim2.new(0.05, 0, 0, y + 5)
stopAll.Text = "🛑 PARAR TUDO"
stopAll.TextColor3 = Color3.fromRGB(255, 80, 80)
stopAll.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
stopAll.Font = Enum.Font.GothamBold
stopAll.TextSize = 15
stopAll.Parent = frame

stopAll.MouseButton1Click:Connect(function()
    status.Farm = false
    status.Boss = false
    status.Raid = false
    status.FastAttack = false
    status.AutoStats = false
    StopClickSpam()
    
    for _, child in pairs(frame:GetChildren()) do
        if child:IsA("TextButton") and child ~= stopAll then
            if string.find(child.Text, "🟢") then
                child.Text = string.gsub(child.Text, " 🟢", " 🔴")
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            end
        end
    end
    print("🛑 Legacy Maru - Todos os processos parados!")
end)

print("✅ LEGACY MARU (Inspirado) CARREGADO!")
print("🎯 Funções: Farm, Boss, Raid, Fast Attack, Auto Stats e Teleports.")
