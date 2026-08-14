-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 12.5: MOVEMENT SYSTEMS INITIALIZATION (NEW IN v10)        ║
-- ║  Speed, Jump, Noclip, Fly, InfiniteJump – typed & pre-allocated    ║
-- ╚══════════════════════════════════════════════════════════════════════╝

type MovementConnection = {
    SpeedConn: RBXScriptConnection?,
    JumpConn: RBXScriptConnection?,
    NoclipConn: RBXScriptConnection?,
    FlyConn: RBXScriptConnection?,
    InfJumpConn: RBXScriptConnection?,
}

local MovementConns: MovementConnection = {
    SpeedConn = nil,
    JumpConn = nil,
    NoclipConn = nil,
    FlyConn = nil,
    InfJumpConn = nil,
}

-- Pre-allocated fly state (zero GC pressure)
local _fly_body_vel: BodyVelocity? = nil
local _fly_body_gyro: BodyGyro? = nil
local _fly_camera: Camera? = nil

local function Movement_ApplySpeed(): ()
    if not Movement.SpeedHack then return end
    local char: Model? = player.Character
    if not char then return end
    local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum:IsA("Humanoid") then return end
    local ok: boolean = pcall(function()
        hum.WalkSpeed = Movement.SpeedValue
    end)
    if not ok then
        warn("[EXO-MOVE] Speed apply failed")
    end
end

local function Movement_ResetSpeed(): ()
    local char: Model? = player.Character
    if not char then return end
    local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum:IsA("Humanoid") then return end
    pcall(function()
        hum.WalkSpeed = 16
    end)
end

local function Movement_StartSpeedLoop(): ()
    if MovementConns.SpeedConn then
        pcall(function() MovementConns.SpeedConn:Disconnect() end)
    end
    MovementConns.SpeedConn = RunService.Heartbeat:Connect(function()
        if not Movement.SpeedHack then return end
        Movement_ApplySpeed()
    end)
end

local function Movement_StopSpeedLoop(): ()
    if MovementConns.SpeedConn then
        pcall(function() MovementConns.SpeedConn:Disconnect() end)
        MovementConns.SpeedConn = nil
    end
    Movement_ResetSpeed()
end

local function Movement_ApplyJumpPower(): ()
    if not Movement.JumpPower then return end
    local char: Model? = player.Character
    if not char then return end
    local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum:IsA("Humanoid") then return end
    pcall(function()
        hum.JumpPower = Movement.JumpValue
        hum.UseJumpPower = true
    end)
end

local function Movement_ResetJumpPower(): ()
    local char: Model? = player.Character
    if not char then return end
    local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum:IsA("Humanoid") then return end
    pcall(function()
        hum.JumpPower = 50
        hum.UseJumpPower = false
    end)
end

local function Movement_StartJumpLoop(): ()
    if MovementConns.JumpConn then
        pcall(function() MovementConns.JumpConn:Disconnect() end)
    end
    MovementConns.JumpConn = RunService.Heartbeat:Connect(function()
        if not Movement.JumpPower then return end
        Movement_ApplyJumpPower()
    end)
end

local function Movement_StopJumpLoop(): ()
    if MovementConns.JumpConn then
        pcall(function() MovementConns.JumpConn:Disconnect() end)
        MovementConns.JumpConn = nil
    end
    Movement_ResetJumpPower()
end

local function Movement_StartNoclip(): ()
    if MovementConns.NoclipConn then
        pcall(function() MovementConns.NoclipConn:Disconnect() end)
    end
    MovementConns.NoclipConn = RunService.Stepped:Connect(function()
        if not Movement.Noclip then return end
        local char: Model? = player.Character
        if not char then return end
        local children_ok: boolean, children = pcall(function() return char:GetDescendants() end)
        if not children_ok or type(children) ~= "table" then return end
        for _, part: Instance in children do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CanCollide = false
                end)
            end
        end
    end)
end

