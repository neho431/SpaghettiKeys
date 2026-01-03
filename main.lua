--[[
    Spaghetti Mafia Hub v1 (MERGED FINAL)
    Base: Script 1 (GUI & Whitelist)
    Logic: Script 2 (Farm & Safety) + Fixed Session Stats
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

--// 1. מערכת Whitelist (מקורי מסקריפט 1)
local WHITELIST_URL = "https://github.com/neho431/SpaghettiKeys/blob/main/whitelist.txt"

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

-- הפעלת הבדיקה
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
    FarmSpeed = 300, -- מהירות מעודכנת מסקריפט 2
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
local LastFullScan = 0

--// 5. ספרית עיצוב (Library) - נשאר מסקריפט 1
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

--// 6. יצירת הממשק (GUI) - נשאר מסקריפט 1 בדיוק
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

--// הגדרת הטאבים
local Tab_Farm_Page = CreateTab("❄️ Event", "אירוע חורף")
local Tab_Main = CreateTab("Main", "ראשי")
local Tab_Sett = CreateTab("Settings", "הגדרות")
local Tab_Cred = CreateTab("Credits", "קרדיטים")

local function AddLayout(p) 
    local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0,12); l.HorizontalAlignment = Enum.HorizontalAlignment.Center 
    local pad = Instance.new("UIPadding", p); pad.PaddingTop = UDim.new(0,10)
end
AddLayout(Tab_Main); AddLayout(Tab_Sett); AddLayout(Tab_Cred)

--================================================================================
--// 8. לוגיקת חווה (הועתקה מסקריפט 2 - Safe Farm)
--================================================================================

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

-- פונקציית חסימת דלתות ופורטלים (הועתקה מסקריפט 2)
local function UltraSafeDisable()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- ביטול CanTouch לשחקן
    for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end
    
    -- חיפוש אובייקטים בעייתיים ומחיקת TouchInterest
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

    -- סריקה רחבה פעם ב-5 שניות
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

-- פונקציית Noclip (הועתקה מסקריפט 2)
local function EnableNoclip(bool)
    if bool then
        if not FarmConnection then
            FarmConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character and Settings.Farming then
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

-- פונקציית החווה הראשית (הועתקה מסקריפט 2)
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
                    
                    -- Tween תנועה
                    local info = TweenInfo.new(distance / Settings.FarmSpeed, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, info, {CFrame = target.CFrame})
                    tween:Play()
                    
                    local start = tick()
                    
                    repeat task.wait() 
                        if not target.Parent or not Settings.Farming then tween:Cancel(); break end
                        
                        -- מנגנון אנטי-תקיעה מסקריפט 2: אם עברו 2 שניות, דלג
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

--// Fly Logic
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

--// 7. פונקציות רכיבים כלליים
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
--// 9. בניית התוכן של Tab_Farm (בדיוק לפי סקריפט 1)
--================================================================================

-- יצירת ScrollingFrame
local Tab_Farm = Instance.new("ScrollingFrame", Tab_Farm_Page)
Tab_Farm.Size = UDim2.new(1, 0, 1, 0)
Tab_Farm.BackgroundTransparency = 1
Tab_Farm.ScrollBarThickness = 2
Tab_Farm.ScrollBarImageColor3 = Settings.Theme.Ice
Tab_Farm.AutomaticCanvasSize = Enum.AutomaticSize.Y
Tab_Farm.CanvasSize = UDim2.new(0,0,0,0)
Tab_Farm.BorderSizePixel = 0

-- גרדיאנט חורפי
local EventGradient = Instance.new("UIGradient", Tab_Farm_Page)
EventGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,25)), 
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,15,30))
}
EventGradient.Rotation = 45

-- 1. פריסת הרשימה
local EventLayout = Instance.new("UIListLayout", Tab_Farm)
EventLayout.Padding = UDim.new(0, 15)
EventLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
EventLayout.SortOrder = Enum.SortOrder.LayoutOrder
local EventPad = Instance.new("UIPadding", Tab_Farm); EventPad.PaddingTop = UDim.new(0,10); EventPad.PaddingBottom = UDim.new(0,20)

-- 2. Toggle Auto Farm
local FarmBtn = Instance.new("TextButton", Tab_Farm)
FarmBtn.Size = UDim2.new(0.95, 0, 0, 70)
FarmBtn.BackgroundColor3 = Settings.Theme.IceDark 
FarmBtn.Text = ""
FarmBtn.AutoButtonColor = false
FarmBtn.LayoutOrder = 1
Library:Corner(FarmBtn, 12)
local FarmStroke = Library:AddGlow(FarmBtn, Settings.Theme.Ice)
FarmStroke.Transparency = 0.3

local BtnGrad = Instance.new("UIGradient", FarmBtn)
BtnGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(30,40,60)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20,25,35))}
BtnGrad.Rotation = 90

