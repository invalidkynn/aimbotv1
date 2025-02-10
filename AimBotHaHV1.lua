-- Load Rayfield UI Library (Only Once)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Main Window
local Window = Rayfield:CreateWindow({
   Name = "HaH Universal Aimbot Hub V3",
   LoadingTitle = "🔫 Arsenal 💥",
   LoadingSubtitle = "by Kynn",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = true, Invite = "ADNEUJsGTV", RememberJoins = true },
   KeySystem = false
})

-- Aimbot Tab
local MainTab = Window:CreateTab("🔫 Aimbot", nil)
local MainSection = MainTab:CreateSection("Aimbot")

-- Notify on execution
Rayfield:Notify({
   Title = "Script Executed!",
   Content = "Aimbot GUI V3",
   Duration = 5,
   Image = 13047715178,
   Actions = { Ignore = { Name = "Okay!", Callback = function() print("User acknowledged.") end }}
})

-- Services
local Players = game:GetService("Players")
local Camera = game.Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Settings
local AimFOV = 100
local AimSmoothness = 0.1
local AimbotEnabled = false
local AimbotEnabled = false
MainTab:CreateToggle({
   Name = "Toggle Aimbot",
   CurrentValue = false,
   Flag = "aimbot_toggle",
   Callback = function(Value)
       AimbotEnabled = Value
       FOVCircle.Visible = Value
   end
})
-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = AimFOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Function to check if player is an enemy
local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

-- Find closest enemy
local function GetClosestEnemy()
    local closestPlayer, shortestDistance = nil, AimFOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Aim at target
local function AimAt(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local targetPosition = head.Position
        local direction = (targetPosition - Camera.CFrame.Position).Unit
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction), AimSmoothness)
    end
end

-- Toggle Aimbot with X Key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.X and not gameProcessed then
        AimbotEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.X and not gameProcessed then
        AimbotEnabled = false
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if AimbotEnabled then
        local target = GetClosestEnemy()
        if target then AimAt(target) end
    end
end)



-- ESP Tab
local ESPTab = Window:CreateTab("👀 ESP", nil)
local ESPSection = ESPTab:CreateSection("ESP")

-- ESP Toggle
local ESPEnabled = false
ESPTab:CreateToggle({
   Name = "Toggle ESP",
   CurrentValue = false,
   Flag = "esp_toggle",
   Callback = function(Value)
       ESPEnabled = Value
   end
})

local ESPBoxes = {}
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and ESPEnabled and IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                if not ESPBoxes[player] then
                    ESPBoxes[player] = Drawing.new("Square")
                    ESPBoxes[player].Thickness = 2
                    ESPBoxes[player].Color = Color3.fromRGB(255, 0, 0)
                    ESPBoxes[player].Filled = false
                end
                ESPBoxes[player].Size = Vector2.new(50, 50)
                ESPBoxes[player].Position = Vector2.new(screenPosition.X - 25, screenPosition.Y - 25)
                ESPBoxes[player].Visible = true
            elseif ESPBoxes[player] then
                ESPBoxes[player].Visible = false
            end
        elseif ESPBoxes[player] then
            ESPBoxes[player]:Remove()
            ESPBoxes[player] = nil
        end
    end
end)

-- Misc Tab
local MiscTab = Window:CreateTab("😈 Misc", nil)
local MiscSection = MiscTab:CreateSection("Miscellaneous")

-- Infinite Jump
local InfiniteJumpEnabled = false
MiscTab:CreateButton({
   Name = "Toggle Infinite Jump",
   Callback = function()
       InfiniteJumpEnabled = not InfiniteJumpEnabled
       game.StarterGui:SetCore("SendNotification", {Title = "Youtube Hub", Text = "Infinite Jump Toggled!", Duration = 5})
       game:GetService("UserInputService").JumpRequest:Connect(function()
           if InfiniteJumpEnabled then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
       end)
   end
})

-- Walk Speed
MiscTab:CreateSlider({
   Name = "🏃‍♀️ Walk-Speed",
   Range = {16, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "slider_ws",
   Callback = function(Value)
       LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end
})

-- Jump Power
MiscTab:CreateSlider({
   Name = "🦘 Jump-Power",
   Range = {50, 350},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "slider_jp",
   Callback = function(Value)
       LocalPlayer.Character.Humanoid.JumpPower = Value
   end
})
