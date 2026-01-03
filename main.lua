--[[
    Spaghetti Mafia Hub v1 (ULTRA FINAL FIXED)
    Branding: "注讜诇诐 讛讻讬祝"
    Updates: Smart Crystal Skip (2s), Drag vs Click Fix, Credits Updated.
]]

--// 谞讬拽讜讬 住拽专讬驻讟讬诐 讬砖谞讬诐
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then
    CoreGui.SpaghettiHub_Rel:Destroy()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// 讛讙讚专讜转
local Settings = {
    Key = "Spaghetti2024",
    Theme = {
        Gold = Color3.fromRGB(255, 215, 0),
        Dark = Color3.fromRGB(10, 10, 10),
        Box = Color3.fromRGB(18, 18, 18),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Keys = {
        Menu = Enum.KeyCode.RightControl,
        Fly = Enum.KeyCode.E,
        Speed = Enum.KeyCode.F
    },
    Fly = { Enabled = false, Speed = 50 },
    Speed = { Enabled = false, Value = 16 },
    Farming = false,
    FarmSpeed = 300,
    Scale = 1
}

local VisualToggles = {}
local FarmConnection = nil
local FarmBlacklist = {}
local LastFullScan = 0

--// 住驻专讬转 注讬爪讜讘
local Library = {}

function Library:Tween(obj, props, time, style)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

function Library:AddGlow(obj, color)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or Settings.Theme.Gold
    s.Thickness = 1
    s.Transparency = 0.6
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function Library:AddTextGlow(obj, color)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or Settings.Theme.Gold
    s.Thickness = 0.6
    s.Transparency = 0.7
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
end

function Library:Corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 6)
    return c
end

function Library:MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// 讬爪讬专转 诪诪砖拽
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpaghettiHub_Rel"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MiniPasta = Instance.new("TextButton", ScreenGui)
MiniPasta.Size = UDim2.new(0, 0, 0, 0); MiniPasta.Position = UDim2.new(0.1, 0, 0.1, 0)
MiniPasta.BackgroundColor3 = Settings.Theme.Dark; MiniPasta.Text = "馃崫"; MiniPasta.TextSize = 35; MiniPasta.Visible = false
Library:Corner(MiniPasta, 30); Library:AddGlow(MiniPasta); Library:MakeDraggable(MiniPasta)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Settings.Theme.Dark
MainFrame.Visible = false
MainFrame.ClipsDescendants = true 
Library:Corner(MainFrame, 12); Library:AddGlow(MainFrame)

local MainScale = Instance.new("UIScale", MainFrame); MainScale.Scale = 1
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1,0,0,60); TopBar.BackgroundTransparency = 1
Library:MakeDraggable(MainFrame)

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(0, 10, 0, 10)
MinBtn.BackgroundColor3 = Settings.Theme.Box; MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.TextSize = 25
Library:Corner(MinBtn, 6); Library:AddGlow(MinBtn, Color3.fromRGB(60,60,60))

MinBtn.MouseButton1Click:Connect(function() 
    Library:Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back)
    task.wait(0.3)
    MainFrame.Visible = false
    MiniPasta.Visible = true
    Library:Tween(MiniPasta, {Size = UDim2.new(0, 60, 0, 60)}, 0.4, Enum.EasingStyle.Elastic)
end)

local PastaDragStart = Vector2.zero
MiniPasta.MouseButton1Down:Connect(function() PastaDragStart = UIS:GetMouseLocation() end)
MiniPasta.MouseButton1Up:Connect(function()
    local delta = (UIS:GetMouseLocation() - PastaDragStart).Magnitude
    if delta < 5 then
        Library:Tween(MiniPasta, {Size = UDim2.new(0,0,0,0)}, 0.2)
        task.wait(0.2)
        MiniPasta.Visible = false
        MainFrame.Visible = true
        Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.4, Enum.EasingStyle.Back)
    end
end)

