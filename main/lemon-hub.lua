task.wait(3)
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer
repeat task.wait() until game:GetService("Players").LocalPlayer.Character

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- ホワイトリスト管理
-- ============================================
local Whitelist = {}
local WhitelistLabel = nil

local function UpdateWhitelistUI()
    if WhitelistLabel then
        local list = {}
        for name, _ in pairs(Whitelist) do
            table.insert(list, name)
        end
        if #list == 0 then
            WhitelistLabel:Set("現在ホワイトリストは空です")
        else
            WhitelistLabel:Set("保護中: " .. table.concat(list, ", "))
        end
    end
end

local function IsWhitelisted(player)
    if not player then return false end
    return Whitelist[player.Name] == true
end

local function GetNonWhitelistedPlayers()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsWhitelisted(player) then
            table.insert(list, player)
        end
    end
    return list
end

local function GetPlayerListForWhitelist()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    return list
end

-- ============================================
-- エラーハンドリングラッパー
-- ============================================
local function SafeCall(func, errorMsg)
    local success, err = pcall(func)
    if not success then
        warn("[lemon hub] " .. (errorMsg or "Error") .. ": " .. tostring(err))
    end
    return success
end

-- OrionLibの読み込み
local OrionLib = nil
local function LoadOrionLib()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
    end)
    if success and result then
        OrionLib = result
        return true
    end
    return false
end

pcall(PlayAloeFinalIntro)

print("[lemon hub] Loading OrionLib...")
local loadSuccess = false
for i = 1, 20 do
    if LoadOrionLib() then
        loadSuccess = true
        print("[lemon hub] OrionLib loaded!")
        break
    end
    task.wait(0.5)
end

if not loadSuccess then
    warn("[lemon hub] OrionLib failed to load")
    return
end

task.wait(2)

-- ============================================
-- 共通ステート管理
-- ============================================
local State = {
    CFrameSpeed = false,
    SpeedMultiplier = 2,
    InfiniteJump = false,
    FlyEnabled = false,
    FlySpeed = 50,
    AntiAim = false,
    AntiGrabEnabled = false,
    ESPEnabled = false,
    XrayEnabled = false,
    MassKillActive = false
}

local SURGICAL_SETTINGS = {
    MAX_ATTACK_FRAMES = 5,
    PACKET_DENSITY = 3,
    OFFSET = CFrame.new(0, 0, 1.85)
}

local AntiGrabProc, AGWalk = false, false
local XrayParts = {}
local nageru = 400
local nageruEnabled = false
local GrabMode = { 
    Kill = false, Sky = false, Down = false, Noclip = false,
    Kick = false, Void = false, Anchor = false 
}
local grabKillActive = false
local grabKillThread = nil

-- ============================================
-- メイン処理用変数
-- ============================================
local mapRp = RaycastParams.new()
mapRp.FilterType = Enum.RaycastFilterType.Exclude

local zoomLevel = 500
local gridRes = 12
local mapPixels = {}
local playerDots = {}
local lastScanPos = Vector3.new(0, 0, 0)

local activeSparklers = {}
local activeTVs = {}
local tv_Enabled = false
local globalConfig = { Responsiveness = 0.06 } 
local sparklerConfig = { 
    Height = 6, Radius = 22, Speed = 18.0, CurrentShape = "Wing", 
    LastSwap = 0, Order = {}, FlapStrength = 2.5 
}
local tvConfig = { 
    Height = 2, Radius = 15, Speed = 2.0, CurrentShape = "Planet", 
    LastSwap = 0, Order = {} 
}

local ObjectIDConfig = { CurrentObjectID = "FireworkSparkler" }

