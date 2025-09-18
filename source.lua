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
local SectionESP3 = TabESP:CreateSection("Filtres")
local SectionESP4 = TabESP:CreateSection("Skeleton")

local TabMBot = Window:CreateTab("M-Bot")
local SectionMBot = TabMBot:CreateSection("Aimbot")
local SectionTrigger = TabMBot:CreateSection("Trigger Bot")
local SectionFire = TabMBot:CreateSection("Fire Modifiers")

local TabHVH = Window:CreateTab("HVH")
local SectionHVH1 = TabHVH:CreateSection("Combat")
local SectionHVH2 = TabHVH:CreateSection("Mouvement")
local SectionHVH3 = TabHVH:CreateSection("Visuals")

local TabExtra = Window:CreateTab("Extra")
local SectionExtra1 = TabExtra:CreateSection("Mouvement")
local SectionExtra2 = TabExtra:CreateSection("Téléportation")
local SectionExtra3 = TabExtra:CreateSection("Autres")

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
    Transparency = true,
    EnemiesOnly = true,
    Skeleton = false,
    Snaplines = false,
    HealthText = false,
    Weapon = false,
    Chams = false,
    Outlines = false
}

-- Aimbot Toggles
local Aimbot_Toggles = {
    Aimbot = false,
    ShowFOV = false,
    AimPart = "Head",
    FOVSize = 200,
    TeamCheck = true,
    TriggerBot = false,
    TriggerDelay = 0.1,
    RapidFire = false,
    NoFireDelay = false,
    FastFire = false,
    Smoothness = 1,
    Prediction = false,
    PredictionAmount = 0.14
}

-- HVH Toggles
local HVH_Toggles = {
    ChangeFOV = false,
    FOVValue = 120,
    SpeedHack = false,
    SpeedHackValue = 2,
    ThirdPerson = false,
    ThirdPersonDistance = 10,
    AntiAim = false,
    SpinBot = false,
    SpinSpeed = 5,
    FakeLag = false,
    FakeLagAmount = 100,
    Desync = false,
    DesyncAmount = 0.5
}

-- Extra Toggles
local Extra_Toggles = {
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    Speed = false,
    SpeedValue = 25,
    TPtoPlayer = false,
    AutoFarm = false,
    InfiniteJump = false,
    NoRecoil = false,
    NoSpread = false,
    FullBright = false
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
    HPBar = Color3.fromRGB(0, 255, 0),
    Skeleton = Color3.fromRGB(255, 255, 255),
    Snapline = Color3.fromRGB(255, 0, 0),
    Chams = Color3.fromRGB(245, 81, 231)
}

local rainbowHue = 0
RunService.RenderStepped:Connect(function()
    if ESP_Toggles.Rainbow then
        rainbowHue = (rainbowHue + 0.05) % 1
        Colors.Box = Color3.fromHSV(rainbowHue, 1, 1)
        Colors.Skeleton = Color3.fromHSV(rainbowHue, 1, 1)
        Colors.Snapline = Color3.fromHSV(rainbowHue, 1, 1)
        Colors.Chams = Color3.fromHSV(rainbowHue, 1, 1)
    end
end)

-- Fonction pour vérifier si un joueur est ennemi
local function isEnemy(player)
    if not Aimbot_Toggles.TeamCheck and not ESP_Toggles.EnemiesOnly then
        return true
    end
    
    local localPlayer = Players.LocalPlayer
    if player == localPlayer then
        return false
    end
    
    if game:GetService("ReplicatedStorage"):FindFirstChild("GetPlayerTeam") then
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage").GetPlayerTeam:InvokeServer(localPlayer) ~= 
                   game:GetService("ReplicatedStorage").GetPlayerTeam:InvokeServer(player)
        end)
        if success then
            return result
        end
    end
    
    if player.Team and localPlayer.Team then
        return player.Team ~= localPlayer.Team
    end
    
    if player.Character and localPlayer.Character then
        local enemyShirt = player.Character:FindFirstChild("Shirt")
        local localShirt = localPlayer.Character:FindFirstChild("Shirt")
        
        if enemyShirt and localShirt then
            return enemyShirt.ShirtTemplate ~= localShirt.ShirtTemplate
        end
        
        local enemyTorso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
        local localTorso = localPlayer.Character:FindFirstChild("UpperTorso") or localPlayer.Character:FindFirstChild("Torso")
        
        if enemyTorso and localTorso and enemyTorso:FindFirstChild("BodyColors") and localTorso:FindFirstChild("BodyColors") then
            return enemyTorso.BodyColors.HeadColor3 ~= localTorso.BodyColors.HeadColor3
        end
    end
    
    return true
end

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
    billboard.Size = UDim2.new(0, 60, 0, 6)
    billboard.StudsOffset = Vector3.new(0, -2.2, 0)
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

