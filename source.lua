-- Attendre que le jeu soit chargé
if not game:IsLoaded() then
    game.Loaded:Wait()
end
wait(3)

local Config = {
    WindowName = "Cheat Arsenal ACE",
    Color = Color3.fromRGB(245, 81, 231),
    Keybind = Enum.KeyCode.RightControl
}

-- Charger la bibliothèque
local Library
local success, err = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Discord0000/BracketV3/main/Lib.lua"))()
end)
if not success then
    warn("Erreur bibliothèque: " .. err)
    return
end

-- Créer la fenêtre GUI
local Window = Library:CreateWindow(Config, game:GetService("CoreGui"))

-- Créer les onglets
local TabESP = Window:CreateTab("ESP")
local SectionESP1 = TabESP:CreateSection("Visuals")
local SectionESP2 = TabESP:CreateSection("Player Info")

local TabMBot = Window:CreateTab("M-Bot")
local SectionMBot = TabMBot:CreateSection("Aimbot")

local TabExtra = Window:CreateTab("Extra")
local SectionExtra1 = TabExtra:CreateSection("Mouvement")

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = game.Workspace.CurrentCamera

-- ESP Toggles
local ESP_Toggles = {
    Box2D = false,
    Name = false,
    Distance = false,
    HPBar = false,
    Rainbow = false,
    Transparency = true
}

-- Aimbot Toggles
local Aimbot_Toggles = {
    Aimbot = false,
    ShowFOV = false,
    AimPart = "Head",
    FOVSize = 200
}

-- Extra Toggles
local Extra_Toggles = {
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    Speed = false,
    SpeedValue = 25
}

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = Aimbot_Toggles.FOVSize
fovCircle.Filled = false
fovCircle.Visible = Aimbot_Toggles.ShowFOV
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Radius = Aimbot_Toggles.FOVSize
    fovCircle.Visible = Aimbot_Toggles.ShowFOV
end)

-- ESP Drawings
local ESP_Drawings = {}
local Colors = {
    Box = Color3.fromRGB(245, 81, 231),
    Text = Color3.fromRGB(255, 255, 255),
    HPBar = Color3.fromRGB(0, 255, 0)
}

local rainbowHue = 0
RunService.RenderStepped:Connect(function()
    if ESP_Toggles.Rainbow then
        rainbowHue = (rainbowHue + 0.05) % 1
        Colors.Box = Color3.fromHSV(rainbowHue, 1, 1)
    end
end)

-- Fonctions ESP
local function createBox2D()
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = Colors.Box
    box.Visible = false
    return box
end

