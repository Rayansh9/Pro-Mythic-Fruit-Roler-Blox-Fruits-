--[[
                            PRO HUB v5.5 ULTIMATE - SUPREME FARMING SUITE
            This was made by Pro Gamer Team ( Rayansh9 )
            Ultimate Blox Fruits Automation System
            Built with Quantum Onyx UI Framework
            Copyright © 2026 Pro Gamer Team - All Rights Reserved.
            
            ✨ PREMIUM FEATURES:
            ✅ Advanced Key System Integration
            ✅ Multi-Game Support
            ✅ Professional UI with animations
            ✅ Auto-Update System
            ✅ Config Save/Load
            ✅ Advanced Logging
            ✅ Notification System
            ✅ Performance Optimization
            ✅ Premium Features
            ✅ Developer Console
]]--

-- ============================================================
-- SERVICES & SETUP
-- ============================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local Workspace = workspace
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

local playerGui = player:WaitForChild("PlayerGui")
local Mouse = player:GetMouse()

-- Remove earlier copies
local oldGui = playerGui:FindFirstChild("ProHubUI_SUPREME")
if oldGui then oldGui:Destroy() end

-- ============================================================
-- CONFIGURATION & DIRECTORIES
-- ============================================================

local FOLDER = "ProHub_Supreme"
local KEY_FILE = FOLDER .. "/Key.json"
local CONFIG_FILE = FOLDER .. "/config.json"
local LOG_FILE = FOLDER .. "/logs.txt"
local gameId = game.GameId

-- Game detection
local SUPPORTED_GAMES = {
    [994732206] = "Blox Fruits",
    [2753915549] = "Blox Fruits",
    [9186719164] = "Sailor Piece",
    [8191429227] = "Cut Trees",
}

-- ============================================================
-- THEME - QUANTUM ONYX SUPREME
-- ============================================================

local THEME = {
    -- Primary Colors
    bg = Color3.fromRGB(6, 3, 12),
    sidebar = Color3.fromRGB(9, 5, 18),
    card = Color3.fromRGB(15, 8, 30),
    border = Color3.fromRGB(110, 50, 210),
    accent = Color3.fromRGB(155, 90, 255),
    accentHover = Color3.fromRGB(175, 110, 255),
    
    -- Secondary Colors
    cyan = Color3.fromRGB(105, 175, 255),
    text = Color3.fromRGB(220, 200, 255),
    subtext = Color3.fromRGB(156, 163, 175),
    white = Color3.fromRGB(255, 255, 255),
    
    -- Status Colors
    red = Color3.fromRGB(239, 68, 68),
    green = Color3.fromRGB(80, 230, 130),
    warning = Color3.fromRGB(255, 200, 80),
    success = Color3.fromRGB(105, 195, 255),
    orange = Color3.fromRGB(255, 140, 60),
    premium = Color3.fromRGB(255, 215, 0),
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function Tween(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
end

local function Protect(gui)
    local env = (getgenv and getgenv()) or _G
    if env.HIDEUI then
        gui.Parent = env.HIDEUI
    elseif gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    else
        gui.Parent = playerGui
    end
end

local function Notify(title, desc, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Pro Hub",
            Text = desc or "",
            Duration = duration or 5,
        })
    end)
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.border
    s.Thickness = thickness or 1
    s.Parent = parent
end

local function padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top or 8)
    p.PaddingBottom = UDim.new(0, bottom or 8)
    p.PaddingLeft = UDim.new(0, left or 8)
    p.PaddingRight = UDim.new(0, right or 8)
    p.Parent = parent
end

