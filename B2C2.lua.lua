local players = game:GetService("Players")
local coreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local localPlayer = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait() or players.LocalPlayer

-- File configuration path para sa save/load
local configFileName = "IOHUB_Config.json"
local currentConfigData = {
    toggles = {},
    dropdowns = {}
}

-- Load saved config if exists
if readfile and pcall(readfile, configFileName) then
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(configFileName))
    end)
    if success and decoded then
        currentConfigData = decoded
    end
end

local function saveConfigToFile()
    if writefile then
        pcall(function()
            writefile(configFileName, HttpService:JSONEncode(currentConfigData))
        end)
    end
end

-- Main ScreenGui setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalMenuGui_Delta"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    screenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = coreGui
else
    screenGui.Parent = coreGui
end

----------------------------------------------------
-- NOTIFICATION SYSTEM
----------------------------------------------------
local function showNotification(message)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 220, 0, 40)
    notifFrame.Position = UDim2.new(1, -235, 1, -60)
    notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notifFrame.BackgroundTransparency = 0.2
    notifFrame.BorderSizePixel = 0
    notifFrame.ZIndex = 999
    notifFrame.Parent = screenGui

    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 8)
    nCorner.Parent = notifFrame

    local nStroke = Instance.new("UIStroke")
    nStroke.Color = Color3.fromRGB(150, 30, 50)
    nStroke.Thickness = 1
    nStroke.Parent = notifFrame

    local nText = Instance.new("TextLabel")
    nText.Size = UDim2.new(1, 0, 1, 0)
    nText.BackgroundTransparency = 1
    nText.Text = message
    nText.TextColor3 = Color3.fromRGB(255, 255, 255)
    nText.Font = Enum.Font.GothamBold
    nText.TextSize = 11
    nText.ZIndex = 1000
    nText.Parent = notifFrame

    task.delay(2, function()
        local tw = TweenService:Create(notifFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        tw:Play()
        TweenService:Create(nText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        tw.Completed:Connect(function()
            notifFrame:Destroy()
        end)
    end)
end

----------------------------------------------------
-- MAIN CONTAINER WINDOW
----------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 580, 0, 420)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false 
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

----------------------------------------------------
-- FLOATING TOGGLE IMAGE BUTTON
----------------------------------------------------
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "MenuToggleButton"
toggleButton.Size = UDim2.new(0, 55, 0, 55)
toggleButton.Position = UDim2.new(0, 20, 0.5, -27) 
toggleButton.BackgroundTransparency = 1
toggleButton.Image = "rbxassetid://139934599708171" 
toggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Active = true
toggleButton.Parent = screenGui

----------------------------------------------------
-- DRAGGING FEATURE
----------------------------------------------------
local userInputService = game:GetService("UserInputService")

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

makeDraggable(mainFrame)
makeDraggable(toggleButton)

----------------------------------------------------
-- TOGGLE LOGIC
----------------------------------------------------
local uiTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local isMenuOpen = false 
local isTweening = false 

local function minimizeToButton()
    if isTweening then return end
    isTweening = true
    
    local closeTween = TweenService:Create(mainFrame, uiTweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        mainFrame.Visible = false
        isMenuOpen = false
        isTweening = false
    end)
end

local function openMenu()
    if isTweening then return end
    isTweening = true
    
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 0, 0, 0) 
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local openTween = TweenService:Create(mainFrame, uiTweenInfo, {
        Size = UDim2.new(0, 580, 0, 420),
        Position = UDim2.new(0.5, -290, 0.5, -210)
    })
    openTween:Play()
    openTween.Completed:Connect(function()
        isMenuOpen = true
        isTweening = false
    end)
end

toggleButton.MouseButton1Click:Connect(function()
    if isMenuOpen then minimizeToButton() else openMenu() end
end)

----------------------------------------------------
-- TOP WINDOW CONTROL DOTS & TITLE
----------------------------------------------------
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "Controls"
controlsFrame.Size = UDim2.new(0, 60, 0, 20)
controlsFrame.Position = UDim2.new(1, -75, 0, 15)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = mainFrame

local colors = {Color3.fromRGB(255, 95, 87), Color3.fromRGB(254, 188, 46), Color3.fromRGB(40, 200, 64)}
for i, color in ipairs(colors) do
    local dot = Instance.new("TextButton")
    dot.Name = "ControlDot" .. i
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, (i - 1) * 20, 0, 4)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Text = ""
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    dot.Parent = controlsFrame
    dot.MouseButton1Click:Connect(minimizeToButton)
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "IOHUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.Size = UDim2.new(0, 24, 0, 24)
logo.Position = UDim2.new(0, 15, 0, 12)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://10840244199" 
logo.ImageColor3 = Color3.fromRGB(255, 30, 30)
logo.Parent = mainFrame

----------------------------------------------------
-- NAVIGATION & PAGES SETUP
----------------------------------------------------
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 160, 1, -60)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundTransparency = 1
sidebar.Parent = mainFrame

local uiListSide = Instance.new("UIListLayout")
uiListSide.Padding = UDim.new(0, 8)
uiListSide.SortOrder = Enum.SortOrder.LayoutOrder
uiListSide.Parent = sidebar

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -195, 1, -55)
contentFrame.Position = UDim2.new(0, 180, 0, 40)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
contentFrame.BackgroundTransparency = 0.4
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = contentFrame

local tabs = {}
local pages = {}
local activeTab = nil

local function createPageContainer()
    local scrollPage = Instance.new("ScrollingFrame")
    scrollPage.Size = UDim2.new(1, -10, 1, -15)
    scrollPage.Position = UDim2.new(0, 5, 0, 10)
    scrollPage.BackgroundTransparency = 1
    scrollPage.BorderSizePixel = 0
    scrollPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollPage.ScrollBarThickness = 2
    scrollPage.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollPage.Visible = false
    scrollPage.Parent = contentFrame

    local uiListContent = Instance.new("UIListLayout")
    uiListContent.Padding = UDim.new(0, 10)
    uiListContent.SortOrder = Enum.SortOrder.LayoutOrder
    uiListContent.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListContent.Parent = scrollPage
    
    uiListContent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollPage.CanvasSize = UDim2.new(0, 0, 0, uiListContent.AbsoluteContentSize.Y + 20)
    end)

    return scrollPage
end

local function switchTab(tabName)
    for name, btnElements in pairs(tabs) do
        if name == tabName then
            btnElements.Button.BackgroundTransparency = 0.9
            btnElements.Icon.ImageColor3 = Color3.fromRGB(255, 100, 120)
            btnElements.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            if btnElements.Stroke then btnElements.Stroke.Enabled = true end
            pages[name].Visible = true
        else
            btnElements.Button.BackgroundTransparency = 1
            btnElements.Icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
            btnElements.Label.TextColor3 = Color3.fromRGB(180, 180, 180)
            if btnElements.Stroke then btnElements.Stroke.Enabled = false end
            pages[name].Visible = false
        end
    end
    activeTab = tabName
end

local function createSidebarTab(name, iconId, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundTransparency = 1
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = ""
    btn.LayoutOrder = order
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 20, 40)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Enabled = false
    stroke.Parent = btn
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0, 12, 0.5, -8)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    icon.Parent = btn
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn
    
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.Parent = sidebar
    
    tabs[name] = {Button = btn, Icon = icon, Label = lbl, Stroke = stroke}
    pages[name] = createPageContainer()
end

----------------------------------------------------
-- MAIN DROPDOWN SECTION
----------------------------------------------------
local function createDropdownSection(pageName, sectionTitle)
    local targetPage = pages[pageName]
    if not targetPage then return end

    local isOpen = false 
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.92, 0, 0, 40)
    dropContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = targetPage

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 8)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 40)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -40, 1, 0)
    titleLbl.Position = UDim2.new(0, 15, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = sectionTitle
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 20
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 16, 0, 16)
    arrowIcon.Position = UDim2.new(1, -28, 0.5, -8)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    arrowIcon.Parent = headerBtn

    local itemsHolder = Instance.new("Frame")
    itemsHolder.Size = UDim2.new(1, 0, 0, 0)
    itemsHolder.Position = UDim2.new(0, 0, 0, 40)
    itemsHolder.BackgroundTransparency = 1
    itemsHolder.Parent = dropContainer

    local itemsList = Instance.new("UIListLayout")
    itemsList.Padding = UDim.new(0, 8)
    itemsList.SortOrder = Enum.SortOrder.LayoutOrder
    itemsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    itemsList.Parent = itemsHolder

    itemsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.92, 0, 0, itemsList.AbsoluteContentSize.Y + 50)
            itemsHolder.Size = UDim2.new(1, 0, 0, itemsList.AbsoluteContentSize.Y + 10)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.92, 0, 0, itemsList.AbsoluteContentSize.Y + 50)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.92, 0, 0, 40)}):Play()
        end
    end)

    return itemsHolder
end

----------------------------------------------------
-- NESTED DROPDOWN SECTION
----------------------------------------------------
local function createNestedDropdownSection(parentContainer, sectionTitle)
    local isOpen = false
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -35, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = sectionTitle
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local itemsHolder = Instance.new("Frame")
    itemsHolder.Size = UDim2.new(1, 0, 0, 0)
    itemsHolder.Position = UDim2.new(0, 0, 0, 36)
    itemsHolder.BackgroundTransparency = 1
    itemsHolder.Parent = dropContainer

    local itemsList = Instance.new("UIListLayout")
    itemsList.Padding = UDim.new(0, 6)
    itemsList.SortOrder = Enum.SortOrder.LayoutOrder
    itemsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    itemsList.Parent = itemsHolder

    itemsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.95, 0, 0, itemsList.AbsoluteContentSize.Y + 45)
            itemsHolder.Size = UDim2.new(1, 0, 0, itemsList.AbsoluteContentSize.Y + 10)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, itemsList.AbsoluteContentSize.Y + 45)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return itemsHolder
end

----------------------------------------------------
-- BUTTON CREATOR (Para sa Action Buttons tulad ng Save)
----------------------------------------------------
local function createButton(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 42)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 16)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0, 100, 0, 26)
    actionBtn.Position = UDim2.new(1, -100, 0.5, -13)
    actionBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 50)
    actionBtn.BackgroundTransparency = 0.2
    actionBtn.Text = "Save"
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 11
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn
    
    actionBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    actionBtn.Parent = row
    row.Parent = parentContainer
end

