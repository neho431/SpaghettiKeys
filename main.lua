--[[
    Spaghetti Mafia Hub v4 (WINTER STORM EDITION)
    - Restored: Last Storm Stats, Discord Copy, All Tabs.
    - System: Deep Scan (Finds data 100%).
    - Theme: Full Winter/Ice Design for Event Tab.
    - Fixes: Strong Door Block & Anti-Sit.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// 1. Whitelist
local WHITELIST_URL = "https://raw.githubusercontent.com/neho431/SpaghettiKeys/main/whitelist.txt"
local function CheckWhitelist()
    local success, content = pcall(function() return game:HttpGet(WHITELIST_URL .. "?t=" .. tick()) end)
    if success and content and string.find(content, LocalPlayer.Name) then
        print("[SYSTEM] Whitelist Confirmed.")
        return true
    end
    LocalPlayer:Kick("Not Whitelisted!")
    return false
end
if not CheckWhitelist() then return end

--// 2. Cleanup
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then CoreGui.SpaghettiHub_Rel:Destroy() end
if CoreGui:FindFirstChild("SpaghettiHub_V2") then CoreGui.SpaghettiHub_V2:Destroy() end

--// 3. Settings & Theme
local Settings = {
    Theme = {
        Gold = Color3.fromRGB(255, 215, 0),
        Dark = Color3.fromRGB(15, 15, 20),
        Box = Color3.fromRGB(25, 25, 30),
        Ice = Color3.fromRGB(135, 206, 250),     -- תכלת קרח
        Snow = Color3.fromRGB(240, 248, 255),    -- לבן שלג
        DeepIce = Color3.fromRGB(0, 100, 150),   -- כחול עמוק
        Shard = Color3.fromRGB(80, 210, 255),
        Crystal = Color3.fromRGB(255, 80, 80),
        Success = Color3.fromRGB(100, 255, 120)
    },
    Keys = { Menu = Enum.KeyCode.RightControl, Fly = Enum.KeyCode.E, Speed = Enum.KeyCode.F },
    Fly = { Enabled = false, Speed = 50 },
    Speed = { Enabled = false, Value = 16 },
    Farming = false,
    FarmSpeed = 120
}

--// 4. Library
local Library = {}
function Library:Tween(obj, props, time) TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine), props):Play() end
function Library:Corner(obj, r) local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c end
function Library:Stroke(obj, color, thick) local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Theme.Gold; s.Thickness = thick or 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; return s end
function Library:MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = obj.Position end end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    RunService.RenderStepped:Connect(function() if dragging and dragInput then local d = dragInput.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end; if dragging and UIS.UserInputState == Enum.UserInputState.End then dragging = false end end)
end

--// 5. UI Setup
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_Rel"; ScreenGui.Parent = CoreGui
local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 600, 0, 420); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = Settings.Theme.Dark; Library:Corner(MainFrame, 16); Library:Stroke(MainFrame, Settings.Theme.Gold, 1.5)
Library:MakeDraggable(MainFrame)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 160, 1, 0); Sidebar.BackgroundColor3 = Settings.Theme.Box; Library:Corner(Sidebar, 16)
local SideCover = Instance.new("Frame", Sidebar); SideCover.Size = UDim2.new(0,10,1,0); SideCover.Position=UDim2.new(1,-10,0,0); SideCover.BorderSizePixel=0; SideCover.BackgroundColor3=Settings.Theme.Box
local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding = UDim.new(0,10); SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidePad = Instance.new("UIPadding", Sidebar); SidePad.PaddingTop = UDim.new(0,20)

-- Container
local Container = Instance.new("Frame", MainFrame); Container.Size = UDim2.new(1, -170, 1, -20); Container.Position = UDim2.new(0, 170, 0, 10); Container.BackgroundTransparency = 1

-- Header
local Title = Instance.new("TextLabel", Sidebar); Title.Size = UDim2.new(1,0,0,40); Title.Text = "SPAGHETTI\n<font color='#FFD700' size='14'>MAFIA HUB v4</font>"; Title.RichText=true; Title.TextColor3=Color3.new(1,1,1); Title.Font=Enum.Font.GothamBlack; Title.TextSize=18; Title.BackgroundTransparency=1
local Div = Instance.new("Frame", Sidebar); Div.Size = UDim2.new(0.8,0,0,1); Div.BackgroundColor3=Color3.fromRGB(60,60,60); Div.BorderSizePixel=0

