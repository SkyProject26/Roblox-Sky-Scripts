--// IceHub 完全版（スマホ対応/中央飛び防止/修正済み） //--
local P=game:GetService("Players")
local LP=P.LocalPlayer
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")

local O=loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
if not O then return end

local W=O:MakeWindow({Name="❄️ IceHub",HidePremium=true})

local mode,loop,toys="none",nil,{}
local infJump,noclipActive,espActive=false,false,false
local espObjs={}
local speedVal=16
local attachTarget=false
local targetPlayer=nil

local itemList={"GlassBoxGray","FireworkSparkler"}
local selectedItem="GlassBoxGray"

local w={sp=4,h=2,b=3,t=45,s=2,amp=1,wd=1}
local s={r=5,s=1,h=0}
local he={r=3,s=2,h=3}
local m={r=8,s=1,h=0}
local t={r=5,s=2,h=2}
local f={r=8,s=1,h=3}
local sp={r=5,s=1,h=1}
local heart={size=5,s=1,h=2}

local function getTargetChar()
    if attachTarget and targetPlayer and targetPlayer.Character then
        return targetPlayer.Character
    end
    return LP.Character
end

local function findItems()
    local items={}
    local myChar=LP.Character
    for _,v in ipairs(WS:GetDescendants()) do
        if v:IsA("Model") and v.Name==selectedItem and v~=myChar then
            table.insert(items,v)
        end
    end
    if #items==0 then
        for i=1,8 do
            local m=Instance.new("Model",WS)
            m.Name=selectedItem
            local p=Instance.new("Part",m)
            p.Size=Vector3.new(2,2,2)
            p.Anchored=true
            p.Transparency=0.5
            local pos=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            p.Position=pos and pos.Position+Vector3.new(math.sin(i)*5,0,math.cos(i)*5) or Vector3.new(0,10,0)
            table.insert(items,m)
        end
    end
    return items
end

local function getPart(m) return m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart") end

local function attachPhysics(p)
    if not p then return end
    for _,x in ipairs(p:GetChildren()) do
        if x:IsA("BodyGyro") or x:IsA("BodyPosition") then x:Destroy() end
    end
    p.Anchored=false
    local bp=Instance.new("BodyPosition",p)
    local bg=Instance.new("BodyGyro",p)
    bp.P=3000
    bp.D=100
    bp.MaxForce=Vector3.new(1e5,1e5,1e5)
    bg.P=3000
    bg.D=100
    bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
    return bg,bp
end

local function stop()
    if loop then loop:Disconnect() end
    for _,t in ipairs(toys) do
        if t.BG then t.BG:Destroy() end
        if t.BP then t.BP:Destroy() end
        if t.model then
            for _,c in ipairs(t.model:GetChildren()) do
                if c:IsA("BasePart") then
                    c.CanCollide=true
                    c.Anchored=false
                end
            end
        end
    end
    toys={}
    mode="none"
end

local function makeMotion(name,init,update)
    return function()
        stop()
        local items=findItems()
        if #items==0 then O:MakeNotification({Name="IceHub",Content="アイテム無し",Time=2}) return end
        mode=name
        local time=0
        init(items)
        loop=RS.RenderStepped:Connect(function(dt)
            if mode~=name or not LP.Character then return end
            local targetChar=getTargetChar()
            if not targetChar then return end
            local hrp=targetChar:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            time=time+dt
            update(hrp,time)
        end)
        O:MakeNotification({Name="IceHub",Content=name.." ON",Time=1})
    end
end