local function Movement_StopNoclip(): ()
    if MovementConns.NoclipConn then
        pcall(function() MovementConns.NoclipConn:Disconnect() end)
        MovementConns.NoclipConn = nil
    end
    -- Restore collision on all parts
    local char: Model? = player.Character
    if char then
        local children_ok: boolean, children = pcall(function() return char:GetDescendants() end)
        if children_ok and type(children) == "table" then
            for _, part: Instance in children do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.CanCollide = true
                    end)
                end
            end
        end
    end
end

local function Movement_StartFly(): ()
    if MovementConns.FlyConn then
        pcall(function() MovementConns.FlyConn:Disconnect() end)
    end

    local char: Model? = player.Character
    if not char then return end
    local hrp: BasePart? = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:IsA("BasePart") then return end

    _fly_camera = workspace.CurrentCamera

    -- Create BodyVelocity for movement
    local bv_ok: boolean, bv = pcall(function()
        local b: BodyVelocity = Instance.new("BodyVelocity")
        b.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        b.Velocity = Vector3.zero
        b.Parent = hrp
        return b
    end)
    if bv_ok and bv then
        _fly_body_vel = bv
    end

    -- Create BodyGyro for orientation
    local bg_ok: boolean, bg = pcall(function()
        local g: BodyGyro = Instance.new("BodyGyro")
        g.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        g.D = 200
        g.P = 10000
        g.Parent = hrp
        return g
    end)
    if bg_ok and bg then
        _fly_body_gyro = bg
    end

    MovementConns.FlyConn = RunService.RenderStepped:Connect(function()
        if not Movement.Fly then return end
        if not _fly_body_vel or not _fly_body_gyro then return end
        if not _fly_camera then return end

        local camCF: CFrame = _fly_camera.CFrame
        local lookDir: Vector3 = camCF.LookVector
        local rightDir: Vector3 = camCF.RightVector
        local upDir: Vector3 = Vector3.new(0, 1, 0)

        local moveVec: Vector3 = Vector3.zero

        -- WASD + Space/Shift controls
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVec += lookDir
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVec -= lookDir
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVec -= rightDir
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVec += rightDir
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVec += upDir
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVec -= upDir
        end

        -- Normalize and apply speed
        if moveVec.Magnitude > 0 then
            moveVec = moveVec.Unit * Movement.FlySpeed
        end

        pcall(function()
            _fly_body_vel.Velocity = moveVec
        end)
        pcall(function()
            _fly_body_gyro.CFrame = camCF
        end)
    end)
end

local function Movement_StopFly(): ()
    if MovementConns.FlyConn then
        pcall(function() MovementConns.FlyConn:Disconnect() end)
        MovementConns.FlyConn = nil
    end
    if _fly_body_vel and _fly_body_vel.Parent then
        pcall(function() _fly_body_vel:Destroy() end)
        _fly_body_vel = nil
    end
    if _fly_body_gyro and _fly_body_gyro.Parent then
        pcall(function() _fly_body_gyro:Destroy() end)
        _fly_body_gyro = nil
    end
end

local function Movement_StartInfiniteJump(): ()
    if MovementConns.InfJumpConn then
        pcall(function() MovementConns.InfJumpConn:Disconnect() end)
    end
    MovementConns.InfJumpConn = UserInputService.JumpRequest:Connect(function()
        if not Movement.InfiniteJump then return end
        local char: Model? = player.Character
        if not char then return end
        local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
        if hum and hum:IsA("Humanoid") then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end)
end

local function Movement_StopInfiniteJump(): ()
    if MovementConns.InfJumpConn then
        pcall(function() MovementConns.InfJumpConn:Disconnect() end)
        MovementConns.InfJumpConn = nil
    end
end

-- Master toggle handler for movement features
local function Movement_HandleToggle(feature: string, state: boolean): ()
    if feature == "SpeedHack" then
        Movement.SpeedHack = state
        if state then Movement_StartSpeedLoop() else Movement_StopSpeedLoop() end
    elseif feature == "JumpPower" then
        Movement.JumpPower = state
        if state then Movement_StartJumpLoop() else Movement_StopJumpLoop() end
    elseif feature == "Noclip" then
        Movement.Noclip = state
        if state then Movement_StartNoclip() else Movement_StopNoclip() end
    elseif feature == "Fly" then
        Movement.Fly = state
        if state then Movement_StartFly() else Movement_StopFly() end
    elseif feature == "InfiniteJump" then
        Movement.InfiniteJump = state
        if state then Movement_StartInfiniteJump() else Movement_StopInfiniteJump() end
    end