local function createHealthText(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_HealthText_" .. player.Name
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.AlwaysOnTop = ESP_Toggles.Transparency
    billboard.Enabled = false
    billboard.Adornee = nil
    billboard.Parent = game:GetService("CoreGui")
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Colors.Text
    text.Text = "100 HP"
    text.TextSize = 14
    text.Font = Enum.Font.SourceSans
    text.TextStrokeTransparency = 0.5
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.Parent = billboard
    
    return billboard
end

local function createWeaponText(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Weapon_" .. player.Name
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 0.5, 0)
    billboard.AlwaysOnTop = ESP_Toggles.Transparency
    billboard.Enabled = false
    billboard.Adornee = nil
    billboard.Parent = game:GetService("CoreGui")
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Colors.Text
    text.Text = "No Weapon"
    text.TextSize = 14
    text.Font = Enum.Font.SourceSans
    text.TextStrokeTransparency = 0.5
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.Parent = billboard
    
    return billboard
end

local function createSnapline(player)
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Colors.Snapline
    line.Visible = false
    return line
end

local function createSkeletonLine()
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Colors.Skeleton
    line.Visible = false
    return line
end

-- Initialiser l'ESP
local function initializeESP(plr)
    if plr == player then return end
    
    if ESP_Drawings[plr] then
        if ESP_Drawings[plr].Box2D then
            pcall(function() ESP_Drawings[plr].Box2D:Remove() end)
        end
        if ESP_Drawings[plr].NameTag then
            pcall(function() ESP_Drawings[plr].NameTag:Destroy() end)
        end
        if ESP_Drawings[plr].DistanceTag then
            pcall(function() ESP_Drawings[plr].DistanceTag:Destroy() end)
        end
        if ESP_Drawings[plr].HPBar then
            pcall(function() ESP_Drawings[plr].HPBar:Destroy() end)
        end
        if ESP_Drawings[plr].HealthText then
            pcall(function() ESP_Drawings[plr].HealthText:Destroy() end)
        end
        if ESP_Drawings[plr].WeaponText then
            pcall(function() ESP_Drawings[plr].WeaponText:Destroy() end)
        end
        if ESP_Drawings[plr].Snapline then
            pcall(function() ESP_Drawings[plr].Snapline:Remove() end)
        end
        if ESP_Drawings[plr].Skeleton then
            for _, line in pairs(ESP_Drawings[plr].Skeleton) do
                pcall(function() line:Remove() end)
            end
        end
        if ESP_Drawings[plr].Chams then
            for _, part in pairs(ESP_Drawings[plr].Chams) do
                pcall(function() part:Destroy() end)
            end
        end
        if ESP_Drawings[plr].Outlines then
            for _, part in pairs(ESP_Drawings[plr].Outlines) do
                pcall(function() part:Destroy() end)
            end
        end
        ESP_Drawings[plr] = nil
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
    
    -- Créer les dessins ESP
    ESP_Drawings[plr] = {
        Box2D = createBox2D(),
        NameTag = createNameTag(plr),
        DistanceTag = createDistanceTag(plr),
        HPBar = createHPBar(plr),
        HealthText = createHealthText(plr),
        WeaponText = createWeaponText(plr),
        Snapline = createSnapline(plr),
        Skeleton = {},
        Chams = {},
        Outlines = {}
    }
    
    -- Créer les lignes du squelette
    local skeletonConnections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"UpperTorso", "RightUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LowerTorso", "RightUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"}
    }
    
    for _, connection in pairs(skeletonConnections) do
        table.insert(ESP_Drawings[plr].Skeleton, createSkeletonLine())
    end
    
    -- Créer les Chams et Outlines
    for _, partName in pairs({"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", 
                             "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand", 
                             "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", 
                             "LeftFoot", "RightFoot"}) do
        local part = character:FindFirstChild(partName)
        if part then
            -- Chams
            local cham = Instance.new("BoxHandleAdornment")
            cham.Name = "Cham_" .. partName
            cham.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
            cham.Color3 = Colors.Chams
            cham.Transparency = 0.5
            cham.Adornee = part
            cham.AlwaysOnTop = true
            cham.ZIndex = 1
            cham.Visible = false
            cham.Parent = game:GetService("CoreGui")
            
            table.insert(ESP_Drawings[plr].Chams, cham)
            
            -- Outlines
            local outline = Instance.new("SelectionBox")
            outline.Name = "Outline_" .. partName
            outline.Color3 = Colors.Chams
            outline.Transparency = 0.5
            outline.Adornee = part
            outline.LineThickness = 0.05
            outline.Visible = false
            outline.Parent = game:GetService("CoreGui")
            
            table.insert(ESP_Drawings[plr].Outlines, outline)
        end
    end
end

-- Nettoyer l'ESP complètement
local function cleanUpESP()
    for plr, drawings in pairs(ESP_Drawings) do
        if drawings.Box2D then
            pcall(function() drawings.Box2D:Remove() end)
        end
        if drawings.NameTag then
            pcall(function() drawings.NameTag:Destroy() end)
        end
        if drawings.DistanceTag then
            pcall(function() drawings.DistanceTag:Destroy() end)
        end
        if drawings.HPBar then
            pcall(function() drawings.HPBar:Destroy() end)
        end
        if drawings.HealthText then
            pcall(function() drawings.HealthText:Destroy() end)
        end
        if drawings.WeaponText then
            pcall(function() drawings.WeaponText:Destroy() end)
        end
        if drawings.Snapline then
            pcall(function() drawings.Snapline:Remove() end)
        end
        if drawings.Skeleton then
            for _, line in pairs(drawings.Skeleton) do
                pcall(function() line:Remove() end)
            end
        end
        if drawings.Chams then
            for _, cham in pairs(drawings.Chams) do
                pcall(function() cham:Destroy() end)
            end
        end
        if drawings.Outlines then
            for _, outline in pairs(drawings.Outlines) do
                pcall(function() outline:Destroy() end)
            end
        end
    end
    ESP_Drawings = {}
end

