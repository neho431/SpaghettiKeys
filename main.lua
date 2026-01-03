--[[
    Spaghetti Mafia Hub v1 (REVERTED & FIXED)
    - GUI Engine: Original Script 1 (Stable, no blank screen)
    - Logic: Script 2 (Safe Farm, Session Stats)
    - Whitelist: GitHub (No Key)
]]

--// 1. Whitelist System
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local WHITELIST_URL = "https://raw.githubusercontent.com/neho431/SpaghettiKeys/main/whitelist.txt"

local function CheckWhitelist()
    local success, content = pcall(function()
        return game:HttpGet(WHITELIST_URL .. "?t=" .. tick())
    end)
    if success and content then
        if string.find(content, LocalPlayer.Name) then
            print("Whitelist Verified.")
            return true
        else
            LocalPlayer:Kick("Not Whitelisted.")
            return false
        end
    end
    return true -- Fallback for testing if http fails, remove for strict security
end
if not CheckWhitelist() then return end

--// Cleanup
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then CoreGui.SpaghettiHub_Rel:Destroy() end

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

--// Settings
local Settings = {
    Theme = {
        Gold = Color3.fromRGB(255, 215, 0),
        Dark = Color3.fromRGB(10, 10, 10),
        Box = Color3.fromRGB(18, 18, 18),
        Text = Color3.fromRGB(255, 255, 255),
        Red = Color3.fromRGB(255, 70, 70),
        Blue = Color3.fromRGB(50, 180, 255)
    },
    Keys = { Menu = Enum.KeyCode.RightControl, Fly = Enum.KeyCode.E, Speed = Enum.KeyCode.F },
    Fly = { Enabled = false, Speed = 50 },
    Speed = { Enabled = false, Value = 16 },
    Farming = false,
    FarmSpeed = 120,
    Scale = 1
}

local VisualToggles = {}
local FarmConnection = nil
local FarmBlacklist = {}

--// Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--// Library (Original Script 1)
local Library = {}
function Library:Tween(obj, props, time, style)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Sine), props):Play()
end
function Library:Corner(obj, r)
    local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c
end
function Library:AddGlow(obj, color)
    local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Theme.Gold; s.Thickness = 1; s.Transparency = 0.6; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; return s
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

--// GUI Creation (Original Structure)
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_Rel"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false

local MiniPasta = Instance.new("TextButton", ScreenGui); MiniPasta.Size = UDim2.new(0,0,0,0); MiniPasta.Visible = false
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 400); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Settings.Theme.Dark; MainFrame.ClipsDescendants = true
Library:Corner(MainFrame, 12); Library:AddGlow(MainFrame); Library:MakeDraggable(MainFrame)

-- Animation Fix
MainFrame.Size = UDim2.new(0,0,0,0)
Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.5, Enum.EasingStyle.Elastic)

local TopBar = Instance.new("Frame", MainFrame); TopBar.Size = UDim2.new(1,0,0,60); TopBar.BackgroundTransparency = 1
local MinBtn = Instance.new("TextButton", TopBar); MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(0, 10, 0, 10); MinBtn.BackgroundColor3 = Settings.Theme.Box; MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1)
Library:Corner(MinBtn, 6)
MinBtn.MouseButton1Click:Connect(function() 
    Library:Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3); task.wait(0.3); MainFrame.Visible = false; MiniPasta.Visible = true 
end)

local MainTitle = Instance.new("TextLabel", TopBar); MainTitle.Size = UDim2.new(0,300,0,30); MainTitle.Position = UDim2.new(0,50,0,10); MainTitle.BackgroundTransparency = 1; MainTitle.Text = "SPAGHETTI <font color='#FFD700'>MAFIA</font> HUB"; MainTitle.RichText = true; MainTitle.Font = Enum.Font.GothamBlack; MainTitle.TextSize = 20; MainTitle.TextColor3 = Color3.new(1,1,1); MainTitle.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 160, 1, -60); Sidebar.Position = UDim2.new(0,0,0,60); Sidebar.BackgroundColor3 = Settings.Theme.Box
Library:Corner(Sidebar, 12)
local SideList = Instance.new("UIListLayout", Sidebar); SideList.Padding = UDim.new(0,10); SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidePad = Instance.new("UIPadding", Sidebar); SidePad.PaddingTop = UDim.new(0,15)

