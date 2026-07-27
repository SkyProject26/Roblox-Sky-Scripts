local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "AuroraHub",
    Footer = "Combat, Movement, World & Advanced Visuals",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Player = Window:AddTab("Player", "zap"),
    World = Window:AddTab("World", "earth"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Battle = Window:AddTab("Battle", "crosshair"),
    Crosshair = Window:AddTab("Crosshair", "crosshair"),
    Server = Window:AddTab("Server", "server"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- ==================== TAB GROUPS ====================

local SpeedGroup = Tabs.Player:AddLeftGroupbox("Speed & Jump Control", "person-standing")
local ExtraGroup = Tabs.Player:AddRightGroupbox("Movement Extras", "shield")
local FlightGroup = Tabs.Player:AddRightGroupbox("Flight System", "wind")

local PhysicsGroup = Tabs.World:AddLeftGroupbox("Physics", "box")
local EnvironmentGroup = Tabs.World:AddRightGroupbox("Environment", "sun")

local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP Features", "users")
local ESPSettingsGroup = Tabs.Visuals:AddRightGroupbox("ESP Settings", "settings")

local AimGroup = Tabs.Battle:AddLeftGroupbox("Aimbot & Silent Aim", "target")
local CombatGroup = Tabs.Battle:AddRightGroupbox("Triggerbot & Settings", "crosshair")

-- ==================== STATE VARIABLES ====================

local state = {
    defaultSpeed = 16,
    currentSpeed = 16,
    defaultJumpPower = 50,
    currentJumpPower = 50,
    flySpeed = 50,
    vflySpeed = 50,
    
    defaultGravity = Workspace.Gravity,
    currentGravity = 196.2,
    
    speedConn = nil,
    noclipConn = nil,
    infJumpConn = nil,
    flyConn = nil,
    vflyConn = nil,
    espConn = nil,
    combatConn = nil,
    
    bodyVelocity = nil,
    bodyGyro = nil,
    vflyBV = nil,
    vflyBG = nil,
    
    customSky = nil,
    lastTriggerTick = 0,
}

-- ==================== UTILITY FUNCTIONS ====================

local function getCharInfo(player)
    local plr = player or LocalPlayer
    local char = plr.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    return char, hum, root
end

local function getVehiclePart()
    local _, hum, _ = getCharInfo()
    if not hum then return nil end
    local seat = hum.SeatPart
    if seat and seat:IsA("BasePart") then
        return seat.AssemblyRootPart or seat
    end
    return nil
end

local function resetCollision()
    local char, _, _ = getCharInfo()
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

local function getFlightVector()
    if not Camera then return Vector3.zero end
    local moveDir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
    return moveDir
end

local function stopBodyPhysics()
    if state.bodyVelocity then state.bodyVelocity:Destroy(); state.bodyVelocity = nil end
    if state.bodyGyro then state.bodyGyro:Destroy(); state.bodyGyro = nil end
    local _, hum, _ = getCharInfo()
    if hum then hum.PlatformStand = false end
end

local function stopVFlyPhysics()
    if state.vflyBV then state.vflyBV:Destroy(); state.vflyBV = nil end
    if state.vflyBG then state.vflyBG:Destroy(); state.vflyBG = nil end
end

local function getClosestPlayerToCursor(fovLimit, maxDist)
    local closestPlayer = nil
    local shortestDist = fovLimit or math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local _, _, localRoot = getCharInfo(LocalPlayer)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char, hum, root = getCharInfo(plr)
        if char and root and hum and hum.Health > 0 then
            local isTeammate = LocalPlayer.Team and LocalPlayer.Team == plr.Team
            if Toggles.CombatTeamCheck and Toggles.CombatTeamCheck.Value and isTeammate then continue end
            
            if localRoot then
                local dist3D = (localRoot.Position - root.Position).Magnitude
                if maxDist and dist3D > maxDist then continue end
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPlayer = plr
                end
            end
        end
    end
    return closestPlayer
end

local function getCharFromHit(hit)
    if not hit then return nil, nil, nil, nil end
    local model = hit:FindFirstAncestorOfClass("Model")
    if model then
        local hum = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        local plr = Players:GetPlayerFromCharacter(model)
        if hum then
            return model, hum, root, plr
        end
    end
    return nil, nil, nil, nil
end

-- ==================== BATTLE TAB (Aimbot, SilentAim, TriggerBot) ====================

local aimbotToggle = AimGroup:AddToggle("AimbotEnabled", { Text = "Aimbot", Default = false })
aimbotToggle:AddKeyPicker("AimbotKey", { Default = "LeftAlt", SyncToggleState = false, Mode = "Hold", Text = "Aimbot Key" })

AimGroup:AddDropdown("AimbotBone", { Values = { "Head", "HumanoidRootPart" }, Default = 1, Multi = false, Text = "Target Bone" })
AimGroup:AddSlider("AimbotSmoothness", { Text = "Smoothness", Default = 5, Min = 1, Max = 20, Rounding = 1 })
AimGroup:AddSlider("AimbotFOV", { Text = "FOV Radius", Default = 150, Min = 10, Max = 500, Rounding = 0 })
AimGroup:AddSlider("AimbotDistance", { Text = "Max Distance", Default = 500, Min = 50, Max = 2000, Rounding = 0 })
AimGroup:AddToggle("AimbotFOVDraw", { Text = "Draw FOV Circle", Default = false })

local silentAimToggle = AimGroup:AddToggle("SilentAimEnabled", { Text = "Silent Aim", Default = false })
AimGroup:AddSlider("SilentAimFOV", { Text = "Silent FOV Radius", Default = 100, Min = 10, Max = 500, Rounding = 0 })
AimGroup:AddSlider("SilentAimDistance", { Text = "Silent Max Distance", Default = 500, Min = 50, Max = 2000, Rounding = 0 })

local triggerBotToggle = CombatGroup:AddToggle("TriggerBotEnabled", { Text = "Triggerbot", Default = false })
CombatGroup:AddSlider("TriggerBotDelay", { Text = "Reaction Speed (ms)", Default = 0, Min = 0, Max = 500, Rounding = 0 })
CombatGroup:AddSlider("TriggerBotDistance", { Text = "Max Distance", Default = 500, Min = 50, Max = 2000, Rounding = 0 })
CombatGroup:AddToggle("CombatTeamCheck", { Text = "Team Check", Default = true })

-- FOV Circle Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.NumSides = 60
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255, 255, 255)

-- Silent Aim Hook Setup
pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, index)
        if Toggles.SilentAimEnabled and Toggles.SilentAimEnabled.Value and self == Mouse and (index == "Hit" or index == "Target") then
            local maxDist = Options.SilentAimDistance and Options.SilentAimDistance.Value or 500
            local target = getClosestPlayerToCursor(Options.SilentAimFOV.Value, maxDist)
            if target then
                local char, _, root = getCharInfo(target)
                if char and root then
                    if index == "Hit" then
                        return root.CFrame
                    elseif index == "Target" then
                        return root
                    end
                end
            end
        end
        return oldIndex(self, index)
    end)
end)