-- Réinitialiser l'ESP
local function resetESP()
    cleanUpESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            spawn(function() initializeESP(plr) end)
        end
    end
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
        if ESP_Drawings[plr].Box2D then
            pcall(function() ESP_Drawings[plr].Box2D:Remove() end)
        end
        if ESP_Drawings[plr].NameTag then
            pcall(function() ESP_Drawings[plr].NameTag:Destroy() end)
        end
        if ESP_Drawings[plr].DistanceTag then
            pcall(function() ESP_Drawings[plr].DistanceTag:Destroy() end)
        end
        if ESP_Drawings[plr].HPBar then
            pcall(function() ESP_Drawings[plr].HPBar:Destroy() end)
        end
        if ESP_Drawings[plr].HealthText then
            pcall(function() ESP_Drawings[plr].HealthText:Destroy() end)
        end
        if ESP_Drawings[plr].WeaponText then
            pcall(function() ESP_Drawings[plr].WeaponText:Destroy() end)
        end
        if ESP_Drawings[plr].Snapline then
            pcall(function() ESP_Drawings[plr].Snapline:Remove() end)
        end
        if ESP_Drawings[plr].Skeleton then
            for _, line in pairs(ESP_Drawings[plr].Skeleton) do
                pcall(function() line:Remove() end)
            end
        end
        if ESP_Drawings[plr].Chams then
            for _, cham in pairs(ESP_Drawings[plr].Chams) do
                pcall(function() cham:Destroy() end)
            end
        end
        if ESP_Drawings[plr].Outlines then
            for _, outline in pairs(ESP_Drawings[plr].Outlines) do
                pcall(function() outline:Destroy() end)
            end
        end
        ESP_Drawings[plr] = nil
    end
end)

-- Mise à jour ESP avec filtrage ennemi/allié
RunService.RenderStepped:Connect(function()
    for plr, drawings in pairs(ESP_Drawings) do
        local character = plr.Character
        
        if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("Head") then
            local humanoid = character.Humanoid
            local head = character.Head
            local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
            
            local shouldShow = true
            if ESP_Toggles.EnemiesOnly then
                shouldShow = isEnemy(plr)
            end
            
            -- Mettre à jour les tags
            if drawings.NameTag then 
                drawings.NameTag.Adornee = head
                drawings.NameTag.Enabled = ESP_Toggles.Name and humanoid.Health > 0 and shouldShow
            end
            
            if drawings.DistanceTag then 
                drawings.DistanceTag.Adornee = head
                drawings.DistanceTag.Enabled = ESP_Toggles.Distance and humanoid.Health > 0 and shouldShow
            end
            
            if drawings.HPBar then 
                drawings.HPBar.Adornee = head
                drawings.HPBar.Enabled = ESP_Toggles.HPBar and humanoid.Health > 0 and shouldShow
            end
            
            if drawings.HealthText then 
                drawings.HealthText.Adornee = head
                drawings.HealthText.Enabled = ESP_Toggles.HealthText and humanoid.Health > 0 and shouldShow
                if drawings.HealthText.Enabled then
                    drawings.HealthText.TextLabel.Text = string.format("%.0f HP", humanoid.Health)
                end
            end
            
            if drawings.WeaponText then 
                drawings.WeaponText.Adornee = head
                drawings.WeaponText.Enabled = ESP_Toggles.Weapon and humanoid.Health > 0 and shouldShow
                if drawings.WeaponText.Enabled then
                    local tool = character:FindFirstChildOfClass("Tool")
                    drawings.WeaponText.TextLabel.Text = tool and tool.Name or "No Weapon"
                end
            end

            -- Mettre à jour la Box2D
            if drawings.Box2D then
                if onScreen and humanoid.Health > 0 and shouldShow then
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

            -- Mettre à jour la distance
            if drawings.DistanceTag and drawings.DistanceTag.Enabled then
                local distance = (player.Character and player.Character:FindFirstChild("Head") and (player.Character.Head.Position - head.Position).Magnitude) or 0
                drawings.DistanceTag.TextLabel.Text = string.format("%.0f studs", distance)
            end

            -- Mettre à jour la barre de vie
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
            
            -- Mettre à jour les Snaplines
            if drawings.Snapline then
                if onScreen and humanoid.Health > 0 and shouldShow and ESP_Toggles.Snaplines then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local rootScreenPos = camera:WorldToViewportPoint(rootPart.Position)
                        drawings.Snapline.Visible = true
                        drawings.Snapline.From = Vector2.new(rootScreenPos.X, rootScreenPos.Y)
                        drawings.Snapline.To = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        drawings.Snapline.Color = Colors.Snapline
                    else
                        drawings.Snapline.Visible = false
                    end
                else
                    drawings.Snapline.Visible = false
                end
            end
            
            -- Mettre à jour le Squelette
            if drawings.Skeleton and ESP_Toggles.Skeleton and onScreen and humanoid.Health > 0 and shouldShow then
                local skeletonConnections = {
                    {"Head", "UpperTorso"},
                    {"UpperTorso", "LowerTorso"},
                    {"UpperTorso", "LeftUpperArm"},
                    {"UpperTorso", "RightUpperArm"},
                    {"LeftUpperArm", "LeftLowerArm"},
                    {"LeftLowerArm", "LeftHand"},
                    {"RightUpperArm", "RightLowerArm"},
                    {"RightLowerArm", "RightHand"},
                    {"LowerTorso", "LeftUpperLeg"},
                    {"LowerTorso", "RightUpperLeg"},
                    {"LeftUpperLeg", "LeftLowerLeg"},
                    {"LeftLowerLeg", "LeftFoot"},
                    {"RightUpperLeg", "RightLowerLeg"},
                    {"RightLowerLeg", "RightFoot"}
                }
                
                for i, connection in pairs(skeletonConnections) do
                    local part1 = character:FindFirstChild(connection[1])
                    local part2 = character:FindFirstChild(connection[2])
                    
                    if part1 and part2 and drawings.Skeleton[i] then
                        local pos1, vis1 = camera:WorldToViewportPoint(part1.Position)
                        local pos2, vis2 = camera:WorldToViewportPoint(part2.Position)
                        
                        if vis1 and vis2 then
                            drawings.Skeleton[i].Visible = true
                            drawings.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                            drawings.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                            drawings.Skeleton[i].Color = Colors.Skeleton
                        else
                            drawings.Skeleton[i].Visible = false
                        end
                    elseif drawings.Skeleton[i] then
                        drawings.Skeleton[i].Visible = false
                    end
                end
            elseif drawings.Skeleton then
                for _, line in pairs(drawings.Skeleton) do
                    line.Visible = false
                end
            end
            
            -- Mettre à jour les Chams et Outlines
            if (ESP_Toggles.Chams or ESP_Toggles.Outlines) and onScreen and humanoid.Health > 0 and shouldShow then
                for _, cham in pairs(drawings.Chams) do
                    cham.Visible = ESP_Toggles.Chams
                    cham.Color3 = Colors.Chams
                end
                
                for _, outline in pairs(drawings.Outlines) do
                    outline.Visible = ESP_Toggles.Outlines
                    outline.Color3 = Colors.Chams
                end
            else
                for _, cham in pairs(drawings.Chams) do
                    cham.Visible = false
                end
                
                for _, outline in pairs(drawings.Outlines) do
                    outline.Visible = false
                end
            end
        else
            -- Cacher tous les éléments si le joueur n'est pas visible
            if drawings.Box2D then drawings.Box2D.Visible = false end
            if drawings.NameTag then drawings.NameTag.Enabled = false end
            if drawings.DistanceTag then drawings.DistanceTag.Enabled = false end
            if drawings.HPBar then drawings.HPBar.Enabled = false end
            if drawings.HealthText then drawings.HealthText.Enabled = false end
            if drawings.WeaponText then drawings.WeaponText.Enabled = false end
            if drawings.Snapline then drawings.Snapline.Visible = false end
            if drawings.Skeleton then
                for _, line in pairs(drawings.Skeleton) do
                    line.Visible = false
                end
            end
            if drawings.Chams then
                for _, cham in pairs(drawings.Chams) do
                    cham.Visible = false
                end
            end
            if drawings.Outlines then
                for _, outline in pairs(drawings.Outlines) do
                    outline.Visible = false
                end
            end
            
            -- Nettoyer si le joueur a quitté
            if not plr or not plr.Parent then
                if drawings.Box2D then pcall(function() drawings.Box2D:Remove() end) end
                if drawings.NameTag then pcall(function() drawings.NameTag:Destroy() end) end
                if drawings.DistanceTag then pcall(function() drawings.DistanceTag:Destroy() end) end
                if drawings.HPBar then pcall(function() drawings.HPBar:Destroy() end) end
                if drawings.HealthText then pcall(function() drawings.HealthText:Destroy() end) end
                if drawings.WeaponText then pcall(function() drawings.WeaponText:Destroy() end) end
                if drawings.Snapline then pcall(function() drawings.Snapline:Remove() end) end
                if drawings.Skeleton then
                    for _, line in pairs(drawings.Skeleton) do
                        pcall(function() line:Remove() end)
                    end
                end
                if drawings.Chams then
                    for _, cham in pairs(drawings.Chams) do
                        pcall(function() cham:Destroy() end)
                    end
                end
                if drawings.Outlines then
                    for _, outline in pairs(drawings.Outlines) do
                        pcall(function() outline:Destroy() end)
                    end
                end
                ESP_Drawings[plr] = nil
            end
        end
    end
end)