local Container = Instance.new("Frame", MainFrame); Container.Size = UDim2.new(1, -170, 1, -70); Container.Position = UDim2.new(0, 170, 0, 65); Container.BackgroundTransparency = 1

local currentTab = nil
local function CreateTab(name, heb)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9,0,0,40); btn.BackgroundColor3 = Settings.Theme.Dark
    btn.Text = name .. "\n<font size='11' color='#AAAAAA'>"..heb.."</font>"; btn.RichText = true; btn.TextColor3 = Color3.fromRGB(150,150,150); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    Library:Corner(btn, 6)
    
    local page = Instance.new("Frame", Container); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false
    
    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then Library:Tween(v, {BackgroundColor3 = Settings.Theme.Dark, TextColor3 = Color3.fromRGB(150,150,150)}) end end
        for _,v in pairs(Container:GetChildren()) do v.Visible = false end
        Library:Tween(btn, {BackgroundColor3 = Settings.Theme.Gold, TextColor3 = Color3.new(0,0,0)})
        page.Visible = true
    end)
    
    -- Auto Select First Tab
    if not currentTab then 
        currentTab = btn
        Library:Tween(btn, {BackgroundColor3 = Settings.Theme.Gold, TextColor3 = Color3.new(0,0,0)})
        page.Visible = true 
    end
    return page
end

--// Tabs
local Tab_Event = CreateTab("Event", "אירוע חורף")
local Tab_Main = CreateTab("Main", "ראשי")
local Tab_Sett = CreateTab("Settings", "הגדרות")

local function AddLayout(p) 
    local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0,12); l.HorizontalAlignment = Enum.HorizontalAlignment.Center 
    local pad = Instance.new("UIPadding", p); pad.PaddingTop = UDim.new(0,10)
end
AddLayout(Tab_Main); AddLayout(Tab_Sett)

--// ---------------- FARM LOGIC (FROM SCRIPT 2) ---------------- //

local function UltraSafeDisable()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local region = Region3.new(hrp.Position - Vector3.new(30,30,30), hrp.Position + Vector3.new(30,30,30))
        local parts = workspace:FindPartsInRegion3(region, nil, 100)
        for _, v in pairs(parts) do
            local n = v.Name:lower()
            if n:find("door") or n:find("portal") or n:find("tele") or n:find("gate") or n:find("enter") then
                v.CanTouch = false
                pcall(function() v.TouchInterest:Destroy() end)
            end
        end
    end
end

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
                    task.wait(0.2)
                end
                task.wait()
            end
        end)
    end
end

--// ---------------- EVENT TAB DESIGN (SIMPLE & ROBUST) ---------------- //

-- Create List Layout for Event Tab
local EventLayout = Instance.new("UIListLayout", Tab_Event)
EventLayout.Padding = UDim.new(0, 15)
EventLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local EventPad = Instance.new("UIPadding", Tab_Event); EventPad.PaddingTop = UDim.new(0,15)

-- Farm Toggle (Big Button Style)
local FarmBtn = Instance.new("TextButton", Tab_Event)
FarmBtn.Size = UDim2.new(0.95, 0, 0, 50)
FarmBtn.BackgroundColor3 = Settings.Theme.Box
FarmBtn.Text = ""
Library:Corner(FarmBtn, 8); Library:AddGlow(FarmBtn, Color3.fromRGB(60,60,60))