-- Combat Render Loop
state.combatConn = RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    
    -- FOV Circle drawing logic
    local isAimbotActiveDraw = Toggles.AimbotEnabled and Toggles.AimbotEnabled.Value and Toggles.AimbotFOVDraw and Toggles.AimbotFOVDraw.Value
    local isSilentActiveDraw = Toggles.SilentAimEnabled and Toggles.SilentAimEnabled.Value
    
    if isAimbotActiveDraw or isSilentActiveDraw then
        fovCircle.Position = mousePos
        if isAimbotActiveDraw and Options.AimbotFOV then
            fovCircle.Radius = Options.AimbotFOV.Value
        elseif isSilentActiveDraw and Options.SilentAimFOV then
            fovCircle.Radius = Options.SilentAimFOV.Value
        end
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
    
    -- Aimbot Logic
    if Toggles.AimbotEnabled and Toggles.AimbotEnabled.Value and Options.AimbotKey and Options.AimbotKey:GetState() then
        local maxDist = Options.AimbotDistance and Options.AimbotDistance.Value or 500
        local target = getClosestPlayerToCursor(Options.AimbotFOV and Options.AimbotFOV.Value or 150, maxDist)
        if target then
            local char, _, _ = getCharInfo(target)
            if char then
                local boneName = Options.AimbotBone and Options.AimbotBone.Value or "Head"
                local bonePart = char:FindFirstChild(boneName) or char:FindFirstChild("Head")
                if bonePart then
                    local smooth = Options.AimbotSmoothness and math.clamp(Options.AimbotSmoothness.Value, 1, 20) or 5
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, bonePart.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / smooth)
                end
            end
        end
    end

    -- Triggerbot Logic
    if Toggles.TriggerBotEnabled and Toggles.TriggerBotEnabled.Value then
        local target = Mouse.Target
        local _, hum, root, enemyPlayer = getCharFromHit(target)
        if hum and hum.Health > 0 and root and enemyPlayer and enemyPlayer ~= LocalPlayer then
            local isTeammate = LocalPlayer.Team and LocalPlayer.Team == enemyPlayer
            if not (Toggles.CombatTeamCheck and Toggles.CombatTeamCheck.Value and isTeammate) then
                local _, _, localRoot = getCharInfo(LocalPlayer)
                local dist = localRoot and (localRoot.Position - root.Position).Magnitude or 0
                local maxDist = Options.TriggerBotDistance and Options.TriggerBotDistance.Value or 500
                if dist <= maxDist then
                    local now = tick() * 1000
                    local delay = Options.TriggerBotDelay and Options.TriggerBotDelay.Value or 0
                    if now - state.lastTriggerTick >= delay then
                        state.lastTriggerTick = now
                        task.spawn(function()
                            pcall(function()
                                mouse1press()
                                task.wait(0.05)
                                mouse1release()
                            end)
                        end)
                    end
                end
            end
        end
    end
end)

-- ==================== PLAYER TAB ====================

