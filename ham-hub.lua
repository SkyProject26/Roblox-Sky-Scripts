local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()

local Window = OrionLib:MakeWindow({
	Name = "Hamhub FTAP",
	HidePremium = false,
	SaveConfig = false,
	ConfigFolder = "HamhubFTAPConfig",
	IntroText = "Hamhub FTAP"
})

-- ==========================================
-- Essential Services & Global Variables
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

-- [Variables] Common / Blobman / Aura
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 10)
local SetNetworkOwner = GrabEvents and GrabEvents:FindFirstChild("SetNetworkOwner")
local CreateGrabLine = GrabEvents and GrabEvents:FindFirstChild("CreateGrabLine")
local ExtendGrabLine = GrabEvents and GrabEvents:FindFirstChild("ExtendGrabLine")
local DestroyGrabLine = GrabEvents and GrabEvents:FindFirstChild("DestroyGrabLine")

local cachedCG, cachedCD, cachedCR = nil, nil, nil
local cachedR_Det, cachedR_Weld = nil, nil
local cachedL_Det, cachedL_Weld = nil, nil
local cachedBlobman = nil
local playerThreads = {}
local bmkAuraEnabled = false
local AURA_RADIUS = 35
local auraConn = nil
local auraInRange = {}

-- [Variables] Blobman Kick & Kick All
local currentBlob = nil
local isActive = false
local levitateRunning = false
local selectedActionTargetName = ""
local ExcludeFriends = false
local autoKillAllEnabled = false

-- [Variables] Drift Kick
local orbitRunning = false
local currentLoopId = 0
local driftRadius = 19
local driftSpeed = 12
local driftHeightOffset = 0
local driftAngle = 0
local playerMap = {}

-- [Variables] 20 Stack Mount Kill (New Logic)
local bm_currentBlobman = nil
local bm_originalCFrame = nil
local bm_isRunning = false
local bm_loopConn = nil
local bm_grabConn = nil
local bm_respawnConn = nil
local bm_localRespawnConn = nil
local bm_mountConn = nil
local bm_lastTargetPos = Vector3.zero
local BM_MY_HEIGHT = 20
local bm_angle = 0
local bm_circleRadius = 8
local bm_rotationSpeed = 14

-- ============================================
-- [Variables & Logic] New Cosmos Toy Mod (Replaces Object Aura)
-- ============================================
local activeSparklers = {}
local sparklerUpdateCounter = 0
local autoSyncEnabled = false
local targetObjectName = "FireworkSparkler" 
local cosmosTargetPlayer = LocalPlayer

-- 設定用変数（全モードのパラメータ）
local sparklerConfig = { 
	Height = 6, 
	Radius = 22, 
	Speed = 18.0, 
	CurrentShape = "Wing", 
	FlapStrength = 2.5, 
	WingSpread = 2.2, 
	AngelRingRadius = 40, 
	AngelRingHeight = 19, 
	AngelRingSpeed = 18.0,
	StarBounce = 3 
}

local function ClearSync()
	for _, obj in pairs(activeSparklers) do
		local main = obj:IsA("BasePart") and obj or obj.PrimaryPart
		if main then
			if main:FindFirstChild("AloeBP") then main.AloeBP:Destroy() end
			if main:FindFirstChild("AloeBG") then main.AloeBG:Destroy() end
		end
	end
	activeSparklers = {}
end

local function GetCosmosPlayerList()
	local list = {"Me (@Me)"}
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
		end
	end
	return list
end

local function isCosmosTarget(name)
	return name:find(targetObjectName) ~= nil
end

local function SetupPhysics(obj, list)
	local mainPart = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
	if mainPart then
		pcall(function() if mainPart:CanSetNetworkOwnership() then mainPart:SetNetworkOwner(LocalPlayer) end end)
		mainPart.Anchored = false
		for _, v in pairs(mainPart:GetChildren()) do
			if v.Name == "AloeBP" or v.Name == "AloeBG" then v:Destroy() end
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
			if p:IsA("BasePart") then p.CanCollide = false p.CanTouch = false end
		end
		if not table.find(list, obj) then table.insert(list, obj) end
	end
end

local function CalculateOffset(index, total, t, cfg, targetRoot)
	local r, h, s = cfg.Radius, cfg.Height, cfg.Speed
	if cfg.CurrentShape == "Angel" then
		local totalForWing = math.floor(total / 2)
		if index <= totalForWing then
			local side = (index % 2 == 0) and 1 or -1
			local idx = math.ceil(index / 2)
			return targetRoot.CFrame:VectorToWorldSpace(Vector3.new((side * 2.0) + (side * (idx * cfg.WingSpread)), h + (math.sin(t * (s / 4) - (idx * 0.5)) * cfg.FlapStrength), (idx * 0.5)))
		else
			local angle = (index * (math.pi * 2) / (total - totalForWing)) + (t * (cfg.AngelRingSpeed / 5))
			return targetRoot.CFrame:VectorToWorldSpace(Vector3.new(math.cos(angle) * cfg.AngelRingRadius, cfg.AngelRingHeight, math.sin(angle) * cfg.AngelRingRadius))
		end
	end
	local angle = (index * (math.pi * 2) / total) + (t * (s / 5))
	if cfg.CurrentShape == "Wing" then
		local side = (index % 2 == 0) and 1 or -1
		local idx = math.ceil(index / 2)
		return targetRoot.CFrame:VectorToWorldSpace(Vector3.new((side * 2.0) + (side * (idx * cfg.WingSpread)), h + (math.sin(t * (s / 4) - (idx * 0.5)) * cfg.FlapStrength), 0))
	elseif cfg.CurrentShape == "Ring" then
		return targetRoot.CFrame:VectorToWorldSpace(Vector3.new(math.cos(angle) * r, h, math.sin(angle) * r))
	elseif cfg.CurrentShape == "Star" then
		local rad = r * (0.7 + 0.3 * math.sin(t * (s / 3) + index))
		return targetRoot.CFrame:VectorToWorldSpace(Vector3.new(math.cos(angle) * rad, h + math.sin(t * (s / 2) + index) * cfg.StarBounce, math.sin(angle) * rad))
	end
	return Vector3.new(math.cos(angle) * r, h, math.sin(angle) * r)
end

-- [Variables] Loop (Replaces Reskill)
local loopSelectedPlayers = {}
local isKilling = false
local loopNoclipConnection = nil
local loopNoclipping = false
local SetNetworkOwnerLoop = SetNetworkOwner

-- [Variables] Grab
local throwStrength = 400
local throwEnabled = false
local GrabMode = { Kill = false, Sky = false, Down = false, Noclip = false }

-- [Variables] Anti
local antiLagT = false
local isFlghtBackEnabled = false
local spamConnection = nil
local isHolding = false
local lastActionTime = 0
_G.Spamming = false

-- [Variables] New Anti System
local gucciRunId = 0
local antiGucciConnectionTrain
local safePositionTrain
local restoreFramesTrain = 0
local autoGucciActiveTrain = false
local antiActive = false
local antiTask = nil

-- [Variables] Nova Hub Anti (Grab & Kick)
local megaCharEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local megaGrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local megaMenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local megaPlayerEvents = ReplicatedStorage:WaitForChild("PlayerEvents")

local megaRagdollRemote = megaCharEvents:WaitForChild("RagdollRemote")
local megaStruggle = megaCharEvents:WaitForChild("Struggle")
local megaSpawnToyRF = megaMenuToys:WaitForChild("SpawnToyRemoteFunction")
local megaBuyToyRF = megaMenuToys:WaitForChild("BuyToyRemoteFunction")
local megaDestroyToy = megaMenuToys:WaitForChild("DestroyToy")
local megaSetNetworkOwner = megaGrabEvents:WaitForChild("SetNetworkOwner")
local megaStickyPartEvent = megaPlayerEvents:WaitForChild("StickyPartEvent")

local megaAntiGrabToggle = false
local megaAntiGrabProce = false
local megaRagdollCount = 0
local megaAntikickV2 = false
local megaNotifiedNoCoins = false
local megaAntiGrabCharConn = nil

local function megaNBNotification(msg)
	OrionLib:MakeNotification({
		Name = "Nova hub v1",
		Content = msg,
		Image = "rbxassetid://4483345998",
		Time = 5
	})
end

-- [Variables] Server
local Go_g = 1
local PP_dd = 50
local running = false
local ragServer = false

-- [Variables] Visuals (ESP)
local ESP_Settings = { Enabled = false, Lines = false }

-- [Variables] Minimap / Teleport
local mapRp = RaycastParams.new()
mapRp.FilterType = Enum.RaycastFilterType.Exclude
local zoomLevel = 500
local gridRes = 12
local mapPixels = {}
local playerDots = {}
local lastScanPos = Vector3.new(0, 0, 0)
local mapOffset = Vector3.zero
local selectedTeleportTargetName = nil

-- ==========================================
-- Minimap UI Construction
-- ==========================================
local MapGui = Instance.new("ScreenGui")
MapGui.Name = "CustomMinimapGui"
pcall(function() MapGui.Parent = game:GetService("CoreGui") end)
if not MapGui.Parent then MapGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MapFrame = Instance.new("Frame", MapGui)
MapFrame.Size = UDim2.new(0, 220, 0, 220)
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

-- ==========================================
-- Core Logic & Helper Functions
-- ==========================================
local function HRP()
	return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function getPlayerList()
	local names = {}
	playerMap = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local displayStr = player.DisplayName .. " (@" .. player.Name .. ")"
			table.insert(names, displayStr)
			playerMap[displayStr] = player.Name
		end
	end
	if #names == 0 then table.insert(names, "(None)") end
	return names
end

local function SendChat(msg)
	pcall(function()
		local TextChatService = game:GetService("TextChatService")
		if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
		else
			ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
		end
	end)
end

local function FWC(Parent, Name, Time)
	return Parent:FindFirstChild(Name) or Parent:WaitForChild(Name, Time or 3)
end

-- ------------------------------------------
-- [Logic] Blobman / Aura
-- ------------------------------------------
local function refreshBlobman()
	local found = nil
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") then
			local seat = v.VehicleSeat
			local weld = seat and seat:FindFirstChild("SeatWeld")
			if weld and weld.Part1 and weld.Part1:IsDescendantOf(LocalPlayer.Character) then
				found = v
				break
			end
		end
	end
	cachedBlobman = found
	if not found then
		cachedCG, cachedCD, cachedCR = nil, nil, nil
		cachedR_Det, cachedR_Weld, cachedL_Det, cachedL_Weld = nil, nil, nil, nil
		return
	end
	local s1 = found:FindFirstChild("BlobmanSeatAndOwnerScript")
	local s2 = found:FindFirstChild("BlobmanSeatAndOwnerScript[old]")
	cachedCG = (s1 and s1:FindFirstChild("CreatureGrab")) or (s2 and s2:FindFirstChild("CreatureGrab")) or found:FindFirstChild("CreatureGrab", true)
	cachedCD = (s1 and s1:FindFirstChild("CreatureDrop")) or (s2 and s2:FindFirstChild("CreatureDrop")) or found:FindFirstChild("CreatureDrop", true)
	cachedCR = (s1 and s1:FindFirstChild("CreatureRelease")) or (s2 and s2:FindFirstChild("CreatureRelease")) or found:FindFirstChild("CreatureRelease", true)
	cachedR_Det = found:FindFirstChild("RightDetector")
	cachedR_Weld = cachedR_Det and (cachedR_Det:FindFirstChild("RightWeld") or cachedR_Det:FindFirstChildWhichIsA("Weld") or cachedR_Det:FindFirstChildWhichIsA("JointInstance"))
	cachedL_Det = found:FindFirstChild("LeftDetector")
	cachedL_Weld = cachedL_Det and (cachedL_Det:FindFirstChild("LeftWeld") or cachedL_Det:FindFirstChildWhichIsA("Weld") or cachedL_Det:FindFirstChildWhichIsA("JointInstance"))
