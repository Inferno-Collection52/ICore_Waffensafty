if not Config then
	Config = {}
end

-- Key mapping table for resolving human-friendly key names (e.g. "E", "C")
local KeyMap = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249,
	["M"] = 244, [","] = 82, ["."] = 81, ["LEFTSHIFT"] = 21, ["LCTRL"] = 36, ["LALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

-- Resolve string keys to numeric control codes when necessary
if type(Config.SelectorKey) == "string" then
	local key = string.upper(tostring(Config.SelectorKey))
	if KeyMap[key] then
		Config.SelectorKey = KeyMap[key]
	else
		local n = tonumber(Config.SelectorKey)
		if n then Config.SelectorKey = n end
	end
end


-- Fire mode variables
local FireMode = {}
-- Weapons the client currently has
FireMode.Weapons = {}
-- Weapons the client currently has with flashlights on
FireMode.WeaponFlashlights = {}
-- Last weapon in use
FireMode.LastWeapon = false
-- Last weapon in use with flashlight
FireMode.LastWeaponFlashlight = false
-- Last weapon type in use
FireMode.LastWeaponActive = false
-- Is shooting currently disabled?
FireMode.ShootingDisable = false
-- Is the client reloading?
FireMode.Reloading = false
-- Amount of time to limp for
FireMode.Limp = -1

-- Flashlight variables
local Flashlights = {}
-- All flashlights from all players, synced
Flashlights.All = {}
-- Flashlight component IDs and position vectors
Flashlights.Hashes = {
	COMPONENT_AT_AR_FLSH = {
		vector3(0.5, 0.03, 0.05),
		vector3(1.0, -0.16, 0.145)
	},
	COMPONENT_AT_PI_FLSH = {
		vector3(0.28, 0.04, 0.0),
		vector3(1.0, -0.12, 0.03)
	},
	COMPONENT_AT_PI_FLSH_02 = {
		vector3(0.28, 0.04, 0.0),
		vector3(1.0, -0.135, 0.03)
	},
	COMPONENT_AT_PI_FLSH_03 = {
		vector3(0.28, 0.04, 0.0),
		vector3(1.0, -0.135, 0.03)
	}
}

-- When the player spawns (or respawns after death)
AddEventHandler("playerSpawned", function ()
	-- Remove all blood effects
	-- Does no seems to work 100% of the time, reason unclear.
	ClearPedBloodDamage(PlayerPedId())
	-- Remove all weapons stored
	FireMode.Weapons = {}
	-- Reenable shooting
	FireMode.ShootingDisable = false
	-- Enable reloading
	FireMode.Reloading = false
	-- Remove last weapon
	FireMode.LastWeapon = false
	-- Remove last weapon type
	FireMode.LastWeaponActive = false
	-- Remove all active local flashlights
	TriggerServerEvent("Weapons:Server:Toggle", false)
	FireMode.WeaponFlashlights = {}
end)

-- Resource master loop
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local PlayerId = PlayerId()
		local PlayerPed = PlayerPedId()

		-- Is the player armed with any gun
		if IsPedArmed(PlayerPed, 4) and not IsPedInAnyVehicle(PlayerPed, true) then
			local Active = false
			local PedWeapon = GetSelectedPedWeapon(PlayerPed)

			-- If last weapon used is not still in use
			if FireMode.LastWeapon ~= PedWeapon then
				-- Loop though all the semi-automatic weapons
				for _, Weapon in ipairs(Config.Weapons.Single) do
					-- If weapon is in list
					if GetHashKey(Weapon) == PedWeapon then
						-- Set weapon type to semi-automatic
						Active = "single"
						goto WeaponIdLoop
					end
				end

				-- If weapon was not found in semi-automatic loop
				if not Active then
					-- Loop though all full weapons
					for _, Weapon in ipairs(Config.Weapons.Full) do
						-- If weapon is in list
						if GetHashKey(Weapon) == PedWeapon then
							-- Set weapon type to full
							Active = "full"
							goto WeaponIdLoop
						end
					end
				end

				-- If weapon was not found in full auto loop
				if not Active and Config.EnableReticle then
					-- Loop though all the weapons that require a reticle
					for _, Weapon in ipairs(Config.Weapons.Reticle) do
						-- If weapon is in list
						if GetHashKey(Weapon) == PedWeapon then
							-- Set weapon type to reticle
							Active = "reticle"
							goto WeaponIdLoop
						end
					end
				end

				::WeaponIdLoop::

				-- If weapon not in any list
				if not Active then
					-- Remove last weapon type
					FireMode.LastWeaponActive = false
				-- If weapon was in a list
				else
					-- Save weapon
					FireMode.LastWeapon = PedWeapon
					-- Save weapon type
					FireMode.LastWeaponActive = Active
				end
			-- If last weapon is still current weapon
			else
				-- Set current type to saved type
				Active = FireMode.LastWeaponActive
			end



			-- If weapon needs to be affected
			if Active and Active ~= "reticle" then
				-- If weapon is not yet logged
				if FireMode.Weapons[PedWeapon] == nil then
					-- Log to array
					if Config.StartSafe then
						FireMode.Weapons[PedWeapon] = 0
					else
						FireMode.Weapons[PedWeapon] = 1
					end
				end

				-- If fire mode selector key pressed
				if IsDisabledControlJustReleased(1, Config.SelectorKey) then
					if Active == "full" then
						if FireMode.Weapons[PedWeapon] <= 2 then
							if FireMode.Weapons[PedWeapon] == 0 then
								NewNUIMessage("NewMode", "single")
							elseif FireMode.Weapons[PedWeapon] == 1 then
								NewNUIMessage("NewMode", "burst")
							elseif FireMode.Weapons[PedWeapon] == 2 then
								NewNUIMessage("NewMode", "full_auto")
							end
							PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
							FireMode.Weapons[PedWeapon] = FireMode.Weapons[PedWeapon] + 1
						elseif FireMode.Weapons[PedWeapon] >= 3 then
							NewNUIMessage("NewMode", "safety")
							PlaySoundFrontend(-1, "Reset_Prop_Position", "DLC_Dmod_Prop_Editor_Sounds", 0)
							FireMode.Weapons[PedWeapon] = 0
						end
					else
						if FireMode.Weapons[PedWeapon] == 0 then
							NewNUIMessage("NewMode", "single")
							PlaySoundFrontend(-1, "Reset_Prop_Position", "DLC_Dmod_Prop_Editor_Sounds", 0)
							FireMode.Weapons[PedWeapon] = FireMode.Weapons[PedWeapon] + 1
						elseif FireMode.Weapons[PedWeapon] >= 1 then
							NewNUIMessage("NewMode", "safety")
							PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1)
							FireMode.Weapons[PedWeapon] = 0
						end
					end
				end

				-- If fire mode is set to safety
				if FireMode.Weapons[PedWeapon] == 0 then FireMode.ShootingDisable = true end

				local _, Ammo = GetAmmoInClip(PlayerPed, PedWeapon)
				-- If R was just pressed and client is not already reloading
				if IsDisabledControlJustPressed(1, 45) and not FireMode.Reloading then
					FireMode.Reloading = true
					FireMode.ShootingDisable = true
					if IsPlayerFreeAiming(PlayerId) then SetPlayerForcedAim(PlayerId, true) end
					Citizen.Wait(400)
					MakePedReload(PlayerPed)
					Citizen.Wait(300)
					SetPlayerForcedAim(PlayerId, false)
					FireMode.ShootingDisable = false
					FireMode.Reloading = false
				-- If they is only one bullet left in the magazine
				-- Or if the firemode is burst, and out of ammo
				elseif (Ammo == 1 and FireMode.Weapons[PedWeapon] ~= 2) or (Ammo <= 3 and FireMode.Weapons[PedWeapon] == 2) then
					FireMode.ShootingDisable = true
					-- Set the ammo in the magazine to one
					SetAmmoInClip(PlayerPed, PedWeapon, 1)
					-- If left click just pressed
					if IsDisabledControlJustPressed(1, 24) then PlaySoundFrontend(-1, "Faster_Click", "RESPAWN_ONLINE_SOUNDSET", 1) end
				-- If left click just pressed
				elseif IsDisabledControlJustPressed(1, 24) then
					-- If the fire mode is set to safety
					if FireMode.Weapons[PedWeapon] == 0 then
						PlaySoundFrontend(-1, "HACKING_MOVE_CURSOR", 0, 1)
					-- If fire mode is set to semi-automatic
					elseif FireMode.Weapons[PedWeapon] == 1 then
						-- While left click is still being held
						while IsDisabledControlPressed(1, 24) do
							-- Disable shooting (which allows for one shot to be fired)
							DisablePlayerFiring(PlayerId, true)
							Citizen.Wait(0)
						end
					-- If fire mode is set to burst
					elseif FireMode.Weapons[PedWeapon] == 2 then
						Citizen.Wait(200)
						-- While left click is still being held
						while IsDisabledControlPressed(1, 24) do
							-- Disable shooting
							DisablePlayerFiring(PlayerId, true)
							Citizen.Wait(0)
						end
					end
				-- If fire mode is not set to safety
				elseif FireMode.Weapons[PedWeapon] ~= 0 then
					FireMode.ShootingDisable = false
				end
			-- If weapon is not in any list
			else
				-- Enable shooting
				FireMode.ShootingDisable = false
			end
		-- If ped is not armed
		else
			FireMode.LastWeapon = false
			FireMode.LastWeaponActive = false
			FireMode.ShootingDisable = false
		end

	end