local MainTitle = Instance.new("TextLabel", TopBar)
MainTitle.Size = UDim2.new(0,300,0,30); MainTitle.Position = UDim2.new(0,50,0,10); MainTitle.BackgroundTransparency = 1
MainTitle.Text = "SPAGHETTI <font color='#FFD700'>MAFIA</font> HUB v1"; MainTitle.RichText = true
MainTitle.Font = Enum.Font.GothamBlack; MainTitle.TextSize = 20; MainTitle.TextColor3 = Color3.new(1,1,1); MainTitle.TextXAlignment = Enum.TextXAlignment.Left
Library:AddTextGlow(MainTitle)

local MainSub = Instance.new("TextLabel", TopBar)
MainSub.Size = UDim2.new(0,300,0,20); MainSub.Position = UDim2.new(0,50,0,32); MainSub.BackgroundTransparency = 1
MainSub.Text = "注讜诇诐 讛讻讬祝"; MainSub.Font = Enum.Font.GothamBold; MainSub.TextSize = 13; MainSub.TextColor3 = Settings.Theme.Gold; MainSub.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, -60); Sidebar.Position = UDim2.new(0,0,0,60)
Sidebar.BackgroundColor3 = Settings.Theme.Box
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2
Library:Corner(Sidebar, 12) 

local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding = UDim.new(0,10); SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidePad = Instance.new("UIPadding", Sidebar); SidePad.PaddingTop = UDim.new(0,15)

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -170, 1, -70); Container.Position = UDim2.new(0, 170, 0, 65); Container.BackgroundTransparency = 1

local currentTab = nil
local function CreateTab(name, heb)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9,0,0,40); btn.BackgroundColor3 = Settings.Theme.Dark
    btn.Text = name .. "\n<font size='11' color='#AAAAAA'>"..heb.."</font>"
    btn.RichText = true; btn.TextColor3 = Color3.fromRGB(150,150,150); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    btn.ZIndex = 3
    Library:Corner(btn, 6)
    
    local page = Instance.new("Frame", Container); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false
    
    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then Library:Tween(v, {BackgroundColor3 = Settings.Theme.Dark, TextColor3 = Color3.fromRGB(150,150,150)}) end end
        for _,v in pairs(Container:GetChildren()) do v.Visible = false end
        Library:Tween(btn, {BackgroundColor3 = Settings.Theme.Gold, TextColor3 = Color3.new(0,0,0)})
        page.Visible = true
    end)
    
    if not currentTab then currentTab = btn; Library:Tween(btn, {BackgroundColor3 = Settings.Theme.Gold, TextColor3 = Color3.new(0,0,0)}); page.Visible = true end
    return page
end

local Tab_Farm = CreateTab("Farming", "讞讜讜讛")
local Tab_Main = CreateTab("Main", "专讗砖讬")
local Tab_Sett = CreateTab("Settings", "讛讙讚专讜转")
local Tab_Cred = CreateTab("Credits", "拽专讚讬讟讬诐")

local function AddLayout(p) 
    local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0,12); l.HorizontalAlignment = Enum.HorizontalAlignment.Center 
    local pad = Instance.new("UIPadding", p); pad.PaddingTop = UDim.new(0,10)
end
AddLayout(Tab_Farm); AddLayout(Tab_Main); AddLayout(Tab_Sett); AddLayout(Tab_Cred)

