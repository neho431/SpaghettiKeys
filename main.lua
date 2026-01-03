--[[
    Spaghetti Mafia Hub v1.5 (FIXED DATA & LAYOUT)
    Updated: "Strong" Data Tracking (Current - Initial)
    Layout: Compact (No Scrolling needed)
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// 1. מערכת Whitelist (בדיקה מול GitHub)
local WHITELIST_URL = "https://raw.githubusercontent.com/neho431/SpaghettiKeys/main/whitelist.txt"

local function CheckWhitelist()
    local success, content = pcall(function()
        return game:HttpGet(WHITELIST_URL .. "?t=" .. tick())
    end)
    
    if success and content then
        if string.find(content, LocalPlayer.Name) then
            print("[SYSTEM] Whitelist Confirmed. Welcome, " .. LocalPlayer.Name)
            return true
        else
            LocalPlayer:Kick("Spaghetti Mafia Hub: Not Whitelisted!")
            return false
        end
    else
        LocalPlayer:Kick("Spaghetti Mafia Hub: Failed to verify Whitelist (Connection Error)")
        return false
    end
end

if not CheckWhitelist() then return end

--// 2. ניקוי סקריפטים ישנים
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then
    CoreGui.SpaghettiHub_Rel:Destroy()
end

--// 3. הגדרות מערכת
local Settings = {
    Theme = {
        Gold = Color3.fromRGB(255, 215, 0),
        Dark = Color3.fromRGB(12, 12, 12),
        Box = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        Ice = Color3.fromRGB(135, 206, 250),
        IceDark = Color3.fromRGB(20, 30, 45),
        ShardBlue = Color3.fromRGB(50, 180, 255),
        CrystalRed = Color3.fromRGB(255, 70, 70),
        Success = Color3.fromRGB(100, 255, 100)
    },
    Keys = {
        Menu = Enum.KeyCode.RightControl,
        Fly = Enum.KeyCode.E,
        Speed = Enum.KeyCode.F
    },
    Fly = { Enabled = false, Speed = 50 },
    Speed = { Enabled = false, Value = 16 },
    Farming = false,
    FarmSpeed = 120,
    Scale = 1
}

--// 4. הגנות (Anti-AFK & Anti-Server Hop)
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local oldTeleport
if hookmetamethod then
    oldTeleport = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if self == TeleportService and (method == "Teleport" or method == "TeleportToPlaceInstance" or method == "TeleportToSpawnByName") then
            warn("[SYSTEM] Blocked server teleport attempt.")
            return nil
        end
        return oldTeleport(self, ...)
    end)
end

local VisualToggles = {}
local FarmConnection = nil
local FarmBlacklist = {}

--// 5. ספרית עיצוב (Library)
local Library = {}

function Library:Tween(obj, props, time, style)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

function Library:AddGlow(obj, color)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or Settings.Theme.Gold
    s.Thickness = 1.2; s.Transparency = 0.5; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function Library:AddTextGlow(obj, color)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or Settings.Theme.Gold
    s.Thickness = 0.6; s.Transparency = 0.7; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
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

--// 6. יצירת הממשק (GUI)
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_Rel"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false

local MiniPasta = Instance.new("TextButton", ScreenGui); MiniPasta.Size = UDim2.new(0, 60, 0, 60); MiniPasta.Position = UDim2.new(0.1, 0, 0.1, 0); MiniPasta.BackgroundColor3 = Settings.Theme.Dark; MiniPasta.Text = "🍝"; MiniPasta.TextSize = 35; MiniPasta.Visible = false; Library:Corner(MiniPasta, 30); Library:AddGlow(MiniPasta); Library:MakeDraggable(MiniPasta)

local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 600, 0, 400); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = Settings.Theme.Dark; MainFrame.ClipsDescendants = true; Library:Corner(MainFrame, 16); Library:AddGlow(MainFrame)

-- הפעלת אנימציה מיידית
MainFrame.Size = UDim2.new(0,0,0,0); Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.6, Enum.EasingStyle.Elastic)

