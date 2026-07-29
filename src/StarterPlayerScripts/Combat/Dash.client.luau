export type instantiateBodyVelocity = {
	vectorName: string,
	speed: number,
	maxForce: Vector3,
	interactiveObject: BasePart,
}

-- Services
const UserInputService = game:GetService("UserInputService")
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
const events = ReplicatedStorage:FindFirstChild("Events")
const dashEvents = events:FindFirstChild("DashEvents")
const dashAnimate = dashEvents:FindFirstChild("DashAnimate")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart: BasePart = character:FindFirstChild("HumanoidRootPart")

const animationNames = {
	W = "Front",
	A = "Left",
	S = "Back",
	D = "Right",
}

local dashAnimationKeys = {
	[Enum.KeyCode.W] = { vector = "LookVector", speed = 1 },
	[Enum.KeyCode.A] = { vector = "RightVector", speed = -1 },
	[Enum.KeyCode.S] = { vector = "LookVector", speed = -1 },
	[Enum.KeyCode.D] = { vector = "RightVector", speed = 1 },
}

const dashTime = 3
const deleteBvTime = 0.3
local dashDebounce = false

const maxDashForce = Vector3.new(1e6, 0, 1e6)

const dashSpeed = 60

local function Loader()
	character = player.Character
	humanoidRootPart = character.HumanoidRootPart
end

local function CreateBodyVelocity(info: instantiateBodyVelocity): BodyVelocity
	local interactiveObject = info.interactiveObject
	local vectorName = info.vectorName
	local speed = info.speed

	local newBody = Instance.new("BodyVelocity", interactiveObject)

	newBody.MaxForce = info.maxForce
	newBody.Velocity = interactiveObject.CFrame[vectorName] * speed

	return newBody
end

local function PlayAnimation(animationName: string)
	dashAnimate:FireServer(animationName)
end

local function GetPressedKey(): (Enum.KeyCode, { vector: string, speed: number })
	local key, info

	for keyCode, data in dashAnimationKeys do
		if UserInputService:IsKeyDown(keyCode) then
			key = keyCode
			info = data
		end
	end

	return key, info
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Q then
		if dashDebounce then
			print("Cannot do this yet!")
			return
		end
		dashDebounce = true

		Loader()

		local bodyVelocity: BodyVelocity

		local downedKeyCode = "W"
		local pressedKey, data = GetPressedKey()

		if pressedKey and data then
			print(`Custom animation for -> {pressedKey.Name}, Speed -> {data.speed}, Direction -> {data.vector}`)
			bodyVelocity = CreateBodyVelocity({
				vectorName = data.vector,
				speed = dashSpeed * data.speed,
				maxForce = maxDashForce,
				interactiveObject = humanoidRootPart,
			})
		else
			print("Default animation ->")
			bodyVelocity = CreateBodyVelocity({
				vectorName = "LookVector",
				speed = dashSpeed,
				maxForce = maxDashForce,
				interactiveObject = humanoidRootPart,
			})
		end

		downedKeyCode = pressedKey and pressedKey.Name or downedKeyCode
		local animName = animationNames[downedKeyCode]

		print(`Anim Name -> {animName}`)

		PlayAnimation(animName)

		task.delay(dashTime, function()
			if dashDebounce then
				dashDebounce = false
			end
		end)

		task.delay(deleteBvTime, function()
			bodyVelocity:Destroy()
		end)
	end
end)