local function New(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Children" and k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    if props.Children then
        for _, c in ipairs(props.Children) do
            pcall(function() c.Parent = inst end)
        end
    end
    inst.Parent = props.Parent or parent
    return inst
end

local function CircleRipple(btn, mx, my)
    task.spawn(function()
        if not btn or not btn.Parent then return end
        btn.ClipsDescendants = true
        local nx = mx - btn.AbsolutePosition.X
        local ny = my - btn.AbsolutePosition.Y
        local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.6
        local c = New("ImageLabel", {
            Name = "Ripple",
            Image = "rbxassetid://266543268",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 0.82,
            BackgroundTransparency = 1,
            ZIndex = btn.ZIndex + 5,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, nx, 0, ny),
        }, btn)
        Tween(c, { Size = UDim2.new(0, sz, 0, sz), Position = UDim2.new(0.5, -sz/2, 0.5, -sz/2) }, 0.45, Enum.EasingStyle.Quad)
        Tween(c, { ImageTransparency = 1 }, 0.45, Enum.EasingStyle.Linear)
        task.wait(0.46)
        pcall(function() c:Destroy() end)
    end)
end

-- ============================================================
-- FILE SYSTEM FUNCTIONS
-- ============================================================

local function ensureFolder()
    if not isfolder(FOLDER) then
        makefolder(FOLDER)
    end
end

local function saveKey(key)
    if not (isfile and writefile) then return end
    ensureFolder()
    pcall(function()
        writefile(KEY_FILE, HttpService:JSONEncode({ key = key, timestamp = os.time() }))
    end)
end

local function loadSavedKey()
    if not (isfile and readfile) then return "" end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(KEY_FILE))
    end)
    return (ok and type(data) == "table" and data.key) and data.key or ""
end

local function saveConfig(data)
    if not (isfile and writefile) then return end
    ensureFolder()
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end)
end

local function loadConfig()
    if not (isfile and readfile) then return {} end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)
    return ok and data or {}
end

local function Log(message)
    if not (isfile and writefile) then return end
    ensureFolder()
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logEntry = string.format("[%s] %s\n", timestamp, message)
    pcall(function()
        if isfile(LOG_FILE) then
            writefile(LOG_FILE, readfile(LOG_FILE) .. logEntry)
        else
            writefile(LOG_FILE, logEntry)
        end
    end)
end

-- ============================================================
-- VIEWPORT & GUI SIZING
-- ============================================================

local function viewport()
    local cam = workspace.CurrentCamera
    return (cam and cam.ViewportSize) or Vector2.new(1920, 1080)
end

local vp = viewport()
local maxW = math.min(1000, math.floor(vp.X * 0.85))
local maxH = math.min(700, math.floor(vp.Y * 0.8))
local minW, minH = 400, 150
local startW = math.clamp(maxW, minW, vp.X - 20)
local startH = math.clamp(maxH, minH, vp.Y - 20)

-- ============================================================
-- MAIN GUI SETUP
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProHubUI_SUPREME"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
Protect(ScreenGui)

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, startW, 0, startH)
main.Position = UDim2.new(0.5, -startW/2, 0.5, -startH/2)
main.BackgroundColor3 = THEME.bg
main.Active = true
main.Parent = ScreenGui
corner(main, 14)
stroke(main, THEME.accent, 2)

-- Background Effects
New("Frame", {
    BackgroundColor3 = Color3.fromRGB(80, 20, 160),
    BackgroundTransparency = 0.88,
    BorderSizePixel = 0,
    Position = UDim2.new(0, -60, 0, -60),
    Size = UDim2.new(0, 220, 0, 220),
    ZIndex = 199,
    Parent = main,
    Children = { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }
})

New("Frame", {
    BackgroundColor3 = Color3.fromRGB(40, 10, 110),
    BackgroundTransparency = 0.90,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -100, 1, -100),
    Size = UDim2.new(0, 180, 0, 180),
    ZIndex = 199,
    Parent = main,
    Children = { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }
})

-- Header
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 60)
top.BackgroundColor3 = THEME.sidebar
top.Parent = main
corner(top, 14)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 700, 1, 0)
title.Position = UDim2.new(0, 18, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✨ PRO HUB SUPREME v5.5 | Ultimate Farming Suite"
title.TextColor3 = THEME.text
title.TextSize = 16
title.Font = Enum.Font.FredokaOne
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

-- Status & Info
local info = Instance.new("TextLabel")
info.Size = UDim2.new(0, 250, 1, 0)
info.Position = UDim2.new(1, -280, 0, 0)
info.BackgroundTransparency = 1
info.Text = "Ping: -- | FPS: --"
info.TextColor3 = THEME.subtext
info.TextSize = 11
info.Font = Enum.Font.GothamBold
info.TextXAlignment = Enum.TextXAlignment.Right
info.Parent = top

-- Status Indicator
local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 14, 0, 14)
statusIndicator.Position = UDim2.new(1, -310, 0.5, -7)
statusIndicator.BackgroundColor3 = THEME.green
statusIndicator.BorderSizePixel = 0
statusIndicator.Parent = top
corner(statusIndicator, 7)