local currentTab = nil
local function CreateTab(name, heb, isWinter)
    local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(0.9,0,0,45); btn.BackgroundColor3 = Settings.Theme.Dark; btn.Text = name .. "\n<font size='11' color='#AAAAAA'>"..heb.."</font>"; btn.RichText = true; btn.TextColor3 = Color3.fromRGB(150,150,150); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; Library:Corner(btn, 8)
    if isWinter then Library:Stroke(btn, Settings.Theme.Ice, 1) end
    
    local page = Instance.new("Frame", Container); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false
    
    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then Library:Tween(v, {BackgroundColor3 = Settings.Theme.Dark, TextColor3 = Color3.fromRGB(150,150,150)}) end end
        for _,v in pairs(Container:GetChildren()) do v.Visible = false end
        Library:Tween(btn, {BackgroundColor3 = isWinter and Settings.Theme.DeepIce or Settings.Theme.Gold, TextColor3 = Color3.new(1,1,1)})
        page.Visible = true
    end)
    if not currentTab then currentTab = btn; Library:Tween(btn, {BackgroundColor3 = isWinter and Settings.Theme.DeepIce or Settings.Theme.Gold, TextColor3 = Color3.new(1,1,1)}); page.Visible = true end
    return page
end

local Tab_Event = CreateTab("❄️ Event", "אירוע חורף", true)
local Tab_Main = CreateTab("Main", "ראשי")
local Tab_Settings = CreateTab("Settings", "הגדרות")
local Tab_Credits = CreateTab("Credits", "קרדיטים")

--================================================================================
--// FARM LOGIC & DOOR BLOCK (THE FIX)
--================================================================================
local FarmBlacklist = {}
local FarmConnection = nil

local function GetTarget()
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

local function SecureLoop()
    if not Settings.Farming then return end
    local char = LocalPlayer.Character
    if char then
        -- 1. Noclip
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        -- 2. Anti-Sit
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.Sit = false; hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
        -- 3. Door Block (Fixed)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local region = Region3.new(hrp.Position - Vector3.new(25,25,25), hrp.Position + Vector3.new(25,25,25))
            local parts = workspace:FindPartsInRegion3(region, nil, 200)
            for _, p in pairs(parts) do
                local n = p.Name:lower()
                if n:find("door") or n:find("tele") or n:find("portal") or n:find("gate") or n:find("enter") then
                    p.CanTouch = false
                    if p:FindFirstChild("TouchInterest") then p.TouchInterest:Destroy() end
                end
            end
        end
    end
end

local function ToggleFarm(v)
    Settings.Farming = v
    if not v then FarmBlacklist = {} end
    
    if v then
        if not FarmConnection then FarmConnection = RunService.Stepped:Connect(SecureLoop) end
        task.spawn(function()
            while Settings.Farming do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local target = GetTarget()
                
                if char and hrp and target then
                    local dist = (hrp.Position - target.Position).Magnitude
                    local info = TweenInfo.new(dist / Settings.FarmSpeed, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, info, {CFrame = target.CFrame})
                    tween:Play()
                    
                    local start = tick()
                    while Settings.Farming and target.Parent and (tick() - start) < 2 do
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
    else
        if FarmConnection then FarmConnection:Disconnect(); FarmConnection = nil end
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end
            for _, p in pairs(LocalPlayer.Character:GetChildren()) do if p:IsA("BasePart") then p.CanTouch = true; p.CanCollide = true end end
        end
    end
end

--================================================================================
--// EVENT TAB DESIGN (WINTER THEME)
--================================================================================
local WinterGrad = Instance.new("UIGradient", Tab_Event)
WinterGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(10,15,30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20,30,50))}
WinterGrad.Rotation = 45

