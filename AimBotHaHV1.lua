-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Aimbot Settings
local aimbotEnabled = false
local aimbotSmoothness = 0.2
local maxAimbotDistance = 500

-- ESP Settings
local espEnabled = false
local activeESP = {}

-- Function to check if two players are on the same team
local function isTeammate(player1, player2)
    if player1.Team and player2.Team then
        return player1.Team == player2.Team
    end
    return false
end

-- Aimbot Logic (Updated)
local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = maxAimbotDistance
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Check if the player is not a teammate
            if not isTeammate(LocalPlayer, player) then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestPlayer
end

-- Aimbot Movement
local function aimbotMovement()
    if aimbotEnabled then
        local closestPlayer = getClosestEnemy()
        if closestPlayer then
            local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
            local cameraPosition = Camera.CFrame.Position
            local direction = (targetPosition - cameraPosition).unit
            local targetCFrame = CFrame.new(cameraPosition, cameraPosition + direction)
            
            -- Smooth camera movement to the target
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, aimbotSmoothness)
        end
    end
end

-- ESP Function (Name & Distance)
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not activeESP[player] then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 150, 0, 50)
                    billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
                    billboard.AlwaysOnTop = true
                    billboard.StudsOffset = Vector3.new(0, 2, 0)

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.TextSize = 14
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.Text = player.Name
                    nameLabel.Parent = billboard

                    local distanceLabel = Instance.new("TextLabel")
                    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    distanceLabel.BackgroundTransparency = 1
                    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    distanceLabel.TextSize = 12
                    distanceLabel.Font = Enum.Font.Gotham
                    distanceLabel.Parent = billboard

                    activeESP[player] = { gui = billboard, label = distanceLabel }
                    billboard.Parent = player.Character
                end
            else
                if activeESP[player] then
                    activeESP[player].gui:Destroy()
                    activeESP[player] = nil
                end
            end
        end
    end
end

-- Update ESP distances
RunService.RenderStepped:Connect(function()
    if espEnabled then
        for player, data in pairs(activeESP) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                data.label.Text = "Distance: " .. distance .. "m"
            else
                data.gui:Destroy()
                activeESP[player] = nil
            end
        end
    end

    -- Aimbot functionality
    aimbotMovement()
end)

-- Clean up ESP when a player leaves
Players.PlayerRemoving:Connect(function(player)
    if activeESP[player] then
        activeESP[player].gui:Destroy()
        activeESP[player] = nil
    end
end)

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local background = Instance.new("Frame")
background.Size = UDim2.new(0, 350, 0, 450)
background.Position = UDim2.new(0, 50, 0, 50)
background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
background.BorderSizePixel = 0
background.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "HaH Universal Aimbot V3"
titleLabel.Parent = background

-- Make GUI Draggable
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

-- Function to create buttons
local function createButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0, 40)
    button.Position = position
    button.AnchorPoint = Vector2.new(0.5, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.Parent = background

    button.MouseButton1Click:Connect(callback)
    return button
end

-- Buttons
local aimbotButton = createButton("Toggle Aimbot", UDim2.new(0.5, 0, 0, 80), function()
    aimbotEnabled = not aimbotEnabled
end)

local espButton = createButton("Toggle ESP", UDim2.new(0.5, 0, 0, 140), function()
    espEnabled = not espEnabled
    updateESP()
end)

local serverHopButton = createButton("Server Hop", UDim2.new(0.5, 0, 0, 200), function()
    -- Server hopping logic here
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    for _, server in pairs(servers.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
            return
        end
    end
end)

local killButton = createButton("Kill Script", UDim2.new(0.5, 0, 0, 260), function()
    aimbotEnabled = false
    espEnabled = false
    for _, v in pairs(activeESP) do
        v.gui:Destroy()
    end
    activeESP = {}
    screenGui:Destroy()
    script:Destroy()
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        aimbotEnabled = not aimbotEnabled
    elseif input.KeyCode == Enum.KeyCode.Z then
        espEnabled = not espEnabled
        updateESP()
    elseif input.KeyCode == Enum.KeyCode.H then
        -- Call the server hop logic directly when key is pressed
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end
end)

print("[HaH Universal Aimbot V3] Loaded successfully!")