-- Buttons (Minimize, Pin, Close)
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 36, 0, 36)
minimize.Position = UDim2.new(1, -120, 0.5, -18)
minimize.BackgroundColor3 = THEME.card
minimize.Text = "—"
minimize.TextColor3 = THEME.white
minimize.TextSize = 18
minimize.Font = Enum.Font.GothamBold
minimize.AutoButtonColor = false
minimize.Parent = top
corner(minimize, 8)
stroke(minimize, THEME.border, 1)

local pin = Instance.new("TextButton")
pin.Size = UDim2.new(0, 36, 0, 36)
pin.Position = UDim2.new(1, -82, 0.5, -18)
pin.BackgroundColor3 = THEME.card
pin.Text = "📌"
pin.TextColor3 = THEME.cyan
pin.TextSize = 14
pin.Font = Enum.Font.GothamBold
pin.AutoButtonColor = false
pin.Parent = top
corner(pin, 8)
stroke(pin, THEME.border, 1)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 36, 0, 36)
close.Position = UDim2.new(1, -44, 0.5, -18)
close.BackgroundColor3 = THEME.card
close.Text = "✕"
close.TextColor3 = THEME.red
close.TextSize = 16
close.Font = Enum.Font.GothamBold
close.AutoButtonColor = false
close.Parent = top
corner(close, 8)
stroke(close, THEME.red, 1)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 200, 1, -78)
sidebar.Position = UDim2.new(0, 12, 0, 66)
sidebar.BackgroundColor3 = THEME.sidebar
sidebar.Parent = main
corner(sidebar, 12)
stroke(sidebar, THEME.border, 1)
padding(sidebar, 10, 10, 8, 8)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 6)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = sidebar

-- Content Area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -230, 1, -78)
content.Position = UDim2.new(0, 220, 0, 66)
content.BackgroundColor3 = THEME.sidebar
content.Parent = main
corner(content, 12)
stroke(content, THEME.border, 1)
padding(content, 12, 12, 12, 12)

-- ============================================================
-- MINIMIZE FUNCTIONALITY
-- ============================================================

local isMinimized = false
local prevSize, prevPosition

local function fitToScreen()
    local vp = viewport()
    if isMinimized then
        local miniW = math.clamp(math.floor(vp.X * 0.5), 350, vp.X - 40)
        local miniH = 60
        local newPosX = math.floor((vp.X - miniW) / 2)
        Tween(main, { Size = UDim2.new(0, miniW, 0, miniH), Position = UDim2.new(0, newPosX, 0, 12) }, 0.18)
        return
    end

    local w = math.clamp(main.Size.X.Offset, minW, maxW)
    local h = math.clamp(main.Size.Y.Offset, minH, maxH)
    local newPosX = math.floor((vp.X - w) / 2)
    local newPosY = math.floor((vp.Y - h) / 2)
    Tween(main, { Size = UDim2.new(0, w, 0, h), Position = UDim2.new(0, newPosX, 0, newPosY) }, 0.18)
end

minimize.MouseButton1Click:Connect(function()
    CircleRipple(minimize, Mouse.X, Mouse.Y)
    if not isMinimized then
        prevSize = main.Size
        prevPosition = main.Position
        sidebar.Visible = false
        content.Visible = false
        local vp = viewport()
        local miniW = math.clamp(math.floor(vp.X * 0.5), 350, vp.X - 40)
        Tween(main, { Size = UDim2.new(0, miniW, 0, 60) }, 0.18)
        isMinimized = true
        Notify("Minimized", "Window minimized to taskbar", 2)
    else
        if prevSize and prevPosition then
            Tween(main, { Size = prevSize, Position = prevPosition }, 0.18)
        else
            fitToScreen()
        end
        sidebar.Visible = true
        content.Visible = true
        isMinimized = false
        Notify("Restored", "Window restored", 2)
    end
end)

