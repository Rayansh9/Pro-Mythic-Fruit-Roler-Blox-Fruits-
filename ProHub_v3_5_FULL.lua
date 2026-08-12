-- ============================================================
-- PRO HUB v3.5 - CLEAN FULL GUI
-- Roblox LocalScript / Studio-safe implementation
-- Combines the requested Pro Hub tabs with the supplied Mythic
-- roll/inventory/boost/command ideas.
--
-- IMPORTANT:
-- This script only implements client-side UI/local features.
-- Quest, trade and sea-event automation require the actual game's
-- server RemoteEvents and are intentionally left as hooks below.
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

local playerGui = player:WaitForChild("PlayerGui")

-- Remove an earlier copy.
local oldGui = playerGui:FindFirstChild("ProHubUI")
if oldGui then
    oldGui:Destroy()
end

-- ============================================================
-- THEME
-- ============================================================

local THEME = {
    bg = Color3.fromRGB(15, 13, 22),
    sidebar = Color3.fromRGB(20, 17, 30),
    card = Color3.fromRGB(26, 22, 40),
    border = Color3.fromRGB(45, 38, 66),
    accent = Color3.fromRGB(147, 51, 234),
    accentHover = Color3.fromRGB(168, 85, 247),
    cyan = Color3.fromRGB(6, 182, 212),
    text = Color3.fromRGB(243, 244, 246),
    subtext = Color3.fromRGB(156, 163, 175),
    white = Color3.fromRGB(255, 255, 255),
    red = Color3.fromRGB(239, 68, 68),
    green = Color3.fromRGB(34, 197, 94),
}

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

local function tween(obj, info, props)
    return TweenService:Create(obj, info, props)
end

-- ============================================================
-- GUI
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 650, 0, 420)
main.Position = UDim2.new(0.5, -325, 0.5, -210)
main.BackgroundColor3 = THEME.bg
main.Active = true
main.Parent = ScreenGui
corner(main, 12)
stroke(main, THEME.accent, 1.5)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 48)
top.BackgroundColor3 = THEME.sidebar
top.Parent = main
corner(top, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 340, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✨ PRO HUB | v3.5"
title.TextColor3 = THEME.text
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local info = Instance.new("TextLabel")
info.Size = UDim2.new(0, 220, 1, 0)
info.Position = UDim2.new(1, -260, 0, 0)
info.BackgroundTransparency = 1
info.Text = "Ping: -- | FPS: --"
info.TextColor3 = THEME.subtext
info.TextSize = 10
info.Font = Enum.Font.Gotham
info.TextXAlignment = Enum.TextXAlignment.Right
info.Parent = top

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -36, 0.5, -14)
close.BackgroundColor3 = THEME.card
close.Text = "X"
close.TextColor3 = THEME.red
close.TextSize = 12
close.Font = Enum.Font.GothamBold
close.Parent = top
corner(close, 6)

-- Simple drag support (works in Studio too).
do
    local dragging = false
    local dragStart
    local startPos

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
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 150, 1, -60)
sidebar.Position = UDim2.new(0, 10, 0, 54)
sidebar.BackgroundColor3 = THEME.sidebar
sidebar.Parent = main
corner(sidebar, 10)
padding(sidebar, 8, 8, 7, 7)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 5)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -174, 1, -60)
content.Position = UDim2.new(0, 164, 0, 54)
content.BackgroundColor3 = THEME.sidebar
content.Parent = main
corner(content, 10)
padding(content, 10, 10, 10, 10)

local pages = {}
local buttons = {}

local function createPage(name, icon)
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(1, 0, 0, 34)
    button.BackgroundColor3 = THEME.card
    button.Text = icon .. "  " .. name
    button.TextColor3 = THEME.subtext
    button.TextSize = 11
    button.Font = Enum.Font.GothamSemibold
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = sidebar
    corner(button, 6)

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
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

    return page
end

local rollPage = createPage("Pro Roll", "🏆")
local boostPage = createPage("Elite Boost", "⚡")
local inventoryPage = createPage("Pro Inventory", "🎒")
local tradePage = createPage("Trade Pro", "⚖")
local questPage = createPage("Pro Quests", "🛡")
local seaPage = createPage("Elite Sea Event", "🌊")
local settingsPage = createPage("Pro Settings", "⚙")

-- ============================================================
-- COMPONENTS
-- ============================================================

