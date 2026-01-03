--[[
    Spaghetti Mafia Hub v4.0 (FIXED & POLISHED)
    - Loading Screen: RESTORED 🍝
    - Speed: Resets to 16 immediately when toggled off.
    - Sidebar: Gap removed, Line fixed perfectly next to buttons.
    - Auto Farm: Bugged crystal skip time reduced to 0.8s.
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

--// 1. בדיקת Whitelist
local WHITELIST_URL = "https://github.com/neho431/SpaghettiKeys/blob/main/whitelist.txt"

local function CheckWhitelist()
    local success, content = pcall(function()
        return game:HttpGet(WHITELIST_URL .. "?t=" .. tick())
    end)
    if success and content and string.find(content, LocalPlayer.Name) then
        print("[SYSTEM] Whitelist Confirmed.")
        return true
    else
        LocalPlayer:Kick("אין לך גישה לסקריפט!")
        return false
    end
end
if not CheckWhitelist() then return end

--// 2. ניקוי ומשתנים
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then CoreGui.SpaghettiHub_Rel:Destroy() end
if CoreGui:FindFirstChild("SpaghettiLoading") then CoreGui.SpaghettiLoading:Destroy() end

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

--// 3. ספריית עיצוב
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
    TweenService:Create(flake, TweenInfo.new(math.random(speedMin, speedMax), Enum.EasingStyle.Linear), {
        Position = UDim2.new(flake.Position.X.Scale, math.random(-20, 20), 1.1, 0),
        BackgroundTransparency = 1
    }):Play()
    Debris:AddItem(flake, speedMax + 1)
end

--// 4. מסך טעינה (הוחזר!)
local LoadGui = Instance.new("ScreenGui"); LoadGui.Name = "SpaghettiLoading"; LoadGui.Parent = CoreGui
local LoadBox = Instance.new("Frame", LoadGui)
LoadBox.Size = UDim2.new(0, 240, 0, 170); LoadBox.Position = UDim2.new(0.5, 0, 0.5, 0); LoadBox.AnchorPoint = Vector2.new(0.5, 0.5); LoadBox.ClipsDescendants = true; LoadBox.BorderSizePixel = 0
Library:Corner(LoadBox, 16); Library:Gradient(LoadBox, Color3.fromRGB(15, 20, 30), Color3.fromRGB(25, 40, 60), 45); Library:AddGlow(LoadBox, Settings.Theme.Gold)

local SnowPile = Instance.new("Frame", LoadBox); SnowPile.Size = UDim2.new(1.2, 0, 0.15, 0); SnowPile.Position = UDim2.new(-0.1, 0, 0.9, 0); SnowPile.BackgroundColor3 = Color3.new(1,1,1); Library:Corner(SnowPile, 20); SnowPile.ZIndex = 3
local PastaIcon = Instance.new("TextLabel", LoadBox); PastaIcon.Size = UDim2.new(1, 0, 0.5, 0); PastaIcon.Position = UDim2.new(0,0,0.1,0); PastaIcon.BackgroundTransparency = 1; PastaIcon.Text = "🍝"; PastaIcon.TextSize = 60; PastaIcon.ZIndex = 5
local TitleLoad = Instance.new("TextLabel", LoadBox); TitleLoad.Size = UDim2.new(1, 0, 0.2, 0); TitleLoad.Position = UDim2.new(0, 0, 0.55, 0); TitleLoad.BackgroundTransparency = 1; TitleLoad.Text = "ספגטי מאפיה"; TitleLoad.Font = Enum.Font.GothamBlack; TitleLoad.TextColor3 = Settings.Theme.Gold; TitleLoad.TextSize = 20; TitleLoad.ZIndex = 5
local SubLoad = Instance.new("TextLabel", LoadBox); SubLoad.Size = UDim2.new(1, 0, 0.2, 0); SubLoad.Position = UDim2.new(0, 0, 0.7, 0); SubLoad.BackgroundTransparency = 1; SubLoad.Text = "טוען נתונים..."; SubLoad.Font = Enum.Font.Gotham; SubLoad.TextColor3 = Color3.new(1,1,1); SubLoad.TextSize = 14; SubLoad.ZIndex = 5

task.spawn(function() while LoadBox.Parent do SpawnSnow(LoadBox, 2, 4); task.wait(0.1) end end)
task.wait(2.5)
LoadGui:Destroy()

--// 5. GUI ראשי
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_Rel"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false

local MiniPasta = Instance.new("TextButton", ScreenGui); MiniPasta.Size = UDim2.new(0, 60, 0, 60); MiniPasta.Position = UDim2.new(0.1, 0, 0.1, 0); MiniPasta.BackgroundColor3 = Settings.Theme.Box; MiniPasta.Text = "🍝"; MiniPasta.TextSize = 35; MiniPasta.Visible = false; Library:Corner(MiniPasta, 30); Library:AddGlow(MiniPasta); Library:MakeDraggable(MiniPasta)

local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 620, 0, 420); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = Settings.Theme.Dark; MainFrame.ClipsDescendants = true; Library:Corner(MainFrame, 16); Library:AddGlow(MainFrame, Settings.Theme.Gold)
MainFrame.Size = UDim2.new(0,0,0,0); Library:Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 420)}, 0.6, Enum.EasingStyle.Elastic) 
Library:MakeDraggable(MainFrame)

