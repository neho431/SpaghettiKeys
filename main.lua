--[[
    Spaghetti Mafia Hub v3.6 (EXACT REQUEST FIX)
    Updates:
    - Reverted to v3.5 layout.
    - Removed top subtitle.
    - Added "Fun World" title inside the Sidebar.
    - Fixed Line positioning (No floating).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// 1. מערכת Whitelist
local WHITELIST_URL = "https://github.com/neho431/SpaghettiKeys/blob/main/whitelist.txt"

local function CheckWhitelist()
    local success, content = pcall(function()
        return game:HttpGet(WHITELIST_URL .. "?t=" .. tick())
    end)
    
    if success and content then
        if string.find(content, LocalPlayer.Name) then
            print("[SYSTEM] Whitelist Confirmed.")
            return true
        else
            LocalPlayer:Kick("אין לך גישה לסקריפט!")
            return false
        end
    else
        LocalPlayer:Kick("שגיאת חיבור לשרת האימות")
        return false
    end
end

if not CheckWhitelist() then return end

--// 2. ניקוי ומשתנים
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then CoreGui.SpaghettiHub_Rel:Destroy() end

local Settings = {
    Theme = {
        Gold = Color3.fromRGB(255, 215, 0), 
        Dark = Color3.fromRGB(12, 12, 12),
        Box = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        IceBlue = Color3.fromRGB(100, 220, 255),
        IceDark = Color3.fromRGB(10, 25, 45),
        ShardBlue = Color3.fromRGB(50, 180, 255),
        CrystalRed = Color3.fromRGB(255, 70, 70),
        SnowWhite = Color3.fromRGB(240, 248, 255)
    },
    Keys = { Menu = Enum.KeyCode.RightControl, Fly = Enum.KeyCode.E, Speed = Enum.KeyCode.F },
    Fly = { Enabled = false, Speed = 50 },
    Speed = { Enabled = false, Value = 16 },
    Farming = false,
    FarmSpeed = 450,
    Scale = 1
}

local VisualToggles = {}
local FarmConnection = nil
local FarmBlacklist = {}

--// 3. פונקציות עזר
local Library = {}
function Library:Tween(obj, props, time, style) TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play() end
function Library:AddGlow(obj, color) local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Theme.Gold; s.Thickness = 1.2; s.Transparency = 0.5; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; return s end
function Library:Corner(obj, r) local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c end
function Library:Gradient(obj, c1, c2, rot) local g = Instance.new("UIGradient", obj); g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)}; g.Rotation = rot or 45; return g end
function Library:MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = obj.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    RunService.RenderStepped:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end

local function SpawnSnow(parent, speedMin, speedMax)
    local flake = Instance.new("Frame", parent)
    local size = math.random(2, 6)
    flake.Size = UDim2.new(0, size, 0, size)
    flake.Position = UDim2.new(math.random(5, 95)/100, 0, -0.1, 0)
    flake.BackgroundColor3 = Settings.Theme.SnowWhite
    flake.BackgroundTransparency = math.random(2, 6) / 10
    Library:Corner(flake, 10)
    local sway = math.random(-20, 20)
    TweenService:Create(flake, TweenInfo.new(math.random(speedMin, speedMax), Enum.EasingStyle.Linear), {
        Position = UDim2.new(flake.Position.X.Scale, sway, 1.1, 0),
        BackgroundTransparency = 1
    }):Play()
    Debris:AddItem(flake, speedMax + 1)
end

--// 4. GUI ראשי
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_Rel"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false

local MiniPasta = Instance.new("TextButton", ScreenGui); MiniPasta.Size = UDim2.new(0, 60, 0, 60); MiniPasta.Position = UDim2.new(0.1, 0, 0.1, 0); MiniPasta.BackgroundColor3 = Settings.Theme.Box; MiniPasta.Text = "🍝"; MiniPasta.TextSize = 35; MiniPasta.Visible = false; Library:Corner(MiniPasta, 30); Library:AddGlow(MiniPasta); Library:MakeDraggable(MiniPasta)

local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 620, 0, 420); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = Settings.Theme.Dark; MainFrame.ClipsDescendants = true; Library:Corner(MainFrame, 16); Library:AddGlow(MainFrame, Settings.Theme.Gold)
MainFrame.Size = UDim2.new(0,0,0,0); Library:Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 420)}, 0.6, Enum.EasingStyle.Elastic) 
Library:MakeDraggable(MainFrame)

