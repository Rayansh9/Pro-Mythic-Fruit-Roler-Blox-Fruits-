--[[
    PRO HUB v4.0 - UNIFIED EDITION
    Merged from ProHub v3.5 + Quantum Onyx styling
    Clean, modern UI with advanced features
    No key system - full access for all users
    Created: 2026
]]--

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

-- Remove earlier copy
local oldGui = playerGui:FindFirstChild("ProHubUI")
if oldGui then
    oldGui:Destroy()
end

-- ============================================================
-- THEME (Quantum Onyx + ProHub merged)
-- ============================================================

local THEME = {
    bg = Color3.fromRGB(6, 3, 12),
    sidebar = Color3.fromRGB(9, 5, 18),
    card = Color3.fromRGB(15, 8, 30),
    border = Color3.fromRGB(110, 50, 210),
    accent = Color3.fromRGB(155, 90, 255),
    accentHover = Color3.fromRGB(168, 85, 247),
    cyan = Color3.fromRGB(105, 175, 255),
    text = Color3.fromRGB(220, 200, 255),
    subtext = Color3.fromRGB(156, 163, 175),
    white = Color3.fromRGB(255, 255, 255),
    red = Color3.fromRGB(239, 68, 68),
    green = Color3.fromRGB(80, 230, 130),
    warning = Color3.fromRGB(255, 200, 80),
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
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
        c:Destroy()
    end)
end

-- ============================================================
-- GUI SETUP
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 700, 0, 480)
main.Position = UDim2.new(0.5, -350, 0.5, -240)
main.BackgroundColor3 = THEME.bg
main.Active = true
main.Parent = ScreenGui
corner(main, 14)
stroke(main, THEME.accent, 2)

-- Background effects (Quantum Onyx style)
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
top.Size = UDim2.new(1, 0, 0, 56)
top.BackgroundColor3 = THEME.sidebar
top.Parent = main
corner(top, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 400, 1, 0)
title.Position = UDim2.new(0, 18, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✨ PRO HUB v4.0 | Unified Edition"
title.TextColor3 = THEME.text
title.TextSize = 16
title.Font = Enum.Font.FredokaOne
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

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

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(1, -42, 0.5, -16)
close.BackgroundColor3 = THEME.card
close.Text = "✕"
close.TextColor3 = THEME.red
close.TextSize = 16
close.Font = Enum.Font.GothamBold
close.Parent = top
corner(close, 8)
stroke(close, THEME.red, 1)

-- Drag support
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

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 160, 1, -70)
sidebar.Position = UDim2.new(0, 12, 0, 62)
sidebar.BackgroundColor3 = THEME.sidebar
sidebar.Parent = main
corner(sidebar, 12)
stroke(sidebar, THEME.border, 1)
padding(sidebar, 10, 10, 8, 8)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 6)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = sidebar

-- Content area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -190, 1, -70)
content.Position = UDim2.new(0, 180, 0, 62)
content.BackgroundColor3 = THEME.sidebar
content.Parent = main
corner(content, 12)
stroke(content, THEME.border, 1)
padding(content, 12, 12, 12, 12)

local pages = {}
local buttons = {}

-- ============================================================
-- PAGE CREATION SYSTEM
-- ============================================================