local TopBar = Instance.new("Frame", MainFrame); TopBar.Size = UDim2.new(1,0,0,60); TopBar.BackgroundTransparency = 1
local MainTitle = Instance.new("TextLabel", TopBar); MainTitle.Size = UDim2.new(0,300,0,30); MainTitle.Position = UDim2.new(0,20,0,15); MainTitle.BackgroundTransparency = 1; MainTitle.Text = "SPAGHETTI <font color='#FFD700'>MAFIA</font> HUB"; MainTitle.RichText = true; MainTitle.Font = Enum.Font.GothamBlack; MainTitle.TextSize = 22; MainTitle.TextColor3 = Color3.new(1,1,1); MainTitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar); CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -40, 0, 15); CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); CloseBtn.Text = "_"; CloseBtn.TextColor3 = Settings.Theme.Gold; CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.TextSize=18; Library:Corner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MiniPasta.Visible = true; Library:Tween(MiniPasta, {Size = UDim2.new(0, 60, 0, 60)}, 0.4, Enum.EasingStyle.Elastic) end)
MiniPasta.MouseButton1Click:Connect(function() MiniPasta.Visible = false; MainFrame.Visible = true; Library:Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 420)}, 0.4, Enum.EasingStyle.Back) end)

--// Sidebar מתוקן (ללא רווחים מיותרים)
local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 160, 1, -60); Sidebar.Position = UDim2.new(0,0,0,60); Sidebar.BackgroundColor3 = Settings.Theme.Box; Sidebar.BorderSizePixel = 0; Sidebar.ZIndex = 2; Library:Corner(Sidebar, 12)

-- כותרת בתוך ה-Sidebar למעלה
local SideTitle = Instance.new("TextLabel", Sidebar)
SideTitle.Size = UDim2.new(1, 0, 0, 35) -- גובה מצומצם
SideTitle.Position = UDim2.new(0, 0, 0, 5) -- קצת למטה מהקצה
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "עולם הכיף ❄️"
SideTitle.Font = Enum.Font.GothamBlack
SideTitle.TextColor3 = Settings.Theme.IceBlue
SideTitle.TextSize = 18
SideTitle.ZIndex = 5

-- מיכל לכפתורים (מתחיל מתחת לכותרת)
local ButtonContainer = Instance.new("Frame", Sidebar)
ButtonContainer.Size = UDim2.new(1, 0, 1, -45) -- כל הגובה פחות הכותרת
ButtonContainer.Position = UDim2.new(0, 0, 0, 45) -- מתחיל מתחת לכותרת
ButtonContainer.BackgroundTransparency = 1

local SideList = Instance.new("UIListLayout", ButtonContainer); SideList.Padding = UDim.new(0,8); SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center; SideList.SortOrder = Enum.SortOrder.LayoutOrder

-- הקו הזז (Active Line) - מוצמד ל-Sidebar
local ActiveLine = Instance.new("Frame", Sidebar)
ActiveLine.Size = UDim2.new(0, 4, 0, 45) 
ActiveLine.BackgroundColor3 = Settings.Theme.Gold 
ActiveLine.BorderSizePixel = 0
ActiveLine.ZIndex = 6 -- מעל הכל
ActiveLine.Visible = false 
Library:Corner(ActiveLine, 2)