-- 羽
local wingInit=function(items)
    local pts={}
    for i=1,#items do
        pts[i]={off=(i-math.ceil(#items/2))*w.sp*w.wd, rk=math.abs((i-math.ceil(#items/2))*w.sp*w.wd)}
    end
    table.sort(pts,function(a,b) return a.rk<b.rk end)
    for r,p in ipairs(pts) do p.rk=r end
    for i,item in ipairs(items) do
        local p=getPart(item)
        if p then
            for _,c in ipairs(item:GetChildren()) do
                if c:IsA("BasePart") then c.CanCollide=false c.Anchored=false end
            end
            local bg,bp=attachPhysics(p)
            table.insert(toys,{BG=bg,BP=bp,model=item,off=pts[i].off,rk=pts[i].rk})
        end
    end
end
local wingUpdate=function(hrp,t)
    local targetChar=getTargetChar()
    if not targetChar then return end
    local torso=targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso")
    if not torso then return end
    local right,look=hrp.CFrame.RightVector,hrp.CFrame.LookVector
    local base=torso.Position+Vector3.new(0,w.h,0)-look*w.b
    for _,v in ipairs(toys) do
        if v.BP then
            local fp=base+right*v.off+Vector3.new(0,math.sin(t*w.s)*w.amp*v.rk,0)
            v.BP.Position=fp
            if v.BG then
                v.BG.CFrame=CFrame.new(fp)*CFrame.Angles(0,math.atan2(-look.X,-look.Z),0)*CFrame.Angles(math.rad(-w.t),0,0)
            end
        end
    end
end

-- 球体
local sphereInit=function(items)
    for i,item in ipairs(items) do
        local p=getPart(item)
        if p then
            for _,c in ipairs(item:GetChildren()) do if c:IsA("BasePart") then c.CanCollide=false c.Anchored=false end end
            local bg,bp=attachPhysics(p)
            table.insert(toys,{BG=bg,BP=bp,model=item,phi=math.acos(1-2*(i-0.5)/#items),theta=math.pi*(1+math.sqrt(5))*i})
        end
    end
end
local sphereUpdate=function(hrp,t)
    local center=hrp.Position+Vector3.new(0,s.h,0)
    for _,v in ipairs(toys) do
        if v.BP then
            local ct=v.theta+t*s.s
            v.BP.Position=Vector3.new(center.X+s.r*math.sin(v.phi)*math.cos(ct),center.Y+s.r*math.cos(v.phi),center.Z+s.r*math.sin(v.phi)*math.sin(ct))
        end
    end
end

-- 頭上
local headInit=function(items)
    for i,item in ipairs(items) do
        local p=getPart(item)
        if p then
            for _,c in ipairs(item:GetChildren()) do if c:IsA("BasePart") then c.CanCollide=false c.Anchored=false end end
            local bg,bp=attachPhysics(p)
            table.insert(toys,{BG=bg,BP=bp,model=item,ang=(i-1)*(360/#items)})
        end
    end
end
local headUpdate=function(hrp,t)
    local center=hrp.Position+Vector3.new(0,he.h,0)
    for _,v in ipairs(toys) do
        if v.BP then
            local rad=math.rad(v.ang+t*he.s*360)
            v.BP.Position=Vector3.new(center.X+he.r*math.cos(rad),center.Y,center.Z+he.r*math.sin(rad))
        end
    end
end

-- 魔法陣
local magicInit=function(items)
    for i,item in ipairs(items) do
        local p=getPart(item)
        if p then
            for _,c in ipairs(item:GetChildren()) do if c:IsA("BasePart") then c.CanCollide=false c.Anchored=false end end
            local bg,bp=attachPhysics(p)
            table.insert(toys,{BG=bg,BP=bp,model=item,ang=(i-1)*(360/#items)})
        end
    end
end
local magicUpdate=function(hrp,t)
    local center=hrp.Position+Vector3.new(0,m.h,0)
    for _,v in ipairs(toys) do
        if v.BP then
            local rad=math.rad(v.ang+t*m.s*60)
            local x=center.X+m.r*math.cos(rad)
            local z=center.Z+m.r*math.sin(rad)
            v.BP.Position=Vector3.new(x,center.Y,z)
            if v.BG then v.BG.CFrame=CFrame.new(x,center.Y,z)*CFrame.Angles(0,rad,0) end
        end
    end
end

-- 竜巻
local tornadoInit=function(items)
    for i,item in ipairs(items) do
        local p=getPart(item)
        if p then
            for _,c in ipairs(item:GetChildren()) do if c:IsA("BasePart") then c.CanCollide=false c.Anchored=false end end
            local bg,bp=attachPhysics(p)
            table.insert(toys,{BG=bg,BP=bp,model=item,prog=math.min(0.99,(i-1)/(#items-1)),idx=i})
        end
    end
end
local tornadoUpdate=function(hrp,t)
    local base=hrp.Position+Vector3.new(0,t.h,0)
    for _,v in ipairs(toys) do
        if v.BP then
            local rad=math.rad(v.prog*3*360+t*t.s*180+v.idx)
            v.BP.Position=Vector3.new(base.X+t.r*(1-v.prog*0.5)*math.cos(rad),base.Y+v.prog*8,base.Z+t.r*(1-v.prog*0.5)*math.sin(rad))
        end
    end
end

-- 観覧車
local ferrisInit=function(items)
    for i,item in ipairs(items) do
        local p=getPart(item)
        if p then
            for _,c in ipairs(item:GetChildren()) do if c:IsA("BasePart") then c.CanCollide=false c.Anchored=false end end
            local bg,bp=attachPhysics(p)
            table.insert(toys,{BG=bg,BP=bp,model=item,ang=(i-1)*(360/#items)})
        end
    end
end
local ferrisUpdate=function(hrp,t)
    local center=hrp.Position+Vector3.new(0,f.h,0)
    for _,v in ipairs(toys) do
        if v.BP then
            local rad=math.rad(v.ang+t*f.s*360)
            v.BP.Position=Vector3.new(center.X+f.r*math.cos(rad),center.Y+f.r*math.sin(rad),center.Z)
        end
    end
end

-- スピン
local spinInit=function(items)
    for i,item in ipairs(items) do
        local p=getPart(item)
        if p then
            for _,c in ipairs(item:GetChildren()) do if c:IsA("BasePart") then c.CanCollide=false c.Anchored=false end end
            local bg,bp=attachPhysics(p)
            table.insert(toys,{BG=bg,BP=bp,model=item,ang=(i-1)*(360/#items)})
        end
    end
end
local spinUpdate=function(hrp,t)
    local center=hrp.Position+Vector3.new(0,sp.h,0)
    for _,v in ipairs(toys) do
        if v.BP then
            local rad=math.rad(v.ang+t*sp.s*360)
            v.BP.Position=Vector3.new(center.X+sp.r*math.cos(rad),center.Y+math.sin(t*2)*0.5,center.Z+sp.r*math.sin(rad))
        end
    end
end

-- ハート
local heartInit=function(items)
    for i,item in ipairs(items) do
        local p=getPart(item)
        if p then
            for _,c in ipairs(item:GetChildren()) do if c:IsA("BasePart") then c.CanCollide=false c.Anchored=false end end
            local bg,bp=attachPhysics(p)
            table.insert(toys,{BG=bg,BP=bp,model=item})
        end
    end
end
local heartUpdate=function(hrp,t)
    local base=hrp.Position+Vector3.new(0,heart.h,0)
    for i,v in ipairs(toys) do
        if v.BP then
            local tv=t*heart.s+(i-1)/(#toys)*2*math.pi
            local x=16*math.sin(tv)^3
            local y=13*math.cos(tv)-5*math.cos(2*tv)-2*math.cos(3*tv)-math.cos(4*tv)
            v.BP.Position=Vector3.new(base.X+x*heart.size/20,base.Y-y*heart.size/20+2,base.Z)
        end
    end
end

local wingMotion=makeMotion("🪶 羽",wingInit,wingUpdate)
local sphereMotion=makeMotion("🌐 球体",sphereInit,sphereUpdate)
local headMotion=makeMotion("🔄 頭上",headInit,headUpdate)
local magicMotion=makeMotion("✨ 魔法陣",magicInit,magicUpdate)
local tornadoMotion=makeMotion("🌪️ 竜巻",tornadoInit,tornadoUpdate)
local ferrisMotion=makeMotion("🎡 観覧車",ferrisInit,ferrisUpdate)
local spinMotion=makeMotion("🔄 スピン",spinInit,spinUpdate)
local heartMotion=makeMotion("❤️ ハート",heartInit,heartUpdate)

local noclipConn=nil
local function startNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipActive=true
    noclipConn=RS.RenderStepped:Connect(function()
        if noclipActive and LP.Character then
            for _,v in ipairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide=false end
            end
        end
    end)
    O:MakeNotification({Name="IceHub",Content="Noclip ON",Time=1})
end
local function stopNoclip()
    noclipActive=false
    if noclipConn then noclipConn:Disconnect() noclipConn=nil end
    if LP.Character then
        for _,v in ipairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=true end
        end
    end
    O:MakeNotification({Name="IceHub",Content="Noclip OFF",Time=1})
end

local function startESP()
    if espActive then return end
    espActive=true
    for _,v in pairs(espObjs) do pcall(function() if v then for _,obj in pairs(v) do obj:Destroy() end end end) end
    espObjs={}
    for _,pl in ipairs(P:GetPlayers()) do
        if pl~=LP and pl.Character then
            local hrp=pl.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local box=Instance.new("BoxHandleAdornment")
                box.Size=Vector3.new(3,5,2) box.Adornee=hrp box.Color3=Color3.fromRGB(255,0,0) box.Transparency=0.5 box.AlwaysOnTop=true box.Parent=hrp
                local tag=Instance.new("BillboardGui")
                tag.Size=UDim2.new(0,200,0,30) tag.Adornee=hrp tag.StudsOffset=Vector3.new(0,2.5,0) tag.Parent=hrp
                local lbl=Instance.new("TextLabel")
                lbl.Size=UDim2.new(1,0,1,0) lbl.Text=pl.Name lbl.TextColor3=Color3.new(1,1,1) lbl.BackgroundColor3=Color3.fromRGB(0,0,0) lbl.BackgroundTransparency=0.3 lbl.TextScaled=true lbl.Parent=tag
                espObjs[pl]={box,tag}
            end
        end
    end
    O:MakeNotification({Name="IceHub",Content="ESP ON",Time=1})
end
local function stopESP()
    espActive=false
    for _,v in pairs(espObjs) do pcall(function() if v then for _,obj in pairs(v) do obj:Destroy() end end end) end
    espObjs={}
    O:MakeNotification({Name="IceHub",Content="ESP OFF",Time=1})
end

local teleTarget=nil
local function teleportTo(pl)
    if pl and pl.Character and LP.Character then
        LP.Character.HumanoidRootPart.CFrame=pl.Character.HumanoidRootPart.CFrame+Vector3.new(0,2,0)
    end
end

local function getPlayers()
    local pl={}
    for _,v in ipairs(P:GetPlayers()) do if v~=LP then table.insert(pl,v.Name) end end
    return pl
end

UIS.JumpRequest:Connect(function()
    if infJump and LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local function setSpeed(v)
    speedVal=v
    if LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed=v end
    end
end
LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    local h=c:FindFirstChild("Humanoid")
    if h then h.WalkSpeed=speedVal end
end)

local tabs={}
for i=1,12 do
    tabs[i]=W:MakeTab({Name=i==1 and"🪶 羽"or i==2 and"🌐 球体"or i==3 and"🔄 頭上"or i==4 and"✨ 魔法陣"or i==5 and"🌪️ 竜巻"or i==6 and"🎡 観覧車"or i==7 and"🔄 スピン"or i==8 and"❤️ ハート"or i==9 and"💀 戦闘"or i==10 and"⚙️ 設定"or i==11 and"👁️ ESP"or"🎯 テレポ"})
end

local setTab=tabs[10]
setTab:AddDropdown({Name="📦 対象アイテム",Options=itemList,Callback=function(v) selectedItem=v end})
setTab:AddToggle({Name="🎯 ターゲット",Default=false,Callback=function(v) attachTarget=v end})
local function refreshTarget()
    local pl=getPlayers()
    if #pl>0 then
        setTab:AddDropdown({Name="👤 ターゲット選択",Options=pl,Callback=function(v) targetPlayer=P:FindFirstChild(v) end})
    end
end
refreshTarget()
P.PlayerAdded:Connect(refreshTarget)
P.PlayerRemoving:Connect(refreshTarget)

tabs[1]:AddSlider({Name="間隔",Min=1,Max=15,Default=4,Callback=function(v) w.sp=v end})
tabs[1]:AddSlider({Name="幅",Min=0.5,Max=3.5,Default=1,Callback=function(v) w.wd=v end})
tabs[1]:AddSlider({Name="高さ",Min=0,Max=10,Default=2,Callback=function(v) w.h=v end})
tabs[1]:AddSlider({Name="奥行き",Min=1,Max=20,Default=3,Callback=function(v) w.b=v end})
tabs[1]:AddSlider({Name="傾き",Min=0,Max=90,Default=45,Callback=function(v) w.t=v end})
tabs[1]:AddSlider({Name="動き幅",Min=0,Max=5,Default=1,Callback=function(v) w.amp=v end})
tabs[1]:AddSlider({Name="速さ",Min=0.5,Max=8,Default=2,Callback=function(v) w.s=v end})
tabs[1]:AddButton({Name="開始",Callback=wingMotion})
tabs[1]:AddButton({Name="停止",Callback=stop})

tabs[2]:AddSlider({Name="半径",Min=2,Max=20,Default=5,Callback=function(v) s.r=v end})
tabs[2]:AddSlider({Name="速度",Min=0.5,Max=5,Default=1,Precision=2,Callback=function(v) s.s=v end})
tabs[2]:AddSlider({Name="高さ",Min=-5,Max=15,Default=0,Callback=function(v) s.h=v end})
tabs[2]:AddButton({Name="開始",Callback=sphereMotion})
tabs[2]:AddButton({Name="停止",Callback=stop})

tabs[3]:AddSlider({Name="半径",Min=1,Max=15,Default=3,Callback=function(v) he.r=v end})
tabs[3]:AddSlider({Name="速度",Min=0.5,Max=10,Default=2,Precision=2,Callback=function(v) he.s=v end})
tabs[3]:AddSlider({Name="高さ",Min=0,Max=15,Default=3,Callback=function(v) he.h=v end})
tabs[3]:AddButton({Name="開始",Callback=headMotion})
tabs[3]:AddButton({Name="停止",Callback=stop})

tabs[4]:AddSlider({Name="半径",Min=2,Max=15,Default=8,Callback=function(v) m.r=v end})
tabs[4]:AddSlider({Name="速度",Min=0.5,Max=5,Default=1,Precision=2,Callback=function(v) m.s=v end})
tabs[4]:AddSlider({Name="高さ",Min=-5,Max=15,Default=0,Callback=function(v) m.h=v end})
tabs[4]:AddButton({Name="開始",Callback=magicMotion})
tabs[4]:AddButton({Name="停止",Callback=stop})

tabs[5]:AddSlider({Name="半径",Min=1,Max=10,Default=5,Callback=function(v) t.r=v end})
tabs[5]:AddSlider({Name="速度",Min=0.5,Max=5,Default=2,Precision=2,Callback=function(v) t.s=v end})
tabs[5]:AddSlider({Name="高さ",Min=-5,Max=15,Default=2,Callback=function(v) t.h=v end})
tabs[5]:AddButton({Name="開始",Callback=tornadoMotion})
tabs[5]:AddButton({Name="停止",Callback=stop})

tabs[6]:AddSlider({Name="半径",Min=3,Max=30,Default=8,Callback=function(v) f.r=v end})
tabs[6]:AddSlider({Name="速度",Min=0.05,Max=5,Default=1,Precision=2,Callback=function(v) f.s=v end})
tabs[6]:AddSlider({Name="高さ",Min=-5,Max=40,Default=3,Callback=function(v) f.h=v end})
tabs[6]:AddButton({Name="開始",Callback=ferrisMotion})
tabs[6]:AddButton({Name="停止",Callback=stop})

tabs[7]:AddSlider({Name="半径",Min=1,Max=15,Default=5,Callback=function(v) sp.r=v end})
tabs[7]:AddSlider({Name="速度",Min=0.2,Max=8,Default=1,Precision=2,Callback=function(v) sp.s=v end})
tabs[7]:AddSlider({Name="高さ",Min=0,Max=10,Default=1,Callback=function(v) sp.h=v end})
tabs[7]:AddButton({Name="開始",Callback=spinMotion})
tabs[7]:AddButton({Name="停止",Callback=stop})

tabs[8]:AddSlider({Name="サイズ",Min=1,Max=15,Default=5,Callback=function(v) heart.size=v end})
tabs[8]:AddSlider({Name="速度",Min=0.2,Max=8,Default=1,Precision=2,Callback=function(v) heart.s=v end})
tabs[8]:AddSlider({Name="高さ",Min=-5,Max=15,Default=2,Callback=function(v) heart.h=v end})
tabs[8]:AddButton({Name="開始",Callback=heartMotion})
tabs[8]:AddButton({Name="停止",Callback=stop})

tabs[9]:AddButton({Name="🔫 全員キル",Callback=function()
    for _,v in ipairs(P:GetPlayers()) do
        if v~=LP and v.Character then
            local h=v.Character:FindFirstChild("Humanoid")
            if h then h.Health=0 end
        end
    end
end})

tabs[10]:AddSlider({Name="🏃 歩行速度",Min=10,Max=200,Default=16,Callback=setSpeed})
tabs[10]:AddButton({Name="🚪 Noclip開始",Callback=startNoclip})
tabs[10]:AddButton({Name="🚪 Noclip停止",Callback=stopNoclip})
tabs[10]:AddToggle({Name="🦘 無限ジャンプ",Default=false,Callback=function(v) infJump=v end})

tabs[11]:AddButton({Name="👁️ ESP開始",Callback=startESP})
tabs[11]:AddButton({Name="👁️ ESP停止",Callback=stopESP})

local function refreshTele()
    local pl=getPlayers()
    if #pl>0 then
        tabs[12]:AddDropdown({Name="プレイヤー",Options=pl,Callback=function(v) teleTarget=P:FindFirstChild(v) end})
        tabs[12]:AddButton({Name="テレポート",Callback=function() if teleTarget then teleportTo(teleTarget) end end})
    end
end
refreshTele()
P.PlayerAdded:Connect(refreshTele)
P.PlayerRemoving:Connect(refreshTele)

O:Init()
print("IceHub起動 | 中央飛び防止済み")