local function CreateSlider(parent, title, heb, min, max, default, callback, toggleCallback, toggleName, isDecimal)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95,0,0,75); f.BackgroundColor3 = Settings.Theme.Box
    Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.7,0,0,25); l.Position = UDim2.new(0,10,0,8)
    l.Text = title .. " <font size='12' color='#999999'>("..heb..")</font> : " .. default
    l.RichText=true; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.BackgroundTransparency=1
    local line = Instance.new("Frame", f); line.Size = UDim2.new(0.9,0,0,12); line.Position = UDim2.new(0.05,0,0.65,0); line.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(line,6)
    local fill = Instance.new("Frame", line); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Settings.Theme.Gold; Library:Corner(fill,6)
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                local r = math.clamp((i.Position.X - line.AbsolutePosition.X)/line.AbsoluteSize.X,0,1)
                fill.Size = UDim2.new(r,0,1,0)
                local v = isDecimal and (math.floor((min+((max-min)*r))*100)/100) or math.floor(min+((max-min)*r))
                l.Text = title.." <font size='12' color='#999999'>("..heb..")</font> : "..v; callback(v)
            end
        end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
    if toggleCallback then
        local t = Instance.new("TextButton", f); t.Size = UDim2.new(0,60,0,25); t.Position = UDim2.new(1,-70,0,8); t.BackgroundColor3 = Color3.fromRGB(40,40,40)
        t.Text = "OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.GothamBold; Library:Corner(t,4)
        local on = false
        local function Update(s) t.Text=s and "ON" or "OFF"; t.BackgroundColor3=s and Settings.Theme.Gold or Color3.fromRGB(40,40,40); t.TextColor3=s and Color3.new(0,0,0) or Color3.new(1,1,1); toggleCallback(s) end
        t.MouseButton1Click:Connect(function() on=not on; Update(on) end)
        if toggleName then VisualToggles[toggleName] = function(v) on=v; t.Text=on and "ON" or "OFF"; t.BackgroundColor3=on and Settings.Theme.Gold or Color3.fromRGB(40,40,40); t.TextColor3=on and Color3.new(0,0,0) or Color3.new(1,1,1) end end
    end
end

local function CreateBigToggle(parent, title, heb, callback, toggleName)
    local f = Instance.new("TextButton", parent); f.Size = UDim2.new(0.95,0,0,50); f.BackgroundColor3 = Settings.Theme.Box; f.Text=""; f.AutoButtonColor=false
    Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.8,0,1,0); l.Position = UDim2.new(0.05,0,0,0); l.Text=title.."  <font size='12' color='#999999'>"..heb.."</font>"; l.RichText=true; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=15; l.TextXAlignment=Enum.TextXAlignment.Left; l.BackgroundTransparency=1
    local icon = Instance.new("Frame", f); icon.Size = UDim2.new(0,20,0,20); icon.Position = UDim2.new(0.9,-10,0.5,-10); icon.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(icon,5)
    local on = false
    local function Update(s) on=s; if on then Library:Tween(icon,{BackgroundColor3=Settings.Theme.Gold}); Library:AddGlow(f,Settings.Theme.Gold) else Library:Tween(icon,{BackgroundColor3=Color3.fromRGB(50,50,50)}); if f:FindFirstChild("UIStroke") then f.UIStroke:Destroy() end; Library:AddGlow(f,Color3.fromRGB(40,40,40)) end end
    f.MouseButton1Click:Connect(function() on=not on; Update(on); callback(on) end)
    if toggleName then VisualToggles[toggleName] = function(v) Update(v) end end
end

local function CreateSquareBind(parent, id, title, heb, default, callback)
    local f = Instance.new("TextButton", parent); local sizeY = id==3 and 60 or 80
    f.Position = id==1 and UDim2.new(0,0,0,0) or (id==2 and UDim2.new(0.52,0,0,0) or UDim2.new(0,0,0,0))
    f.Size = UDim2.new(id==3 and 1 or 0.48,0,0,sizeY); f.BackgroundColor3 = Settings.Theme.Box; f.Text=""; f.AutoButtonColor=false
    Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1,0,0,20); t.Position = UDim2.new(0,0,id==3 and 0.1 or 0.15,0); t.Text=title; t.TextColor3=Color3.fromRGB(150,150,150); t.Font=Enum.Font.Gotham; t.TextSize=13; t.BackgroundTransparency=1
    local h = Instance.new("TextLabel", f); h.Size = UDim2.new(1,0,0,15); h.Position = UDim2.new(0,0,0.35,0); h.Text=heb; h.TextColor3=Color3.fromRGB(100,100,100); h.Font=Enum.Font.Gotham; h.TextSize=11; h.BackgroundTransparency=1
    local k = Instance.new("TextLabel", f); k.Size = UDim2.new(1,0,0,30); k.Position = UDim2.new(0,0,id==3 and 0.5 or 0.6,0); k.Text=default.Name; k.TextColor3=Settings.Theme.Gold; k.Font=Enum.Font.GothamBold; k.TextSize=20; k.BackgroundTransparency=1
    f.MouseButton1Click:Connect(function() k.Text="..."; local i=UIS.InputBegan:Wait(); if i.UserInputType==Enum.UserInputType.Keyboard then k.Text=i.KeyCode.Name; callback(i.KeyCode) end end)
    return f