end)

-- Remove reticle loop
-- This is in it"s own loop to stop flickering caused by Citizen.Wait"s in other loops.
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		-- Reticle handling:
		-- If Config.EnableReticle is true, only show reticle for weapons flagged as "reticle".
		-- If Config.EnableReticle is false, always show the reticle (do not hide it).
		if Config.EnableReticle then
			if FireMode.LastWeaponActive ~= "reticle" then HideHudComponentThisFrame(14) end
		end

		-- Hide weapon icon
		HideHudComponentThisFrame(2)
		-- Hide weapon wheel stats
		HideHudComponentThisFrame(20)
		-- Hide hud weapons
		HideHudComponentThisFrame(22)
	end
end)

-- Disable shooting loop
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		while FireMode.ShootingDisable do
			DisablePlayerFiring(PlayerId(), true)

			-- Disable fire mode selector key
			DisableControlAction(0, Config.SelectorKey, true)

			-- Disable reload and pistol whip
			DisableControlAction(0, 45, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 264, true)
			Citizen.Wait(0)
		end

	end
end)

-- Disable controls while using weapon
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if FireMode.LastWeapon and FireMode.LastWeaponActive ~= "reticle" then
			-- Disable fire mode selector key
			DisableControlAction(0, Config.SelectorKey, true)

			-- Disable reload and pistol whip
			DisableControlAction(0, 45, true)
			DisableControlAction(0, 54, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 264, true)
		end

	end