-- Toggles ESP
SectionESP1:CreateToggle("2D Box", nil, function(State) 
    ESP_Toggles.Box2D = State 
    if not State then
        for _, drawings in pairs(ESP_Drawings) do
            if drawings.Box2D then
                drawings.Box2D.Visible = false
            end
        end
    end
end)

SectionESP2:CreateToggle("Nom", nil, function(State) 
    ESP_Toggles.Name = State 
    if not State then
        for _, drawings in pairs(ESP_Drawings) do
            if drawings.NameTag then
                drawings.NameTag.Enabled = false
            end
        end
    end
end)

SectionESP2:CreateToggle("Distance", nil, function(State) 
    ESP_Toggles.Distance = State 
    if not State then
        for _, drawings in pairs(ESP_Drawings) do
            if drawings.DistanceTag then
                drawings.DistanceTag.Enabled = false
            end
        end
    end
end)

SectionESP2:CreateToggle("HP Bar", nil, function(State) 
    ESP_Toggles.HPBar = State 
    if not State then
        for _, drawings in pairs(ESP_Drawings) do
            if drawings.HPBar then
                drawings.HPBar.Enabled = false
            end
        end
    end
end)

SectionESP2:CreateToggle("Health Text", nil, function(State) 
    ESP_Toggles.HealthText = State 
    if not State then
        for _, drawings in pairs(ESP_Drawings) do
            if drawings.HealthText then
                drawings.HealthText.Enabled = false
            end
        end
    end
end)

SectionESP2:CreateToggle("Weapon", nil, function(State) 
    ESP_Toggles.Weapon = State 
    if not State then
        for _, drawings in pairs(ESP_Drawings) do
            if drawings.WeaponText then
                drawings.WeaponText.Enabled = false
            end
        end
    end
end)

SectionESP1:CreateToggle("Rainbow ESP", nil, function(State) 
    ESP_Toggles.Rainbow = State 
end)

SectionESP1:CreateToggle("Transparency", nil, function(State) 
    ESP_Toggles.Transparency = State
    for _, drawings in pairs(ESP_Drawings) do
        if drawings.NameTag then drawings.NameTag.AlwaysOnTop = State end
        if drawings.DistanceTag then drawings.DistanceTag.AlwaysOnTop = State end
        if drawings.HPBar then drawings.HPBar.AlwaysOnTop = State end
        if drawings.HealthText then drawings.HealthText.AlwaysOnTop = State end
        if drawings.WeaponText then drawings.WeaponText.AlwaysOnTop = State end
    end
end)

SectionESP1:CreateToggle("Chams", nil, function(State) 
    ESP_Toggles.Chams = State 
    if not State then
        for _, drawings in pairs(ESP_Drawings) do
            if drawings.Chams then
                for _, cham in pairs(drawings.Chams) do
                    cham.Visible = false
                end
            end
        end
    end
end)