local function createNameTag(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Name_" .. player.Name
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = ESP_Toggles.Transparency
    billboard.Enabled = false
    billboard.Adornee = nil
    billboard.Parent = game:GetService("CoreGui")
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Colors.Text
    text.Text = player.Name
    text.TextSize = 16
    text.Font = Enum.Font.SourceSansBold
    text.TextStrokeTransparency = 0.5
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.Parent = billboard
    
    return billboard
end

local function createDistanceTag(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Distance_" .. player.Name
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = ESP_Toggles.Transparency
    billboard.Enabled = false
    billboard.Adornee = nil
    billboard.Parent = game:GetService("CoreGui")
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Colors.Text
    text.Text = "0 studs"
    text.TextSize = 14
    text.Font = Enum.Font.SourceSans
    text.TextStrokeTransparency = 0.5
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.Parent = billboard
    
    return billboard
end

local function createHPBar(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_HPBar_" .. player.Name
    billboard.Size = UDim2.new(0, 60, 0, 6)  -- Barre plus fine
    billboard.StudsOffset = Vector3.new(0, -2.2, 0)  -- Position en bas de la box
    billboard.AlwaysOnTop = ESP_Toggles.Transparency
    billboard.Enabled = false
    billboard.Adornee = nil
    billboard.Parent = game:GetService("CoreGui")
    
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    background.BorderSizePixel = 1
    background.BorderColor3 = Color3.new(0, 0, 0)
    background.Parent = billboard
    
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.BackgroundColor3 = Colors.HPBar
    bar.BorderSizePixel = 0
    bar.Parent = billboard
    
    return billboard
end

-- Initialiser l'ESP
local function initializeESP(plr)
    if plr == player then return end
    
    if ESP_Drawings[plr] then
        for _, drawing in pairs(ESP_Drawings[plr]) do
            if drawing and drawing.Parent then
                drawing:Destroy()
            end
        end
    end
    
    local character = plr.Character
    if not character then
        plr.CharacterAdded:Connect(function()
            wait(1)
            initializeESP(plr)
        end)
        return
    end
    
    if not character:FindFirstChild("Humanoid") or not character:FindFirstChild("Head") then
        return
    end
    
    ESP_Drawings[plr] = {
        Box2D = createBox2D(),
        NameTag = createNameTag(plr),
        DistanceTag = createDistanceTag(plr),
        HPBar = createHPBar(plr)
    }
end

-- Initialiser les joueurs
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= player then
        spawn(function() initializeESP(plr) end)
    end
end

Players.PlayerAdded:Connect(function(plr)
    spawn(function() initializeESP(plr) end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if ESP_Drawings[plr] then
        for _, drawing in pairs(ESP_Drawings[plr]) do
            if drawing and drawing.Parent then
                drawing:Destroy()
            end
        end
        ESP_Drawings[plr] = nil
    end
end)

-- Mise à jour ESP
RunService.RenderStepped:Connect(function()
    for plr, drawings in pairs(ESP_Drawings) do
        local character = plr.Character
        if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("Head") then
            local humanoid = character.Humanoid
            local head = character.Head
            local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
            
            -- Mettre à jour les Adornees
            if drawings.NameTag then 
                drawings.NameTag.Adornee = head
                drawings.NameTag.Enabled = ESP_Toggles.Name
            end
            
            if drawings.DistanceTag then 
                drawings.DistanceTag.Adornee = head
                drawings.DistanceTag.Enabled = ESP_Toggles.Distance
            end
            
            if drawings.HPBar then 
                drawings.HPBar.Adornee = head
                drawings.HPBar.Enabled = ESP_Toggles.HPBar and humanoid.Health > 0
            end

            -- 2D Box
            if drawings.Box2D then
                if onScreen then
                    local height = math.abs((camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0)).Y - camera:WorldToViewportPoint(head.Position - Vector3.new(0, 2, 0)).Y))
                    local width = height * 0.6
                    
                    drawings.Box2D.Visible = ESP_Toggles.Box2D
                    drawings.Box2D.Position = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)
                    drawings.Box2D.Size = Vector2.new(width, height)
                    drawings.Box2D.Color = Colors.Box
                else
                    drawings.Box2D.Visible = false
                end
            end

            -- Distance
            if drawings.DistanceTag and drawings.DistanceTag.Enabled then
                local distance = (player.Character and player.Character:FindFirstChild("Head") and (player.Character.Head.Position - head.Position).Magnitude) or 0
                drawings.DistanceTag.TextLabel.Text = string.format("%.0f studs", distance)
            end

            -- HP Bar
            if drawings.HPBar and drawings.HPBar.Enabled then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                drawings.HPBar.Bar.Size = UDim2.new(healthPercent, 0, 1, 0)
                
                if healthPercent > 0.5 then
                    drawings.HPBar.Bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 0.25 then
                    drawings.HPBar.Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                else
                    drawings.HPBar.Bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
        else
            if drawings.Box2D then drawings.Box2D.Visible = false end
            if drawings.NameTag then drawings.NameTag.Enabled = false end
            if drawings.DistanceTag then drawings.DistanceTag.Enabled = false end
            if drawings.HPBar then drawings.HPBar.Enabled = false end
        end
    end
end)

-- Toggles ESP
SectionESP1:CreateToggle("2D Box", nil, function(State) ESP_Toggles.Box2D = State end)
SectionESP2:CreateToggle("Nom", nil, function(State) ESP_Toggles.Name = State end)
SectionESP2:CreateToggle("Distance", nil, function(State) ESP_Toggles.Distance = State end)
SectionESP2:CreateToggle("HP Bar", nil, function(State) ESP_Toggles.HPBar = State end)
SectionESP1:CreateToggle("Rainbow ESP", nil, function(State) ESP_Toggles.Rainbow = State end)
SectionESP1:CreateToggle("Transparency", nil, function(State) 
    ESP_Toggles.Transparency = State
    for _, drawings in pairs(ESP_Drawings) do
        if drawings.NameTag then drawings.NameTag.AlwaysOnTop = State end
        if drawings.DistanceTag then drawings.DistanceTag.AlwaysOnTop = State end
        if drawings.HPBar then drawings.HPBar.AlwaysOnTop = State end
    end
end)

-- Aimbot Logic
local isAiming = false

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Aimbot_Toggles.Aimbot then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
    end
end)