local function card(parent, height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, height or 60)
    f.BackgroundColor3 = THEME.card
    f.Parent = parent
    corner(f, 8)
    stroke(f, THEME.border, 1)
    padding(f, 10, 10, 10, 10)
    return f
end

local function label(parent, text, size, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, size or 24)
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
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = THEME.accent
    b.Text = text
    b.TextColor3 = THEME.white
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.Parent = parent
    corner(b, 6)

    b.MouseEnter:Connect(function()
        tween(b, TweenInfo.new(0.12), {BackgroundColor3 = THEME.accentHover}):Play()
    end)
    b.MouseLeave:Connect(function()
        tween(b, TweenInfo.new(0.12), {BackgroundColor3 = THEME.accent}):Play()
    end)
    b.MouseButton1Click:Connect(callback)

    return b
end

local function toggle(parent, text, default, callback)
    local f = card(parent, 40)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -70, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = THEME.text
    t.TextSize = 11
    t.Font = Enum.Font.GothamSemibold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 54, 0, 24)
    b.Position = UDim2.new(1, -54, 0.5, -12)
    b.TextSize = 9
    b.Font = Enum.Font.GothamBold
    b.Parent = f
    corner(b, 12)

    local state = default == true

    local function render()
        b.Text = state and "ON" or "OFF"
        b.BackgroundColor3 = state and THEME.green or THEME.sidebar
        b.TextColor3 = state and THEME.white or THEME.subtext
    end

    b.MouseButton1Click:Connect(function()
        state = not state
        render()
        callback(state)
    end)

    render()
    callback(state)
    return f
end

local function setOutput(parent, text, color)
    local l = parent:FindFirstChild("Output")
    if not l then
        l = label(parent, "", 42, color or THEME.subtext)
        l.Name = "Output"
    end
    l.Text = text
    l.TextColor3 = color or THEME.subtext
    return l
end

-- ============================================================
-- STATE
-- ============================================================

local inventory = {}
local beli = 1000000
local luck = 1

local speedOn = false
local jumpOn = false
local infiniteJump = false
local noclipOn = false

local autoTrade = false
local autoAddMythics = false
local autoQuest = false
local autoCompleteQuest = false
local autoSeaHunt = false
local autoSeaBeast = false

local hotkeyEnabled = true
local shimmerEnabled = true

local MYTHIC_POOL = {
    {Name = "Kitsune", Weight = 1},
    {Name = "Dragon", Weight = 1},
    {Name = "Leopard", Weight = 2},
    {Name = "Dough", Weight = 3},
    {Name = "T-Rex", Weight = 4},
    {Name = "Mammoth", Weight = 5},
    {Name = "Spirit", Weight = 5},
    {Name = "Venom", Weight = 6},
    {Name = "Shadow", Weight = 7},
    {Name = "Gravity", Weight = 8},
}

local function chooseFruit()
    local total = 0
    for _, fruit in ipairs(MYTHIC_POOL) do
        total += fruit.Weight * luck
    end

    local roll = math.random() * total
    local count = 0

    for _, fruit in ipairs(MYTHIC_POOL) do
        count += fruit.Weight * luck
        if roll <= count then
            return fruit.Name
        end
    end

    return MYTHIC_POOL[1].Name
end

local function addFruit(name)
    table.insert(inventory, name)
end

local function clearInventory()
    table.clear(inventory)
end

-- ============================================================
-- PRO ROLL
-- ============================================================

do
    local c = card(rollPage, 150)
    label(c, "MYTHICAL-ONLY ROLL", 22, THEME.accent)

    local status = label(c, "Ready to roll.", 32, THEME.subtext)
    status.Name = "RollStatus"

    local rollButton = action(c, "🎲  ROLL MYTHICAL FRUIT", function()
        local result = chooseFruit()
        addFruit(result)
        beli = math.max(0, beli - 100000)
        status.Text = "🎉 OBTAINED: " .. string.upper(result)
        status.TextColor3 = THEME.green
        refreshInventory()
    end)

    label(c, "Cost: 100,000 local Beli | Luck: x" .. tostring(luck), 20, THEME.subtext)
end

-- ============================================================
-- ELITE BOOST
-- ============================================================

toggle(boostPage, "Speed Boost (100)", false, function(v)
    speedOn = v
end)

toggle(boostPage, "High Jump (120)", false, function(v)
    jumpOn = v
end)

toggle(boostPage, "Infinite Jump", false, function(v)
    infiniteJump = v
end)

toggle(boostPage, "Noclip", false, function(v)
    noclipOn = v
end)

