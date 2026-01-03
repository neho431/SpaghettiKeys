--[[
    Spaghetti Mafia Hub v5.0 (FRESH START & FIXED)
    
    Fixes included:
    1. Speed Toggle: Resets Humanoid.WalkSpeed to 16 immediately when turned OFF.
    2. Sidebar Line: Precise positioning, no floating, correct ZIndex.
    3. Auto Farm: Waits exactly 1s. If stuck -> Blacklists crystal -> Skips instantly.
    4. Layout: Removed gaps, clean Winter title.
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

--// 1. בדיקת Whitelist (ללא שינוי)
local WHITELIST_URL = "https://github.com/neho431/SpaghettiKeys/blob/main/whitelist.txt"

local function CheckWhitelist()
    local success, content = pcall(function()
        return game:HttpGet(WHITELIST_URL .. "?t=" .. tick())
    end)
    if success and content and string.find(content, LocalPlayer.Name) then
        print("[SYSTEM] Whitelist Confirmed.")
        return true
    else
        LocalPlayer:Kick("Access Denied / אין גישה")
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
        IceBlue = Color3.fromRGB(100, 220, 255),
        IceDark = Color3.fromRGB(10, 25, 45),
        SnowWhite = Color3.fromRGB(240, 248, 255),
        ShardBlue = Color3.fromRGB(50, 180, 255),
        CrystalRed = Color3.fromRGB(255, 70, 70)
    },
    Keys = { Menu = Enum.KeyCode.RightControl, Fly = Enum.KeyCode.E, Speed = Enum.KeyCode.F },
    Fly = { Enabled = false, Speed = 50 },
    Speed = { Enabled = false, Value = 16 },
    Farming = false,
    FarmSpeed = 450
}

local FarmBlacklist = {}
local FarmConnection = nil
local VisualToggles = {}

--// 3. UI Helper Functions
local Library = {}
function Library:Tween(obj, props, time) TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play() end
function Library:Corner(obj, r) local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c end
function Library:Stroke(obj, color) local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Theme.Gold; s.Thickness = 1.2; s.ApplyStrokeMode = "Border"; s.Transparency = 0.6; return s end
function Library:MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; dragStart=i.Position; startPos=obj.Position end end)
    UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement and dragging then local d=i.Position-dragStart; obj.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)
end

--// 4. GUI Setup
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_Rel"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false

-- מסגרת ראשית
local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 620, 0, 420); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = Settings.Theme.Dark; MainFrame.ClipsDescendants = true
Library:Corner(MainFrame, 16); Library:Stroke(MainFrame, Settings.Theme.Gold); Library:MakeDraggable(MainFrame)
MainFrame.Size = UDim2.new(0,0,0,0); Library:Tween(MainFrame, {Size = UDim2.new(0, 620, 0, 420)}, 0.5)

-- כותרת
local TopBar = Instance.new("Frame", MainFrame); TopBar.Size = UDim2.new(1,0,0,50); TopBar.BackgroundTransparency = 1
local MainTitle = Instance.new("TextLabel", TopBar); MainTitle.Size = UDim2.new(0, 300, 1, 0); MainTitle.Position = UDim2.new(0, 20, 0, 0); MainTitle.BackgroundTransparency = 1; MainTitle.Text = "SPAGHETTI <font color='#FFD700'>MAFIA</font> HUB"; MainTitle.RichText = true; MainTitle.Font = Enum.Font.GothamBlack; MainTitle.TextSize = 22; MainTitle.TextColor3 = Color3.new(1,1,1); MainTitle.TextXAlignment = "Left"

-- כפתור סגירה
local CloseBtn = Instance.new("TextButton", TopBar); CloseBtn.Size = UDim2.new(0,30,0,30); CloseBtn.Position = UDim2.new(1,-40,0,10); CloseBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Settings.Theme.CrystalRed; Library:Corner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

--// 5. Sidebar Layout (Fixed)
local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 160, 1, -50); Sidebar.Position = UDim2.new(0,0,0,50); Sidebar.BackgroundColor3 = Settings.Theme.Box; Sidebar.BorderSizePixel = 0; Library:Corner(Sidebar, 12)

-- כותרת "עולם הכיף" בתוך ה-Sidebar
local SideTitle = Instance.new("TextLabel", Sidebar)
SideTitle.Size = UDim2.new(1, 0, 0, 40)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "עולם הכיף ❄️"
SideTitle.Font = Enum.Font.GothamBlack
SideTitle.TextColor3 = Settings.Theme.IceBlue
SideTitle.TextSize = 18

