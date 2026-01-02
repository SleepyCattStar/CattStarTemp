repeat task.wait() until game:IsLoaded()

local Keybind = shared.Keybind or "RightShift"
local collectionService = game:GetService("CollectionService")
local debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PulseSpeed = 5 
local PulseStrength = 0.2 

local Icons = {
    ["iron"] = "rbxassetid://6850537969",
    ["bee"] = "rbxassetid://7343272839",
    ["natures_essence_1"] = "rbxassetid://11003449842",
    ["thorns"] = "rbxassetid://9134549615",
    ["mushrooms"] = "rbxassetid://9134534696",
    ["wild_flower"] = "rbxassetid://9134545166",
    ["crit_star"] = "rbxassetid://10165036155",
    ["vitality_star"] = "rbxassetid://10165045356"
}

local espobjs = {}
local connections = {}
local hidden = false


local gui = Instance.new("ScreenGui", localPlayer.PlayerGui)
gui.Name = "ResourceESP"
gui.ResetOnSpawn = false

local espfold = Instance.new("Folder", gui)
espfold.Name = "ESPStorage"

local statusLabel = Instance.new("TextLabel", gui)
statusLabel.Size = UDim2.new(0, 130, 0, 30)
statusLabel.Position = UDim2.new(1, -140, 0, 10)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusLabel.BackgroundTransparency = 0.4
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 14
statusLabel.Text = "ESP: ENABLED"
local statusCorner = Instance.new("UICorner", statusLabel)
statusCorner.CornerRadius = UDim.new(0, 6)

local function updateStatusUI()
    if hidden then
        statusLabel.Text = "ESP: DISABLED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Red
    else
        statusLabel.Text = "ESP: ENABLED"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150) -- Green
    end
end

local function isKeybindValid(key)
    return pcall(function() return Enum.KeyCode[key] end)
end

local function showNotification(message)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 300, 0, 40)
    notification.Position = UDim2.new(0.5, -150, 0, 60)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.TextColor3 = Color3.new(1, 1, 1)
    notification.Font = Enum.Font.GothamBold
    notification.TextSize = 16
    notification.Text = message
    notification.AnchorPoint = Vector2.new(0.5, 0)
    notification.Parent = gui
    Instance.new("UICorner", notification)
    debris:AddItem(notification, 2)
end

local function espadd(v, icon)
    if not v or espobjs[v] then return end

    local billboard = Instance.new("BillboardGui", espfold)
    billboard.Name = "ResourceBillboard"
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    billboard.Size = UDim2.new(0, 50, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Adornee = v

    local image = Instance.new("ImageLabel", billboard)
    image.BackgroundTransparency = 1
    image.Image = Icons[icon] or ""
    image.Size = UDim2.new(0, 32, 0, 32)
    image.AnchorPoint = Vector2.new(0.5, 0.5)
    image.Position = UDim2.new(0.5, 0, 0.4, 0)

    local distLabel = Instance.new("TextLabel", billboard)
    distLabel.BackgroundTransparency = 1
    distLabel.Size = UDim2.new(1, 0, 0, 15)
    distLabel.Position = UDim2.new(0.5, 0, 0.9, 0)
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- RED font
    distLabel.TextSize = 12
    distLabel.TextStrokeTransparency = 0.5
    distLabel.Text = "..."

    espobjs[v] = {gui = billboard, img = image, text = distLabel}
end

local function reset()
    for _, v in pairs(connections) do
        pcall(function() v:Disconnect() end)
    end
    table.clear(connections)
    espfold:ClearAllChildren()
    table.clear(espobjs)
end

local function addKit(tag, icon, custom)
    if not custom then
        local function onAdded(v)
            task.defer(function()
                local part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                if part then espadd(part, icon) end
            end)
        end
        table.insert(connections, collectionService:GetInstanceAddedSignal(tag):Connect(onAdded))
        table.insert(connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
            local part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
            if part and espobjs[part] then
                espobjs[part].gui:Destroy()
                espobjs[part] = nil
            end
        end))
        for _, v in pairs(collectionService:GetTagged(tag)) do onAdded(v) end
    else
        local function check(v)
            if v.Name == tag then
                task.defer(function()
                    local part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    if part then espadd(part, icon) end
                end)
            end
        end
        table.insert(connections, workspace.ChildAdded:Connect(check))
        for _, v in pairs(workspace:GetChildren()) do check(v) end
    end
end

local function recreateESP()
    reset()
    addKit("hidden-metal", "iron")
    addKit("bee", "bee")
    addKit("treeOrb", "natures_essence_1")
    addKit("Thorns", "thorns", true)
    addKit("Mushrooms", "mushrooms", true)
    addKit("Flower", "wild_flower", true)
    addKit("CritStar", "crit_star", true)
    addKit("VitalityStar", "vitality_star", true)
end

RunService.RenderStepped:Connect(function()
    if hidden then return end
    
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local pulseScale = 1 + (math.sin(tick() * PulseSpeed) * PulseStrength)

    for part, data in pairs(espobjs) do
        if part and part.Parent then
            local distance = (root.Position - part.Position).Magnitude
            data.text.Text = math.floor(distance) .. " studs"
            data.img.Size = UDim2.new(0, 32 * pulseScale, 0, 32 * pulseScale)
        else
            if data.gui then data.gui:Destroy() end
            espobjs[part] = nil
        end
    end
end)

--// Initialize
if not isKeybindValid(Keybind) then
    Keybind = "RightShift"
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode[Keybind] then
        hidden = not hidden
        updateStatusUI()
        if hidden then reset() else recreateESP() end
    end
end)

recreateESP()
updateStatusUI()