local MainScale = Instance.new("UIScale", MainFrame); MainScale.Scale = 1
local TopBar = Instance.new("Frame", MainFrame); TopBar.Size = UDim2.new(1,0,0,60); TopBar.BackgroundTransparency = 1; Library:MakeDraggable(MainFrame)

local MinBtn = Instance.new("TextButton", TopBar); MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(0, 10, 0, 10); MinBtn.BackgroundColor3 = Settings.Theme.Box; MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.TextSize = 25; Library:Corner(MinBtn, 8); Library:AddGlow(MinBtn, Color3.fromRGB(60,60,60))

MinBtn.MouseButton1Click:Connect(function() 
    Library:Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back); task.wait(0.3); MainFrame.Visible = false; MiniPasta.Visible = true; Library:Tween(MiniPasta, {Size = UDim2.new(0, 60, 0, 60)}, 0.4, Enum.EasingStyle.Elastic)
end)

local pds = Vector2.zero
MiniPasta.MouseButton1Down:Connect(function() pds = UIS:GetMouseLocation() end)
MiniPasta.MouseButton1Up:Connect(function()
    if (UIS:GetMouseLocation() - pds).Magnitude < 5 then
        Library:Tween(MiniPasta, {Size = UDim2.new(0,0,0,0)}, 0.2); task.wait(0.2); MiniPasta.Visible = false; MainFrame.Visible = true; Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.4, Enum.EasingStyle.Back)
    end
end)

local MainTitle = Instance.new("TextLabel", TopBar); MainTitle.Size = UDim2.new(0,300,0,30); MainTitle.Position = UDim2.new(0,50,0,10); MainTitle.BackgroundTransparency = 1; MainTitle.Text = "SPAGHETTI <font color='#FFD700'>MAFIA</font> HUB v1"; MainTitle.RichText = true; MainTitle.Font = Enum.Font.GothamBlack; MainTitle.TextSize = 20; MainTitle.TextColor3 = Color3.new(1,1,1); MainTitle.TextXAlignment = Enum.TextXAlignment.Left; Library:AddTextGlow(MainTitle)
local MainSub = Instance.new("TextLabel", TopBar); MainSub.Size = UDim2.new(0,300,0,20); MainSub.Position = UDim2.new(0,50,0,32); MainSub.BackgroundTransparency = 1; MainSub.Text = "עולם הכיף"; MainSub.Font = Enum.Font.GothamBold; MainSub.TextSize = 13; MainSub.TextColor3 = Settings.Theme.Gold; MainSub.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 160, 1, -60); Sidebar.Position = UDim2.new(0,0,0,60); Sidebar.BackgroundColor3 = Settings.Theme.Box; Sidebar.BorderSizePixel = 0; Sidebar.ZIndex = 2; Library:Corner(Sidebar, 12) 
local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding = UDim.new(0,10); SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center; local SidePad = Instance.new("UIPadding", Sidebar); SidePad.PaddingTop = UDim.new(0,15)

local Container = Instance.new("Frame", MainFrame); Container.Size = UDim2.new(1, -170, 1, -70); Container.Position = UDim2.new(0, 170, 0, 65); Container.BackgroundTransparency = 1

local currentTab = nil
local function CreateTab(name, heb)
    local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(0.9,0,0,40); btn.BackgroundColor3 = Settings.Theme.Dark; btn.Text = name .. "\n<font size='11' color='#AAAAAA'>"..heb.."</font>"; btn.RichText = true; btn.TextColor3 = Color3.fromRGB(150,150,150); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.ZIndex = 3; Library:Corner(btn, 6)
    local page = Instance.new("Frame", Container); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false
    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then Library:Tween(v, {BackgroundColor3 = Settings.Theme.Dark, TextColor3 = Color3.fromRGB(150,150,150)}) end end
        for _,v in pairs(Container:GetChildren()) do v.Visible = false end
        Library:Tween(btn, {BackgroundColor3 = Settings.Theme.Gold, TextColor3 = Color3.new(0,0,0)}); page.Visible = true
    end)
    if not currentTab then currentTab = btn; Library:Tween(btn, {BackgroundColor3 = Settings.Theme.Gold, TextColor3 = Color3.new(0,0,0)}); page.Visible = true end
    return page