----------------------------------------------------
-- MULTI-SELECT DROPDOWN SELECTOR (FIXED SEARCH)
----------------------------------------------------
local function createDropdownSelect(parentContainer, title, itemsListTable, callback)
    local isOpen = false
    
    if not currentConfigData.dropdowns[title] then
        currentConfigData.dropdowns[title] = {}
    end
    local selectedItems = currentConfigData.dropdowns[title]
    local allSelected = false
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(0.4, 0, 1, 0)
    selectedLbl.Position = UDim2.new(0.55, -20, 0, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = "None selected"
    selectedLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    selectedLbl.Font = Enum.Font.Gotham
    selectedLbl.TextSize = 10
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
    selectedLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, 0, 0, 0)
    contentHolder.Position = UDim2.new(0, 0, 0, 36)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = dropContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = contentHolder

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.92, 0, 0, 28)
    searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search 🔎"
    searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 11
    searchBox.ClearTextOnFocus = false
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 4)
    searchCorner.Parent = searchBox
    searchBox.Parent = contentHolder

    local scrollOptions = Instance.new("ScrollingFrame")
    scrollOptions.Size = UDim2.new(0.92, 0, 0, 90)
    scrollOptions.BackgroundTransparency = 1
    scrollOptions.BorderSizePixel = 0
    scrollOptions.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollOptions.ScrollBarThickness = 2
    scrollOptions.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollOptions.Parent = contentHolder

    local optList = Instance.new("UIListLayout")
    optList.Padding = UDim.new(0, 4)
    optList.SortOrder = Enum.SortOrder.LayoutOrder
    optList.Parent = scrollOptions

    local optionButtons = {}
    local allBtn = nil

    local function updateSelectedLabel()
        local count = 0
        local names = {}
        for item, isSel in pairs(selectedItems) do
            if isSel then
                count = count + 1
                table.insert(names, item)
            end
        end
        if count == 0 then
            selectedLbl.Text = "None selected"
        elseif count == #itemsListTable then
            selectedLbl.Text = "All selected"
        else
            selectedLbl.Text = table.concat(names, ", ")
        end
    end

    local function updateAllButtonState()
        if not allBtn then return end
        local allCurrentlySelected = true
        for _, itemText in ipairs(itemsListTable) do
            if not selectedItems[itemText] then
                allCurrentlySelected = false
                break
            end
        end
        allSelected = allCurrentlySelected
        
        allBtn.BackgroundColor3 = allSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
        allBtn.BackgroundTransparency = allSelected and 0.2 or 0.5
        allBtn.TextColor3 = allSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        allBtn.Font = allSelected and Enum.Font.GothamBold or Enum.Font.Gotham
    end

    local function populateOptions(filter)
        -- Linisin nang lubusan ang lumang buttons para hindi magpatong-patong
        for _, btn in pairs(optionButtons) do 
            if btn.Button then btn.Button:Destroy() end 
        end
        optionButtons = {}
        if allBtn then allBtn:Destroy() allBtn = nil end

        -- I-trim at gawing lowercase ang filter para sa malinis na paghahanap
        local cleanFilter = string.lower(string.gsub(filter or "", "^%s*(.-)%s*$", "%1"))

        -- Ilagay ang "All" button kung pasok sa filter
        if cleanFilter == "" or string.find(string.lower("All"), cleanFilter) then
            allBtn = Instance.new("TextButton")
            allBtn.Size = UDim2.new(1, 0, 0, 26)
            allBtn.BackgroundColor3 = allSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
            allBtn.BackgroundTransparency = allSelected and 0.2 or 0.5
            allBtn.Text = "  All"
            allBtn.TextColor3 = allSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            allBtn.Font = allSelected and Enum.Font.GothamBold or Enum.Font.Gotham
            allBtn.TextSize = 11
            allBtn.TextXAlignment = Enum.TextXAlignment.Left

            local allCorner = Instance.new("UICorner")
            allCorner.CornerRadius = UDim.new(0, 4)
            allCorner.Parent = allBtn

            allBtn.MouseButton1Click:Connect(function()
                allSelected = not allSelected
                for _, itemText in ipairs(itemsListTable) do
                    selectedItems[itemText] = allSelected
                end
                updateAllButtonState()
                for _, btnData in pairs(optionButtons) do
                    local isSel = selectedItems[btnData.ItemName] == true
                    btnData.Button.BackgroundColor3 = isSel and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                    btnData.Button.BackgroundTransparency = isSel and 0.2 or 0.5
                    btnData.Button.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                    btnData.Button.Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham
                end
                updateSelectedLabel()
                if callback then callback(selectedItems) end
            end)

            allBtn.Parent = scrollOptions
        end

        -- I-loop at i-filter ang mga item batay sa tinype sa search box
        for _, itemText in ipairs(itemsListTable) do
            local lowerItemText = string.lower(itemText)
            if cleanFilter == "" or string.find(lowerItemText, cleanFilter) then
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                
                local isSelected = selectedItems[itemText] == true
                optBtn.BackgroundColor3 = isSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                optBtn.BackgroundTransparency = isSelected and 0.2 or 0.5
                optBtn.Text = "  " .. itemText
                optBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                optBtn.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
                optBtn.TextSize = 11
                optBtn.TextXAlignment = Enum.TextXAlignment.Left

                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 4)
                optCorner.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    selectedItems[itemText] = not selectedItems[itemText]
                    
                    local nowSelected = selectedItems[itemText]
                    optBtn.BackgroundColor3 = nowSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
                    optBtn.BackgroundTransparency = nowSelected and 0.2 or 0.5
                    optBtn.TextColor3 = nowSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                    optBtn.Font = nowSelected and Enum.Font.GothamBold or Enum.Font.Gotham

                    updateAllButtonState()
                    updateSelectedLabel()
                    if callback then callback(selectedItems) end
                end)

                optBtn.Parent = scrollOptions
                table.insert(optionButtons, {Button = optBtn, ItemName = itemText})
            end
        end

        updateAllButtonState()
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 10)
        
        if isOpen then
            local optionListHeight = optList.AbsoluteContentSize.Y + 15
            if optionListHeight > 90 then optionListHeight = 90 end
            scrollOptions.Size = UDim2.new(0.92, 0, 0, optionListHeight)
            
            local totalTargetHeight = optionListHeight + 36 + 28 + 20
            dropContainer.Size = UDim2.new(0.95, 0, 0, totalTargetHeight)
        end
    end

    populateOptions("")
    updateSelectedLabel()
    if callback then callback(selectedItems) end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        populateOptions(searchBox.Text)
    end)

    optList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 10)
    end)

    contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if isOpen then
            local optionListHeight = optList.AbsoluteContentSize.Y + 15
            if optionListHeight > 90 then optionListHeight = 90 end
            local totalHeight = optionListHeight + 36 + 28 + 20
            dropContainer.Size = UDim2.new(0.95, 0, 0, totalHeight)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isOpen then
            local optionListHeight = optList.AbsoluteContentSize.Y + 15
            if optionListHeight > 90 then optionListHeight = 90 end
            local totalHeight = optionListHeight + 36 + 28 + 20
            
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, totalHeight)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return dropContainer
end


----------------------------------------------------
-- SINGLE-SELECT DROPDOWN SELECTOR (Walang Search / Walang All)
----------------------------------------------------
local function createSingleDropdownSelect(parentContainer, title, itemsListTable, callback)
    local isOpen = false
    
    -- Gagamit tayo ng string value para sa single selection state
    if not currentConfigData.singleDropdowns then
        currentConfigData.singleDropdowns = {}
    end
    if not currentConfigData.singleDropdowns[title] then
        currentConfigData.singleDropdowns[title] = itemsListTable[1] or ""
    end
    
    local selectedValue = currentConfigData.singleDropdowns[title]
    
    local dropContainer = Instance.new("Frame")
    dropContainer.Size = UDim2.new(0.95, 0, 0, 36)
    dropContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropContainer.BackgroundTransparency = 0.5
    dropContainer.ClipsDescendants = true
    dropContainer.Parent = parentContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropContainer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = dropContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(0.4, 0, 1, 0)
    selectedLbl.Position = UDim2.new(0.55, -20, 0, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = selectedValue ~= "" and selectedValue or "Select..."
    selectedLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    selectedLbl.Font = Enum.Font.Gotham
    selectedLbl.TextSize = 10
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
    selectedLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 14, 0, 14)
    arrowIcon.Position = UDim2.new(1, -24, 0.5, -7)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709791437"
    arrowIcon.Rotation = 90
    arrowIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    arrowIcon.Parent = headerBtn

    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, 0, 0, 0)
    contentHolder.Position = UDim2.new(0, 0, 0, 36)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = dropContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = contentHolder

    local scrollOptions = Instance.new("ScrollingFrame")
    scrollOptions.Size = UDim2.new(0.92, 0, 0, #itemsListTable * 30 + 5)
    scrollOptions.BackgroundTransparency = 1
    scrollOptions.BorderSizePixel = 0
    scrollOptions.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollOptions.ScrollBarThickness = 2
    scrollOptions.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scrollOptions.Parent = contentHolder

    local optList = Instance.new("UIListLayout")
    optList.Padding = UDim.new(0, 4)
    optList.SortOrder = Enum.SortOrder.LayoutOrder
    optList.Parent = scrollOptions

    local optionButtons = {}

    local function populateOptions()
        for _, btn in pairs(optionButtons) do btn:Destroy() end
        optionButtons = {}

        for _, itemText in ipairs(itemsListTable) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            
            local isSelected = (selectedValue == itemText)
            optBtn.BackgroundColor3 = isSelected and Color3.fromRGB(150, 30, 50) or Color3.fromRGB(35, 35, 35)
            optBtn.BackgroundTransparency = isSelected and 0.2 or 0.5
            
            optBtn.Text = "  " .. itemText
            optBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            optBtn.Font = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham
            optBtn.TextSize = 11
            optBtn.TextXAlignment = Enum.TextXAlignment.Left

            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 4)
            optCorner.Parent = optBtn

            optBtn.MouseButton1Click:Connect(function()
                selectedValue = itemText
                currentConfigData.singleDropdowns[title] = selectedValue
                selectedLbl.Text = selectedValue
                
                -- Isara ang dropdown pagkapili
                isOpen = false
                local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
                TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()

                populateOptions()
                if callback then callback(selectedValue) end
            end)

            optBtn.Parent = scrollOptions
            table.insert(optionButtons, optBtn)
        end
        scrollOptions.CanvasSize = UDim2.new(0, 0, 0, optList.AbsoluteContentSize.Y + 5)
    end

    populateOptions()
    if callback then callback(selectedValue) end

    contentHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if isOpen then
            dropContainer.Size = UDim2.new(0.95, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
        end
    end)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local totalHeight = listLayout.AbsoluteContentSize.Y + 20
        
        if isOpen then
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 270}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, totalHeight)}):Play()
        else
            TweenService:Create(arrowIcon, tweenInfo, {Rotation = 90}):Play()
            TweenService:Create(dropContainer, tweenInfo, {Size = UDim2.new(0.95, 0, 0, 36)}):Play()
        end
    end)

    return dropContainer
end

----------------------------------------------------
-- ENTER TEXT / INPUT BOX (Para sa Custom Weight Target)
----------------------------------------------------
local function createEnterText(parentContainer, title, placeholder, defaultVal, callback)
    if not currentConfigData.inputs then
        currentConfigData.inputs = {}
    end
    if currentConfigData.inputs[title] == nil then
        currentConfigData.inputs[title] = tostring(defaultVal or "")
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.95, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = parentContainer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = container

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 100, 0, 26)
    textBox.Position = UDim2.new(1, -108, 0.5, -13)
    textBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    textBox.BackgroundTransparency = 0.4
    textBox.Text = currentConfigData.inputs[title]
    textBox.PlaceholderText = placeholder or "Enter..."
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 11
    textBox.ClearTextOnFocus = false
    textBox.Parent = container

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = textBox

    textBox.FocusLost:Connect(function(enterPressed)
        local val = textBox.Text
        currentConfigData.inputs[title] = val
        if callback then
            callback(val)
        end
    end)

    return container
end



----------------------------------------------------
-- TOGGLE CREATOR
----------------------------------------------------
local function createToggle(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 42)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.75, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 16)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 36, 0, 18)
    toggleBtn.Position = UDim2.new(1, -34, 0.5, -9)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(0, 3, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator
    indicator.Parent = toggleBtn
    
    local enabled = currentConfigData.toggles[title] == true
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    local function applyState(state, immediate)
        enabled = state
        currentConfigData.toggles[title] = enabled
        if immediate then
            if enabled then
                toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                indicator.Position = UDim2.new(1, -15, 0.5, -6)
                indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            else
                toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                indicator.Position = UDim2.new(0, 3, 0.5, -6)
                indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
        else
            if enabled then
                TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -15, 0.5, -6), BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            else
                TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end
        end
        if callback then callback(enabled) end
    end

    applyState(enabled, true)
    
    toggleBtn.MouseButton1Click:Connect(function()
        applyState(not enabled, false)
    end)
    
    toggleBtn.Parent = row
    row.Parent = parentContainer
end

local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