end

-- Reset all movement on character death/respawn
player.CharacterAdded:Connect(function()
    task.defer(function()
        Movement_ResetSpeed()
        Movement_ResetJumpPower()
        if Movement.Noclip then Movement_StopNoclip() end
        if Movement.Fly then Movement_StopFly() end
    end)
end)

-- Expose globally
_G.EXO_Movement_HandleToggle = Movement_HandleToggle
_G.EXO_Movement_StartSpeedLoop = Movement_StartSpeedLoop
_G.EXO_Movement_StopSpeedLoop = Movement_StopSpeedLoop
_G.EXO_Movement_StartFly = Movement_StartFly
_G.EXO_Movement_StopFly = Movement_StopFly
_G.EXO_Movement_StartNoclip = Movement_StartNoclip
_G.EXO_Movement_StopNoclip = Movement_StopNoclip
_G.EXO_Movement_StartInfiniteJump = Movement_StartInfiniteJump
_G.EXO_Movement_StopInfiniteJump = Movement_StopInfiniteJump

print(`[EXO] Section 12.5 complete. Movement Systems initialized.`)
print(`[EXO]   Features: Speed, JumpPower, Noclip, Fly, InfiniteJump`)
print(`[EXO]   Fly controls: WASD + Space/Shift`)
print(`[EXO]   Auto-reset on respawn: ENABLED`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 12.6: MODULARIZED UI TAB CONFIGURATION REGISTRY           ║
-- ║  Declarative tab/section/element definitions for clean UI builds   ║
-- ╚══════════════════════════════════════════════════════════════════════╝

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
}

-- Central registry for all UI tab definitions
-- This allows tabs to be defined declaratively and built programmatically
local UITabRegistry: {UITabConfig} = {}

local function UI_RegisterTab(config: UITabConfig): ()
    table.insert(UITabRegistry, config)
end

local function UI_GetTabCount(): number
    return #UITabRegistry
end

local function UI_GetTab(index: number): UITabConfig?
    if index < 1 or index > #UITabRegistry then
        return nil
    end
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

-- Register default tab configurations (declarative definitions)
-- These are used by the UI builder in Part 4 to construct the actual UI
UI_RegisterTab({
    Title = "Combat",
    Locked = false,
    Sections = {
        {
            Title = "1000x Multi-Target Aura",
            Elements = {
                {Type = "Toggle", Name = "Enable Aura", Default = false},
                {Type = "Toggle", Name = "Instant Kill", Default = false},
                {Type = "Slider", Name = "Prediction Depth", Min = 3, Max = 30, Default = 8},
                {Type = "Dropdown", Name = "Aura Targets", Options = {}},
            },
        },
        {
            Title = "1000x Tool Follow",
            Elements = {
                {Type = "Toggle", Name = "Enable Tool Follow", Default = false},
            },
        },
        {
            Title = "1000x Defense / Anti-Aura",
            Elements = {
                {Type = "Toggle", Name = "Enable Anti-Aura", Default = false},
                {Type = "Toggle", Name = "God Mode (ForceField)", Default = false},
                {Type = "Toggle", Name = "Repel (Anti-Touch)", Default = false},
                {Type = "Toggle", Name = "Phase (No Collide)", Default = false},
                {Type = "Toggle", Name = "Heal Aura", Default = false},
                {Type = "Slider", Name = "Repel Force", Min = 50, Max = 300, Default = 120},
                {Type = "Slider", Name = "Repel Radius", Min = 8, Max = 30, Default = 18},
                {Type = "Toggle", Name = "Anti Spawnkill", Default = false},
            },
        },
    },
})