local FarmTitle = Instance.new("TextLabel", FarmBtn)
FarmTitle.Size = UDim2.new(1, -60, 1, 0)
FarmTitle.Position = UDim2.new(0, 20, 0, 0)
FarmTitle.Text = "Toggle Auto Farm ❄️\n<font size='13' color='#87CEFA'>הפעלת חווה אוטומטית</font>"
FarmTitle.RichText = true
FarmTitle.TextColor3 = Color3.new(1,1,1)
FarmTitle.Font = Enum.Font.GothamBlack
FarmTitle.TextSize = 18
FarmTitle.TextXAlignment = Enum.TextXAlignment.Left
FarmTitle.BackgroundTransparency = 1

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
    -- הפעלת הפונקציה החדשה מסקריפט 2
    ToggleFarm(isFarming)
end)

-- 3. Anti-AFK
local AFKStatus = Instance.new("TextLabel", Tab_Farm)
AFKStatus.Size = UDim2.new(0.95, 0, 0, 20)
AFKStatus.BackgroundTransparency = 1
AFKStatus.Text = "Anti-AFK System: <font color='#00FF00'>Active</font> ⚡"
AFKStatus.RichText = true
AFKStatus.TextColor3 = Color3.new(1, 1, 1)
AFKStatus.Font = Enum.Font.GothamMedium
AFKStatus.TextSize = 13
AFKStatus.LayoutOrder = 2

-- 4. מוני איסוף צבעוניים (SESSION)
local StatsLabel = Instance.new("TextLabel", Tab_Farm)
StatsLabel.Size = UDim2.new(0.95,0,0,20); StatsLabel.Text = "Session Collected (איסוף נוכחי) 📥"; StatsLabel.TextColor3 = Color3.fromRGB(180,180,180); StatsLabel.Font=Enum.Font.GothamBold; StatsLabel.TextSize=12; StatsLabel.BackgroundTransparency=1; StatsLabel.LayoutOrder=3

local StatsContainer = Instance.new("Frame", Tab_Farm)
StatsContainer.Size = UDim2.new(0.95, 0, 0, 85)
StatsContainer.BackgroundTransparency = 1
StatsContainer.LayoutOrder = 4

local StatsGrid = Instance.new("UIGridLayout", StatsContainer)
StatsGrid.CellSize = UDim2.new(0.48, 0, 1, 0)
StatsGrid.CellPadding = UDim2.new(0.04, 0, 0, 0)
StatsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- SHARDS (ריבוע כחול)
local BoxBlue = Instance.new("Frame", StatsContainer)
BoxBlue.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
Library:Corner(BoxBlue, 12)
local StrokeBlue = Instance.new("UIStroke", BoxBlue)
StrokeBlue.Color = Settings.Theme.ShardBlue
StrokeBlue.Thickness = 1.2
StrokeBlue.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local TitleBlue = Instance.new("TextLabel", BoxBlue)
TitleBlue.Size = UDim2.new(1, 0, 0.3, 0)
TitleBlue.Position = UDim2.new(0,0,0.1,0)
TitleBlue.BackgroundTransparency = 1
TitleBlue.Text = "Shards 🧊"
TitleBlue.TextColor3 = Settings.Theme.ShardBlue
TitleBlue.Font = Enum.Font.GothamBold
TitleBlue.TextSize = 16
TitleBlue.TextYAlignment = Enum.TextYAlignment.Center

local ValBlue = Instance.new("TextLabel", BoxBlue)
ValBlue.Size = UDim2.new(1, 0, 0.5, 0)
ValBlue.Position = UDim2.new(0,0,0.45,0)
ValBlue.BackgroundTransparency = 1
ValBlue.Text = "0"
ValBlue.TextColor3 = Color3.new(1, 1, 1)
ValBlue.Font = Enum.Font.GothamBlack
ValBlue.TextSize = 30
ValBlue.TextYAlignment = Enum.TextYAlignment.Center

-- CRYSTALS (ריבוע אדום)
local BoxRed = Instance.new("Frame", StatsContainer)
BoxRed.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
Library:Corner(BoxRed, 12)
local StrokeRed = Instance.new("UIStroke", BoxRed)
StrokeRed.Color = Settings.Theme.CrystalRed
StrokeRed.Thickness = 1.2
StrokeRed.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local TitleRed = Instance.new("TextLabel", BoxRed)
TitleRed.Size = UDim2.new(1, 0, 0.3, 0)
TitleRed.Position = UDim2.new(0,0,0.1,0)
TitleRed.BackgroundTransparency = 1
TitleRed.Text = "Crystals 💎"
TitleRed.TextColor3 = Settings.Theme.CrystalRed
TitleRed.Font = Enum.Font.GothamBold
TitleRed.TextSize = 16
TitleRed.TextYAlignment = Enum.TextYAlignment.Center

