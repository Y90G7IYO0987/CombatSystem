export type enemyInfo = { Character: Model, Humanoid: Humanoid, HumanoidRootPart: BasePart }

-- Services
local Debris = game:GetService("Debris")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")
const SoundService = game:GetService("SoundService")

-- Folders
const modules = ReplicatedStorage:FindFirstChild("Modules")
const combatAnimations = ReplicatedStorage:FindFirstChild("CombatAnimations")
const events = ReplicatedStorage:FindFirstChild("Events")
const swordEvents = events:FindFirstChild("SwordEvents")
const dashEvents = events:FindFirstChild("DashEvents")
const vfx = ReplicatedStorage:FindFirstChild("VFX")

-- Events
const swordStartup = swordEvents:FindFirstChild("SwordStartup")
const dashAnimate = dashEvents:FindFirstChild("DashAnimate")

-- Variables
local loadedAnimations: { [Player]: { [string]: { [string]: Animation } } } = {}
local animationsForPlaying: { [Player]: { [string]: Animation } } = {}

const isPlayingAnimations = {}

const isPlayingSounds = {}
const gettedSounds: { [string]: Sound } = {}

const gettedVfxses: { [string]: Attachment } = {}

-- SUPPORT MODULES
const swordsUniversal = require(modules:FindFirstChild("SwordsUniversal"))

local function PlaySound(soundId: string)
	if isPlayingSounds[soundId] then
		return
	end
	isPlayingSounds[soundId] = true

	local currentSound = gettedSounds[soundId]

	if not currentSound then
		print("Find sound...")

		for _, sound in SoundService:GetDescendants() do
			if not sound or not sound:IsA("Sound") or sound.SoundId ~= soundId then
				continue
			end

			gettedSounds[soundId] = sound
			currentSound = sound
		end

		if not currentSound then
			local createdSounds = {}

			for _, sound in gettedSounds do
				table.insert(createdSounds, sound)
			end

			local newSound = Instance.new("Sound", SoundService)
			newSound.SoundId = soundId
			newSound.Name = `CreatedSound{#createdSounds}`

			gettedSounds[soundId] = newSound
			currentSound = newSound
		end
	else
		print(`Optimization working for: {soundId}`)
	end

	coroutine.wrap(function()
		currentSound:Play()

		task.wait(currentSound.TimeLength)

		isPlayingSounds[soundId] = nil
	end)()
end

local function PlayAnimation(player, animationName: string)
	local playingPlayer = isPlayingAnimations[player]
	if not playingPlayer then
		isPlayingAnimations[player] = {}
	end
	local currentPlayedAnim = playingPlayer[animationName]
	if currentPlayedAnim then
		return
	end
	currentPlayedAnim = true

	local playingPlayerAnims = animationsForPlaying[player]
	if not playingPlayerAnims then
		print("Once we create a table for `animationsForPlaying`")
		animationsForPlaying[player] = {}
		playingPlayerAnims = animationsForPlaying[player]
	end

	local currentAnim: AnimationTrack = playingPlayerAnims[animationName]

	if not currentAnim then
		local loadedPlayerAnims = loadedAnimations[player]

		for folderName, animInfo: { [string]: Animation } in loadedPlayerAnims do
			local searchedAnim = animInfo[animationName]
			if not searchedAnim then
				continue
			end

			print(`Found: {animationName} from {folderName}`)

			playingPlayerAnims[animationName] = searchedAnim
			currentAnim = playingPlayerAnims[animationName]
		end
	end

	coroutine.wrap(function()
		print(`Animation: {animationName} is playing now!`)
		currentAnim:Play()
		task.wait(currentAnim.Length)
		print(`Animation: {animationName} is cleaned  into playing anims!`)
		currentPlayedAnim = nil
	end)()
end

local function CreateHitbox(radius: number, height: number, humanoidRootPart)
	local zone = Instance.new("Part")
	zone.Size = Vector3.new(radius * 1.4, height, radius * 2)
	zone.Shape = Enum.PartType.Cylinder
	zone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -radius / 2)
	zone.Anchored = true
	zone.CanCollide = false
	zone.Transparency = 0.5
	zone.Parent = workspace

	return zone
