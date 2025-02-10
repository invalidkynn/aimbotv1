local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "HaH Universal Aimbot Hub V3",
   LoadingTitle = "🔫 Arsenal 💥",
   LoadingSubtitle = "by Kynn",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "DW"
   },
   Discord = {
      Enabled = true,
      Invite = "ADNEUJsGTV", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Key | Youtube Hub",
      Subtitle = "Key System",
      Note = "Key In Discord Server",
      FileName = "YoutubeHubKey1", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"https://pastebin.com/raw/AtgzSPWK"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("🔫 Aimbot", nil) -- Title, Image
local MainSection = MainTab:CreateSection("aimbot")

Rayfield:Notify({
   Title = "You executed the script!",
   Content = "Aimbot GUI V3",
   Duration = 5,
   Image = 13047715178,
   Actions = { -- Notification Buttons
      Ignore = {
         Name = "Okay!",
         Callback = function()
         print("The user tapped Okay!")
      end
   },
},
})

local Toggle = Tab:CreateToggle({
   Name = "Toggle Aimbot",
   CurrentValue = false,
   Flag = "aimbot1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
local Players = game:GetService("Players")
local Camera = game.Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AimFOV = 100  -- Field of view size
local AimSmoothness = 0.2  -- Smoothing factor
local AimbotEnabled = false  -- Toggle for aimbot

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = AimFOV
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255) -- White thin circle
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Function to check if a player is an enemy
local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

-- Get the closest visible enemy within the FOV
local function GetClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = AimFOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) then
            local character = player.Character
            if character and character:FindFirstChild("Head") then
                local head = character.Head
                local headPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPosition.X, headPosition.Y)).magnitude
                    
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Aim at the closest enemy smoothly
local function AimAt(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local targetPosition = head.Position
        
        -- Use a direct camera angle change
        local direction = (targetPosition - Camera.CFrame.Position).unit
        local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
        
        -- Smooth aim
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, AimSmoothness)
    end
end

-- Toggle Aimbot On/Off when "X" is pressed
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
        AimbotEnabled = not AimbotEnabled
        FOVCircle.Visible = AimbotEnabled
        
        if AimbotEnabled then
            print("Aimbot Enabled")
        else
            print("Aimbot Disabled")
        end
    end
end)

-- Main Aimbot Loop (Runs when enabled)
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    
    if AimbotEnabled then
        local closestEnemy = GetClosestEnemy()
        if closestEnemy then
            AimAt(closestEnemy)
        end
    end
end)


   end,
})

local ESPTab = Window:CreateTab("👀 ESP", nil) -- Title, Image
local ESPSection = ESPTab:CreateSection("ESP")

local Toggle = Tab:CreateToggle({
   Name = "Toggle ESP",
   CurrentValue = false,
   Flag = "ESP1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Drawing = Drawing or require("Drawing")

local boxes = {}
local nameTags = {}

local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function DrawBox(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        
        if onScreen then
            -- Remove old drawings
            if boxes[player] then boxes[player]:Remove() end
            if nameTags[player] then nameTags[player]:Remove() end
            
            -- Create new box
            local box = Drawing.new("Square")
            box.Size = Vector2.new(50, 50)
            box.Position = Vector2.new(screenPosition.X - 25, screenPosition.Y - 25)
            box.Color = Color3.new(1, 0, 0)
            box.Thickness = 2
            box.Filled = false
            box.Visible = true
            boxes[player] = box
            
            -- Create new name tag
            local nameTag = Drawing.new("Text")
            nameTag.Text = player.Name .. " (" .. math.floor((rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude) .. "m)"
            nameTag.Position = Vector2.new(screenPosition.X, screenPosition.Y - 30)
            nameTag.Color = Color3.new(1, 1, 1)
            nameTag.Size = 20
            nameTag.Visible = true
            nameTags[player] = nameTag
        else
            if boxes[player] then boxes[player]:Remove() boxes[player] = nil end
            if nameTags[player] then nameTags[player]:Remove() nameTags[player] = nil end
        end
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) then
            DrawBox(player)
        elseif boxes[player] then
            boxes[player]:Remove()
            boxes[player] = nil
            nameTags[player]:Remove()
            nameTags[player] = nil
        end
    end
end)

   end,
})

local MiscTab = Window:CreateTab("😈 Misc", nil) -- Title, Image
local MiscSection = MainTab:CreateSection("Miscellaneous")

local Button = MiscTab:CreateButton({
   Name = "Infinite Jump Toggle",
   Callback = function()
       --Toggles the infinite jump between on or off on every script run
_G.infinjump = not _G.infinjump

if _G.infinJumpStarted == nil then
	--Ensures this only runs once to save resources
	_G.infinJumpStarted = true
	
	--Notifies readiness
	game.StarterGui:SetCore("SendNotification", {Title="Youtube Hub"; Text="Infinite Jump Activated!"; Duration=5;})

	--The actual infinite jump
	local plr = game:GetService('Players').LocalPlayer
	local m = plr:GetMouse()
	m.KeyDown:connect(function(k)
		if _G.infinjump then
			if k:byte() == 32 then
			humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
			humanoid:ChangeState('Jumping')
			wait()
			humanoid:ChangeState('Seated')
			end
		end
	end)
end
   end,
})

local Slider = MiscTab:CreateSlider({
   Name = "🏃‍♀️ Walk-Speed",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderws", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Value)
   end,
})

local Slider = MiscTab:CreateSlider({
   Name = "🦘 Jump-Power",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderjp", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = (Value)
   end,
})
