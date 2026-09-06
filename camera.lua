local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CameraUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- CAMERA BUTTON
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(170, 60)
button.Position = UDim2.new(1, -190, 0.62, 0)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
button.BackgroundTransparency = 0.1
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 17
button.Font = Enum.Font.GothamBold
button.Text = "FREELOOK"
button.Active = true
button.Parent = gui

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 16)
buttonCorner.Parent = button

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Thickness = 2
buttonStroke.Transparency = 0.2
buttonStroke.Parent = button

-- SLIDER FRAME
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.fromOffset(240, 65)
sliderFrame.Position = UDim2.new(1, -260, 0.73, 0)
sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
sliderFrame.BackgroundTransparency = 0.1
sliderFrame.Visible = false
sliderFrame.Active = true
sliderFrame.Parent = gui

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 16)
sliderCorner.Parent = sliderFrame

local sliderStroke = Instance.new("UIStroke")
sliderStroke.Thickness = 2
sliderStroke.Transparency = 0.2
sliderStroke.Parent = sliderFrame

-- SLIDER TEXT
local sliderText = Instance.new("TextLabel")
sliderText.Size = UDim2.new(1, 0, 0, 25)
sliderText.BackgroundTransparency = 1
sliderText.TextColor3 = Color3.new(1, 1, 1)
sliderText.TextSize = 15
sliderText.Font = Enum.Font.GothamBold
sliderText.Text = "Camera Distance: 8"
sliderText.Parent = sliderFrame

-- SLIDER BAR
local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(1, -30, 0, 8)
sliderBar.Position = UDim2.new(0, 15, 0, 43)
sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
sliderBar.BorderSizePixel = 0
sliderBar.Active = true
sliderBar.Parent = sliderFrame

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = sliderBar

-- SLIDER KNOB
local knob = Instance.new("TextButton")
knob.Size = UDim2.fromOffset(22, 22)
knob.Position = UDim2.new(0.294, -11, 0.5, -11)
knob.BackgroundColor3 = Color3.new(1, 1, 1)
knob.Text = ""
knob.BorderSizePixel = 0
knob.Active = true
knob.Parent = sliderBar

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob

-- CAMERA MODES
local mode = 1

local MIN_DISTANCE = 3
local MAX_DISTANCE = 20
local distance = 8

-- CHARACTER
local function getHumanoid()
	local character = player.Character

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

-- LOCAL ONLY TRANSPARENCY
local function setTransparency(value)
	local character = player.Character

	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.LocalTransparencyModifier = value
		elseif object:IsA("Decal") then
			object.LocalTransparencyModifier = value
		end
	end
end

-- CAMERA
local function updateCamera()
	local humanoid = getHumanoid()

	if not humanoid then
		return
	end

	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = humanoid

	if mode == 1 then

		player.CameraMode = Enum.CameraMode.Classic
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 128

		setTransparency(0)

		sliderFrame.Visible = false
		button.Text = "FREELOOK"

	elseif mode == 2 then

		player.CameraMode = Enum.CameraMode.Classic
		player.CameraMinZoomDistance = distance
		player.CameraMaxZoomDistance = distance

		-- Nur für dich sichtbar
		setTransparency(0.35)

		sliderFrame.Visible = true
		button.Text = "THIRD PERSON"

	elseif mode == 3 then

		player.CameraMode = Enum.CameraMode.LockFirstPerson
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 0.5

		setTransparency(0)

		sliderFrame.Visible = false
		button.Text = "FIRST PERSON"
	end
end

-- CHANGE MODE
button.Activated:Connect(function()
	mode = mode + 1

	if mode > 3 then
		mode = 1
	end

	updateCamera()
end)

-- SLIDER
local function setSlider(positionX)
	local startX = sliderBar.AbsolutePosition.X
	local width = sliderBar.AbsoluteSize.X

	if width <= 0 then
		return
	end

	local percent = (positionX - startX) / width
	percent = math.clamp(percent, 0, 1)

	distance = MIN_DISTANCE + ((MAX_DISTANCE - MIN_DISTANCE) * percent)
	distance = math.round(distance)

	knob.Position = UDim2.new(
		percent,
		-11,
		0.5,
		-11
	)

	sliderText.Text = "Camera Distance: " .. distance

	if mode == 2 then
		player.CameraMinZoomDistance = distance
		player.CameraMaxZoomDistance = distance
	end
end

local sliderDragging = false

local function beginSlider(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		sliderDragging = true
		setSlider(input.Position.X)
	end
end

knob.InputBegan:Connect(beginSlider)
sliderBar.InputBegan:Connect(beginSlider)

UserInputService.InputChanged:Connect(function(input)
	if not sliderDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		setSlider(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		sliderDragging = false
	end
end)

-- DRAGGABLE UI
local function makeDraggable(object)
	local dragging = false
	local dragStart
	local startPosition

	object.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = object.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			local delta = input.Position - dragStart

			object.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false
		end
	end)
end

makeDraggable(button)
makeDraggable(sliderFrame)

-- RESPAWN
player.CharacterAdded:Connect(function()
	task.wait(1)
	updateCamera()
end)

updateCamera()