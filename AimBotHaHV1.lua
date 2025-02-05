-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Aimbot settings
local aimbotEnabled = false
local fovRadius = 100
local maxDistance = 1000
local smoothness = 0.5

-- ESP settings
local espEnabled = false
local activeESP = {}

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local background = Instance.new("Frame")
background.Size = UDim2.new(0, 350, 0, 450)
background.Position = UDim2.new(0, 50, 0, 50)
background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
background.BorderSizePixel = 0
background.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = background

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "HaH Universal Aimbot V1"
titleLabel.Parent = background

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

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button

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
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    for _, server in pairs(servers.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, localPlayer)
            return
        end
    end
end)

local killButton = createButton("Kill Script", UDim2.new(0.5, 0, 0, 260), function()
    aimbotEnabled = false
    espEnabled = false
    for _, v in pairs(activeESP) do
        v:Destroy()
    end
    activeESP = {}
    screenGui:Destroy()
    script:Destroy()
end)

-- ESP Function
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Size = UDim2.new(0, 100, 0, 50)
            billboardGui.Adornee = player.Character.Head
            billboardGui.AlwaysOnTop = true
            billboardGui.Parent = player.Character

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.Text = player.Name
            nameLabel.TextSize = 16
            nameLabel.Parent = billboardGui

            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
            distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextColor3 = Color3.new(1, 1, 1)
            distanceLabel.TextSize = 14
            distanceLabel.Parent = billboardGui

            RunService.RenderStepped:Connect(function()
                if player.Character and player.Character:FindFirstChild("Head") then
                    local distance = (player.Character.Head.Position - localPlayer.Character.Head.Position).Magnitude
                    distanceLabel.Text = string.format("%.1f studs", distance)
                end
            end)

            activeESP[player] = billboardGui
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    if activeESP[player] then
        activeESP[player]:Destroy()
        activeESP[player] = nil
    end
end)

print("[HaH Universal Aimbot V1] Loaded successfully!")