local TopBar = Instance.new("Frame", MainFrame); TopBar.Size = UDim2.new(1,0,0,60); TopBar.BackgroundTransparency = 1

-- כותרת ראשית (ללא כותרת משנה)
local MainTitle = Instance.new("TextLabel", TopBar); MainTitle.Size = UDim2.new(0,300,0,30); MainTitle.Position = UDim2.new(0,20,0,15); MainTitle.BackgroundTransparency = 1; MainTitle.Text = "SPAGHETTI <font color='#FFD700'>MAFIA</font> HUB"; MainTitle.RichText = true; MainTitle.Font = Enum.Font.GothamBlack; MainTitle.TextSize = 22; MainTitle.TextColor3 = Color3.new(1,1,1); MainTitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar); CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -40, 0, 15); CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); CloseBtn.Text = "_"; CloseBtn.TextColor3 = Settings.Theme.Gold; CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.TextSize=18; Library:Corner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MiniPasta.Visible = true; Library:Tween(MiniPasta, {Size = UDim2.new(0, 60, 0, 60)}, 0.4, Enum.EasingStyle.Elastic) end)
MiniPasta.MouseButton1Click:Connect(function() MiniPasta.Visible = false; MainFrame.Visible = true; Library:Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 420)}, 0.4, Enum.EasingStyle.Back) end)

--// Sidebar ועיצוב הקו המתוקן
local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 160, 1, -60); Sidebar.Position = UDim2.new(0,0,0,60); Sidebar.BackgroundColor3 = Settings.Theme.Box; Sidebar.BorderSizePixel = 0; Sidebar.ZIndex = 2; Library:Corner(Sidebar, 12)

-- כותרת חורפית גדולה בתוך ה-SIDEBAR (במקום הקו המרחף)
local SideTitle = Instance.new("TextLabel", Sidebar)
SideTitle.Size = UDim2.new(1, 0, 0, 40)
SideTitle.Position = UDim2.new(0, 0, 0, 10)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "עולם הכיף ❄️"
SideTitle.Font = Enum.Font.GothamBlack
SideTitle.TextColor3 = Settings.Theme.IceBlue
SideTitle.TextSize = 19
SideTitle.ZIndex = 5

local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding = UDim.new(0,8); SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center; SideList.SortOrder = Enum.SortOrder.LayoutOrder
-- הוספתי ריווח מלמעלה (Padding) כדי שהכפתורים ירדו מתחת לכותרת החדשה
local SidePad = Instance.new("UIPadding", Sidebar); SidePad.PaddingTop = UDim.new(0, 60) 

-- הקו הזז (Active Line) - מוצמד לכפתור
local ActiveLine = Instance.new("Frame", Sidebar)
ActiveLine.Size = UDim2.new(0, 4, 0, 45) 
ActiveLine.Position = UDim2.new(0, 0, 0, 0) 
ActiveLine.BackgroundColor3 = Settings.Theme.Gold 
ActiveLine.BorderSizePixel = 0
ActiveLine.ZIndex = 5
ActiveLine.Visible = false 
Library:Corner(ActiveLine, 2)

local Container = Instance.new("Frame", MainFrame); Container.Size = UDim2.new(1, -170, 1, -70); Container.Position = UDim2.new(0, 170, 0, 65); Container.BackgroundTransparency = 1

local currentTab = nil

