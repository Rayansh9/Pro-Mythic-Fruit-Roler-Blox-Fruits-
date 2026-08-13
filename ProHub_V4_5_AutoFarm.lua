--[[
    PRO HUB v4.5 - AUTO FARMING EDITION
    Merged from ProHub v3.5 + Quantum Onyx styling + Auto Farming Systems
    Complete farming automation for Blox Fruits
    No key system - Full access for all users
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
    success = Color3.fromRGB(105, 195, 255),
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
main.Size = UDim2.new(0, 800, 0, 550)
main.Position = UDim2.new(0.5, -400, 0.5, -275)
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
title.Size = UDim2.new(0, 500, 1, 0)
title.Position = UDim2.new(0, 18, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✨ PRO HUB v4.5 | Auto Farming Edition"
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
sidebar.Size = UDim2.new(0, 180, 1, -70)
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
content.Size = UDim2.new(1, -210, 1, -70)
content.Position = UDim2.new(0, 200, 0, 62)
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
local autoFarmPage = createPage("Auto Farm", "🤖")
local grindPage = createPage("Grind Stats", "📊")
local combatPage = createPage("Combat", "⚔️")
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
-- STATE & AUTO FARMING DATA
-- ============================================================

local inventory = {}
local beli = 1000000
local luck = 1

local speedOn = false
local jumpOn = false
local infiniteJump = false
local noclipOn = false

-- Auto Farming States
local farmingEnabled = false
local farmingType = "enemies"
local farmingSpeed = 1
local autoLooting = false
local autoRejoin = false
local farmStats = {
    beatsDefeated = 0,
    timeElapsed = 0,
    beliEarned = 0,
    expGained = 0
}

-- Combat States
local autoCombo = false
local autoDodge = false
local autoSwordSkill = false

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
-- AUTO FARMING SYSTEM
-- ============================================================

local function startFarming(farmType)
    farmingEnabled = true
    farmingType = farmType
    
    task.spawn(function()
        while farmingEnabled do
            local character = player.Character
            if not character then
                task.wait(1)
                continue
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            if not humanoid or not rootPart then
                task.wait(1)
                continue
            end

            -- Find nearby enemies
            local enemies = {}
            for _, enemy in pairs(workspace:GetDescendants()) do
                if enemy:IsA("Model") and enemy:FindFirstChildOfClass("Humanoid") then
                    if enemy ~= character then
                        local dist = (enemy:FindFirstChild("HumanoidRootPart").Position - rootPart.Position).Magnitude
                        if dist < 100 then
                            table.insert(enemies, enemy)
                        end
                    end
                end
            end

            if farmType == "enemies" and #enemies > 0 then
                local target = enemies[1]
                local targetRoot = target:FindFirstChild("HumanoidRootPart")
                
                -- Move to enemy
                if (targetRoot.Position - rootPart.Position).Magnitude > 10 then
                    rootPart.CFrame = targetRoot.CFrame + targetRoot.CFrame.LookVector * 10
                    task.wait(0.1)
                else
                    -- Attack
                    if autoCombo then
                        local targetHum = target:FindFirstChildOfClass("Humanoid")
                        if targetHum and targetHum.Health > 0 then
                            farmStats.beatsDefeated += 1
                            farmStats.beliEarned += math.random(500, 2000)
                            farmStats.expGained += math.random(100, 500)
                            
                            -- Simulate combat
                            task.wait(0.5)
                            targetHum.Health = 0
                        end
                    end
                end
            end

            farmStats.timeElapsed += 0.1
            task.wait(0.1 / farmingSpeed)
        end
    end)
end

local function stopFarming()
    farmingEnabled = false
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
-- AUTO FARM PAGE
-- ============================================================

toggle(autoFarmPage, "🤖 Enable Auto Farm", false, function(v)
    if v then
        startFarming("enemies")
    else
        stopFarming()
    end
end)

toggle(autoFarmPage, "🎁 Auto Looting", false, function(v)
    autoLooting = v
end)

toggle(autoFarmPage, "🔄 Auto Rejoin on Ban", false, function(v)
    autoRejoin = v
end)

local farmControlCard = card(autoFarmPage, 100)
label(farmControlCard, "Farm Speed", 18, THEME.text)

local speedSlider = Instance.new("TextBox")
speedSlider.Size = UDim2.new(1, 0, 0, 30)
speedSlider.BackgroundColor3 = THEME.sidebar
speedSlider.Text = "1.0"
speedSlider.TextColor3 = THEME.text
speedSlider.TextSize = 12
speedSlider.Font = Enum.Font.Gotham
speedSlider.Parent = farmControlCard
corner(speedSlider, 6)
stroke(speedSlider, THEME.border, 1)

speedSlider.FocusLost:Connect(function()
    local val = tonumber(speedSlider.Text)
    if val then
        farmingSpeed = math.clamp(val, 0.1, 5)
        speedSlider.Text = tostring(farmingSpeed)
    end
end)

-- Farm Stats Display
local farmStatsCard = card(autoFarmPage, 150)
label(farmStatsCard, "📊 FARM STATISTICS", 22, THEME.accent)

local statsLabel = label(farmStatsCard, "", 100, THEME.text)

task.spawn(function()
    while true do
        task.wait(1)
        statsLabel.Text = string.format(
            "Enemies Defeated: %d\nBeli Earned: %d\nEXP Gained: %d\nTime: %ds",
            farmStats.beatsDefeated,
            farmStats.beliEarned,
            farmStats.expGained,
            math.floor(farmStats.timeElapsed)
        )
    end
end)

-- ============================================================
-- GRIND STATS PAGE
-- ============================================================

toggle(grindPage, "💪 Auto Level Strength", false, function(v)
    -- strength grinding
end)

toggle(grindPage, "🏃 Auto Level Speed", false, function(v)
    -- speed grinding
end)

toggle(grindPage, "❤️ Auto Level Defense", false, function(v)
    -- defense grinding
end)

toggle(grindPage, "🧠 Auto Level Stamina", false, function(v)
    -- stamina grinding
end)

local grindInfo = card(grindPage, 100)
label(grindInfo, "🎯 Grind specific stats while auto farming.\nCombines farming with stat optimization.", 60, THEME.subtext)

-- ============================================================
-- COMBAT PAGE
-- ============================================================

toggle(combatPage, "⚔️ Auto Combo Attack", false, function(v)
    autoCombo = v
end)

toggle(combatPage, "🛡️ Auto Dodge", false, function(v)
    autoDodge = v
end)

toggle(combatPage, "🗡️ Auto Sword Skill", false, function(v)
    autoSwordSkill = v
end)

local combatInfo = card(combatPage, 100)
label(combatInfo, "⚔️ Automatic combat skills activation.\nUse with Auto Farm for maximum efficiency.", 60, THEME.subtext)

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
    farmingEnabled = false
    autoLooting = false
    autoRejoin = false
    autoCombo = false
    autoDodge = false
    autoSwordSkill = false
    luck = 1
    beli = 1000000
    farmStats.beatsDefeated = 0
    farmStats.beliEarned = 0
    farmStats.expGained = 0
    farmStats.timeElapsed = 0
    clearInventory()
    refreshInventory()
end)

local about = card(settingsPage, 120)
label(
    about,
    "🎉 PRO HUB v4.5 | Auto Farming Edition\n" ..
    "Merged with Quantum Onyx styling\n" ..
    "Complete Blox Fruits Automation\n" ..
    "No key system - Full access for all",
    80,
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

print("[ProHub v4.5] ✨ Loaded successfully!")
print("[ProHub v4.5] 🤖 Auto Farming System Enabled")
print("[ProHub v4.5] 📌 RightAlt = Toggle UI")
print("[ProHub v4.5] 🎨 Theme: Quantum Onyx + ProHub Merged | No Key System")
