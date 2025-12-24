local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/mTMLkW1V"))()

-- Hauptfenster mit eigenem Namen
local Window = OrionLib:MakeWindow({
  Name = "ZyneyHub ・ AutoRob",
  HidePremium = false,
  SaveConfig = false,
  ConfigFolder = "ProjectNexar",
  IntroEnabled = true,
  IntroText = "Project Volara "
})

-- // Creating Tabs \\ --
local AutorobberyTab = Window:MakeTab({
    Name = "Auto Robbery",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local InformationTab = Window:MakeTab({
    Name = "Information",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- // Creating Sections \\ --
local Section = InformationTab:AddSection({
    Name = "Information"
})

InformationTab:AddParagraph("Warning!", "If your device is not that good you may get thrown out of your vehicle or kicked if that happens make sure your graphics are turned down.")

local Section = InformationTab:AddSection({
    Name = "Are you having problems?"
})    

InformationTab:AddButton({
    Name = "Copy Discord",
    Callback = function()
        setclipboard("https://discord.gg/wENUshsgV3")
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Copied!", Text="Discord invite copied.", Duration=3})
    end
})     

InformationTab:AddLabel("Script not working or bugs? Open a ticket on the dc.")
InformationTab:AddLabel("You got a error? Open a ticket on the dc.")
InformationTab:AddLabel("Script is in Release Version R3.")

-- // Autofarm \\ --
local Section = AutorobberyTab:AddSection({
    Name = "Autorobbery Script"
})

AutorobberyTab:AddParagraph("How does it work automatically?", "You need to add this script to your auto-execute folder from your executer.")

AutorobberyTab:AddButton({
    Name = "Copy Script",
    Callback = function()
        setclipboard("https://raw.githubusercontent.com/ItemTo/VortexAutorob/refs/heads/main/release")
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="Copied!", Text="Autorobbery script copied.", Duration=3})
    end
})

local Section = AutorobberyTab:AddSection({
    Name = "Autorobbery Options"
})

local configFileName = "ZyneyHub5.json"
local autorobToggle = false
local autoSellToggle = true
local vehicleSpeedDivider = 170
local healthAbortThreshold = 37
local collectSpeedDivider = 28

local function loadConfig()
    if isfile(configFileName) then
        local data = readfile(configFileName)
        local success, config = pcall(function()
            return game:GetService("HttpService"):JSONDecode(data)
        end)

        if success and config then
            autorobToggle = config.autorobToggle or false
            autoSellToggle = config.autoSellToggle or false
            vehicleSpeedDivider = config.vehicleSpeedDivider or 170
            healthAbortThreshold = config.healthAbortThreshold or 37
            collectSpeedDivider = config.collectSpeedDivider or 28
        end
    end
end

local function saveConfig()
    local config = {
        autorobToggle = autorobToggle,
        autoSellToggle = autoSellToggle,
        vehicleSpeedDivider = vehicleSpeedDivider,
        healthAbortThreshold = healthAbortThreshold,
        collectSpeedDivider = collectSpeedDivider
    }
    local json = game:GetService("HttpService"):JSONEncode(config)
    writefile(configFileName, json)
end

loadConfig()

AutorobberyTab:AddToggle({
    Name = "Autorob",
    Default = autorobToggle,
    Callback = function(Value)
        autorobToggle = Value
        saveConfig()
    end    
})

AutorobberyTab:AddToggle({
    Name = "Automatically sells stolen items",
    Default = autoSellToggle,
    Callback = function(Value)
        autoSellToggle = Value
        saveConfig()
    end    
})

local Section = AutorobberyTab:AddSection({
    Name = "Settings (Set it so that it matches the performance of your device.)"
})

-- Geänderter Slider: Maximalwert von 175 auf 240 erhöht
AutorobberyTab:AddSlider({
    Name = "Vehicle speed",
    Min = 50,
    Max = 240,
    Default = vehicleSpeedDivider,
    Increment = 5,
    Callback = function(value)
        vehicleSpeedDivider = value
        saveConfig()
    end
})

AutorobberyTab:AddSlider({
    Name = "Item collection speed",
    Min = 15,
    Max = 40,
    Default = collectSpeedDivider,
    Increment = 1,
    Callback = function(value)
        collectSpeedDivider = value
        saveConfig()
    end
})

AutorobberyTab:AddSlider({
    Name = "Life limit where it should stop farming",
    Min = 27,
    Max = 100,
    Default = healthAbortThreshold,
    Increment = 1,
    Callback = function(value)
        healthAbortThreshold = value
        saveConfig()
    end
})

-- Services und Variablen
local plr = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- RemoteEvents
local robRemoteEvent = ReplicatedStorage:WaitForChild("MW5"):WaitForChild("adc4b609-bcc8-4d34-972b-99152ad2e8a3")
local sellRemoteEvent = ReplicatedStorage:WaitForChild("MW5"):WaitForChild("7c0c6f72-73f4-48a5-81e6-8ccf02a96366")
local EquipRemoteEvent = ReplicatedStorage:WaitForChild("MW5"):WaitForChild("542a57d7-254c-43f1-8b1c-bb928c73db62")
local buyRemoteEvent = ReplicatedStorage:WaitForChild("MW5"):WaitForChild("c82cec53-dd03-4db0-aa12-1fc14334ffe0")
local fireBombRemoteEvent = ReplicatedStorage:WaitForChild("MW5"):WaitForChild("a44ab0b3-ea43-466a-8e72-e0dd121e718a")

-- Konstanten
local ProximityPromptTimeBet = 2.5
local key = Enum.KeyCode.E

-- Hilfsfunktionen
local function JumpOut()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.SeatPart then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

local function ensurePlayerInVehicle()
    local vehicle = Workspace:FindFirstChild("Vehicles") and Workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    if vehicle and character then
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        local driveSeat = vehicle:FindFirstChild("DriveSeat")
        if humanoid and driveSeat and humanoid.SeatPart ~= driveSeat then
            driveSeat:Sit(humanoid)
        end
    end
end

local function clickAtCoordinates(scaleX, scaleY, duration)
    local camera = game.Workspace.CurrentCamera
    local screenWidth = camera.ViewportSize.X
    local screenHeight = camera.ViewportSize.Y
    local absoluteX = screenWidth * scaleX
    local absoluteY = screenHeight * scaleY

    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, true, game, 0)  
    if duration and duration > 0 then
        task.wait(duration)  
    end
    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, false, game, 0) 