local ValRed = Instance.new("TextLabel", BoxRed)
ValRed.Size = UDim2.new(1, 0, 0.5, 0)
ValRed.Position = UDim2.new(0,0,0.45,0)
ValRed.BackgroundTransparency = 1
ValRed.Text = "0"
ValRed.TextColor3 = Color3.new(1, 1, 1)
ValRed.Font = Enum.Font.GothamBlack
ValRed.TextSize = 30
ValRed.TextYAlignment = Enum.TextYAlignment.Center

-- 5. TOTAL BALANCE (להצגת סך הכל)
local BalanceLabel = Instance.new("TextLabel", Tab_Farm)
BalanceLabel.Size = UDim2.new(0.95,0,0,25); BalanceLabel.Text = "Total Balance (סה''כ בתיק) 💰"; BalanceLabel.TextColor3 = Color3.fromRGB(255, 215, 0); BalanceLabel.Font=Enum.Font.GothamBlack; BalanceLabel.TextSize=14; BalanceLabel.BackgroundTransparency=1; BalanceLabel.LayoutOrder=5

local BalanceContainer = Instance.new("Frame", Tab_Farm)
BalanceContainer.Size = UDim2.new(0.95, 0, 0, 70)
BalanceContainer.BackgroundTransparency = 1
BalanceContainer.LayoutOrder = 6

local BalanceGrid = Instance.new("UIGridLayout", BalanceContainer)
BalanceGrid.CellSize = UDim2.new(0.48, 0, 1, 0)
BalanceGrid.CellPadding = UDim2.new(0.04, 0, 0, 0)
BalanceGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- TOTAL SHARDS
local TotShards = Instance.new("Frame", BalanceContainer)
TotShards.BackgroundColor3 = Settings.Theme.Box
Library:Corner(TotShards, 8)
Library:AddGlow(TotShards, Settings.Theme.ShardBlue)

local T_TitleS = Instance.new("TextLabel", TotShards)
T_TitleS.Size = UDim2.new(1,0,0.3,0); T_TitleS.BackgroundTransparency=1; T_TitleS.Text="Total Shards"; T_TitleS.TextColor3=Settings.Theme.ShardBlue; T_TitleS.Font=Enum.Font.GothamBold; T_TitleS.TextSize=12; T_TitleS.TextYAlignment=Enum.TextYAlignment.Bottom
local T_ValS = Instance.new("TextLabel", TotShards)
T_ValS.Size = UDim2.new(1,0,0.7,0); T_ValS.Position=UDim2.new(0,0,0.3,0); T_ValS.BackgroundTransparency=1; T_ValS.Text="..."; T_ValS.TextColor3=Color3.new(1,1,1); T_ValS.Font=Enum.Font.GothamMedium; T_ValS.TextSize=18; T_ValS.TextYAlignment=Enum.TextYAlignment.Top

-- TOTAL CRYSTALS
local TotCrystals = Instance.new("Frame", BalanceContainer)
TotCrystals.BackgroundColor3 = Settings.Theme.Box
Library:Corner(TotCrystals, 8)
Library:AddGlow(TotCrystals, Settings.Theme.CrystalRed)

local T_TitleC = Instance.new("TextLabel", TotCrystals)
T_TitleC.Size = UDim2.new(1,0,0.3,0); T_TitleC.BackgroundTransparency=1; T_TitleC.Text="Total Crystals"; T_TitleC.TextColor3=Settings.Theme.CrystalRed; T_TitleC.Font=Enum.Font.GothamBold; T_TitleC.TextSize=12; T_TitleC.TextYAlignment=Enum.TextYAlignment.Bottom
local T_ValC = Instance.new("TextLabel", TotCrystals)
T_ValC.Size = UDim2.new(1,0,0.7,0); T_ValC.Position=UDim2.new(0,0,0.3,0); T_ValC.BackgroundTransparency=1; T_ValC.Text="..."; T_ValC.TextColor3=Color3.new(1,1,1); T_ValC.Font=Enum.Font.GothamMedium; T_ValC.TextSize=18; T_ValC.TextYAlignment=Enum.TextYAlignment.Top

-- 6. LAST STORM (סיכום למטה)
local SummaryFrame = Instance.new("Frame", Tab_Farm)
SummaryFrame.Size = UDim2.new(0.95, 0, 0, 60)
SummaryFrame.BackgroundColor3 = Settings.Theme.Box
SummaryFrame.LayoutOrder = 7
Library:Corner(SummaryFrame, 8)
Library:AddGlow(SummaryFrame, Color3.fromRGB(60,60,70))

local SumLayout = Instance.new("UIListLayout", SummaryFrame)
SumLayout.Padding = UDim.new(0, 4)
SumLayout.VerticalAlignment = Enum.VerticalAlignment.Center
SumLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