end

local Tab_Farm_Page = CreateTab("❄️ Event", "אירוע חורף")
local Tab_Main = CreateTab("Main", "ראשי")
local Tab_Sett = CreateTab("Settings", "הגדרות")
local Tab_Cred = CreateTab("Credits", "קרדיטים")

local function AddLayout(p) 
    local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0,12); l.HorizontalAlignment = Enum.HorizontalAlignment.Center 
    local pad = Instance.new("UIPadding", p); pad.PaddingTop = UDim.new(0,10)
end
AddLayout(Tab_Main); AddLayout(Tab_Sett); AddLayout(Tab_Cred)

--// Logic Farm
local function GetClosestTarget()
    local drops = Workspace:FindFirstChild("StormDrops")
    if not drops then return nil end
    local closest, dist = nil, math.huge; local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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
    local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end
    local region = Region3.new(hrp.Position - Vector3.new(30,30,30), hrp.Position + Vector3.new(30,30,30))
    local objects = workspace:FindPartsInRegion3(region, nil, 200)
    for _, part in pairs(objects) do
        local n = part.Name:lower()
        if n:find("door") or n:find("portal") or n:find("tele") or n:find("gate") or n:find("enter") then
            part.CanTouch = false
            pcall(function() if part:FindFirstChild("TouchInterest") then part.TouchInterest:Destroy() end end)
        end
    end
end

local function EnableNoclip(bool)
    if bool then
        if not FarmConnection then
            FarmConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character and Settings.Farming then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid"); if hum then hum.Sit = false; hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
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
    Settings.Farming = v; EnableNoclip(v); if not v then FarmBlacklist = {} end
    if v then
        task.spawn(function()
            while Settings.Farming do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local target = GetClosestTarget()
                if char and hrp and target and Settings.Farming then
                    local distance = (hrp.Position - target.Position).Magnitude
                    local info = TweenInfo.new(distance / Settings.FarmSpeed, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, info, {CFrame = target.CFrame})
                    tween:Play()
                    local start = tick()
                    while Settings.Farming and target.Parent and (tick() - start) < 1.5 do 
                        task.wait() 
                        if (hrp.Position - target.Position).Magnitude < 10 then
                            if firetouchinterest then firetouchinterest(target, hrp, 0); firetouchinterest(target, hrp, 1) end
                            target.CanTouch = true
                        end
                        if not target.Parent then break end
                    end
                    if target.Parent then tween:Cancel(); FarmBlacklist[target] = true end
                else
                    task.wait(0.1) 
                end
                task.wait()
            end
        end)
    end
end

local function ToggleFly(v)
    Settings.Fly.Enabled = v; local char = LocalPlayer.Character; if not char then return end; local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChild("Humanoid")
    if v then
        local bv = Instance.new("BodyVelocity",hrp); bv.MaxForce=Vector3.new(1e9,1e9,1e9); bv.Name="F_V"; local bg = Instance.new("BodyGyro",hrp); bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bg.P=9e4; bg.Name="F_G"; hum.PlatformStand=true
        task.spawn(function()
            while Settings.Fly.Enabled and char.Parent do
                local cam = workspace.CurrentCamera; local d = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
                bv.Velocity = d * Settings.Fly.Speed; bg.CFrame = cam.CFrame; RunService.Heartbeat:Wait()
            end
            if hrp:FindFirstChild("F_V") then hrp.F_V:Destroy() end; if hrp:FindFirstChild("F_G") then hrp.F_G:Destroy() end; hum.PlatformStand=false
        end)
    else if hrp:FindFirstChild("F_V") then hrp.F_V:Destroy() end; if hrp:FindFirstChild("F_G") then hrp.F_G:Destroy() end; hum.PlatformStand=false end
