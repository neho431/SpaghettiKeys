--[[
    Spaghetti Mafia Hub v2 (WINTER EDITION)
    Updates:
    - Advanced Snow Effects (Both Loading & Event Tab)
    - Winter Themed Design (Blue & Ice Colors)
    - Reordered Buttons: AutoFarm > Total Reds > Total Blues > Storm Session
    - Color Scheme: Red=Crystals, Blue=Shards
    - Improved Animations & Polish
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
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// 1. Whitelist System
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

--// 2. Cleanup & Settings
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then CoreGui.SpaghettiHub_Rel:Destroy() end
if CoreGui:FindFirstChild("SpaghettiLoading") then CoreGui.SpaghettiLoading:Destroy() end

local Settings = {
    Theme = {
        Gold = Color3.fromRGB(255, 215, 0),
        Dark = Color3.fromRGB(12, 12, 12),
        Box = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        Ice = Color3.fromRGB(135, 206, 250),
        IceDark = Color3.fromRGB(10, 20, 35),
        ShardBlue = Color3.fromRGB(100, 200, 255),
        CrystalRed = Color3.fromRGB(255, 100, 100),
        WinterAccent = Color3.fromRGB(120, 220, 255),
        SnowWhite = Color3.fromRGB(245, 250, 255),
        IceBlue = Color3.fromRGB(70, 180, 220)
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
local LastFullScan = 0

--// 3. Advanced Loading Screen with Enhanced Snow
local LoadGui = Instance.new("ScreenGui"); LoadGui.Name = "SpaghettiLoading"; LoadGui.Parent = CoreGui
local LoadBox = Instance.new("Frame", LoadGui)
LoadBox.Size = UDim2.new(0, 280, 0, 200)
LoadBox.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadBox.AnchorPoint = Vector2.new(0.5, 0.5)
LoadBox.BackgroundColor3 = Color3.fromRGB(10, 20, 35)
LoadBox.ClipsDescendants = true
LoadBox.BorderSizePixel = 0
local BoxStroke = Instance.new("UIStroke", LoadBox); BoxStroke.Color = Settings.Theme.WinterAccent; BoxStroke.Thickness = 3
local BoxCorner = Instance.new("UICorner", LoadBox); BoxCorner.CornerRadius = UDim.new(0, 20)

-- Ice Gradient Background
local LoadGradient = Instance.new("UIGradient", LoadBox)
LoadGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 15, 25))
}
LoadGradient.Rotation = -45

-- Pasta Icon
local PastaIcon = Instance.new("TextLabel", LoadBox)
PastaIcon.Size = UDim2.new(1, 0, 0.5, 0)
PastaIcon.Position = UDim2.new(0, 0, 0.05, 0)
PastaIcon.BackgroundTransparency = 1
PastaIcon.Text = "🍝"
PastaIcon.TextSize = 70
PastaIcon.TextYAlignment = Enum.TextYAlignment.Center
PastaIcon.ZIndex = 5

-- Title
local TitleLoad = Instance.new("TextLabel", LoadBox)
TitleLoad.Size = UDim2.new(1, 0, 0.15, 0)
TitleLoad.Position = UDim2.new(0, 0, 0.65, 0)
TitleLoad.BackgroundTransparency = 1
TitleLoad.Text = "Spaghetti Mafia"
TitleLoad.Font = Enum.Font.GothamBlack
TitleLoad.TextColor3 = Settings.Theme.SnowWhite
TitleLoad.TextSize = 16
TitleLoad.ZIndex = 5

-- Subtitle
local SubLoad = Instance.new("TextLabel", LoadBox)
SubLoad.Size = UDim2.new(1, 0, 0.15, 0)
SubLoad.Position = UDim2.new(0, 0, 0.8, 0)
SubLoad.BackgroundTransparency = 1
SubLoad.Text = "❄️ WINTER EDITION ❄️"
SubLoad.Font = Enum.Font.GothamBold
SubLoad.TextColor3 = Settings.Theme.WinterAccent
SubLoad.TextSize = 12
SubLoad.ZIndex = 5

-- Enhanced Snow Effect in Loading Screen
local function CreateAdvancedSnow(container, maxFlakes)
    task.spawn(function()
        local flakeCount = 0
        while container.Parent and flakeCount < maxFlakes do
            local flake = Instance.new("Frame", container)
            local size = math.random(2, 6)
            flake.Size = UDim2.new(0, size, 0, size)
            flake.Position = UDim2.new(math.random(0, 100) / 100, 0, -0.15, 0)
            flake.BackgroundColor3 = Settings.Theme.SnowWhite
            flake.BorderSizePixel = 0
            flake.ZIndex = 2
            
            local corner = Instance.new("UICorner", flake)
            corner.CornerRadius = UDim.new(1, 0)
            
            local fallTime = math.random(3, 6)
            local sway = math.random(-30, 30) / 100
            
            TweenService:Create(flake, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
                Position = UDim2.new(flake.Position.X.Scale + sway, 0, 1.2, 0),
                BackgroundTransparency = 1
            }):Play()
            
            Debris:AddItem(flake, fallTime + 0.5)
            flakeCount = flakeCount + 1
            task.wait(0.15)
        end
    end)