local Container = Instance.new("Frame", MainFrame); Container.Size = UDim2.new(1, -170, 1, -70); Container.Position = UDim2.new(0, 170, 0, 65); Container.BackgroundTransparency = 1

local function CreateTab(name, heb, order, isWinter)
    local btn = Instance.new("TextButton", ButtonContainer) -- כפתור בתוך המיכל
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
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false; page.Name = name .. "_Page"
    
    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(ButtonContainer:GetChildren()) do if v:IsA("TextButton") then Library:Tween(v, {BackgroundColor3 = Settings.Theme.Dark, TextColor3 = Color3.fromRGB(150,150,150)}) end end
        for _,v in pairs(Container:GetChildren()) do v.Visible = false end
        
        local activeColor = isWinter and Settings.Theme.IceBlue or Settings.Theme.Gold
        local activeBG = isWinter and Settings.Theme.IceDark or Color3.fromRGB(30, 30, 30)
        
        Library:Tween(btn, {BackgroundColor3 = activeBG, TextColor3 = activeColor})
        page.Visible = true
        
        ActiveLine.Visible = true
        ActiveLine.BackgroundColor3 = activeColor
        -- חישוב מיקום: מיקום הכפתור בתוך המיכל + המיקום של המיכל
        local targetY = btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y
        Library:Tween(ActiveLine, {Position = UDim2.new(0, 0, 0, targetY)}, 0.3, Enum.EasingStyle.Quint)
    end)
    
    if order == 1 then 
        local activeColor = isWinter and Settings.Theme.IceBlue or Settings.Theme.Gold
        local activeBG = isWinter and Settings.Theme.IceDark or Color3.fromRGB(30, 30, 30)
        Library:Tween(btn, {BackgroundColor3 = activeBG, TextColor3 = activeColor})
        page.Visible = true 
        task.spawn(function()
            task.wait(0.1)
            ActiveLine.Visible = true; ActiveLine.BackgroundColor3 = activeColor
            ActiveLine.Position = UDim2.new(0, 0, 0, btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y)
        end)
    end
    return page
end

local Tab_Event = CreateTab("Winter Event", "אירוע חורף", 1, true)
local Tab_Main = CreateTab("Main", "ראשי", 2, false)
local Tab_Settings = CreateTab("Settings", "הגדרות", 3, false)
local Tab_Credits = CreateTab("Credits", "קרדיטים", 4, false)

local function AddLayout(p) local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0,12); l.HorizontalAlignment = Enum.HorizontalAlignment.Center; local pad = Instance.new("UIPadding", p); pad.PaddingTop = UDim.new(0,10) end
AddLayout(Tab_Main); AddLayout(Tab_Settings); AddLayout(Tab_Credits)

--// 6. Auto Farm Logic (Faster Skip)
task.spawn(function() while true do task.wait(60); pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end end)

local function GetClosestTarget()
    local drops = Workspace:FindFirstChild("StormDrops"); if not drops then return nil end
    local closest, dist = nil, math.huge; local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then for _, v in pairs(drops:GetChildren()) do if v:IsA("BasePart") and not FarmBlacklist[v] then local mag = (hrp.Position - v.Position).Magnitude; if mag < dist then dist = mag; closest = v end end end end
    return closest
end

local function UltraSafeDisable()
    local char = LocalPlayer.Character; if not char then return end
    for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local r = Region3.new(hrp.Position - Vector3.new(30,30,30), hrp.Position + Vector3.new(30,30,30))
        for _,v in pairs(workspace:FindPartsInRegion3(r, nil, 100)) do if v.Name:lower():find("door") or v.Name:lower():find("portal") then v.CanTouch = false end end
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
                        -- שיניתי ל-0.8 שניות כדי שזה יהיה סופר מהיר
                        if (tick() - start) > 0.8 then 
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

--// 7. Event Tab
local EventBackground = Instance.new("Frame", Tab_Event); EventBackground.Size = UDim2.new(1,0,1,0); EventBackground.ZIndex = 0; Library:Gradient(EventBackground, Color3.fromRGB(10, 25, 45), Color3.fromRGB(5, 10, 20), 45)
local EventSnow = Instance.new("Frame", Tab_Event); EventSnow.Size = UDim2.new(1,0,1,0); EventSnow.BackgroundTransparency = 1; EventSnow.ClipsDescendants = true; EventSnow.ZIndex = 1
task.spawn(function() while Tab_Event.Parent do SpawnSnow(EventSnow, 5, 8); task.wait(0.25) end end)

