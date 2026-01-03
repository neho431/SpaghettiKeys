--[[
    Spaghetti Mafia Hub v2 (WINTER EDITION) - FIXED
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

--// 1. Whitelist (BYPASSED FOR TESTING)
local WHITELIST_ENABLED = false -- שנה ל-true אם אתה רוצה

local function CheckWhitelist()
    if not WHITELIST_ENABLED then return true end
    print("[SYSTEM] Whitelist check skipped for testing")
    return true
end

if not CheckWhitelist() then return end

--// 2. Cleanup
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then CoreGui.SpaghettiHub_Rel:Destroy() end
if CoreGui:FindFirstChild("SpaghettiLoading") then CoreGui.SpaghettiLoading:Destroy() end

local Settings = {
    Theme = {
        Gold = Color3.fromRGB(255, 215, 0),
        Dark = Color3.fromRGB(12, 12, 12),
        Box = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        IceDark = Color3.fromRGB(10, 20, 35),
        ShardBlue = Color3.fromRGB(100, 200, 255),
        CrystalRed = Color3.fromRGB(255, 100, 100),
        WinterAccent = Color3.fromRGB(120, 220, 255),
        SnowWhite = Color3.fromRGB(245, 250, 255),
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

--// 3. Loading Screen with Snow
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "SpaghettiLoading"
LoadGui.Parent = CoreGui

local LoadBox = Instance.new("Frame", LoadGui)
LoadBox.Size = UDim2.new(0, 280, 0, 200)
LoadBox.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadBox.AnchorPoint = Vector2.new(0.5, 0.5)
LoadBox.BackgroundColor3 = Color3.fromRGB(10, 20, 35)
LoadBox.ClipsDescendants = true
LoadBox.BorderSizePixel = 0

local BoxCorner = Instance.new("UICorner", LoadBox)
BoxCorner.CornerRadius = UDim.new(0, 20)

local BoxStroke = Instance.new("UIStroke", LoadBox)
BoxStroke.Color = Settings.Theme.WinterAccent
BoxStroke.Thickness = 3

-- Snow in loading
task.spawn(function()
    for i = 1, 40 do
        local flake = Instance.new("Frame", LoadBox)
        flake.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        flake.Position = UDim2.new(math.random(0, 100) / 100, 0, -0.15, 0)
        flake.BackgroundColor3 = Settings.Theme.SnowWhite
        flake.BorderSizePixel = 0
        local c = Instance.new("UICorner", flake)
        c.CornerRadius = UDim.new(1, 0)
        
        local fallTime = math.random(3, 6)
        local sway = math.random(-30, 30) / 100
        
        TweenService:Create(flake, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
            Position = UDim2.new(flake.Position.X.Scale + sway, 0, 1.2, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.1)
    end
end)

local PastaIcon = Instance.new("TextLabel", LoadBox)
PastaIcon.Size = UDim2.new(1, 0, 0.5, 0)
PastaIcon.BackgroundTransparency = 1
PastaIcon.Text = "🍝"
PastaIcon.TextSize = 70
PastaIcon.ZIndex = 5

local TitleLoad = Instance.new("TextLabel", LoadBox)
TitleLoad.Size = UDim2.new(1, 0, 0.2, 0)
TitleLoad.Position = UDim2.new(0, 0, 0.65, 0)
TitleLoad.BackgroundTransparency = 1
TitleLoad.Text = "Spaghetti Mafia"
TitleLoad.Font = Enum.Font.GothamBlack
TitleLoad.TextColor3 = Settings.Theme.SnowWhite
TitleLoad.TextSize = 16
TitleLoad.ZIndex = 5

local SubLoad = Instance.new("TextLabel", LoadBox)
SubLoad.Size = UDim2.new(1, 0, 0.15, 0)
SubLoad.Position = UDim2.new(0, 0, 0.8, 0)
SubLoad.BackgroundTransparency = 1
SubLoad.Text = "❄️ WINTER ❄️"
SubLoad.Font = Enum.Font.GothamBold
SubLoad.TextColor3 = Settings.Theme.WinterAccent
SubLoad.TextSize = 12
SubLoad.ZIndex = 5

task.wait(3)
LoadGui:Destroy()

--// 4. Design Library
local Library = {}

function Library:Tween(obj, props, time, style)
    if not obj or not obj.Parent then return end
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
    local dragging, dragStart, startPos
    
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = UIS:GetMouseLocation()
            startPos = obj.Position
        end
    end)
    
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local delta = UIS:GetMouseLocation() - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// 5. Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpaghettiHub_Rel"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 700, 0, 450)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Settings.Theme.IceDark
MainFrame.ClipsDescendants = true
Library:Corner(MainFrame, 18)
Library:AddGlow(MainFrame, Settings.Theme.WinterAccent)

MainFrame.Size = UDim2.new(0, 0, 0, 0)
Library:Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.7, Enum.EasingStyle.Elastic)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 70)
TopBar.BackgroundTransparency = 0.1
TopBar.BorderSizePixel = 0

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(0, 12, 0, 12)
MinBtn.BackgroundColor3 = Settings.Theme.Box
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 28
MinBtn.AutoButtonColor = false
Library:Corner(MinBtn, 10)
Library:AddGlow(MinBtn, Color3.fromRGB(80, 80, 100))

local MainTitle = Instance.new("TextLabel", TopBar)
MainTitle.Size = UDim2.new(0, 400, 0, 35)
MainTitle.Position = UDim2.new(0, 60, 0, 10)
MainTitle.BackgroundTransparency = 1
MainTitle.Text = "SPAGHETTI 🍝 MAFIA"
MainTitle.Font = Enum.Font.GothamBlack
MainTitle.TextSize = 22
MainTitle.TextColor3 = Color3.new(1, 1, 1)
MainTitle.TextXAlignment = Enum.TextXAlignment.Left

local MainSub = Instance.new("TextLabel", TopBar)
MainSub.Size = UDim2.new(0, 400, 0, 22)
MainSub.Position = UDim2.new(0, 60, 0, 40)
MainSub.BackgroundTransparency = 1
MainSub.Text = "❄️ WINTER EDITION ❄️"
MainSub.Font = Enum.Font.GothamBold
MainSub.TextSize = 12
MainSub.TextColor3 = Settings.Theme.WinterAccent
MainSub.TextXAlignment = Enum.TextXAlignment.Left

Library:MakeDraggable(MainFrame)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, -75)
Sidebar.Position = UDim2.new(0, 0, 0, 70)
Sidebar.BackgroundColor3 = Settings.Theme.Box
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2
Library:Corner(Sidebar, 14)

local SideList = Instance.new("UIListLayout", Sidebar)
SideList.Padding = UDim.new(0, 8)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.SortOrder = Enum.SortOrder.LayoutOrder

local SidePad = Instance.new("UIPadding", Sidebar)
SidePad.PaddingTop = UDim.new(0, 12)

-- Container
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -170, 1, -85)
Container.Position = UDim2.new(0, 170, 0, 70)
Container.BackgroundTransparency = 1

