local L=loadstring(game:HttpGet("https://raw.githubusercontent.com/oxireun/UiLibrary/refs/heads/main/2049.lua"))()
local W=L:NewWindow("Day 5 puzzle")
W:SetFooter("yt: oxireun",128337196312757,1)
local S=W:NewSection("Main")
local function tp(t)local c=game.Players.LocalPlayer.Character if c then local p=Instance.new("Part")p.Size=Vector3.new(6,1,6)p.Position=t-Vector3.new(0,3.5,0)p.Anchored=true p.Transparency=0 p.Parent=workspace task.delay(3,function()if p then p:Destroy()end end)c:PivotTo(CFrame.new(t))end end
S:CreateButton("1 floor",function()pcall(function()tp(Vector3.new(-1519.71,5.4,-969.46))end)end)
S:CreateButton("Floor 5",function()tp(Vector3.new(263.04,3.54,9998.55))end)
S:CreateButton("Auto puzzle",function()
local function M()
local P=game:GetService("Players")local R=game:GetService("ReplicatedStorage")local Wk=game:GetService("Workspace")
local pl=P.LocalPlayer
local MS=300000 local YE=150 local VR=10 local CD=0.2
local function hmp(n)return type(n)=="string"and string.sub(n,1,9)=="GR_Mimic_"end
local function fz()
local cs={}
local ch=pl.Character local rt=ch and ch:FindFirstChild("HumanoidRootPart")local pp=rt and rt.Position
for _,o in ipairs(Wk:GetDescendants())do
if hmp(o.Name)then
local pz=o:FindFirstChild("LightPuzzle")
if pz and pz:IsA("Model")then
local s=pz:FindFirstChild("Source")local sk=pz:FindFirstChild("Skull")local m=pz:FindFirstChild("Mirrors")local b=pz:FindFirstChild("Blockers")
if s and sk and m and b then
local pc=0
for _,mr in ipairs(m:GetChildren())do if mr:IsA("BasePart")and mr:FindFirstChildWhichIsA("ProximityPrompt",true)then pc=pc+1 end end
local d=math.huge
if pp and s:IsA("BasePart")then d=(pp-s.Position).Magnitude end
table.insert(cs,{Puzzle=pz,PromptCount=pc,Distance=d,Container=o})
end end end end
table.sort(cs,function(a,b)if a.PromptCount~=b.PromptCount then return a.PromptCount>b.PromptCount end return a.Distance<b.Distance end)
if cs[1]then return cs[1].Puzzle end return nil end
local Pz=fz()
if not Pz then return end
local function lm(n)
if type(_G)=="table"and type(_G.require)=="function"then
local ok,r=pcall(function()return _G.require(n)end)
if ok and r then return r end end
local f=R:FindFirstChild("ClientModules")f=f and f:FindFirstChild("ReleasedPuzzles")f=f and f:FindFirstChild("LightMirror")
local ms=f and f:FindFirstChild(n)
if ms and ms:IsA("ModuleScript")then
local ok,r=pcall(require,ms)
if ok and r then return r end end
return nil end
local function fr(n)
local rs=R:FindFirstChild("Remotes")local r=rs and rs:FindFirstChild(n)
if r and r:IsA("RemoteFunction")then return r end
for _,o in ipairs(R:GetDescendants())do if o.Name==n and o:IsA("RemoteFunction")then return o end end
return nil end
local LB=lm("LightBeam")local SR=fr("LightMirrorState")local SoR=fr("LightMirrorSolve")
if not LB or type(LB.layout)~="function"or type(LB.yawFor)~="function"or type(LB.trace)~="function"then return end
if not SR then return end
local function gs()
local ok,r=pcall(function()return SR:InvokeServer()end)
if ok and type(r)=="table"then return r end return nil end
local IS=gs()
if not IS or type(IS.Turns)~="table"then return end
if IS.Solved then return end
local lok,Ly=pcall(function()return LB.layout(Pz)end)
if not lok or type(Ly)~="table"or type(Ly.Mirrors)~="table"or not Ly.Blockers then return end
local N=#Ly.Mirrors
if N==0 or #IS.Turns~=N then return end
local Nm={}local CT={}local Pr={}local IN={}
for i,inf in ipairs(Ly.Mirrors)do Nm[i]=inf.Base.Name IN[Nm[i]]=i CT[i]=(tonumber(IS.Turns[i])or 0)%8 end
for at=1,24 do
local af=true
for i,inf in ipairs(Ly.Mirrors)do
local pr=inf.Base:FindFirstChildWhichIsA("ProximityPrompt",true)
Pr[i]=pr if not pr then af=false end end
if af then break end
task.wait(0.25)end
for i=1,N do if not Pr[i]then return end end
local Lk={}local Pa={}local ID={}
for i=1,N do Lk[i]={}Pa[i]={}ID[i]=0 end
for i,inf in ipairs(Ly.Mirrors)do
for _,ch in ipairs(inf.Links or{})do
if type(ch)=="number"and ch>=1 and ch<=N and ch~=i and not Lk[i][ch]then
Lk[i][ch]=true table.insert(Pa[ch],i)ID[ch]=ID[ch]+1 end end end
local Q={}local Or={}
for i=1,N do if ID[i]==0 then table.insert(Q,i)end end
local qh=1
while qh<=#Q do local i=Q[qh]qh=qh+1 table.insert(Or,i)
for ch in pairs(Lk[i])do ID[ch]=ID[ch]-1 if ID[ch]==0 then table.insert(Q,ch)end end end
if #Or~=N then return end
local RP=RaycastParams.new()RP.FilterType=Enum.RaycastFilterType.Include RP.FilterDescendantsInstances={Ly.Blockers}
local function ta(a)
local ys={}
for i,inf in ipairs(Ly.Mirrors)do
if a[i]~=nil then
local ok,y=pcall(function()return LB.yawFor(inf,a[i])end)
if not ok or type(y)~="number"then return nil end
ys[i]=y end end
local ok,r=pcall(function()return LB.trace(Ly,ys,RP)end)
if not ok or type(r)~="table"then return nil end
return r end
local function tf(cfg)local a={}for i=1,N do a[i]=cfg[i]end return ta(a)end
local function ck(a)local ps={}for i=1,N do ps[i]=a[i]==nil and"-"or tostring(a[i])end return table.concat(ps,",")end
local SN=0 local SA=false local V={}local Sol local ST
local function srch(a,dp)
if SA then return false end
SN=SN+1
if SN>MS then SA=true return false end
if SN%YE==0 then task.wait()end
local k=ck(a)
if V[k]then return false end
V[k]=true
local tr=ta(a)
if not tr then return false end
if tr.Complete then
local f={}
for i=1,N do if a[i]~=nil then f[i]=a[i]else f[i]=CT[i]end end
local ft=tf(f)
if ft and ft.Complete then Sol=f ST=ft return true end
local bi
if ft then
local st=ft.Stopped local un=ft.Unknown
if type(st)=="number"and st>=1 and st<=N and a[st]==nil then bi=st
elseif type(un)=="number"and un>=1 and un<=N and a[un]==nil then bi=un end end
if bi and dp<N then
for of=0,7 do
a[bi]=(CT[bi]+of)%8
if srch(a,dp+1)then return true end
a[bi]=nil end end
return false end
local un=tr.Unknown
if type(un)~="number"or un<1 or un>N or un%1~=0 or a[un]~=nil or dp>=N then return false end
for of=0,7 do
if SA then return false end
a[un]=(CT[un]+of)%8
if srch(a,dp+1)then return true end
a[un]=nil end
return false end
if not srch({},0)or not Sol then return end
local Cl=table.create(N,0)
for _,i in ipairs(Or)do
local inc=0
for _,pa in ipairs(Pa[i])do inc=inc+Cl[pa]end
Cl[i]=(Sol[i]-CT[i]-inc)%8 end
local PT=table.create(N,0)
for i=1,N do
local inc=0
for _,pa in ipairs(Pa[i])do inc=inc+Cl[pa]end
PT[i]=(CT[i]+Cl[i]+inc)%8 end
local ptr=tf(PT)
if not ptr or not ptr.Complete then return end
local fs=gs()
if not fs or type(fs.Turns)~="table"then return end
for i=1,N do if (tonumber(fs.Turns[i])or 0)%8~=CT[i]then return end end
local function ttm(idx)
local ch=pl.Character if not ch then return false end
local inf=Ly.Mirrors[idx]local bs=inf.Base local pr=Pr[idx]
if not bs or not pr or not pr.Parent then return false end
local anc=bs.Position
if pr.Parent:IsA("Attachment")then anc=pr.Parent.WorldPosition end
local dr=Ly.Direction local sd=Vector3.new(-dr.Z,0,dr.X)
if sd.Magnitude>0.001 then sd=sd.Unit else sd=Vector3.new(0,0,1)end
local tp=anc+Vector3.new(0,2,0)+sd*3.5
local pt=Instance.new("Part")pt.Size=Vector3.new(6,1,6)pt.Position=tp-Vector3.new(0,3.5,0)pt.Anchored=true pt.Transparency=0 pt.Parent=Wk
task.delay(3,function()if pt then pt:Destroy()end end)
local ok=pcall(function()ch:PivotTo(CFrame.new(tp))end)
if ok then task.wait(0.25)end
return ok end
local function fire(pr)
if not pr or not pr.Parent or not pr.Enabled then return false end
if type(fireproximityprompt)=="function"then
local ok=pcall(function()fireproximityprompt(pr)end)
if ok then return true end end
return pcall(function()pr:InputHoldBegin()task.wait(math.max(pr.HoldDuration,0.1))pr:InputHoldEnd()end)end
local ET=table.clone(CT)
local function vs()
for at=1,VR do
local st=gs()
if st and st.Solved then return true,true end
if st and type(st.Turns)=="table"then
local mt=true
for i=1,N do if (tonumber(st.Turns[i])or 0)%8~=ET[i]then mt=false break end end
if mt then return true,false end end
task.wait(0.2)end
return false,false end
for _,i in ipairs(Or)do
local amt=Cl[i]
if amt>0 then
if not ttm(i)then return end
for cl=1,amt do
if not fire(Pr[i])then return end
ET[i]=(ET[i]+1)%8
for ch in pairs(Lk[i])do ET[ch]=(ET[ch]+1)%8 end
local vf,sv=vs()
if not vf then return end
if sv then return end
task.wait(CD)end end end
local fst=gs()
if not fst or type(fst.Turns)~="table"then return end
if fst.Solved then return end
local AT=table.create(N,0)
for i=1,N do
AT[i]=(tonumber(fst.Turns[i])or 0)%8
if AT[i]~=Sol[i]then return end end
local ftr=tf(AT)
if not ftr or not ftr.Complete then return end
task.wait(2.2)
fst=gs()
if fst and fst.Solved then return end
if SoR then pcall(function()return SoR:InvokeServer()end)end
for at=1,8 do
task.wait(0.4)
fst=gs()
if fst and fst.Solved then return end end
end
xpcall(M,function(m)return debug.traceback(tostring(m),2)end)
end)
local CS=W:NewSection("Credits")
CS:CreateButton("Copy YouTube",function()setclipboard("https://youtube.com/@oxireun2?si=Te2WhImkK3B31iX_")L:SendNotification("Copied!","YouTube link copied to clipboard!",2,108320733835485,1,"red")end)
CS:CreateButton("Copy Discord",function()setclipboard("https://discord.gg/qgV6v9WcE9")L:SendNotification("Copied!","Discord invite copied to clipboard!",2,119731774091515,1,"blue")end)
