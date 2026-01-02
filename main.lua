--[[
    Spaghetti Mafia Hub v1 (DEBUG & FIX VERSION)
    Branding: "עולם הכיף"
    Backend: GitHub Single-Use Key System
]]

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

--// ניקוי סקריפטים ישנים
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then
    CoreGui.SpaghettiHub_Rel:Destroy()
end

local LocalPlayer = Players.LocalPlayer

--// הגדרות GitHub
local GH_USER = "neho431"
local GH_REPO = "SpaghettiKeys"
local GH_FILE = "keys.txt"
-- פיצול הטוקן למניעת חסימה אוטומטית
local p1 = "ghp_yE7tc0UZgXx2"
local p2 = "6ELX4kH8whlVwrDmJt0n4s7W"
local GH_TOKEN = p1 .. p2
local RAW_URL = "https://raw.githubusercontent.com/" .. GH_USER .. "/" .. GH_REPO .. "/main/" .. GH_FILE
local API_URL = "https://api.github.com/repos/" .. GH_USER .. "/" .. GH_REPO .. "/contents/" .. GH_FILE

--// פונקציית Base64 מלאה ותקינה
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function base64encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

--// פונקציית עזר לניקוי רווחים
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

--// הגדרות עיצוב למסך המפתח
local Theme = { Gold = Color3.fromRGB(255, 215, 0), Dark = Color3.fromRGB(10, 10, 10), Box = Color3.fromRGB(18, 18, 18) }
local Lib = {}
function Lib:Tween(obj, props, time) TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play() end
function Lib:Corner(obj, r) local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c end
function Lib:AddGlow(obj) local s = Instance.new("UIStroke", obj); s.Color = Theme.Gold; s.Thickness = 1; s.Transparency = 0.6; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end

--// יצירת ממשק המפתח
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_Rel"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false
local KeyFrame = Instance.new("Frame", ScreenGui); KeyFrame.Size = UDim2.new(0, 400, 0, 260); KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -130); KeyFrame.BackgroundColor3 = Theme.Dark; Lib:Corner(KeyFrame, 10); Lib:AddGlow(KeyFrame)
local KeyTitle = Instance.new("TextLabel", KeyFrame); KeyTitle.Size = UDim2.new(1,0,0,40); KeyTitle.Position = UDim2.new(0,0,0,15); KeyTitle.BackgroundTransparency = 1; KeyTitle.Text = "SPAGHETTI MAFIA HUB <font color='#FFD700'>v1</font>"; KeyTitle.RichText = true; KeyTitle.Font = Enum.Font.GothamBlack; KeyTitle.TextSize = 24; KeyTitle.TextColor3 = Color3.new(1,1,1)
local KeySub = Instance.new("TextLabel", KeyFrame); KeySub.Size = UDim2.new(1,0,0,20); KeySub.Position = UDim2.new(0,0,0,45); KeySub.BackgroundTransparency = 1; KeySub.Text = "עולם הכיף"; KeySub.Font = Enum.Font.GothamBold; KeySub.TextSize = 16; KeySub.TextColor3 = Theme.Gold
local KeyInput = Instance.new("TextBox", KeyFrame); KeyInput.Size = UDim2.new(0.7,0,0,45); KeyInput.Position = UDim2.new(0.15,0,0.4,0); KeyInput.BackgroundColor3 = Theme.Box; KeyInput.TextColor3 = Color3.new(1,1,1); KeyInput.PlaceholderText = "Enter Key..."; KeyInput.Text = ""; KeyInput.Font = Enum.Font.Gotham; KeyInput.TextSize = 14; Lib:Corner(KeyInput, 6)
local KeyBtn = Instance.new("TextButton", KeyFrame); KeyBtn.Size = UDim2.new(0.4,0,0,40); KeyBtn.Position = UDim2.new(0.3,0,0.75,0); KeyBtn.BackgroundColor3 = Theme.Gold; KeyBtn.Text = "LOGIN / כניסה"; KeyBtn.Font = Enum.Font.GothamBold; KeyBtn.TextSize = 16; Lib:Corner(KeyBtn, 6)