end

local function Attack(player: Player, radius: number, angle: number, height: number, damage: number)
	const character = player.Character
	const humanoidRootPart = character.HumanoidRootPart

	local hitbox = CreateHitbox(radius, height, humanoidRootPart)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }

	local parts = workspace:GetPartsInPart(hitbox, params)

	Debris:AddItem(hitbox, 0.25)

	local targets = {}
	local seen = {}

	for _, part in parts do
		local model = part:FindFirstAncestorOfClass("Model")

		if model and not seen[model] then
			local humanoid = model:FindFirstChild("Humanoid")

			if humanoid and humanoid.Health > 0 then
				seen[model] = true

				local targetHrp = model:FindFirstChild("HumanoidRootPart")

				table.insert(targets, {
					Character = model,
					Humanoid = humanoid,
					HumanoidRootPart = targetHrp,
				})
			end
		end
	end

	for _, target in targets do
		target.Humanoid:TakeDamage(damage)
	end

	return targets
end

local function AddVfx(vfxId: string, parent: Instance, aliveTime: number?, isDeletable)
	local currentVfx = gettedVfxses[vfxId]
	if not currentVfx then
		print(`Find: {vfxId} vfx.`)

		for _, attachment in vfx:GetDescendants() do
			if not attachment or not attachment:IsA("Attachment") or not attachment:GetAttribute(vfxId) then
				continue
			end

			print(`Finded: {attachment.Name} with using: {vfxId}`)

			currentVfx = attachment
			gettedVfxses[vfxId] = attachment
		end
	else
		print("Optimization working!")
	end

	local newVfx = currentVfx:Clone()
	newVfx.Parent = parent

	for _, particleEmitter in newVfx:GetChildren() do
		particleEmitter:Emit(particleEmitter:GetAttribute("EmitCount"))
	end

	if not isDeletable then
		Debris:AddItem(newVfx, aliveTime)
	end
end

local function EnemyDeath(info: enemyInfo)
	print("Enemy death...")
	local head = info.Character:FindFirstChild("Head")
	local upperTorso = info.Character:FindFirstChild("UpperTorso")
	local headBleedingId = "head-bleeding-id-035ekdeq"

	info.Humanoid.RequiresNeck = false
	info.Humanoid.BreakJointsOnDeath = false
	info.Humanoid.AutoRotate = false
	info.Humanoid.PlatformStand = false

	for _, neckAttachment in head:GetDescendants() do
		if tostring(neckAttachment):match("Neck") then
			print(`Finded: {neckAttachment.Name}`)
			neckAttachment:Destroy()
		end
	end

	for _, neckAttachment in upperTorso:GetDescendants() do
		if tostring(neckAttachment):match("Neck") then
			print(`Finded: {neckAttachment.Name}`)
			neckAttachment:Destroy()
		end
	end

	head.AssemblyLinearVelocity = Vector3.new(math.random(-5, 5), math.random(10, 20), math.random(-5, 5))
	head.AssemblyAngularVelocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))

	AddVfx(headBleedingId, upperTorso, nil, true)
end