end

local function GetClosestTarget()
    local drops = Workspace:FindFirstChild("StormDrops")
    if not drops then return nil end
    local closest, dist = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, v in pairs(drops:GetChildren()) do
            if v:IsA("BasePart") and not FarmBlacklist[v] then
                local mag = (hrp.Position - v.Position).Magnitude
                if mag < dist then dist = mag; closest = v end
            end
        end
    end
    return closest
end

local function UltraSafeDisable()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end
    local region = Region3.new(hrp.Position - Vector3.new(30,30,30), hrp.Position + Vector3.new(30,30,30))
    local objects = workspace:FindPartsInRegion3(region, nil, 200)
    for _, part in pairs(objects) do
        local n = part.Name:lower()
        if n:find("door") or n:find("portal") or n:find("tele") or n:find("gate") or n:find("enter") or n:find("selection") or n:find("lobby") or n:find("zone") or n:find("minigame") or n:find("warp") then
            part.CanTouch = false
            pcall(function() 
                if part:FindFirstChild("TouchInterest") then part.TouchInterest:Destroy() end 
                for _, p in pairs(part:GetDescendants()) do if p:IsA("ProximityPrompt") then p.Enabled = false end end
            end)
        end
    end
    if tick() - LastFullScan > 5 then
        LastFullScan = tick()
        task.spawn(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("door") then
                    obj.CanTouch = false
                    pcall(function() if obj:FindFirstChild("TouchInterest") then obj.TouchInterest:Destroy() end end)
                end
            end
        end)
    end
end

local function EnableNoclip(bool)
    if bool then
        if not FarmConnection then
            FarmConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum then hum.Sit = false; hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
                    UltraSafeDisable() 
                end
            end)
        end
    else
        if FarmConnection then FarmConnection:Disconnect(); FarmConnection = nil end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = true end end
            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end
        end
    end
end

local function ToggleFarm(v)
    Settings.Farming = v
    EnableNoclip(v)
    if not v then FarmBlacklist = {} end
    if v then
        task.spawn(function()
            while Settings.Farming do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local target = GetClosestTarget()
                if char and hrp and target then
                    local distance = (hrp.Position - target.Position).Magnitude
                    local info = TweenInfo.new(distance / Settings.FarmSpeed, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, info, {CFrame = target.CFrame})
                    tween:Play()
                    local start = tick()
                    repeat task.wait() 
                        if not target.Parent or not Settings.Farming then tween:Cancel(); break end
                        -- 转讬拽讜谉: 讚讬诇讜讙 注诇 拽专讬住讟诇讬诐 讘讗讙讬诐 讗讞专讬 2 砖谞讬讜转
                        if (tick() - start) > 2 then 
                            tween:Cancel()
                            FarmBlacklist[target] = true
                            break 
                        end
                    until (tick() - start) > (distance / Settings.FarmSpeed) + 0.1
                else
                    task.wait(0.5)
                end
                task.wait()
            end
        end)
    end
end