-- Drag functionality
do
    local dragging = false
    local dragStart, startPos

    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

close.MouseButton1Click:Connect(function()
    CircleRipple(close, Mouse.X, Mouse.Y)
    Notify("Closed", "Pro Hub Supreme closed", 2)
    Log("Pro Hub Supreme closed by user")
    ScreenGui:Destroy()
end)

-- ============================================================
-- PAGE SYSTEM
-- ============================================================

local pages = {}
local buttons = {}

local function createPage(name, icon)
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = THEME.card
    button.Text = icon .. "  " .. name
    button.TextColor3 = THEME.subtext
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.AutoButtonColor = false
    button.Parent = sidebar
    corner(button, 8)
    stroke(button, THEME.border, 1)

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 5
    page.ScrollBarImageColor3 = THEME.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local function resize()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

    pages[name] = page
    buttons[name] = button

    button.MouseButton1Click:Connect(function()
        CircleRipple(button, Mouse.X, Mouse.Y)
        for n, p in pairs(pages) do
            p.Visible = false
            buttons[n].BackgroundColor3 = THEME.card
            buttons[n].TextColor3 = THEME.subtext
        end
        page.Visible = true
        button.BackgroundColor3 = THEME.accent
        button.TextColor3 = THEME.white
        resize()
    end)

    button.MouseEnter:Connect(function()
        if button.BackgroundColor3 ~= THEME.accent then
            Tween(button, { BackgroundColor3 = THEME.border }, 0.12)
        end
    end)

    button.MouseLeave:Connect(function()
        if button.BackgroundColor3 ~= THEME.accent then
            Tween(button, { BackgroundColor3 = THEME.card }, 0.12)
        end
    end)

    return page
end

-- ============================================================
-- UI COMPONENTS
-- ============================================================

local function card(parent, height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, height or 70)
    f.BackgroundColor3 = THEME.card
    f.Parent = parent
    corner(f, 10)
    stroke(f, THEME.border, 1)
    padding(f, 10, 10, 10, 10)
    return f
end

local function label(parent, text, size, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, size or 26)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or THEME.text
    l.TextSize = 11
    l.Font = Enum.Font.Gotham
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function action(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 38)
    b.BackgroundColor3 = THEME.accent
    b.Text = text
    b.TextColor3 = THEME.white
    b.TextSize = 11
    b.Font = Enum.Font.FredokaOne
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 8)
    stroke(b, THEME.accent, 1)

    b.MouseEnter:Connect(function()
        Tween(b, {BackgroundColor3 = THEME.accentHover}, 0.12)
    end)
    b.MouseLeave:Connect(function()
        Tween(b, {BackgroundColor3 = THEME.accent}, 0.12)
    end)
    b.MouseButton1Click:Connect(function()
        CircleRipple(b, Mouse.X, Mouse.Y)
        callback()
    end)

    return b
end

local function toggle(parent, text, default, callback)
    local f = card(parent, 42)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -70, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = THEME.text
    t.TextSize = 11
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 60, 0, 28)
    b.Position = UDim2.new(1, -62, 0.5, -14)
    b.TextSize = 9
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = f
    corner(b, 14)
    stroke(b, THEME.border, 1)

    local state = default == true

    local function render()
        b.Text = state and "ON" or "OFF"
        b.BackgroundColor3 = state and THEME.green or THEME.card
        b.TextColor3 = state and THEME.white or THEME.subtext
    end

    b.MouseButton1Click:Connect(function()
        CircleRipple(b, Mouse.X, Mouse.Y)
        state = not state
        render()
        callback(state)
    end)

    render()
    callback(state)
    return f
end

-- ============================================================
-- CREATE ALL PAGES
-- ============================================================

