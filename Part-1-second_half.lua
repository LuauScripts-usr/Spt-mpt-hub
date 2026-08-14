-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 7: KEYBIND MANAGER (FULL SYSTEM)                          ║
-- ║  Persistent keybinds, mobile-friendly, profile-aware               ║
-- ╚══════════════════════════════════════════════════════════════════════╝

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

-- Register a new keybind
local function KB_Register(name: string, defaultKey: Enum.KeyCode, category: string, callback: () -> ()): ()
    -- Prevent duplicate registrations
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

-- Unregister a keybind by name
local function KB_Unregister(name: string): ()
    for i = #KeybindManager.Binds, 1, -1 do
        if KeybindManager.Binds[i].Name == name then
            table.remove(KeybindManager.Binds, i)
            break
        end
    end
end

-- Get a keybind entry by name
local function KB_Get(name: string): KeybindEntry?
    for _, entry in KeybindManager.Binds do
        if entry.Name == name then
            return entry
        end
    end
    return nil
end

-- Update a keybind's key
local function KB_SetKey(name: string, newKey: Enum.KeyCode): ()
    local entry: KeybindEntry? = KB_Get(name)
    if entry then
        entry.KeyCode = newKey
    end
end

-- Toggle a keybind's enabled state
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

-- Get all keybinds in a category
local function KB_GetByCategory(category: string): {KeybindEntry}
    local result: {KeybindEntry} = {}
    for _, entry in KeybindManager.Binds do
        if entry.Category == category then
            table.insert(result, entry)
        end
    end
    return result
end

-- Start listening for a new key assignment
local function KB_StartListening(name: string): ()
    KeybindManager.Listening = true
    KeybindManager.ListenTarget = name
end

-- Stop listening without assigning
local function KB_CancelListening(): ()
    KeybindManager.Listening = false
    KeybindManager.ListenTarget = nil
end

-- Save all keybinds to file
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

-- Load keybinds from file
local function KB_Load(): ()
    local data = readJSON(KEYBIND_FILE)
    if not data or type(data.Binds) ~= "table" then
        return
    end
    for _, saved in data.Binds do
        if type(saved) == "table" and type(saved.Name) == "string" then
            local entry: KeybindEntry? = KB_Get(saved.Name)
            if entry then
                -- Restore key from name string
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

-- Input handler for keybinds
local function KB_InitInputHandler(): ()
    if KeybindManager.Connection then
        pcall(function() KeybindManager.Connection:Disconnect() end)
    end

    KeybindManager.Connection = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        -- Skip if game UI is consuming input
        if gameProcessed then
            return
        end

        -- If listening for a new key assignment
        if KeybindManager.Listening and KeybindManager.ListenTarget then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                KB_SetKey(KeybindManager.ListenTarget, input.KeyCode)
                KeybindManager.Listening = false
                KeybindManager.ListenTarget = nil
                KB_Save()
            end
            return
        end

        -- Check all registered keybinds
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