end

CreateAdvancedSnow(LoadBox, 35)

-- Rotation Animation
task.spawn(function()
    local t = 0
    while LoadBox.Parent do
        t = t + 0.08
        PastaIcon.Rotation = math.sin(t * 1.5) * 15
        SubLoad.TextTransparency = 0.3 + (math.sin(t * 3) * 0.3)
        TitleLoad.TextTransparency = math.sin(t * 2) * 0.2
        task.wait(0.05)
    end
end)

task.wait(5)
LoadGui:Destroy()

--// 4. Design Library
local Library = {}
function Library:Tween(obj, props, time, style) 
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play() 
end

function Library:AddGlow(obj, color)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or Settings.Theme.WinterAccent
    s.Thickness = 1.5
    s.Transparency = 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function Library:Corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

function Library:MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// 5. Main GUI - Complete Rebuild
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpaghettiHub_Rel"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Mini Pasta Button
local MiniPasta = Instance.new("TextButton", ScreenGui)
MiniPasta.Size = UDim2.new(0, 70, 0, 70)
MiniPasta.Position = UDim2.new(0.1, 0, 0.1, 0)
MiniPasta.BackgroundColor3 = Settings.Theme.IceDark
MiniPasta.Text = "🍝"
MiniPasta.TextSize = 40
MiniPasta.Visible = false
Library:Corner(MiniPasta, 35)
Library:AddGlow(MiniPasta, Settings.Theme.WinterAccent)
Library:MakeDraggable(MiniPasta)

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 700, 0, 450)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Settings.Theme.IceDark
MainFrame.ClipsDescendants = true
Library:Corner(MainFrame, 18)
Library:AddGlow(MainFrame, Settings.Theme.WinterAccent)

-- Background Gradient
local MainGradient = Instance.new("UIGradient", MainFrame)
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 25, 40))
}
MainGradient.Rotation = 135

MainFrame.Size = UDim2.new(0, 0, 0, 0)
Library:Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.7, Enum.EasingStyle.Elastic)

local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 1

-- Top Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 70)
TopBar.BackgroundTransparency = 0.1
TopBar.BorderSizePixel = 0
Library:MakeDraggable(MainFrame)

-- Minimize Button
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(0, 12, 0, 12)
MinBtn.BackgroundColor3 = Settings.Theme.Box
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 28
Library:Corner(MinBtn, 10)
Library:AddGlow(MinBtn, Color3.fromRGB(80, 80, 100))

MinBtn.MouseButton1Click:Connect(function()
    Library:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
    task.wait(0.3)
    MainFrame.Visible = false
    MiniPasta.Visible = true
    Library:Tween(MiniPasta, {Size = UDim2.new(0, 70, 0, 70)}, 0.4, Enum.EasingStyle.Elastic)
end)

