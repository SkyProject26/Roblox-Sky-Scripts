getgenv().key = "Xana"
local v_u_4_ = loadstring(game:HttpGet("https://raw.githubusercontent.com/BlizTBr/scripts/main/Orion%20X"))()
local v_u_5_ = game:GetService("Players")
local v_u_6_ = game:GetService("Debris")
local v_u_7_ = game:GetService("Workspace")
local v8_ = game:GetService("Lighting")
local v_u_9_ = game:GetService("TweenService")
local v_u_10_ = game:GetService("UserInputService")
local v_u_11_ = game:GetService("ReplicatedStorage")
local v12_ = game:GetService("ReplicatedFirst")
local v_u_13_ = game:GetService("ContextActionService")
local v_u_14_ = game:GetService("RunService")
local v_u_15_ = game:GetService("VirtualUser")
local v16_ = v_u_11_:WaitForChild("CharacterEvents")
local v_u_17_ = v_u_5_.LocalPlayer
local v18_ = v_u_17_:WaitForChild("PlayerGui")
v_u_17_:GetMouse()
local v_u_19_ = v_u_7_:WaitForChild(v_u_17_.Name .. "SpawnedInToys")
local v_u_20_ = v_u_17_:WaitForChild("InPlot")
local v21_ = v_u_17_:WaitForChild("ToysLimitCap")
SpawnToyRF = v_u_11_:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
DeleteToyRE = v_u_11_:WaitForChild("MenuToys"):WaitForChild("DestroyToy")
BuyToy = v_u_11_:WaitForChild("MenuToys"):WaitForChild("BuyToyRemoteFunction")
BombEvents = v_u_11_:WaitForChild("BombEvents")
typeAnimation = v12_.Typing.Type
flailAnimation = v12_.ThrowPlayers.Flail
local v_u_22_ = v_u_11_:WaitForChild("GrabEvents"):WaitForChild("CreateGrabLine")
local v_u_23_ = v_u_11_:WaitForChild("GrabEvents"):WaitForChild("DestroyGrabLine")
local v_u_24_ = v_u_11_:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
v_u_11_:WaitForChild("GrabEvents"):WaitForChild("ExtendGrabLine")
local v_u_25_ = v16_:WaitForChild("RagdollRemote")
local v_u_26_ = v_u_11_:WaitForChild("DataEvents"):WaitForChild("UpdateLineColorsEvent")
local v_u_27_ = v_u_17_:WaitForChild("IsHeld")
local v28_ = v_u_17_:WaitForChild("PlayerScripts")
local v_u_29_ = nil
local v_u_30_ = v16_:WaitForChild("Struggle")
anticreatelinelocalscript = v28_:WaitForChild("CharacterAndBeamMove")
v_u_17_.Changed:Connect(
    function(p31_)
        if p31_ == "userId" or p31_ == "UserId" then
            while true do
            end
        else
            return
        end
    end
)
local function v_u_33_(p32_)
    -- upvalues: (ref) v_u_4_
    v_u_4_:MakeNotification(
        {
            ["Name"] = "Bliz_T HUB",
            ["Content"] = p32_,
            ["Image"] = "rbxassetid://16570630989",
            ["Time"] = 5
        }
    )
end
function IsSolara()
    if getexecutorname then
        local v34_ = getexecutorname()
        if v34_ and string.find(v34_, "Solara") then
            return true
        end
    end
end
IsUsingSolara = IsSolara()
if IsUsingSolara then
    print("new proximity promp created!")
    getgenv().fireproximityprompt = function(p35_)
        if p35_.Name ~= "ProximityPrompt" then
            error("retard: " .. Obj.Name)
        else
            local v36_ = p35_.HoldDuration
            local v37_ = p35_.MaxActivationDistance
            p35_.MaxActivationDistance = math.huge
            p35_.HoldDuration = 0
            p35_:InputHoldBegin()
            p35_:InputHoldEnd()
            p35_.HoldDuration = v36_
            p35_.MaxActivationDistance = v37_
        end
    end
end
local v_u_38_ = {}
function checkadminData(p39_)
    -- upvalues: (ref) v_u_38_
    if table.find(v_u_38_, p39_) then
        return true
    end
end
spawnToyThread =
    coroutine.create(
    function()
        while true do
            repeat
                local v40_ = coroutine.yield()
            until typeof(v40_) == "table"
            SpawnToyRF:InvokeServer(unpack(v40_))
        end
    end
)
function SpawnToy(p41_)
    coroutine.resume(spawnToyThread, p41_)
end
local function v_u_46_(p42_, p43_)
    if typeof(p42_) == "Instance" and p42_.Parent then
        local v44_ = p42_:GetAttribute("LastTimeRankUpdate")
        if v44_ and (not v44_ or os.clock() - v44_ < 300) then
            local _ = p42_.GetAttribute
        else
            local v45_ = p42_:GetRankInGroup(p43_)
            if v45_ == 255 then
                p42_:SetAttribute("Rank", "Leader")
            elseif v45_ == 4 then
                p42_:SetAttribute("Rank", "High Rank Admin")
            elseif v45_ == 3 then
                p42_:SetAttribute("Rank", "Low Rank Admin")
            elseif v45_ == 2 then
                p42_:SetAttribute("Rank", "Goon")
            elseif v45_ == 0 or v45_ == 1 then
                p42_:SetAttribute("Rank", "Common")
            end
            p42_:SetAttribute("LastTimeRankUpdate", os.clock())
        end
    end
end
local function v_u_51_(p47_)
    -- upvalues: (ref) v_u_5_, (ref) v_u_46_, (ref) v_u_38_
    if typeof(p47_) ~= "Instance" then
        p47_ = nil
    elseif p47_:IsA("Model") and p47_:FindFirstChildOfClass("Humanoid") and v_u_5_:GetPlayerFromCharacter(p47_) then
        p47_ = v_u_5_:GetPlayerFromCharacter(p47_)
    elseif not p47_:IsA("Player") then
        return
    end
    local v48_ = false
    if p47_ then
        local v49_ = v_u_46_(p47_, 16168861)
        local v50_ =
            (v49_ == "Leader" or (v49_ == "High Rank Admin" or (v49_ == "Low Rank Admin" or v49_ == "Goon"))) and true or
            v48_
        if checkadminData(p47_.Name) and not v_u_38_[p47_.Name].Protection then
            v50_ = false
        end
        return v50_
    end
end
function tableAlphabeticOrder(p52_, p53_)
    return p52_:lower() < p53_:lower()
end
local function v_u_61_(p54_)
    -- upvalues: (ref) v_u_5_, (ref) v_u_17_
    local v55_ = v_u_5_
    local v56_, v57_, v58_ = pairs(v55_:GetPlayers())
    local v59_ = {}
    while true do
        local v60_
        v58_, v60_ = v56_(v57_, v58_)
        if v58_ == nil then
            break
        end
        if v60_.UserId ~= v_u_17_.UserId then
            table.insert(v59_, v60_.Name .. " " .. "(" .. v60_.DisplayName .. ")")
        end
    end
    table.sort(v59_, tableAlphabeticOrder)
    p54_:Refresh(v59_, true)
end
local v_u_62_ = {}
local v_u_63_ = {}
local function v_u_71_(p64_, p65_)
    local v66_, v67_, v68_ = pairs(p65_)
    local v69_ = {}
    while true do
        local v70_
        v68_, v70_ = v66_(v67_, v68_)
        if v68_ == nil then
            break
        end
        if typeof(v70_) == "string" then
            table.insert(v69_, v70_)
        end
    end
    p64_:Refresh(v69_, true)
end
local function v_u_79_(p72_)
    -- upvalues: (ref) v_u_5_
    local v73_ = v_u_5_
    local v74_, v75_, v76_ = pairs(v73_:GetPlayers())
    local v77_ = {}
    while true do
        local v78_
        v76_, v78_ = v74_(v75_, v76_)
        if v76_ == nil then
            break
        end
        table.insert(v77_, v78_.Name .. " " .. "(" .. v78_.DisplayName .. ")")
    end
    table.sort(v77_, tableAlphabeticOrder)
    p72_:Refresh(v77_, true)
end
function lookAt(p80_, p81_)
    local v82_ = (p81_ - p80_).Unit
    local v83_ = v82_:Cross((Vector3.new(0, 1, 0)))
    local v84_ = v83_:Cross(v82_)
    return CFrame.fromMatrix(p80_, v83_, v84_)
end
local function v_u_88_(p85_, p86_, _)
    -- upvalues: (ref) v_u_17_
    if p85_ == "Spawn Toy (TAB)" and p86_ == Enum.UserInputState.Begin then
        local v87_ = {
            _G.SelectedToy,
            v_u_17_.Character.CamPart.CFrame,
            Vector3.new(0, v_u_17_.Character.CamPart.Orientation.Y, 0)
        }
        SpawnToyRF:InvokeServer(unpack(v87_))
    end
end
function teleportfunc()
    -- upvalues: (ref) v_u_17_, (ref) v_u_7_
    local v89_ = _G.ControllingCreature or v_u_17_.Character
    local v90_ = _G.ControllingCreature and "Head" or (v_u_17_.Character and "CamPart" or nil)
    local v91_, v92_ =
        v_u_7_:FindPartOnRayWithIgnoreList(
        Ray.new(v89_[v90_].Position, v_u_17_.Character.CamPart.CFrame.lookVector * 5000),
        {
            v89_
        }
    )
    if v91_ then
        v89_.HumanoidRootPart.CFrame = CFrame.new(v92_.X, v92_.Y + 5, v92_.Z)
    end
end
local function v_u_95_(p93_, p94_, _)
    if p93_ == "Teleport(Z)" and p94_ == Enum.UserInputState.Begin then
        teleportfunc()
    end
end
local function v_u_97_(p96_)
    -- upvalues: (ref) v_u_63_
    if table.find(v_u_63_, p96_) then
        return true
    end
end
local v_u_98_ = nil
local v_u_99_ = nil
Noclip2 = nil
Clip2 = nil
local function v_u_105_()
    -- upvalues: (ref) v_u_98_, (ref) v_u_99_, (ref) v_u_14_
    if not v_u_98_ then
        v_u_99_ = false
        local function v104_()
            -- upvalues: (ref) v_u_99_
            if v_u_99_ == false and game.Players.LocalPlayer.Character ~= nil then
                local v100_, v101_, v102_ = pairs(game.Players.LocalPlayer.Character:GetChildren())
                while true do
                    local v103_
                    v102_, v103_ = v100_(v101_, v102_)
                    if v102_ == nil then
                        break
                    end
                    if v103_:IsA("BasePart") and (v103_.CanCollide and v103_.Name ~= floatName) then
                        v103_.CanCollide = false
                    end
                end
            end
            wait(0.21)
        end
        v_u_98_ = v_u_14_.Stepped:Connect(v104_)
    end
end
local function v_u_106_()
    -- upvalues: (ref) v_u_98_, (ref) v_u_99_
    if not _G.NoclipToggle then
        if v_u_98_ then
            v_u_98_:Disconnect()
            v_u_98_ = nil
        end
        v_u_99_ = true
    end
end
function countToys(p107_)
    -- upvalues: (ref) v_u_19_
    local v108_ = v_u_19_
    local v109_, v110_, v111_ = pairs(v108_:GetChildren())
    local v112_ = 0
    while true do
        local v113_
        v111_, v113_ = v109_(v110_, v111_)
        if v111_ == nil then
            break
        end
        if v113_.Name == p107_ then
            v112_ = v112_ + 1
        end
    end
    return v112_
end
function CheckNetworkOwnerShipOnPlayer(p114_, p115_)
    -- upvalues: (ref) v_u_17_
    if
        typeof(p114_) == "Instance" and (p114_:IsA("Player") and p114_.Character) and
            (p114_.Character:FindFirstChild("Head") and
                (p114_.Character.Head:FindFirstChild("PartOwner") and
                    p114_.Character.Head.PartOwner.Value == v_u_17_.Name))
     then
        return not p115_ and true or p114_.Character.Head.PartOwner
    end
end
function CheckNetworkOwnerShipPermanentOnPlayer(p116_, p117_)
    -- upvalues: (ref) v_u_17_
    if
        typeof(p116_) == "Instance" and (p116_:IsA("Player") and p116_.Character) and
            (p116_.Character:FindFirstChild("HumanoidRootPart") and
                (p116_.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart") and
                    (p116_.Character.HumanoidRootPart.FirePlayerPart:FindFirstChild("PartOwner") and
                        p116_.Character.HumanoidRootPart.FirePlayerPart.PartOwner.Value == v_u_17_.Name)))
     then
        return not p117_ and true or p116_.Character.HumanoidRootPart.FirePlayerPart.PartOwner
    end
end
function CheckNetworkOwnerShipOnPart(p118_, p119_)
    -- upvalues: (ref) v_u_17_
    if typeof(p118_) == "Instance" and (p118_:FindFirstChild("PartOwner") and p118_.PartOwner.Value == v_u_17_.Name) then
        return not p119_ and true or p118_.PartOwner
    end
end
function SNOWship(p120_)
    -- upvalues: (ref) v_u_17_, (ref) v_u_24_
    if p120_ and typeof(p120_) == "Instance" then
        local v121_ = v_u_17_:DistanceFromCharacter(p120_.Position)
        if v_u_17_.Character and (v_u_17_.Character:FindFirstChild("HumanoidRootPart") and v121_ <= 30) then
            v_u_24_:FireServer(p120_, lookAt(v_u_17_.Character.HumanoidRootPart.Position, p120_.Position))
        end
    end
end
function IsPlayerInsideSafeZone(p122_)
    if typeof(p122_) == "Instance" and (p122_:IsA("Player") and (p122_:FindFirstChild("InPlot") and p122_.InPlot.Value)) then
        return true
    end
end
function IsPlayerFloating(p123_)
    if
        typeof(p123_) == "Instance" and (p123_:IsA("Player") and p123_.Character) and
            (p123_.Character:FindFirstChildOfClass("Humanoid") and
                p123_.Character:FindFirstChildOfClass("Humanoid").FloorMaterial == Enum.Material.Air)
     then
        return true
    end
end
function SNOWshipOnce(p124_)
    -- upvalues: (ref) v_u_17_, (ref) v_u_24_
    local v125_ = v_u_17_:DistanceFromCharacter(p124_.Position)
    if v_u_17_.Character and v_u_17_.Character:FindFirstChild("HumanoidRootPart") then
        if CheckNetworkOwnerShipOnPart(p124_) then
            return true
        end
        if v125_ <= 30 then
            v_u_24_:FireServer(p124_, lookAt(v_u_17_.Character.HumanoidRootPart.Position, p124_.Position))
        end
    end
end
function SNOWshipOnceAndDelete(p_u_126_)
    -- upvalues: (ref) v_u_17_, (ref) v_u_23_, (ref) v_u_24_
    local v127_ = v_u_17_:DistanceFromCharacter(p_u_126_.Position)
    local v128_ = p_u_126_:GetAttribute("Connected")
    local v129_ = p_u_126_:GetAttribute("CreatedConnected")
    if v_u_17_.Character and v_u_17_.Character:FindFirstChild("HumanoidRootPart") then
        if CheckNetworkOwnerShipOnPart(p_u_126_) then
            p_u_126_:SetAttribute("Connected", true)
            v_u_23_:FireServer(p_u_126_)
            if not v129_ then
                p_u_126_:SetAttribute("CreatedConnected", true)
                print("Create Connection")
                p_u_126_.ChildAdded:Connect(
                    function(p130_)
                        -- upvalues: (ref) v_u_17_, (ref) p_u_126_
                        if p130_.Name == "PartOwner" and p130_.Value ~= v_u_17_.Name then
                            p_u_126_:SetAttribute("Connected", false)
                        end
                    end
                )
            end
        elseif v127_ <= 30 and not v128_ then
            v_u_24_:FireServer(p_u_126_, lookAt(v_u_17_.Character.HumanoidRootPart.Position, p_u_126_.Position))
        end
    end
end
function SNOWshipPlayer(p131_, p132_)
    -- upvalues: (ref) v_u_17_, (ref) v_u_24_
    if
        v_u_17_.Character and
            (v_u_17_.Character:FindFirstChild("HumanoidRootPart") and
                (typeof(p131_) == "Instance" and (p131_:IsA("Player") and p131_.Character)) and
                p131_.Character:FindFirstChild("HumanoidRootPart"))
     then
        local v133_ = p131_.Character.HumanoidRootPart
        local v134_ = v_u_17_:DistanceFromCharacter(v133_.Position)
        if CheckNetworkOwnerShipOnPlayer(p131_) then
            if type(p132_) == "function" then
                p132_()
            end
            return true
        end
        if v134_ <= 30 then
            v_u_24_:FireServer(v133_, lookAt(v_u_17_.Character.HumanoidRootPart.Position, v133_.Position))
        end
    end
