--[[
    Spaghetti Mafia Hub v1 (WINTER EVENT UPDATE)
    Branding: "עולם הכיף"
    Owner: NX3HO
    Updates: Ice Theme, Real-time Stats, Anti-AFK, Server-Hop Protection.
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

--// 1. מערכת Whitelist (בדיקה מול GitHub)
local WHITELIST_URL = "https://raw.githubusercontent.com/neho431/SpaghettiKeys/main/whitelist.txt"

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
        LocalPlayer:Kick("Spaghetti Mafia Hub: Connection Error (Whitelist)")
        return false
    end
end

if not CheckWhitelist() then return end

--// 2. ניקוי סקריפטים ישנים
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then
    CoreGui.SpaghettiHub_Rel:Destroy()
end

--// 3. מערכת Anti-AFK חזקה
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
    while task.wait(120) do -- מדמה לחיצה כל 2 דקות לביטחון מקסימלי
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

--// 4. הגנה מהעברת שרת
if hookmetamethod then
    local oldTeleport; oldTeleport = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if self == TeleportService and (method == "Teleport" or method == "TeleportToPlaceInstance") then
            return nil
        end
        return oldTeleport(self, ...)
    end)
end

--// 5. הגדרות ועיצוב
local Settings = {
    Theme = {
        Gold = Color3.fromRGB(255, 215, 0),
        Dark = Color3.fromRGB(10, 10, 10),
        Ice = Color3.fromRGB(0, 195, 255), -- צבע קרח
        Box = Color3.fromRGB(18, 18, 18),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Keys = { Menu = Enum.KeyCode.RightControl, Fly = Enum.KeyCode.E, Speed = Enum.KeyCode.F },
    Fly = { Enabled = false, Speed = 50 },
    Speed = { Enabled = false, Value = 16 },
    Farming = false, FarmSpeed = 300, Scale = 1
}

local VisualToggles = {}
local FarmBlacklist = {}

--// 6. ספרית עיצוב (Library)
local Library = {}
function Library:Tween(obj, props, time) TweenService:Create(obj, TweenInfo.new(time or 0.2), props):Play() end
function Library:Corner(obj, r) local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c end
function Library:AddGlow(obj, color) local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Theme.Gold; s.Thickness = 1; s.Transparency = 0.6; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; return s end
function Library:MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = obj.Position end end)
    obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    RunService.RenderStepped:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UIS.InputEnded:Connect(function(input) dragging = false end)
end

--// 7. בניית הממשק
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_Rel"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 600, 0, 400); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = Settings.Theme.Dark; MainFrame.ClipsDescendants = true; Library:Corner(MainFrame, 12); Library:AddGlow(MainFrame)
MainFrame.Size = UDim2.new(0,0,0,0); Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.6)

local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 160, 1, -60); Sidebar.Position = UDim2.new(0,0,0,60); Sidebar.BackgroundColor3 = Settings.Theme.Box; Library:Corner(Sidebar, 12)
local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0,10); SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local Container = Instance.new("Frame", MainFrame); Container.Size = UDim2.new(1, -170, 1, -70); Container.Position = UDim2.new(0, 170, 0, 65); Container.BackgroundTransparency = 1

local function CreateTab(name, heb, isIce)
    local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(0.9,0,0,40); btn.BackgroundColor3 = Settings.Theme.Dark
    btn.Text = (isIce and "❄️ " or "") .. name .. "\n<font size='11'>"..heb.."</font>"; btn.RichText = true; btn.TextColor3 = Color3.fromRGB(150,150,150); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; Library:Corner(btn, 6)
    if isIce then Library:AddGlow(btn, Settings.Theme.Ice) end
    
    local page = Instance.new("Frame", Container); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false
    local l = Instance.new("UIListLayout", page); l.Padding = UDim.new(0,12); l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then Library:Tween(v, {BackgroundColor3 = Settings.Theme.Dark, TextColor3 = Color3.fromRGB(150,150,150)}) end end
        for _,v in pairs(Container:GetChildren()) do v.Visible = false end
        Library:Tween(btn, {BackgroundColor3 = isIce and Settings.Theme.Ice or Settings.Theme.Gold, TextColor3 = Color3.new(0,0,0)})
        page.Visible = true
    end)
    return page, btn
end

local Tab_Event, EventBtn = CreateTab("Event", "אירוע חורף", true)
local Tab_Main = CreateTab("Main", "ראשי", false)
local Tab_Sett = CreateTab("Settings", "הגדרות", false)
local Tab_Cred = CreateTab("Credits", "קרדיטים", false)

--// 8. מוני סטטיסטיקה (NX3HO Stats)
local function CreateStatLabel(parent, labelText, defaultVal, color)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95,0,0,35); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 6)
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1,-20,1,0); t.Position = UDim2.new(0,10,0,0); t.BackgroundTransparency = 1; t.Text = labelText .. ": " .. defaultVal; t.TextColor3 = color or Color3.new(1,1,1); t.Font = Enum.Font.GothamBold; t.TextSize = 14; t.TextXAlignment = Enum.TextXAlignment.Left
    return t
end

local EventStatusLabel = CreateStatLabel(Tab_Event, "Event Status", "Idle", Settings.Theme.Ice)
local AfkStatusLabel = CreateStatLabel(Tab_Event, "Anti-AFK", "Active", Color3.fromRGB(0, 255, 150))
local CrystalLabel = CreateStatLabel(Tab_Event, "Crystals", "0", Settings.Theme.Gold)
local ShardLabel = CreateStatLabel(Tab_Event, "Shards", "0", Color3.fromRGB(200, 200, 200))