local EventLayout = Instance.new("UIListLayout", Tab_Event); EventLayout.Padding = UDim.new(0,10); EventLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 1. TOTAL BALANCE (TOP)
local BalFrame = Instance.new("Frame", Tab_Event); BalFrame.Size = UDim2.new(0.95,0,0,50); BalFrame.BackgroundTransparency=1
local BalGrid = Instance.new("UIGridLayout", BalFrame); BalGrid.CellSize = UDim2.new(0.48,0,1,0); BalGrid.CellPadding = UDim2.new(0.04,0,0,0)
local function CreateBal(name, col)
    local f = Instance.new("Frame", BalFrame); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 8); Library:Stroke(f, col, 1)
    local t = Instance.new("TextLabel", f); t.Size=UDim2.new(1,-10,0,20); t.Position=UDim2.new(0,10,0,5); t.Text=name; t.TextColor3=col; t.Font=Enum.Font.GothamBold; t.TextSize=12; t.TextXAlignment=Enum.TextXAlignment.Left; t.BackgroundTransparency=1
    local v = Instance.new("TextLabel", f); v.Size=UDim2.new(1,-10,0,25); v.Position=UDim2.new(0,10,0,20); v.Text="..."; v.TextColor3=Color3.new(1,1,1); v.Font=Enum.Font.Gotham; v.TextSize=16; v.TextXAlignment=Enum.TextXAlignment.Left; v.BackgroundTransparency=1
    return v
end
local TotalS = CreateBal("Total Shards", Settings.Theme.Shard)
local TotalC = CreateBal("Total Crystals", Settings.Theme.Crystal)

-- 2. TOGGLE
local ToggleFrame = Instance.new("Frame", Tab_Event); ToggleFrame.Size = UDim2.new(0.95,0,0,70); ToggleFrame.BackgroundColor3 = Settings.Theme.DeepIce; Library:Corner(ToggleFrame, 12); Library:Stroke(ToggleFrame, Settings.Theme.Ice, 1)
local TogTitle = Instance.new("TextLabel", ToggleFrame); TogTitle.Size=UDim2.new(0,200,1,0); TogTitle.Position=UDim2.new(0,20,0,0); TogTitle.Text="Winter Auto Farm ❄️"; TogTitle.TextColor3=Settings.Theme.Snow; TogTitle.Font=Enum.Font.GothamBlack; TogTitle.TextSize=20; TogTitle.TextXAlignment=Enum.TextXAlignment.Left; TogTitle.BackgroundTransparency=1
local TogBtn = Instance.new("TextButton", ToggleFrame); TogBtn.Size=UDim2.new(0,60,0,30); TogBtn.Position=UDim2.new(1,-80,0.5,-15); TogBtn.BackgroundColor3=Color3.fromRGB(40,50,70); TogBtn.Text=""; Library:Corner(TogBtn,15)
local TogCirc = Instance.new("Frame", TogBtn); TogCirc.Size=UDim2.new(0,24,0,24); TogCirc.Position=UDim2.new(0,3,0.5,-12); TogCirc.BackgroundColor3=Color3.fromRGB(150,160,180); Library:Corner(TogCirc,20)

local isFarming = false
TogBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        Library:Tween(TogBtn, {BackgroundColor3 = Settings.Theme.Ice}); Library:Tween(TogCirc, {Position=UDim2.new(1,-27,0.5,-12), BackgroundColor3=Color3.new(1,1,1)})
    else
        Library:Tween(TogBtn, {BackgroundColor3 = Color3.fromRGB(40,50,70)}); Library:Tween(TogCirc, {Position=UDim2.new(0,3,0.5,-12), BackgroundColor3=Color3.fromRGB(150,160,180)})
    end
    ToggleFarm(isFarming)
end)

-- 3. SESSION STATS (BIG BOXES)
local SessLabel = Instance.new("TextLabel", Tab_Event); SessLabel.Size=UDim2.new(0.95,0,0,20); SessLabel.Text="Session Collected (איסוף נוכחי) 📥"; SessLabel.TextColor3=Settings.Theme.Snow; SessLabel.Font=Enum.Font.GothamBold; SessLabel.TextSize=14; SessLabel.BackgroundTransparency=1
local SessFrame = Instance.new("Frame", Tab_Event); SessFrame.Size = UDim2.new(0.95,0,0,100); SessFrame.BackgroundTransparency=1
local SessGrid = Instance.new("UIGridLayout", SessFrame); SessGrid.CellSize = UDim2.new(0.48,0,1,0); SessGrid.CellPadding = UDim2.new(0.04,0,0,0)

