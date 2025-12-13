local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Cam = game.Workspace.CurrentCamera

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Players.LocalPlayer.PlayerGui

--DraggingThing
local Dragging, DragStart, StartPos, DragInput

--AimbotThing
local abEnabled = false
local teamCheck = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.2, 0, 0.8, 0)
MainFrame.Position = UDim2.new(0.4, 0, 0.09, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.1, 0)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.Text = "Aimbot"
Title.TextSize = 36
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local FPSCounter = Instance.new("TextLabel")
FPSCounter.Size = UDim2.new(1, 0, 0.05, 0)
FPSCounter.Position = UDim2.new(0, 0, 0.1, 0)
FPSCounter.Text = "FPS: 0"
FPSCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSCounter.BackgroundTransparency = 1
FPSCounter.Font = Enum.Font.SourceSans
FPSCounter.TextSize = 20
FPSCounter.Parent = MainFrame

local ButtonsContainer = Instance.new("Frame")
ButtonsContainer.Size = UDim2.new(1, 0, 0.75, 0)
ButtonsContainer.Position = UDim2.new(0.022, 0, 0.16, 0)
ButtonsContainer.BackgroundTransparency = 1
ButtonsContainer.ClipsDescendants = true
ButtonsContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.Padding = UDim.new(0.02, 0)
UIListLayout.Parent = ButtonsContainer

local PageLeft = Instance.new("TextButton")
PageLeft.Size = UDim2.new(0.48, 0, 0.05, 0)
PageLeft.Position = UDim2.new(0.01, 0, 0.96, 0)
PageLeft.Text = "<"
PageLeft.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
PageLeft.Font = Enum.Font.SourceSansBold
PageLeft.TextSize = 20
PageLeft.Parent = MainFrame
local UICorner_ButtonPL = Instance.new("UICorner")
    UICorner_ButtonPL.CornerRadius = UDim.new(0.3, 0)
    UICorner_ButtonPL.Parent = PageLeft

local PageRight = Instance.new("TextButton")
PageRight.Size = UDim2.new(0.48, 0, 0.05, 0)
PageRight.Position = UDim2.new(0.51, 0, 0.96, 0)
PageRight.Text = ">"
PageRight.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
PageRight.Font = Enum.Font.SourceSansBold
PageRight.TextSize = 20
PageRight.Parent = MainFrame
local UICorner_ButtonPR = Instance.new("UICorner")
    UICorner_ButtonPR.CornerRadius = UDim.new(0.3, 0)
    UICorner_ButtonPR.Parent = PageRight

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function(dt)
    FPSCounter.Text = "FPS: " .. tostring(math.floor(1 / dt))
end)

local buttons = {
    {name = "Button1", type = "button", callback = function() print("Button1 clicked") end},
    {name = "Aimbot", type = "toggle", on = function() abEnabled = true end, off = function() abEnabled = false end},
    {name = "Team Check", type = "toggle", on = function() teamCheck = true end, off = function() teamCheck = false end},
}

local currentPage = 1
local itemsPerPage = 5

local function renderPage(page)
    for _, child in ipairs(ButtonsContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local startIndex = (page - 1) * itemsPerPage + 1
    local endIndex = math.min(page * itemsPerPage, #buttons)
    for i = startIndex, endIndex do
        local item = buttons[i]
        local btn = Instance.new("TextButton", ButtonsContainer)
        btn.Size = UDim2.new(0.95, 0, 0.1, 0)
        btn.Text = item.name
        btn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 20
        local UICorner_Button = Instance.new("UICorner")
    UICorner_Button.CornerRadius = UDim.new(0.3, 0)
    UICorner_Button.Parent = btn
        if item.type == "button" then
            btn.MouseButton1Click:Connect(item.callback)
        elseif item.type == "toggle" then
            local toggled = false
            btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                btn.BackgroundColor3 = toggled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 200, 200)
                if toggled then
                    item.on()
                else
                    item.off()
                end
            end)
        end
    end
end

PageLeft.MouseButton1Click:Connect(function()
    if currentPage > 1 then
        currentPage = currentPage - 1
        renderPage(currentPage)
    end
end)

PageRight.MouseButton1Click:Connect(function()
    if currentPage < math.ceil(#buttons / itemsPerPage) then
        currentPage = currentPage + 1
        renderPage(currentPage)
    end
end)

renderPage(currentPage)


--Dragging

local function Update(input)
    local delta = input.Position - DragStart
    MainFrame.Position = UDim2.new(
        StartPos.X.Scale, 
        StartPos.X.Offset + delta.X,
        StartPos.Y.Scale, 
        StartPos.Y.Offset + delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        Update(input)
    end
end)


--MyAimbot
local fov = 100

local FOVring = Drawing.new("Circle")
FOVring.Visible = true
FOVring.Thickness = 2
FOVring.Color = Color3.fromRGB(128, 0, 128) -- Purple color
FOVring.Filled = false
FOVring.Radius = fov
FOVring.Position = Cam.ViewportSize / 2

local function updateDrawings()
    local camViewportSize = Cam.ViewportSize
    FOVring.Position = camViewportSize / 2
end

local function onKeyDown(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        RunService:UnbindFromRenderStep("FOVUpdate")
        FOVring:Remove()
    end
end

UserInputService.InputBegan:Connect(onKeyDown)

local function lookAt(target)
    local offset = Vector3.new(0, 0.3, 0)
    local realTarget = target - offset
    local lookVector = (realTarget - Cam.CFrame.Position).unit
    local newCFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)
    Cam.CFrame = newCFrame
end

--and player.Team ~= Players.LocalPlayer.Team Team Check Thing

local function getClosestPlayerInFOV(trg_part)
    local nearest = nil
    local last = math.huge
    local playerMousePos = Cam.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local part = player.Character and player.Character:FindFirstChild(trg_part)
            if part then

                local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)

                local distance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude

                local health = part.Parent:FindFirstChildOfClass("Humanoid").Health

                local obscuringParts = Cam:GetPartsObscuringTarget({part.Position}, player.Character:GetDescendants())

                if teamCheck then
                if distance < last and isVisible and #obscuringParts == 0 and health > 0 and player.Team ~= Players.LocalPlayer.Team and distance < fov then
                    last = distance
                    nearest = player
                end
                else 
                if distance < last and isVisible and #obscuringParts == 0 and health > 0 and distance < fov then
                    last = distance
                    nearest = player
                end
                end
            end
        end
    end

    return nearest