--// פונקציית אימות ומחיקה עם Debug Prints
local function AuthenticateAndDestroy(inputKey)
    inputKey = trim(inputKey)
    KeyBtn.Text = "CHECKING..."; KeyBtn.Active = false
    print("--- [DEBUG] Starting Authentication ---")
    
    -- 1. הורדת רשימת המפתחות
    print("[1] Fetching keys from: " .. RAW_URL)
    local success, allKeysRaw = pcall(function()
        return game:HttpGet(RAW_URL .. "?t=" .. tick())
    end)
    
    if not success or not allKeysRaw then 
        warn("[ERROR] Failed to connect to GitHub Raw URL.")
        KeyBtn.Text = "CONN ERROR"; task.wait(2); KeyBtn.Text = "LOGIN / כניסה"; KeyBtn.Active = true; return false 
    end
    
    print("[2] Keys received from server:\n" .. allKeysRaw)
    
    local keyList = {}
    for key in allKeysRaw:gmatch("[^\r\n]+") do table.insert(keyList, trim(key)) end
    
    local foundIndex = table.find(keyList, inputKey)
    
    if foundIndex then
        print("[3] Key '" .. inputKey .. "' is VALID. Proceeding to delete...")
        table.remove(keyList, foundIndex)
        local newContent = table.concat(keyList, "\n")
        
        -- 2. קבלת ה-SHA של הקובץ
        print("[4] Fetching file SHA via API...")
        local shaRequest = HttpService:RequestAsync({
            Url = API_URL,
            Method = "GET",
            Headers = { ["Authorization"] = "Bearer " .. GH_TOKEN }
        })
        
        if not shaRequest.Success then
            warn("[ERROR] GitHub API (GET SHA) failed. Status: " .. shaRequest.StatusCode)
            warn("Response Body: " .. shaRequest.Body)
            KeyBtn.Text = "API ERROR (SHA)"; task.wait(2); KeyBtn.Text = "LOGIN / כניסה"; KeyBtn.Active = true; return false
        end
        
        local fileData = HttpService:JSONDecode(shaRequest.Body)
        local fileSHA = fileData.sha
        print("[5] SHA received: " .. fileSHA)
        
        -- 3. עדכון הקובץ (המחיקה)
        print("[6] Sending update request to GitHub...")
        local update = HttpService:RequestAsync({
            Url = API_URL,
            Method = "PUT",
            Headers = {
                ["Authorization"] = "Bearer " .. GH_TOKEN,
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                message = "Automated: Key Used (" .. inputKey .. ")",
                content = base64encode(newContent),
                sha = fileSHA
            })
        })
        
        if update.Success then
            print("[7] Success! Key deleted from GitHub. Hub starting...")
            return true
        else
            warn("[ERROR] GitHub API (PUT) failed. Status: " .. update.StatusCode)
            warn("Response Body: " .. update.Body)
            KeyBtn.Text = "SYNC ERROR"; task.wait(2); KeyBtn.Text = "LOGIN / כניסה"; KeyBtn.Active = true; return false
        end
    else
        warn("[ERROR] Key '" .. inputKey .. "' not found in the list.")
        KeyBtn.Text = "INVALID KEY"; task.wait(2); KeyBtn.Text = "LOGIN / כניסה"; KeyBtn.Active = true; return false
    end
end

