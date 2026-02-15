--!nocheck
local _Config = { --// Example config
	Targets = { --// One or more target(s), write usernames in quotations (ex: { "newandreformedlyth", "PS2_Ports" })
		"newandreformedlyth"
	},

	GIVE_BOATS = 2, --// 0 = None | 1 = All boats (non-dev) | 2 = All boats
	GIVE_BOBBERS = 2, --// 0 = None | 1 = All bobbers (non-dev) | 2 = All bobbers
	GIVE_HALOS = 2, --// 0 = None | 1 = All halos (non-dev) | 2 = All halos
	GIVE_LANTERNS = 2, --// 0 = None | 1 = All lanterns (non-dev) | 2 = All lanterns
	GIVE_ROD_SKINS = 2, --// 0 = None | 1 = All rod skins (non-dev) | 2 = All rod skins
	GIVE_RODS = 2, --// 0 = None | 1 = All rods (registered only) | 2 = All rods
	GIVE_SPEARS = 2, --// 0 = None | 1 = All spears (non-dev) | 2 = All spears
	GIVE_TITLES = 2, --// 0 = None | 1 = All titles (non-dev) | 2 = All titles
}

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Constants
local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
local library = require(ReplicatedStorage.shared.modules.library)

--// Types
type Folder = Instance
type Player = Instance

--// Functions
local Modules = {
	["GIVE_BOATS"] = function(player: Player, playerStats: Folder, playerProfile: {[any]: any}, level: number)
		if level == 0 then return end

		local vessels = require(ReplicatedStorage.shared.modules.vessels)

		for name, data in vessels.library do
			if typeof(name) ~= "string" or typeof(data) ~= "table" then continue end
			if level == 1 and data.DEV then continue end

			if not vessels:Has(player, name) then
				vessels:Give(player, name, 1)
			end
		end
	end,

	["GIVE_BOBBERS"] = function(player: Player, playerStats: Folder, playerProfile: {[any]: any}, level: number)
		if level == 0 then return end

		local bobbers = require(ReplicatedStorage.shared.modules.fishing.bobbers)

		for name, data in bobbers.Bobbers do
			if typeof(name) ~= "string" or typeof(data) ~= "table" then continue end
			if level == 1 and data.Untradeable then continue end --// No DEV tag for bobbers, but all dev bobbers are untradeable

			if not bobbers:Owns(player, name) then
				bobbers:Give(player, name)
			end
		end
	end,

	["GIVE_HALOS"] = function(player: Player, playerStats: Folder, playerProfile: {[any]: any}, level: number)
		if level == 0 then return end

		local HaloService = require(ServerScriptService.server.legacyServices.HaloService)

		for name, data in library.halos do
			if typeof(name) ~= "string" or typeof(data) ~= "table" then continue end
			if level == 1 and data.DEV then continue end --// Not actually in use yet, but this will probably be the tag

			if not HaloService:Has(player, name) then
				HaloService:Give(player, name)
			end
		end
	end,

	["GIVE_LANTERNS"] = function(player: Player, playerStats: Folder, playerProfile: {[any]: any}, level: number)
		if level == 0 then return end

		local LanternService = require(ServerScriptService.server.legacyServices.LanternService)

		for name, data in library.lanterns do
			if typeof(name) ~= "string" or typeof(data) ~= "table" then continue end
			if level == 1 and data.DEV then continue end

			if not LanternService:Has(player, name) then
				LanternService:Give(player, name)
			end
		end
	end,

	["GIVE_ROD_SKINS"] = function(player: Player, playerStats: Folder, playerProfile: {[any]: any}, level: number)
		if level == 0 then return end

		local RodSkins = require(ReplicatedStorage.shared.modules.RodSkins)
		local skinInventory = playerProfile.Data.NewFormat.RodSkins

		for name, data in RodSkins.Skins do
			if typeof(name) ~= "string" or typeof(data) ~= "table" then continue end
			if level == 1 and data.Untradeable then continue end --// No DEV tag for skins, but all dev skins are untradeable

			if not skinInventory[name] or skinInventory[name].stack <= 0 then --// Just in case
				skinInventory[name] = { stack = 1 }

				--// Anno not built in
				ReplicatedStorage.events.anno_thought:FireClient(player, `Received <b><font color="#{(RodSkins.Rarities[data.Rarity].Color):ToHex() or Color3.fromRGB(255, 255, 255):ToHex()}">{name}</font></b> (Rod Skin)`)
			end
		end
	end,

	["GIVE_RODS"] = function(player: Player, playerStats: Folder, playerProfile: {[any]: any}, level: number)
		if level == 0 then return end

		local fishing = require(ReplicatedStorage.shared.modules.fishing)

		local exclusionList = {
			"Amygdala",
			"Debug Rod",
			"Hubert Rod",
			"Illumina",
		}

		for name, data in library.rods do
			if typeof(name) ~= "string" or typeof(data) ~= "table" then continue end
			if level == 1 and data.Unregistered then continue end
			if table.find(exclusionList, name) then continue end

			fishing:GiveRodItem(player, name, true)
		end
	end,

	["GIVE_SPEARS"] = function(player: Player, playerStats: Folder, playerProfile: {[any]: any}, level: number)
		if level == 0 then return end

		local SpearFishing = require(ServerScriptService.server.legacyServices.SpearFishing)
		local spearInventory = playerStats.Spears

		for name, data in library.spears do
			if typeof(name) ~= "string" or typeof(data) ~= "table" then continue end
			if level == 1 and data.DEV then continue end --// Not actually in use yet, but this will probably be the tag

			if not spearInventory:FindFirstChild(name) then
				SpearFishing:GiveSpear(player, name, true)
			end
		end
	end,

	["GIVE_TITLES"] = function(player: Player, playerStats: Folder, playerProfile: {[any]: any}, level: number)
		if level == 0 then return end

		local titles = require(ReplicatedStorage.shared.modules.character.titles)

		for name, data in titles do
			if typeof(name) ~= "string" or typeof(data) ~= "table" then continue end
			if level == 1 and data.Exclusive then continue end

			if not titles:Has(player, name) then
				titles:Give(player, name, false)
			end
		end
	end,

} :: { [string]: (Player, Folder, {[any]: any}, number) -> () }

--// Main
return function(Config)
	assert(typeof(Config) == "table" and next(Config), "Please pass a valid config in the function.")
	assert(typeof(Config.Targets) == "table" and next(Config.Targets), "Please include a valid table list with at least one username. (Targets: { string })")

	for _, playerName: string in Config.Targets do
		local player: any = Players:FindFirstChild(playerName)
		if typeof(player) ~= "Instance" then
			warn(`[Restore Tool]: Player {playerName} not found, skipping...`)
			continue
		else
			warn(`[Restore Tool]: Starting process for player {playerName}...`)
		end

		local playerStats, playerProfile = legacyPlayerData.forPlayer(player)
		if typeof(playerStats) ~= "Instance" or typeof(playerProfile) ~= "table" then
			warn(`[Restore Tool]: Error while fetching data for player {playerName}, skipping...`)
			continue
		end

		for moduleName, func in Modules do
			local level = Config[moduleName]
			if typeof(level) ~= "number" or not table.find({0, 1, 2}, level) then
				warn(`[Restore Tool]: Invalid level for {moduleName} ({level}), skipping...`)
				continue
			end

			func(player, playerStats, playerProfile, level)
		end

		warn(`[Restore Tool]: Finished process for player {playerName}.`)
	end
end
