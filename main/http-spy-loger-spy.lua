--!! エクスプロイト（Executor）環境専用 HTTP & Discord Webhook 監視スクリプト !!
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- 古いUIがあれば削除
if CoreGui:FindFirstChild("ExecHttpSpyGUI") then
    CoreGui.ExecHttpSpyGUI:Destroy()
end

local isHttpSpyEnabled = true

---------------------------------------------------------
-- 1. GUIの生成
---------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExecHttpSpyGUI"
screenGui.Parent = CoreGui 

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 350)
mainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
title.Text = " 🕵️‍♂️ EXECUTOR HTTP SPY (Discord Monitor)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.Code
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -55)
container.Position = UDim2.new(0, 10, 0, 45)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = container

-- トグルボタン
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 0, 35)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 14
toggleButton.BorderSizePixel = 0

local function updateButton(state)
    if state then
        toggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        toggleButton.Text = "SPY STATUS : [ ACTIVE / 監視中 ]"
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        toggleButton.Text = "SPY STATUS : [ DISABLED / 停止 ]"
    end
end
updateButton(isHttpSpyEnabled)

toggleButton.MouseButton1Click:Connect(function()
    isHttpSpyEnabled = not isHttpSpyEnabled
    updateButton(isHttpSpyEnabled)
end)
toggleButton.Parent = container

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

-- スクロールログ
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -45)
scrollFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = container

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 6)
logLayout.Parent = scrollFrame

---------------------------------------------------------
-- 2. ログ追加関数
---------------------------------------------------------
local function addSpyLog(url, method, data)
    local logText = Instance.new("TextLabel")
    logText.Size = UDim2.new(1, -10, 0, 0)
    logText.AutomaticSize = Enum.AutomaticSize.Y
    logText.TextWrapped = true
    logText.BackgroundTransparency = 1
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.Font = Enum.Font.Code
    logText.TextSize = 11
    
    local timeStr = os.date("%H:%M:%S")
    
    if string.find(string.lower(url), "discord") or string.find(string.lower(url), "webhook") then
        logText.TextColor3 = Color3.fromRGB(255, 100, 100)
        logText.Text = string.format("[%s] 🚨 [DISCORD DETECTED!]\nMETHOD: %s\nURL: %s\nDATA: %s\n------------------------", timeStr, method, url, tostring(data))
    else
        logText.TextColor3 = Color3.fromRGB(100, 255, 150)
        logText.Text = string.format("[%s] 📡 [HTTP REQUEST]\nMETHOD: %s\nURL: %s\nDATA: %s\n------------------------", timeStr, method, url, string.sub(tostring(data), 1, 200))
    end
    
    logText.Parent = scrollFrame
    
    task.defer(function()
        scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.AbsoluteCanvasSize.Y)
    end)
end

addSpyLog("http://localhost", "SYSTEM", "Spy Initialized. Waiting for traffic...")

---------------------------------------------------------
-- 3. フック処理 (hookfunction)
---------------------------------------------------------
local requestFunc = (fluxus and fluxus.request) or (syn and syn.request) or request or http_request or (http and http.request)

if requestFunc and hookfunction then
    local originalRequest
    originalRequest = hookfunction(requestFunc, function(options)
        if isHttpSpyEnabled and options then
            local url = options.Url or options.url or "Unknown"
            local method = options.Method or options.method or "GET"
            local body = options.Body or options.body or "No Body"
            addSpyLog(url, "Exec " .. method, body)
        end
        return originalRequest(options)
    end)
    addSpyLog("Executor API", "SYSTEM", "hookfunction 成功。Executorの通信をフックしました。")
else
    addSpyLog("Executor API", "SYSTEM", "フック関数が未対応です。標準HttpServiceのみ監視します。")
end

-- 標準のHttpServiceも上書き
local originalPost = HttpService.PostAsync
HttpService.PostAsync = function(self, url, data, ...)
    if isHttpSpyEnabled then addSpyLog(url, "Roblox POST", data) end
    return originalPost(self, url, data, ...)
end

local originalGet = HttpService.GetAsync
HttpService.GetAsync = function(self, url, ...)
    if isHttpSpyEnabled then addSpyLog(url, "Roblox GET", "None") end
    return originalGet(self, url, ...)
end