----------------------------------------------------
-- TOGGLE CREATOR (May On/Off switch)
----------------------------------------------------
local function createToggle(pageName, title, description, callback)
    local targetPage = pages[pageName]
    if not targetPage then return end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.92, 0, 0, 55)
    row.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 0, 18)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = row
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.75, 0, 0, 32)
    descLabel.Position = UDim2.new(0, 0, 0, 20)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = row
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 42, 0, 22)
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -11)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = UDim2.new(0, 3, 0.5, -8)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator
    indicator.Parent = toggleBtn
    
    local enabled = false
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        else
            TweenService:Create(toggleBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            TweenService:Create(indicator, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
        if callback then callback(enabled) end
    end)
    
    toggleBtn.Parent = row
    row.Parent = targetPage
end

----------------------------------------------------
-- 2. UPDATED BUTTON CREATOR (Malaking Rectangle + Mouse Icon)
----------------------------------------------------
local function createButton(parentContainer, title, description, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.95, 0, 0, 48) -- Swabe ang taas para sa dalawang linya ng text
    row.BackgroundTransparency = 1
    
    -- Ang buong row ay ginawang isang malaking clickable rectangle button
    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(1, 0, 1, 0)
    actionBtn.Position = UDim2.new(0, 0, 0, 0)
    actionBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 50) -- Kulay ng button mo
    actionBtn.BackgroundTransparency = 0.2
    actionBtn.Text = "" -- Walang default text, gagamit tayo ng labels
    actionBtn.AutoButtonColor = true
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn
    
    -- Spacing sa loob para sa mga teksto
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = actionBtn
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.8, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = actionBtn
    
    -- Description Label
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.8, 0, 0, 18)
    descLabel.Position = UDim2.new(0, 0, 0, 24)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = actionBtn
    
    -- Mouse Clicker Icon sa kanang dulo
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 24, 0, 24)
    iconLabel.Position = UDim2.new(1, -24, 0.5, -12)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "🖱️"
    iconLabel.TextSize = 14
    iconLabel.Parent = actionBtn
    
    -- Click trigger ng button
    actionBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    actionBtn.Parent = row
    row.Parent = parentContainer
end


----------------------------------------------------
-- BAGONG BUTTON CREATOR (Para lang sa mga Standalone Buttons na may Mouse Pointer)
----------------------------------------------------
local function createCustomButton(pageName, title, description, callback)
    local targetPage = pages[pageName]
    if not targetPage then return end

    -- Ang mismong malaking clickable rectangle button
    local actionBtn = Instance.new("TextButton")
    actionBtn.Name = title .. "_CustomRectangle"
    actionBtn.Size = UDim2.new(0.92, 0, 0, 55) -- Malaking rectangle
    actionBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40) -- Kulay na babagay sa background ng IOHUB mo
    actionBtn.BackgroundTransparency = 0.4
    actionBtn.Text = "" -- Alisin ang default button text
    actionBtn.AutoButtonColor = true

    -- Bilugan ang mga kanto ng rectangle
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actionBtn

    -- Spacing para hindi nakadikit ang mga letra sa gilid
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = actionBtn
    
    -- Title Label sa loob ng malaking button
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.7, 0, 0, 18)
    titleLabel.Position = UDim2.new(0, 0, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = actionBtn
    
    -- Description Label sa loob ng malaking button
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.75, 0, 0, 32)
    descLabel.Position = UDim2.new(0, 0, 0, 24)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 11
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.Parent = actionBtn
    
    -- Ang Mouse Click Cursor Asset sa kanang dulo ng rectangle
    local mouseIcon = Instance.new("ImageLabel")
    mouseIcon.Name = "MousePointerIcon"
    mouseIcon.Size = UDim2.new(0, 22, 0, 22)
    mouseIcon.Position = UDim2.new(1, -25, 0.5, -11)
    mouseIcon.BackgroundTransparency = 1
    mouseIcon.Image = "rbxassetid://10734896206" -- Mouse click cursor icon asset
    mouseIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    mouseIcon.Parent = actionBtn
    
    -- Click at Flash Effect para sa mouse pointer
    actionBtn.MouseButton1Click:Connect(function()
        mouseIcon.ImageColor3 = Color3.fromRGB(255, 100, 120)
        task.wait(0.1)
        mouseIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
        if callback then callback() end
    end)
    
    actionBtn.Parent = targetPage
end


-- ====================================================================
-- 3. SIDEBAR TABS & GROUPS DEFINITION
-- ====================================================================

createSidebarTab("Section 1", "rbxassetid://10723345479", 1)
createSidebarTab("Section 2", "rbxassetid://10723345479", 2)
createSidebarTab("Section 3", "rbxassetid://10734951111", 3)
createSidebarTab("Section 4", "rbxassetid://10734951111", 4)
createSidebarTab("Section 5", "rbxassetid://10734951111", 5)
createSidebarTab("Settings", "rbxassetid://10734951111", 6)


-- Kunin ang mga kailangang serbisyo
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

-- (Ito yung original notify function mo sa taas)
local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 2;
    })
end




-- ====================================================================
-- Custom Button: Skip Statue (Waiting CFrame -> 20s Anti Cheat Timer -> Tween)
-- ====================================================================
createCustomButton("Section 1", "Skip Statue (Anti Cheat)", "Smooth Tween to Finish", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    -- ILAGAY DITO ANG GUSTO MONG WAITING / TRIGGER AREA CFRAME
    local waitingCFrame = CFrame.new(259.500, 57.114, -66.892) -- Palitan mo itong mga numero (X, Y, Z) ng trigger area mo
    
    if rootPart then
  
        rootPart.Anchored = false
        rootPart.CFrame = waitingCFrame
        
        -- 2. I-notify ang user na nagsimula na ang 20s anti-cheat timer habang nasa waiting area
        if type(notify) == "function" then
            notify("ANTI CHEAT", "Wait 30s before Flight", 30)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ANTI CHEAT",
                Text = "Wait 30s before Flight",
                Duration = 30,
            })
        end
        
        -- 3. Mag-antay ng 20 segundo habang nakaabang sa trigger area
        task.wait(30)
        
        -- I-check ulit ang character/rootPart kung sakaling namatay habang naghihintay
        character = player.Character
        rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if rootPart then
            if type(notify) == "function" then
                notify("IOHUB", "Smooth Tween Started", 2)
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "IOHUB",
                    Text = "Smooth Tween Started",
                    Duration = 2,
                })
            end
            
            -- Siguraduhing hindi naka-anchor para gumalaw nang maayos ang physics
            rootPart.Anchored = false
            
            local TweenService = game:GetService("TweenService")
            local targetCFrame = CFrame.new(-539.382, 84.881, -88.505)
            
            -- Pwede mong baguhin ang 1.5 seconds kung gusto mong baguhin ang bilis ng galaw
            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear) 
            local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
            
            tween:Play()
        else
            if type(notify) == "function" then
                notify("Error", "Nawala ang Character habang naghihintay!", 3)
            end
        end
    else
        if type(notify) == "function" then
            notify("Error", "Hindi makita ang Character/RootPart!", 3)
        end
    end
end)






-- ====================================================================
-- Custom Button: Skip Crouch (Fixed Door B & Exact Prompt Text Matching)
-- ====================================================================
createCustomButton("Section 1", " Skip Crouch (Anti Cheat)", "Teleport and Wait to Finish the Timer", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        -- Helper function na mas agresibo ang paghanap ng pinto (gamit ang Text at Object Name)
        local function fireDoorPrompt(targetCFrame, targetNameHint)
            -- 1. Teleport sa CFrame
            rootPart.CFrame = targetCFrame
            task.wait(0.4) -- Palawigin nang konti para makapaghintay mag-load ang client
            
            local fired = false
            
            -- 2. Unang subok: Hanapin sa pamamagitan ng ProximityPrompt properties ("Door", "Open", "Close")
            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    local actionText = tostring(desc.ActionText):lower()
                    local objectText = tostring(desc.ObjectText):lower()
                    local parentName = tostring(desc.Parent.Name):lower()
                    
                    if objectText:find("door") or actionText:find("open") or actionText:find("close") or parentName:find("door") then
                        if desc.Parent and desc.Parent:IsA("BasePart") then
                            -- Pinalaki natin ang magnitude range sa 20 para sure na sakop kahit medyo malayo ang CFrame
                            if (desc.Parent.Position - rootPart.Position).Magnitude <= 20 then
                                fireproximityprompt(desc)
                                fired = true
                                break
                            end
                        end
                    end
                end
            end
            
            -- 3. Pangalawang subok (Fallback): Kung may ibinigay na pangalan tulad ng "ProxDoorB" o "TeleportDoor"
            if not fired and targetNameHint then
                for _, desc in ipairs(workspace:GetDescendants()) do
                    if desc.Name == targetNameHint then
                        local prompt = desc:FindFirstChildOfClass("ProximityPrompt", true)
                        if prompt then
                            fireproximityprompt(prompt)
                            fired = true
                            break
                        end
                    end
                end
            end
            
            -- 4. Huling saklolo: I-fire ang pinakamalapit na prompt sa paligid mo
            if not fired then
                for _, desc in ipairs(workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        if desc.Parent and desc.Parent:IsA("BasePart") then
                            if (desc.Parent.Position - rootPart.Position).Magnitude <= 15 then
                                fireproximityprompt(desc)
                                break
                            end
                        end
                    end
                end
            end
        end

        if type(notify) == "function" then
            notify("IOHUB", "Skip Crouch Starting", 2)
        end

        -- ----------------------------------------------------------------
        -- STEP 1: ProxDoorA
        -- ----------------------------------------------------------------
     fireDoorPrompt(CFrame.new(-3578.081, 602.739, 887.780), "ProxDoorA")
      task.wait(2.0) 

        -- ----------------------------------------------------------------
        -- STEP 2: ProxDoorB (Siguraduhing naka-abang at nasasalo na ang 'Door' object text)
        -- ----------------------------------------------------------------
        fireDoorPrompt(CFrame.new(-3613.163, 608.205, 771.423), "ProxDoorB")
        task.wait(2.0)

        -- ----------------------------------------------------------------
        -- STEP 3: TeleportDoor Waiting Spot (May 60 seconds anti-cheat wait)
        -- ----------------------------------------------------------------
        rootPart.CFrame = CFrame.new(-3691.832, 611.427, 335.681)
        
        if type(notify) == "function" then
            notify("ANTI CHEAT", "Stay and Wait 60 seconds", 60)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ANTI CHEAT",
                Text = "Stay and Wait 60 seconds",
                Duration = 60,
            })
        end

        task.wait(60)

        -- Huling pinto: I-fire ang prompt sa TeleportDoor pagkalipas ng 60 segundo
        fireDoorPrompt(CFrame.new(-3953.075, 594.244, 316.145), "TeleportDoor")
        
        if type(notify) == "function" then
            notify("IOHUB", "Door Opened", 3)
        end

    else
        if type(notify) == "function" then
            notify("Error", "Hindi makita ang Character/RootPart!", 3)
        end
    end
end)



local ashinaConnection = nil
local ashinaTracker = {} -- Dito natin ise-save ang mga active highlights

createToggle("Section 2", "Ashina ESP", "Highlights Ashina monster body", function(state)
    if state then
        -- ===== STATE IS TRUE (TOGGLE ON) =====
        
        -- Function para i-check at lagyan ng highlight ang Ashina body
        local function checkAshina(obj)
            -- Hanapin ang "body" kahit nasaan man ito sa ilalim ng object/model
            local bodyPart = obj:FindFirstChild("body", true)
            if bodyPart and (bodyPart:IsA("BasePart") or bodyPart:IsA("Model")) then
                if not ashinaTracker[bodyPart] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "AshinaESP_Highlight"
                    highlight.Adornee = bodyPart
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)       -- Pulang kulay sa loob
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Puting gilid
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = bodyPart
                    
                    ashinaTracker[bodyPart] = highlight
                end
            end
        end

        -- 1. I-scan muna ang workspace para sa mga nandiyan nang Ashina
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant.Name == "Ashina" then
                checkAshina(descendant)
            end
        end
        
        -- 2. I-on ang dynamic listener para sa mga susunod na mag-spawn sa workspace
        ashinaConnection = workspace.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "Ashina" then
                task.wait(0.1)
                checkAshina(descendant)
            end
        end)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "IOHUB ESP Active",
            Text = "🔴 Ashina Monster ESP: ON",
            Duration = 3
        })
    else
        -- ===== STATE IS FALSE (TOGGLE OFF) =====
        -- 1. Patayin ang event listener
        if ashinaConnection then
            ashinaConnection:Disconnect()
            ashinaConnection = nil
        end
        
        -- 2. Burahin lahat ng nakakabit na highlights
        for part, highlight in pairs(ashinaTracker) do
            if highlight then highlight:Destroy() end
        end
        table.clear(ashinaTracker)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "IOHUB ESP Status",
            Text = "⚪ Ashina Monster ESP: OFF",
            Duration = 2
        })
    end