-- Fonction Aimbot corrigée
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = Aimbot_Toggles.FOVSize
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local humanoid = plr.Character.Humanoid
            if humanoid.Health > 0 then
                local aimPart = plr.Character:FindFirstChild(Aimbot_Toggles.AimPart)
                if aimPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(aimPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = plr
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Mise à jour de l'aimbot
RunService.RenderStepped:Connect(function()
    if isAiming and Aimbot_Toggles.Aimbot and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local closestPlayer = getClosestPlayer()
            if closestPlayer and closestPlayer.Character then
                local aimPart = closestPlayer.Character:FindFirstChild(Aimbot_Toggles.AimPart)
                if aimPart then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, aimPart.Position)
                end
            end
        end
    end
end)

-- Options Aimbot
SectionMBot:CreateToggle("Aimbot", nil, function(State) 
    Aimbot_Toggles.Aimbot = State 
end)

SectionMBot:CreateToggle("Show FOV", nil, function(State) 
    Aimbot_Toggles.ShowFOV = State 
end)

SectionMBot:CreateDropdown("Aim Part", {"Head", "UpperTorso", "HumanoidRootPart"}, function(String)
    Aimbot_Toggles.AimPart = String
end)

SectionMBot:CreateSlider("FOV Size", 50, 500, 200, true, function(Value)
    Aimbot_Toggles.FOVSize = Value
end)

-- Fonctions Extra
local flyConnection, bodyVelocity, bodyGyro
local keysPressed = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false,
    LeftShift = false
}

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keysPressed.W = true end
    if input.KeyCode == Enum.KeyCode.A then keysPressed.A = true end
    if input.KeyCode == Enum.KeyCode.S then keysPressed.S = true end
    if input.KeyCode == Enum.KeyCode.D then keysPressed.D = true end
    if input.KeyCode == Enum.KeyCode.Space then keysPressed.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftShift then keysPressed.LeftShift = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keysPressed.W = false end
    if input.KeyCode == Enum.KeyCode.A then keysPressed.A = false end
    if input.KeyCode == Enum.KeyCode.S then keysPressed.S = false end
    if input.KeyCode == Enum.KeyCode.D then keysPressed.D = false end
    if input.KeyCode == Enum.KeyCode.Space then keysPressed.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then keysPressed.LeftShift = false end
end)

local function startFly()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    if flyConnection then flyConnection:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.P = 1000
    bodyVelocity.Parent = rootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 1000
    bodyGyro.D = 50
    bodyGyro.Parent = rootPart
    
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not Extra_Toggles.Fly or not player.Character or not rootPart then return end
        
        bodyGyro.CFrame = camera.CFrame
        local direction = Vector3.new()
        local moving = false
        
        if keysPressed.W then
            direction = direction + (camera.CFrame.LookVector * Extra_Toggles.FlySpeed)
            moving = true
        end
        if keysPressed.S then
            direction = direction - (camera.CFrame.LookVector * Extra_Toggles.FlySpeed)
            moving = true
        end
        if keysPressed.D then
            direction = direction + (camera.CFrame.RightVector * Extra_Toggles.FlySpeed)
            moving = true
        end
        if keysPressed.A then
            direction = direction - (camera.CFrame.RightVector * Extra_Toggles.FlySpeed)
            moving = true
        end
        if keysPressed.Space then
            direction = direction + (Vector3.new(0, Extra_Toggles.FlySpeed, 0))
            moving = true
        end
        if keysPressed.LeftShift then
            direction = direction - (Vector3.new(0, Extra_Toggles.FlySpeed, 0))
            moving = true
        end
        
        bodyVelocity.Velocity = moving and direction or Vector3.new(0, 0, 0)
    end)
end

local function stopFly()
    if flyConnection then flyConnection:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
    end
end

-- Options Extra
SectionExtra1:CreateToggle("Fly", nil, function(State)
    Extra_Toggles.Fly = State
    if State then startFly() else stopFly() end
end)

SectionExtra1:CreateSlider("Vitesse Fly", 1, 100, 50, true, function(Value)
    Extra_Toggles.FlySpeed = Value
end)

SectionExtra1:CreateToggle("Noclip", nil, function(State)
    Extra_Toggles.Noclip = State
end)

SectionExtra1:CreateToggle("Speed", nil, function(State)
    Extra_Toggles.Speed = State
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = State and Extra_Toggles.SpeedValue or 16
        end
    end
end)

SectionExtra1:CreateSlider("Vitesse Marche", 16, 100, 25, true, function(Value)
    Extra_Toggles.SpeedValue = Value
    if Extra_Toggles.Speed and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end
end)

-- UI Toggle
SectionESP1:CreateToggle("UI Toggle", nil, function(State)
    Window:Toggle(State)
end):CreateKeybind(tostring(Config.Keybind):gsub("Enum.KeyCode.", ""), function(Key)
    Config.Keybind = Enum.KeyCode[Key]
end):SetState(true)

print("Script chargé avec succès!")