local function SetupPhysics(obj, list)
    local mainPart = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    if mainPart then
        pcall(function()
            if mainPart:CanSetNetworkOwnership() then
                mainPart:SetNetworkOwner(LocalPlayer)
            end
        end)
        mainPart.Anchored = false
        for _, v in pairs(mainPart:GetChildren()) do
            if v.Name == "AloeBP" or v.Name == "AloeBG" then
                v:Destroy()
            end
        end
        local bp = Instance.new("BodyPosition", mainPart)
        bp.Name = "AloeBP"
        bp.MaxForce = Vector3.new(1, 1, 1) * 1e9
        bp.P = 45000
        bp.D = 1200   
        local bg = Instance.new("BodyGyro", mainPart)
        bg.Name = "AloeBG"
        bg.MaxTorque = Vector3.new(1, 1, 1) * 1e9
        for _, p in pairs(obj:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
                p.CanTouch = false
            end
        end
        if not table.find(list, obj) then
            table.insert(list, obj)
        end
    end
end

local function SetupTVMirror(obj)
    local mainPart = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    if mainPart then
        pcall(function()
            if mainPart:CanSetNetworkOwnership() then
                mainPart:SetNetworkOwner(LocalPlayer)
            end
        end)
        mainPart.Anchored = false
        for _, v in pairs(mainPart:GetChildren()) do
            if v.Name == "TVBP" or v.Name == "TVBG" then
                v:Destroy()
            end
        end
        local bp = Instance.new("BodyPosition", mainPart)
        bp.Name = "TVBP"
        bp.MaxForce = Vector3.new(1, 1, 1) * 1e9
        bp.P = 45000
        bp.D = 1200
        local bg = Instance.new("BodyGyro", mainPart)
        bg.Name = "TVBG"
        bg.MaxTorque = Vector3.new(1, 1, 1) * 1e9
        if not table.find(activeTVs, obj) then
            table.insert(activeTVs, obj)
        end
    end
end

local function CalculateOffset(index, total, t, cfg, targetRoot)
    local r, h, s = cfg.Radius, cfg.Height, cfg.Speed
    local side = (index % 2 == 0) and 1 or -1
    local idx = math.ceil(index / 2)
    local angle = (index * (math.pi * 2) / total) + (t * (s / 5))
    
    if cfg.CurrentShape == "VerticalHeart" then
        local th = (index / total) * math.pi * 2
        local x = 16 * math.sin(th)^3
        local y = 13 * math.cos(th) - 5 * math.cos(2 * th) - 2 * math.cos(3 * th) - math.cos(4 * th)
        return targetRoot.CFrame:VectorToWorldSpace(Vector3.new(x * (r/16), y * (r/16) + h, 0))
    elseif cfg.CurrentShape == "Wing" then
        return targetRoot.CFrame:VectorToWorldSpace(Vector3.new((side * 1.5) + (side * (idx * (r / 15))), h + (math.sin(t * (s / 4) - (idx * 0.3)) * (cfg.FlapStrength or 2.5)), 1.5))
    elseif cfg.CurrentShape == "DNA" then
        local yPos = (index / total) * r - (r / 2)
        local rot = yPos * 0.4 + (t * (s / 3))
        return targetRoot.CFrame:VectorToWorldSpace(Vector3.new(math.cos(rot + (side * math.pi)) * 5, yPos + h, math.sin(rot + (side * math.pi)) * 5))
    elseif cfg.CurrentShape == "Circle" then
        return targetRoot.CFrame:VectorToWorldSpace(Vector3.new(math.cos(angle) * r, h, math.sin(angle) * r))
    elseif cfg.CurrentShape == "Lotus" then
        local rad = r * (0.7 + 0.3 * math.sin(t * (s / 3) + index))
        return targetRoot.CFrame:VectorToWorldSpace(Vector3.new(math.cos(angle) * rad, h + math.sin(t * (s / 2) + index) * 3, math.sin(angle) * rad))
    elseif cfg.CurrentShape == "Planet" then
        local rad = r * (0.8 + 0.2 * math.sin(t * (s / 5)))
        return targetRoot.CFrame:VectorToWorldSpace(Vector3.new(math.cos(angle) * rad, h + math.sin(t * (s / 3) + index) * 2, math.sin(angle) * rad))
    end
    return Vector3.new(math.cos(angle) * r, h, math.sin(angle) * r)
end

-- UI作成
local MapGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MapFrame = Instance.new("Frame", MapGui)
MapFrame.Size = UDim2.new(0, 180, 0, 180)
MapFrame.Position = UDim2.new(0.01, 0, 0.02, 0)
MapFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MapFrame.BorderColor3 = Color3.fromRGB(255, 105, 180)
MapFrame.BorderSizePixel = 2
MapFrame.ClipsDescendants = true
MapFrame.Visible = false
MapFrame.Active = true

for x = 1, gridRes do
    mapPixels[x] = {}
    for y = 1, gridRes do
        local p = Instance.new("Frame", MapFrame)
        p.Size = UDim2.new(1 / gridRes, 0, 1 / gridRes, 0)
        p.Position = UDim2.new((x - 1) / gridRes, 0, (y - 1) / gridRes, 0)
        p.BorderSizePixel = 0
        p.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        mapPixels[x][y] = p
    end
end

local CatGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local CatFrame = Instance.new("Frame", CatGui)
CatFrame.Size = UDim2.new(0, 150, 0, 120)
CatFrame.Position = UDim2.new(0.01, 0, 0.75, 0)
CatFrame.BackgroundTransparency = 1
CatFrame.Visible = false

local function CreateCatPart(id, z)
    local i = Instance.new("ImageLabel", CatFrame)
    i.Size = UDim2.new(1, 0, 1, 0)
    i.BackgroundTransparency = 1
    i.Image = "rbxassetid://" .. id
    i.ZIndex = z
    i.ResampleMode = Enum.ResamplerMode.Pixelated
    return i
end
local CatBase = CreateCatPart("13583091924", 500)
local PawL = CreateCatPart("13583103443", 501)
local PawR = CreateCatPart("13583115456", 501)
PawL.Visible, PawR.Visible = false, false

-- ============================================
-- ロジック: 掴む (Grab) 拡張
-- ============================================
Workspace.ChildAdded:Connect(function(model)
    if model.Name == "GrabParts" then
        task.wait()
        local grabPart = model:FindFirstChild("GrabPart")
        local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
        local target = weld and weld.Part1
        if not target then return end
        local targetChar = target.Parent
        if targetChar == LocalPlayer.Character then return end
        local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
        if IsWhitelisted(targetPlayer) then return end

        local hrp = targetChar:FindFirstChild("HumanoidRootPart")
        local hum = targetChar:FindFirstChild("Humanoid")
        local isObject = not hum

        if GrabMode.Kill and hum then targetChar:BreakJoints() end
        
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Parent = target
        if GrabMode.Sky then bv.Velocity = Vector3.new(0, 20, 0)
        elseif GrabMode.Down then bv.Velocity = Vector3.new(0, -20, 0)
        else bv:Destroy() end

        if GrabMode.Noclip then
            for _, p in pairs(targetChar:GetChildren()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end

        if GrabMode.Kick and hrp then
            task.spawn(function()
                while model.Parent == Workspace do
                    if IsWhitelisted(targetPlayer) then break end
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.CFrame = CFrame.new(9e8, 9e8, 9e8)
                    task.wait()
                end
            end)
        end

        if GrabMode.Void and hrp then
            task.spawn(function()
                while model.Parent == Workspace do
                    if IsWhitelisted(targetPlayer) then break end
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = CFrame.new(hrp.Position.X, -1500, hrp.Position.Z)
                    task.wait()
                end
            end)
        end

        if GrabMode.Anchor and isObject then target.Anchored = false end

        model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                if bv and bv.Parent then bv:Destroy() end
                if nageruEnabled and target and target.Parent and not IsWhitelisted(targetPlayer) then
                    local throwV = Instance.new("BodyVelocity")
                    throwV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    throwV.Velocity = Camera.CFrame.LookVector * nageru
                    throwV.Parent = target
                    Debris:AddItem(throwV, 1)
                end
                if GrabMode.Noclip and targetChar then
                    for _, p in pairs(targetChar:GetChildren()) do
                        if p:IsA("BasePart") then p.CanCollide = true end
                    end
                end
                if GrabMode.Anchor and isObject and target then
                    target.AssemblyLinearVelocity = Vector3.zero
                    target.Anchored = true
                end
            end
        end)
    end
end)

-- ============================================
-- ロジック: アンチ掴み (Anti-Grab)
-- ============================================
local function setupAntiGrab(char)
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    local head = char:WaitForChild("Head", 5)
    if not (hrp and hum and head) then return end

    head.ChildAdded:Connect(function(PartOwner)
        if State.AntiGrabEnabled and PartOwner.Name == "PartOwner" then
            if not AntiGrabProc then
                AntiGrabProc = true
                hum.Sit = false
                local charEvents = ReplicatedStorage:FindFirstChild("CharacterEvents")
                local Struggle = charEvents and charEvents:FindFirstChild("Struggle")
                local RagdollRemote = charEvents and charEvents:FindFirstChild("RagdollRemote")
                task.spawn(function()
                    local IsHeld = char:FindFirstChild("IsHeld")
                    while (head:FindFirstChild("PartOwner")) or (IsHeld and IsHeld.Value) do
                        if Struggle then Struggle:FireServer(char) end
                        if RagdollRemote then RagdollRemote:FireServer(hrp, 0) end
                        task.wait()
                    end
                end)
                hrp.Anchored = true
                if not AGWalk then
                    AGWalk = true
                    local IsHeld = char:FindFirstChild("IsHeld")
                    while IsHeld and IsHeld.Value and task.wait() do
                        hrp.CFrame = hrp.CFrame + hum.MoveDirection * 0.43
                    end
                end
                hrp.Anchored = false
                AntiGrabProc = false
                AGWalk = false
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(setupAntiGrab)
if LocalPlayer.Character then setupAntiGrab(LocalPlayer.Character) end

-- ============================================
-- ロジック: Quantum Network Dominator v7.0
-- ============================================
local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    if IsWhitelisted(player) then return false end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    return char and root and hum and hum.Health > 0 and char.Parent == Workspace
end

local function ExecuteQuantumKill()
    local GE = ReplicatedStorage:WaitForChild("GrabEvents", 5)
    if not GE then return end

    while State.MassKillActive do
        local targets = GetNonWhitelistedPlayers()
        table.sort(targets, function(a, b)
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            return (a.Character.HumanoidRootPart.Position - myPos).Magnitude < (b.Character.HumanoidRootPart.Position - myPos).Magnitude
        end)

        for _, target in ipairs(targets) do
            if not State.MassKillActive then break end
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if IsValidTarget(target) and myRoot then
                local tChar = target.Character
                local tRoot = tChar.HumanoidRootPart
                local tHum = tChar.Humanoid

                for i = 1, SURGICAL_SETTINGS.MAX_ATTACK_FRAMES do
                    if not IsValidTarget(target) or not State.MassKillActive then break end
                    
                    myRoot.CFrame = tRoot.CFrame * SURGICAL_SETTINGS.OFFSET
                    tRoot.AssemblyLinearVelocity = Vector3.zero
                    
                    pcall(function()
                        for _ = 1, SURGICAL_SETTINGS.PACKET_DENSITY do
                            GE.SetNetworkOwner:FireServer(tRoot, tRoot.CFrame)
                            GE.CreateGrabLine:FireServer(tRoot, Vector3.new(0, -500, 0), tRoot.Position, true)
                            tHum:ChangeState(Enum.HumanoidStateType.Dead)
                            GE.DestroyGrabLine:FireServer(tRoot)
                        end
                    end)
                    RunService.PostSimulation:Wait()
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end

-- ============================================
-- Blobman機能
-- ============================================
local selectedPlayer = nil
local isGrabbingLoop = false
local autoKillEnabled = false
local isGlobalAntiVisualLoop = false

local function GetMyBlobman()
    local char = LocalPlayer.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart then return nil end
    local seat = humanoid.SeatPart
    if seat:IsA("VehicleSeat") and seat.Parent and seat.Parent.Name == "CreatureBlobman" then
        return seat.Parent
    end
    return nil
end

local function TeleportToPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if IsWhitelisted(target) then return false end
        local targetRoot = target.Character.HumanoidRootPart
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2.5)
        end
        return true
    end
    return false
end

local function KillPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        if IsWhitelisted(target) then return false end
        target.Character.Humanoid.Health = 0
        return true
    end
    return false
end

local function GetPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    return list
end

local function ExecuteFastGrabLoop(targetName)
    local creature = GetMyBlobman()
    if not creature or isGrabbingLoop then return end
    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character then return end
    if IsWhitelisted(target) then return end

    local scripts = creature:FindFirstChild("BlobmanSeatAndOwnerScript")
    local grabEvent = scripts and scripts:FindFirstChild("CreatureGrab")
    local releaseEvent = scripts and scripts:FindFirstChild("CreatureRelease")
    local detector = creature:FindFirstChild("LeftDetector")
    local weld = detector and detector:FindFirstChild("LeftWeld")
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")

    if not (grabEvent and releaseEvent and detector and weld and tRoot) then 
        OrionLib:MakeNotification({Name = "Error", Content = "パーツまたはイベント未検出", Time = 3})
        return 
    end

    isGrabbingLoop = true
    TeleportToPlayer(targetName)
    task.wait(0.1)

    task.spawn(function()
        while isGrabbingLoop do
            if not target.Character or not tRoot.Parent then break end
            if IsWhitelisted(target) then break end
            grabEvent:FireServer(detector, tRoot, weld)
            RunService.Heartbeat:Wait()
            releaseEvent:FireServer(weld, tRoot)
            RunService.Heartbeat:Wait()
        end
        isGrabbingLoop = false
    end)
end

local function ExecutePrecisionCombo(targetName)
    local creature = GetMyBlobman()
    if not creature then return end
    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer or IsWhitelisted(targetPlayer) then return end

    local scripts = creature:FindFirstChild("BlobmanSeatAndOwnerScript")
    local grabEvent = scripts and scripts:FindFirstChild("CreatureGrab")
    local releaseEvent = scripts and scripts:FindFirstChild("CreatureRelease")
    local detector = creature:FindFirstChild("LeftDetector")
    local weld = detector and detector:FindFirstChild("LeftWeld")
    local tRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not (grabEvent and releaseEvent and detector and weld and tRoot) then return end

    local originalCFrame = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame or CFrame.new()

    TeleportToPlayer(targetName)
    task.wait(0.18) 
    KillPlayer(targetName)
    
    for i = 1, 4 do
        if IsWhitelisted(targetPlayer) then break end
        grabEvent:FireServer(detector, tRoot, weld)
        RunService.Heartbeat:Wait() 
        releaseEvent:FireServer(weld, tRoot)
        RunService.Heartbeat:Wait()
    end
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot then
        myRoot.CFrame = originalCFrame
    end
end

local function SpawnBlobman()
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local args = {
        [1] = "CreatureBlobman",
        [2] = rootPart.CFrame * CFrame.new(0, 5, -5),
        [3] = Vector3.new(0, 27.4, 0)
    }
    local spawnRemote = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
    if spawnRemote then
        spawnRemote:InvokeServer(unpack(args))
    end
end

-- ============================================
-- Kick All用ユーティリティ
-- ============================================
local blackHoleCount = 0
local detectedBlackHoles = {}
local kickAllActive = false
local selectedPlayerForKick = nil
local placementMode = "circle"
local circleRadius = 25
local innerRadius = 15
local outerRadius = 35
local spiralStart = 10
local spiralEnd = 40
local PLAYER_Y = 100
local SELF_Y = 100

local function GetAllPlayers()
    return GetNonWhitelistedPlayers()
end

local function GetPlayerListForKick()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsWhitelisted(player) then
            table.insert(list, player.Name)
        end
    end
    return list
end

local function GetMyRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function GetMyBlobmanForKick()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "CreatureBlobman" then
            local seat = v:FindFirstChild("VehicleSeat")
            if seat and seat:FindFirstChild("SeatWeld") then
                local p1 = seat.SeatWeld.Part1
                if p1 and p1:IsDescendantOf(LocalPlayer.Character) then return v end
            end
        end
    end
    return nil
end

local function WaitForBlobmanAndRide()
    for i = 1, 30 do
        task.wait(0.1)
        local folder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        if folder then
            local blob = folder:FindFirstChild("CreatureBlobman")
            if blob then
                local seat = blob:FindFirstChild("VehicleSeat")
                if seat then
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        seat:Sit(hum)
                        task.wait(0.2)
                        if hum.SeatPart == seat then
                            return blob
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function SpawnAndRideBlobman()
    local root = GetMyRoot()
    if not root then return nil end
    local spawnPos = root.CFrame * CFrame.new(0, 0, -8)
    local spawnRemote = ReplicatedStorage:FindFirstChild("MenuToys")
    if spawnRemote then
        pcall(function()
            spawnRemote.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 27.4, 0))
        end)
    end
    return WaitForBlobmanAndRide()
