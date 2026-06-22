-- すでにGUIが存在していたら削除（二重起動防止）
local old_gui = game:GetService("CoreGui"):FindFirstChild("LoadstringTracker")
if old_gui then old_gui:Destroy() end

-- --- GUIの作成 ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LoadstringTracker"
ScreenGui.Parent = game:GetService("CoreGui") -- エグゼキューター環境用の安全なGUI親要素
ScreenGui.ResetOnSpawn = false

-- メインフレーム
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(1, -270, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- 画面内でドラッグして動かせます
MainFrame.Parent = ScreenGui

-- 角丸にする
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- タイトル
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = " 🔍 Loadstring 監視ログ"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- スクロールリスト（検出したスクリプトが並ぶ場所）
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -10, 1, -45)
ScrollList.Position = UDim2.new(0, 5, 0, 40)
ScrollList.BackgroundTransparency = 1
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollList.ScrollBarThickness = 6
ScrollList.Parent = MainFrame

-- リストの並び替え設定
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- リストが増えたら自動でスクロール範囲を広げる
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- --- スクリプトデータを格納するテーブル ---
local detectedScripts = {}
local call_count = 0

-- --- リストにボタンを追加する関数 ---
local function createLogItem(count, source_code)
    detectedScripts[count] = source_code

    local ItemFrame = Instance.new("Frame")
    ItemFrame.Size = UDim2.new(1, -5, 0, 35)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ItemFrame.BorderSizePixel = 0
    ItemFrame.Parent = ScrollList

    local ItemCorner = Instance.new("UICorner")
    ItemCorner.CornerRadius = UDim.new(0, 5)
    ItemCorner.Parent = ItemFrame

    -- 「ロード ○個目」の文字
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 120, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "ロード " .. tostring(count) .. " 個目"
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ItemFrame

    -- 「コピーする」ボタン
    local CopyButton = Instance.new("TextButton")
    CopyButton.Size = UDim2.new(0, 90, 0, 25)
    CopyButton.Position = UDim2.new(1, -95, 0.5, -12)
    CopyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 136)
    CopyButton.Text = "コピーする"
    CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyButton.TextSize = 12
    CopyButton.Font = Enum.Font.SourceSansBold
    CopyButton.Parent = ItemFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = CopyButton

    -- ボタンが押されたらクリップボードにコピー
    CopyButton.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(detectedScripts[count])
            CopyButton.Text = "コピー完了！"
            CopyButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            task.delay(1.5, function()
                CopyButton.Text = "コピーする"
                CopyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 136)
            end)
        else
            CopyButton.Text = "非対応環境"
            CopyButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
        end
    end)
end

-- --- loadstring のフック処理 ---
local original_loadstring = loadstring

getgenv().loadstring = function(source_code, ...)
    call_count = call_count + 1
    
    -- GUIにアイテムを追加（スレッドを止めないように task.spawn で実行）
    task.spawn(function()
        createLogItem(call_count, source_code)
    end)
    
    -- 本来の処理を実行
    return original_loadstring(source_code, ...)
end

print("[監視システム] GUI付きの loadstring 監視を開始しました。")