local function CreateTab(name, heb, order, isWinter)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9,0,0,45)
    btn.BackgroundColor3 = Settings.Theme.Dark
    btn.Text = "   " .. name .. "\n   <font size='12' color='#8899AA'>"..heb.."</font>"
    btn.RichText = true
    btn.TextColor3 = Color3.fromRGB(150,150,150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 3
    btn.LayoutOrder = order
    Library:Corner(btn, 8)
    
    local page = Instance.new("Frame", Container)
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Name = name .. "_Page"
    
    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Sidebar:GetChildren()) do 
            if v:IsA("TextButton") then 
                Library:Tween(v, {BackgroundColor3 = Settings.Theme.Dark, TextColor3 = Color3.fromRGB(150,150,150)}) 
            end 
        end
        for _,v in pairs(Container:GetChildren()) do v.Visible = false end
        
        local activeColor = isWinter and Settings.Theme.IceBlue or Settings.Theme.Gold
        local activeBG = isWinter and Settings.Theme.IceDark or Color3.fromRGB(30, 30, 30)
        
        Library:Tween(btn, {BackgroundColor3 = activeBG, TextColor3 = activeColor})
        page.Visible = true
        
        ActiveLine.Visible = true
        ActiveLine.BackgroundColor3 = activeColor
        -- חישוב מיקום מדויק יחסית ל-Padding החדש
        Library:Tween(ActiveLine, {Position = UDim2.new(0, 0, 0, btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y)}, 0.3, Enum.EasingStyle.Quint)
    end)
    
    if order == 1 then 
        currentTab = btn
        local activeColor = isWinter and Settings.Theme.IceBlue or Settings.Theme.Gold
        local activeBG = isWinter and Settings.Theme.IceDark or Color3.fromRGB(30, 30, 30)
        
        Library:Tween(btn, {BackgroundColor3 = activeBG, TextColor3 = activeColor})
        page.Visible = true 
        
        task.spawn(function()
            task.wait(0.1)
            ActiveLine.Visible = true
            ActiveLine.BackgroundColor3 = activeColor
            ActiveLine.Position = UDim2.new(0, 0, 0, btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y)
        end)
    end
    
    return page
end

local Tab_Event_Page = CreateTab("Winter Event", "אירוע חורף", 1, true)
local Tab_Main_Page = CreateTab("Main", "ראשי", 2, false)
local Tab_Settings_Page = CreateTab("Settings", "הגדרות", 3, false)
local Tab_Credits_Page = CreateTab("Credits", "קרדיטים", 4, false)

local function AddLayout(p) 
    local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0,12); l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pad = Instance.new("UIPadding", p); pad.PaddingTop = UDim.new(0,10) 
end
AddLayout(Tab_Main_Page); AddLayout(Tab_Settings_Page); AddLayout(Tab_Credits_Page)

--// 6. Auto Farm Logic (With Anti-Bug)
task.spawn(function() while true do task.wait(60); pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end end)

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
    local char = LocalPlayer.Character; if not char then return end
    for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local r = Region3.new(hrp.Position - Vector3.new(30,30,30), hrp.Position + Vector3.new(30,30,30))
        for _,v in pairs(workspace:FindPartsInRegion3(r, nil, 100)) do 
            if v.Name:lower():find("door") or v.Name:lower():find("portal") then v.CanTouch = false end 
        end
    end
end

local function ToggleFarm(v)
    Settings.Farming = v; if not v then FarmBlacklist = {} end
    if not FarmConnection and v then
        FarmConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character and Settings.Farming then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
                local hum = LocalPlayer.Character:FindFirstChild("Humanoid"); if hum then hum.Sit = false; hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
                UltraSafeDisable()
            end
        end)
    elseif not v and FarmConnection then FarmConnection:Disconnect(); FarmConnection = nil end

    if v then
        task.spawn(function()
            while Settings.Farming do
                local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local target = GetClosestTarget()
                if char and hrp and target then
                    local distance = (hrp.Position - target.Position).Magnitude
                    local tween = TweenService:Create(hrp, TweenInfo.new(distance / Settings.FarmSpeed, Enum.EasingStyle.Linear), {CFrame = target.CFrame}); tween:Play()
                    local start = tick()
                    
                    repeat task.wait() 
                        if not target.Parent or not Settings.Farming then tween:Cancel(); break end
                        -- Anti-Bug Logic
                        if (tick() - start) > 1.2 then 
                            tween:Cancel()
                            FarmBlacklist[target] = true
                            target.CFrame = CFrame.new(0,-500,0)
                            print("Skipped Bugged Crystal")
                            break 
                        end
                        if (hrp.Position - target.Position).Magnitude < 5 then target.CanTouch = true end
                    until (tick() - start) > 5
                else task.wait(0.2) end
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

--// 7. Event Tab - רקע כחול + שלג
local EventBackground = Instance.new("Frame", Tab_Event_Page)
EventBackground.Size = UDim2.new(1,0,1,0)
EventBackground.ZIndex = 0
Library:Gradient(EventBackground, Color3.fromRGB(10, 25, 45), Color3.fromRGB(5, 10, 20), 45)

local EventSnowContainer = Instance.new("Frame", Tab_Event_Page)
EventSnowContainer.Size = UDim2.new(1,0,1,0)
EventSnowContainer.BackgroundTransparency = 1
EventSnowContainer.ClipsDescendants = true
EventSnowContainer.ZIndex = 1

task.spawn(function()
    while Tab_Event_Page.Parent do
        SpawnSnow(EventSnowContainer, 5, 8) 
        task.wait(0.25)
    end
end)

local Tab_Farm_Scroll = Instance.new("ScrollingFrame", Tab_Event_Page)
Tab_Farm_Scroll.Size = UDim2.new(1, 0, 1, 0)
Tab_Farm_Scroll.BackgroundTransparency = 1
Tab_Farm_Scroll.ScrollBarThickness = 2
Tab_Farm_Scroll.ScrollBarImageColor3 = Settings.Theme.IceBlue
Tab_Farm_Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Tab_Farm_Scroll.BorderSizePixel = 0
Tab_Farm_Scroll.ZIndex = 5

local EventLayout = Instance.new("UIListLayout", Tab_Farm_Scroll)
EventLayout.Padding = UDim.new(0, 15)
EventLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
EventLayout.SortOrder = Enum.SortOrder.LayoutOrder 
local EventPad = Instance.new("UIPadding", Tab_Farm_Scroll); EventPad.PaddingTop = UDim.new(0,10)

-- 1. כפתור החווה
local FarmBtn = Instance.new("TextButton", Tab_Farm_Scroll)
FarmBtn.Size = UDim2.new(0.95, 0, 0, 70)
FarmBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 70)
FarmBtn.Text = ""
FarmBtn.LayoutOrder = 1
Library:Corner(FarmBtn, 12)
Library:AddGlow(FarmBtn, Settings.Theme.IceBlue)

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