end

-- NORMALE TWEEN FUNKTION für Spieler (wird für Items verwendet)
local function plrTween(destination)
    local char = plr.Character
    if not char or not char.PrimaryPart then
        warn("Character or PrimaryPart not available.")
        return
    end

    local distance = (char.PrimaryPart.Position - destination).Magnitude
    local tweenDuration = distance / collectSpeedDivider
    local TweenInfoToUse = TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    local TweenValue = Instance.new("CFrameValue")
    TweenValue.Value = char:GetPivot()

    TweenValue.Changed:Connect(function(newCFrame)
        char:PivotTo(newCFrame)
    end)

    local targetCFrame = CFrame.new(destination)
    local tween = TweenService:Create(TweenValue, TweenInfoToUse, { Value = targetCFrame })
    tween:Play()
    tween.Completed:Wait()
    TweenValue:Destroy()
end

-- INSTANT TELEPORT für feste Koordinaten (nicht für Items)
local function plrInstantTeleport(destination)
    local char = plr.Character
    if not char or not char.PrimaryPart then
        warn("Character or PrimaryPart not available.")
        return
    end

    -- INSTANT TELEPORT - Kein Tween, direkt teleportieren
    char:PivotTo(CFrame.new(destination))
end

-- NORMALE TELEPORT für Fahrzeug (mit Slider)
local function tweenTo(destination)
    ensurePlayerInVehicle()

    local vehicle = Workspace:FindFirstChild("Vehicles") and Workspace.Vehicles:FindFirstChild(LocalPlayer.Name)
    if not vehicle then 
        warn("Vehicle not found.")
        return
    end

    local primaryPart = vehicle:FindFirstChild("DriveSeat") or vehicle.PrimaryPart
    if not primaryPart then 
        warn("PrimaryPart not found.")
        return
    end

    vehicle.PrimaryPart = primaryPart

    -- Parkbremse und gesperrt setzen
    vehicle:SetAttribute("ParkingBrake", true)
    vehicle:SetAttribute("Locked", true)

    -- Ins Fahrzeug setzen
    if vehicle:FindFirstChild("DriveSeat") then
        vehicle.DriveSeat:Sit(plr.Character.Humanoid)
    end

    local distance = (primaryPart.Position - destination).Magnitude
    local tweenDuration = distance / vehicleSpeedDivider

    local TweenInfoToUse = TweenInfo.new(
        tweenDuration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    local TweenValue = Instance.new("CFrameValue")
    TweenValue.Value = vehicle:GetPivot()

    TweenValue.Changed:Connect(function(newCFrame)
        vehicle:PivotTo(newCFrame)
        if vehicle:FindFirstChild("DriveSeat") then
            vehicle.DriveSeat.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            vehicle.DriveSeat.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end)

    local targetCFrame = CFrame.new(destination)
    local tween = TweenService:Create(TweenValue, TweenInfoToUse, { Value = targetCFrame })

    tween:Play()
    tween.Completed:Wait()

    vehicle:SetAttribute("ParkingBrake", true)
    vehicle:SetAttribute("Locked", true)
    TweenValue:Destroy()
end

local function interactWithVisibleMeshParts(folder)
    if not folder then return end
    local player = game.Players.LocalPlayer
    local policeTeam = game:GetService("Teams"):FindFirstChild("Police")

    if not policeTeam then return end

    local function isPoliceNearby()
        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
            if plr.Team == policeTeam and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance <= 40 then
                    return true
                end
            end
        end
        return false
    end

    local meshParts = {}
    for _, meshPart in ipairs(folder:GetChildren()) do
        if meshPart:IsA("MeshPart") and meshPart.Transparency == 0 then
            table.insert(meshParts, meshPart)
        end
    end

    table.sort(meshParts, function(a, b)
        local aDist = (a.Position - player.Character.HumanoidRootPart.Position).Magnitude
        local bDist = (b.Position - player.Character.HumanoidRootPart.Position).Magnitude
        return aDist < bDist
    end)

    for _, meshPart in ipairs(meshParts) do
        if isPoliceNearby() then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Police is nearby",
                Text = "Interaction aborted",
            })
            return
        end

        if player.Character.Humanoid.Health <= healthAbortThreshold then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Player is hurt",
                Text = "Interaction aborted",
            })
            return
        end

        if meshPart.Transparency == 1 then
            continue
        end

        if meshPart.Parent.Name == "Money" then
            local args = {meshPart, "ORe", true}
            robRemoteEvent:FireServer(unpack(args))
            task.wait(ProximityPromptTimeBet)
            args[3] = false
            robRemoteEvent:FireServer(unpack(args))
        else
            local args = {meshPart, "OBG", true}
            robRemoteEvent:FireServer(unpack(args))
            task.wait(ProximityPromptTimeBet)
            args[3] = false
            robRemoteEvent:FireServer(unpack(args))
        end
    end