local function CreateSess(name, col, icon)
    local f = Instance.new("Frame", SessFrame); f.BackgroundColor3 = Color3.fromRGB(20,25,35); Library:Corner(f,12); Library:Stroke(f, col, 1)
    local t = Instance.new("TextLabel", f); t.Size=UDim2.new(1,0,0,30); t.Position=UDim2.new(0,0,0.1,0); t.Text=name.." "..icon; t.TextColor3=col; t.Font=Enum.Font.GothamBold; t.TextSize=16; t.BackgroundTransparency=1
    local v = Instance.new("TextLabel", f); v.Size=UDim2.new(1,0,0,40); v.Position=UDim2.new(0,0,0.45,0); v.Text="0"; v.TextColor3=Color3.new(1,1,1); v.Font=Enum.Font.GothamBlack; v.TextSize=32; v.BackgroundTransparency=1
    return v
end
local SessS = CreateSess("Shards", Settings.Theme.Shard, "🧊")
local SessC = CreateSess("Crystals", Settings.Theme.Crystal, "💎")

-- 4. LAST STORM & TOTAL SESSION TEXT (RESTORED)
local InfoFrame = Instance.new("Frame", Tab_Event); InfoFrame.Size = UDim2.new(0.95,0,0,80); InfoFrame.BackgroundColor3=Settings.Theme.Box; Library:Corner(InfoFrame, 10); Library:Stroke(InfoFrame, Color3.fromRGB(60,60,80))
local InfoPad = Instance.new("UIPadding", InfoFrame); InfoPad.PaddingLeft=UDim.new(0,15); InfoPad.PaddingTop=UDim.new(0,10)
local InfoLayout = Instance.new("UIListLayout", InfoFrame); InfoLayout.Padding=UDim.new(0,5)

local TxtStorm = Instance.new("TextLabel", InfoFrame); TxtStorm.Size=UDim2.new(1,0,0,25); TxtStorm.Text="Last Storm: 0 🌩️"; TxtStorm.TextColor3=Settings.Theme.Ice; TxtStorm.Font=Enum.Font.Gotham; TxtStorm.TextSize=14; TxtStorm.TextXAlignment=Enum.TextXAlignment.Left; TxtStorm.BackgroundTransparency=1
local TxtTotSess = Instance.new("TextLabel", InfoFrame); TxtTotSess.Size=UDim2.new(1,0,0,25); TxtTotSess.Text="Session Total: 0 📦"; TxtTotSess.TextColor3=Settings.Theme.Gold; TxtTotSess.Font=Enum.Font.GothamBold; TxtTotSess.TextSize=14; TxtTotSess.TextXAlignment=Enum.TextXAlignment.Left; TxtTotSess.BackgroundTransparency=1