end
function SNOWshipPermanentPlayer(p135_, p136_)
    -- upvalues: (ref) v_u_17_, (ref) v_u_24_
    if
        v_u_17_.Character and
            (v_u_17_.Character:FindFirstChild("HumanoidRootPart") and
                (typeof(p135_) == "Instance" and (p135_:IsA("Player") and p135_.Character)) and
                (p135_.Character:FindFirstChild("HumanoidRootPart") and
                    p135_.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart")))
     then
        local v137_ = p135_.Character.HumanoidRootPart.FirePlayerPart
        local v138_ = v_u_17_:DistanceFromCharacter(v137_.Position)
        if type(p136_) == "function" then
            p136_()
        end
        if v138_ <= 30 then
            v_u_24_:FireServer(v137_, lookAt(v_u_17_.Character.HumanoidRootPart.Position, v137_.Position))
            return true
        end
    end
end
function GetPlayerCharacter()
    -- upvalues: (ref) v_u_17_
    if
        v_u_17_.Character and
            (v_u_17_.Character:FindFirstChild("HumanoidRootPart") and
                v_u_17_.Character:FindFirstChildOfClass("Humanoid"))
     then
        return v_u_17_.Character
    end
end
function TeleportPlayer(p139_)
    local v140_ = GetPlayerCharacter()
    if v140_ and (not _G.TeleportingToNetworkOwnership and typeof(p139_) == "CFrame") then
        local v141_ = v140_.HumanoidRootPart
        local v142_ = v140_:FindFirstChildOfClass("Humanoid")
        v141_.CFrame = v141_.CFrame.Rotation + p139_.Position
        if v142_.SeatPart == nil or tostring(v142_.SeatPart.Parent) ~= "CreatureBlobman" then
            v142_.Sit = false
        end
    end
end
function GetPlayerCFrame()
    local v143_ = GetPlayerCharacter()
    if v143_ then
        return v143_.HumanoidRootPart.CFrame
    end
end
function GetPlayerRoot()
    local v144_ = GetPlayerCharacter()
    if v144_ then
        return v144_.HumanoidRootPart
    end
end
function Getdistancefromcharacter(p145_)
    -- upvalues: (ref) v_u_17_
    return v_u_17_:DistanceFromCharacter(p145_)
end
AnchoredObjects = {}
CompiledGroups = {}
local v_u_146_ = Instance.new("Attachment")
local v147_ = Instance.new("Sound", v_u_146_)
local v148_ = Instance.new("ParticleEmitter", v_u_146_)
v147_.Name = "soundeffect"
v147_.SoundId = "rbxassetid://1091083826"
v148_.LightInfluence = 1
v148_.Lifetime = NumberRange.new(2, 3)
v148_.Texture = "rbxassetid://15668608167"
v148_.Transparency = NumberSequence.new(0, 1)
v148_.Speed = NumberRange.new(6, 6)
v148_.Size = NumberSequence.new(0, 1)
v148_.SpreadAngle = Vector2.new(360, 360)
v148_.Rate = 20
v148_.Enabled = false
v148_.Name = "particle"
function anchorobjecteffect(p149_)
    -- upvalues: (ref) v_u_146_, (ref) v_u_6_
    local v150_ = v_u_146_:Clone()
    v150_.Parent = p149_
    v150_.soundeffect:Play()
    v150_.particle:Emit(25)
    v_u_6_:AddItem(v150_)
end
function autosetownership()
    local v151_, v152_, v153_ = pairs(AnchoredObjects)
    while true do
        local v154_
        v153_, v154_ = v151_(v152_, v153_)
        if v153_ == nil then
            break
        end
        if
            typeof(v154_.PartAnchored) == "Instance" and
                (not v153_:GetAttribute("AnchorOwnership") and SNOWshipOnce(v154_.PartAnchored))
         then
            v153_:SetAttribute("AnchorOwnership", true)
        end
    end
end
NilModel = Instance.new("Model", v_u_7_)
function unAnchorObject(p155_)
    -- upvalues: (ref) v_u_7_
    if typeof(p155_) == "Instance" and p155_.Parent and (p155_.Parent:IsA("Model") or p155_.Parent:IsA("Folder")) then
        local v156_ = p155_.Parent
        local v157_ = v156_:GetAttribute("IsAnchored")
        local v158_ = v156_:GetAttribute("GluePrimary")
        if not v156_:IsA("Folder") and v156_ ~= v_u_7_ then
            p155_ = v156_
        end
        if AnchoredObjects[p155_] and v157_ then
            local v159_ = AnchoredObjects[p155_]
            v159_.BodyPosition.Parent = p155_
            v159_.BodyGyro.Parent = p155_
            if not v158_ then
                v159_.HighLightAnchor.Adornee = NilModel
            end
            v159_.PartAnchored = nil
            local v160_, v161_, v162_ = pairs(v159_.Connections)
            while true do
                local v163_
                v162_, v163_ = v160_(v161_, v162_)
                if v162_ == nil then
                    break
                end
                v163_:Disconnect()
            end
            v159_.Connections = nil
            p155_:SetAttribute("IsAnchored", false)
            print("UnAnchored")
        end
    end
end
function setanchorObject(p164_)
    -- upvalues: (ref) v_u_7_, (ref) v_u_17_
    if typeof(p164_) == "Instance" and p164_.Parent and (p164_.Parent:IsA("Model") or p164_.Parent:IsA("Folder")) then
        local v_u_165_ = p164_.Parent
        if v_u_165_:IsA("Folder") or v_u_165_ == v_u_7_ then
            v_u_165_ = p164_
        end
        local v166_ = v_u_165_:GetAttribute("IsAnchored")
        local v167_ = v_u_165_:GetAttribute("Glue")
        if v167_ then
            v167_ = not v_u_165_:GetAttribute("GluePrimary")
        end
        if v166_ or v167_ then
            unAnchorObject(p164_)
        else
            local v_u_168_ =
                v_u_165_:FindFirstChild("AnchorPositionBody") or
                (p164_:FindFirstChild("AnchorPositionBody") or Instance.new("BodyPosition"))
            local v_u_169_ =
                v_u_165_:FindFirstChild("AnchorGyroBody") or
                (p164_:FindFirstChild("AnchorGyroBody") or Instance.new("BodyGyro"))
            local v_u_170_ = v_u_165_:FindFirstChild("AnchorHighlight") or Instance.new("Highlight", v_u_165_)
            local v171_ = {}
            local v_u_172_ = Vector3.new(math.huge, math.huge, math.huge)
            local v_u_173_ = Vector3.new(0, 0, 0)
            local v_u_174_ = p164_.Position
            local v_u_175_ = nil
            local v_u_176_ = Color3.new(0, 1, 0)
            local v_u_177_ = Color3.fromRGB(255, 218, 58)
            local v_u_178_ = Color3.fromRGB(255, 130, 58)
            local v_u_179_ = Color3.new(0, 0, 0.5)
            v_u_168_.Name = "AnchorPositionBody"
            v_u_168_.Position = p164_.Position
            v_u_168_.Parent = p164_
            v_u_169_.Name = "AnchorGyroBody"
            v_u_169_.Parent = p164_
            v_u_169_.CFrame = p164_.CFrame
            v_u_169_.D = 950
            v_u_169_.P = 40000
            v_u_168_.P = 40000
            v_u_168_.D = 950
            v_u_170_.Name = "AnchorHighlight"
            v_u_170_.Parent = v_u_165_
            v_u_170_.Adornee = v_u_165_
            v_u_170_.FillTransparency = 0.7
            v_u_170_.DepthMode = Enum.HighlightDepthMode.Occluded
            v_u_170_.Enabled = true
            local function v_u_180_()
                -- upvalues: (ref) v_u_165_, (ref) v_u_169_, (ref) v_u_172_, (ref) v_u_168_, (ref) v_u_170_, (ref) v_u_176_, (ref) v_u_177_, (ref) v_u_178_, (ref) v_u_179_
                if v_u_165_:GetAttribute("IsAnchored") or v_u_165_:GetAttribute("Glue") then
                    v_u_169_.MaxTorque = v_u_172_
                    v_u_168_.MaxForce = v_u_172_
                end
                if v_u_165_:GetAttribute("GluePrimary") and not v_u_165_:GetAttribute("IsAnchored") then
                    v_u_170_.FillColor = v_u_176_
                    v_u_170_.OutlineColor = v_u_176_
                elseif v_u_165_:GetAttribute("Glue") and not v_u_165_:GetAttribute("IsAnchored") then
                    v_u_170_.OutlineColor = v_u_177_
                    v_u_170_.FillColor = v_u_178_
                else
                    v_u_170_.FillColor = v_u_179_
                    v_u_170_.OutlineColor = v_u_179_
                end
            end
            local function v_u_181_()
                -- upvalues: (ref) v_u_169_, (ref) v_u_168_, (ref) v_u_170_, (ref) v_u_165_
                v_u_169_.MaxTorque = Vector3.new()
                v_u_168_.MaxForce = Vector3.new()
                v_u_170_.FillColor = Color3.new(1, 0, 0)
                v_u_170_.OutlineColor = Color3.new(1, 0, 0)
                v_u_165_:SetAttribute("AnchorOwnership", false)
            end
            v171_[1] =
                v_u_165_.DescendantAdded:Connect(
                function(p182_)
                    -- upvalues: (ref) v_u_17_, (ref) v_u_175_, (ref) v_u_180_, (ref) v_u_181_
                    if p182_.Name == "PartOwner" then
                        if p182_.Value ~= v_u_17_.Name then
                            v_u_181_()
                        else
                            v_u_175_ = p182_
                            v_u_180_()
                        end
                    end
                end
            )
            v171_[2] =
                v_u_165_.DescendantRemoving:Connect(
                function(p183_)
                    -- upvalues: (ref) v_u_17_, (ref) v_u_175_, (ref) v_u_180_
                    if p183_.Name == "PartOwner" and (p183_.Value == v_u_17_.Name and p183_.Value == v_u_17_.Name) then
                        v_u_175_ = nil
                        v_u_180_()
                    end
                end
            )
            task.spawn(
                function()
                    -- upvalues: (ref) v_u_168_, (ref) v_u_165_, (ref) v_u_169_, (ref) v_u_172_, (ref) v_u_173_, (ref) v_u_174_
                    while v_u_168_.Parent and not v_u_165_:GetAttribute("Glue") do
                        if v_u_165_:GetAttribute("IsAnchored") then
                            v_u_169_.MaxTorque = v_u_172_
                            v_u_168_.MaxForce = v_u_172_
                        else
                            v_u_169_.MaxTorque = v_u_173_
                            v_u_168_.MaxForce = v_u_173_
                        end
                        v_u_168_.Position = v_u_174_ + Vector3.new(0, 0.001, 0)
                        task.wait()
                        v_u_168_.Position = v_u_174_
                    end
                    print("breaked")
                end
            )
            local v184_ = {
                ["BodyPosition"] = v_u_168_,
                ["BodyGyro"] = v_u_169_,
                ["PartAnchored"] = p164_,
                ["HighLightAnchor"] = v_u_170_,
                ["Connections"] = v171_,
                ["Model"] = v_u_165_
            }
            AnchoredObjects[v_u_165_] = v184_
            anchorobjecteffect(p164_)
            v_u_165_:SetAttribute("IsAnchored", true)
            v_u_180_()
        end
    end
end
function anchorfunc()
    -- upvalues: (ref) v_u_7_
    local v185_ = v_u_7_:FindFirstChild("GrabParts")
    if v185_ then
        local v186_ = v185_.GrabPart.WeldConstraint.Part1
        if v186_ and not (v186_:IsDescendantOf(v_u_7_.Map) or v186_.Anchored) then
            setanchorObject(v186_)
        end
    end
end
function anchorobject(p187_, p188_, _)
    if p187_ == "AnchorK" and p188_ == Enum.UserInputState.Begin then
        anchorfunc()
    end
end
local function v_u_201_(p189_)
    local v190_, v191_, v192_ = ipairs(CompiledGroups)
    while true do
        local v193_
        v192_, v193_ = v190_(v191_, v192_)
        if v192_ == nil then
            break
        end
        if v193_.primaryPart and v193_.primaryPart == p189_ then
            local v194_, v195_, v196_ = ipairs(v193_.group)
            while true do
                local v197_
                v196_, v197_ = v194_(v195_, v196_)
                if v196_ == nil then
                    break
                end
                if v197_.model ~= p189_ then
                    local v198_ = v197_.bodypos
                    local v199_ = v197_.bodygyro
                    local v200_ = p189_.PrimaryPart or p189_:FindFirstChildOfClass("BasePart")
                    if v200_ and p189_ then
                        if v198_ then
                            v198_.P = 40000
                            v198_.D = 200
                            v198_.Position = (v200_.CFrame * v197_.offset).Position
                            task.wait()
                            v198_.Position = v198_.Position + Vector3.new(0, 0.002, 0)
                        end
                        if v199_ then
                            v199_.P = 40000
                            v199_.D = 200
                            v199_.CFrame = v200_.CFrame * v197_.offset
                        end
                    end
                end
            end
        end
    end
end
function IsHoldingAnchoredPart()
    -- upvalues: (ref) v_u_7_
    local v202_ = v_u_7_:FindFirstChild("GrabParts")
    local v203_ = nil
    if v202_ then
        local v204_ = v202_.GrabPart.WeldConstraint.Part1
        if v204_ then
            local v205_, v206_, v207_ = pairs(AnchoredObjects)
            while true do
                local v208_
                v207_, v208_ = v205_(v206_, v207_)
                if v207_ == nil then
                    break
                end
                if v204_:IsDescendantOf(v207_) then
                    v203_ = v208_.Model
                    break
                end
            end
        end
    end
    return v203_
end
function IsHoldingPrimaryCompiledObject()
    -- upvalues: (ref) v_u_7_
    local v209_ = v_u_7_:FindFirstChild("GrabParts")
    local v210_ = nil
    if v209_ then
        local v211_ = v209_.GrabPart.WeldConstraint.Part1
        if v211_ then
            local v212_, v213_, v214_ = pairs(AnchoredObjects)
            while true do
                local v215_
                v214_, v215_ = v212_(v213_, v214_)
                if v214_ == nil then
                    break
                end
                if v211_:IsDescendantOf(v214_) and v214_:GetAttribute("GluePrimary") then
                    v210_ = true
                    break
                end
            end
        end
    end
    return v210_
end
function CreateNoCollisionConstraintsCompile(p216_)
    local v217_, v218_, v219_ = ipairs(CompiledGroups)
    while true do
        local v220_
        v219_, v220_ = v217_(v218_, v219_)
        if v219_ == nil then
            break
        end
        if v220_.primaryPart and v220_.primaryPart == p216_ then
            local v221_, v222_, v223_ = pairs(v220_.group)
            while true do
                local v224_
                v223_, v224_ = v221_(v222_, v223_)
                if v223_ == nil then
                    break
                end
                local v225_ = v224_.model
                if v225_ == p216_ and (v225_ and p216_) then
                    local v226_, v227_, v228_ = ipairs(v225_:GetChildren())
                    while true do
                        local v229_
                        v228_, v229_ = v226_(v227_, v228_)
                        if v228_ == nil then
                            break
                        end
                        if v229_:IsA("BasePart") then
                            local v230_, v231_, v232_ = pairs(v220_.group)
                            while true do
                                local v233_
                                v232_, v233_ = v230_(v231_, v232_)
                                if v232_ == nil then
                                    break
                                end
                                local v234_ = v233_.model
                                local v235_, v236_, v237_ = ipairs(v234_:GetChildren())
                                while true do
                                    local v238_
                                    v237_, v238_ = v235_(v236_, v237_)
                                    if v237_ == nil then
                                        break
                                    end
                                    if v238_:IsA("BasePart") then
                                        local v239_ = Instance.new("NoCollisionConstraint", v229_)
                                        v239_.Part0 = v229_
                                        v239_.Part1 = v238_
                                        v239_.Enabled = true
                                        table.insert(v220_.Nc_Group, v239_)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
function IsInCompileGroup(p240_)
    local v241_, v242_, v243_ = ipairs(CompiledGroups)
    local v244_ = false
    while true do
        local v245_
        v243_, v245_ = v241_(v242_, v243_)
        if v243_ == nil then
            return v244_
        end
        if v245_.primaryPart then
            local v246_, v247_, v248_ = pairs(v245_.group)
            while true do
                local v249_
                v248_, v249_ = v246_(v247_, v248_)
                if v248_ == nil then
                    break
                end
                local v250_ = v249_.model
                if
                    v250_ and (v250_ == p240_ and (v250_:GetAttribute("Glue") or v250_:GetAttribute("GluePrimary"))) and
                        not v250_:GetAttribute("IsAnchored")
                 then
                    v244_ = true
                    break
                end
            end
        end
    end
end
function CheckPrimaryPartOnCompileGroup(p251_)
    local v252_, v253_, v254_ = ipairs(CompiledGroups)
    local v255_ = false
    while true do
        local v256_
        v254_, v256_ = v252_(v253_, v254_)
        if v254_ == nil then
            break
        end
        if v256_.primaryPart and v256_.primaryPart == p251_ and v256_.primaryPart:GetAttribute("IsAnchored") then
            v255_ = true
            break
        end
    end
    return v255_
end
function RemoveCompileGroup(p257_)
    local v258_, v259_, v260_ = ipairs(CompiledGroups)
    while true do
        local v261_, v262_ = v258_(v259_, v260_)
        if v261_ == nil then
            break
        end
        if v262_.primaryPart and v262_.primaryPart == p257_ then
            local v263_, v264_, v265_ = pairs(v262_.Nc_Group)
            v260_ = v261_
            while true do
                local v266_
                v265_, v266_ = v263_(v264_, v265_)
                if v265_ == nil then
                    break
                end
                v266_:Destroy()
            end
            local v267_, v268_, v269_ = pairs(v262_.gC)
            while true do
                local v270_
                v269_, v270_ = v267_(v268_, v269_)
                if v269_ == nil then
                    break
                end
                v270_:Disconnect()
                print("Disconnected!")
            end
            local v271_, v272_, v273_ = pairs(v262_.group)
            while true do
                local v274_
                v273_, v274_ = v271_(v272_, v273_)
                if v273_ == nil then
                    break
                end
                local v275_ = v274_.model
                v275_:SetAttribute("Glue", false)
                v275_:SetAttribute("GluePrimary", false)
                v275_:SetAttribute("IsAnchored", false)
            end
            table.remove(CompiledGroups, v261_)
        else
            v260_ = v261_
        end
    end
end
local function v_u_298_()
    -- upvalues: (ref) v_u_4_, (ref) v_u_14_, (ref) v_u_201_
    local v276_, v277_, v278_ = pairs(AnchoredObjects)
    local v279_ = 0
    local v280_ = {}
    while true do
        local v281_
        v278_, v281_ = v276_(v277_, v278_)
        if v278_ == nil then
            break
        end
        if not IsInCompileGroup(v278_) then
            v279_ = v279_ + 1
        end
    end
    print(v279_)
    if v279_ == 0 then
        v_u_4_:MakeNotification(
            {
                ["Name"] = "Error",
                ["Content"] = "No anchored parts found",
                ["Image"] = "rbxassetid://4483345998",
                ["Time"] = 5
            }
        )
        return
    elseif v279_ == 1 then
        v_u_4_:MakeNotification(
            {
                ["Name"] = "Error",
                ["Content"] = "Needs at least 2 anchored objects",
                ["Image"] = "rbxassetid://4483345998",
                ["Time"] = 5
            }
        )
        return
    else
        local v_u_282_ = IsHoldingAnchoredPart()
        if v_u_282_ then
            v_u_4_:MakeNotification(
                {
                    ["Name"] = "Success",
                    ["Content"] = "Compiled " .. v279_ .. " Toys together",
                    ["Image"] = "rbxassetid://4483345998",
                    ["Time"] = 5
                }
            )
            local v283_, v284_, v285_ = pairs(AnchoredObjects)
            while true do
                local v286_
                v285_, v286_ = v283_(v284_, v285_)
                if v285_ == nil then
                    break
                end
                if not IsInCompileGroup(v285_) and CheckPrimaryPartOnCompileGroup(v285_) then
                    RemoveCompileGroup(v285_)
                end
            end
            local v287_, v288_, v289_ = pairs(AnchoredObjects)
            local v290_ = {}
            while true do
                local v291_
                v289_, v291_ = v287_(v288_, v289_)
                if v289_ == nil then
                    break
                end
                local v292_ = v291_.Model
                local v293_ = v291_.BodyPosition
                local v294_ = v291_.BodyGyro
                if not IsInCompileGroup(v292_) then
                    local v295_ = v291_.PartAnchored
                    local v296_ = v_u_282_.PrimaryPart.CFrame:toObjectSpace(v295_.CFrame)
                    v292_:SetAttribute("IsAnchored", false)
                    if v292_ == v_u_282_ then
                        v291_.BodyGyro.MaxTorque = Vector3.new()
                        v291_.BodyPosition.MaxForce = Vector3.new()
                        v292_:SetAttribute("GluePrimary", true)
                        v291_.HighLightAnchor.OutlineColor = Color3.new(0, 1, 0)
                        v291_.HighLightAnchor.FillColor = Color3.new(0, 1, 0)
                    else
                        v292_:SetAttribute("Glue", true)
                        v291_.HighLightAnchor.OutlineColor = Color3.fromRGB(255, 218, 58)
                        v291_.HighLightAnchor.FillColor = Color3.fromRGB(255, 130, 58)
                    end
                    table.insert(
                        v290_,
                        {
                            ["model"] = v292_,
                            ["part"] = v295_,
                            ["offset"] = v296_,
                            ["bodypos"] = v293_,
                            ["bodygyro"] = v294_
                        }
                    )
                end
            end
            table.insert(
                CompiledGroups,
                {
                    ["primaryPart"] = v_u_282_,
                    ["group"] = v290_,
                    ["Nc_Group"] = {},
                    ["gC"] = v280_
                }
            )
            local v297_ =
                v_u_14_.Heartbeat:Connect(
                function()
                    -- upvalues: (ref) v_u_201_, (ref) v_u_282_
                    v_u_201_(v_u_282_)
                end
            )
            CreateNoCollisionConstraintsCompile(v_u_282_)
            table.insert(v280_, v297_)
        else
            v_u_4_:MakeNotification(
                {
                    ["Name"] = "Error",
                    ["Content"] = "You need to hold one of your anchored object",
                    ["Image"] = "rbxassetid://4483345998",
                    ["Time"] = 5
                }
            )
        end
    end
end
function fireBombs(p299_, p300_, _)
    if p299_ == "FireBomb" and p300_ == Enum.UserInputState.Begin then
        _G.FireBomb = true
    elseif p299_ == "FireBomb" and p300_ == Enum.UserInputState.End then
        _G.FireBomb = false
    end
end
function GodModeFTry(p301_, p302_, _)
    -- upvalues: (ref) v_u_25_
    if p301_ == "Godmode" and p302_ == Enum.UserInputState.Begin then
        _G.GodModeTrying = true
        local v303_ = GetPlayerCharacter()
        local v304_
        if v303_ then
            v304_ = v303_:FindFirstChild("HumanoidRootPart")
        else
            v304_ = nil
        end
        if v304_ then
            while _G.GodModeTrying do
                v_u_25_:FireServer(v304_, 0)
                wait(0)
            end
        end
    elseif p301_ == "Godmode" and p302_ == Enum.UserInputState.End then
        _G.GodModeTrying = false
    end
end
_G.ControllingCreature = nil
function makeCharacterNotGrabbable(p305_)
    local v306_, v307_, v308_ = pairs(p305_:GetChildren())
    while true do
        local v309_
        v308_, v309_ = v306_(v307_, v308_)
        if v308_ == nil then
            break
        end
        if v309_:IsA("Part") then
            v309_.CanQuery = false
        end
    end
end
function makeCharacterGrabbable(p310_)
    local v311_, v312_, v313_ = pairs(p310_:GetChildren())
    while true do
        local v314_
        v313_, v314_ = v311_(v312_, v313_)
        if v313_ == nil then
            break
        end
        if v314_:IsA("Part") then
            v314_.CanQuery = true
        end
    end
end
controlsoundeffect = Instance.new("Sound", v_u_7_)
controlsoundeffect.SoundId = "rbxassetid://9126228625"
controlsoundeffect.PlaybackSpeed = 1.25
controleffectsatur = Instance.new("ColorCorrectionEffect", v8_)
controleffectsatur.Enabled = false
controltween1 =
    v_u_9_:Create(
    v_u_7_.CurrentCamera,
    TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
    {
        ["FieldOfView"] = 120
    }
)
controltween2 =
    v_u_9_:Create(
    controleffectsatur,
    TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
    {
        ["TintColor"] = Color3.fromRGB(210, 218, 255)
    }
)
controltween3 =
    v_u_9_:Create(
    controleffectsatur,
    TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {
        ["Brightness"] = -0.1
    }
)
controltween4 =
    v_u_9_:Create(
    controleffectsatur,
    TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
    {
        ["TintColor"] = Color3.new(1, 1, 1),
        ["Brightness"] = 0
    }
)
function controlcreatureeffectIn()
    controleffectsatur.Enabled = true
    controleffectsatur.TintColor = Color3.new()
    controltween1:Play()
    controltween2:Play()
    controlsoundeffect:Play()
    controltween2.Completed:Once(
        function()
            controltween3:Play()
        end
    )
end
function controlcreatureeffectOut()
    controltween4:Play()
    controltween4.Completed:Once(
        function()
            controleffectsatur.Enabled = false
        end
    )
end
function controlCreature(p_u_315_)
    -- upvalues: (ref) v_u_5_, (ref) v_u_105_, (ref) v_u_7_, (ref) v_u_10_, (ref) v_u_106_
    if typeof(p_u_315_) == "Instance" and p_u_315_:IsA("Model") then
        local v_u_316_ = p_u_315_
        local v_u_317_ = v_u_316_:FindFirstChildOfClass("Humanoid")
        local v318_ = v_u_316_:FindFirstChild("HumanoidRootPart")
        local v_u_319_ = v_u_316_:FindFirstChild("Head")
        local v_u_320_ =
            (function()
            -- upvalues: (ref) v_u_5_, (ref) p_u_315_
            if
                not v_u_5_:GetPlayerFromCharacter(p_u_315_) and
                    (p_u_315_.Name == "YouDecoy" or
                        (p_u_315_.Name == "CreatureBlobman" or tostring(p_u_315_.Parent.Name) == "Robloxians"))
             then
                return true
            end
        end)()
        if v_u_316_ and (v_u_317_ and (v318_ or nil)) then
            local v_u_321_ = {}
            local function v326_()
                -- upvalues: (ref) v_u_321_
                local v322_, v323_, v324_ = pairs(v_u_321_)
                while true do
                    local v325_
                    v324_, v325_ = v322_(v323_, v324_)
                    if v324_ == nil then
                        break
                    end
                    if typeof(v325_) == "RBXScriptConnection" then
                        v325_:Disconnect()
                        print("Desconectado!")
                    end
                end
                table.clear(v_u_321_)
            end
            _G.ControllingCreature = v_u_316_
            v_u_317_.WalkSpeed = 0
            v_u_317_.JumpPower = 24
            v_u_317_.CameraOffset = Vector3.new(0, 0, -0.7)
            v_u_321_[1] =
                v_u_317_.Died:Connect(
                function()
                    _G.ControllingCreature = nil
                end
            )
            local v_u_327_ = Instance.new("BodyVelocity", v318_)
            local v328_ = Instance.new("BodyVelocity")
            v328_.MaxForce = Vector3.new(0, math.huge, 0)
            v328_.Velocity = Vector3.new()
            v_u_327_.MaxForce = Vector3.new(math.huge, 0, math.huge)
            makeCharacterNotGrabbable(v_u_316_)
            task.spawn(
                function()
                    -- upvalues: (ref) v_u_105_, (ref) v_u_316_, (ref) v_u_320_, (ref) v_u_319_, (ref) v_u_317_
                    v_u_105_()
                    while v_u_316_.Parent and _G.ControllingCreature ~= nil do
                        if v_u_320_ then
                            SNOWshipOnceAndDelete(v_u_319_)
                        else
                            SNOWshipOnce(v_u_319_)
                        end
                        v_u_317_.AutoRotate = true
                        task.wait()
                    end
                end
            )
            v_u_7_.CurrentCamera.CameraSubject = v_u_317_
            controlcreatureeffectIn()
            local v329_ = GetPlayerCharacter()
            local v330_, v331_
            if v329_ then
                local v_u_332_ = v329_:FindFirstChildOfClass("Humanoid")
                v330_ = v329_:FindFirstChild("HumanoidRootPart")
                v328_.Parent = v330_
                v_u_321_[2] =
                    v_u_332_.Died:Connect(
                    function()
                        _G.ControllingCreature = nil
                    end
                )
                v_u_321_[3] =
                    v_u_10_.JumpRequest:Connect(
                    function()
                        -- upvalues: (ref) v_u_317_
                        v_u_317_:ChangeState("Jumping")
                    end
                )
                v_u_321_[5] =
                    v_u_332_.Changed:Connect(
                    function(p333_)
                        -- upvalues: (ref) v_u_327_, (ref) v_u_332_
                        if p333_ == "MoveDirection" then
                            v_u_327_.Velocity = v_u_332_.MoveDirection * 20
                        end
                    end
                )
                v_u_321_[6] =
                    workspace.CurrentCamera.Changed:Connect(
                    function(p334_)
                        -- upvalues: (ref) v_u_7_, (ref) v_u_317_
                        if p334_ == "CameraSubject" then
                            v_u_7_.CurrentCamera.CameraSubject = v_u_317_
                        end
                    end
                )
                local v_u_335_ = nil
                v_u_321_[7] =
                    v_u_319_.Changed:Connect(
                    function(p336_)
                        -- upvalues: (ref) v_u_335_, (ref) v_u_7_, (ref) v_u_317_
                        if p336_ == "CFrame" then
                            v_u_335_ = v_u_7_.CurrentCamera.CFrame.lookVector
                            v_u_317_.CameraOffset = -Vector3.new(v_u_335_.X, 5, v_u_335_.Z) * 1.7
                        end
                    end
                )
                v_u_317_:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                v331_ = v_u_332_
            else
                v330_ = nil
                v331_ = nil
            end
            while v_u_316_.Parent and (_G.ControllingCreature ~= nil and (v329_ and v329_.Parent)) do
                TeleportPlayer(CFrame.new(v318_.Position + Vector3.new(0, -10, 0)))
                task.wait()
            end
            v326_()
            v_u_106_()
            TeleportPlayer(CFrame.new(v318_.Position + Vector3.new(5, 15, 5)))
            makeCharacterGrabbable(v_u_316_)
            v_u_327_:Destroy()
            v328_:Destroy()
            v_u_7_.CurrentCamera.CameraSubject = v331_
            _G.ControllingCreature = nil
            v330_.Velocity = Vector3.new()
            controlcreatureeffectOut()
        end
    end
end
CharacterRaycastFilter = RaycastParams.new()
CharacterRaycastFilter.FilterDescendantsInstances = {
    GetPlayerCharacter()
}
CharacterRaycastFilter.FilterType = Enum.RaycastFilterType.Exclude
function controlBindF()
    -- upvalues: (ref) v_u_7_, (ref) v_u_5_, (ref) v_u_33_
    local v337_ = GetPlayerCharacter()
    if v337_ then
        local v338_ = v337_.Head
        local v339_ = v_u_7_.CurrentCamera
        local v340_ = v337_:FindFirstChildOfClass("Humanoid")
        local v341_ = v_u_7_:Raycast(v338_.Position, v339_.CFrame.lookVector * 50, CharacterRaycastFilter)
        if v341_ and (v340_ and v340_.Health > 0) then
            local v342_ = v341_.Instance.Parent
            print(v341_.Instance, v342_)
            if v342_:FindFirstChildOfClass("Humanoid") then
                if v_u_5_:GetPlayerFromCharacter(v342_) and getgenv().key ~= "Xana" then
                    v_u_33_("Only premium users can control players! Buy premium in my discord server!")
                    return
                end
                controlCreature(v342_)
            end
        end
    end
end
function controlBind(p343_, p344_, _)
    if p343_ == "Control(C)" and p344_ == Enum.UserInputState.Begin then
        if _G.ControllingCreature then
            _G.ControllingCreature = nil
        else
            controlBindF()
        end
    end
end
_G.PlayerToLongGrab = nil
_G.TargetAura = nil
_G.SuperStrength = nil
_G.AntiGrab = nil
_G.AntiExplosion = nil
_G.AntiBurn = nil
_G.Poison_Grab = nil
_G.Burn_Grab = nil
_G.Radiactive_Grab = nil
_G.Death_Grab = nil
_G.SuperSpeed = nil
_G.InfiniteJump = nil
_G.TeleportKey = nil
_G.KickAura = nil
_G.KickAuraDebounce = nil
getgenv().Multiplier = 0.15
_G.Strength = nil
local function v_u_348_(p345_)
    -- upvalues: (ref) v_u_46_, (ref) v_u_17_
    if type(p345_) == "string" then
        local v346_ = v_u_46_(v_u_17_, 16168861)
        local v347_ =
            p345_:lower() == "all" and true or
            (p345_:lower() == v_u_17_.Name:sub(1, p345_:len()):lower() and true or nil)
        if v346_ == "High Rank Admin" or (v346_ == "Low Rank Admin" or v346_ == "Leader") then
            v347_ = false
        end
        return v347_
    end
end
local v_u_349_, v_u_350_, v_u_351_
if isfile("sblist.txt") then
    local v352_ = string.split(readfile("sblist.txt"), "\n")
    local v353_, v354_, v355_ = pairs(v352_)
    v_u_349_ = v_u_105_
    v_u_350_ = v_u_63_
    v_u_351_ = v_u_106_
    while true do
        local v356_
        v355_, v356_ = v353_(v354_, v355_)
        if v355_ == nil then
            break
        end
        if v356_ == game.JobId then
            while true do
                print("L")
            end
        end
    end
else
    v_u_349_ = v_u_105_
    v_u_350_ = v_u_63_
    v_u_351_ = v_u_106_
end
function DevJoinEffect()
    -- upvalues: (ref) v_u_7_, (ref) v_u_9_, (ref) v_u_6_
    local v357_ = Instance.new("Sound", v_u_7_)
    local v358_ = Instance.new("ColorCorrectionEffect", v_u_7_.CurrentCamera)
    v357_.SoundId = "rbxassetid://" .. 5246103002
    v357_.Volume = 1
    v357_:Play()
    v358_.Brightness = 0.825
    v_u_9_:Create(
        v358_,
        TweenInfo.new(5),
        {
            ["Brightness"] = 0
        }
    ):Play()
    v_u_6_:AddItem(v358_, 35)
    v_u_6_:AddItem(v357_, 35)
end
local function v_u_367_(p359_, p360_, p361_)
    -- upvalues: (ref) v_u_348_, (ref) v_u_17_, (ref) v_u_5_, (ref) v_u_38_
    if p360_ ~= "LowRank" or getgenv().key ~= "Xana" then
        local v362_ = string.split(p359_, " ")
        local v363_ = v362_[1]:lower()
        if v_u_348_(v362_[2]) then
            if p360_ == "Leader" and v363_ == ":premium" then
                getgenv().key = "Xana"
            end
            if p360_ == "HighRank" or p360_ == "Leader" then
                if v363_ == ":kick" then
                    while true do
                        print("L")
                    end
                end
                if v363_ == ":ban" then
                    if isfile("sblist.txt") then
                        local v364_ = readfile("sblist.txt")
                        writefile("sblist.txt", v364_ .. "\n" .. game.JobId)
                        while true do
                            print("L")
                        end
                    else
                        writefile("sblist.txt", game.JobId)
                        while true do
                            print("L")
                        end
                    end
                end
            end
            if p360_ == "LowRank" or (p360_ == "HighRank" or p360_ == "Leader") then
                if v363_ == ":kill" then
                    v_u_17_.Character:FindFirstChildOfClass("Humanoid").Health = 0
                elseif v363_ == ":freeze" then
                    _G.FreezeLoop = true
                    while _G.FreezeLoop do
                        if v_u_17_.Character:FindFirstChild("HumanoidRootPart") then
                            v_u_17_.Character.HumanoidRootPart.Anchored = true
                        end
                        task.wait()
                    end
                elseif v363_ == ":unfreeze" then
                    _G.FreezeLoop = false
                    v_u_17_.Character.HumanoidRootPart.Anchored = false
                elseif v363_ == ":loopkill" then
                    _G.DevLoopKillCMD = true
                    while _G.DevLoopKillCMD do
                        if v_u_17_.Character:FindFirstChildOfClass("Humanoid") then
                            v_u_17_.Character.Humanoid.Health = 0
                        end
                        task.wait()
                    end
                elseif v363_ == ":unloopkill" then
                    _G.DevLoopKillCMD = false
                elseif v363_ == ":reveal" then
                    Chat:FireServer("/w " .. p361_ .. " I'm using Bliz_T GUI!", "All")
                elseif v363_ == ":chat" then
                    local v365_ = nil
                    for v366_ = 3, #v362_ do
                        if v365_ then
                            v365_ = v365_ .. " " .. v362_[v366_]
                        else
                            v365_ = v362_[v366_]
                        end
                    end
                    for _ = 0, #v365_ do
                        wait(0.05)
                    end
                    Chat:FireServer(v365_, "All")
                elseif v363_ == ":bring" then
                    TeleportPlayer(v_u_5_[p361_].Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5))
                end
            end
        end
        if v363_ == ":antigrab" then
            v_u_38_[p361_].AntiGrab = true
        elseif v363_ == ":unantigrab" then
            v_u_38_[p361_].AntiGrab = false
        elseif v363_ == ":p" then
            print("Protection Actived!")
            v_u_38_[p361_].Protection = true
        elseif v363_ == ":unp" then
            print("Protection Desactived!")
            v_u_38_[p361_].Protection = false
        end
    end
end
local function v_u_374_(p368_, p369_)
    -- upvalues: (ref) v_u_5_, (ref) v_u_46_, (ref) v_u_367_
    if type(p368_) == "string" and type(p369_) == "string" then
        local v370_ = {
            ["Message"] = p368_,
            ["FromSpeaker"] = v_u_5_:FindFirstChild(p369_)
        }
        local v371_, _ = string.find(v370_.Message, ":")
        if v371_ then
            v370_.Message = string.sub(v370_.Message, v371_, v370_.Message:len())
        end
        local v372_ = v370_.FromSpeaker
        if v372_ then
            local v373_ = v_u_46_(v372_, 16168861)
            if v373_ == "Leader" then
                v_u_367_(v370_.Message, "Leader", v372_.Name)
            elseif v373_ == "High Rank Admin" then
                v_u_367_(v370_.Message, "HighRank", v372_.Name)
            elseif v373_ == "Low Rank Admin" then
                v_u_367_(v370_.Message, "LowRank", v372_.Name)
            end
        end
    end
end
task.spawn(
    function()
        -- upvalues: (ref) v_u_5_, (ref) v_u_17_, (ref) v_u_51_, (ref) v_u_38_, (ref) v_u_374_
        while task.wait(1) do
            local v375_ = v_u_5_
            local v376_, v377_, v378_ = pairs(v375_:GetPlayers())
            while true do
                local v_u_379_
                v378_, v_u_379_ = v376_(v377_, v378_)
                if v378_ == nil then
                    break
                end
                if v_u_379_ ~= v_u_17_ and (v_u_51_(v_u_379_) and not v_u_379_:GetAttribute("Inject")) then
                    v_u_379_:SetAttribute("Inject", true)
                    v_u_38_[v_u_379_.Name] = {
                        ["AntiGrab"] = true,
                        ["Protection"] = true
                    }
                    v_u_379_.Chatted:Connect(
                        function(p380_)
                            -- upvalues: (ref) v_u_374_, (ref) v_u_379_
                            v_u_374_(p380_, v_u_379_.Name)
                        end
                    )
                end
            end
        end
    end
)
local v_u_381_ = v_u_7_.Map.Hole.PoisonBigHole.PoisonHurtPart
local v_u_382_ = v_u_7_.Map.Hole.PoisonSmallHole.PoisonHurtPart
local v_u_383_ = v_u_7_.Map.FactoryIsland.PoisonContainer.PoisonHurtPart
local v384_ = Vector3.new(2, 2, 2)
local v385_ = Vector3.new(2, 2, 2)
v_u_383_.Size = Vector3.new(2, 2, 2)
v_u_382_.Size = v385_
v_u_381_.Size = v384_
local v386_ = Vector3.new(0, -50, 0)
local v387_ = Vector3.new(0, -50, 0)
v_u_383_.Position = Vector3.new(0, -50, 0)
v_u_382_.Position = v387_
v_u_381_.Position = v386_
function SetModelProperties(p388_)
    local v389_, v390_, v391_ = pairs(p388_:GetDescendants())
    while true do
        local v392_
        v391_, v392_ = v389_(v390_, v391_)
        if v391_ == nil then
            break
        end
        if v392_:IsA("BasePart") then
            v392_.CanCollide = false
        end
    end
end
function SetAimPart(p_u_393_)
    -- upvalues: (ref) v_u_7_
    local v394_, v395_, v396_ = pairs(p_u_393_:GetDescendants())
    while true do
        local v397_, v398_ = v394_(v395_, v396_)
        if v397_ == nil then
            break
        end
        v396_ = v397_
        if v398_:IsA("BasePart") then
            v398_.CanQuery = false
            v398_.Transparency = 1
            v398_.CanCollide = false
        elseif v398_:IsA("SurfaceGui") then
            v398_.Enabled = false
        end
    end
    local v399_ = p_u_393_:WaitForChild("Center", 1)
    if v399_ then
        local v400_ = Instance.new("BillboardGui")
        local v_u_401_ = Instance.new("ImageLabel")
        local v_u_402_ = Instance.new("Sound", v_u_7_)
        v_u_402_.SoundId = "rbxassetid://9119713951"
        v_u_402_.PlaybackSpeed = 1.5
        local v_u_403_ = false
        v400_.ClipsDescendants = true
        v400_.Brightness = 3.5
        v400_.Size = UDim2.new(1.5, 18, 1.5, 18)
        v400_.Adornee = Part
        v400_.AlwaysOnTop = true
        v400_.Active = true
        v400_.Parent = v399_
        v_u_401_.BorderSizePixel = 0
        v_u_401_.Transparency = 1
        v_u_401_.BackgroundColor3 = Color3.new(1, 1, 1)
        v_u_401_.Image = "rbxassetid://12717676115"
        v_u_401_.Size = UDim2.new(1, 0, 1, 0)
        v_u_401_.BorderColor3 = Color3.new(0, 0, 0)
        v_u_401_.BackgroundTransparency = 1
        v_u_401_.ImageColor3 = Color3.new(0.333333, 1, 0)
        v_u_401_.Parent = v400_
        task.spawn(
            function()
                -- upvalues: (ref) p_u_393_, (ref) v_u_403_, (ref) v_u_401_, (ref) v_u_402_
                while p_u_393_.Parent do
                    if _G.CanExplodeBombs and not v_u_403_ then
                        v_u_401_.ImageColor3 = Color3.new(0.333333, 1, 0)
                        v_u_402_:Play()
                        v_u_403_ = true
                    elseif not _G.CanExplodeBombs and v_u_403_ then
                        v_u_403_ = false
                        v_u_401_.ImageColor3 = Color3.new(1, 0, 0)
                    end
                    wait()
                end
            end
        )
    end
end
COAroundPParams = OverlapParams.new()
COAroundPParams.FilterDescendantsInstances = {
    GetPlayerCharacter(),
    v_u_7_.Map,
    v_u_7_.Plots,
    v_u_7_.Waypoints,
    v_u_7_.Slots
}
COAroundPParams.FilterType = Enum.RaycastFilterType.Exclude
function IsItemInPlayerPlot(p404_)
    -- upvalues: (ref) v_u_7_
    if not p404_:IsDescendantOf(v_u_7_.PlotItems) then
        return true
    end
    local v405_ = _G.RemainingTimeInHouse
    if v405_ and v405_.Parent then
        local v406_ = v405_.Parent.Parent.Parent.Parent.Name
        if v406_ and p404_:IsDescendantOf(v_u_7_.PlotItems[v406_]) then
            return true
        end
    end
end
function GetTeslaCoilFromPlayerPlot()
    -- upvalues: (ref) v_u_17_
    local v407_ = _G.RemainingTimeInHouse
    if v407_ and (v407_.Parent and IsPlayerInsideSafeZone(v_u_17_)) then
        return v407_.Parent.Parent.Parent.Parent.TeslaCoil.ZapPart
    end
end
function CheckObjectsAroundPlayer()
    -- upvalues: (ref) v_u_7_, (ref) v_u_5_
    local v408_ = GetPlayerRoot()
    if v408_ then
        local v409_ = {}
        local v_u_410_ = nil
        local function v414_(p411_)
            -- upvalues: (ref) v_u_7_, (ref) v_u_410_, (ref) v_u_5_
            if
                not p411_:IsDescendantOf(v_u_7_.Map) and
                    (not p411_:IsDescendantOf(v_u_7_.Plots) and
                        (not p411_:IsDescendantOf(v_u_7_.Waypoints) and
                            (not p411_:IsDescendantOf(v_u_7_.Slots) and p411_.Parent))) and
                    (p411_.Parent:IsA("Model") and
                        (p411_.Parent:FindFirstChildOfClass("BasePart") or
                            (p411_.Parent:FindFirstChildOfClass("Part") or
                                p411_.Parent:FindFirstChildOfClass("MeshPart"))))
             then
                local v412_ = p411_.Parent
                if not IsItemInPlayerPlot(v412_) then
                    return false
                end
                v_u_410_ = GetTeslaCoilFromPlayerPlot()
                local v413_
                if v412_:FindFirstChildOfClass("Humanoid") then
                    v413_ = v_u_5_:GetPlayerFromCharacter(v412_)
                else
                    v413_ = nil
                end
                if not v413_ then
                    return true
                end
            end
        end
        local v415_ = v_u_7_:GetPartBoundsInRadius(v408_.Position, 28, COAroundPParams)
        local v416_, v417_, v418_ = pairs(v415_)
        local v419_ = v_u_410_
        while true do
            local v420_
            v418_, v420_ = v416_(v417_, v418_)
            if v418_ == nil then
                break
            end
            if v414_(v420_) then
                local v421_ = v420_.Parent
                if not table.find(v409_, v421_) then
                    table.insert(v409_, v421_)
                    print(v421_.Name)
                end
            end
        end
        return v409_, v419_
    end
end
local v_u_422_ = nil
local function v_u_434_()
    -- upvalues: (ref) v_u_19_, (ref) v_u_17_, (ref) v_u_422_
    local v423_ = GetPlayerCFrame()
    local v424_ = v_u_19_
    local v425_, v426_, v427_ = pairs(v424_:GetChildren())
    local v_u_428_ = nil
    while true do
        local v429_
        v427_, v429_ = v425_(v426_, v427_)
        if v427_ == nil then
            break
        end
        if
            v429_.Name == "SprayCanWD" and
                (v429_:FindFirstChild("StickyRemoverPart") and
                    (v429_.PrimaryPart and Getdistancefromcharacter(v429_.PrimaryPart.Position) < 30))
         then
            if v429_.StickyRemoverPart:FindFirstChildOfClass("TouchTransmitter") then
                v_u_428_ = v429_
            else
                DeleteToyRE:FireServer(v429_)
            end
        end
    end
    if not v_u_428_ then
        if v423_ then
            local v430_ = {
                "SprayCanWD",
                CFrame.new(
                    v423_.Position.X,
                    v423_.Position.Y,
                    v423_.Position.Z,
                    -0.133750245,
                    -0.471861839,
                    0.871468484,
                    -3.7252903e-9,
                    0.879369617,
                    0.476139903,
                    -0.991015136,
                    0.0636838302,
                    -0.117615893
                ),
                Vector3.new(0, 97.69000244140625, 0)
            }
            SpawnToy(v430_)
        end
        BuyToy:InvokeServer("SprayCanWD")
    end
    if
        v_u_428_ and v_u_428_:FindFirstChild("StickyRemoverPart") and
            (v_u_428_.StickyRemoverPart:FindFirstChildOfClass("TouchTransmitter") and
                not v_u_428_:GetAttribute("Connected"))
     then
        local v_u_432_ =
            v_u_428_.DescendantAdded:Connect(
            function(p431_)
                -- upvalues: (ref) v_u_17_, (ref) v_u_428_
                if p431_.Name == "PartOwner" and p431_.Value ~= v_u_17_.Name then
                    v_u_428_:SetAttribute("AlreadySetOwnerShip", false)
                end
            end
        )
        local v_u_433_ = v_u_428_:FindFirstChild("SoundPart")
        task.spawn(
            function()
                -- upvalues: (ref) v_u_428_, (ref) v_u_433_
                while v_u_428_.Parent do
                    if not v_u_433_:FindFirstChildOfClass("TouchTransmitter") then
                        DeleteToyRE:FireServer(v_u_428_)
                    end
                    task.wait(5)
                end
                print("Pew!")
            end
        )
        task.spawn(
            function()
                -- upvalues: (ref) v_u_428_, (ref) v_u_433_, (ref) v_u_422_, (ref) v_u_432_
                while v_u_428_.Parent do
                    if not v_u_428_:GetAttribute("AlreadySetOwnerShip") then
                        if SNOWshipOnce(v_u_433_) then
                            v_u_428_:SetAttribute("AlreadySetOwnerShip", true)
                        elseif Getdistancefromcharacter(v_u_433_.Position) > 30 then
                            DeleteToyRE:FireServer(v_u_428_)
                        end
                    end
                    task.wait(0.1)
                end
                v_u_433_ = nil
                v_u_422_ = nil
                v_u_428_ = nil
                v_u_432_:Disconnect()
                print("Pew!")
            end
        )
        v_u_428_:SetAttribute("Connected", true)
    end
    v_u_422_ = v_u_428_
end
local function v_u_435_()
    -- upvalues: (ref) v_u_422_, (ref) v_u_434_
    if v_u_422_ and v_u_422_.Parent ~= nil then
        return v_u_422_
    end
    v_u_434_()
end
local function v_u_442_(p436_)
    -- upvalues: (ref) v_u_435_, (ref) v_u_17_
    local v_u_437_ = v_u_435_()
    local v438_ = nil
    local v_u_439_ = v_u_17_.Character
    if v_u_439_ then
        v_u_439_ = v_u_439_:FindFirstChild("Head")
    end
    if v_u_437_ then
        v438_ = v_u_437_.PrimaryPart
    end
    if v_u_437_ and (v_u_439_ and v438_) then
        local v440_ = v_u_437_:FindFirstChild("StickyRemoverPart")
        if not v438_:FindFirstChild("SprayPosRemove") and v_u_437_:GetAttribute("AlreadySetOwnerShip") then
            SetModelProperties(v_u_437_)
            local v_u_441_ = Instance.new("BodyPosition", v438_)
            v_u_441_.Name = "SprayPosRemove"
            v_u_441_.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            Vector3.new(-453, math.random(50, 100), 1081)
            task.spawn(
                function()
                    -- upvalues: (ref) v_u_437_, (ref) v_u_441_, (ref) v_u_439_
                    while v_u_437_.Parent do
                        v_u_441_.Position = v_u_439_.Position + Vector3.new(10, 500, 0)
                        task.wait()
                    end
                end
            )
        end
        if v440_ and v_u_437_:GetAttribute("AlreadySetOwnerShip") then
            v440_.Position = p436_.Position
            task.wait()
            v440_.Position = v438_.Position
        end
    end
end
local v_u_443_ = nil
local v_u_444_ = nil
local function v_u_448_(p445_)
    if p445_ then
        local v446_ = p445_:FindFirstChild("EdiblePart")
        local v447_ = p445_:FindFirstChild("HoldPart")
        if v447_ then
            v447_ = v447_.RigidConstraint.Attachment1
        end
        if not (v446_ or v447_) then
            return true
        end
    end
end
local function v_u_466_()
    -- upvalues: (ref) v_u_19_, (ref) v_u_448_, (ref) v_u_17_, (ref) v_u_11_, (ref) v_u_23_, (ref) v_u_443_, (ref) v_u_444_
    local v449_ = GetPlayerCFrame()
    local v450_ = v_u_19_
    local v451_, v452_, v453_ = pairs(v450_:GetChildren())
    local v_u_454_ = nil
    while true do
        local v455_
        v453_, v455_ = v451_(v452_, v453_)
        if v453_ == nil then
            break
        end
        if v455_.Name == "FoodBanana" and (v455_:GetAttribute("RagdollToy") and v_u_448_(v455_)) then
            v_u_454_ = v455_
        end
    end
    if not v_u_454_ then
        local v456_ = v_u_19_:FindFirstChild("FoodBanana")
        if v456_ then
            if v_u_448_(v456_) then
                v456_:SetAttribute("RagdollToy", true)
            else
                local v457_ = v456_:FindFirstChild("EdiblePart")
                local v458_ = v456_.HoldPart
                local v459_ = v458_.RigidConstraint
                if v457_ and not v459_.Attachment1 then
                    local v460_ = {
                        v456_,
                        v_u_17_.Character
                    }
                    v458_.HoldItemRemoteFunction:InvokeServer(unpack(v460_))
                elseif
                    v457_ and v459_.Attachment1 and
                        (v459_.Attachment1:IsDescendantOf(v_u_17_.Character) and not v458_.EatingSound.IsPlaying)
                 then
                    v_u_11_.HoldEvents.Use:FireServer(v456_)
                    task.wait(0.5)
                elseif not v457_ and v459_.Attachment1 and v459_.Attachment1:IsDescendantOf(v_u_17_.Character) then
                    local v461_ = {
                        v456_,
                        CFrame.new(
                            v449_.Position.X,
                            v449_.Position.Y,
                            v449_.Position.Z,
                            -0.133750245,
                            -0.471861839,
                            0.871468484,
                            -3.7252903e-9,
                            0.879369617,
                            0.476139903,
                            -0.991015136,
                            0.0636838302,
                            -0.117615893
                        ),
                        Vector3.new(0, 97.69000244140625, 0)
                    }
                    v458_.DropItemRemoteFunction:InvokeServer(unpack(v461_))
                end
            end
        else
            local v462_ = {
                "FoodBanana",
                CFrame.new(
                    508.073517,
                    67.2614441,
                    -261.901917,
                    -0.133750245,
                    -0.471861839,
                    0.871468484,
                    -3.7252903e-9,
                    0.879369617,
                    0.476139903,
                    -0.991015136,
                    0.0636838302,
                    -0.117615893
                ),
                Vector3.new(0, 97.69000244140625, 0)
            }
            SpawnToy(v462_)
            BuyToy:InvokeServer("FoodBanana")
        end
    end
    if
        v_u_454_ and v_u_454_:FindFirstChild("HoldPart") and
            (v_u_454_.HoldPart:FindFirstChild("RigidConstraint") and not v_u_454_:GetAttribute("Connected"))
     then
        local v_u_464_ =
            v_u_454_.DescendantAdded:Connect(
            function(p463_)
                -- upvalues: (ref) v_u_17_, (ref) v_u_454_
                if p463_.Name == "PartOwner" and p463_.Value ~= v_u_17_.Name then
                    v_u_454_:SetAttribute("AlreadySetOwnerShip", nil)
                end
            end
        )
        local v_u_465_ = v_u_454_:FindFirstChild("HitboxPart")
        task.spawn(
            function()
                -- upvalues: (ref) v_u_454_, (ref) v_u_465_, (ref) v_u_23_, (ref) v_u_464_, (ref) v_u_443_, (ref) v_u_444_
                while v_u_454_.Parent do
                    if not v_u_454_:GetAttribute("AlreadySetOwnerShip") then
                        if SNOWshipOnce(v_u_465_) then
                            for _ = 1, 15 do
                                v_u_23_:FireServer(v_u_465_)
                                task.wait()
                            end
                            v_u_454_:SetAttribute("AlreadySetOwnerShip", true)
                        elseif Getdistancefromcharacter(v_u_465_.Position) > 30 then
                            DeleteToyRE:FireServer(v_u_454_)
                        end
                    end
                    task.wait(0.1)
                end
                v_u_464_:Disconnect()
                v_u_443_ = nil
                v_u_444_ = nil
                v_u_465_ = nil
            end
        )
        v_u_454_:SetAttribute("Connected", true)
    end
    v_u_443_ = v_u_454_
end
local function v_u_467_()
    -- upvalues: (ref) v_u_443_, (ref) v_u_466_
    if v_u_443_ and v_u_443_.Parent ~= nil then
        return v_u_443_
    end
    v_u_466_()
end
local function v_u_478_(p468_)
    -- upvalues: (ref) v_u_467_, (ref) v_u_17_, (ref) v_u_444_
    local v_u_469_ = v_u_467_()
    local v470_ = nil
    local v_u_471_ = v_u_17_.Character
    if v_u_471_ then
        v_u_471_ = v_u_471_:FindFirstChild("Head")
    end
    if v_u_469_ then
        v470_ = v_u_469_.PrimaryPart
    end
    if v_u_469_ and (v_u_471_ and v470_) then
        if not v_u_444_ then
            local v472_, v473_, v474_ = pairs(v_u_469_:GetChildren())
            while true do
                local v475_
                v474_, v475_ = v472_(v473_, v474_)
                if v474_ == nil then
                    break
                end
                if v475_.Name == "BananaPeel" and v475_:FindFirstChildOfClass("TouchTransmitter") then
                    v_u_444_ = v475_
                end
            end
            print("Done!")
        end
        local v476_ = v_u_444_
        v476_.Size = Vector3.new(2, 2, 2)
        v476_.Transparency = 1
        if not v470_:FindFirstChild("FoodBananaPosRemove") and v_u_469_:GetAttribute("AlreadySetOwnerShip") then
            SetModelProperties(v_u_469_)
            local v_u_477_ = Instance.new("BodyPosition", v_u_469_.PrimaryPart)
            v_u_477_.Name = "FoodBananaPosRemove"
            v_u_477_.MaxForce = Vector3.new(12500, 12500, 12500)
            task.spawn(
                function()
                    -- upvalues: (ref) v_u_469_, (ref) v_u_477_, (ref) v_u_471_
                    while v_u_469_.Parent do
                        v_u_477_.Position = v_u_471_.Position + Vector3.new(0, 500, 0)
                        task.wait()
                    end
                end
            )
        end
        if v476_ and (p468_ and v_u_469_:GetAttribute("AlreadySetOwnerShip")) then
            v476_.Position = p468_.Position
            task.wait()
            v476_.Position = v470_.Position
        end
    end
end
local v_u_479_ = nil
holdfirePartFound = nil
function checkHoldFirePart()
    -- upvalues: (ref) v_u_19_
    local v480_ = v_u_19_
    local v481_, v482_, v483_ = pairs(v480_:GetChildren())
    local v484_ = nil
    while true do
        local v485_
        v483_, v485_ = v481_(v482_, v483_)
        if v483_ == nil then
            break
        end
        if v485_.Name == "Campfire" and not v485_:GetAttribute("FirePlayerPart") then
            if v485_.FirePlayerPart.CanBurn.Value then
                v484_ = v485_
            end
        end
    end
    if not v484_ then
        local v486_ = {
            "Campfire",
            CFrame.new(
                508.073517,
                67.2614441,
                -261.901917,
                -0.133750245,
                -0.471861839,
                0.871468484,
                -3.7252903e-9,
                0.879369617,
                0.476139903,
                -0.991015136,
                0.0636838302,
                -0.117615893
            ),
            Vector3.new(0, 97.69000244140625, 0)
        }
        SpawnToy(v486_)
        BuyToy:InvokeServer("Campfire")
    end
    holdfirePartFound = v484_
end
local function v_u_487_()
    if holdfirePartFound and holdfirePartFound.Parent ~= nil then
        return holdfirePartFound
    end
    checkHoldFirePart()
end
local function v_u_500_()
    -- upvalues: (ref) v_u_19_, (ref) v_u_17_, (ref) v_u_487_, (ref) v_u_479_
    local v488_ = GetPlayerCFrame()
    local v489_ = v_u_19_
    local v490_, v491_, v492_ = pairs(v489_:GetChildren())
    local v_u_493_ = nil
    local v_u_494_ = nil
    while true do
        local v495_
        v492_, v495_ = v490_(v491_, v492_)
        if v492_ == nil then
            break
        end
        if
            v495_.Name == "Campfire" and
                (v495_.PrimaryPart and
                    (Getdistancefromcharacter(v495_.PrimaryPart.Position) < 30 and v495_.FirePlayerPart.CanBurn.Value))
         then
            v_u_493_ = v495_
        end
    end
    if not v_u_493_ then
        if v488_ then
            local v496_ = {
                "Campfire",
                CFrame.new(
                    v488_.Position.X,
                    v488_.Position.Y,
                    v488_.Position.Z,
                    -0.133750245,
                    -0.471861839,
                    0.871468484,
                    -3.7252903e-9,
                    0.879369617,
                    0.476139903,
                    -0.991015136,
                    0.0636838302,
                    -0.117615893
                ),
                Vector3.new(0, 97.69000244140625, 0)
            }
            SpawnToy(v496_)
        end
        BuyToy:InvokeServer("Campfire")
    end
    if
        v_u_493_ and v_u_493_:FindFirstChild("FirePlayerPart") and
            (v_u_493_.FirePlayerPart:FindFirstChild("CanBurn") and not v_u_493_:GetAttribute("Connected"))
     then
        local v_u_498_ =
            v_u_493_.DescendantAdded:Connect(
            function(p497_)
                -- upvalues: (ref) v_u_17_, (ref) v_u_493_
                if p497_.Name == "PartOwner" and p497_.Value ~= v_u_17_.Name then
                    v_u_493_:SetAttribute("AlreadySetOwnerShip", false)
                end
            end
        )
        task.spawn(
            function()
                -- upvalues: (ref) v_u_494_, (ref) v_u_493_, (ref) v_u_487_, (ref) v_u_498_
                lastpos = GetPlayerCFrame()
                v_u_494_ = v_u_493_.FirePlayerPart
                while v_u_493_.Parent do
                    local v499_ = not v_u_493_.FirePlayerPart.CanBurn.Value and v_u_487_()
                    if v499_ then
                        v_u_494_.Position = v499_.FirePlayerPart.Position
                    end
                    if not v_u_493_:GetAttribute("AlreadySetOwnerShip") then
                        if SNOWshipOnce(v_u_494_) then
                            v_u_493_:SetAttribute("AlreadySetOwnerShip", true)
                        elseif Getdistancefromcharacter(v_u_494_.Position) > 30 then
                            DeleteToyRE:FireServer(v_u_493_)
                        end
                    end
                    task.wait(0.1)
                end
                v_u_498_:Disconnect()
                print("Pew!")
            end
        )
        v_u_493_:SetAttribute("Connected", true)
    end
    v_u_479_ = v_u_493_
end
local function v_u_501_()
    -- upvalues: (ref) v_u_479_, (ref) v_u_500_
    if v_u_479_ and v_u_479_.Parent ~= nil then
        return v_u_479_
    end
    v_u_500_()
end
local function v_u_509_(p502_)
    -- upvalues: (ref) v_u_501_, (ref) v_u_17_
    local v_u_503_ = v_u_501_()
    local v504_ = nil
    local v_u_505_ = v_u_17_.Character
    if v_u_505_ then
        v_u_505_ = v_u_505_:FindFirstChild("Head")
    end
    if v_u_503_ then
        v504_ = v_u_503_.PrimaryPart
    end
    if v_u_503_ and (v_u_505_ and v504_) then
        local v506_ = v_u_503_:FindFirstChild("FirePlayerPart")
        local v507_ = v504_:FindFirstChild("CampfirePosRemove")
        v506_.Size = Vector3.new(2, 2, 2)
        if not v507_ and v_u_503_:GetAttribute("AlreadySetOwnerShip") then
            SetModelProperties(v_u_503_)
            local v_u_508_ = Instance.new("BodyPosition", v_u_503_.PrimaryPart)
            v_u_508_.Name = "CampfirePosRemove"
            v_u_508_.MaxForce = Vector3.new(12500, 12500, 12500)
            Vector3.new(-453, math.random(50, 100), 1081)
            task.spawn(
                function()
                    -- upvalues: (ref) v_u_503_, (ref) v_u_508_, (ref) v_u_505_
                    while v_u_503_.Parent do
                        v_u_508_.Position = v_u_505_.Position + Vector3.new(5, 500, 0)
                        task.wait()
                    end
                end
            )
        end
        if v506_ and (p502_ and (v_u_503_:GetAttribute("AlreadySetOwnerShip") and v504_)) then
            v506_.Position = p502_.Position
            task.wait()
            v506_.Position = v504_.Position
        end
    end
end
smalldiceToyFound = nil
function CheckFakeAim()
    -- upvalues: (ref) v_u_19_, (ref) v_u_17_
    local v510_ = GetPlayerCFrame()
    local v511_ = v_u_19_
    local v512_, v513_, v514_ = pairs(v511_:GetChildren())
    local v_u_515_ = nil
    while true do
        local v516_
        v514_, v516_ = v512_(v513_, v514_)
        if v514_ == nil then
            break
        end
        if
            v516_.Name == "DiceSmall" and
                (v516_:FindFirstChild("Center") and
                    (v516_.PrimaryPart and Getdistancefromcharacter(v516_.PrimaryPart.Position) < 30))
         then
            v_u_515_ = v516_
        end
    end
    if not v_u_515_ then
        if v510_ then
            local v517_ = {
                "DiceSmall",
                CFrame.new(
                    v510_.Position.X,
                    v510_.Position.Y,
                    v510_.Position.Z,
                    -0.133750245,
                    -0.471861839,
                    0.871468484,
                    -3.7252903e-9,
                    0.879369617,
                    0.476139903,
                    -0.991015136,
                    0.0636838302,
                    -0.117615893
                ),
                Vector3.new(0, 97.69000244140625, 0)
            }
            SpawnToy(v517_)
        end
        BuyToy:InvokeServer("DiceSmall")
    end
    if v_u_515_ and (v_u_515_:FindFirstChild("Center") and not v_u_515_:GetAttribute("Connected")) then
        local v_u_519_ =
            v_u_515_.DescendantAdded:Connect(
            function(p518_)
                -- upvalues: (ref) v_u_17_, (ref) v_u_515_
                if p518_.Name == "PartOwner" and p518_.Value ~= v_u_17_.Name then
                    v_u_515_:SetAttribute("AlreadySetOwnerShip", false)
                end
            end
        )
        local v_u_520_ = v_u_515_:FindFirstChild("SoundPart")
        task.spawn(
            function()
                -- upvalues: (ref) v_u_515_, (ref) v_u_520_, (ref) v_u_519_
                while v_u_515_.Parent do
                    if not v_u_515_:GetAttribute("AlreadySetOwnerShip") then
                        if SNOWshipOnce(v_u_520_) then
                            v_u_515_:SetAttribute("AlreadySetOwnerShip", true)
                        elseif Getdistancefromcharacter(v_u_520_.Position) > 30 then
                            DeleteToyRE:FireServer(v_u_515_)
                        end
                    end
                    if not _G.FireworkEffectSpam then
                        DeleteToyRE:FireServer(v_u_515_)
                    end
                    task.wait(0.1)
                end
                v_u_520_ = nil
                smalldiceToyFound = nil
                v_u_515_ = nil
                v_u_519_:Disconnect()
                print("Pew!")
            end
        )
        v_u_515_:SetAttribute("Connected", true)
    end
    smalldiceToyFound = v_u_515_
end
function GetFakeAim()
    if smalldiceToyFound and smalldiceToyFound.Parent ~= nil then
        return smalldiceToyFound
    end
    CheckFakeAim()
end
function GetFakeAim2()
    -- upvalues: (ref) v_u_17_, (ref) v_u_7_, (ref) v_u_19_
    local v_u_521_ = GetFakeAim()
    local v522_ = v_u_17_.Character
    local v523_
    if v_u_521_ then
        v523_ = v_u_521_.PrimaryPart
    else
        v523_ = nil
    end
    if v_u_521_ and (v522_ and v523_) then
        hitpart = v_u_521_:FindFirstChild("StickyRemoverPart")
        if not v523_:FindFirstChild("AimPosRemove") and v_u_521_:GetAttribute("AlreadySetOwnerShip") then
            SetAimPart(v_u_521_)
            local v_u_524_ = Instance.new("BodyPosition", v523_)
            v_u_524_.Name = "AimPosRemove"
            v_u_524_.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            v_u_524_.P = 40000
            v_u_524_.D = 950
            local v_u_525_ = nil
            local v_u_526_ = nil
            local v_u_527_ = nil
            task.spawn(
                function()
                    -- upvalues: (ref) v_u_521_, (ref) v_u_17_, (ref) v_u_525_, (ref) v_u_526_, (ref) v_u_527_, (ref) v_u_7_, (ref) v_u_19_, (ref) v_u_524_
                    while v_u_521_.Parent do
                        if v_u_17_.Character and v_u_17_.Character:FindFirstChild("CamPart") then
                            v_u_525_ =
                                Ray.new(
                                v_u_17_.Character.CamPart.Position,
                                v_u_17_.Character.CamPart.CFrame.lookVector * 5000
                            )
                            local v528_, v529_ =
                                v_u_7_:FindPartOnRayWithIgnoreList(
                                v_u_525_,
                                {
                                    v_u_17_.Character,
                                    v_u_19_
                                }
                            )
                            v_u_527_ = v529_
                            v_u_526_ = v528_
                            if v_u_526_ and v_u_527_ then
                                v_u_524_.Position = v_u_527_
                            end
                        end
                        task.wait()
                    end
                end
            )
        end
        return v523_
    end
end
local v_u_530_ = nil
local function v_u_539_()
    -- upvalues: (ref) v_u_19_, (ref) v_u_530_
    local v531_ = GetPlayerCharacter()
    local v532_ = v_u_19_
    local v533_, v534_, v535_ = pairs(v532_:GetChildren())
    local v536_ = nil
    while true do
        local v537_
        v535_, v537_ = v533_(v534_, v535_)
        if v535_ == nil then
            break
        end
        if v537_.Name == "CreatureBlobman" then
            v536_ = v537_
        end
    end
    if not v536_ then
        if v_u_19_:FindFirstChild("CreatureBlobman") then
            v536_ = v_u_19_.CreatureBlobman
        else
            local v538_ = {
                "CreatureBlobman",
                CFrame.new(v531_.Head.Position),
                Vector3.new(0, 97.69000244140625, 0)
            }
            SpawnToy(v538_)
            BuyToy:InvokeServer("CreatureBlobman")
        end
    end
    v_u_530_ = v536_
end
local function v_u_540_()
    -- upvalues: (ref) v_u_530_, (ref) v_u_539_
    if v_u_530_ and v_u_530_.Parent then
        return v_u_530_
    end
    v_u_539_()
end
local v541_ = v_u_4_
local v542_ =
    v_u_4_.MakeWindow(
    v541_,
    {
        ["Name"] = "Fling Things and people",
        ["HidePremium"] = true,
        ["SaveConfig"] = true,
        ["ConfigFolder"] = "FTAPConfig",
        ["IntroEnabled"] = false,
        ["KeyToOpenWindow"] = "M",
        ["FreeMouse"] = true
    }
)
local v543_ =
    v542_:MakeTab(
    {
        ["Name"] = "Combat",
        ["Icon"] = "rbxassetid://7485051715",
        ["PremiumOnly"] = false
    }
)
LongReachGrab_Player =
    v542_:MakeTab(
    {
        ["Name"] = "Blobman Grab",
        ["Icon"] = "rbxassetid://7734058599",
        ["PremiumOnly"] = false
    }
)
local v544_ =
    v542_:MakeTab(
    {
        ["Name"] = "Invincibility",
        ["Icon"] = "rbxassetid://7734056608",
        ["PremiumOnly"] = false
    }
)
local v545_ =
    v542_:MakeTab(
    {
        ["Name"] = "Player",
        ["Icon"] = "rbxassetid://7743871002",
        ["PremiumOnly"] = false
    }
)
Esp_Tab =
    v542_:MakeTab(
    {
        ["Name"] = "ESP",
        ["Icon"] = "rbxassetid://7733774602",
        ["PremiumOnly"] = false
    }
)
local v546_ =
    v542_:MakeTab(
    {
        ["Name"] = "Explosions",
        ["Icon"] = "rbxassetid://17837704089",
        ["PremiumOnly"] = false
    }
)
local v547_ =
    v542_:MakeTab(
    {
        ["Name"] = "Teleport",
        ["Icon"] = "rbxassetid://7733992829",
        ["PremiumOnly"] = false
    }
)
local v548_ =
    v542_:MakeTab(
    {
        ["Name"] = "Custom Line",
        ["Icon"] = "rbxassetid://7734022107",
        ["PremiumOnly"] = false
    }
)
local v549_ =
    v542_:MakeTab(
    {
        ["Name"] = "Grab Auras",
        ["Icon"] = "rbxassetid://7733955740",
        ["PremiumOnly"] = false
    }
)
local v550_ =
    v542_:MakeTab(
    {
        ["Name"] = "Keybinds",
        ["Icon"] = "rbxassetid://11710306232",
        ["PremiumOnly"] = false
    }
)
local v551_ =
    v542_:MakeTab(
    {
        ["Name"] = "Loop Players",
        ["Icon"] = "rbxassetid://7733964640",
        ["PremiumOnly"] = false
    }
)
local v552_ =
    v542_:MakeTab(
    {
        ["Name"] = "Auto",
        ["Icon"] = "rbxassetid://7733916988",
        ["PremiumOnly"] = false
    }
)
local v553_ =
    v542_:MakeTab(
    {
        ["Name"] = "Misc",
        ["Icon"] = "rbxassetid://7733917120",
        ["PremiumOnly"] = false
    }
)
local v_u_554_ =
    v542_:MakeTab(
    {
        ["Name"] = "Discord Server",
        ["Icon"] = "rbxassetid://16570630989",
        ["PremiumOnly"] = false
    }
)
local v555_ =
    v542_:MakeTab(
    {
        ["Name"] = "Config",
        ["Icon"] = "rbxassetid://7734053495",
        ["PremiumOnly"] = false
    }
)
v542_:MakeTab(
    {
        ["Name"] = "Premium Info",
        ["Icon"] = "rbxassetid://7734053495",
        ["PremiumOnly"] = false
    }
)
local v556_ =
    v542_:MakeTab(
    {
        ["Name"] = "Credits",
        ["Icon"] = "rbxassetid://7733687281",
        ["PremiumOnly"] = false
    }
)
local v_u_557_ = nil
task.spawn(
    function()
        -- upvalues: (ref) v_u_557_, (ref) v_u_554_, (ref) v_u_33_
        local v558_, v559_ =
            pcall(
            function()
                return loadstring(game:HttpGet("https://pastebin.com/raw/Q4iUTG48"))()
            end
        )
        v_u_557_ = "https://discord.gg/ENnZ4W9eMN"
        local v560_ =
            v_u_554_:AddSection(
            {
                ["Name"] = "Discord Server"
            }
        )
        v560_:AddLabel(v_u_557_)
        v560_:AddButton(
            {
                ["Name"] = "Copy Discord Server Link",
                ["Callback"] = function()
                    -- upvalues: (ref) v_u_557_, (ref) v_u_33_
                    setclipboard(v_u_557_)
                    v_u_33_("Copied to your clipboard")
                end
            }
        )
        v560_:AddLabel("Join my discord server to see updates!")
    end
)
local CRACKED_CREDITS =
    v556_:AddSection(
    {
        ["Name"] = "CRACK CREDITS!"
    }
)
local v561_ =
    v556_:AddSection(
    {
        ["Name"] = "1# Medal credits"
    }
)
local v562_ =
    v556_:AddSection(
    {
        ["Name"] = "2# Medal credits"
    }
)
local v563_ =
    v556_:AddSection(
    {
        ["Name"] = "3# Medal credits"
    }
)
local v_u_564_ = game:GetService("UserService")
local v_u_565_ = {
    90063030,
    2298910483,
    1030559478,
    1762306425,
    542649826,
    237152138,
    1390422876,
    3089724826,
    882860613,
    7280113503
}
local v566_, v567_ =
    ypcall(
    function()
        -- upvalues: (ref) v_u_564_, (ref) v_u_565_
        return v_u_564_:GetUserInfosByUserIdsAsync(v_u_565_)
    end
)
local v568_, v569_, v570_ = pairs(v_u_565_)
local v571_ = v_u_565_
local v572_ = {}
while true do
    local v573_
    v570_, v573_ = v568_(v569_, v570_)
    if v570_ == nil then
        break
    end
    local v574_, v575_, v576_ = pairs(v567_)
    while true do
        local v577_, v578_ = v574_(v575_, v576_)
        if v577_ == nil then
            break
        end
        v576_ = v577_
        if v578_.Id == v573_ then
            table.insert(v572_, v578_)
        end
    end
end
local v579_, v580_, v581_ = pairs(v571_)
local v582_ = v572_
while true do
    local v583_, _ = v579_(v580_, v581_)
    if v583_ == nil then
        break
    end
    v581_ = v583_
    if not v572_[v583_] then
        v582_[v583_] = {
            ["DisplayName"] = "deleted",
            ["Username"] = "deleted"
        }
    end
end
if v566_ then
    v561_:AddParagraph("Luna! I cracked this hub!")
    v561_:AddParagraph(
        v572_[1].DisplayName .. " (" .. v572_[1].Username .. ")",
        "Thanks for made the whole GUI (Combat, Player, Auras and more) XD!"
    )
    v561_:AddParagraph(
        v572_[2].DisplayName .. " (" .. v572_[2].Username .. ")",
        "Thanks for inspiration to create the blobman functions, Massless Grab and Line color changer script!"
    )
    v561_:AddParagraph(
        v572_[3].DisplayName ..
            " (" .. v572_[3].Username .. ") " .. "and " .. v572_[6].DisplayName .. " (" .. v572_[6].Username .. ")",
        "Thanks for sharing the Attraction Aura, Silent Aim, Further Extend scripts!"
    )
    v561_:AddParagraph(
        v572_[7].DisplayName .. " (" .. v572_[7].Username .. ")",
        "Thanks for helping to fix kick stuff and anti-blobman"
    )
    v561_:AddParagraph(
        v572_[8].DisplayName .. " (" .. v572_[8].Username .. ")",
        "Thanks for explosion stuff, fireproximityprompt fix and script updater"
    )
    v561_:AddParagraph(v572_[9].DisplayName .. " (" .. v572_[9].Username .. ")", "Thanks for laggy stuff!")
    v561_:AddParagraph(
        v572_[10].DisplayName .. " (" .. v572_[10].Username .. ")",
        "Thanks for Anchor Objects Glue/Compile"
    )
    v562_:AddParagraph(v572_[4].DisplayName .. " (" .. v572_[4].Username .. ")", "Thanks for releasing script!")
    v563_:AddParagraph(v572_[5].DisplayName .. " (" .. v572_[5].Username .. ")", "Thanks for testing scripts")
end
PerspectiveEffect = Instance.new("ScreenGui")
ImageLabel = Instance.new("ImageLabel")
PerspectiveSaturation = Instance.new("ColorCorrectionEffect", v8_)
PerspectiveEffect.Name = "PerspectiveEffect"
PerspectiveEffect.DisplayOrder = -5
PerspectiveEffect.Enabled = true
PerspectiveEffect.IgnoreGuiInset = true
PerspectiveEffect.ResetOnSpawn = false
PerspectiveEffect.Parent = v_u_17_.PlayerGui
ImageLabel.Parent = PerspectiveEffect
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1
ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Size = UDim2.new(1, 0, 1, 0)
ImageLabel.Image = "rbxassetid://8586979842"
ImageLabel.ImageTransparency = 1
PerspectiveSaturation.Enabled = true
PerspectiveSaturation.Saturation = 0
imagestransparencyeffect = 0.65
saturationvalue = -0.3
t1p = TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
t2p = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
perspectiveON_effect1 =
    v_u_9_:Create(
    ImageLabel,
    t1p,
    {
        ["ImageTransparency"] = imagestransparencyeffect
    }
)
perspectiveON_effect2 =
    v_u_9_:Create(
    PerspectiveSaturation,
    t1p,
    {
        ["Saturation"] = saturationvalue
    }
)
perspectiveOff_effect1 =
    v_u_9_:Create(
    ImageLabel,
    t2p,
    {
        ["ImageTransparency"] = 1
    }
)
perspectiveOff_effect2 =
    v_u_9_:Create(
    PerspectiveSaturation,
    t2p,
    {
        ["Saturation"] = 0
    }
)
function PerspectiveOnEffect()
    perspectiveON_effect1:Play()
    perspectiveON_effect2:Play()
end
function PerspectiveOffEffect()
    perspectiveOff_effect1:Play()
    perspectiveOff_effect2:Play()
end
local function v_u_585_(p584_)
    if p584_ and _G.PerspectiveEffectsAllow then
        PerspectiveOnEffect()
    else
        PerspectiveOffEffect()
    end
end
gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
CAG = v_u_17_.PlayerGui:FindFirstChild("ContextActionGui")
if v_u_10_.TouchEnabled then
    gui.Parent = v_u_17_.PlayerGui
end
if CAG then
    CAG.DescendantAdded:Connect(
        function(p586_)
            if _G.FutherExtend and p586_:IsA("ImageButton") then
                local v587_ = p586_:WaitForChild("ActionIcon")
                if v587_.Image == "rbxassetid://9603826756" or v587_.Image == "rbxassetid://9603831913" then
                    v587_.Parent.Visible = false
                end
            end
        end
    )
end
scriptToGetSenv = nil
senv = nil
minDistance = 3
pcDistance = 0
imageButton = Instance.new("ImageButton")
imageButton.Size = UDim2.new(0, 45, 0, 45)
imageButton.Position = UDim2.new(1, -70, 1, -259)
imageButton.Image = "rbxassetid://97166444"
imageButton.BackgroundTransparency = 1
imageButton.ImageTransparency = 0.2
imageButton.Visible = false
imageButton.ImageColor3 = Color3.fromRGB(142, 142, 142)
imageButton.Parent = gui
imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(1, 0, 1, 0)
imageLabel.Image = "rbxassetid://9603831913"
imageLabel.BackgroundTransparency = 1
imageLabel.Parent = imageButton
imageButtonDe = Instance.new("ImageButton")
imageButtonDe.Size = UDim2.new(0, 45, 0, 45)
imageButtonDe.Position = UDim2.new(1, -70, 1, -211)
imageButtonDe.Image = "rbxassetid://97166444"
imageButtonDe.BackgroundTransparency = 1
imageButtonDe.ImageTransparency = 0.2
imageButtonDe.Visible = false
imageButtonDe.ImageColor3 = Color3.fromRGB(142, 142, 142)
imageButtonDe.Parent = gui
imageLabelDe = Instance.new("ImageLabel")
imageLabelDe.Size = UDim2.new(1, 0, 1, 0)
imageLabelDe.Image = "rbxassetid://9603826756"
imageLabelDe.BackgroundTransparency = 1
imageLabelDe.Parent = imageButtonDe
IncreaseLineExtend = 0
function buttonClicked()
    if senv and (senv.distance and _G.FutherExtend) then
        senv.distance = (senv.distance or 0) + IncreaseLineExtend
        if senv.distance < minDistance then
            senv.distance = minDistance
        end
    end
end
function buttonClickedDE()
    if senv and (senv.distance and _G.FutherExtend) then
        senv.distance = (senv.distance or 0) - IncreaseLineExtend
        if senv.distance < minDistance then
            senv.distance = minDistance
        end
    end
end
function toggleButtonState(p588_)
    if p588_ and _G.FutherExtend then
        imageButton.Visible = true
        imageButton.Active = true
        imageButtonDe.Visible = true
        imageButtonDe.Active = true
    else
        imageButton.Visible = false
        imageButton.Active = false
        imageButtonDe.Visible = false
        imageButtonDe.Active = false
    end
end
v_u_7_.ChildAdded:Connect(
    function(p589_)
        -- upvalues: (ref) v_u_10_, (ref) v_u_7_
        if p589_.Name == "GrabParts" and p589_:IsA("Model") then
            if _G.FutherExtend and v_u_10_.MouseEnabled then
                local v_u_590_ = p589_
                GetPlayerCharacter()
                local v591_ = v_u_590_
                v_u_590_.WaitForChild(v591_, "GrabPart")
                local v592_ = v_u_590_
                v_u_590_.WaitForChild(v592_, "DragPart")
                local v_u_593_ = Instance.new("BodyPosition", v_u_590_.GrabPart)
                v_u_593_.MaxForce = Vector3.new(275000, 275000, 275000)
                v_u_593_.P = 20000
                v_u_593_.D = 950
                v_u_593_.Position = v_u_590_.GrabPart.WeldConstraint.Part1.Position
                pcDistance = (v_u_590_.GrabPart.Position - v_u_7_.CurrentCamera.CFrame.Position).Magnitude
                v_u_590_.DragPart.AlignPosition.Enabled = false
                task.spawn(
                    function()
                        -- upvalues: (ref) v_u_590_, (ref) v_u_593_, (ref) v_u_7_
                        while v_u_590_.Parent do
                            v_u_593_.Position =
                                v_u_7_.Camera.CFrame.Position + v_u_7_.Camera.CFrame.LookVector * pcDistance
                            task.wait()
                        end
                        pcDistance = 0
                        v_u_593_:Destroy()
                    end
                )
            end
            toggleButtonState(true)
        end
    end
)
workspace.ChildRemoved:Connect(
    function(p594_)
        if p594_.Name == "GrabParts" and p594_:IsA("Model") then
            toggleButtonState(false)
        end
    end
)
local v_u_595_ = false
local function v_u_596_()
    -- upvalues: (ref) v_u_595_
    while v_u_595_ do
        buttonClicked()
        wait(0.1)
    end
end
local function v_u_597_()
    -- upvalues: (ref) v_u_595_
    while v_u_595_ do
        buttonClickedDE()
        wait(0.1)
    end
end
local v_u_598_ = v_u_10_
imageButton.InputBegan:Connect(
    function(p599_, p600_)
        -- upvalues: (ref) v_u_598_, (ref) v_u_595_, (ref) v_u_596_
        if not p600_ and (v_u_598_.TouchEnabled and p599_.UserInputType == Enum.UserInputType.Touch) then
            v_u_595_ = true
            v_u_596_()
        end
    end
)
imageButton.InputEnded:Connect(
    function(p601_)
        -- upvalues: (ref) v_u_598_, (ref) v_u_595_
        if v_u_598_.TouchEnabled and p601_.UserInputType == Enum.UserInputType.Touch then
            v_u_595_ = false
        end
    end
)
imageButtonDe.InputBegan:Connect(
    function(p602_, p603_)
        -- upvalues: (ref) v_u_598_, (ref) v_u_595_, (ref) v_u_597_
        if not p603_ and (v_u_598_.TouchEnabled and p602_.UserInputType == Enum.UserInputType.Touch) then
            v_u_595_ = true
            v_u_597_()
        end
    end
)
imageButtonDe.InputEnded:Connect(
    function(p604_)
        -- upvalues: (ref) v_u_598_, (ref) v_u_595_
        if v_u_598_.TouchEnabled and p604_.UserInputType == Enum.UserInputType.Touch then
            v_u_595_ = false
        end
    end
)
v_u_10_.InputChanged:Connect(
    function(p605_)
        if p605_.UserInputType == Enum.UserInputType.MouseWheel then
            if pcDistance < 11 then
                pcDistance = 11
            end
            if p605_.Position.Z <= 0 then
                if p605_.Position.Z < 0 then
                    pcDistance = pcDistance - IncreaseLineExtend
                end
            else
                pcDistance = pcDistance + IncreaseLineExtend
            end
        end
    end
)
getgenv().Settings = {
    ["Fov"] = 150,
    ["Hitbox"] = {
        "Head",
        "Torso",
        "Left Leg",
        "Right Leg"
    },
    ["FovCircle"] = false
}
local v_u_606_ = v_u_5_
local v_u_607_ = v_u_17_
local v_u_608_ = v_u_7_.CurrentCamera
local v609_ = v_u_607_
v_u_607_.GetMouse(v609_)
local v_u_610_ = nil
local function v_u_622_(_)
    -- upvalues: (ref) v_u_606_, (ref) v_u_607_, (ref) v_u_608_
    local v611_ = math.huge
    local v612_ = v_u_606_
    local v613_, v614_, v615_ = pairs(v612_:GetPlayers())
    local v616_ = nil
    while true do
        local v617_
        v615_, v617_ = v613_(v614_, v615_)
        if v615_ == nil then
            break
        end
        if
            v617_.Name ~= v_u_607_.Name and (v617_.Character and (v_u_607_ and v_u_607_.Character)) and
                v_u_607_.Character:FindFirstChild("HumanoidRootPart")
         then
            local v618_ = v617_.Character:FindFirstChild("HumanoidRootPart")
            if v618_ then
                local v619_ = v_u_607_.Character.HumanoidRootPart.Position
                local _, v620_ = v_u_608_:WorldToScreenPoint(v618_.Position)
                if v620_ then
                    local v621_ = (v619_ - v618_.Position).magnitude
                    if v621_ < v611_ then
                        v616_ = v617_
                        v611_ = v621_
                    end
                end
            end
        end
    end
    return v616_
end
local v_u_623_ = nil
local v_u_624_ = nil
local v_u_625_ = nil
local v_u_626_ = nil
local v_u_627_ = Drawing.new("Circle")
local v_u_628_ = Drawing.new("Circle")
v_u_14_.RenderStepped:Connect(
    function()
        -- upvalues: (ref) v_u_627_, (ref) v_u_608_, (ref) v_u_628_, (ref) v_u_623_, (ref) v_u_622_
        if v_u_627_ then
            v_u_627_.Radius = getgenv().Settings.Fov
            v_u_627_.Thickness = 2
            v_u_627_.Position = Vector2.new(v_u_608_.ViewportSize.X / 2, v_u_608_.ViewportSize.Y / 2 + 36)
            v_u_627_.Transparency = 1
            v_u_627_.Filled = false
            v_u_627_.Color = Color3.fromRGB(255, 255, 255)
            v_u_627_.Visible = getgenv().Settings.FovCircle
            v_u_627_.ZIndex = 2
        end
        if v_u_628_ then
            v_u_628_.Radius = getgenv().Settings.Fov
            v_u_628_.Thickness = 4
            v_u_628_.Position = Vector2.new(v_u_608_.ViewportSize.X / 2, v_u_608_.ViewportSize.Y / 2 + 36)
            v_u_628_.Transparency = 1
            v_u_628_.Filled = false
            v_u_628_.Color = Color3.new()
            v_u_628_.Visible = getgenv().Settings.FovCircle
            v_u_628_.ZIndex = 1
        end
        v_u_623_ = v_u_622_(getgenv().Settings.Fov)
    end
)
local function v_u_632_(p629_, p630_, p631_)
    return (p630_ - p629_).Unit * p631_
end
if hookmetamethod then
    local v_u_633_ = nil
    v_u_633_ =
        hookmetamethod(
        game,
        "__namecall",
        function(...)
            local v634_ = {...} -- 蜈・・蠑墓焚
            local v635_ = v634_[1]
            local v636_ = getnamecallmethod()

            if
                v635_ == workspace and not checkcaller() and v636_ == "Raycast" and v_u_623_ and v_u_623_.Character and
                    v_u_623_.Character:FindFirstChild("HumanoidRootPart") and
                    v_u_607_ and
                    v_u_607_.Character and
                    v_u_607_.Character:FindFirstChild("HumanoidRootPart") and
                    v_u_623_.Character:FindFirstChild("Humanoid") and
                    v_u_623_.Character.Humanoid.Health > 0 and
                    not v_u_623_:FindFirstChild("InPlot") and
                    _G.SilentAim
             then
                local v637_ =
                    (v_u_607_.Character.HumanoidRootPart.Position - v_u_623_.Character.HumanoidRootPart.Position).magnitude
                v_u_624_ = math.random(1, #getgenv().Settings.Hitbox)
                v_u_625_ = getgenv().Settings.Hitbox[v_u_624_]
                v_u_626_ = v_u_623_.Character:FindFirstChild(v_u_625_)

                if v637_ <= v_u_610_ and v_u_626_ then
                    -- Raycast 縺ｮ譁ｹ蜷代ｒ豁｣縺励￥菴懈・
                    local origin = v634_[2]
                    local targetPos = v_u_626_.Position
                    if v_u_632_ then
                        v634_[3] = v_u_632_(origin, targetPos, 1000)
                    else
                        -- v_u_632_ 縺檎┌縺代ｌ縺ｰ騾壼ｸｸ縺ｮ險育ｮ・                        v634_[3] = (targetPos - origin).Unit * 1000
                    end

                    local rp = RaycastParams.new()
                    rp.FilterDescendantsInstances = {v_u_623_.Character}
                    rp.FilterType = Enum.RaycastFilterType.Include
                    v634_[4] = rp

                    -- 繧ｯ繝ｪ繝ｼ繝ｳ繧｢繝・・
                    v_u_624_ = nil
                    v_u_625_ = nil
                    v_u_626_ = nil
                end
            end

            return v_u_633_(unpack(v634_))
        end
    )
end
local function v_u_643_()
    -- upvalues: (ref) v_u_7_
    local v638_, v639_, v640_ = pairs(v_u_7_.Slots:GetChildren())
    local v641_ = nil
    while true do
        local v642_
        v640_, v642_ = v638_(v639_, v640_)
        if v640_ == nil then
            break
        end
        if v642_.SlotHandle.LightBall.Material ~= Enum.Material.Neon then
            v641_ = false
            break
        end
        v641_ = true
    end
    return v641_
end
local function v_u_646_(p644_)
    -- upvalues: (ref) v_u_17_
    local v645_
    if v_u_17_.Character and v_u_17_.Character:FindFirstChild("HumanoidRootPart") then
        v645_ = v_u_17_.Character.HumanoidRootPart
    else
        v645_ = nil
    end
    if p644_ == "Spin" then
        if v645_ then
            _G.SavedPositionInSpin = v645_.CFrame
        end
    elseif p644_ == "House" and v645_ then
        _G.SavedPositionOutHouse = v645_.CFrame
    end
end
local function v_u_649_(p647_)
    -- upvalues: (ref) v_u_17_
    local v648_
    if v_u_17_.Character and v_u_17_.Character:FindFirstChild("HumanoidRootPart") then
        v648_ = v_u_17_.Character.HumanoidRootPart
    else
        v648_ = nil
    end
    if p647_ == "Spin" then
        if v648_ then
            v648_.CFrame = _G.SavedPositionInSpin
        end
    elseif p647_ == "House" and v648_ then
        v648_.CFrame = _G.SavedPositionOutHouse
    end
end
local v650_ =
    v552_:AddSection(
    {
        ["Name"] = "Auto Get Coins"
    }
)
local v651_ =
    v552_:AddSection(
    {
        ["Name"] = "Auto Time-Reset"
    }
)
local v652_ =
    v552_:AddSection(
    {
        ["Name"] = "Auto Claim-Plot"
    }
)
timelefttextlabelingame = v_u_7_.Slots.Slots.Screen.SlotGui.TimeLeftFrame.TimeText
v650_:AddToggle(
    {
        ["Name"] = "Auto-Spin",
        ["Default"] = false,
        ["Callback"] = function(p653_)
            -- upvalues: (ref) v_u_643_, (ref) v_u_646_, (ref) v_u_7_, (ref) v_u_649_
            _G.AutoFarmCoins = p653_
            if p653_ then
                while _G.AutoFarmCoins do
                    if v_u_643_() then
                        v_u_646_("Spin")
                        local v_u_654_ = nil
                        local v655_ =
                            task.spawn(
                            function()
                                -- upvalues: (ref) v_u_654_
                                while true do
                                    if v_u_654_ then
                                        TeleportPlayer(v_u_654_.CFrame + Vector3.new(0, 5, 0))
                                        task.wait(0.2)
                                        SNOWship(v_u_654_)
                                    end
                                    task.wait()
                                end
                            end
                        )
                        local v656_, v657_, v658_ = pairs(v_u_7_.Slots:GetChildren())
                        while true do
                            local v659_
                            v658_, v659_ = v656_(v657_, v658_)
                            if v658_ == nil then
                                break
                            end
                            v_u_654_ = v659_.SlotHandle.Handle
                            v_u_654_.CanCollide = false
                            local v660_ = v_u_654_
                            for _ = 1, 5 do
                                task.wait(0.2)
                            end
                            v660_.CanCollide = true
                            if not v_u_643_() then
                                break
                            end
                        end
                        task.cancel(v655_)
                        newtask = nil
                        v_u_649_("Spin")
                    end
                    task.wait(5)
                end
            end
        end,
        ["Save"] = true,
        ["Flag"] = "autofarmcoins_toggle"
    }
)
TimeRemainingLabel = v650_:AddLabel("Time Remaining: 0:00")
CoinsWonLabel = v650_:AddLabel("Coins Won: 0")
timelefttextlabelingame.Changed:Connect(
    function(p661_)
        if p661_ == "Text" then
            TimeRemainingLabel:Set("Time Remaining: " .. timelefttextlabelingame.Text)
        end
    end
)
task.spawn(
    function()
        -- upvalues: (ref) v_u_7_, (ref) v_u_17_
        local v662_, v663_, v664_ = pairs(v_u_7_.Slots:GetDescendants())
        while true do
            local v_u_665_
            v664_, v_u_665_ = v662_(v663_, v664_)
            if v664_ == nil then
                break
            end
            if v_u_665_.Name == "CoinAmount" and tostring(v_u_665_.Parent) == "CoinsFrame" then
                v_u_665_.Changed:Connect(
                    function(p666_)
                        -- upvalues: (ref) v_u_665_, (ref) v_u_17_
                        local v667_ = v_u_665_.Parent.Parent.SpinningFrame.PlayerName
                        if p666_ == "Text" and (v667_.Text == v_u_17_.DisplayName and CoinsWonLabel) then
                            CoinsWonLabel:Set(v_u_665_.Text)
                        end
                    end
                )
            end
        end
        v_u_7_.Plots.DescendantAdded:Connect(
            function(p668_)
                -- upvalues: (ref) v_u_17_
                if
                    p668_.Name == "Value" and
                        (tostring(p668_.Parent) == "ThisPlotsOwners" and p668_.Value == v_u_17_.Name)
                 then
                    RTime = p668_:WaitForChild("TimeRemainingNum", 1)
                    if RTime then
                        RTime.Changed:Connect(
                            function(p669_)
                                TimeInHouseLabel:Set("Time: " .. p669_)
                            end
                        )
                    end
                end
            end
        )
    end
)
task.spawn(
    function()
        -- upvalues: (ref) v_u_7_, (ref) v_u_17_
        local v670_, v671_, v672_ = pairs(v_u_7_.Plots:GetDescendants())
        while true do
            local v673_
            v672_, v673_ = v670_(v671_, v672_)
            if v672_ == nil then
                break
            end
            if v673_.Name == "TimeRemainingNum" and v673_.Parent.Value == v_u_17_.Name then
                _G.RemainingTimeInHouse = v673_
                v673_.Changed:Connect(
                    function(p674_)
                        TimeInHouseLabel:Set("Time: " .. p674_)
                    end
                )
            end
        end
    end
)
local v_u_675_ = nil
v_u_675_ =
    v651_:AddToggle(
    {
        ["Name"] = "Preserve Time",
        ["Default"] = false,
        ["Callback"] = function(p676_)
            -- upvalues: (ref) v_u_17_, (ref) v_u_675_, (ref) v_u_4_, (ref) v_u_7_, (ref) v_u_646_, (ref) v_u_649_
            _G.AutoSaveHouseTime = p676_
            if p676_ then
                while _G.AutoSaveHouseTime do
                    if v_u_17_.InfiniteHouseTime.Value then
                        v_u_675_:Set(false)
                        v_u_4_:MakeNotification(
                            {
                                ["Name"] = "Stop being greedy!",
                                ["Content"] = "You already own infinity house gamepass!",
                                ["Image"] = "rbxassetid://4483345998",
                                ["Time"] = 5
                            }
                        )
                        break
                    end
                    local v677_ = _G.RemainingTimeInHouse
                    if typeof(v677_) == "Instance" and (v677_:IsDescendantOf(v_u_7_) and v677_:IsA("IntValue")) then
                        local v678_ = _G.RemainingTimeInHouse.Parent.Parent.Parent.Parent:FindFirstChild("PlotArea")
                        if v677_.Value < 20 then
                            v_u_646_("House")
                            task.wait()
                            repeat
                                TeleportPlayer(CFrame.new(v678_.Position))
                                task.wait(0.156)
                            until v677_.Parent ~= nil or (not _G.AutoSaveHouseTime or v677_.Value > 15)
                            v_u_649_("House")
                        end
                    end
                    task.wait(2)
                end
            end
        end,
        ["Save"] = true,
        ["Flag"] = "autosavehousetimeremaining_toggle"
    }
)
TimeInHouseLabel = v651_:AddLabel("Plot Time: 0")
local v_u_679_ = Instance.new("IntValue")
PlotWorkspace = v_u_7_.Plots:GetDescendants()
function GetPlotModel(_)
    -- upvalues: (ref) v_u_7_
    local v680_ = v_u_7_.Plots
    local v681_ = _G.PlotName
    if v681_ == "Witch House" then
        v680_ = v680_:FindFirstChild("Plot3")
    elseif v681_ == "Lumber House" then
        v680_ = v680_:FindFirstChild("Plot2")
    elseif v681_ == "Common House" then
        v680_ = v680_:FindFirstChild("Plot1")
    elseif v681_ == "American House" then
        v680_ = v680_:FindFirstChild("Plot4")
    elseif v681_ == "Chinese House" then
        v680_ = v680_:FindFirstChild("Plot5")
    end
    return v680_
end
function ClaimPlot()
    -- upvalues: (ref) v_u_17_
    local v682_ = not IsThereOwnerOnPlot() and GetPlotModel(_G.PlotName)
    if v682_ then
        local v_u_683_ = v682_.PlotSign
        local function v689_()
            -- upvalues: (ref) v_u_683_, (ref) v_u_17_
            local v684_, v685_, v686_ = pairs(v_u_683_.ThisPlotsOwners:GetChildren())
            local v687_ = false
            while true do
                local v688_
                v686_, v688_ = v684_(v685_, v686_)
                if v686_ == nil then
                    break
                end
                if v688_.Value == v_u_17_.Name then
                    v687_ = true
                end
            end
            return v687_
        end
        local v690_ = v_u_683_
        local v691_, v692_, v693_ = pairs(v_u_683_.GetChildren(v690_))
        while true do
            local v694_
            v693_, v694_ = v691_(v692_, v693_)
            if v693_ == nil or v689_() then
                break
            end
            if v694_.Name == "Sign" then
                local v695_ = v694_.Plus.PlusGrabPart
                TeleportPlayer(v695_.CFrame * CFrame.new(-5, 0, -5))
                for _ = 0, 15 do
                    SNOWship(v695_)
                    wait()
                end
            end
        end
    end
end
function UpdatePlotOwner()
    -- upvalues: (ref) v_u_5_, (ref) v_u_679_
    local v696_ = PlotWorkspace
    local v697_, v698_, v699_ = pairs(v696_)
    while true do
        local v700_
        v699_, v700_ = v697_(v698_, v699_)
        if v699_ == nil then
            break
        end
        if v700_.Name == "PlayerRole" then
            local v_u_701_ = v700_.Parent.PlayerDisplayName
            local v_u_702_ = v700_
            local v_u_703_ = v700_.Parent
            local v_u_704_ = nil
            local v_u_705_ = false
            local function v_u_711_()
                -- upvalues: (ref) v_u_705_, (ref) v_u_704_, (ref) v_u_702_, (ref) v_u_703_, (ref) v_u_5_, (ref) v_u_701_
                v_u_705_ = false
                v_u_704_ = GetPlotModel(_G.PlotName)
                if v_u_704_ and (v_u_702_:IsDescendantOf(v_u_704_) and (v_u_702_.Text == "Owner" and v_u_703_.Visible)) then
                    wait()
                    local v706_ = v_u_5_
                    local v707_, v708_, v709_ = pairs(v706_:GetPlayers())
                    while true do
                        local v710_
                        v709_, v710_ = v707_(v708_, v709_)
                        if v709_ == nil then
                            break
                        end
                        if v710_.DisplayName == v_u_701_.Text then
                            v_u_705_ = true
                        end
                    end
                    if PlotOwner and v_u_705_ then
                        PlotOwner:Set("Plot Owner: " .. v_u_701_.Text)
                    else
                        PlotOwner:Set("Plot Available!")
                    end
                end
            end
            v_u_702_.Changed:Connect(
                function(p712_)
                    -- upvalues: (ref) v_u_711_
                    if p712_ == "Text" then
                        v_u_711_()
                    end
                end
            )
            v_u_679_.Changed:Connect(
                function(_)
                    -- upvalues: (ref) v_u_711_
                    v_u_711_()
                end
            )
            v_u_711_()
        end
    end
end
function IsThereOwnerOnPlot()
    local v713_ = GetPlotModel()
    if v713_ and v713_.PlotSign.ThisPlotsOwners:FindFirstChild("Value") then
        return true
    end
end
function UpdatePeopleInPlot()
    -- upvalues: (ref) v_u_679_
    local v714_ = PlotWorkspace
    local v715_, v716_, v717_ = pairs(v714_)
    while true do
        local v_u_718_
        v717_, v_u_718_ = v715_(v716_, v717_)
        if v717_ == nil then
            break
        end
        if v_u_718_.Name == "ThisPlotsOwners" then
            local function v_u_723_()
                -- upvalues: (ref) v_u_718_
                local v719_ = v_u_718_
                local v720_ = GetPlotModel(_G.PlotName)
                local v721_ = v719_:GetChildren()
                if v720_ and v_u_718_:IsDescendantOf(v720_) then
                    local v722_ = table.getn(v721_)
                    if PlayersInPlot then
                        PlayersInPlot:Set("Players in Plot: " .. v722_)
                    end
                    if v722_ == 0 and PlotOwner then
                        PlotOwner:Set("Plot Available!")
                    end
                end
            end
            v_u_679_.Changed:Connect(
                function(_)
                    -- upvalues: (ref) v_u_723_
                    v_u_723_()
                end
            )
            v_u_718_.ChildAdded:Connect(v_u_723_)
            v_u_718_.ChildRemoved:Connect(v_u_723_)
            v_u_723_()
        end
    end
end
v652_:AddDropdown(
    {
        ["Name"] = "Plot",
        ["Default"] = "Witch House",
        ["Options"] = {
            "Witch House",
            "Lumber House",
            "Common House",
            "American House",
            "Chinese House"
        },
        ["Callback"] = function(p724_)
            -- upvalues: (ref) v_u_679_
            _G.PlotName = p724_
            v_u_679_.Value = v_u_679_.Value + 1
        end
    }
)
task.spawn(
    function()
        UpdatePlotOwner()
        task.wait()
        UpdatePeopleInPlot()
    end
)
PlotOwner = v652_:AddLabel("Plot Owner:")
PlayersInPlot = v652_:AddLabel("Players in Plot: 0")
v652_:AddButton(
    {
        ["Name"] = "Claim Plot!",
        ["Callback"] = function()
            ClaimPlot()
        end
    }
)
function ExplodeSb(p725_)
    -- upvalues: (ref) v_u_17_
    local v726_ = {
        {
            ["Radius"] = 17.5,
            ["TimeLength"] = 0.1,
            ["Hitbox"] = p725_:FindFirstChild("SoundPart"),
            ["ExplodesByFire"] = true,
            ["MaxForcePerStudSquared"] = -100,
            ["DestroysModel"] = true,
            ["Model"] = p725_,
            ["ExplodesByPointy"] = false,
            ["ImpactSpeed"] = 100,
            ["PositionPart"] = v_u_17_.Character.HumanoidRootPart
        },
        v_u_17_.Character.HumanoidRootPart.Position
    }
    BombEvents.BombExplode:FireServer(unpack(v726_))
end
getgenv().MaxSize = 15
local v_u_727_ = {}
local v_u_728_ = 0
local v_u_729_ = nil
snowballEffectConnection = nil
snowballMaxAmmount = 20
if v21_.Value == 200 then
    snowballMaxAmmount = 40
end
function checkSize(p730_)
    -- upvalues: (ref) v_u_7_, (ref) v_u_727_
    while _G.SnowbalEffectSpam do
        if p730_ and (p730_:IsDescendantOf(v_u_7_) and p730_:FindFirstChild("SoundPart")) then
            local v731_ = p730_:FindFirstChild("SoundPart")
            local v732_ = v731_.Size
            if v732_.X >= MaxSize and (v732_.Y >= MaxSize and (v732_.Z >= MaxSize and not v_u_727_[v731_])) then
                v_u_727_[v731_] = true
                break
            end
        end
        task.wait()
    end
end
function checkSnowBall(p733_)
    -- upvalues: (ref) v_u_7_
    if p733_ and p733_:FindFirstChild("SoundPart") then
        local v734_ = p733_.SoundPart
        local v735_ = RaycastParams.new()
        v735_.FilterDescendantsInstances = {
            p733_
        }
        v735_.FilterType = Enum.RaycastFilterType.Exclude
        local v736_ = v_u_7_:Raycast(v734_.Position, Vector3.new(0, -100, 0), v735_)
        if v736_ and v736_.Material == Enum.Material.Sand then
            return true
        end
    end
end
lastpossb = nil
function holdOwnership()
    -- upvalues: (ref) v_u_19_
    if not _G.SnowbalEffectSpam then
        return
    end
    local v737_ = v_u_19_
    local v738_, v739_, v740_ = pairs(v737_:GetChildren())
    if v742_ and (v742_.Name == "BallSnowball" and v742_:FindFirstChild("SoundPart")) then
        local v741_ = v742_:FindFirstChild("SoundPart")
        if not CheckNetworkOwnerShipOnPart(v741_) then
            if not lastpossb then
                lastpossb = GetPlayerCFrame()
            end
            for _ = 1, 10 do
                if SNOWshipOnce(v741_) then
                    v741_.CanTouch = false
                    v741_.CanCollide = false
                    break
                end
                TeleportPlayer(CFrame.new(v741_.Position + Vector3.new(0, -10, 0)))
                task.wait(0.1)
            end
            TeleportPlayer(lastpossb)
            lastpossb = nil
        end
    end
    local v742_
    v740_, v742_ = v738_(v739_, v740_)
    if v740_ ~= nil and _G.SnowbalEffectSpam then
    else
    end
    task.wait()
end
function CountGrownSnowsballs()
    -- upvalues: (ref) v_u_727_, (ref) v_u_7_, (ref) v_u_729_
    local v743_, v744_, v745_ = pairs(v_u_727_)
    local v746_ = 0
    while true do
        local v747_
        v745_, v747_ = v743_(v744_, v745_)
        if v745_ == nil then
            break
        end
        if v745_:IsDescendantOf(v_u_7_) then
            v746_ = v746_ + 1
        else
            v_u_727_[v745_] = nil
        end
    end
    return v746_
end
function modify(p748_)
    -- upvalues: (ref) v_u_727_
    local v749_ =
        CFrame.new(
        -410,
        228.394,
        510,
        -0.246182978,
        3.22764193e-9,
        -0.96922338,
        1.2914926e-8,
        1,
        4.97377278e-11,
        0.96922338,
        -1.2505204e-8,
        -0.246182978
    )
    while _G.SnowbalEffectSpam and p748_ do
        if p748_:FindFirstChild("SoundPart") then
            local v750_ = p748_.SoundPart
            local v751_ = v750_:FindFirstChild("FarmSnowball")
            if CheckNetworkOwnerShipOnPart(v750_) then
                if v751_ then
                    if v_u_727_[v750_] then
                        v751_.Position = Vector3.new(math.random(-10000, 10000), 10000, math.random(-10000, 10000))
                    else
                        v751_.Position =
                            v749_.Position + Vector3.new(25, 0, 0) + Vector3.new(0, v750_.Size.X / 2 - 0.65, 0)
                        wait(0.5)
                        v751_.Position =
                            v749_.Position + Vector3.new(-25, 0, 0) + Vector3.new(0, v750_.Size.X / 2 - 0.65, 0)
                        wait(0.5)
                        v751_.Position = v749_.Position + Vector3.new(0, v750_.Size.X / 2 - 0.65, 0)
                    end
                else
                    local v752_ = Instance.new("BodyPosition", v750_)
                    v752_.MaxForce = Vector3.new(12500, 12500, 12500)
                    v752_.Name = "FarmSnowball"
                    v752_.Position = v750_.Position
                end
            end
        end
        wait()
    end
end
function newSnowball(p_u_753_)
    if p_u_753_.Name == "BallSnowball" and _G.SnowbalEffectSpam then
        task.spawn(
            function()
                -- upvalues: (ref) p_u_753_
                checkSize(p_u_753_)
            end
        )
        task.spawn(
            function()
                -- upvalues: (ref) p_u_753_
                modify(p_u_753_)
            end
        )
    end
end
task.spawn(
    function()
        while task.wait() do
            CountGrownSnowsballs()
        end
    end
)
local v754_ =
    v546_:AddSection(
    {
        ["Name"] = "Snowball"
    }
)
v754_:AddSlider(
    {
        ["Name"] = "Ammount",
        ["Min"] = 5,
        ["Max"] = snowballMaxAmmount,
        ["Default"] = 5,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 1,
        ["ValueName"] = "Snowballs you want to make to explode them!",
        ["Callback"] = function(p755_)
            -- upvalues: (ref) v_u_728_
            v_u_728_ = p755_
        end,
        ["Save"] = true,
        ["Flag"] = "ammountsnowballtomake_slider"
    }
)
automakesnowballtoggle = nil
automakesnowballtoggle =
    v754_:AddToggle(
    {
        ["Name"] = "Auto Make Snowball",
        ["Default"] = false,
        ["Callback"] = function(p756_)
            -- upvalues: (ref) v_u_19_, (ref) v_u_728_
            _G.SnowbalEffectSpam = p756_
            if p756_ then
                snowballEffectConnection = v_u_19_.ChildAdded:Connect(newSnowball)
                task.spawn(
                    function()
                        -- upvalues: (ref) v_u_728_
                        while _G.SnowbalEffectSpam do
                            if v_u_728_ > countToys("BallSnowball") then
                                SpawnToy(
                                    {
                                        "BallSnowball",
                                        CFrame.new(
                                            -389,
                                            228,
                                            550,
                                            -0.3092496991157532,
                                            0.2610282301902771,
                                            -0.9144555330276489,
                                            0,
                                            0.9615919589996338,
                                            0.2744831442832947,
                                            0.9509809017181396,
                                            0.08488383144140244,
                                            -0.2973720133304596
                                        ),
                                        Vector3.new(0, 97.69000244140625, 0)
                                    }
                                )
                                task.wait(0.1)
                            end
                            if v_u_728_ <= CountGrownSnowsballs() then
                                automakesnowballtoggle:Set(false)
                            end
                            task.wait()
                        end
                    end
                )
                task.spawn(
                    function()
                        holdOwnership()
                    end
                )
                local v757_ = v_u_19_
                local v758_, v759_, v760_ = ipairs(v757_:GetChildren())
                while true do
                    local v761_
                    v760_, v761_ = v758_(v759_, v760_)
                    if v760_ == nil then
                        break
                    end
                    newSnowball(v761_)
                end
            elseif snowballEffectConnection then
                snowballEffectConnection:Disconnect()
            end
        end,
        ["Save"] = true,
        ["Flag"] = "autofarmsnowball_toggle"
    }
)
local _ = v754_:AddLabel("Grown Snowballs:")
v754_:AddButton(
    {
        ["Name"] = "Explode Snowballs",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_727_, (ref) v_u_7_
            local v762_, v763_, v764_ = pairs(v_u_727_)
            while true do
                local v765_
                v764_, v765_ = v762_(v763_, v764_)
                if v764_ == nil then
                    break
                end
                if v764_:IsDescendantOf(v_u_7_) then
                    ExplodeSb(v764_.Parent)
                end
            end
        end
    }
)
spamexplosiontype = nil
spamexplosiontarget = 0
bombsammountoexplode = 1
reachedrightammount = false
explosionInterval = nil
canExplode = false
maxBombstoexplode = 8
if v21_.Value == 200 then
    maxBombstoexplode = 18
end
v_u_13_:BindAction("FireBomb", fireBombs, false, Enum.KeyCode.F)
function ExplodeFw()
    -- upvalues: (ref) v_u_19_, (ref) v_u_5_
    local v766_ = v_u_19_
    local v767_, v768_, v769_ = pairs(v766_:GetChildren())
    while true do
        local v770_
        v769_, v770_ = v767_(v768_, v769_)
        if v769_ == nil then
            break
        end
        if v770_.Name == spamexplosiontype then
            local v771_ = {
                {
                    ["Radius"] = 17.5,
                    ["TimeLength"] = 0.5,
                    ["Hitbox"] = v770_:FindFirstChild("PartHitDetector"),
                    ["ExplodesByFire"] = true,
                    ["MaxForcePerStudSquared"] = 225,
                    ["DestroysModel"] = true,
                    ["Model"] = v770_,
                    ["ExplodesByPointy"] = false,
                    ["ImpactSpeed"] = 20,
                    ["PositionPart"] = workspace.SpawnLocation
                },
                Vector3.new(0, -10, 0)
            }
            if spamexplosiontype ~= "BombBalloon" then
                if spamexplosiontype == "PresentBig" or spamexplosiontype == "PresentSmall" then
                    v771_[1].Hitbox = v770_.Box
                end
            else
                v771_[1].Hitbox = v770_.Balloon
            end
            if spamexplosiontarget ~= 0 then
                if spamexplosiontarget ~= 1 then
                    local v772_ = spamexplosiontarget == 2 and GetFakeAim2()
                    if v772_ then
                        v771_[1].PositionPart = v772_
                        v771_[2] = v772_.Position
                    end
                else
                    local v773_
                    if _G.TargetToBombPlayer then
                        v773_ = v_u_5_:FindFirstChild(_G.TargetToBombPlayer)
                    else
                        v773_ = nil
                    end
                    if
                        v773_ and (not IsPlayerInsideSafeZone(v773_) and v773_.Character) and
                            v773_.Character:FindFirstChild("HumanoidRootPart")
                     then
                        local v774_ = v773_.Character.HumanoidRootPart
                        v771_[1].PositionPart = v774_
                        v771_[2] = v774_.Position
                    end
                end
            else
                v771_[1].PositionPart = workspace.SpawnLocation
                v771_[2] = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
            end
            BombEvents.BombExplode:FireServer(unpack(v771_))
        end
        if explosionInterval > 0 then
            task.wait(explosionInterval)
        end
    end
end
firework_section =
    v546_:AddSection(
    {
        ["Name"] = "Explosions Spam"
    }
)
explosionexplanation =
    v546_:AddSection(
    {
        ["Name"] = "FAQ about (Explosions Spam)"
    }
)
firework_section:AddToggle(
    {
        ["Name"] = "Explode",
        ["Default"] = false,
        ["Callback"] = function(p775_)
            -- upvalues: (ref) v_u_19_, (ref) v_u_17_
            _G.FireworkEffectSpam = p775_
            if p775_ then
                task.spawn(
                    function()
                        while _G.FireworkEffectSpam do
                            local v776_ = GetPlayerCFrame()
                            if
                                countToys(spamexplosiontype) < bombsammountoexplode and
                                    (not reachedrightammount and (spamexplosiontarget ~= 2 or GetFakeAim())) and
                                    v776_
                             then
                                SpawnToy(
                                    {
                                        spamexplosiontype,
                                        CFrame.new(
                                            v776_.Position.X,
                                            v776_.Position.Y,
                                            v776_.Position.Z,
                                            -0.3092496991157532,
                                            0.2610282301902771,
                                            -0.9144555330276489,
                                            0,
                                            0.9615919589996338,
                                            0.2744831442832947,
                                            0.9509809017181396,
                                            0.08488383144140244,
                                            -0.2973720133304596
                                        ),
                                        Vector3.new(0, 97.69000244140625, 0)
                                    }
                                )
                            end
                            task.wait()
                        end
                    end
                )
                task.spawn(
                    function()
                        -- upvalues: (ref) v_u_19_, (ref) v_u_17_
                        while _G.FireworkEffectSpam do
                            local v777_ = v_u_19_
                            local v778_, v779_, v780_ = pairs(v777_:GetChildren())
                            while true do
                                local v781_
                                v780_, v781_ = v778_(v779_, v780_)
                                if v780_ == nil then
                                    break
                                end
                                if v781_.Name == spamexplosiontype then
                                    local v782_ = nil
                                    if spamexplosiontype ~= "BombDarkMatter" then
                                        if spamexplosiontype ~= "BombMissile" then
                                            if spamexplosiontype ~= "BombBalloon" then
                                                if spamexplosiontype ~= "FireworkMissile" then
                                                    if
                                                        spamexplosiontype == "PresentBig" or
                                                            spamexplosiontype == "PresentSmall"
                                                     then
                                                        v782_ = v781_:FindFirstChild("Box")
                                                    end
                                                else
                                                    v782_ = v781_:FindFirstChild("Hitbox")
                                                end
                                            else
                                                v782_ = v781_:FindFirstChild("Balloon")
                                            end
                                        else
                                            v782_ = v781_:FindFirstChild("Body")
                                        end
                                    else
                                        v782_ = v781_:FindFirstChild("Pyramid")
                                    end
                                    if
                                        v782_ and not SNOWshipOnce(v782_) and
                                            v_u_17_:DistanceFromCharacter(v782_.Position) > 30
                                     then
                                        DeleteToyRE:FireServer(v781_)
                                        print("Deletado!")
                                    elseif
                                        v782_ and
                                            (CheckNetworkOwnerShipOnPart(v782_) and
                                                not v781_:GetAttribute("MissileTeleported"))
                                     then
                                        wait()
                                        if v781_.PrimaryPart then
                                            Instance.new("BodyVelocity", v781_.PrimaryPart).Velocity =
                                                Vector3.new(10000, 10000, 10000)
                                            v781_:SetPrimaryPartCFrame(
                                                CFrame.new(math.random(-1000, 1000), 10000, math.random(-1000, 1000))
                                            )
                                            v781_:SetAttribute("MissileTeleported", true)
                                        end
                                        print("ownershipped!")
                                    end
                                end
                            end
                            task.wait(0.1)
                        end
                    end
                )
                task.spawn(
                    function()
                        while _G.FireworkEffectSpam do
                            if countToys(spamexplosiontype) < bombsammountoexplode then
                                _G.CanExplodeBombs = false
                            else
                                if spamexplosiontarget ~= 2 or not _G.FireBomb then
                                    if spamexplosiontarget ~= 2 then
                                        canExplode = true
                                    end
                                else
                                    canExplode = true
                                end
                                _G.CanExplodeBombs = true
                                if canExplode then
                                    ExplodeFw()
                                    reachedrightammount = false
                                    canExplode = false
                                end
                            end
                            task.wait()
                        end
                    end
                )
                task.spawn(
                    function()
                        while _G.FireworkEffectSpam do
                            if spamexplosiontarget == 2 then
                                GetFakeAim2()
                            end
                            wait(0.1)
                        end
                    end
                )
            end
        end
    }
)
firework_section:AddDropdown(
    {
        ["Name"] = "Explosion Type",
        ["Default"] = "Firework",
        ["Options"] = {
            "Firework",
            "Missile",
            "Void",
            "Ballon",
            "Small Present",
            "Big Present"
        },
        ["Callback"] = function(p783_)
            if p783_ == "Firework" then
                spamexplosiontype = "FireworkMissile"
            elseif p783_ == "Missile" then
                spamexplosiontype = "BombMissile"
            elseif p783_ == "Void" then
                spamexplosiontype = "BombDarkMatter"
            elseif p783_ == "Ballon" then
                spamexplosiontype = "BombBalloon"
            elseif p783_ == "Small Present" then
                spamexplosiontype = "PresentSmall"
            elseif p783_ == "Big Present" then
                spamexplosiontype = "PresentBig"
            end
        end
    }
)
firework_section:AddSlider(
    {
        ["Name"] = "Ammount to Explode",
        ["Min"] = 1,
        ["Max"] = maxBombstoexplode,
        ["Default"] = 1,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 1,
        ["ValueName"] = "to explode the player brutally",
        ["Callback"] = function(p784_)
            bombsammountoexplode = p784_
        end
    }
)
firework_section:AddSlider(
    {
        ["Name"] = "Delay",
        ["Min"] = 0,
        ["Max"] = 1,
        ["Default"] = 0,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 0.1,
        ["ValueName"] = "interval between every explosion",
        ["Callback"] = function(p785_)
            explosionInterval = p785_
        end
    }
)
firework_section:AddDropdown(
    {
        ["Name"] = "Target",
        ["Default"] = "Spawn",
        ["Options"] = {
            "Spawn",
            "Player",
            "Mouse"
        },
        ["Callback"] = function(p786_)
            if p786_ == "Spawn" then
                spamexplosiontarget = 0
            elseif p786_ == "Player" then
                spamexplosiontarget = 1
            elseif p786_ == "Mouse" then
                spamexplosiontarget = 2
            end
        end
    }
)
PlayerToTarget =
    firework_section:AddDropdown(
    {
        ["Name"] = "Select Player",
        ["Default"] = "Macaco (negro)",
        ["Options"] = {
            ""
        },
        ["Callback"] = function(p787_)
            local v788_ = string.split(p787_, " ")
            _G.TargetToBombPlayer = v788_[1]
        end
    }
)
explosionexplanation:AddParagraph("How to use target mouse?", "Press/Hold the keybind (F) and then BOOM!")
explosionexplanation:AddParagraph(
    "How to target player?",
    "Select Target to Player and then select the player you want to target"
)
explosionexplanation:AddParagraph("How to change the explosive", "Click on Explosive Type and select any type")
v_u_17_.Idled:connect(
    function()
        -- upvalues: (ref) v_u_15_
        v_u_15_:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        wait(1)
        v_u_15_:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
)
local v789_ =
    v553_:AddSection(
    {
        ["Name"] = "Silent-Aim"
    }
)
v789_:AddToggle(
    {
        ["Name"] = "Silent Aim",
        ["Default"] = false,
        ["Callback"] = function(p790_)
            _G.SilentAim = p790_
        end,
        ["Save"] = true,
        ["Flag"] = "SilentAim_toggle"
    }
)
v789_:AddSlider(
    {
        ["Name"] = "Silent-Aim Range",
        ["Min"] = 0,
        ["Max"] = 50,
        ["Default"] = 50,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 1,
        ["ValueName"] = "",
        ["Callback"] = function(p791_)
            -- upvalues: (ref) v_u_610_
            v_u_610_ = p791_
        end,
        ["Save"] = true,
        ["Flag"] = "silentaimrange_slider"
    }
)
local v792_ =
    v548_:AddSection(
    {
        ["Name"] = "Line Extender"
    }
)
v792_:AddToggle(
    {
        ["Name"] = "Further Extend",
        ["Default"] = false,
        ["Callback"] = function(p793_)
            _G.FutherExtend = p793_
        end,
        ["Save"] = true,
        ["Flag"] = "FurtherLineExtend_toggle"
    }
)
MaxExtendLine = 0
MinExtendLine = 0
if v_u_10_.TouchEnabled then
    MinExtendLine = 3
    MaxExtendLine = 25
elseif v_u_10_.MouseEnabled then
    MinExtendLine = 3
    MaxExtendLine = 25
end
v792_:AddSlider(
    {
        ["Name"] = "Increase Extend",
        ["Min"] = MinExtendLine,
        ["Max"] = MaxExtendLine,
        ["Default"] = 3,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 1,
        ["ValueName"] = "Ammount",
        ["Callback"] = function(p794_)
            IncreaseLineExtend = p794_
        end,
        ["Save"] = true,
        ["Flag"] = "FurtherLineExtend_slider"
    }
)
local v795_ =
    v549_:AddSection(
    {
        ["Name"] = "Normal Auras"
    }
)
local v796_ =
    v549_:AddSection(
    {
        ["Name"] = "Fling Aura"
    }
)
local v797_ =
    v549_:AddSection(
    {
        ["Name"] = "Kick Aura"
    }
)
local v798_ =
    v549_:AddSection(
    {
        ["Name"] = "Auras Whitelist"
    }
)
local function v_u_801_()
    -- upvalues: (ref) v_u_17_
    local v799_ = v_u_17_.Character
    local v800_
    if v799_ then
        v800_ = v799_:FindFirstChildOfClass("Humanoid")
    else
        v800_ = nil
    end
    if
        not v799_ or
            (not v800_ or
                (not v800_.Sit or (v800_.SeatPart == nil or tostring(v800_.SeatPart.Parent) ~= "CreatureBlobman")))
     then
        return false
    end
    _G.LastBlobmanWasSeat = v800_.SeatPart.Parent
    return true
end
local function v_u_808_(p802_)
    -- upvalues: (ref) v_u_5_, (ref) v_u_801_, (ref) v_u_62_
    local v803_ = false
    v_u_5_:FindFirstChild(p802_)
    if v_u_801_() and _G.LoopKick then
        local v804_, v805_, v806_ = pairs(v_u_62_)
        while true do
            local v807_
            v806_, v807_ = v804_(v805_, v806_)
            if v806_ == nil then
                break
            end
            if p802_ == v807_ then
                v803_ = true
            end
        end
    end
    return v803_
end
local function v_u_810_(p809_)
    -- upvalues: (ref) v_u_17_, (ref) v_u_51_, (ref) v_u_7_
    if
        typeof(p809_) == "Instance" and (p809_ ~= v_u_17_ and (not v_u_51_(p809_) and p809_.Character)) and
            (p809_.Character:IsDescendantOf(v_u_7_) and
                (p809_.Character:FindFirstChild("HumanoidRootPart") and
                    (p809_.Character:FindFirstChildOfClass("Humanoid") and p809_.Character.Humanoid.Health > 0)))
     then
        return true
    end
end
local function v_u_812_(p811_)
    -- upvalues: (ref) v_u_810_
    if v_u_810_(p811_) and not IsPlayerInsideSafeZone(p811_) then
        return true
    end
end
local function v_u_814_(p813_)
    -- upvalues: (ref) v_u_810_, (ref) v_u_97_, (ref) v_u_808_
    if
        v_u_810_(p813_) and not (v_u_97_(p813_.Name) and _G.WhitelistFriends) and not v_u_808_(p813_.Name) and
            not (p813_.Character:GetAttribute("Kicking") or _G.KickAura)
     then
        return true
    end
end
local function v_u_816_(p815_)
    -- upvalues: (ref) v_u_810_, (ref) v_u_97_, (ref) v_u_808_
    if
        v_u_810_(p815_) and not (v_u_97_(p815_.Name) and _G.WhitelistFriends) and not v_u_808_(p815_.Name) and
            not p815_.Character:GetAttribute("Kicking")
     then
        return true
    end
end
local function v_u_818_(p817_)
    -- upvalues: (ref) v_u_810_, (ref) v_u_97_, (ref) v_u_808_
    if
        v_u_810_(p817_) and not (v_u_97_(p817_.Name) and _G.WhitelistFriends3) and not v_u_808_(p817_.Name) and
            not p817_.Character:GetAttribute("Kicking")
     then
        return true
    end
end
local function v_u_820_(p819_)
    -- upvalues: (ref) v_u_810_, (ref) v_u_97_
    if v_u_810_(p819_) and not (v_u_97_(p819_.Name) and _G.WhitelistFriends3) and not IsPlayerInsideSafeZone(p819_) then
        return true
    end
end
local function v_u_822_(p821_)
    -- upvalues: (ref) v_u_810_, (ref) v_u_97_
    if
        v_u_810_(p821_) and not (v_u_97_(p821_.Name) and _G.WhitelistFriends3) and
            not (IsPlayerInsideSafeZone(p821_) or IsPlayerFloating(p821_))
     then
        return true
    end
end
function CreateSkyVelocity(p823_)
    if not p823_:FindFirstChild("SkyVelocity") then
        local v824_ = Instance.new("BodyVelocity", p823_)
        v824_.Name = "SkyVelocity"
        v824_.Velocity = Vector3.new(0, 100000000000000, 0)
        v824_.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    end
end
local v_u_825_ = v_u_7_.Map.AlwaysHereTweenedObjects:FindFirstChild("OuterUFO")
if v_u_825_ and v_u_825_:FindFirstChild("Object") and v_u_825_.Object:FindFirstChild("ObjectModel") then
    v_u_825_ = v_u_825_.Object.ObjectModel.PaintPlayerPart
    v_u_825_:WaitForChild("WeldConstraint").Enabled = false
    v_u_825_.Anchored = true
    v_u_825_.Shape = Enum.PartType.Block
    v_u_825_.Transparency = 1
    v_u_825_.Size = Vector3.new(0.5, 0.5, 0.5)
    v_u_825_.Position = Vector3.new(0, -50, 0)
end
v795_:AddToggle(
    {
        ["Name"] = "Poison Aura",
        ["Default"] = false,
        ["Callback"] = function(p826_)
            -- upvalues: (ref) v_u_5_, (ref) v_u_814_, (ref) v_u_381_, (ref) v_u_382_, (ref) v_u_383_
            _G.Poison_Aura = p826_
            if p826_ then
                while _G.Poison_Aura do
                    local v827_ = v_u_5_
                    local v828_, v829_, v830_ = pairs(v827_:GetPlayers())
                    while true do
                        local v831_
                        v830_, v831_ = v828_(v829_, v830_)
                        if v830_ == nil then
                            break
                        end
                        if v_u_814_(v831_) then
                            local v832_ = v831_.Character:FindFirstChild("Head")
                            if v832_ and SNOWshipPlayer(v831_) then
                                v_u_381_.CFrame = v832_.CFrame
                                v_u_382_.CFrame = v832_.CFrame
                                v_u_383_.CFrame = v832_.CFrame
                                task.wait()
                                v_u_383_.Position = Vector3.new(0, -50, 0)
                                v_u_382_.Position = Vector3.new(0, -50, 0)
                                v_u_381_.Position = Vector3.new(0, -50, 0)
                            end
                        end
                    end
                    task.wait()
                end
            end
        end,
        ["Save"] = true,
        ["Flag"] = "poisonaura_toggle"
    }
)
v795_:AddToggle(
    {
        ["Name"] = "Death Aura",
        ["Default"] = false,
        ["Callback"] = function(p833_)
            -- upvalues: (ref) v_u_5_, (ref) v_u_814_, (ref) v_u_23_
            _G.DeathAura = p833_
            if p833_ then
                while _G.DeathAura do
                    local v834_ = v_u_5_
                    local v835_, v836_, v837_ = pairs(v834_:GetPlayers())
                    while true do
                        local v838_
                        v837_, v838_ = v835_(v836_, v837_)
                        if v837_ == nil then
                            break
                        end
                        if v_u_814_(v838_) then
                            local v839_ = v838_.Character
                            local v840_ = v839_:FindFirstChild("HumanoidRootPart")
                            local v841_ = v839_:FindFirstChildOfClass("Humanoid")
                            if v840_ and (v841_ and SNOWshipPlayer(v838_)) then
                                v_u_23_:FireServer(v840_)
                                CreateSkyVelocity(v840_)
                                v841_.BreakJointsOnDeath = false
                                v841_:ChangeState(Enum.HumanoidStateType.Dead)
                                v841_.Jump = true
                                v841_.Sit = false
                                if v841_:GetStateEnabled(Enum.HumanoidStateType.Dead) then
                                    v_u_23_:FireServer(v840_)
                                end
                            end
                        end
                    end
                    task.wait()
                end
            end
        end,
        ["Save"] = true,
        ["Flag"] = "deathaura_toggle"
    }
)
if v_u_825_ then
    v795_:AddToggle(
        {
            ["Name"] = "Radioactive Aura",
            ["Default"] = false,
            ["Callback"] = function(p842_)
                -- upvalues: (ref) v_u_5_, (ref) v_u_814_, (ref) v_u_825_
                _G.RadioactiveAura = p842_
                if p842_ then
                    while _G.RadioactiveAura do
                        local v843_ = v_u_5_
                        local v844_, v845_, v846_ = pairs(v843_:GetPlayers())
                        while true do
                            local v847_
                            v846_, v847_ = v844_(v845_, v846_)
                            if v846_ == nil then
                                break
                            end
                            if v_u_814_(v847_) then
                                local v848_ = v847_.Character:FindFirstChild("HumanoidRootPart")
                                if v848_ and SNOWshipPlayer(v847_) then
                                    v_u_825_.Position = v848_.Position
                                    task.wait()
                                    v_u_825_.Position = Vector3.new(0, -50, 0)
                                end
                            end
                        end
                        task.wait()
                    end
                end
            end,
            ["Save"] = true,
            ["Flag"] = "radioaura_toggle"
        }
    )
end
v795_:AddToggle(
    {
        ["Name"] = "Burn Aura",
        ["Default"] = false,
        ["Callback"] = function(p849_)
            -- upvalues: (ref) v_u_5_, (ref) v_u_814_, (ref) v_u_17_, (ref) v_u_509_
            _G.BurnAura = p849_
            if p849_ then
                while _G.BurnAura do
                    local v850_ = v_u_5_
                    local v851_, v852_, v853_ = pairs(v850_:GetPlayers())
                    while true do
                        local v854_
                        v853_, v854_ = v851_(v852_, v853_)
                        if v853_ == nil then
                            break
                        end
                        if v_u_814_(v854_) then
                            local v855_ = v854_.Character:FindFirstChild("HumanoidRootPart")
                            if v855_ and v_u_17_:DistanceFromCharacter(v855_.Position) < 30 then
                                v_u_509_(v855_)
                            end
                        end
                    end
                    task.wait()
                end
            end
        end,
        ["Save"] = true,
        ["Flag"] = "burnaura_toggle"
    }
)
v796_:AddToggle(
    {
        ["Name"] = "Fling Aura",
        ["Default"] = false,
        ["Callback"] = function(p856_)
            -- upvalues: (ref) v_u_6_, (ref) v_u_5_, (ref) v_u_814_
            _G.FlingAura = p856_
            if p856_ then
                while _G.FlingAura do
                    if _G.FlingTarget == 2 or _G.FlingTarget == 3 then
                        local v857_, v858_ = CheckObjectsAroundPlayer()
                        if v857_ then
                            local v859_, v860_, v861_ = pairs(v857_)
                            while true do
                                local v862_
                                v861_, v862_ = v859_(v860_, v861_)
                                if v861_ == nil then
                                    break
                                end
                                attempts = 0
                                if v862_ then
                                    local v863_ = v862_:FindFirstChild("Head")
                                    local v864_, v865_, v866_ = pairs(v862_:GetChildren())
                                    while true do
                                        local v867_
                                        v866_, v867_ = v864_(v865_, v866_)
                                        if v866_ == nil then
                                            break
                                        end
                                        if v867_:IsA("BasePart") and v867_.CanQuery then
                                            local v868_ = SNOWshipOnce(v867_)
                                            local v869_ = GetPlayerRoot()
                                            if not v868_ and v863_ then
                                                v868_ = CheckNetworkOwnerShipOnPart(v863_)
                                            end
                                            if v868_ and v869_ then
                                                if v858_ then
                                                    local v870_ = v858_.Position
                                                    v858_.Position = v867_.Position
                                                    task.wait()
                                                    v858_.Position = v870_
                                                elseif not v867_:FindFirstChild("FlingAuraVelocity") then
                                                    local v871_ = lookAt(v869_.Position, v867_.Position)
                                                    local v872_ = Instance.new("BodyVelocity", v867_)
                                                    v872_.Name = "FlingAuraVelocity"
                                                    v872_.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                                    v872_.Velocity =
                                                        Vector3.new(v871_.lookVector.X, 0.5, v871_.lookVector.Z) *
                                                        math.clamp(_G.FlingStrength, 400, 600)
                                                    v_u_6_:AddItem(v872_)
                                                end
                                                attempts = attempts + 1
                                            end
                                            if attempts >= 3 then
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if _G.FlingTarget == 1 or _G.FlingTarget == 3 then
                        local v873_ = v_u_5_
                        local v874_, v875_, v876_ = pairs(v873_:GetPlayers())
                        while true do
                            local v877_
                            v876_, v877_ = v874_(v875_, v876_)
                            if v876_ == nil then
                                break
                            end
                            if v_u_814_(v877_) then
                                local v878_ = v877_.Character:FindFirstChild("HumanoidRootPart")
                                local v879_ = SNOWshipPlayer(v877_)
                                local v880_ = GetPlayerCharacter()
                                if v878_ and (v879_ and (v880_ and not v878_:FindFirstChild("FlingAuraVelocity"))) then
                                    local v881_ = lookAt(v880_.HumanoidRootPart.Position, v878_.Position)
                                    local v882_ = Instance.new("BodyVelocity", v878_)
                                    v882_.Name = "FlingAuraVelocity"
                                    v882_.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    v882_.Velocity =
                                        Vector3.new(v881_.lookVector.X, 0.5, v881_.lookVector.Z) * _G.FlingStrength
                                    v_u_6_:AddItem(v882_)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end
        end,
        ["Save"] = true,
        ["Flag"] = "flingaura_toggle"
    }
)
v796_:AddSlider(
    {
        ["Name"] = "Strength",
        ["Min"] = 400,
        ["Max"] = 10000,
        ["Default"] = 400,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 100,
        ["ValueName"] = "",
        ["Callback"] = function(p883_)
            _G.FlingStrength = p883_
        end,
        ["Save"] = true,
        ["Flag"] = "flingstrengthvalue_toggle"
    }
)
v796_:AddDropdown(
    {
        ["Name"] = "Target",
        ["Default"] = "Players",
        ["Options"] = {
            "Players",
            "Objects",
            "Players and Objects"
        },
        ["Callback"] = function(p884_)
            if p884_ == "Players" then
                _G.FlingTarget = 1
            elseif p884_ == "Objects" then
                _G.FlingTarget = 2
            elseif p884_ == "Players and Objects" then
                _G.FlingTarget = 3
            end
        end,
        ["Save"] = true,
        ["Flag"] = "flingtarget_dropdown"
    }
)
v795_:AddToggle(
    {
        ["Name"] = "Attraction Aura",
        ["Default"] = false,
        ["Callback"] = function(p885_)
            -- upvalues: (ref) v_u_5_, (ref) v_u_814_
            _G.AttractionAura = p885_
            if p885_ then
                while _G.AttractionAura do
                    local v886_ = v_u_5_
                    local v887_, v888_, v889_ = pairs(v886_:GetPlayers())
                    while true do
                        local v890_
                        v889_, v890_ = v887_(v888_, v889_)
                        if v889_ == nil then
                            break
                        end
                        if v_u_814_(v890_) then
                            local v891_ = v890_.Character
                            local v892_ = v891_:FindFirstChild("HumanoidRootPart")
                            local v893_ = v891_:FindFirstChildOfClass("Humanoid")
                            local v894_ = GetPlayerCharacter()
                            if v893_ and (v892_ and v894_) then
                                SNOWship(v892_)
                                v893_.Sit = false
                                v893_.WalkSpeed = 25
                                v893_:MoveTo(v894_.HumanoidRootPart.Position)
                            end
                        end
                    end
                    task.wait()
                end
            end
        end,
        ["Save"] = true,
        ["Flag"] = "attractaura_toggle"
    }
)
kickauratoggle = nil
KickTypesList = {
    "Silent",
    "Float",
    "Sky Anchor"
}
function CreateKickPhysical(p_u_895_, p_u_896_, p_u_897_)
    -- upvalues: (ref) v_u_7_
    if p_u_896_:FindFirstChild("KickAuraP") then
        p_u_896_.KickAuraP:SetAttribute("TypeFunction", p_u_897_)
    else
        local v_u_898_ = Instance.new("BodyPosition", p_u_896_)
        v_u_898_.Name = "KickAuraP"
        local v899_ = v_u_898_
        v_u_898_.SetAttribute(v899_, "TypeFunction", p_u_897_)
        local v_u_900_ = Instance.new("BodyVelocity", p_u_896_)
        v_u_900_.Name = "KickAuraP1"
        v_u_900_.Velocity = Vector3.new(0, 400, 0)
        task.spawn(
            function()
                -- upvalues: (ref) p_u_895_, (ref) v_u_898_, (ref) v_u_900_, (ref) p_u_896_, (ref) v_u_7_, (ref) p_u_897_
                local v_u_901_ = nil
                local v_u_902_ = nil
                local v_u_903_ = Vector3.new(0, -100, 0)
                local v_u_904_ = Vector3.new(0, 0, 0)
                local v_u_905_ = Vector3.new(0, 12500, 0)
                local v_u_906_ = Vector3.new(4000, 4000, 4000)
                local v_u_907_ = Vector3.new(math.random(50, 250), 250, math.random(50, 250))
                local v_u_908_ = RaycastParams.new()
                v_u_908_.FilterDescendantsInstances = {
                    p_u_895_
                }
                v_u_908_.FilterType = Enum.RaycastFilterType.Exclude
                local function v910_(p909_)
                    -- upvalues: (ref) v_u_898_, (ref) v_u_905_, (ref) v_u_900_, (ref) v_u_904_, (ref) v_u_901_, (ref) p_u_896_, (ref) v_u_902_, (ref) v_u_7_, (ref) v_u_903_, (ref) v_u_908_, (ref) v_u_906_, (ref) v_u_907_
                    if p909_ == "Silent" then
                        v_u_898_.MaxForce = v_u_905_
                        v_u_900_.MaxForce = v_u_904_
                        v_u_901_ = p_u_896_.Position
                        v_u_902_ = v_u_7_:Raycast(v_u_901_, v_u_903_, v_u_908_)
                        if v_u_902_ then
                            v_u_898_.Position = v_u_902_.Position + Vector3.new(0, 5, 0)
                        end
                    elseif p909_ == "Float" then
                        v_u_900_.MaxForce = v_u_906_
                        v_u_898_.MaxForce = v_u_904_
                    elseif p909_ == "Sky Anchor" then
                        v_u_898_.MaxForce = v_u_906_
                        v_u_898_.Position = v_u_907_
                        v_u_900_.MaxForce = v_u_904_
                    end
                end
                while v_u_898_.Parent and p_u_895_.Parent do
                    p_u_897_ = v_u_898_:GetAttribute("TypeFunction")
                    if p_u_897_ == "Aura" or not p_u_897_ then
                        if not _G.KickAura then
                            break
                        end
                        v910_(_G.KickAuraType)
                    elseif p_u_897_ ~= "Counter" then
                        if p_u_897_ ~= "Kick_All" then
                            if p_u_897_ == "LoopKick" then
                                if not _G.LoopKickOwnership then
                                    break
                                end
                                v910_(_G.LoopKickOwnerType)
                            end
                        else
                            if not _G.KickAll then
                                break
                            end
                            v910_(_G.KickAllType)
                        end
                    else
                        if not _G.AutoAttacker then
                            break
                        end
                        v910_(_G.KickCounterType)
                    end
                    task.wait()
                end
                v_u_898_:Destroy()
                v_u_900_:Destroy()
            end
        )
    end
end
kickauratoggle =
    v797_:AddToggle(
    {
        ["Name"] = "Kick Aura",
        ["Default"] = false,
        ["Callback"] = function(p911_)
            -- upvalues: (ref) v_u_33_, (ref) v_u_5_, (ref) v_u_816_, (ref) v_u_23_
            _G.KickAura = p911_
            if p911_ then
                while _G.KickAura do
                    if getgenv().key ~= "Xana" then
                        kickauratoggle:Set(false)
                        v_u_33_("Only for premium users! Buy premium in my discord server!")
                        break
                    end
                    local v912_ = v_u_5_
                    local v913_, v914_, v915_ = pairs(v912_:GetPlayers())
                    while true do
                        local v916_
                        v915_, v916_ = v913_(v914_, v915_)
                        if v915_ == nil then
                            break
                        end
                        if v_u_816_(v916_) then
                            local v917_ = v916_.Character
                            local v918_ = v917_:FindFirstChild("HumanoidRootPart")
                            if
                                v918_ and
                                    (v917_:FindFirstChildOfClass("Humanoid") and
                                        (v918_:FindFirstChild("FirePlayerPart") and SNOWshipPlayer(v916_)))
                             then
                                CreateSkyVelocity(v918_)
                                v_u_23_:FireServer(v918_)
                            end
                        end
                    end
                    task.wait()
                end
            end
        end
    }
)
v797_:AddDropdown(
    {
        ["Name"] = "Kick Type",
        ["Default"] = "Go to the heaven!",
        ["Options"] = {
            "Go to the heaven!"
        },
        ["Callback"] = function(p919_)
            _G.KickAuraType = p919_
        end,
        ["Save"] = true,
        ["Flag"] = "kickauratype_dropdown"
    }
)
v798_:AddToggle(
    {
        ["Name"] = "Whitelist Friends",
        ["Default"] = false,
        ["Callback"] = function(p920_)
            _G.WhitelistFriends = p920_
        end,
        ["Save"] = true,
        ["Flag"] = "whitelistaura_toggle"
    }
)
local v921_ =
    v543_:AddSection(
    {
        ["Name"] = "Strength"
    }
)
local v922_ =
    v543_:AddSection(
    {
        ["Name"] = "Others"
    }
)
local v923_ =
    v543_:AddSection(
    {
        ["Name"] = "Perspective"
    }
)
v921_:AddToggle(
    {
        ["Name"] = "Super Strength",
        ["Default"] = false,
        ["Callback"] = function(p924_)
            _G.SuperStrength = p924_
        end,
        ["Save"] = true,
        ["Flag"] = "superstrengthgrab_toggle"
    }
)
v921_:AddSlider(
    {
        ["Name"] = "Strength",
        ["Min"] = 400,
        ["Max"] = 10000,
        ["Default"] = 400,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 100,
        ["ValueName"] = "",
        ["Callback"] = function(p925_)
            _G.Strength = p925_
        end,
        ["Save"] = true,
        ["Flag"] = "superstrengthvalue_toggle"
    }
)
v922_:AddToggle(
    {
        ["Name"] = "Poison Grab",
        ["Default"] = false,
        ["Callback"] = function(p926_)
            _G.Poison_Grab = p926_
        end,
        ["Save"] = true,
        ["Flag"] = "poisongrab_toggle"
    }
)
v922_:AddToggle(
    {
        ["Name"] = "Burn Grab",
        ["Default"] = false,
        ["Callback"] = function(p927_)
            _G.Burn_Grab = p927_
        end,
        ["Save"] = true,
        ["Flag"] = "burngrab_toggle"
    }
)
v922_:AddToggle(
    {
        ["Name"] = "Death Grab",
        ["Default"] = false,
        ["Callback"] = function(p928_)
            _G.Death_Grab = p928_
        end,
        ["Save"] = true,
        ["Flag"] = "deathgrab_toggle"
    }
)
v922_:AddToggle(
    {
        ["Name"] = "Massless Grab",
        ["Default"] = false,
        ["Callback"] = function(p929_)
            _G.MasslessGrab = p929_
        end,
        ["Save"] = true,
        ["Flag"] = "masslessgrab_toggle"
    }
)
if v_u_825_ then
    v922_:AddToggle(
        {
            ["Name"] = "Radiactive Grab",
            ["Default"] = false,
            ["Callback"] = function(p930_)
                _G.Radiactive_Grab = p930_
            end,
            ["Save"] = true,
            ["Flag"] = "radiactivegrab_toggle"
        }
    )
end
v922_:AddToggle(
    {
        ["Name"] = "Noclip Grab",
        ["Default"] = false,
        ["Callback"] = function(p931_)
            _G.NoclipGrab = p931_
        end,
        ["Save"] = true,
        ["Flag"] = "noclipgrab_toggle"
    }
)
local v_u_932_ = nil
local v_u_933_ = 50
kickgrabtoggle = nil
v923_:AddToggle(
    {
        ["Name"] = "Perspective Grab",
        ["Default"] = false,
        ["Callback"] = function(p934_)
            _G.PerspectiveGrab = p934_
        end,
        ["Save"] = true,
        ["Flag"] = "perspectivegrab_toggle"
    }
)
v923_:AddSlider(
    {
        ["Name"] = "Speed",
        ["Min"] = 50,
        ["Max"] = 150,
        ["Default"] = 50,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 1,
        ["ValueName"] = "",
        ["Callback"] = function(p935_)
            -- upvalues: (ref) v_u_933_
            v_u_933_ = p935_
        end,
        ["Save"] = true,
        ["Flag"] = "perspectivespeedvalue_toggle"
    }
)
local v936_ =
    v553_:AddSection(
    {
        ["Name"] = "Annoy Players"
    }
)
local v937_ =
    v553_:AddSection(
    {
        ["Name"] = "Kick All"
    }
)
local v938_ =
    v553_:AddSection(
    {
        ["Name"] = "Whitelist"
    }
)
local v_u_939_ = nil
v_u_939_ =
    v936_:AddToggle(
    {
        ["Name"] = "Fire All",
        ["Default"] = false,
        ["Callback"] = function(p940_)
            -- upvalues: (ref) v_u_939_, (ref) v_u_33_, (ref) v_u_5_, (ref) v_u_818_, (ref) v_u_509_
            _G.FireAllPlayers = p940_
            if p940_ then
                while _G.FireAllPlayers do
                    if getgenv().key ~= "Xana" then
                        v_u_939_:Set(false)
                        v_u_33_("Only for premium users! Buy premium in my discord server!")
                        break
                    end
                    local v941_ = v_u_5_
                    local v942_, v943_, v944_ = pairs(v941_:GetPlayers())
                    while true do
                        local v945_
                        v944_, v945_ = v942_(v943_, v944_)
                        if v944_ == nil then
                            break
                        end
                        if v_u_818_(v945_) then
                            local _ = v945_.Character
                            local v946_ = v945_.Character:FindFirstChild("HumanoidRootPart")
                            local v947_
                            if v946_:FindFirstChild("FirePlayerPart") and v946_.FirePlayerPart:FindFirstChild("CanBurn") then
                                v947_ = v946_.FirePlayerPart.CanBurn.Value
                            else
                                v947_ = nil
                            end
                            if v946_ and (v945_ and not (IsPlayerInsideSafeZone(v945_) or v947_)) then
                                v_u_509_(v946_)
                                task.wait(0.015)
                            end
                        end
                    end
                    task.wait()
                end
            end
        end
    }
)
annoyalltoggle =
    v936_:AddToggle(
    {
        ["Name"] = "Ragdoll All",
        ["Default"] = false,
        ["Callback"] = function(p948_)
            -- upvalues: (ref) v_u_33_, (ref) v_u_5_, (ref) v_u_818_, (ref) v_u_478_
            _G.AnnoyAllPlayers = p948_
            if p948_ then
                while _G.AnnoyAllPlayers do
                    if getgenv().key ~= "Xana" then
                        annoyalltoggle:Set(false)
                        v_u_33_("Only for premium users! Buy premium in my discord server!")
                        break
                    end
                    local v949_ = v_u_5_
                    local v950_, v951_, v952_ = pairs(v949_:GetPlayers())
                    while true do
                        local v953_
                        v952_, v953_ = v950_(v951_, v952_)
                        if v952_ == nil then
                            break
                        end
                        if v_u_818_(v953_) then
                            local v954_ = v953_.Character
                            local v955_ = v953_.Character:FindFirstChild("HumanoidRootPart")
                            local v956_ = v954_:FindFirstChildOfClass("Humanoid"):FindFirstChild("Ragdolled")
                            if v955_ and (v956_ and not v956_.Value) then
                                v_u_478_(v955_)
                                task.wait(0.015)
                            end
                        end
                    end
                    task.wait()
                end
            end
        end
    }
)
killalltoggle =
    v936_:AddToggle(
    {
        ["Name"] = "Kill All",
        ["Default"] = false,
        ["Callback"] = function(p957_)
            -- upvalues: (ref) v_u_33_, (ref) v_u_5_, (ref) v_u_820_, (ref) v_u_349_, (ref) v_u_23_, (ref) v_u_351_
            _G.KillAll = p957_
            if p957_ then
                if getgenv().key ~= "Xana" then
                    _G.KillAll = false
                    killalltoggle:Set(false)
                    v_u_33_("Only for premium users! Buy premium in my discord server!")
                    return
                end
                while _G.KillAll do
                    ipos = GetPlayerCFrame()
                    local v958_ = v_u_5_
                    local v959_, v960_, v961_ = pairs(v958_:GetPlayers())
                    while true do
                        local v962_
                        v961_, v962_ = v959_(v960_, v961_)
                        if v961_ == nil then
                            break
                        end
                        if v_u_820_(v962_) then
                            local v963_ = v962_.Character:FindFirstChild("HumanoidRootPart")
                            local v964_ = v962_.Character:FindFirstChild("Humanoid")
                            if v962_ and (v963_ and v964_) then
                                for _ = 0, 50 do
                                    v_u_349_()
                                    SNOWship(v963_)
                                    if
                                        not v_u_820_(v962_) or
                                            (not _G.KillAll or
                                                (CheckNetworkOwnerShipOnPlayer(v962_) or
                                                    v963_.AssemblyLinearVelocity.Magnitude > 500))
                                     then
                                        CreateSkyVelocity(v963_)
                                        v_u_23_:FireServer(v963_)
                                        break
                                    end
                                    task.wait()
                                    if v963_.Position.Y <= -12 then
                                        TeleportPlayer(CFrame.new(v963_.Position + Vector3.new(0, 5, -15)))
                                    else
                                        TeleportPlayer(CFrame.new(v963_.Position + Vector3.new(0, -10, -10)))
                                    end
                                    v964_.BreakJointsOnDeath = false
                                    v964_:ChangeState(Enum.HumanoidStateType.Dead)
                                    v964_.Jump = true
                                    v964_.Sit = false
                                end
                            end
                        end
                    end
                    TeleportPlayer(ipos)
                    task.wait(0.2)
                end
                v_u_351_()
                TeleportPlayer(ipos)
            end
        end
    }
)
kickalltoggle =
    v937_:AddToggle(
    {
        ["Name"] = "Kick All",
        ["Default"] = false,
        ["Callback"] = function(p965_)
            -- upvalues: (ref) v_u_33_, (ref) v_u_5_, (ref) v_u_822_, (ref) v_u_349_, (ref) v_u_23_, (ref) v_u_351_
            _G.KickAll = p965_
            if p965_ then
                if getgenv().key ~= "Xana" then
                    _G.KickAll = false
                    kickalltoggle:Set(false)
                    v_u_33_("Only for premium users! Buy premium in my discord server!")
                    return
                end
                while _G.KickAll do
                    ipos = GetPlayerCFrame()
                    local v966_ = v_u_5_
                    local v967_, v968_, v969_ = pairs(v966_:GetPlayers())
                    while true do
                        local v970_
                        v969_, v970_ = v967_(v968_, v969_)
                        if v969_ == nil then
                            break
                        end
                        if v_u_822_(v970_) then
                            local v971_ = v970_.Character:FindFirstChild("HumanoidRootPart")
                            if v970_ and v971_ then
                                for _ = 0, 50 do
                                    v_u_349_()
                                    SNOWship(v971_)
                                    if
                                        not v_u_822_(v970_) or
                                            (not _G.KickAll or
                                                (CheckNetworkOwnerShipOnPlayer(v970_) or
                                                    v971_.AssemblyLinearVelocity.Magnitude > 500))
                                     then
                                        CreateSkyVelocity(v971_)
                                        v_u_23_:FireServer(v971_)
                                        break
                                    end
                                    task.wait()
                                    if v971_.Position.Y <= -12 then
                                        TeleportPlayer(CFrame.new(v971_.Position + Vector3.new(0, 5, -15)))
                                    else
                                        TeleportPlayer(CFrame.new(v971_.Position + Vector3.new(0, -10, -10)))
                                    end
                                end
                            end
                        end
                    end
                    TeleportPlayer(ipos)
                    task.wait(0.2)
                end
                v_u_351_()
                TeleportPlayer(ipos)
            end
        end
    }
)
v937_:AddDropdown(
    {
        ["Name"] = "Kick Type",
        ["Default"] = "Go to the heaven!",
        ["Options"] = {
            "Go to the heaven!"
        },
        ["Callback"] = function(p972_)
            _G.KickAllType = p972_
        end,
        ["Save"] = true,
        ["Flag"] = "kickalltype_dropdown"
    }
)
v938_:AddToggle(
    {
        ["Name"] = "Whitelist Friends",
        ["Default"] = false,
        ["Callback"] = function(p973_)
            _G.WhitelistFriends3 = p973_
        end,
        ["Save"] = true,
        ["Flag"] = "whitelistfriends3_toggle"
    }
)
local v974_ =
    v544_:AddSection(
    {
        ["Name"] = "Invulnerability"
    }
)
local v975_ =
    v544_:AddSection(
    {
        ["Name"] = "Counter-Attack"
    }
)
v974_:AddToggle(
    {
        ["Name"] = "Anti-Grab",
        ["Default"] = false,
        ["Callback"] = function(p976_)
            -- upvalues: (ref) v_u_51_, (ref) v_u_29_, (ref) v_u_30_, (ref) v_u_17_
            _G.AntiGrab = p976_
            if p976_ and not v_u_51_(v_u_29_) then
                v_u_30_:FireServer(v_u_17_)
            end
        end,
        ["Save"] = true,
        ["Flag"] = "antigrab_toggle"
    }
)
v974_:AddToggle(
    {
        ["Name"] = "Anti-Burn",
        ["Default"] = false,
        ["Callback"] = function(p977_)
            _G.AntiBurn = p977_
        end,
        ["Save"] = true,
        ["Flag"] = "antiburn_toggle"
    }
)
v974_:AddToggle(
    {
        ["Name"] = "Anti-Explosion",
        ["Default"] = false,
        ["Callback"] = function(p978_)
            _G.AntiExplosion = p978_
        end,
        ["Save"] = true,
        ["Flag"] = "antiexplosion_toggle"
    }
)
v975_:AddToggle(
    {
        ["Name"] = "Auto-Attacker",
        ["Default"] = false,
        ["Callback"] = function(p979_)
            _G.AutoAttacker = p979_
        end,
        ["Save"] = true,
        ["Flag"] = "rinnegan_toggle"
    }
)
counterdropdownselection = nil
counterdropdownselection =
    v975_:AddDropdown(
    {
        ["Name"] = "Counter Mode",
        ["Default"] = "Repulsion",
        ["Options"] = {
            "Repulsion",
            "Freeze",
            "Death",
            "Kick"
        },
        ["Callback"] = function(p980_)
            -- upvalues: (ref) v_u_33_
            if p980_ == "Kick" and key ~= "Xana" then
                counterdropdownselection:Set("Repulsion")
                v_u_33_("Only for premium users! Buy premium in my discord server!")
            else
                _G.CounterMode = p980_
            end
        end
    }
)
floppadialogo = Instance.new("ScreenGui")
Floppa = Instance.new("ImageLabel")
Bubble_chat = Instance.new("ImageLabel")
BubbleTextchat = Instance.new("TextLabel")
typingsoundeffect = Instance.new("Sound", v_u_7_)
typingsoundeffect2 = Instance.new("Sound", v_u_7_)
typingsoundeffect.SoundId = "rbxassetid://" .. 9120299506
typingsoundeffect.Volume = 0.345
typingsoundeffect2.SoundId = "rbxassetid://" .. 9118870964
typingsoundeffect2.Volume = 1
typingsoundeffect2.PlaybackSpeed = 1.5
floppadialogo.IgnoreGuiInset = true
floppadialogo.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
floppadialogo.Name = "floppadialogo"
floppadialogo.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
floppadialogo.Parent = v18_
floppadialogo.DisplayOrder = 10
floppadialogo.Enabled = false
floppadialogo.ResetOnSpawn = false
Floppa.ZIndex = 0
Floppa.BorderSizePixel = 0
Floppa.BackgroundColor3 = Color3.new(1, 1, 1)
Floppa.Image = "rbxassetid://15668608167"
Floppa.Size = UDim2.new(0.195372716, 0, 0.305668026, 0)
Floppa.BorderColor3 = Color3.new(0, 0, 0)
Floppa.Position = UDim2.new(0.0185752641, 0, 0.661330521, 0)
Floppa.Name = "Floppa"
Floppa.Parent = floppadialogo
Bubble_chat.BorderSizePixel = 0
Bubble_chat.Transparency = 1
Bubble_chatBackgroundColor3 = Color3.new(1, 1, 1)
Bubble_chat.Image = "rbxassetid://1395860348"
Bubble_chat.Size = UDim2.new(1.03356743, 0, 0.79455024, 0)
Bubble_chat.BorderColor3 = Color3.new(0, 0, 0)
Bubble_chat.BackgroundTransparency = 1
Bubble_chat.Position = UDim2.new(0.678329766, 0, -0.292054504, 0)
Bubble_chat.Name = "Bubble chat"
Bubble_chat.Parent = Floppa
BubbleTextchat.TextWrapped = true
BubbleTextchat.BorderSizePixel = 0
BubbleTextchat.Transparency = 1
BubbleTextchat.TextScaled = true
BubbleTextchat.BackgroundColor3 = Color3.new(1, 1, 1)
BubbleTextchat.TextSize = 14
BubbleTextchat.Size = UDim2.new(0.634431362, 0, 0.268763244, 0)
BubbleTextchat.TextColor3 = Color3.new(0, 0, 0)
BubbleTextchat.BorderColor3 = Color3.new(0, 0, 0)
BubbleTextchat.Text = "I saved you from falling on the void, my son!"
BubbleTextchat.Font = Enum.Font.SourceSans
BubbleTextchat.Position = UDim2.new(0.18163082, 0, 0.365639389, 0)
BubbleTextchat.BackgroundTransparency = 1
BubbleTextchat.TextTransparency = 0
BubbleTextchat.Parent = Bubble_chat
floppatweeninfo1 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
floppatween =
    v_u_9_:Create(
    Floppa,
    floppatweeninfo1,
    {
        ["Position"] = UDim2.new(0.0185752641, 0, 0.661330521, 0)
    }
)
floppamessageoncooldown = false
function antivoidmesssage()
    if not floppamessageoncooldown then
        Floppa.Position = UDim2.new(0.0185752641, 0, 2, 0)
        floppadialogo.Enabled = true
        Floppa.Visible = true
        Bubble_chat.Visible = false
        BubbleTextchat.Visible = false
        floppamessageoncooldown = true
        floppatween:Play()
        floppatween.Completed:Connect(
            function(p981_)
                if p981_ == Enum.PlaybackState.Completed then
                    Bubble_chat.Visible = true
                    BubbleTextchat.Visible = true
                    BubbleTextchat.Text = ""
                    local v982_ = "I saved you from falling on the void, my son!"
                    for v983_ = 0, #v982_ do
                        BubbleTextchat.Text = string.sub(v982_, 1, v983_)
                        typingsoundeffect:Play()
                        task.wait(0.05)
                    end
                    task.wait(1)
                    typingsoundeffect2:Play()
                    floppadialogo.Enabled = false
                    floppamessageoncooldown = false
                end
            end
        )
    end
end
v974_:AddToggle(
    {
        ["Name"] = "Anti-Void",
        ["Default"] = false,
        ["Callback"] = function(p984_)
            -- upvalues: (ref) v_u_7_
            _G.AntiVoid = p984_
            if p984_ then
                v_u_7_.FallenPartsDestroyHeight = -1000
                while _G.AntiVoid do
                    local v985_ = GetPlayerCharacter()
                    if v985_ and v985_.HumanoidRootPart.Position.Y < -800 then
                        v985_:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
                        antivoidmesssage()
                    end
                    wait(0.1)
                end
            else
                v_u_7_.FallenPartsDestroyHeight = -100
            end
        end,
        ["Save"] = true,
        ["Flag"] = "antivoid_toggle"
    }
)
v974_:AddToggle(
    {
        ["Name"] = "Anti-Lag",
        ["Default"] = false,
        ["Callback"] = function(p986_)
            anticreatelinelocalscript.Disabled = p986_
        end,
        ["Save"] = true,
        ["Flag"] = "antilag_toggle"
    }
)
antikicktoggle =
    v974_:AddToggle(
    {
        ["Name"] = "Anti-Kick",
        ["Default"] = false,
        ["Callback"] = function(p987_)
            -- upvalues: (ref) v_u_33_
            if getgenv().key == "Xana" then
                _G.AntiKick = p987_
            else
                _G.AntiKick = false
                if p987_ then
                    antikicktoggle:Set(false)
                    v_u_33_("Only for premium users! Buy premium in my discord server!")
                end
            end
        end,
        ["Save"] = true,
        ["Flag"] = "antikick_toggle"
    }
)
playersCharFolder = Instance.new("Model", v_u_7_)
playersCharFolder.Name = "Characters"
highlightesp = Instance.new("Highlight")
highlightesp.Enabled = true
ESP_Section1 =
    Esp_Tab:AddSection(
    {
        ["Name"] = "ESP Highlight"
    }
)
ESP_Section2 =
    Esp_Tab:AddSection(
    {
        ["Name"] = "ESP Billboard"
    }
)
ESP_Section1:AddToggle(
    {
        ["Name"] = "ESP (Highlight)",
        ["Default"] = false,
        ["Callback"] = function(p988_)
            -- upvalues: (ref) v_u_17_, (ref) v_u_5_
            _G.ESP_Hightlight = p988_
            if p988_ then
                highlightesp.Parent = playersCharFolder
                local function v_u_991_(p989_)
                    -- upvalues: (ref) v_u_17_
                    local v990_ = p989_ ~= v_u_17_ and p989_.Character
                    if v990_ then
                        v990_.Parent = playersCharFolder
                    end
                end
                local function v997_()
                    -- upvalues: (ref) v_u_5_, (ref) v_u_991_
                    local v992_ = v_u_5_
                    local v993_, v994_, v995_ = pairs(v992_:GetPlayers())
                    while true do
                        local v996_
                        v995_, v996_ = v993_(v994_, v995_)
                        if v995_ == nil then
                            break
                        end
                        v_u_991_(v996_)
                    end
                end
                v997_()
                while _G.ESP_Hightlight do
                    v997_()
                    wait(2)
                end
                highlightesp.Parent = nil
            end
        end
    }
)
ESP_Section1:AddColorpicker(
    {
        ["Name"] = "Fill Color",
        ["Default"] = Color3.fromRGB(255, 0, 0),
        ["Callback"] = function(p998_)
            highlightesp.FillColor = p998_
        end,
        ["Save"] = true,
        ["Flag"] = "espHighlightFillcolor_picker"
    }
)
ESP_Section1:AddSlider(
    {
        ["Name"] = "Fill Transparency",
        ["Min"] = 0,
        ["Max"] = 1,
        ["Default"] = 0.5,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 0.1,
        ["ValueName"] = "Fill color transparency:",
        ["Callback"] = function(p999_)
            highlightesp.FillTransparency = p999_
        end,
        ["Save"] = true,
        ["Flag"] = "espHighlightFillTransparency_slider"
    }
)
ESP_Section1:AddColorpicker(
    {
        ["Name"] = "Outline Color",
        ["Default"] = Color3.fromRGB(255, 0, 0),
        ["Callback"] = function(p1000_)
            highlightesp.OutlineColor = p1000_
        end,
        ["Save"] = true,
        ["Flag"] = "espHighlightOutlinecolor_picker"
    }
)
ESP_Section1:AddSlider(
    {
        ["Name"] = "Outline Transparency",
        ["Min"] = 0,
        ["Max"] = 1,
        ["Default"] = 0.5,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 0.1,
        ["ValueName"] = "Outline color transparency:",
        ["Callback"] = function(p1001_)
            highlightesp.OutlineTransparency = p1001_
        end,
        ["Save"] = true,
        ["Flag"] = "espHighlightOutlineTransparency_slider"
    }
)
ESP_Section1:AddDropdown(
    {
        ["Name"] = "Highlight Mode",
        ["Default"] = "AlwaysOnTop",
        ["Options"] = {
            "AlwaysOnTop",
            "Occluded"
        },
        ["Callback"] = function(p1002_)
            highlightesp.DepthMode = Enum.HighlightDepthMode[p1002_]
        end,
        ["Save"] = true,
        ["Flag"] = "espHighlightMode_dropdown"
    }
)
function ESPIconCreation()
    local v1003_ = Instance.new("BillboardGui")
    local v1004_ = Instance.new("ImageButton")
    local v1005_ = Instance.new("UICorner")
    local v1006_ = Instance.new("TextLabel")
    local v1007_ = Instance.new("UITextSizeConstraint")
    local v1008_ = Instance.new("UIAspectRatioConstraint")
    v1003_.Name = "ESP"
    v1003_.Parent = nil
    v1003_.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    v1003_.Active = true
    v1003_.Adornee = nil
    v1003_.AlwaysOnTop = true
    v1003_.ExtentsOffset = Vector3.new(0, 10, 0)
    v1003_.Size = UDim2.new(3, 50, 3, 45)
    v1004_.Name = "UserImage"
    v1004_.Parent = v1003_
    v1004_.AnchorPoint = Vector2.new(0.5, 0.5)
    v1004_.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    v1004_.BackgroundTransparency = 1
    v1004_.BorderColor3 = Color3.fromRGB(0, 0, 0)
    v1004_.BorderSizePixel = 0
    v1004_.Position = UDim2.new(0.5, 0, 0.300000012, 0)
    v1004_.Size = UDim2.new(0.5, 5, 0.5, 5)
    v1004_.Image = ""
    v1005_.CornerRadius = UDim.new(2, 0)
    v1005_.Parent = v1004_
    v1006_.Name = "Username"
    v1006_.Parent = v1003_
    v1006_.AnchorPoint = Vector2.new(0.5, 0.5)
    v1006_.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    v1006_.BackgroundTransparency = 1
    v1006_.BorderColor3 = Color3.fromRGB(0, 0, 0)
    v1006_.BorderSizePixel = 0
    v1006_.Position = UDim2.new(0.5, 0, 0.75999999, 0)
    v1006_.Size = UDim2.new(1, 5, 0.340000004, 5)
    v1006_.Font = Enum.Font.SourceSans
    v1006_.Text = ""
    v1006_.TextColor3 = Color3.fromRGB(255, 255, 255)
    v1006_.TextScaled = true
    v1006_.TextSize = 35
    v1006_.TextStrokeTransparency = 0
    v1006_.TextWrapped = true
    v1007_.Parent = v1006_
    v1007_.MaxTextSize = 35
    v1007_.MinTextSize = 15
    v1008_.Parent = v1003_
    v1008_.AspectRatio = 1.043
    return v1003_
end
ESPIconCreation = ESPIconCreation()
function CreateIconOnPlayer(p1009_)
    if p1009_.Character then
        local v_u_1010_ = p1009_.Character
        local v1011_ = v_u_1010_:WaitForChild("Head", 1)
        if not v_u_1010_:FindFirstChild("ESP") and v1011_ then
            local v_u_1012_ = ESPIconCreation:Clone()
            v_u_1012_.Parent = v_u_1010_
            v_u_1012_.Adornee = v1011_
            v_u_1012_.Username.Text = p1009_.Name
            v_u_1012_.UserImage.Image =
                "https://www.roblox.com/headshot-thumbnail/image?userId=" ..
                p1009_.UserId .. "&width=420&height=420&format=png"
            task.spawn(
                function()
                    -- upvalues: (ref) v_u_1010_, (ref) v_u_1012_
                    while v_u_1010_.Parent and _G.ESP_Icon do
                        task.wait(0.25)
                    end
                    v_u_1012_:Destroy()
                end
            )
        end
    end
end
ESP_Section2:AddToggle(
    {
        ["Name"] = "ESP (Icon)",
        ["Default"] = false,
        ["Callback"] = function(p1013_)
            -- upvalues: (ref) v_u_17_, (ref) v_u_5_
            _G.ESP_Icon = p1013_
            if p1013_ then
                local v_u_1014_ = {}
                local function v1019_()
                    -- upvalues: (ref) v_u_1014_
                    local v1015_, v1016_, v1017_ = pairs(v_u_1014_)
                    while true do
                        local v1018_
                        v1017_, v1018_ = v1015_(v1016_, v1017_)
                        if v1017_ == nil then
                            break
                        end
                        if typeof(v1018_) == "RBXScriptConnection" then
                            v1018_:Disconnect()
                            print("Desconectado!")
                        end
                    end
                    table.clear(v_u_1014_)
                end
                local function v_u_1021_(p_u_1020_)
                    -- upvalues: (ref) v_u_17_, (ref) v_u_1014_
                    if p_u_1020_ ~= v_u_17_ and (p_u_1020_.Character or p_u_1020_.CharacterAdded:Wait()) then
                        CreateIconOnPlayer(p_u_1020_)
                        v_u_1014_[#v_u_1014_ + 1] =
                            p_u_1020_.CharacterAdded:Connect(
                            function(_)
                                -- upvalues: (ref) p_u_1020_
                                CreateIconOnPlayer(p_u_1020_)
                            end
                        )
                    end
                end
                local function v1027_()
                    -- upvalues: (ref) v_u_5_, (ref) v_u_1021_
                    local v1022_ = v_u_5_
                    local v1023_, v1024_, v1025_ = pairs(v1022_:GetPlayers())
                    while true do
                        local v1026_
                        v1025_, v1026_ = v1023_(v1024_, v1025_)
                        if v1025_ == nil then
                            break
                        end
                        v_u_1021_(v1026_)
                    end
                end
                local v1029_ =
                    v_u_5_.PlayerAdded:Connect(
                    function(p1028_)
                        -- upvalues: (ref) v_u_1021_
                        v_u_1021_(p1028_)
                    end
                )
                v1027_()
                while _G.ESP_Icon do
                    wait(0.1)
                end
                v1029_:Disconnect()
                v1019_()
            end
        end
    }
)
MapTeleport_Section =
    v547_:AddSection(
    {
        ["Name"] = "Place TP"
    }
)
PlayerTeleport_Section =
    v547_:AddSection(
    {
        ["Name"] = "Player TP"
    }
)
placeLocations = {
    ["Green House"] = CFrame.new(-352, 99, 354),
    ["Green Safe-House"] = CFrame.new(-584, -6, 93),
    ["Chinese Safe-House"] = CFrame.new(579, 124, -94),
    ["Farm House"] = CFrame.new(-234, 83, -324),
    ["Spawn"] = CFrame.new(4, -7, -3),
    ["Blue Safe-House"] = CFrame.new(538, 96, -372),
    ["Secret Big Cave"] = CFrame.new(17, -7, 539),
    ["Secret Train Cave"] = CFrame.new(500, 62, -307),
    ["Mine Cave"] = CFrame.new(-254, -7, 518),
    ["Witch Safe-House"] = CFrame.new(296, -4, 494),
    ["Red Safe-House"] = CFrame.new(-516, -6, -162)
}
MapTeleport_Section:AddDropdown(
    {
        ["Name"] = "Place to Teleport",
        ["Default"] = "Green House",
        ["Options"] = {
            "Green House",
            "Chinese Safe-House",
            "Spawn",
            "Blue Safe-House",
            "Secret Big Cave",
            "Secret Train Cave",
            "Mine Cave",
            "Farm House",
            "Witch Safe-House",
            "Green Safe-House",
            "Red Safe-House"
        },
        ["Callback"] = function(p1030_)
            _G.PlaceToTeleport = p1030_
        end
    }
)
MapTeleport_Section:AddButton(
    {
        ["Name"] = "Teleport",
        ["Callback"] = function()
            TeleportPlayer(placeLocations[_G.PlaceToTeleport])
        end
    }
)
PlayerToTeleport =
    PlayerTeleport_Section:AddDropdown(
    {
        ["Name"] = "Select Player",
        ["Default"] = "",
        ["Options"] = {
            ""
        },
        ["Callback"] = function(p1031_)
            local v1032_ = string.split(p1031_, " ")
            _G.PlayerToTeleport = v1032_[1]
        end
    }
)
function teleportplayerfunctionoffset(p1033_, p1034_, p1035_, p1036_)
    -- upvalues: (ref) v_u_7_
    local v1037_ = nil
    if _G.PlayerToTeleportDirection ~= "Behind" then
        if _G.PlayerToTeleportDirection ~= "Front" then
            if _G.PlayerToTeleportDirection ~= "Right" then
                if _G.PlayerToTeleportDirection ~= "Left" then
                    if _G.PlayerToTeleportDirection == "Rotate" and (p1034_ and p1035_) then
                        local v1038_ = 0
                        while _G.PlayerToTeleportDirection == "Rotate" and
                            (_G.LoopPlayerTP and (p1035_:IsDescendantOf(v_u_7_) and p1036_ == _G.PlayerToTeleport)) do
                            v1038_ = v1038_ + 0.1
                            v1037_ =
                                CFrame.new(
                                p1034_.Position +
                                    Vector3.new(
                                        math.clamp(math.cos(v1038_), -1, 1),
                                        0,
                                        math.clamp(math.sin(v1038_), -1, 1)
                                    ) *
                                        (TeleportPlayerOffset + 1),
                                p1034_.Position
                            )
                            TeleportPlayer(v1037_)
                            task.wait()
                        end
                    end
                else
                    v1037_ = CFrame.new(p1033_.Position - p1033_.rightVector * (TeleportPlayerOffset + 1))
                end
            else
                v1037_ = CFrame.new(p1033_.Position + p1033_.rightVector * (TeleportPlayerOffset + 1))
            end
        else
            v1037_ = CFrame.new(p1033_.Position + p1033_.lookVector * (TeleportPlayerOffset + 1))
        end
    else
        v1037_ = CFrame.new(p1033_.Position - p1033_.lookVector * (TeleportPlayerOffset + 1))
    end
    if _G.PlayerToTeleportDirection ~= "Rotate" then
        TeleportPlayer(v1037_)
    end
end
PlayerTeleport_Section:AddButton(
    {
        ["Name"] = "Teleport",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_5_
            local v1039_ = v_u_5_:FindFirstChild(_G.PlayerToTeleport)
            local v1040_ = GetPlayerRoot()
            local v1041_ =
                v1039_ and (v1039_.Character and v1040_) and v1039_.Character:FindFirstChild("HumanoidRootPart")
            if v1041_ then
                teleportplayerfunctionoffset(v1041_.CFrame, v1040_)
            end
        end
    }
)
PlayerLoopTeleport =
    PlayerTeleport_Section:AddToggle(
    {
        ["Name"] = "Loop Teleport",
        ["Default"] = false,
        ["Callback"] = function(p1042_)
            -- upvalues: (ref) v_u_5_
            _G.LoopPlayerTP = p1042_
            if p1042_ then
                while _G.LoopPlayerTP do
                    local v1043_ = v_u_5_:FindFirstChild(_G.PlayerToTeleport)
                    if v1043_ and v1043_.Character then
                        local v1044_ = v1043_.Character
                        local v1045_ = v1044_:FindFirstChild("HumanoidRootPart")
                        if v1045_ then
                            teleportplayerfunctionoffset(v1045_.CFrame, v1045_, v1044_, v1043_.Name)
                        end
                    elseif not v1043_ then
                        if PlayerLoopTeleport then
                            PlayerLoopTeleport:Set(false)
                        end
                        _G.LoopPlayerTP = false
                    end
                    task.wait()
                end
            end
        end
    }
)
PlayerLockCamera =
    PlayerTeleport_Section:AddToggle(
    {
        ["Name"] = "Lock Camera",
        ["Default"] = false,
        ["Callback"] = function(p1046_)
            -- upvalues: (ref) v_u_14_, (ref) v_u_5_, (ref) v_u_7_
            _G.LockCameraOnPlayer = p1046_
            if p1046_ then
                local v_u_1047_ = nil
                local v_u_1048_ = nil
                local v_u_1049_ = nil
                local v_u_1050_ = nil
                local v_u_1051_ = nil
                v_u_1051_ =
                    v_u_14_.RenderStepped:Connect(
                    function()
                        -- upvalues: (ref) v_u_1047_, (ref) v_u_5_, (ref) v_u_1050_, (ref) v_u_7_, (ref) v_u_1051_, (ref) v_u_1049_, (ref) v_u_1048_
                        v_u_1047_ = v_u_5_:FindFirstChild(_G.PlayerToTeleport)
                        v_u_1050_ = v_u_7_.CurrentCamera
                        if not _G.LockCameraOnPlayer then
                            v_u_1051_:Disconnect()
                        end
                        if v_u_1047_ and (v_u_1047_.Character and v_u_1050_) then
                            v_u_1049_ = v_u_1047_.Character
                            v_u_1048_ = v_u_1049_:FindFirstChild("HumanoidRootPart")
                            if v_u_1048_ then
                                v_u_1050_.CFrame =
                                    CFrame.lookAt(
                                    v_u_1050_.CFrame.Position,
                                    v_u_1048_.CFrame.Position + Vector3.new(0, 1, 0)
                                )
                            end
                        elseif not v_u_1047_ then
                            if PlayerLockCamera then
                                PlayerLockCamera:Set(false)
                            end
                            _G.LockCameraOnPlayer = false
                        end
                        task.wait()
                    end
                )
            end
        end
    }
)
PlayerViewCamera =
    PlayerTeleport_Section:AddToggle(
    {
        ["Name"] = "View",
        ["Default"] = false,
        ["Callback"] = function(p1052_)
            -- upvalues: (ref) v_u_7_, (ref) v_u_5_
            _G.ViewCameraOnPlayer = p1052_
            if p1052_ then
                local v1053_ = v_u_7_.CurrentCamera
                local v1054_ = v1053_.CameraSubject
                while _G.ViewCameraOnPlayer do
                    local v1055_ = v_u_5_:FindFirstChild(_G.PlayerToTeleport)
                    if v1055_ and (v1055_.Character and v1053_) then
                        local v1056_ = v1055_.Character:FindFirstChildOfClass("Humanoid")
                        if v1056_ then
                            v1053_.CameraSubject = v1056_
                        end
                    elseif not v1055_ then
                        if PlayerViewCamera then
                            PlayerViewCamera:Set(false)
                        end
                        _G.ViewCameraOnPlayer = false
                    end
                    wait()
                end
                v1053_.CameraSubject = v1054_
            end
        end
    }
)
PlayerTeleport_Section:AddSlider(
    {
        ["Name"] = "Offset",
        ["Min"] = 1,
        ["Max"] = 20,
        ["Default"] = 1,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 1,
        ["ValueName"] = "Teleport Offset",
        ["Callback"] = function(p1057_)
            TeleportPlayerOffset = p1057_
        end,
        ["Save"] = true,
        ["Flag"] = "speed_slider"
    }
)
PlayerTeleport_Section:AddDropdown(
    {
        ["Name"] = "Behavior",
        ["Default"] = "Behind",
        ["Options"] = {
            "Behind",
            "Left",
            "Right",
            "Front",
            "Rotate"
        },
        ["Callback"] = function(p1058_)
            _G.PlayerToTeleportDirection = p1058_
        end
    }
)
WS_Section =
    v545_:AddSection(
    {
        ["Name"] = "Walkspeed"
    }
)
JP_Section =
    v545_:AddSection(
    {
        ["Name"] = "Infinite Power Jump"
    }
)
NC_Section =
    v545_:AddSection(
    {
        ["Name"] = "Noclip"
    }
)
WS_Section:AddToggle(
    {
        ["Name"] = "Walkspeed",
        ["Default"] = false,
        ["Callback"] = function(p1059_)
            _G.SuperSpeed = p1059_
        end,
        ["Save"] = true,
        ["Flag"] = "walkspeed_toggle"
    }
)
WS_Section:AddSlider(
    {
        ["Name"] = "Speed",
        ["Min"] = 0.1,
        ["Max"] = 5,
        ["Default"] = 0.1,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 0.01,
        ["ValueName"] = "",
        ["Callback"] = function(p1060_)
            Multiplier = p1060_
        end,
        ["Save"] = true,
        ["Flag"] = "speed_slider"
    }
)
JP_Section:AddToggle(
    {
        ["Name"] = "Infinite Jump",
        ["Default"] = false,
        ["Callback"] = function(p1061_)
            _G.InfiniteJump = p1061_
        end,
        ["Save"] = true,
        ["Flag"] = "infinitejump_toggle"
    }
)
JP_Section:AddSlider(
    {
        ["Name"] = "Jump Power",
        ["Min"] = 24,
        ["Max"] = 1000,
        ["Default"] = 24,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 10,
        ["ValueName"] = "",
        ["Callback"] = function(p1062_)
            -- upvalues: (ref) v_u_17_
            _G.InfiniteJumpPower = p1062_
            v_u_17_.Character:FindFirstChildOfClass("Humanoid").JumpPower = p1062_
        end,
        ["Save"] = true,
        ["Flag"] = "jumppower_slider"
    }
)
NC_Section:AddToggle(
    {
        ["Name"] = "Noclip",
        ["Default"] = false,
        ["Callback"] = function(p1063_)
            -- upvalues: (ref) v_u_349_, (ref) v_u_351_
            _G.NoclipToggle = p1063_
            if p1063_ then
                v_u_349_()
            else
                v_u_351_()
            end
        end,
        ["Save"] = true,
        ["Flag"] = "noclip_toggle"
    }
)
local v_u_1064_ = {
    Color3.new(1, 0, 0),
    Color3.new(1, 0, 0),
    Color3.new(1, 0, 0),
    Color3.new(1, 0, 0),
    Color3.new(1, 0, 0),
    Color3.new(1, 0, 0),
    Color3.new(1, 0, 0),
    Color3.new(1, 0, 0),
    Color3.new(1, 0, 0),
    Color3.new(1, 0, 0)
}
local v1065_ =
    v548_:AddSection(
    {
        ["Name"] = "Change your entire line color"
    }
)
local v1066_ =
    v548_:AddSection(
    {
        ["Name"] = "Line Effects"
    }
)
local v1067_ =
    v548_:AddSection(
    {
        ["Name"] = "Stress Server"
    }
)
LagServerToggle = nil
LagServerToggle =
    v1067_:AddToggle(
    {
        ["Name"] = "Lag Server",
        ["Default"] = false,
        ["Callback"] = function(p1068_)
            -- upvalues: (ref) v_u_33_, (ref) v_u_22_
            laggg = p1068_
            while laggg do
                if getgenv().key ~= "Xana" then
                    LagServerToggle:Set(false)
                    v_u_33_("Only for premium users! Buy premium in my discord server!")
                    break
                end
                for _ = 0, Lag_Intensity do
                    local v1069_, v1070_, v1071_ = ipairs(game:GetService("Players"):GetPlayers())
                    while true do
                        local v1072_
                        v1071_, v1072_ = v1069_(v1070_, v1071_)
                        if v1071_ == nil then
                            break
                        end
                        if v1072_.Character.Torso ~= nil then
                            v_u_22_:FireServer(v1072_.Character.Torso, v1072_.Character.Torso.CFrame)
                        end
                    end
                end
                wait(1)
            end
        end
    }
)
v1067_:AddSlider(
    {
        ["Name"] = "Lag Intensity",
        ["Min"] = 1,
        ["Max"] = 400,
        ["Default"] = 150,
        ["Color"] = Color3.fromRGB(255, 255, 255),
        ["Increment"] = 1,
        ["ValueName"] = "This can have you kicked or kick someone in the server!",
        ["Save"] = true,
        ["Flag"] = "Lag-Intensity",
        ["Callback"] = function(p1073_)
            Lag_Intensity = p1073_
        end
    }
)
v1065_:AddColorpicker(
    {
        ["Name"] = "Choose the color",
        ["Default"] = Color3.fromRGB(255, 0, 0),
        ["Callback"] = function(p1074_)
            _G.LineColorChangeValue = p1074_
        end,
        ["Save"] = true,
        ["Flag"] = "changelinecolor_picker"
    }
)
v1065_:AddButton(
    {
        ["Name"] = "Apply Colors",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_1064_, (ref) v_u_26_
            local v1075_, v1076_, v1077_ = pairs(v_u_1064_)
            while true do
                local v1078_
                v1077_, v1078_ = v1075_(v1076_, v1077_)
                if v1077_ == nil then
                    break
                end
                if v1077_ == 1 then
                    v_u_1064_[v1077_] = ColorSequence.new(_G.LineColorChangeValue, 1)
                else
                    v_u_1064_[v1077_] =
                        Color3.new(
                        _G.LineColorChangeValue.R / 255,
                        _G.LineColorChangeValue.G / 255,
                        _G.LineColorChangeValue.B / 255
                    )
                end
            end
            v_u_26_:FireServer(unpack(v_u_1064_))
        end
    }
)
v1066_:AddToggle(
    {
        ["Name"] = "Crazy Line (Soft Lag)",
        ["Default"] = false,
        ["Callback"] = function(p1079_)
            -- upvalues: (ref) v_u_5_, (ref) v_u_17_, (ref) v_u_22_
            if p1079_ then
                _G.CrazyLine = p1079_
                while _G.CrazyLine do
                    local v1080_ = v_u_5_
                    local v1081_, v1082_, v1083_ = pairs(v1080_:GetPlayers())
                    while true do
                        local v1084_
                        v1083_, v1084_ = v1081_(v1082_, v1083_)
                        if v1083_ == nil then
                            break
                        end
                        if
                            v1084_ and (v1084_ ~= v_u_17_ and v1084_.Character) and
                                v1084_.Character:FindFirstChild("Torso")
                         then
                            v_u_22_:FireServer(
                                v1084_.Character:FindFirstChild("Torso"),
                                CFrame.new(
                                    0.12640380859375,
                                    0.9606337547302246,
                                    -0.5000009536743164,
                                    0.9985212683677673,
                                    0,
                                    -0.05436277016997337,
                                    -6.4805472099749295e-9,
                                    1,
                                    -1.1903301100346653e-7,
                                    0.05436277016997337,
                                    5.960464477539063e-8,
                                    0.9985212683677673
                                )
                            )
                        end
                        task.wait()
                    end
                end
            else
                _G.CrazyLine = p1079_
            end
        end,
        ["Save"] = true,
        ["Flag"] = "softlagline_toggle"
    }
)
v1066_:AddToggle(
    {
        ["Name"] = "Invisible Line",
        ["Default"] = false,
        ["Callback"] = function(p1085_)
            if p1085_ then
                _G.InvisibleLine = p1085_
            else
                _G.InvisibleLine = p1085_
            end
        end,
        ["Save"] = true,
        ["Flag"] = "invisLine_toggle"
    }
)
v_u_13_:BindAction("Godmode", GodModeFTry, false, Enum.KeyCode.T)
v1066_:AddParagraph(
    "Note!",
    "You can't see the effects line, but others player can see it. And Invisible Line won't work if Crazy Line is Enabled"
)
gui2 = Instance.new("ScreenGui")
gui2.ResetOnSpawn = false
gui2.Name = "CAG2"
if v_u_10_.TouchEnabled then
    gui2.Parent = v_u_17_.PlayerGui
end
imageButtonTeleport = Instance.new("ImageButton")
imageButtonTeleport.Size = UDim2.new(0, 70, 0, 70)
imageButtonTeleport.Position = UDim2.new(1, -267, 1, -90)
imageButtonTeleport.Image = "rbxassetid://97166444"
imageButtonTeleport.BackgroundTransparency = 1
imageButtonTeleport.ImageTransparency = 0.2
imageButtonTeleport.ImageColor3 = Color3.fromRGB(142, 142, 142)
imageButtonTeleport.Parent = gui2
imageTLabel = Instance.new("ImageLabel")
imageTLabel.Size = UDim2.new(1, 0, 1, 0)
imageTLabel.Image = "rbxassetid://6723742952"
imageTLabel.BackgroundTransparency = 1
imageTLabel.Parent = imageButtonTeleport
imageButtonControl = Instance.new("ImageButton")
imageButtonControl.Size = UDim2.new(0, 50, 0, 50)
imageButtonControl.Position = UDim2.new(1, -378, 1, -80)
imageButtonControl.Image = "rbxassetid://97166444"
imageButtonControl.BackgroundTransparency = 1
imageButtonControl.ImageTransparency = 0.2
imageButtonControl.ImageColor3 = Color3.fromRGB(142, 142, 142)
imageButtonControl.Parent = gui2
imageCLabel = Instance.new("ImageLabel")
imageCLabel.Size = UDim2.new(1, 0, 1, 0)
imageCLabel.Image = "rbxassetid://14436167187"
imageCLabel.BackgroundTransparency = 1
imageCLabel.Parent = imageButtonControl
imageButtonAnchor = Instance.new("ImageButton")
imageButtonAnchor.Size = UDim2.new(0, 50, 0, 50)
imageButtonAnchor.Position = UDim2.new(1, -325, 1, -80)
imageButtonAnchor.Image = "rbxassetid://97166444"
imageButtonAnchor.BackgroundTransparency = 1
imageButtonAnchor.ImageTransparency = 0.2
imageButtonAnchor.ImageColor3 = Color3.fromRGB(142, 142, 142)
imageButtonAnchor.Parent = gui2
imageKLabelDe = Instance.new("ImageLabel")
imageKLabelDe.Size = UDim2.new(1, 0, 1, 0)
imageKLabelDe.Image = "rbxassetid://3040311268"
imageKLabelDe.BackgroundTransparency = 1
imageKLabelDe.Parent = imageButtonAnchor
imageButtonAnchor.InputBegan:Connect(
    function(p1086_, p1087_)
        -- upvalues: (ref) v_u_598_
        if not p1087_ and (v_u_598_.TouchEnabled and p1086_.UserInputType == Enum.UserInputType.Touch) then
            anchorfunc()
        end
    end
)
imageButtonTeleport.InputBegan:Connect(
    function(p1088_, p1089_)
        -- upvalues: (ref) v_u_598_
        if not p1089_ and (v_u_598_.TouchEnabled and p1088_.UserInputType == Enum.UserInputType.Touch) then
            teleportfunc()
        end
    end
)
imageButtonControl.InputBegan:Connect(
    function(p1090_, p1091_)
        -- upvalues: (ref) v_u_598_
        if not p1091_ and (v_u_598_.TouchEnabled and p1090_.UserInputType == Enum.UserInputType.Touch) then
            controlBind("Control(C)", Enum.UserInputState.Begin)
        end
    end
)
local v1092_ =
    v550_:AddSection(
    {
        ["Name"] = "Teleport"
    }
)
local v1093_ =
    v550_:AddSection(
    {
        ["Name"] = "Spawn Toy"
    }
)
local v1094_ =
    v550_:AddSection(
    {
        ["Name"] = "Anchor"
    }
)
local v1095_ =
    v550_:AddSection(
    {
        ["Name"] = "Control Player/NPC"
    }
)
v1094_:AddToggle(
    {
        ["Name"] = "Anchor (K)",
        ["Default"] = false,
        ["Callback"] = function(p1096_)
            -- upvalues: (ref) v_u_13_
            imageButtonAnchor.Visible = p1096_
            imageButtonAnchor.Active = p1096_
            if p1096_ then
                v_u_13_:BindAction("AnchorK", anchorobject, false, Enum.KeyCode.K)
            else
                v_u_13_:UnbindAction("AnchorK")
            end
        end,
        ["Save"] = true,
        ["Flag"] = "anchorbind_toggle"
    }
)
v1094_:AddButton(
    {
        ["Name"] = "Compile Parts",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_298_
            v_u_298_()
        end
    }
)
v1092_:AddToggle(
    {
        ["Name"] = "Teleport (Z)",
        ["Default"] = false,
        ["Callback"] = function(p1097_)
            -- upvalues: (ref) v_u_13_, (ref) v_u_95_
            imageButtonTeleport.Visible = p1097_
            imageButtonTeleport.Active = p1097_
            if p1097_ then
                v_u_13_:BindAction("Teleport(Z)", v_u_95_, false, Enum.KeyCode.Z)
            else
                v_u_13_:UnbindAction("Teleport(Z)")
            end
        end,
        ["Save"] = true,
        ["Flag"] = "teleportbind_toggle"
    }
)
v1095_:AddToggle(
    {
        ["Name"] = "Control (C)",
        ["Default"] = false,
        ["Callback"] = function(p1098_)
            -- upvalues: (ref) v_u_13_
            imageButtonControl.Visible = p1098_
            imageButtonControl.Active = p1098_
            if p1098_ then
                v_u_13_:BindAction("Control(C)", controlBind, false, Enum.KeyCode.C)
            else
                v_u_13_:UnbindAction("Control(C)")
            end
        end,
        ["Save"] = true,
        ["Flag"] = "controlbind_toggle"
    }
)
v1093_:AddDropdown(
    {
        ["Name"] = "Select Toy",
        ["Default"] = "Pallet",
        ["Options"] = {
            "Pallet",
            "BombMissile"
        },
        ["Callback"] = function(p1099_)
            if p1099_ == "Pallet" then
                _G.SelectedToy = "PalletLightBrown"
            else
                _G.SelectedToy = p1099_
            end
        end,
        ["Save"] = true,
        ["Flag"] = "selecttoy_dropdown"
    }
)
v1093_:AddToggle(
    {
        ["Name"] = "Spawn Toy (TAB)",
        ["Default"] = false,
        ["Callback"] = function(p1100_)
            -- upvalues: (ref) v_u_13_, (ref) v_u_88_
            if p1100_ then
                v_u_13_:BindAction("Spawn Toy (TAB)", v_u_88_, false, Enum.KeyCode.Tab)
                v_u_13_:SetImage("Spawn Toy (TAB)", "rbxassetid://6723742952")
                v_u_13_:SetPosition("Spawn Toy (TAB)", UDim2.new(1, -367, 1, -90))
                local v1101_ = v_u_13_:GetButton("Spawn Toy (TAB)")
                if v1101_ then
                    v1101_.Size = UDim2.new(0, 70, 0, 70)
                end
            else
                v_u_13_:UnbindAction("Spawn Toy (TAB)")
            end
        end,
        ["Save"] = true,
        ["Flag"] = "spawntoy_toggle"
    }
)
local v1102_ =
    v555_:AddSection(
    {
        ["Name"] = "Whitelist"
    }
)
local v_u_1104_ =
    v1102_:AddDropdown(
    {
        ["Name"] = "Select Player",
        ["Default"] = "",
        ["Options"] = {
            ""
        },
        ["Callback"] = function(p1103_)
            if p1103_ then
                _G.PlayerToAddWhitelist = string.split(p1103_, " ")[1]
            end
        end
    }
)
local v_u_1105_ = nil
v1102_:AddButton(
    {
        ["Name"] = "Add",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_97_, (ref) v_u_350_, (ref) v_u_71_, (ref) v_u_1105_
            if not v_u_97_(_G.PlayerToAddWhitelist) then
                table.insert(v_u_350_, _G.PlayerToAddWhitelist)
                v_u_71_(v_u_1105_, v_u_350_)
            end
        end
    }
)
v_u_1105_ =
    v1102_:AddDropdown(
    {
        ["Name"] = "Players in Whitelist",
        ["Default"] = "",
        ["Options"] = {
            ""
        },
        ["Callback"] = function(p1106_)
            _G.PlayerToRemoveWhitelist = p1106_
        end
    }
)
v1102_:AddButton(
    {
        ["Name"] = "Remove",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_350_, (ref) v_u_71_, (ref) v_u_1105_
            local v1107_, v1108_, v1109_ = pairs(v_u_350_)
            while true do
                local v1110_
                v1109_, v1110_ = v1107_(v1108_, v1109_)
                if v1109_ == nil then
                    break
                end
                if v1110_ == _G.PlayerToRemoveWhitelist then
                    v_u_350_[v1109_] = nil
                end
            end
            v_u_71_(v_u_1105_, v_u_350_)
        end
    }
)
local v1111_ =
    v555_:AddSection(
    {
        ["Name"] = "Blobman Loopkick"
    }
)
local v1112_ =
    v555_:AddSection(
    {
        ["Name"] = "Perspective"
    }
)
v555_:AddSection(
    {
        ["Name"] = "Anchor Objects"
    }
):AddToggle(
    {
        ["Name"] = "Auto Ownership",
        ["Default"] = false,
        ["Callback"] = function(p1113_)
            _G.AutoOwnershipAnchor = p1113_
            if p1113_ then
                while _G.AutoOwnershipAnchor do
                    autosetownership()
                    task.wait(0.2)
                end
            end
        end,
        ["Save"] = true,
        ["Flag"] = "autoownershipanchorconfig_toggle"
    }
)
v1111_:AddToggle(
    {
        ["Name"] = "Heavy Blobman",
        ["Default"] = false,
        ["Callback"] = function(p1114_)
            _G.RockBlobman = p1114_
        end,
        ["Save"] = true,
        ["Flag"] = "heavyblobmanconfig_toggle"
    }
)
_G.PerspectiveEffectsAllow = true
v1112_:AddToggle(
    {
        ["Name"] = "Teleport to Camera Position",
        ["Default"] = true,
        ["Callback"] = function(p1115_)
            _G.PerspectiveTeleportToCameraPos = p1115_
        end,
        ["Save"] = true,
        ["Flag"] = "perspectiveconfig1_toggle"
    }
)
v1112_:AddDropdown(
    {
        ["Name"] = "Camera Effect",
        ["Default"] = "Default",
        ["Options"] = {
            "Default",
            "Old TV"
        },
        ["Callback"] = function(p1116_)
            -- upvalues: (ref) v_u_9_
            if p1116_ == "Default" then
                ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ImageLabel.BorderSizePixel = 0
                ImageLabel.Size = UDim2.new(1, 0, 1, 0)
                ImageLabel.Image = "rbxassetid://5945121255"
                ImageLabel.ImageColor3 = Color3.new(0, 0, 0)
                imagestransparencyeffect = 0.45
                saturationvalue = -0.6
                perspectiveON_effect1 =
                    v_u_9_:Create(
                    ImageLabel,
                    t1p,
                    {
                        ["ImageTransparency"] = imagestransparencyeffect
                    }
                )
                perspectiveON_effect2 =
                    v_u_9_:Create(
                    PerspectiveSaturation,
                    t1p,
                    {
                        ["Saturation"] = saturationvalue
                    }
                )
            elseif p1116_ == "Old TV" then
                ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ImageLabel.BorderSizePixel = 0
                ImageLabel.Size = UDim2.new(1, 0, 1, 0)
                ImageLabel.Image = "rbxassetid://8586979842"
                ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
                imagestransparencyeffect = 0.7
                saturationvalue = -0.3
                perspectiveON_effect1 =
                    v_u_9_:Create(
                    ImageLabel,
                    t1p,
                    {
                        ["ImageTransparency"] = imagestransparencyeffect
                    }
                )
                perspectiveON_effect2 =
                    v_u_9_:Create(
                    PerspectiveSaturation,
                    t1p,
                    {
                        ["Saturation"] = saturationvalue
                    }
                )
            end
        end,
        ["Save"] = true,
        ["Flag"] = "perspectivevisualeffect_dropdown"
    }
)
local v1117_ =
    v551_:AddSection(
    {
        ["Name"] = "Loop Players"
    }
)
local v1118_ =
    v551_:AddSection(
    {
        ["Name"] = "Players in Loop"
    }
)
local v1119_ =
    v551_:AddSection(
    {
        ["Name"] = "Loop Kill Functions"
    }
)
local v1120_ =
    v551_:AddSection(
    {
        ["Name"] = "Loop Kick (Blobman)"
    }
)
local v_u_1122_ =
    v1117_:AddDropdown(
    {
        ["Name"] = "Select Player",
        ["Default"] = "",
        ["Options"] = {
            ""
        },
        ["Callback"] = function(p1121_)
            if p1121_ then
                _G.PlayerToAdd = string.split(p1121_, " ")[1]
            end
        end
    }
)
local v_u_1123_ = nil
local v_u_1124_ = getgenv().key ~= "Xana" and 3 or 999999
v1117_:AddButton(
    {
        ["Name"] = "Add",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_62_, (ref) v_u_1124_, (ref) v_u_71_, (ref) v_u_1123_, (ref) v_u_33_
            if not table.find(v_u_62_, _G.PlayerToAdd) then
                if v_u_1124_ <= #v_u_62_ then
                    v_u_33_("You reached the max ammount of players in loop, buy premium to unlock more space!")
                else
                    table.insert(v_u_62_, _G.PlayerToAdd)
                    v_u_71_(v_u_1123_, v_u_62_)
                end
            end
        end
    }
)
local v_u_1126_ =
    v1118_:AddDropdown(
    {
        ["Name"] = "Players in Loop",
        ["Default"] = "",
        ["Options"] = {
            ""
        },
        ["Callback"] = function(p1125_)
            _G.PlayerToRemove = p1125_
        end
    }
)
v1118_:AddButton(
    {
        ["Name"] = "Remove",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_62_, (ref) v_u_71_, (ref) v_u_1126_
            local v1127_, v1128_, v1129_ = pairs(v_u_62_)
            while true do
                local v1130_
                v1129_, v1130_ = v1127_(v1128_, v1129_)
                if v1129_ == nil then
                    break
                end
                if v1130_ == _G.PlayerToRemove then
                    v_u_62_[v1129_] = nil
                end
            end
            v_u_71_(v_u_1126_, v_u_62_)
        end
    }
)
local function v_u_1137_()
    -- upvalues: (ref) v_u_17_, (ref) v_u_5_, (ref) v_u_540_
    if typeof(_G.LastBlobmanWasSeat) ~= "Instance" or not _G.LastBlobmanWasSeat.Parent then
        _G.LastBlobmanWasSeat = v_u_540_()
    else
        local v1131_ = GetPlayerCharacter()
        local v1132_ = _G.LastBlobmanWasSeat:FindFirstChild("VehicleSeat")
        local v1133_, v1134_
        if v1132_ then
            v1133_ = v1132_:FindFirstChild("ProximityPrompt")
            v1134_ = v1132_:FindFirstChildOfClass("Weld")
        else
            v1134_ = nil
            v1133_ = nil
        end
        if v_u_17_:DistanceFromCharacter(v1132_.Position) >= 150 then
            DeleteToyRE:FireServer(_G.LastBlobmanWasSeat)
            return
        end
        if v1131_ and (v1134_ and v1134_.Part1) and not v1134_.Part1:IsDescendantOf(v1131_) then
            local v1135_ = v1134_.Part1
            local v1136_ = v_u_5_
            SNOWshipPlayer(v1136_:GetPlayerFromCharacter(v1135_.Parent))
        end
        if v1133_ and v1132_ then
            fireproximityprompt(v1133_)
            TeleportPlayer(v1132_.CFrame + Vector3.new(0, 3.5, 0))
        end
    end
end
function CountRealNumberPlayersInLoop()
    -- upvalues: (ref) v_u_62_, (ref) v_u_5_
    local v1138_, v1139_, v1140_ = pairs(v_u_62_)
    local v1141_ = 0
    while true do
        local v1142_
        v1140_, v1142_ = v1138_(v1139_, v1140_)
        if v1140_ == nil then
            break
        end
        if v_u_5_:FindFirstChild(v1142_) then
            v1141_ = v1141_ + 1
        end
    end
    return v1141_
end
function IsThereAnyPlayersInLoopAlive()
    -- upvalues: (ref) v_u_62_, (ref) v_u_5_
    local v1143_, v1144_, v1145_ = pairs(v_u_62_)
    local v1146_ = false
    while true do
        local v1147_
        v1145_, v1147_ = v1143_(v1144_, v1145_)
        if v1145_ == nil then
            break
        end
        if v_u_5_:FindFirstChild(v1147_) and v1147_.Character then
            if v1147_.Character:FindFirstChildOfClass("Humanoid") and v1147_.Character.Humanoid.Health > 0 then
                v1146_ = true
            end
        end
    end
    return v1146_
end
function ResetCharacterStats()
    -- upvalues: (ref) v_u_62_, (ref) v_u_5_
    local v1148_, v1149_, v1150_ = pairs(v_u_62_)
    while true do
        local v1151_
        v1150_, v1151_ = v1148_(v1149_, v1150_)
        if v1150_ == nil then
            break
        end
        local v1152_ = v_u_5_:FindFirstChild(v1151_)
        if v1152_ and v1152_.Character and v1152_.Character:FindFirstChild("HumanoidRootPart") then
            local v1153_ = v1152_.Character.HumanoidRootPart
            v1152_.Character:SetAttribute("Kick", 0)
            v1152_.Character:SetAttribute("Kicking", nil)
            v1152_.Character:SetAttribute("Kicking2", nil)
            if v1153_:FindFirstChild("KickAuraVelocity") then
                v1153_.KickAuraVelocity:Destroy()
            end
        end
    end
end
function verifyPlayerinBlobmanHand()
    -- upvalues: (ref) v_u_17_, (ref) v_u_801_, (ref) v_u_5_
    local v1154_ = v_u_17_.Character:FindFirstChildOfClass("Humanoid")
    if v_u_801_() then
        local v1155_ = v1154_.SeatPart.Parent:WaitForChild("LeftDetector"):WaitForChild("LeftWeld").Attachment0
        local v1156_ = v1155_ and v1155_.Parent and v_u_5_:GetPlayerFromCharacter(v1155_.Parent.Parent)
        if v1156_ then
            return v1156_
        end
    end
end
local v_u_1157_ = nil
v1119_:AddToggle(
    {
        ["Name"] = "Loop Kill",
        ["Default"] = false,
        ["Callback"] = function(p1158_)
            -- upvalues: (ref) v_u_1157_, (ref) v_u_62_, (ref) v_u_5_, (ref) v_u_812_, (ref) v_u_349_, (ref) v_u_23_, (ref) v_u_351_
            _G.LoopKill = p1158_
            if p1158_ then
                while _G.LoopKill do
                    v_u_1157_ = GetPlayerCFrame()
                    local v1159_, v1160_, v1161_ = pairs(v_u_62_)
                    while true do
                        local v1162_
                        v1161_, v1162_ = v1159_(v1160_, v1161_)
                        if v1161_ == nil then
                            break
                        end
                        local v1163_ = v_u_5_:FindFirstChild(v1162_)
                        if v_u_812_(v1163_) then
                            local v1164_ = v1163_.Character:FindFirstChild("HumanoidRootPart")
                            local v1165_ = v1163_.Character:FindFirstChild("Head")
                            local v1166_ = v1163_.Character:FindFirstChild("Humanoid")
                            if v1163_ and (v1164_ and v1165_) then
                                for _ = 0, 50 do
                                    v_u_349_()
                                    SNOWship(v1164_)
                                    if
                                        not v_u_812_(v1163_) or
                                            (not _G.LoopKill or
                                                (CheckNetworkOwnerShipOnPlayer(v1163_) or
                                                    v1164_.AssemblyLinearVelocity.Magnitude > 500))
                                     then
                                        v_u_23_:FireServer(v1164_)
                                        CreateSkyVelocity(v1164_)
                                        break
                                    end
                                    task.wait()
                                    if v1164_.Position.Y <= -12 then
                                        TeleportPlayer(CFrame.new(v1164_.Position + Vector3.new(0, 5, -15)))
                                    else
                                        TeleportPlayer(CFrame.new(v1164_.Position + Vector3.new(0, -10, -10)))
                                    end
                                    v1166_.BreakJointsOnDeath = false
                                    v1166_:ChangeState(Enum.HumanoidStateType.Dead)
                                    v1166_.Jump = true
                                    v1166_.Sit = false
                                end
                            end
                        end
                    end
                    TeleportPlayer(v_u_1157_)
                    task.wait(0.2)
                end
                v_u_351_()
                TeleportPlayer(v_u_1157_)
                print("End LoopKill")
            end
        end,
        ["Save"] = true,
        ["Flag"] = "lk_toggle"
    }
)
local v1167_ =
    v551_:AddSection(
    {
        ["Name"] = "Loop Kick (Ownership)"
    }
)
loopkickownertoggle =
    v1167_:AddToggle(
    {
        ["Name"] = "Loop Kick",
        ["Default"] = false,
        ["Callback"] = function(p1168_)
            -- upvalues: (ref) v_u_33_, (ref) v_u_1157_, (ref) v_u_62_, (ref) v_u_5_, (ref) v_u_812_, (ref) v_u_349_, (ref) v_u_23_, (ref) v_u_351_
            _G.LoopKickOwnership = p1168_
            if p1168_ then
                while _G.LoopKickOwnership do
                    if getgenv().key ~= "Xana" then
                        _G.LoopKickOwnership = false
                        v_u_33_("Only for premium users! Buy premium in my discord server!")
                        loopkickownertoggle:Set(false)
                    end
                    v_u_1157_ = GetPlayerCFrame()
                    local v1169_, v1170_, v1171_ = pairs(v_u_62_)
                    while true do
                        local v1172_
                        v1171_, v1172_ = v1169_(v1170_, v1171_)
                        if v1171_ == nil then
                            break
                        end
                        local v1173_ = v_u_5_:FindFirstChild(v1172_)
                        if v_u_812_(v1173_) then
                            local v1174_ = v1173_.Character:FindFirstChild("HumanoidRootPart")
                            local v1175_ = v1173_.Character:FindFirstChild("Head")
                            v1173_.Character:FindFirstChild("Humanoid")
                            if v1173_ and (v1174_ and v1175_) then
                                for _ = 0, 50 do
                                    v_u_349_()
                                    SNOWship(v1174_)
                                    if
                                        not v_u_812_(v1173_) or
                                            (not _G.LoopKickOwnership or
                                                (CheckNetworkOwnerShipOnPlayer(v1173_) or
                                                    v1174_.AssemblyLinearVelocity.Magnitude > 500))
                                     then
                                        v_u_23_:FireServer(v1174_)
                                        wait()
                                        CreateSkyVelocity(v1174_)
                                        break
                                    end
                                    task.wait()
                                    if v1174_.Position.Y <= -12 then
                                        TeleportPlayer(CFrame.new(v1174_.Position + Vector3.new(0, 5, -15)))
                                    else
                                        TeleportPlayer(CFrame.new(v1174_.Position + Vector3.new(0, -10, -10)))
                                    end
                                end
                            end
                        end
                    end
                    TeleportPlayer(v_u_1157_)
                    task.wait(0.2)
                end
                v_u_351_()
                TeleportPlayer(v_u_1157_)
            end
        end,
        ["Save"] = true,
        ["Flag"] = "lkickowner_toggle"
    }
)
v1167_:AddDropdown(
    {
        ["Name"] = "Kick Type",
        ["Default"] = "Go to the heaven!",
        ["Options"] = {
            "Go to the heaven!"
        },
        ["Callback"] = function(p1176_)
            _G.LoopKickOwnerType = p1176_
        end,
        ["Save"] = true,
        ["Flag"] = "loopkickownershiptype_dropdown"
    }
)
loopRagdoll =
    v1119_:AddToggle(
    {
        ["Name"] = "Loop Ragdoll",
        ["Default"] = false,
        ["Callback"] = function(p1177_)
            -- upvalues: (ref) v_u_33_, (ref) v_u_62_, (ref) v_u_5_, (ref) v_u_818_, (ref) v_u_478_
            _G.LoopRagdoll = p1177_
            if p1177_ then
                while _G.LoopRagdoll do
                    if getgenv().key ~= "Xana" then
                        loopRagdoll:Set(false)
                        _G.LoopRagdoll = false
                        v_u_33_("Only for premium users! Buy premium in my discord server!")
                        break
                    end
                    local v1178_, v1179_, v1180_ = pairs(v_u_62_)
                    while true do
                        local v1181_
                        v1180_, v1181_ = v1178_(v1179_, v1180_)
                        if v1180_ == nil then
                            break
                        end
                        local v1182_ = v_u_5_:FindFirstChild(v1181_)
                        if v_u_818_(v1182_) then
                            local v1183_ = v1182_.Character
                            local v1184_ = v1182_.Character:FindFirstChild("HumanoidRootPart")
                            local v1185_ = v1183_:FindFirstChildOfClass("Humanoid"):FindFirstChild("Ragdolled")
                            if v1184_ and (v1185_ and not v1185_.Value) then
                                v_u_478_(v1184_)
                                task.wait(0.015)
                            end
                        end
                    end
                    task.wait()
                end
            end
        end
    }
)
loopFire =
    v1119_:AddToggle(
    {
        ["Name"] = "Loop Fire",
        ["Default"] = false,
        ["Callback"] = function(p1186_)
            -- upvalues: (ref) v_u_33_, (ref) v_u_62_, (ref) v_u_5_, (ref) v_u_818_, (ref) v_u_509_
            _G.LoopFire = p1186_
            if p1186_ then
                while _G.LoopFire do
                    if getgenv().key ~= "Xana" then
                        loopFire:Set(false)
                        _G.LoopFire = false
                        v_u_33_("Only for premium users! Buy premium in my discord server!")
                        break
                    end
                    local v1187_, v1188_, v1189_ = pairs(v_u_62_)
                    while true do
                        local v1190_
                        v1189_, v1190_ = v1187_(v1188_, v1189_)
                        if v1189_ == nil then
                            break
                        end
                        local v1191_ = v_u_5_:FindFirstChild(v1190_)
                        if v_u_818_(v1191_) then
                            local _ = v1191_.Character
                            local v1192_ = v1191_.Character:FindFirstChild("HumanoidRootPart")
                            local v1193_
                            if
                                v1192_:FindFirstChild("FirePlayerPart") and
                                    v1192_.FirePlayerPart:FindFirstChild("CanBurn")
                             then
                                v1193_ = v1192_.FirePlayerPart.CanBurn.Value
                            else
                                v1193_ = nil
                            end
                            if v1192_ and (v1191_ and not (IsPlayerInsideSafeZone(v1191_) or v1193_)) then
                                v_u_509_(v1192_)
                                task.wait(0.015)
                            end
                        end
                    end
                    task.wait()
                end
            end
        end
    }
)
local function v_u_1208_(p1194_, p1195_)
    -- upvalues: (ref) v_u_17_, (ref) v_u_801_, (ref) v_u_5_, (ref) v_u_51_, (ref) v_u_19_, (ref) v_u_4_, (ref) v_u_23_
    local v1196_ = v_u_17_.Character:FindFirstChildOfClass("Humanoid")
    if v_u_801_() then
        local v1197_ = v1196_.SeatPart.Parent
        local v1198_ = v_u_5_:FindFirstChild(p1194_)
        if
            v1198_ and v1198_.Character and
                (v1198_.Character:FindFirstChild("HumanoidRootPart") and (v1197_ and not v_u_51_(v1198_)))
         then
            local v1199_ = {
                v1197_.LeftDetector,
                v1198_.Character.HumanoidRootPart,
                v1197_.LeftDetector.LeftWeld
            }
            local v1200_ = {
                v1197_.LeftDetector.LeftWeld,
                v1198_.Character.HumanoidRootPart
            }
            CreatureGrab = v1197_.BlobmanSeatAndOwnerScript.CreatureGrab
            local v1201_ = v1197_.BlobmanSeatAndOwnerScript.CreatureDrop
            if v1197_ then
                if p1195_ == 1 then
                    if v1197_.Parent ~= v_u_19_ then
                        v_u_4_:MakeNotification(
                            {
                                ["Name"] = "You need to be seated on Blobman",
                                ["Content"] = "The Blobman needs to be your own toy",
                                ["Image"] = "rbxassetid://4483345998",
                                ["Time"] = 5
                            }
                        )
                    else
                        task.wait(0.2)
                        DeleteToyRE:FireServer(v1197_)
                    end
                elseif p1195_ == 2 then
                    CreatureGrab:FireServer(unpack(v1199_))
                    task.wait(0.155)
                    v1196_.Sit = false
                elseif
                    p1195_ == 3 and
                        not (v1198_.Character:GetAttribute("Kicking") or v1198_.Character:GetAttribute("Kicking2"))
                 then
                    local v1202_ = v_u_5_:FindFirstChild(p1194_)
                    local v1203_ = v1202_.Character
                    local v1204_ = v1203_.HumanoidRootPart
                    local _ = v1203_.Head
                    local v1205_ = v1203_:FindFirstChildOfClass("Humanoid")
                    local v1206_ = nil
                    v1203_:SetAttribute("Kicking", true)
                    if v1204_:FindFirstChild("FlingAuraVelocity") then
                        v1204_.FlingAuraVelocity:Destroy()
                    end
                    print("Kick")
                    for _ = 0, 50 do
                        if not v_u_801_() or CheckNetworkOwnerShipOnPlayer(v1202_) then
                            break
                        end
                        if verifyPlayerinBlobmanHand() == v1202_ then
                            v1201_:FireServer(unpack(v1200_))
                            break
                        end
                        CreatureGrab:FireServer(unpack(v1199_))
                        task.wait()
                    end
                    print("End Loop Here!")
                    for _ = 0, 25 do
                        if SNOWshipPlayer(v1202_) then
                            if not v1204_:FindFirstChild("KickAuraVelocity") then
                                v1206_ = Instance.new("BodyVelocity", v1204_)
                                v1206_.Name = "KickAuraVelocity"
                                v1206_.MaxForce = Vector3.new(0, 12500, 0)
                                v1206_.Velocity = Vector3.new(0, 100, 0)
                            end
                            local v1207_ = 0
                            while v_u_801_() and v1207_ < 100 do
                                if
                                    v1205_.FloorMaterial == Enum.Material.Air and
                                        v_u_17_:DistanceFromCharacter(v1204_.Position) > 100
                                 then
                                    v1203_:SetAttribute("Kicking2", true)
                                    v_u_23_:FireServer(v1204_)
                                    CreatureGrab:FireServer(unpack(v1199_))
                                    print("Destroyed!")
                                    break
                                end
                                SNOWshipPlayer(v1202_)
                                v1207_ = v1207_ + 1
                                task.wait()
                            end
                            break
                        end
                        if not v_u_801_() then
                            break
                        end
                        task.wait()
                    end
                    if v1206_ then
                        v1206_:Destroy()
                    end
                    v1203_:SetAttribute("Kicking", nil)
                elseif not p1195_ then
                    CreatureGrab:FireServer(unpack(v1199_))
                end
            end
        end
    else
        v_u_4_:MakeNotification(
            {
                ["Name"] = "You need to be seated on Blobman",
                ["Content"] = "Please, sit on any Blobman",
                ["Image"] = "rbxassetid://4483345998",
                ["Time"] = 5
            }
        )
    end
end
v1120_:AddToggle(
    {
        ["Name"] = "Loop Kick (Blobman)",
        ["Default"] = false,
        ["Callback"] = function(p1209_)
            -- upvalues: (ref) v_u_62_, (ref) v_u_5_, (ref) v_u_801_, (ref) v_u_1208_, (ref) v_u_1137_
            if p1209_ then
                _G.LoopKick = p1209_
                while _G.LoopKick do
                    local v1210_, v1211_, v1212_ = pairs(v_u_62_)
                    while true do
                        local v1213_
                        v1212_, v1213_ = v1210_(v1211_, v1212_)
                        if v1212_ == nil then
                            break
                        end
                        if v_u_5_:FindFirstChild(v1213_) then
                            if v_u_801_() then
                                v_u_1208_(v1213_, 3)
                            else
                                v_u_1137_()
                            end
                        end
                    end
                    task.wait()
                end
            else
                _G.LoopKick = p1209_
            end
        end,
        ["Save"] = true,
        ["Flag"] = "lkick_toggle"
    }
)
function blobmangraball()
    -- upvalues: (ref) v_u_5_, (ref) v_u_51_, (ref) v_u_17_, (ref) v_u_97_
    local v1214_ = v_u_5_
    local v1215_, v1216_, v1217_ = pairs(v1214_:GetPlayers())
    while true do
        local v1218_
        v1217_, v1218_ = v1215_(v1216_, v1217_)
        if v1217_ == nil then
            break
        end
        if
            not v_u_51_(v1218_) and (v1218_ ~= v_u_17_ and v1218_.Character) and
                (v1218_.Character:FindFirstChild("HumanoidRootPart") and
                    not (v_u_97_(v1218_.Name) and _G.WhitelistFriends2) and
                    v_u_17_.Character and
                    v_u_17_.Character:FindFirstChildOfClass("Humanoid"))
         then
            local v1219_ = v_u_17_.Character:FindFirstChildOfClass("Humanoid").SeatPart.Parent
            local v1220_ = {
                v1219_:WaitForChild("LeftDetector"),
                v1218_.Character:FindFirstChild("HumanoidRootPart"),
                v1219_:WaitForChild("LeftDetector"):WaitForChild("LeftWeld")
            }
            v1219_:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(unpack(v1220_))
        end
        task.wait()
    end
end
PlayerToSelect =
    LongReachGrab_Player:AddDropdown(
    {
        ["Name"] = "Select Player",
        ["Default"] = "",
        ["Options"] = {
            ""
        },
        ["Callback"] = function(p1221_)
            local v1222_ = string.split(p1221_, " ")
            _G.PlayerToLongGrab = v1222_[1]
        end
    }
)
LongReachGrab_Player:AddButton(
    {
        ["Name"] = "Lock",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_1208_
            v_u_1208_(_G.PlayerToLongGrab, 2)
        end
    }
)
LongReachGrab_Player:AddButton(
    {
        ["Name"] = "Bring",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_1208_
            v_u_1208_(_G.PlayerToLongGrab)
        end
    }
)
LongReachGrab_Player:AddButton(
    {
        ["Name"] = "Kick",
        ["Callback"] = function()
            -- upvalues: (ref) v_u_1208_
            v_u_1208_(_G.PlayerToLongGrab, 3)
        end
    }
)
local v1223_ =
    LongReachGrab_Player:AddSection(
    {
        ["Name"] = "Destroy Everything"
    }
)
local v_u_1224_ = nil
v_u_1224_ =
    v1223_:AddToggle(
    {
        ["Name"] = "Destroy Server",
        ["Default"] = false,
        ["Callback"] = function(p1225_)
            -- upvalues: (ref) v_u_20_, (ref) v_u_1224_, (ref) v_u_33_, (ref) v_u_801_, (ref) v_u_4_
            if p1225_ then
                _G.BringAllLongReach = true
                if getgenv().key ~= "Xana" and v_u_20_.Value then
                    v_u_1224_:Set(false)
                    v_u_33_("You can't use destroy server inside a house!, buy premium to be able to do that!")
                    return
                end
                if v_u_801_() then
                    while _G.BringAllLongReach do
                        if v_u_801_() then
                            blobmangraball()
                        else
                            task.wait(1)
                        end
                    end
                else
                    v_u_1224_:Set(false)
                    v_u_4_:MakeNotification(
                        {
                            ["Name"] = "You need to be seated on Blobman",
                            ["Content"] = "Please, sit on any Blobman",
                            ["Image"] = "rbxassetid://4483345998",
                            ["Time"] = 5
                        }
                    )
                end
            else
                _G.BringAllLongReach = false
            end
        end,
        ["Save"] = true,
        ["Flag"] = "BringAllLongReach_toggle"
    }
)
v_u_1224_ =
    v1223_:AddToggle(
    {
        ["Name"] = "Whitelist Friends",
        ["Default"] = false,
        ["Callback"] = function(p1226_)
            _G.WhitelistFriends2 = p1226_
        end,
        ["Save"] = true,
        ["Flag"] = "Whitelistfreinds2_toggle"
    }
)
apagarfogo = v_u_7_.Map.Hole.PoisonBigHole.ExtinguishPart
apagarfogo.Size = Vector3.new(0.5, 0.5, 0.5)
apagarfogo.Transparency = 1
apagarfogo.Tex.Transparency = 1
v_u_7_.ChildAdded:Connect(
    function(p_u_1227_)
        -- upvalues: (ref) v_u_51_, (ref) v_u_22_, (ref) v_u_7_, (ref) v_u_932_, (ref) v_u_585_, (ref) v_u_14_, (ref) v_u_933_, (ref) v_u_17_, (ref) v_u_6_, (ref) v_u_10_, (ref) v_u_381_, (ref) v_u_382_, (ref) v_u_383_, (ref) v_u_509_, (ref) v_u_825_, (ref) v_u_5_, (ref) v_u_23_
        if p_u_1227_.Name == "GrabParts" then
            local v_u_1228_ = p_u_1227_.GrabPart.WeldConstraint.Part1
            local v_u_1229_ = nil
            if v_u_1228_ then
                if v_u_51_(v_u_1228_.Parent) then
                    return
                end
                if _G.InvisibleLine then
                    v_u_22_:FireServer()
                end
                if _G.SuperStrength then
                    v_u_1229_ = Instance.new("BodyVelocity", v_u_1228_)
                    v_u_1229_.MaxForce = Vector3.new(0, 0, 0)
                    v_u_1229_.Velocity = Vector3.new()
                    v_u_1229_.Name = "SuperStrength"
                end
                if _G.MasslessGrab then
                    task.spawn(
                        function()
                            -- upvalues: (ref) p_u_1227_
                            local v1230_ = p_u_1227_.DragPart.AlignOrientation
                            local v1231_ = p_u_1227_.DragPart.AlignPosition
                            while _G.MasslessGrab do
                                v1230_.MaxTorque = 1e46
                                v1230_.Responsiveness = 20099
                                v1231_.MaxForce = 1e51
                                v1231_.Responsiveness = 20099
                                task.wait(0.245)
                            end
                            v1230_.MaxTorque = 600000
                            v1230_.Responsiveness = 30
                            v1231_.MaxForce = 60000
                            v1231_.Responsiveness = 40
                        end
                    )
                end
                if _G.NoclipGrab and not v_u_1228_.Anchored then
                    task.spawn(
                        function()
                            -- upvalues: (ref) v_u_1228_, (ref) p_u_1227_
                            if v_u_1228_.Parent and v_u_1228_.Parent:IsA("Model") then
                                local v1232_ = v_u_1228_.Parent:GetDescendants()
                                local v1233_ = v_u_1228_.Parent:FindFirstChildOfClass("Humanoid")
                                local v1234_, v1235_, v1236_ = pairs(v1232_)
                                local v1237_ = {}
                                while true do
                                    local v1238_
                                    v1236_, v1238_ = v1234_(v1235_, v1236_)
                                    if v1236_ == nil then
                                        break
                                    end
                                    if v1238_:IsA("BasePart") or (v1238_:IsA("Part") or v1238_:IsA("MeshPart")) then
                                        v1237_[v1238_] = v1238_.CanCollide
                                    end
                                end
                                while p_u_1227_.Parent do
                                    local v1239_, v1240_, v1241_ = pairs(v1232_)
                                    while true do
                                        local v1242_
                                        v1241_, v1242_ = v1239_(v1240_, v1241_)
                                        if v1241_ == nil then
                                            break
                                        end
                                        if v1242_:IsA("BasePart") or (v1242_:IsA("Part") or v1242_:IsA("MeshPart")) then
                                            v1242_.CanCollide = false
                                        end
                                    end
                                    wait(0.214)
                                end
                                if v1233_ then
                                    task.wait(0.5)
                                end
                                local v1243_, v1244_, v1245_ = pairs(v1232_)
                                while true do
                                    local v1246_
                                    v1245_, v1246_ = v1243_(v1244_, v1245_)
                                    if v1245_ == nil then
                                        break
                                    end
                                    if v1246_:IsA("BasePart") or (v1246_:IsA("Part") or v1246_:IsA("MeshPart")) then
                                        v1246_.CanCollide = v1237_[v1246_]
                                    end
                                end
                            end
                        end
                    )
                end
                if _G.PerspectiveGrab and not v_u_1228_.Anchored then
                    task.spawn(
                        function()
                            -- upvalues: (ref) v_u_22_, (ref) v_u_7_, (ref) v_u_932_, (ref) v_u_585_, (ref) v_u_14_, (ref) v_u_933_, (ref) p_u_1227_, (ref) v_u_17_
                            local v1247_ = GetPlayerCharacter()
                            v_u_22_:FireServer()
                            local v_u_1248_, v_u_1249_
                            if v1247_ then
                                v_u_1248_ = v1247_:FindFirstChildOfClass("Humanoid")
                                v_u_1249_ = v1247_:FindFirstChild("HumanoidRootPart")
                            else
                                v_u_1248_ = nil
                                v_u_1249_ = nil
                            end
                            local v_u_1250_ = Instance.new("Part", v_u_7_)
                            v_u_1250_.Anchored = true
                            v_u_1250_.CanCollide = false
                            v_u_1250_.Transparency = 1
                            v_u_1250_.CanQuery = false
                            v_u_1250_.Size = Vector3.new()
                            v_u_1250_.CFrame = workspace.CurrentCamera.CFrame
                            workspace.CurrentCamera.CameraType = Enum.CameraType.Follow
                            workspace.CurrentCamera.CameraSubject = v_u_1250_
                            if v_u_932_ then
                                v_u_932_:Disconnect()
                            end
                            if v_u_1248_ and v_u_1249_ then
                                local v1251_ = GetPlayerCFrame()
                                v_u_585_(true)
                                local v_u_1252_ = nil
                                local v_u_1253_ = nil
                                local v_u_1254_ = nil
                                local v_u_1255_ = nil
                                local v_u_1256_ = nil
                                local v_u_1257_ = nil
                                local v_u_1258_ = nil
                                v_u_932_ =
                                    v_u_14_.Heartbeat:Connect(
                                    function(p1259_)
                                        -- upvalues: (ref) v_u_1252_, (ref) v_u_1248_, (ref) v_u_933_, (ref) v_u_1253_, (ref) v_u_1250_, (ref) v_u_1254_, (ref) v_u_1255_, (ref) v_u_1256_, (ref) v_u_1257_, (ref) v_u_1258_, (ref) v_u_1249_
                                        v_u_1252_ = v_u_1248_.MoveDirection * (v_u_933_ * p1259_)
                                        v_u_1253_ = v_u_1250_.CFrame
                                        v_u_1254_ = workspace.CurrentCamera.CFrame
                                        v_u_1255_ = v_u_1253_:ToObjectSpace(v_u_1254_).Position
                                        v_u_1254_ = v_u_1254_ * CFrame.new(-v_u_1255_.X, -v_u_1255_.Y, -v_u_1255_.Z + 1)
                                        v_u_1256_ = v_u_1254_.Position
                                        v_u_1257_ = v_u_1253_.Position
                                        v_u_1258_ =
                                            CFrame.new(v_u_1256_, Vector3.new(v_u_1257_.X, v_u_1256_.Y, v_u_1257_.Z)):VectorToObjectSpace(
                                            v_u_1252_
                                        )
                                        v_u_1250_.CFrame =
                                            CFrame.new(v_u_1257_) * (v_u_1254_ - v_u_1256_) * CFrame.new(v_u_1258_)
                                        v_u_1249_.CFrame = CFrame.new(527, 123, -376)
                                    end
                                )
                                while p_u_1227_.Parent do
                                    task.wait()
                                end
                                local v1260_ = workspace.CurrentCamera.CFrame
                                v_u_585_(false)
                                workspace.CurrentCamera.CameraSubject =
                                    v_u_17_.Character:FindFirstChildOfClass("Humanoid")
                                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                                if v_u_932_ then
                                    v_u_932_:Disconnect()
                                end
                                if _G.PerspectiveTeleportToCameraPos then
                                    v_u_1249_.CFrame = v1260_
                                else
                                    v_u_1249_.CFrame = v1251_
                                end
                            end
                        end
                    )
                end
                task.spawn(
                    function()
                        -- upvalues: (ref) v_u_1229_, (ref) v_u_17_, (ref) p_u_1227_, (ref) v_u_6_
                        if v_u_1229_ then
                            if not v_u_17_.PlayerGui:FindFirstChild("ContextActionGui") then
                                return
                            end
                            local v1261_ = nil
                            local v_u_1262_ = nil
                            local v_u_1263_ = nil
                            while v1261_ == nil and p_u_1227_.Parent do
                                local v1264_, v1265_, v1266_ =
                                    pairs(game.Players.LocalPlayer.PlayerGui.ContextActionGui:GetDescendants())
                                while true do
                                    local v1267_
                                    v1266_, v1267_ = v1264_(v1265_, v1266_)
                                    if v1266_ == nil then
                                        break
                                    end
                                    if
                                        v1267_:IsA("ImageLabel") and
                                            v1267_.Image == "http://www.roblox.com/asset/?id=9603678090"
                                     then
                                        v1261_ = v1267_.Parent
                                    end
                                end
                                task.wait()
                            end
                            v1261_.Active = true
                            if v1261_ then
                                v_u_1262_ =
                                    v1261_.MouseButton1Down:Connect(
                                    function()
                                        -- upvalues: (ref) v_u_1229_
                                        print("Launched Mobile!")
                                        pressedStrength = true
                                        v_u_1229_.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                        v_u_1229_.Velocity = workspace.CurrentCamera.CFrame.lookVector * _G.Strength
                                    end
                                )
                            end
                            local _ =
                                p_u_1227_:GetPropertyChangedSignal("Parent"):Connect(
                                function()
                                    -- upvalues: (ref) p_u_1227_, (ref) v_u_6_, (ref) v_u_1229_, (ref) v_u_1262_, (ref) v_u_1263_
                                    if not p_u_1227_.Parent then
                                        v_u_6_:AddItem(v_u_1229_, 1)
                                        if v_u_1262_ then
                                            v_u_1262_:Disconnect()
                                        end
                                        v_u_1263_:Disconnect()
                                    end
                                end
                            )
                        end
                    end
                )
                task.spawn(
                    function()
                        -- upvalues: (ref) v_u_1229_, (ref) p_u_1227_, (ref) v_u_10_, (ref) v_u_6_
                        if v_u_1229_ then
                            local v_u_1268_ = nil
                            v_u_1268_ =
                                p_u_1227_:GetPropertyChangedSignal("Parent"):Connect(
                                function()
                                    -- upvalues: (ref) p_u_1227_, (ref) v_u_10_, (ref) v_u_1229_, (ref) v_u_6_, (ref) v_u_1268_
                                    if not p_u_1227_.Parent then
                                        if
                                            v_u_10_:GetLastInputType() ~= Enum.UserInputType.MouseButton2 or
                                                not _G.SuperStrength
                                         then
                                            if v_u_10_:GetLastInputType() == Enum.UserInputType.MouseButton1 then
                                                v_u_1229_:Destroy()
                                            end
                                        else
                                            print("Launched!")
                                            pressedStrength = true
                                            v_u_1229_.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                            v_u_1229_.Velocity = workspace.CurrentCamera.CFrame.lookVector * _G.Strength
                                            v_u_6_:AddItem(v_u_1229_, 1)
                                        end
                                        v_u_1268_:Disconnect()
                                    end
                                end
                            )
                        end
                    end
                )
                if _G.Poison_Grab then
                    task.spawn(
                        function()
                            -- upvalues: (ref) v_u_1228_, (ref) p_u_1227_, (ref) v_u_381_, (ref) v_u_382_, (ref) v_u_383_
                            if v_u_1228_.Parent:FindFirstChildOfClass("Humanoid") then
                                local v1269_ = v_u_1228_.Parent.Head
                                while p_u_1227_.Parent and _G.Poison_Grab do
                                    v_u_381_.CFrame = v1269_.CFrame
                                    v_u_382_.CFrame = v1269_.CFrame
                                    v_u_383_.CFrame = v1269_.CFrame
                                    task.wait()
                                    v_u_383_.Position = Vector3.new(0, -50, 0)
                                    v_u_382_.Position = Vector3.new(0, -50, 0)
                                    v_u_381_.Position = Vector3.new(0, -50, 0)
                                end
                            end
                        end
                    )
                end
                if _G.Burn_Grab then
                    task.spawn(
                        function()
                            -- upvalues: (ref) p_u_1227_, (ref) v_u_1228_, (ref) v_u_509_
                            while p_u_1227_.Parent and _G.Burn_Grab do
                                if v_u_1228_.Parent:FindFirstChildOfClass("Humanoid") then
                                    v_u_509_(v_u_1228_.Parent.HumanoidRootPart)
                                elseif v_u_1228_.Parent:FindFirstChild("FireDetector") then
                                    v_u_509_(v_u_1228_.Parent.FireDetector)
                                else
                                    v_u_509_(v_u_1228_)
                                end
                                task.wait()
                            end
                        end
                    )
                end
                if _G.Radiactive_Grab then
                    task.spawn(
                        function()
                            -- upvalues: (ref) v_u_1228_, (ref) p_u_1227_, (ref) v_u_825_
                            if v_u_1228_.Parent:FindFirstChildOfClass("Humanoid") then
                                while p_u_1227_.Parent and _G.Radiactive_Grab do
                                    v_u_825_.Position = v_u_1228_.Position
                                    task.wait()
                                end
                                v_u_825_.Position = Vector3.new(0, -50, 0)
                            end
                        end
                    )
                end
                if _G.Death_Grab then
                    task.spawn(
                        function()
                            -- upvalues: (ref) v_u_1228_, (ref) v_u_5_, (ref) v_u_23_
                            if v_u_1228_.Parent:FindFirstChildOfClass("Humanoid") then
                                local v1270_ = v_u_1228_.Parent:FindFirstChildOfClass("Humanoid")
                                local _ = v_u_1228_.Parent.HumanoidRootPart
                                while v_u_1228_.Parent do
                                    local v1271_ = v_u_5_
                                    if CheckNetworkOwnerShipOnPlayer(v1271_:GetPlayerFromCharacter(v_u_1228_.Parent)) then
                                        v1270_.BreakJointsOnDeath = false
                                        v1270_:ChangeState(Enum.HumanoidStateType.Dead)
                                        v1270_.Jump = true
                                        v1270_.Sit = false
                                        if v1270_:GetStateEnabled(Enum.HumanoidStateType.Dead) then
                                            v_u_23_:FireServer(v_u_1228_)
                                        end
                                    end
                                    task.wait()
                                end
                            end
                        end
                    )
                end
            end
        end
    end
)
workspace.DescendantAdded:Connect(
    function(p1272_)
        -- upvalues: (ref) v_u_17_
        if p1272_.Name == "PartOwner" and p1272_.Parent.Name == "Head" then
            local v1273_ = p1272_.Parent.Parent:FindFirstChild("HumanoidRootPart")
            if v1273_:FindFirstChild("KickAuraP") then
                v1273_.KickAuraP:Destroy()
            end
            if v1273_:FindFirstChild("KickAuraP1") then
                v1273_.KickAuraP1:Destroy()
            end
            if v1273_:FindFirstChild("SkyVelocity") then
                v1273_.SkyVelocity:Destroy()
            end
        end
        if p1272_.Name == "TimeRemainingNum" and p1272_.Parent.Value == v_u_17_.Name then
            _G.RemainingTimeInHouse = p1272_
        end
    end
)
v_u_27_.Changed:Connect(
    function(p1274_)
        -- upvalues: (ref) v_u_51_, (ref) v_u_5_, (ref) v_u_29_, (ref) v_u_17_, (ref) v_u_27_, (ref) v_u_14_, (ref) v_u_30_, (ref) v_u_25_
        if p1274_ == true and (not v_u_51_(v_u_5_:FindFirstChild(v_u_29_)) and _G.AntiGrab) then
            local v_u_1275_ = (v_u_17_.Character or v_u_17_.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
            if v_u_27_.Value then
                local v_u_1276_ = nil
                v_u_1276_ =
                    v_u_14_.Heartbeat:Connect(
                    function()
                        -- upvalues: (ref) v_u_27_, (ref) v_u_1275_, (ref) v_u_30_, (ref) v_u_17_, (ref) v_u_25_, (ref) v_u_1276_
                        if v_u_27_.Value then
                            v_u_1275_.Velocity = Vector3.new()
                            v_u_1275_.Anchored = true
                            v_u_30_:FireServer(v_u_17_)
                            v_u_25_:FireServer(v_u_1275_, 0)
                        else
                            v_u_1275_.Velocity = Vector3.new()
                            v_u_1275_.Anchored = false
                            v_u_1276_:Disconnect()
                        end
                    end
                )
            end
        end
    end
)
function IsReallyBeingHeld()
    -- upvalues: (ref) v_u_27_, (ref) v_u_51_, (ref) v_u_5_, (ref) v_u_29_
    if v_u_27_.Value and not _G.AntiGrab then
        return true
    end
    if v_u_27_.Value and v_u_51_(v_u_5_:FindFirstChild(v_u_29_)) then
        return true
    end
end
function setMasslessFalse(p1277_)
    local v1278_, v1279_, v1280_ = ipairs(p1277_:GetDescendants())
    while true do
        local v1281_
        v1280_, v1281_ = v1278_(v1279_, v1280_)
        if v1280_ == nil then
            break
        end
        if v1281_:IsA("BasePart") then
            v1281_.Massless = false
        end
    end
end
function enforceMasslessFalse(p1282_)
    p1282_.DescendantAdded:Connect(
        function(p_u_1283_)
            if p_u_1283_:IsA("BasePart") then
                p_u_1283_:GetPropertyChangedSignal("Massless"):Connect(
                    function()
                        -- upvalues: (ref) p_u_1283_
                        if p_u_1283_.Massless then
                            p_u_1283_.Massless = false
                        end
                    end
                )
            end
        end
    )
    local v1284_, v1285_, v1286_ = ipairs(p1282_:GetDescendants())
    while true do
        local v_u_1287_
        v1286_, v_u_1287_ = v1284_(v1285_, v1286_)
        if v1286_ == nil then
            break
        end
        if v_u_1287_:IsA("BasePart") then
            v_u_1287_:GetPropertyChangedSignal("Massless"):Connect(
                function()
                    -- upvalues: (ref) v_u_1287_
                    if v_u_1287_.Massless then
                        v_u_1287_.Massless = false
                    end
                end
            )
        end
    end
end
function reconnect()
    -- upvalues: (ref) v_u_17_, (ref) v_u_25_, (ref) v_u_349_, (ref) v_u_29_, (ref) v_u_5_, (ref) v_u_51_, (ref) v_u_23_, (ref) v_u_801_
    local v1288_ = v_u_17_.Character or v_u_17_.CharacterAdded:Wait()
    local v_u_1289_ = v1288_:FindFirstChildWhichIsA("Humanoid") or v1288_:WaitForChild("Humanoid")
    local v_u_1290_ = v1288_:WaitForChild("HumanoidRootPart")
    v1288_:WaitForChild("Head")
    CharacterRaycastFilter.FilterDescendantsInstances[1] = v1288_
    COAroundPParams.FilterDescendantsInstances[1] = v1288_
    scriptToGetSenv = v1288_:WaitForChild("GrabbingScript")
    if scriptToGetSenv and getsenv then
        senv = getsenv(scriptToGetSenv)
    end
    local v_u_1291_ = v_u_1290_:WaitForChild("FirePlayerPart"):WaitForChild("CanBurn")
    local v_u_1292_ = v_u_1289_:WaitForChild("Ragdolled")
    if getgenv().key == "Xana" then
        local v_u_1293_ = v_u_1290_ and v_u_1290_:FindFirstChild("RootAttachment")
        if v_u_1293_ then
            task.delay(
                1,
                function()
                    -- upvalues: (ref) v_u_1293_
                    v_u_1293_:Destroy()
                end
            )
        end
        v1288_.DescendantAdded:Connect(
            function(p1294_)
                -- upvalues: (ref) v_u_25_, (ref) v_u_1290_
                if p1294_.Name == "PartOwner" and (p1294_.Parent.Name ~= "Head" and _G.AntiKick) then
                    v_u_25_:FireServer(v_u_1290_, 0)
                end
            end
        )
        setMasslessFalse(v1288_)
        enforceMasslessFalse(v1288_)
    end
    local v_u_1295_ = Instance.new("BodyPosition", v_u_1290_)
    v_u_1295_.MaxForce = Vector3.new(0, 0, 0)
    v_u_1289_.JumpPower = _G.InfiniteJumpPower
    if _G.NoclipToggle then
        v_u_349_()
    end
    v1288_.DescendantAdded:Connect(
        function(p1296_)
            -- upvalues: (ref) v_u_29_, (ref) v_u_5_, (ref) v_u_51_, (ref) v_u_17_, (ref) v_u_23_
            if p1296_.Name == "PartOwner" then
                v_u_29_ = tostring(p1296_.Value)
                if _G.AutoAttacker then
                    local v_u_1297_ = v_u_5_:FindFirstChild(v_u_29_)
                    local v_u_1298_ = nil
                    local v_u_1299_ = nil
                    if v_u_1297_ and v_u_1297_.Character then
                        local v1300_ = v_u_1297_.Character
                        if v1300_ then
                            v_u_1298_ = v1300_:FindFirstChildOfClass("Humanoid")
                            v_u_1299_ = v1300_:FindFirstChild("HumanoidRootPart")
                        end
                    end
                    if v_u_1297_ and (v_u_51_(v_u_1297_) == false and v_u_1297_ ~= v_u_17_) then
                        local v1301_ = nil
                        local v_u_1302_ = nil
                        local v1303_ = false
                        local v1304_
                        if _G.CounterMode == "Repulsion" or not _G.CounterMode then
                            v1304_ = function()
                                -- upvalues: (ref) v_u_1302_, (ref) v_u_17_, (ref) v_u_1299_, (ref) v_u_1297_, (ref) v_u_23_
                                v_u_1302_ = lookAt(v_u_17_.Character.HumanoidRootPart.Position, v_u_1299_.Position)
                                local v1305_ = Instance.new("BodyVelocity", v_u_1297_.Character.HumanoidRootPart)
                                v1305_.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                v1305_.Velocity = Vector3.new(v_u_1302_.lookVector.X, 0.5, v_u_1302_.lookVector.Z) * 100
                                wait()
                                v1305_:Destroy()
                                v_u_23_:FireServer(v_u_1299_)
                            end
                        elseif _G.CounterMode ~= "Freeze" then
                            if _G.CounterMode ~= "Kick" then
                                v1304_ = _G.CounterMode == "Death" and function()
                                        -- upvalues: (ref) v_u_1298_, (ref) v_u_1299_, (ref) v_u_23_
                                        local v1306_ = v_u_1298_
                                        if v1306_ then
                                            CreateSkyVelocity(v_u_1299_)
                                            for _ = 0, 20 do
                                                v1306_.BreakJointsOnDeath = false
                                                v1306_:ChangeState(Enum.HumanoidStateType.Dead)
                                                v1306_.Jump = true
                                                v1306_.Sit = true
                                            end
                                            task.wait()
                                            v_u_23_:FireServer(v_u_1299_)
                                        end
                                    end or v1301_
                            else
                                v1304_ = function()
                                    -- upvalues: (ref) v_u_1299_, (ref) v_u_23_
                                    CreateSkyVelocity(v_u_1299_)
                                    wait(1)
                                    v_u_23_:FireServer(v_u_1299_)
                                end
                            end
                        else
                            v1304_ = function()
                                -- upvalues: (ref) v_u_1298_
                                local v1307_ = v_u_1298_
                                if v1307_ then
                                    v1307_.WalkSpeed = 0
                                    v1307_.Sit = false
                                    v1307_.JumpPower = 0
                                end
                            end
                        end
                        if v1303_ then
                            for _ = 1, 50 do
                                SNOWshipPermanentPlayer(v_u_1297_, v1304_)
                                task.wait()
                            end
                        else
                            for _ = 1, 50 do
                                if SNOWshipPlayer(v_u_1297_, v1304_) then
                                    break
                                end
                                task.wait()
                            end
                        end
                    end
                end
            end
        end
    )
    v_u_1291_.Changed:Connect(
        function(p1308_)
            -- upvalues: (ref) v_u_1291_, (ref) v_u_1290_
            if p1308_ and _G.AntiBurn then
                while v_u_1291_.Value do
                    if firetouchinterest then
                        firetouchinterest(v_u_1290_.FirePlayerPart, apagarfogo, 0)
                        task.wait()
                        firetouchinterest(v_u_1290_.FirePlayerPart, apagarfogo, 1)
                    else
                        apagarfogo.CFrame =
                            v_u_1290_.FirePlayerPart.CFrame *
                            CFrame.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
                        task.wait()
                        apagarfogo.Position = Vector3.new(0, -100, 0)
                    end
                end
            end
        end
    )
    v_u_1292_.Changed:Connect(
        function(p1309_)
            -- upvalues: (ref) v_u_1292_, (ref) v_u_1290_
            if p1309_ and _G.AntiExplosion then
                while v_u_1292_.Value do
                    if IsReallyBeingHeld() then
                        v_u_1290_.Anchored = false
                    else
                        v_u_1290_.Anchored = true
                        v_u_1290_.Velocity = Vector3.new()
                    end
                    task.wait()
                end
                v_u_1290_.Velocity = Vector3.new()
                v_u_1290_.Anchored = false
            end
        end
    )
    v_u_1289_.Changed:Connect(
        function(p1310_)
            -- upvalues: (ref) v_u_1289_, (ref) v_u_1295_, (ref) v_u_1290_, (ref) v_u_801_
            if p1310_ == "Sit" and v_u_1289_.Sit == true then
                if v_u_1289_.SeatPart == nil or tostring(v_u_1289_.SeatPart.Parent) ~= "CreatureBlobman" then
                    if v_u_1289_.SeatPart == nil and _G.AntiGrab then
                        v_u_1289_:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                        v_u_1289_.Sit = false
                    end
                elseif _G.RockBlobman then
                    v_u_1295_.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    v_u_1295_.Position = v_u_1290_.Position
                end
            end
            if p1310_ == "SeatPart" and v_u_1289_.SeatPart == nil then
                ResetCharacterStats()
                if v_u_1290_:FindFirstChild("BodyPositionFloat") then
                    v_u_1290_.BodyPositionFloat:Destroy()
                end
                v_u_1295_.MaxForce = Vector3.new(0, 0, 0)
            end
            if p1310_ == "MoveDirection" and (_G.RockBlobman and v_u_801_()) then
                v_u_1295_.Position = v_u_1290_.Position
                if v_u_1289_.MoveDirection.Magnitude <= 0 then
                    v_u_1295_.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                else
                    v_u_1295_.MaxForce = Vector3.new(0, 0, 0)
                end
            end
        end
    )
    local v1311_ = v_u_1289_ and v_u_1289_:WaitForChild("Animator", 1)
    if v1311_ then
        TypeAnimation = v1311_:LoadAnimation(typeAnimation)
        FlailAnimation = v1311_:LoadAnimation(flailAnimation)
    end
end
v_u_10_.JumpRequest:Connect(
    function()
        -- upvalues: (ref) v_u_17_
        if _G.InfiniteJump then
            v_u_17_.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
)
v_u_14_.Heartbeat:Connect(
    function()
        -- upvalues: (ref) v_u_17_
        if _G.SuperSpeed then
            v_u_17_.Character.HumanoidRootPart.CFrame =
                v_u_17_.Character.HumanoidRootPart.CFrame +
                v_u_17_.Character:FindFirstChildOfClass("Humanoid").MoveDirection * Multiplier
        end
    end
)
function CanRemoveStickyPart(_, p1312_, _)
    return p1312_:GetAttribute("Kicking2") and true or nil
end
task.spawn(
    function()
        -- upvalues: (ref) v_u_5_, (ref) v_u_810_, (ref) v_u_442_
        while task.wait() do
            local v1313_ = v_u_5_
            local v1314_, v1315_, v1316_ = pairs(v1313_:GetPlayers())
            while true do
                local v1317_
                v1316_, v1317_ = v1314_(v1315_, v1316_)
                if v1316_ == nil then
                    break
                end
                if v_u_810_(v1317_) then
                    local v1318_ = v1317_.Character
                    local v1319_ = v1317_.Character:FindFirstChild("HumanoidRootPart")
                    if v1317_ and (v1318_ and (v1319_ and CanRemoveStickyPart(v1317_, v1318_, v1319_))) then
                        v_u_442_(v1319_)
                    end
                end
            end
        end
    end
)
function PlayerRemoving_Added(_)
    -- upvalues: (ref) v_u_61_, (ref) v_u_1122_, (ref) v_u_1104_, (ref) v_u_79_
    v_u_61_(PlayerToSelect)
    v_u_61_(v_u_1122_)
    v_u_61_(v_u_1104_)
    v_u_61_(PlayerToTeleport)
    v_u_79_(PlayerToTarget)
end
local _ = PlayerRemoving_Added
v_u_5_.PlayerAdded:Connect(PlayerRemoving_Added)
v_u_5_.PlayerRemoving:Connect(PlayerRemoving_Added)
task.spawn(PlayerRemoving_Added)
task.spawn(reconnect)
v_u_5_.PlayerAdded:Connect(
    function(p1320_)
        -- upvalues: (ref) v_u_17_, (ref) v_u_97_, (ref) v_u_350_, (ref) v_u_71_, (ref) v_u_1105_
        if p1320_:IsFriendsWith(v_u_17_.UserId) and not v_u_97_(p1320_.Name) then
            table.insert(v_u_350_, p1320_.Name)
        end
        v_u_71_(v_u_1105_, v_u_350_)
    end
)
task.spawn(
    function()
        -- upvalues: (ref) v_u_5_, (ref) v_u_17_, (ref) v_u_350_, (ref) v_u_71_, (ref) v_u_1105_
        local v1321_ = v_u_5_
        local v1322_, v1323_, v1324_ = pairs(v1321_:GetPlayers())
        while true do
            local v1325_
            v1324_, v1325_ = v1322_(v1323_, v1324_)
            if v1324_ == nil then
                break
            end
            if v1325_:IsFriendsWith(v_u_17_.UserId) then
                table.insert(v_u_350_, v1325_.Name)
            end
        end
        v_u_71_(v_u_1105_, v_u_350_)
    end
)
v_u_17_.CharacterAdded:Connect(reconnect)
v_u_4_:Init()
