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

-- Aimbot Settings
local AimFOV = 100  
local AimbotEnabled = false

-- Create the FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = AimFOV
FOVCircle.Color = Color3.fromRGB(255, 0, 0)  
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Function to find the closest enemy within the FOV
local function GetClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = AimFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPosition, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local mousePosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude

                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Function to aim at the target's head instantly
local function AimAt(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
    end
end

-- Toggle the aimbot with the X key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.X and not gameProcessed then
        AimbotEnabled = not AimbotEnabled
        FOVCircle.Visible = AimbotEnabled
    end
end)

-- Update the FOV Circle and perform aimbot actions
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if AimbotEnabled then
        local target = GetClosestEnemy()
        if target then
            AimAt(target)
        end
    end
end)

-- Create Aimbot Tab and Section
local MainTab = Window:CreateTab("🔫 Aimbot", nil)
MainTab:CreateToggle({
   Name = "Toggle Aimbot",
   CurrentValue = false,
   Flag = "aimbot_toggle",
   Callback = function(Value)
       AimbotEnabled = Value
       FOVCircle.Visible = Value
   end
})

-- ESP Section
local ESPTab = Window:CreateTab("👀 ESP", nil)
local ESPEnabled = false

-- ESP Toggle Function
local function ToggleESP(State)
    ESPEnabled = State

    if not ESPEnabled then
        -- Remove all ESPs
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local ESPBox = player.Character:FindFirstChild("ESPBox")
                if ESPBox then
                    ESPBox:Destroy()
                end
            end
        end
        return -- Stop execution if ESP is turned off
    end

    -- Enable ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not player.Character:FindFirstChild("ESPBox") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESPBox"
                billboard.Parent = player.Character:FindFirstChild("HumanoidRootPart")
                billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
                billboard.Size = UDim2.new(4, 0, 1, 0)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true

                local nameLabel = Instance.new("TextLabel", billboard)
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextStrokeTransparency = 0.5
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                nameLabel.Font = Enum.Font.SourceSansBold
                nameLabel.TextScaled = true

                -- Remove ESP when player dies
                player.Character:FindFirstChild("Humanoid").Died:Connect(function()
                    if billboard then
                        billboard:Destroy()
                    end
                end)
            end
        end
    end
end

-- ESP Toggle Button in UI
ESPTab:CreateToggle({
   Name = "Toggle ESP",
   CurrentValue = false,
   Flag = "esp_toggle",
   Callback = ToggleESP
})


-- Misc Tab
local MiscTab = Window:CreateTab("😈 Misc", nil)

local InfiniteJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

MiscTab:CreateButton({
   Name = "Toggle Infinite Jump",
   Callback = function()
       InfiniteJumpEnabled = not InfiniteJumpEnabled
       game.StarterGui:SetCore("SendNotification", {Title = "HaH Hub", Text = "Infinite Jump Toggled!", Duration = 5})
   end
})

MiscTab:CreateSlider({
   Name = "🏃‍♀️ Walk-Speed",
   Range = {16, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "slider_ws",
   Callback = function(Value)
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
           LocalPlayer.Character.Humanoid.WalkSpeed = Value
       end
   end
})

MiscTab:CreateSlider({
   Name = "🦘 Jump-Power",
   Range = {50, 350},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "slider_jp",
   Callback = function(Value)
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
           LocalPlayer.Character.Humanoid.JumpPower = Value
       end
   end
})
