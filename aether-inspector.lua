-- Aether Inspector
-- (Http Hook Spy V2)
-- by SKPR

-- SKPR SPY SYSTEM

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")

if CoreGui:FindFirstChild("AdvancedHttpSpyGUI_Refactored") then
    CoreGui.AdvancedHttpSpyGUI_Refactored:Destroy()
end

local config = {
    HttpRequest = true,
    DiscordWebHook = true,
    Loadstring = true,
    RobloxLog = true,
    RemoteEvent = true
}

local currentFilter = "ALL" 
local MAX_LOGS = 100
local logHistory = {}

local setClipboardFunc = setclipboard or toclipboard or set_clipboard or (syn and syn.write_clipboard)
local function copyToClipboard(text)
    if setClipboardFunc then
        setClipboardFunc(tostring(text))
    else
        warn("[Spy] Clipboard API unavailable.")
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedHttpSpyGUI_Refactored"
screenGui.Parent = CoreGui 

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 580, 0, 450)
mainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(45, 45, 60)
stroke.Thickness = 1.2
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 44)
title.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
title.Text = "     Aether Inspector"
title.TextColor3 = Color3.fromRGB(230, 230, 245)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local settingsBtn = Instance.new("TextButton")
settingsBtn.Size = UDim2.new(0, 100, 0, 28)
settingsBtn.Position = UDim2.new(1, -110, 0, 8)
settingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
settingsBtn.Text = "SETTINGS"
settingsBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.TextSize = 11
settingsBtn.Parent = title

local settingsBtnCorner = Instance.new("UICorner")
settingsBtnCorner.CornerRadius = UDim.new(0, 6)
settingsBtnCorner.Parent = settingsBtn

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -135, 0, 32)
searchBox.Position = UDim2.new(0, 12, 0, 52)
searchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
searchBox.Text = ""
searchBox.PlaceholderText = "Search logs (URL, Method, Data)..."
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 130)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 11
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.Parent = mainFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBox

local searchPadding = Instance.new("UIPadding")
searchPadding.PaddingLeft = UDim.new(0, 10)
searchPadding.Parent = searchBox

local filterBtn = Instance.new("TextButton")
filterBtn.Size = UDim2.new(0, 100, 0, 32)
filterBtn.Position = UDim2.new(1, -112, 0, 52)
filterBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
filterBtn.Text = "FILTER: ALL"
filterBtn.TextColor3 = Color3.fromRGB(200, 200, 230)
filterBtn.Font = Enum.Font.GothamBold
filterBtn.TextSize = 11
filterBtn.Parent = mainFrame

local filterBtnCorner = Instance.new("UICorner")
filterBtnCorner.CornerRadius = UDim.new(0, 6)
filterBtnCorner.Parent = filterBtn

-- Main Scroll View
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -24, 1, -100)
scrollFrame.Position = UDim2.new(0, 12, 0, 92)
scrollFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 90)
scrollFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 6)
scrollCorner.Parent = scrollFrame

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 8)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = scrollFrame

local logPadding = Instance.new("UIPadding")
logPadding.PaddingTop = UDim.new(0, 8)
logPadding.PaddingBottom = UDim.new(0, 8)
logPadding.PaddingLeft = UDim.new(0, 8)
logPadding.PaddingRight = UDim.new(0, 8)
logPadding.Parent = scrollFrame

local function createModal(titleText, sizeY)
    local modal = Instance.new("Frame")
    modal.Size = UDim2.new(0, 260, 0, sizeY)
    modal.Position = UDim2.new(0.5, -130, 0.5, -sizeY/2)
    modal.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    modal.BorderSizePixel = 0
    modal.Visible = false
    modal.ZIndex = 20
    modal.Parent = mainFrame

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 8)
    mCorner.Parent = modal

    local mStroke = Instance.new("UIStroke")
    mStroke.Color = Color3.fromRGB(70, 70, 100)
    mStroke.Thickness = 1.5
    mStroke.Parent = modal

    local mTitle = Instance.new("TextLabel")
    mTitle.Size = UDim2.new(1, 0, 0, 36)
    mTitle.BackgroundTransparency = 1
    mTitle.Text = titleText
    mTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
    mTitle.Font = Enum.Font.GothamBold
    mTitle.TextSize = 12
    mTitle.ZIndex = 21
    mTitle.Parent = modal

    local mContainer = Instance.new("Frame")
    mContainer.Size = UDim2.new(1, 0, 1, -36)
    mContainer.Position = UDim2.new(0, 0, 0, 36)
    mContainer.BackgroundTransparency = 1
    mContainer.ZIndex = 21
    mContainer.Parent = modal

    local mLayout = Instance.new("UIListLayout")
    mLayout.Padding = UDim.new(0, 6)
    mLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    mLayout.Parent = mContainer

    return modal, mContainer