local function Attacking(player: Player, attackTool: Tool)
	print(attackTool)

	const character = player.Character
	const humanoid = character:FindFirstChild("Humanoid")

	const startSpeed = humanoid.WalkSpeed
	const slowdownSpeed = humanoid.WalkSpeed - (humanoid.WalkSpeed * 40 / 100)

	const swordInfo = swordsUniversal.GetSwordInfo(attackTool.Name)
	local attackCount = swordInfo.StartAnimationCount
	const animationPack = swordInfo.AnimationPack
	local sounds = swordInfo.Sounds

	const vfxses = swordInfo.VFX
	const firstVfxId = vfxses[1]
	const secondVfxId = vfxses[2]

	local currentPlayerAnims = loadedAnimations[player]
	local currentAnimPack = currentPlayerAnims[animationPack]

	local animsAmount = {}

	for animName, _ in currentAnimPack do
		table.insert(animsAmount, animName)
	end

	local attackingDebounce = false
	local slowdownDebounce = false
	local accelerationDebounce = false
	local attackDebounce = false

	local debounceTime = 0.9

	local currentCount = attackCount

	local playerPlayingAnims = isPlayingAnimations[player]

	if not playerPlayingAnims then
		isPlayingAnimations[player] = {}
		playerPlayingAnims = isPlayingAnimations[player]
	end

	attackTool.Activated:Connect(function()
		if attackingDebounce or playerPlayingAnims[tostring(currentCount)] then
			print("CANT ATTACK!")
			return
		end
		attackingDebounce = true
		playerPlayingAnims[tostring(currentCount)] = true

		task.delay(debounceTime, function()
			attackingDebounce = false
		end)

		PlaySound(sounds.SwingSound)

		local currentAnim = currentAnimPack[tostring(currentCount)]
		currentAnim:Play()

		if currentCount < #animsAmount then
			currentCount += 1
		else
			currentCount = attackCount
		end

		print(currentCount)

		currentAnim:GetMarkerReachedSignal("Slowdown"):Connect(function()
			if slowdownDebounce then
				return
			end
			slowdownDebounce = true
			task.delay(debounceTime, function()
				slowdownDebounce = false
			end)

			humanoid.WalkSpeed = slowdownSpeed

			print("Slowdown...")
		end)

		currentAnim:GetMarkerReachedSignal("Acceleration"):Connect(function()
			if accelerationDebounce then
				return
			end
			accelerationDebounce = true
			task.delay(debounceTime, function()
				accelerationDebounce = false
			end)

			humanoid.WalkSpeed = startSpeed

			print("Acceleration...")
		end)

		currentAnim:GetMarkerReachedSignal("Attack"):Connect(function()
			if attackDebounce then
				return
			end
			attackDebounce = true
			task.delay(debounceTime, function()
				attackDebounce = false
			end)

			AddVfx(firstVfxId, attackTool, 0.35)

			local targets = Attack(player, 12, 140, 5, 25)

			if #targets > 0 then
				PlaySound(sounds.HitSound)

				for _, info in targets do
					if info.Humanoid.Health > 0 then
						AddVfx(secondVfxId, info.HumanoidRootPart, 0.66)
					else
						EnemyDeath(info)
					end
				end
			end

			print("Attacking...")
		end)

		task.delay(currentAnim.Length + 0.1, function()
			print("Player Playing Anims equals nil!")
			playerPlayingAnims[currentAnim.Name] = nil
		end)
	end)
end

local function SwordStartup(player: Player, tool: Tool)
	const character = player.Character
	const humanoid = character.Humanoid

	local newSword = tool:Clone()

	newSword.Parent = character

	humanoid:EquipTool(newSword)

	Attacking(player, newSword)
end

local function PlayerAdded(player: Player)
	if not loadedAnimations[player] then
		loadedAnimations[player] = {}
	end

	if not isPlayingAnimations[player] then
		isPlayingAnimations[player] = {}
	end

	player.CharacterAdded:Connect(function(character)
		const humanoid = character:FindFirstChild("Humanoid")
		const animator = humanoid:FindFirstChild("Animator")

		for _, animation in combatAnimations:GetDescendants() do
			if (animation and animation:IsA("Animation")) and (animation.Parent and animation.Parent:IsA("Folder")) then
				if not loadedAnimations[player][animation.Parent.Name] then
					loadedAnimations[player][animation.Parent.Name] = {}
				end
				loadedAnimations[player][animation.Parent.Name][animation.Name] = animator:LoadAnimation(animation)

				print(
					`Successfuly loaded animation: {animation.Name} for player: {player.Name} from {animation.Parent.Name}`
				)
			end
		end
	end)
end

swordStartup.OnServerEvent:Connect(function(player, attackTool)
	SwordStartup(player, attackTool)
end)

dashAnimate.OnServerEvent:Connect(function(player, animationName)
	PlayAnimation(player, animationName)
end)

Players.PlayerAdded:Connect(PlayerAdded)