local FarmSwitch = Instance.new("Frame", FarmBtn)
FarmSwitch.Size = UDim2.new(0, 45, 0, 26)
FarmSwitch.Position = UDim2.new(1, -65, 0.5, -13)
FarmSwitch.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Library:Corner(FarmSwitch, 20)
local FarmDot = Instance.new("Frame", FarmSwitch)
FarmDot.Size = UDim2.new(0, 22, 0, 22)
FarmDot.Position = UDim2.new(0, 2, 0.5, -11)
FarmDot.BackgroundColor3 = Color3.fromRGB(180, 200, 220)
Library:Corner(FarmDot, 20)

local isFarming = false
FarmBtn.MouseButton1Click:Connect(function() 
    isFarming = not isFarming; ToggleFarm(isFarming)
    if isFarming then 
        Library:Tween(FarmSwitch,{BackgroundColor3=Settings.Theme.IceBlue})
        Library:Tween(FarmDot,{Position=UDim2.new(1,-24,0.5,-11)}) 
    else 
        Library:Tween(FarmSwitch,{BackgroundColor3=Color3.fromRGB(40,40,60)}) 
        Library:Tween(FarmDot,{Position=UDim2.new(0,2,0.5,-11)}) 
    end 
end)

-- 2. Balance GUI
local BalanceLabel = Instance.new("TextLabel", Tab_Farm_Scroll)
BalanceLabel.Size = UDim2.new(0.95,0,0,25)
BalanceLabel.Text = "Total Balance (סה''כ בתיק) 💰"
BalanceLabel.TextColor3 = Settings.Theme.Gold
BalanceLabel.Font=Enum.Font.GothamBlack
BalanceLabel.TextSize=14
BalanceLabel.BackgroundTransparency=1
BalanceLabel.LayoutOrder = 2

