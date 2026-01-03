--[[
    Spaghetti Mafia Hub v1 (EMERGENCY FIX)
    - Removed Start Animations (Fixes "Black Screen/Nothing" bug)
    - Whitelist: Active
    - Logic: Safe Farm + Session Stats (Red/Blue)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// 1. Whitelist System (Safe Mode)
local WHITELIST_URL = "https://raw.githubusercontent.com/neho431/SpaghettiKeys/main/whitelist.txt"
local function CheckWhitelist()
    print("Checking Whitelist...")
    local success, content = pcall(function()
        return game:HttpGet(WHITELIST_URL .. "?t=" .. tick())
    end)
    if success and content then
        if string.find(content, LocalPlayer.Name) then
            print("Whitelist PASSED for: " .. LocalPlayer.Name)
            return true
        end
    end
    -- אם נכשל - זורק את השחקן
    LocalPlayer:Kick("Not Whitelisted / Connection Fail")
    return false
end

if not CheckWhitelist() then return end

--// ניקוי
if CoreGui:FindFirstChild("SpaghettiHub_Rel") then
    CoreGui.SpaghettiHub_Rel:Destroy()
end

--// הגדרות
local Settings = {
    Theme = {
        Gold = Color3.fromRGB(255, 215, 0),
        Dark = Color3.fromRGB(15, 15, 15),
        Box = Color3.fromRGB(25, 25, 25),
        Text = Color3.fromRGB(255, 255, 255),
        Red = Color3.fromRGB(255, 80, 80),
        Blue = Color3.fromRGB(80, 180, 255)
    },
    Farming = false,
    FarmSpeed = 120
}

local Library = {}
function Library:Corner(obj, r)
    local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r or 6); return c
end
function Library:AddGlow(obj, color)
    local s = Instance.new("UIStroke", obj); s.Color = color or Settings.Theme.Gold; s.Thickness = 1; s.Transparency = 0.5; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; return s
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

--// GUI Creation - SIMPLE & DIRECT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpaghettiHub_Rel"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- כפתור הקטנה
local MiniPasta = Instance.new("TextButton", ScreenGui)
MiniPasta.Size = UDim2.new(0, 50, 0, 50); MiniPasta.Position = UDim2.new(0.1, 0, 0.1, 0)
MiniPasta.BackgroundColor3 = Settings.Theme.Dark; MiniPasta.Text = "🍝"; MiniPasta.TextSize = 30; MiniPasta.Visible = false
Library:Corner(MiniPasta, 25); Library:MakeDraggable(MiniPasta)

-- מסגרת ראשית (גודל מלא מיד!)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 400) -- גודל קבוע
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200) -- מרכז מסך
MainFrame.BackgroundColor3 = Settings.Theme.Dark
MainFrame.Visible = true -- גלוי מיד
Library:Corner(MainFrame, 12); Library:AddGlow(MainFrame); Library:MakeDraggable(MainFrame)

-- כפתור סגירה
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(0, 10, 0, 10)
CloseBtn.BackgroundColor3 = Settings.Theme.Box; CloseBtn.Text = "-"; CloseBtn.TextColor3 = Color3.new(1,1,1)
Library:Corner(CloseBtn, 5)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false; MiniPasta.Visible = true
end)
MiniPasta.MouseButton1Click:Connect(function()
    MainFrame.Visible = true; MiniPasta.Visible = false
end)

-- כותרת
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0, 300, 0, 30); Title.Position = UDim2.new(0, 50, 0, 10)
Title.Text = "SPAGHETTI MAFIA HUB (Fixed)"; Title.TextColor3 = Settings.Theme.Gold; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 18; Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

-- אזור תוכן
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -60); Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1

local List = Instance.new("UIListLayout", Container); List.Padding = UDim.new(0, 15); List.HorizontalAlignment = Enum.HorizontalAlignment.Center

--// ---------------- LOGIC ---------------- //

-- Farm Toggle Button
local FarmBtn = Instance.new("TextButton", Container)
FarmBtn.Size = UDim2.new(0.95, 0, 0, 60)
FarmBtn.BackgroundColor3 = Settings.Theme.Box
FarmBtn.Text = "Toggle Auto Farm (OFF)"
FarmBtn.TextColor3 = Settings.Theme.Red
FarmBtn.Font = Enum.Font.GothamBold; FarmBtn.TextSize = 18
Library:Corner(FarmBtn, 8); Library:AddGlow(FarmBtn, Settings.Theme.Red)

-- Logic Functions
local FarmBlacklist = {}
local function GetClosestTarget()
    local drops = game.Workspace:FindFirstChild("StormDrops")
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

local function UltraSafeDisable()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = false end end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local region = Region3.new(hrp.Position - Vector3.new(30,30,30), hrp.Position + Vector3.new(30,30,30))
        local parts = game.Workspace:FindPartsInRegion3(region, nil, 100)
        for _, v in pairs(parts) do
            local n = v.Name:lower()
            if n:find("door") or n:find("portal") or n:find("tele") or n:find("gate") then
                v.CanTouch = false
                pcall(function() v.TouchInterest:Destroy() end)
            end
        end
    end
end

