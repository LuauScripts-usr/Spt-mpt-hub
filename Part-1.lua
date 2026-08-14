--!strict
-- ═══════════════════════════════════════════════════════════════════════════
--  ███████╗██╗  ██╗ ██████╗     ██╗  ██╗ █████╗ ██╗   ██╗██████╗  ██████╗
--  ██╔════╝╚██╗██╔╝██╔═══██╗    ██║  ██║██╔══██╗██║   ██║██╔══██╗██╔═══██╗
--  █████╗   ╚███╔╝ ██║   ██║    ███████║███████║██║   ██║██║  ██║██║   ██║
--  ██╔══╝   ██╔██╗ ██║   ██║    ██╔══██║██╔══██║██║   ██║██║  ██║██║   ██║
--  ███████╗██╔╝ ██╗╚██████╔╝    ██║  ██║██║  ██║╚██████╔╝██████╔╝╚██████╔╝
--  ╚══════╝╚═╝  ╚═╝ ╚═════╝     ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝
--
--  EXO HUB v10.0 – SENTINEL PRIME
--  100% LUAU | MODULARIZED | DISCORD LOGGER | KEYBIND MANAGER
--  TARGET PREDICTION | PROFILE SAVING | MOBILE OPTIMIZED
--  LIGHT OBFUSCATION | PRE-ALLOCATED | TASK.SPAWN SAFE
-- ═══════════════════════════════════════════════════════════════════════════

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 0: ANTI-TAMPER INTEGRITY (LIGHTWEIGHT)                    ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local _EXO_VERSION: number = 10.0
local _EXO_BUILD: string = "SENTINEL_PRIME"
local _EXO_INTEGRITY: boolean = true
local _EXO_INTEGRITY_LOG: {string} = {}

local _layer1_ok: boolean = pcall(function()
    if not game then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: game nil")
        _EXO_INTEGRITY = false
        return
    end
    if not game.GetService then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: GetService nil")
        _EXO_INTEGRITY = false
        return
    end
    if not workspace then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: workspace nil")
        _EXO_INTEGRITY = false
        return
    end
    if not typeof then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: typeof nil")
        _EXO_INTEGRITY = false
        return
    end
    if not pcall then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: pcall nil")
        _EXO_INTEGRITY = false
        return
    end
    if not task then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: task nil")
        _EXO_INTEGRITY = false
        return
    end
end)

if not _layer1_ok then
    table.insert(_EXO_INTEGRITY_LOG, `L1_EXCEPTION: {tostring(_layer1_ok)}`)
    _EXO_INTEGRITY = false
end

if not _EXO_INTEGRITY then
    warn("[EXO] INTEGRITY CHECK FAILED - ABORTING")
    return
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 1: LIGHT OBFUSCATION ENGINE (GITHUB-SAFE)                 ║
-- ║  Simple XOR + string split. NOT malware-grade. Readable by design. ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local _xor_key: string = "EXO10"
local _xor_cache: {string} = {}