end)


-- ====================================================================
-- Custom Button: Auto Get Bowl
-- ====================================================================
createCustomButton("Section 2", "Auto Get Bowl", "Teleport at kuhanin ang Bowl gamit ang saktong path", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    if not rootPart then return end

    local targetPrompt = nil
    
    -- 1. I-loop ang mga top folders sa Workspace para mahanap ang RestaurantRoom
    for _, topFolder in ipairs(workspace:GetChildren()) do
        for _, child in ipairs(topFolder:GetChildren()) do
            if child.Name == "RestaurantRoom" then
                local bowlGiver = child:FindFirstChild("BowlGiver")
                if bowlGiver then
                    local promptFolder = bowlGiver:FindFirstChild("Prompt")
                    if promptFolder then
                        -- Kunin ang ProximityPrompt sa loob ng Prompt folder
                        for _, pChild in ipairs(promptFolder:GetChildren()) do
                            if pChild:IsA("ProximityPrompt") then
                                targetPrompt = pChild
                                break
                            end
                        end
                    end
                end
            end
        end
        if targetPrompt then break end
    end

    -- 2. Kung nahanap, i-teleport at i-fire
    if targetPrompt then
        local parentPart = targetPrompt.Parent
        if parentPart and parentPart:IsA("BasePart") then
            rootPart.CFrame = parentPart.CFrame + Vector3.new(0, 3, 0)
        elseif parentPart and parentPart.Parent and parentPart.Parent:IsA("BasePart") then
            rootPart.CFrame = parentPart.Parent.CFrame + Vector3.new(0, 3, 0)
        end
        
        task.wait(0.4)
        fireproximityprompt(targetPrompt)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Success",
            Text = "🥣 Matagumpay na nakuha ang Bowl gamit ang saktong path!",
            Duration = 3
        })
    else
        -- Fallback: Kung sakaling nasa ibang nested level ang RestaurantRoom
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc.Name == "BowlGiver" then
                local promptFolder = desc:FindFirstChild("Prompt")
                if promptFolder then
                    targetPrompt = promptFolder:FindFirstChildOfClass("ProximityPrompt", true)
                    if targetPrompt then break end
                end
            end
        end

        if targetPrompt then
            local parentPart = targetPrompt.Parent
            if parentPart and parentPart:IsA("BasePart") then
                rootPart.CFrame = parentPart.CFrame + Vector3.new(0, 3, 0)
            end
            task.wait(0.4)
            fireproximityprompt(targetPrompt)
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Success",
                Text = "🥣 Nakuha ang Bowl gamit ang fallback search!",
                Duration = 3
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Error",
                Text = "Hindi pa rin makita ang Prompt sa BowlGiver.",
                Duration = 3
            })
            warn("Hindi makita ang Prompt sa BowlGiver.")
        end
    end
end)



-- ====================================================================
-- Custom Button: Meat Finder (ESP / Indicator)
-- ====================================================================
createCustomButton("Section 2", "Meat Finder", "I-highlight o hanapin ang lokasyon ng mga Meat sa paligid", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    if not rootPart then return end

    local foundMeats = 0

    -- Linisin muna ang mga lumang highlights kung meron man
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "MeatFinderHighlight" then
            obj:Destroy()
        end
    end

    -- Mag-scan sa buong workspace para hanapin ang mga Meat prompts
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local objText = desc.ObjectText or ""
            local actText = desc.ActionText or ""
            
            if objText:lower():match("meat") or actText:lower():match("grab") then
                local parentPart = desc.Parent
                while parentPart and not parentPart:IsA("BasePart") and parentPart ~= workspace do
                    parentPart = parentPart.Parent
                end

                if parentPart and parentPart:IsA("BasePart") then
                    foundMeats = foundMeats + 1
                    
                    -- Lagyan ng visual highlight (ESP) ang part para madali mong makita
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "MeatFinderHighlight"
                    highlight.Adornee = parentPart
                    highlight.FillColor = Color3.fromRGB(255, 100, 100) -- Kulay pulang karne
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = parentPart
                    
                    -- Opsyonal: Lagyan ng BillboardGui para makita ang distansya kung gusto mo, pero ang Highlight ay sapat na para mamataan agad
                end
            end
        end
    end

    if foundMeats > 0 then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Meat Finder",
            Text = "🔍 Nakakita ng " .. foundMeats .. " Meats! Naka-highlight na ang mga ito.",
            Duration = 4
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Meat Finder",
            Text = "❌ Walang makitang Meat sa paligid sa ngayon.",
            Duration = 4
        })
    end
end)



-- ====================================================================
-- Custom Button: Auto Submit (Exact Path Fix)
-- ====================================================================
createCustomButton("Section 2", "Auto Submit Meat", "Teleport sa NPC, mag-antay ng 10s, at isumite ang order", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    if not rootPart then return end

    -- 1. Teleport sa NPC Talk Area
    rootPart.CFrame = CFrame.new(-4443, 711, 1164)

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ALERT",
        Text = "Naghihintay ng 10 seconds bago i-submit sa NPC...",
        Duration = 11
    })

    -- 10 Seconds Countdown
    for i = 11, 1, -1 do
        task.wait(1)
    end

    -- 2. Hanapin ang ProximityPrompt sa eksaktong MainRoom -> NoppeNPC -> RootPart path
    local targetPrompt = nil
    
    for _, topFolder in ipairs(workspace:GetChildren()) do
        for _, child in ipairs(topFolder:GetChildren()) do
            if child.Name == "MainRoom" then
                local noppeNPC = child:FindFirstChild("NoppeNPC")
                if noppeNPC then
                    local rootPartNPC = noppeNPC:FindFirstChild("RootPart")
                    if rootPartNPC then
                        targetPrompt = rootPartNPC:FindFirstChildOfClass("ProximityPrompt", true)
                    end
                end
            end
        end
        if targetPrompt then break end
    end

    -- Fallback: Kung hindi mahanap sa MainRoom, hanapin kahit saang "NoppeNPC" sa buong Workspace
    if not targetPrompt then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc.Name == "NoppeNPC" then
                local rootPartNPC = desc:FindFirstChild("RootPart")
                if rootPartNPC then
                    targetPrompt = rootPartNPC:FindFirstChildOfClass("ProximityPrompt", true)
                end
                if not targetPrompt then
                    targetPrompt = desc:FindFirstChildOfClass("ProximityPrompt", true)
                end
                if targetPrompt then break end
            end
        end
    end

    -- 3. I-fire ang prompt kung nahanap
    if targetPrompt then
        fireproximityprompt(targetPrompt)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Success",
            Text = "✨ Matagumpay na naisumite ang order sa NPC!",
            Duration = 4
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Notice",
            Text = "Hindi pa rin makita ang Prompt sa RootPart ng NPC.",
            Duration = 4
        })
        warn("Hindi makita ang ProximityPrompt sa RootPart ng NoppeNPC.")
    end
end)



-- ====================================================================
-- Custom Button: Auto Open Door (Rooms / EndRoom Structure Approach)
-- ====================================================================
createCustomButton("Section 2", "Open End Door", "Find the EndRoom Door", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    if not rootPart then return end

    local targetPrompt = nil
    local targetPart = nil

    -- 1. Hanapin ang EndRoom o Rooms folder sa buong Workspace para makuha ang DoorFrame prompt
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc.Name == "EndRoom" or desc.Name == "Rooms" then
            local doorTele = desc:FindFirstChild("DoorTele", true)
            if doorTele then
                local doorFrame = doorTele:FindFirstChild("DoorFrame")
                if doorFrame then
                    targetPrompt = doorFrame:FindFirstChildOfClass("ProximityPrompt", true)
                    if doorFrame:IsA("BasePart") then
                        targetPart = doorFrame
                    else
                        targetPart = doorFrame:FindFirstChildWhichIsA("BasePart", true)
                    end
                end
            end
        end
        if targetPrompt then break end
    end

    -- 2. Fallback: Kung hindi nahanap sa itaas, hanapin ang mismong DoorFrame sa buong Workspace
    if not targetPrompt then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc.Name == "DoorFrame" then
                targetPrompt = desc:FindFirstChildOfClass("ProximityPrompt", true)
                if desc:IsA("BasePart") then
                    targetPart = desc
                else
                    targetPart = desc:FindFirstChildWhichIsA("BasePart", true)
                end
                if targetPrompt then break end
            end
        end
    end

    -- 3. Teleport at i-fire ang prompt kung nahanap
    if targetPrompt then
        if not targetPart and targetPrompt.Parent and targetPrompt.Parent:IsA("BasePart") then
            targetPart = targetPrompt.Parent
        end

        if targetPart then
            rootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
        end

        task.wait(0.3) -- Tamang bilis gaya ng reference
        fireproximityprompt(targetPrompt)

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Success",
            Text = "🚪 Matagumpay na nabuksan ang EndRoom Door!",
            Duration = 3
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error",
            Text = "Hindi makita ang DoorFrame prompt.",
            Duration = 3
        })
        warn("Hindi makita ang EndRoom.DoorTele.DoorFrame.ProximityPrompt")
    end
end)





-- ====================================================================
-- Custom Button: Teleport to WoodDebris PartBreak
-- ====================================================================
createCustomButton("Section 2", "TP to WoodDebris", "Mag-teleport nang diretso sa WoodDebris PartBreak", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    if not rootPart then return end

    local targetPart = nil
    
    -- 1. I-loop ang mga top folders sa Workspace para mahanap ang Build -> WoodDebris -> PartBreak
    for _, topFolder in ipairs(workspace:GetChildren()) do
        for _, child in ipairs(topFolder:GetChildren()) do
            if child.Name == "Build" then
                local woodDebris = child:FindFirstChild("WoodDebris")
                if woodDebris then
                    local partBreak = woodDebris:FindFirstChild("PartBreak")
                    if partBreak then
                        if partBreak:IsA("BasePart") then
                            targetPart = partBreak
                        else
                            targetPart = partBreak:FindFirstChildWhichIsA("BasePart", true)
                        end
                    end
                end
            end
        end
        if targetPart then break end
    end

    -- Fallback: Kung hindi nahanap sa itaas, hanapin ang PartBreak sa buong Workspace
    if not targetPart then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc.Name == "PartBreak" and desc:IsA("BasePart") then
                targetPart = desc
                break
            end
        end
    end

    -- 2. I-teleport ang player kung nahanap ang part
    if targetPart then
        rootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Success",
            Text = "🪵 Matagumpay na na-teleport sa WoodDebris PartBreak!",
            Duration = 3
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error",
            Text = "Hindi makita ang PartBreak sa WoodDebris.",
            Duration = 3
        })
        warn("Hindi makita ang PartBreak sa Build.WoodDebris.PartBreak")
    end
end)

-- ====================================================================
-- Custom Button: Auto Run / Route (Tween & ForceFloat Approach)
-- ====================================================================
createCustomButton("Section 2", "Auto Run Route", "Awtomatikong mag-run o mag-teleport sa mga takdang lokasyon na may pathing", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    if not rootPart then return end

    -- Opsyonal na variable para sa float/noclip control kung ginagamit sa script hub mo
    local ForceFloat = false

    -- 1. Unang puntahan (Teleport sa unang CFrame)
    ForceFloat = false
    
    
    

    -- 3. I-on ang float at i-tween papunta sa susunod na CFrame coordinate
    ForceFloat = true
    task.spawn(function()
        -- Kung ang script hub mo ay may sariling Tween function, magagamit ito nang direkta.
        -- Pero kung wala, gagamitin natin ang TweenService para sa smooth movement:
        local TweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear) -- Ayusin ang bilis kung kinakailangan
        local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(-5364, 682.12, 29.63)})
        tween:Play()
    end)

    -- 4. Mag-antay ng 2 segundo bago tapusin o i-reset ang ForceFloat
    task.wait(2)
    ForceFloat = "None"

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Success",
        Text = "🏃 Matagumpay na naisagawa ang Auto Run route!",
        Duration = 3
    })