end

RunService.RenderStepped:Connect(function()
    updateDrawings()
    if abEnabled then 
    
    local closest = getClosestPlayerInFOV("Head")
    
    if closest and
        closest.Character:FindFirstChild("Head") then 
                lookAt(closest.Character.Head.Position)
      end
    end
 end)





--SomeTeleportBypass
--local teleport = TweenService:Create(game.Players.LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(how much time it takes to reach there), {CFrame = CFrame.new(place)})
--teleport:Play()



--AntiKick

--// Loaded check

if getgenv().ED_AntiKick then
	return
end

--// Variables

local cloneref = cloneref or function(...) 
	return ...
end

local clonefunction = clonefunction or function(...)
	return ...
end

local SetCore = clonefunction(StarterGui.SetCore)
--local GetDebugId = clonefunction(game.GetDebugId)
local FindFirstChild = clonefunction(game.FindFirstChild)

local CompareInstances = (CompareInstances and function(Instance1, Instance2)
		if typeof(Instance1) == "Instance" and typeof(Instance2) == "Instance" then
			return CompareInstances(Instance1, Instance2)
		end
	end)
or
function(Instance1, Instance2)
	return (typeof(Instance1) == "Instance" and typeof(Instance2) == "Instance")-- and GetDebugId(Instance1) == GetDebugId(Instance2)
end

local CanCastToSTDString = function(...)
	return pcall(FindFirstChild, game, ...)
end

--// Global Variables

getgenv().ED_AntiKick = {
	Enabled = true, -- Set to false if you want to disable the Anti-Kick.
	SendNotifications = true, -- Set to true if you want to get notified for every event.
	CheckCaller = true -- Set to true if you want to disable kicking by other user executed scripts.
}

--// Main

local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
	local self, message = ...
	local method = getnamecallmethod()

	return OldNamecall(...)
end))

local OldFunction; OldFunction = hookfunction(LocalPlayer.Kick, function(...)
	local self, Message = ...
end)


--AntiCheatBypasses

--//bypass adonis--//
local debugMode = true

--// Cache

local getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, lower, gsub, match = getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, string.lower, string.gsub, string.match

local function isAdonisAC(table) -- basic stupid checks
    return rawget(table, "Detected") and typeof(rawget(table, "Detected")) == "function" and rawget(table, "RLocked")
end
local function dwarn(func, ...)
    if debugMode then
        --print("debug mode enable")
        func(...)
    end
end

dwarn(warn, "------------------------------")

for _, v in next, getgc(true) do
    if typeof(v) == "table" and isAdonisAC(v) then
        dwarn(warn, "uwu")
        for i, v in next, v do
            dwarn(print, i, typeof(v))
            if rawequal(i, "Detected") then
                dwarn(warn, "^^^^^^^")
                local old;
                old = hookfunction(v, function(action, info, nocrash)
                    if rawequal(action, "_") and rawequal(info, "_") and rawequal(nocrash, true) then
                        -- warn("checkup")
                        return old(action, info, nocrash)
                    end
                    dwarn(warn, "detected for :", action, info, nocrash)
                    return task.wait(9e9)
                end)
            end
        end
    end
end

warn("bypassed adonis ac")
--//Bypass//--
local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if not checkcaller() then
        local func = getnamecallmethod()
        local cScript = getcallingscript()
        local args = {...}
        if rawequal(func, "FireServer") and tonumber(self) then
            warn(self.Name)
            return wait(9e9)
    
        end
    end
    return old(self, ...)
end))

local ACS = {"Anti", "anti", "Ac", "Anti-Cheat", "Anti Cheat", "AC", "ANTI Cheat", "AntiFly", "AntiSpeed", "AntiTP", "AntiTeleport", "AntiDex", "AntiDEX", "AntiFlight", "Anti Remote", "Anti Remote Manipulation"}
local ignore = {"Animate", "Animation", "Attacks", "Bite", "Ability", "Abilities"}

while true do
    local work = game.Workspace:GetDescendants()
    for _, v in pairs(work) do
        if v:IsA("LocalScript") then
            local shouldIgnore = false
            for _, ignoreName in pairs(ignore) do
                if string.find(v.Name, ignoreName) then
                    shouldIgnore = true
                    break
                end
            end
            
            if not shouldIgnore then
                for _, acsName in pairs(ACS) do
                    if string.find(v.Name, acsName) then
                        -- Destroy the LocalScript
                        v:Destroy()

                        -- Print the directory (parent hierarchy)
                        local directory = ""
                        local parent = v.Parent
                        while parent ~= nil do
                            directory = parent.Name .. "/" .. directory
                            parent = parent.Parent
                        end
                        directory = directory .. v.Name
                        --print("AC Detected and Destroyed: " .. v.Name .. " | AC Type = LocalScript" .. " | Searching For Other AC's...")
                        break
                    end
                end
            end
        end
    end
end