local function ToggleFly(v)
    Settings.Fly.Enabled = v
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChild("Humanoid")
    if v then
        local bv = Instance.new("BodyVelocity",hrp); bv.MaxForce=Vector3.new(1e9,1e9,1e9); bv.Name="F_V"
        local bg = Instance.new("BodyGyro",hrp); bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bg.P=9e4; bg.Name="F_G"
        hum.PlatformStand=true
        task.spawn(function()
            while Settings.Fly.Enabled and char.Parent do
                local cam = workspace.CurrentCamera; local d = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
                bv.Velocity = d * Settings.Fly.Speed; bg.CFrame = cam.CFrame; RunService.Heartbeat:Wait()
            end
            if hrp:FindFirstChild("F_V") then hrp.F_V:Destroy() end; if hrp:FindFirstChild("F_G") then hrp.F_G:Destroy() end; hum.PlatformStand=false
        end)
    else
        if hrp:FindFirstChild("F_V") then hrp.F_V:Destroy() end; if hrp:FindFirstChild("F_G") then hrp.F_G:Destroy() end; hum.PlatformStand=false
    end
end

--// Setup Tabs & Content
CreateBigToggle(Tab_Farm, "Auto Farm Crystals", "讞讜讜讛 讗讜讟讜诪讟讬转 诇拽专讬住讟诇讬诐 (Anti-Stuck)", function(v) ToggleFarm(v) end, "Farm")
CreateSlider(Tab_Main, "Walk Speed", "诪讛讬专讜转 讛诇讬讻讛", 16, 250, 16, function(v) Settings.Speed.Value = v end, function(t) Settings.Speed.Enabled = t end, "Speed")
CreateSlider(Tab_Main, "Fly Speed", "诪讛讬专讜转 转注讜驻讛", 20, 300, 50, function(v) Settings.Fly.Speed = v end, function(t) ToggleFly(t) end, "Fly")
local BindCont = Instance.new("Frame", Tab_Main); BindCont.Size = UDim2.new(0.95,0,0,80); BindCont.BackgroundTransparency = 1
CreateSquareBind(BindCont, 1, "FLY", "转注讜驻讛", Settings.Keys.Fly, function(k) Settings.Keys.Fly = k end)
CreateSquareBind(BindCont, 2, "SPEED", "诪讛讬专讜转", Settings.Keys.Speed, function(k) Settings.Keys.Speed = k end)
CreateSlider(Tab_Sett, "FOV", "砖讚讛 专讗讬讬讛", 70, 120, 70, function(v) Camera.FieldOfView = v end)
CreateSlider(Tab_Sett, "GUI Scale", "讙讜讚诇 诪诪砖拽", 0.5, 1.5, 1, function(v) MainScale.Scale = v end, nil, nil, true)
local MenuBindCont = Instance.new("Frame", Tab_Sett); MenuBindCont.Size = UDim2.new(0.95,0,0,70); MenuBindCont.BackgroundTransparency = 1
CreateSquareBind(MenuBindCont, 3, "MENU KEY", "诪拽砖 转驻专讬讟", Settings.Keys.Menu, function(k) Settings.Keys.Menu = k end)

local function AddCr(n, id)
    local f = Instance.new("Frame", Tab_Cred); f.Size = UDim2.new(0.95,0,0,100); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 12); Library:AddGlow(f)
    local i = Instance.new("ImageLabel", f); i.Size = UDim2.new(0,80,0,80); i.Position = UDim2.new(0,10,0.5,-40); i.Image = "rbxthumb://type=AvatarHeadShot&id="..id.."&w=150&h=150"; Library:Corner(i, 40)
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(0,350,0,30); t.Position = UDim2.new(0,100,0,20); t.Text = n .. " <font color='#AAAAAA'>(讬讜爪专讬诐)</font>"; t.RichText=true; t.TextColor3 = Settings.Theme.Gold; t.Font=Enum.Font.GothamBlack; t.TextSize=22; t.TextXAlignment="Left"; t.BackgroundTransparency=1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0,140,0,30); b.Position = UDim2.new(0,100,0,55); b.BackgroundColor3 = Color3.fromRGB(88,101,242); b.Text="Copy Discord"; b.TextColor3=Color3.new(1,1,1); Library:Corner(b,6); b.TextSize=13
    b.MouseButton1Click:Connect(function() setclipboard(n); b.Text="Copied!"; task.wait(1); b.Text="Copy Discord" end)
end
AddCr("nx3ho", 1323665023)
AddCr("8adshot3", 3370067928)

