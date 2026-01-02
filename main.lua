-- ArrayField Version (Bypass Theme Bug)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Bedwars Elite | V6.5",
   LoadingTitle = "Syncing Combined Elite Modules...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local localPlayer = Players.LocalPlayer

-- States
local speedEnabled, walkSpeedValue = false, 0
local infJumpEnabled, flyEnabled, flySpeed = false, false, 50
local jumpEnabled, jumpHeightValue = false, 7.2
local noFallEnabled, noFallSpeed = false, -70 
local killauraEnabled, killauraReach = false, 18
local bedNukerEnabled = false
local nokbEnabled, kbReductionValue = false, 100
local projectileMagnet, magnetRange = false, 15
local espEnabled, enemiesOnly = true, false

-- ESP Data Storage
local playerESP = {}
local espfold = Instance.new("Folder", localPlayer.PlayerGui)
espfold.Name = "MasterESP_Folder"

--- MODULE: FPS BOOST ---
local function FPSBoost()
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0; Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 0
    end
    Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9; Lighting.Brightness = 1
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostProcessEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") then
            effect.Enabled = false
        end
    end
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0; v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
    Rayfield:Notify({Title = "Performance", Content = "Potato Mode Active.", Duration = 5})
end

--- MODULE: MASTER ESP LOGIC ---
local function clearPlayerESP(player)
    if playerESP[player] then
        if playerESP[player].highlight then playerESP[player].highlight:Destroy() end
        if playerESP[player].billboard then playerESP[player].billboard:Destroy() end
        playerESP[player] = nil
    end
end

local function addPlayerESP(player)
    if player == localPlayer then return end

    local function updateESP()
        clearPlayerESP(player)
        
        if not espEnabled then return end
        
        local isTeammate = player.Team ~= nil and player.Team == localPlayer.Team
        if enemiesOnly and isTeammate then return end

        local char = player.Character
        if not char then return end

        -- Highlight Logic
        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 1 
        highlight.OutlineColor = isTeammate and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        highlight.OutlineTransparency = 0
        highlight.Adornee = char
        highlight.Parent = espfold
        
        -- Billboard Logic
        local billboard = Instance.new("BillboardGui", espfold)
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = char:WaitForChild("Head", 5) or char:FindFirstChild("HumanoidRootPart")

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = highlight.OutlineColor
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0.5

        playerESP[player] = {highlight = highlight, billboard = billboard, label = label}
    end

    player.CharacterAdded:Connect(updateESP)
    player:GetPropertyChangedSignal("Team"):Connect(updateESP)
    if player.Character then updateESP() end
end

local function refreshESP()
    for _, p in pairs(Players:GetPlayers()) do
        addPlayerESP(p)
    end
end