end

local function GetCirclePositions(center, radius, count)
    local positions = {}
    if count == 0 then return positions end
    local angleStep = (math.pi * 2) / count
    for i = 1, count do
        local angle = (i - 1) * angleStep
        local x = center.X + radius * math.cos(angle)
        local z = center.Z + radius * math.sin(angle)
        table.insert(positions, {x = x, z = z})
    end
    return positions
end

local function GetDoubleCirclePositions(center, innerR, outerR, count)
    local positions = {}
    if count == 0 then return positions end
    local halfCount = math.floor(count / 2)
    local innerCount = halfCount
    local outerCount = count - halfCount
    local innerAngleStep = (math.pi * 2) / math.max(innerCount, 1)
    for i = 1, innerCount do
        local angle = (i - 1) * innerAngleStep
        local x = center.X + innerR * math.cos(angle)
        local z = center.Z + innerR * math.sin(angle)
        table.insert(positions, {x = x, z = z})
    end
    local outerAngleStep = (math.pi * 2) / math.max(outerCount, 1)
    for i = 1, outerCount do
        local angle = (i - 1) * outerAngleStep + (math.pi / outerCount)
        local x = center.X + outerR * math.cos(angle)
        local z = center.Z + outerR * math.sin(angle)
        table.insert(positions, {x = x, z = z})
    end
    return positions
end

local function GetSpiralPositions(center, startR, endR, count)
    local positions = {}
    if count == 0 then return positions end
    for i = 1, count do
        local t = (i - 1) / (count - 1)
        local radius = startR + (endR - startR) * t
        local angle = (i - 1) * (math.pi * 2 / count) * 3
        local x = center.X + radius * math.cos(angle)
        local z = center.Z + radius * math.sin(angle)
        table.insert(positions, {x = x, z = z})
    end
    return positions
end

local function SetNetworkOwner(part)
    if not part then return end
    pcall(function()
        if ReplicatedStorage and ReplicatedStorage.GrabEvents then
            local root = GetMyRoot()
            if root then
                ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(part, root.CFrame)
            end
        end
    end)
end

local function DoGrab(targetPart)
    if not targetPart then return false end
    local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
    if not grabEvents then return false end
    pcall(function()
        if grabEvents:FindFirstChild("SetNetworkOwner") then
            grabEvents.SetNetworkOwner:FireServer(targetPart, CFrame.new(targetPart.Position))
        end
        if grabEvents:FindFirstChild("DestroyGrabLine") then
            grabEvents.DestroyGrabLine:FireServer(targetPart)
        end
    end)
    return true
end

local function AnchorBlob(blob)
    if not blob then return end
    for _, part in ipairs(blob:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function() part.Anchored = true end)
        end
    end
end

local function UnanchorBlob(blob)
    if not blob then return end
    for _, part in ipairs(blob:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function() part.Anchored = false end)
        end
    end
end

local function GrabRelease(blob, targetPlayer)
    if not blob or not targetPlayer or not targetPlayer.Character or IsWhitelisted(targetPlayer) then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
    if not script then return end
    pcall(function()
        if script:FindFirstChild("CreatureGrab") then
            script.CreatureGrab:FireServer(blob.LeftDetector, targetRoot, blob.LeftDetector.LeftWeld)
        end
        if script:FindFirstChild("CreatureRelease") then
            script.CreatureRelease:FireServer(blob.LeftDetector.LeftWeld)
        end
    end)
end

local function KickBoth(blob, targetPlayer)
    if not blob or not targetPlayer or not targetPlayer.Character or IsWhitelisted(targetPlayer) then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
    if not script or not script:FindFirstChild("CreatureGrab") then return end
    pcall(function()
        script.CreatureGrab:FireServer(blob.LeftDetector, targetRoot, blob.LeftDetector.LeftWeld)
        script.CreatureGrab:FireServer(blob.RightDetector, targetRoot, blob.RightDetector.RightWeld)
    end)
end

local function RapidKick(blob, targetPlayer, count)
    if not blob or not targetPlayer or IsWhitelisted(targetPlayer) then return end
    for i = 1, count do
        if IsWhitelisted(targetPlayer) then break end
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then break end
        local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        if script and script:FindFirstChild("CreatureGrab") then
            pcall(function()
                script.CreatureGrab:FireServer(blob.LeftDetector, targetRoot, blob.LeftDetector.LeftWeld)
                script.CreatureGrab:FireServer(blob.RightDetector, targetRoot, blob.RightDetector.RightWeld)
            end)
        end
        task.wait(0.02)
    end
end

local function TeleportToTarget(targetRoot)
    local myRoot = GetMyRoot()
    if myRoot and targetRoot then
        myRoot.CFrame = targetRoot.CFrame
        task.wait(0.02)
    end
end

local function TeleportPlayersToPositions(players, centerX, centerZ, yOffset, getPositionsFunc, ...)
    local positions = getPositionsFunc({X = centerX, Z = centerZ}, ...)
    for i, target in ipairs(players) do
        if target.Character and positions[i] then
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(positions[i].x, PLAYER_Y + yOffset, positions[i].z)
            end
        end
    end
end

-- Destroy Server 用
local selectedHeight = "Spawn"
local lineLagThread = nil
local lineLagEnabled = false

local function getAllPlayersDestroy()
    return GetNonWhitelistedPlayers()
end

local GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")

local function spamOwnership(hrp)
    if not GrabEvents then return end
    local setOwner = GrabEvents:FindFirstChild("SetNetworkOwner")
    if setOwner and hrp then
        pcall(function() setOwner:FireServer(hrp, hrp.CFrame) end)
    end
end

local function teleportToPlayer(myHrp, targetHrp)
    if not myHrp or not targetHrp then return end
    pcall(function()
        myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 5, 5)
        myHrp.AssemblyLinearVelocity = Vector3.zero
    end)