-- Title
local MainTitle = Instance.new("TextLabel", TopBar)
MainTitle.Size = UDim2.new(0, 400, 0, 35)
MainTitle.Position = UDim2.new(0, 60, 0, 10)
MainTitle.BackgroundTransparency = 1
MainTitle.Text = "SPAGHETTI <font color='#78DCFF'>MAFIA</font>"
MainTitle.RichText = true
MainTitle.Font = Enum.Font.GothamBlack
MainTitle.TextSize = 24
MainTitle.TextColor3 = Color3.new(1, 1, 1)
MainTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Subtitle (Winter Theme)
local MainSub = Instance.new("TextLabel", TopBar)
MainSub.Size = UDim2.new(0, 400, 0, 22)
MainSub.Position = UDim2.new(0, 60, 0, 40)
MainSub.BackgroundTransparency = 1
MainSub.Text = "❄️ WINTER EDITION • עולם הכיף ❄️"
MainSub.Font = Enum.Font.GothamBold
MainSub.TextSize = 12
MainSub.TextColor3 = Settings.Theme.WinterAccent
MainSub.TextXAlignment = Enum.TextXAlignment.Left

-- Mini Pasta Click
local pds = Vector2.zero
MiniPasta.MouseButton1Down:Connect(function() pds = UIS:GetMouseLocation() end)
MiniPasta.MouseButton1Up:Connect(function()
    if (UIS:GetMouseLocation() - pds).Magnitude < 5 then
        Library:Tween(MiniPasta, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        MiniPasta.Visible = false
        MainFrame.Visible = true
        Library:Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.5, Enum.EasingStyle.Back)
    end
end)

-- Sidebar with Fixed Tab Order
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 180, 1, -75)
Sidebar.Position = UDim2.new(0, 0, 0, 70)
Sidebar.BackgroundColor3 = Settings.Theme.Box
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2
Library:Corner(Sidebar, 14)

local SideList = Instance.new("UIListLayout", Sidebar)
SideList.Padding = UDim.new(0, 8)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.VerticalAlignment = Enum.VerticalAlignment.Top

local SidePad = Instance.new("UIPadding", Sidebar)
SidePad.PaddingTop = UDim.new(0, 12)
SidePad.PaddingLeft = UDim.new(0, 5)
SidePad.PaddingRight = UDim.new(0, 5)

-- Container for Tab Pages
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -190, 1, -85)
Container.Position = UDim2.new(0, 190, 0, 70)
Container.BackgroundTransparency = 1

local currentTab = nil