end

local function CreateSlider(parent, title, heb, min, max, default, callback, toggleCallback, toggleName, isDecimal)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95,0,0,75); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.7,0,0,25); l.Position = UDim2.new(0,10,0,8); l.Text = title .. " <font size='12' color='#999999'>("..heb..")</font> : " .. default; l.RichText=true; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.BackgroundTransparency=1
    local line = Instance.new("Frame", f); line.Size = UDim2.new(0.9,0,0,12); line.Position = UDim2.new(0.05,0,0.65,0); line.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(line,6)
    local fill = Instance.new("Frame", line); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Settings.Theme.Gold; Library:Corner(fill,6)
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                local r = math.clamp((i.Position.X - line.AbsolutePosition.X)/line.AbsoluteSize.X,0,1)
                fill.Size = UDim2.new(r,0,1,0); local v = isDecimal and (math.floor((min+((max-min)*r))*100)/100) or math.floor(min+((max-min)*r))
                l.Text = title.." <font size='12' color='#999999'>("..heb..")</font> : "..v; callback(v)
                if title == "Walk Speed" and Settings.Speed.Enabled and LocalPlayer.Character then local hum = LocalPlayer.Character:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = v end end
            end
        end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
    if toggleCallback then
        local t = Instance.new("TextButton", f); t.Size = UDim2.new(0,60,0,25); t.Position = UDim2.new(1,-70,0,8); t.BackgroundColor3 = Color3.fromRGB(40,40,40); t.Text = "OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.GothamBold; Library:Corner(t,4)
        local on = false
        local function Update(s) on=s; t.Text=on and "ON" or "OFF"; t.BackgroundColor3=on and Settings.Theme.Gold or Color3.fromRGB(40,40,40); t.TextColor3=on and Color3.new(0,0,0) or Color3.new(1,1,1); toggleCallback(on); if title == "Walk Speed" and not on and LocalPlayer.Character then local hum = LocalPlayer.Character:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = 16 end end end
        t.MouseButton1Click:Connect(function() Update(not on) end)
        if toggleName then VisualToggles[toggleName] = function(v) Update(v) end end
    end
end

local function CreateSquareBind(parent, id, title, heb, default, callback)
    local f = Instance.new("TextButton", parent); local sizeY = id==3 and 60 or 80; f.Position = id==1 and UDim2.new(0,0,0,0) or (id==2 and UDim2.new(0.52,0,0,0) or UDim2.new(0,0,0,0)); f.Size = UDim2.new(id==3 and 1 or 0.48,0,0,sizeY); f.BackgroundColor3 = Settings.Theme.Box; f.Text=""; f.AutoButtonColor=false; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1,0,0,20); t.Position = UDim2.new(0,0,id==3 and 0.1 or 0.15,0); t.Text=title; t.TextColor3=Color3.fromRGB(150,150,150); t.Font=Enum.Font.Gotham; t.TextSize=13; t.BackgroundTransparency=1
    local h = Instance.new("TextLabel", f); h.Size = UDim2.new(1,0,0,15); h.Position = UDim2.new(0,0,0.35,0); h.Text=heb; h.TextColor3=Color3.fromRGB(100,100,100); h.Font=Enum.Font.Gotham; h.TextSize=11; h.BackgroundTransparency=1
    local k = Instance.new("TextLabel", f); k.Size = UDim2.new(1,0,0,30); k.Position = UDim2.new(0,0,id==3 and 0.5 or 0.6,0); k.Text=default.Name; k.TextColor3=Settings.Theme.Gold; k.Font=Enum.Font.GothamBold; k.TextSize=20; k.BackgroundTransparency=1
    f.MouseButton1Click:Connect(function() k.Text="..."; local i=UIS.InputBegan:Wait(); if i.UserInputType==Enum.UserInputType.Keyboard then k.Text=i.KeyCode.Name; callback(i.KeyCode) end end)
    return f
end

--================================================================================
--// 9. בניית התוכן החדש - מעודכן ללא גלילה + לוגיקה חזקה
--================================================================================