-- מיכל כפתורים (מסודר ברשימה)
local ButtonsHolder = Instance.new("Frame", Sidebar)
ButtonsHolder.Size = UDim2.new(1, 0, 1, -40)
ButtonsHolder.Position = UDim2.new(0, 0, 0, 40)
ButtonsHolder.BackgroundTransparency = 1

local ListLayout = Instance.new("UIListLayout", ButtonsHolder); ListLayout.SortOrder = "LayoutOrder"; ListLayout.Padding = UDim.new(0, 5)

-- הקו הזז (The Line) - עכשיו הוא בתוך ButtonsHolder כדי לזוז עם הכפתורים
local ActiveLine = Instance.new("Frame", Sidebar) -- משאירים ב-Sidebar כדי שיוכל לזוז בחופשיות
ActiveLine.Size = UDim2.new(0, 4, 0, 40)
ActiveLine.BackgroundColor3 = Settings.Theme.Gold
ActiveLine.BorderSizePixel = 0
ActiveLine.ZIndex = 5
ActiveLine.Visible = false
Library:Corner(ActiveLine, 2)

local Container = Instance.new("Frame", MainFrame); Container.Size = UDim2.new(1, -170, 1, -60); Container.Position = UDim2.new(0, 170, 0, 55); Container.BackgroundTransparency = 1