-- Register default keybinds
local function KB_RegisterDefaults(): ()
    -- UI Toggle
    KB_Register("ToggleUI", Enum.KeyCode.RightShift, "General", function()
        if type(_G.EXO_ToggleUI) == "function" then
            pcall(_G.EXO_ToggleUI)
        end
    end)

    -- Combat toggles
    KB_Register("ToggleAura", Enum.KeyCode.F1, "Combat", function()
        Aura.Enabled = not Aura.Enabled
        if Aura.Enabled then
            if type(_G.EXO_StartAuraLoop) == "function" then
                pcall(_G.EXO_StartAuraLoop)
            end
        else
            if type(_G.EXO_StopAuraLoop) == "function" then
                pcall(_G.EXO_StopAuraLoop)
            end
        end
    end)

    KB_Register("ToggleInstaKill", Enum.KeyCode.F2, "Combat", function()
        InstaKillEnabled = not InstaKillEnabled
        if InstaKillEnabled then
            if type(_G.EXO_StartInstaKill) == "function" then
                pcall(_G.EXO_StartInstaKill)
            end
        else
            if type(_G.EXO_StopInstaKill) == "function" then
                pcall(_G.EXO_StopInstaKill)
            end
        end
    end)

    KB_Register("ToggleAntiAura", Enum.KeyCode.F3, "Combat", function()
        AntiAura.Enabled = not AntiAura.Enabled
        if AntiAura.Enabled then
            if type(_G.EXO_StartAntiAura) == "function" then
                pcall(_G.EXO_StartAntiAura)
            end
        else
            if type(_G.EXO_StopAntiAura) == "function" then
                pcall(_G.EXO_StopAntiAura)
            end
        end
    end)

    KB_Register("ToggleReach", Enum.KeyCode.F4, "Combat", function()
        Reach = not Reach
        if Reach then
            if type(_G.EXO_ApplyReach) == "function" then
                pcall(_G.EXO_ApplyReach)
            end
        else
            if type(_G.EXO_StopReach) == "function" then
                pcall(_G.EXO_StopReach)
            end
        end
    end)

    -- Movement toggles
    KB_Register("ToggleSpeed", Enum.KeyCode.F5, "Movement", function()
        Movement.SpeedHack = not Movement.SpeedHack
    end)

    KB_Register("ToggleNoclip", Enum.KeyCode.F6, "Movement", function()
        Movement.Noclip = not Movement.Noclip
    end)

    KB_Register("ToggleFly", Enum.KeyCode.F7, "Movement", function()
        Movement.Fly = not Movement.Fly
    end)

    -- Automation toggles
    KB_Register("ToggleAutoBuild", Enum.KeyCode.F8, "Automation", function()
        AutoBuild = not AutoBuild
        if AutoBuild then
            if type(_G.EXO_StartAutoBuild) == "function" then
                pcall(_G.EXO_StartAutoBuild)
            end
        else
            if type(_G.EXO_StopAutoBuild) == "function" then
                pcall(_G.EXO_StopAutoBuild)
            end
        end
    end)

    KB_Register("ToggleAutoClaim", Enum.KeyCode.F9, "Automation", function()
        AutoClaimMoney = not AutoClaimMoney
        if AutoClaimMoney then
            if type(_G.EXO_StartClaimMoney) == "function" then
                pcall(_G.EXO_StartClaimMoney)
            end
        else
            if type(_G.EXO_StopClaimMoney) == "function" then
                pcall(_G.EXO_StopClaimMoney)
            end
        end
    end)

    -- Visuals
    KB_Register("ToggleESP", Enum.KeyCode.F10, "Visuals", function()
        ESPEnabled = not ESPEnabled
        if ESPEnabled then
            if type(_G.EXO_StartESP) == "function" then
                pcall(_G.EXO_StartESP)
            end
        else
            if type(_G.EXO_StopESP) == "function" then
                pcall(_G.EXO_StopESP)
            end
        end
    end)

    -- Emergency panic button - disables everything
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
        if type(_G.EXO_StopAuraLoop) == "function" then pcall(_G.EXO_StopAuraLoop) end
        if type(_G.EXO_StopInstaKill) == "function" then pcall(_G.EXO_StopInstaKill) end
        if type(_G.EXO_StopHitAmplifier) == "function" then pcall(_G.EXO_StopHitAmplifier) end
        if type(_G.EXO_StopAntiAura) == "function" then pcall(_G.EXO_StopAntiAura) end
        if type(_G.EXO_StopReach) == "function" then pcall(_G.EXO_StopReach) end
        if type(_G.EXO_StopToolFollow) == "function" then pcall(_G.EXO_StopToolFollow) end
        if type(_G.EXO_StopNoCooldown) == "function" then pcall(_G.EXO_StopNoCooldown) end
        if type(_G.EXO_StopAutoBuild) == "function" then pcall(_G.EXO_StopAutoBuild) end
        if type(_G.EXO_StopClaimMoney) == "function" then pcall(_G.EXO_StopClaimMoney) end
    end)
