local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CameraUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")
local button = Instance.new("TextButton")
button.Name = "CameraButton"
button.Size = UDim2.fromOffset(170, 60)
button.Position = UDim2.new(1, -190, 0.75, 0)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
button.BackgroundTransparency = 0.1
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 17
button.Font = Enum.Font.GothamBold
button.Text = "FREELOOK"
button.Active = true
button.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = button
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Transparency = 0.2
stroke.Parent = button
-- 1 = Freelook
-- 2 = Third Person
-- 3 = First Person
local mode = 1
local THIRD_PERSON_DISTANCE = 8
local function getHumanoid()
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end
local function setCameraMode()
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
		button.Text = "FREELOOK"
	elseif mode == 2 then
		-- LOCKED THIRD PERSON
		player.CameraMode = Enum.CameraMode.Classic
		player.CameraMinZoomDistance = THIRD_PERSON_DISTANCE
		player.CameraMaxZoomDistance = THIRD_PERSON_DISTANCE
		button.Text = "THIRD PERSON"
	elseif mode == 3 then
		-- LOCKED FIRST PERSON
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 0.5
		button.Text = "FIRST PERSON"
	end
end
button.Activated:Connect(function()
	mode += 1
	if mode > 3 then
		mode = 1
	end
	setCameraMode()
end)
player.CharacterAdded:Connect(function()
	task.wait(1)
	setCameraMode()
end)
-- MOBILE DRAG
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
setCameraMode()