end)



createCustomButton("Section 2", "Skip Lever", "Teleport to Trigger Door", function()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-10057.646, 490.684, -8.683) 
    end
end)

createCustomButton("Section 3", "Skip Math", "Teleport to Trigger Cook Part", function()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-2581.771, 990.561, -4918.280)
    end
end)


-- ====================================================================
-- Script Hub Integration: Precise Cooking Buttons
-- ====================================================================

-- Helper para mahanap ang BasePart ng isang prompt para sa teleportation
local function getPartFromPrompt(prompt)
    local pPart = prompt.Parent
    while pPart and not pPart:IsA("BasePart") and pPart ~= workspace do
        pPart = pPart.Parent
    end
    return pPart
end

-- Helper para i-fire ang prompt gamit ang keyword
local function triggerPrompt(keyword)
    local player = game:GetService("Players").LocalPlayer
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local targetPrompt = nil
    
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local objText = desc.ObjectText or ""
            local actText = desc.ActionText or ""
            local parentName = desc.Parent and desc.Parent.Name or ""
            
            if objText:lower():match(keyword:lower()) or actText:lower():match(keyword:lower()) or parentName:lower():match(keyword:lower()) then
                targetPrompt = desc
                break
            end
        end
    end
    
    if targetPrompt then
        local pPart = getPartFromPrompt(targetPrompt)
        if pPart and rootPart then
            rootPart.CFrame = pPart.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.3)
        end
        fireproximityprompt(targetPrompt)
        task.wait(0.4)
        return true
    end
    return false
end

-- Helper para sa Counter prompt/part
local function interactWithCounter()
    local player = game:GetService("Players").LocalPlayer
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local counterPrompt = nil
    
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local pName = desc.Parent and desc.Parent.Name or ""
            if pName:lower():match("counter") or desc.ObjectText:lower():match("counter") or desc.ActionText:lower():match("counter") then
                counterPrompt = desc
                break
            end
        end
    end
    
    if counterPrompt then
        local pPart = getPartFromPrompt(counterPrompt)
        if pPart and rootPart then
            rootPart.CFrame = pPart.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.3)
        end
        fireproximityprompt(counterPrompt)
        task.wait(0.4)
    end
end

-- Helper para sa Stove prompt
local function interactWithStove()
    local player = game:GetService("Players").LocalPlayer
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local stovePrompt = nil
    
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local pName = desc.Parent and desc.Parent.Name or ""
            local gpName = desc.Parent and desc.Parent.Parent and desc.Parent.Parent.Name or ""
            if pName:lower():match("stove") or gpName:lower():match("stove") or desc.ObjectText:lower():match("stove") then
                stovePrompt = desc
                break
            end
        end
    end
    
    if stovePrompt then
        local pPart = getPartFromPrompt(stovePrompt)
        if pPart and rootPart then
            rootPart.CFrame = pPart.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.3)
        end
        fireproximityprompt(stovePrompt)
        task.wait(0.4)
    end
end

-- ====================================================================
-- Custom Buttons para sa iyong Script Hub (Section 2 / Cooking)
-- ====================================================================

-- 1. Auto Cook Ham Stew
createCustomButton("Section 3", "Auto Cook Ham Stew", "Awtomatikong lutuin ang Ham Stew gamit ang tamang counter sequence", function()
    task.spawn(function()
        triggerPrompt("Pot")
        interactWithCounter()
        
        triggerPrompt("Sausage")
        interactWithCounter()
        
        triggerPrompt("Ham")
        interactWithCounter()
        
        interactWithCounter() -- Kunin sa counter
        interactWithStove()   -- Ilagay sa stove
        
        task.wait(10)         -- Hintay maluto
        
        triggerPrompt("Bowl")
        interactWithCounter()
        
        interactWithStove()   -- Kunin mula sa stove
        interactWithCounter() -- Lagay sa counter
        interactWithCounter() -- Kunin sa counter para i-submit
        
        triggerPrompt("Ushi Oni")
    end)
end)

-- 2. Auto Cook Chicken Soup
createCustomButton("Section 3", "Auto Cook Chicken Soup", "Awtomatikong lutuin ang Chicken Soup gamit ang tamang counter sequence", function()
    task.spawn(function()
        triggerPrompt("Pot")
        interactWithCounter()
        
        triggerPrompt("Chicken")
        interactWithCounter()
        
        triggerPrompt("Wrapped Meat")
        interactWithCounter()
        
        triggerPrompt("Cheese")
        interactWithCounter()
        
        interactWithCounter()
        interactWithStove()
        
        task.wait(10)
        
        triggerPrompt("Bowl")
        interactWithCounter()
        
        interactWithStove()
        interactWithCounter()
        interactWithCounter()
        
        triggerPrompt("Ushi Oni")
    end)
end)

-- 3. Auto Prepare Eyeball and Spaghetti (Bowl -> Spaghetti -> Eyeball -> Submit)
createCustomButton("Section 3", "Auto Prepare Eyeball & Spaghetti", "Awtomatikong ihanda ang Spaghetti N Eyeballs ayon sa tamang sunod", function()
    task.spawn(function()
        triggerPrompt("Bowl")
        interactWithCounter()
        
        triggerPrompt("Spaghetti")
        interactWithCounter()
        
        triggerPrompt("Eyeball")
        interactWithCounter()
        
        interactWithCounter()
        triggerPrompt("Ushi Oni")
    end)
end)

createCustomButton("Section 3", "End Chase 2", "Teleport to Trigger End", function()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-3362.965, 1205.029, -6819.904)
    end
end)



createCustomButton("Section 4", "Skip Curse 1", "Teleport to 2nd Curse Zone Game", function()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-4186.859, 624.788, -967.759)
    end
end)









-- ====================================================================
-- Custom Button: Box ESP for GAMESTART
-- ====================================================================
createToggle("Section 4", "GAMESTART Box ESP", "Maglagay ng 3D Box ESP at Label sa GAMESTART parts", function()
    local players = game:GetService("Players")
    local count = 0
    
    -- Function para lagyan ng SelectionBox (Cube ESP) at Text ang isang part
    local function applyBoxESP(targetPart)
        if not targetPart:FindFirstChild("GameStartBoxESP") then
            -- 1. SelectionBox para sa 3D cube outline
            local box = Instance.new("SelectionBox")
            box.Name = "GameStartBoxESP"
            box.Adornee = targetPart
            box.Color3 = Color3.fromRGB(0, 255, 255) -- Cyan color
            box.LineThickness = 0.05
            box.SurfaceTransparency = 0.85
            box.Parent = targetPart
            
            -- 2. Billboard Text sa ibabaw ng part
            if not targetPart:FindFirstChild("GameStartLabel") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "GameStartLabel"
                billboard.Adornee = targetPart
                billboard.Size = UDim2.new(0, 100, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = targetPart
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                textLabel.TextStrokeTransparency = 0
                textLabel.TextSize = 13
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.Text = "[ GAMESTART ]"
                textLabel.Parent = billboard
            end
        end
    end
    
    -- I-scan ang buong Workspace para hanapin ang GAMESTART
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc.Name == "GAMESTART" then
            if desc:IsA("BasePart") then
                applyBoxESP(desc)
                count = count + 1
            else
                for _, subDesc in ipairs(desc:GetDescendants()) do
                    if subDesc:IsA("BasePart") then
                        applyBoxESP(subDesc)
                        count = count + 1
                    end
                end
            end
        end
    end
    
    -- Opsyonal na notification
    if type(notify) == "function" then
        if count > 0 then
            notify("Box ESP Loaded", "Nilagyan ng 3D Box ESP ang " .. count .." parts ng GAMESTART!", 3)
        else
            notify("ESP Warning", "Walang makitang BasePart sa GAMESTART.", 3)
        end
    end
end)



createCustomButton("Section 4", "Skip GameStart Trigger (Tell to Teammates Don't Trigger it and Stay)", "Teleport to 2nd Curse Zone Game", function()
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(-4186.859, 624.788, -967.759)
    end
end)


-- ====================================================================
-- Custom Button: DoorTeleport Trigger
-- ====================================================================
createCustomButton("Section 4", "Door Teleport", "Teleport at i-fire ang DoorTeleport prompt", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        local fired = false
        
        -- 1. Subukang hanapin ang eksaktong folder o part na may pangalang "DoorTeleport"
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc.Name == "DoorTeleport" then
                local targetPart = nil
                if desc:IsA("BasePart") then
                    targetPart = desc
                elseif desc:IsA("Model") and desc.PrimaryPart then
                    targetPart = desc.PrimaryPart
                else
                    targetPart = desc:FindFirstChildWhichIsA("BasePart", true)
                end
                
                if targetPart then
                    rootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.3)
                    
                    -- Hanapin ang ProximityPrompt sa loob nito
                    local prompt = desc:FindFirstChildOfClass("ProximityPrompt", true)
                    if prompt then
                        fireproximityprompt(prompt)
                        fired = true
                        break
                    end
                end
            end
        end
        
        -- 2. Fallback kung sakaling hindi direktang mahanap sa pamamagitan ng pangalan
        if not fired then
            if type(notify) == "function" then
                notify("DoorTeleport", "Hindi nahanap ang prompt, sinusubukang i-scan ang paligid...", 2)
            end
        else
            if type(notify) == "function" then
                notify("Success", "Matagumpay na na-trigger ang DoorTeleport!", 2)
            end
        end
    else
        if type(notify) == "function" then
            notify("Error", "Hindi makita ang Character!", 2)
        end
    end
end)



-- ====================================================================
-- 1. Custom Button: Kid Teleport & Back to Safespot
-- ====================================================================
createCustomButton("Section 5", "Kid Teleport & Back", "Teleport sa kid trigger game tapos balik agad sa safespot", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        local kidTriggerCFrame = CFrame.new(-4435.166, 704.837, -2357.964)
        local safespotCFrame = CFrame.new(-4421.647, 683.953, -2365.499)
        
        if type(notify) == "function" then
            notify("Kid Game", "Pumupunta sa kid trigger...", 1)
        end
        
        -- 1. Pumunta sa kid trigger game
        rootPart.CFrame = kidTriggerCFrame
        task.wait(0.5) -- Maghintay nang saglit para ma-trigger
        
        -- 2. Bumalik agad sa safespot
        rootPart.CFrame = safespotCFrame
        
        if type(notify) == "function" then
            notify("Kid Game", "Nakatapos at nakabalik na sa safespot!", 2)
        end
    else
        if type(notify) == "function" then
            notify("Error", "Hindi makita ang Character!", 2)
        end
    end
end)

-- ====================================================================
-- Mother ESP & Auto Safe Toggle (Ashina Format)
-- ====================================================================
local motherConnection = nil
local motherCheckConnection = nil
local motherTracker = {} -- Dito natin ise-save ang mga active highlights ng Mother
local safespotCFrame = CFrame.new(-4421.647, 683.953, -2365.499)