local Tab_Farm = Instance.new("ScrollingFrame", Tab_Farm_Page)
Tab_Farm.Size = UDim2.new(1, 0, 1, 0)
Tab_Farm.BackgroundTransparency = 1
Tab_Farm.ScrollBarThickness = 2
Tab_Farm.ScrollBarImageColor3 = Settings.Theme.Ice
Tab_Farm.AutomaticCanvasSize = Enum.AutomaticSize.Y
Tab_Farm.CanvasSize = UDim2.new(0,0,0,0)
Tab_Farm.BorderSizePixel = 0

local EventLayout = Instance.new("UIListLayout", Tab_Farm)
EventLayout.Padding = UDim.new(0, 8) -- רווח קטן יותר כדי שהכל ייכנס
EventLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
EventLayout.SortOrder = Enum.SortOrder.LayoutOrder
local EventPad = Instance.new("UIPadding", Tab_Farm); EventPad.PaddingTop = UDim.new(0,5); EventPad.PaddingBottom = UDim.new(0,10)

-- 1. Toggle Auto Farm
local FarmBtn = Instance.new("TextButton", Tab_Farm)
FarmBtn.Size = UDim2.new(0.95, 0, 0, 60) -- קצת יותר קטן
FarmBtn.BackgroundColor3 = Settings.Theme.IceDark 
FarmBtn.Text = ""
FarmBtn.AutoButtonColor = false
FarmBtn.LayoutOrder = 1
Library:Corner(FarmBtn, 12)
local FarmStroke = Library:AddGlow(FarmBtn, Settings.Theme.Ice); FarmStroke.Transparency = 0.3

local FarmTitle = Instance.new("TextLabel", FarmBtn)
FarmTitle.Size = UDim2.new(1, -60, 1, 0)
FarmTitle.Position = UDim2.new(0, 20, 0, 0)
FarmTitle.Text = "Toggle Auto Farm ❄️"
FarmTitle.TextColor3 = Color3.new(1,1,1); FarmTitle.Font = Enum.Font.GothamBlack; FarmTitle.TextSize = 18; FarmTitle.TextXAlignment = Enum.TextXAlignment.Left; FarmTitle.BackgroundTransparency = 1

local FarmIconBack = Instance.new("Frame", FarmBtn)
FarmIconBack.Size = UDim2.new(0, 40, 0, 25)
FarmIconBack.Position = UDim2.new(1, -60, 0.5, -12.5)
FarmIconBack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Library:Corner(FarmIconBack, 20)
local FarmCircle = Instance.new("Frame", FarmIconBack)
FarmCircle.Size = UDim2.new(0, 21, 0, 21)
FarmCircle.Position = UDim2.new(0, 2, 0.5, -10.5)
FarmCircle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
Library:Corner(FarmCircle, 20)

local isFarming = false
FarmBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        Library:Tween(FarmIconBack, {BackgroundColor3 = Settings.Theme.Ice})
        Library:Tween(FarmCircle, {Position = UDim2.new(1, -23, 0.5, -10.5), BackgroundColor3 = Color3.new(1,1,1)})
        Library:Tween(FarmStroke, {Color = Color3.new(1,1,1)})
    else
        Library:Tween(FarmIconBack, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)})
        Library:Tween(FarmCircle, {Position = UDim2.new(0, 2, 0.5, -10.5), BackgroundColor3 = Color3.fromRGB(150, 150, 150)})
        Library:Tween(FarmStroke, {Color = Settings.Theme.Ice})
    end
    ToggleFarm(isFarming)
end)

-- 2. TOTAL BALANCE (מופיע למעלה כדי שלא יהיה צריך לגלול)
local BalanceContainer = Instance.new("Frame", Tab_Farm)
BalanceContainer.Size = UDim2.new(0.95, 0, 0, 45) -- נמוך וקומפקטי
BalanceContainer.BackgroundTransparency = 1
BalanceContainer.LayoutOrder = 2