-- עדכון נתונים NX3HO
task.spawn(function()
    while task.wait(1) do
        local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer -- חיפוש גמיש
        local cry = stats:FindFirstChild("Crystals")
        local sha = stats:FindFirstChild("Shards")
        
        CrystalLabel.Text = "Crystals: " .. (cry and tostring(cry.Value) or "0")
        ShardLabel.Text = "Shards: " .. (sha and tostring(sha.Value) or "0")
        EventStatusLabel.Text = "Event Status: " .. (Settings.Farming and "Farming..." or "Idle")
    end
end)

--// 9. פונקציות רכיבים (Sliders/Toggles)
local function CreateSlider(parent, title, min, max, default, callback, toggleCallback, toggleName)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95,0,0,70); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.7,0,0,25); l.Position = UDim2.new(0,10,0,5); l.Text = title .. " : " .. default; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=13; l.BackgroundTransparency=1
    local line = Instance.new("Frame", f); line.Size = UDim2.new(0.9,0,0,10); line.Position = UDim2.new(0.05,0,0.7,0); line.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(line,5)
    local fill = Instance.new("Frame", line); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Settings.Theme.Gold; Library:Corner(fill,5)
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.MouseButton1Down:Connect(function() local move; move = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local r = math.clamp((i.Position.X - line.AbsolutePosition.X)/line.AbsoluteSize.X,0,1); fill.Size = UDim2.new(r,0,1,0); local v = math.floor(min+((max-min)*r)); l.Text = title.." : "..v; callback(v) end end) UIS.InputEnded:Connect(function() move:Disconnect() end) end)
    if toggleCallback then
        local t = Instance.new("TextButton", f); t.Size = UDim2.new(0,50,0,20); t.Position = UDim2.new(1,-60,0,8); t.BackgroundColor3 = Color3.fromRGB(40,40,40); t.Text = "OFF"; t.TextColor3 = Color3.new(1,1,1); Library:Corner(t,4); local on = false
        local function Update(s) on=s; t.Text=on and "ON" or "OFF"; t.BackgroundColor3=on and Settings.Theme.Gold or Color3.fromRGB(40,40,40); t.TextColor3=on and Color3.new(0,0,0) or Color3.new(1,1,1); toggleCallback(on) end
        t.MouseButton1Click:Connect(function() Update(not on) end)
        if toggleName then VisualToggles[toggleName] = Update end
    end
end

local function CreateBigToggle(parent, title, callback, toggleName, isIce)
    local f = Instance.new("TextButton", parent); f.Size = UDim2.new(0.95,0,0,45); f.BackgroundColor3 = Settings.Theme.Box; f.Text=""; Library:Corner(f, 8); Library:AddGlow(f, isIce and Settings.Theme.Ice or Color3.fromRGB(40,40,40))
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.8,0,1,0); l.Position = UDim2.new(0.05,0,0,0); l.Text=title; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextXAlignment="Left"; l.BackgroundTransparency=1
    local icon = Instance.new("Frame", f); icon.Size = UDim2.new(0,18,0,18); icon.Position = UDim2.new(0.9,-10,0.5,-9); icon.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(icon,4); local on = false
    local function Update(s) on=s; Library:Tween(icon,{BackgroundColor3=on and (isIce and Settings.Theme.Ice or Settings.Theme.Gold) or Color3.fromRGB(50,50,50)}); callback(on) end
    f.MouseButton1Click:Connect(function() Update(not on) end)
    if toggleName then VisualToggles[toggleName] = Update end
end

--// 10. לוגיקת Farming (Crystals)
local function ToggleFarm(v)
    Settings.Farming = v
    if v then
        task.spawn(function()
            while Settings.Farming do
                local drops = Workspace:FindFirstChild("StormDrops")
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and drops then
                    local target = nil; local dist = math.huge
                    for _, vk in pairs(drops:GetChildren()) do if vk:IsA("BasePart") and not FarmBlacklist[vk] then local m = (hrp.Position - vk.Position).Magnitude; if m < dist then dist = m; target = vk end end end
                    if target then
                        local tween = TweenService:Create(hrp, TweenInfo.new(dist/Settings.FarmSpeed, Enum.EasingStyle.Linear), {CFrame = target.CFrame})
                        tween:Play(); local start = tick()
                        while Settings.Farming and target.Parent and (tick() - start) < 2 do task.wait(0.1) end
                        if target.Parent then tween:Cancel(); FarmBlacklist[target] = true end
                    else task.wait(0.5) end
                end
                task.wait()
            end
        end)
    end
end

--// 11. הפעלה
CreateBigToggle(Tab_Event, "Auto Farm Crystals", function(v) ToggleFarm(v) end, "Farm", true)
CreateSlider(Tab_Main, "Walk Speed", 16, 250, 16, function(v) Settings.Speed.Value = v end, function(t) Settings.Speed.Enabled = t end, "Speed")
CreateSlider(Tab_Main, "Fly Speed", 20, 300, 50, function(v) Settings.Fly.Speed = v end, function(t) Settings.Fly.Enabled = t end, "Fly")

RunService.RenderStepped:Connect(function()
    if Settings.Speed.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed.Value
    end
end)

print("[SYSTEM] NX3HO Hub Winter Update Loaded.")
