local swordsUniversal = {}

local swordsInfo = {
	["Purple Katana"] = {
		Name = "Purple Katana",
		AnimationPack = "KatanaAnims",
		StartAnimationCount = 1,
		Sounds = {
			SwingSound = "rbxassetid://608537390",
			HitSound = "rbxassetid://566593606",
		},
		VFX = {
			[1] = "purple-slash-id-01xde1e",
			[2] = "purple-burst-id-01xde1e",
		},
	},
}

function swordsUniversal.GetSwordInfo(swordName: string): {
	Name: string,
	AnimationPack: string,
	StartAnimationCount: number,
	Sounds: { SwingSound: string, HitSound: string },
	VFX: { [number]: string },
}?
	if not swordName or type(swordName) ~= "string" then
		print("We need correct swordName")
		return
	end

	local swordInfo = swordsInfo[swordName]
	if not swordInfo then
		print(`Not found info about: {swordName} sword.`)
		return
	end

	print(`Successfuly found info about: {swordName} sword.`)

	return swordInfo
end

return swordsUniversal