--- UTILITY ---
local function getClosestPlayer()
    local closest, dist = nil, killauraReach
    local myChar = localPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= localPlayer and v.Team ~= localPlayer.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (myPos - v.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then dist = mag; closest = v end
        end
    end
    return closest
end

--- MAIN PERFORMANCE LOOP ---
RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = char.Humanoid

    -- PROJECTILE MAGNET (Silent Aim Style)
    if projectileMagnet then
        for _, projectile in pairs(workspace:GetChildren()) do
            if projectile.Name == "arrow" or projectile.Name == "crossbow_bolt" then
                for _, enemy in pairs(Players:GetPlayers()) do
                    if enemy ~= localPlayer and enemy.Team ~= localPlayer.Team and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                        local enemyRoot = enemy.Character.HumanoidRootPart
                        local dist = (projectile.Position - enemyRoot.Position).Magnitude
                        if dist < magnetRange then
                            projectile.CFrame = CFrame.new(projectile.Position, enemyRoot.Position)
                            projectile.Velocity = (enemyRoot.Position - projectile.Position).Unit * 200
                        end
                    end
                end
            end
        end
    end

    -- NO-KB / VELOCITY SMOOTHING
    if nokbEnabled and hum.MoveDirection.Magnitude == 0 then
        local vel = root.AssemblyLinearVelocity
        if vel.Magnitude > 2 then
            local multiplier = kbReductionValue / 100
            root.AssemblyLinearVelocity = Vector3.new(vel.X * multiplier, vel.Y, vel.Z * multiplier)
        end
    end

    -- JUMP & MOVEMENT
    if infJumpEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    if noFallEnabled and hum.FloorMaterial == Enum.Material.Air and root.AssemblyLinearVelocity.Y < -40 then
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, noFallSpeed, root.AssemblyLinearVelocity.Z)
    end

    if flyEnabled then
        local v = (UserInputService:IsKeyDown(Enum.KeyCode.Space) and flySpeed or 0) + (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -flySpeed or 0)
        root.AssemblyLinearVelocity = (hum.MoveDirection * flySpeed) + Vector3.new(0, v, 0)
    elseif speedEnabled and hum.MoveDirection.Magnitude > 0 then
        root.CFrame = root.CFrame + (hum.MoveDirection * (walkSpeedValue * 0.01))
    end

    -- COMBAT (Nuker & KA)
    if bedNukerEnabled then
        for _, v in pairs(workspace:GetChildren()) do
            if v.Name == "bed" and v:FindFirstChild("Covers") and v:GetAttribute("Team") ~= localPlayer:GetAttribute("Team") then
                if (root.Position - v.Position).Magnitude < 30 then
                    ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ClientBlockBreak:InvokeServer({
                        ["blockRef"] = {["blockPosition"] = Vector3.new(math.floor(v.Position.X/3), math.floor(v.Position.Y/3), math.floor(v.Position.Z/3))}
                    })
                end
            end
        end
    end

    if killauraEnabled then
        local enemy = getClosestPlayer()
        if enemy then
            local sword = char:FindFirstChildWhichIsA("Tool")
            if sword then sword:Activate() end
        end
    end

    -- ESP DISTANCE UPDATE
    for player, data in pairs(playerESP) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
            data.label.Text = player.Name .. "\n[" .. math.floor(dist) .. "s]"
        else
            clearPlayerESP(player)
        end
    end
end)

--- UI TABS ---
local MainTab = Window:CreateTab("Movement")
MainTab:CreateToggle({Name = "Speed Boost", CurrentValue = false, Callback = function(v) speedEnabled = v end})
MainTab:CreateSlider({Name = "Speed Power", Range = {0, 15}, Increment = 1, CurrentValue = 0, Callback = function(v) walkSpeedValue = v end})
MainTab:CreateToggle({Name = "Fly Mode", CurrentValue = false, Callback = function(v) flyEnabled = v end})
MainTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) infJumpEnabled = v end})
MainTab:CreateToggle({Name = "No-Fall Damage", CurrentValue = false, Callback = function(v) noFallEnabled = v end})

local CombatTab = Window:CreateTab("Combat")
CombatTab:CreateToggle({Name = "Killaura", CurrentValue = false, Callback = function(v) killauraEnabled = v end})
CombatTab:CreateSlider({Name = "Aura Reach", Range = {10, 25}, Increment = 1, CurrentValue = 18, Callback = function(v) killauraReach = v end})
CombatTab:CreateToggle({Name = "Bed Nuker", CurrentValue = false, Callback = function(v) bedNukerEnabled = v end})
CombatTab:CreateToggle({Name = "Projectile Magnet", CurrentValue = false, Callback = function(v) projectileMagnet = v end})
CombatTab:CreateSlider({Name = "Magnet Range", Range = {5, 30}, Increment = 1, CurrentValue = 15, Callback = function(v) magnetRange = v end})
CombatTab:CreateToggle({Name = "Smooth Velocity (No-KB)", CurrentValue = false, Callback = function(v) nokbEnabled = v end})
CombatTab:CreateSlider({Name = "Knockback Taken %", Range = {0, 100}, Increment = 1, CurrentValue = 100, Callback = function(v) kbReductionValue = v end})

local VisTab = Window:CreateTab("Visuals")
VisTab:CreateToggle({
    Name = "Player ESP", 
    CurrentValue = true, 
    Callback = function(v) 
        espEnabled = v 
        refreshESP() 
    end
})
VisTab:CreateToggle({
    Name = "Enemies Only", 
    CurrentValue = false, 
    Callback = function(v) 
        enemiesOnly = v 
        refreshESP() 
    end
})

local SettingsTab = Window:CreateTab("Settings")
SettingsTab:CreateButton({Name = "FPS Boost (Potato Mode)", Callback = function() FPSBoost() end})

-- Initialize
for _, p in pairs(Players:GetPlayers()) do addPlayerESP(p) end
Players.PlayerAdded:Connect(addPlayerESP)
Players.PlayerRemoving:Connect(clearPlayerESP)