local Tab_Farm_Scroll = Instance.new("ScrollingFrame", Tab_Event); Tab_Farm_Scroll.Size = UDim2.new(1, 0, 1, 0); Tab_Farm_Scroll.BackgroundTransparency = 1; Tab_Farm_Scroll.ScrollBarThickness = 2; Tab_Farm_Scroll.ScrollBarImageColor3 = Settings.Theme.IceBlue; Tab_Farm_Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Tab_Farm_Scroll.BorderSizePixel = 0; Tab_Farm_Scroll.ZIndex = 5
local EventLayout = Instance.new("UIListLayout", Tab_Farm_Scroll); EventLayout.Padding = UDim.new(0, 15); EventLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; EventLayout.SortOrder = Enum.SortOrder.LayoutOrder; local EventPad = Instance.new("UIPadding", Tab_Farm_Scroll); EventPad.PaddingTop = UDim.new(0,10)

-- Farm Button
local FarmBtn = Instance.new("TextButton", Tab_Farm_Scroll); FarmBtn.Size = UDim2.new(0.95, 0, 0, 70); FarmBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 70); FarmBtn.Text = ""; FarmBtn.LayoutOrder = 1; Library:Corner(FarmBtn, 12); Library:AddGlow(FarmBtn, Settings.Theme.IceBlue)
local FarmTitle = Instance.new("TextLabel", FarmBtn); FarmTitle.Size = UDim2.new(1, -60, 1, 0); FarmTitle.Position = UDim2.new(0, 20, 0, 0); FarmTitle.Text = "Toggle Auto Farm ❄️\n<font size='13' color='#87CEFA'>הפעלת חווה אוטומטית</font>"; FarmTitle.RichText = true; FarmTitle.TextColor3 = Color3.new(1,1,1); FarmTitle.Font = Enum.Font.GothamBlack; FarmTitle.TextSize = 18; FarmTitle.TextXAlignment = Enum.TextXAlignment.Left; FarmTitle.BackgroundTransparency = 1
local FarmSwitch = Instance.new("Frame", FarmBtn); FarmSwitch.Size = UDim2.new(0, 45, 0, 26); FarmSwitch.Position = UDim2.new(1, -65, 0.5, -13); FarmSwitch.BackgroundColor3 = Color3.fromRGB(40, 40, 60); Library:Corner(FarmSwitch, 20)
local FarmDot = Instance.new("Frame", FarmSwitch); FarmDot.Size = UDim2.new(0, 22, 0, 22); FarmDot.Position = UDim2.new(0, 2, 0.5, -11); FarmDot.BackgroundColor3 = Color3.fromRGB(180, 200, 220); Library:Corner(FarmDot, 20)
local isFarming = false
FarmBtn.MouseButton1Click:Connect(function() isFarming = not isFarming; ToggleFarm(isFarming); if isFarming then Library:Tween(FarmSwitch,{BackgroundColor3=Settings.Theme.IceBlue}); Library:Tween(FarmDot,{Position=UDim2.new(1,-24,0.5,-11)}) else Library:Tween(FarmSwitch,{BackgroundColor3=Color3.fromRGB(40,40,60)}); Library:Tween(FarmDot,{Position=UDim2.new(0,2,0.5,-11)}) end end)