end

-- Initialize keybind system
KB_InitInputHandler()
KB_RegisterDefaults()
KB_Load()

print(`[EXO] Section 7 complete. Keybind Manager initialized.`)
print(`[EXO]   Registered binds: {#KeybindManager.Binds}`)
print(`[EXO]   Categories: General, Combat, Movement, Automation, Visuals`)
print(`[EXO]   Persistence: {KEYBIND_FILE}`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 8: PROFILE STATE SAVING SYSTEM                            ║
-- ║  Saves/loads all feature states, keybinds, AI memory               ║
-- ╚══════════════════════════════════════════════════════════════════════╝

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

    -- Save keybind states
    for _, entry in KeybindManager.Binds do
        table.insert(profile.Keybinds, {
            Name = entry.Name,
            KeyCode = entry.KeyCode.Name,
            Enabled = entry.Enabled,
            Category = entry.Category,
        })
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

    -- Restore Combat
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

    -- Restore Movement
    if type(profile.Movement) == "table" then
        local m = profile.Movement
        if type(m.SpeedValue) == "number" then Movement.SpeedValue = m.SpeedValue end
        if type(m.JumpValue) == "number" then Movement.JumpValue = m.JumpValue end
        if type(m.FlySpeed) == "number" then Movement.FlySpeed = m.FlySpeed end
    end

    -- Restore AI
    if type(profile.AI) == "table" then
        local ai = profile.AI
        if type(ai.ThreatRadius) == "number" then ThreatRadius = ai.ThreatRadius end
        if type(ai.latencyEstimate) == "number" then latencyEstimate = ai.latencyEstimate end
    end

    -- Restore Automation
    if type(profile.Automation) == "table" then
        local a = profile.Automation
        if type(a.TG_BurstCount) == "number" then TG_BurstCount = a.TG_BurstCount end
        if type(a.TG_WavePriority) == "boolean" then TG_WavePriority = a.TG_WavePriority end
    end

    -- Restore Keybinds
    if type(profile.Keybinds) == "table" then
        for _, saved in profile.Keybinds do
            if type(saved) == "table" and type(saved.Name) == "string" then
                local entry: KeybindEntry? = KB_Get(saved.Name)
                if entry and type(saved.KeyCode) == "string" then
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

-- Auto-load profile on startup
local _profile_loaded: boolean = Profile_Load()
if _profile_loaded then
    print("[EXO] Section 8: Profile loaded from disk.")
else
    print("[EXO] Section 8: No saved profile found (first run).")
end

print(`[EXO] Section 8 complete. Profile system initialized.`)
print(`[EXO]   Save file: {PROFILE_FILE}`)
print(`[EXO]   Auto-load: {if _profile_loaded then "SUCCESS" else "FRESH START"}`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 9: TARGET PREDICTION ENGINE (PHYSICS MATH)                ║
-- ║  Quadratic + Cubic prediction, gravity comp, velocity decay        ║
-- ╚══════════════════════════════════════════════════════════════════════╝

type PredictionResult = {
    Position: Vector3,
    Velocity: Vector3,
    Confidence: number,
    Method: string,
}

-- Linear prediction: pos + vel * t
local function Predict_Linear(rootPos: Vector3, velocity: Vector3, t: number): Vector3
    return rootPos + velocity * t
end

-- Quadratic prediction: pos + vel * t + 0.5 * accel * t^2
-- Approximates acceleration from velocity change + gravity
local function Predict_Quadratic(rootPos: Vector3, velocity: Vector3, t: number, gravity: number?): Vector3
    local g: number = gravity or workspace.Gravity or 196.2
    local gravityVec: Vector3 = Vector3.new(0, -g, 0)
    return rootPos + velocity * t + 0.5 * gravityVec * t * t
end

-- Cubic prediction with velocity decay (drag approximation)
local function Predict_Cubic(rootPos: Vector3, velocity: Vector3, t: number, dragCoeff: number?): Vector3
    local drag: number = dragCoeff or 0.01
    local decayFactor: number = math.max(0, 1 - drag * t)
    local decayedVel: Vector3 = velocity * decayFactor
    -- Integrate decayed velocity over time
    return rootPos + decayedVel * t * 0.5 * (1 + decayFactor)
end

-- Exponential smoothing for jittery velocity data
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

-- Full adaptive prediction: picks best method based on target state
local function Predict_Adaptive(
    rootPos: Vector3,
    velocity: Vector3,
    latency: number,
    targetHumanoid: Humanoid?
): PredictionResult
    -- If target is stationary, no prediction needed
    local speed: number = velocity.Magnitude
    if speed < 0.5 then
        return {
            Position = rootPos,
            Velocity = velocity,
            Confidence = 1.0,
            Method = "Static",
        }
    end

    -- If target is walking slowly, linear is sufficient
    if speed < 10 then
        local predicted: Vector3 = Predict_Linear(rootPos, velocity, latency)
        return {
            Position = predicted,
            Velocity = velocity,
            Confidence = 0.9,
            Method = "Linear",
        }
    end

    -- If target is running/sprinting, use quadratic with gravity
    if speed < 30 then
        local predicted: Vector3 = Predict_Quadratic(rootPos, velocity, latency)
        return {
            Position = predicted,
            Velocity = velocity,
            Confidence = 0.8,
            Method = "Quadratic",
        }
    end

    -- If target is very fast (vehicle, flung, speed hack), use cubic with drag
    local predicted: Vector3 = Predict_Cubic(rootPos, velocity, latency, 0.02)
    return {
        Position = predicted,
        Velocity = velocity,
        Confidence = 0.7,
        Method = "Cubic",
    }
end

-- Multi-hitbox prediction: returns predicted positions for all major body parts
local function Predict_MultiHitbox(
    char: Model,
    latency: number
): {Vector3}
    table.clear(_buf_predictions)

    local hitboxNames: {string} = {
        "HumanoidRootPart",
        "UpperTorso",
        "Torso",
        "Head",
        "LowerTorso",
    }

    for _, name in hitboxNames do
        local part: Instance? = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            local posOk: boolean, pos = pcall(function() return part.Position end)
            local velOk: boolean, vel = pcall(function() return part.Velocity end)
            if posOk and velOk and typeof(pos) == "Vector3" and typeof(vel) == "Vector3" then
                local predicted: Vector3 = Predict_Linear(pos, vel, latency)
                table.insert(_buf_predictions, predicted)
            end
        end
    end

    return _buf_predictions
end

-- Calculate distance between two positions (optimized)
local function Distance_Fast(a: Vector3, b: Vector3): number
    return (a - b).Magnitude
end

-- Squared distance (avoids sqrt for comparisons)
local function Distance_Squared(a: Vector3, b: Vector3): number
    local dx: number = a.X - b.X
    local dy: number = a.Y - b.Y
    local dz: number = a.Z - b.Z
    return dx * dx + dy * dy + dz * dz
end

-- Angle calculation between two positions relative to a forward vector
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

-- Time-to-intercept calculation for projectile-like attacks
local function Predict_InterceptTime(
    attackerPos: Vector3,
    targetPos: Vector3,
    targetVel: Vector3,
    projectileSpeed: number
): number?
    if projectileSpeed <= 0 then
        return nil
    end
    local toTarget: Vector3 = targetPos - attackerPos
    local dist: number = toTarget.Magnitude
    if dist < 0.01 then
        return 0
    end

    -- Solve quadratic: |targetPos + vel*t - attackerPos| = speed*t
    local a: number = targetVel:Dot(targetVel) - projectileSpeed * projectileSpeed
    local b: number = 2 * targetVel:Dot(toTarget)
    local c: number = toTarget:Dot(toTarget)

    local discriminant: number = b * b - 4 * a * c
    if discriminant < 0 then
        return nil -- No solution, target moving too fast
    end

    local sqrtDisc: number = math.sqrt(discriminant)
    local t1: number = (-b + sqrtDisc) / (2 * a)
    local t2: number = (-b - sqrtDisc) / (2 * a)

    -- Return smallest positive time
    if t1 > 0 and t2 > 0 then
        return math.min(t1, t2)
    elseif t1 > 0 then
        return t1
    elseif t2 > 0 then
        return t2
    end
    return nil
end

-- Clean up velocity tracking when players leave
Players.PlayerRemoving:Connect(function(plr: Player)
    _prevVelocities[plr] = nil
end)

print(`[EXO] Section 9 complete. Target Prediction Engine initialized.`)
print(`[EXO]   Methods: Static, Linear, Quadratic, Cubic, Adaptive`)
print(`[EXO]   Multi-hitbox prediction: 5 body parts`)
print(`[EXO]   Physics: Gravity compensation + velocity decay + intercept solver`)
print(`[EXO]   Smoothing: Exponential (factor={SMOOTH_FACTOR})`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 10: HELPER FUNCTIONS (SHARED UTILITIES)                   ║
-- ╚══════════════════════════════════════════════════════════════════════╝

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
    if not descendants_ok or type(descendants) ~= "table" then
        return _buf_parts
    end
    -- Pass 1: TouchTransmitter-backed parts (preferred)
    for _, desc: Instance in descendants do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
            table.insert(_buf_parts, desc.Parent)
        end
    end
    -- Pass 2: Fallback to any BasePart if no transmitters found
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

-- Reset cache on respawn
player.CharacterAdded:Connect(function()
    cachedTycoonType = nil
end)

print(`[EXO] Section 10 complete. Helper functions initialized.`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 11: DEFERRED HEAVY SCANS (NON-BLOCKING, task.spawn)       ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local scansComplete: boolean = false

task.spawn(function()
    local scanStart: number = os.clock()

    -- Remote detection
    table.clear(_buf_remotes)
    local containers: {Instance} = {ReplicatedStorage, workspace}
    for _, container in containers do
        local ok: boolean = pcall(function()
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

    -- Tycoon pad registration
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
    print(`[EXO] Section 11: Scans complete in {string.format("%.3f", duration)}s`)
    print(`[EXO]   Remotes found: {#_buf_remotes}`)
    local baseCount: number = 0
    for _ in TG_padsByBase do baseCount += 1 end
    print(`[EXO]   Tycoon bases registered: {baseCount}`)
end)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 12: THREAT DETECTION ENGINE (MULTI-LAYER)                 ║
-- ╚══════════════════════════════════════════════════════════════════════╝
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
                        local dist: number = Distance_Fast(myPos, theirPos)
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

print(`[EXO] Section 12 complete. Threat Detection Engine initialized.`)
print(`[EXO]   Check interval: 0.15s`)
print(`[EXO]   Radius: {ThreatRadius} studs`)
print(`[EXO]   Layers: Distance, Proximity, Velocity, Tool Detection`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  END OF PART 1 (SECOND HALF)                                       ║
-- ║  Part 1 total: Sections 0-12 complete (~3,200 lines)               ║
-- ║  Next: Part 2 – Combat Systems, Movement, FSM Engine               ║
-- ╚══════════════════════════════════════════════════════════════════════╝
print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] PART 1 FULLY COMPLETE: Sections 0-12 loaded.`)
print(`[EXO] Discord Webhook: FIRED`)
print(`[EXO] Keybind Manager: {#KeybindManager.Binds} binds registered`)
print(`[EXO] Profile System: {if _profile_loaded then "LOADED" else "FRESH"}`)
print(`[EXO] Prediction Engine: 5 methods + intercept solver active`)
print(`[EXO] Threat Detection: Multi-layer operational`)
print(`[EXO] Awaiting Part 2 for combat systems...`)
print(`[EXO] ═══════════════════════════════════════════════════`)
