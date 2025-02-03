-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Aimbot settings
local aimbotEnabled = false  -- Toggle aimbot
local fovRadius = 100  -- Field of view radius for aimbot (in pixels)
local maxDistance = 1000  -- Maximum distance for aimbot
local smoothness = 0.5  -- Smoothness of the aim (lower = smoother)

-- ESP settings
local espEnabled = false  -- Toggle ESP
local highlightColor = Color3.new(1, 0, 0)  -- Red outline
local maxDistanceESP = 500  -- Maximum distance for ESP

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local background = Instance.new("Frame")
background.Size = UDim2.new(0, 300, 0, 500)  -- Increased size for more space
background.Position = UDim2.new(0, 10, 0, 10)
background.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)  -- Darker background for better contrast
background.BorderSizePixel = 0
background.Parent = screenGui

-- Round the corners of the frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 25)
corner.Parent = background

local isMinimized = false

local function createButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)  -- Make button width 100% of the parent with a small margin
    button.Position = position
    button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 18
    button.Font = Enum.Font.SourceSans
    button.Text = text
    button.Parent = background
    button.AnchorPoint = Vector2.new(0.5, 0.5)  -- Center the button text

    -- Debugging button position and creation
    print("Created button with position: ", position)

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    end)

    button.MouseButton1Click:Connect(callback)

    -- Add rounded corners to the button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 25)  -- Circular button
    buttonCorner.Parent = button
    
    return button
end

-- Labels to show status
local assistStatus = Instance.new("TextLabel")
assistStatus.Size = UDim2.new(0, 280, 0, 30)
assistStatus.Position = UDim2.new(0, 10, 0, 10)
assistStatus.BackgroundTransparency = 1
assistStatus.TextColor3 = Color3.new(1, 1, 1)
assistStatus.TextSize = 18
assistStatus.Text = "Aimbot: Off"
assistStatus.Parent = background

local espStatus = Instance.new("TextLabel")
espStatus.Size = UDim2.new(0, 280, 0, 30)
espStatus.Position = UDim2.new(0, 10, 0, 50)
espStatus.BackgroundTransparency = 1
espStatus.TextColor3 = Color3.new(1, 1, 1)
espStatus.TextSize = 18
espStatus.Text = "ESP: Off"
espStatus.Parent = background

local teamStatus = Instance.new("TextLabel")
teamStatus.Size = UDim2.new(0, 280, 0, 30)
teamStatus.Position = UDim2.new(0, 10, 0, 90)  -- Adjusted position to be lower
teamStatus.BackgroundTransparency = 1
teamStatus.TextColor3 = Color3.new(1, 1, 1)
teamStatus.TextSize = 18
teamStatus.Text = "Team: Not Checked"
teamStatus.Parent = background

-- Buttons for Aimbot, ESP, Kill Script, and Team Checker
local aimbotButton = createButton("Aimbot", UDim2.new(0.5, 0, 0, 150), function()
    aimbotEnabled = not aimbotEnabled
    assistStatus.Text = "Aimbot: " .. (aimbotEnabled and "On" or "Off")
end)

local espButton = createButton("ESP", UDim2.new(0.5, 0, 0, 210), function()
    espEnabled = not espEnabled
    espStatus.Text = "ESP: " .. (espEnabled and "On" or "Off")
    
    -- Update all players' ESP visibility
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local billboardGui = player.Character:FindFirstChildOfClass("BillboardGui")
            if billboardGui then
                billboardGui.Enabled = espEnabled
            end
        end
    end
end)

local killScriptButton = createButton("Kill Script", UDim2.new(0.5, 0, 0, 270), function()
    -- Disable Aimbot and ESP
    aimbotEnabled = false
    espEnabled = false
    assistStatus.Text = "Aimbot: Off"
    espStatus.Text = "ESP: Off"
    
    -- Remove the entire GUI and kill the script
    screenGui:Destroy()
    localPlayer.PlayerScripts:ClearAllChildren()  -- Clear the script from player scripts
end)