end

local function destroyLineOnPlayer(hrp)
    if not GrabEvents then return end
    local createLine = GrabEvents:FindFirstChild("CreateGrabLine")
    local destroyLine = GrabEvents:FindFirstChild("DestroyGrabLine")
    if not createLine or not destroyLine then return end
    pcall(function()
        createLine:FireServer(hrp, CFrame.new(0, 1e9, 0))
        task.wait()
        destroyLine:FireServer(hrp)
    end)
end

local function startLineLag()
    if lineLagEnabled then return end
    lineLagEnabled = true
    lineLagThread = coroutine.create(function()
        if not GrabEvents then return end
        local createLine = GrabEvents:FindFirstChild("CreateGrabLine")
        if not createLine then return end
        while lineLagEnabled do
            local spawnLocation = Workspace:FindFirstChild("SpawnLocation") 
                or Workspace:FindFirstChild("Spawn") 
                or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
            if spawnLocation then
                local randomX = math.random(-9e9, 9e9)
                local randomZ = math.random(-9e9, 9e9)
                local directions = {
                    CFrame.new(randomX, 0, randomZ),
                    CFrame.new(-randomX, 0, -randomZ),
                    CFrame.new(randomX, 0, -randomZ),
                    CFrame.new(-randomX, 0, randomZ),
                }
                for _, pos in pairs(directions) do
                    createLine:FireServer(spawnLocation, pos)
                end
            end
            task.wait()
        end
    end)
    coroutine.resume(lineLagThread)
end

local function stopLineLag()
    if not lineLagEnabled then return end
    lineLagEnabled = false
    if lineLagThread then
        coroutine.close(lineLagThread)
        lineLagThread = nil
    end
end

-- BlackHole監視
local function StartBlackHoleMonitor()
    local function OnBlackHoleSpawn(obj)
        if obj.Name == "BlackHoleKick" and not detectedBlackHoles[obj] then
            blackHoleCount = blackHoleCount + 1
            detectedBlackHoles[obj] = true
            OrionLib:MakeNotification({Name = "BlackHoleKick 検知", Content = "第" .. blackHoleCount .. "番目が出現", Time = 5})
        end
    end
    for _, obj in pairs(workspace:GetChildren()) do
        OnBlackHoleSpawn(obj)
    end
    workspace.ChildAdded:Connect(OnBlackHoleSpawn)
end

StartBlackHoleMonitor()

-- ============================================
-- Defence タブ用変数
-- ============================================
local StruggleEnabled = false
local AntiExplosionEnabled = false
local antiExplosionConn = nil

local function setupAntiExplosion(character)
    if not AntiExplosionEnabled then return end
    local hum = character:WaitForChild("Humanoid", 5)
    local partOwner = hum and hum:FindFirstChild("Ragdolled")
    if partOwner then
        if antiExplosionConn then antiExplosionConn:Disconnect() end
        antiExplosionConn = partOwner:GetPropertyChangedSignal("Value"):Connect(function()
            if not AntiExplosionEnabled then return end
            if partOwner.Value then
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.Anchored = true end
                end
            else
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.Anchored = false end
                end
            end
        end)
    end
end

-- ============================================
-- Player タブ用変数
-- ============================================
local speedEnabled = false
local originalWalkSpeed = 16
local originalJumpPower = 50
local infiniteJumpEnabled = false
local flyEnabled = false
local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil
local AntiAim = false

local function SetWalkSpeed(speed)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speed end
end

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    hum.PlatformStand = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 1e6
    bodyVelocity.Parent = root
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 1e8
    bodyGyro.P = 20000
    bodyGyro.D = 1000
    bodyGyro.Parent = root
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not root.Parent then return end
        local cameraCF = Camera.CFrame
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cameraCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cameraCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cameraCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cameraCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        bodyVelocity.Velocity = moveDir * flySpeed
        bodyGyro.CFrame = cameraCF
    end)
end

local function stopFly()
    flyEnabled = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

-- ============================================
-- UI構築 (OrionLib) - メインウィンドウ
-- ============================================
local Window = OrionLib:MakeWindow({
    Name = "lemon hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "lemon_hub_config"
})

-- [プレイヤー]
local PlayerTab = Window:MakeTab({ Name = "プレイヤー", Icon = "rbxassetid://4483327233" })
PlayerTab:AddSection({ Name = "Movement Settings" })
PlayerTab:AddToggle({ Name = "フライ", Default = false, Callback = function(v) flyEnabled = v; if v then startFly() else stopFly() end end })
PlayerTab:AddSlider({ Name = "フライ速度", Min = 10, Max = 200, Default = 50, Callback = function(v) flySpeed = v end })
PlayerTab:AddToggle({ Name = "CFrameスピード", Default = false, Callback = function(v) State.CFrameSpeed = v end })
PlayerTab:AddSlider({ Name = "速度倍率", Min = 1, Max = 10, Default = 2, Callback = function(v) State.SpeedMultiplier = v end })
PlayerTab:AddSection({ Name = "Jump Settings" })
PlayerTab:AddToggle({ Name = "無限ジャンプ", Default = false, Callback = function(v) infiniteJumpEnabled = v end })
PlayerTab:AddSlider({ Name = "ジャンプ力", Min = 50, Max = 300, Default = 50, Callback = function(v) originalJumpPower = v; local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower = v end end })
PlayerTab:AddToggle({ Name = "アンチエイム (Spin)", Default = false, Callback = function(v) AntiAim = v end })
PlayerTab:AddButton({ Name = "リセット", Callback = function()
    flyEnabled = false; stopFly(); State.CFrameSpeed = false; infiniteJumpEnabled = false; AntiAim = false
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
    OrionLib:MakeNotification({Name = "リセット", Content = "速度16 / ジャンプ50 に戻しました", Time = 2})
end })

-- [ESP]
local ESPTab = Window:MakeTab({ Name = "ESP", Icon = "rbxassetid://4483345998" })
ESPTab:AddToggle({ Name = "プレイヤーESP", Default = false, Callback = function(v) State.ESPEnabled = v end })
ESPTab:AddToggle({ Name = "X-ray (壁透視)", Default = false, Callback = function(v) State.XrayEnabled = v end })