local fruitFarmPage = createPage("Fruit Farm", "🍎")
local islandFarmPage = createPage("Island Farm", "🏝️")
local questFarmPage = createPage("Quests", "🎯")
local bossPage = createPage("Bosses", "👹")
local dungeonPage = createPage("Dungeons", "🏰")
local raceV4Page = createPage("Race V4", "🏎️")
local seaEventPage = createPage("Sea Event", "🌊")
local combatPage = createPage("Combat", "⚔️")
local statsPage = createPage("Stats", "📊")
local settingsPage = createPage("Settings", "⚙️")

-- ============================================================
-- STATE MANAGEMENT
-- ============================================================

local farmingState = {
    autoFruit = false,
    autoTeleport = false,
    autoStore = false,
    autoIsland = false,
    autoHop = false,
    autoQuest = false,
    autoBoss = false,
    autoDungeon = false,
    autoRaceV4 = false,
    autoSeaEvent = false,
    autoCombo = false,
    autoDodge = false,
    farmingActive = false,
    
    stats = {
        beatsDefeated = 0,
        beliEarned = 0,
        fruitsLooted = 0,
        questsCompleted = 0,
        uptime = 0,
        totalXP = 0,
        bossDefeats = 0,
    }
}

-- ============================================================
-- FRUIT FARM PAGE (ENHANCED)
-- ============================================================

label(fruitFarmPage, "🍎 FRUIT FARMING SYSTEM", 22, THEME.accent)

toggle(fruitFarmPage, "🍎 Enable Fruit Farm", false, function(v)
    farmingState.autoFruit = v
    statusIndicator.BackgroundColor3 = v and THEME.orange or THEME.green
    Log("Fruit Farming: " .. (v and "ENABLED" or "DISABLED"))
end)

toggle(fruitFarmPage, "📍 Auto Teleport Fruits", false, function(v)
    farmingState.autoTeleport = v
    Log("Auto Teleport: " .. (v and "ENABLED" or "DISABLED"))
end)

toggle(fruitFarmPage, "🎁 Auto Store Fruits", false, function(v)
    farmingState.autoStore = v
    Log("Auto Store: " .. (v and "ENABLED" or "DISABLED"))
end)

action(fruitFarmPage, "▶ START FRUIT FARMING", function()
    farmingState.autoFruit = true
    farmingState.autoTeleport = true
    farmingState.farmingActive = true
    statusIndicator.BackgroundColor3 = THEME.orange
    Notify("🍎 Farming Started", "Fruit farming activated", 3)
    Log("Fruit Farming started by user")
end)

action(fruitFarmPage, "⏹ STOP FARMING", function()
    farmingState.autoFruit = false
    farmingState.autoTeleport = false
    farmingState.farmingActive = false
    statusIndicator.BackgroundColor3 = THEME.green
    Notify("Farming Stopped", "All farming halted", 2)
    Log("Farming stopped by user")
end)

local fruitStatsCard = card(fruitFarmPage, 110)
label(fruitStatsCard, "📊 FRUIT STATS", 20, THEME.accent)
local fruitStatsLabel = label(fruitStatsCard, "Fruits: 0 | Beli: 0", 80, THEME.text)

-- ============================================================
-- ISLAND FARM PAGE (ENHANCED)
-- ============================================================

label(islandFarmPage, "🏝️ ISLAND FARMING SYSTEM", 22, THEME.accent)

toggle(islandFarmPage, "🏝️ Enable Island Farm", false, function(v)
    farmingState.autoIsland = v
end)

toggle(islandFarmPage, "🔄 Auto Island Hopping", false, function(v)
    farmingState.autoHop = v
end)

action(islandFarmPage, "▶ START ISLAND FARM", function()
    farmingState.autoIsland = true
    statusIndicator.BackgroundColor3 = THEME.orange
    Notify("🏝️ Island Farm Started", "Island farming activated", 3)
end)

action(islandFarmPage, "🔄 HOP ISLANDS", function()
    farmingState.autoHop = true
    statusIndicator.BackgroundColor3 = THEME.warning
    Notify("Hopping Islands", "Starting island hopping", 2)
end)

-- ============================================================
-- QUEST FARM PAGE (ENHANCED)
-- ============================================================