local BalanceGrid = Instance.new("UIGridLayout", BalanceContainer)
BalanceGrid.CellSize = UDim2.new(0.48, 0, 1, 0)
BalanceGrid.CellPadding = UDim2.new(0.04, 0, 0, 0)
BalanceGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Total Shards (קטן)
local TotShards = Instance.new("Frame", BalanceContainer)
TotShards.BackgroundColor3 = Settings.Theme.Box
Library:Corner(TotShards, 8)
Library:AddGlow(TotShards, Settings.Theme.ShardBlue)
local T_ValS = Instance.new("TextLabel", TotShards); T_ValS.Size = UDim2.new(1,-10,1,0); T_ValS.Position=UDim2.new(0,5,0,0); T_ValS.BackgroundTransparency=1; T_ValS.Text="Total: ..."; T_ValS.TextColor3=Settings.Theme.ShardBlue; T_ValS.Font=Enum.Font.GothamBold; T_ValS.TextSize=14; T_ValS.TextXAlignment=Enum.TextXAlignment.Left

-- Total Crystals (קטן)
local TotCrystals = Instance.new("Frame", BalanceContainer)
TotCrystals.BackgroundColor3 = Settings.Theme.Box
Library:Corner(TotCrystals, 8)
Library:AddGlow(TotCrystals, Settings.Theme.CrystalRed)
local T_ValC = Instance.new("TextLabel", TotCrystals); T_ValC.Size = UDim2.new(1,-10,1,0); T_ValC.Position=UDim2.new(0,5,0,0); T_ValC.BackgroundTransparency=1; T_ValC.Text="Total: ..."; T_ValC.TextColor3=Settings.Theme.CrystalRed; T_ValC.Font=Enum.Font.GothamBold; T_ValC.TextSize=14; T_ValC.TextXAlignment=Enum.TextXAlignment.Left

-- 3. SESSION COLLECTED (הריבועים הגדולים)
local StatsLabel = Instance.new("TextLabel", Tab_Farm)
StatsLabel.Size = UDim2.new(0.95,0,0,15); StatsLabel.Text = "Session Collected (נאסף בריצה זו) 📥"; StatsLabel.TextColor3 = Color3.fromRGB(180,180,180); StatsLabel.Font=Enum.Font.GothamBold; StatsLabel.TextSize=12; StatsLabel.BackgroundTransparency=1; StatsLabel.LayoutOrder=3

local StatsContainer = Instance.new("Frame", Tab_Farm)
StatsContainer.Size = UDim2.new(0.95, 0, 0, 85)
StatsContainer.BackgroundTransparency = 1
StatsContainer.LayoutOrder = 4

local StatsGrid = Instance.new("UIGridLayout", StatsContainer)
StatsGrid.CellSize = UDim2.new(0.48, 0, 1, 0)
StatsGrid.CellPadding = UDim2.new(0.04, 0, 0, 0)
StatsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- SHARDS BOX
local BoxBlue = Instance.new("Frame", StatsContainer)
BoxBlue.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
Library:Corner(BoxBlue, 12)
local StrokeBlue = Instance.new("UIStroke", BoxBlue); StrokeBlue.Color = Settings.Theme.ShardBlue; StrokeBlue.Thickness = 1.2; StrokeBlue.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local TitleBlue = Instance.new("TextLabel", BoxBlue); TitleBlue.Size = UDim2.new(1, 0, 0.3, 0); TitleBlue.Position = UDim2.new(0,0,0.1,0); TitleBlue.BackgroundTransparency = 1; TitleBlue.Text = "Shards 🧊"; TitleBlue.TextColor3 = Settings.Theme.ShardBlue; TitleBlue.Font = Enum.Font.GothamBold; TitleBlue.TextSize = 16
local ValBlue = Instance.new("TextLabel", BoxBlue); ValBlue.Size = UDim2.new(1, 0, 0.5, 0); ValBlue.Position = UDim2.new(0,0,0.45,0); ValBlue.BackgroundTransparency = 1; ValBlue.Text = "0"; ValBlue.TextColor3 = Color3.new(1, 1, 1); ValBlue.Font = Enum.Font.GothamBlack; ValBlue.TextSize = 30