-- [掴む]
local GrabTab = Window:MakeTab({ Name = "掴む", Icon = "rbxassetid://73570431850302" })
GrabTab:AddSection({ Name = "Grab Controls" })
GrabTab:AddToggle({ Name = "投げる有効化", Default = false, Callback = function(v) nageruEnabled = v end })
GrabTab:AddSlider({ Name = "投げる強さ", Min = 300, Max = 4000, Default = 400, Callback = function(v) nageru = v end })
GrabTab:AddSection({ Name = "Grab Modes" })
GrabTab:AddToggle({ Name = "キル掴む", Default = false, Callback = function(v) GrabMode.Kill = v end })
GrabTab:AddToggle({ Name = "Kick Grab", Default = false, Callback = function(v) GrabMode.Kick = v end })
GrabTab:AddToggle({ Name = "Void Grab", Default = false, Callback = function(v) GrabMode.Void = v end })
GrabTab:AddToggle({ Name = "上に上がる掴む", Default = false, Callback = function(v) GrabMode.Sky = v end })
GrabTab:AddToggle({ Name = "下に下がる掴む", Default = false, Callback = function(v) GrabMode.Down = v end })
GrabTab:AddToggle({ Name = "ノクリップ掴む", Default = false, Callback = function(v) GrabMode.Noclip = v end })
GrabTab:AddToggle({ Name = "Anchor Grab", Default = false, Callback = function(v) GrabMode.Anchor = v end })
GrabTab:AddToggle({ Name = "💀 グラブキル（掴んだ相手を即死）", Default = false, Callback = function(v)
    grabKillActive = v
    if v then
        grabKillThread = coroutine.create(function()
            while grabKillActive do
                local grabParts = workspace:FindFirstChild("GrabParts")
                if grabParts then
                    local grabPart = grabParts:FindFirstChild("GrabPart")
                    local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
                    local part = weld and weld.Part1
                    if part then
                        local char = part.Parent
                        while char and not char:FindFirstChild("Humanoid") do char = char.Parent end
                        if char then
                            local hum = char:FindFirstChild("Humanoid")
                            local plr = Players:GetPlayerFromCharacter(char)
                            if hum and hum.Health > 0 and not IsWhitelisted(plr) then
                                hum.BreakJointsOnDeath = false; hum.Health = 0
                                hum:ChangeState(Enum.HumanoidStateType.Dead)
                                local root = char:FindFirstChild("HumanoidRootPart")
                                if root then root.Velocity = Vector3.zero end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
        coroutine.resume(grabKillThread)
    end
end })

-- [ キル ]
local KillTab = Window:MakeTab({ Name = "キル", Icon = "rbxassetid://7733911020" })
KillTab:AddSection({ Name = "Mass Elimination OS v7.0" })
KillTab:AddToggle({ Name = "QUANTUM KILL OVERDRIVE", Default = false, Callback = function(v) State.MassKillActive = v; if v then task.spawn(ExecuteQuantumKill) end end })
KillTab:AddButton({ Name = "Emergency Stop", Callback = function() State.MassKillActive = false end })

-- [アンチ]
local AntiTab = Window:MakeTab({ Name = "アンチ", Icon = "rbxassetid://7734068321" })
AntiTab:AddToggle({ Name = "アンチ掴み有効化", Default = false, Callback = function(v) State.AntiGrabEnabled = v end })
AntiTab:AddSection({ Name = "Auto Defense System" })
AntiTab:AddToggle({ Name = "Anti Grab / Struggle / Ragdoll", Default = false, Callback = function(v)
    StruggleEnabled = v
    if v then
        task.spawn(function()
            while StruggleEnabled do
                local event = ReplicatedStorage:FindFirstChild("CharacterEvents")
                if event and event:FindFirstChild("Struggle") then event.Struggle:FireServer() end
                task.wait(0.03)
            end
        end)
    end
end })
AntiTab:AddToggle({ Name = "Anti Explosion", Default = false, Callback = function(v)
    AntiExplosionEnabled = v
    if v then
        if LocalPlayer.Character then setupAntiExplosion(LocalPlayer.Character) end
        local respawnConn = LocalPlayer.CharacterAdded:Connect(setupAntiExplosion)
        task.spawn(function()
            repeat task.wait() until not AntiExplosionEnabled
            respawnConn:Disconnect()
            if antiExplosionConn then antiExplosionConn:Disconnect() end
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.Anchored = false end
                end
            end
        end)
    else
        if antiExplosionConn then antiExplosionConn:Disconnect() end
    end
end })

-- [Blobman]
local BlobTab = Window:MakeTab({ Name = "Blobman", Icon = "rbxassetid://4483345998" })
BlobTab:AddSection({ Name = "ターゲット設定" })
local BlobDropdown = BlobTab:AddDropdown({ Name = "Select Victim", Default = "", Options = GetPlayerList(), Callback = function(Value) if Value and Value ~= "" then selectedPlayer = Value:match("%@(.*)%)") end end })
BlobTab:AddButton({ Name = "リセットプレイヤーリスト", Callback = function() BlobDropdown:Refresh(GetPlayerList(), true) end })
BlobTab:AddSection({ Name = "Execution Commands" })
BlobTab:AddButton({ Name = "テレポート", Callback = function() if selectedPlayer then TeleportToPlayer(selectedPlayer) end end })
BlobTab:AddButton({ Name = "高速掴みループ開始", Callback = function() if selectedPlayer then ExecuteFastGrabLoop(selectedPlayer) end end })
BlobTab:AddButton({ Name = "掴みループ停止", Callback = function() isGrabbingLoop = false end })
BlobTab:AddSection({ Name = "早いkill" })
BlobTab:AddButton({ Name = "kill", Callback = function() if selectedPlayer then ExecutePrecisionCombo(selectedPlayer) end end })
BlobTab:AddSection({ Name = "Spawner" })
BlobTab:AddButton({ Name = "Blobmanを召喚", Callback = function() SpawnBlobman(); OrionLib:MakeNotification({Name = "Blobman", Content = "召喚成功！乗ってくれ！", Time = 3}) end })
BlobTab:AddSection({ Name = "all kill roop" })
BlobTab:AddToggle({ Name = "オールキルループ", Default = false, Callback = function(Value)
    isGlobalAntiVisualLoop = Value
    if Value then
        task.spawn(function()
            while isGlobalAntiVisualLoop do
                local creature = GetMyBlobman()
                if not creature then isGlobalAntiVisualLoop = false; break end
                local scripts = creature:FindFirstChild("BlobmanSeatAndOwnerScript")
                local grab = scripts and scripts:FindFirstChild("CreatureGrab")
                local release = scripts and scripts:FindFirstChild("CreatureRelease")
                local det = creature:FindFirstChild("LeftDetector")
                local weld = det and det:FindFirstChild("LeftWeld")
                if grab and release and det and weld then
                    local targets = GetNonWhitelistedPlayers()
                    for _, p in ipairs(targets) do
                        if not isGlobalAntiVisualLoop then break end
                        local char = p.Character
                        local tRoot = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if tRoot and hum and hum.Health > 0 then
                            hum.BreakJointsOnDeath = false
                            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if myRoot then myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3) end
                            task.wait(0.05)
                            for i = 1, 100 do
                                if not p.Character then break end
                                grab:FireServer(det, tRoot, weld)
                                release:FireServer(weld, tRoot)
                                if i % 25 == 0 then task.wait() end
                            end
                            if p.Character then
                                hum.Health = 0; hum:ChangeState(Enum.HumanoidStateType.Dead)
                                release:FireServer(weld, tRoot)
                                task.delay(3, function()
                                    if char and char.Parent then
                                        for _, part in pairs(char:GetDescendants()) do
                                            if part:IsA("BasePart") then part:Destroy() end
                                        end
                                    end
                                end)
                            end
                            task.wait(0.15)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end })

-- [Omni / Kick All]
local OmniTab = Window:MakeTab({ Name = "Omni / Kick All", Icon = "rbxassetid://4483345998" })
OmniTab:AddSection({ Name = "BlackHole検知" })
OmniTab:AddButton({ Name = "BlackHoleカウントリセット", Callback = function() blackHoleCount = 0; detectedBlackHoles = {}; OrionLib:MakeNotification({Name = "リセット", Content = "BlackHoleカウンタをリセット", Time = 2}) end })
OmniTab:AddSection({ Name = "配置モード選択" })
OmniTab:AddDropdown({ Name = "プレイヤー配置形状", Default = "円形 (シングル)", Options = {"円形 (シングル)", "二重円", "渦巻き状"}, Callback = function(Value)
    if Value == "円形 (シングル)" then placementMode = "circle"
    elseif Value == "二重円" then placementMode = "double"
    elseif Value == "渦巻き状" then placementMode = "spiral" end
end })
OmniTab:AddSection({ Name = "ターゲット指定" })
local PlayerDropdown = OmniTab:AddDropdown({ Name = "ターゲット選択", Default = "", Options = GetPlayerListForKick(), Callback = function(Value) selectedPlayerForKick = Players:FindFirstChild(Value) end })
OmniTab:AddButton({ Name = "プレイヤーリスト更新", Callback = function() PlayerDropdown:Refresh(GetPlayerListForKick(), true) end })
OmniTab:AddButton({ Name = "単体キック", Callback = function()
    local blob = GetMyBlobmanForKick()
    if not blob then OrionLib:MakeNotification({Name = "Error", Content = "先にKICK ALLを実行してください", Time = 3}); return end
    if not selectedPlayerForKick then OrionLib:MakeNotification({Name = "Error", Content = "先にターゲットを選択してください", Time = 2}); return end
    if IsWhitelisted(selectedPlayerForKick) then OrionLib:MakeNotification({Name = "Error", Content = "ホワイトリスト対象です", Time = 2}); return end
    local targetRoot = selectedPlayerForKick.Character and selectedPlayerForKick.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then OrionLib:MakeNotification({Name = "Error", Content = "ターゲットが見つかりません", Time = 2}); return end
    TeleportToTarget(targetRoot); SetNetworkOwner(targetRoot)
    for i = 1, 3 do GrabRelease(blob, selectedPlayerForKick); if i < 3 then task.wait(0.08) end end
end })
OmniTab:AddButton({ Name = "連打 (100回)", Callback = function()
    if not selectedPlayerForKick then OrionLib:MakeNotification({Name = "Error", Content = "先にターゲットを選択してください", Time = 2}); return end
    if IsWhitelisted(selectedPlayerForKick) then OrionLib:MakeNotification({Name = "Error", Content = "ホワイトリスト対象です", Time = 2}); return end
    local blob = GetMyBlobmanForKick()
    if not blob then OrionLib:MakeNotification({Name = "Error", Content = "先にKICK ALLを実行してください", Time = 3}); return end
    task.spawn(function() RapidKick(blob, selectedPlayerForKick, 100); OrionLib:MakeNotification({Name = "連打完了", Content = "100回実行しました", Time = 2}) end)
end })
OmniTab:AddButton({ Name = "KICK ALL", Callback = function()
    local allPlayers = GetAllPlayers()
    if #allPlayers == 0 then OrionLib:MakeNotification({Name = "エラー", Content = "他のプレイヤーがいません", Time = 2}); return end
    kickAllActive = true
    local blob = SpawnAndRideBlobman()
    if not blob then OrionLib:MakeNotification({Name = "エラー", Content = "Blobmanに乗れませんでした", Time = 3}); kickAllActive = false; return end
    task.wait(0.3)
    local myRoot = GetMyRoot()
    if not myRoot then kickAllActive = false; return end
    for _, target in ipairs(allPlayers) do
        local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            TeleportToTarget(targetRoot); SetNetworkOwner(targetRoot)
            for j = 1, 3 do GrabRelease(blob, target); if j < 3 then task.wait(0.08) end end
        end
    end
    myRoot.CFrame = CFrame.new(0, SELF_Y, 0); task.wait(0.1); AnchorBlob(blob); task.wait(0.1)
    local centerX, centerZ = 0, 0
    if placementMode == "circle" then TeleportPlayersToPositions(allPlayers, centerX, centerZ, 0, GetCirclePositions, circleRadius, #allPlayers)
    elseif placementMode == "double" then TeleportPlayersToPositions(allPlayers, centerX, centerZ, 0, GetDoubleCirclePositions, innerRadius, outerRadius, #allPlayers)
    elseif placementMode == "spiral" then TeleportPlayersToPositions(allPlayers, centerX, centerZ, 0, GetSpiralPositions, spiralStart, spiralEnd, #allPlayers) end
    task.wait(0.1)
    for _, target in ipairs(allPlayers) do local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart"); if targetRoot then DoGrab(targetRoot) end end
    task.wait(0.1)
    for _, target in ipairs(allPlayers) do local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart"); if targetRoot then DoGrab(targetRoot) end end
    task.wait(0.3)
    for i = 1, 3 do for _, target in ipairs(allPlayers) do KickBoth(blob, target) end; if i < 3 then task.wait(0.08) end end
    task.wait(0.1); UnanchorBlob(blob)
    OrionLib:MakeNotification({Name = "Kick All 完了", Content = #allPlayers .. "人をキック", Time = 4})
    kickAllActive = false
end })

OmniTab:AddSection({ Name = "Destroy Server" })
OmniTab:AddDropdown({ Name = "破壊の高さモード", Default = "Spawn (地上)", Options = {"Spawn (地上)", "Heaven (天国)"}, Callback = function(Value) selectedHeight = (Value == "Heaven (天国)") and "Heaven" or "Spawn" end })
OmniTab:AddButton({ Name = "Destroy Server", Callback = function()
    task.spawn(function()
        local height = (selectedHeight == "Heaven") and 1e9 or 35
        startLineLag(); task.wait(1)
        local players = getAllPlayersDestroy()
        if #players == 0 then stopLineLag(); return end
        local myChar = LocalPlayer.Character; local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then stopLineLag(); return end
        local playerData = {}
        for _, plr in ipairs(players) do
            local char = plr.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then table.insert(playerData, {player = plr, hrp = hrp}) end
        end
        for _, data in ipairs(playerData) do teleportToPlayer(myHrp, data.hrp); task.wait(0.2); spamOwnership(data.hrp); task.wait() end
        local radius = 40; local angleStep = (math.pi * 2) / #playerData
        for idx, data in ipairs(playerData) do
            local angle = (idx - 1) * angleStep; local x = math.cos(angle) * radius; local z = math.sin(angle) * radius
            pcall(function() data.hrp.CFrame = CFrame.new(x, height, z); data.hrp.AssemblyLinearVelocity = Vector3.zero end)
            local bp = Instance.new("BodyPosition"); bp.MaxForce = Vector3.new(9e9, 9e9, 9e9); bp.P = 50000000000; bp.Position = Vector3.new(x, height, z); bp.Parent = data.hrp
            task.delay(2, function() pcall(function() bp:Destroy() end) end); task.wait()
        end
        for i = 1, 8 do for _, data in ipairs(playerData) do destroyLineOnPlayer(data.hrp) end; task.wait(0.3) end
        task.wait(6); stopLineLag()
    end)
end })

-- [Whitelist]
local WhitelistTab = Window:MakeTab({ Name = "Whitelist", Icon = "rbxassetid://4483345998" })
WhitelistTab:AddSection({ Name = "Whitelist Settings" })
WhitelistLabel = WhitelistTab:AddParagraph("保護リスト", "現在ホワイトリストは空です")

local WhitelistDropdown = WhitelistTab:AddDropdown({ 
    Name = "Select Player to Add/Remove", 
    Default = "", 
    Options = GetPlayerListForWhitelist(), 
    Callback = function(Value) 
        if Value and Value ~= "" then 
            local name = Value:match("%@(.*)%)")
            if name then
                if Whitelist[name] then
                    Whitelist[name] = nil
                    OrionLib:MakeNotification({Name = "Whitelist", Content = name .. " をホワイトリストから削除しました", Time = 2})
                else
                    Whitelist[name] = true
                    OrionLib:MakeNotification({Name = "Whitelist", Content = name .. " をホワイトリストに追加しました", Time = 2})
                end
                UpdateWhitelistUI()
                WhitelistDropdown:Refresh(GetPlayerListForWhitelist(), true)
            end
        end 
    end 
})

WhitelistTab:AddButton({ Name = "Clear All Whitelist", Callback = function() 
    Whitelist = {} 
    UpdateWhitelistUI()
    WhitelistDropdown:Refresh(GetPlayerListForWhitelist(), true)
    OrionLib:MakeNotification({Name = "Whitelist", Content = "ホワイトリストをすべて解除しました", Time = 2})
end })

WhitelistTab:AddButton({ Name = "Refresh Player List", Callback = function() 
    WhitelistDropdown:Refresh(GetPlayerListForWhitelist(), true) 
end })

-- [Cosmos Control]
local CosmosTab = Window:MakeTab({ Name = "Cosmos Control", Icon = "rbxassetid://4483345998" })
CosmosTab:AddSection({ Name = "Sparkler Control" })
CosmosTab:AddButton({ Name = "Sparkler同期 (FireworkSparkler)", Callback = function() for _, o in pairs(Workspace:GetDescendants()) do if o.Name:find("FireworkSparkler") then SetupPhysics(o, activeSparklers) end end end })
CosmosTab:AddSlider({ Name = "半径 / 広さ", Min = 2, Max = 300, Default = sparklerConfig.Radius, Callback = function(v) sparklerConfig.Radius = v end })
CosmosTab:AddSlider({ Name = "高さ (Height)", Min = -50, Max = 100, Default = sparklerConfig.Height, Callback = function(v) sparklerConfig.Height = v end })
CosmosTab:AddSlider({ Name = "回転速さ (Speed)", Min = 0, Max = 100, Default = sparklerConfig.Speed, Callback = function(v) sparklerConfig.Speed = v end })
CosmosTab:AddSlider({ Name = "羽の強さ (Wing Only)", Min = 0, Max = 20, Default = 2.5, Callback = function(v) sparklerConfig.FlapStrength = v end })
CosmosTab:AddSection({ Name = "Shape Selection" })
local shapes = {"Wing", "VerticalHeart", "DNA", "Circle", "Lotus", "Planet"}
for _, s in pairs(shapes) do
    CosmosTab:AddButton({ Name = "形状: "..s, Callback = function() sparklerConfig.CurrentShape = s end })
end

-- [Main / Chat / Cat]
local MainTab = Window:MakeTab({ Name = "Main / Chat / Cat", Icon = "rbxassetid://4483345998" })
MainTab:AddSection({ Name = "Main Controls" })
MainTab:AddTextbox({ Name = "Spam Chat", Default = "", TextDisappear = true, Callback = function(v) if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral"); if channel then channel:SendAsync(v) end end end })
MainTab:AddToggle({ Name = "Bongo Cat表示", Default = false, Callback = function(v) CatFrame.Visible = v end })
MainTab:AddButton({ Name = "カメラ制限解除", Callback = function() LocalPlayer.CameraMaxZoomDistance = 10000 end })

-- [Minimap TP]
local MinimapTab = Window:MakeTab({ Name = "Minimap TP", Icon = "rbxassetid://4483345998" })
MinimapTab:AddSection({ Name = "Minimap Settings" })
MinimapTab:AddToggle({ Name = "ミニマップ表示", Default = false, Callback = function(v) MapFrame.Visible = v end })
MinimapTab:AddSlider({ Name = "ズームレベル", Min = 50, Max = 1000, Default = 500, Callback = function(v) zoomLevel = v end })
MinimapTab:AddParagraph("Info", "マップ上をクリックで埋まり防止TP、ドラッグでUI移動。")

-- [Television Mirror]
local TVTab = Window:MakeTab({ Name = "Television Mirror", Icon = "rbxassetid://4483345998" })
TVTab:AddSection({ Name = "Television Control" })
TVTab:AddToggle({ Name = "Television 追従", Default = false, Callback = function(v) tv_Enabled = v end })
TVTab:AddButton({ Name = "Television 同期 (ゴースト化)", Callback = function() for _, o in pairs(Workspace:GetDescendants()) do if o.Name == "Television" or o:FindFirstChild("Screen") then SetupTVMirror(o) end end end })
TVTab:AddSection({ Name = "TV Config" })
TVTab:AddSlider({ Name = "半径 / Radius", Min = 2, Max = 300, Default = tvConfig.Radius, Callback = function(v) tvConfig.Radius = v end })
TVTab:AddSlider({ Name = "高さ / Height", Min = -50, Max = 100, Default = tvConfig.Height, Callback = function(v) tvConfig.Height = v end })
TVTab:AddSlider({ Name = "回転速度 / Speed", Min = 0, Max = 100, Default = tvConfig.Speed, Callback = function(v) tvConfig.Speed = v end })
TVTab:AddSlider({ Name = "羽の強さ (Wing)", Min = 0, Max = 20, Default = tvConfig.FlapStrength or 2.5, Callback = function(v) tvConfig.FlapStrength = v end })
local tv_Shapes = {"Wing", "VerticalHeart", "DNA", "Circle", "Lotus", "Planet"}
for _, s in pairs(tv_Shapes) do
    TVTab:AddButton({ Name = "形状: "..s, Callback = function() tvConfig.CurrentShape = s end })
end

-- ============================================
-- [Orbit & Grab Hub] - 追加機能（drift kick）
-- ============================================
local OrbitTab = Window:MakeTab({ Name = "Orbit & Grab", Icon = "rbxassetid://4483345998" })

local orbitRunning = false
local selectedActionTargetName = ""
local orbitRadius = 19
local orbitSpeed = 8.5
local orbitHeightOffset = 0
local orbitAngle = 0
local orbitCurrentLoopId = 0
local orbitPlayerMap = {}

local function getOrbitPlayerNames()
    local names = {}
    orbitPlayerMap = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local displayStr = player.DisplayName .. " (@" .. player.Name .. ")"
            table.insert(names, displayStr)
            orbitPlayerMap[displayStr] = player.Name
        end
    end
    return names
end

local OrbitTargetDropdown = OrbitTab:AddDropdown({
    Name = "ターゲットを選択", Default = "", Options = getOrbitPlayerNames(),
    Callback = function(Value)
        selectedActionTargetName = orbitPlayerMap[Value] or ""
    end    
})

OrbitTab:AddButton({
    Name = "プレイヤーリストを更新",
    Callback = function() OrbitTargetDropdown:Refresh(getOrbitPlayerNames(), true) end    
})

OrbitTab:AddToggle({
    Name = "drift kick",
    Default = false,
    Callback = function(v)
        orbitRunning = v
        orbitCurrentLoopId = orbitCurrentLoopId + 1
        local myLoopId = orbitCurrentLoopId

        if not v then return end

        local target = Players:FindFirstChild(selectedActionTargetName)
        
        if target and target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local blobman = nil
            local spawned = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
            
            if not blobman then
                local mt = ReplicatedStorage:FindFirstChild("MenuToys")
                local st = mt and mt:FindFirstChild("SpawnToyRemoteFunction")
                if st then
                    local myRoot = LocalPlayer.Character.HumanoidRootPart
                    local spawnCF = myRoot and (myRoot.CFrame + Vector3.new(0, 5, 0)) or CFrame.new(0, 50, 0)
                    st:InvokeServer("CreatureBlobman", spawnCF, Vector3.zero)
                    task.wait(0.8)
                    spawned = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                    if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
                end
            end

            if not blobman then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj.Name == "CreatureBlobman" and obj:FindFirstChild("VehicleSeat") then
                        blobman = obj
                        break
                    end
                end
            end
            
            if blobman then
                local scriptObj = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
                local grabRemote = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
                local dropRemote = scriptObj and scriptObj:FindFirstChild("CreatureDrop")

                local lDet = blobman:FindFirstChild("LeftDetector")
                local rDet = blobman:FindFirstChild("RightDetector")
                local lWeld = lDet and (lDet:FindFirstChild("LeftWeld") or lDet:FindFirstChild("RigidConstraint"))
                local rWeld = rDet and (rDet:FindFirstChild("RightWeld") or rDet:FindFirstChild("RigidConstraint"))
                
                local seat = blobman:FindFirstChild("VehicleSeat")
                local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                
                if seat and hum then
                    if seat.Occupant ~= hum then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.2)
                        seat:Sit(hum)
                        task.wait(0.5)
                    end
                end
                
                local GE = ReplicatedStorage:FindFirstChild("GrabEvents")
                
                if GE and grabRemote and dropRemote and ((lDet and lWeld) or (rDet and rWeld)) then
                    OrionLib:MakeNotification({ Name = "実行", Content = "drift kick を開始します", Time = 3 })

                    task.spawn(function()
                        local blobRoot = blobman:FindFirstChild("HumanoidRootPart") or blobman.PrimaryPart
                        local Det = rDet or lDet
                        local Weld = rWeld or lWeld
                        
                        local bringStart = tick()
                        while tick() - bringStart < 0.35 do
                            if myLoopId ~= orbitCurrentLoopId or not orbitRunning or not blobman or not blobman.Parent then return end
                            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                local tRoot = target.Character.HumanoidRootPart
                                blobRoot.CFrame = tRoot.CFrame
                                blobRoot.AssemblyLinearVelocity = Vector3.zero
                                
                                pcall(function()
                                    if Det then grabRemote:FireServer(Det, tRoot, Weld) end
                                    GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                                    GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                                end)
                            end
                            RunService.Heartbeat:Wait()
                        end
                        
                        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
                        
                        local SavedPos = target.Character.HumanoidRootPart.CFrame
                        local targetCenterCFrame = SavedPos + Vector3.new(0, 30, 0)
                        
                        local lastTime = tick()
                        local lastDropTime = tick()
                        local dropCount = 0
                        
                        while orbitRunning and blobman and blobman.Parent do
                            if myLoopId ~= orbitCurrentLoopId then break end
                            if not target or not target.Parent or not target.Character then break end
                            
                            local tChar = target.Character
                            local tRoot = tChar:FindFirstChild("HumanoidRootPart")
                            local tHum = tChar:FindFirstChild("Humanoid")
                            
                            if dropCount < 2 and (tick() - lastDropTime) > 0.8 then
                                dropCount = dropCount + 1
                                
                                pcall(function()
                                    local currentWeld = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChild("RigidConstraint")
                                    if currentWeld then
                                        dropRemote:FireServer(currentWeld)
                                    end
                                    GE.DestroyGrabLine:FireServer(tRoot)
                                end)
                                
                                blobRoot.CFrame = SavedPos
                                blobRoot.AssemblyLinearVelocity = Vector3.zero
                                
                                task.wait(0.1)
                                
                                local reCaptureStart = tick()
                                while tick() - reCaptureStart < 0.35 do
                                    if myLoopId ~= orbitCurrentLoopId or not orbitRunning or not blobman or not blobman.Parent then break end
                                    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                        local currentTRoot = target.Character.HumanoidRootPart
                                        blobRoot.CFrame = currentTRoot.CFrame
                                        blobRoot.AssemblyLinearVelocity = Vector3.zero
                                        
                                        pcall(function()
                                            if Det then grabRemote:FireServer(Det, currentTRoot, Weld) end
                                            GE.CreateGrabLine:FireServer(currentTRoot, Vector3.zero, currentTRoot.Position, false)
                                            GE.SetNetworkOwner:FireServer(currentTRoot, blobRoot.CFrame)
                                        end)
                                    end
                                    RunService.Heartbeat:Wait()
                                end
                                
                                lastTime = tick()
                                lastDropTime = tick()
                            end

                            if tRoot and tHum and tHum.Health > 0 and blobRoot then
                                local currentTime = tick()
                                local dt = currentTime - lastTime
                                lastTime = currentTime

                                orbitAngle = orbitAngle + (orbitSpeed * dt)
                                local offsetX = math.cos(orbitAngle) * orbitRadius
                                local offsetZ = math.sin(orbitAngle) * orbitRadius
                                
                                local blobPos = targetCenterCFrame.Position + Vector3.new(offsetX, orbitHeightOffset, offsetZ)
                                blobRoot.CFrame = CFrame.new(blobPos, targetCenterCFrame.Position)
                                blobRoot.AssemblyLinearVelocity = Vector3.zero
                                blobRoot.AssemblyAngularVelocity = Vector3.zero
                                
                                tRoot.CFrame = targetCenterCFrame
                                tRoot.AssemblyLinearVelocity = Vector3.zero
                                tRoot.AssemblyAngularVelocity = Vector3.zero

                                pcall(function()
                                    tHum.PlatformStand = true
                                    tHum.Sit = true
                                    GE.SetNetworkOwner:FireServer(tRoot, targetCenterCFrame)
                                    
                                    local currentWeld = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChild("RigidConstraint")
                                    if currentWeld then
                                        dropRemote:FireServer(currentWeld)
                                    end
                                    
                                    GE.DestroyGrabLine:FireServer(tRoot)
                                    if Det then grabRemote:FireServer(Det, tRoot, Weld) end
                                    GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, targetCenterCFrame.Position, false)
                                end)
                            else
                                break
                            end
                            RunService.Heartbeat:Wait()
                        end
                        
                        if blobRoot and SavedPos then
                            pcall(function()
                                local currentWeld = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChild("RigidConstraint")
                                if currentWeld then dropRemote:FireServer(currentWeld) end
                                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                    GE.DestroyGrabLine:FireServer(target.Character.HumanoidRootPart)
                                end
                            end)
                            blobRoot.CFrame = SavedPos
                            blobRoot.AssemblyLinearVelocity = Vector3.zero
                        end

                    end)
                else
                    OrionLib:MakeNotification({ Name = "エラー", Content = "必要なRemoteEventやDetectorが見つかりません", Time = 5 })
                    orbitRunning = false
                end
            else
                OrionLib:MakeNotification({ Name = "エラー", Content = "Blobmanの取得・生成に失敗しました", Time = 3 })
                orbitRunning = false
            end
        else
            OrionLib:MakeNotification({ Name = "エラー", Content = "ターゲットが無効です", Time = 3 })
            orbitRunning = false
        end
    end
})

-- [その他]
local MiscTab = Window:MakeTab({ Name = "その他", Icon = "rbxassetid://4483345998" })
MiscTab:AddButton({ Name = "UIを閉じる", Callback = function() OrionLib:Destroy() end })

-- ミニマップドラッグ機能
MapFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local dragging = true
        local dragStart = input.Position
        local startPos = MapFrame.Position
        local moveCon, endCon
        moveCon = UserInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = inp.Position - dragStart
                MapFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        endCon = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false; moveCon:Disconnect(); endCon:Disconnect()
                if (inp.Position - dragStart).Magnitude < 5 and LocalPlayer.Character then
                    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local relX = (inp.Position.X - MapFrame.AbsolutePosition.X) / MapFrame.AbsoluteSize.X - 0.5
                        local relY = (inp.Position.Y - MapFrame.AbsolutePosition.Y) / MapFrame.AbsoluteSize.Y - 0.5
                        local targetX = root.Position.X + (relX * zoomLevel)
                        local targetZ = root.Position.Z + (relY * zoomLevel)
                        local rayRes = Workspace:Raycast(Vector3.new(targetX, 1000, targetZ), Vector3.new(0, -2000, 0), mapRp)
                        local finalY = rayRes and rayRes.Position.Y or root.Position.Y
                        root.CFrame = CFrame.new(targetX, finalY + 4, targetZ)
                    end
                end
            end
        end)
    end
end)

-- ============================================
-- メインループ (RenderStepped)
-- ============================================
local espUpdateCounter = 0
local sparklerUpdateCounter = 0

RunService.RenderStepped:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    local prediction = hrp and hrp.AssemblyLinearVelocity * globalConfig.Responsiveness or Vector3.zero

    if flyEnabled and hrp and hum then
        local moveDir = hum.MoveDirection
        hrp.Velocity = moveDir * flySpeed
        if moveDir.Magnitude == 0 then hrp.Velocity = Vector3.new(0, 0.1, 0) end
    end

    if State.CFrameSpeed and hrp and hum and hum.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (State.SpeedMultiplier * deltaTime * 50))
    end

    if AntiAim and hrp then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end

    if MapFrame.Visible and hrp and (hrp.Position - lastScanPos).Magnitude > 4 then
        lastScanPos = hrp.Position
        mapRp.FilterDescendantsInstances = {char}
        for x = 1, gridRes do
            for y = 1, gridRes do
                local offX = ((x - 1) / (gridRes - 1) - 0.5) * zoomLevel
                local offZ = ((y - 1) / (gridRes - 1) - 0.5) * zoomLevel
                local ray = Workspace:Raycast(hrp.Position + Vector3.new(offX, 100, offZ), Vector3.new(0, -200, 0), mapRp)
                if ray then
                    local h = math.clamp((ray.Position.Y - hrp.Position.Y + 20) / 40, 0, 1)
                    mapPixels[x][y].BackgroundColor3 = Color3.fromRGB(30 + (h * 40), 60 + (h * 80), 30 + (h * 40))
                else
                    mapPixels[x][y].BackgroundColor3 = Color3.fromRGB(10, 10, 15)
                end
            end
        end
    end

    if MapFrame.Visible and hrp then
        for _, p in pairs(Players:GetPlayers()) do
            local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if pr then
                local d = playerDots[p.Name]
                if not d then
                    d = Instance.new("Frame", MapFrame)
                    d.Size = UDim2.new(0, 6, 0, 6)
                    d.ZIndex = 10
                    Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
                    playerDots[p.Name] = d
                end
                d.BackgroundColor3 = (p == LocalPlayer) and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 50, 50)
                local rx = (pr.Position.X - hrp.Position.X) / zoomLevel
                local rz = (pr.Position.Z - hrp.Position.Z) / zoomLevel
                d.Position = UDim2.new(0.5 + rx, -3, 0.5 + rz, -3)
                d.Visible = math.abs(rx) < 0.5 and math.abs(rz) < 0.5
            end
        end
    end

    espUpdateCounter = espUpdateCounter + 1
    if espUpdateCounter % 6 == 0 then
        if State.ESPEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pchar = p.Character
                    if not pchar:FindFirstChild("ESPHighlight") then
                        local highlight = Instance.new("Highlight", pchar)
                        highlight.Name = "ESPHighlight"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    end
                    if not pchar.Head:FindFirstChild("ESPName") then
                        local bgui = Instance.new("BillboardGui", pchar.Head)
                        bgui.Name = "ESPName"
                        bgui.Size = UDim2.new(0, 200, 0, 50)
                        bgui.AlwaysOnTop = true
                        bgui.ExtentsOffset = Vector3.new(0, 3, 0)
                        local tl = Instance.new("TextLabel", bgui)
                        tl.BackgroundTransparency = 1
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                        tl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        tl.TextScaled = true
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    if p.Character:FindFirstChild("ESPHighlight") then p.Character.ESPHighlight:Destroy() end
                    if p.Character.Head:FindFirstChild("ESPName") then p.Character.Head.ESPName:Destroy() end
                end
            end
        end
    end

    if State.XrayEnabled then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not (part.Parent and part.Parent:FindFirstChild("Humanoid")) then
                if not XrayParts[part] then XrayParts[part] = part.Transparency end
                part.Transparency = 0.5
            end
        end
    else
        for part, trans in pairs(XrayParts) do
            if part and part.Parent then part.Transparency = trans end
            XrayParts[part] = nil
        end
    end

    sparklerUpdateCounter = sparklerUpdateCounter + 1
    if sparklerUpdateCounter % 2 == 0 then
        local t = tick()
        for i, obj in pairs(activeSparklers) do
            local main = obj:IsA("BasePart") and obj or obj.PrimaryPart
            local bp = main and main:FindFirstChild("AloeBP")
            local bg = main and main:FindFirstChild("AloeBG")
            if bp and bg and hrp then
                local offset = CalculateOffset(i, #activeSparklers, t, sparklerConfig, hrp)
                bp.Position = hrp.Position + prediction + offset
                bg.CFrame = CFrame.new(main.Position, hrp.Position + Vector3.new(0, 2, 0))
            end
        end
    end

    if tv_Enabled and sparklerUpdateCounter % 2 == 0 then
        local t_tv = tick()
        for i, obj in pairs(activeTVs) do
            local main = obj:IsA("BasePart") and obj or obj.PrimaryPart
            local bp = main and main:FindFirstChild("TVBP")
            local bg = main and main:FindFirstChild("TVBG")
            if bp and bg and hrp then
                local offset = CalculateOffset(i, #activeTVs, t_tv, tvConfig, hrp)
                bp.Position = hrp.Position + prediction + offset
                bg.CFrame = CFrame.new(main.Position, hrp.Position + Vector3.new(0, 2, 0))
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if autoKillEnabled and selectedPlayer then
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and not IsWhitelisted(target) then
            local hum = target.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                ExecutePrecisionCombo(selectedPlayer)
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(io, g)
    if g or not CatFrame.Visible then return end
    local name = io.KeyCode.Name
    if name:match("[WASD]") then
        PawL.Visible = true
    elseif io.KeyCode == Enum.KeyCode.Space then
        PawR.Visible = true
    end
end)

UserInputService.InputEnded:Connect(function(io)
    local name = io.KeyCode.Name
    if name:match("[WASD]") then
        PawL.Visible = false
    elseif io.KeyCode == Enum.KeyCode.Space then
        PawR.Visible = false
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if speedEnabled then hum.WalkSpeed = originalWalkSpeed end
        hum.JumpPower = originalJumpPower
    end
    setupAntiGrab(char)
end)

-- ============================================
-- OrionLib Init
-- ============================================
OrionLib:Init()
UpdateWhitelistUI()