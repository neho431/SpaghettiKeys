--[[
    Spaghetti Mafia Hub v2 (DEEP SCAN & PREMIUM UI)
    System: Universal Value Finder (Searches EVERYWHERE in LocalPlayer)
    Design: Modern Card Layout
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

--// 1. הגדרות עיצוב משופרות
local Settings = {
    Colors = {
        Background = Color3.fromRGB(15, 15, 20),
        Card = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(255, 215, 0), -- Gold
        TextMain = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 160),
        Success = Color3.fromRGB(100, 255, 120),
        Fail = Color3.fromRGB(255, 80, 80),
        Shards = Color3.fromRGB(80, 200, 255),
        Crystals = Color3.fromRGB(255, 85, 85)
    },
    Farm = {
        Enabled = false,
        Speed = 120,
        Blacklist = {}
    }
}

--// 2. ניקוי והגנות
if CoreGui:FindFirstChild("SpaghettiHub_V2") then CoreGui.SpaghettiHub_V2:Destroy() end

local function AntiAFK()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end
LocalPlayer.Idled:Connect(AntiAFK)

--// 3. ספריית UI קלילה
local Library = {}

function Library:Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function Library:Corner(obj, r)
    local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 8); return c
end

function Library:Stroke(obj, color, thick)
    local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Colors.Accent; s.Thickness = thick or 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Transparency = 0.8; return s
end

function Library:Gradient(obj, c1, c2)
    local g = Instance.new("UIGradient", obj)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    }
    g.Rotation = 45
    return g
end

--// 4. בניית הממשק (GUI)
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_V2"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Settings.Colors.Background
Library:Corner(MainFrame, 16)
Library:Stroke(MainFrame, Settings.Colors.Accent, 1.5)

-- כותרת עליונה
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Text = "SPAGHETTI <font color='#FFD700'>MAFIA</font> <font size='14' color='#999999'>v2 DeepScan</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.TextColor3 = Settings.Colors.TextMain
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- גרירה
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- אזור תוכן ראשי
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -30, 1, -60)
Content.Position = UDim2.new(0, 15, 0, 55)
Content.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 12)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

--// רכיב 1: כפתור חווה (Farm Toggle)
local FarmCard = Instance.new("Frame", Content)
FarmCard.Size = UDim2.new(1, 0, 0, 65)
FarmCard.BackgroundColor3 = Settings.Colors.Card
FarmCard.LayoutOrder = 1
Library:Corner(FarmCard, 10)
Library:Stroke(FarmCard, Color3.fromRGB(60,60,80), 1)

local FarmTitle = Instance.new("TextLabel", FarmCard)
FarmTitle.Size = UDim2.new(0, 200, 1, 0)
FarmTitle.Position = UDim2.new(0, 15, 0, 0)
FarmTitle.Text = "Auto Farm Event ❄️\n<font size='12' color='#888899'>איסוף אוטומטי מהיר</font>"
FarmTitle.RichText = true
FarmTitle.Font = Enum.Font.GothamBold
FarmTitle.TextSize = 16
FarmTitle.TextColor3 = Settings.Colors.TextMain
FarmTitle.TextXAlignment = Enum.TextXAlignment.Left
FarmTitle.BackgroundTransparency = 1

local ToggleBtn = Instance.new("TextButton", FarmCard)
ToggleBtn.Size = UDim2.new(0, 50, 0, 26)
ToggleBtn.Position = UDim2.new(1, -65, 0.5, -13)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
ToggleBtn.Text = ""
Library:Corner(ToggleBtn, 14)
local ToggleCircle = Instance.new("Frame", ToggleBtn)
ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
ToggleCircle.Position = UDim2.new(0, 3, 0.5, -10)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(120,120,130)
Library:Corner(ToggleCircle, 20)

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.Farm.Enabled = not Settings.Farm.Enabled
    if Settings.Farm.Enabled then
        Library:Tween(ToggleBtn, {BackgroundColor3 = Settings.Colors.Accent})
        Library:Tween(ToggleCircle, {Position = UDim2.new(1, -23, 0.5, -10), BackgroundColor3 = Color3.new(1,1,1)})
    else
        Library:Tween(ToggleBtn, {BackgroundColor3 = Color3.fromRGB(40,40,50)})
        Library:Tween(ToggleCircle, {Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Color3.fromRGB(120,120,130)})
    end