-- CRYSTALS BOX
local BoxRed = Instance.new("Frame", StatsContainer)
BoxRed.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
Library:Corner(BoxRed, 12)
local StrokeRed = Instance.new("UIStroke", BoxRed); StrokeRed.Color = Settings.Theme.CrystalRed; StrokeRed.Thickness = 1.2; StrokeRed.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local TitleRed = Instance.new("TextLabel", BoxRed); TitleRed.Size = UDim2.new(1, 0, 0.3, 0); TitleRed.Position = UDim2.new(0,0,0.1,0); TitleRed.BackgroundTransparency = 1; TitleRed.Text = "Crystals 💎"; TitleRed.TextColor3 = Settings.Theme.CrystalRed; TitleRed.Font = Enum.Font.GothamBold; TitleRed.TextSize = 16
local ValRed = Instance.new("TextLabel", BoxRed); ValRed.Size = UDim2.new(1, 0, 0.5, 0); ValRed.Position = UDim2.new(0,0,0.45,0); ValRed.BackgroundTransparency = 1; ValRed.Text = "0"; ValRed.TextColor3 = Color3.new(1, 1, 1); ValRed.Font = Enum.Font.GothamBlack; ValRed.TextSize = 30

--// לוגיקה חכמה לחיפוש נתונים + חישוב INITIAL
task.spawn(function()
    T_ValS.Text = "Searching..."
    T_ValC.Text = "Searching..."

    local DataFolder = nil
    
    -- 1. מציאת התיקייה בלולאה עד שנמצאת
    while not DataFolder do
        -- בדיקה 1: NX3HO
        if LocalPlayer:FindFirstChild("NX3HO") then
            DataFolder = LocalPlayer.NX3HO
        -- בדיקה 2: leaderstats
        elseif LocalPlayer:FindFirstChild("leaderstats") then
            DataFolder = LocalPlayer.leaderstats
        end
        
        if not DataFolder then
             -- בדיקה 3: חיפוש עמוק
            for _, child in pairs(LocalPlayer:GetChildren()) do
                if child:IsA("Folder") and (child:FindFirstChild("Crystals") or child:FindFirstChild("Shards")) then
                    DataFolder = child
                    break
                end
            end
        end

        if not DataFolder then task.wait(1) end
    end

    -- 2. מציאת הערכים וקביעת Initial
    local CrystalsRef = DataFolder:WaitForChild("Crystals", 10)
    local ShardsRef = DataFolder:WaitForChild("Shards", 10)

    if not CrystalsRef or not ShardsRef then
        T_ValS.Text = "Error"
        return
    end

    -- שמירת הערך ההתחלתי (Snapshot)
    local initialCrystals = CrystalsRef.Value
    local initialShards = ShardsRef.Value
    
    print("[SYSTEM] Initial Crystals: " .. initialCrystals)
    print("[SYSTEM] Initial Shards: " .. initialShards)

    -- 3. לולאת עדכון (Current - Initial)
    while true do
        task.wait(0.2) -- רענון מהיר
        
        local currentCrystals = CrystalsRef.Value
        local currentShards = ShardsRef.Value

        -- חישוב כמה נאסף מאז הטעינה
        local collectedCrystals = currentCrystals - initialCrystals
        local collectedShards = currentShards - initialShards

        -- מניעת מספרים שליליים (אם בזבזת בחנות)
        if collectedCrystals < 0 then collectedCrystals = 0 end 
        if collectedShards < 0 then collectedShards = 0 end

        -- עדכון תצוגה
        -- סה"כ למעלה
        T_ValC.Text = "Total: " .. currentCrystals
        T_ValS.Text = "Total: " .. currentShards
        
        -- כמה נאסף בריבועים הגדולים
        ValRed.Text = tostring(collectedCrystals)
        ValBlue.Text = tostring(collectedShards)
    end
end)