SectionESP1:CreateToggle("Outlines", nil, function(State) 
    ESP_Toggles.Outlines = State 
    if not State then
        for _, drawings in pairs(ESP_Drawings) do
            if drawings.Outlines then
                for _, outline in pairs(drawings.Outlines) do
                    outline.Visible = false
                end
            end
        end
    end
end)

SectionESP4:CreateToggle("Skeleton", nil, function(State) 
    ESP_Toggles.Skeleton = State 
    if not State then
        for _, drawings in pairs(ESP_Drawings) do
            if drawings.Skeleton then
                for _, line in pairs(drawings.Skeleton) do
                    line.Visible = false
                end
            end
        end
    end
end)

SectionESP4:CreateToggle("Snaplines", nil, function(State) 
    ESP_Toggles.Snaplines = State 
    if not State then
        for _, drawings in pairs(ESP_Drawings) do
            if drawings.Snapline then
                drawings.Snapline.Visible = false
            end
        end
    end
end)

SectionESP3:CreateToggle("Ennemis Seulement", nil, function(State)
    ESP_Toggles.EnemiesOnly = State
end)

SectionESP1:CreateButton("Reset ESP", function()
    resetESP()
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

-- Fonction Aimbot avec Team Check
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = Aimbot_Toggles.FOVSize
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and isEnemy(plr) and plr.Character and plr.Character:FindFirstChild("Humanoid") then
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

-- Aimbot Connection avec Smoothness
local aimbotConnection
local function startAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
    end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if isAiming and Aimbot_Toggles.Aimbot and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local closestPlayer = getClosestPlayer()
                if closestPlayer and closestPlayer.Character then
                    local aimPart = closestPlayer.Character:FindFirstChild(Aimbot_Toggles.AimPart)
                    if aimPart then
                        -- Prédiction de mouvement
                        local targetPosition = aimPart.Position
                        if Aimbot_Toggles.Prediction then
                            local velocity = aimPart.Velocity or Vector3.new(0, 0, 0)
                            targetPosition = targetPosition + (velocity * Aimbot_Toggles.PredictionAmount)
                        end
                        
                        -- Smooth aim
                        local currentCFrame = camera.CFrame
                        local targetCFrame = CFrame.new(camera.CFrame.Position, targetPosition)
                        
                        if Aimbot_Toggles.Smoothness > 1 then
                            camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / Aimbot_Toggles.Smoothness)
                        else
                            camera.CFrame = targetCFrame
                        end
                    end
                end
            end
        end
    end)
end