local function CreateTab(name, heb, order, isEvent)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.95, 0, 0, 45)
    btn.BackgroundColor3 = Settings.Theme.Dark
    btn.Text = name .. "\n<font size='10' color='#AAAAAA'>" .. heb .. "</font>"
    btn.RichText = true
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.ZIndex = 3
    btn.LayoutOrder = order
    btn.AutoButtonColor = false
    Library:Corner(btn, 8)
    
    local page = Instance.new("Frame", Container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = isEvent and 0 or 1
    
    if isEvent then
        page.BackgroundColor3 = Color3.fromRGB(10, 20, 35)
        local eventGradient = Instance.new("UIGradient", page)
        eventGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 35, 55)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 15, 30))
        }
        eventGradient.Rotation = 45
    end
    
    page.Visible = false
    page.Name = name .. "_Page"
    page.ClipsDescendants = true
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(Sidebar:GetChildren()) do
            if v:IsA("TextButton") then
                Library:Tween(v, {BackgroundColor3 = Settings.Theme.Dark, TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
            end
        end
        for _, v in pairs(Container:GetChildren()) do
            v.Visible = false
        end
        Library:Tween(btn, {BackgroundColor3 = Settings.Theme.WinterAccent, TextColor3 = Color3.new(0, 0, 0)}, 0.2)
        page.Visible = true
        
        -- Underline Animation
        if btn:FindFirstChild("Underline") then btn.Underline:Destroy() end
        local underline = Instance.new("Frame", btn)
        underline.Name = "Underline"
        underline.Size = UDim2.new(0, 0, 0, 3)
        underline.Position = UDim2.new(0.5, 0, 1, 0)
        underline.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
        underline.BorderSizePixel = 0
        underline.AnchorPoint = Vector2.new(0.5, 0)
        Library:Tween(underline, {Size = UDim2.new(0.8, 0, 0, 3)}, 0.3)
    end)
    
    if not currentTab then
        currentTab = btn
        Library:Tween(btn, {BackgroundColor3 = Settings.Theme.WinterAccent, TextColor3 = Color3.new(0, 0, 0)}, 0.3)
        page.Visible = true
    end
    
    return page
end

-- Create Tabs
local Tab_Event_Page = CreateTab("❄️ Event", "אירוע חורף", 1, true)
local Tab_Main_Page = CreateTab("Main", "ראשי", 2, false)
local Tab_Settings_Page = CreateTab("Settings", "הגדרות", 3, false)
local Tab_Credits_Page = CreateTab("Credits", "קרדיטים", 4, false)

-- Layout Helper
local function AddLayout(p)
    local l = Instance.new("UIListLayout", p)
    l.Padding = UDim.new(0, 14)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pad = Instance.new("UIPadding", p)
    pad.PaddingTop = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 12)
end

AddLayout(Tab_Main_Page)
AddLayout(Tab_Settings_Page)
AddLayout(Tab_Credits_Page)

--// 6. Logic Systems
-- Super Strong Anti-AFK
task.spawn(function()
    while true do
        task.wait(60)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if not Settings.Farming then
                    LocalPlayer.Character.Humanoid.Jump = true
                end
            end
        end)
    end
end)

local function GetClosestTarget()
    local drops = Workspace:FindFirstChild("StormDrops")
    if not drops then return nil end
    local closest, dist = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, v in pairs(drops:GetChildren()) do
            if v:IsA("BasePart") and not FarmBlacklist[v] then
                local mag = (hrp.Position - v.Position).Magnitude
                if mag < dist then
                    dist = mag
                    closest = v
                end
            end
        end
    end
    return closest
end

local function UltraSafeDisable()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanTouch = false
        end
    end
    local region = Region3.new(hrp.Position - Vector3.new(30, 30, 30), hrp.Position + Vector3.new(30, 30, 30))
    local objects = workspace:FindPartsInRegion3(region, nil, 200)
    for _, part in pairs(objects) do
        local n = part.Name:lower()
        if n:find("door") or n:find("portal") or n:find("tele") or n:find("gate") or n:find("enter") or n:find("selection") or n:find("lobby") or n:find("zone") or n:find("minigame") then
            part.CanTouch = false
            pcall(function()
                if part:FindFirstChild("TouchInterest") then
                    part.TouchInterest:Destroy()
                end
            end)
        end
    end
    if tick() - LastFullScan > 5 then
        LastFullScan = tick()
        task.spawn(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("door") then
                    obj.CanTouch = false
                    pcall(function()
                        if obj:FindFirstChild("TouchInterest") then
                            obj.TouchInterest:Destroy()
                        end
                    end)
                end
            end
        end)
    end
end

