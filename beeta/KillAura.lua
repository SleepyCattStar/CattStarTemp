-- STANDALONE BEDWARS KILLAURA (2026 FIXED)
-- Toggle Key: X

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local lplr = Players.LocalPlayer

-- // CONFIGURATION //
local KA_ENABLED = true    -- Starts as true
local KA_RANGE = 16        -- 14-17 is the safe zone for 2026 Anticheat
local ATTACK_SPEED = 0.11  -- Time between hits (~9 CPS)

-- // REMOTE FINDER //
local function getSwordRemote()
    -- Path determined by standard Bedwars structure + your SimpleSpy screenshot
    local net = ReplicatedStorage:FindFirstChild("rbxts_include")
    if net then
        net = net:FindFirstChild("node_modules"):FindFirstChild("@rbxts"):FindFirstChild("net"):FindFirstChild("out"):FindFirstChild("_NetManaged")
        -- Prioritizing 'SwordHit' from your screenshot
        return net:FindFirstChild("SwordHit") or net:FindFirstChild("swordHit")
    end
    return nil
end

-- // KEYBIND TOGGLE (X) //
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Don't toggle if you're typing in chat
    
    if input.KeyCode == Enum.KeyCode.X then
        KA_ENABLED = not KA_ENABLED
        print("[KA] Killaura is now: " .. (KA_ENABLED and "ENABLED" or "DISABLED"))
        
        -- Optional: Simple visual notification
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Killaura",
            Text = KA_ENABLED and "Enabled (X)" or "Disabled (X)",
            Duration = 2
        })
    end
end)

-- // MAIN KILLAURA LOGIC //
print("[KA] Script Loaded. Press 'X' to toggle.")

task.spawn(function()
    while true do
        task.wait(ATTACK_SPEED)
        
        if KA_ENABLED then
            local remote = getSwordRemote()
            local character = lplr.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            
            if remote and root then
                -- Scan all players for a target
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = v.Character.HumanoidRootPart
                        local dist = (targetRoot.Position - root.Position).Magnitude
                        
                        -- Alive and within range check
                        if dist <= KA_RANGE and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                            
                            -- DATA STRUCTURE FROM YOUR SCREENSHOT
                            local args = {
                                [1] = {
                                    ["entityInstance"] = v.Character,
                                    ["chargeRatio"] = 0, -- Line 7 from your image
                                    ["validate"] = {
                                        ["targetPosition"] = {["value"] = targetRoot.Position}, -- Line 10
                                        ["selfPosition"] = {["value"] = root.Position}      -- Line 13
                                    }
                                }
                            }
                            
                            -- Fire the confirmed remote name
                            remote:FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)