local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- Options Aimbot
SectionMBot:CreateToggle("Aimbot", nil, function(State) 
    Aimbot_Toggles.Aimbot = State 
    if State then
        startAimbot()
    else
        stopAimbot()
    end
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

SectionMBot:CreateSlider("Smoothness", 1, 10, 1, true, function(Value)
    Aimbot_Toggles.Smoothness = Value
end)

SectionMBot:CreateToggle("Team Check", nil, function(State)
    Aimbot_Toggles.TeamCheck = State
end)

SectionMBot:CreateToggle("Prediction", nil, function(State)
    Aimbot_Toggles.Prediction = State
end)

SectionMBot:CreateSlider("Prediction Amount", 0.1, 0.5, 0.14, false, function(Value)
    Aimbot_Toggles.PredictionAmount = Value
end)

-- Rapid Fire System
local rapidFireHooks = {}
local originalFireRates = {}

local function modifyWeaponFireRate(tool)
    if not tool or rapidFireHooks[tool] then return end
    
    for _, module in pairs(tool:GetDescendants()) do
        if module:IsA("ModuleScript") then
            local success, required = pcall(function() return require(module) end)
            if success and type(required) == "table" then
                originalFireRates[module] = {
                    FireRate = required.FireRate,
                    AutoFireRate = required.AutoFireRate,
                    SemiFireRate = required.SemiFireRate,
                    FireDelay = required.FireDelay,
                    Delay = required.Delay
                }
                
                if Aimbot_Toggles.RapidFire or Aimbot_Toggles.FastFire then
                    if required.FireRate then required.FireRate = 0.01 end
                    if required.AutoFireRate then required.AutoFireRate = 0.01 end
                    if required.SemiFireRate then required.SemiFireRate = 0.01 end
                end
                
                if Aimbot_Toggles.NoFireDelay then
                    if required.FireDelay then required.FireDelay = 0 end
                    if required.Delay then required.Delay = 0 end
                end
            end
        end
    end
    rapidFireHooks[tool] = true
end

local function restoreWeaponFireRate(tool)
    if not tool then return end
    
    for module, originalValues in pairs(originalFireRates) do
        if module and module.Parent then
            local success, required = pcall(function() return require(module) end)
            if success and type(required) == "table" then
                if originalValues.FireRate then required.FireRate = originalValues.FireRate end
                if originalValues.AutoFireRate then required.AutoFireRate = originalValues.AutoFireRate end
                if originalValues.SemiFireRate then required.SemiFireRate = originalValues.SemiFireRate end
                if originalValues.FireDelay then required.FireDelay = originalValues.FireDelay end
                if originalValues.Delay then required.Delay = originalValues.Delay end
            end
        end
    end
    rapidFireHooks[tool] = nil
end

local function setupWeaponMonitoring()
    if player.Character then
        player.Character.ChildAdded:Connect(function(tool)
            if tool:IsA("Tool") then
                wait(0.5)
                modifyWeaponFireRate(tool)
            end
        end)
        
        player.Character.ChildRemoved:Connect(function(tool)
            if tool:IsA("Tool") then
                restoreWeaponFireRate(tool)
            end
        end)
        
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                modifyWeaponFireRate(tool)
            end
        end
    end
end

setupWeaponMonitoring()
player.CharacterAdded:Connect(function()
    wait(1)
    setupWeaponMonitoring()
end)

-- Trigger Bot
local triggerBotConnection
local lastTriggerTime = 0

local function startTriggerBot()
    if triggerBotConnection then
        triggerBotConnection:Disconnect()
    end
    
    triggerBotConnection = RunService.RenderStepped:Connect(function()
        if Aimbot_Toggles.TriggerBot and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local tool = player.Character:FindFirstChildOfClass("Tool")
            
            if humanoid and humanoid.Health > 0 and tool and tick() - lastTriggerTime > Aimbot_Toggles.TriggerDelay then
                local closestPlayer = getClosestPlayer()
                if closestPlayer and closestPlayer.Character then
                    local aimPart = closestPlayer.Character:FindFirstChild(Aimbot_Toggles.AimPart)
                    if aimPart then
                        for _, v in pairs(tool:GetDescendants()) do
                            if v:IsA("RemoteEvent") and (v.Name:find("Fire") or v.Name:find("Shoot") or v.Name:find("Attack")) then
                                pcall(function()
                                    v:FireServer()
                                end)
                                lastTriggerTime = tick()
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopTriggerBot()
    if triggerBotConnection then
        triggerBotConnection:Disconnect()
        triggerBotConnection = nil
    end
end

-- Options Trigger Bot
SectionTrigger:CreateToggle("Trigger Bot", nil, function(State)
    Aimbot_Toggles.TriggerBot = State
    if State then
        startTriggerBot()
    else
        stopTriggerBot()
    end
end):AddToolTip("Tire automatiquement quand un ennemi est dans le FOV")

SectionTrigger:CreateSlider("Trigger Delay", 0, 1, 0.1, false, function(Value)
    Aimbot_Toggles.TriggerDelay = Value
end)

-- Options Fire Modifiers
SectionFire:CreateToggle("Rapid Fire ⚡", nil, function(State)
    Aimbot_Toggles.RapidFire = State
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                if State then
                    modifyWeaponFireRate(tool)
                else
                    restoreWeaponFireRate(tool)
                end
            end
        end
    end
end):AddToolTip("Modifie la cadence de tir des armes")

SectionFire:CreateToggle("Fast Fire", nil, function(State)
    Aimbot_Toggles.FastFire = State
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                if State then
                    modifyWeaponFireRate(tool)
                else
                    restoreWeaponFireRate(tool)
                end
            end
        end
    end
end):AddToolTip("Augmente la vitesse de tir")

SectionFire:CreateToggle("No Fire Delay 🔥", nil, function(State)
    Aimbot_Toggles.NoFireDelay = State
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                if State then
                    modifyWeaponFireRate(tool)
                else
                    restoreWeaponFireRate(tool)
                end
            end
        end
    end
end):AddToolTip("Supprime les délais entre les tirs")

-- HVH Functions
local function updateFOV()
    if HVH_Toggles.ChangeFOV then
        camera.FieldOfView = HVH_Toggles.FOVValue
    else
        camera.FieldOfView = 70
    end
end

local speedHackConnection
local function startSpeedHack()
    if speedHackConnection then
        speedHackConnection:Disconnect()
    end
    
    speedHackConnection = RunService.Heartbeat:Connect(function()
        if HVH_Toggles.SpeedHack and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 * HVH_Toggles.SpeedHackValue
            end
        end
    end)
end

local function stopSpeedHack()
    if speedHackConnection then
        speedHackConnection:Disconnect()
        speedHackConnection = nil
    end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end

-- Nouvelle implémentation de Third Person
local thirdPersonEnabled = false
local function toggleThirdPerson()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if HVH_Toggles.ThirdPerson then
        -- Activer la troisième personne
        thirdPersonEnabled = true
        
        -- Créer une caméra à la troisième personne
        local function updateThirdPerson()
            if not thirdPersonEnabled or not player.Character then return end
            
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            -- Calculer la position de la caméra
            local offset = CFrame.new(0, 0, HVH_Toggles.ThirdPersonDistance)
            local cameraCFrame = rootPart.CFrame * offset
            
            -- Mettre à jour la caméra
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            workspace.CurrentCamera.CFrame = cameraCFrame
        end
        
        -- Mettre à jour la caméra à chaque frame
        RunService.RenderStepped:Connect(updateThirdPerson)
    else
        -- Désactiver la troisième personne
        thirdPersonEnabled = false
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end

-- Nouvelle implémentation de SpinBot
local spinBotConnection
local function startSpinBot()
    if spinBotConnection then
        spinBotConnection:Disconnect()
    end
    
    spinBotConnection = RunService.Heartbeat:Connect(function()
        if HVH_Toggles.SpinBot and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Faire tourner le personnage
                local spinAngle = tick() * HVH_Toggles.SpinSpeed % (2 * math.pi)
                rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, spinAngle, 0)
            end
        end
    end)
end

local function stopSpinBot()
    if spinBotConnection then
        spinBotConnection:Disconnect()
        spinBotConnection = nil
    end
end

-- Anti-Aim amélioré
local antiAimConnection
local function startAntiAim()
    if antiAimConnection then
        antiAimConnection:Disconnect()
    end
    
    antiAimConnection = RunService.Heartbeat:Connect(function()
        if HVH_Toggles.AntiAim and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                if HVH_Toggles.Desync then
                    -- Désynchronisation avancée
                    local desyncAngle = math.sin(tick() * 5) * HVH_Toggles.DesyncAmount
                    rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, desyncAngle, 0)
                else
                    -- Anti-aim basique
                    rootPart.CFrame = rootPart.CFrame * CFrame.Angles(math.rad(180), 0, 0)
                end
            end
        end
    end)
end

local function stopAntiAim()
    if antiAimConnection then
        antiAimConnection:Disconnect()
        antiAimConnection = nil
    end