-- פונקציית טאבים משופרת
local function CreateTab(name, heb, order, isWinter)
    local btn = Instance.new("TextButton", ButtonsHolder)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundTransparency = 1
    btn.Text = "   " .. name .. "\n   <font size='11' color='#888'>"..heb.."</font>"
    btn.RichText = true
    btn.TextColor3 = Color3.fromRGB(150,150,150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextXAlignment = "Left"
    btn.LayoutOrder = order
    
    local page = Instance.new("Frame", Container); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.Visible=false
    
    btn.MouseButton1Click:Connect(function()
        -- Reset all
        for _,v in pairs(ButtonsHolder:GetChildren()) do if v:IsA("TextButton") then Library:Tween(v, {TextColor3 = Color3.fromRGB(150,150,150)}) end end
        for _,v in pairs(Container:GetChildren()) do v.Visible = false end
        
        -- Activate current
        local col = isWinter and Settings.Theme.IceBlue or Settings.Theme.Gold
        Library:Tween(btn, {TextColor3 = col})
        page.Visible = true
        
        -- Line Logic
        ActiveLine.Visible = true
        ActiveLine.BackgroundColor3 = col
        -- חישוב המיקום של הקו: המיקום של הכפתור בתוך ה-Holder + המיקום של ה-Holder
        local targetY = btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y
        Library:Tween(ActiveLine, {Position = UDim2.new(0, 0, 0, targetY)}, 0.3)
    end)
    
    if order == 1 then
        -- Default selection
        local col = isWinter and Settings.Theme.IceBlue or Settings.Theme.Gold
        btn.TextColor3 = col
        page.Visible = true
        task.spawn(function()
            task.wait(0.1)
            ActiveLine.Visible = true; ActiveLine.BackgroundColor3 = col
            ActiveLine.Position = UDim2.new(0, 0, 0, btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y)
        end)
    end
    
    return page
end

local Tab_Event = CreateTab("Winter Event", "אירוע חורף", 1, true)
local Tab_Main = CreateTab("Main", "ראשי", 2, false)
local Tab_Settings = CreateTab("Settings", "הגדרות", 3, false)
local Tab_Credits = CreateTab("Credits", "קרדיטים", 4, false)

--// 6. AUTO FARM LOGIC (FIXED)
task.spawn(function() while true do task.wait(60); pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end end)

local function GetClosest()
    local drops = Workspace:FindFirstChild("StormDrops"); if not drops then return nil end
    local close, dist = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _,v in pairs(drops:GetChildren()) do
            if v:IsA("BasePart") and not FarmBlacklist[v] then -- בדיקת Blacklist
                local d = (hrp.Position - v.Position).Magnitude
                if d < dist then dist = d; close = v end
            end
        end
    end
    return close
end

local function DisableCollisions()
    local char = LocalPlayer.Character
    if char then
        for _,v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide=false; v.CanTouch=false end end
    end
end

local function ToggleFarm(val)
    Settings.Farming = val
    if not val then 
        FarmBlacklist = {} -- איפוס רשימה כשמכבים
        if FarmConnection then FarmConnection:Disconnect() end
    else
        FarmConnection = RunService.Stepped:Connect(function()
            if Settings.Farming then DisableCollisions() end
        end)
        
        task.spawn(function()
            while Settings.Farming do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local target = GetClosest()
                
                if hrp and target then
                    -- התחלת תנועה
                    local dist = (hrp.Position - target.Position).Magnitude
                    local info = TweenInfo.new(dist / Settings.FarmSpeed, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, info, {CFrame = target.CFrame})
                    tween:Play()
                    
                    local startTime = tick()
                    
                    -- לולאת איסוף
                    repeat 
                        task.wait()
                        -- אם כיבו באמצע
                        if not Settings.Farming then tween:Cancel(); break end
                        
                        -- אם הקריסטל נעלם (נאסף בהצלחה)
                        if not target.Parent then tween:Cancel(); break end
                        
                        -- Anti-Bug: אם עברה שניה אחת (1.0)
                        if (tick() - startTime) > 1.0 then
                            tween:Cancel()
                            FarmBlacklist[target] = true -- שולח לבלאקליסט
                            target.CFrame = CFrame.new(0, -999, 0) -- מעיף אותו מהעיניים
                            print("[AutoFarm] Bugged crystal skipped!")
                            break
                        end
                        
                        -- איסוף אם קרוב
                        if (hrp.Position - target.Position).Magnitude < 5 then
                            target.CanTouch = true
                        end
                        
                    until false
                else
                    task.wait(0.1)
                end
                task.wait()
            end
        end)
    end
end

--// 7. Event Tab Content
local Scroll = Instance.new("ScrollingFrame", Tab_Event); Scroll.Size=UDim2.new(1,0,1,0); Scroll.BackgroundTransparency=1; Scroll.ScrollBarThickness=2
local UIList = Instance.new("UIListLayout", Scroll); UIList.Padding=UDim.new(0,10); UIList.HorizontalAlignment="Center"

-- כפתור Auto Farm
local FarmBtn = Instance.new("TextButton", Scroll); FarmBtn.Size=UDim2.new(0.95,0,0,60); FarmBtn.BackgroundColor3=Color3.fromRGB(30,50,70); FarmBtn.Text=""; Library:Corner(FarmBtn, 10); Library:Stroke(FarmBtn, Settings.Theme.IceBlue)
local FarmTxt = Instance.new("TextLabel", FarmBtn); FarmTxt.Text="Toggle Auto Farm ❄️"; FarmTxt.Size=UDim2.new(1,-60,1,0); FarmTxt.Position=UDim2.new(0,15,0,0); FarmTxt.BackgroundTransparency=1; FarmTxt.TextColor3=Color3.new(1,1,1); FarmTxt.Font=Enum.Font.GothamBold; FarmTxt.TextSize=16; FarmTxt.TextXAlignment="Left"
local ToggleBox = Instance.new("Frame", FarmBtn); ToggleBox.Size=UDim2.new(0,40,0,20); ToggleBox.Position=UDim2.new(1,-50,0.5,-10); ToggleBox.BackgroundColor3=Color3.fromRGB(20,20,20); Library:Corner(ToggleBox,10)
local ToggleDot = Instance.new("Frame", ToggleBox); ToggleDot.Size=UDim2.new(0,16,0,16); ToggleDot.Position=UDim2.new(0,2,0.5,-8); ToggleDot.BackgroundColor3=Color3.fromRGB(200,200,200); Library:Corner(ToggleDot,10)

local isFarming = false
FarmBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    ToggleFarm(isFarming)
    if isFarming then
        Library:Tween(ToggleBox, {BackgroundColor3 = Settings.Theme.IceBlue})
        Library:Tween(ToggleDot, {Position = UDim2.new(1, -18, 0.5, -8)})
    else
        Library:Tween(ToggleBox, {BackgroundColor3 = Color3.fromRGB(20,20,20)})
        Library:Tween(ToggleDot, {Position = UDim2.new(0, 2, 0.5, -8)})
    end
end)

-- Balance Display
local BalFrame = Instance.new("Frame", Scroll); BalFrame.Size=UDim2.new(0.95,0,0,80); BalFrame.BackgroundTransparency=1
local BalGrid = Instance.new("UIGridLayout", BalFrame); BalGrid.CellSize=UDim2.new(0.48,0,1,0); BalGrid.CellPadding=UDim2.new(0.04,0,0,0)

local function MakeStat(parent, title, color)
    local f = Instance.new("Frame", parent); f.BackgroundColor3=Color3.fromRGB(15,15,20); Library:Corner(f,8); Library:Stroke(f, color)
    local t = Instance.new("TextLabel", f); t.Text=title; t.Size=UDim2.new(1,0,0.3,0); t.Position=UDim2.new(0,0,0.1,0); t.BackgroundTransparency=1; t.TextColor3=color; t.Font=Enum.Font.GothamBold
    local v = Instance.new("TextLabel", f); v.Text="0"; v.Size=UDim2.new(1,0,0.5,0); v.Position=UDim2.new(0,0,0.4,0); v.BackgroundTransparency=1; v.TextColor3=Color3.new(1,1,1); v.Font=Enum.Font.GothamBlack; v.TextSize=20
    return v