local teamCheckButton = createButton("Check Team", UDim2.new(0.5, 0, 0, 330), function()
    local targetPlayer = getClosestPlayerToCrosshair()
    if targetPlayer then
        if localPlayer.Team and targetPlayer.Team then
            if localPlayer.Team == targetPlayer.Team then
                teamStatus.Text = "Team: Same Team"
            else
                teamStatus.Text = "Team: Different Team"
            end
        else
            teamStatus.Text = "Team: Invalid Target"
        end
    else
        teamStatus.Text = "Team: No Target"
    end
end)

-- Make the GUI draggable
local dragging = false
local dragStart = nil
local startPos = nil

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

-- Function to find the closest player to the crosshair
local function getClosestPlayerToCrosshair()
    local closestPlayer = nil
    local closestDistance = fovRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            -- Skip teammates if aimbot should not aim at them
            if localPlayer.Team and player.Team and localPlayer.Team == player.Team then
                continue
            end

            local head = player.Character:FindFirstChild("Head")
            if head then
                local headPosition, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local headScreenPosition = Vector2.new(headPosition.X, headPosition.Y)
                    local distance = (headScreenPosition - screenCenter).Magnitude

                    if distance < closestDistance and (head.Position - camera.CFrame.Position).Magnitude <= maxDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Function to aim at the closest player (Aimbot)
local function aimAtClosestPlayer()
    if not aimbotEnabled then return end

    local targetPlayer = getClosestPlayerToCrosshair()
    if targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
            local targetPosition = head.Position
            local currentCFrame = camera.CFrame
            local newCFrame = CFrame.new(currentCFrame.Position, targetPosition)

            -- Smoothly interpolate the camera's CFrame
            camera.CFrame = currentCFrame:Lerp(newCFrame, smoothness)
        end
    end
end

-- Function to create ESP for a player (BillboardGui)
local function createESP(player)
    if player == localPlayer then return end

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local head = character:WaitForChild("Head")

    -- Create a BillboardGui for ESP
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = head
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)  -- Position above the head
    billboardGui.AlwaysOnTop = true
    billboardGui.Enabled = espEnabled
    billboardGui.Parent = character

    -- Create a TextLabel for the ESP info
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboardGui
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 18
    textLabel.Text = player.Name

    -- Update ESP visibility based on distance
    RunService.RenderStepped:Connect(function()
        if character and humanoidRootPart then
            local distance = (humanoidRootPart.Position - camera.CFrame.Position).Magnitude
            if distance <= maxDistanceESP then
                textLabel.Text = player.Name .. "\n" .. tostring(math.floor(distance)) .. " studs"
                billboardGui.Enabled = espEnabled
            else
                billboardGui.Enabled = false
            end
        else
            billboardGui.Enabled = false
        end
    end)

    -- Clean up ESP when player leaves
    player.CharacterRemoving:Connect(function()
        billboardGui:Destroy()
    end)
end

-- Loop through all players and create ESP
for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

-- Main loop for Aimbot
RunService.RenderStepped:Connect(function()
    aimAtClosestPlayer()
end)

-- Keybinds for Aimbot, ESP, Team Check
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Toggle Aimbot with the "X" key
    if input.KeyCode == Enum.KeyCode.X then
        aimbotEnabled = not aimbotEnabled
        assistStatus.Text = "Aimbot: " .. (aimbotEnabled and "On" or "Off")
    end

    -- Toggle ESP with the "E" key
    if input.KeyCode == Enum.KeyCode.E then
        espEnabled = not espEnabled
        espStatus.Text = "ESP: " .. (espEnabled and "On" or "Off")

        -- Update all players' ESP visibility
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local billboardGui = player.Character:FindFirstChildOfClass("BillboardGui")
                if billboardGui then
                    billboardGui.Enabled = espEnabled
                end
            end
        end
    end

    -- Check teams with the "T" key
    if input.KeyCode == Enum.KeyCode.T then
        local targetPlayer = getClosestPlayerToCrosshair()
        if targetPlayer then
            if localPlayer.Team and targetPlayer.Team then
                if localPlayer.Team == targetPlayer.Team then
                    teamStatus.Text = "Team: Same Team"
                else
                    teamStatus.Text = "Team: Different Team"
                end
            else
                teamStatus.Text = "Team: Invalid Target"
            end
        else
            teamStatus.Text = "Team: No Target"
        end
    end
end)