createToggle("Section 5", "Mother ESP & Auto Safe", "Highlights Mother monster and auto teleports to safespot when close", function(state)
    local player = game:GetService("Players").LocalPlayer
    
    if state then
        -- ===== STATE IS TRUE (TOGGLE ON) =====
        
        -- Function para i-check at lagyan ng highlight ang Mother body/part
        local function checkMother(obj)
            local motherPart = nil
            if obj:IsA("BasePart") then
                motherPart = obj
            elseif obj:IsA("Model") then
                motherPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            end
            
            if motherPart and not motherTracker[motherPart] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "MotherESP_Highlight"
                highlight.Adornee = motherPart
                highlight.FillColor = Color3.fromRGB(255, 0, 0)       -- Pulang kulay sa loob
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Puting gilid
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = motherPart
                
                motherTracker[motherPart] = highlight
            end
        end

        -- 1. I-scan muna ang workspace para sa mga nandiyan nang Mother
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant.Name == "Mother" then
                checkMother(descendant)
            end
        end
        
        -- 2. I-on ang dynamic listener para sa mga susunod na mag-spawn sa workspace
        if not motherConnection then
            motherConnection = workspace.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "Mother" then
                    task.wait(0.1)
                    checkMother(descendant)
                end
            end)
        end
        
        -- 3. Auto SafeZone Loop (Babalik sa safespot kapag lumapit ang Mother)
        if not motherCheckConnection then
            motherCheckConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local character = player.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                for part, _ in pairs(motherTracker) do
                    if part and part.Parent then
                        local distance = (part.Position - rootPart.Position).Magnitude
                        -- Kapag pumasok sa loob ng 35 studs radius, teleport agad sa safespot
                        if distance <= 35 then
                            rootPart.CFrame = safespotCFrame
                            if type(notify) == "function" then
                                notify("Auto Safe", "Delikado! Lumapit ang Mother, inilipat ka sa safespot.", 2)
                            end
                            task.wait(1) -- Para iwas spam
                        end
                    end
                end
            end)
        end
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "IOHUB ESP Active",
            Text = "🔴 Mother ESP & Auto Safe: ON",
            Duration = 3
        })
    else
        -- ===== STATE IS FALSE (TOGGLE OFF) =====
        -- 1. Patayin ang event listeners
        if motherConnection then
            motherConnection:Disconnect()
            motherConnection = nil
        end
        
        if motherCheckConnection then
            motherCheckConnection:Disconnect()
            motherCheckConnection = nil
        end
        
        -- 2. Burahin lahat ng nakakabit na highlights ng Mother
        for part, highlight in pairs(motherTracker) do
            if highlight then highlight:Destroy() end
        end
        table.clear(motherTracker)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "IOHUB ESP Status",
            Text = "⚪ Mother ESP & Auto Safe: OFF",
            Duration = 2
        })
    end
end)



-- ====================================================================
-- Custom Button: TP Real Daughter & Auto Return to Safespot
-- ====================================================================
createCustomButton("Section 5", "Auto Find Daughter", "Teleport to Daughter Location and Back to Safe Spot", function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        local safespotCFrame = CFrame.new(-4421.647, 683.953, -2365.499)
        local targetCFrame = nil
        local foundDaughter = nil
        
        -- 1. Function para i-check kung ang object ay nasa loob ng Jumpscare o Cutscene folder
        local function isInsideJumpscare(obj)
            local current = obj
            while current and current ~= workspace do
                local name = current.Name:lower()
                if name:find("jumpscare") or name:find("cutscene") then
                    return true
                end
                current = current.Parent
            end
            return false
        end
        
        -- 2. I-scan ang workspace para sa tamang "Daughter" na HINDI nasa Jumpscare
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc.Name == "Daughter" then
                if not isInsideJumpscare(desc) then
                    foundDaughter = desc
                    break
                end
            end
        end
        
        -- 3. Kunin ang CFrame o Pivot
        if foundDaughter then
            if foundDaughter:IsA("Model") then
                local success, pivot = pcall(function()
                    return foundDaughter:GetPivot()
                end)
                if success and pivot then
                    targetCFrame = pivot
                else
                    local anyPart = foundDaughter:FindFirstChildWhichIsA("BasePart", true)
                    if anyPart then
                        targetCFrame = anyPart.CFrame
                    end
                end
            elseif foundDaughter:IsA("BasePart") then
                targetCFrame = foundDaughter.CFrame
            end
        end
        
        -- 4. Isagawa ang Teleport papunta kay Daughter, tapos balik sa Safespot
        if targetCFrame then
            rootPart.CFrame = targetCFrame + Vector3.new(0, 3, 0)
            
            if type(notify) == "function" then
                notify("Daughter TP", "Naka-teleport kay Daughter! Bumabalik sa safespot...", 1.5)
            end
            
            task.wait(0.5) -- Maghintay nang saglit para sa interaction
            
            rootPart.CFrame = safespotCFrame
        else
            if type(notify) == "function" then
                notify("Error", "Hindi nahanap ang tamang Daughter o hindi pa naglo-load.", 2)
            end
        end
    else
        if type(notify) == "function" then
            notify("Error", "Hindi makita ang Character/RootPart!", 2)
        end
    end
end)




-- ====================================================================
-- Custom Button: TP to Exact Door Model (Bulletproof Version)
-- ====================================================================
createCustomButton("Section 5", "TP Exact Door", "Teleport papunta sa eksaktong Door model", function()
    local player = game:GetService("Players").LocalPlayer
    local workspace = game:GetService("Workspace")
    
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        local targetCFrame = nil
        local foundDoor = nil
        
        -- 1. I-scan ang workspace para hanapin ang Model na ang pangalan ay "Door"
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc.Name == "Door" and desc:IsA("Model") then
                local parent = desc.Parent
                if parent then
                    local pName = parent.Name
                    if not pName:lower():find("portal") and not pName:lower():find("jumpscare") then
                        foundDoor = desc
                        break
                    end
                end
            end
        end
        
        -- 2. Kunin ang posisyon gamit ang Model Pivot o huling physical part sa loob
        if foundDoor then
            local success, pivot = pcall(function()
                return foundDoor:GetPivot()
            end)
            
            if success and pivot and pivot.Position.Magnitude > 0 then
                targetCFrame = pivot
            else
                for _, part in ipairs(foundDoor:GetDescendants()) do
                    if part:IsA("BasePart") then
                        targetCFrame = part.CFrame
                        break
                    end
                end
            end
        end
        
        -- 3. Isagawa ang Teleport
        if targetCFrame then
            rootPart.CFrame = targetCFrame + Vector3.new(0, 3, 0)
            if type(notify) == "function" then
                notify("Door TP", "Matagumpay na naka-teleport sa Door Model!", 2)
            end
        else
            if type(notify) == "function" then
                notify("Door TP", "Hindi makuha ang CFrame ng Door Model.", 2)
            end
        end
    else
        if type(notify) == "function" then
            notify("Error", "Hindi makita ang Character/RootPart!", 2)
        end
    end
end)





-- ====================================================================
-- Custom Button: Auto Collect Notes (Bulletproof & Safe)
-- ====================================================================
createCustomButton("Section 5", "Auto Collect Notes", "Awtomatikong magte-teleport sa mga Notes, kukunin gamit ang prompt, at babalik sa safespot", function()
    local player = game:GetService("Players").LocalPlayer
    local workspace = game:GetService("Workspace")
    
    
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then
        if type(notify) == "function" then
            notify("Error", "Hindi makita ang Character/RootPart!", 2)
        end
        return
    end
    
    if type(notify) == "function" then
        notify("Notes", "Sinisimulan ang pagkolekta ng mga Notes...", 1.5)
    end
    
    task.spawn(function()
        local collectedCount = 0
        
        -- I-scan ang buong workspace para sa mga Notes (Model o BasePart man yan)
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc.Name == "Note" or desc.Name:lower():find("note") then
                local targetCFrame = nil
                
                -- Kunin ang CFrame o Pivot ng Note
                if desc:IsA("Model") then
                    local success, pivot = pcall(function() return desc:GetPivot() end)
                    if success and pivot and pivot.Position.Magnitude > 0 then
                        targetCFrame = pivot
                    else
                        for _, part in ipairs(desc:GetDescendants()) do
                            if part:IsA("BasePart") then
                                targetCFrame = part.CFrame
                                break
                            end
                        end
                    end
                elseif desc:IsA("BasePart") then
                    targetCFrame = desc.CFrame
                end
                
                -- Kung nakuha ang posisyon, i-teleport at kolektahin
                if targetCFrame then
                    rootPart.CFrame = targetCFrame + Vector3.new(0, 2, 0)
                    task.wait(0.3) -- Maghintay para mag-load ang prompt sa client
                    
                    -- Hanapin ang ProximityPrompt sa malapit at i-fire
                    local promptFired = false
                    for _, prompt in ipairs(workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            local pParent = prompt.Parent
                            if pParent and pParent:IsA("BasePart") then
                                if (pParent.Position - rootPart.Position).Magnitude <= 12 then
                                    pcall(function()
                                        fireproximityprompt(prompt)
                                    end)
                                    promptFired = true
                                    collectedCount = collectedCount + 1
                                    break
                                end
                            end
                        end
                    end
                    
                    if not promptFired then
                        collectedCount = collectedCount + 1
                    end
                    
                    task.wait(0.2) -- Delay bago lumipat sa sunod
                end
            end
        end
        
        -- Bumalik sa Safespot pagkatapos maubos kolektahin ang lahat
        task.wait(0.5)
        
        
        if type(notify) == "function" then
            notify("Notes", "Tapos na! Nakolekta ang " .. collectedCount .. " na notes. Bumalik sa Safespot.", 2)
        end
    end)
end)


-- ====================================================================
-- CreateToggle: Nure ESP (Strict Exact Case: HITBOX & HEADHITBOX Only)
-- ====================================================================
local espEnabled = false
local espHighlights = {}

createToggle("Section 5", "Nagisa ESP (Hitboxes)", "Naglalagay ng Highlight eksklusibo sa HITBOX at HEADHITBOX", function(state)
    espEnabled = state
    
    if espEnabled then
        task.spawn(function()
            while espEnabled do
                for _, desc in ipairs(workspace:GetDescendants()) do
                    if desc:IsA("BasePart") then
                        -- Saktong pangalan na may tamang capitalization (walang lower)
                        local name = desc.Name
                        
                        if name == "HITBOX" or name == "HEADHITBOX" then
                            if not espHighlights[desc] then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = desc
                                hl.FillColor = Color3.fromRGB(255, 50, 50)     -- Pula
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255) -- Puti ang gilid
                                hl.FillTransparency = 0.4
                                hl.Parent = desc
                                espHighlights[desc] = hl
                            end
                        end
                    end
                end
                task.wait(2) -- Refresh every 2 seconds para sa mga bagong spawn/load
            end
        end)
    else
        -- Alisin lahat ng ESP kapag naka-off ang toggle
        for part, hl in pairs(espHighlights) do
            if hl then hl:Destroy() end
        end
        espHighlights = {}
    end
end)





-- ====================================================================
-- CreateToggle: Auto SafeSpot (One-shot per Cycle)
-- ====================================================================
local autoSafeEnabled = false

createToggle("Section 5", "Auto SafeSpot Nagisa Poison", "Magte-teleport sa danger kapag 0.5, tapos sa spawn kapag naging 1 (One-time per trigger)", function(state)
    autoSafeEnabled = state
    
    if autoSafeEnabled then
        task.spawn(function()
            local dangerSpot = CFrame.new(1976.510, 147.665, -4721.051)
            local spawnSpot = CFrame.new(1973.085, 58.095, -4772.383)
            
            local hasBeenTriggered = false -- Para hindi mag-spam
            
            while autoSafeEnabled do
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    -- Hanapin ang POISON part
                    local poisonPart = nil
                    for _, desc in ipairs(workspace:GetDescendants()) do
                        if desc.Name == "POISON" and desc:IsA("BasePart") then
                            poisonPart = desc
                            break
                        end
                    end
                    
                    if poisonPart then
                        local trans = poisonPart.Transparency
                        
                        -- Kapag naging 0.5, pumunta sa danger spot (isang beses lang kada cycle)
                        if trans == 0.5 and not hasBeenTriggered then
                            rootPart.CFrame = dangerSpot
                            hasBeenTriggered = true
                        -- Kapag bumalik sa 1, ibalik sa spawn spot at i-reset ang trigger para sa susunod
                        elseif trans == 1 and hasBeenTriggered then
                            rootPart.CFrame = spawnSpot
                            hasBeenTriggered = false
                        end
                    end
                end
                
                task.wait(0.3)
            end
        end)
    end
end)