-- Balance & Stats
local function SB(p,t,c) local f=Instance.new("Frame",p);f.BackgroundColor3=(c==Settings.Theme.IceBlue or c==Settings.Theme.ShardBlue)and Color3.fromRGB(15,30,50)or Color3.fromRGB(30,15,15);Library:Corner(f,12);local s=Instance.new("UIStroke",f);s.Color=c;s.Thickness=1.2;local tt=Instance.new("TextLabel",f);tt.Size=UDim2.new(1,0,0.3,0);tt.Position=UDim2.new(0,0,0.15,0);tt.BackgroundTransparency=1;tt.Text=t;tt.TextColor3=c;tt.Font=Enum.Font.GothamBold;tt.TextSize=14;local tv=Instance.new("TextLabel",f);tv.Size=UDim2.new(1,0,0.5,0);tv.Position=UDim2.new(0,0,0.45,0);tv.BackgroundTransparency=1;tv.Text="0";tv.TextColor3=Color3.new(1,1,1);tv.Font=Enum.Font.GothamBlack;tv.TextSize=22;return tv end
local BC=Instance.new("Frame",Tab_Farm_Scroll);BC.Size=UDim2.new(0.95,0,0,70);BC.BackgroundTransparency=1;BC.LayoutOrder=3;local BG=Instance.new("UIGridLayout",BC);BG.CellSize=UDim2.new(0.48,0,1,0);BG.CellPadding=UDim2.new(0.04,0,0,0)
local BL=Instance.new("TextLabel",Tab_Farm_Scroll);BL.Size=UDim2.new(0.95,0,0,25);BL.Text="Total Balance (סה''כ בתיק) 💰";BL.TextColor3=Settings.Theme.Gold;BL.Font=Enum.Font.GothamBlack;BL.TextSize=14;BL.BackgroundTransparency=1;BL.LayoutOrder=2
local T_B=SB(BC,"כחולים 🧊",Settings.Theme.ShardBlue);local T_R=SB(BC,"אדומים 💎",Settings.Theme.CrystalRed)
local SL=Instance.new("TextLabel",Tab_Farm_Scroll);SL.Size=UDim2.new(0.95,0,0,25);SL.Text="Collected in Storm (נאספו בסופה) 📥";SL.TextColor3=Color3.fromRGB(200,230,255);SL.Font=Enum.Font.GothamBold;SL.TextSize=12;SL.BackgroundTransparency=1;SL.LayoutOrder=4
local SC=Instance.new("Frame",Tab_Farm_Scroll);SC.Size=UDim2.new(0.95,0,0,70);SC.BackgroundTransparency=1;SC.LayoutOrder=5;local SG=Instance.new("UIGridLayout",SC);SG.CellSize=UDim2.new(0.48,0,1,0);SG.CellPadding=UDim2.new(0.04,0,0,0)
local S_B=SB(SC,"כחולים (Session)",Settings.Theme.IceBlue);local S_R=SB(SC,"אדומים (Session)",Settings.Theme.CrystalRed)

task.spawn(function() local C,S=LocalPlayer:WaitForChild("Crystals",10),LocalPlayer:WaitForChild("Shards",10);if not C or not S then return end;local iC,iS=C.Value,S.Value;while true do task.wait(0.5);local c,s=C.Value,S.Value;T_R.Text=tostring(c);T_B.Text=tostring(s);S_R.Text="+"..tostring(math.max(0,c-iC));S_B.Text="+"..tostring(math.max(0,s-iS)) end end)

--// 8. Sliders & Toggles (FIXED SPEED)
local function CreateSlider(parent, title, heb, min, max, default, callback, toggleCallback, toggleName)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95,0,0,75); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.7,0,0,25); l.Position = UDim2.new(0,10,0,8); l.Text = title .. " ("..heb..") : " .. default; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.BackgroundTransparency=1
    local line = Instance.new("Frame", f); line.Size = UDim2.new(0.9,0,0,12); line.Position = UDim2.new(0.05,0,0.65,0); line.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(line,6)
    local fill = Instance.new("Frame", line); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Settings.Theme.Gold; Library:Corner(fill,6)
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.MouseButton1Down:Connect(function() local move = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then local r = math.clamp((i.Position.X - line.AbsolutePosition.X)/line.AbsoluteSize.X,0,1); fill.Size = UDim2.new(r,0,1,0); local v = math.floor(min+((max-min)*r)); l.Text = title.." ("..heb..") : "..v; callback(v) end end); UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then move:Disconnect() end end) end)
    if toggleCallback then
        local t = Instance.new("TextButton", f); t.Size = UDim2.new(0,60,0,25); t.Position = UDim2.new(1,-70,0,8); t.BackgroundColor3 = Color3.fromRGB(40,40,40); t.Text = "OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.GothamBold; Library:Corner(t,4)
        local on = false; 
        local function Update(s) 
            on=s; t.Text=on and "ON" or "OFF"; t.BackgroundColor3=on and Settings.Theme.Gold or Color3.fromRGB(40,40,40); t.TextColor3=on and Color3.new(0,0,0) or Color3.new(1,1,1)
            toggleCallback(on) 
        end
        t.MouseButton1Click:Connect(function() Update(not on) end)
    end
end

CreateSlider(Tab_Main, "Walk Speed", "מהירות הליכה", 16, 250, 16, 
    function(v) Settings.Speed.Value = v end, 
    function(t) 
        Settings.Speed.Enabled = t 
        -- התיקון: אם מכבים, מחזיר ל-16
        if not t and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end, 
"Speed")