end

local function interactWithVisibleMeshParts2(folder)
    if not folder then return end
    local player = game.Players.LocalPlayer
    local policeTeam = game:GetService("Teams"):FindFirstChild("Police")

    if not policeTeam then return end

    local function isPoliceNearby()
        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
            if plr.Team == policeTeam and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance <= 40 then
                    return true
                end
            end
        end
        return false
    end

    local meshParts = {}
    for _, meshPart in ipairs(folder:GetChildren()) do
        if meshPart:IsA("MeshPart") and meshPart.Transparency == 0 then
            table.insert(meshParts, meshPart)
        end
    end

    table.sort(meshParts, function(a, b)
        local aDist = (a.Position - player.Character.HumanoidRootPart.Position).Magnitude
        local bDist = (b.Position - player.Character.HumanoidRootPart.Position).Magnitude
        return aDist < bDist
    end)

    for i, meshPart in ipairs(meshParts) do
        if isPoliceNearby() then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Police is nearby",
                Text = "Interaction aborted",
            })
            return
        end

        if player.Character.Humanoid.Health <= healthAbortThreshold then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Player is hurt",
                Text = "Interaction aborted",
            })
            return
        end

        if meshPart.Transparency == 1 then
            return
        end

        -- NORMALES TWEEN zu Items (nicht instant)
        plrTween(meshPart.Position)

        if meshPart.Parent.Name == "Money" then
            local args3 = {meshPart, "ORe", true}
            robRemoteEvent:FireServer(unpack(args3))
            task.wait(ProximityPromptTimeBet)
            local args3 = {meshPart, "OBG", false}
            robRemoteEvent:FireServer(unpack(args3))
        else
            local args4 = {meshPart, "OBG", true}
            robRemoteEvent:FireServer(unpack(args4))
            task.wait(ProximityPromptTimeBet)
            local args4 = {meshPart, "OBG", false}
            robRemoteEvent:FireServer(unpack(args4))
        end

        task.wait(0.1)
    end
