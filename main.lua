--[[
    Spaghetti Mafia Hub v1 (COMPACT LOAD + SWAPPED LAYOUT + STRONG AFK)
    Updates:
    - Compact Loading Screen (Small box in center)
    - Layout Swapped: Total Balance is now ABOVE Session Stats
    - Super Strong Anti-AFK (Physical Jump + Input every 60s)
    - Winter Theme maintained
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

--// 2. ניקוי
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then CoreGui.SpaghettiHub_Rel:Destroy() end
if CoreGui:FindFirstChild("SpaghettiLoading") then CoreGui.SpaghettiLoading:Destroy() end

--// 3. מסך טעינה קומפקטי (Compact Loading)
local LoadGui = Instance.new("ScreenGui"); LoadGui.Name = "SpaghettiLoading"; LoadGui.Parent = CoreGui
local LoadBox = Instance.new("Frame", LoadGui)
LoadBox.Size = UDim2.new(0, 220, 0, 160)
LoadBox.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadBox.AnchorPoint = Vector2.new(0.5, 0.5)
LoadBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LoadBox.BorderSizePixel = 0

-- עיצוב למסך טעינה
local BoxStroke = Instance.new("UIStroke", LoadBox)
BoxStroke.Color = Color3.fromRGB(255, 215, 0) -- זהב
BoxStroke.Thickness = 2

local BoxCorner = Instance.new("UICorner", LoadBox); BoxCorner.CornerRadius = UDim.new(0, 12)

local PastaIcon = Instance.new("TextLabel", LoadBox)
PastaIcon.Size = UDim2.new(1, 0, 0.6, 0); PastaIcon.Position = UDim2.new(0,0,0.1,0)
PastaIcon.BackgroundTransparency = 1; PastaIcon.Text = "🍝"; PastaIcon.TextSize = 60
PastaIcon.TextYAlignment = Enum.TextYAlignment.Center

local TitleLoad = Instance.new("TextLabel", LoadBox)
TitleLoad.Size = UDim2.new(1, 0, 0.2, 0); TitleLoad.Position = UDim2.new(0, 0, 0.65, 0)
TitleLoad.BackgroundTransparency = 1; TitleLoad.Text = "Spaghetti Mafia Hub v1"
TitleLoad.Font = Enum.Font.GothamBold; TitleLoad.TextColor3 = Color3.new(1,1,1); TitleLoad.TextSize = 14

local SubLoad = Instance.new("TextLabel", LoadBox)
SubLoad.Size = UDim2.new(1, 0, 0.2, 0); SubLoad.Position = UDim2.new(0, 0, 0.8, 0)
SubLoad.BackgroundTransparency = 1; SubLoad.Text = "Loading..."
SubLoad.Font = Enum.Font.Gotham; SubLoad.TextColor3 = Color3.fromRGB(255, 215, 0); SubLoad.TextSize = 12

-- אנימציה קטנה
task.spawn(function()
    local t = 0
    while LoadBox.Parent do
        t = t + 0.1
        PastaIcon.Rotation = math.sin(t*2) * 10
        SubLoad.TextTransparency = 0.5 + (math.sin(t*5) * 0.5)
        task.wait(0.05)
    end
end)

task.wait(2) -- זמן המתנה
LoadGui:Destroy()

--// 4. הגדרות
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
        WinterAccent = Color3.fromRGB(100, 220, 255)
    },
    Keys = { Menu = Enum.KeyCode.RightControl, Fly = Enum.KeyCode.E, Speed = Enum.KeyCode.F },
    Fly = { Enabled = false, Speed = 50 },
    Speed = { Enabled = false, Value = 16 },
    Farming = false,
    FarmSpeed = 450,
    Scale = 1
}

--// 5. SUPER STRONG ANTI-AFK (פיזי + וירטואלי)
-- מנגנון חזק שרץ ברקע כל הזמן
task.spawn(function()
    while true do
        task.wait(60) -- כל דקה בדיוק
        pcall(function()
            -- 1. שליחת קלט וירטואלי
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            
            -- 2. ביצוע קפיצה פיזית (הכי בטוח נגד ניתוק)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if not Settings.Farming then -- רק אם לא בחווה (כי החווה כבר זזה)
                    LocalPlayer.Character.Humanoid.Jump = true
                end
            end
        end)
    end
end)

