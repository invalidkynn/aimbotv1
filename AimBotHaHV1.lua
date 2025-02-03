-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Aimbot settings
local aimbotEnabled = false
local fovRadius = 100  -- Decreased FOV
local maxDistance = 1000  
local smoothness = 0.5  -- Smoother aim

-- ESP settings
local espEnabled = false
local maxDistanceESP = 1000

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local background = Instance.new("Frame")
background.Size = UDim2.new(0, 320, 0, 500)
background.Position = UDim2.new(0, 50, 0, 50)
background.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
background.BorderSizePixel = 0
background.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 25)
corner.Parent = background

-- Title Label for the aimbot
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.SourceSans
titleLabel.Text = "HaH Uni AimBot V1"
titleLabel.Parent = background

-- Create a function to make buttons
local function createButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0, 40)
    button.Position = position
    button.AnchorPoint = Vector2.new(0.5, 0)
    button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 18
    button.Font = Enum.Font.SourceSans
    button.Text = text
    button.Parent = background

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 15)
    buttonCorner.Parent = button

    button.MouseButton1Click:Connect(callback)
    return button
end

-- Toggle buttons
local aimbotButton = createButton("Aimbot", UDim2.new(0.5, 0, 0, 100), function()
    aimbotEnabled = not aimbotEnabled
end)

local espButton = createButton("ESP", UDim2.new(0.5, 0, 0, 160), function()
    espEnabled = not espEnabled
    -- Enable/Disable ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local character = player.Character
            local head = character:FindFirstChild("Head")
            if head then
                -- Check if BillboardGui already exists or create a new one
                local billboardGui = character:FindFirstChildOfClass("BillboardGui")
                if not billboardGui then
                    billboardGui = Instance.new("BillboardGui")
                    billboardGui.Size = UDim2.new(0, 200, 0, 50)
                    billboardGui.Adornee = head
                    billboardGui.AlwaysOnTop = true
                    billboardGui.Parent = character
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.new(1, 1, 1)
                    textLabel.TextStrokeTransparency = 0.5
                    textLabel.Text = player.Name
                    textLabel.TextSize = 18
                    textLabel.Parent = billboardGui
                end
                billboardGui.Enabled = espEnabled
            end
        end
    end
end)

-- Draggable GUI
local dragging, dragStart, startPos
background.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = background.Position
    end
end)

background.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        background.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

background.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Aimbot function
local function getClosestEnemy()
    local closestPlayer = nil
    local closestDistance = fovRadius
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPosition, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local targetPlayer = getClosestEnemy()
        if targetPlayer and targetPlayer.Character then
            local head = targetPlayer.Character:FindFirstChild("Head")
            if head then
                camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, head.Position), smoothness)
            end
        end
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        aimbotEnabled = not aimbotEnabled
    elseif input.KeyCode == Enum.KeyCode.E then
        espEnabled = not espEnabled
        -- Toggle ESP visibility for all players
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local character = player.Character
                local head = character:FindFirstChild("Head")
                if head then
                    local billboardGui = character:FindFirstChildOfClass("BillboardGui")
                    if billboardGui then
                        billboardGui.Enabled = espEnabled
                    end
                end
            end
        end
    end
end)

print("[HaH Uni AimBot V1] Loaded successfully!")
