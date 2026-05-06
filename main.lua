print("[DRK] Loader Executing...")
--[[
    EzRES - Secure Loader
    Verifies key and loads main script from Salting.io
]]

--// Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--// Configuration
local DB_URL = "https://ez-res-default-rtdb.asia-southeast1.firebasedatabase.app/keys/"
local PORTAL_URL = "https://ltnproject.github.io/DrkExternal-Key/" 
local KEY_FILENAME = "drk_license.txt"

--// Salting.io Configuration for Main Script
-- IMPORTANT: Replace this with the UUID of the Credential containing main_core.lua
local SCRIPT_SALTING_UUID = "e3a11fcd-7993-4b1c-83a5-c35de48277bb"

--// Utility Functions
local function getHWID()
	local success, result = pcall(function()
		return game:GetService("RbxAnalyticsService"):GetClientId()
	end)
	return success and result or "UNKNOWN"
end

local function httpRequest(url, method, body)
    method = method or "GET"
    local success, response
    local requestFunc = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or request
    
    if requestFunc then
        success, response = pcall(function()
            local res = requestFunc({
                Url = url,
                Method = method,
                Headers = {["Content-Type"] = "application/json"},
                Body = body
            })
            return res.Body
        end)
    end
    
    if (not success or not response) and method == "GET" then
        success, response = pcall(function()
            local getFunc = game.HttpGet or function(self, u) return HttpService:GetAsync(u) end
            return getFunc(game, url)
        end)
    end
    
    return success, response
end

local function notify(text, color)
    task.spawn(function()
        local gui = player.PlayerGui:FindFirstChild("DrkKeyGUI") or player.PlayerGui:FindFirstChild("ResolutionGUI")
        if not gui then return end
        
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0, 250, 0, 35)
        notif.Position = UDim2.new(0.5, -125, 0.8, 0)
        notif.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
        notif.TextColor3 = Color3.new(1, 1, 1)
        notif.Text = text
        notif.Font = Enum.Font.GothamMedium
        notif.TextSize = 14
        notif.Parent = gui
        
        local corner = Instance.new("UICorner", notif)
        local stroke = Instance.new("UIStroke", notif)
        stroke.Color = Color3.new(1,1,1)
        stroke.Transparency = 0.8
        
        task.wait(3)
        local tween = TweenService:Create(notif, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Wait()
        notif:Destroy()
    end)
end

--// Key Verification
local function verifyKey(key)
	local hwid = getHWID()
	local success, response = httpRequest(DB_URL .. key .. ".json")
	
	if not success or not response or response == "null" then
		return false, "Invalid License Key"
	end
	
	local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not decodeSuccess or not data then return false, "Invalid Data Format" end

	if not data.active then return false, "Key disabled" end
	local currentTime = os.time() * 1000
	if data.expires_at and data.expires_at < currentTime then 
        return false, "Key expired" 
    end
	
	if data.hwid == "UNBOUND" then
		httpRequest(DB_URL .. key .. ".json", "PATCH", HttpService:JSONEncode({hwid = hwid}))
	elseif data.hwid ~= hwid then
		return false, "Key bound to another device"
	end
	
	return true, data
end

--// Base64 Decoder
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64Decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        return string.char(tonumber(x,2))
    end))
end

--// Script Loader
local function launchScript()
    print("[DRK] Fetching main script...")
    local success, response = httpRequest("https://api.salting.io/r/" .. SCRIPT_SALTING_UUID)
    
    if success and response then
        local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response) end)
        if decodeSuccess and data.data then
            print("[DRK] Decoding and running main script...")
            local decodedScript = base64Decode(data.data)
            local func, err = loadstring(decodedScript)
            
            if func then
                task.spawn(function()
                    local success, runErr = pcall(func)
                    if not success then
                        warn("[DRK] Script execution error: " .. tostring(runErr))
                    end
                end)
            else
                warn("[DRK] Failed to load payload: " .. tostring(err))
            end
        else
            warn("[DRK] Failed to decode script data")
        end
    else
        warn("[DRK] Failed to fetch script from Salting.io")
    end
end

--// Login GUI
local function createLoginUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "DrkKeyGUI"
	gui.Parent = player.PlayerGui

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0, 350, 0, 220)
	frame.Position = UDim2.new(0.5, -175, 0.5, -110)
	frame.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(168, 85, 247)
	stroke.Thickness = 2

	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Text = "DRK EXTERNAL"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.BackgroundTransparency = 1

	local inputBox = Instance.new("TextBox", frame)
	inputBox.Size = UDim2.new(0.8, 0, 0, 40)
	inputBox.Position = UDim2.new(0.1, 0, 0, 80)
	inputBox.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
	inputBox.Text = ""
	inputBox.PlaceholderText = "DRK-XXXX-XXXX-XXXX"
	inputBox.TextColor3 = Color3.new(1, 1, 1)
	inputBox.Font = Enum.Font.Code
	Instance.new("UICorner", inputBox)

	local loginBtn = Instance.new("TextButton", frame)
	loginBtn.Size = UDim2.new(0.8, 0, 0, 40)
	loginBtn.Position = UDim2.new(0.1, 0, 0, 130)
	loginBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
	loginBtn.Text = "Login"
	loginBtn.TextColor3 = Color3.new(1, 1, 1)
	loginBtn.Font = Enum.Font.GothamBold
	Instance.new("UICorner", loginBtn)

	loginBtn.MouseButton1Click:Connect(function()
		local key = inputBox.Text
		if key == "" then return end
		loginBtn.Text = "Verifying..."
		local valid, data = verifyKey(key)
		if valid then
			pcall(function() writefile(KEY_FILENAME, key) end)
			gui:Destroy()
			launchScript()
		else
			loginBtn.Text = "Login"
			notify(data, Color3.fromRGB(150, 50, 50))
		end
	end)
end

--// Init
local savedKey = nil
pcall(function() if isfile(KEY_FILENAME) then savedKey = readfile(KEY_FILENAME) end end)

if savedKey then
    local valid, data = verifyKey(savedKey)
    if valid then launchScript() else createLoginUI() end
else
    createLoginUI()
end