--================================================================================
--// המשך בניית הטאבים האחרים
--================================================================================

CreateSlider(Tab_Main, "Walk Speed", "מהירות הליכה", 16, 250, 16, function(v) Settings.Speed.Value = v end, function(t) Settings.Speed.Enabled = t end, "Speed")
CreateSlider(Tab_Main, "Fly Speed", "מהירות תעופה", 20, 300, 50, function(v) Settings.Fly.Speed = v end, function(t) ToggleFly(t) end, "Fly")
local BindCont = Instance.new("Frame", Tab_Main); BindCont.Size = UDim2.new(0.95,0,0,80); BindCont.BackgroundTransparency = 1; CreateSquareBind(BindCont, 1, "FLY", "תעופה", Settings.Keys.Fly, function(k) Settings.Keys.Fly = k end); CreateSquareBind(BindCont, 2, "SPEED", "מהירות", Settings.Keys.Speed, function(k) Settings.Keys.Speed = k end)
CreateSlider(Tab_Sett, "FOV", "שדה ראייה", 70, 120, 70, function(v) Camera.FieldOfView = v end); CreateSlider(Tab_Sett, "GUI Scale", "גודל ממשק", 0.5, 1.5, 1, function(v) MainScale.Scale = v end, nil, nil, true)
local MenuBindCont = Instance.new("Frame", Tab_Sett); MenuBindCont.Size = UDim2.new(0.95,0,0,70); MenuBindCont.BackgroundTransparency = 1; CreateSquareBind(MenuBindCont, 3, "MENU KEY", "מקש תפריט", Settings.Keys.Menu, function(k) Settings.Keys.Menu = k end)

local function AddCr(n, id)
    local f = Instance.new("Frame", Tab_Cred); f.Size = UDim2.new(0.95,0,0,100); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 12); Library:AddGlow(f)
    local i = Instance.new("ImageLabel", f); i.Size = UDim2.new(0,80,0,80); i.Position = UDim2.new(0,10,0.5,-40); i.Image = "rbxthumb://type=AvatarHeadShot&id="..id.."&w=150&h=150"; Library:Corner(i, 40)
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(0,350,0,30); t.Position = UDim2.new(0,100,0,20); t.Text = n .. " <font color='#AAAAAA'>(יוצרים)</font>"; t.RichText=true; t.TextColor3 = Settings.Theme.Gold; t.Font=Enum.Font.GothamBlack; t.TextSize=22; t.TextXAlignment="Left"; t.BackgroundTransparency=1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0,140,0,30); b.Position = UDim2.new(0,100,0,55); b.BackgroundColor3 = Color3.fromRGB(88,101,242); b.Text="Copy Discord"; b.TextColor3=Color3.new(1,1,1); Library:Corner(b,6); b.TextSize=13; b.MouseButton1Click:Connect(function() setclipboard(n); b.Text="Copied!"; task.wait(1); b.Text="Copy Discord" end)
end
AddCr("nx3ho", 1323665023); AddCr("8adshot3", 3370067928)

UIS.InputBegan:Connect(function(i,g)
    if not g then
        if i.KeyCode == Settings.Keys.Menu then 
            if MainFrame.Visible then Library:Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back); task.wait(0.3); MainFrame.Visible = false
            else MainFrame.Visible = true; MainFrame.Size = UDim2.new(0,0,0,0); Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.5, Enum.EasingStyle.Elastic) end
        end
        if i.KeyCode == Settings.Keys.Fly then 
            Settings.Fly.Enabled = not Settings.Fly.Enabled; 
            ToggleFly(Settings.Fly.Enabled); 
            if VisualToggles["Fly"] then VisualToggles["Fly"](Settings.Fly.Enabled) end 
        end
        if i.KeyCode == Settings.Keys.Speed then 
            Settings.Speed.Enabled = not Settings.Speed.Enabled; 
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

print("[SYSTEM] Spaghetti Mafia Hub Loaded Successfully.")