end

local function MoveToDealer()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local vehicle = Workspace.Vehicles:FindFirstChild(player.Name)

    if not vehicle then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Error",
            Text = "No vehicle found.",
            Duration = 3,
        })
        return
    end

    local dealers = Workspace:FindFirstChild("Dealers")
    if not dealers then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Error",
            Text = "Dealers not found.",
            Duration = 3,
        })
        tweenTo(Vector3.new(374.6724548339844, -25.861278533935547, 3789.667724609375))
        return
    end

    local closest, shortest = nil, math.huge
    for _, dealer in pairs(dealers:GetChildren()) do
        if dealer:FindFirstChild("Head") then
            local dist = (character.HumanoidRootPart.Position - dealer.Head.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = dealer.Head
            end
        end
    end

    if not closest then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Error",
            Text = "No dealer found.",
            Duration = 3,
        })
        tweenTo(Vector3.new(374.6724548339844, -25.861278533935547, 3789.667724609375))
        return
    end

    local destination1 = closest.Position + Vector3.new(0, 5, 0)
    tweenTo(destination1)
end

-- OPTIMIERTES SERVERHOP SYSTEM
local HttpService = game:GetService('HttpService')
local TeleportService = game:GetService('TeleportService')
local PlaceID = game.PlaceId 
local AllIDs = {}
local foundAnything = ""
local actualHour = os.time()

local success, result = pcall(function()
    return HttpService:JSONDecode(readfile("NotSameServersAutoRob.json"))
end)

if success and type(result) == "table" then
    AllIDs = result
else
    AllIDs = {actualHour}
    writefile("NotSameServersAutoRob.json", HttpService:JSONEncode(AllIDs))
end

local function TPReturner()
    local Site
    if foundAnything == "" then
        Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end

    if Site.nextPageCursor then
        foundAnything = Site.nextPageCursor
    end

    for _, v in pairs(Site.data) do
        if tonumber(v.playing) < tonumber(v.maxPlayers) then
            local ServerID = tostring(v.id)
            local AlreadyVisited = false

            for _, ExistingID in ipairs(AllIDs) do
                if ServerID == ExistingID then
                    AlreadyVisited = true
                    break
                end
            end

            if not AlreadyVisited then
                table.insert(AllIDs, ServerID)
                writefile("NotSameServersAutoRob.json", HttpService:JSONEncode(AllIDs))
                TeleportService:TeleportToPlaceInstance(PlaceID, ServerID, Players.LocalPlayer)
                wait(4)
                return true -- Erfolgreich gehoppt
            end
        end
    end
    return false -- Kein Server gefunden
end

local function ServerHop()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Server Hop",
        Text = "Looking for new server...",
        Duration = 5,
    })

    local success = false

    -- Versuche einmal zu hoppen
    success = pcall(function()
        return TPReturner()
    end)

    -- Wenn nichts gefunden wurde, versuche es nochmal
    if not success and foundAnything ~= "" then
        success = pcall(function()
            return TPReturner()
        end)
    end

    if success then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Success",
            Text = "Server hop completed!",
            Duration = 3,
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Error",
            Text = "Failed to find a new server.",
            Duration = 5,
        })
    end
end

-- NEUE SERVERHOP-KOORDINATE
local SERVERHOP_POSITION = Vector3.new(374.6724548339844, -25.861278533935547, 3789.667724609375)