-- ====================================================================
-- Custom Button: Auto Collect Cannon Ball (5x Fire)
-- ====================================================================
createCustomButton("Section 5", "Auto Collect Cannon Ball (5x)", "Awtomatikong kukunin ang Cannon ball at i-fire ng 5 beses", function()
    local player = game:GetService("Players").LocalPlayer
    local workspace = game:GetService("Workspace")
    
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then
        if type(notify) == "function" then notify("Error", "Wala kang Character/RootPart!", 2) end
        return
    end
    
    local foundPrompt = false
    
    -- I-scan ang buong workspace para hanapin ang tamang ProximityPrompt ng Cannon Ball
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local actionText = tostring(desc.ActionText):lower()
            local objectText = tostring(desc.ObjectText):lower()
            
            if actionText:find("cannon") or objectText:find("ball") or actionText:find("grab") or desc.Name:lower():find("ballgiver") then
                local parentPart = desc.Parent
                if parentPart and parentPart:IsA("BasePart") then
                    -- Teleport malapit sa prompt
                    rootPart.CFrame = parentPart.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.2)
                    
                    -- I-fire ng 5 beses nang sunod-sunod
                    for i = 1, 5 do
                        pcall(function()
                            fireproximityprompt(desc)
                        end)
                        task.wait(0.15) -- Kaunting delay kada fire para pumasok sa laro
                    end
                    
                    foundPrompt = true
                    if type(notify) == "function" then
                        notify("Cannon Ball", "Matagumpay na nakolekta ang Cannon Ball (5x Fire)!", 2)
                    end
                    break
                end
            end
        end
    end
    
    if not foundPrompt then
        if type(notify) == "function" then
            notify("Cannon Ball", "Hindi mahanap ang Cannon Ball prompt sa paligid.", 2)
        end
    end
end)


-- ====================================================================
-- Custom Button: Hold to Attack Boss (TP, Equip, Slash, Return)
-- ====================================================================
createCustomButton("Section 2", "Hold Attack Boss", "I-hold para lumipat sa TailHitbox at mag-slash, bitawan para bumalik sa SafeSpot", function(btnObject)
    local player = game:GetService("Players").LocalPlayer
    local workspace = game:GetService("Workspace")
    local runService = game:GetService("RunService")
    
    local safespotCFrame = CFrame.new(1976.510, 147.665, -4721.051)
    
    -- Function para hanapin ang TailHitbox1 nang dynamic (walang 0x ID)
    local function getTailHitbox()
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc.Name == "TailHitbox1" and desc:IsA("BasePart") then
                return desc
            end
        end
        return nil
    end
    
    -- Kung ang btnObject ay nagbibigay ng direktang TextButton, ikinakabit natin ang hold events
    if btnObject and btnObject:IsA("TextButton") then
        local isHolding = false
        local holdConnection = nil
        
        -- Alisin muna ang mga lumang koneksyon para hindi mag-stack
        if btnObject:FindFirstChild("HoldConn") then
            btnObject.HoldConn:Destroy()
        end
        
        local connFolder = Instance.new("Folder")
        connFolder.Name = "HoldConn"
        connFolder.Parent = btnObject
        
        -- Kapag PININDOT at HINAHAWAKAN
        local downConn = btnObject.MouseButton1Down:Connect(function()
            isHolding = true
            btnObject.Text = "⚔️ ATTACKING..."
            btnObject.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
            
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local backpack = player:FindFirstChild("Backpack")
            
            if not rootPart then return end
            
            -- 1. Auto-Equip Cutlass mula sa Backpack
            if backpack then
                local cutlassTool = backpack:FindFirstChild("Cutlass")
                if cutlassTool and humanoid then
                    humanoid:EquipTool(cutlassTool)
                end
            end
            
            -- 2. Loop habang nakahawak para sumunod sa TailHitbox at mag-slash
            holdConnection = runService.RenderStepped:Connect(function()
                if not isHolding then return end
                
                local currentChars = player.Character
                local currentRoot = currentChars and currentChars:FindFirstChild("HumanoidRootPart")
                
                if currentRoot then
                    local tailPart = getTailHitbox()
                    if tailPart then
                        currentRoot.CFrame = tailPart.CFrame + Vector3.new(0, 3, 0)
                    end
                end
                
                -- Auto Slash (Activate ang Cutlass tool)
                local equippedTool = currentChars and currentChars:FindFirstChild("Cutlass")
                if equippedTool and equippedTool:IsA("Tool") then
                    pcall(function()
                        equippedTool:Activate()
                    end)
                end
            end)
        end)
        
        -- Function para sa pagbinitaw
        local function releaseAction()
            if not isHolding then return end
            isHolding = false
            
            if holdConnection then
                holdConnection:Disconnect()
                holdConnection = nil
            end
            
            btnObject.Text = "Hold Attack Boss"
            btnObject.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Ibalik sa default UI color mo kung kailangan
            
            -- 3. Teleport pabalik sa SafeSpot kapag binitawan
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = safespotCFrame
            end
        end
        
        local upConn1 = btnObject.MouseButton1Up:Connect(releaseAction)
        local upConn2 = btnObject.MouseLeave:Connect(releaseAction)
        
        -- I-save sa folder para ma-cleanup mamaya
        downConn.Parent = connFolder
        upConn1.Parent = connFolder
        upConn2.Parent = connFolder
    else
        -- Fallback kung standard click lang ang kaya ng UI library mo (instant TP, slash, return)
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local backpack = player:FindFirstChild("Backpack")
        
        if rootPart then
            if backpack then
                local cutlassTool = backpack:FindFirstChild("Cutlass")
                if cutlassTool and humanoid then
                    humanoid:EquipTool(cutlassTool)
                end
            end
            
            local tailPart = getTailHitbox()
            if tailPart then
                rootPart.CFrame = tailPart.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.2)
                
                local equippedTool = character:FindFirstChild("Cutlass")
                if equippedTool and equippedTool:IsA("Tool") then
                    pcall(function() equippedTool:Activate() end)
                end
                
                task.wait(0.3)
                rootPart.CFrame = safespotCFrame
            end
        end
    end
end)




-- ====================================================================
-- Custom Button: Get Cutlass (1x Fire)
-- ====================================================================
createCustomButton("Section 5", "Get Cutlass", "Awtomatikong kukunin ang Cutlass gamit ang dynamic search (1x Fire)", function()
    local player = game:GetService("Players").LocalPlayer
    local workspace = game:GetService("Workspace")
    
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then
        if type(notify) == "function" then notify("Error", "Wala kang Character/RootPart!", 2) end
        return
    end
    
    local foundPrompt = false
    
    -- Dynamic scan sa buong workspace para hanapin ang Cutlass o ang prompt nito
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local actionText = tostring(desc.ActionText):lower()
            local objectText = tostring(desc.ObjectText):lower()
            local parentName = desc.Parent and desc.Parent.Name:lower() or ""
            
            -- I-check kung ito ay tumutugma sa Cutlass / Grab prompt
            if actionText:find("cutlass") or objectText:find("grab") or parentName:find("cutlass") then
                local parentPart = desc.Parent
                
                -- Kunin ang CFrame ng BasePart o sa loob ng model
                local targetCFrame = nil
                if parentPart and parentPart:IsA("BasePart") then
                    targetCFrame = parentPart.CFrame
                elseif parentPart and parentPart:IsA("Model") then
                    local pSuccess, pivot = pcall(function() return parentPart:GetPivot() end)
                    if pSuccess and pivot then targetCFrame = pivot end
                end
                
                if targetCFrame then
                    rootPart.CFrame = targetCFrame + Vector3.new(0, 2, 0)
                    task.wait(0.2)
                    
                    -- Isang beses lang i-fire ang prompt
                    pcall(function()
                        fireproximityprompt(desc)
                    end)
                    
                    foundPrompt = true
                    if type(notify) == "function" then
                        notify("Cutlass", "Matagumpay na nakuha ang Cutlass (1x Fire)!", 2)
                    end
                    break
                end
            end
        end
    end
    
    if not foundPrompt then
        if type(notify) == "function" then
            notify("Cutlass", "Hindi mahanap ang Cutlass prompt sa paligid.", 2)
        end
    end
end)










-- ====================================================================
-- YEN ESP TOGGLE (HOGO STYLE)
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local player = game:GetService("Players").LocalPlayer
local yenConnection = nil
local yenRenderConnection = nil