-- חסימת טלפורט שרת
local oldTeleport
if hookmetamethod then
    oldTeleport = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if self == TeleportService and (method == "Teleport" or method == "TeleportToPlaceInstance" or method == "TeleportToSpawnByName") then
            return nil
        end
        return oldTeleport(self, ...)
    end)
end

local FarmConnection = nil
local FarmBlacklist = {}
local LastFullScan = 0
local VisualToggles = {}

--// 6. ספריית עיצוב
local Library = {}
function Library:Tween(obj, props, time, style) TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play() end
function Library:AddGlow(obj, color) local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Theme.Gold; s.Thickness = 1.2; s.Transparency = 0.5; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; return s end
function Library:AddTextGlow(obj, color) local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Theme.Gold; s.Thickness = 0.6; s.Transparency = 0.7; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual end
function Library:Corner(obj, r) local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c end
function Library:MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = obj.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    RunService.RenderStepped:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end

--// 7. GUI ראשי
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_Rel"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false

local MiniPasta = Instance.new("TextButton", ScreenGui); MiniPasta.Size = UDim2.new(0, 60, 0, 60); MiniPasta.Position = UDim2.new(0.1, 0, 0.1, 0); MiniPasta.BackgroundColor3 = Settings.Theme.Dark; MiniPasta.Text = "🍝"; MiniPasta.TextSize = 35; MiniPasta.Visible = false; Library:Corner(MiniPasta, 30); Library:AddGlow(MiniPasta); Library:MakeDraggable(MiniPasta)

local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 600, 0, 400); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = Settings.Theme.Dark; MainFrame.ClipsDescendants = true; Library:Corner(MainFrame, 16); Library:AddGlow(MainFrame)
MainFrame.Size = UDim2.new(0,0,0,0); Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.6, Enum.EasingStyle.Elastic) -- אנימציית פתיחה

local MainScale = Instance.new("UIScale", MainFrame); MainScale.Scale = 1
local TopBar = Instance.new("Frame", MainFrame); TopBar.Size = UDim2.new(1,0,0,60); TopBar.BackgroundTransparency = 1; Library:MakeDraggable(MainFrame)
local MinBtn = Instance.new("TextButton", TopBar); MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(0, 10, 0, 10); MinBtn.BackgroundColor3 = Settings.Theme.Box; MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.TextSize = 25; Library:Corner(MinBtn, 8); Library:AddGlow(MinBtn, Color3.fromRGB(60,60,60))
MinBtn.MouseButton1Click:Connect(function() Library:Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back); task.wait(0.3); MainFrame.Visible = false; MiniPasta.Visible = true; Library:Tween(MiniPasta, {Size = UDim2.new(0, 60, 0, 60)}, 0.4, Enum.EasingStyle.Elastic) end)
local pds = Vector2.zero; MiniPasta.MouseButton1Down:Connect(function() pds = UIS:GetMouseLocation() end)
MiniPasta.MouseButton1Up:Connect(function() if (UIS:GetMouseLocation() - pds).Magnitude < 5 then Library:Tween(MiniPasta, {Size = UDim2.new(0,0,0,0)}, 0.2); task.wait(0.2); MiniPasta.Visible = false; MainFrame.Visible = true; Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.4, Enum.EasingStyle.Back) end end)

