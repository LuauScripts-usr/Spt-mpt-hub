--!strict
-- ═══════════════════════════════════════════════════════════════════════════
--  ███████╗██╗  ██╗ ██████╗     ██╗  ██╗ █████╗ ██╗   ██╗██████╗  ██████╗
--  ██╔════╝╚██╗██╔╝██╔═══██╗    ██║  ██║██╔══██╗██║   ██║██╔══██╗██╔═══██╗
--  █████╗   ╚███╔╝ ██║   ██║    ███████║███████║██║   ██║██║  ██║██║   ██║
--  ██╔══╝   ██╔██╗ ██║   ██║    ██╔══██║██╔══██║██║   ██║██║  ██║██║   ██║
--  ███████╗██╔╝ ██╗╚██████╝    ██║  ██║██║  ██║╚██████╝██████╔╝╚██████╔╝
--  ╚══════╝╚═╝  ╚═╝ ╚═════╝     ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝
--
--  EXO HUB v11.0 – SENTINEL PRIME NOVA
--  100% STRICT LUAU | NOVAUI CORE | DISCORD LOGGER | KEYBIND MANAGER
--  TARGET PREDICTION | PROFILE SAVING | MOBILE OPTIMIZED | LEAK-SAFE CONNS
--  PRE-ALLOCATED BUFFERS | TASK.* ONLY | do...end REGISTER ENCAPSULATION
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══ WEBHOOK CONFIG (SET AT TOP AS REQUIRED) ═══
local WEBHOOK_URL: string = "https://discord.com/api/webhooks/1537879404888326234/Q2JGytYToyPRLUc_l54U3eyXMC8LLX72LdsICThXglNZ9P-omOhy3uhqYAPCappdqPX-"

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 0: ANTI-TAMPER INTEGRITY (LIGHTWEIGHT, STRICT)             ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local _EXO_VERSION: number = 11.0
local _EXO_BUILD: string = "SENTINEL_PRIME_NOVA"
local _EXO_INTEGRITY: boolean = true
local _EXO_INTEGRITY_LOG: {string} = table.create(8)

do
	local layer_ok: boolean = pcall(function()
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
		if not task.spawn or not task.defer or not task.wait then
			table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: task.* incomplete")
			_EXO_INTEGRITY = false
			return
		end
		if not table.create or not table.clear then
			table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: table.create/clear missing")
			_EXO_INTEGRITY = false
			return
		end
	end)
	if not layer_ok then
		table.insert(_EXO_INTEGRITY_LOG, "L1_EXCEPTION: pcall fault")
		_EXO_INTEGRITY = false
	end
end

if not _EXO_INTEGRITY then
	warn("[EXO] INTEGRITY CHECK FAILED - ABORTING")
	for _, msg: string in _EXO_INTEGRITY_LOG do
		warn("[EXO]   " .. msg)
	end
	return
end