end)

--// רכיב 2: תצוגת נתונים (Data Cards)
local StatsContainer = Instance.new("Frame", Content)
StatsContainer.Size = UDim2.new(1, 0, 0, 180)
StatsContainer.BackgroundTransparency = 1
StatsContainer.LayoutOrder = 2

local StatsGrid = Instance.new("UIGridLayout", StatsContainer)
StatsGrid.CellSize = UDim2.new(0.48, 0, 0, 85)
StatsGrid.CellPadding = UDim2.new(0.04, 0, 0, 10)

-- פונקציה ליצירת כרטיס מידע
local function CreateStatCard(name, color, icon)
    local f = Instance.new("Frame", StatsContainer)
    f.BackgroundColor3 = Settings.Colors.Card
    Library:Corner(f, 10)
    Library:Stroke(f, color, 1)
    
    local top = Instance.new("Frame", f); top.Size = UDim2.new(1,0,0,30); top.BackgroundTransparency=1
    local t = Instance.new("TextLabel", top); t.Size=UDim2.new(1,-10,1,0); t.Position=UDim2.new(0,10,0,0); t.Text=name.." "..icon; t.Font=Enum.Font.GothamBold; t.TextColor3=color; t.TextSize=14; t.TextXAlignment=Enum.TextXAlignment.Left; t.BackgroundTransparency=1
    
    local val = Instance.new("TextLabel", f); val.Size=UDim2.new(1,0,0,35); val.Position=UDim2.new(0,0,0.35,0); val.Text="Scanning..."; val.Font=Enum.Font.GothamBlack; val.TextColor3=Settings.Colors.TextMain; val.TextSize=24; val.BackgroundTransparency=1
    
    local sub = Instance.new("TextLabel", f); sub.Size=UDim2.new(1,0,0,15); sub.Position=UDim2.new(0,0,0.75,0); sub.Text="Total: ?"; sub.Font=Enum.Font.Gotham; sub.TextColor3=Settings.Colors.TextDim; sub.TextSize=11; sub.BackgroundTransparency=1
    
    return val, sub -- מחזיר את הטקסטים לעדכון
end

local ShardsVal, ShardsTotal = CreateStatCard("Shards", Settings.Colors.Shards, "🧊")
local CrystalsVal, CrystalsTotal = CreateStatCard("Crystals", Settings.Colors.Crystals, "💎")

--// לוגיקה חכמה לחיפוש נתונים (Deep Scan System)
local function FindValueObject(root, possibleNames)
    -- חיפוש מהיר בילדים ישירים
    for _, child in pairs(root:GetChildren()) do
        if table.find(possibleNames, child.Name) and (child:IsA("IntValue") or child:IsA("NumberValue")) then
            return child
        end
    end
    -- חיפוש עמוק (יקר יותר, אבל מוצא הכל)
    for _, child in pairs(root:GetDescendants()) do
        if table.find(possibleNames, child.Name) and (child:IsA("IntValue") or child:IsA("NumberValue")) then
            return child
        end
    end
    return nil
end