local speedToggle = SpeedGroup:AddToggle("SpeedEnabled", {
    Text = "Enable Custom Speed", Default = false,
    Callback = function(Value)
        if Value then
            if not state.speedConn then
                state.speedConn = RunService.Heartbeat:Connect(function()
                    if Toggles.SpeedEnabled.Value then
                        local mode = Options.BypassMode and Options.BypassMode.Value or "WalkSpeed"
                        local _, hum, root = getCharInfo()
                        if hum then
                            if mode == "WalkSpeed" then
                                hum.WalkSpeed = state.currentSpeed
                            elseif mode == "CFrame Velocity" and root and hum.MoveDirection.Magnitude > 0 then
                                root.CFrame = root.CFrame + (hum.MoveDirection * (state.currentSpeed / 100))
                            end
                        end
                    end
                end)
            end
        else
            if state.speedConn then state.speedConn:Disconnect(); state.speedConn = nil end
            local _, hum, _ = getCharInfo()
            if hum then hum.WalkSpeed = state.defaultSpeed end
        end
    end,
})
speedToggle:AddKeyPicker("SpeedKey", { Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Speed Toggle" })

SpeedGroup:AddSlider("SpeedSlider", {
    Text = "Speed Value", Default = state.defaultSpeed, Min = 0, Max = 300, Rounding = 0,
    Callback = function(Value) state.currentSpeed = Value end,
})
SpeedGroup:AddDropdown("BypassMode", { Values = { "WalkSpeed", "CFrame Velocity" }, Default = 1, Multi = false, Text = "Bypass Method" })
SpeedGroup:AddButton({ Text = "Reset Speed", Func = function() Options.SpeedSlider:SetValue(16) end })

local jumpToggle = SpeedGroup:AddToggle("JumpEnabled", {
    Text = "Enable Custom Jump", Default = false,
    Callback = function(Value)
        local _, hum, _ = getCharInfo()
        if hum then
            local power = Value and state.currentJumpPower or state.defaultJumpPower
            if hum.UseJumpPower then hum.JumpPower = power else hum.JumpHeight = (power / 50) * 7.2 end
        end
    end,
})
jumpToggle:AddKeyPicker("JumpKey", { Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Jump Toggle" })

SpeedGroup:AddSlider("JumpSlider", {
    Text = "Jump Power", Default = 50, Min = 0, Max = 300, Rounding = 0,
    Callback = function(Value)
        state.currentJumpPower = Value
        if Toggles.JumpEnabled.Value then
            local _, hum, _ = getCharInfo()
            if hum then if hum.UseJumpPower then hum.JumpPower = Value else hum.JumpHeight = (Value / 50) * 7.2 end end
        end
    end,
})

local noclipToggle = ExtraGroup:AddToggle("NoclipEnabled", {
    Text = "Noclip", Default = false,
    Callback = function(Value)
        if Value then
            if not state.noclipConn then
                state.noclipConn = RunService.Stepped:Connect(function()
                    local char, _, _ = getCharInfo()
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end)
            end
        else
            if state.noclipConn then state.noclipConn:Disconnect(); state.noclipConn = nil end
            resetCollision()
        end
    end,
})
noclipToggle:AddKeyPicker("NoclipKey", { Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Noclip Toggle" })

local infJumpToggle = ExtraGroup:AddToggle("InfJumpEnabled", {
    Text = "Infinite Jump", Default = false,
    Callback = function(Value)
        if Value then
            if not state.infJumpConn then
                state.infJumpConn = UserInputService.JumpRequest:Connect(function()
                    if Toggles.InfJumpEnabled.Value then
                        local _, hum, _ = getCharInfo()
                        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end
                end)
            end
        else
            if state.infJumpConn then state.infJumpConn:Disconnect(); state.infJumpConn = nil end
        end
    end,
})
infJumpToggle:AddKeyPicker("InfJumpKey", { Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Infinite Jump Toggle" })

local flyToggle = FlightGroup:AddToggle("FlyEnabled", {
    Text = "Fly", Default = false,
    Callback = function(Value)
        if Value then
            if Toggles.VFlyEnabled.Value then task.defer(function() Toggles.VFlyEnabled:SetValue(false) end) end
            local _, hum, root = getCharInfo()
            if not root then return end
            if hum then hum.PlatformStand = true end
            state.bodyVelocity = Instance.new("BodyVelocity", root)
            state.bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            state.bodyVelocity.Velocity = Vector3.zero
            state.bodyGyro = Instance.new("BodyGyro", root)
            state.bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            state.bodyGyro.CFrame = root.CFrame
            state.flyConn = RunService.RenderStepped:Connect(function()
                if not Toggles.FlyEnabled.Value then return end
                if state.bodyVelocity then state.bodyVelocity.Velocity = getFlightVector() * state.flySpeed end
                if state.bodyGyro and Camera then state.bodyGyro.CFrame = Camera.CFrame end
            end)
        else
            if state.flyConn then state.flyConn:Disconnect(); state.flyConn = nil end
            stopBodyPhysics()
        end
    end,
})
flyToggle:AddKeyPicker("FlyKey", { Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Fly Toggle" })
FlightGroup:AddSlider("FlySpeedSlider", { Text = "Fly Speed", Default = 50, Min = 10, Max = 300, Rounding = 0, Callback = function(Value) state.flySpeed = Value end })

local vflyToggle = FlightGroup:AddToggle("VFlyEnabled", {
    Text = "Vehicle Fly (VFly)", Default = false,
    Callback = function(Value)
        if Value then
            if Toggles.FlyEnabled.Value then task.defer(function() Toggles.FlyEnabled:SetValue(false) end) end
            local vehiclePart = getVehiclePart()
            if not vehiclePart then 
                Library:Notify("VFly: 乗り物（座席）に乗った状態でオンにしてください", 3)
                task.defer(function() Toggles.VFlyEnabled:SetValue(false) end)
                return 
            end
            stopVFlyPhysics()
            state.vflyBV = Instance.new("BodyVelocity", vehiclePart)
            state.vflyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            state.vflyBV.Velocity = Vector3.zero
            state.vflyBG = Instance.new("BodyGyro", vehiclePart)
            state.vflyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            state.vflyBG.P = 10000
            state.vflyBG.CFrame = vehiclePart.CFrame
            state.vflyConn = RunService.RenderStepped:Connect(function()
                if not Toggles.VFlyEnabled.Value then return end
                local targetVehicle = getVehiclePart()
                if not targetVehicle then task.defer(function() Toggles.VFlyEnabled:SetValue(false) end) return end
                if state.vflyBV then state.vflyBV.Parent = targetVehicle; state.vflyBV.Velocity = getFlightVector() * state.vflySpeed end
                if state.vflyBG and Camera then state.vflyBG.Parent = targetVehicle; state.vflyBG.CFrame = Camera.CFrame end
            end)
        else
            if state.vflyConn then state.vflyConn:Disconnect(); state.vflyConn = nil end
            stopVFlyPhysics()
        end
    end,
})
vflyToggle:AddKeyPicker("VFlyKey", { Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "VFly Toggle" })
FlightGroup:AddSlider("VFlySpeedSlider", { Text = "VFly Speed", Default = 50, Min = 10, Max = 300, Rounding = 0, Callback = function(Value) state.vflySpeed = Value end })

-- ==================== WORLD TAB ====================

PhysicsGroup:AddToggle("CustomGravity", {
    Text = "Enable Custom Gravity", Default = false,
    Callback = function(Value) Workspace.Gravity = Value and state.currentGravity or state.defaultGravity end,
})
PhysicsGroup:AddSlider("GravitySlider", {
    Text = "Gravity", Default = 196.2, Min = 0, Max = 500, Rounding = 1,
    Callback = function(Value)
        state.currentGravity = Value
        if Toggles.CustomGravity.Value then Workspace.Gravity = Value end
    end,
})
PhysicsGroup:AddButton({ Text = "Reset to Default (196.2)", Func = function() Options.GravitySlider:SetValue(196.2) end })

EnvironmentGroup:AddSlider("TimeSlider", { Text = "Time of Day", Default = Lighting.ClockTime, Min = 0, Max = 24, Rounding = 1, Callback = function(Value) Lighting.ClockTime = Value end })

local SkyboxData = {
    ["Space"] = { Bk = 159454299, Dn = 159454296, Ft = 159454293, Lf = 159454286, Rt = 159454300, Up = 159454288 },
    ["Vaporwave"] = { Bk = 1417494030, Dn = 1417494146, Ft = 1417494253, Lf = 1417494402, Rt = 1417494499, Up = 1417494598 },
    ["Night"] = { Bk = 120640474, Dn = 120640478, Ft = 120640484, Lf = 120640489, Rt = 120640494, Up = 120640502 },
    ["Red Moon"] = { Bk = 687820152, Dn = 687820152, Ft = 687820152, Lf = 687820152, Rt = 687820152, Up = 687820152 }
}

EnvironmentGroup:AddDropdown("SkyboxDropdown", {
    Values = { "Default", "Space", "Vaporwave", "Night", "Red Moon" },
    Default = 1, Multi = false, Text = "Custom Skybox",
    Callback = function(Value)
        if state.customSky then state.customSky:Destroy(); state.customSky = nil end
        if Value ~= "Default" and SkyboxData[Value] then
            local data = SkyboxData[Value]
            state.customSky = Instance.new("Sky")
            state.customSky.Name = "AuroraCustomSky"
            state.customSky.SkyboxBk, state.customSky.SkyboxDn, state.customSky.SkyboxFt = "rbxassetid://"..data.Bk, "rbxassetid://"..data.Dn, "rbxassetid://"..data.Ft
            state.customSky.SkyboxLf, state.customSky.SkyboxRt, state.customSky.SkyboxUp = "rbxassetid://"..data.Lf, "rbxassetid://"..data.Rt, "rbxassetid://"..data.Up
            state.customSky.Parent = Lighting
        end
    end,
})

-- ==================== VISUALS (ESP) TAB ====================

local espCache = {}

local function createESP(player)
    if not espCache[player] then
        espCache[player] = {
            Box = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            ToolText = Drawing.new("Text"),
            HealthBg = Drawing.new("Square"),
            HealthBar = Drawing.new("Square"),
            OffScreenText = Drawing.new("Text"),
            Highlight = Instance.new("Highlight"),
            Skeleton = {
                Head_UpperTorso = Drawing.new("Line"),
                UpperTorso_LowerTorso = Drawing.new("Line"),
                LeftUpperArm_LeftLowerArm = Drawing.new("Line"),
                LeftLowerArm_LeftHand = Drawing.new("Line"),
                RightUpperArm_RightLowerArm = Drawing.new("Line"),
                RightLowerArm_RightHand = Drawing.new("Line"),
                LeftUpperLeg_LeftLowerLeg = Drawing.new("Line"),
                LeftLowerLeg_LeftFoot = Drawing.new("Line"),
                RightUpperLeg_RightLowerLeg = Drawing.new("Line"),
                RightLowerLeg_RightFoot = Drawing.new("Line"),
                UpperTorso_LeftUpperArm = Drawing.new("Line"),
                UpperTorso_RightUpperArm = Drawing.new("Line"),
                LowerTorso_LeftUpperLeg = Drawing.new("Line"),
                LowerTorso_RightUpperLeg = Drawing.new("Line"),
            }
        }
        
        local cache = espCache[player]
        cache.Box.Thickness = 1; cache.Box.Filled = false
        cache.Tracer.Thickness = 1
        cache.Name.Size = 15; cache.Name.Center = true; cache.Name.Outline = true
        cache.Distance.Size = 13; cache.Distance.Center = true; cache.Distance.Outline = true
        cache.ToolText.Size = 13; cache.ToolText.Center = true; cache.ToolText.Outline = true
        cache.HealthBg.Filled = true; cache.HealthBg.Color = Color3.fromRGB(0, 0, 0); cache.HealthBg.Thickness = 1
        cache.HealthBar.Filled = true; cache.HealthBar.Thickness = 1
        cache.OffScreenText.Size = 18; cache.OffScreenText.Center = true; cache.OffScreenText.Outline = true
        
        cache.Highlight.FillTransparency = 1
        cache.Highlight.OutlineTransparency = 0
        cache.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        
        for _, line in pairs(cache.Skeleton) do
            line.Thickness = 1
        end
    end
    return espCache[player]
end

local function removeESP(player)
    if espCache[player] then
        for k, v in pairs(espCache[player]) do
            if k == "Skeleton" then
                for _, line in pairs(v) do pcall(function() line:Remove() end) end
            else
                pcall(function() v:Remove() end)
                pcall(function() v:Destroy() end)
            end
        end
        espCache[player] = nil
    end
end

Players.PlayerRemoving:Connect(removeESP)

ESPGroup:AddToggle("BoxESP", { Text = "Box ESP", Default = false })
ESPGroup:AddToggle("PlayerESP", { Text = "Player Outline", Default = false })
ESPGroup:AddToggle("ChamsESP", { Text = "Chams (Fill Body)", Default = false })
ESPGroup:AddToggle("LinesESP", { Text = "Lines ESP", Default = false })
ESPGroup:AddDropdown("TracerOrigin", { Values = {"Bottom", "Center", "Mouse"}, Default = 1, Multi = false, Text = "Line Origin" })
ESPGroup:AddToggle("NameESP", { Text = "Name ESP", Default = false })
ESPGroup:AddToggle("DistanceESP", { Text = "Distance ESP", Default = false })
ESPGroup:AddToggle("HealthESP", { Text = "Health Bar", Default = false })
ESPGroup:AddToggle("SkeletonESP", { Text = "Skeleton ESP", Default = false })
ESPGroup:AddToggle("WeaponESP", { Text = "Weapon/Tool ESP", Default = false })
ESPGroup:AddToggle("OffScreenESP", { Text = "Off-screen Arrows", Default = false })

ESPSettingsGroup:AddToggle("TeamESP", { Text = "Team Check (Gray for team)", Default = false })
ESPSettingsGroup:AddLabel("ESP Color"):AddColorPicker("ESPColor", { Default = Color3.fromRGB(255, 0, 0), Title = "Enemy/Default Color" })
ESPSettingsGroup:AddSlider("ChamsTransparency", { Text = "Chams Fill Alpha", Default = 0.5, Min = 0.1, Max = 1, Rounding = 1 })

state.espConn = RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        
        local esp = createESP(plr)
        local char, hum, root = getCharInfo(plr)
        local isAlive = char and root and hum and hum.Health > 0
        
        if isAlive then
            local isTeammate = LocalPlayer.Team and LocalPlayer.Team == plr.Team
            local targetColor = Options.ESPColor.Value
            if Toggles.TeamESP.Value and isTeammate then
                targetColor = Color3.fromRGB(150, 150, 150)
            end
            
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if Toggles.PlayerESP.Value or Toggles.ChamsESP.Value then
                esp.Highlight.Parent = char
                esp.Highlight.OutlineColor = targetColor
                if Toggles.ChamsESP.Value then
                    esp.Highlight.FillColor = targetColor
                    esp.Highlight.FillTransparency = Options.ChamsTransparency.Value
                else
                    esp.Highlight.FillTransparency = 1
                end
                esp.Highlight.Enabled = true
            else
                esp.Highlight.Enabled = false
            end
            
            if onScreen then
                esp.OffScreenText.Visible = false
                
                local head = char:FindFirstChild("Head")
                local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or pos
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2
                local boxX = pos.X - width / 2
                local boxY = headPos.Y
                
                if Toggles.BoxESP.Value then
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(boxX, boxY)
                    esp.Box.Color = targetColor
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end
                
                if Toggles.HealthESP.Value then
                    local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local barHeight = height * healthPct
                    esp.HealthBg.Size = Vector2.new(3, height + 2)
                    esp.HealthBg.Position = Vector2.new(boxX - 6, boxY - 1)
                    esp.HealthBg.Visible = true
                    
                    esp.HealthBar.Size = Vector2.new(1, barHeight)
                    esp.HealthBar.Position = Vector2.new(boxX - 5, boxY + (height - barHeight))
                    esp.HealthBar.Color = Color3.fromRGB(255 - (healthPct * 255), healthPct * 255, 0)
                    esp.HealthBar.Visible = true
                else
                    esp.HealthBg.Visible = false
                    esp.HealthBar.Visible = false
                end
                
                if Toggles.LinesESP.Value then
                    local origin = Vector2.zero
                    local mode = Options.TracerOrigin.Value
                    local viewSize = Camera.ViewportSize
                    if mode == "Center" then origin = Vector2.new(viewSize.X / 2, viewSize.Y / 2)
                    elseif mode == "Bottom" then origin = Vector2.new(viewSize.X / 2, viewSize.Y)
                    elseif mode == "Mouse" then origin = UserInputService:GetMouseLocation() end
                    
                    esp.Tracer.From = origin
                    esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.Tracer.Color = targetColor
                    esp.Tracer.Visible = true
                else
                    esp.Tracer.Visible = false
                end
                
                local currentY = boxY - 18
                if Toggles.NameESP.Value then
                    esp.Name.Text = plr.Name
                    esp.Name.Position = Vector2.new(pos.X, currentY)
                    esp.Name.Color = targetColor
                    esp.Name.Visible = true
                    currentY = currentY - 14
                else
                    esp.Name.Visible = false
                end
                
                if Toggles.DistanceESP.Value then
                    local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                    esp.Distance.Text = "[" .. tostring(dist) .. "m]"
                    esp.Distance.Position = Vector2.new(pos.X, currentY)
                    esp.Distance.Color = targetColor
                    esp.Distance.Visible = true
                    currentY = currentY - 14
                else
                    esp.Distance.Visible = false
                end
                
                if Toggles.WeaponESP.Value then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        esp.ToolText.Text = tool.Name
                        esp.ToolText.Position = Vector2.new(pos.X, boxY + height + 2)
                        esp.ToolText.Color = targetColor
                        esp.ToolText.Visible = true
                    else
                        esp.ToolText.Visible = false
                    end
                else
                    esp.ToolText.Visible = false
                end
                
                if Toggles.SkeletonESP.Value then
                    local function getJointPos(partName)
                        local p = char:FindFirstChild(partName)
                        if p then
                            local v, vis = Camera:WorldToViewportPoint(p.Position)
                            if vis then return Vector2.new(v.X, v.Y) end
                        end
                        return nil
                    end
                    
                    local headP = getJointPos("Head")
                    local upperTorsoP = getJointPos("UpperTorso") or getJointPos("Torso")
                    local lowerTorsoP = getJointPos("LowerTorso") or upperTorsoP
                    
                    if headP and upperTorsoP then esp.Skeleton.Head_UpperTorso.From = headP; esp.Skeleton.Head_UpperTorso.To = upperTorsoP; esp.Skeleton.Head_UpperTorso.Color = targetColor; esp.Skeleton.Head_UpperTorso.Visible = true else esp.Skeleton.Head_UpperTorso.Visible = false end
                    if upperTorsoP and lowerTorsoP then esp.Skeleton.UpperTorso_LowerTorso.From = upperTorsoP; esp.Skeleton.UpperTorso_LowerTorso.To = lowerTorsoP; esp.Skeleton.UpperTorso_LowerTorso.Color = targetColor; esp.Skeleton.UpperTorso_LowerTorso.Visible = true else esp.Skeleton.UpperTorso_LowerTorso.Visible = false end
                    
                    local lUA, lLA, lH = getJointPos("LeftUpperArm"), getJointPos("LeftLowerArm"), getJointPos("LeftHand")
                    if upperTorsoP and lUA then esp.Skeleton.UpperTorso_LeftUpperArm.From = upperTorsoP; esp.Skeleton.UpperTorso_LeftUpperArm.To = lUA; esp.Skeleton.UpperTorso_LeftUpperArm.Color = targetColor; esp.Skeleton.UpperTorso_LeftUpperArm.Visible = true else esp.Skeleton.UpperTorso_LeftUpperArm.Visible = false end
                    if lUA and lLA then esp.Skeleton.LeftUpperArm_LeftLowerArm.From = lUA; esp.Skeleton.LeftUpperArm_LeftLowerArm.To = lLA; esp.Skeleton.LeftUpperArm_LeftLowerArm.Visible = true; esp.Skeleton.LeftUpperArm_LeftLowerArm.Color = targetColor else esp.Skeleton.LeftUpperArm_LeftLowerArm.Visible = false end
                    if lLA and lH then esp.Skeleton.LeftLowerArm_LeftHand.From = lLA; esp.Skeleton.LeftLowerArm_LeftHand.To = lH; esp.Skeleton.LeftLowerArm_LeftHand.Visible = true; esp.Skeleton.LeftLowerArm_LeftHand.Color = targetColor else esp.Skeleton.LeftLowerArm_LeftHand.Visible = false end
                    
                    local rUA, rLA, rH = getJointPos("RightUpperArm"), getJointPos("RightLowerArm"), getJointPos("RightHand")
                    if upperTorsoP and rUA then esp.Skeleton.UpperTorso_RightUpperArm.From = upperTorsoP; esp.Skeleton.UpperTorso_RightUpperArm.To = rUA; esp.Skeleton.UpperTorso_RightUpperArm.Color = targetColor; esp.Skeleton.UpperTorso_RightUpperArm.Visible = true else esp.Skeleton.UpperTorso_RightUpperArm.Visible = false end
                    if rUA and rLA then esp.Skeleton.RightUpperArm_RightLowerArm.From = rUA; esp.Skeleton.RightUpperArm_RightLowerArm.To = rLA; esp.Skeleton.RightUpperArm_RightLowerArm.Visible = true; esp.Skeleton.RightUpperArm_RightLowerArm.Color = targetColor else esp.Skeleton.RightUpperArm_RightLowerArm.Visible = false end
                    if rLA and rH then esp.Skeleton.RightLowerArm_RightHand.From = rLA; esp.Skeleton.RightLowerArm_RightHand.To = rH; esp.Skeleton.RightLowerArm_RightHand.Visible = true; esp.Skeleton.RightLowerArm_RightHand.Color = targetColor else esp.Skeleton.RightLowerArm_RightHand.Visible = false end

                    local lUL, lLL, lF = getJointPos("LeftUpperLeg"), getJointPos("LeftLowerLeg"), getJointPos("LeftFoot")
                    if lowerTorsoP and lUL then esp.Skeleton.LowerTorso_LeftUpperLeg.From = lowerTorsoP; esp.Skeleton.LowerTorso_LeftUpperLeg.To = lUL; esp.Skeleton.LowerTorso_LeftUpperLeg.Visible = true; esp.Skeleton.LowerTorso_LeftUpperLeg.Color = targetColor else esp.Skeleton.LowerTorso_LeftUpperLeg.Visible = false end
                    if lUL and lLL then esp.Skeleton.LeftUpperLeg_LeftLowerLeg.From = lUL; esp.Skeleton.LeftUpperLeg_LeftLowerLeg.To = lLL; esp.Skeleton.LeftUpperLeg_LeftLowerLeg.Visible = true; esp.Skeleton.LeftUpperLeg_LeftLowerLeg.Color = targetColor else esp.Skeleton.LeftUpperLeg_LeftLowerLeg.Visible = false end
                    if lLL and lF then esp.Skeleton.LeftLowerLeg_LeftFoot.From = lLL; esp.Skeleton.LeftLowerLeg_LeftFoot.To = lF; esp.Skeleton.LeftLowerLeg_LeftFoot.Visible = true; esp.Skeleton.LeftLowerLeg_LeftFoot.Color = targetColor else esp.Skeleton.LeftLowerLeg_LeftFoot.Visible = false end

                    local rUL, rLL, rF = getJointPos("RightUpperLeg"), getJointPos("RightLowerLeg"), getJointPos("RightFoot")
                    if lowerTorsoP and rUL then esp.Skeleton.LowerTorso_RightUpperLeg.From = lowerTorsoP; esp.Skeleton.LowerTorso_RightUpperLeg.To = rUL; esp.Skeleton.LowerTorso_RightUpperLeg.Visible = true; esp.Skeleton.LowerTorso_RightUpperLeg.Color = targetColor else esp.Skeleton.LowerTorso_RightUpperLeg.Visible = false end
                    if rUL and rLL then esp.Skeleton.RightUpperLeg_RightLowerLeg.From = rUL; esp.Skeleton.RightUpperLeg_RightLowerLeg.To = rLL; esp.Skeleton.RightUpperLeg_RightLowerLeg.Visible = true; esp.Skeleton.RightUpperLeg_RightLowerLeg.Color = targetColor else esp.Skeleton.RightUpperLeg_RightLowerLeg.Visible = false end
                    if rLL and rF then esp.Skeleton.RightLowerLeg_RightFoot.From = rLL; esp.Skeleton.RightLowerLeg_RightFoot.To = rF; esp.Skeleton.RightLowerLeg_RightFoot.Visible = true; esp.Skeleton.RightLowerLeg_RightFoot.Color = targetColor else esp.Skeleton.RightLowerLeg_RightFoot.Visible = false end
                else
                    for _, l in pairs(esp.Skeleton) do l.Visible = false end
                end
            else
                esp.Box.Visible = false; esp.Tracer.Visible = false
                esp.Name.Visible = false; esp.Distance.Visible = false
                esp.ToolText.Visible = false; esp.HealthBg.Visible = false; esp.HealthBar.Visible = false
                for _, l in pairs(esp.Skeleton) do l.Visible = false end
                
                if Toggles.OffScreenESP.Value then
                    local camCFrame = Camera.CFrame
                    local relPos = camCFrame:PointToObjectSpace(root.Position)
                    if relPos.Z < 0 then relPos = -relPos end
                    local angle = math.atan2(relPos.X, relPos.Y)
                    local viewSize = Camera.ViewportSize
                    local radius = math.min(viewSize.X, viewSize.Y) * 0.4
                    local center = Vector2.new(viewSize.X / 2, viewSize.Y / 2)
                    local arrowPos = center + Vector2.new(math.sin(angle), -math.cos(angle)) * radius
                    
                    esp.OffScreenText.Text = "v " .. plr.Name .. " v"
                    esp.OffScreenText.Position = arrowPos
                    esp.OffScreenText.Color = targetColor
                    esp.OffScreenText.Visible = true
                else
                    esp.OffScreenText.Visible = false
                end
            end
        else
            esp.Box.Visible = false; esp.Tracer.Visible = false
            esp.Name.Visible = false; esp.Distance.Visible = false
            esp.ToolText.Visible = false; esp.HealthBg.Visible = false; esp.HealthBar.Visible = false
            esp.OffScreenText.Visible = false
            esp.Highlight.Enabled = false
            for _, l in pairs(esp.Skeleton) do l.Visible = false end
        end
    end
end)

-- ==================== SERVER TAB ====================

local ServerInfoGroup = Tabs.Server:AddLeftGroupbox("Server Information", "info")
local ServerActionGroup = Tabs.Server:AddRightGroupbox("Server Actions", "globe")

-- 1. サーバー詳細のラベル作成
local infoLabels = {
    Name = ServerInfoGroup:AddLabel("Place Name: Loading..."),
    ID = ServerInfoGroup:AddLabel("Place ID: Loading..."),
    Job = ServerInfoGroup:AddLabel("Job ID: Loading..."),
    Players = ServerInfoGroup:AddLabel("Players: Loading..."),
    Ping = ServerInfoGroup:AddLabel("Ping: Loading..."),
    FPS = ServerInfoGroup:AddLabel("Server FPS: Loading..."),
    Uptime = ServerInfoGroup:AddLabel("Uptime: Loading..."),
}

-- サーバー稼働時間の計測用スタート時間
local serverStartTime = tick()

-- サーバー情報のリアルタイム更新処理
task.spawn(function()
    while true do
        pcall(function()
            -- プレース名
            local marketplaceService = game:GetService("MarketplaceService")
            local success, info = pcall(function() return marketplaceService:GetProductInfo(game.PlaceId) end)
            if success and info then
                infoLabels.Name:SetText("Place Name: " .. info.Name)
            end
            
            -- ID類
            infoLabels.ID:SetText("Place ID: " .. tostring(game.PlaceId))
            infoLabels.Job:SetText("Job ID: " .. tostring(game.JobId))
            
            -- プレイヤー数
            local players = game:GetService("Players")
            infoLabels.Players:SetText("Players: " .. #players:GetPlayers() .. " / " .. players.MaxPlayers)
            
            -- Ping (レイテンシ)
            local stats = game:GetService("Stats")
            local netStats = stats.Network.ServerStatsItem
            local pingVal = netStats["Data Ping"]:GetValue()
            infoLabels.Ping:SetText(string.format("Ping: %.1f ms", pingVal))
            
            -- サーバーFPS
            local fps = 60
            pcall(function()
                fps = math.floor(workspace:GetRealPhysicsFPS())
            end)
            infoLabels.FPS:SetText("Server FPS: " .. tostring(fps))
            
            -- サーバー稼働時間 (Uptime)
            local uptimeSeconds = math.floor(tick() - serverStartTime)
            local hours = math.floor(uptimeSeconds / 3600)
            local minutes = math.floor((uptimeSeconds % 3600) / 60)
            local seconds = uptimeSeconds % 60
            infoLabels.Uptime:SetText(string.format("Uptime: %02d:%02d:%02d", hours, minutes, seconds))
        end)
        task.wait(1)
    end
end)

-- 2. サーバー操作・機能の追加
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 通常のサーバーホップ
ServerActionGroup:AddButton({
    Text = "Server Hop",
    Func = function()
        Library:Notify("Searching for a new server...", 3)
        local servers = {}
        local success, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and res and res.data then
            for _, s in ipairs(res.data) do
                if type(s) == "table" and s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(servers, s.id)
                end
            end
        end
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            Library:Notify("No servers found, retrying normal teleport...", 3)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end
})

-- 低人数サーバーホップ (1〜3人優先)
ServerActionGroup:AddButton({
    Text = "Low Player Hop (1-3)",
    Func = function()
        Library:Notify("Searching for low player servers...", 3)
        local servers = {}
        local success, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and res and res.data then
            for _, s in ipairs(res.data) do
                if type(s) == "table" and s.id ~= game.JobId and s.playing >= 1 and s.playing <= 3 then
                    table.insert(servers, s.id)
                end
            end
        end
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            Library:Notify("No low player servers found. Trying standard hop...", 3)
        end
    end
})

-- サーバーリジョイン
ServerActionGroup:AddButton({
    Text = "Rejoin Server",
    Func = function()
        Library:Notify("Rejoining current server...", 2)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- Job IDで参加機能 (入力欄 + ボタン)
local targetJobId = ""
ServerActionGroup:AddInput("JobIdInput", {
    Title = "Target Job ID",
    Default = "",
    Placeholder = "Paste Job ID here...",
    Callback = function(value)
        targetJobId = value
    end
})

ServerActionGroup:AddButton({
    Text = "Join by Job ID",
    Func = function()
        if targetJobId and targetJobId ~= "" then
            Library:Notify("Teleporting to Job ID...", 2)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
            end)
        else
            Library:Notify("Please enter a valid Job ID first!", 2)
        end
    end
})

-- フレンドのサーバーに参加機能
ServerActionGroup:AddButton({
    Text = "Join Friend's Server",
    Func = function()
        Library:Notify("Checking online friends...", 2)
        local onlineFriends = {}
        pcall(function()
            onlineFriends = LocalPlayer:GetFriendsOnline()
        end)
        
        local found = false
        for _, friend in ipairs(onlineFriends) do
            if friend.PlaceId == game.PlaceId and friend.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, friend.JobId, LocalPlayer)
                found = true
                break
            end
        end
        
        if not found then
            Library:Notify("No friends are currently playing this game.", 3)
        end
    end
})

-- Job IDをコピーするボタン
ServerActionGroup:AddButton({
    Text = "Copy Job ID",
    Func = function()
        if setclipboard then
            setclipboard(game.JobId)
            Library:Notify("Job ID copied to clipboard!", 2)
        else
            Library:Notify("Clipboard not supported on your executor.", 2)
        end
    end
})

-- サーバー退出機能 (メッセージ指定付き)
ServerActionGroup:AddButton({
    Text = "Exit Server",
    Func = function()
        LocalPlayer:Kick("AuroraHub Server Exit Sys")
    end
})

-- ==================== CROSSHAIR TAB (FULL VERSION) ====================

local CrosshairMainGroup = Tabs.Crosshair:AddLeftGroupbox("Crosshair Elements", "target")
local CrosshairStyleGroup = Tabs.Crosshair:AddRightGroupbox("Style & Advanced", "settings")

-- 1. メイン要素の設定
CrosshairMainGroup:AddToggle("CH_Enabled", { Text = "Enable Custom Crosshair", Default = false })
CrosshairMainGroup:AddDropdown("CH_Position", { Values = { "Center Screen", "Mouse Position" }, Default = 1, Multi = false, Text = "Display Position" })

CrosshairMainGroup:AddDivider()

-- ドット関連
CrosshairMainGroup:AddToggle("CH_Dot", { Text = "Center Dot", Default = true })
CrosshairMainGroup:AddSlider("CH_DotSize", { Text = "Dot Size", Default = 2, Min = 1, Max = 10, Rounding = 0 })
CrosshairMainGroup:AddToggle("CH_DotFill", { Text = "Dot Fill (Solid)", Default = true })

-- 丸・枠線関連
CrosshairMainGroup:AddToggle("CH_Circle", { Text = "Outer Circle", Default = false })
CrosshairMainGroup:AddSlider("CH_CircleRadius", { Text = "Circle Radius", Default = 15, Min = 5, Max = 50, Rounding = 0 })
CrosshairMainGroup:AddToggle("CH_CircleFill", { Text = "Circle Fill Inside", Default = false })

-- 十字線関連
CrosshairMainGroup:AddToggle("CH_Lines", { Text = "Crosshair Lines (4-Way)", Default = true })
CrosshairMainGroup:AddSlider("CH_LineLength", { Text = "Line Length", Default = 6, Min = 1, Max = 30, Rounding = 0 })
CrosshairMainGroup:AddSlider("CH_LineThickness", { Text = "Line Thickness", Default = 1, Min = 1, Max = 5, Rounding = 0 })
CrosshairMainGroup:AddSlider("CH_LineGap", { Text = "Line Gap", Default = 4, Min = 0, Max = 25, Rounding = 0 })

-- 2. スタイル・カラー・アドバンス設定
CrosshairStyleGroup:AddToggle("CH_Outline", { Text = "Black Outline (Border)", Default = true })
CrosshairStyleGroup:AddToggle("CH_TStyle", { Text = "T-Shape (Remove Top Line)", Default = false })
CrosshairStyleGroup:AddToggle("CH_TargetColor", { Text = "Enemy Target Color Change", Default = true })
CrosshairStyleGroup:AddToggle("CH_Dynamic", { Text = "Dynamic Spread (Move/Action)", Default = false })
CrosshairStyleGroup:AddSlider("CH_DynamicMultiplier", { Text = "Spread Intensity", Default = 5, Min = 1, Max = 20, Rounding = 0 })

CrosshairStyleGroup:AddLabel("Crosshair Color"):AddColorPicker("CH_Color", { Default = Color3.fromRGB(0, 255, 0), Title = "Crosshair Main Color" })
CrosshairStyleGroup:AddLabel("Enemy Hit Color"):AddColorPicker("CH_HitColor", { Default = Color3.fromRGB(255, 0, 0), Title = "Enemy Hit Color" })
CrosshairStyleGroup:AddSlider("CH_Transparency", { Text = "Transparency", Default = 1, Min = 0.1, Max = 1, Rounding = 1 })

-- ==================== DRAWING OBJECTS ====================
local chDrawings = {
    Dot = Drawing.new("Square"),
    DotOutline = Drawing.new("Square"),
    Circle = Drawing.new("Circle"),
    CircleOutline = Drawing.new("Circle"),
    Lines = {
        Top = Drawing.new("Line"),
        Bottom = Drawing.new("Line"),
        Left = Drawing.new("Line"),
        Right = Drawing.new("Line"),
    },
    Outlines = {
        Top = Drawing.new("Line"),
        Bottom = Drawing.new("Line"),
        Left = Drawing.new("Line"),
        Right = Drawing.new("Line"),
    }
}

chDrawings.Dot.Filled = true
chDrawings.DotOutline.Filled = false
chDrawings.Circle.Filled = false
chDrawings.CircleOutline.Filled = false

for _, line in pairs(chDrawings.Lines) do line.Thickness = 1 end
for _, outline in pairs(chDrawings.Outlines) do outline.Thickness = 2 end

-- ダイナミック用スプレッドの追従変数
local currentDynamicSpread = 0

-- 描画・更新ループ
local chConnection
chConnection = RunService.RenderStepped:Connect(function(dt)
    local enabled = Toggles.CH_Enabled and Toggles.CH_Enabled.Value
    if not enabled then
        chDrawings.Dot.Visible = false
        chDrawings.DotOutline.Visible = false
        chDrawings.Circle.Visible = false
        chDrawings.CircleOutline.Visible = false
        for _, l in pairs(chDrawings.Lines) do l.Visible = false end
        for _, o in pairs(chDrawings.Outlines) do o.Visible = false end
        return
    end
    
    -- 表示位置の計算
    local pos = Camera.ViewportSize / 2
    if Options.CH_Position and Options.CH_Position.Value == "Mouse Position" then
        pos = UserInputService:GetMouseLocation()
    end
    
    -- 敵（プレイヤー）にクロスヘアが重なっているかの判定
    local isTargetingEnemy = false
    if Toggles.CH_TargetColor and Toggles.CH_TargetColor.Value then
        local target = Mouse.Target
        if target then
            local model = target:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChildOfClass("Humanoid") then
                local plr = Players:GetPlayerFromCharacter(model)
                if plr and plr ~= LocalPlayer then
                    if not (LocalPlayer.Team and LocalPlayer.Team == plr.Team) then
                        isTargetingEnemy = true
                    end
                end
            end
        end
    end
    
    local mainColor = Options.CH_Color.Value
    if isTargetingEnemy and Options.CH_HitColor then
        mainColor = Options.CH_HitColor.Value
    end
    local trans = Options.CH_Transparency and Options.CH_Transparency.Value or 1
    local outlineEnabled = Toggles.CH_Outline and Toggles.CH_Outline.Value
    
    -- ダイナミック・スプレッド（移動・発射時の広がり）の計算
    local targetSpread = 0
    if Toggles.CH_Dynamic and Toggles.CH_Dynamic.Value then
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local speed = rootPart.AssemblyLinearVelocity.Magnitude
                local multiplier = Options.CH_DynamicMultiplier and Options.CH_DynamicMultiplier.Value or 5
                if speed > 2 then
                    targetSpread = math.min(speed / 16 * multiplier, 25)
                end
                -- 左クリック（発射動作）時にブレを追加
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    targetSpread = targetSpread + (multiplier * 0.8)
                end
            end
        end
    end
    -- スムージングを効かせて滑らかに広がり・縮小させる
    currentDynamicSpread = currentDynamicSpread + (targetSpread - currentDynamicSpread) * math.clamp(dt * 15, 0, 1)
    
    -- 1. ドットの描画
    if Toggles.CH_Dot and Toggles.CH_Dot.Value then
        local size = Options.CH_DotSize and Options.CH_DotSize.Value or 2
        local filled = Toggles.CH_DotFill and Toggles.CH_DotFill.Value
        
        chDrawings.Dot.Size = Vector2.new(size, size)
        chDrawings.Dot.Position = pos - Vector2.new(size/2, size/2)
        chDrawings.Dot.Color = mainColor
        chDrawings.Dot.Transparency = trans
        chDrawings.Dot.Filled = filled
        chDrawings.Dot.Visible = true
        
        if outlineEnabled then
            chDrawings.DotOutline.Size = Vector2.new(size + 2, size + 2)
            chDrawings.DotOutline.Position = pos - Vector2.new((size + 2)/2, (size + 2)/2)
            chDrawings.DotOutline.Color = Color3.fromRGB(0, 0, 0)
            chDrawings.DotOutline.Transparency = trans
            chDrawings.DotOutline.Visible = true
        else
            chDrawings.DotOutline.Visible = false
        end
    else
        chDrawings.Dot.Visible = false
        chDrawings.DotOutline.Visible = false
    end
    
    -- 2. 丸の描画
    if Toggles.CH_Circle and Toggles.CH_Circle.Value then
        local radius = (Options.CH_CircleRadius and Options.CH_CircleRadius.Value or 15) + (currentDynamicSpread * 0.5)
        local circleFilled = Toggles.CH_CircleFill and Toggles.CH_CircleFill.Value
        
        chDrawings.Circle.Radius = radius
        chDrawings.Circle.Position = pos
        chDrawings.Circle.Color = mainColor
        chDrawings.Circle.Transparency = trans
        chDrawings.Circle.Filled = circleFilled
        chDrawings.Circle.Visible = true
        
        if outlineEnabled then
            chDrawings.CircleOutline.Radius = radius
            chDrawings.CircleOutline.Position = pos
            chDrawings.CircleOutline.Color = Color3.fromRGB(0, 0, 0)
            chDrawings.CircleOutline.Transparency = trans
            chDrawings.CircleOutline.Visible = true
        else
            chDrawings.CircleOutline.Visible = false
        end
    else
        chDrawings.Circle.Visible = false
        chDrawings.CircleOutline.Visible = false
    end
    
    -- 3. 十字線の描画
    if Toggles.CH_Lines and Toggles.CH_Lines.Value then
        local length = Options.CH_LineLength and Options.CH_LineLength.Value or 6
        local thickness = Options.CH_LineThickness and Options.CH_LineThickness.Value or 1
        local gap = (Options.CH_LineGap and Options.CH_LineGap.Value or 4) + currentDynamicSpread
        local isT = Toggles.CH_TStyle and Toggles.CH_TStyle.Value
        
        for _, l in pairs(chDrawings.Lines) do l.Thickness = thickness; l.Color = mainColor; l.Transparency = trans end
        for _, o in pairs(chDrawings.Outlines) do o.Thickness = thickness + 2; o.Color = Color3.fromRGB(0, 0, 0); o.Transparency = trans end
        
        -- 上の線 (T型の場合は非表示)
        if not isT then
            chDrawings.Lines.Top.From = pos - Vector2.new(0, gap + length)
            chDrawings.Lines.Top.To = pos - Vector2.new(0, gap)
            chDrawings.Lines.Top.Visible = true
            if outlineEnabled then
                chDrawings.Outlines.Top.From = chDrawings.Lines.Top.From
                chDrawings.Outlines.Top.To = chDrawings.Lines.Top.To
                chDrawings.Outlines.Top.Visible = true
            else chDrawings.Outlines.Top.Visible = false end
        else
            chDrawings.Lines.Top.Visible = false
            chDrawings.Outlines.Top.Visible = false
        end
        
        -- 下の線
        chDrawings.Lines.Bottom.From = pos + Vector2.new(0, gap)
        chDrawings.Lines.Bottom.To = pos + Vector2.new(0, gap + length)
        chDrawings.Lines.Bottom.Visible = true
        if outlineEnabled then
            chDrawings.Outlines.Bottom.From = chDrawings.Lines.Bottom.From
            chDrawings.Outlines.Bottom.To = chDrawings.Lines.Bottom.To
            chDrawings.Outlines.Bottom.Visible = true
        else chDrawings.Outlines.Bottom.Visible = false end
        
        -- 左の線
        chDrawings.Lines.Left.From = pos - Vector2.new(gap + length, 0)
        chDrawings.Lines.Left.To = pos - Vector2.new(gap, 0)
        chDrawings.Lines.Left.Visible = true
        if outlineEnabled then
            chDrawings.Outlines.Left.From = chDrawings.Lines.Left.From
            chDrawings.Outlines.Left.To = chDrawings.Lines.Left.To
            chDrawings.Outlines.Left.Visible = true
        else chDrawings.Outlines.Left.Visible = false end
        
        -- 右の線
        chDrawings.Lines.Right.From = pos + Vector2.new(gap, 0)
        chDrawings.Lines.Right.To = pos + Vector2.new(gap + length, 0)
        chDrawings.Lines.Right.Visible = true
        if outlineEnabled then
            chDrawings.Outlines.Right.From = chDrawings.Lines.Right.From
            chDrawings.Outlines.Right.To = chDrawings.Lines.Right.To
            chDrawings.Outlines.Right.Visible = true
        else chDrawings.Outlines.Right.Visible = false end
    else
        for _, l in pairs(chDrawings.Lines) do l.Visible = false end
        for _, o in pairs(chDrawings.Outlines) do o.Visible = false end
    end
end)

-- アンロード時のメモリ解放処理
Library:OnUnload(function()
    if chConnection then chConnection:Disconnect() end
    pcall(function()
        chDrawings.Dot:Remove()
        chDrawings.DotOutline:Remove()
        chDrawings.Circle:Remove()
        chDrawings.CircleOutline:Remove()
        for _, l in pairs(chDrawings.Lines) do l:Remove() end
        for _, o in pairs(chDrawings.Outlines) do o:Remove() end
    end)
end)

-- ==================== UI SETTINGS ====================

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu Settings", "wrench")
MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end })
MenuGroup:AddLabel("Menu Bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu Keybind" })

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("AuroraHub")
SaveManager:SetFolder("AuroraHub/configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    if state.speedConn then state.speedConn:Disconnect() end
    if state.noclipConn then state.noclipConn:Disconnect() end
    if state.infJumpConn then state.infJumpConn:Disconnect() end
    if state.flyConn then state.flyConn:Disconnect() end
    if state.vflyConn then state.vflyConn:Disconnect() end
    if state.espConn then state.espConn:Disconnect() end
    if state.combatConn then state.combatConn:Disconnect() end
    
    pcall(function() fovCircle:Remove() end)
    for plr, _ in pairs(espCache) do removeESP(plr) end
    
    resetCollision()
    stopBodyPhysics()
    stopVFlyPhysics()
    local _, hum, _ = getCharInfo()
    if hum then hum.WalkSpeed = state.defaultSpeed; if hum.UseJumpPower then hum.JumpPower = state.defaultJumpPower else hum.JumpHeight = (state.defaultJumpPower / 50) * 7.2 end end
    
    Workspace.Gravity = state.defaultGravity
    if state.customSky then state.customSky:Destroy() end
end)