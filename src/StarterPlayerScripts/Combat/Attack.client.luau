-- Services //
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

-- Folders
const swords = ReplicatedStorage:FindFirstChild("Swords")
const events = ReplicatedStorage:FindFirstChild("Events")
const swordEvents = events:FindFirstChild("SwordEvents")

-- Events
const swordStartup = swordEvents:FindFirstChild("SwordStartup")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid")

-- ============================================================
-- LOADER
-- ============================================================

if not game:IsLoaded() then
	game.Loaded:Wait()
end

repeat
	task.wait()
until character and humanoid

print(swords, typeof(swords))

-- ============================================================
-- LOADER
-- ============================================================

local function Loader()
	character = player.Character
	humanoid = character.Humanoid
end

Loader()

local function GetSwordByName(swordName: string): Tool?
	local currentSword = swords:FindFirstChild(swordName)
	if not currentSword then
		print(`Not found sword: {swordName} in swords folder!`)
		return
	end

	return currentSword
end

local function SwordStartup(attackTool)
	swordStartup:FireServer(attackTool)
end

local function PutSwordToCharacter(sword: Tool)
	if not sword then
		print("You need get the sword to continue!")
	end

	Loader()

	SwordStartup(sword)

	print(`Successfuly putted: {sword.Name} to {player.Name}`)
end

local purpleKatana = GetSwordByName("Purple Katana")

PutSwordToCharacter(purpleKatana)
