local inputKey = _G.Key
local keysUrl = "https://raw.githubusercontent.com/neho431/SpaghettiKeys/main/keys.txt"
local mainScriptUrl = "https://raw.githubusercontent.com/neho431/SpaghettiKeys/refs/heads/main/main.lua"

local allKeys = game:HttpGet(keysUrl)

if string.find(allKeys, inputKey) then
    print("✅ Key Authorized! Loading Spaghetti Script...")
    loadstring(game:HttpGet(mainScriptUrl))() -- מריץ את הקוד הארוך שלך
else
    game.Players.LocalPlayer:Kick("❌ Invalid Key! Get one from our Discord.")
end