end

local ValBlues = MakeStat(BalFrame, "ICE", Settings.Theme.ShardBlue)
local ValReds = MakeStat(BalFrame, "FIRE", Settings.Theme.CrystalRed)

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            ValBlues.Text = tostring(LocalPlayer.Shards.Value)
            ValReds.Text = tostring(LocalPlayer.Crystals.Value)
        end)
    end
end)

--// 8. Main Tab Components (SPEED FIX HERE)
local function CreateSlider(parent, name, min, max, default, callback, toggleCallback)
    local f = Instance.new("Frame", parent); f.Size=UDim2.new(0.95,0,0,60); f.BackgroundColor3=Settings.Theme.Box; Library:Corner(f,8)
    local t = Instance.new("TextLabel", f); t.Text=name.." : "..default; t.Size=UDim2.new(1,0,0,25); t.Position=UDim2.new(0,10,0,5); t.BackgroundTransparency=1; t.TextColor3=Color3.new(1,1,1); t.Font=Enum.Font.GothamBold; t.TextXAlignment="Left"
    local bar = Instance.new("Frame", f); bar.Size=UDim2.new(0.9,0,0,6); bar.Position=UDim2.new(0.05,0,0.7,0); bar.BackgroundColor3=Color3.fromRGB(40,40,40); Library:Corner(bar,3)
    local fill = Instance.new("Frame", bar); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=Settings.Theme.Gold; Library:Corner(fill,3)
    local btn = Instance.new("TextButton", f); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    
    -- Slider Logic
    btn.MouseButton1Down:Connect(function()
        local input = UIS.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement then
                local s = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(s, 0, 1, 0)
                local val = math.floor(min + ((max - min) * s))
                t.Text = name.." : "..val
                callback(val)
            end
        end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then input:Disconnect() end end)
    end)
    
    -- Toggle Button (FIX IS INSIDE HERE)
    if toggleCallback then
        local tog = Instance.new("TextButton", f); tog.Size=UDim2.new(0,50,0,25); tog.Position=UDim2.new(1,-60,0,5); tog.BackgroundColor3=Color3.fromRGB(40,40,40); tog.Text="OFF"; tog.TextColor3=Color3.new(1,1,1); Library:Corner(tog, 4)
        local on = false
        tog.MouseButton1Click:Connect(function()
            on = not on
            tog.Text = on and "ON" or "OFF"
            tog.BackgroundColor3 = on and Settings.Theme.Gold or Color3.fromRGB(40,40,40)
            tog.TextColor3 = on and Color3.new(0,0,0) or Color3.new(1,1,1)
            toggleCallback(on)
        end)
    end
end

-- רשימה בטאב הראשי
local MainList = Instance.new("UIListLayout", Tab_Main); MainList.Padding = UDim.new(0,10); MainList.HorizontalAlignment="Center"
local MainPad = Instance.new("UIPadding", Tab_Main); MainPad.PaddingTop = UDim.new(0,10)

-- יצירת הסליידר עם התיקון
CreateSlider(Tab_Main, "WalkSpeed", 16, 250, 16, 
    function(val) 
        Settings.Speed.Value = val 
    end, 
    function(state) 
        Settings.Speed.Enabled = state 
        -- כאן התיקון: אם מכבים (state == false), משנים מיד את המהירות ל-16
        if not state then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
)

CreateSlider(Tab_Main, "Fly Speed", 20, 300, 50, function(v) Settings.Fly.Speed=v end, function(s) 
    Settings.Fly.Enabled = s
    -- פונקציית תעופה בסיסית
    if s then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if hrp and hum then
            local bv = Instance.new("BodyVelocity", hrp); bv.Name="FV"; bv.MaxForce=Vector3.new(1e9,1e9,1e9)
            hum.PlatformStand=true
            task.spawn(function()
                while Settings.Fly.Enabled do
                    local cam = workspace.CurrentCamera
                    local d = Vector3.zero
                    if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
                    bv.Velocity = d * Settings.Fly.Speed
                    task.wait()
                end
                bv:Destroy()
                hum.PlatformStand=false
            end)
        end
    end
end)

-- Loop to apply speed if enabled
RunService.RenderStepped:Connect(function()
    if Settings.Speed.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed.Value
    end
end)

print("Spaghetti Hub v5.0 Loaded - Fixed Speed & Farm")