local BalanceContainer = Instance.new("Frame", Tab_Farm_Scroll)
BalanceContainer.Size = UDim2.new(0.95, 0, 0, 70)
BalanceContainer.BackgroundTransparency = 1
BalanceContainer.LayoutOrder = 3
local BalanceGrid = Instance.new("UIGridLayout", BalanceContainer)
BalanceGrid.CellSize = UDim2.new(0.48, 0, 1, 0)
BalanceGrid.CellPadding = UDim2.new(0.04, 0, 0, 0)
BalanceGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TotBlues = Instance.new("Frame", BalanceContainer); TotBlues.BackgroundColor3 = Color3.fromRGB(15, 30, 50); Library:Corner(TotBlues, 12); local StrokeTotalB = Instance.new("UIStroke", TotBlues); StrokeTotalB.Color = Settings.Theme.ShardBlue; StrokeTotalB.Thickness = 1.2; StrokeTotalB.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local T_TitleB = Instance.new("TextLabel", TotBlues); T_TitleB.Size = UDim2.new(1,0,0.3,0); T_TitleB.Position=UDim2.new(0,0,0.15,0); T_TitleB.BackgroundTransparency=1; T_TitleB.Text="כחולים 🧊"; T_TitleB.TextColor3=Settings.Theme.ShardBlue; T_TitleB.Font=Enum.Font.GothamBold; T_TitleB.TextSize=14
local T_ValB = Instance.new("TextLabel", TotBlues); T_ValB.Size = UDim2.new(1,0,0.5,0); T_ValB.Position=UDim2.new(0,0,0.45,0); T_ValB.BackgroundTransparency=1; T_ValB.Text="..."; T_ValB.TextColor3=Color3.new(1,1,1); T_ValB.Font=Enum.Font.GothamBlack; T_ValB.TextSize=22

local TotReds = Instance.new("Frame", BalanceContainer); TotReds.BackgroundColor3 = Color3.fromRGB(30, 15, 15); Library:Corner(TotReds, 12); local StrokeTotalR = Instance.new("UIStroke", TotReds); StrokeTotalR.Color = Settings.Theme.CrystalRed; StrokeTotalR.Thickness = 1.2; StrokeTotalR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local T_TitleR = Instance.new("TextLabel", TotReds); T_TitleR.Size = UDim2.new(1,0,0.3,0); T_TitleR.Position=UDim2.new(0,0,0.15,0); T_TitleR.BackgroundTransparency=1; T_TitleR.Text="אדומים 💎"; T_TitleR.TextColor3=Settings.Theme.CrystalRed; T_TitleR.Font=Enum.Font.GothamBold; T_TitleR.TextSize=14
local T_ValR = Instance.new("TextLabel", TotReds); T_ValR.Size = UDim2.new(1,0,0.5,0); T_ValR.Position=UDim2.new(0,0,0.45,0); T_ValR.BackgroundTransparency=1; T_ValR.Text="..."; T_ValR.TextColor3=Color3.new(1,1,1); T_ValR.Font=Enum.Font.GothamBlack; T_ValR.TextSize=22

-- 3. Session Stats
local StatsLabel = Instance.new("TextLabel", Tab_Farm_Scroll)
StatsLabel.Size = UDim2.new(0.95,0,0,20)
StatsLabel.Text = "Collected in Storm (נאספו בסופה) 📥"
StatsLabel.TextColor3 = Color3.fromRGB(200,230,255)
StatsLabel.Font=Enum.Font.GothamBold
StatsLabel.TextSize=12
StatsLabel.BackgroundTransparency=1
StatsLabel.LayoutOrder = 4

local StatsContainer = Instance.new("Frame", Tab_Farm_Scroll)
StatsContainer.Size = UDim2.new(0.95, 0, 0, 70)
StatsContainer.BackgroundTransparency = 1
StatsContainer.LayoutOrder = 5
local StatsGrid = Instance.new("UIGridLayout", StatsContainer)
StatsGrid.CellSize = UDim2.new(0.48, 0, 1, 0)
StatsGrid.CellPadding = UDim2.new(0.04, 0, 0, 0)
StatsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local BoxBlue = Instance.new("Frame", StatsContainer); BoxBlue.BackgroundColor3 = Color3.fromRGB(15, 30, 50); Library:Corner(BoxBlue, 12); local StrokeBlue = Instance.new("UIStroke", BoxBlue); StrokeBlue.Color = Settings.Theme.IceBlue; StrokeBlue.Thickness = 1.2
local TitleBlue = Instance.new("TextLabel", BoxBlue); TitleBlue.Size = UDim2.new(1, 0, 0.3, 0); TitleBlue.Position = UDim2.new(0,0,0.15,0); TitleBlue.BackgroundTransparency = 1; TitleBlue.Text = "כחולים (Session)"; TitleBlue.TextColor3 = Settings.Theme.IceBlue; TitleBlue.Font = Enum.Font.GothamBold; TitleBlue.TextSize = 13
local ValBlue = Instance.new("TextLabel", BoxBlue); ValBlue.Size = UDim2.new(1, 0, 0.5, 0); ValBlue.Position = UDim2.new(0,0,0.45,0); ValBlue.BackgroundTransparency = 1; ValBlue.Text = "0"; ValBlue.TextColor3 = Color3.new(1, 1, 1); ValBlue.Font = Enum.Font.GothamBlack; ValBlue.TextSize = 22

