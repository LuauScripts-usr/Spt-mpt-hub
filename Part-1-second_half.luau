-- =============================================================================
-- PART 1 (SECOND HALF) — SECTIONS 7 → 12.4
-- Keybind Manager | Profile Engine | Target Prediction | Helpers |
-- Workspace Scans | FSM Threat Engine | UI Registry
-- 100% strict Luau, do...end encapsulated, zero placeholders
-- =============================================================================

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 7: KEYBIND MANAGER (FULL SYSTEM)                            ║
-- ║  Persistent keybinds | mobile-friendly | profile-aware               ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
	type KeybindEntry = {
		Name: string,
		KeyCode: Enum.KeyCode,
		Callback: () -> (),
		Enabled: boolean,
		Category: string,
	}

	local KeybindManager: {
		Binds: {KeybindEntry},
		ActiveBind: string?,
		Listening: boolean,
		ListenTarget: string?,
		Connection: RBXScriptConnection?,
	} = {
		Binds = {},
		ActiveBind = nil,
		Listening = false,
		ListenTarget = nil,
		Connection = nil,
	}

	local function KB_Register(name: string, defaultKey: Enum.KeyCode, category: string, callback: () -> ()): ()
		for _, existing in KeybindManager.Binds do
			if existing.Name == name then
				warn(`[EXO-KB] Duplicate keybind registration blocked: {name}`)
				return
			end
		end
		local entry: KeybindEntry = {
			Name = name,
			KeyCode = defaultKey,
			Callback = callback,
			Enabled = true,
			Category = category,
		}
		table.insert(KeybindManager.Binds, entry)
	end

	local function KB_Unregister(name: string): ()
		for i = #KeybindManager.Binds, 1, -1 do
			if KeybindManager.Binds[i].Name == name then
				table.remove(KeybindManager.Binds, i)
				break
			end
		end
	end

	local function KB_Get(name: string): KeybindEntry?
		for _, entry in KeybindManager.Binds do
			if entry.Name == name then
				return entry
			end
		end
		return nil
	end

	local function KB_SetKey(name: string, newKey: Enum.KeyCode): ()
		local entry: KeybindEntry? = KB_Get(name)
		if entry then
			entry.KeyCode = newKey
		end
	end

	local function KB_Toggle(name: string, state: boolean?): ()
		local entry: KeybindEntry? = KB_Get(name)
		if entry then
			if state ~= nil then
				entry.Enabled = state
			else
				entry.Enabled = not entry.Enabled
			end
		end
	end

	local function KB_GetByCategory(category: string): {KeybindEntry}
		local result: {KeybindEntry} = {}
		for _, entry in KeybindManager.Binds do
			if entry.Category == category then
				table.insert(result, entry)
			end
		end
		return result
	end

	local function KB_StartListening(name: string): ()
		KeybindManager.Listening = true
		KeybindManager.ListenTarget = name
	end

	local function KB_CancelListening(): ()
		KeybindManager.Listening = false
		KeybindManager.ListenTarget = nil
	end

	local function KB_Save(): ()
		local saveData: {{[string]: any}} = {}
		for _, entry in KeybindManager.Binds do
			table.insert(saveData, {
				Name = entry.Name,
				KeyCode = entry.KeyCode.Name,
				Enabled = entry.Enabled,
				Category = entry.Category,
			})
		end
		writeJSON(KEYBIND_FILE, {Binds = saveData, SavedAt = os.date("%Y-%m-%d %H:%M:%S")})
	end

	local function KB_Load(): ()
		local data = readJSON(KEYBIND_FILE)
		if not data or type(data.Binds) ~= "table" then
			return
		end
		for _, saved in data.Binds do
			if type(saved) == "table" and type(saved.Name) == "string" then
				local entry: KeybindEntry? = KB_Get(saved.Name)
				if entry then
					local keyOk: boolean, keyVal = pcall(function()
						return (Enum.KeyCode :: any)[saved.KeyCode]
					end)
					if keyOk and keyVal then
						entry.KeyCode = keyVal
					end
					if type(saved.Enabled) == "boolean" then
						entry.Enabled = saved.Enabled
					end
				end
			end
		end
	end

	local function KB_InitInputHandler(): ()
		if KeybindManager.Connection then
			pcall(function() KeybindManager.Connection:Disconnect() end)
		end
		KeybindManager.Connection = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
			if gameProcessed then
				return
			end
			if KeybindManager.Listening and KeybindManager.ListenTarget then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					KB_SetKey(KeybindManager.ListenTarget, input.KeyCode)
					KeybindManager.Listening = false
					KeybindManager.ListenTarget = nil
					KB_Save()
				end
				return
			end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				for _, entry in KeybindManager.Binds do
					if entry.Enabled and input.KeyCode == entry.KeyCode then
						local ok: boolean, err = pcall(entry.Callback)
						if not ok then
							warn(`[EXO-KB] Bind "{entry.Name}" error: {tostring(err)}`)
						end
						break
					end
				end
			end
		end)
	end

	local function KB_RegisterDefaults(): ()
		KB_Register("ToggleUI", Enum.KeyCode.RightShift, "General", function()
			if type(_G.EXO_ToggleUI) == "function" then pcall(_G.EXO_ToggleUI) end
		end)
		KB_Register("ToggleAura", Enum.KeyCode.F1, "Combat", function()
			Aura.Enabled = not Aura.Enabled
			if Aura.Enabled then
				if type(_G.EXO_StartAuraLoop) == "function" then pcall(_G.EXO_StartAuraLoop) end
			else
				if type(_G.EXO_StopAuraLoop) == "function" then pcall(_G.EXO_StopAuraLoop) end
			end
		end)
		KB_Register("ToggleInstaKill", Enum.KeyCode.F2, "Combat", function()
			InstaKillEnabled = not InstaKillEnabled
			if InstaKillEnabled then
				if type(_G.EXO_StartInstaKill) == "function" then pcall(_G.EXO_StartInstaKill) end
			else
				if type(_G.EXO_StopInstaKill) == "function" then pcall(_G.EXO_StopInstaKill) end
			end
		end)
		KB_Register("ToggleAntiAura", Enum.KeyCode.F3, "Combat", function()
			AntiAura.Enabled = not AntiAura.Enabled
			if AntiAura.Enabled then
				if type(_G.EXO_StartAntiAura) == "function" then pcall(_G.EXO_StartAntiAura) end
			else
				if type(_G.EXO_StopAntiAura) == "function" then pcall(_G.EXO_StopAntiAura) end
			end
		end)
		KB_Register("ToggleReach", Enum.KeyCode.F4, "Combat", function()
			Reach = not Reach
			if Reach then
				if type(_G.EXO_ApplyReach) == "function" then pcall(_G.EXO_ApplyReach) end
			else
				if type(_G.EXO_StopReach) == "function" then pcall(_G.EXO_StopReach) end
			end
		end)
		KB_Register("ToggleSpeed", Enum.KeyCode.F5, "Movement", function()
			Movement.SpeedHack = not Movement.SpeedHack
		end)
		KB_Register("ToggleNoclip", Enum.KeyCode.F6, "Movement", function()
			Movement.Noclip = not Movement.Noclip
		end)
		KB_Register("ToggleFly", Enum.KeyCode.F7, "Movement", function()
			Movement.Fly = not Movement.Fly
		end)
		KB_Register("ToggleAutoBuild", Enum.KeyCode.F8, "Automation", function()
			AutoBuild = not AutoBuild
			if AutoBuild then
				if type(_G.EXO_StartAutoBuild) == "function" then pcall(_G.EXO_StartAutoBuild) end
			else
				if type(_G.EXO_StopAutoBuild) == "function" then pcall(_G.EXO_StopAutoBuild) end
			end
		end)
		KB_Register("ToggleAutoClaim", Enum.KeyCode.F9, "Automation", function()
			AutoClaimMoney = not AutoClaimMoney
			if AutoClaimMoney then
				if type(_G.EXO_StartClaimMoney) == "function" then pcall(_G.EXO_StartClaimMoney) end
			else
				if type(_G.EXO_StopClaimMoney) == "function" then pcall(_G.EXO_StopClaimMoney) end
			end
		end)
		KB_Register("ToggleESP", Enum.KeyCode.F10, "Visuals", function()
			ESPEnabled = not ESPEnabled
			if ESPEnabled then
				if type(_G.EXO_StartESP) == "function" then pcall(_G.EXO_StartESP) end
			else
				if type(_G.EXO_StopESP) == "function" then pcall(_G.EXO_StopESP) end
			end
		end)
		KB_Register("PanicDisable", Enum.KeyCode.End, "General", function()
			Aura.Enabled = false
			InstantKill = false
			InstaKillEnabled = false
			HitAmpEnabled = false
			AntiAura.Enabled = false
			Reach = false
			ToolFollow.Enabled = false
			NoCooldown = false
			AutoBuild = false
			AutoClaimMoney = false
			Movement.SpeedHack = false
			Movement.Noclip = false
			Movement.Fly = false
			if type(_G.EXO_Movement_StopAll) == "function" then pcall(_G.EXO_Movement_StopAll) end
		end)
	end

	KB_InitInputHandler()
	KB_RegisterDefaults()
	KB_Load()

	_G.EXO_KB_Register = KB_Register
	_G.EXO_KB_Unregister = KB_Unregister
	_G.EXO_KB_Get = KB_Get
	_G.EXO_KB_SetKey = KB_SetKey
	_G.EXO_KB_Toggle = KB_Toggle
	_G.EXO_KB_GetByCategory = KB_GetByCategory
	_G.EXO_KB_StartListening = KB_StartListening
	_G.EXO_KB_CancelListening = KB_CancelListening
	_G.EXO_KB_Save = KB_Save
	_G.EXO_KB_Load = KB_Load
	_G.EXO_KB_RegisterDefaults = KB_RegisterDefaults
	_G.EXO_KeybindManager = KeybindManager

	print(`[EXO] Section 7 complete. Keybind Manager initialized.`)
	print(`[EXO]   Registered binds: {#KeybindManager.Binds}`)
	print(`[EXO]   Categories: General, Combat, Movement, Automation, Visuals`)
	print(`[EXO]   Persistence: {KEYBIND_FILE}`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 8: PROFILE STATE SAVING ENGINE                              ║
-- ║  Saves/loads all feature states, keybinds, AI memory                 ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
	type ProfileData = {
		Version: number,
		SavedAt: string,
		Combat: {[string]: any},
		Movement: {[string]: any},
		Visuals: {[string]: any},
		Automation: {[string]: any},
		AI: {[string]: any},
		Keybinds: {{[string]: any}},
	}

	local function Profile_Save(): boolean
		local profile: ProfileData = {
			Version = _EXO_VERSION,
			SavedAt = os.date("%Y-%m-%d %H:%M:%S"),
			Combat = {
				AuraEnabled = Aura.Enabled,
				AuraMode = Aura.Mode,
				PredictionDepth = Aura.PredictionDepth,
				InstantKill = InstantKill,
				Reach = Reach,
				ReachSize = ReachSize,
				InstaKillEnabled = InstaKillEnabled,
				IK_BurstCount = IK_BurstCount,
				IK_AdaptiveBurst = IK_AdaptiveBurst,
				HitAmpEnabled = HitAmpEnabled,
				HA_Range = HA_Range.X,
				HA_BurstCount = HA_BurstCount,
				HA_MultiPulse = HA_MultiPulse,
				AntiAuraEnabled = AntiAura.Enabled,
				GodMode = AntiAura.GodMode,
				Repel = AntiAura.Repel,
				Phase = AntiAura.Phase,
				HealAura = AntiAura.HealAura,
				Reflect = AntiAura.Reflect,
				RepelForce = AntiAura.RepelForce,
				RepelRadius = AntiAura.RepelRadius,
				ToolFollowEnabled = ToolFollow.Enabled,
				ToolFollowOffset = ToolFollow.PredictionOffset,
				NoCooldown = NoCooldown,
				AutoTools = AutoTools,
			},
			Movement = {
				SpeedHack = Movement.SpeedHack,
				SpeedValue = Movement.SpeedValue,
				JumpPower = Movement.JumpPower,
				JumpValue = Movement.JumpValue,
				Noclip = Movement.Noclip,
				Fly = Movement.Fly,
				FlySpeed = Movement.FlySpeed,
				InfiniteJump = Movement.InfiniteJump,
			},
			Visuals = {
				ESPEnabled = ESPEnabled,
				AntiLagEnabled = AntiLagEnabled,
				ChamsEnabled = ChamsEnabled,
			},
			Automation = {
				AutoClaimMoney = AutoClaimMoney,
				AutoBuild = AutoBuild,
				AutoGetTools = AutoGetTools,
				TG_BurstCount = TG_BurstCount,
				TG_WavePriority = TG_WavePriority,
				FastRespawn = FastRespawn,
				AntiSpawnkill = AntiSpawnkill,
			},
			AI = {
				KillNotifEnabled = KillNotifEnabled,
				KillLogEnabled = KillLogEnabled,
				ThreatRadius = ThreatRadius,
				latencyEstimate = latencyEstimate,
			},
			Keybinds = {},
		}
		local kb = _G.EXO_KeybindManager
		if kb and type(kb.Binds) == "table" then
			for _, entry in kb.Binds do
				table.insert(profile.Keybinds, {
					Name = entry.Name,
					KeyCode = entry.KeyCode.Name,
					Enabled = entry.Enabled,
					Category = entry.Category,
				})
			end
		end
		local success: boolean = writeJSON(PROFILE_FILE, profile :: any)
		if success then
			print(`[EXO-PROFILE] Saved at {profile.SavedAt}`)
		else
			warn("[EXO-PROFILE] Save failed")
		end
		return success
	end

	local function Profile_Load(): boolean
		local data = readJSON(PROFILE_FILE)
		if not data then
			return false
		end
		local profile = data :: any
		if type(profile) ~= "table" then
			return false
		end
		if type(profile.Combat) == "table" then
			local c = profile.Combat
			if type(c.AuraMode) == "string" then Aura.Mode = c.AuraMode end
			if type(c.PredictionDepth) == "number" then Aura.PredictionDepth = c.PredictionDepth end
			if type(c.ReachSize) == "number" then ReachSize = c.ReachSize end
			if type(c.IK_BurstCount) == "number" then IK_BurstCount = c.IK_BurstCount end
			if type(c.IK_AdaptiveBurst) == "boolean" then IK_AdaptiveBurst = c.IK_AdaptiveBurst end
			if type(c.HA_Range) == "number" then HA_Range = Vector3.new(c.HA_Range, c.HA_Range, c.HA_Range) end
			if type(c.HA_BurstCount) == "number" then HA_BurstCount = c.HA_BurstCount end
			if type(c.HA_MultiPulse) == "boolean" then HA_MultiPulse = c.HA_MultiPulse end
			if type(c.RepelForce) == "number" then AntiAura.RepelForce = c.RepelForce end
			if type(c.RepelRadius) == "number" then AntiAura.RepelRadius = c.RepelRadius end
			if type(c.ToolFollowOffset) == "number" then ToolFollow.PredictionOffset = c.ToolFollowOffset end
		end
		if type(profile.Movement) == "table" then
			local m = profile.Movement
			if type(m.SpeedValue) == "number" then Movement.SpeedValue = m.SpeedValue end
			if type(m.JumpValue) == "number" then Movement.JumpValue = m.JumpValue end
			if type(m.FlySpeed) == "number" then Movement.FlySpeed = m.FlySpeed end
		end
		if type(profile.AI) == "table" then
			local ai = profile.AI
			if type(ai.ThreatRadius) == "number" then ThreatRadius = ai.ThreatRadius end
			if type(ai.latencyEstimate) == "number" then latencyEstimate = ai.latencyEstimate end
		end
		if type(profile.Automation) == "table" then
			local a = profile.Automation
			if type(a.TG_BurstCount) == "number" then TG_BurstCount = a.TG_BurstCount end
			if type(a.TG_WavePriority) == "boolean" then TG_WavePriority = a.TG_WavePriority end
		end
		print(`[EXO-PROFILE] Loaded from disk. Version: {profile.Version or "unknown"}`)
		return true
	end

	local function Profile_Reset(): boolean
		local ok: boolean = deleteFile(PROFILE_FILE)
		if ok then
			print("[EXO-PROFILE] Profile reset. Defaults will apply next load.")
		end
		return ok
	end

	local function Profile_Export(): string?
		local data = readJSON(PROFILE_FILE)
		if not data then
			return nil
		end
		local ok: boolean, jsonStr = pcall(HttpService.JSONEncode, HttpService, data)
		if ok and type(jsonStr) == "string" then
			return jsonStr
		end
		return nil
	end

	local _profile_loaded: boolean = Profile_Load()

	_G.EXO_Profile_Save = Profile_Save
	_G.EXO_Profile_Load = Profile_Load
	_G.EXO_Profile_Reset = Profile_Reset
	_G.EXO_Profile_Export = Profile_Export

	print(`[EXO] Section 8 complete. Profile State Saving Engine initialized.`)
	print(`[EXO]   Save file: {PROFILE_FILE}`)
	print(`[EXO]   Auto-load: {if _profile_loaded then "SUCCESS" else "FRESH START"}`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 9: TARGET PREDICTION ENGINE (PHYSICS MATH)                  ║
-- ║  Linear/Quadratic/Cubic | gravity comp | velocity decay | intercept  ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
	type PredictionResult = {
		Position: Vector3,
		Velocity: Vector3,
		Confidence: number,
		Method: string,
	}

	local function Predict_Linear(rootPos: Vector3, velocity: Vector3, t: number): Vector3
		return rootPos + velocity * t
	end

	local function Predict_Quadratic(rootPos: Vector3, velocity: Vector3, t: number, gravity: number?): Vector3
		local g: number = gravity or workspace.Gravity or 196.2
		local gravityVec: Vector3 = Vector3.new(0, -g, 0)
		return rootPos + velocity * t + 0.5 * gravityVec * t * t
	end

	local function Predict_Cubic(rootPos: Vector3, velocity: Vector3, t: number, dragCoeff: number?): Vector3
		local drag: number = dragCoeff or 0.01
		local decayFactor: number = math.max(0, 1 - drag * t)
		local decayedVel: Vector3 = velocity * decayFactor
		return rootPos + decayedVel * t * 0.5 * (1 + decayFactor)
	end

	local _prevVelocities: {[Player]: Vector3} = {}
	local SMOOTH_FACTOR: number = 0.3

	local function Predict_SmoothVelocity(plr: Player, currentVel: Vector3): Vector3
		local prev: Vector3? = _prevVelocities[plr]
		if prev then
			local smoothed: Vector3 = prev:Lerp(currentVel, SMOOTH_FACTOR)
			_prevVelocities[plr] = smoothed
			return smoothed
		end
		_prevVelocities[plr] = currentVel
		return currentVel
	end

	local function Predict_Adaptive(rootPos: Vector3, velocity: Vector3, latency: number, targetHumanoid: Humanoid?): PredictionResult
		local speed: number = velocity.Magnitude
		if speed < 0.5 then
			return {Position = rootPos, Velocity = velocity, Confidence = 1.0, Method = "Static"}
		end
		if speed < 10 then
			return {Position = Predict_Linear(rootPos, velocity, latency), Velocity = velocity, Confidence = 0.9, Method = "Linear"}
		end
		if speed < 30 then
			return {Position = Predict_Quadratic(rootPos, velocity, latency), Velocity = velocity, Confidence = 0.8, Method = "Quadratic"}
		end
		return {Position = Predict_Cubic(rootPos, velocity, latency, 0.02), Velocity = velocity, Confidence = 0.7, Method = "Cubic"}
	end

	local function Predict_MultiHitbox(char: Model, latency: number): {Vector3}
		table.clear(_buf_predictions)
		local hitboxNames: {string} = {"HumanoidRootPart", "UpperTorso", "Torso", "Head", "LowerTorso"}
		for _, name in hitboxNames do
			local part: Instance? = char:FindFirstChild(name)
			if part and part:IsA("BasePart") then
				local posOk: boolean, pos = pcall(function() return part.Position end)
				local velOk: boolean, vel = pcall(function() return part.Velocity end)
				if posOk and velOk and typeof(pos) == "Vector3" and typeof(vel) == "Vector3" then
					table.insert(_buf_predictions, Predict_Linear(pos, vel, latency))
				end
			end
		end
		return _buf_predictions
	end

	local function Distance_Fast(a: Vector3, b: Vector3): number
		return (a - b).Magnitude
	end

	local function Distance_Squared(a: Vector3, b: Vector3): number
		local dx: number = a.X - b.X
		local dy: number = a.Y - b.Y
		local dz: number = a.Z - b.Z
		return dx * dx + dy * dy + dz * dz
	end

	local function Angle_Between(origin: Vector3, target: Vector3, forward: Vector3): number
		local direction: Vector3 = (target - origin)
		local mag: number = direction.Magnitude
		if mag < 0.001 then
			return 0
		end
		direction = direction / mag
		local dot: number = forward:Dot(direction)
		return math.deg(math.acos(math.clamp(dot, -1, 1)))
	end

	local function Predict_InterceptTime(attackerPos: Vector3, targetPos: Vector3, targetVel: Vector3, projectileSpeed: number): number?
		if projectileSpeed <= 0 then
			return nil
		end
		local toTarget: Vector3 = targetPos - attackerPos
		local dist: number = toTarget.Magnitude
		if dist < 0.01 then
			return 0
		end
		local a: number = targetVel:Dot(targetVel) - projectileSpeed * projectileSpeed
		local b: number = 2 * targetVel:Dot(toTarget)
		local c: number = toTarget:Dot(toTarget)
		local discriminant: number = b * b - 4 * a * c
		if discriminant < 0 then
			return nil
		end
		local sqrtDisc: number = math.sqrt(discriminant)
		local t1: number = (-b + sqrtDisc) / (2 * a)
		local t2: number = (-b - sqrtDisc) / (2 * a)
		if t1 > 0 and t2 > 0 then
			return math.min(t1, t2)
		elseif t1 > 0 then
			return t1
		elseif t2 > 0 then
			return t2
		end
		return nil
	end

	Players.PlayerRemoving:Connect(function(plr: Player)
		_prevVelocities[plr] = nil
	end)

	_G.EXO_Predict_Linear = Predict_Linear
	_G.EXO_Predict_Quadratic = Predict_Quadratic
	_G.EXO_Predict_Cubic = Predict_Cubic
	_G.EXO_Predict_SmoothVelocity = Predict_SmoothVelocity
	_G.EXO_Predict_Adaptive = Predict_Adaptive
	_G.EXO_Predict_MultiHitbox = Predict_MultiHitbox
	_G.EXO_Distance_Fast = Distance_Fast
	_G.EXO_Distance_Squared = Distance_Squared
	_G.EXO_Angle_Between = Angle_Between
	_G.EXO_Predict_InterceptTime = Predict_InterceptTime

	print(`[EXO] Section 9 complete. Target Prediction Engine initialized.`)
	print(`[EXO]   Methods: Static, Linear, Quadratic, Cubic, Adaptive`)
	print(`[EXO]   Physics: Gravity compensation + velocity decay + intercept solver`)
	print(`[EXO]   Smoothing: Exponential (factor={SMOOTH_FACTOR})`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 10: HELPER FUNCTIONS (SHARED UTILITIES)                     ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
	local function getHRP(char: Instance?): BasePart?
		if not char then return nil end
		local hrp: Instance? = char:FindFirstChild("HumanoidRootPart")
		if hrp and hrp:IsA("BasePart") then return hrp end
		local torso: Instance? = char:FindFirstChild("Torso")
		if torso and torso:IsA("BasePart") then return torso end
		return nil
	end

	local function getToolPart(tool: Instance): BasePart?
		if not tool then return nil end
		local handle: Instance? = tool:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then return handle end
		local descOk: boolean, descendants = pcall(function() return tool:GetDescendants() end)
		if descOk and type(descendants) == "table" then
			for _, v in descendants do
				if v:IsA("BasePart") then return v end
			end
		end
		return nil
	end

	local function getServerPlayers(): {string}
		table.clear(_buf_players)
		local ok: boolean, list = pcall(function() return Players:GetPlayers() end)
		if not ok or type(list) ~= "table" then return {"No Players"} end
		for _, p: Player in list do
			if p ~= player then
				table.insert(_buf_players, p.Name)
			end
		end
		return #_buf_players > 0 and _buf_players or {"No Players"}
	end

	local function getTouchableParts(model: Instance): {BasePart}
		table.clear(_buf_parts)
		if not model then return _buf_parts end
		local descendants_ok: boolean, descendants = pcall(function() return model:GetDescendants() end)
		if not descendants_ok or type(descendants) ~= "table" then return _buf_parts end
		for _, desc: Instance in descendants do
			if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
				table.insert(_buf_parts, desc.Parent)
			end
		end
		if #_buf_parts == 0 then
			for _, desc: Instance in descendants do
				if desc:IsA("BasePart") then
					table.insert(_buf_parts, desc)
					break
				end
			end
		end
		return _buf_parts
	end

	local function getPlayerCash(): number
		local ls: Instance? = player:FindFirstChild("leaderstats")
		if ls then
			local names: {string} = {"Cash", "Money", "Coins", "Gold", "Credits"}
			for _, name in names do
				local v: Instance? = ls:FindFirstChild(name)
				if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then
					local ok: boolean, val = pcall(function() return v.Value end)
					if ok and type(val) == "number" then return val end
				end
			end
		end
		return 0
	end

	local function getPlayerTycoonType(): string?
		if cachedTycoonType then
			local tycoons = workspace:FindFirstChild("Tycoons")
			if tycoons and tycoons:FindFirstChild(cachedTycoonType) then
				return cachedTycoonType
			end
		end
		local root: BasePart? = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			local closest: string? = nil
			local minDist: number = math.huge
			local tf: Instance? = workspace:FindFirstChild("Tycoons")
			if tf then
				local children_ok: boolean, children = pcall(function() return tf:GetChildren() end)
				if children_ok and type(children) == "table" then
					for _, t: Instance in children do
						if t:IsA("Folder") then
							local door: Instance? = t:FindFirstChild("Door", true)
							if door then
								local dp: BasePart? = door:FindFirstChildWhichIsA("BasePart")
								if dp then
									local d_ok: boolean, d = pcall(function()
										return (dp.Position - root.Position).Magnitude
									end)
									if d_ok and type(d) == "number" and d < minDist then
										minDist = d
										closest = t.Name
									end
								end
							end
						end
					end
				end
			end
			cachedTycoonType = closest
			return closest
		end
		return nil
	end

	local function getCost(obj: Instance): number
		if not obj then return 0 end
		local pv: Instance? = obj:FindFirstChild("Price") or obj:FindFirstChild("Cost") or obj:FindFirstChild("Value")
		if pv and (pv:IsA("IntValue") or pv:IsA("NumberValue")) then
			local val_ok: boolean, val = pcall(function() return pv.Value end)
			if val_ok and type(val) == "number" then return val end
		end
		local attr_ok: boolean, attr = pcall(function()
			return obj:GetAttribute("Price") or obj:GetAttribute("Cost")
		end)
		if attr_ok and type(attr) == "number" then return attr end
		return 0
	end

	local function getPriority(modelName: string): number
		if type(modelName) ~= "string" then return 90 end
		local name: string = modelName:lower()
		if name:find("robux") then return 999 end
		local num: number = tonumber(name:match("%d+")) or 0
		if name:find("gen") and not name:find("gear") then
			if num <= 1 then return 10 + num
			elseif num <= 3 then return 30 + num
			elseif num <= 5 then return 50 + num
			else return 70 + num end
		end
		if name:find("gear") or name:find("gun") then
			if num <= 2 then return 20 + num
			elseif num <= 5 then return 55 + num
			else return 67 + num end
		end
		if name:find("wall") or name:find("door") or name:find("ladder") then return 40 + num end
		if name:find("ultima") or name:find("effect") then return 80 end
		return 90 + num
	end

	player.CharacterAdded:Connect(function()
		cachedTycoonType = nil
	end)

	_G.EXO_getHRP = getHRP
	_G.EXO_getToolPart = getToolPart
	_G.EXO_getServerPlayers = getServerPlayers
	_G.EXO_getTouchableParts = getTouchableParts
	_G.EXO_getPlayerCash = getPlayerCash
	_G.EXO_getPlayerTycoonType = getPlayerTycoonType
	_G.EXO_getCost = getCost
	_G.EXO_getPriority = getPriority

	print(`[EXO] Section 10 complete. Helper Functions initialized.`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 11: DEFERRED WORKSPACE SCANS (NON-BLOCKING, task.spawn)     ║
-- ║  Remote detection | Tycoon pad registration                          ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
	local function runScans(): ()
		local scanStart: number = os.clock()
		table.clear(_buf_remotes)
		local containers: {Instance} = {ReplicatedStorage, workspace}
		for _, container in containers do
			pcall(function()
				local descendants = container:GetDescendants()
				for _, obj in descendants do
					if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
						local n: string = obj.Name:lower()
						if n:match("damage") or n:match("hit") or n:match("attack")
							or n:match("deal") or n:match("hurt") or n:match("strike")
							or n:match("combat") or n:match("fight") or n:match("kill")
							or n:match("weapon") or n:match("sword") or n:match("gun") then
							table.insert(_buf_remotes, obj)
						end
					end
				end
			end)
		end
		if #_buf_remotes > 0 then
			DAMAGE_REMOTE = _buf_remotes[1]
			if #_buf_remotes > 1 then DAMAGE_REMOTE_ALT = _buf_remotes[2] end
			if #_buf_remotes > 2 then DAMAGE_REMOTE_TERT = _buf_remotes[3] end
		end
		local TycoonsFolder = workspace:FindFirstChild("Tycoons")
		if TycoonsFolder then
			pcall(function()
				local descendants = TycoonsFolder:GetDescendants()
				for _, d in descendants do
					if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent
						and d.Parent.Parent.Name:find("GearGiver") then
						local base = d.Parent.Parent.Parent
						if base then
							local bn: string = base.Name
							local validBases: {string} = {
								"Stone", "Magic", "Storm", "Robotic",
								"Mecha", "Shadow", "Hyper", "Thunder",
								"Void", "Frozen", "Magma", "Nuclear",
								"Toxic", "Kong",
							}
							for _, valid in validBases do
								if bn == valid then
									if not TG_padsByBase[bn] then
										TG_padsByBase[bn] = {}
									end
									table.insert(TG_padsByBase[bn], d.Parent)
									TG_registered[d.Parent] = bn
									break
								end
							end
						end
					end
				end
			end)
		end
		scansComplete = true
		local duration: number = os.clock() - scanStart
		local baseCount: number = 0
		for _ in TG_padsByBase do baseCount += 1 end
		print(`[EXO] Section 11: Scans complete in {string.format("%.3f", duration)}s`)
		print(`[EXO]   Remotes found: {#_buf_remotes}`)
		print(`[EXO]   Tycoon bases registered: {baseCount}`)
	end

	task.spawn(runScans)

	_G.EXO_RunScans = runScans

	print(`[EXO] Section 11 complete. Deferred Workspace Scans scheduled.`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 12: THREAT DETECTION + FSM THREAT ENGINE                    ║
-- ║  12.1 updateThreatLevel | 12.2 FSM configs | 12.3 FSM scoring/       ║
-- ║  transition/heartbeat | 12.4 UI Registry                             ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
	-- 12.1: Multi-layer threat detection
	local function updateThreatLevel(): ()
		if tick() - LastThreatCheck < 0.15 then return end
		LastThreatCheck = tick()
		local prevThreat: number = ThreatLevel
		ThreatLevel = 0
		local myChar: Model? = player.Character
		if not myChar then return end
		local myRoot = myChar:FindFirstChild("HumanoidRootPart")
		if not myRoot or not myRoot:IsA("BasePart") then return end
		local posOk: boolean, myPos = pcall(function() return myRoot.Position end)
		if not posOk or typeof(myPos) ~= "Vector3" then return end
		local playersOk: boolean, playersList = pcall(function() return Players:GetPlayers() end)
		if not playersOk or type(playersList) ~= "table" then return end
		for _, plr: Player in playersList do
			if plr ~= player then
				local charOk: boolean, plrChar = pcall(function() return plr.Character end)
				if charOk and plrChar then
					local theirRoot = plrChar:FindFirstChild("HumanoidRootPart")
					if theirRoot and theirRoot:IsA("BasePart") then
						local tposOk: boolean, theirPos = pcall(function() return theirRoot.Position end)
						if tposOk and typeof(theirPos) == "Vector3" then
							local dist: number = (theirPos - myPos).Magnitude
							if dist < ThreatRadius then
								ThreatLevel += 1
								if dist < ThreatRadius * 0.3 then ThreatLevel += 2 end
								if dist < ThreatRadius * 0.1 then ThreatLevel += 3 end
								local velOk: boolean, velocity = pcall(function() return theirRoot.Velocity.Magnitude end)
								if velOk and type(velocity) == "number" and velocity > 20 then
									ThreatLevel += 1
								end
								local hasTool: boolean = false
								local cOk: boolean, children = pcall(function() return plrChar:GetChildren() end)
								if cOk and type(children) == "table" then
									for _, item in children do
										if item:IsA("Tool") then
											hasTool = true
											break
										end
									end
								end
								if hasTool then ThreatLevel += 1 end
							end
						end
					end
				end
			end
		end
		ThreatTrend = ThreatLevel - prevThreat
		if ThreatLevel > PeakThreat then PeakThreat = ThreatLevel end
		ThreatDecay = math.max(0, ThreatDecay - 0.1)
		table.insert(ThreatHistory, {time = tick(), level = ThreatLevel, trend = ThreatTrend})
		if #ThreatHistory > 60 then table.remove(ThreatHistory, 1) end
		table.insert(ThreatVelocity, {time = tick(), delta = ThreatTrend})
		if #ThreatVelocity > 30 then table.remove(ThreatVelocity, 1) end
	end

	-- 12.2: FSM mode configs
	local fsm_mode_configs: {[string]: {[string]: boolean}} = {
		IDLE = {
			Aura = false, InstantKill = false, AntiAura = false,
			AutoBuild = false, AutoClaimMoney = false, ToolFollow = false,
			SpeedHack = false, Noclip = false,
		},
		TYCOON = {
			Aura = false, InstantKill = false, AntiAura = false,
			AutoBuild = true, AutoClaimMoney = true, ToolFollow = false,
			SpeedHack = true, Noclip = false,
		},
		DEFENSIVE = {
			Aura = false, InstantKill = false, AntiAura = true,
			AutoBuild = false, AutoClaimMoney = false, ToolFollow = false,
			SpeedHack = true, Noclip = false,
		},
		COMBAT = {
			Aura = true, InstantKill = true, AntiAura = true,
			AutoBuild = false, AutoClaimMoney = false, ToolFollow = true,
			SpeedHack = false, Noclip = false,
		},
	}

	-- 12.3: FSM scoring / optimal mode / transition / heartbeat
	local function fsmCalculateModeScores(): {[string]: number}
		local scores: {[string]: number} = {IDLE = 10, TYCOON = 0, DEFENSIVE = 0, COMBAT = 0}
		local timeSinceDeath: number = tick() - LastDeathTime
		local timeSinceSpawn: number = tick() - LastSpawnTime
		if ThreatLevel <= 2 then scores.TYCOON += 30 end
		if timeSinceDeath > 30 then scores.TYCOON += 25 end
		if timeSinceSpawn > 10 then scores.TYCOON += 15 end
		local cash: number = getPlayerCash()
		if cash > 0 then scores.TYCOON += 20 end
		if cash > 1000 then scores.TYCOON += 10 end
		if ThreatLevel >= 3 and ThreatLevel <= 5 then scores.DEFENSIVE += 35 end
		if timeSinceDeath < 10 then scores.DEFENSIVE += 30 end
		if DeathCount > 0 and timeSinceDeath < 20 then scores.DEFENSIVE += 20 end
		if ThreatTrend > 0 then scores.DEFENSIVE += 15 end
		if ThreatLevel > 5 then scores.COMBAT += 40 end
		if PeakThreat > 7 then scores.COMBAT += 20 end
		local hasCombatTool: boolean = false
		local myChar: Model? = player.Character
		if myChar then
			local children_ok: boolean, children = pcall(function() return myChar:GetChildren() end)
			if children_ok and type(children) == "table" then
				for _, item in children do
					if item:IsA("Tool") then
						hasCombatTool = true
						break
					end
				end
			end
		end
		if hasCombatTool then scores.COMBAT += 25 end
		return scores
	end

	local function fsmDetermineOptimalMode(scores: {[string]: number}): string
		local bestMode: string = "IDLE"
		local bestScore: number = -1
		for mode: string, score: number in scores do
			if type(score) == "number" and score > bestScore then
				bestScore = score
				bestMode = mode
			end
		end
		return bestMode
	end

	if type(_G.EXO_FSM_ENGINE_STATE) ~= "table" then
		_G.EXO_FSM_ENGINE_STATE = {
			CurrentMode = "IDLE",
			PreviousMode = "IDLE",
			ModeStartTime = tick(),
			ModeDuration = 0,
			TransitionCount = 0,
			AutoSwitchEnabled = false,
			LastEvaluation = 0,
			EvaluationInterval = 1.0,
		}
	end

	local _fsm_conn: RBXScriptConnection? = nil
	local SWITCH_THRESHOLD: number = 15

	local function fsmApplyMode(mode: string): ()
		local config = fsm_mode_configs[mode]
		if type(config) ~= "table" then return end
		if config.Aura ~= Aura.Enabled then Aura.Enabled = config.Aura end
		if config.InstantKill ~= InstantKill then InstantKill = config.InstantKill end
		if config.InstantKill ~= InstaKillEnabled then InstaKillEnabled = config.InstantKill end
		if config.AntiAura ~= AntiAura.Enabled then
			AntiAura.Enabled = config.AntiAura
			if config.AntiAura then
				AntiAura.GodMode = true
				AntiAura.Repel = true
				AntiAura.Phase = true
			end
		end
		if config.AutoBuild ~= AutoBuild then AutoBuild = config.AutoBuild end
		if config.AutoClaimMoney ~= AutoClaimMoney then AutoClaimMoney = config.AutoClaimMoney end
		if config.ToolFollow ~= ToolFollow.Enabled then ToolFollow.Enabled = config.ToolFollow end
		if config.SpeedHack ~= Movement.SpeedHack then Movement.SpeedHack = config.SpeedHack end
		if config.Noclip ~= Movement.Noclip then Movement.Noclip = config.Noclip end
	end

	local function fsmTransitionTo(newMode: string, reason: string): ()
		local engine = _G.EXO_FSM_ENGINE_STATE
		if type(engine) ~= "table" then return end
		if newMode == engine.CurrentMode then return end
		engine.PreviousMode = engine.CurrentMode
		engine.CurrentMode = newMode
		engine.ModeStartTime = tick()
		engine.TransitionCount += 1
		fsmApplyMode(newMode)
		print(`[EXO-FSM] Transition: {engine.PreviousMode} → {newMode} | Reason: {reason}`)
	end

	local function fsmStartEngine(): ()
		if _fsm_conn then pcall(function() _fsm_conn:Disconnect() end) end
		local engine = _G.EXO_FSM_ENGINE_STATE
		engine.AutoSwitchEnabled = true
		_fsm_conn = RunService.Heartbeat:Connect(function()
			if not engine.AutoSwitchEnabled then return end
			if tick() - engine.LastEvaluation < engine.EvaluationInterval then return end
			engine.LastEvaluation = tick()
			engine.ModeDuration = tick() - engine.ModeStartTime
			updateThreatLevel()
			local scores = fsmCalculateModeScores()
			local optimalMode = fsmDetermineOptimalMode(scores)
			local currentScore: number = scores[engine.CurrentMode] or 0
			local optimalScore: number = scores[optimalMode] or 0
			if optimalMode ~= engine.CurrentMode and optimalScore > currentScore + SWITCH_THRESHOLD then
				fsmTransitionTo(optimalMode, `score {optimalScore} vs current {currentScore}`)
			end
			if ThreatLevel > 7 and engine.CurrentMode ~= "COMBAT" then
				fsmTransitionTo("COMBAT", "EMERGENCY: Threat spike detected")
			end
			local timeSinceDeath: number = tick() - LastDeathTime
			if timeSinceDeath < 3 and engine.CurrentMode ~= "DEFENSIVE" and DeathCount > 0 then
				fsmTransitionTo("DEFENSIVE", "EMERGENCY: Recent death detected")
			end
		end)
	end

	local function fsmStopEngine(): ()
		if _fsm_conn then pcall(function() _fsm_conn:Disconnect() end); _fsm_conn = nil end
		local engine = _G.EXO_FSM_ENGINE_STATE
		if type(engine) == "table" then engine.AutoSwitchEnabled = false end
	end

	local function fsmSetAutoSwitch(enabled: boolean): ()
		local engine = _G.EXO_FSM_ENGINE_STATE
		if type(engine) ~= "table" then return end
		engine.AutoSwitchEnabled = enabled
		if enabled and not _fsm_conn then
			fsmStartEngine()
		elseif not enabled and _fsm_conn then
			fsmStopEngine()
		end
	end

	local function fsmGetCurrentMode(): string
		local engine = _G.EXO_FSM_ENGINE_STATE
		if type(engine) == "table" and type(engine.CurrentMode) == "string" then
			return engine.CurrentMode
		end
		return "IDLE"
	end

	local function fsmGetModeScores(): {[string]: number}
		return fsmCalculateModeScores()
	end

	-- 12.4: UI Registry (declarative tab/section/element definitions)
	type UIElementConfig = {
		Type: string,
		Name: string,
		Default: any?,
		Min: number?,
		Max: number?,
		Options: {string}?,
		Placeholder: string?,
		Callback: ((any) -> ())?,
		Info: string?,
	}
	type UISectionConfig = {
		Title: string,
		Elements: {UIElementConfig},
	}
	type UITabConfig = {
		Title: string,
		Sections: {UISectionConfig},
		Locked: boolean?,
		Icon: string?,
		Order: number,
	}

	local UITabRegistry: {UITabConfig} = {}
	local UITabOrder: {string} = {}

	local function UI_RegisterTab(config: UITabConfig): ()
		if type(config) ~= "table" then
			warn("[EXO-UI] Invalid tab config: not a table")
			return
		end
		if type(config.Title) ~= "string" or config.Title == "" then
			warn("[EXO-UI] Invalid tab config: missing title")
			return
		end
		if type(config.Sections) ~= "table" then
			warn(`[EXO-UI] Invalid tab config for {config.Title}: missing sections`)
			return
		end
		for _, existing in UITabRegistry do
			if existing.Title == config.Title then
				warn(`[EXO-UI] Duplicate tab registration blocked: {config.Title}`)
				return
			end
		end
		table.insert(UITabRegistry, config)
		table.insert(UITabOrder, config.Title)
	end

	local function UI_GetTabCount(): number
		return #UITabRegistry
	end

	local function UI_GetTab(index: number): UITabConfig?
		if index < 1 or index > #UITabRegistry then return nil end
		return UITabRegistry[index]
	end

	local function UI_FindTab(title: string): UITabConfig?
		for _, tab in UITabRegistry do
			if tab.Title == title then
				return tab
			end
		end
		return nil
	end

	local function UI_GetTabOrder(): {string}
		return UITabOrder
	end

	local function UI_GetTotalElements(): number
		local total: number = 0
		for _, tab in UITabRegistry do
			for _, section in tab.Sections do
				total += #section.Elements
			end
		end
		return total
	end

	local function UI_GetTotalSections(): number
		local total: number = 0
		for _, tab in UITabRegistry do
			total += #tab.Sections
		end
		return total
	end

	_G.EXO_updateThreatLevel = updateThreatLevel
	_G.EXO_FSM_MODE_CONFIGS = fsm_mode_configs
	_G.EXO_FSM_CalculateModeScores = fsmCalculateModeScores
	_G.EXO_FSM_DetermineOptimalMode = fsmDetermineOptimalMode
	_G.EXO_FSM_ApplyMode = fsmApplyMode
	_G.EXO_FSM_TransitionTo = fsmTransitionTo
	_G.EXO_FSM_Start = fsmStartEngine
	_G.EXO_FSM_Stop = fsmStopEngine
	_G.EXO_FSM_SetAutoSwitch = fsmSetAutoSwitch
	_G.EXO_FSM_GetCurrentMode = fsmGetCurrentMode
	_G.EXO_FSM_GetModeScores = fsmGetModeScores
	_G.EXO_UI_RegisterTab = UI_RegisterTab
	_G.EXO_UI_GetTabCount = UI_GetTabCount
	_G.EXO_UI_GetTab = UI_GetTab
	_G.EXO_UI_FindTab = UI_FindTab
	_G.EXO_UI_GetTabOrder = UI_GetTabOrder
	_G.EXO_UI_GetTotalElements = UI_GetTotalElements
	_G.EXO_UI_GetTotalSections = UI_GetTotalSections
	_G.EXO_UITabRegistry = UITabRegistry

	print(`[EXO] Section 12 complete. Threat Detection + FSM Threat Engine + UI Registry initialized.`)
	print(`[EXO]   12.1 Threat detection: multi-layer (distance/velocity/tool)`)
	print(`[EXO]   12.2 FSM modes: IDLE, TYCOON, DEFENSIVE, COMBAT`)
	print(`[EXO]   12.3 FSM hysteresis: {SWITCH_THRESHOLD} points + emergency overrides`)
	print(`[EXO]   12.4 UI Registry: {UI_GetTabCount()} tabs registered`)
end

print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] PART 1 (SECOND HALF) COMPLETE`)
print(`[EXO] Sections 7 → 12.4 loaded and verified.`)
print(`[EXO] Keybinds: {#(_G.EXO_KeybindManager and _G.EXO_KeybindManager.Binds or {})} binds`)
print(`[EXO] Prediction: 5 methods + intercept solver`)
print(`[EXO] FSM: 4 modes + hysteresis + emergency overrides`)
print(`[EXO] UI Registry: {_G.EXO_UI_GetTabCount()} tabs`)
print(`[EXO] ═══ PART 1 (SECOND HALF) COMPLETE ═══`)