local MainTitle = Instance.new("TextLabel", TopBar); MainTitle.Size = UDim2.new(0,300,0,30); MainTitle.Position = UDim2.new(0,50,0,10); MainTitle.BackgroundTransparency = 1; MainTitle.Text = "SPAGHETTI <font color='#FFD700'>MAFIA</font> HUB v1"; MainTitle.RichText = true; MainTitle.Font = Enum.Font.GothamBlack; MainTitle.TextSize = 20; MainTitle.TextColor3 = Color3.new(1,1,1); MainTitle.TextXAlignment = Enum.TextXAlignment.Left; Library:AddTextGlow(MainTitle)
local MainSub = Instance.new("TextLabel", TopBar); MainSub.Size = UDim2.new(0,300,0,20); MainSub.Position = UDim2.new(0,50,0,32); MainSub.BackgroundTransparency = 1; MainSub.Text = "עולם הכיף"; MainSub.Font = Enum.Font.GothamBold; MainSub.TextSize = 13; MainSub.TextColor3 = Settings.Theme.Gold; MainSub.TextXAlignment = Enum.TextXAlignment.Left

local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 160, 1, -60); Sidebar.Position = UDim2.new(0,0,0,60); Sidebar.BackgroundColor3 = Settings.Theme.Box; Sidebar.BorderSizePixel = 0; Sidebar.ZIndex = 2; Library:Corner(Sidebar, 12)
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

local function AddLayout(p) local l = Instance.new("UIListLayout", p); l.Padding = UDim.new(0,12); l.HorizontalAlignment = Enum.HorizontalAlignment.Center; local pad = Instance.new("UIPadding", p); pad.PaddingTop = UDim.new(0,10) end
AddLayout(Tab_Main); AddLayout(Tab_Sett); AddLayout(Tab_Cred)

--// 8. Farm Logic
local function GetClosestTarget()
    local drops = Workspace:FindFirstChild("StormDrops"); if not drops then return nil end
    local closest, dist = nil, math.huge; local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then for _, v in pairs(drops:GetChildren()) do if v:IsA("BasePart") and not FarmBlacklist[v] then local mag = (hrp.Position - v.Position).Magnitude; if mag < dist then dist = mag; closest = v end end end end
    return closest
end

local function UltraSafeDisable()
    local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end
    local region = Region3.new(hrp.Position - Vector3.new(30,30,30), hrp.Position + Vector3.new(30,30,30))
    local objects = workspace:FindPartsInRegion3(region, nil, 200)
    for _, part in pairs(objects) do
        local n = part.Name:lower()
        if n:find("door") or n:find("portal") or n:find("tele") or n:find("gate") or n:find("enter") or n:find("selection") or n:find("lobby") or n:find("zone") or n:find("minigame") then
            part.CanTouch = false; pcall(function() if part:FindFirstChild("TouchInterest") then part.TouchInterest:Destroy() end end)
        end
    end
    if tick() - LastFullScan > 5 then LastFullScan = tick(); task.spawn(function() for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and obj.Name:lower():find("door") then obj.CanTouch = false; pcall(function() if obj:FindFirstChild("TouchInterest") then obj.TouchInterest:Destroy() end end) end end end) end
end

local function ToggleFarm(v)
    Settings.Farming = v; if not v then FarmBlacklist = {} end
    if not FarmConnection and v then
        FarmConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character and Settings.Farming then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
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
                        if (tick() - start) > 1.8 then tween:Cancel(); FarmBlacklist[target] = true; break end
                        if (hrp.Position - target.Position).Magnitude < 5 then target.CanTouch = true end
                    until (tick() - start) > (distance / Settings.FarmSpeed) + 0.1
                else task.wait(0.2) end
                task.wait()
            end
        end)
    end
end

--// 9. EVENT TAB - WINTER THEME + NEW LAYOUT
local Tab_Farm_Scroll = Instance.new("ScrollingFrame", Tab_Farm_Page)
Tab_Farm_Scroll.Size = UDim2.new(1, 0, 1, 0); Tab_Farm_Scroll.BackgroundTransparency = 1; Tab_Farm_Scroll.ScrollBarThickness = 2; Tab_Farm_Scroll.ScrollBarImageColor3 = Settings.Theme.WinterAccent; Tab_Farm_Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Tab_Farm_Scroll.BorderSizePixel = 0
local EventGradient = Instance.new("UIGradient", Tab_Farm_Page); EventGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 40, 60)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 35))}; EventGradient.Rotation = 45
local EventLayout = Instance.new("UIListLayout", Tab_Farm_Scroll); EventLayout.Padding = UDim.new(0, 15); EventLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; EventLayout.SortOrder = Enum.SortOrder.LayoutOrder; local EventPad = Instance.new("UIPadding", Tab_Farm_Scroll); EventPad.PaddingTop = UDim.new(0,10)