print(`[EXO] Section 0 complete. Integrity PASSED. v{_EXO_VERSION} {_EXO_BUILD}`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 1: LIGHT OBFUSCATION ENGINE (GITHUB-SAFE, STRICT)          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local _xor_key: string = "EXO11NOVA"
local _xor_cache: {[string]: string} = {}

local function _xor_transform(input: string): string
	local cached: string? = _xor_cache[input]
	if cached then
		return cached
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

local function _split_join(parts: {string}, sep: string?): string
	if sep then
		return table.concat(parts, sep)
	end
	return table.concat(parts)
end

local function _obf(str: string): string
	local chunks: {string} = table.create(8)
	local chunkSize: number = 4
	for i = 1, #str, chunkSize do
		table.insert(chunks, str:sub(i, math.min(i + chunkSize - 1, #str)))
	end
	return table.concat(chunks)
end

local function _hash(str: string): number
	local h: number = 0x45584F39
	for i = 1, #str do
		h = ((h * 31) + str:byte(i)) % 0x7FFFFFFF
	end
	return h
end

print(`[EXO] Section 1 complete. Light obfuscation engine loaded (xor+split+hash).`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 2: SERVICES + EXECUTOR CAPABILITY PROBE (STRICT TYPED)     ║
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

-- Executor environment probe (strict-safe via getfenv cast)
local _env: any = getfenv() :: any
local _fn_request: any = _env.request or _env.http_request or (_env.syn and _env.syn.request)
local _fn_identify: any = _env.identifyexecutor or _env.getexecutorname
local _fn_isfile: any = _env.isfile
local _fn_readfile: any = _env.readfile
local _fn_writefile: any = _env.writefile
local _fn_delfile: any = _env.delfile
local _fn_makefolder: any = _env.makefolder
local _fn_isfolder: any = _env.isfolder
local _fn_setclipboard: any = _env.setclipboard
local _fn_firetouch: any = _env.firetouchinterest

do
	local svc_ok: boolean = pcall(function()
		if not Players then _EXO_INTEGRITY = false end
		if not RunService then _EXO_INTEGRITY = false end
		if not player then _EXO_INTEGRITY = false end
		if not UserInputService then _EXO_INTEGRITY = false end
		if not HttpService then _EXO_INTEGRITY = false end
		if not TweenService then _EXO_INTEGRITY = false end
	end)
	if not svc_ok or not _EXO_INTEGRITY then
		warn("[EXO] SERVICE VALIDATION FAILED - ABORTING")
		return
	end
end

print(`[EXO] Section 2 complete. Services loaded. request={type(_fn_request)} files={type(_fn_writefile)} touch={type(_fn_firetouch)}`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 3: DISCORD WEBHOOK EXECUTION LOGGER (NON-BLOCKING)         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function _detect_platform(): string
	local platform: string = "Unknown"
	local ok: boolean = pcall(function()
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			local cam: Camera? = workspace.CurrentCamera
			local viewportSize: Vector2 = (cam and cam.ViewportSize) or Vector2.new(0, 0)
			if viewportSize.Y > 700 then
				platform = "Tablet"
			else
				platform = "Mobile"
			end
		elseif UserInputService.KeyboardEnabled then
			platform = "PC"
		else
			local ok2: boolean = pcall(function()
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

local function _detect_executor(): string
	if type(_fn_identify) == "function" then
		local ok: boolean, result = pcall(_fn_identify)
		if ok and type(result) == "string" and #result > 0 then
			return result
		end
	end
	return "Unknown"
end

local function _send_execution_log(): ()
	task.spawn(function()
		if type(_fn_request) ~= "function" then
			warn("[EXO-WEBHOOK] No HTTP request method available. Log skipped.")
			return
		end
		local username: string = player.Name or "Unknown"
		local displayName: string = player.DisplayName or username
		local userId: number = player.UserId or 0
		local placeId: number = game.PlaceId or 0
		local jobId: string = game.JobId or "N/A"
		local platform: string = _detect_platform()
		local executor: string = _detect_executor()
		local timestamp: string = os.date("%Y-%m-%d %H:%M:%S UTC") :: string
		local buildInfo: string = `v{_EXO_VERSION} | {_EXO_BUILD}`

		local payload: {[string]: any} = {
			embeds = {
				{
					title = "🚀 EXO Hub Execution Log",
					description = "Script hub executed successfully.",
					color = 0x7C5CFF, -- NovaUI accent (purple)
					fields = {
						{ name = "👤 Username", value = username, inline = true },
						{ name = "📛 Display Name", value = displayName, inline = true },
						{ name = "🔢 User ID", value = tostring(userId), inline = true },
						{ name = "📱 Platform", value = platform, inline = true },
						{ name = "⚙️ Executor", value = executor, inline = true },
						{ name = "🏗️ Build", value = buildInfo, inline = true },
						{ name = "🎮 Place ID", value = tostring(placeId), inline = true },
						{ name = "🔗 Job ID", value = jobId, inline = true },
						{ name = "🕐 Timestamp", value = timestamp, inline = false },
					},
					footer = { text = `EXO Hub v{_EXO_VERSION} | SENTINEL PRIME NOVA` },
					timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
				},
			},
		}

		local encode_ok: boolean, json_str = pcall(function()
			return HttpService:JSONEncode(payload)
		end)
		if not encode_ok or type(json_str) ~= "string" then
			warn("[EXO-WEBHOOK] Failed to encode payload")
			return
		end

		local send_ok: boolean = pcall(function()
			_fn_request({
				Url = WEBHOOK_URL,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = json_str,
			})
		end)
		if send_ok then
			print("[EXO-WEBHOOK] Execution log sent successfully.")
		else
			warn("[EXO-WEBHOOK] Send failed.")
		end
	end)
end

-- Fire on load (startup requirement)
_send_execution_log()
print(`[EXO] Section 3 complete. Webhook logger fired. Platform: {_detect_platform()} | Executor: {_detect_executor()}`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 4: FILE I/O ENGINE (ROBUST, STRICT TYPED)                  ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local CONFIG_FILE: string = "exo_v11_cfg.dat"
local PROFILE_FILE: string = "exo_v11_profiles.dat"
local KEYBIND_FILE: string = "exo_v11_keybinds.dat"
local LOG_FILE: string = "exo_v11_logs.dat"
local AI_MEMORY_FILE: string = "exo_v11_ai_mem.dat"

local function readFile(path: string): string?
	if type(path) ~= "string" then return nil end
	if type(_fn_isfile) ~= "function" or type(_fn_readfile) ~= "function" then return nil end
	local exists_ok: boolean, exists_result = pcall(_fn_isfile, path)
	if not exists_ok or not exists_result then return nil end
	local read_ok: boolean, read_result = pcall(_fn_readfile, path)
	if not read_ok or type(read_result) ~= "string" then return nil end
	return read_result
end

local function writeFile(path: string, data: string): boolean
	if type(path) ~= "string" or type(data) ~= "string" then return false end
	if type(_fn_writefile) ~= "function" then return false end
	local ok: boolean = pcall(_fn_writefile, path, data)
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

local function deleteFile(path: string): boolean
	if type(path) ~= "string" then return false end
	if type(_fn_delfile) ~= "function" then return false end
	local ok: boolean = pcall(_fn_delfile, path)
	return ok
end

print(`[EXO] Section 4 complete. File I/O engine initialized (strict, env-probed).`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 5: STATE VARIABLES (FULLY TYPED, EXPANDED FOR v11)         ║
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
	TargetList = table.create(16),
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
	Targets = table.create(16),
	Connection = nil,
	PredictionOffset = 0.08,
}

local AutoGetTools: boolean = false
local AutoClaimMoney: boolean = false
local AutoBuild: boolean = false

-- Connection references (legacy refs kept for compat)
local grabLoopConn: RBXScriptConnection? = nil
local toolLoopConn: RBXScriptConnection? = nil
local auraConn: RBXScriptConnection? = nil
local claimConn: RBXScriptConnection? = nil
local buildConn: RBXScriptConnection? = nil
local cachedTycoonType: string? = nil

-- Anti-Aura State
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

-- Movement State
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
local ThreatHistory: {{time: number, level: number, trend: number}} = table.create(60)
local ThreatTrend: number = 0
local latencyEstimate: number = 0.08
local ThreatDecay: number = 0
local PeakThreat: number = 0
local ThreatVelocity: {{time: number, delta: number}} = table.create(30)

-- Insta-Kill State
local InstaKillEnabled: boolean = false
local InstaKillConn: RBXScriptConnection? = nil
local IK_ToolsCache: {{Tool: Tool, FightEvent: RemoteEvent?, TouchPart: BasePart?}} = table.create(8)
local IK_LastActivation: number = 0
local IK_TargetParts: {BasePart} = table.create(9)
local IK_BurstCount: number = 12
local IK_AdaptiveBurst: boolean = true
local IK_MultiTarget: boolean = true
local IK_ParallelFire: boolean = true
local IK_SweepAngle: number = 360
local IK_PenetrationDepth: number = 3

-- Hit Amplifier State
local HitAmpEnabled: boolean = false
local HitAmpConn: RBXScriptConnection? = nil
local HA_CachedTools: {{Tool: Tool, FightEvent: RemoteEvent?}} = table.create(8)
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
local KillLogs: {{[string]: any}} = table.create(100)
local KillStreak: number = 0
local LastKillTime: number = 0
local DeathCount: number = 0
local LastDeathTime: number = 0
local DeathTimestamps: {number} = table.create(20)
local LastSpawnTime: number = 0

-- Visuals State (v11: ColorPicker-customizable)
local ESPEnabled: boolean = false
local AntiLagEnabled: boolean = false
local ChamsEnabled: boolean = false
local espDots: {[Player]: Frame} = {}
local espGui: ScreenGui? = nil
local chamsFolder: Folder? = nil

-- v11 NEW: ESP/Chams color customization (driven by native ColorPicker)
local ESPColors: {
	Close: Color3,
	Mid: Color3,
	Far: Color3,
	NameTag: Color3,
} = {
	Close = Color3.fromRGB(255, 0, 0),
	Mid = Color3.fromRGB(255, 150, 0),
	Far = Color3.fromRGB(0, 255, 100),
	NameTag = Color3.fromRGB(230, 240, 255),
}
local ChamsColor: Color3 = Color3.fromRGB(124, 92, 255)
local ESPDistanceClose: number = 15
local ESPDistanceMid: number = 30

-- v11 NEW: NovaUI theme flags
local UITheme: {
	DropShadows: boolean,
	Accent: Color3,
	ShowActiveHighlights: boolean,
} = {
	DropShadows = true,
	Accent = Color3.fromRGB(124, 92, 255),
	ShowActiveHighlights = true,
}

-- NovaUI module placeholder (loaded in Part 7)
local NovaUI: any? = nil
local AdminUI: any? = nil

-- No Cooldown
local NoCooldownConn: RBXScriptConnection? = nil

print(`[EXO] Section 5 complete. All state variables initialized and typed (v11 expanded).`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 6: PRE-ALLOCATED BUFFERS + CONNECTION REGISTRY (LEAK-SAFE) ║
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

-- v11 NEW: Connection Registry (prevents input/connection leaks)
-- Every loop/drag listener registers under a tag; tags can be torn down cleanly.
local ConnRegistry: {[string]: {RBXScriptConnection}} = {}

local function Conn_Register(tag: string, conn: RBXScriptConnection): RBXScriptConnection
	local bucket = ConnRegistry[tag]
	if not bucket then
		bucket = table.create(4)
		ConnRegistry[tag] = bucket
	end
	table.insert(bucket, conn)
	return conn
end

local function Conn_DisconnectTag(tag: string): number
	local bucket = ConnRegistry[tag]
	if not bucket then
		return 0
	end
	local count: number = 0
	for _, conn: RBXScriptConnection in bucket do
		if conn.Connected then
			conn:Disconnect()
			count += 1
		end
	end
	table.clear(bucket)
	return count
end

local function Conn_DisconnectAll(): number
	local total: number = 0
	for tag: string, _ in ConnRegistry do
		total += Conn_DisconnectTag(tag)
	end
	return total
end

-- Expose registry for later parts (UI drag listeners, loops)
_G.EXO_Conn_Register = Conn_Register
_G.EXO_Conn_DisconnectTag = Conn_DisconnectTag
_G.EXO_Conn_DisconnectAll = Conn_DisconnectAll

print(`[EXO] Section 6 complete. 9 buffers pre-allocated + Connection Registry active (leak-safe).`)

-- ═══ PART 1 CLOSING ═══
print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] PART 1 COMPLETE (Sections 0–6)`)
print(`[EXO] Webhook: FIRED | Integrity: PASSED | Buffers: 9 | Conns: LEAK-SAFE`)
print(`[EXO] Next: Part 2 – Keybind Engine, Profiles, Prediction, Helpers,`)
print(`[EXO]       Scans, Threat, UI Registry`)
print(`[EXO] ═══════════════════════════════════════════════════`)