end

pcall(refreshBlobman)
Workspace.DescendantAdded:Connect(function(d)
	if d.Name == "CreatureBlobman" or d.Name == "SeatWeld" then
		task.defer(refreshBlobman)
	end
end)
Workspace.DescendantRemoving:Connect(function(d)
	if d == cachedBlobman or d.Name == "SeatWeld" then
		task.defer(refreshBlobman)
	end
end)

local function stopThreads(userId)
	local st = playerThreads[userId]
	if st then
		st.active = false
		playerThreads[userId] = nil
	end
end

local function startThreads(player, userId)
	stopThreads(userId)
	local state = { active = true }
	playerThreads[userId] = state
	local grabConn
	grabConn = RunService.Heartbeat:Connect(function()
		if not state.active then grabConn:Disconnect(); return end
		if not cachedCG then return end
		local char = player.Character
		if not char then return end
		local pHRP = char:FindFirstChild("HumanoidRootPart")
		if not pHRP then return end
		pcall(function()
			if cachedR_Det then
				cachedCG:FireServer(cachedR_Det, pHRP, cachedR_Weld)
				cachedR_Weld = cachedR_Det:FindFirstChild("RightWeld") or cachedR_Det:FindFirstChildWhichIsA("Weld") or cachedR_Det:FindFirstChildWhichIsA("JointInstance")
				if cachedCR and cachedR_Weld then cachedCR:FireServer(cachedR_Weld) end
				if cachedCD and cachedR_Weld then cachedCD:FireServer(cachedR_Weld) end
			end
			if cachedL_Det then
				cachedCG:FireServer(cachedL_Det, pHRP, cachedL_Weld)
				cachedL_Weld = cachedL_Det:FindFirstChild("LeftWeld") or cachedL_Det:FindFirstChildWhichIsA("Weld") or cachedL_Det:FindFirstChildWhichIsA("JointInstance")
				if cachedCR and cachedL_Weld then cachedCR:FireServer(cachedL_Weld) end
				if cachedCD and cachedL_Weld then cachedCD:FireServer(cachedL_Weld) end
			end
		end)
	end)
	local killConn
	killConn = RunService.Heartbeat:Connect(function()
		if not state.active then killConn:Disconnect(); return end
		local char = player.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		pcall(function()
			hum.Health = 0
			hum:ChangeState(Enum.HumanoidStateType.Dead)
		end)
	end)
end

-- ------------------------------------------
-- [Logic] 20 Stack Mount Kill Methods
-- ------------------------------------------
local function bm_SpawnBlobman()
	if bm_currentBlobman and bm_currentBlobman.Parent then pcall(function() bm_currentBlobman:Destroy() end) end
	bm_currentBlobman = nil
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
	local root = char.HumanoidRootPart
	bm_originalCFrame = root.CFrame
	local spawnPos = root.CFrame * CFrame.new(0, BM_MY_HEIGHT, -5)
	local success = pcall(function()
		ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
	end)
	if not success then return false end
	for _ = 1, 20 do
		bm_currentBlobman = workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys", true) and workspace[LocalPlayer.Name.."SpawnedInToys"]:FindFirstChild("CreatureBlobman")
		if bm_currentBlobman then break end
		task.wait(0.01)
	end
	if not bm_currentBlobman then return false end
	pcall(function()
		local seat = bm_currentBlobman:FindFirstChild("VehicleSeat") or Instance.new("VehicleSeat", bm_currentBlobman)
		seat.Name = "MyMountSeat"
		seat.CFrame = CFrame.new(0, BM_MY_HEIGHT, 0)
		seat.HeadOffset = Vector3.new(0, BM_MY_HEIGHT + 1, 0)
		seat.MaxSpeed = 0
		seat.Torque = 0
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			seat:Sit(hum)
			hum.JumpPower = 0
			hum.PlatformStand = true
		end
		if bm_currentBlobman.PrimaryPart then
			bm_currentBlobman.PrimaryPart.CanCollide = false
			bm_currentBlobman.PrimaryPart.Anchored = false
			bm_currentBlobman.PrimaryPart.Massless = true
		end
	end)
	return true
end

local function bm_KeepMounted()
	if bm_mountConn then bm_mountConn:Disconnect() end
	bm_mountConn = RunService.RenderStepped:Connect(function()
		if not bm_isRunning or not bm_currentBlobman then return end
		local char = LocalPlayer.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local seat = bm_currentBlobman:FindFirstChild("MyMountSeat")
		if hum and seat and not seat.Occupant then pcall(function() seat:Sit(hum) end) end
	end)
end

local function bm_StartContinuousGrab(targetRoot)
	if bm_grabConn then bm_grabConn:Disconnect() end
	bm_grabConn = RunService.RenderStepped:Connect(function()
		if not bm_isRunning or not bm_currentBlobman then return end
		local targetPlayer = Players:FindFirstChild(selectedActionTargetName)
		local validRoot = nil
		if targetPlayer and targetPlayer.Character then
			validRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if validRoot then bm_lastTargetPos = validRoot.Position end
		end
		pcall(function()
			local s = bm_currentBlobman:FindFirstChild("BlobmanSeatAndOwnerScript")
			local grab = s and s:FindFirstChild("CreatureGrab")
			local release = s and s:FindFirstChild("CreatureRelease")
			local det = bm_currentBlobman:FindFirstChild("LeftDetector")
			local weld = det and det:FindFirstChild("LeftWeld")
			if grab and release and det and weld then
				local sendTarget = validRoot or { Position = bm_lastTargetPos, Name = "TempTarget", Parent = workspace }
				grab:FireServer(det, sendTarget, weld)
				release:FireServer(weld)
			end
		end)
	end)
end

local function bm_SetupRespawnMonitor(targetPlayer)
	if bm_respawnConn then bm_respawnConn:Disconnect() end
	if not targetPlayer then return end
	bm_respawnConn = targetPlayer.CharacterAdded:Connect(function(newChar)
		task.wait(0.3)
		if not bm_isRunning then return end
		local newRoot = newChar:WaitForChild("HumanoidRootPart", 10)
		if newRoot then
			bm_lastTargetPos = newRoot.Position
			if not bm_currentBlobman or not bm_currentBlobman.Parent then bm_SpawnBlobman() end
			bm_StartContinuousGrab(newRoot)
			OrionLib:MakeNotification({Name="Grab Recovered", Content="Continuing after death", Time=1})
		end
	end)
	if bm_localRespawnConn then bm_localRespawnConn:Disconnect() end
	bm_localRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.5)
		if bm_isRunning then bm_SpawnBlobman(); bm_KeepMounted() end
	end)
end