end)

-- Toggle Weapon Flashlight Loop
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		-- If player has a weapon
		if FireMode.LastWeapon then
			local PlayerPed = PlayerPedId()
			local RemovedFlashlight = true

			-- Loop though all flashlights
			for Flashlight, _ in pairs(Flashlights.Hashes) do
				-- If weapon has flashlight
				if HasPedGotWeaponComponent(PlayerPed, FireMode.LastWeapon, GetHashKey(Flashlight)) then
					if not FireMode.WeaponFlashlights[FireMode.LastWeapon] then
						FireMode.WeaponFlashlights[FireMode.LastWeapon] = {Flashlight, false}
						FireMode.LastWeaponFlashlight = FireMode.LastWeapon
					end

					RemovedFlashlight = false
					break
				end
			end

			if RemovedFlashlight and FireMode.WeaponFlashlights[FireMode.LastWeapon] then
				FireMode.WeaponFlashlights[FireMode.LastWeapon] = nil
				TriggerServerEvent("Weapons:Server:Toggle", false)
			end

			if (FireMode.LastWeapon ~= FireMode.LastWeaponFlashlight) and FireMode.WeaponFlashlights[FireMode.LastWeapon] then
				TriggerServerEvent("Weapons:Server:Toggle",
					FireMode.WeaponFlashlights[FireMode.LastWeapon][2],
					FireMode.WeaponFlashlights[FireMode.LastWeapon][1],
					FireMode.LastWeapon
				)
				FireMode.LastWeaponFlashlight = FireMode.LastWeapon
			end

			-- If E just pressed
			if IsDisabledControlJustPressed(0, 54) then
				if FireMode.WeaponFlashlights[FireMode.LastWeapon] then
					-- Toggle flashlight
					FireMode.WeaponFlashlights[FireMode.LastWeapon][2] = not FireMode.WeaponFlashlights[FireMode.LastWeapon][2]

					TriggerServerEvent("Weapons:Server:Toggle",
						FireMode.WeaponFlashlights[FireMode.LastWeapon][2],
						FireMode.WeaponFlashlights[FireMode.LastWeapon][1],
						FireMode.LastWeapon
					)

					PlaySoundFrontend(-1, "COMPUTERS_MOUSE_CLICK", 0, 1)

					-- Stops spamming the button, causing network issues
					Citizen.Wait(250)
				end
			end
		end
	end