end

local settingsModal, settingsContainer = createModal("MONITOR CONFIG", 240)

local function createToggleRow(name, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 28)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.ZIndex = 22
    btn.Parent = settingsContainer

    local function updateRow()
        if config[key] then
            btn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
            btn.Text = name .. " : [ ON ]"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            btn.Text = name .. " : [ OFF ]"
            btn.TextColor3 = Color3.fromRGB(160, 160, 180)
        end
    end
    updateRow()

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 5)
    bCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        config[key] = not config[key]
        updateRow()
    end)
end

createToggleRow("HTTP Request", "HttpRequest")
createToggleRow("Discord WebHook", "DiscordWebHook")
createToggleRow("Loadstring", "Loadstring")
createToggleRow("Roblox Log", "RobloxLog")
createToggleRow("Remote Event", "RemoteEvent")

local filterModal, filterContainer = createModal("🔍 CATEGORY FILTER", 260)
local filterTypes = { "ALL", "HTTP", "DISCORD", "LOADSTRING", "LOG", "REMOTE" }
local filterButtons = {}

local function updateFilterDisplay()
    filterBtn.Text = "FILTER: " .. currentFilter
    local query = string.lower(searchBox.Text)
    
    for _, logData in ipairs(logHistory) do
        local matchesQuery = query == "" 
           or string.find(string.lower(logData.url), query) 
           or string.find(string.lower(logData.method), query) 
           or string.find(string.lower(logData.body or ""), query)

        local matchesType = (currentFilter == "ALL") or (logData.category == currentFilter)

        if matchesQuery and matchesType then
            logData.frame.Visible = true
        else
            logData.frame.Visible = false
        end
    end
end

for _, fType in ipairs(filterTypes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 28)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.ZIndex = 22
    btn.Parent = filterContainer

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 5)
    bCorner.Parent = btn

    local function refreshBtn()
        if currentFilter == fType then
            btn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
            btn.Text = "► " .. fType
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            btn.Text = fType
            btn.TextColor3 = Color3.fromRGB(170, 170, 190)
        end
    end
    refreshBtn()
    table.insert(filterButtons, refreshBtn)

    btn.MouseButton1Click:Connect(function()
        currentFilter = fType
        filterModal.Visible = false
        for _, ref in ipairs(filterButtons) do ref() end
        updateFilterDisplay()
    end)
end

settingsBtn.MouseButton1Click:Connect(function()
    filterModal.Visible = false
    settingsModal.Visible = not settingsModal.Visible
end)

filterBtn.MouseButton1Click:Connect(function()
    settingsModal.Visible = false
    filterModal.Visible = not filterModal.Visible
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(updateFilterDisplay)

local function createCopyButton(parent, text, copyContent, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 85, 0, 24)
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 240)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = parent

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        copyToClipboard(copyContent)
        local origText = btn.Text
        btn.Text = "COPIED!"
        btn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
        task.delay(1, function()
            btn.Text = origText
            btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 55)
        end)
    end)
    return btn
end