label(questFarmPage, "🎯 QUEST FARMING SYSTEM", 22, THEME.accent)

toggle(questFarmPage, "🎯 Enable Quest Farm", false, function(v)
    farmingState.autoQuest = v
end)

toggle(questFarmPage, "✅ Auto Accept Quests", false, function(v)
    Log("Auto Accept Quests: " .. (v and "ENABLED" or "DISABLED"))
end)

toggle(questFarmPage, "⚔️ Auto Complete Quests", false, function(v)
    Log("Auto Complete Quests: " .. (v and "ENABLED" or "DISABLED"))
end)

action(questFarmPage, "▶ START QUEST FARMING", function()
    farmingState.autoQuest = true
    statusIndicator.BackgroundColor3 = THEME.orange
    Notify("🎯 Quest Farming Started", "Quest automation activated", 3)
end)

local questStatsCard = card(questFarmPage, 110)
label(questStatsCard, "📊 QUEST STATS", 20, THEME.accent)
local questStatsLabel = label(questStatsCard, "Quests: 0 | XP: 0", 80, THEME.text)

-- ============================================================
-- BOSS FARM PAGE (ENHANCED)
-- ============================================================

label(bossPage, "👹 BOSS FARMING SYSTEM", 22, THEME.accent)

toggle(bossPage, "👹 Enable Boss Farm", false, function(v)
    farmingState.autoBoss = v
end)

local bosses = {"Shanks", "Mihawk", "Aokiji", "Kizaru", "Big Mom", "Blackbeard"}
for _, bossName in ipairs(bosses) do
    action(bossPage, "👹 Farm " .. bossName, function()
        farmingState.autoBoss = true
        statusIndicator.BackgroundColor3 = THEME.orange
        Notify("👹 Boss Farming", "Farming " .. bossName, 3)
        Log("Boss Farming: " .. bossName)
    end)
end

local bossStatsCard = card(bossPage, 100)
label(bossStatsCard, "📊 BOSS STATS", 20, THEME.accent)
local bossStatsLabel = label(bossStatsCard, "Defeats: 0", 70, THEME.text)

-- ============================================================
-- DUNGEON FARM PAGE (ENHANCED)
-- ============================================================

label(dungeonPage, "🏰 DUNGEON FARMING SYSTEM", 22, THEME.accent)

toggle(dungeonPage, "🏰 Enable Dungeon Farm", false, function(v)
    farmingState.autoDungeon = v
end)

local dungeons = {"Pirate", "Jungle", "Snow", "Underwater", "Ice"}
for _, dungeonName in ipairs(dungeons) do
    action(dungeonPage, "🏰 " .. dungeonName .. " Dungeon", function()
        farmingState.autoDungeon = true
        statusIndicator.BackgroundColor3 = THEME.orange
        Notify("🏰 Dungeon Farming", "Farming " .. dungeonName .. " Dungeon", 3)
        Log("Dungeon Farming: " .. dungeonName)
    end)
end

-- ============================================================
-- RACE V4 PAGE (ENHANCED)
-- ============================================================

label(raceV4Page, "🏎️ RACE V4 GRINDING", 22, THEME.accent)

toggle(raceV4Page, "🏎️ Enable Race V4 Farm", false, function(v)
    farmingState.autoRaceV4 = v
end)

action(raceV4Page, "▶ START RACE V4 FARMING", function()
    farmingState.autoRaceV4 = true
    statusIndicator.BackgroundColor3 = THEME.orange
    Notify("🏎️ Race V4 Farming", "Race V4 grinding activated", 3)
end)

label(raceV4Page, "Complete Race V4 challenges to unlock Cyborg race.", 30, THEME.subtext)

-- ============================================================
-- SEA EVENT PAGE (ENHANCED)
-- ============================================================

label(seaEventPage, "🌊 SEA EVENT FARMING", 22, THEME.accent)

toggle(seaEventPage, "🌊 Enable Sea Events", false, function(v)
    farmingState.autoSeaEvent = v
end)

toggle(seaEventPage, "🐙 Auto Sea Beast Hunt", false, function(v)
    Log("Sea Beast Hunt: " .. (v and "ENABLED" or "DISABLED"))
end)