end)

-- Synced Flashlight loop
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		-- Loop though all player flashlights
		for Source, Pack in pairs(Flashlights.All) do
			local SourcePlayer = GetPlayerFromServerId(Source)
			local SourcePed = GetPlayerPed(SourcePlayer)
			local Flashlight = Pack[1]
			local Weapon = Pack[2]

			if Source and SourcePlayer and SourcePlayer and SourcePed and GetSelectedPedWeapon(SourcePed) == Weapon then
				local FlashlightVectors = Flashlights.Hashes[Flashlight]
				local FlashlightPosition = GetPedBoneCoords(SourcePed, 0xDEAD, FlashlightVectors[1])
				local FlashlightDirection = GetPedBoneCoords(SourcePed, 0xDEAD, FlashlightVectors[2])
				local DirectionVector = FlashlightDirection - FlashlightPosition
				local VectorMagnitude = Vmag2(DirectionVector)
				local FlashlightEndPosition = vector3(
					DirectionVector.x / VectorMagnitude,
					DirectionVector.y / VectorMagnitude,
					DirectionVector.z / VectorMagnitude
				)

				DrawSpotLight(FlashlightPosition, FlashlightEndPosition, 255, 255, 255, 40.0, 2.0, 2.0, 10.0, 15.0)
			end
		end
	end
end)

-- Injury loop
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local PlayerPed = PlayerPedId()

		if HasEntityBeenDamagedByAnyPed(PlayerPed) then
			ClearEntityLastDamageEntity(PlayerPed)

			RequestAnimDict("move_m@injured")
			if not HasAnimDictLoaded("move_m@injured") then
				RequestAnimDict("move_m@injured")
				while not HasAnimDictLoaded("move_m@injured") do Citizen.Wait(0) end
			end

			-- Apply random effect to ped
			ApplyPedDamagePack(PlayerPed, Config.BloodEffects[math.random(#Config.BloodEffects)], 0, 0)
			-- Set limp
			SetPedMovementClipset(PlayerPed, "move_m@injured", 5.0)
			-- Add random amount of limping time
			FireMode.Limp = FireMode.Limp + math.random(100, 200)
		end

		-- While there is still limp time remaining remove 1 tick from limp time
		if FireMode.Limp > 0 then FireMode.Limp = FireMode.Limp - 1 end

		-- When there is no limp time remaining
		if FireMode.Limp == 0 then
			-- Reset limp timer
			FireMode.Limp = -1

			-- Remove walking effect
			ResetPedMovementClipset(PlayerPed, false)
		end
	end
end)

-- Updates the synced flashlight variable
RegisterNetEvent("Weapons:Client:Return")
AddEventHandler("Weapons:Client:Return", function(NewFlashlights) Flashlights.All = NewFlashlights end)

-- NUI function
function NewNUIMessage (Type, Load)
	if Config.SelectorImages then
		SendNUIMessage({
			PayloadType = Type,
			Payload = Load
		})
	end
end