-- 1. Farm Button
local FarmBtn = Instance.new("TextButton", Tab_Farm_Scroll); FarmBtn.Size = UDim2.new(0.95, 0, 0, 70); FarmBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 70); FarmBtn.Text = ""; FarmBtn.LayoutOrder = 1; Library:Corner(FarmBtn, 12); Library:AddGlow(FarmBtn, Settings.Theme.WinterAccent)
local FarmTitle = Instance.new("TextLabel", FarmBtn); FarmTitle.Size = UDim2.new(1, -60, 1, 0); FarmTitle.Position = UDim2.new(0, 20, 0, 0); FarmTitle.Text = "Toggle Auto Farm ❄️\n<font size='13' color='#87CEFA'>הפעלת חווה אוטומטית</font>"; FarmTitle.RichText = true; FarmTitle.TextColor3 = Color3.new(1,1,1); FarmTitle.Font = Enum.Font.GothamBlack; FarmTitle.TextSize = 18; FarmTitle.TextXAlignment = Enum.TextXAlignment.Left; FarmTitle.BackgroundTransparency = 1
local FarmSwitch = Instance.new("Frame", FarmBtn); FarmSwitch.Size = UDim2.new(0, 40, 0, 25); FarmSwitch.Position = UDim2.new(1, -60, 0.5, -12.5); FarmSwitch.BackgroundColor3 = Color3.fromRGB(40, 40, 60); Library:Corner(FarmSwitch, 20)
local FarmDot = Instance.new("Frame", FarmSwitch); FarmDot.Size = UDim2.new(0, 21, 0, 21); FarmDot.Position = UDim2.new(0, 2, 0.5, -10.5); FarmDot.BackgroundColor3 = Color3.fromRGB(180, 200, 220); Library:Corner(FarmDot, 20)
local isFarming = false
FarmBtn.MouseButton1Click:Connect(function() isFarming = not isFarming; ToggleFarm(isFarming); if isFarming then Library:Tween(FarmSwitch,{BackgroundColor3=Settings.Theme.WinterAccent}); Library:Tween(FarmDot,{Position=UDim2.new(1,-23,0.5,-10.5)}) else Library:Tween(FarmSwitch,{BackgroundColor3=Color3.fromRGB(40,40,60)}); Library:Tween(FarmDot,{Position=UDim2.new(0,2,0.5,-10.5)}) end end)

-- 2. Strong AFK Status
local AFKStatus = Instance.new("TextLabel", Tab_Farm_Scroll); AFKStatus.Size = UDim2.new(0.95, 0, 0, 20); AFKStatus.BackgroundTransparency = 1; AFKStatus.Text = "Strong AFK System: <font color='#00FF00'>Active (Jumper)</font> ⚡"; AFKStatus.RichText = true; AFKStatus.TextColor3 = Color3.new(1, 1, 1); AFKStatus.Font = Enum.Font.GothamMedium; AFKStatus.TextSize = 13; AFKStatus.LayoutOrder = 2

-- 3. TOTAL BALANCE (עבר לפה! למעלה!)
local BalanceLabel = Instance.new("TextLabel", Tab_Farm_Scroll); BalanceLabel.Size = UDim2.new(0.95,0,0,25); BalanceLabel.Text = "Total Balance (סה''כ בתיק) 💰"; BalanceLabel.TextColor3 = Color3.fromRGB(255, 215, 0); BalanceLabel.Font=Enum.Font.GothamBlack; BalanceLabel.TextSize=14; BalanceLabel.BackgroundTransparency=1; BalanceLabel.LayoutOrder = 3