end

-- Fake Lag amélioré
local fakeLagConnection
local fakeLagPackets = {}
local function startFakeLag()
    if fakeLagConnection then
        fakeLagConnection:Disconnect()
    end
    
    fakeLagConnection = RunService.Heartbeat:Connect(function()
        if HVH_Toggles.FakeLag and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                table.insert(fakeLagPackets, {
                    Position = rootPart.Position,
                    Time = tick()
                })
                
                while #fakeLagPackets > 0 and tick() - fakeLagPackets[1].Time > HVH_Toggles.FakeLagAmount/1000 do
                    table.remove(fakeLagPackets, 1)
                end
                
                if #fakeLagPackets > 0 then
                    rootPart.CFrame = CFrame.new(fakeLagPackets[1].Position)
                end
            end
        else
            fakeLagPackets = {}
        end
    end)
end

local function stopFakeLag()
    if fakeLagConnection then
        fakeLagConnection:Disconnect()
        fakeLagConnection = nil
    end
    fakeLagPackets = {}
end

-- Options HVH
SectionHVH1:CreateToggle("Change FOV", nil, function(State)
    HVH_Toggles.ChangeFOV = State
    updateFOV()
end)

SectionHVH1:CreateSlider("FOV Value", 70, 150, 120, true, function(Value)
    HVH_Toggles.FOVValue = Value
    updateFOV()
end)

SectionHVH1:CreateToggle("Anti-Aim", nil, function(State)
    HVH_Toggles.AntiAim = State
    if State then
        startAntiAim()
    else
        stopAntiAim()
    end
end):AddToolTip("Désynchronise votre hitbox")

SectionHVH1:CreateToggle("Desync", nil, function(State)
    HVH_Toggles.Desync = State
end)

SectionHVH1:CreateSlider("Desync Amount", 0.1, 2, 0.5, false, function(Value)
    HVH_Toggles.DesyncAmount = Value
end)

SectionHVH1:CreateToggle("SpinBot", nil, function(State)
    HVH_Toggles.SpinBot = State
    if State then
        startSpinBot()
    else
        stopSpinBot()
    end
end)

SectionHVH1:CreateSlider("Spin Speed", 1, 20, 5, true, function(Value)
    HVH_Toggles.SpinSpeed = Value
end)

SectionHVH1:CreateToggle("Fake Lag", nil, function(State)
    HVH_Toggles.FakeLag = State
    if State then
        startFakeLag()
    else
        stopFakeLag()
    end
end):AddToolTip("Retarde votre position pour tromper l'ennemi")

SectionHVH1:CreateSlider("Fake Lag (ms)", 50, 500, 100, true, function(Value)
    HVH_Toggles.FakeLagAmount = Value
end)

SectionHVH2:CreateToggle("SpeedHack", nil, function(State)
    HVH_Toggles.SpeedHack = State
    if State then
        startSpeedHack()
    else
        stopSpeedHack()
    end
end):AddToolTip("Augmente votre vitesse de mouvement")

SectionHVH2:CreateSlider("Speed Multiplier", 1, 5, 2, true, function(Value)
    HVH_Toggles.SpeedHackValue = Value
    if HVH_Toggles.SpeedHack and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 * Value
        end
    end
end)

SectionHVH3:CreateToggle("Third Person", nil, function(State)
    HVH_Toggles.ThirdPerson = State
    toggleThirdPerson()
end):AddToolTip("Vue à la troisième personne")

SectionHVH3:CreateSlider("Third Person Distance", 5, 20, 10, true, function(Value)
    HVH_Toggles.ThirdPersonDistance = Value
end)

-- Extra Functions
local noclipConnection
local originalCollision = {}

local function startNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalCollision[part] = part.CanCollide
            end
        end
    end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not Extra_Toggles.Noclip or not player.Character then
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            return
        end
        
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if player.Character then
        for part, canCollide in pairs(originalCollision) do
            if part and part.Parent then
                part.CanCollide = canCollide
            end
        end
        originalCollision = {}
    end
end

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

local tpConnection
local lastTPTime = 0

local function startTPtoPlayer()
    if tpConnection then
        tpConnection:Disconnect()
    end
    
    tpConnection = RunService.Heartbeat:Connect(function()
        if Extra_Toggles.TPtoPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart and tick() - lastTPTime > 0.5 then
                local closestPlayer = getClosestPlayer()
                if closestPlayer and closestPlayer.Character then
                    local enemyRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local enemyHumanoid = closestPlayer.Character:FindFirstChild("Humanoid")
                    
                    if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                        local offset = enemyRoot.CFrame.LookVector * -3
                        rootPart.CFrame = CFrame.new(enemyRoot.Position + offset + Vector3.new(0, 2, 0))
                        lastTPTime = tick()
                    end
                end
            end
        end
    end)
end

local function stopTPtoPlayer()
    if tpConnection then
        tpConnection:Disconnect()
        tpConnection = nil
    end
end

-- Infinite Jump
local infiniteJumpConnection
local function startInfiniteJump()
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
    end
    
    infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if Extra_Toggles.InfiniteJump and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState("Jumping")
            end
        end
    end)
end

local function stopInfiniteJump()
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
end

-- FullBright
local lighting = game:GetService("Lighting")
local originalBrightness = lighting.Brightness
local originalAmbient = lighting.Ambient
local originalOutdoorAmbient = lighting.OutdoorAmbient
local originalColorShiftTop = lighting.ColorShift_Top
local originalColorShiftBottom = lighting.ColorShift_Bottom

local function enableFullBright()
    lighting.Brightness = 2
    lighting.Ambient = Color3.fromRGB(255, 255, 255)
    lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
    lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
    lighting.ClockTime = 14
    lighting.GeographicLatitude = 41.733
    lighting.ExposureCompensation = 0
end