CreateSlider(Tab_Main, "Fly Speed", "מהירות תעופה", 20, 300, 50, function(v) Settings.Fly.Speed = v end, function(t) ToggleFly(t) end, "Fly")
CreateSlider(Tab_Settings, "FOV", "שדה ראייה", 70, 120, 70, function(v) Camera.FieldOfView = v end)

-- Keybinds
local function Bind(p,id,t,h,d,cb) local f=Instance.new("TextButton",p);f.Size=UDim2.new(0.95,0,0,45);f.BackgroundColor3=Settings.Theme.Box;f.Text="";Library:Corner(f,8);Library:AddGlow(f,Color3.fromRGB(40,40,40));local tl=Instance.new("TextLabel",f);tl.Size=UDim2.new(0.5,0,1,0);tl.Position=UDim2.new(0,10,0,0);tl.Text=t.." ("..h..")";tl.TextColor3=Color3.new(0.8,0.8,0.8);tl.Font=Enum.Font.Gotham;tl.TextSize=13;tl.TextXAlignment=Enum.TextXAlignment.Left;tl.BackgroundTransparency=1;local k=Instance.new("TextLabel",f);k.Size=UDim2.new(0.4,0,1,0);k.Position=UDim2.new(0.6,0,0,0);k.Text=d.Name;k.TextColor3=Settings.Theme.Gold;k.Font=Enum.Font.GothamBold;k.TextSize=14;k.BackgroundTransparency=1;f.MouseButton1Click:Connect(function() k.Text="...";local i=UIS.InputBegan:Wait();if i.UserInputType==Enum.UserInputType.Keyboard then k.Text=i.KeyCode.Name;cb(i.KeyCode) end end) end
Bind(Tab_Main,1,"Fly Key","מקש תעופה",Settings.Keys.Fly,function(k) Settings.Keys.Fly=k end)
Bind(Tab_Settings,2,"Menu Key","מקש תפריט",Settings.Keys.Menu,function(k) Settings.Keys.Menu=k end)

-- Credits
local function AddCr(n, id)
    local f = Instance.new("Frame", Tab_Credits); f.Size = UDim2.new(0.95,0,0,100); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 12); Library:AddGlow(f)
    local i = Instance.new("ImageLabel", f); i.Size = UDim2.new(0,80,0,80); i.Position = UDim2.new(0,10,0.5,-40); i.Image = "rbxthumb://type=AvatarHeadShot&id="..id.."&w=150&h=150"; Library:Corner(i, 40)
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(0,350,0,30); t.Position = UDim2.new(0,100,0,20); t.Text = n .. " <font color='#AAAAAA'>(יוצרים)</font>"; t.RichText=true; t.TextColor3 = Settings.Theme.Gold; t.Font=Enum.Font.GothamBlack; t.TextSize=22; t.TextXAlignment="Left"; t.BackgroundTransparency=1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0,140,0,30); b.Position = UDim2.new(0,100,0,55); b.BackgroundColor3 = Color3.fromRGB(88,101,242); b.Text="Copy Discord"; b.TextColor3=Color3.new(1,1,1); Library:Corner(b,6); b.TextSize=13; b.MouseButton1Click:Connect(function() setclipboard(n); b.Text="Copied!"; task.wait(1); b.Text="Copy Discord" end)
end
AddCr("nx3ho", 1323665023); AddCr("8adshot3", 3370067928)

UIS.InputBegan:Connect(function(i,g)
    if not g then
        if i.KeyCode == Settings.Keys.Menu then MainFrame.Visible = not MainFrame.Visible end
        if i.KeyCode == Settings.Keys.Fly then Settings.Fly.Enabled = not Settings.Fly.Enabled; ToggleFly(Settings.Fly.Enabled) end
        if i.KeyCode == Settings.Keys.Speed then 
            Settings.Speed.Enabled = not Settings.Speed.Enabled
            if not Settings.Speed.Enabled and LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Speed.Enabled and LocalPlayer.Character then local h = LocalPlayer.Character:FindFirstChild("Humanoid"); if h then h.WalkSpeed = Settings.Speed.Value end end
end)

print("[SYSTEM] Spaghetti Mafia Hub v4.0 Loaded")