local FarmTitle = Instance.new("TextLabel", FarmBtn)
FarmTitle.Size = UDim2.new(0.8,0,1,0); FarmTitle.Position = UDim2.new(0.05,0,0,0)
FarmTitle.Text = "Auto Farm Event ❄️"; FarmTitle.TextColor3 = Color3.new(1,1,1); FarmTitle.Font = Enum.Font.GothamBold; FarmTitle.TextSize = 16; FarmTitle.TextXAlignment = Enum.TextXAlignment.Left; FarmTitle.BackgroundTransparency = 1

local FarmStatus = Instance.new("Frame", FarmBtn)
FarmStatus.Size = UDim2.new(0, 20, 0, 20); FarmStatus.Position = UDim2.new(0.9, -10, 0.5, -10)
FarmStatus.BackgroundColor3 = Color3.fromRGB(50,50,50)
Library:Corner(FarmStatus, 5)

local isFarming = false
FarmBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        Library:Tween(FarmStatus, {BackgroundColor3 = Settings.Theme.Gold})
        Library:AddGlow(FarmBtn, Settings.Theme.Gold)
    else
        Library:Tween(FarmStatus, {BackgroundColor3 = Color3.fromRGB(50,50,50)})
        if FarmBtn:FindFirstChild("UIStroke") then FarmBtn.UIStroke:Destroy() end
        Library:AddGlow(FarmBtn, Color3.fromRGB(60,60,60))
    end
    ToggleFarm(isFarming)
end)

-- Anti AFK Label
local AFKLabel = Instance.new("TextLabel", Tab_Event)
AFKLabel.Size = UDim2.new(0.95, 0, 0, 20)
AFKLabel.Text = "Anti-AFK: Active"; AFKLabel.TextColor3 = Color3.fromRGB(150,150,150); AFKLabel.Font = Enum.Font.Gotham; AFKLabel.TextSize = 12; AFKLabel.BackgroundTransparency = 1

-- Stats Container
local StatsCont = Instance.new("Frame", Tab_Event)
StatsCont.Size = UDim2.new(0.95, 0, 0, 100); StatsCont.BackgroundTransparency = 1
local StatsGrid = Instance.new("UIGridLayout", StatsCont); StatsGrid.CellSize = UDim2.new(0.48, 0, 1, 0)

-- Function for Boxes
local function CreateBox(color, title)
    local f = Instance.new("Frame", StatsCont)
    f.BackgroundColor3 = Settings.Theme.Box
    Library:Corner(f, 8); Library:AddGlow(f, color)
    
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1,0,0.3,0); t.Text = title; t.TextColor3 = color; t.Font = Enum.Font.GothamBold; t.TextSize = 14; t.BackgroundTransparency = 1; t.TextYAlignment = Enum.TextYAlignment.Bottom
    
    local v = Instance.new("TextLabel", f)
    v.Size = UDim2.new(1,0,0.7,0); v.Position = UDim2.new(0,0,0.3,0); v.Text = "0"; v.TextColor3 = Color3.new(1,1,1); v.Font = Enum.Font.GothamBlack; v.TextSize = 28; v.BackgroundTransparency = 1; v.TextYAlignment = Enum.TextYAlignment.Center
    return v
end

local ValRed = CreateBox(Settings.Theme.Red, "Crystals")
local ValBlue = CreateBox(Settings.Theme.Blue, "Shards")

-- Summary Label
local SummaryLabel = Instance.new("TextLabel", Tab_Event)
SummaryLabel.Size = UDim2.new(0.95,0,0,30); SummaryLabel.Text = "Session: 0 | Last Storm: 0"; SummaryLabel.TextColor3 = Color3.new(1,1,1); SummaryLabel.Font = Enum.Font.Gotham; SummaryLabel.TextSize = 14; SummaryLabel.BackgroundTransparency = 1