local BoxRed = Instance.new("Frame", StatsContainer); BoxRed.BackgroundColor3 = Color3.fromRGB(30, 15, 15); Library:Corner(BoxRed, 12); local StrokeRed = Instance.new("UIStroke", BoxRed); StrokeRed.Color = Settings.Theme.CrystalRed; StrokeRed.Thickness = 1.2
local TitleRed = Instance.new("TextLabel", BoxRed); TitleRed.Size = UDim2.new(1, 0, 0.3, 0); TitleRed.Position = UDim2.new(0,0,0.15,0); TitleRed.BackgroundTransparency = 1; TitleRed.Text = "אדומים (Session)"; TitleRed.TextColor3 = Settings.Theme.CrystalRed; TitleRed.Font = Enum.Font.GothamBold; TitleRed.TextSize = 13
local ValRed = Instance.new("TextLabel", BoxRed); ValRed.Size = UDim2.new(1, 0, 0.5, 0); ValRed.Position = UDim2.new(0,0,0.45,0); ValRed.BackgroundTransparency = 1; ValRed.Text = "0"; ValRed.TextColor3 = Color3.new(1, 1, 1); ValRed.Font = Enum.Font.GothamBlack; ValRed.TextSize = 22

-- 4. AFK Status
local AFKStatus = Instance.new("TextLabel", Tab_Farm_Scroll)
AFKStatus.Size = UDim2.new(0.95, 0, 0, 20)
AFKStatus.BackgroundTransparency = 1
AFKStatus.Text = "Anti-AFK: <font color='#00FF00'>Active (Jumper)</font> ⚡"
AFKStatus.RichText = true
AFKStatus.TextColor3 = Color3.new(1, 1, 1)
AFKStatus.Font = Enum.Font.GothamMedium
AFKStatus.TextSize = 12
AFKStatus.LayoutOrder = 6

task.spawn(function()
    local CrystalsRef = LocalPlayer:WaitForChild("Crystals", 10)
    local ShardsRef = LocalPlayer:WaitForChild("Shards", 10)
    if not CrystalsRef or not ShardsRef then return end
    local InitC = CrystalsRef.Value; local InitS = ShardsRef.Value
    while true do
        task.wait(0.5)
        pcall(function()
            local CurC = CrystalsRef.Value; local CurS = ShardsRef.Value
            local SesC = CurC - InitC; local SesS = CurS - InitS
            if SesC < 0 then SesC = 0 end; if SesS < 0 then SesS = 0 end
            ValRed.Text = "+"..tostring(SesC); ValBlue.Text = "+"..tostring(SesS)
            T_ValR.Text = tostring(CurC); T_ValB.Text = tostring(CurS)
        end)
    end
end)

--// 8. רכיבים וטאבים אחרים
local function CreateSlider(parent, title, heb, min, max, default, callback, toggleCallback, toggleName)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95,0,0,75); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.7,0,0,25); l.Position = UDim2.new(0,10,0,8); l.Text = title .. " ("..heb..") : " .. default; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.BackgroundTransparency=1
    local line = Instance.new("Frame", f); line.Size = UDim2.new(0.9,0,0,12); line.Position = UDim2.new(0.05,0,0.65,0); line.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(line,6)
    local fill = Instance.new("Frame", line); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Settings.Theme.Gold; Library:Corner(fill,6)
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.MouseButton1Down:Connect(function() local move = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then local r = math.clamp((i.Position.X - line.AbsolutePosition.X)/line.AbsoluteSize.X,0,1); fill.Size = UDim2.new(r,0,1,0); local v = math.floor(min+((max-min)*r)); l.Text = title.." ("..heb..") : "..v; callback(v) end end); UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then move:Disconnect() end end) end)
    if toggleCallback then
        local t = Instance.new("TextButton", f); t.Size = UDim2.new(0,60,0,25); t.Position = UDim2.new(1,-70,0,8); t.BackgroundColor3 = Color3.fromRGB(40,40,40); t.Text = "OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.GothamBold; Library:Corner(t,4)
        local on = false; local function Update(s) on=s; t.Text=on and "ON" or "OFF"; t.BackgroundColor3=on and Settings.Theme.Gold or Color3.fromRGB(40,40,40); t.TextColor3=on and Color3.new(0,0,0) or Color3.new(1,1,1); toggleCallback(on) end
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