local BalanceContainer = Instance.new("Frame", Tab_Farm_Scroll); BalanceContainer.Size = UDim2.new(0.95, 0, 0, 70); BalanceContainer.BackgroundTransparency = 1; BalanceContainer.LayoutOrder = 4
local BalanceGrid = Instance.new("UIGridLayout", BalanceContainer); BalanceGrid.CellSize = UDim2.new(0.48, 0, 1, 0); BalanceGrid.CellPadding = UDim2.new(0.04, 0, 0, 0); BalanceGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TotShards = Instance.new("Frame", BalanceContainer); TotShards.BackgroundColor3 = Settings.Theme.Box; Library:Corner(TotShards, 8); Library:AddGlow(TotShards, Settings.Theme.ShardBlue)
local T_TitleS = Instance.new("TextLabel", TotShards); T_TitleS.Size = UDim2.new(1,0,0.3,0); T_TitleS.BackgroundTransparency=1; T_TitleS.Text="Total Shards"; T_TitleS.TextColor3=Settings.Theme.ShardBlue; T_TitleS.Font=Enum.Font.GothamBold; T_TitleS.TextSize=12; T_TitleS.TextYAlignment=Enum.TextYAlignment.Bottom
local T_ValS = Instance.new("TextLabel", TotShards); T_ValS.Size = UDim2.new(1,0,0.7,0); T_ValS.Position=UDim2.new(0,0,0.3,0); T_ValS.BackgroundTransparency=1; T_ValS.Text="..."; T_ValS.TextColor3=Color3.new(1,1,1); T_ValS.Font=Enum.Font.GothamMedium; T_ValS.TextSize=18; T_ValS.TextYAlignment=Enum.TextYAlignment.Top

local TotCrystals = Instance.new("Frame", BalanceContainer); TotCrystals.BackgroundColor3 = Settings.Theme.Box; Library:Corner(TotCrystals, 8); Library:AddGlow(TotCrystals, Settings.Theme.CrystalRed)
local T_TitleC = Instance.new("TextLabel", TotCrystals); T_TitleC.Size = UDim2.new(1,0,0.3,0); T_TitleC.BackgroundTransparency=1; T_TitleC.Text="Total Crystals"; T_TitleC.TextColor3=Settings.Theme.CrystalRed; T_TitleC.Font=Enum.Font.GothamBold; T_TitleC.TextSize=12; T_TitleC.TextYAlignment=Enum.TextYAlignment.Bottom
local T_ValC = Instance.new("TextLabel", TotCrystals); T_ValC.Size = UDim2.new(1,0,0.7,0); T_ValC.Position=UDim2.new(0,0,0.3,0); T_ValC.BackgroundTransparency=1; T_ValC.Text="..."; T_ValC.TextColor3=Color3.new(1,1,1); T_ValC.Font=Enum.Font.GothamMedium; T_ValC.TextSize=18; T_ValC.TextYAlignment=Enum.TextYAlignment.Top

-- 4. SESSION COLLECTED (עבר לפה! למטה!)
local StatsLabel = Instance.new("TextLabel", Tab_Farm_Scroll); StatsLabel.Size = UDim2.new(0.95,0,0,20); StatsLabel.Text = "Session Collected (איסוף נוכחי) 📥"; StatsLabel.TextColor3 = Color3.fromRGB(200,230,255); StatsLabel.Font=Enum.Font.GothamBold; StatsLabel.TextSize=12; StatsLabel.BackgroundTransparency=1; StatsLabel.LayoutOrder = 5

