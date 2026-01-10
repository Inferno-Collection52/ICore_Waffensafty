local Config = {}

Config.SelectorKey = "E"

-- NOTE: string-to-code resolution for `Config.SelectorKey` is performed in `client.lua`.
-- The key mapping table was moved to the client because input handling is client-side.

-- Whether or not to enable selector images when changing fire modes
Config.SelectorImages = true

-- Whether weapons should start on Safety or semi-automatic
-- true = Weapons start on Safety, false = weapons start on semi-automatic
Config.StartSafe = true

-- Whether weapons listed in Config.Weapons.Reticle should enable a reticle.
-- Set to false to treat those weapons like normal weapons (no special reticle handling).
Config.EnableReticle = false

-- Weapons variables
--
-- Do not place a weapon in more than one list, or you may experience unexpected behaviour.
-- Weapons not placed in this list will behave like they do in normal GTA 5, including melee, etc.
--
Config.Weapons = {}

-- These weapons will have safety and semi-automatic modes only
Config.Weapons.Single = {
    "WEAPON_PISTOL",
    "WEAPON_PISTOL_MK2",
    "WEAPON_COMBATPISTOL",
    "WEAPON_PISTOL50",
    "WEAPON_SNSPISTOL",
    "WEAPON_SNSPISTOL_MK2",
    "WEAPON_HEAVYPISTOL",
    "WEAPON_VINTAGEPISTOL",
    "WEAPON_MARKSMANPISTOL",
    "WEAPON_REVOLVER",
    "WEAPON_REVOLVER_MK2",
    "WEAPON_DOUBLEACTION",
    "WEAPON_CERAMICPISTOL",
    "WEAPON_NAVYREVOLVER",
    "WEAPON_GADGETPISTOL",
    "WEAPON_PISTOLXM3",
    "WEAPON_FLAREGUN",
    "WEAPON_RAYPISTOL",
    "WEAPON_PUMPSHOTGUN",
    "WEAPON_PUMPSHOTGUN_MK2",
    "WEAPON_SAWNOFFSHOTGUN",
    "WEAPON_DBSHOTGUN",
    "WEAPON_HEAVYSHOTGUN",
    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_HEAVYSNIPER_MK2",
    "WEAPON_MARKSMANRIFLE",
    "WEAPON_MARKSMANRIFLE_MK2",
    "WEAPON_PRECISIONRIFLE",
    "WEAPON_MUSKET",
    "WEAPON_STUNGUN",
    "WEAPON_STUNGUN_MP"
}

-- These weapons will have safety, semi-automatic, burst shot, and full auto modes
Config.Weapons.Full = {
    "WEAPON_MICROSMG",
    "WEAPON_SMG",
    "WEAPON_SMG_MK2",
    "WEAPON_ASSAULTSMG",
    "WEAPON_MINISMG",
    "WEAPON_MACHINEPISTOL",
    "WEAPON_COMBATPDW",
    "WEAPON_TECPISTOL",
    "WEAPON_ASSAULTRIFLE",
    "WEAPON_ASSAULTRIFLE_MK2",
    "WEAPON_CARBINERIFLE",
    "WEAPON_CARBINERIFLE_MK2",
    "WEAPON_ADVANCEDRIFLE",
    "WEAPON_SPECIALCARBINE",
    "WEAPON_SPECIALCARBINE_MK2",
    "WEAPON_BULLPUPRIFLE",
    "WEAPON_BULLPUPRIFLE_MK2",
    "WEAPON_COMPACTRIFLE",
    "WEAPON_MILITARYRIFLE",
    "WEAPON_HEAVYRIFLE",
    "WEAPON_TACTICALRIFLE",
    "WEAPON_MG",
    "WEAPON_COMBATMG",
    "WEAPON_COMBATMG_MK2",
    "WEAPON_GUSENBERG",
    "WEAPON_ASSAULTSHOTGUN",
    "WEAPON_AUTOSHOTGUN",
    "WEAPON_COMBATSHOTGUN",
    "WEAPON_PUMPSHOTGUN_MK2",
    "WEAPON_APPISTOL",
    "WEAPON_RAYCARBINE",
    "WEAPON_RAYMINIGUN"
}

-- These weapons will have their reticle enabled
Config.Weapons.Reticle = {
    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_HEAVYSNIPER_MK2",
    "WEAPON_MARKSMANRIFLE",
    "WEAPON_MARKSMANRIFLE_MK2",
    "WEAPON_STUNGUN"
}

-- Effects that are randomly selected when the player takes any damage.
-- Pick and choose which effects using the list below. Remember to add ","s where needed.
Config.BloodEffects = {
    "Skin_Melee_0",
    "Useful_Bits",
    "Explosion_Med",
    "BigHitByVehicle",
    "Car_Crash_Heavy",
    "HitByVehicle",
    "BigRunOverByVehicle"
}

-- Blood Effects
-- Very small effects --
	-- Car_Crash_Light
	-- RunOverByVehicle
	-- Splashback_Torso_0
	-- Splashback_Torso_1

-- Small Effects --
	-- Skin_Melee_0
	-- Useful_Bits

-- Medium --
	-- Explosion_Med
	-- BigHitByVehicle
	-- Car_Crash_Heavy
	-- HitByVehicle
	-- BigRunOverByVehicle

-- Big --
	-- Explosion_Large
	-- Fall

_G.Config = Config

return Config