CreateSlider(Tab_Main_Page, "Walk Speed", "מהירות הליכה", 16, 250, 16, function(v) Settings.Speed.Value = v end, function(t) Settings.Speed.Enabled = t end, "Speed")
CreateSlider(Tab_Main_Page, "Fly Speed", "מהירות תעופה", 20, 300, 50, function(v) Settings.Fly.Speed = v end, function(t) ToggleFly(t) end, "Fly")
local BindCont = Instance.new("Frame", Tab_Main_Page); BindCont.Size = UDim2.new(0.95,0,0,80); BindCont.BackgroundTransparency = 1; CreateSquareBind(BindCont, 1, "FLY", "תעופה", Settings.Keys.Fly, function(k) Settings.Keys.Fly = k end); CreateSquareBind(BindCont, 2, "SPEED", "מהירות", Settings.Keys.Speed, function(k) Settings.Keys.Speed = k end)

CreateSlider(Tab_Settings_Page, "FOV", "שדה ראייה", 70, 120, 70, function(v) Camera.FieldOfView = v end); CreateSlider(Tab_Settings_Page, "GUI Scale", "גודל ממשק", 0.5, 1.5, 1, function(v) MainScale.Scale = v end)
local MenuBindCont = Instance.new("Frame", Tab_Settings_Page); MenuBindCont.Size = UDim2.new(0.95,0,0,70); MenuBindCont.BackgroundTransparency = 1; CreateSquareBind(MenuBindCont, 3, "MENU KEY", "מקש תפריט", Settings.Keys.Menu, function(k) Settings.Keys.Menu = k end)

local function AddCr(n, id)
    local f = Instance.new("Frame", Tab_Credits_Page); f.Size = UDim2.new(0.95,0,0,100); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 12); Library:AddGlow(f)
    local i = Instance.new("ImageLabel", f)
    i.Size = UDim2.new(0,80,0,80); i.Position = UDim2.new(0,10,0.5,-40); 
    i.Image = "rbxthumb://type=AvatarHeadShot&id="..id.."&w=150&h=150"
    Library:Corner(i, 40)
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(0,350,0,30); t.Position = UDim2.new(0,100,0,20); t.Text = n .. " <font color='#AAAAAA'>(יוצרים)</font>"; t.RichText=true; t.TextColor3 = Settings.Theme.Gold; t.Font=Enum.Font.GothamBlack; t.TextSize=22; t.TextXAlignment="Left"; t.BackgroundTransparency=1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0,140,0,30); b.Position = UDim2.new(0,100,0,55); b.BackgroundColor3 = Color3.fromRGB(88,101,242); b.Text="Copy Discord"; b.TextColor3=Color3.new(1,1,1); Library:Corner(b,6); b.TextSize=13; b.MouseButton1Click:Connect(function() setclipboard(n); b.Text="Copied!"; task.wait(1); b.Text="Copy Discord" end)
end
AddCr("nx3ho", 1323665023); AddCr("8adshot3", 3370067928)

--// 9. ניהול מקשים
UIS.InputBegan:Connect(function(i,g)
    if not g then
        if i.KeyCode == Settings.Keys.Menu then if MainFrame.Visible then Library:Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back); task.wait(0.3); MainFrame.Visible = false else MainFrame.Visible = true; MainFrame.Size = UDim2.new(0,0,0,0); Library:Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 420)}, 0.5, Enum.EasingStyle.Elastic) end end
        if i.KeyCode == Settings.Keys.Fly then Settings.Fly.Enabled = not Settings.Fly.Enabled; ToggleFly(Settings.Fly.Enabled); if VisualToggles["Fly"] then VisualToggles["Fly"](Settings.Fly.Enabled) end end
        if i.KeyCode == Settings.Keys.Speed then Settings.Speed.Enabled = not Settings.Speed.Enabled; if VisualToggles["Speed"] then VisualToggles["Speed"](Settings.Speed.Enabled) end end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Speed.Enabled and LocalPlayer.Character then local h = LocalPlayer.Character:FindFirstChild("Humanoid"); if h then h.WalkSpeed = Settings.Speed.Value end end
end)

print("[SYSTEM] Spaghetti Mafia Hub v3.6 Loaded")