--// DATA LOGIC (DEEP SCAN + STORM CALC)
task.spawn(function()
    -- 1. Find Data (Deep Scan)
    local C_Obj, S_Obj
    local C_Names = {"Crystals", "Crystal", "Gem", "Gems", "Diamonds"}
    local S_Names = {"Shards", "Shard", "Ice", "Snow"}
    
    local attempts = 0
    while (not C_Obj or not S_Obj) and attempts < 30 do
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            for _,v in pairs(ls:GetChildren()) do if table.find(C_Names, v.Name) then C_Obj=v end; if table.find(S_Names, v.Name) then S_Obj=v end end
        end
        if not C_Obj or not S_Obj then
            for _,v in pairs(LocalPlayer:GetDescendants()) do 
                if v:IsA("IntValue") or v:IsA("NumberValue") then
                    if table.find(C_Names, v.Name) then C_Obj=v end
                    if table.find(S_Names, v.Name) then S_Obj=v end
                end
            end
        end
        task.wait(1)
        attempts = attempts + 1
    end
    
    if not C_Obj or not S_Obj then TotalC.Text="Error"; TotalS.Text="Error"; return end

    -- 2. Variables for Stats
    local InitialC = C_Obj.Value
    local InitialS = S_Obj.Value
    local LastC = C_Obj.Value
    local LastS = S_Obj.Value
    
    local StormC = 0
    local StormS = 0

    RunService.RenderStepped:Connect(function()
        local CurC = C_Obj.Value
        local CurS = S_Obj.Value
        
        -- Update Total
        TotalC.Text = tostring(CurC)
        TotalS.Text = tostring(CurS)
        
        -- Update Session
        local DiffC = CurC - InitialC
        local DiffS = CurS - InitialS
        if DiffC < 0 then DiffC = 0 end
        if DiffS < 0 then DiffS = 0 end
        SessC.Text = tostring(DiffC)
        SessS.Text = tostring(DiffS)
        
        -- Update Last Storm
        if CurC > LastC then StormC = StormC + (CurC - LastC) end
        if CurS > LastS then StormS = StormS + (CurS - LastS) end
        
        -- Reset storm count if values drop (spent money) or if storm ends (logic optional, here based on increase)
        -- For now, we keep storm count accumulating until manual reset or script reload, or we can reset if no gain for X seconds.
        -- Simple logic: Storm count is just recent gains.
        
        TxtStorm.Text = "Last Storm: " .. (StormC + StormS) .. " 🌩️"
        TxtTotSess.Text = "Session Total: " .. (DiffC + DiffS) .. " 📦"
        
        LastC = CurC
        LastS = CurS
    end)
end)

--================================================================================
--// RESTORED TABS (Main, Settings, Credits)
--================================================================================
local function AddLayout(p) local l = Instance.new("UIListLayout", p); l.Padding=UDim.new(0,10); l.HorizontalAlignment=Enum.HorizontalAlignment.Center; local pad = Instance.new("UIPadding", p); pad.PaddingTop=UDim.new(0,10) end
AddLayout(Tab_Main); AddLayout(Tab_Settings); AddLayout(Tab_Credits)

-- Main
local function CreateSlider(p, t, h, min, max, def, cb)
    local f = Instance.new("Frame", p); f.Size=UDim2.new(0.95,0,0,60); f.BackgroundColor3=Settings.Theme.Box; Library:Corner(f,8)
    local lbl = Instance.new("TextLabel", f); lbl.Size=UDim2.new(1,0,0,20); lbl.Position=UDim2.new(0,10,0,5); lbl.Text=t.." ("..h.."): "..def; lbl.TextColor3=Color3.new(1,1,1); lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.BackgroundTransparency=1
    local bar = Instance.new("Frame", f); bar.Size=UDim2.new(0.9,0,0,10); bar.Position=UDim2.new(0.05,0,0.6,0); bar.BackgroundColor3=Color3.fromRGB(50,50,50); Library:Corner(bar,5)
    local fill = Instance.new("Frame", bar); fill.Size=UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3=Settings.Theme.Gold; Library:Corner(fill,5)
    local btn = Instance.new("TextButton", f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    btn.MouseButton1Down:Connect(function()
        local move; move=UIS.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then
            local r = math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); fill.Size=UDim2.new(r,0,1,0); local v=math.floor(min+((max-min)*r)); lbl.Text=t.." ("..h.."): "..v; cb(v)
        end end); UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
    end)
end

CreateSlider(Tab_Main, "WalkSpeed", "מהירות", 16, 200, 16, function(v) Settings.Speed.Value=v end)
CreateSlider(Tab_Main, "FlySpeed", "תעופה", 20, 300, 50, function(v) Settings.Fly.Speed=v end)