--// Key System
local KeyFrame = Instance.new("Frame", ScreenGui)
KeyFrame.Size = UDim2.new(0, 400, 0, 260)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -130)
KeyFrame.BackgroundColor3 = Settings.Theme.Dark
Library:Corner(KeyFrame, 10); Library:AddGlow(KeyFrame)
Library:MakeDraggable(KeyFrame)

local KeyTitle = Instance.new("TextLabel", KeyFrame)
KeyTitle.Size = UDim2.new(1,0,0,40); KeyTitle.Position = UDim2.new(0,0,0,15)
KeyTitle.BackgroundTransparency = 1; KeyTitle.Text = "SPAGHETTI MAFIA HUB <font color='#FFD700'>v1</font>"
KeyTitle.RichText = true; KeyTitle.Font = Enum.Font.GothamBlack; KeyTitle.TextSize = 24; KeyTitle.TextColor3 = Color3.new(1,1,1)
Library:AddTextGlow(KeyTitle)

local KeySub = Instance.new("TextLabel", KeyFrame)
KeySub.Size = UDim2.new(1,0,0,20); KeySub.Position = UDim2.new(0,0,0,45)
KeySub.BackgroundTransparency = 1; KeySub.Text = "注讜诇诐 讛讻讬祝"
KeySub.Font = Enum.Font.GothamBold; KeySub.TextSize = 16; KeySub.TextColor3 = Settings.Theme.Gold

local KeyInput = Instance.new("TextBox", KeyFrame)
KeyInput.Size = UDim2.new(0.7,0,0,45); KeyInput.Position = UDim2.new(0.15,0,0.4,0)
KeyInput.BackgroundColor3 = Settings.Theme.Box; KeyInput.TextColor3 = Color3.new(1,1,1)
KeyInput.PlaceholderText = "Enter Key... / 讛讻谞住 诪驻转讞"; KeyInput.Text = ""
KeyInput.Font = Enum.Font.Gotham; KeyInput.TextSize = 14
Library:Corner(KeyInput, 6); Library:AddGlow(KeyInput, Color3.fromRGB(60,60,60))

local KeyBtn = Instance.new("TextButton", KeyFrame)
KeyBtn.Size = UDim2.new(0.4,0,0,40); KeyBtn.Position = UDim2.new(0.3,0,0.75,0)
KeyBtn.BackgroundColor3 = Settings.Theme.Gold; KeyBtn.Text = "LOGIN / 讻谞讬住讛"; KeyBtn.Font = Enum.Font.GothamBold; KeyBtn.TextSize = 16
Library:Corner(KeyBtn, 6)

KeyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == Settings.Key then
        Library:Tween(KeyFrame, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}, 0.4, Enum.EasingStyle.Back)
        task.wait(0.3)
        KeyFrame.Visible = false
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0,0,0,0)
        Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.6, Enum.EasingStyle.Elastic)
    end
end)

--// Binds
UIS.InputBegan:Connect(function(i,g)
    if not g then
        if i.KeyCode == Settings.Keys.Menu then 
            if MainFrame.Visible then
                Library:Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back)
                task.wait(0.3)
                MainFrame.Visible = false
            else
                MainFrame.Visible = true
                MainFrame.Size = UDim2.new(0,0,0,0)
                Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.5, Enum.EasingStyle.Elastic)
            end
        end
        if i.KeyCode == Settings.Keys.Fly then 
            Settings.Fly.Enabled = not Settings.Fly.Enabled
            ToggleFly(Settings.Fly.Enabled)
            if VisualToggles["Fly"] then VisualToggles["Fly"](Settings.Fly.Enabled) end
        end
        if i.KeyCode == Settings.Keys.Speed then 
            Settings.Speed.Enabled = not Settings.Speed.Enabled
            if VisualToggles["Speed"] then VisualToggles["Speed"](Settings.Speed.Enabled) end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Speed.Enabled and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = Settings.Speed.Value end
    end
end)

print("Spaghetti Mafia Hub v1 Final Optimized Loaded")