local function bm_ProcessCycle()
	if not bm_isRunning or bm_rotationSpeed <= 0 then return end
	local targetPlayer = Players:FindFirstChild(selectedActionTargetName)
	if not bm_currentBlobman or not bm_currentBlobman.Parent then
		if bm_SpawnBlobman() then
			bm_StartContinuousGrab(targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") or nil)
			bm_KeepMounted()
		else return end
	end
	bm_angle += math.rad(bm_rotationSpeed * 0.8)
	local offsetX = math.sin(bm_angle) * bm_circleRadius
	local offsetZ = math.cos(bm_angle) * bm_circleRadius
	local newPosition = bm_lastTargetPos + Vector3.new(offsetX, 0, offsetZ)
	local lookDir = (bm_lastTargetPos - newPosition).Unit
	if lookDir.Magnitude > 0 then
		pcall(function() bm_currentBlobman:SetPrimaryPartCFrame(CFrame.new(newPosition, newPosition + lookDir)) end)
	end
	if targetPlayer and targetPlayer.Character then
		local tHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
		if tHum and tHum.Health > 0 then
			pcall(function()
				tHum.BreakJointsOnDeath = true
				tHum.MaxHealth = 1
				tHum.Health = -999999
				tHum:TakeDamage(9999)
				tHum:ChangeState(Enum.HumanoidStateType.Dead)
			end)
		end
	end
end

-- ------------------------------------------
-- [Logic] Kill Aura
-- ------------------------------------------
local function stopAura()
	bmkAuraEnabled = false
	if auraConn then auraConn:Disconnect(); auraConn = nil end
	for uid in pairs(auraInRange) do stopThreads(uid) end
	auraInRange = {}
end

local function startAura()
	if auraConn then auraConn:Disconnect(); auraConn = nil end
	auraInRange = {}
	auraConn = RunService.Heartbeat:Connect(function()
		if not bmkAuraEnabled then stopAura(); return end
		local myHRP = HRP()
		if not myHRP then return end
		local myPos = myHRP.Position
		local nowInRange = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p == LocalPlayer then continue end
			local char = p.Character
			local pHRP = char and char:FindFirstChild("HumanoidRootPart")
			if pHRP then
				if (myPos - pHRP.Position).Magnitude > AURA_RADIUS then
					if auraInRange[p.UserId] then stopThreads(p.UserId) end
					continue 				
				end
			elseif not auraInRange[p.UserId] then
				continue
			end
			nowInRange[p.UserId] = true
			if not auraInRange[p.UserId] then startThreads(p, p.UserId) end
		end
		for uid in pairs(auraInRange) do
			if not nowInRange[uid] then stopThreads(uid) end
		end
		auraInRange = nowInRange
	end)
end

-- ------------------------------------------
-- [Logic] Kick All
-- ------------------------------------------
local function KickAll()
	if isActive then return end
	isActive = true
	local allPlayers = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			if ExcludeFriends and LocalPlayer:IsFriendsWith(p.UserId) then continue end
			table.insert(allPlayers, p)
		end
	end
	if #allPlayers == 0 then isActive = false; return end
	local rootPart = HRP()
	if rootPart then
		local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
		ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
	end
	task.wait(0.5)
	currentBlob = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys") and Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys"):FindFirstChild("CreatureBlobman")
	if not currentBlob then isActive = false; return end
	local vehicleSeat = currentBlob:FindFirstChild("VehicleSeat")
	if vehicleSeat and LocalPlayer.Character then
		vehicleSeat:Sit(LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
	end
	task.wait(0.3)
	local myRoot = HRP()
	if not myRoot then isActive = false; return end
	for _, targetPlayer in ipairs(allPlayers) do
		local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			myRoot.CFrame = targetRoot.CFrame
			task.wait(0.02)
			for i = 1, 3 do
				pcall(function()
					currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(currentBlob.LeftDetector, targetRoot, currentBlob.LeftDetector.LeftWeld)
					currentBlob.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(currentBlob.LeftDetector.LeftWeld)
				end)
				if i < 3 then task.wait(0.08) end
			end
		end
	end
	myRoot.CFrame = CFrame.new(0, 100, 0)
	task.wait(0.1)
	for _, part in ipairs(currentBlob:GetDescendants()) do
		if part:IsA("BasePart") then pcall(function() part.Anchored = true end) end
	end
	task.wait(0.1)
	local radius = 15
	for i, targetPlayer in ipairs(allPlayers) do
		local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			local angle = math.rad((i - 1) * (360 / #allPlayers))
			local x = radius * math.cos(angle)
			local z = radius * math.sin(angle)
			targetRoot.CFrame = CFrame.new(x, 110, z)
		end
	end
	task.wait(0.1)
	for _ = 1, 2 do
		for _, targetPlayer in ipairs(allPlayers) do
			local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				pcall(function()
					if SetNetworkOwner then SetNetworkOwner:FireServer(targetRoot, CFrame.new(targetRoot.Position)) end
					if DestroyGrabLine then DestroyGrabLine:FireServer(targetRoot) end
				end)
			end
		end
		task.wait(0.1)
	end
	task.wait(0.3)
	for _, targetPlayer in ipairs(allPlayers) do
		local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			pcall(function()
				currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(currentBlob.LeftDetector, targetRoot, currentBlob.LeftDetector.LeftWeld)
				currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(currentBlob.RightDetector, targetRoot, currentBlob.RightDetector.RightWeld)
			end)
		end
	end
	for _, part in ipairs(currentBlob:GetDescendants()) do
		if part:IsA("BasePart") then pcall(function() part.Anchored = false end) end
	end
	isActive = false
end

-- ------------------------------------------
-- [Logic] Grab
-- ------------------------------------------
Workspace.ChildAdded:Connect(function(model)
	if model.Name == "GrabParts" then
		task.wait()
		local grabPart = model:FindFirstChild("GrabPart")
		local weld = grabPart and grabPart:FindFirstChild("WeldConstraint")
		local target = weld and weld.Part1
		if not target then return end
		local targetChar = target.Parent
		if GrabMode.Kill and targetChar:FindFirstChild("Humanoid") then
			targetChar:BreakJoints()
		end
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
		model.AncestryChanged:Connect(function(_, parent)
			if not parent then
				if bv and bv.Parent then bv:Destroy() end
				if throwEnabled and target and target.Parent then
					local throwV = Instance.new("BodyVelocity")
					throwV.Name = "ThrowForce"
					throwV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					throwV.Velocity = Workspace.CurrentCamera.CFrame.LookVector * throwStrength
					throwV.Parent = target
					Debris:AddItem(throwV, 1)
				end
				if GrabMode.Noclip and targetChar then
					for _, p in pairs(targetChar:GetChildren()) do
						if p:IsA("BasePart") then p.CanCollide = true end
					end
				end
			end
		end)
	end
end)

-- ------------------------------------------
-- [Logic] Anti Explosion
-- ------------------------------------------
local function setupAntiExplosion(char)
	if not char then return end
	local hum = char:WaitForChild("Humanoid", 5)
	if not hum then return end
	local ragdolled = hum:FindFirstChild("Ragdolled")
	if ragdolled and ragdolled:IsA("BoolValue") then
		if antiExplosionConn then antiExplosionConn:Disconnect() end
		antiExplosionConn = ragdolled:GetPropertyChangedSignal("Value"):Connect(function()
			local anchored = ragdolled.Value
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then part.Anchored = anchored end
			end
		end)
	end
end

-- ------------------------------------------
-- [Logic] Loop / Reskill
-- ------------------------------------------
local function lookAt(from, to)
	local direction = (to - from).Unit
	local right = direction:Cross(Vector3.new(0, 1, 0))
	local up = right:Cross(direction)
	return CFrame.fromMatrix(from, right, up)
end

local function EnableLoopNoclip()
	if not loopNoclipConnection then
		loopNoclipping = false
		loopNoclipConnection = RunService.Stepped:Connect(function()
			if loopNoclipping == false and LocalPlayer.Character then
				for _, part in pairs(LocalPlayer.Character:GetChildren()) do
					if part:IsA("BasePart") and part.CanCollide and part.Name ~= "floatName" then
						part.CanCollide = false
					end
				end
			end
			task.wait(0.21)
		end)
	end
end

local function DisableLoopNoclip()
	if loopNoclipConnection then
		loopNoclipConnection:Disconnect()
		loopNoclipConnection = nil
	end
	loopNoclipping = true
end

local function SNOWship(part)
	if part and typeof(part) == "Instance" and SetNetworkOwnerLoop then
		local distance = LocalPlayer:DistanceFromCharacter(part.Position)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and distance <= 30 then
			SetNetworkOwnerLoop:FireServer(part, lookAt(LocalPlayer.Character.HumanoidRootPart.Position, part.Position))
		end
	end
end

local function TeleportPlayerLoop(cf)
	local character = LocalPlayer.Character
	if character and typeof(cf) == "CFrame" then
		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if root and humanoid then
			root.CFrame = root.CFrame.Rotation + cf.Position
			if humanoid.SeatPart == nil or tostring(humanoid.SeatPart.Parent) ~= "CreatureBlobman" then
				humanoid.Sit = false
			end
		end
	end
end

local function CreateSkyVelocity(part)
	if not part:FindFirstChild("SkyVelocity") then
		local bv = Instance.new("BodyVelocity", part)
		bv.Name = "SkyVelocity"
		bv.Velocity = Vector3.new(0, 1e14, 0)
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	end
end

local function CheckNetworkOwnership(player)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Character then
		local head = player.Character:FindFirstChild("Head")
		if head and head:FindFirstChild("PartOwner") and head.PartOwner.Value == LocalPlayer.Name then
			return true
		end
	end
	return false
end

local function IsValidTarget(player)
	if typeof(player) == "Instance" and player ~= LocalPlayer then
		if player:IsA("Player") and player.Character then
			if player.Character:IsDescendantOf(workspace) then
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				if root and humanoid and humanoid.Health > 0 then
					if player:FindFirstChild("InPlot") and player.InPlot.Value then
						return false
					end
					if humanoid.FloorMaterial == Enum.Material.Air then
						return false
					end
					return true
				end
			end
		end
	end
	return false
end

local function KillPlayer(targetPlayer)
	if not IsValidTarget(targetPlayer) then return end
	local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then return end
	local initialPos = LocalPlayer.Character.HumanoidRootPart.CFrame
	
	EnableLoopNoclip()
	
	for i = 1, 50 do
		SNOWship(root)
		if CheckNetworkOwnership(targetPlayer) or root.AssemblyLinearVelocity.Magnitude > 500 then
			CreateSkyVelocity(root)
			if DestroyGrabLine then pcall(function() DestroyGrabLine:FireServer(root) end) end
			break
		end
		task.wait()
		if root.Position.Y <= -12 then
			TeleportPlayerLoop(CFrame.new(root.Position + Vector3.new(0, 5, -15)))
		else
			TeleportPlayerLoop(CFrame.new(root.Position + Vector3.new(0, -10, -10)))
		end
		humanoid.BreakJointsOnDeath = false
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
		humanoid.Jump = true
		humanoid.Sit = false
	end
	
	DisableLoopNoclip()
	TeleportPlayerLoop(initialPos)
end

-- ------------------------------------------
-- [Logic] New Anti Systems (Gucci & Train & Blobman)
-- ------------------------------------------
local function grab_network(prt)
	ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(prt, prt.CFrame)
end

local function toy_spawn_gucci(name, cframe, vector)
	local ToySpawn = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction
	local InPlot = LocalPlayer:WaitForChild("InPlot")
	local InOwnerPlot = LocalPlayer:WaitForChild("InOwnedPlot")
	local CanSpawn = LocalPlayer:WaitForChild("CanSpawnToy")
	while InPlot.Value and not InOwnerPlot.Value and not CanSpawn.Value do task.wait(0.01) end
	task.spawn(function() ToySpawn:InvokeServer(name, cframe, vector or Vector3.new()) end)
	local BackPack = Workspace:FindFirstChild(LocalPlayer.Name .. 'SpawnedInToys')
	if not BackPack then return nil end
	local SpawnedToy = nil
	local connection
	connection = BackPack.ChildAdded:Connect(function(toy)
		if toy.Name == name and toy:IsA("Model") then
			SpawnedToy = toy
			connection:Disconnect()
		end
	end)
	local startTick = tick()
	while not SpawnedToy do
		if tick() - startTick > 2 then
			if connection then connection:Disconnect() end
			return nil
		end
		task.wait(0.01)
	end
	return SpawnedToy
end

local function GucciAntiGrab()
	gucciRunId = gucciRunId + 1
	local MyId = gucciRunId
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = FWC(char, "Humanoid")
	local hrp = FWC(char, "HumanoidRootPart")
	OrionLib:MakeNotification({ Name = "GUCCI", Content = "Executing Gucci Anti-Grab...", Time = 2, Image = "rbxassetid://4483345998" })
	hum.Sit = true
	task.wait(0.02)
	hum.Sit = false
	task.spawn(function()
		local t = tick()
		while tick() - t < 0.8 do
			for _, v in pairs(char:GetChildren()) do
				if v:IsA('BasePart') then v.Velocity = Vector3.new() end
			end
			task.wait(0.01)
		end
	end)
	local Blob = toy_spawn_gucci(
		"CreatureBlobman",
		hrp.CFrame * CFrame.new(0, 0, -5),
		Vector3.new(0, -15.716, 0)
	)
	if not Blob then return end
	local BHead = FWC(Blob, "Head")
	local HitBox = FWC(Blob, "GrabbableHitbox")
	local Seat = FWC(Blob, "VehicleSeat")
	task.spawn(function()
		while MyId == gucciRunId and BHead and (not BHead:FindFirstChild("PartOwner") or BHead.PartOwner.Value ~= LocalPlayer.Name) do
			grab_network(HitBox)
			task.wait(0.01)
		end
	end)
	local autoGucci = true
	task.spawn(function()
		local startTime = tick()
		while autoGucci and MyId == gucciRunId and tick() - startTime < 0.4 do
			if Blob and Blob.Parent then
				if Seat and Seat.Occupant ~= hum then Seat:Sit(hum) end
			end
			task.wait(0.03)
			if char and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
		autoGucci = false
	end)
	task.spawn(function()
		while autoGucci and MyId == gucciRunId do
			ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(hrp, 0.095)
			task.wait(0.01)
		end
	end)
	task.wait(0.5)
	if MyId ~= gucciRunId then return end
	hum.Sit = false
	Blob.Name = "Gucci"
	for _, v in pairs(Blob:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.CanTouch = false
			v.CanQuery = false
		end
	end
	task.spawn(function()
		while MyId == gucciRunId and Blob and BHead do
			BHead.CFrame = CFrame.new(BHead.Position.X, 1e5, BHead.Position.Z)
			task.wait(0.01)
		end
	end)
end

local function startAntiGucciTrain()
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	safePositionTrain = rootPart.Position
	local folder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("AlwaysHereTweenedObjects")
	local train = folder and folder:FindFirstChild("Train")
	local seat
	if train then
		for _, d in ipairs(train:GetDescendants()) do
			if d:IsA("Seat") then seat = d; break end
		end
	end
	if seat then
		rootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
		seat:Sit(humanoid)
	end
	humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if humanoid.Jump and humanoid.Sit then
			restoreFramesTrain = 15
			safePositionTrain = rootPart.Position
		end
	end)
	if antiGucciConnectionTrain then antiGucciConnectionTrain:Disconnect() end
	antiGucciConnectionTrain = RunService.Heartbeat:Connect(function()
		if not rootPart or not humanoid then return end
		if ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("RagdollRemote") then
			ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(rootPart, 0)
		end
		if restoreFramesTrain > 0 then
			rootPart.CFrame = CFrame.new(safePositionTrain)
			restoreFramesTrain = restoreFramesTrain - 1
		end
	end)
	task.spawn(function()
		while humanoid.Sit do task.wait(1) end
		task.wait(0.5)
		rootPart.CFrame = CFrame.new(safePositionTrain)
	end)
end

local function stopAntiGucciTrain()
	if antiGucciConnectionTrain then
		antiGucciConnectionTrain:Disconnect()
		antiGucciConnectionTrain = nil
	end
	local trainFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("AlwaysHereTweenedObjects")
	if trainFolder and trainFolder:FindFirstChild("Train") then
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") then
			character.Humanoid.Health = 0
		end
	end
end

local function AntiBlobmanKill()
	while antiActive do
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChild("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 then
				hum.Sit = true
				hum:ChangeState(Enum.HumanoidStateType.Running)
				local camera = workspace.CurrentCamera
				if camera then
					local lookVec = camera.CFrame.LookVector
					hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVec.X, 0, lookVec.Z))
				end
			end
		end
		task.wait()
	end
end

-- ------------------------------------------
-- [Logic] Visuals (ESP / Tracers)
-- ------------------------------------------
local function CreateTracer(player)
	local line
	pcall(function() line = Drawing.new("Line") end)
	if not line then return end
	line.Visible = false
	line.Color = Color3.new(1, 0, 0)
	line.Thickness = 1
	line.Transparency = 1
	RunService.RenderStepped:Connect(function()
		if ESP_Settings.Enabled and ESP_Settings.Lines and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if onScreen then
				line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				line.To = Vector2.new(vector.X, vector.Y)
				line.Visible = true
			else
				line.Visible = false
			end
		else
			line.Visible = false
		end
	end)
end

local function CreateNameTag(player)
	if player == LocalPlayer then return end
	local function setup(char)
		local head = char:WaitForChild("Head", 10)
		if not head then return end
		local billboard = Instance.new("BillboardGui", head)
		billboard.Name = "ESP_UI"
		billboard.Size = UDim2.new(0, 100, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Enabled = ESP_Settings.Enabled
		local icon = Instance.new("ImageLabel", billboard)
		icon.Size = UDim2.new(0, 40, 0, 40)
		icon.Position = UDim2.new(0.5, -20, 0, -35)
		icon.BackgroundTransparency = 1
		task.spawn(function()
			local success, content = pcall(function() return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
			if success and content then icon.Image = content end
		end)
		local name = Instance.new("TextLabel", billboard)
		name.Size = UDim2.new(1, 0, 0, 20)
		name.Position = UDim2.new(0, 0, 0, 5)
		name.BackgroundTransparency = 1
		name.Text = player.DisplayName
		name.TextColor3 = Color3.new(1, 1, 1)
		name.TextStrokeTransparency = 0
		name.TextScaled = true
	end
	if player.Character then setup(player.Character) end
	player.CharacterAdded:Connect(setup)
end

-- ------------------------------------------
-- [Logic] Minimap & Teleport
-- ------------------------------------------
local activeTouches = 0
UserInputService.TouchStarted:Connect(function() activeTouches = activeTouches + 1 end)
UserInputService.TouchEnded:Connect(function() activeTouches = math.max(0, activeTouches - 1) end)

MapFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if activeTouches > 1 then return end
		local dragging = true
		local uiMoving = false
		local mapScrolling = false
		local pressTime = tick()
		local dragStartPos = input.Position
		local uiStartPos = MapFrame.Position
		local mapOffsetStart = mapOffset
		local moveCon, endCon
		moveCon = UserInputService.InputChanged:Connect(function(inp)
			if (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) and dragging then
				if activeTouches > 1 then dragging = false; return end
				local delta = inp.Position - dragStartPos
				local elapsed = tick() - pressTime
				if not uiMoving and not mapScrolling then
					if delta.Magnitude > 5 then
						if elapsed > 0.25 then mapScrolling = true
						else uiMoving = true end
					end
				end
				if uiMoving then
					MapFrame.Position = UDim2.new(uiStartPos.X.Scale, uiStartPos.X.Offset + delta.X, uiStartPos.Y.Scale, uiStartPos.Y.Offset + delta.Y)
				elseif mapScrolling then
					local relX = delta.X / MapFrame.AbsoluteSize.X
					local relY = delta.Y / MapFrame.AbsoluteSize.Y
					mapOffset = mapOffsetStart - Vector3.new(relX * zoomLevel, 0, relY * zoomLevel)
				end
			end
		end)
		endCon = UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				if dragging then
					dragging = false
					if not uiMoving and not mapScrolling and (inp.Position - dragStartPos).Magnitude < 15 and LocalPlayer.Character then
						local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						if root then
							local relX = (inp.Position.X - MapFrame.AbsolutePosition.X) / MapFrame.AbsoluteSize.X - 0.5
							local relY = (inp.Position.Y - MapFrame.AbsolutePosition.Y) / MapFrame.AbsoluteSize.Y - 0.5
							local centerPos = root.Position + mapOffset
							local targetX = centerPos.X + (relX * zoomLevel)
							local targetZ = centerPos.Z + (relY * zoomLevel)
							local rayRes = Workspace:Raycast(Vector3.new(targetX, 1000, targetZ), Vector3.new(0, -2000, 0), mapRp)
							local finalY = rayRes and rayRes.Position.Y or root.Position.Y
							root.CFrame = CFrame.new(targetX, finalY + 4, targetZ)
						end
					end
				end
				moveCon:Disconnect()
				endCon:Disconnect()
			end
		end)
	end
end)

MapFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		zoomLevel = math.clamp(zoomLevel + (input.Position.Z * -100), 50, 1500)
	end
end)

local initialZoom = zoomLevel
UserInputService.TouchPinch:Connect(function(touchPositions, scale, velocity, state, gameProcessed)
	if not MapFrame.Visible then return end
	if state == Enum.UserInputState.Begin then
		initialZoom = zoomLevel
	elseif state == Enum.UserInputState.Change then
		zoomLevel = math.clamp(initialZoom / scale, 50, 1500)
	end
end)

Players.PlayerRemoving:Connect(function(p)
	if playerDots[p.Name] then
		playerDots[p.Name]:Destroy()
		playerDots[p.Name] = nil
	end
end)

local function initRenderStep()
	RunService.RenderStepped:Connect(function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local centerPos = hrp.Position + mapOffset
		if MapFrame.Visible and (centerPos - lastScanPos).Magnitude > 4 then
			lastScanPos = centerPos
			mapRp.FilterDescendantsInstances = {char}
			for x = 1, gridRes do
				for y = 1, gridRes do
					local offX = ((x - 1) / (gridRes - 1) - 0.5) * zoomLevel
					local offZ = ((y - 1) / (gridRes - 1) - 0.5) * zoomLevel
					local ray = Workspace:Raycast(centerPos + Vector3.new(offX, 100, offZ), Vector3.new(0, -200, 0), mapRp)
					if ray and ray.Instance then
						local partColor = ray.Instance.Color
						local h = math.clamp((ray.Position.Y - centerPos.Y + 30) / 60, 0.3, 1.2)
						local r = math.clamp(partColor.R * 255 * h, 0, 255)
						local g = math.clamp(partColor.G * 255 * h, 0, 255)
						local b = math.clamp(partColor.B * 255 * h, 0, 255)
						mapPixels[x][y].BackgroundColor3 = Color3.fromRGB(r, g, b)
					else
						mapPixels[x][y].BackgroundColor3 = Color3.fromRGB(15, 15, 20)
					end
				end
			end
		end
		if MapFrame.Visible then
			for _, p in pairs(Players:GetPlayers()) do
				local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if pr then
					local d = playerDots[p.Name]
					if not d then
						d = Instance.new("Frame", MapFrame)
						d.Size = UDim2.new(0, 26, 0, 26)
						d.AnchorPoint = Vector2.new(0.5, 0.5)
						d.BackgroundTransparency = 1
						d.ZIndex = 10
						local iconBg = Instance.new("Frame", d)
						iconBg.Size = UDim2.new(1, 0, 1, 0)
						iconBg.BackgroundColor3 = (p == LocalPlayer) and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 50, 50)
						Instance.new("UICorner", iconBg).CornerRadius = UDim.new(1, 0)
						local icon = Instance.new("ImageLabel", iconBg)
						icon.Size = UDim2.new(1, -4, 1, -4)
						icon.Position = UDim2.new(0, 2, 0, 2)
						icon.BackgroundTransparency = 1
						Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
						icon.ClipsDescendants = true
						task.spawn(function()
							local success, url = pcall(function() return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
							if success and url then icon.Image = url end
						end)
						local nameLbl = Instance.new("TextLabel", d)
						nameLbl.Size = UDim2.new(0, 100, 0, 12)
						nameLbl.Position = UDim2.new(0.5, -50, 1, 2)
						nameLbl.BackgroundTransparency = 1
						nameLbl.Text = p.DisplayName
						nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
						nameLbl.TextStrokeTransparency = 0.3
						nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
						nameLbl.TextSize = 10
						nameLbl.Font = Enum.Font.GothamBold
						nameLbl.ZIndex = 11
						playerDots[p.Name] = d
					end
					local rx = (pr.Position.X - centerPos.X) / zoomLevel
					local rz = (pr.Position.Z - centerPos.Z) / zoomLevel
					d.Position = UDim2.new(0.5 + rx, 0, 0.5 + rz, 0)
					d.Visible = math.abs(rx) < 0.5 and math.abs(rz) < 0.5
				end
			end
		end
	end)
end

-- Background Cosmos Loop
task.spawn(function()
    while task.wait(1) do
        if autoSyncEnabled and cosmosTargetPlayer and cosmosTargetPlayer.Character then
            for _, o in pairs(Workspace:GetDescendants()) do 
                if isCosmosTarget(o.Name) and not table.find(activeSparklers, o) then SetupPhysics(o, activeSparklers) end 
            end
        else
            ClearSync()
        end
        for i = #activeSparklers, 1, -1 do if not activeSparklers[i].Parent then table.remove(activeSparklers, i) end end
    end
end)

RunService.RenderStepped:Connect(function()
    if not autoSyncEnabled or not cosmosTargetPlayer or not cosmosTargetPlayer.Character then return end
    local root = cosmosTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and sparklerUpdateCounter % 2 == 0 then
        local t = tick()
        for i, obj in pairs(activeSparklers) do
            local main = obj:IsA("BasePart") and obj or obj.PrimaryPart
            local bp, bg = main and main:FindFirstChild("AloeBP"), main and main:FindFirstChild("AloeBG")
            if bp and bg then
                bp.Position = root.Position + CalculateOffset(i, #activeSparklers, t, sparklerConfig, root)
                bg.CFrame = CFrame.new(main.Position, root.Position + Vector3.new(0, 2, 0))
            end
        end
    end
    sparklerUpdateCounter = (sparklerUpdateCounter + 1) % 100
end)

-- ==========================================
-- 4. UI Construction (Tabs)
-- ==========================================

-- ------------------------------------------
-- [Tab 1] Grab
-- ------------------------------------------
local GrabTab = Window:MakeTab({ Name = "Grab", Icon = "rbxassetid://7733954884", PremiumOnly = false })
GrabTab:AddSection({Name = "Throw Settings"})
GrabTab:AddToggle({ Name = "Enable Throw", Default = false, Callback = function(Value) throwEnabled = Value end })
GrabTab:AddSlider({
	Name = "Throw Strength",
	Min = 300,
	Max = 4000,
	Default = 400,
	Color = Color3.fromRGB(255, 255, 255),
	Increment = 1,
	ValueName = "Strength",
	Callback = function(Value) throwStrength = Value end
})
GrabTab:AddSection({Name = "Grab Modes"})
GrabTab:AddToggle({ Name = "Kill Grab", Default = false, Callback = function(Value) GrabMode.Kill = Value end })
GrabTab:AddToggle({ Name = "Sky Grab (Upward)", Default = false, Callback = function(Value) GrabMode.Sky = Value end })
GrabTab:AddToggle({ Name = "Down Grab (Downward)", Default = false, Callback = function(Value) GrabMode.Down = Value end })
GrabTab:AddToggle({ Name = "Noclip Grab", Default = false, Callback = function(Value) GrabMode.Noclip = Value end })

-- ------------------------------------------
-- [Tab 2] Anti (Defense System)
-- ------------------------------------------
local AntiTab = Window:MakeTab({ Name = "Anti", Icon = "rbxassetid://7734056608", PremiumOnly = false })
AntiTab:AddSection({Name = "Gucci Functions"})
AntiTab:AddToggle({ Name = "Anti Gucci", Default = false, Callback = function(Value)
	if Value then
		task.spawn(GucciAntiGrab)
	else
		gucciRunId = gucciRunId + 1
	end
end })
AntiTab:AddToggle({ Name = "Train Gocci", Default = false, Callback = function(Value)
	autoGucciActiveTrain = Value
	if Value then
		startAntiGucciTrain()
		OrionLib:MakeNotification({ Name = "System", Content = "Gucci active (monitoring)", Time = 3, Image = "rbxassetid://4483362458" })
		task.spawn(function()
			while autoGucciActiveTrain do
				local trainFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("AlwaysHereTweenedObjects")
				local trainExists = trainFolder and trainFolder:FindFirstChild("Train")
				if not trainExists then
					stopAntiGucciTrain()
					OrionLib:MakeNotification({ Name = "System", Content = "Train lost", Time = 3, Image = "rbxassetid://4483362458" })
					local retries = 0
					repeat
						task.wait(0.2)
						retries = retries + 1
						trainFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("AlwaysHereTweenedObjects")
					until (trainFolder and trainFolder:FindFirstChild("Train")) or retries > 25 or not autoGucciActiveTrain
					if autoGucciActiveTrain and trainFolder and trainFolder:FindFirstChild("Train") then
						startAntiGucciTrain()
						OrionLib:MakeNotification({ Name = "System", Content = "Train restored.", Time = 3, Image = "rbxassetid://4483362458" })
					end
				end
				task.wait(0.5)
			end
		end)
	else
		autoGucciActiveTrain = false
		stopAntiGucciTrain()
		OrionLib:MakeNotification({ Name = "System", Content = "Gucci disabled.", Time = 3, Image = "rbxassetid://4483362458" })
	end
end })

AntiTab:AddToggle({ Name = "Anti Blobman Kill", Default = false, Callback = function(Value)
	antiActive = Value
	if Value then
		antiTask = task.spawn(AntiBlobmanKill)
	else
		if antiTask then
			task.cancel(antiTask)
			antiTask = nil
		end
	end
end })

AntiTab:AddToggle({
    Name = "Anti Kick",
    Default = false,
    Callback = function(Value)
        local megaPlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        local ToyContents = megaPlayerGui:WaitForChild("MenuGui"):WaitForChild("Menu")
            :WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents")
        local megaSpawnedInToys = workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys")
        
        megaAntikickV2 = Value
        if Value then megaNotifiedNoCoins = false end

        local function getCharPart(name)
            local char = LocalPlayer.Character
            return char and char:FindFirstChild(name)
        end

        local function inner_toyspn(toyName, cf)
            megaSpawnToyRF:InvokeServer(toyName, cf, Vector3.new(0, 0, 0))
        end

        local function inner_toyspn2(toyName)
            local hrp = getCharPart("HumanoidRootPart")
            if hrp then
                local cf = hrp.CFrame
                inner_toyspn(toyName, cf - Vector3.new(cf.LookVector.X * 20, -15, cf.LookVector.Z * 20))
            end
        end

        local function f()
            local character = LocalPlayer.Character
            if not character then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local hum = character:FindFirstChildOfClass("Humanoid")
            local leg = character:FindFirstChild("Right Leg")
            if not hrp or not hum or not leg or hum.Health <= 0 then return end
            if LocalPlayer:FindFirstChild("InPlot") and LocalPlayer.InPlot.Value then return end

            if not ToyContents:FindFirstChild("NinjaKunai") then
                local success = megaBuyToyRF:InvokeServer("NinjaKunai")
                if not success then
                    if not megaNotifiedNoCoins then
                        megaNBNotification("Cannot purchase NinjaKunai (Not enough coins)")
                        megaNotifiedNoCoins = true
                    end
                    return
                end
            end

            local kunai = megaSpawnedInToys:FindFirstChild("NinjaKunai")
            if kunai then
                local sticky = kunai:WaitForChild("StickyPart", 1)
                if sticky then
                    local weld = sticky:FindFirstChild("StickyWeld")
                    local attachedPart = weld and weld.Part1
                    if not weld or attachedPart ~= leg then
                        megaDestroyToy:FireServer(kunai)
                        task.wait(0.1)
                    end
                else
                    megaDestroyToy:FireServer(kunai)
                        task.wait(0.1)
                end
            elseif LocalPlayer:FindFirstChild("CanSpawnToy") and LocalPlayer.CanSpawnToy.Value then
                task.spawn(inner_toyspn2, "NinjaKunai")
                local newKunai = megaSpawnedInToys:WaitForChild("NinjaKunai", 3)
                if newKunai then
                    local sticky = newKunai:WaitForChild("StickyPart", 2)
                    if sticky then
                        local weld = sticky:WaitForChild("StickyWeld", 2)
                        megaSetNetworkOwner:FireServer(sticky, sticky.CFrame)
                        local retry = 0
                        while megaAntikickV2 and weld.Part1 == nil and retry < 20 do
                            megaStickyPartEvent:FireServer(sticky, leg, CFrame.new(0.0490287527, 0.5, 0, 0, 0.00739139877, -0.999561906, -0.998452604, -0.0478846952, 0.0282763243, -0.0476547107, 0.99882561, 0) * CFrame.Angles(0, 0, 0))
                            task.wait(0.1)
                            retry = retry + 1
                        end
                    end
                end
            end
        end

        if megaAntikickV2 then
            task.spawn(function()
                while megaAntikickV2 do
                    pcall(f)
                    task.wait()
                end
            end)
        end
    end
})

AntiTab:AddToggle({ Name = "Anti Kill", Default = false, Callback = function(Value)
	if Value then
		if spamConnection then
			spamConnection:Disconnect()
			spamConnection = nil
		end
		spamConnection = RunService.Heartbeat:Connect(function()
			local character = LocalPlayer.Character
			if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
				local playerName = LocalPlayer.Name
				local spawnedFolder = workspace:FindFirstChild(playerName .. "SpawnedInToys")
				local hamburger = spawnedFolder and spawnedFolder:FindFirstChild("FoodHamburger")
				if not hamburger then
					if os.clock() - lastActionTime > 0.1 then
						ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(
							"FoodHamburger",
							CFrame.new(0, 300, 0),
							Vector3.new(0, 0, 0)
						)
						lastActionTime = os.clock()
					end
				else
					if not isHolding then
						pcall(function()
							hamburger.HoldPart.HoldItemRemoteFunction:InvokeServer(hamburger, character)
						end)
						isHolding = true
					else
						pcall(function()
							hamburger.HoldPart.DropItemRemoteFunction:InvokeServer(
								hamburger,
								CFrame.new(0, 300, 0),
								Vector3.new(0, 0, 0)
							)
						end)
						isHolding = false
					end
				end
			end
		end)
	else
		if spamConnection then
			spamConnection:Disconnect()
			spamConnection = nil
		end
	end
end })

AntiTab:AddToggle({ Name = "Fight Back", Default = false, Callback = function(Value)
	isFlghtBackEnabled = Value
	if isFlghtBackEnabled then
		task.spawn(function()
			while isFlghtBackEnabled do
				local character = LocalPlayer.Character
				if character and character:FindFirstChild("Head") then
					local head = character.Head
					local partOwner = head:FindFirstChild("PartOwner")
					if partOwner and partOwner.Value ~= "" then
						local attacker = Players:FindFirstChild(partOwner.Value)
						if attacker and attacker.Character then
							pcall(function()
								ReplicatedStorage.CharacterEvents.Struggle:FireServer()
								local attackerChar = attacker.Character
								local targetPart = attackerChar:FindFirstChild("Torso") or attackerChar:FindFirstChild("UpperTorso") or attackerChar:FindFirstChild("Head")
								if targetPart then
									if SetNetworkOwner then SetNetworkOwner:FireServer(targetPart, targetPart.CFrame) end
									task.wait()
									local velocity = targetPart:FindFirstChild("l") or Instance.new("BodyVelocity")
									velocity.Name = "l"
									velocity.Velocity = Vector3.new(0, 2000, 0)
									velocity.MaxForce = Vector3.new(0, math.huge, 0)
									velocity.Parent = targetPart
									Debris:AddItem(velocity, 0.5)
								end
							end)
						end
					end
				end
				task.wait(0.1)
			end
		end)
	end
end })

AntiTab:AddToggle({ Name = "Anti Lag", Default = false, Callback = function(Value)
	antiLagT = Value
	if LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("CharacterAndBeamMove") then
		LocalPlayer.PlayerScripts.CharacterAndBeamMove.Disabled = antiLagT
	end
end })

AntiTab:AddToggle({
    Name = "Anti Grab",
    Default = false,
    Callback = function(value)
        megaAntiGrabToggle = value
        if value then
            task.spawn(function()
                while megaAntiGrabToggle do
                    pcall(function() megaStruggle:FireServer(LocalPlayer) end)
                    megaRagdollCount = 0
                    task.wait(0.1)
                end
            end)

            local function AntiGrabT(character)
                local hrp = character:WaitForChild("HumanoidRootPart", 10)
                local hum = character:WaitForChild("Humanoid", 10)
                local head = character:WaitForChild("Head", 10)
                if not (hrp and hum and head) then return end

                head.ChildAdded:Connect(function(child)
                    if child.Name ~= "PartOwner" or not megaAntiGrabToggle then return end
                    hum.Sit = false
                    if megaRagdollCount < 100 then
                        megaRagdollRemote:FireServer(hrp, 0)
                        megaRagdollCount = megaRagdollCount + 1
                    end
                    if not megaAntiGrabProce then
                        megaAntiGrabProce = true
                        hrp.Anchored = true
                        local isHeld = LocalPlayer:WaitForChild("IsHeld", 5)
                        while megaAntiGrabToggle and (not isHeld or not isHeld.Value) do
                            task.wait()
                        end
                        local renderConnection = RunService.RenderStepped:Connect(function()
                            hrp.CFrame = hrp.CFrame + hum.MoveDirection * 0.3
                        end)
                        while megaAntiGrabToggle and isHeld and isHeld.Value do
                            task.wait()
                        end
                        renderConnection:Disconnect()
                        hrp.Anchored = false
                        megaAntiGrabProce = false
                    end
                end)
            end

            if LocalPlayer.Character then
                task.spawn(AntiGrabT, LocalPlayer.Character)
            end
            if megaAntiGrabCharConn then megaAntiGrabCharConn:Disconnect() end
            megaAntiGrabCharConn = LocalPlayer.CharacterAdded:Connect(AntiGrabT)
        else
            if megaAntiGrabCharConn then 
                megaAntiGrabCharConn:Disconnect()
                megaAntiGrabCharConn = nil
            end
        end
    end
})

AntiTab:AddToggle({ Name = "Anti Blobman", Default = false, Callback = function(Value)
	_G.AntiBlob = Value
	task.spawn(function()
		while _G.AntiBlob do
			for _, p in ipairs(Players:GetPlayers()) do
				local st = Workspace:FindFirstChild(p.Name .. "SpawnedInToys")
				if st then
					for _, toy in ipairs(st:GetChildren()) do
						if toy.Name == "CreatureBlobman" then
							pcall(function()
								if toy:FindFirstChild("LeftDetector") then toy.LeftDetector:Destroy() end
								if toy:FindFirstChild("RightDetector") then toy.RightDetector:Destroy() end
							end)
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)
end })

AntiTab:AddToggle({ Name = "Anti Fire", Default = false, Callback = function(Value)
	_G.AntiBurn = Value
	task.spawn(function()
		while _G.AntiBurn do
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("FireLight") then
				local st = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
				local ext = st and st:FindFirstChild("FireExtinguisher")
				if ext then
					ext.ExtinguishPart.Position = char.HumanoidRootPart.Position
				else
					ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("FireExtinguisher", char.HumanoidRootPart.CFrame, Vector3.zero)
				end
			end
			task.wait(0.1)
		end
	end)
end })

AntiTab:AddToggle({ Name = "Anti Void", Default = false, Callback = function(Value)
	if Value then
		Workspace.FallenPartsDestroyHeight = 0/0
	else
		Workspace.FallenPartsDestroyHeight = -100
	end
end })

AntiTab:AddToggle({ Name = "Anti Ragdoll", Default = false, Callback = function(Value)
	_G.AntiRagdoll = Value
	task.spawn(function()
		while _G.AntiRagdoll do
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") and char.Humanoid.PlatformStand then
				char.Humanoid.PlatformStand = false
			end
			task.wait(0.1)
		end
	end)
end })

AntiTab:AddButton({
    Name = "Break PCLD",
    Callback = function()
        local plr = Players.LocalPlayer
        local serverPos = CFrame.new(-272.2197265625, -7.350403785705566, 475.0108947753906)
        
        workspace.FallenPartsDestroyHeight = 0/0

        local storedJoints = {}
        local root
        local conn
        local active = false

        local function breakPCLD()
            local char = plr.Character
            if not char then return end
            root = char:WaitForChild("HumanoidRootPart")

            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("Motor6D") then
                    storedJoints[v] = v.Part0
                    v.Part0 = nil
                end
            end

            root.CFrame = serverPos

            conn = RunService.RenderStepped:Connect(function()
                if root and root.Parent then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            end)
        end

        local function restore()
            if conn then 
                conn:Disconnect() 
                conn = nil 
            end

            for m, p0 in pairs(storedJoints) do
                if m and m.Parent then
                    m.Part0 = p0
                end
            end
            storedJoints = {}
        end

        local function press6()
            active = not active
            if active then
                breakPCLD()
            else
                restore()
            end
        end

        press6()
        task.wait(0.12)
        press6()

        plr.CharacterAdded:Once(function()
            task.wait(0.25)
            press6()
            task.wait(0.12)
            press6()
        end)
        
        OrionLib:MakeNotification({
            Name = "Success",
            Content = "Break PCLD が実行されました",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
    end    
})

-- ------------------------------------------
-- [Tab 3] Aura
-- ------------------------------------------
local AuraTab = Window:MakeTab({ Name = "Aura", Icon = "rbxassetid://7733673987", PremiumOnly = false })
AuraTab:AddSection({Name = "Kill Aura"})
AuraTab:AddToggle({ Name = " Kill Aura (Radius 35)", Default = false, Color = Color3.fromRGB(255,0,0), Callback = function(val)
	bmkAuraEnabled = val
	if val then
		startAura()
		OrionLib:MakeNotification({Name="Kill Aura", Content="Aura ON", Time=2})
	else
		stopAura()
		OrionLib:MakeNotification({Name="Kill Aura", Content="Aura OFF", Time=2})
	end
end })
AuraTab:AddSection({Name = "Camera View"})
AuraTab:AddButton({ Name = "📷 Enable Third Person", Callback = function()
	LocalPlayer.CameraMaxZoomDistance = 5000
	LocalPlayer.CameraMode = Enum.CameraMode.Classic
	OrionLib:MakeNotification({Name="Third Person", Content="Enabled", Time=2})
end })
AuraTab:AddSlider({
	Name = "Max Zoom Distance",
	Min = 100,
	Max = 5000,
	Default = 5000,
	Color = Color3.fromRGB(100,150,255),
	Increment = 100,
	ValueName = "Studs",
	Callback = function(v) LocalPlayer.CameraMaxZoomDistance = v end
})

-- ------------------------------------------
-- [Tab 4] Blobman
-- ------------------------------------------
local BlobmanTab = Window:MakeTab({ Name = "Blobman", Icon = "rbxassetid://7733916988", PremiumOnly = false })
BlobmanTab:AddSection({Name = "Target Settings"})
local targetDropdown = BlobmanTab:AddDropdown({
	Name = "Select Target",
	Default = "",
	Options = getPlayerList(),
	Callback = function(val)
		selectedActionTargetName = playerMap[val] or ""
	end
})
BlobmanTab:AddButton({
	Name = " Refresh Player List",
	Callback = function()
		targetDropdown:Refresh(getPlayerList(), true)
		OrionLib:MakeNotification({Name="Refresh List", Content="Player list updated", Time=2})
	end
})
BlobmanTab:AddToggle({ Name = "Blobman Kick", Default = false, Callback = function(v)
	levitateRunning = v
	if not v then return end
	local target = Players:FindFirstChild(selectedActionTargetName)
	if target and target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local blobman = nil
		local spawned = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
		if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
		if blobman then
			local lDet = blobman:FindFirstChild("LeftDetector")
			local rDet = blobman:FindFirstChild("RightDetector")
			local hasValidWeld = (lDet and (lDet:FindFirstChild("LeftWeld") or lDet:FindFirstChildWhichIsA("Weld") or lDet:FindFirstChildWhichIsA("JointInstance") or lDet:FindFirstChild("RigidConstraint"))) or (rDet and (rDet:FindFirstChild("RightWeld") or rDet:FindFirstChildWhichIsA("Weld") or rDet:FindFirstChildWhichIsA("JointInstance") or rDet:FindFirstChild("RigidConstraint")))
			if not hasValidWeld then
				pcall(function() ReplicatedStorage.MenuToys.DestroyToy:FireServer(blobman) end)
				blobman = nil
				task.wait(0.3)
			end
		end
		if not blobman then
			local mt = ReplicatedStorage:FindFirstChild("MenuToys")
			local st = mt and mt:FindFirstChild("SpawnToyRemoteFunction")
			if st then
				local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local spawnCF = myRoot and (myRoot.CFrame + Vector3.new(0, 5, 0)) or CFrame.new(0, 50, 0)
				st:InvokeServer("CreatureBlobman", spawnCF, Vector3.zero)
				task.wait(0.5)
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
			local scriptObj = blobman:FindFirstChild("BlobmanSeatAndOwnerScript") or blobman:FindFirstChild("BlobmanSeatAndOwnerScript[old]")
			local grabRemote = (scriptObj and scriptObj:FindFirstChild("CreatureGrab")) or blobman:FindFirstChild("CreatureGrab", true)
			local dropRemote = (scriptObj and scriptObj:FindFirstChild("CreatureDrop")) or blobman:FindFirstChild("CreatureDrop", true)
			local lDet = blobman:FindFirstChild("LeftDetector")
			local rDet = blobman:FindFirstChild("RightDetector")
			local lWeld = lDet and (lDet:FindFirstChild("LeftWeld") or lDet:FindFirstChildWhichIsA("Weld") or lDet:FindFirstChildWhichIsA("JointInstance") or lDet:FindFirstChild("RigidConstraint"))
			local rWeld = rDet and (rDet:FindFirstChild("RightWeld") or rDet:FindFirstChildWhichIsA("Weld") or rDet:FindFirstChildWhichIsA("JointInstance") or rDet:FindFirstChild("RigidConstraint"))
			local seat = blobman:FindFirstChild("VehicleSeat")
			local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
			if seat and hum then
				if seat.Occupant ~= hum then
					LocalPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
					seat:Sit(hum)
					task.wait(0.3)
				end
			end
			local GE = ReplicatedStorage:FindFirstChild("GrabEvents")
			if GE and grabRemote and dropRemote and ((lDet and lWeld) or (rDet and rWeld)) then
				OrionLib:MakeNotification({ Name = "Execute", Content = "Blobman Kick Loop", Time = 3 })
				task.spawn(function()
					local blobRoot = blobman:FindFirstChild("HumanoidRootPart") or blobman.PrimaryPart
					local SavedPos = blobRoot.CFrame
					local Det = rDet or lDet
					local Weld = rWeld or lWeld
					local bringStart = tick()
					while tick() - bringStart < 0.35 do
						if not levitateRunning or not blobman or not blobman.Parent then break end
						if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
							local tRoot = target.Character.HumanoidRootPart
							blobRoot.CFrame = tRoot.CFrame
							blobRoot.AssemblyLinearVelocity = Vector3.zero
							pcall(function()
								if Det then grabRemote:FireServer(Det, tRoot, Weld) end
								local CGL = GE:FindFirstChild("CreateGrabLine")
								local SNO = GE:FindFirstChild("SetNetworkOwner")
								if CGL then CGL:FireServer(tRoot, Vector3.zero, tRoot.Position, false) end
								if SNO then SNO:FireServer(tRoot, blobRoot.CFrame) end
							end)
						end
						RunService.Heartbeat:Wait()
					end
					if blobRoot then
						blobRoot.CFrame = SavedPos
						blobRoot.AssemblyLinearVelocity = Vector3.zero
						task.wait(0.05)
					end
					while levitateRunning and blobman and blobman.Parent do
						if not target or not target.Parent or not target.Character then break end
						local tChar = target.Character
						local tRoot = tChar:FindFirstChild("HumanoidRootPart")
						local tHum = tChar:FindFirstChild("Humanoid")
						if tRoot and tHum and tHum.Health > 0 and blobRoot then
							blobRoot.CFrame = SavedPos
							blobRoot.AssemblyLinearVelocity = Vector3.zero
							local lockPos = SavedPos * CFrame.new(0, 23, 0)
							tRoot.CFrame = lockPos
							tRoot.AssemblyLinearVelocity = Vector3.zero
							tRoot.AssemblyAngularVelocity = Vector3.zero
							pcall(function()
								tHum.PlatformStand = true
								tHum.Sit = true
								local SNO = GE:FindFirstChild("SetNetworkOwner")
								if SNO then SNO:FireServer(tRoot, lockPos) end
								local currentWeld = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChildWhichIsA("JointInstance") or Det:FindFirstChild("RigidConstraint")
								if currentWeld then dropRemote:FireServer(currentWeld) end
								local DGL = GE:FindFirstChild("DestroyGrabLine")
								local CGL = GE:FindFirstChild("CreateGrabLine")
								if DGL then DGL:FireServer(tRoot) end
								if Det then grabRemote:FireServer(Det, tRoot, Weld) end
								if CGL then CGL:FireServer(tRoot, Vector3.zero, tRoot.Position, false) end
							end)
						else
							if blobRoot then
								blobRoot.CFrame = SavedPos
								blobRoot.AssemblyLinearVelocity = Vector3.zero
							end
						end
						RunService.Heartbeat:Wait()
					end
					if blobRoot then
						blobRoot.CFrame = SavedPos
						blobRoot.AssemblyLinearVelocity = Vector3.zero
					end
				end)
			else
				levitateRunning = false
				local missing = {}
				if not GE then table.insert(missing, "GrabEvents") end
				if not grabRemote then table.insert(missing, "CreatureGrab") end
				if not dropRemote then table.insert(missing, "CreatureDrop") end
				if not (lDet or rDet) then table.insert(missing, "Detector") end
				if not (lWeld or rWeld) then table.insert(missing, "Weld/Constraint") end
				OrionLib:MakeNotification({ Name = "Error", Content = "Missing: " .. table.concat(missing, ", "), Time = 5 })
			end
		else
			levitateRunning = false
			OrionLib:MakeNotification({ Name = "Error", Content = "Blobman not found (Please spawn the toy)", Time = 3 })
		end
	end
end })
BlobmanTab:AddButton({ Name = " Stop Blobman Kick", Callback = function()
	if levitateRunning then
		levitateRunning = false
		OrionLib:MakeNotification({ Name = "Stop", Content = "Blobman Kick stopped", Time = 3 })
	else
		OrionLib:MakeNotification({ Name = "Info", Content = "Blobman Kick is not running", Time = 3 })
	end
end })
BlobmanTab:AddToggle({ Name = "drift kick", Default = false, Callback = function(v)
	orbitRunning = v
	currentLoopId = currentLoopId + 1
	local myLoopId = currentLoopId
	if not v then return end
	local target = Players:FindFirstChild(selectedActionTargetName)
	if target and target ~= LocalPlayer then
		local blobman = nil
		local spawned = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
		if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
		if not blobman then
			local mt = ReplicatedStorage:FindFirstChild("MenuToys")
			local st = mt and mt:FindFirstChild("SpawnToyRemoteFunction")
			if st then
				local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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
			local scriptObj = blobman:FindFirstChild("BlobmanSeatAndOwnerScript") or blobman:FindFirstChild("BlobmanSeatAndOwnerScript[old]")
			local grabRemote = scriptObj and scriptObj:FindFirstChild("CreatureGrab") or blobman:FindFirstChild("CreatureGrab", true)
			local dropRemote = scriptObj and scriptObj:FindFirstChild("CreatureDrop") or blobman:FindFirstChild("CreatureDrop", true)
			local lDet = blobman:FindFirstChild("LeftDetector")
			local rDet = blobman:FindFirstChild("RightDetector")
			local lWeld = lDet and (lDet:FindFirstChild("LeftWeld") or lDet:FindFirstChildWhichIsA("Weld") or lDet:FindFirstChildWhichIsA("JointInstance") or lDet:FindFirstChild("RigidConstraint"))
			local rWeld = rDet and (rDet:FindFirstChild("RightWeld") or rDet:FindFirstChildWhichIsA("Weld") or rDet:FindFirstChildWhichIsA("JointInstance") or rDet:FindFirstChild("RigidConstraint"))
			local seat = blobman:FindFirstChild("VehicleSeat")
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
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
				OrionLib:MakeNotification({ Name = "実行", Content = "drift kick を開始します (自動リスポーン追跡ON)", Time = 3 })
				task.spawn(function()
					local blobRoot = blobman:FindFirstChild("HumanoidRootPart") or blobman.PrimaryPart
					local Det = rDet or lDet
					local Weld = rWeld or lWeld
					while orbitRunning do
						if myLoopId ~= currentLoopId then break end
						if not target or not target.Parent then break end
						local tChar = target.Character
						local tHum = tChar and tChar:FindFirstChild("Humanoid")
						local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
						if tChar and tRoot and tHum and tHum.Health > 0 then
							local bringStart = tick()
							while tick() - bringStart < 0.35 do
								if myLoopId ~= currentLoopId or not orbitRunning or not blobman or not blobman.Parent then break end
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
							if myLoopId ~= currentLoopId or not orbitRunning or not blobman or not blobman.Parent then break end
							tChar = target.Character
							tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
							tHum = tChar and tChar:FindFirstChild("Humanoid")
							if tChar and tRoot and tHum and tHum.Health > 0 then
								local SavedPos = tRoot.CFrame
								local targetCenterCFrame = SavedPos + Vector3.new(0, 30, 0)
								local lastTime = tick()
								local lastDropTime = tick()
								local dropCount = 0
								while orbitRunning and blobman and blobman.Parent do
									if myLoopId ~= currentLoopId then break end
									if not target or not target.Parent then break end
									tChar = target.Character
									tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
									tHum = tChar and tChar:FindFirstChild("Humanoid")
									if not tChar or not tRoot or not tHum or tHum.Health <= 0 then break end
									if dropCount < 2 and (tick() - lastDropTime) > 0.8 then
										dropCount = dropCount + 1
										pcall(function()
											local currentWeld = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChildWhichIsA("JointInstance") or Det:FindFirstChild("RigidConstraint")
											if currentWeld then dropRemote:FireServer(currentWeld) end
											GE.DestroyGrabLine:FireServer(tRoot)
										end)
										blobRoot.CFrame = SavedPos
										blobRoot.AssemblyLinearVelocity = Vector3.zero
										RunService.Heartbeat:Wait()
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
										lastTime = tick()
										lastDropTime = tick()
										continue
									end
									if tRoot and tHum and tHum.Health > 0 and blobRoot then
										local currentTime = tick()
										local dt = currentTime - lastTime
										lastTime = currentTime
										driftAngle = driftAngle + (driftSpeed * dt)
										local offsetX = math.cos(driftAngle) * driftRadius
										local offsetZ = math.sin(driftAngle) * driftRadius
										local blobPos = targetCenterCFrame.Position + Vector3.new(offsetX, driftHeightOffset, offsetZ)
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
											local currentWeld = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChildWhichIsA("JointInstance") or Det:FindFirstChild("RigidConstraint")
											if currentWeld then dropRemote:FireServer(currentWeld) end
											GE.DestroyGrabLine:FireServer(tRoot)
											if Det then grabRemote:FireServer(Det, tRoot, Weld) end
											GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, targetCenterCFrame.Position, false)
										end)
									else
										break
									end
									RunService.Heartbeat:Wait()
								end
								if not orbitRunning or myLoopId ~= currentLoopId then
									if blobRoot and SavedPos then
										pcall(function()
											local currentWeld = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChildWhichIsA("JointInstance") or Det:FindFirstChild("RigidConstraint")
											if currentWeld then dropRemote:FireServer(currentWeld) end
											if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
												GE.DestroyGrabLine:FireServer(target.Character.HumanoidRootPart)
											end
										end)
										blobRoot.CFrame = SavedPos
										blobRoot.AssemblyLinearVelocity = Vector3.zero
									end
									break
								end
							end
						end
						RunService.Heartbeat:Wait()
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
end })
BlobmanTab:AddSection({Name = "Blobman Features"})
BlobmanTab:AddToggle({ Name = "Blobman kill (20 Stack Mount)", Default = false, Callback = function(state)
	bm_isRunning = state
	local targetPlayer = Players:FindFirstChild(selectedActionTargetName)
	if state then
		if not targetPlayer then
			OrionLib:MakeNotification({Name="Error", Content="Select a target first", Time=2})
			bm_isRunning = false
			return
		end
		if bm_loopConn then bm_loopConn:Disconnect() end
		if bm_grabConn then bm_grabConn:Disconnect() end
		if bm_mountConn then bm_mountConn:Disconnect() end
		pcall(function()
			if bm_currentBlobman then bm_currentBlobman:Destroy() end
		end)
		task.wait(0.05)
		if not bm_SpawnBlobman() then
			OrionLib:MakeNotification({Name="Failed", Content="Failed to spawn Blobman", Time=2})
			bm_isRunning = false
			return
		end
		bm_SetupRespawnMonitor(targetPlayer)
		bm_StartContinuousGrab(targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") or nil)
		bm_KeepMounted()
		bm_angle = 0
		bm_loopConn = RunService.Heartbeat:Connect(bm_ProcessCycle)
		OrionLib:MakeNotification({Name="Started", Content="Mounted at 20 studs high", Time=2})
	else
		if bm_loopConn then bm_loopConn:Disconnect() end
		if bm_grabConn then bm_grabConn:Disconnect() end
		if bm_respawnConn then bm_respawnConn:Disconnect() end
		if bm_localRespawnConn then bm_localRespawnConn:Disconnect() end
		if bm_mountConn then bm_mountConn:Disconnect() end
		pcall(function()
			if bm_currentBlobman then bm_currentBlobman:Destroy() end
		end)
		bm_isRunning = false
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.PlatformStand = false
				hum.Jump = true
			end
		end
		OrionLib:MakeNotification({Name="Stopped", Content="Blobman removed and normal state restored", Time=2})
	end
end })
BlobmanTab:AddToggle({ Name = "Auto Kill All", Default = false, Color = Color3.fromRGB(255,0,0), Callback = function(val)
	autoKillAllEnabled = val
	if val then
		OrionLib:MakeNotification({Name="Auto Kill", Content="Auto Kill All ON", Time=2})
		task.spawn(function()
			while autoKillAllEnabled do
				local myHRP = HRP()
				if myHRP and cachedBlobman then
					for _, p in ipairs(Players:GetPlayers()) do
						if not autoKillAllEnabled then break end
						if p == LocalPlayer then continue end
						if ExcludeFriends and LocalPlayer:IsFriendsWith(p.UserId) then continue end
						local char = p.Character
						local pHRP = char and char:FindFirstChild("HumanoidRootPart")
						local hum = char and char:FindFirstChildOfClass("Humanoid")
						if pHRP and hum and hum.Health > 0 then
							myHRP.CFrame = pHRP.CFrame * CFrame.new(0, 2, -3)
							startThreads(p, p.UserId)
							task.wait(0.3)
							stopThreads(p.UserId)
						end
					end
				else
					if not cachedBlobman and autoKillAllEnabled then
						OrionLib:MakeNotification({Name="Error", Content="Please sit on Blobman", Time=2})
						autoKillAllEnabled = false
						break
					end
				end
				task.wait(0.5)
			end
		end)
	else
		OrionLib:MakeNotification({Name="Auto Kill", Content="Auto Kill All OFF", Time=2})
		for _, p in ipairs(Players:GetPlayers()) do
			stopThreads(p.UserId)
		end
	end
end })
BlobmanTab:AddButton({ Name = "Kick All", Callback = KickAll })
BlobmanTab:AddToggle({ Name = "Exclude Friends", Default = false, Callback = function(Value) ExcludeFriends = Value end })

-- ------------------------------------------
-- [Tab 5] Loop (Replaces Reskill)
-- ------------------------------------------
local LoopTab = Window:MakeTab({ Name = "Loop", Icon = "rbxassetid://7743872758", PremiumOnly = false })
local LoopSection1 = LoopTab:AddSection({ Name = "Player Selection" })
local LoopSection2 = LoopTab:AddSection({ Name = "Kill Settings" })
local LoopSelectedLabel = LoopSection1:AddLabel("Selected: None")

local function UpdateLoopSelectedList()
	if #loopSelectedPlayers == 0 then
		LoopSelectedLabel:Set("Selected: None")
	else
		LoopSelectedLabel:Set("Selected: " .. table.concat(loopSelectedPlayers, ", "))
	end
end

local function UpdateLoopPlayerList()
	local options = {}
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local alreadySelected = false
			for _, selected in ipairs(loopSelectedPlayers) do
				if selected == player.Name then
					alreadySelected = true
					break
				end
			end
			if not alreadySelected then
				table.insert(options, player.Name .. " (" .. player.DisplayName .. ")")
			end
		end
	end
	table.sort(options)
	return options
end

local LoopPlayerDropdown = LoopSection1:AddDropdown({
	Name = "Select Player",
	Default = "",
	Options = UpdateLoopPlayerList(),
	Callback = function(value)
		local playerName = string.split(value, " ")[1]
		local player = Players:FindFirstChild(playerName)
		if player and player ~= LocalPlayer then
			local found = false
			for _, p in ipairs(loopSelectedPlayers) do
				if p == playerName then
					found = true
					break
				end
			end
			if not found then
				table.insert(loopSelectedPlayers, playerName)
				UpdateLoopSelectedList()
			end
		end
	end
})

LoopSection1:AddButton({
	Name = "Reset Selection",
	Callback = function()
		loopSelectedPlayers = {}
		UpdateLoopSelectedList()
	end
})

LoopSection2:AddToggle({
	Name = "Reskill",
	Default = false,
	Callback = function(value)
		isKilling = value
		if value then
			task.spawn(function()
				while isKilling do
					for i = #loopSelectedPlayers, 1, -1 do
						if not isKilling then break end
						local playerName = loopSelectedPlayers[i]
						local targetPlayer = Players:FindFirstChild(playerName)
						if targetPlayer then
							if IsValidTarget(targetPlayer) then
								KillPlayer(targetPlayer)
							end
						else
							table.remove(loopSelectedPlayers, i)
							UpdateLoopSelectedList()
						end
					end
					task.wait(0.2)
				end
			end)
		end
	end
})

-- ------------------------------------------
-- [Tab 6] Toy mod (Replaces Object Aura)
-- ------------------------------------------
local ToyTab = Window:MakeTab({ Name = "Toy mod", Icon = "rbxassetid://8997388430"})

local PlayerDropdown = ToyTab:AddDropdown({ Name = "Select Target", Default = "Me (@Me)", Options = GetCosmosPlayerList(), Callback = function(V)
    if V == "Me (@Me)" then cosmosTargetPlayer = LocalPlayer
    else
        local name = V:match("%@(.*)%)")
        cosmosTargetPlayer = Players:FindFirstChild(name)
    end
end })

ToyTab:AddButton({ Name = "Refresh Player List", Callback = function() PlayerDropdown:Refresh(GetCosmosPlayerList(), true) end })

ToyTab:AddSection({Name = "General Settings"})
ToyTab:AddDropdown({ Name = "Object to Sync", Default = "FireworkSparkler", Options = {"FireworkSparkler", "PoopPile", "PalletLightBrown", "GlassBoxGray"}, Callback = function(V) targetObjectName = V; ClearSync() end })
ToyTab:AddToggle({ Name = "Auto Sync", Default = false, Callback = function(V) autoSyncEnabled = V end })
ToyTab:AddDropdown({ Name = "Shape", Default = "Wing", Options = {"Wing", "Ring", "Star", "Angel"}, Callback = function(V) sparklerConfig.CurrentShape = V end })
ToyTab:AddSlider({ Name = "Base Speed", Min = 0, Max = 100, Default = 18, Callback = function(V) sparklerConfig.Speed = V end })
ToyTab:AddSlider({ Name = "Base Radius (Wing/Ring/Star)", Min = 1, Max = 100, Default = 22, Callback = function(V) sparklerConfig.Radius = V end })
ToyTab:AddSlider({ Name = "Base Height (Wing/Ring/Star)", Min = -50, Max = 100, Default = 6, Callback = function(V) sparklerConfig.Height = V end })

ToyTab:AddSection({Name = "Wing & Angel Adjustments"})
ToyTab:AddSlider({ Name = "Flap Strength", Min = 0, Max = 20, Default = 2.5, Increment = 0.5, Callback = function(V) sparklerConfig.FlapStrength = V end })
ToyTab:AddSlider({ Name = "Wing Spread (Width)", Min = 0, Max = 10, Default = 2.2, Increment = 0.1, Callback = function(V) sparklerConfig.WingSpread = V end })

ToyTab:AddSection({Name = "Angel Specific Adjustments"})
ToyTab:AddSlider({ Name = "Angel Ring Radius", Min = 1, Max = 150, Default = 40, Callback = function(V) sparklerConfig.AngelRingRadius = V end })
ToyTab:AddSlider({ Name = "Angel Ring Height", Min = -50, Max = 100, Default = 19, Callback = function(V) sparklerConfig.AngelRingHeight = V end })
ToyTab:AddSlider({ Name = "Angel Ring Speed", Min = 0, Max = 100, Default = 18, Callback = function(V) sparklerConfig.AngelRingSpeed = V end })

ToyTab:AddSection({Name = "Star Specific Adjustments"})
ToyTab:AddSlider({ Name = "Star Bounce Height", Min = 0, Max = 30, Default = 3, Increment = 0.5, Callback = function(V) sparklerConfig.StarBounce = V end })


-- ------------------------------------------
-- [Tab 7] Teleport (Minimap)
-- ------------------------------------------
local TeleportTab = Window:MakeTab({ Name = "Teleport", Icon = "rbxassetid://7733992829" })
TeleportTab:AddToggle({ Name = "Toggle Minimap", Default = false, Callback = function(v) MapFrame.Visible = v end })
TeleportTab:AddButton({ Name = "Reset View", Callback = function() mapOffset = Vector3.zero; lastScanPos = Vector3.new(0,0,0) end })
TeleportTab:AddParagraph("Controls", "- Quick Swipe: Move UI\n- Long Press (0.25s) & Swipe: Scroll Map\n- Tap: Teleport\n- 2-Finger Pinch: Zoom In/Out")
TeleportTab:AddSection({ Name = "Player Teleport" })
local TeleportTargetDropdown = TeleportTab:AddDropdown({ Name = "Select Target", Default = "", Options = getPlayerList(), Callback = function(Value)
	selectedTeleportTargetName = playerMap[Value] or ""
end })
TeleportTab:AddButton({ Name = "Refresh Player List", Callback = function()
	TeleportTargetDropdown:Refresh(getPlayerList(), true)
end })
TeleportTab:AddButton({ Name = "Execute Teleport", Callback = function()
	if selectedTeleportTargetName and selectedTeleportTargetName ~= "" then
		local targetPlayer = Players:FindFirstChild(selectedTeleportTargetName)
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if myRoot then
				myRoot.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
				OrionLib:MakeNotification({ Name = "Teleport", Content = targetPlayer.DisplayName .. " teleported successfully", Time = 2 })
			end
		else
			OrionLib:MakeNotification({ Name = "Error", Content = "Target not found or not spawned yet", Time = 3 })
		end
	else
		OrionLib:MakeNotification({ Name = "Error", Content = "Please select a teleport target first", Time = 2 })
	end
end })

-- ------------------------------------------
-- [Tab 8] Visuals (ESP)
-- ------------------------------------------
local VisualsTab = Window:MakeTab({ Name = "Visuals", Icon = "rbxassetid://7733774602", PremiumOnly = false })
VisualsTab:AddToggle({ Name = "Enable ESP", Default = false, Callback = function(v)
	ESP_Settings.Enabled = v
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("Head") then
			local ui = p.Character.Head:FindFirstChild("ESP_UI")
			if ui then ui.Enabled = v end
		end
	end
end })
VisualsTab:AddToggle({ Name = "Show Red Lines", Default = false, Callback = function(v)
	ESP_Settings.Lines = v
end })

-- ------------------------------------------
-- 5. Background Processes & Initialization
-- ------------------------------------------
task.spawn(function()
	task.wait(1)
	if LocalPlayer.Character then setupAntiExplosion(LocalPlayer.Character) end
	pcall(initRenderStep)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(1)
	setupAntiExplosion(char)
end)

for _, player in pairs(Players:GetPlayers()) do
	pcall(function() CreateTracer(player) end)
	pcall(function() CreateNameTag(player) end)
end

Players.PlayerAdded:Connect(function(p)
	pcall(function() CreateTracer(p) end)
	pcall(function() CreateNameTag(p) end)
	task.wait(0.5)
	if LoopPlayerDropdown then LoopPlayerDropdown:Refresh(UpdateLoopPlayerList(), true) end
    if PlayerDropdown then PlayerDropdown:Refresh(GetCosmosPlayerList(), true) end
end)

Players.PlayerRemoving:Connect(function()
	task.wait(0.5)
	if LoopPlayerDropdown then LoopPlayerDropdown:Refresh(UpdateLoopPlayerList(), true) end
    if PlayerDropdown then PlayerDropdown:Refresh(GetCosmosPlayerList(), true) end
end)

SendChat("Ham H,ub")
OrionLib:Init()