local function addSpyLog(url, method, reqBody, resStatus, resBody, category, codeData)
    if #logHistory >= MAX_LOGS then
        local oldest = table.remove(logHistory, 1)
        if oldest and oldest.frame then oldest.frame:Destroy() end
    end

    local accentColor = Color3.fromRGB(85, 255, 170)
    if category == "DISCORD" then accentColor = Color3.fromRGB(255, 85, 85)
    elseif category == "LOADSTRING" then accentColor = Color3.fromRGB(255, 200, 85)
    elseif category == "REMOTE" then accentColor = Color3.fromRGB(180, 100, 255)
    elseif category == "LOG" then accentColor = Color3.fromRGB(100, 180, 255) end

    local itemFrame = Instance.new("Frame")
    itemFrame.Size = UDim2.new(1, 0, 0, 0)
    itemFrame.AutomaticSize = Enum.AutomaticSize.Y
    itemFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    itemFrame.BorderSizePixel = 0
    itemFrame.Parent = scrollFrame

    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = itemFrame

    local itemStroke = Instance.new("UIStroke")
    itemStroke.Color = accentColor
    itemStroke.Transparency = 0.6
    itemStroke.Thickness = 1
    itemStroke.Parent = itemFrame

    local itemLayout = Instance.new("UIListLayout")
    itemLayout.Padding = UDim.new(0, 6)
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemLayout.Parent = itemFrame

    local itemPadding = Instance.new("UIPadding")
    itemPadding.PaddingTop = UDim.new(0, 8)
    itemPadding.PaddingBottom = UDim.new(0, 8)
    itemPadding.PaddingLeft = UDim.new(0, 8)
    itemPadding.PaddingRight = UDim.new(0, 8)
    itemPadding.Parent = itemFrame

    local timeStr = os.date("%H:%M:%S")
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, 0, 0, 0)
    headerText.AutomaticSize = Enum.AutomaticSize.Y
    headerText.TextWrapped = true
    headerText.BackgroundTransparency = 1
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Font = Enum.Font.Code
    headerText.TextSize = 11
    headerText.TextColor3 = Color3.fromRGB(230, 230, 245)

    local statusInfo = resStatus and string.format(" | Status: %s", tostring(resStatus)) or ""
    headerText.Text = string.format("[%s] [%s]%s\nTARGET: %s", timeStr, string.upper(method), statusInfo, url)
    headerText.Parent = itemFrame

    if reqBody and reqBody ~= "" and reqBody ~= "None" then
        local bodyText = Instance.new("TextLabel")
        bodyText.Size = UDim2.new(1, 0, 0, 0)
        bodyText.AutomaticSize = Enum.AutomaticSize.Y
        bodyText.TextWrapped = true
        bodyText.BackgroundTransparency = 1
        bodyText.TextXAlignment = Enum.TextXAlignment.Left
        bodyText.Font = Enum.Font.Code
        bodyText.TextSize = 10
        bodyText.TextColor3 = Color3.fromRGB(160, 160, 180)
        bodyText.Text = "DATA: " .. string.sub(tostring(reqBody), 1, 150) .. (#tostring(reqBody) > 150 and "..." or "")
        bodyText.Parent = itemFrame
    end

    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, 0, 0, 24)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = itemFrame

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 6)
    btnLayout.Parent = btnContainer

    createCopyButton(btnContainer, "Target", url)
    if reqBody and reqBody ~= "" and reqBody ~= "None" then createCopyButton(btnContainer, "Data", reqBody) end
    if resBody and resBody ~= "" then createCopyButton(btnContainer, "Res", resBody) end

    if codeData or category == "LOADSTRING" then
        local scBtn = createCopyButton(btnContainer, "Copy Code", codeData or reqBody or "", Color3.fromRGB(180, 120, 30))
        scBtn.Size = UDim2.new(0, 100, 0, 24)
    end

    local entry = { url = url, method = method, body = tostring(reqBody or ""), category = category, frame = itemFrame }
    table.insert(logHistory, entry)

    updateFilterDisplay()

    task.defer(function()
        scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.AbsoluteCanvasSize.Y)
    end)
end

if hookfunction then
    local originalLoadstring
    originalLoadstring = hookfunction(loadstring, function(code, chunkname)
        if config.Loadstring and type(code) == "string" then
            addSpyLog("Internal / Loadstring", "LOADSTRING", string.sub(code, 1, 100) .. "...", "OK", nil, "LOADSTRING", code)
        end
        return originalLoadstring(code, chunkname)
    end)
end

local requestFunc = (fluxus and fluxus.request) or (syn and syn.request) or request or http_request or (http and http.request)
if requestFunc and hookfunction then
    local originalRequest
    originalRequest = hookfunction(requestFunc, function(options)
        if not options then return originalRequest(options) end
        local response = originalRequest(options)
        
        local url = options.Url or options.url or "Unknown"
        local isDiscord = string.find(string.lower(url), "discord") or string.find(string.lower(url), "webhook")

        if (isDiscord and config.DiscordWebHook) or (not isDiscord and config.HttpRequest) then
            local method = options.Method or options.method or "GET"
            local body = options.Body or options.body or "None"
            local status = response and (response.StatusCode or response.StatusMessage) or "N/A"
            local resBody = response and response.Body or ""

            local cat = isDiscord and "DISCORD" or "HTTP"
            addSpyLog(url, cat .. " " .. method, body, status, resBody, cat, nil)
        end
        return response
    end)
end

if hookmetamethod then
    local originalNamecall
    originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if config.RemoteEvent and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            local serializedArgs = ""
            for i, arg in ipairs(args) do
                serializedArgs = serializedArgs .. string.format("[%d]: %s, ", i, tostring(arg))
            end
            addSpyLog(self:GetFullName(), "REMOTE " .. method, serializedArgs, "SENT", nil, "REMOTE", nil)
        end
        return originalNamecall(self, ...)
    end)
end

LogService.MessageOut:Connect(function(message, messageType)
    if config.RobloxLog then
        local typeStr = tostring(messageType):gsub("Enum.MessageType.", "")
        addSpyLog("Roblox Console", "LOG [" .. typeStr .. "]", message, "LOG", nil, "LOG", nil)
    end
end)

addSpyLog("http://localhost", "SYSTEM", "Spy Initialized Successfully.", "OK", nil, "HTTP", nil)