task.spawn(function()
    print("[SYSTEM] Starting Deep Scan for Data...")
    
    local CrystalObj = nil
    local ShardObj = nil
    
    -- רשימת שמות אפשריים (חשוב מאוד!)
    local CrystalNames = {"Crystals", "Crystal", "Gem", "Gems", "Diamonds", "Money", "Coins"}
    local ShardNames = {"Shards", "Shard", "Ice", "Snow"}
    
    while not CrystalObj or not ShardObj do
        -- ניסיון 1: Leaderstats (הכי נפוץ)
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            if not CrystalObj then CrystalObj = FindValueObject(ls, CrystalNames) end
            if not ShardObj then ShardObj = FindValueObject(ls, ShardNames) end
        end
        
        -- ניסיון 2: תיקיות DATA בתוך השחקן
        if not CrystalObj or not ShardObj then
            if not CrystalObj then CrystalObj = FindValueObject(LocalPlayer, CrystalNames) end
            if not ShardObj then ShardObj = FindValueObject(LocalPlayer, ShardNames) end
        end

        -- עדכון סטטוס חיפוש למשתמש
        if not CrystalObj then CrystalsVal.Text = "Searching..." CrystalsVal.TextColor3 = Settings.Colors.Accent else CrystalsVal.Text = "Synced!" CrystalsVal.TextColor3 = Settings.Colors.Success end
        if not ShardObj then ShardsVal.Text = "Searching..." ShardsVal.TextColor3 = Settings.Colors.Accent else ShardsVal.Text = "Synced!" ShardsVal.TextColor3 = Settings.Colors.Success end
        
        if CrystalObj and ShardObj then break end
        task.wait(2)
    end
    
    print("[SYSTEM] Data Found!")
    print("Crystals Path: " .. CrystalObj:GetFullName())
    print("Shards Path: " .. ShardObj:GetFullName())

    -- הגדרת ערכים התחלתיים
    local StartCrystals = CrystalObj.Value
    local StartShards = ShardObj.Value
    
    -- לולאת עדכון UI
    RunService.RenderStepped:Connect(function()
        local currC = CrystalObj.Value
        local currS = ShardObj.Value
        
        local diffC = currC - StartCrystals
        local diffS = currS - StartShards
        
        if diffC < 0 then diffC = 0 end -- הגנה ממספרים שליליים
        if diffS < 0 then diffS = 0 end
        
        -- עדכון התצוגה
        CrystalsVal.Text = "+" .. tostring(diffC)
        CrystalsVal.TextColor3 = (diffC > 0) and Settings.Colors.Success or Settings.Colors.TextMain
        CrystalsTotal.Text = "Total: " .. tostring(currC)
        
        ShardsVal.Text = "+" .. tostring(diffS)
        ShardsVal.TextColor3 = (diffS > 0) and Settings.Colors.Success or Settings.Colors.TextMain
        ShardsTotal.Text = "Total: " .. tostring(currS)
    end)
end)

--// מערכת החווה (ללא שינוי מהותי, רק חיבור)
local function GetTarget()
    local drops = Workspace:FindFirstChild("StormDrops")
    if not drops then return nil end
    local closest, dist = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, v in pairs(drops:GetChildren()) do
            if v:IsA("BasePart") and not Settings.Farm.Blacklist[v] then
                local mag = (hrp.Position - v.Position).Magnitude
                if mag < dist then dist = mag; closest = v end
            end
        end
    end
    return closest
end

task.spawn(function()
    while true do
        if Settings.Farm.Enabled and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local target = GetTarget()
            
            if hrp and target then
                -- ביטול התנגשויות (Noclip)
                for _, p in pairs(LocalPlayer.Character:GetChildren()) do 
                    if p:IsA("BasePart") then p.CanCollide = false end 
                end
                
                -- תנועה
                local distance = (hrp.Position - target.Position).Magnitude
                local info = TweenInfo.new(distance / Settings.Farm.Speed, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(hrp, info, {CFrame = target.CFrame})
                tween:Play()
                
                -- המתנה להגעה
                local arriveTime = tick()
                while Settings.Farm.Enabled and target.Parent and (tick() - arriveTime) < 2 do
                    task.wait()
                    if (hrp.Position - target.Position).Magnitude < 8 then
                        -- מגע אגרסיבי
                        if firetouchinterest then
                            firetouchinterest(target, hrp, 0)
                            firetouchinterest(target, hrp, 1)
                        end
                        target.CanTouch = true
                        break 
                    end
                end
                if target.Parent then tween:Cancel(); Settings.Farm.Blacklist[target] = true end
            else
                if hrp then hrp.Velocity = Vector3.zero end -- עצירה כשאין מטרות
            end
        else
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.PlatformStand = false end
            end
        end
        task.wait(0.1)
    end
end)

print("[SYSTEM] Spaghetti Hub v2 Loaded - Deep Scan Active")