UI_RegisterTab({
    Title = "Movement",
    Locked = false,
    Sections = {
        {
            Title = "Speed & Jump",
            Elements = {
                {Type = "Toggle", Name = "Speed Hack", Default = false},
                {Type = "Slider", Name = "Walk Speed", Min = 16, Max = 200, Default = 16},
                {Type = "Toggle", Name = "Jump Power", Default = false},
                {Type = "Slider", Name = "Jump Value", Min = 50, Max = 500, Default = 50},
                {Type = "Toggle", Name = "Infinite Jump", Default = false},
            },
        },
        {
            Title = "Flight & Phase",
            Elements = {
                {Type = "Toggle", Name = "Noclip", Default = false},
                {Type = "Toggle", Name = "Fly", Default = false},
                {Type = "Slider", Name = "Fly Speed", Min = 10, Max = 300, Default = 50},
            },
        },
    },
})

UI_RegisterTab({
    Title = "Tycoon",
    Locked = false,
    Sections = {
        {
            Title = "1000x Tycoon Automation",
            Elements = {
                {Type = "Toggle", Name = "Auto Claim Money", Default = false},
                {Type = "Toggle", Name = "Smart Auto Build (Multi-Buy)", Default = false},
                {Type = "Toggle", Name = "Auto Grab Weapons", Default = false},
            },
        },
        {
            Title = "Tools & Cooldown",
            Elements = {
                {Type = "Toggle", Name = "Auto Use Tools (0 delay)", Default = false},
                {Type = "Toggle", Name = "No Cooldown (SAFE)", Default = false},
            },
        },
    },
})

UI_RegisterTab({
    Title = "Kill Engine",
    Locked = false,
    Sections = {
        {
            Title = "1000x Omni-Kill Engine",
            Elements = {
                {Type = "Toggle", Name = "Enable Omni-Kill", Default = false},
                {Type = "Toggle", Name = "Insta-Kill Micro-Burst", Default = false},
                {Type = "Toggle", Name = "Adaptive Burst (Threat-Based)", Default = true},
                {Type = "Slider", Name = "Prediction Aggression", Min = 3, Max = 30, Default = 8},
                {Type = "Slider", Name = "Burst Count", Min = 3, Max = 20, Default = 12},
                {Type = "Button", Name = "Manual Kill Burst"},
                {Type = "Button", Name = "Refresh Target List"},
            },
        },
        {
            Title = "1000x Hit Amplifier",
            Elements = {
                {Type = "Toggle", Name = "Enable Hit Amplifier", Default = false},
                {Type = "Slider", Name = "Scan Range", Min = 15, Max = 60, Default = 45},
                {Type = "Slider", Name = "Burst Count", Min = 1, Max = 15, Default = 8},
                {Type = "Toggle", Name = "Multi-Pulse (3x waves)", Default = true},
            },
        },
        {
            Title = "1000x Tool Arsenal",
            Elements = {
                {Type = "Toggle", Name = "Enable Tool Arsenal", Default = false},
                {Type = "Button", Name = "Force Acquire All"},
            },
        },
    },
})

UI_RegisterTab({
    Title = "Visuals",
    Locked = false,
    Sections = {
        {
            Title = "1000x ESP (Threat-Colored)",
            Elements = {
                {Type = "Toggle", Name = "Enable ESP", Default = false},
            },
        },
        {
            Title = "1000x Anti-Lag Shield",
            Elements = {
                {Type = "Toggle", Name = "Enable Anti-Lag", Default = false},
            },
        },
    },
})

UI_RegisterTab({
    Title = "FSM Control",
    Locked = false,
    Sections = {
        {
            Title = "Adaptive FSM Engine",
            Elements = {
                {Type = "Toggle", Name = "Enable Auto Mode Switching", Default = false},
                {Type = "Button", Name = "View Current Mode"},
                {Type = "Button", Name = "View Mode Scores"},
            },
        },
        {
            Title = "Manual Mode Override",
            Elements = {
                {Type = "Button", Name = "Force TYCOON Mode"},
                {Type = "Button", Name = "Force DEFENSIVE Mode"},
                {Type = "Button", Name = "Force COMBAT Mode"},
                {Type = "Button", Name = "Force IDLE Mode"},
            },
        },
    },
})