local function ToggleFarm(v)
    Settings.Farming = v
    if not v then FarmBlacklist = {} end
    if not FarmConnection and v then
        FarmConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character and Settings.Farming then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
                local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then
                    hum.Sit = false
                    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                end
                UltraSafeDisable()
            end
        end)
    elseif not v and FarmConnection then
        FarmConnection:Disconnect()
        FarmConnection = nil
    end

    if v then
        task.spawn(function()
            while Settings.Farming do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local target = GetClosestTarget()
                if char and hrp and target then
                    local distance = (hrp.Position - target.Position).Magnitude
                    local tween = TweenService:Create(hrp, TweenInfo.new(distance / Settings.FarmSpeed, Enum.EasingStyle.Linear), {CFrame = target.CFrame})
                    tween:Play()
                    local start = tick()
                    repeat
                        task.wait()
                        if not target.Parent or not Settings.Farming then
                            tween:Cancel()
                            break
                        end
                        if (tick() - start) > 1.8 then
                            tween:Cancel()
                            FarmBlacklist[target] = true
                            break
                        end
                        if (hrp.Position - target.Position).Magnitude < 5 then
                            target.CanTouch = true
                        end
                    until (tick() - start) > (distance / Settings.FarmSpeed) + 0.1
                else
                    task.wait(0.2)
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
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if v then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Name = "F_V"
        local bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.P = 9e4
        bg.Name = "F_G"
        hum.PlatformStand = true
        task.spawn(function()
            while Settings.Fly.Enabled and char.Parent do
                local cam = workspace.CurrentCamera
                local d = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then d = d + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then d = d - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then d = d + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then d = d - cam.CFrame.RightVector end
                bv.Velocity = d * Settings.Fly.Speed
                bg.CFrame = cam.CFrame
                RunService.Heartbeat:Wait()
            end
            if hrp:FindFirstChild("F_V") then hrp.F_V:Destroy() end
            if hrp:FindFirstChild("F_G") then hrp.F_G:Destroy() end
            hum.PlatformStand = false
        end)
    else
        if hrp:FindFirstChild("F_V") then hrp.F_V:Destroy() end
        if hrp:FindFirstChild("F_G") then hrp.F_G:Destroy() end
        hum.PlatformStand = false
    end
end

--// 7. EVENT TAB - ADVANCED WINTER DESIGN
-- Snow Effect Container
local EventSnowContainer = Instance.new("Frame", Tab_Event_Page)
EventSnowContainer.Size = UDim2.new(1, 0, 1, 0)
EventSnowContainer.BackgroundTransparency = 1
EventSnowContainer.ClipsDescendants = true
EventSnowContainer.ZIndex = 1

CreateAdvancedSnow(EventSnowContainer, 50)

-- Scrolling Content
local Tab_Event_Scroll = Instance.new("ScrollingFrame", Tab_Event_Page)
Tab_Event_Scroll.Size = UDim2.new(1, 0, 1, 0)
Tab_Event_Scroll.BackgroundTransparency = 1
Tab_Event_Scroll.ScrollBarThickness = 3
Tab_Event_Scroll.ScrollBarImageColor3 = Settings.Theme.WinterAccent
Tab_Event_Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Tab_Event_Scroll.BorderSizePixel = 0
Tab_Event_Scroll.ZIndex = 5

local EventLayout = Instance.new("UIListLayout", Tab_Event_Scroll)
EventLayout.Padding = UDim.new(0, 16)
EventLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
EventLayout.SortOrder = Enum.SortOrder.LayoutOrder

local EventPad = Instance.new("UIPadding", Tab_Event_Scroll)
EventPad.PaddingTop = UDim.new(0, 14)
EventPad.PaddingLeft = UDim.new(0, 10)
EventPad.PaddingRight = UDim.new(0, 10)
EventPad.PaddingBottom = UDim.new(0, 14)

--// AUTO FARM BUTTON (ראשון)
local FarmBtn = Instance.new("TextButton", Tab_Event_Scroll)
FarmBtn.Size = UDim2.new(0.95, 0, 0, 80)
FarmBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 65)
FarmBtn.Text = ""
FarmBtn.LayoutOrder = 1
FarmBtn.AutoButtonColor = false
Library:Corner(FarmBtn, 14)
Library:AddGlow(FarmBtn, Settings.Theme.WinterAccent)

