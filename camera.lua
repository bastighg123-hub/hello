local Players = game:GetService(“Players”)
local UserInputService = game:GetService(“UserInputService”)

local player = Players.LocalPlayer

local gui = Instance.new(“ScreenGui”)
gui.Name = “CameraUI”
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild(“PlayerGui”)

– CAMERA BUTTON

local button = Instance.new(“TextButton”)
button.Name = “CameraButton”
button.Size = UDim2.fromOffset(170, 60)
button.Position = UDim2.new(1, -190, 0.65, 0)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
button.BackgroundTransparency = 0.1
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 17
button.Font = Enum.Font.GothamBold
button.Text = “FREELOOK”
button.Active = true
button.Parent = gui

local corner = Instance.new(“UICorner”)
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = button

local stroke = Instance.new(“UIStroke”)
stroke.Thickness = 2
stroke.Transparency = 0.2
stroke.Parent = button

– SLIDER

local sliderFrame = Instance.new(“Frame”)
sliderFrame.Name = “DistanceSlider”
sliderFrame.Size = UDim2.fromOffset(220, 55)
sliderFrame.Position = UDim2.new(1, -240, 0.75, 0)
sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
sliderFrame.BackgroundTransparency = 0.1
sliderFrame.Visible = false
sliderFrame.Parent = gui

local sliderCorner = Instance.new(“UICorner”)
sliderCorner.CornerRadius = UDim.new(0, 14)
sliderCorner.Parent = sliderFrame

local sliderStroke = Instance.new(“UIStroke”)
sliderStroke.Thickness = 2
sliderStroke.Transparency = 0.2
sliderStroke.Parent = sliderFrame

local sliderLabel = Instance.new(“TextLabel”)
sliderLabel.Size = UDim2.new(1, 0, 0, 22)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.new(1, 1, 1)
sliderLabel.TextSize = 14
sliderLabel.Font = Enum.Font.GothamBold
sliderLabel.Text = “Distance: 8”
sliderLabel.Parent = sliderFrame

local sliderBar = Instance.new(“Frame”)
sliderBar.Size = UDim2.new(1, -30, 0, 8)
sliderBar.Position = UDim2.new(0, 15, 0, 35)
sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = sliderFrame

local barCorner = Instance.new(“UICorner”)
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = sliderBar

local sliderButton = Instance.new(“TextButton”)
sliderButton.Size = UDim2.fromOffset(20, 20)
sliderButton.Position = UDim2.new(0, -10, 0.5, -10)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.Text = “”
sliderButton.BorderSizePixel = 0
sliderButton.Parent = sliderBar

local knobCorner = Instance.new(“UICorner”)
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = sliderButton

– CAMERA SETTINGS

local mode = 1

local MIN_DISTANCE = 3
local MAX_DISTANCE = 20
local thirdPersonDistance = 8

local function getCharacter()
return player.Character
end

local function getHumanoid()
local character = getCharacter()

if not character then
	return nil
end
return character:FindFirstChildOfClass("Humanoid")

end

– TRANSPARENCY

local function setCharacterTransparency(value)

local character = getCharacter()
if not character then
	return
end
for _, object in ipairs(character:GetDescendants()) do
	if object:IsA("BasePart") then
		object.LocalTransparencyModifier = value
	elseif object:IsA("Decal") then
		object.Transparency = value
	end
end

end

– CAMERA

local function updateCamera()

local humanoid = getHumanoid()
local camera = workspace.CurrentCamera
if not humanoid or not camera then
	return
end
camera.CameraSubject = humanoid
camera.CameraType = Enum.CameraType.Custom
if mode == 1 then
	-- FREELOOK
	player.CameraMode = Enum.CameraMode.Classic
	player.CameraMinZoomDistance = 0.5
	player.CameraMaxZoomDistance = 128
	setCharacterTransparency(0)
	sliderFrame.Visible = false
	button.Text = "FREELOOK"
elseif mode == 2 then
	-- LOCKED THIRD PERSON
	player.CameraMode = Enum.CameraMode.Classic
	player.CameraMinZoomDistance = thirdPersonDistance
	player.CameraMaxZoomDistance = thirdPersonDistance
	setCharacterTransparency(0.35)
	sliderFrame.Visible = true
	button.Text = "THIRD PERSON"
elseif mode == 3 then
	-- LOCKED FIRST PERSON
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	player.CameraMinZoomDistance = 0.5
	player.CameraMaxZoomDistance = 0.5
	setCharacterTransparency(0)
	sliderFrame.Visible = false
	button.Text = "FIRST PERSON"
end

end

– CAMERA BUTTON

button.Activated:Connect(function()

mode += 1
if mode > 3 then
	mode = 1
end
updateCamera()

end)

– SLIDER

local sliderDragging = false

local function updateSlider(inputPosition)

local barPosition = sliderBar.AbsolutePosition.X
local barSize = sliderBar.AbsoluteSize.X
local percent = (inputPosition.X - barPosition) / barSize
percent = math.clamp(percent, 0, 1)
thirdPersonDistance =
	MIN_DISTANCE + (MAX_DISTANCE - MIN_DISTANCE) * percent
thirdPersonDistance = math.round(thirdPersonDistance * 10) / 10
player.CameraMinZoomDistance = thirdPersonDistance
player.CameraMaxZoomDistance = thirdPersonDistance
sliderButton.Position = UDim2.new(
	percent,
	-10,
	0.5,
	-10
)
sliderLabel.Text =
	"Distance: " .. tostring(thirdPersonDistance)

end

sliderButton.InputBegan:Connect(function(input)

if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then
	sliderDragging = true
end

end)

UserInputService.InputChanged:Connect(function(input)

if not sliderDragging then
	return
end
if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseMovement then
	updateSlider(input.Position)
end

end)

UserInputService.InputEnded:Connect(function(input)

if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then
	sliderDragging = false
end

end)

– BUTTON DRAG

local dragging = false
local dragStart
local startPosition
local dragInput
local moved = false

button.InputBegan:Connect(function(input)

if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then
	dragging = true
	moved = false
	dragStart = input.Position
	startPosition = button.Position
	if input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end

end)

button.InputChanged:Connect(function(input)

if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseMovement then
	dragInput = input
end

end)

UserInputService.InputChanged:Connect(function(input)

if not dragging then
	return
end
if input == dragInput
	or input.UserInputType == Enum.UserInputType.MouseMovement then
	local delta = input.Position - dragStart
	if math.abs(delta.X) > 8
		or math.abs(delta.Y) > 8 then
		moved = true
	end
	button.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end

end)

UserInputService.InputEnded:Connect(function(input)

if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then
	dragging = false
end

end)

– RESPAWN

player.CharacterAdded:Connect(function()

task.wait(1)
updateCamera()

end)

updateCamera()

Third Person