local StatsContainer = Instance.new("Frame", Tab_Farm_Scroll); StatsContainer.Size = UDim2.new(0.95, 0, 0, 85); StatsContainer.BackgroundTransparency = 1; StatsContainer.LayoutOrder = 6
local StatsGrid = Instance.new("UIGridLayout", StatsContainer); StatsGrid.CellSize = UDim2.new(0.48, 0, 1, 0); StatsGrid.CellPadding = UDim2.new(0.04, 0, 0, 0); StatsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local BoxBlue = Instance.new("Frame", StatsContainer); BoxBlue.BackgroundColor3 = Color3.fromRGB(15, 30, 50); Library:Corner(BoxBlue, 12); local StrokeBlue = Instance.new("UIStroke", BoxBlue); StrokeBlue.Color = Settings.Theme.WinterAccent; StrokeBlue.Thickness = 1.2; StrokeBlue.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local TitleBlue = Instance.new("TextLabel", BoxBlue); TitleBlue.Size = UDim2.new(1, 0, 0.3, 0); TitleBlue.Position = UDim2.new(0,0,0.1,0); TitleBlue.BackgroundTransparency = 1; TitleBlue.Text = "Shards 🧊"; TitleBlue.TextColor3 = Settings.Theme.WinterAccent; TitleBlue.Font = Enum.Font.GothamBold; TitleBlue.TextSize = 16
local ValBlue = Instance.new("TextLabel", BoxBlue); ValBlue.Size = UDim2.new(1, 0, 0.5, 0); ValBlue.Position = UDim2.new(0,0,0.45,0); ValBlue.BackgroundTransparency = 1; ValBlue.Text = "0"; ValBlue.TextColor3 = Color3.new(1, 1, 1); ValBlue.Font = Enum.Font.GothamBlack; ValBlue.TextSize = 30

local BoxRed = Instance.new("Frame", StatsContainer); BoxRed.BackgroundColor3 = Color3.fromRGB(30, 15, 15); Library:Corner(BoxRed, 12); local StrokeRed = Instance.new("UIStroke", BoxRed); StrokeRed.Color = Settings.Theme.CrystalRed; StrokeRed.Thickness = 1.2; StrokeRed.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local TitleRed = Instance.new("TextLabel", BoxRed); TitleRed.Size = UDim2.new(1, 0, 0.3, 0); TitleRed.Position = UDim2.new(0,0,0.1,0); TitleRed.BackgroundTransparency = 1; TitleRed.Text = "Crystals 💎"; TitleRed.TextColor3 = Settings.Theme.CrystalRed; TitleRed.Font = Enum.Font.GothamBold; TitleRed.TextSize = 16
local ValRed = Instance.new("TextLabel", BoxRed); ValRed.Size = UDim2.new(1, 0, 0.5, 0); ValRed.Position = UDim2.new(0,0,0.45,0); ValRed.BackgroundTransparency = 1; ValRed.Text = "0"; ValRed.TextColor3 = Color3.new(1, 1, 1); ValRed.Font = Enum.Font.GothamBlack; ValRed.TextSize = 30

-- 5. SUMMARY
local SummaryFrame = Instance.new("Frame", Tab_Farm_Scroll); SummaryFrame.Size = UDim2.new(0.95, 0, 0, 60); SummaryFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 45); SummaryFrame.LayoutOrder = 7; Library:Corner(SummaryFrame, 8); Library:AddGlow(SummaryFrame, Settings.Theme.WinterAccent)
local SumLayout = Instance.new("UIListLayout", SummaryFrame); SumLayout.Padding = UDim.new(0, 4); SumLayout.VerticalAlignment = Enum.VerticalAlignment.Center
local PadSum = Instance.new("UIPadding", SummaryFrame); PadSum.PaddingLeft = UDim.new(0, 15)
local TxtLastStorm = Instance.new("TextLabel", SummaryFrame); TxtLastStorm.Size = UDim2.new(1, 0, 0.45, 0); TxtLastStorm.BackgroundTransparency = 1; TxtLastStorm.Text = "Last Storm: 0 🌩️"; TxtLastStorm.TextColor3 = Color3.fromRGB(220, 240, 255); TxtLastStorm.Font = Enum.Font.Gotham; TxtLastStorm.TextSize = 14; TxtLastStorm.TextXAlignment = Enum.TextXAlignment.Left
local TxtTotalSession = Instance.new("TextLabel", SummaryFrame); TxtTotalSession.Size = UDim2.new(1, 0, 0.45, 0); TxtTotalSession.BackgroundTransparency = 1; TxtTotalSession.Text = "Session Total: 0 📦"; TxtTotalSession.TextColor3 = Settings.Theme.WinterAccent; TxtTotalSession.Font = Enum.Font.GothamBold; TxtTotalSession.TextSize = 14; TxtTotalSession.TextXAlignment = Enum.TextXAlignment.Left

