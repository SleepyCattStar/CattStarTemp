local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("CattStarIntro") then
    CoreGui.CattStarIntro:Destroy()
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CattStarIntro"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true 
ScreenGui.DisplayOrder = 9999 

-- Black Background
local Background = Instance.new("Frame")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.new(0, 0, 0)
Background.BorderSizePixel = 0
Background.BackgroundTransparency = 0
Background.Parent = ScreenGui

-- The Text Label
local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, 0, 0.2, 0)
TextLabel.Position = UDim2.new(0, 0, 0.4, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.Text = "CATTSTAR"
TextLabel.Font = Enum.Font.LuckiestGuy 
TextLabel.TextSize = 1 
TextLabel.TextTransparency = 1
TextLabel.Parent = Background

local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local zoomIn = TweenService:Create(TextLabel, tweenInfo, {
    TextSize = 120,
    TextTransparency = 0
})

local pulseInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local pulse = TweenService:Create(TextLabel, pulseInfo, {
    TextSize = 135
})

local fadeOutInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local fadeOut = TweenService:Create(Background, fadeOutInfo, {
    BackgroundTransparency = 1
})
local textFade = TweenService:Create(TextLabel, fadeOutInfo, {
    TextTransparency = 1
})

task.spawn(function()
    zoomIn:Play()
    zoomIn.Completed:Wait()
    
    pulse:Play()
    task.wait(1.5) 
    
    pulse:Cancel()
    fadeOut:Play()
    textFade:Play()
    
    fadeOut.Completed:Wait()
    ScreenGui:Destroy()
end)