local function disableFullBright()
    lighting.Brightness = originalBrightness
    lighting.Ambient = originalAmbient
    lighting.OutdoorAmbient = originalOutdoorAmbient
    lighting.ColorShift_Top = originalColorShiftTop
    lighting.ColorShift_Bottom = originalColorShiftBottom
end

-- No Recoil & No Spread
local noRecoilHooks = {}
local function applyNoRecoilNoSpread()
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") and not noRecoilHooks[tool] then
                for _, module in pairs(tool:GetDescendants()) do
                    if module:IsA("ModuleScript") then
                        local success, required = pcall(function() return require(module) end)
                        if success and type(required) == "table" then
                            if Extra_Toggles.NoRecoil then
                                if required.Recoil then required.Recoil = 0 end
                                if required.RecoilX then required.RecoilX = 0 end
                                if required.RecoilY then required.RecoilY = 0 end
                            end
                            
                            if Extra_Toggles.NoSpread then
                                if required.Spread then required.Spread = 0 end
                                if required.SpreadMin then required.SpreadMin = 0 end
                                if required.SpreadMax then required.SpreadMax = 0 end
                            end
                        end
                    end
                end
                noRecoilHooks[tool] = true
            end
        end
    end
end

local function removeNoRecoilNoSpread()
    for tool, _ in pairs(noRecoilHooks) do
        if tool and tool.Parent then
            for _, module in pairs(tool:GetDescendants()) do
                if module:IsA("ModuleScript") then
                    local success, required = pcall(function() return require(module) end)
                    if success and type(required) == "table" then
                        -- Restaurer les valeurs originales (vous devriez stocker les valeurs originales comme pour le rapid fire)
                    end
                end
            end
        end
    end
    noRecoilHooks = {}
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
    if State then 
        startNoclip()
    else 
        stopNoclip()
    end
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

SectionExtra2:CreateToggle("TP to Player", nil, function(State)
    Extra_Toggles.TPtoPlayer = State
    if State then
        startTPtoPlayer()
    else
        stopTPtoPlayer()
    end
end):AddToolTip("Se téléporte sur l'ennemi le plus proche")

SectionExtra3:CreateToggle("Infinite Jump", nil, function(State)
    Extra_Toggles.InfiniteJump = State
    if State then
        startInfiniteJump()
    else
        stopInfiniteJump()
    end
end)

SectionExtra3:CreateToggle("FullBright", nil, function(State)
    Extra_Toggles.FullBright = State
    if State then
        enableFullBright()
    else
        disableFullBright()
    end
end)

SectionExtra3:CreateToggle("No Recoil", nil, function(State)
    Extra_Toggles.NoRecoil = State
    if State then
        applyNoRecoilNoSpread()
    else
        removeNoRecoilNoSpread()
    end
end)

SectionExtra3:CreateToggle("No Spread", nil, function(State)
    Extra_Toggles.NoSpread = State
    if State then
        applyNoRecoilNoSpread()
    else
        removeNoRecoilNoSpread()
    end
end)

-- UI Toggle
SectionESP1:CreateToggle("UI Toggle", nil, function(State)
    Window:Toggle(State)
end):CreateKeybind(tostring(Config.Keybind):gsub("Enum.KeyCode.", ""), function(Key)
    Config.Keybind = Enum.KeyCode[Key]
end):SetState(true)

-- Character Change Handlers
player.CharacterAdded:Connect(function()
    wait(1)
    -- Réactiver les fonctionnalités si elles étaient activées
    if Aimbot_Toggles.Aimbot then startAimbot() end
    if Aimbot_Toggles.TriggerBot then startTriggerBot() end
    if Aimbot_Toggles.RapidFire or Aimbot_Toggles.FastFire or Aimbot_Toggles.NoFireDelay then setupWeaponMonitoring() end
    if HVH_Toggles.SpeedHack then startSpeedHack() end
    if HVH_Toggles.ThirdPerson then toggleThirdPerson() end
    if HVH_Toggles.AntiAim then startAntiAim() end
    if HVH_Toggles.SpinBot then startSpinBot() end
    if HVH_Toggles.FakeLag then startFakeLag() end
    if Extra_Toggles.Fly then startFly() end
    if Extra_Toggles.Noclip then startNoclip() end
    if Extra_Toggles.TPtoPlayer then startTPtoPlayer() end
    if Extra_Toggles.InfiniteJump then startInfiniteJump() end
    if Extra_Toggles.FullBright then enableFullBright() end
    if Extra_Toggles.NoRecoil or Extra_Toggles.NoSpread then applyNoRecoilNoSpread() end
    updateFOV()
end)

player.CharacterRemoving:Connect(function()
    stopAimbot()
    stopTriggerBot()
    stopSpeedHack()
    if HVH_Toggles.ThirdPerson then
        HVH_Toggles.ThirdPerson = false
        toggleThirdPerson()
    end
    stopAntiAim()
    stopSpinBot()
    stopFakeLag()
    stopFly()
    stopNoclip()
    stopTPtoPlayer()
    stopInfiniteJump()
    if Extra_Toggles.FullBright then
        Extra_Toggles.FullBright = false
        disableFullBright()
    end
    removeNoRecoilNoSpread()
end)

-- Initial States
stopAimbot()
stopTriggerBot()
stopSpeedHack()
if HVH_Toggles.ThirdPerson then
    HVH_Toggles.ThirdPerson = false
    toggleThirdPerson()
end
stopAntiAim()
stopSpinBot()
stopFakeLag()
stopFly()
stopNoclip()
stopTPtoPlayer()
stopInfiniteJump()
if Extra_Toggles.FullBright then
    Extra_Toggles.FullBright = false
    disableFullBright()
end
removeNoRecoilNoSpread()
updateFOV()

print("Cheat Arsenal ACE Loaded Successfully!")