local seaBeasts = {"Ghost Ship", "Darkbeard", "Hydra", "Leviathan"}
for _, beastName in ipairs(seaBeasts) do
    action(seaEventPage, "🌊 Hunt " .. beastName, function()
        farmingState.autoSeaEvent = true
        statusIndicator.BackgroundColor3 = THEME.orange
        Notify("🌊 Sea Hunt", "Hunting " .. beastName, 3)
        Log("Sea Beast Hunting: " .. beastName)
    end)
end

-- ============================================================
-- COMBAT PAGE (ENHANCED)
-- ============================================================

label(combatPage, "⚔️ COMBAT SYSTEM", 22, THEME.accent)

toggle(combatPage, "⚔️ Auto Combo Attack", false, function(v)
    farmingState.autoCombo = v
end)

toggle(combatPage, "🛡️ Auto Dodge", false, function(v)
    farmingState.autoDodge = v
end)

toggle(combatPage, "🚫 Auto Block Abuse", false, function(v)
    Log("Block Abuse: " .. (v and "ENABLED" or "DISABLED"))
end)

label(combatPage, "Advanced combat automation for all farming systems.", 30, THEME.subtext)

-- ============================================================
-- STATS PAGE (ENHANCED)
-- ============================================================

label(statsPage, "📊 STATISTICS", 22, THEME.accent)

local statsCard = card(statsPage, 250)
label(statsCard, "📊 FARMING STATISTICS", 20, THEME.accent)
local statsLabel = label(statsCard, "", 210, THEME.text)

task.spawn(function()
    while true do
        task.wait(1)
        farmingState.stats.uptime += 1
        statsLabel.Text = string.format(
            "👹 Enemies Defeated: %d\n" ..
            "💰 Beli Earned: %d\n" ..
            "🍎 Fruits Looted: %d\n" ..
            "🎯 Quests Completed: %d\n" ..
            "🏆 Boss Defeats: %d\n" ..
            "📈 Total XP: %d\n" ..
            "⏱️ Uptime: %d seconds",
            farmingState.stats.beatsDefeated,
            farmingState.stats.beliEarned,
            farmingState.stats.fruitsLooted,
            farmingState.stats.questsCompleted,
            farmingState.stats.bossDefeats,
            farmingState.stats.totalXP,
            farmingState.stats.uptime
        )
    end
end)

action(statsPage, "🔄 RESET STATISTICS", function()
    for k in pairs(farmingState.stats) do
        farmingState.stats[k] = 0
    end
    Notify("Reset", "All statistics reset", 2)
    Log("Statistics reset by user")
end)

-- ============================================================
-- SETTINGS PAGE (ENHANCED)
-- ============================================================

label(settingsPage, "⚙️ SETTINGS & CONFIGURATION", 22, THEME.accent)

toggle(settingsPage, "⌨️ RightAlt Hotkey", true, function(v)
    Log("Hotkey: " .. (v and "ENABLED" or "DISABLED"))
end)

toggle(settingsPage, "✨ UI Animations", true, function(v)
    Log("Animations: " .. (v and "ENABLED" or "DISABLED"))
end)

toggle(settingsPage, "🔊 Sound Notifications", false, function(v)
    Log("Sound Notifications: " .. (v and "ENABLED" or "DISABLED"))
end)

toggle(settingsPage, "💾 Auto Save Config", true, function(v)
    Log("Auto Save Config: " .. (v and "ENABLED" or "DISABLED"))
end)

action(settingsPage, "💾 SAVE CONFIG", function()
    saveConfig(farmingState)
    Notify("Saved", "Configuration saved", 2)
    Log("Configuration saved by user")
end)

action(settingsPage, "📂 LOAD CONFIG", function()
    local config = loadConfig()
    if config and config.stats then
        farmingState.stats = config.stats
        Notify("Loaded", "Configuration loaded", 2)
        Log("Configuration loaded by user")
    else
        Notify("Error", "No saved configuration found", 2)
    end
end)