createToggle("Settings", "Yen ESP", "Highlights scattered Yen items with distance", function(state)
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    local yenFolder = Workspace:FindFirstChild("Yen")

    local function addYenESP(yenItem)
        if not yenItem then return end
        local tagIdentifier = "YenESP_" .. yenItem:GetFullName()
        
        -- Alisin muna kung meron na para iwas duplicate
        if CoreGui:FindFirstChild(tagIdentifier) then
            CoreGui[tagIdentifier]:Destroy()
        end

        -- 1. Highlight para lumitaw ang kulay (Gold/Yellow) sa Yen item
        local highlight = yenItem:FindFirstChild("YenHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "YenHighlight"
            highlight.FillColor = Color3.fromRGB(255, 215, 0) -- Gold Color
            highlight.FillTransparency = 0.4
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = yenItem
        end

        -- 2. Hanapin ang BasePart para sa Adornee ng BillboardGui
        local targetPart = yenItem:IsA("BasePart") and yenItem or yenItem:FindFirstChildWhichIsA("BasePart", true)
        if targetPart then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = tagIdentifier
            billboard.Size = UDim2.new(0, 150, 0, 40)
            billboard.AlwaysOnTop = true
            billboard.ExtentsOffset = Vector3.new(0, 2, 0)
            billboard.Adornee = targetPart
            billboard.Parent = CoreGui
            
            local label = Instance.new("TextLabel")
            label.Name = "YenLabel"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "💰 Yen"
            label.TextColor3 = Color3.fromRGB(255, 223, 0)
            label.TextSize = 14
            label.Font = Enum.Font.SourceSansBold
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextStrokeTransparency = 0
            label.Parent = billboard
        end
    end

    if state then
        -- ===== [TOGGLE ON] =====
        if yenFolder then
            for _, yen in ipairs(yenFolder:GetChildren()) do
                pcall(function() addYenESP(yen) end)
            end

            -- Live tracking kapag may nadagdag o lumitaw na bagong Yen
            yenConnection = yenFolder.ChildAdded:Connect(function(yen)
                task.spawn(function()
                    task.wait(0.1)
                    pcall(function() addYenESP(yen) end)
                end)
            end)
        end

        -- Real-time distance tracker (kung gaano kalayo ang bawat Yen sa studs)
        yenRenderConnection = RunService.RenderStepped:Connect(function()
            local myChar = player.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot or not yenFolder then return end

            for _, gui in ipairs(CoreGui:GetChildren()) do
                if string.sub(gui.Name, 1, 7) == "YenESP_" then
                    local label = gui:FindFirstChild("YenLabel")
                    local adornee = gui.Adornee
                    
                    if label and adornee and adornee.Parent then
                        local distance = math.floor((myRoot.Position - adornee.Position).Magnitude)
                        label.Text = "💰 Yen [" .. distance .. "s]"
                    end
                end
            end
        end)

        notify("YEN ESP", "🟢 Yen ESP with Distance: ON", 2)
    else
        -- ===== [TOGGLE OFF] =====
        if yenConnection then
            yenConnection:Disconnect()
            yenConnection = nil
        end
        
        if yenRenderConnection then
            yenRenderConnection:Disconnect()
            yenRenderConnection = nil
        end

        -- Alisin ang lahat ng Yen highlights at billboards
        if yenFolder then
            for _, yen in ipairs(yenFolder:GetChildren()) do
                local hl = yen:FindFirstChild("YenHighlight")
                if hl then hl:Destroy() end
            end
        end

        for _, gui in ipairs(CoreGui:GetChildren()) do
            if string.sub(gui.Name, 1, 7) == "YenESP_" then
                gui:Destroy()
            end
        end

        notify("YEN ESP", "⚪ Yen ESP: OFF", 2)
    end
end)

-- ====================================================================
-- DAYTIME / MORNING TOGGLE (SETTINGS)
-- ====================================================================
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

-- I-save ang original settings para maibalik kapag naka-off
local originalLightingData = {
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient,
    GlobalShadows = Lighting.GlobalShadows,
    Atmosphere = {},
    ColorCorrection = {},
    Sky = {}
}

createToggle("Settings", "DayTime/Morning", "Toggles full brightness / removes darkness and red atmosphere", function(state)
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    if state then
        -- ===== [TOGGLE ON] =====
        -- I-save ang current state mago bago palitan
        originalLightingData.ClockTime = Lighting.ClockTime
        originalLightingData.Brightness = Lighting.Brightness
        originalLightingData.OutdoorAmbient = Lighting.OutdoorAmbient
        originalLightingData.Ambient = Lighting.Ambient
        originalLightingData.GlobalShadows = Lighting.GlobalShadows

        pcall(function()
            Lighting.ClockTime = 14
            Lighting.Brightness = 3
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
            Lighting.Ambient = Color3.fromRGB(150, 150, 150)
            Lighting.GlobalShadows = false
            
            for _, child in ipairs(Lighting:GetChildren()) do
                if child:IsA("Atmosphere") then
                    originalLightingData.Atmosphere[child] = {Density = child.Density, Haze = child.Haze, Color = child.Color, Decay = child.Decay}
                    child.Density = 0
                    child.Haze = 0
                    child.Color = Color3.fromRGB(255, 255, 255)
                    child.Decay = Color3.fromRGB(255, 255, 255)
                elseif child:IsA("ColorCorrectionEffect") then
                    originalLightingData.ColorCorrection[child] = {TintColor = child.TintColor, Saturation = child.Saturation, Contrast = child.Contrast}
                    child.TintColor = Color3.fromRGB(255, 255, 255)
                    child.Saturation = 0.1
                    child.Contrast = 0.1
                elseif child:IsA("Sky") then
                    originalLightingData.Sky[child] = child.StarCount
                    child.StarCount = 0
                end
            end
        end)
        
        notify("DayTime Active", "☀️ DayTime Morning Enabled", 2.5)
    else
        -- ===== [TOGGLE OFF] =====
        pcall(function()
            Lighting.ClockTime = originalLightingData.ClockTime
            Lighting.Brightness = originalLightingData.Brightness
            Lighting.OutdoorAmbient = originalLightingData.OutdoorAmbient
            Lighting.Ambient = originalLightingData.Ambient
            Lighting.GlobalShadows = originalLightingData.GlobalShadows
            
            for child, data in pairs(originalLightingData.Atmosphere) do
                if child and child.Parent then
                    child.Density = data.Density
                    child.Haze = data.Haze
                    child.Color = data.Color
                    child.Decay = data.Decay
                end
            end

            for child, data in pairs(originalLightingData.ColorCorrection) do
                if child and child.Parent then
                    child.TintColor = data.TintColor
                    child.Saturation = data.Saturation
                    child.Contrast = data.Contrast
                end
            end

            for child, starCount in pairs(originalLightingData.Sky) do
                if child and child.Parent then
                    child.StarCount = starCount
                end
            end
        end)

        notify("DayTime Disabled", "🌙 Original Darkness Restored", 2.5)
    end
end)




-- ====================================================================
-- ANTI-LAG / LOW GRAPHICS TOGGLE
-- ====================================================================
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local antilagConnection = nil
local originalSettings = {}

createToggle("Settings", "Anti-Lag / Low Graphics", "Boosts FPS by disabling shadows, particles, and heavy textures", function(state)
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    if state then
        -- ===== [TOGGLE ON] =====
        notify("Anti-Lag", "Enabling FPS Boost...", 2)

        local Terrain = Workspace:FindFirstChildWhichIsA("Terrain")
        if Terrain then
            originalSettings.WaterWaveSize = Terrain.WaterWaveSize
            originalSettings.WaterWaveSpeed = Terrain.WaterWaveSpeed
            originalSettings.WaterReflectance = Terrain.WaterReflectance
            originalSettings.WaterTransparency = Terrain.WaterTransparency
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end

        originalSettings.GlobalShadows = Lighting.GlobalShadows
        originalSettings.FogEnd = Lighting.FogEnd
        originalSettings.FogStart = Lighting.FogStart
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9

        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                originalSettings[v] = {CastShadow = v.CastShadow, Material = v.Material, Reflectance = v.Reflectance}
                v.CastShadow = false
                v.Material = "Plastic"
                v.Reflectance = 0
            elseif v:IsA("Decal") then
                if originalSettings[v] == nil then originalSettings[v] = v.Transparency end
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                if originalSettings[v] == nil then originalSettings[v] = v.Lifetime end
                v.Lifetime = NumberRange.new(0)
            end
        end

        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("PostEffect") then
                originalSettings[v] = v.Enabled
                v.Enabled = false
            end
        end

        antilagConnection = Workspace.DescendantAdded:Connect(function(child)
            task.spawn(function()
                if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                    RunService.Heartbeat:Wait()
                    child:Destroy()
                elseif child:IsA("BasePart") then
                    child.CastShadow = false
                end
            end)
        end)

        notify("Anti-Lag", "⚡ Anti-Lag Enabled: Graphics Optimized", 3)
    else
        -- ===== [TOGGLE OFF] =====
        if antilagConnection then
            antilagConnection:Disconnect()
            antilagConnection = nil
        end

        local Terrain = Workspace:FindFirstChildWhichIsA("Terrain")
        if Terrain and originalSettings.WaterTransparency then
            Terrain.WaterWaveSize = originalSettings.WaterWaveSize
            Terrain.WaterWaveSpeed = originalSettings.WaterWaveSpeed
            Terrain.WaterReflectance = originalSettings.WaterReflectance
            Terrain.WaterTransparency = originalSettings.WaterTransparency
        end

        Lighting.GlobalShadows = originalSettings.GlobalShadows ~= nil and originalSettings.GlobalShadows or true
        Lighting.FogEnd = originalSettings.FogEnd ~= nil and originalSettings.FogEnd or 100000
        Lighting.FogStart = originalSettings.FogStart ~= nil and originalSettings.FogStart or 0

        for _, v in pairs(game:GetDescendants()) do
            if originalSettings[v] then
                if v:IsA("BasePart") then
                    v.CastShadow = originalSettings[v].CastShadow
                    v.Material = originalSettings[v].Material
                    v.Reflectance = originalSettings[v].Reflectance
                elseif v:IsA("Decal") then
                    v.Transparency = originalSettings[v]
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = originalSettings[v]
                end
            end
        end

        for _, v in pairs(Lighting:GetDescendants()) do
            if originalSettings[v] ~= nil and v:IsA("PostEffect") then
                v.Enabled = originalSettings[v]
            end
        end

        originalSettings = {}
        notify("Anti-Lag", "⚪ Anti-Lag Disabled: Original Graphics Restored", 2)
    end
end)


-- ====================================================================
-- FLY TOGGLE WITH SPEED (SETTINGS)
-- ====================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local speaker = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flyActive = false
local flyConnection = nil
local flyKeyDown, flyKeyUp = nil, nil

-- Dito mo pwedeng baguhin ang bilis ng lipad (Default ay 14)
local flightSpeed = 14 

createToggle("Settings", "Fly Mode (Speed 14)", "Enables Flight with customizable speed", function(state)
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    local char = speaker.Character or speaker.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

    if not root or not humanoid then
        notify("Fly Error", "Character root or humanoid not found!", 2)
        return
    end

    local velocityHandlerName = "IYFlyVelocity"
    local gyroHandlerName = "IYFlyGyro"

    if state then
        -- ===== [TOGGLE ON] =====
        flyActive = true

        if root:FindFirstChild(velocityHandlerName) then root[velocityHandlerName]:Destroy() end
        if root:FindFirstChild(gyroHandlerName) then root[gyroHandlerName]:Destroy() end

        local v3zero = Vector3.new(0, 0, 0)
        local v3inf = Vector3.new(9e9, 9e9, 9e9)

        local bv = Instance.new("BodyVelocity")
        bv.Name = velocityHandlerName
        bv.Parent = root
        bv.MaxForce = v3inf
        bv.Velocity = v3zero

        local bg = Instance.new("BodyGyro")
        bg.Name = gyroHandlerName
        bg.Parent = root
        bg.MaxTorque = v3inf
        bg.P = 1000
        bg.D = 50

        humanoid.PlatformStand = true

        local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}

        if not isMobile then
            flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == Enum.KeyCode.W then
                    CONTROL.F = 1
                elseif input.KeyCode == Enum.KeyCode.S then
                    CONTROL.B = -1
                elseif input.KeyCode == Enum.KeyCode.A then
                    CONTROL.L = -1
                elseif input.KeyCode == Enum.KeyCode.D then
                    CONTROL.R = 1
                elseif input.KeyCode == Enum.KeyCode.E then
                    CONTROL.Q = 1
                elseif input.KeyCode == Enum.KeyCode.Q then
                    CONTROL.E = -1
                end
            end)

            flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == Enum.KeyCode.W then
                    CONTROL.F = 0
                elseif input.KeyCode == Enum.KeyCode.S then
                    CONTROL.B = 0
                elseif input.KeyCode == Enum.KeyCode.A then
                    CONTROL.L = 0
                elseif input.KeyCode == Enum.KeyCode.D then
                    CONTROL.R = 0
                elseif input.KeyCode == Enum.KeyCode.E then
                    CONTROL.Q = 0
                elseif input.KeyCode == Enum.KeyCode.Q then
                    CONTROL.E = 0
                end
            end)
        end

        local success, controlModule = pcall(function()
            return require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
        end)

        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyActive or not char or not humanoid or humanoid.Health <= 0 then return end
            
            bg.CFrame = camera.CFrame
            bv.Velocity = v3zero

            if isMobile then
                if success and controlModule then
                    local direction = controlModule:GetMoveVector()
                    -- Ginamit ang flightSpeed multiplier
                    local speedMultiplier = flightSpeed * 3.5 
                    
                    if direction.X ~= 0 then
                        bv.Velocity = bv.Velocity + camera.CFrame.RightVector * (direction.X * speedMultiplier)
                    end
                    if direction.Z ~= 0 then
                        bv.Velocity = bv.Velocity - camera.CFrame.LookVector * (direction.Z * speedMultiplier)
                    end
                end
            else
                bv.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + 
                ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * (flightSpeed * 15)
            end
        end)

        notify("Fly Active", "✈️ Flight Enabled (Speed: 14)", 2)
    else
        -- ===== [TOGGLE OFF] =====
        flyActive = false

        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if flyKeyDown then
            flyKeyDown:Disconnect()
            flyKeyDown = nil
        end
        if flyKeyUp then
            flyKeyUp:Disconnect()
            flyKeyUp = nil
        end

        pcall(function()
            if root then
                if root:FindFirstChild(velocityHandlerName) then root[velocityHandlerName]:Destroy() end
                if root:FindFirstChild(gyroHandlerName) then root[gyroHandlerName]:Destroy() end
            end
            if humanoid then
                humanoid.PlatformStand = false
            end
        end)

        notify("Fly Disabled", "🛑 Flight Mode Off", 2)
    end
end)


-- ====================================================================
-- NOCLIP TOGGLE (SETTINGS)
-- ====================================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local noclipConnection = nil

createToggle("Settings", "Noclip", "Walk through walls and obstacles", function(state)
    local function notify(title, text, duration)
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 2;
        })
    end

    if state then
        -- ===== [TOGGLE ON] =====
        if noclipConnection then
            noclipConnection:Disconnect()
        end

        noclipConnection = RunService.Stepped:Connect(function()
            local character = player.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)

        notify("NOCLIP", "🟢 Noclip Enabled: Walking through walls", 2)
    else
        -- ===== [TOGGLE OFF] =====
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end

        local character = player.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end

        notify("NOCLIP", "⚪ Noclip Disabled: Collisions Restored", 2)
    end
end)




switchTab("Section 1")