-- Keybinds
local BindFrame = Instance.new("Frame", Tab_Main); BindFrame.Size=UDim2.new(0.95,0,0,50); BindFrame.BackgroundTransparency=1
local function Bind(id, txt, key, cb)
    local b = Instance.new("TextButton", BindFrame); b.Size=UDim2.new(0.48,0,1,0); b.Position=id==1 and UDim2.new(0,0,0,0) or UDim2.new(0.52,0,0,0); b.BackgroundColor3=Settings.Theme.Box; b.Text=txt..": "..key.Name; b.TextColor3=Color3.new(1,1,1); Library:Corner(b,8)
    b.MouseButton1Click:Connect(function() b.Text="Press key..."; local i=UIS.InputBegan:Wait(); if i.UserInputType==Enum.UserInputType.Keyboard then b.Text=txt..": "..i.KeyCode.Name; cb(i.KeyCode) end end)
end
Bind(1, "Fly", Settings.Keys.Fly, function(k) Settings.Keys.Fly=k end)
Bind(2, "Speed", Settings.Keys.Speed, function(k) Settings.Keys.Speed=k end)

-- Settings
CreateSlider(Tab_Settings, "FOV", "שדה ראייה", 70, 120, 70, function(v) Camera.FieldOfView=v end)

-- Credits (RESTORED FULLY)
local function AddCred(n, id)
    local f = Instance.new("Frame", Tab_Credits); f.Size=UDim2.new(0.95,0,0,70); f.BackgroundColor3=Settings.Theme.Box; Library:Corner(f,10)
    local img = Instance.new("ImageLabel", f); img.Size=UDim2.new(0,50,0,50); img.Position=UDim2.new(0,10,0.5,-25); img.Image="rbxthumb://type=AvatarHeadShot&id="..id.."&w=150&h=150"; Library:Corner(img,25)
    local t = Instance.new("TextLabel", f); t.Size=UDim2.new(0,150,0,20); t.Position=UDim2.new(0,70,0,15); t.Text=n; t.TextColor3=Settings.Theme.Gold; t.Font=Enum.Font.GothamBold; t.TextSize=16; t.TextXAlignment="Left"; t.BackgroundTransparency=1
    local copy = Instance.new("TextButton", f); copy.Size=UDim2.new(0,100,0,25); copy.Position=UDim2.new(0,70,0,40); copy.BackgroundColor3=Color3.fromRGB(88,101,242); copy.Text="Copy Discord"; copy.TextColor3=Color3.new(1,1,1); Library:Corner(copy,6)
    copy.MouseButton1Click:Connect(function() setclipboard(n); copy.Text="Copied!"; task.wait(1); copy.Text="Copy Discord" end)
end
AddCred("nx3ho", 1323665023)
AddCred("8adshot3", 3370067928)

--// 6. Logic (Fly, Speed, Menu)
local function FlyFunc(v)
    local c = LocalPlayer.Character; if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart"); local hum = c:FindFirstChild("Humanoid")
    if v then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name="FV"; bv.MaxForce=Vector3.new(1e9,1e9,1e9)
        local bg = Instance.new("BodyGyro", hrp); bg.Name="FG"; bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bg.P=9e4
        hum.PlatformStand=true
        task.spawn(function()
            while Settings.Fly.Enabled and c.Parent do
                local cam = workspace.CurrentCamera; local d = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
                bv.Velocity = d * Settings.Fly.Speed; bg.CFrame = cam.CFrame; RunService.Heartbeat:Wait()
            end
            if hrp:FindFirstChild("FV") then hrp.FV:Destroy() end; if hrp:FindFirstChild("FG") then hrp.FG:Destroy() end; hum.PlatformStand=false
        end)
    else
        if hrp:FindFirstChild("FV") then hrp.FV:Destroy() end; if hrp:FindFirstChild("FG") then hrp.FG:Destroy() end; hum.PlatformStand=false
    end
end

UIS.InputBegan:Connect(function(i,g)
    if not g then
        if i.KeyCode == Settings.Keys.Menu then MainFrame.Visible = not MainFrame.Visible end
        if i.KeyCode == Settings.Keys.Fly then Settings.Fly.Enabled = not Settings.Fly.Enabled; FlyFunc(Settings.Fly.Enabled) end
        if i.KeyCode == Settings.Keys.Speed then Settings.Speed.Enabled = not Settings.Speed.Enabled end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Speed.Enabled and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = Settings.Speed.Value end
    end
end)

print("[SYSTEM] Spaghetti Mafia Hub v4 - Winter Storm - Fully Loaded")