-- Haupt-Robbery Loop
while task.wait() do
    if autorobToggle == true then
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local camera = game.Workspace.CurrentCamera

        local function lockCamera()
            local rootPart = character.HumanoidRootPart
            local heightOffset = 10
            local backOffset = 4
            local cameraPosition = rootPart.Position - rootPart.CFrame.LookVector * backOffset + Vector3.new(0, heightOffset, 0)
            local lookAtPosition = rootPart.Position + Vector3.new(0, 3, 0)
            camera.CFrame = CFrame.new(cameraPosition, lookAtPosition)
            camera.FieldOfView = 100
        end

        game:GetService("RunService").RenderStepped:Connect(lockCamera)

        -- Startposition
        ensurePlayerInVehicle()
        task.wait(.5)
        clickAtCoordinates(0.5, 0.9)
        task.wait(.5)

        -- Zur Startposition fahren
        tweenTo(Vector3.new(-1370.972412109375, 5.499999046325684, 3127.154541015625))

        -- Club Tresor prüfen
        local musikPart = workspace.Robberies["Club Robbery"].Club.Door.Accessory.Black
        local bankLight = game.Workspace.Robberies.BankRobbery.LightGreen.Light
        local bankLight2 = game.Workspace.Robberies.BankRobbery.LightRed.Light

        -- CLUB ROBBERY
        if musikPart.Rotation == Vector3.new(180, 0, 180) then
            clickAtCoordinates(0.6, 0.9)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Club Safe is open",
                Text = "Going to rob",
            })

            local function checkContainer(container)
                for _, item in ipairs(container:GetChildren()) do
                    if item:IsA("Tool") and item.Name == "Bomb" then
                        return true
                    end
                end
                return false
            end

            local function playerHasBombGui(player)
                local playerGui = player:FindFirstChild("PlayerGui")
                if not playerGui then return false end

                local uiElement = playerGui:FindFirstChild("A6A23F59-70AC-4DDF-8F7B-C4E1E8D6434F")
                if not uiElement then return false end

                for _, guiObject in ipairs(uiElement:GetDescendants()) do
                    if (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) and guiObject.Image == "rbxassetid://132706206999660" then
                        return true
                    end
                end
                return false
            end

            local hasBomb = checkContainer(plr.Backpack) or checkContainer(plr.Character) or playerHasBombGui(plr)

            if not hasBomb then
                ensurePlayerInVehicle()
                task.wait(0.5)
                MoveToDealer()
                task.wait(0.5)
                local args = {"Bomb", "Dealer"}
                buyRemoteEvent:FireServer(unpack(args))
                task.wait(0.5)
            end

            ensurePlayerInVehicle()
            task.wait(0.5)

            -- Club Positionen
            local musikPos = Vector3.new(-1739.5330810546875, 11, 3052.31103515625)
            local musikStand = Vector3.new(-1744.177001953125, 11.125, 3012.20263671875)
            local musikSafe = Vector3.new(-1743.4300537109375, 11.124999046325684, 3049.96630859375)

            tweenTo(musikPos)
            task.wait(0.5)
            JumpOut()
            task.wait(0.5)

            local args = {"Bomb"}
            EquipRemoteEvent:FireServer(unpack(args))
            task.wait(0.5)

            -- INSTANT TELEPORT für feste Positionen
            plrInstantTeleport(musikStand)
            task.wait(0.5)

            local tool = plr.Character:FindFirstChild("Bomb")
            if tool then
                -- Zielen starten (Rechtsklick gedrückt halten)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 1)
                wait(1)
                -- Linksklick ausführen
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                -- 0.5 Sekunden warten
                wait(0.5)
                -- Zielen beenden (Rechtsklick loslassen)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 1)
            else
                warn("Tool 'Bomb' not found in the Backpack!")
            end

            task.wait(0.5)
            fireBombRemoteEvent:FireServer()
            plrInstantTeleport(musikSafe)
            task.wait(2)
            plrInstantTeleport(musikStand)

            local safeFolder = workspace.Robberies["Club Robbery"].Club
            interactWithVisibleMeshParts(safeFolder:FindFirstChild("Items"))
            interactWithVisibleMeshParts(safeFolder:FindFirstChild("Money"))

            -- LÄNGERE WARTEZEIT FÜR ERSTEN TRESOR (CLUB)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Club Robbery",
                Text = "Waiting extra time after first robbery...",
                Duration = 5,
            })
            task.wait(5)  -- 5 Sekunden extra warten nach Club-Raub

            ensurePlayerInVehicle()
            if autoSellToggle == true then
                ensurePlayerInVehicle()
                MoveToDealer()
                task.wait(0.5)
                local args = {"Gold", "Dealer"}
                sellRemoteEvent:FireServer(unpack(args))
                sellRemoteEvent:FireServer(unpack(args))
                sellRemoteEvent:FireServer(unpack(args))
            end

            game.StarterGui:SetCore("SendNotification", {
                Title = "Club robbed",
                Text = "Moving to check bank",
                Duration = 3,
            })

        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "Club Safe is not open",
                Text = "Checking bank...",
                Duration = 3,
            })
        end

        -- BANK ROBBERY
        if bankLight2.Enabled == false and bankLight.Enabled == true then
            clickAtCoordinates(0.5, 0.9)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Bank is open",
                Text = "Going to rob",
                Duration = 3,
            })

            ensurePlayerInVehicle()
            local hasBomb1 = false
            local plr = game.Players.LocalPlayer

            local function checkContainer(container)
                for _, item in ipairs(container:GetChildren()) do
                    if item:IsA("Tool") and item.Name == "Bomb" then
                        return true
                    end
                end
                return false
            end

            hasBomb1 = checkContainer(plr.Backpack) or checkContainer(plr.Character)

            if not hasBomb1 then
                ensurePlayerInVehicle()
                task.wait(0.5)
                MoveToDealer()
                task.wait(0.5)
                local args = {"Bomb", "Dealer"}
                buyRemoteEvent:FireServer(unpack(args))
                task.wait(0.5)
            end

            -- Bank Positionen
            tweenTo(Vector3.new(-1202.86181640625, 7.877995491027832, 3164.614501953125))
            task.wait(0.5)
            JumpOut()
            task.wait(0.5)

            -- INSTANT TELEPORT für feste Positionen
            plrInstantTeleport(Vector3.new(-1242.367919921875, 7.749999046325684, 3144.705322265625))
            task.wait(0.5)

            local args = {"Bomb"}
            EquipRemoteEvent:FireServer(unpack(args))
            task.wait(0.5)

            local tool = plr.Character:FindFirstChild("Bomb")
            if tool then
                -- Zielen starten (Rechtsklick gedrückt halten)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 1)
                wait(1)
                -- Linksklick ausführen
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                -- 0.5 Sekunden warten
                wait(0.5)
                -- Zielen beenden (Rechtsklick loslassen)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 1)
            else
                warn("Tool 'Bomb' not found in the Backpack!")
            end

            task.wait(.5)
            fireBombRemoteEvent:FireServer()
            plrInstantTeleport(Vector3.new(-1246.291015625, 7.749999046325684, 3120.8505859375))
            task.wait(2.5)

            local safeFolder = Workspace.Robberies.BankRobbery
            interactWithVisibleMeshParts2(safeFolder:FindFirstChild("Gold"))
            interactWithVisibleMeshParts2(safeFolder:FindFirstChild("Money"))

            ensurePlayerInVehicle()
            if autoSellToggle == true then
                task.wait(.5)
                MoveToDealer()
                task.wait(.5)
                local args = {"Gold", "Dealer"}
                sellRemoteEvent:FireServer(unpack(args))
                sellRemoteEvent:FireServer(unpack(args))
                sellRemoteEvent:FireServer(unpack(args))
                task.wait(.5)
            end

            game.StarterGui:SetCore("SendNotification", {
                Title = "Bank robbed",
                Text = "Moving to serverhop location",
                Duration = 3,
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "Bank is not open",
                Text = "Moving to serverhop location",
                Duration = 3,
            })
        end

        -- KEINE CONTAINER MEHR - DIREKT ZUM SERVERHOP

        -- Zur ServerHop-Position gehen
        ensurePlayerInVehicle()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Moving to serverhop",
            Text = "No containers, going to serverhop location",
            Duration = 3,
        })

        tweenTo(SERVERHOP_POSITION)
        task.wait(1)

        -- ServerHop durchführen (nur einmal)
        ServerHop()
    end
end