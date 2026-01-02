--[[
    Spaghetti Mafia Hub v1 (ULTRA FINAL - GITHUB KEY SYSTEM)
    Branding: "עולם הכיף"
    Backend: GitHub Single-Use Key System (Repo: SpaghettiKeys)
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
local GH_TOKEN = "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"
local RAW_URL = "https://raw.githubusercontent.com/" .. GH_USER .. "/" .. GH_REPO .. "/main/" .. GH_FILE
local API_URL = "https://api.github.com/repos/" .. GH_USER .. "/" .. GH_REPO .. "/contents/" .. GH_FILE

--// פונקציית Base64 מלאה (קידוד)
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
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

--// הגדרות עיצוב בסיסיות למסך המפתח
local Theme = {
    Gold = Color3.fromRGB(255, 215, 0),
    Dark = Color3.fromRGB(10, 10, 10),
    Box = Color3.fromRGB(18, 18, 18),
    Text = Color3.fromRGB(255, 255, 255)
}

--// ספרית עיצוב פשוטה למסך המפתח
local Lib = {}
function Lib:Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end
function Lib:Corner(obj, r)
    local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c
end
function Lib:AddGlow(obj)
    local s = Instance.new("UIStroke", obj); s.Color = Theme.Gold; s.Thickness = 1; s.Transparency = 0.6; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

--// יצירת ממשק המפתח
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SpaghettiHub_Rel"; ScreenGui.Parent = CoreGui; ScreenGui.ResetOnSpawn = false

local KeyFrame = Instance.new("Frame", ScreenGui); KeyFrame.Size = UDim2.new(0, 400, 0, 260); KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -130); KeyFrame.BackgroundColor3 = Theme.Dark; Lib:Corner(KeyFrame, 10); Lib:AddGlow(KeyFrame)
local KeyTitle = Instance.new("TextLabel", KeyFrame); KeyTitle.Size = UDim2.new(1,0,0,40); KeyTitle.Position = UDim2.new(0,0,0,15); KeyTitle.BackgroundTransparency = 1; KeyTitle.Text = "SPAGHETTI MAFIA HUB <font color='#FFD700'>v1</font>"; KeyTitle.RichText = true; KeyTitle.Font = Enum.Font.GothamBlack; KeyTitle.TextSize = 24; KeyTitle.TextColor3 = Color3.new(1,1,1)
local KeySub = Instance.new("TextLabel", KeyFrame); KeySub.Size = UDim2.new(1,0,0,20); KeySub.Position = UDim2.new(0,0,0,45); KeySub.BackgroundTransparency = 1; KeySub.Text = "עולם הכיף"; KeySub.Font = Enum.Font.GothamBold; KeySub.TextSize = 16; KeySub.TextColor3 = Theme.Gold
local KeyInput = Instance.new("TextBox", KeyFrame); KeyInput.Size = UDim2.new(0.7,0,0,45); KeyInput.Position = UDim2.new(0.15,0,0.4,0); KeyInput.BackgroundColor3 = Theme.Box; KeyInput.TextColor3 = Color3.new(1,1,1); KeyInput.PlaceholderText = "Enter Key... / הכנס מפתח"; KeyInput.Text = ""; KeyInput.Font = Enum.Font.Gotham; KeyInput.TextSize = 14; Lib:Corner(KeyInput, 6)
local KeyBtn = Instance.new("TextButton", KeyFrame); KeyBtn.Size = UDim2.new(0.4,0,0,40); KeyBtn.Position = UDim2.new(0.3,0,0.75,0); KeyBtn.BackgroundColor3 = Theme.Gold; KeyBtn.Text = "LOGIN / כניסה"; KeyBtn.Font = Enum.Font.GothamBold; KeyBtn.TextSize = 16; Lib:Corner(KeyBtn, 6)

--// פונקציית אימות ומחיקה מ-GitHub
local function AuthenticateAndDestroy(inputKey)
    KeyBtn.Text = "CHECKING..."; KeyBtn.Active = false
    
    local success, allKeysRaw = pcall(function()
        return game:HttpGet(RAW_URL .. "?t=" .. tick())
    end)
    
    if not success or not allKeysRaw then KeyBtn.Text = "CONNECTION ERROR"; task.wait(2); KeyBtn.Text = "LOGIN / כניסה"; KeyBtn.Active = true; return false end
    
    local keyList = {}
    for key in allKeysRaw:gmatch("[^\r\n]+") do table.insert(keyList, key) end
    
    local foundIndex = table.find(keyList, inputKey)
    
    if foundIndex then
        table.remove(keyList, foundIndex)
        local newContent = table.concat(keyList, "\n")
        
        -- קבלת SHA לעדכון
        local shaRequest = HttpService:RequestAsync({
            Url = API_URL,
            Method = "GET",
            Headers = { ["Authorization"] = "token " .. GH_TOKEN }
        })
        
        if shaRequest.Success then
            local fileData = HttpService:JSONDecode(shaRequest.Body)
            local fileSHA = fileData.sha
            
            -- עדכון הקובץ (מחיקת המפתח)
            local update = HttpService:RequestAsync({
                Url = API_URL,
                Method = "PUT",
                Headers = {
                    ["Authorization"] = "token " .. GH_TOKEN,
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode({
                    message = "Key Used: " .. inputKey,
                    content = base64encode(newContent),
                    sha = fileSHA
                })
            })
            
            if update.Success then return true end
        end
        KeyBtn.Text = "SYNC ERROR"; task.wait(2); KeyBtn.Text = "LOGIN / כניסה"; KeyBtn.Active = true; return false
    else
        KeyBtn.Text = "INVALID KEY"; task.wait(2); KeyBtn.Text = "LOGIN / כניסה"; KeyBtn.Active = true; return false
    end
end

--// התחלת ה-Hub הראשי (כל הלוגיקה שלך כאן)
function StartHub()
    local Settings = {
        Theme = { Gold = Color3.fromRGB(255, 215, 0), Dark = Color3.fromRGB(10, 10, 10), Box = Color3.fromRGB(18, 18, 18), Text = Color3.fromRGB(255, 255, 255) },
        Keys = { Menu = Enum.KeyCode.RightControl, Fly = Enum.KeyCode.E, Speed = Enum.KeyCode.F },
        Fly = { Enabled = false, Speed = 50 },
        Speed = { Enabled = false, Value = 16 },
        Farming = false, FarmSpeed = 300, Scale = 1
    }

    local VisualToggles = {}
    local FarmConnection = nil
    local FarmBlacklist = {}
    local LastFullScan = 0

    --// ספרית עיצוב ל-Hub
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

    --// Anti-AFK & Teleport Protection
    LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
    local oldTeleport; if hookmetamethod then oldTeleport = hookmetamethod(game, "__namecall", function(self, ...) local method = getnamecallmethod(); if self == TeleportService and (method == "Teleport" or method == "TeleportToPlaceInstance") then return nil end return oldTeleport(self, ...) end) end

    --// GUI Structures
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
        if not currentTab then currentTab = btn; Library:Tween(btn, {BackgroundColor3 = Settings.Theme.Gold, TextColor3 = Color3.new(0,0,0)}); page.Visible = true end
        local l = Instance.new("UIListLayout", page); l.Padding = UDim.new(0,12); l.HorizontalAlignment = Enum.HorizontalAlignment.Center; local p = Instance.new("UIPadding", page); p.PaddingTop = UDim.new(0,10)
        return page
    end

    local Tab_Farm = CreateTab("Farming", "חווה"); local Tab_Main = CreateTab("Main", "ראשי"); local Tab_Sett = CreateTab("Settings", "הגדרות"); local Tab_Cred = CreateTab("Credits", "קרדיטים")

    --// Components Logic
    local function CreateSlider(parent, title, heb, min, max, default, callback, toggleCallback, toggleName, isDecimal)
        local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95,0,0,75); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.7,0,0,25); l.Position = UDim2.new(0,10,0,8); l.Text = title .. " <font size='12' color='#999999'>("..heb..")</font> : " .. default; l.RichText=true; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left; l.BackgroundTransparency=1
        local line = Instance.new("Frame", f); line.Size = UDim2.new(0.9,0,0,12); line.Position = UDim2.new(0.05,0,0.65,0); line.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(line,6)
        local fill = Instance.new("Frame", line); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Settings.Theme.Gold; Library:Corner(fill,6)
        local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
        btn.MouseButton1Down:Connect(function() local move; move = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local r = math.clamp((i.Position.X - line.AbsolutePosition.X)/line.AbsoluteSize.X,0,1); fill.Size = UDim2.new(r,0,1,0); local v = isDecimal and (math.floor((min+((max-min)*r))*100)/100) or math.floor(min+((max-min)*r)); l.Text = title.." <font size='12' color='#999999'>("..heb..")</font> : "..v; callback(v) if title == "Walk Speed" and Settings.Speed.Enabled and LocalPlayer.Character then local hum = LocalPlayer.Character:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = v end end end end) UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end) end)
        if toggleCallback then local t = Instance.new("TextButton", f); t.Size = UDim2.new(0,60,0,25); t.Position = UDim2.new(1,-70,0,8); t.BackgroundColor3 = Color3.fromRGB(40,40,40); t.Text = "OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.GothamBold; Library:Corner(t,4); local on = false; local function Update(s) on=s; t.Text=on and "ON" or "OFF"; t.BackgroundColor3=on and Settings.Theme.Gold or Color3.fromRGB(40,40,40); t.TextColor3=on and Color3.new(0,0,0) or Color3.new(1,1,1); toggleCallback(on); if title == "Walk Speed" and not on and LocalPlayer.Character then local hum = LocalPlayer.Character:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = 16 end end end; t.MouseButton1Click:Connect(function() Update(not on) end); if toggleName then VisualToggles[toggleName] = function(v) Update(v) end end end
    end

    local function CreateBigToggle(parent, title, heb, callback, toggleName)
        local f = Instance.new("TextButton", parent); f.Size = UDim2.new(0.95,0,0,50); f.BackgroundColor3 = Settings.Theme.Box; f.Text=""; f.AutoButtonColor=false; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.8,0,1,0); l.Position = UDim2.new(0.05,0,0,0); l.Text=title.."  <font size='12' color='#999999'>"..heb.."</font>"; l.RichText=true; l.TextColor3=Color3.new(1,1,1); l.Font=Enum.Font.GothamBold; l.TextSize=15; l.TextXAlignment=Enum.TextXAlignment.Left; l.BackgroundTransparency=1
        local icon = Instance.new("Frame", f); icon.Size = UDim2.new(0,20,0,20); icon.Position = UDim2.new(0.9,-10,0.5,-10); icon.BackgroundColor3 = Color3.fromRGB(50,50,50); Library:Corner(icon,5); local on = false
        local function Update(s) on=s; if on then Library:Tween(icon,{BackgroundColor3=Settings.Theme.Gold}); Library:AddGlow(f,Settings.Theme.Gold) else Library:Tween(icon,{BackgroundColor3=Color3.fromRGB(50,50,50)}); if f:FindFirstChild("UIStroke") then f.UIStroke:Destroy() end; Library:AddGlow(f,Color3.fromRGB(40,40,40)) end end
        f.MouseButton1Click:Connect(function() on=not on; Update(on); callback(on) end); if toggleName then VisualToggles[toggleName] = function(v) Update(v) end end
    end

    local function CreateSquareBind(parent, id, title, heb, default, callback)
        local f = Instance.new("TextButton", parent); local sizeY = id==3 and 60 or 80; f.Position = id==1 and UDim2.new(0,0,0,0) or (id==2 and UDim2.new(0.52,0,0,0) or UDim2.new(0,0,0,0)); f.Size = UDim2.new(id==3 and 1 or 0.48,0,0,sizeY); f.BackgroundColor3 = Settings.Theme.Box; f.Text=""; f.AutoButtonColor=false; Library:Corner(f, 8); Library:AddGlow(f, Color3.fromRGB(40,40,40))
        local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1,0,0,20); t.Position = UDim2.new(0,0,id==3 and 0.1 or 0.15,0); t.Text=title; t.TextColor3=Color3.fromRGB(150,150,150); t.Font=Enum.Font.Gotham; t.TextSize=13; t.BackgroundTransparency=1
        local h = Instance.new("TextLabel", f); h.Size = UDim2.new(1,0,0,15); h.Position = UDim2.new(0,0,0.35,0); h.Text=heb; h.TextColor3=Color3.fromRGB(100,100,100); h.Font=Enum.Font.Gotham; h.TextSize=11; h.BackgroundTransparency=1
        local k = Instance.new("TextLabel", f); k.Size = UDim2.new(1,0,0,30); k.Position = UDim2.new(0,0,id==3 and 0.5 or 0.6,0); k.Text=default.Name; k.TextColor3=Settings.Theme.Gold; k.Font=Enum.Font.GothamBold; k.TextSize=20; k.BackgroundTransparency=1
        f.MouseButton1Click:Connect(function() k.Text="..."; local i=UIS.InputBegan:Wait(); if i.UserInputType==Enum.UserInputType.Keyboard then k.Text=i.KeyCode.Name; callback(i.KeyCode) end end); return f
    end

    --// Farming Logic
    local function UltraSafeDisable()
        local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end
            local region = Region3.new(hrp.Position - Vector3.new(30,30,30), hrp.Position + Vector3.new(30,30,30))
            local objects = workspace:FindPartsInRegion3(region, nil, 200)
            for _, part in pairs(objects) do local n = part.Name:lower(); if n:find("door") or n:find("portal") or n:find("tele") or n:find("gate") or n:find("enter") or n:find("minigame") then part.CanTouch = false; pcall(function() if part:FindFirstChild("TouchInterest") then part.TouchInterest:Destroy() end end) end end
        end
    end

    local function ToggleFarm(v)
        Settings.Farming = v; if not v then FarmBlacklist = {} end
        if v then
            if not FarmConnection then FarmConnection = RunService.Stepped:Connect(function() if LocalPlayer.Character and Settings.Farming then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end; local hum = LocalPlayer.Character:FindFirstChild("Humanoid"); if hum then hum.Sit = false; hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end; UltraSafeDisable() end end) end
            task.spawn(function()
                while Settings.Farming do
                    local drops = Workspace:FindFirstChild("StormDrops"); local target = nil; local dist = math.huge; local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and drops then for _, v in pairs(drops:GetChildren()) do if v:IsA("BasePart") and not FarmBlacklist[v] then local m = (hrp.Position - v.Position).Magnitude; if m < dist then dist = m; target = v end end end end
                    if hrp and target then
                        local info = TweenInfo.new((hrp.Position - target.Position).Magnitude / Settings.FarmSpeed, Enum.EasingStyle.Linear); local tween = TweenService:Create(hrp, info, {CFrame = target.CFrame}); tween:Play(); local start = tick()
                        while Settings.Farming and target.Parent and (tick() - start) < 2 do task.wait(0.1); if (hrp.Position - target.Position).Magnitude < 3 then task.wait(0.3); if target.Parent then break end end end
                        if target.Parent then tween:Cancel(); FarmBlacklist[target] = true end
                    else task.wait(0.5) end; task.wait()
                end
            end)
        else if FarmConnection then FarmConnection:Disconnect(); FarmConnection = nil end; if LocalPlayer.Character then for _, p in pairs(LocalPlayer.Character:GetChildren()) do if p:IsA("BasePart") then p.CanTouch = true end end; if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end end end
    end

    local function ToggleFly(v)
        Settings.Fly.Enabled = v; local char = LocalPlayer.Character; if not char then return end; local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChild("Humanoid")
        if v then
            local bv = Instance.new("BodyVelocity",hrp); bv.MaxForce=Vector3.new(1e9,1e9,1e9); bv.Name="F_V"; local bg = Instance.new("BodyGyro",hrp); bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bg.P=9e4; bg.Name="F_G"; hum.PlatformStand=true
            task.spawn(function() while Settings.Fly.Enabled and char.Parent do local cam = workspace.CurrentCamera; local d = Vector3.zero; if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end; if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end; bv.Velocity = d * Settings.Fly.Speed; bg.CFrame = cam.CFrame; RunService.Heartbeat:Wait() end; if hrp:FindFirstChild("F_V") then hrp.F_V:Destroy() end; if hrp:FindFirstChild("F_G") then hrp.F_G:Destroy() end; hum.PlatformStand=false end)
        else if hrp:FindFirstChild("F_V") then hrp.F_V:Destroy() end; if hrp:FindFirstChild("F_G") then hrp.F_G:Destroy() end; hum.PlatformStand=false end
    end

    --// Build Tabs
    CreateBigToggle(Tab_Farm, "Auto Farm Crystals", "חווה אוטומטית לקריסטלים (Anti-Stuck 2s)", function(v) ToggleFarm(v) end, "Farm")
    CreateSlider(Tab_Main, "Walk Speed", "מהירות הליכה", 16, 250, 16, function(v) Settings.Speed.Value = v end, function(t) Settings.Speed.Enabled = t end, "Speed")
    CreateSlider(Tab_Main, "Fly Speed", "מהירות תעופה", 20, 300, 50, function(v) Settings.Fly.Speed = v end, function(t) ToggleFly(t) end, "Fly")
    local BindCont = Instance.new("Frame", Tab_Main); BindCont.Size = UDim2.new(0.95,0,0,80); BindCont.BackgroundTransparency = 1; CreateSquareBind(BindCont, 1, "FLY", "תעופה", Settings.Keys.Fly, function(k) Settings.Keys.Fly = k end); CreateSquareBind(BindCont, 2, "SPEED", "מהירות", Settings.Keys.Speed, function(k) Settings.Keys.Speed = k end)
    CreateSlider(Tab_Sett, "FOV", "שדה ראייה", 70, 120, 70, function(v) Camera.FieldOfView = v end); CreateSlider(Tab_Sett, "GUI Scale", "גודל ממשק", 0.5, 1.5, 1, function(v) MainScale.Scale = v end, nil, nil, true)
    local MenuBindCont = Instance.new("Frame", Tab_Sett); MenuBindCont.Size = UDim2.new(0.95,0,0,70); MenuBindCont.BackgroundTransparency = 1; CreateSquareBind(MenuBindCont, 3, "MENU KEY", "מקש תפריט", Settings.Keys.Menu, function(k) Settings.Keys.Menu = k end)

    local function AddCr(n, id)
        local f = Instance.new("Frame", Tab_Cred); f.Size = UDim2.new(0.95,0,0,100); f.BackgroundColor3 = Settings.Theme.Box; Library:Corner(f, 12); Library:AddGlow(f); local i = Instance.new("ImageLabel", f); i.Size = UDim2.new(0,80,0,80); i.Position = UDim2.new(0,10,0.5,-40); i.Image = "rbxthumb://type=AvatarHeadShot&id="..id.."&w=150&h=150"; Library:Corner(i, 40); local t = Instance.new("TextLabel", f); t.Size = UDim2.new(0,350,0,30); t.Position = UDim2.new(0,100,0,20); t.Text = n .. " <font color='#AAAAAA'>(יוצרים)</font>"; t.RichText=true; t.TextColor3 = Settings.Theme.Gold; t.Font=Enum.Font.GothamBlack; t.TextSize=22; t.TextXAlignment="Left"; t.BackgroundTransparency=1; local b = Instance.new("TextButton", f); b.Size = UDim2.new(0,140,0,30); b.Position = UDim2.new(0,100,0,55); b.BackgroundColor3 = Color3.fromRGB(88,101,242); b.Text="Copy Discord"; b.TextColor3=Color3.new(1,1,1); Library:Corner(b,6); b.TextSize=13; b.MouseButton1Click:Connect(function() setclipboard(n); b.Text="Copied!"; task.wait(1); b.Text="Copy Discord" end)
    end
    AddCr("nx3ho", 1323665023); AddCr("8adshot3", 3370067928)

    --// Final Binds & Main Speed Render Loop
    UIS.InputBegan:Connect(function(i,g) if not g then
        if i.KeyCode == Settings.Keys.Menu then if MainFrame.Visible then Library:Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back); task.wait(0.3); MainFrame.Visible = false else MainFrame.Visible = true; MainFrame.Size = UDim2.new(0,0,0,0); Library:Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.5, Enum.EasingStyle.Elastic) end end
        if i.KeyCode == Settings.Keys.Fly then Settings.Fly.Enabled = not Settings.Fly.Enabled; ToggleFly(Settings.Fly.Enabled); if VisualToggles["Fly"] then VisualToggles["Fly"](Settings.Fly.Enabled) end end
        if i.KeyCode == Settings.Keys.Speed then Settings.Speed.Enabled = not Settings.Speed.Enabled; if VisualToggles["Speed"] then VisualToggles["Speed"](Settings.Speed.Enabled) end end
    end end)
    RunService.RenderStepped:Connect(function() if Settings.Speed.Enabled and LocalPlayer.Character then local h = LocalPlayer.Character:FindFirstChild("Humanoid") if h then h.WalkSpeed = Settings.Speed.Value end end end)
end

print("System Authenticated via GitHub.")