local function createPage(name, icon)
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = THEME.card
    button.Text = icon .. "  " .. name
    button.TextColor3 = THEME.subtext
    button.TextSize = 12
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
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local function resize()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

    pages[name] = page
    buttons[name] = button

    button.MouseButton1Click:Connect(function()
        CircleRipple(button, game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
        for n, p in pairs(pages) do
            p.Visible = false
            buttons[n].BackgroundColor3 = THEME.card
            buttons[n].TextColor3 = THEME.subtext
        end
        page.Visible = true
        button.BackgroundColor3 = THEME.accent
        button.TextColor3 = THEME.white
        Tween(button, { BackgroundColor3 = THEME.accent }, 0.12)
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

-- Create pages
local rollPage = createPage("Pro Roll", "🏆")
local boostPage = createPage("Elite Boost", "⚡")
local inventoryPage = createPage("Pro Inventory", "🎒")
local tradePage = createPage("Trade Pro", "⚖️")
local questPage = createPage("Pro Quests", "🛡️")
local seaPage = createPage("Elite Sea", "🌊")
local commandPage = createPage("Console", "⌨️")
local settingsPage = createPage("Settings", "⚙️")

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
    padding(f, 12, 12, 12, 12)
    return f
end

local function label(parent, text, size, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, size or 26)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or THEME.text
    l.TextSize = 12
    l.Font = Enum.Font.Gotham
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function action(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = THEME.accent
    b.Text = text
    b.TextColor3 = THEME.white
    b.TextSize = 12
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
        CircleRipple(b, game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
        callback()
    end)

    return b
end

local function toggle(parent, text, default, callback)
    local f = card(parent, 44)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -70, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = THEME.text
    t.TextSize = 12
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 60, 0, 28)
    b.Position = UDim2.new(1, -60, 0.5, -14)
    b.TextSize = 10
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
        state = not state
        render()
        callback(state)
    end)

    render()
    callback(state)
    return f
end

-- ============================================================
-- STATE & DATA
-- ============================================================

local inventory = {}
local beli = 1000000
local luck = 1

local speedOn = false
local jumpOn = false
local infiniteJump = false
local noclipOn = false

local autoTrade = false
local autoQuest = false
local autoCompleteQuest = false
local autoSeaHunt = false

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
    {Name = "Kilo", Weight = 9},
    {Name = "Pika", Weight = 10},
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
-- PRO ROLL PAGE
-- ============================================================

do
    local c = card(rollPage, 180)
    label(c, "🎲 MYTHICAL-ONLY ROLL", 26, THEME.accent)

    local status = label(c, "Ready to roll for your dream fruit!", 40, THEME.subtext)
    status.Name = "RollStatus"

    local rollButton = action(c, "🎲 SPIN MYTHICAL FRUIT", function()
        local result = chooseFruit()
        addFruit(result)
        beli = math.max(0, beli - 100000)
        status.Text = "🎉 OBTAINED: " .. string.upper(result) .. " ✨"
        status.TextColor3 = THEME.green
        refreshInventory()
    end)

    label(c, "💰 Cost: 100,000 Beli  |  🍀 Luck: x" .. tostring(luck), 22, THEME.warning)
end

-- ============================================================
-- ELITE BOOST PAGE
-- ============================================================

toggle(boostPage, "⚡ Speed Boost (100)", false, function(v)
    speedOn = v
end)

toggle(boostPage, "🚀 High Jump (120)", false, function(v)
    jumpOn = v
end)

toggle(boostPage, "∞ Infinite Jump", false, function(v)
    infiniteJump = v
end)

toggle(boostPage, "👻 Noclip", false, function(v)
    noclipOn = v
end)

local boostInfo = card(boostPage, 80)
label(boostInfo, "⚠️ These toggles modify your local character only.\nServer permissions required for multiplayer use.", 50, THEME.warning)

-- ============================================================
-- INVENTORY PAGE
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
        label(inventoryList, "📭 Inventory is empty. Start rolling!", 30, THEME.subtext)
        return
    end

    for i, fruit in ipairs(inventory) do
        label(inventoryList, (i) .. ". " .. fruit .. " ✓", 28, THEME.text)
    end
end

do
    local c = card(inventoryPage, 300)
    label(c, "🎒 PRO INVENTORY", 28, THEME.accent)

    inventoryList = Instance.new("Frame")
    inventoryList.Size = UDim2.new(1, 0, 0, 200)
    inventoryList.BackgroundTransparency = 1
    inventoryList.Parent = c

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = inventoryList

    action(c, "🗑️ CLEAR INVENTORY", function()
        clearInventory()
        refreshInventory()
    end)

    refreshInventory()
end

-- ============================================================
-- TRADE PRO PAGE
-- ============================================================

toggle(tradePage, "⚖️ Auto Accept Trades", false, function(v)
    autoTrade = v
end)

toggle(tradePage, "🔄 Auto Add Mythics", false, function(v)
    -- auto add functionality
end)

local tradeInfo = card(tradePage, 100)
label(tradeInfo, "📡 Trade system ready for integration.\n\nAdd server RemoteEvents in the hooks section at the bottom of the script.\nNo fake trades - client-only validation.", 70, THEME.subtext)

-- ============================================================
-- PRO QUESTS PAGE
-- ============================================================

toggle(questPage, "✅ Auto Take Quest (Lv 2880+)", false, function(v)
    autoQuest = v
end)

toggle(questPage, "⚔️ Auto Complete Quest", false, function(v)
    autoCompleteQuest = v
end)

local questInfo = card(questPage, 100)
label(questInfo, "🛡️ Quest automation requires server integration.\n\nEnsure your game has the proper RemoteEvent setup.\nContact support for integration help.", 70, THEME.subtext)

-- ============================================================
-- ELITE SEA EVENT PAGE
-- ============================================================

toggle(seaPage, "🚢 Auto Sea Hunt", false, function(v)
    autoSeaHunt = v
end)

toggle(seaPage, "🐙 Auto Attack Sea Beast", false, function(v)
    -- sea beast functionality
end)

local seaCard = card(seaPage, 220)
label(seaCard, "🌊 LOCAL SEA EVENT REWARDS", 26, THEME.accent)

action(seaCard, "🚢 GHOST SHIP REWARD", function()
    addFruit("Dough")
    refreshInventory()
end)

action(seaCard, "🐉 DARKBEARD REWARD", function()
    addFruit("Dragon")
    refreshInventory()
end)

action(seaCard, "⚡ MYTHIC SURGE", function()
    addFruit(chooseFruit())
    refreshInventory()
end)

label(seaCard, "💡 Reward buttons simulate local inventory changes.", 28, THEME.subtext)

-- ============================================================
-- COMMAND CONSOLE PAGE
-- ============================================================

local commandBox
local commandOutput

local function processCommand(raw)
    local text = tostring(raw or "")
    local lower = text:lower()

    if lower == ";help" then
        commandOutput.Text = ";speed <n> | ;jump <n> | ;reset | ;roll | ;inv | ;clearinv | ;luck <n> | ;addbeli <n>"
        commandOutput.TextColor3 = THEME.text

    elseif lower:sub(1, 7) == ";speed " then
        local value = tonumber(lower:sub(8))
        local character = player.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if value and hum then
            hum.WalkSpeed = value
            commandOutput.Text = "✓ WalkSpeed set to " .. tostring(value)
            commandOutput.TextColor3 = THEME.green
        else
            commandOutput.Text = "✗ Invalid speed value"
            commandOutput.TextColor3 = THEME.red
        end

    elseif lower == ";reset" then
        local character = player.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
            commandOutput.Text = "✓ Character reset"
            commandOutput.TextColor3 = THEME.green
        end

    elseif lower == ";roll" or lower == ";spin" then
        local result = chooseFruit()
        addFruit(result)
        refreshInventory()
        commandOutput.Text = "✓ Rolled: " .. result
        commandOutput.TextColor3 = THEME.green

    elseif lower == ";inv" then
        commandOutput.Text = "📊 Inventory: " .. tostring(#inventory) .. " item(s)"
        commandOutput.TextColor3 = THEME.text

    elseif lower == ";clearinv" then
        clearInventory()
        refreshInventory()
        commandOutput.Text = "✓ Inventory cleared"
        commandOutput.TextColor3 = THEME.green

    elseif lower:sub(1, 6) == ";luck " then
        local value = tonumber(lower:sub(7))
        if value and value > 0 then
            luck = math.clamp(value, 0.1, 10000)
            commandOutput.Text = "✓ Luck multiplier: x" .. tostring(luck)
            commandOutput.TextColor3 = THEME.green
        else
            commandOutput.Text = "✗ Invalid luck value"
            commandOutput.TextColor3 = THEME.red
        end

    elseif lower:sub(1, 9) == ";addbeli " then
        local value = tonumber(lower:sub(10))
        if value then
            beli += value
            commandOutput.Text = "✓ Beli: " .. tostring(beli)
            commandOutput.TextColor3 = THEME.green
        else
            commandOutput.Text = "✗ Invalid beli value"
            commandOutput.TextColor3 = THEME.red
        end

    else
        commandOutput.Text = "❓ Unknown command. Type ;help"
        commandOutput.TextColor3 = THEME.warning
    end
end

do
    local c = card(commandPage, 200)
    label(c, "⌨️ COMMAND CONSOLE", 26, THEME.accent)

    commandBox = Instance.new("TextBox")
    commandBox.Size = UDim2.new(1, 0, 0, 40)
    commandBox.BackgroundColor3 = THEME.sidebar
    commandBox.PlaceholderText = "Type command... (;help)"
    commandBox.PlaceholderColor3 = THEME.subtext
    commandBox.TextColor3 = THEME.text
    commandBox.TextSize = 12
    commandBox.Font = Enum.Font.Gotham
    commandBox.ClearTextOnFocus = false
    commandBox.Parent = c
    corner(commandBox, 8)
    stroke(commandBox, THEME.border, 1)
    padding(commandBox, 8, 8, 8, 8)

    commandOutput = label(c, "Ready. Type ;help for commands.", 50, THEME.subtext)
    commandOutput.Name = "CommandOutput"

    action(c, "▶ EXECUTE COMMAND", function()
        processCommand(commandBox.Text)
        commandBox.Text = ""
    end)
end

-- ============================================================
-- SETTINGS PAGE
-- ============================================================

toggle(settingsPage, "⌨️ RIGHTALT HOTKEY", true, function(v)
    -- hotkey functionality
end)

toggle(settingsPage, "✨ UI ANIMATIONS", true, function(v)
    -- animation toggle
end)

action(settingsPage, "🔄 RESET ALL SETTINGS", function()
    speedOn = false
    jumpOn = false
    infiniteJump = false
    noclipOn = false
    autoTrade = false
    autoQuest = false
    autoCompleteQuest = false
    autoSeaHunt = false
    luck = 1
    beli = 1000000
    clearInventory()
    refreshInventory()
end)

local about = card(settingsPage, 100)
label(
    about,
    "🎉 PRO HUB v4.0 | Unified Edition\n" ..
    "Merged with Quantum Onyx styling\n" ..
    "No key system - Full access for all",
    70,
    THEME.subtext
)

-- ============================================================
-- CHARACTER BOOST LOOP
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
-- HOTKEY & CLOSE
-- ============================================================

close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.RightAlt then
        main.Visible = not main.Visible
    end
end)

-- ============================================================
-- INITIALIZATION
-- ============================================================

-- Set default tab
buttons["Pro Roll"].BackgroundColor3 = THEME.accent
buttons["Pro Roll"].TextColor3 = THEME.white
pages["Pro Roll"].Visible = true

print("[ProHub v4.0] ✨ Loaded successfully!")
print("[ProHub v4.0] 📌 RightAlt = Toggle UI | Type ;help in console for commands")
print("[ProHub v4.0] 🎨 Theme: Quantum Onyx + ProHub Merged | No Key System")