-- Data Loop
task.spawn(function()
    local CrystalsRef = LocalPlayer:WaitForChild("Crystals", 10); local ShardsRef = LocalPlayer:WaitForChild("Shards", 10)
    if not CrystalsRef or not ShardsRef then return end
    local InitC = CrystalsRef.Value; local InitS = ShardsRef.Value
    local LastC = InitC; local LastS = InitS; local StormC = 0; local StormS = 0
    while true do
        task.wait(0.5)
        pcall(function()
            local CurC = CrystalsRef.Value; local CurS = ShardsRef.Value
            local SesC = CurC - InitC; local SesS = CurS - InitS
            if SesC < 0 then SesC = 0 end; if SesS < 0 then SesS = 0 end
            ValRed.Text = tostring(SesC); ValBlue.Text = tostring(SesS)
            T_ValC.Text = tostring(CurC); T_ValS.Text = tostring(CurS)
            if CurC > LastC then StormC = StormC + (CurC - LastC) elseif CurC < LastC then StormC = 0 end
            if CurS > LastS then StormS = StormS + (CurS - LastS) elseif CurS < LastS then StormS = 0 end
            LastC = CurC; LastS = CurS
            TxtLastStorm.Text = "Last Storm: "..(StormC+StormS).." 🌩️"; TxtTotalSession.Text = "Session Total: "..(SesC+SesS).." 📦"
        end)
    end
end)

--// Extra Tabs Content
local function CreateSlider(parent, title, heb, min, max, default, callback)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95,0,0,75); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.7,0,0,25); l.Position = UDim2.new(0,10,0,8); l.Text = title .. " ("..heb..") : " .. default; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.BackgroundTransparency=1
    local line = Instance.new("Frame", f); line.Size = UDim2.new(0.9,0,0,12); line.Position = UDim2.new(0.05,0,0.65,0); line.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(line,6)
    local fill = Instance.new("Frame", line); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Settings.Theme.Gold; Library:Corner(fill,6)
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.MouseButton1Down:Connect(function() local move = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then local r = math.clamp((i.Position.X - line.AbsolutePosition.X)/line.AbsoluteSize.X,0,1); fill.Size = UDim2.new(r,0,1,0); local v = math.floor(min+((max-min)*r)); l.Text = title.." ("..heb..") : "..v; callback(v) end end); UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then move:Disconnect() end end) end)
end

CreateSlider(Tab_Main, "Walk Speed", "מהירות", 16, 250, 16, function(v) Settings.Speed.Value = v; if Settings.Speed.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end)
CreateSlider(Tab_Sett, "FOV", "שדה ראייה", 70, 120, 70, function(v) Camera.FieldOfView = v end)

--// Credits
local function AddCr(n, id)
    local f = Instance.new("Frame", Tab_Cred); f.Size = UDim2.new(0.95,0,0,100); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 12); Library:AddGlow(f)
    local i = Instance.new("ImageLabel", f); i.Size = UDim2.new(0,80,0,80); i.Position = UDim2.new(0,10,0.5,-40); i.Image = "rbxthumb://type=AvatarHeadShot&id="..id.."&w=150&h=150"; Library:Corner(i, 40)
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(0,350,0,30); t.Position = UDim2.new(0,100,0,20); t.Text = n; t.TextColor3 = Settings.Theme.Gold; t.Font=Enum.Font.GothamBlack; t.TextSize=22; t.TextXAlignment="Left"; t.BackgroundTransparency=1
end
AddCr("nx3ho", 1323665023); AddCr("8adshot3", 3370067928)

--// Toggle Key
UIS.InputBegan:Connect(function(i,g) if not g and i.KeyCode == Settings.Keys.Menu then if MainFrame.Visible then Library:Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back); task.wait(0.3); MainFrame.Visible = false else MainFrame.Visible = true; MainFrame.Size = UDim2.new(0,0,0,0); Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.5, Enum.EasingStyle.Elastic) end end end)

print("Spaghetti Mafia Loaded")