local function ToggleFarm(v)
    Settings.Farming = v
    FarmBtn.Text = v and "Toggle Auto Farm (ON)" or "Toggle Auto Farm (OFF)"
    FarmBtn.TextColor3 = v and Settings.Theme.Gold or Settings.Theme.Red
    Library:AddGlow(FarmBtn, v and Settings.Theme.Gold or Settings.Theme.Red)
    
    if not v then FarmBlacklist = {} end
    if v then
        task.spawn(function()
            while Settings.Farming do
                pcall(function()
                    if LocalPlayer.Character then
                        -- Noclip & Anti Sit
                        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do 
                            if p:IsA("BasePart") then p.CanCollide = false end 
                        end
                        if LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.Sit = false
                        end
                        UltraSafeDisable()
                        
                        -- Farm Movement
                        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local target = GetClosestTarget()
                        
                        if hrp and target then
                            local dist = (hrp.Position - target.Position).Magnitude
                            local info = TweenInfo.new(dist / Settings.FarmSpeed, Enum.EasingStyle.Linear)
                            local tw = TweenService:Create(hrp, info, {CFrame = target.CFrame})
                            tw:Play()
                            
                            local s = tick()
                            while Settings.Farming and target.Parent and (tick() - s) < 1.5 do
                                task.wait()
                                if (hrp.Position - target.Position).Magnitude < 10 then
                                    if firetouchinterest then firetouchinterest(target, hrp, 0); firetouchinterest(target, hrp, 1) end
                                    target.CanTouch = true
                                end
                            end
                            if target.Parent then tw:Cancel(); FarmBlacklist[target] = true end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end

FarmBtn.MouseButton1Click:Connect(function() ToggleFarm(not Settings.Farming) end)

-- Anti-AFK Text
local AfkLbl = Instance.new("TextLabel", Container)
AfkLbl.Size = UDim2.new(0.95,0,0,20); AfkLbl.Text = "Anti-AFK Active"; AfkLbl.TextColor3 = Color3.new(0.7,0.7,0.7); AfkLbl.BackgroundTransparency = 1; AfkLbl.Font = Enum.Font.Gotham

-- Stats (Squares)
local StatsFrame = Instance.new("Frame", Container)
StatsFrame.Size = UDim2.new(0.95, 0, 0, 100); StatsFrame.BackgroundTransparency = 1
local Grid = Instance.new("UIGridLayout", StatsFrame); Grid.CellSize = UDim2.new(0.48, 0, 1, 0)

local function MakeBox(col, txt)
    local f = Instance.new("Frame", StatsFrame); f.BackgroundColor3 = Settings.Theme.Box
    Library:Corner(f, 8); Library:AddGlow(f, col)
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1,0,0.3,0); t.Text = txt; t.TextColor3 = col; t.Font=Enum.Font.GothamBold; t.BackgroundTransparency=1
    local v = Instance.new("TextLabel", f); v.Size = UDim2.new(1,0,0.7,0); v.Position=UDim2.new(0,0,0.3,0); v.Text="..."; v.TextColor3=Color3.new(1,1,1); v.Font=Enum.Font.GothamBlack; v.TextSize=25; v.BackgroundTransparency=1
    return v
end

local ValCrystals = MakeBox(Settings.Theme.Red, "Crystals")
local ValShards = MakeBox(Settings.Theme.Blue, "Shards")

-- Summary
local SumLbl = Instance.new("TextLabel", Container)
SumLbl.Size = UDim2.new(0.95,0,0,30); SumLbl.Text = "Waiting for data..."; SumLbl.TextColor3 = Color3.new(1,1,1); SumLbl.BackgroundTransparency = 1; SumLbl.Font = Enum.Font.Gotham

-- Logic Data
task.spawn(function()
    -- Safe Wait
    local C_Obj = LocalPlayer:WaitForChild("Crystals", 10) or LocalPlayer:WaitForChild("crystals", 5)
    local S_Obj = LocalPlayer:WaitForChild("Shards", 10) or LocalPlayer:WaitForChild("shards", 5)
    
    if not C_Obj or not S_Obj then
        SumLbl.Text = "Error: Could not find Crystals/Shards on LocalPlayer!"
        return
    end
    
    local InitCry = C_Obj.Value
    local InitShrd = S_Obj.Value
    local LastCry = C_Obj.Value
    local LastShrd = S_Obj.Value
    local StormTotal = 0
    
    while true do
        task.wait(1)
        local CurrCry = C_Obj.Value
        local CurrShrd = S_Obj.Value
        
        -- Session Only
        local SessCry = math.max(0, CurrCry - InitCry)
        local SessShrd = math.max(0, CurrShrd - InitShrd)
        
        ValCrystals.Text = tostring(SessCry)
        ValShards.Text = tostring(SessShrd)
        
        -- Storm Logic
        if CurrCry > LastCry then StormTotal = StormTotal + (CurrCry - LastCry) end
        if CurrShrd > LastShrd then StormTotal = StormTotal + (CurrShrd - LastShrd) end
        
        LastCry = CurrCry
        LastShrd = CurrShrd
        
        SumLbl.Text = "Session Total: " .. (SessCry+SessShrd) .. " | Storm: " .. StormTotal
    end
end)

print("Spaghetti Mafia Hub - Emergency Fix Loaded")