local PadSum = Instance.new("UIPadding", SummaryFrame)
PadSum.PaddingLeft = UDim.new(0, 15)

local TxtLastStorm = Instance.new("TextLabel", SummaryFrame)
TxtLastStorm.Size = UDim2.new(1, 0, 0.45, 0)
TxtLastStorm.BackgroundTransparency = 1
TxtLastStorm.Text = "Last Storm: 0 🌩️"
TxtLastStorm.TextColor3 = Color3.fromRGB(200, 200, 200)
TxtLastStorm.Font = Enum.Font.Gotham
TxtLastStorm.TextSize = 14
TxtLastStorm.TextXAlignment = Enum.TextXAlignment.Left

local TxtTotalSession = Instance.new("TextLabel", SummaryFrame)
TxtTotalSession.Size = UDim2.new(1, 0, 0.45, 0)
TxtTotalSession.BackgroundTransparency = 1
TxtTotalSession.Text = "Session Total: 0 📦"
TxtTotalSession.TextColor3 = Settings.Theme.Ice
TxtTotalSession.Font = Enum.Font.GothamBold
TxtTotalSession.TextSize = 14
TxtTotalSession.TextXAlignment = Enum.TextXAlignment.Left

--// ==============================================================================
--// מנגנון זיהוי נתונים מתוקן (SESSION ONLY + נתיבים נכונים)
--// ==============================================================================
task.spawn(function()
    T_ValS.Text = "Searching..."
    T_ValC.Text = "Searching..."

    -- 1. איתור הערכים (שימוש ב-WaitForChild למניעת שגיאות בתחילת משחק)
    -- הערה: המשתמש ביקש LocalPlayer.Crystals ו-LocalPlayer.Shards ישירות
    local CrystalsRef = LocalPlayer:WaitForChild("Crystals", 10)
    local ShardsRef = LocalPlayer:WaitForChild("Shards", 10)

    if not CrystalsRef or not ShardsRef then
        T_ValS.Text = "Error"
        T_ValC.Text = "Error"
        warn("[SYSTEM] Could not find Crystals/Shards directly in LocalPlayer!")
        return
    end

    -- 2. שמירת ערכים התחלתיים (כדי לחשב SESSION)
    local InitialCrystals = CrystalsRef.Value
    local InitialShards = ShardsRef.Value
    
    local LastCrystals = CrystalsRef.Value
    local LastShards = ShardsRef.Value
    
    local StormCrystals = 0
    local StormShards = 0

    while true do
        task.wait(0.5) -- רענון חסכוני
        
        local success, err = pcall(function()
            local CurrentCrystals = CrystalsRef.Value
            local CurrentShards = ShardsRef.Value
            
            -- חישוב ה-Session (מה שיש עכשיו פחות מה שהיה בהתחלה)
            local SessionCrystals = CurrentCrystals - InitialCrystals
            local SessionShards = CurrentShards - InitialShards
            
            -- אם הערך שלילי (למשל בוזבז כסף), נאפס את ה-Session שלא יראה מינוס
            if SessionCrystals < 0 then SessionCrystals = 0 end
            if SessionShards < 0 then SessionShards = 0 end

            -- עדכון ריבועים צבעוניים (מראה רק Session!)
            ValRed.Text = tostring(SessionCrystals)  -- אדום = Crystals
            ValBlue.Text = tostring(SessionShards)   -- כחול = Shards

            -- עדכון Total Balance (מראה הכל)
            T_ValC.Text = tostring(CurrentCrystals)
            T_ValS.Text = tostring(CurrentShards)

            -- חישוב Last Storm (כמה נאסף בגל האחרון)
            if CurrentCrystals > LastCrystals then
                StormCrystals = StormCrystals + (CurrentCrystals - LastCrystals)
            elseif CurrentCrystals < LastCrystals then
                -- כנראה בזבזנו או התאפס
                StormCrystals = 0 
            end
            
            if CurrentShards > LastShards then
                StormShards = StormShards + (CurrentShards - LastShards)
            elseif CurrentShards < LastShards then
                StormShards = 0
            end

            LastCrystals = CurrentCrystals
            LastShards = CurrentShards

            -- עדכון שורות סיכום למטה
            local totalStorm = StormCrystals + StormShards
            local totalSession = SessionCrystals + SessionShards

            TxtLastStorm.Text = "Last Storm: " .. totalStorm .. " 🌩️"
            TxtTotalSession.Text = "Session Total: " .. totalSession .. " 📦"
        end)

        if not success then
            warn("[SYSTEM] Data update error: " .. tostring(err))
        end
    end
end)

--================================================================================
--// סיום בניית הטאב הראשון, המשך בניית שאר הטאבים כרגיל
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

--// 10. ניהול מקשים ועדכונים
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

print("[SYSTEM] Spaghetti Mafia Hub - Logic Swapped Successfully.")