local currentTab = nil

local function CreateTab(name, heb, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.BackgroundColor3 = Settings.Theme.Dark
    btn.Text = name .. "\n" .. heb
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.ZIndex = 3
    btn.LayoutOrder = order
    btn.AutoButtonColor = false
    Library:Corner(btn, 8)
    
    local page = Instance.new("Frame", Container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Name = name .. "_Page"
    
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
    end)
    
    if not currentTab then
        currentTab = btn
        Library:Tween(btn, {BackgroundColor3 = Settings.Theme.WinterAccent, TextColor3 = Color3.new(0, 0, 0)}, 0.3)
        page.Visible = true
    end
    
    return page
end

local Tab_Event = CreateTab("❄️ Event", "אירוע", 1)
local Tab_Main = CreateTab("Main", "ראשי", 2)
local Tab_Settings = CreateTab("Settings", "הגדרות", 3)
local Tab_Credits = CreateTab("Credits", "קרדיטים", 4)

--// 6. EVENT TAB CONTENT
local EventScroll = Instance.new("ScrollingFrame", Tab_Event)
EventScroll.Size = UDim2.new(1, 0, 1, 0)
EventScroll.BackgroundTransparency = 1
EventScroll.ScrollBarThickness = 3
EventScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local EventLayout = Instance.new("UIListLayout", EventScroll)
EventLayout.Padding = UDim.new(0, 12)
EventLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local EventPad = Instance.new("UIPadding", EventScroll)
EventPad.PaddingTop = UDim.new(0, 10)

-- Auto Farm Button
local FarmBtn = Instance.new("TextButton", EventScroll)
FarmBtn.Size = UDim2.new(0.9, 0, 0, 70)
FarmBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 65)
FarmBtn.Text = "🌪️ AUTO FARM\nהפעלת חווה"
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
FarmBtn.Font = Enum.Font.GothamBlack
FarmBtn.TextSize = 14
FarmBtn.AutoButtonColor = false
Library:Corner(FarmBtn, 12)
Library:AddGlow(FarmBtn, Settings.Theme.WinterAccent)

local isFarming = false
FarmBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        FarmBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    else
        FarmBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 65)
    end
end)

-- Total Reds
local RedsLabel = Instance.new("TextLabel", EventScroll)
RedsLabel.Size = UDim2.new(0.9, 0, 0, 20)
RedsLabel.BackgroundTransparency = 1
RedsLabel.Text = "סה״כ אדומים 💎"
RedsLabel.TextColor3 = Settings.Theme.CrystalRed
RedsLabel.Font = Enum.Font.GothamBold
RedsLabel.TextSize = 12