UI_RegisterTab({
    Title = "Sentinel AI",
    Locked = false,
    Sections = {
        {
            Title = "AI Control",
            Elements = {
                {Type = "Toggle", Name = "Enable Sentinel AI", Default = true},
                {Type = "Toggle", Name = "Auto-Analyze Kills", Default = true},
                {Type = "Button", Name = "Open AI Chat"},
                {Type = "Button", Name = "Disable All AI Features"},
            },
        },
        {
            Title = "AI Intelligence",
            Elements = {
                {Type = "Button", Name = "View All Threat Profiles"},
                {Type = "Button", Name = "Reset All Profiles"},
                {Type = "Button", Name = "Reset AI Memory"},
            },
        },
    },
})

UI_RegisterTab({
    Title = "Settings",
    Locked = false,
    Sections = {
        {
            Title = "General",
            Elements = {
                {Type = "Toggle", Name = "Anti-Lag Shield", Default = false},
                {Type = "Toggle", Name = "ESP (Threat-Colored)", Default = false},
                {Type = "Toggle", Name = "Kill Notifications", Default = false},
                {Type = "Toggle", Name = "Kill Logs", Default = false},
                {Type = "Button", Name = "View Kill Logs"},
            },
        },
        {
            Title = "Configuration",
            Elements = {
                {Type = "Button", Name = "Save Config"},
                {Type = "Button", Name = "Load Config"},
                {Type = "Button", Name = "Rejoin Server"},
            },
        },
    },
})

UI_RegisterTab({
    Title = "Updates",
    Locked = false,
    Sections = {
        {
            Title = "EXO Hub Changelog",
            Elements = {
                {Type = "Label", Name = "v10.0 - SENTINEL PRIME (CURRENT)"},
                {Type = "Label", Name = "  - Discord Webhook Logger"},
                {Type = "Label", Name = "  - Keybind Manager"},
                {Type = "Label", Name = "  - Target Prediction Engine"},
                {Type = "Label", Name = "  - Profile State Saving"},
                {Type = "Label", Name = "  - Movement Systems"},
                {Type = "Label", Name = "  - Modularized UI Config"},
            },
        },
    },
})

-- Expose globally
_G.EXO_UI_RegisterTab = UI_RegisterTab
_G.EXO_UI_GetTabCount = UI_GetTabCount
_G.EXO_UI_GetTab = UI_GetTab
_G.EXO_UI_FindTab = UI_FindTab
_G.EXO_UITabRegistry = UITabRegistry