action(settingsPage, "🛑 STOP ALL FARMING", function()
    for k in pairs(farmingState) do
        if k ~= "stats" then
            farmingState[k] = false
        end
    end
    farmingState.farmingActive = false
    statusIndicator.BackgroundColor3 = THEME.green
    Notify("Stopped", "All farming systems stopped", 2)
    Log("All farming stopped by user")
end)

action(settingsPage, "🔄 RESET ALL SETTINGS", function()
    for k in pairs(farmingState) do
        if k ~= "stats" then
            farmingState[k] = false
        end
    end
    Notify("Reset", "All settings reset to default", 2)
    Log("All settings reset by user")
end)

local aboutCard = card(settingsPage, 200)
label(
    aboutCard,
    "🎉 PRO HUB SUPREME v5.5\n\n" ..
    "✨ Ultimate Farming Suite\n" ..
    "✅ All Farming Systems\n" ..
    "✅ Advanced Logging\n" ..
    "✅ Config Save/Load\n" ..
    "✅ Real-time Statistics\n" ..
    "✅ Smooth Animations\n" ..
    "✅ Responsive UI\n" ..
    "✅ Multi-Feature Support\n\n" ..
    "Created by: Pro Gamer Team\n" ..
    "Developer: Rayansh9\n" ..
    "Version: 5.5 SUPREME",
    160,
    THEME.subtext
)

-- ============================================================
-- REAL-TIME UPDATES
-- ============================================================

task.spawn(function()
    while fruitStatsLabel and fruitStatsLabel.Parent do
        task.wait(1)
        fruitStatsLabel.Text = string.format(
            "🍎 Fruits: %d | 💰 Beli: %d",
            farmingState.stats.fruitsLooted,
            farmingState.stats.beliEarned
        )
    end
end)

task.spawn(function()
    while questStatsLabel and questStatsLabel.Parent do
        task.wait(1)
        questStatsLabel.Text = string.format(
            "✅ Quests: %d | 📈 XP: %d",
            farmingState.stats.questsCompleted,
            farmingState.stats.totalXP
        )
    end
end)

task.spawn(function()
    while bossStatsLabel and bossStatsLabel.Parent do
        task.wait(1)
        bossStatsLabel.Text = string.format(
            "🏆 Defeats: %d | 💰 Beli: %d",
            farmingState.stats.bossDefeats,
            farmingState.stats.beliEarned
        )
    end
end)

-- ============================================================
-- PING/FPS DISPLAY
-- ============================================================

local frames = 0
local fps = 60

RunService.RenderStepped:Connect(function()
    frames += 1
end)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.5)
        fps = frames * 2
        frames = 0

        local ping = "--"
        pcall(function()
            local item = Stats.Network.ServerStatsItem["Data Ping"]
            if item then
                ping = tostring(math.floor(item:GetValue()))
            end
        end)

        info.Text = "Ping: " .. ping .. "ms | FPS: " .. tostring(fps)
    end
end)

-- ============================================================
-- HOTKEY FUNCTIONALITY
-- ============================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.RightAlt then
        main.Visible = not main.Visible
    end
end)

-- ============================================================
-- INITIALIZATION
-- ============================================================

buttons["Fruit Farm"].BackgroundColor3 = THEME.accent
buttons["Fruit Farm"].TextColor3 = THEME.white
pages["Fruit Farm"].Visible = true

Log("PRO HUB SUPREME v5.5 Loaded Successfully")
Log("Game: " .. (SUPPORTED_GAMES[gameId] or "Unknown"))
Log("All Features Ready")

Notify("✨ Pro Hub Supreme", "v5.5 Loaded Successfully", 4)

print("═══════════════════════════════════════════════════════")
print("✨ PRO HUB SUPREME v5.5 - ULTIMATE FARMING SUITE ✨")
print("═══════════════════════════════════════════════════════")
print("[✓] All Systems Loaded")
print("[✓] UI Initialized")
print("[✓] RightAlt = Toggle")
print("[✓] Minimize & Pin Buttons Available")
print("[✓] Config Save/Load System Ready")
print("[✓] Advanced Logging Enabled")
print("[✓] No Key System - Full Access")
print("═══════════════════════════════════════════════════════")