local RedsBox = Instance.new("Frame", EventScroll)
RedsBox.Size = UDim2.new(0.9, 0, 0, 60)
RedsBox.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
Library:Corner(RedsBox, 12)
local RedsStroke = Instance.new("UIStroke", RedsBox)
RedsStroke.Color = Settings.Theme.CrystalRed
RedsStroke.Thickness = 2

local RedsVal = Instance.new("TextLabel", RedsBox)
RedsVal.Size = UDim2.new(1, 0, 1, 0)
RedsVal.BackgroundTransparency = 1
RedsVal.Text = "0"
RedsVal.TextColor3 = Color3.new(1, 1, 1)
RedsVal.Font = Enum.Font.GothamBlack
RedsVal.TextSize = 40

-- Total Blues
local BluesLabel = Instance.new("TextLabel", EventScroll)
BluesLabel.Size = UDim2.new(0.9, 0, 0, 20)
BluesLabel.BackgroundTransparency = 1
BluesLabel.Text = "סה״כ כחולים 🧊"
BluesLabel.TextColor3 = Settings.Theme.ShardBlue
BluesLabel.Font = Enum.Font.GothamBold
BluesLabel.TextSize = 12

local BluesBox = Instance.new("Frame", EventScroll)
BluesBox.Size = UDim2.new(0.9, 0, 0, 60)
BluesBox.BackgroundColor3 = Color3.fromRGB(15, 35, 55)
Library:Corner(BluesBox, 12)
local BluesStroke = Instance.new("UIStroke", BluesBox)
BluesStroke.Color = Settings.Theme.ShardBlue
BluesStroke.Thickness = 2

local BluesVal = Instance.new("TextLabel", BluesBox)
BluesVal.Size = UDim2.new(1, 0, 1, 0)
BluesVal.BackgroundTransparency = 1
BluesVal.Text = "0"
BluesVal.TextColor3 = Color3.new(1, 1, 1)
BluesVal.Font = Enum.Font.GothamBlack
BluesVal.TextSize = 40

-- Storm Session
local StormLabel = Instance.new("TextLabel", EventScroll)
StormLabel.Size = UDim2.new(0.9, 0, 0, 20)
StormLabel.BackgroundTransparency = 1
StormLabel.Text = "סה״כ סופה 🌩️"
StormLabel.TextColor3 = Settings.Theme.WinterAccent
StormLabel.Font = Enum.Font.GothamBold
StormLabel.TextSize = 12

local StormBox = Instance.new("Frame", EventScroll)
StormBox.Size = UDim2.new(0.9, 0, 0, 60)
StormBox.BackgroundColor3 = Color3.fromRGB(15, 30, 45)
Library:Corner(StormBox, 12)
local StormStroke = Instance.new("UIStroke", StormBox)
StormStroke.Color = Settings.Theme.WinterAccent
StormStroke.Thickness = 2

local StormVal = Instance.new("TextLabel", StormBox)
StormVal.Size = UDim2.new(1, 0, 1, 0)
StormVal.BackgroundTransparency = 1
StormVal.Text = "0"
StormVal.TextColor3 = Color3.new(1, 1, 1)
StormVal.Font = Enum.Font.GothamBlack
StormVal.TextSize = 40

--// 7. MAIN TAB
local MainScroll = Instance.new("ScrollingFrame", Tab_Main)
MainScroll.Size = UDim2.new(1, 0, 1, 0)
MainScroll.BackgroundTransparency = 1
MainScroll.ScrollBarThickness = 2
MainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local MainLayout = Instance.new("UIListLayout", MainScroll)
MainLayout.Padding = UDim.new(0, 12)
MainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local MainPad = Instance.new("UIPadding", MainScroll)
MainPad.PaddingTop = UDim.new(0, 10)

local TestBtn = Instance.new("TextButton", MainScroll)
TestBtn.Size = UDim2.new(0.9, 0, 0, 50)
TestBtn.BackgroundColor3 = Settings.Theme.Box
TestBtn.Text = "✈️ Fly"
TestBtn.TextColor3 = Color3.new(1, 1, 1)
TestBtn.Font = Enum.Font.GothamBold
TestBtn.TextSize = 16
Library:Corner(TestBtn, 8)
Library:AddGlow(TestBtn)

local TestBtn2 = Instance.new("TextButton", MainScroll)
TestBtn2.Size = UDim2.new(0.9, 0, 0, 50)
TestBtn2.BackgroundColor3 = Settings.Theme.Box
TestBtn2.Text = "💨 Speed"
TestBtn2.TextColor3 = Color3.new(1, 1, 1)
TestBtn2.Font = Enum.Font.GothamBold
TestBtn2.TextSize = 16
Library:Corner(TestBtn2, 8)
Library:AddGlow(TestBtn2)

--// 8. SETTINGS TAB
local SettingsScroll = Instance.new("ScrollingFrame", Tab_Settings)
SettingsScroll.Size = UDim2.new(1, 0, 1, 0)
Settings