local FarmTitle = Instance.new("TextLabel", FarmBtn)
FarmTitle.Size = UDim2.new(1, -70, 1, 0)
FarmTitle.Position = UDim2.new(0, 15, 0, 0)
FarmTitle.Text = "🌪️ AUTO FARM\n<font size='12' color='#78DCFF'>הפעלת חווה אוטומטית</font>"
FarmTitle.RichText = true
FarmTitle.TextColor3 = Color3.new(1, 1, 1)
FarmTitle.Font = Enum.Font.GothamBlack
FarmTitle.TextSize = 16
FarmTitle.TextXAlignment = Enum.TextXAlignment.Left
FarmTitle.BackgroundTransparency = 1

local FarmSwitch = Instance.new("Frame", FarmBtn)
FarmSwitch.Size = UDim2.new(0, 50, 0, 30)
FarmSwitch.Position = UDim2.new(1, -65, 0.5, -15)
FarmSwitch.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
Library:Corner(FarmSwitch, 25)

local FarmDot = Instance.new("Frame", FarmSwitch)
FarmDot.Size = UDim2.new(0, 26, 0, 26)
FarmDot.Position = UDim2.new(0, 2, 0.5, -13)
FarmDot.BackgroundColor3 = Color3.fromRGB(180, 200, 220)
Library:Corner(FarmDot, 25)

local isFarming = false
FarmBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    ToggleFarm(isFarming)
    if isFarming then
        Library:Tween(FarmSwitch, {BackgroundColor3 = Settings.Theme.WinterAccent}, 0.3)
        Library:Tween(FarmDot, {Position = UDim2.new(1, -28, 0.5, -13)}, 0.3)
    else
        Library:Tween(FarmSwitch, {BackgroundColor3 = Color3.fromRGB(40, 60, 80)}, 0.3)
        Library:Tween(FarmDot, {Position = UDim2.new(0, 2, 0.5, -13)}, 0.3)
    end
end)

--// TOTAL REDS (שני)
local TotalRedsLabel = Instance.new("TextLabel", Tab_Event_Scroll)
TotalRedsLabel.Size = UDim2.new(0.95, 0, 0, 22)
TotalRedsLabel.BackgroundTransparency = 1
TotalRedsLabel.Text = "סה״כ אדומים • Total Crystals 💎"
TotalRedsLabel.TextColor3 = Settings.Theme.CrystalRed
TotalRedsLabel.Font = Enum.Font.GothamBold
TotalRedsLabel.TextSize = 13
TotalRedsLabel.LayoutOrder = 2

local TotalRedsBox = Instance.new("Frame", Tab_Event_Scroll)
TotalRedsBox.Size = UDim2.new(0.95, 0, 0, 75)
TotalRedsBox.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
TotalRedsBox.LayoutOrder = 3
Library:Corner(TotalRedsBox, 12)
local RedsStroke = Instance.new("UIStroke", TotalRedsBox)
RedsStroke.Color = Settings.Theme.CrystalRed
RedsStroke.Thickness = 2
RedsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local RedsVal = Instance.new("TextLabel", TotalRedsBox)
RedsVal.Size = UDim2.new(1, 0, 1, 0)
RedsVal.BackgroundTransparency = 1
RedsVal.Text = "0"
RedsVal.TextColor3 = Color3.new(1, 1, 1)
RedsVal.Font = Enum.Font.GothamBlack
RedsVal.TextSize = 48

--// TOTAL BLUES (שלישי)
local TotalBluesLabel = Instance.new("TextLabel", Tab_Event_Scroll)
TotalBluesLabel.Size = UDim2.new(0.95, 0, 0, 22)
TotalBluesLabel.BackgroundTransparency = 1
TotalBluesLabel.Text = "סה״כ כחולים • Total Shards 🧊"
TotalBluesLabel.TextColor3 = Settings.Theme.ShardBlue
TotalBluesLabel.Font = Enum.Font.GothamBold
TotalBluesLabel.TextSize = 13
TotalBluesLabel.LayoutOrder = 4