local boostInfo = card(boostPage, 72)
label(boostInfo, "These toggles modify your local character only.", 48, THEME.subtext)

-- ============================================================
-- INVENTORY
-- ============================================================

local inventoryList

local function refreshInventory()
    if not inventoryList then return end

    for _, child in ipairs(inventoryList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    if #inventory == 0 then
        label(inventoryList, "Inventory is empty.", 28, THEME.subtext)
        return
    end

    for i, fruit in ipairs(inventory) do
        label(inventoryList, i .. ". " .. fruit, 26, THEME.text)
    end
end

do
    local c = card(inventoryPage, 250)
    label(c, "PRO INVENTORY", 24, THEME.accent)

    inventoryList = Instance.new("Frame")
    inventoryList.Size = UDim2.new(1, 0, 0, 170)
    inventoryList.BackgroundTransparency = 1
    inventoryList.Parent = c

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = inventoryList

    action(c, "🗑 CLEAR INVENTORY", function()
        clearInventory()
        refreshInventory()
    end)

    refreshInventory()
end

-- ============================================================
-- TRADE PRO
-- ============================================================

toggle(tradePage, "Auto Accept Trades", false, function(v)
    autoTrade = v
end)

toggle(tradePage, "Auto Add Mythical Fruits", false, function(v)
    autoAddMythics = v
end)

local tradeInfo = card(tradePage, 90)
label(
    tradeInfo,
    "Trade hooks are ready for your game's RemoteEvents. " ..
    "No fake server trade is performed by this client-only version.",
    66,
    THEME.subtext
)

-- ============================================================
-- PRO QUESTS
-- ============================================================

toggle(questPage, "Auto Take Quest (Lv 2880+)", false, function(v)
    autoQuest = v
end)

toggle(questPage, "Auto Complete Active Quest", false, function(v)
    autoCompleteQuest = v
end)

local questInfo = card(questPage, 92)
label(
    questInfo,
    "Quest automation requires the exact quest RemoteEvent/function " ..
    "from your game's server. Add it in the hook section at the bottom.",
    70,
    THEME.subtext
)

-- ============================================================
-- ELITE SEA EVENT
-- ============================================================

toggle(seaPage, "Auto Sea Hunt", false, function(v)
    autoSeaHunt = v
end)

toggle(seaPage, "Auto Attack Sea Beast / TerrorShark", false, function(v)
    autoSeaBeast = v
end)

local seaCard = card(seaPage, 180)
label(seaCard, "LOCAL EVENT SIMULATION", 22, THEME.accent)

action(seaCard, "🚢 GHOST SHIP REWARD", function()
    addFruit("Dough")
    refreshInventory()
end)

action(seaCard, "🐉 DARKBEARD REWARD", function()
    addFruit("Dragon")
    refreshInventory()
end)

action(seaCard, "🌊 MYTHIC SURGE", function()
    addFruit(chooseFruit())
    refreshInventory()
end)

label(
    seaCard,
    "The reward buttons above are local inventory simulations, " ..
    "not real server rewards.",
    44,
    THEME.subtext
)

-- ============================================================
-- SETTINGS / COMMAND CONSOLE
-- ============================================================

local commandBox
local commandOutput

local function processCommand(raw)
    local text = tostring(raw or "")
    local lower = text:lower()

    if lower == ";help" then
        commandOutput.Text =
            ";speed <n> | ;reset | ;roll | ;inv\n" ..
            ";clearinv | ;luck <n> | ;addbeli <n>"
        commandOutput.TextColor3 = THEME.text

    elseif lower:sub(1, 7) == ";speed " then
        local value = tonumber(lower:sub(8))
        local character = player.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")

        if value and hum then
            hum.WalkSpeed = value
            commandOutput.Text = "WalkSpeed = " .. tostring(value)
            commandOutput.TextColor3 = THEME.green
        else
            commandOutput.Text = "Invalid speed."
            commandOutput.TextColor3 = THEME.red
        end

    elseif lower == ";reset" then
        local character = player.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end

    elseif lower == ";roll" or lower == ";spin" then
        local result = chooseFruit()
        addFruit(result)
        refreshInventory()
        commandOutput.Text = "Rolled: " .. result
        commandOutput.TextColor3 = THEME.green

    elseif lower == ";inv" then
        commandOutput.Text = "Inventory: " .. tostring(#inventory) .. " item(s)"
        commandOutput.TextColor3 = THEME.text

    elseif lower == ";clearinv" then
        clearInventory()
        refreshInventory()
        commandOutput.Text = "Inventory cleared."
        commandOutput.TextColor3 = THEME.green

    elseif lower:sub(1, 6) == ";luck " then
        local value = tonumber(lower:sub(7))
        if value and value > 0 then
            luck = math.clamp(value, 0.1, 10000)
            commandOutput.Text = "Local luck = x" .. tostring(luck)
            commandOutput.TextColor3 = THEME.green
        else
            commandOutput.Text = "Invalid luck."
            commandOutput.TextColor3 = THEME.red
        end

    elseif lower:sub(1, 9) == ";addbeli " then
        local value = tonumber(lower:sub(10))
        if value then
            beli += value
            commandOutput.Text = "Local Beli = " .. tostring(beli)
            commandOutput.TextColor3 = THEME.green
        end

    else
        commandOutput.Text = "Unknown command. Use ;help"
        commandOutput.TextColor3 = THEME.red
    end
end

do
    local c = card(settingsPage, 170)
    label(c, "COMMAND CONSOLE", 22, THEME.accent)

    commandBox = Instance.new("TextBox")
    commandBox.Size = UDim2.new(1, 0, 0, 36)
    commandBox.BackgroundColor3 = THEME.sidebar
    commandBox.PlaceholderText = "Type command... ;help"
    commandBox.PlaceholderColor3 = THEME.subtext
    commandBox.TextColor3 = THEME.text
    commandBox.TextSize = 11
    commandBox.Font = Enum.Font.Gotham
    commandBox.ClearTextOnFocus = false
    commandBox.Parent = c
    corner(commandBox, 6)
    stroke(commandBox, THEME.border, 1)

    commandOutput = label(c, "Ready.", 44, THEME.subtext)
    commandOutput.Name = "CommandOutput"

    action(c, "▶ RUN COMMAND", function()
        processCommand(commandBox.Text)
        commandBox.Text = ""
    end)
end

toggle(settingsPage, "RIGHTALT SHOW / HIDE", true, function(v)
    hotkeyEnabled = v
end)

toggle(settingsPage, "UI SHIMMER EFFECT", true, function(v)
    shimmerEnabled = v
end)

action(settingsPage, "RESET LOCAL SETTINGS", function()
    speedOn = false
    jumpOn = false
    infiniteJump = false
    noclipOn = false
    autoTrade = false
    autoAddMythics = false
    autoQuest = false
    autoCompleteQuest = false
    autoSeaHunt = false
    autoSeaBeast = false
    luck = 1
    beli = 1000000
    clearInventory()
    refreshInventory()
end)

local about = card(settingsPage, 75)
label(
    about,
    "PRO HUB v3.5 | Local GUI build\n" ..
    "RightAlt toggles the window. Use the server hooks below " ..
    "when integrating with your own Roblox experience.",
    58,
    THEME.subtext
)

-- ============================================================
-- CHARACTER / LOCAL BOOST LOOP
-- ============================================================

RunService.RenderStepped:Connect(function()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        if speedOn then
            humanoid.WalkSpeed = 100
        end

        if jumpOn then
            humanoid.JumpPower = 120
        end
    end

    if noclipOn and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ============================================================
-- LIVE PING / FPS
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
-- HOTKEY / CLOSE
-- ============================================================

close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if hotkeyEnabled and input.KeyCode == Enum.KeyCode.RightAlt then
        main.Visible = not main.Visible
    end
end)

-- ============================================================
-- GAME-SPECIFIC SERVER HOOKS
-- ============================================================
-- Put your own game's RemoteEvents here.
-- Example pattern:
--
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local Remotes = ReplicatedStorage:WaitForChild("Remotes")
--
-- local function takeQuest()
--     Remotes.TakeQuest:FireServer(...)
-- end
--
-- local function completeQuest()
--     Remotes.CompleteQuest:FireServer(...)
-- end
--
-- local function acceptTrade()
--     Remotes.AcceptTrade:FireServer(...)
-- end
--
-- local function seaAttack()
--     Remotes.SeaAttack:FireServer(...)
-- end
--
-- Do NOT invent remote names. They must match your own game's
-- server implementation.

-- Default tab
buttons["Pro Roll"].BackgroundColor3 = THEME.accent
buttons["Pro Roll"].TextColor3 = THEME.white
pages["Pro Roll"].Visible = true

print("[ProHub] v3.5 loaded successfully.")
print("[ProHub] RightAlt = show/hide")