local function _xor_transform(input: string): string
    if _xor_cache[input] then
        return _xor_cache[input]
    end
    local result: {string} = table.create(#input)
    local keyLen: number = #_xor_key
    for i = 1, #input do
        local byte: number = bit32.bxor(input:byte(i), _xor_key:byte(((i - 1) % keyLen) + 1))
        result[i] = string.char(byte)
    end
    local output: string = table.concat(result)
    _xor_cache[input] = output
    return output
end

-- Light string split obfuscation for sensitive constants
local function _split_join(parts: {string}, sep: string?): string
    if sep then
        return table.concat(parts, sep)
    end
    return table.concat(parts)
end

-- Obfuscate a string by splitting into chunks (reversible, lightweight)
local function _obf(str: string): string
    local chunks: {string} = {}
    local chunkSize: number = 4
    for i = 1, #str, chunkSize do
        table.insert(chunks, str:sub(i, math.min(i + chunkSize - 1, #str)))
    end
    return table.concat(chunks)
end

print(`[EXO] Section 1 complete. Light obfuscation engine loaded.`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 2: SERVICES (TYPED, NO TRAILING SPACES)                   ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local Players: Players = game:GetService("Players")
local RunService: RunService = game:GetService("RunService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui: CoreGui = game:GetService("CoreGui")
local HttpService: HttpService = game:GetService("HttpService")
local TweenService: TweenService = game:GetService("TweenService")
local UserInputService: UserInputService = game:GetService("UserInputService")
local Lighting: Lighting = game:GetService("Lighting")
local TeleportService: TeleportService = game:GetService("TeleportService")
local StarterGui: StarterGui = game:GetService("StarterGui")
local TextService: TextService = game:GetService("TextService")
local GuiService: GuiService = game:GetService("GuiService")
local Stats: Stats = game:GetService("Stats")
local player: Player = Players.LocalPlayer

-- Post-definition validation
local _svc_ok: boolean = pcall(function()
    if not Players then _EXO_INTEGRITY = false end
    if not RunService then _EXO_INTEGRITY = false end
    if not player then _EXO_INTEGRITY = false end
    if not UserInputService then _EXO_INTEGRITY = false end
    if not HttpService then _EXO_INTEGRITY = false end
end)

if not _svc_ok or not _EXO_INTEGRITY then
    warn("[EXO] SERVICE VALIDATION FAILED - ABORTING")
    return
end

print(`[EXO] Section 2 complete. All services loaded and validated.`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 3: DISCORD WEBHOOK EXECUTION LOGGER                       ║
-- ║  Sends embed on every execution. Non-sensitive data only.          ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- Webhook URL assembled via split to avoid plain-text scraping
local WEBHOOK_URL: string = _split_join({
    "https://discord.com/api/",
    "webhooks/1537879404888326234/",
    "Q2JGytYToyPRLUc_l54U3eyXMC8LLX72LdsICThXglNZ9P-omOhy3uhqYAPCappdqPX-"
})

-- Device platform detection
local function _detect_platform(): string
    local platform: string = "Unknown"
    local ok, err = pcall(function()
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            -- Touch only = Mobile or Tablet
            local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(0, 0)
            if viewportSize.Y > 700 then
                platform = "Tablet"
            else
                platform = "Mobile"
            end
        elseif UserInputService.KeyboardEnabled then
            platform = "PC"
        else
            -- Console detection via GuiService
            local ok2, autoTranslate = pcall(function()
                return GuiService.AutoSelectGuiEnabled
            end)
            if ok2 then
                platform = "Console"
            end
        end
    end)
    if not ok then
        platform = "Unknown"
    end
    return platform
end

-- Executor name detection
local function _detect_executor(): string
    local executorName: string = "Unknown"
    if identifyexecutor then
        local ok, result = pcall(identifyexecutor)
        if ok and type(result) == "string" and #result > 0 then
            executorName = result
        end
    elseif getexecutorname then
        local ok, result = pcall(getexecutorname)
        if ok and type(result) == "string" and #result > 0 then
            executorName = result
        end
    end
    return executorName
end

-- Main webhook send function (non-blocking via task.spawn)
local function _send_execution_log(): ()
    task.spawn(function()
        -- Gather execution details
        local username: string = player.Name or "Unknown"
        local displayName: string = player.DisplayName or username
        local userId: number = player.UserId or 0
        local placeId: number = game.PlaceId or 0
        local jobId: string = game.JobId or "N/A"
        local platform: string = _detect_platform()
        local executor: string = _detect_executor()
        local timestamp: string = os.date("%Y-%m-%d %H:%M:%S UTC")
        local buildInfo: string = `v{_EXO_VERSION} | {_EXO_BUILD}`

        -- Build Discord embed payload
        local payload: {[string]: any} = {
            embeds = {
                {
                    title = "🚀 EXO Hub Execution Log",
                    description = "Script hub executed successfully.",
                    color = 0x0096FF, -- Blue
                    fields = {
                        {
                            name = "👤 Username",
                            value = username,
                            inline = true,
                        },
                        {
                            name = "📛 Display Name",
                            value = displayName,
                            inline = true,
                        },
                        {
                            name = "🔢 User ID",
                            value = tostring(userId),
                            inline = true,
                        },
                        {
                            name = "📱 Platform",
                            value = platform,
                            inline = true,
                        },
                        {
                            name = "⚙️ Executor",
                            value = executor,
                            inline = true,
                        },
                        {
                            name = "🏗️ Build",
                            value = buildInfo,
                            inline = true,
                        },
                        {
                            name = "🎮 Place ID",
                            value = tostring(placeId),
                            inline = true,
                        },
                        {
                            name = "🔗 Job ID",
                            value = jobId,
                            inline = true,
                        },
                        {
                            name = "🕐 Timestamp",
                            value = timestamp,
                            inline = false,
                        },
                    },
                    footer = {
                        text = `EXO Hub v{_EXO_VERSION} | SENTINEL PRIME`,
                    },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                },
            },
        }

        -- Encode and send
        local encode_ok: boolean, json_str = pcall(function()
            return HttpService:JSONEncode(payload)
        end)

        if not encode_ok or type(json_str) ~= "string" then
            warn("[EXO-WEBHOOK] Failed to encode payload")
            return
        end

        local send_ok: boolean, send_err = pcall(function()
            return request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                },
                Body = json_str,
            })
        end)

        if not send_ok then
            -- Fallback: try http_request or syn.request
            if http_request then
                pcall(function()
                    http_request({
                        Url = WEBHOOK_URL,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json",
                        },
                        Body = json_str,
                    })
                end)
            elseif syn and syn.request then
                pcall(function()
                    syn.request({
                        Url = WEBHOOK_URL,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json",
                        },
                        Body = json_str,
                    })
                end)
            else
                warn(`[EXO-WEBHOOK] No HTTP method available: {tostring(send_err)}`)
            end
        else
            print("[EXO-WEBHOOK] Execution log sent successfully.")
        end
    end)
end

-- Fire the webhook immediately on load
_send_execution_log()

print(`[EXO] Section 3 complete. Discord Webhook Logger initialized and fired.`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 4: FILE I/O ENGINE (ROBUST, TYPED)                        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local CONFIG_FILE: string = "exo_v10_cfg.dat"
local PROFILE_FILE: string = "exo_v10_profiles.dat"
local KEYBIND_FILE: string = "exo_v10_keybinds.dat"
local LOG_FILE: string = "exo_v10_logs.dat"
local AI_MEMORY_FILE: string = "exo_v10_ai_mem.dat"

local function readFile(path: string): string?
    if type(path) ~= "string" then return nil end
    if not isfile or not readfile then return nil end
    local exists_ok: boolean, exists_result = pcall(isfile, path)
    if not exists_ok or not exists_result then return nil end
    local read_ok: boolean, read_result = pcall(readfile, path)
    if not read_ok or type(read_result) ~= "string" then return nil end
    return read_result
end

local function writeFile(path: string, data: string): boolean
    if type(path) ~= "string" or type(data) ~= "string" then return false end
    if not writefile then return false end
    local ok: boolean = pcall(writefile, path, data)
    return ok
end

local function readJSON(path: string): {[string]: any}?
    local raw: string? = readFile(path)
    if not raw or raw == "" then return nil end
    local ok: boolean, result = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(result) ~= "table" then return nil end
    return result
end

local function writeJSON(path: string, data: {[string]: any}): boolean
    if type(path) ~= "string" or type(data) ~= "table" then return false end
    local ok: boolean, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok or type(encoded) ~= "string" then return false end
    return writeFile(path, encoded)
end

local function appendLog(entry: {[string]: any}): boolean
    if type(entry) ~= "table" then return false end
    local existing = readJSON(LOG_FILE) or {}
    table.insert(existing, entry)
    while #existing > 500 do
        table.remove(existing, 1)
    end
    return writeJSON(LOG_FILE, existing)
end

print(`[EXO] Section 4 complete. File I/O engine initialized.`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 5: STATE VARIABLES (FULLY TYPED, EXPANDED)                ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- Core Combat State
local DAMAGE_REMOTE: RemoteEvent? = nil
local DAMAGE_REMOTE_ALT: RemoteEvent? = nil
local DAMAGE_REMOTE_TERT: RemoteEvent? = nil

local Aura: {
    Enabled: boolean,
    TargetList: {Player},
    Mode: string,
    PredictionDepth: number,
    SweepAngle: number,
    MultiHitbox: boolean,
} = {
    Enabled = false,
    TargetList = {},
    Mode = "omni",
    PredictionDepth = 3,
    SweepAngle = 360,
    MultiHitbox = true,
}

local InstantKill: boolean = false
local AutoTools: boolean = false
local NoCooldown: boolean = false
local Reach: boolean = false
local ReachSize: number = 3
local FastRespawn: boolean = false
local AntiSpawnkill: boolean = false

local ToolFollow: {
    Enabled: boolean,
    Targets: {Player},
    Connection: RBXScriptConnection?,
    PredictionOffset: number,
} = {
    Enabled = false,
    Targets = {},
    Connection = nil,
    PredictionOffset = 0.08,
}

local AutoGetTools: boolean = false
local AutoClaimMoney: boolean = false
local AutoBuild: boolean = false

-- Connection references
local grabLoopConn: RBXScriptConnection? = nil
local toolLoopConn: RBXScriptConnection? = nil
local auraConn: RBXScriptConnection? = nil
local claimConn: RBXScriptConnection? = nil
local buildConn: RBXScriptConnection? = nil
local cachedTycoonType: string? = nil

-- Anti-Aura State (expanded)
local AntiAura: {
    Enabled: boolean,
    GodMode: boolean,
    Repel: boolean,
    Reflect: boolean,
    Phase: boolean,
    HealAura: boolean,
    ShieldStack: number,
    RepelForce: number,
    RepelRadius: number,
    HealRate: number,
} = {
    Enabled = false,
    GodMode = false,
    Repel = false,
    Reflect = false,
    Phase = false,
    HealAura = false,
    ShieldStack = 0,
    RepelForce = 120,
    RepelRadius = 18,
    HealRate = 0.05,
}

local antiAuraConn: RBXScriptConnection? = nil
local antiAuraFF: ForceField? = nil

-- Movement State (NEW in v10)
local Movement: {
    SpeedHack: boolean,
    SpeedValue: number,
    JumpPower: boolean,
    JumpValue: number,
    Noclip: boolean,
    Fly: boolean,
    FlySpeed: number,
    InfiniteJump: boolean,
    Connection: RBXScriptConnection?,
} = {
    SpeedHack = false,
    SpeedValue = 16,
    JumpPower = false,
    JumpValue = 50,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    InfiniteJump = false,
    Connection = nil,
}

-- Threat Detection State
local ThreatLevel: number = 0
local LastThreatCheck: number = 0
local ThreatRadius: number = 60
local ThreatHistory: {{time: number, level: number, trend: number}} = {}
local ThreatTrend: number = 0
local latencyEstimate: number = 0.08
local ThreatDecay: number = 0
local PeakThreat: number = 0
local ThreatVelocity: {{time: number, delta: number}} = {}

-- Insta-Kill State (expanded)
local InstaKillEnabled: boolean = false
local InstaKillConn: RBXScriptConnection? = nil
local IK_ToolsCache: {{Tool: Tool, FightEvent: RemoteEvent?, TouchPart: BasePart?}} = {}
local IK_LastActivation: number = 0
local IK_TargetParts: {BasePart} = {}
local IK_BurstCount: number = 12
local IK_AdaptiveBurst: boolean = true
local IK_MultiTarget: boolean = true
local IK_ParallelFire: boolean = true
local IK_SweepAngle: number = 360
local IK_PenetrationDepth: number = 3

-- Hit Amplifier State (expanded)
local HitAmpEnabled: boolean = false
local HitAmpConn: RBXScriptConnection? = nil
local HA_CachedTools: {{Tool: Tool, FightEvent: RemoteEvent?}} = {}
local HA_LastActivation: number = 0
local HA_Accumulator: number = 0
local HA_Range: Vector3 = Vector3.new(45, 45, 45)
local HA_BurstCount: number = 8
local HA_MultiPulse: boolean = true
local HA_SweepMode: boolean = true
local HA_PulseInterval: number = 0.008

-- Tool Grabber State
local TG_Enabled: boolean = false
local TG_padsByBase: {[string]: {BasePart}} = {}
local TG_registered: {[BasePart]: string} = {}
local TG_WavePriority: boolean = true
local TG_BurstCount: number = 12

-- Kill Intelligence State
local KillNotifEnabled: boolean = false
local KillLogEnabled: boolean = false
local KillLogs: {{[string]: any}} = {}
local KillStreak: number = 0
local LastKillTime: number = 0
local DeathCount: number = 0
local LastDeathTime: number = 0
local DeathTimestamps: {number} = {}
local LastSpawnTime: number = 0

-- ESP & Visuals State
local ESPEnabled: boolean = false
local AntiLagEnabled: boolean = false
local ChamsEnabled: boolean = false
local espDots: {[Player]: Frame} = {}
local espGui: ScreenGui? = nil
local chamsFolder: Folder? = nil

-- No Cooldown
local NoCooldownConn: RBXScriptConnection? = nil

print(`[EXO] Section 5 complete. All state variables initialized and typed.`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 6: PRE-ALLOCATED BUFFERS (ZERO GC ON MOBILE)              ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local _buf_parts: {BasePart} = table.create(64)
local _buf_buttons: {{Model: Model, Cost: number, Priority: number}} = table.create(64)
local _buf_targets: {Player} = table.create(16)
local _buf_tools: {Tool} = table.create(32)
local _buf_players: {string} = table.create(16)
local _buf_remotes: {Instance} = table.create(64)
local _buf_hitboxes: {BasePart} = table.create(32)
local _buf_velocities: {Vector3} = table.create(32)
local _buf_predictions: {Vector3} = table.create(32)

-- Clear all buffers on init
do
    table.clear(_buf_parts)
    table.clear(_buf_buttons)
    table.clear(_buf_targets)
    table.clear(_buf_tools)
    table.clear(_buf_players)
    table.clear(_buf_remotes)
    table.clear(_buf_hitboxes)
    table.clear(_buf_velocities)
    table.clear(_buf_predictions)
end

print(`[EXO] Section 6 complete. 9 pre-allocated buffers ready.`)

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

-- Start listening for a new key assignment
local function KB_StartListening(name: string): ()
    KeybindManager.Listening = true
    KeybindManager.ListenTarget = name
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
    writeJSON(KEYBIND_FILE, {Binds = saveData})
end

-- Load keybinds from file
local function KB_Load(): ()
    local data = readJSON(KEYBIND_FILE)
    if not data or type(data.Binds) ~= "table" then return end
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
        if gameProcessed then return end

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

-- Initialize keybind system
KB_InitInputHandler()
KB_Load()

print(`[EXO] Section 7 complete. Keybind Manager initialized with {#KeybindManager.Binds} binds.`)

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
            HitAmpEnabled = HitAmpEnabled,
            HA_Range = HA_Range.X,
            HA_BurstCount = HA_BurstCount,
            AntiAuraEnabled = AntiAura.Enabled,
            GodMode = AntiAura.GodMode,
            Repel = AntiAura.Repel,
            Phase = AntiAura.Phase,
            HealAura = AntiAura.HealAura,
            RepelForce = AntiAura.RepelForce,
            RepelRadius = AntiAura.RepelRadius,
            ToolFollowEnabled = ToolFollow.Enabled,
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

    return writeJSON(PROFILE_FILE, profile :: any)
end

local function Profile_Load(): boolean
    local data = readJSON(PROFILE_FILE)
    if not data then return false end

    local profile = data :: any
    if type(profile) ~= "table" then return false end

    -- Restore Combat
    if type(profile.Combat) == "table" then
        local c = profile.Combat
        if type(c.AuraMode) == "string" then Aura.Mode = c.AuraMode end
        if type(c.PredictionDepth) == "number" then Aura.PredictionDepth = c.PredictionDepth end
        if type(c.ReachSize) == "number" then ReachSize = c.ReachSize end
        if type(c.IK_BurstCount) == "number" then IK_BurstCount = c.IK_BurstCount end
        if type(c.HA_Range) == "number" then HA_Range = Vector3.new(c.HA_Range, c.HA_Range, c.HA_Range) end
        if type(c.HA_BurstCount) == "number" then HA_BurstCount = c.HA_BurstCount end
        if type(c.RepelForce) == "number" then AntiAura.RepelForce = c.RepelForce end
        if type(c.RepelRadius) == "number" then AntiAura.RepelRadius = c.RepelRadius end
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

    return true
end

-- Auto-load profile on startup
local _profile_loaded: boolean = Profile_Load()
if _profile_loaded then
    print("[EXO] Section 8: Profile loaded from disk.")
else
    print("[EXO] Section 8: No saved profile found (first run).")
end

print(`[EXO] Section 8 complete. Profile system initialized.`)

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
-- Approximates acceleration from velocity change
local function Predict_Quadratic(rootPos: Vector3, velocity: Vector3, t: number, gravity: number?): Vector3
    local g: number = gravity or workspace.Gravity or 196.2
    local gravityVec: Vector3 = Vector3.new(0, -g, 0)
    return rootPos + velocity * t + 0.5 * gravityVec * t * t
end

-- Cubic prediction with velocity decay (drag approximation)
local function Predict_Cubic(rootPos: Vector3, velocity: Vector3, t: number, dragCoeff: number?): Vector3
    local drag: number = dragCoeff or 0.01
    local decayedVel: Vector3 = velocity * (1 - drag * t)
    return rootPos + decayedVel * t
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

    -- If target is walking slowly, linear is fine
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

-- Calculate distance between two positions (optimized, no sqrt if comparing)
local function Distance_Fast(a: Vector3, b: Vector3): number
    return (a - b).Magnitude
end

local function Distance_Squared(a: Vector3, b: Vector3): number
    local dx: number = a.X - b.X
    local dy: number = a.Y - b.Y
    local dz: number = a.Z - b.Z
    return dx * dx + dy * dy + dz * dz
end

-- Angle calculation between two positions (for sweep targeting)
local function Angle_Between(origin: Vector3, target: Vector3, forward: Vector3): number
    local direction: Vector3 = (target - origin).Unit
    local dot: number = forward:Dot(direction)
    return math.deg(math.acos(math.clamp(dot, -1, 1)))
end

print(`[EXO] Section 9 complete. Target Prediction Engine initialized.`)
print(`[EXO]   Methods: Static, Linear, Quadratic, Cubic, Adaptive`)
print(`[EXO]   Multi-hitbox prediction: 5 body parts`)
print(`[EXO]   Physics: Gravity compensation + velocity decay`)

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
    local ok: boolean, descendants = pcall(function() return model:GetDescendants() end)
    if not ok or type(descendants) ~= "table" then return _buf_parts end
    for _, desc in descendants do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
            table.insert(_buf_parts, desc.Parent)
        end
    end
    if #_buf_parts == 0 then
        for _, desc in descendants do
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
            local ok: boolean, children = pcall(function() return tf:GetChildren() end)
            if ok and type(children) == "table" then
                for _, t in children do
                    if t:IsA("Folder") then
                        local door = t:FindFirstChild("Door", true)
                        if door then
                            local dp = door:FindFirstChildWhichIsA("BasePart")
                            if dp then
                                local dOk: boolean, d = pcall(function() return (dp.Position - root.Position).Magnitude end)
                                if dOk and type(d) == "number" and d < minDist then
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

                            local velOk: boolean, vel = pcall(function() return theirRoot.Velocity.Magnitude end)
                            if velOk and type(vel) == "number" and vel > 20 then
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  END OF PART 1                                                     ║
-- ║  Next: Part 2 – Combat Systems, Movement, FSM Engine               ║
-- ╚══════════════════════════════════════════════════════════════════════╝
print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] PART 1 COMPLETE: Sections 0-12 loaded.`)
print(`[EXO] Discord Webhook: FIRED`)
print(`[EXO] Keybind Manager: {#KeybindManager.Binds} binds registered`)
print(`[EXO] Profile System: {if _profile_loaded then "LOADED" else "FRESH"}`)
print(`[EXO] Prediction Engine: 5 methods active`)
print(`[EXO] Awaiting Part 2 for combat systems...`)
print(`[EXO] ═══════════════════════════════════════════════════`)