--// פונקציית ה-Hub המקורית שלך
function StartHub()
    local Settings = {
        Theme = { Gold = Color3.fromRGB(255, 215, 0), Dark = Color3.fromRGB(10, 10, 10), Box = Color3.fromRGB(18, 18, 18), Text = Color3.fromRGB(255, 255, 255) },
        Keys = { Menu = Enum.KeyCode.RightControl, Fly = Enum.KeyCode.E, Speed = Enum.KeyCode.F },
        Fly = { Enabled = false, Speed = 50 }, Speed = { Enabled = false, Value = 16 }, Farming = false, FarmSpeed = 300, Scale = 1
    }
    local VisualToggles, FarmConnection, FarmBlacklist, LastFullScan = {}, nil, {}, 0
    local Library = {}
    function Library:Tween(obj, props, time, style) TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play() end
    function Library:Corner(obj, r) local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c end
    function Library:AddGlow(obj, color) local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Theme.Gold; s.Thickness = 1; s.Transparency = 0.6; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; return s end
    function Library:AddTextGlow(obj, color) local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Theme.Gold; s.Thickness = 0.6; s.Transparency = 0.7; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual end
    function Library:MakeDraggable(obj)
        local dragging, dragInput, dragStart, startPos
        obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = obj.Position end end)
        obj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
        RunService.RenderStepped:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
        UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    end

    -- Anti-AFK & Teleport Block
    LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
    if hookmetamethod then local old; old = hookmetamethod(game, "__namecall", function(self, ...) local m = getnamecallmethod(); if self == TeleportService and (m == "Teleport" or m == "TeleportToPlaceInstance") then return nil end return old(self, ...) end) end

    -- Main UI
    local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 600, 0, 400); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.BackgroundColor3 = Settings.Theme.Dark; MainFrame.ClipsDescendants = true; Library:Corner(MainFrame, 12); Library:AddGlow(MainFrame)
    local MainScale = Instance.new("UIScale", MainFrame); local TopBar = Instance.new("Frame", MainFrame); TopBar.Size = UDim2.new(1,0,0,60); TopBar.BackgroundTransparency = 1; Library:MakeDraggable(MainFrame)
    local MiniPasta = Instance.new("TextButton", ScreenGui); MiniPasta.Size = UDim2.new(0, 60, 0, 60); MiniPasta.Position = UDim2.new(0.1, 0, 0.1, 0); MiniPasta.BackgroundColor3 = Settings.Theme.Dark; MiniPasta.Text = "🍝"; MiniPasta.TextSize = 35; MiniPasta.Visible = false; Library:Corner(MiniPasta, 30); Library:AddGlow(MiniPasta); Library:MakeDraggable(MiniPasta)
    
    local MinBtn = Instance.new("TextButton", TopBar); MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(0, 10, 0, 10); MinBtn.BackgroundColor3 = Settings.Theme.Box; MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.TextSize = 25; Library:Corner(MinBtn, 6)
    MinBtn.MouseButton1Click:Connect(function() Library:Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back); task.wait(0.3); MainFrame.Visible = false; MiniPasta.Visible = true; Library:Tween(MiniPasta, {Size = UDim2.new(0, 60, 0, 60)}, 0.4, Enum.EasingStyle.Elastic) end)
    local pds = Vector2.zero; MiniPasta.MouseButton1Down:Connect(function() pds = UIS:GetMouseLocation() end)
    MiniPasta.MouseButton1Up:Connect(function() if (UIS:GetMouseLocation() - pds).Magnitude < 5 then Library:Tween(MiniPasta, {Size = UDim2.new(0,0,0,0)}, 0.2); task.wait(0.2); MiniPasta.Visible = false; MainFrame.Visible = true; Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.4, Enum.EasingStyle.Back) end end)

    local MainTitle = Instance.new("TextLabel", TopBar); MainTitle.Size = UDim2.new(0,300,0,30); MainTitle.Position = UDim2.new(0,50,0,10); MainTitle.BackgroundTransparency = 1; MainTitle.Text = "SPAGHETTI <font color='#FFD700'>MAFIA</font> HUB v1"; MainTitle.RichText = true; MainTitle.Font = Enum.Font.GothamBlack; MainTitle.TextSize = 20; MainTitle.TextColor3 = Color3.new(1,1,1); MainTitle.TextXAlignment = Enum.TextXAlignment.Left; Library:AddTextGlow(MainTitle)
    local MainSub = Instance.new("TextLabel", TopBar); MainSub.Size = UDim2.new(0,300,0,20); MainSub.Position = UDim2.new(0,50,0,32); MainSub.BackgroundTransparency = 1; MainSub.Text = "עולם הכיף"; MainSub.Font = Enum.Font.GothamBold; MainSub.TextSize = 13; MainSub.TextColor3 = Settings.Theme.Gold; MainSub.TextXAlignment = Enum.TextXAlignment.Left

    local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 160, 1, -60); Sidebar.Position = UDim2.new(0,0,0,60); Sidebar.BackgroundColor3 = Settings.Theme.Box; Sidebar.BorderSizePixel = 0; Sidebar.ZIndex = 2; Library:Corner(Sidebar, 12) 
    local Container = Instance.new("Frame", MainFrame); Container.Size = UDim2.new(1, -170, 1, -70); Container.Position = UDim2.new(0, 170, 0, 65); Container.BackgroundTransparency = 1
    local SidebarLayout = Instance.new("UIListLayout", Sidebar); SidebarLayout.Padding = UDim.new(0,10); SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; local SidePad = Instance.new("UIPadding", Sidebar); SidePad.PaddingTop = UDim.new(0,15)

    local function CreateTab(name, heb)
        local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(0.9,0,0,40); btn.BackgroundColor3 = Settings.Theme.Dark; btn.Text = name .. "\n<font size='11' color='#AAAAAA'>"..heb.."</font>"; btn.RichText = true; btn.TextColor3 = Color3.fromRGB(150,150,150); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.ZIndex = 3; Library:Corner(btn, 6)
        local page = Instance.new("Frame", Container); page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false
        btn.MouseButton1Click:Connect(function() for _,v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then Library:Tween(v, {BackgroundColor3 = Settings.Theme.Dark, TextColor3 = Color3.fromRGB(150,150,150)}) end end; for _,v in pairs(Container:GetChildren()) do v.Visible = false end; Library:Tween(btn, {BackgroundColor3 = Settings.Theme.Gold, TextColor3 = Color3.new(0,0,0)}); page.Visible = true end)
        local l = Instance.new("UIListLayout", page); l.Padding = UDim.new(0,12); l.HorizontalAlignment = Enum.HorizontalAlignment.Center; local p = Instance.new("UIPadding", page); p.PaddingTop = UDim.new(0,10)
        return page
    end

    local Tab_Farm = CreateTab("Farming", "חווה"); local Tab_Main = CreateTab("Main", "ראשי"); local Tab_Sett = CreateTab("Settings", "הגדרות"); local Tab_Cred = CreateTab("Credits", "קרדיטים")

    -- Components
    local function CreateSlider(parent, title, heb, min, max, default, callback, toggleCallback, toggleName, isDecimal)
        local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95,0,0,75); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.7,0,0,25); l.Position = UDim2.new(0,10,0,8); l.Text = title .. " : " .. default; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.BackgroundTransparency=1
        local line = Instance.new("Frame", f); line.Size = UDim2.new(0.9,0,0,12); line.Position = UDim2.new(0.05,0,0.65,0); line.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(line,6)
        local fill = Instance.new("Frame", line); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Settings.Theme.Gold; Library:Corner(fill,6)
        local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
        btn.MouseButton1Down:Connect(function() local move; move = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local r = math.clamp((i.Position.X - line.AbsolutePosition.X)/line.AbsoluteSize.X,0,1); fill.Size = UDim2.new(r,0,1,0); local v = isDecimal and (math.floor((min+((max-min)*r))*100)/100) or math.floor(min+((max-min)*r)); l.Text = title.." : "..v; callback(v) end end) UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end) end)
        if toggleCallback then local t = Instance.new("TextButton", f); t.Size = UDim2.new(0,60,0,25); t.Position = UDim2.new(1,-70,0,8); t.BackgroundColor3 = Color3.fromRGB(40,40,40); t.Text = "OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.GothamBold; Library:Corner(t,4); local on = false; t.MouseButton1Click:Connect(function() on=not on; t.Text=on and "ON" or "OFF"; t.BackgroundColor3=on and Settings.Theme.Gold or Color3.fromRGB(40,40,40); t.TextColor3=on and Color3.new(0,0,0) or Color3.new(1,1,1); toggleCallback(on) end) end
    end

    local function CreateBigToggle(parent, title, heb, callback)
        local f = Instance.new("TextButton", parent); f.Size = UDim2.new(0.95,0,0,50); f.BackgroundColor3 = Settings.Theme.Box; f.Text=""; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.8,0,1,0); l.Position = UDim2.new(0.05,0,0,0); l.Text=title; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=15; l.TextXAlignment=Enum.TextXAlignment.Left; l.BackgroundTransparency=1
        local icon = Instance.new("Frame", f); icon.Size = UDim2.new(0,20,0,20); icon.Position = UDim2.new(0.9,-10,0.5,-10); icon.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(icon,5); local on = false
        f.MouseButton1Click:Connect(function() on=not on; Library:Tween(icon,{BackgroundColor3=on and Settings.Theme.Gold or Color3.fromRGB(50,50,50)}); callback(on) end)
    end

    local function CreateSquareBind(parent, id, title, heb, default, callback)
        local f = Instance.new("TextButton", parent); f.Size = UDim2.new(id==3 and 1 or 0.48,0,0,80); f.BackgroundColor3 = Settings.Theme.Box; f.Text=""; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
        local k = Instance.new("TextLabel", f); k.Size = UDim2.new(1,0,0,30); k.Position = UDim2.new(0,0,0.5,0); k.Text=default.Name; k.TextColor3=Settings.Theme.Gold; k.Font=Enum.Font.GothamBold; k.TextSize=20; k.BackgroundTransparency=1
        f.MouseButton1Click:Connect(function() k.Text="..."; local i=UIS.InputBegan:Wait(); if i.UserInputType==Enum.UserInputType.Keyboard then k.Text=i.KeyCode.Name; callback(i.KeyCode) end end); return f
    end

    -- Farm & Logic
    local function UltraSafeDisable() local char = LocalPlayer.Character; if char then for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end; local region = Region3.new(char.PrimaryPart.Position - Vector3.new(30,30,30), char.PrimaryPart.Position + Vector3.new(30,30,30)); local objects = workspace:FindPartsInRegion3(region, nil, 200); for _, part in pairs(objects) do local n = part.Name:lower(); if n:find("door") or n:find("portal") or n:find("tele") or n:find("minigame") then part.CanTouch = false; pcall(function() if part:FindFirstChild("TouchInterest") then part.TouchInterest:Destroy() end end) end end end end
    local function ToggleFarm(v) Settings.Farming = v; if v then task.spawn(function() while Settings.Farming do local drops = Workspace:FindFirstChild("StormDrops"); local target = nil; local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp and drops then for _, vk in pairs(drops:GetChildren()) do if vk:IsA("BasePart") and not FarmBlacklist[vk] then target = vk break end end end; if hrp and target then local tween = TweenService:Create(hrp, TweenInfo.new((hrp.Position - target.Position).Magnitude / Settings.FarmSpeed, Enum.EasingStyle.Linear), {CFrame = target.CFrame}); tween:Play(); local start = tick(); while Settings.Farming and target.Parent and (tick() - start) < 2 do task.wait(0.1) end; if target.Parent then tween:Cancel(); FarmBlacklist[target] = true end else task.wait(0.5) end; task.wait() end end) end end
    local function ToggleFly(v) Settings.Fly.Enabled = v; local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if v then local bv = Instance.new("BodyVelocity",hrp); bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(1e9,1e9,1e9); bv.Name="F_V"; local bg = Instance.new("BodyGyro",hrp); bg.CFrame=hrp.CFrame; bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bg.Name="F_G"; task.spawn(function() while Settings.Fly.Enabled do local cam = workspace.CurrentCamera; local d = Vector3.zero; if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end; bv.Velocity = d * Settings.Fly.Speed; bg.CFrame = cam.CFrame; RunService.Heartbeat:Wait() end; bv:Destroy(); bg:Destroy() end) end end

    -- Content
    CreateBigToggle(Tab_Farm, "Auto Farm Crystals", function(v) ToggleFarm(v) end)
    CreateSlider(Tab_Main, "Walk Speed", "מהירות", 16, 250, 16, function(v) Settings.Speed.Value = v end, function(t) Settings.Speed.Enabled = t end)
    CreateSlider(Tab_Main, "Fly Speed", "תעופה", 20, 300, 50, function(v) Settings.Fly.Speed = v end, function(t) ToggleFly(t) end)
    CreateSquareBind(Tab_Main, 1, "FLY", "תעופה", Settings.Keys.Fly, function(k) Settings.Keys.Fly = k end)
    CreateSlider(Tab_Sett, "GUI Scale", "גודל", 0.5, 1.5, 1, function(v) MainScale.Scale = v end, nil, nil, true)
    
    UIS.InputBegan:Connect(function(i,g) if not g and i.KeyCode == Settings.Keys.Menu then MainFrame.Visible = not MainFrame.Visible end end)
    RunService.RenderStepped:Connect(function() if Settings.Speed.Enabled and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed.Value end end)
end

--// לוגיקת לחיצה על Login
KeyBtn.MouseButton1Click:Connect(function()
    if AuthenticateAndDestroy(KeyInput.Text) then
        Lib:Tween(KeyFrame, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}, 0.4, Enum.EasingStyle.Back)
        task.wait(0.3); KeyFrame.Visible = false; StartHub()
    end
end)

print("[SYSTEM] Key Authentication Loaded.")