local TotalBluesBox = Instance.new("Frame", Tab_Event_Scroll)
TotalBluesBox.Size = UDim2.new(0.95, 0, 0, 75)
TotalBluesBox.BackgroundColor3 = Color3.fromRGB(15, 35, 55)
TotalBluesBox.LayoutOrder = 5
Library:Corner(TotalBluesBox, 12)
local BluesStroke = Instance.new("UIStroke", TotalBluesBox)
BluesStroke.Color = Settings.Theme.ShardBlue
BluesStroke.Thickness = 2
BluesStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local BluesVal = Instance.new("TextLabel", TotalBluesBox)
BluesVal.Size = UDim2.new(1, 0, 1, 0)
BluesVal.BackgroundTransparency = 1
BluesVal.Text = "0"
BluesVal.TextColor3 = Color3.new(1, 1, 1)
BluesVal.Font = Enum.Font.GothamBlack
BluesVal.TextSize = 48

--// STORM SESSION (רביעי)
local StormLabel = Instance.new("TextLabel", Tab_Event_Scroll)
StormLabel.Size = UDim2.new(0.95, 0, 0, 22)
StormLabel.BackgroundTransparency = 1
StormLabel.Text = "סה״כ סופה • Storm Session 🌩️"
StormLabel.TextColor3 = Settings.Theme.WinterAccent
StormLabel.Font = Enum.Font.GothamBold
StormLabel.TextSize = 13
StormLabel.LayoutOrder = 6

local StormContainer = Instance.new("Frame", Tab_Event_Scroll)
StormContainer.Size = UDim2.new(0.95, 0, 0, 75)
StormContainer.BackgroundTransparency = 1
StormContainer.LayoutOrder = 7

local StormGrid = Instance.new("UIGridLayout", StormContainer)
StormGrid.CellSize = UDim2.new(0.48, 0, 1, 0)
StormGrid.CellPadding = UDim2.new(0.04, 0, 0, 0)
StormGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local StormRedsBox = Instance.new("Frame", StormContainer)
StormRedsBox.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
Library:Corner(StormRedsBox, 12)
local StormRedsStroke = Instance.new("UIStroke", StormRedsBox)
StormRedsStroke.Color = Settings.Theme.CrystalRed
StormRedsStroke.Thickness = 1.5
StormRedsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local StormRedsTitle = Instance.new("TextLabel", StormRedsBox)
StormRedsTitle.Size = UDim2.new(1, 0, 0.3, 0)
StormRedsTitle.BackgroundTransparency = 1
StormRedsTitle.Text = "Reds"
StormRedsTitle.TextColor3 = Settings.Theme.CrystalRed
StormRedsTitle.Font = Enum.Font.GothamBold
StormRedsTitle.TextSize = 14

local StormRedsVal = Instance.new("TextLabel", StormRedsBox)
StormRedsVal.Size = UDim2.new(1, 0, 0.7, 0)
StormRedsVal.Position = UDim2.new(0, 0, 0.3, 0)
StormRedsVal.BackgroundTransparency = 1
StormRedsVal.Text = "0"
StormRedsVal.TextColor3 = Color3.new(1, 1, 1)
StormRedsVal.Font = Enum.Font.GothamBlack
StormRedsVal.TextSize = 32

local StormBluesBox = Instance.new("Frame", StormContainer)
StormBluesBox.BackgroundColor3 = Color3.fromRGB(15, 30, 50)
Library:Corner(StormBluesBox, 12)
local StormBluesStroke = Instance.new("UIStroke", StormBluesBox)
StormBluesStroke.Color = Settings.Theme.ShardBlue
StormBluesStroke.Thickness = 1.5
StormBluesStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local StormBluesTitle = Instance.new("TextLabel", StormBluesBox)
StormBluesTitle.Size = UDim2.new(1, 0, 0.3, 0)
StormBluesTitle.BackgroundTransparency = 1
StormBluesTitle.Text = "Blues"
StormBluesTitle.TextColor3 = Settings.Theme.ShardBlue
StormBluesTitle.Font = Enum.Font.GothamBold
StormBluesTitle.TextSize = 14