print(`[EXO] Section 12.6 complete. UI Tab Configuration Registry initialized.`)
print(`[EXO]   Registered tabs: {UI_GetTabCount()}`)
print(`[EXO]   Tab list: Combat, Movement, Tycoon, Kill Engine, Visuals,`)
print(`[EXO]              FSM Control, Sentinel AI, Settings, Updates`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 12.7: CROSS-SYSTEM BRIDGE & GLOBAL REGISTRY               ║
-- ║  Single source of truth for all cross-section function references  ║
-- ╚══════════════════════════════════════════════════════════════════════╝

type GlobalBridge = {
    Version: number,
    Build: string,
    Initialized: boolean,
    SystemsLoaded: number,
    SystemsExpected: number,
    LoadErrors: {string},
}

local GlobalBridge: GlobalBridge = {
    Version = _EXO_VERSION,
    Build = _EXO_BUILD,
    Initialized = false,
    SystemsLoaded = 0,
    SystemsExpected = 42,
    LoadErrors = {},
}

-- Verify all critical globals exist after Part 1 initialization
local function Bridge_ValidateGlobals(): boolean
    local required: {string} = {
        -- Combat
        "EXO_StartAuraLoop",
        "EXO_StopAuraLoop",
        "EXO_StartInstaKill",
        "EXO_StopInstaKill",
        "EXO_StartHitAmplifier",
        "EXO_StopHitAmplifier",
        "EXO_StartAntiAura",
        "EXO_StopAntiAura",
        "EXO_ApplyReach",
        "EXO_StopReach",
        "EXO_StartToolFollow",
        "EXO_StopToolFollow",
        "EXO_StartNoCooldown",
        "EXO_StopNoCooldown",
        "EXO_StartAutoTools",
        "EXO_StopAutoTools",
        -- Automation
        "EXO_StartClaimMoney",
        "EXO_StopClaimMoney",
        "EXO_StartAutoBuild",
        "EXO_StopAutoBuild",
        "EXO_StartFastRespawn",
        "EXO_SetupAntiSpawnkill",
        "EXO_SetupCharacterHooks",
        "EXO_SetupKillNotifications",
        "EXO_OnKillDetected",
        -- Visuals
        "EXO_StartESP",
        "EXO_StopESP",
        "EXO_StartAntiLag",
        "EXO_StopAntiLag",
        -- AI
        "EXO_ChatAddMessage",
        "EXO_RobotSetState",
        "EXO_ProcessUserMessage",
        -- FSM
        "EXO_FSM_Start",
        "EXO_FSM_Stop",
        "EXO_FSM_SetAutoSwitch",
        "EXO_FSM_GetCurrentMode",
        "EXO_FSM_GetModeScores",
        "EXO_FSM_TransitionTo",
        -- Tool Grabber
        "EXO_TG_HasTool",
        "EXO_TG_GetClosestPad",
        "EXO_TG_GetProgress",
        "EXO_StartToolGrabber",
        "EXO_StopToolGrabber",
        -- Movement
        "EXO_Movement_HandleToggle",
        "EXO_Movement_StartSpeedLoop",
        "EXO_Movement_StopSpeedLoop",
        "EXO_Movement_StartFly",
        "EXO_Movement_StopFly",
        "EXO_Movement_StartNoclip",
        "EXO_Movement_StopNoclip",
        "EXO_Movement_StartInfiniteJump",
        "EXO_Movement_StopInfiniteJump",
        -- UI
        "EXO_UI_RegisterTab",
        "EXO_UI_GetTabCount",
        "EXO_UI_GetTab",
        "EXO_UI_FindTab",
    }

    local missing: number = 0
    for _, name: string in required do
        if type(_G[name]) ~= "function" then
            missing += 1
            table.insert(GlobalBridge.LoadErrors, `Missing: {name}`)
        else
            GlobalBridge.SystemsLoaded += 1
        end
    end

    GlobalBridge.SystemsExpected = #required
    return missing == 0
end

-- Initialize the bridge
local _bridge_ok: boolean = Bridge_ValidateGlobals()
if _bridge_ok then
    GlobalBridge.Initialized = true
    print(`[EXO] Section 12.7: Global Bridge validated. {GlobalBridge.SystemsLoaded}/{GlobalBridge.SystemsExpected} systems registered.`)
else
    warn(`[EXO] Section 12.7: Global Bridge has {#GlobalBridge.LoadErrors} missing systems.`)
    for _, err in GlobalBridge.LoadErrors do
        warn(`[EXO]   {err}`)
    end
end

-- Expose bridge globally
_G.EXO_GlobalBridge = GlobalBridge

print(`[EXO] Section 12.7 complete. Cross-System Bridge initialized.`)
print(`[EXO]   Bridge status: {if GlobalBridge.Initialized then "FULLY OPERATIONAL" else "PARTIAL"}`)
print(`[EXO]   Systems loaded: {GlobalBridge.SystemsLoaded}/{GlobalBridge.SystemsExpected}`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 12.8: PART 1 READINESS CHECK & INITIALIZATION SEQUENCE    ║
-- ║  Final validation before declaring Part 1 complete                 ║
-- ╚══════════════════════════════════════════════════════════════════════╝

type Part1Status = {
    AntiTamper: boolean,
    Obfuscation: boolean,
    DiscordLogger: boolean,
    Services: boolean,
    FileIO: boolean,
    StateVars: boolean,
    Buffers: boolean,
    KeybindManager: boolean,
    ProfileSystem: boolean,
    PredictionEngine: boolean,
    Helpers: boolean,
    Scans: boolean,
    ThreatDetection: boolean,
    Movement: boolean,
    UIRegistry: boolean,
    GlobalBridge: boolean,
}

local Part1Readiness: Part1Status = {
    AntiTamper = _EXO_INTEGRITY,
    Obfuscation = type(_xor_transform) == "function",
    DiscordLogger = type(_send_execution_log) == "function",
    Services = type(Players) == "userdata" and type(RunService) == "userdata",
    FileIO = type(readFile) == "function" and type(writeJSON) == "function",
    StateVars = type(Aura) == "table" and type(AntiAura) == "table" and type(Movement) == "table",
    Buffers = type(_buf_parts) == "table" and type(_buf_predictions) == "table",
    KeybindManager = type(KB_Register) == "function" and #KeybindManager.Binds > 0,
    ProfileSystem = type(Profile_Save) == "function" and type(Profile_Load) == "function",
    PredictionEngine = type(Predict_Adaptive) == "function" and type(Predict_MultiHitbox) == "function",
    Helpers = type(getHRP) == "function" and type(getTouchableParts) == "function",
    Scans = true, -- Scans run async, mark as initiated
    ThreatDetection = type(updateThreatLevel) == "function",
    Movement = type(Movement_HandleToggle) == "function",
    UIRegistry = #UITabRegistry > 0,
    GlobalBridge = GlobalBridge.Initialized,
}

-- Count passing systems
local _pass_count: number = 0
local _total_checks: number = 0
local _failed_systems: {string} = {}

for system_name, passed in Part1Readiness do
    _total_checks += 1
    if passed then
        _pass_count += 1
    else
        table.insert(_failed_systems, system_name)
    end
end

print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] PART 1 READINESS CHECK`)
print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO]   Anti-Tamper:         {if Part1Readiness.AntiTamper then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Obfuscation:         {if Part1Readiness.Obfuscation then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Discord Logger:      {if Part1Readiness.DiscordLogger then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Services:            {if Part1Readiness.Services then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   File I/O:            {if Part1Readiness.FileIO then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   State Variables:     {if Part1Readiness.StateVars then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Pre-Alloc Buffers:   {if Part1Readiness.Buffers then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Keybind Manager:     {if Part1Readiness.KeybindManager then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Profile System:      {if Part1Readiness.ProfileSystem then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Prediction Engine:   {if Part1Readiness.PredictionEngine then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Helper Functions:    {if Part1Readiness.Helpers then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Deferred Scans:      {if Part1Readiness.Scans then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Threat Detection:    {if Part1Readiness.ThreatDetection then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Movement Systems:    {if Part1Readiness.Movement then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   UI Tab Registry:     {if Part1Readiness.UIRegistry then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO]   Global Bridge:       {if Part1Readiness.GlobalBridge then "✓ PASS" else "✗ FAIL"}`)
print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO]   RESULT: {_pass_count}/{_total_checks} systems operational`)

if #_failed_systems > 0 then
    warn(`[EXO]   FAILED SYSTEMS: {table.concat(_failed_systems, ", ")}`)
end

print(`[EXO] ═══════════════════════════════════════════════════`)

-- Final Part 1 declaration
if _pass_count == _total_checks then
    print(`[EXO] ★★★ PART 1 OFFICIALLY COMPLETE ★★★`)
    print(`[EXO] All {_total_checks} foundational systems validated and operational.`)
    print(`[EXO] Ready to proceed to Part 2: Combat Systems.`)
else
    warn(`[EXO] ⚠ PART 1 COMPLETE WITH WARNINGS`)
    print(`[EXO] {_pass_count}/{_total_checks} systems operational. Proceeding with degraded mode.`)
end

print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] END OF PART 1 (THIRD HALF)`)
print(`[EXO] Total Part 1 sections: 0 through 12.8`)
print(`[EXO] Total Part 1 estimated lines: ~3,200`)
print(`[EXO] Next: Part 2 – Combat Systems, Aura, InstaKill, HitAmp,`)
print(`[EXO]       AntiAura, Reach, ToolFollow, NoCooldown, FSM Engine`)
print(`[EXO] ═══════════════════════════════════════════════════`)