-- Logic for Stats
task.spawn(function()
    local CrystalObj = LocalPlayer:WaitForChild("Crystals", 10) or LocalPlayer:WaitForChild("crystals", 10)
    local ShardObj = LocalPlayer:WaitForChild("Shards", 10) or LocalPlayer:WaitForChild("shards", 10)
    
    if CrystalObj and ShardObj then
        local StartCry = CrystalObj.Value
        local StartShrd = ShardObj.Value
        local LastCry = CrystalObj.Value
        local LastShrd = ShardObj.Value
        local StormTotal = 0
        
        while true do
            task.wait(1)
            local CurrCry = CrystalObj.Value
            local CurrShrd = ShardObj.Value
            
            -- Session
            local SessCry = math.max(0, CurrCry - StartCry)
            local SessShrd = math.max(0, CurrShrd - StartShrd)
            ValRed.Text = tostring(SessCry)
            ValBlue.Text = tostring(SessShrd)
            
            -- Storm Logic (Increments only)
            if CurrCry > LastCry then StormTotal = StormTotal + (CurrCry - LastCry) end
            if CurrShrd > LastShrd then StormTotal = StormTotal + (CurrShrd - LastShrd) end
            
            LastCry = CurrCry
            LastShrd = CurrShrd
            
            SummaryLabel.Text = "Session Total: "..(SessCry+SessShrd).." | Storm: "..StormTotal
        end
    else
        SummaryLabel.Text = "Error: Data not found"
    end
end)

--// ---------------- MAIN & SETTINGS ---------------- //

local function CreateSlider(parent, title, min, max, default, callback)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95,0,0,60); f.BackgroundColor3 = Settings.Theme.Box
    Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.7,0,0,20); l.Position = UDim2.new(0,10,0,5); l.Text = title .. ": " .. default; l.TextColor3 = Color3.new(1,1,1); l.Font = Enum.Font.GothamBold; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.BackgroundTransparency = 1
    
    local line = Instance.new("Frame", f); line.Size = UDim2.new(0.9,0,0,10); line.Position = UDim2.new(0.05,0,0.6,0); line.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(line,5)
    local fill = Instance.new("Frame", line); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Settings.Theme.Gold; Library:Corner(fill,5)
    
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.MouseButton1Down:Connect(function()
        local move = UIS.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                local r = math.clamp((i.Position.X - line.AbsolutePosition.X)/line.AbsoluteSize.X,0,1)
                fill.Size = UDim2.new(r,0,1,0)
                local v = math.floor(min+((max-min)*r))
                l.Text = title..": "..v; callback(v)
            end
        end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

CreateSlider(Tab_Main, "Walk Speed", 16, 200, 16, function(v) Settings.Speed.Value = v; if Settings.Speed.Enabled then LocalPlayer.Character.Humanoid.WalkSpeed = v end end)
-- Bind for speed
local SpeedTog = Instance.new("TextButton", Tab_Main); SpeedTog.Size = UDim2.new(0.95,0,0,40); SpeedTog.BackgroundColor3 = Settings.Theme.Box; SpeedTog.Text = "Toggle Speed (Key: F)"; SpeedTog.TextColor3 = Color3.new(1,1,1); Library:Corner(SpeedTog, 8)
SpeedTog.MouseButton1Click:Connect(function() Settings.Speed.Enabled = not Settings.Speed.Enabled; SpeedTog.BackgroundColor3 = Settings.Speed.Enabled and Settings.Theme.Gold or Settings.Theme.Box; SpeedTog.TextColor3 = Settings.Speed.Enabled and Color3.new(0,0,0) or Color3.new(1,1,1) end)

UIS.InputBegan:Connect(function(i,g)
    if not g then
        if i.KeyCode == Settings.Keys.Menu then MainFrame.Visible = not MainFrame.Visible end
        if i.KeyCode == Settings.Keys.Speed then 
            Settings.Speed.Enabled = not Settings.Speed.Enabled
            SpeedTog.BackgroundColor3 = Settings.Speed.Enabled and Settings.Theme.Gold or Settings.Theme.Box
            SpeedTog.TextColor3 = Settings.Speed.Enabled and Color3.new(0,0,0) or Color3.new(1,1,1)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Speed.Enabled and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = Settings.Speed.Value end
    end
end)

print("Spaghetti Mafia Hub - Fixed & Restored")