local StormBluesVal = Instance.new("TextLabel", StormBluesBox)
StormBluesVal.Size = UDim2.new(1, 0, 0.7, 0)
StormBluesVal.Position = UDim2.new(0, 0, 0.3, 0)
StormBluesVal.BackgroundTransparency = 1
StormBluesVal.Text = "0"
StormBluesVal.TextColor3 = Color3.new(1, 1, 1)
StormBluesVal.Font = Enum.Font.GothamBlack
StormBluesVal.TextSize = 32

-- Anti-AFK Status
local AFKStatus = Instance.new("TextLabel", Tab_Event_Scroll)
AFKStatus.Size = UDim2.new(0.95, 0, 0, 24)
AFKStatus.BackgroundTransparency = 1
AFKStatus.Text = "⚡ Anti-AFK: <font color='#00FF00'>ACTIVE</font> (Jumper)"
AFKStatus.RichText = true
AFKStatus.TextColor3 = Color3.new(1, 1, 1)
AFKStatus.Font = Enum.Font.GothamMedium
AFKStatus.TextSize = 12
AFKStatus.LayoutOrder = 8

-- Data Tracking
task.spawn(function()
    local CrystalsRef = LocalPlayer:WaitForChild("Crystals", 10)
    local ShardsRef = LocalPlayer:WaitForChild("Shards", 10)
    if not CrystalsRef or not ShardsRef then return end
    
    local InitC = CrystalsRef.Value
    local InitS = ShardsRef.Value
    local LastC = InitC
    local LastS = InitS
    local StormC = 0
    local StormS = 0
    
    while true do
        task.wait(0.5)
        pcall(function()
            local CurC = CrystalsRef.Value
            local CurS = ShardsRef.Value
            
            RedsVal.Text = tostring(CurC)
            BluesVal.Text = tostring(CurS)
            
            if CurC > LastC then
                StormC = StormC + (CurC - LastC)
            elseif CurC < LastC then
                StormC = 0
            end
            
            if CurS > LastS then
                StormS = StormS + (CurS - LastS)
            elseif CurS < LastS then
                StormS = 0
            end
            
            LastC = CurC
            LastS = CurS
            
            StormRedsVal.Text = tostring(StormC)
            StormBluesVal.Text = tostring(StormS)
        end)
    end
end)

--// 8. Components for Other Tabs
local function CreateSlider(parent, title, heb, min, max, default, callback, toggleCallback, toggleName)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.95, 0, 0, 85)
    f.BackgroundColor3 = Settings.Theme.Box
    Library:Corner(f, 10)
    Library:AddGlow(f, Color3.fromRGB(50, 50, 70))
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.7, 0, 0, 25)
    l.Position = UDim2.new(0, 12, 0, 10)
    l.Text = title .. " (" .. heb .. "): " .. default
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    
    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(0.9, 0, 0, 14)
    line.Position = UDim2.new(0.05, 0, 0.65, 0)
    line.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
    Library:Corner(line, 8)
    
    local fill = Instance.new("Frame", line)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Settings.Theme.WinterAccent
    Library:Corner(fill, 8)
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    btn.MouseButton1Down:Connect(function()
        local move = UIS.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement then
                local r = math.clamp((i.Position.X - line.AbsolutePosition.X) / line.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(r, 0, 1, 0)
                local v = math.floor(min + ((max - min) * r))
                l.Text = title .. " (" .. heb .. "): " .. v
                callback(v)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                move:Disconnect()
            end
        end)
    end)
    
    if toggleCallback then
        local t = Instance.new("TextButton", f)
        t.Size = UDim2.new(0, 70, 0, 28)
        t.Position = UDim2.new(1, -85, 0, 10)
        t.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
        t.Text = "OFF"
        t.TextColor3 = Color3.new(1, 1, 1)
        t.Font = Enum.Font.GothamBold
        Library:Corner(t, 6)
        t.TextSize = 13
        
        local on = false
        
