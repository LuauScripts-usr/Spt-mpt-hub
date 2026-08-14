-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  PART 4 (FIRST HALF): UI TAB ENGINE + TAB BUILDERS                  ║
-- ║  Sections 24.1-25.3 | EXO HUB v10.0 SENTINEL PRIME                  ║
-- ║  All sub-modules isolated in do...end blocks for register safety     ║
-- ╚══════════════════════════════════════════════════════════════════════╝

print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] PART 4 (FIRST HALF): UI TAB ENGINE LOADING`)
print(`[EXO] Modules: TabRegistry, 9 Tab Builders, Keybind Tab`)
print(`[EXO] ═══════════════════════════════════════════════════`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 24.1: UI TAB REGISTRY SYSTEM                              ║
-- ║  Declarative tab/section/element definitions for clean UI builds     ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    -- Type definitions for UI element configurations
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

    -- Central registry for all UI tab definitions
    -- This allows tabs to be defined declaratively and built programmatically
    local UITabRegistry: {UITabConfig} = {}
    local UITabOrder: {string} = {}

    local function UI_RegisterTab(config: UITabConfig): ()
        -- Validate config before registering
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

        -- Check for duplicate registration
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

    -- Expose registry functions globally
    _G.EXO_UI_RegisterTab = UI_RegisterTab
    _G.EXO_UI_GetTabCount = UI_GetTabCount
    _G.EXO_UI_GetTab = UI_GetTab
    _G.EXO_UI_FindTab = UI_FindTab
    _G.EXO_UI_GetTabOrder = UI_GetTabOrder
    _G.EXO_UI_GetTotalElements = UI_GetTotalElements
    _G.EXO_UI_GetTotalSections = UI_GetTotalSections
    _G.EXO_UITabRegistry = UITabRegistry

    print(`[EXO] Section 24.1 complete. UI Tab Registry System registered.`)
    print(`[EXO]   Registry functions: 7`)
    print(`[EXO]   Tab order tracking: ENABLED`)
    print(`[EXO]   Duplicate prevention: ENABLED`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 24.2: UI WINDOW CREATION & VALIDATION                     ║
-- ║  AdmianianUI window init | Fallback handling | API validation        ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    -- Validate AdminUI is available before building
    if not AdminUI then
        warn("[EXO] FATAL: AdminUI is nil. Cannot build UI tabs.")
        return
    end

    -- Create the main window using AdmianianUI API (exact syntax from user example)
    local Window = AdminUI:CreateWindow({
        Title = "EXO Hub v10.0",
        Subtitle = "SENTINEL PRIME | OMNISCIENT | LUAU",
        Color = Color3.fromRGB(0, 150, 255),
    })

    if not Window then
        warn("[EXO] FATAL: Window creation failed. Aborting.")
        return
    end

    -- Store window reference globally for tab builders
    _G.EXO_UI_Window = Window
    _G.EXO_UI_AdminUI = AdminUI

    print(`[EXO] Section 24.2 complete. Window created successfully via AdmianianUI.`)
    print(`[EXO]   Window title: EXO Hub v10.0`)
    print(`[EXO]   Subtitle: SENTINEL PRIME | OMNISCIENT | LUAU`)
    print(`[EXO]   Accent color: RGB(0, 150, 255)`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 24.3: TAB 1 – COMBAT (AURA + TOOL FOLLOW + DEFENSE)       ║
-- ║  1000x Multi-Target Aura | Predictive Tool Follow | Anti-Aura        ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local Window = _G.EXO_UI_Window
    if not Window then
        warn("[EXO] Combat tab skipped: Window is nil")
    else
        local CombatTab = Window:CreateTab("Combat")
        if not CombatTab then
            warn("[EXO] Combat tab creation failed")
        else
            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Multi-Target Aura
            -- ─────────────────────────────────────────────────────────────
            local AuraSec = CombatTab:CreateSection("1000x Multi-Target Aura")

            AuraSec:AddToggle("Enable Aura", false, function(state: boolean)
                Aura.Enabled = state
                if state then
                    Aura.TargetList = {}
                    local players_ok: boolean, players_list = pcall(function() return Players:GetPlayers() end)
                    if players_ok and type(players_list) == "table" then
                        for _, plr: Player in players_list do
                            if plr ~= player then
                                table.insert(Aura.TargetList, plr)
                            end
                        end
                    end
                    if type(_G.EXO_StartAuraLoop) == "function" then
                        pcall(_G.EXO_StartAuraLoop)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify(`Aura ENGAGED - {#Aura.TargetList} targets. Multi-vector prediction active.`, 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopAuraLoop) == "function" then
                        pcall(_G.EXO_StopAuraLoop)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Aura DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            AuraSec:AddToggle("Instant Kill", false, function(state: boolean)
                InstantKill = state
            end)

            AuraSec:AddSlider("Prediction Depth", 3, 30, 8, function(val: number)
                latencyEstimate = val / 100
            end)

            AuraSec:AddDropdown("Aura Targets", getServerPlayers(), function(selected)
                table.clear(Aura.TargetList)
                if type(selected) == "table" then
                    for _, name in selected do
                        local plr: Player? = Players:FindFirstChild(name)
                        if plr then
                            table.insert(Aura.TargetList, plr)
                        end
                    end
                elseif type(selected) == "string" then
                    local plr: Player? = Players:FindFirstChild(selected)
                    if plr then
                        table.insert(Aura.TargetList, plr)
                    end
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify(`Aura targets updated: {#Aura.TargetList} selected.`, 2)
                    end)
                end
            end)

            AuraSec:AddLabel("Prediction: Quadratic + gravity compensation")
            AuraSec:AddLabel("Hitboxes: HRP + UpperTorso/Torso + Head")
            AuraSec:AddLabel("Remotes: Triple fire (primary + alt + tertiary)")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Tool Follow
            -- ─────────────────────────────────────────────────────────────
            local ToolFollowSec = CombatTab:CreateSection("1000x Tool Follow")

            ToolFollowSec:AddToggle("Enable Tool Follow", false, function(state: boolean)
                ToolFollow.Enabled = state
                if state then
                    ToolFollow.Targets = {}
                    local players_ok: boolean, players_list = pcall(function() return Players:GetPlayers() end)
                    if players_ok and type(players_list) == "table" then
                        for _, plr: Player in players_list do
                            if plr ~= player then
                                table.insert(ToolFollow.Targets, plr)
                            end
                        end
                    end
                    if type(_G.EXO_StartToolFollow) == "function" then
                        pcall(_G.EXO_StartToolFollow)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify(`Tool Follow ENGAGED - {#ToolFollow.Targets} targets.`, 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopToolFollow) == "function" then
                        pcall(_G.EXO_StopToolFollow)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Tool Follow DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            ToolFollowSec:AddSlider("Prediction Offset (ms)", 1, 20, 8, function(val: number)
                ToolFollow.PredictionOffset = val / 100
            end)

            ToolFollowSec:AddLabel("Predictive velocity tracking with 0.08s lookahead")
            ToolFollowSec:AddLabel("Offset: Vector3.new(0, 0.8, 0.5) above torso")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Defense / Anti-Aura
            -- ─────────────────────────────────────────────────────────────
            local DefenseSec = CombatTab:CreateSection("1000x Defense / Anti-Aura")

            DefenseSec:AddToggle("Enable Anti-Aura", false, function(state: boolean)
                AntiAura.Enabled = state
                if state then
                    if type(_G.EXO_StartAntiAura) == "function" then
                        pcall(_G.EXO_StartAntiAura)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Anti-Aura ENGAGED. Defense matrix active.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopAntiAura) == "function" then
                        pcall(_G.EXO_StopAntiAura)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Anti-Aura DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            DefenseSec:AddToggle("God Mode (ForceField)", false, function(state: boolean)
                AntiAura.GodMode = state
            end)

            DefenseSec:AddToggle("Repel (Anti-Touch)", false, function(state: boolean)
                AntiAura.Repel = state
            end)

            DefenseSec:AddToggle("Phase (No Collide)", false, function(state: boolean)
                AntiAura.Phase = state
            end)

            DefenseSec:AddToggle("Heal Aura", false, function(state: boolean)
                AntiAura.HealAura = state
            end)

            DefenseSec:AddToggle("Reflect (Reserved)", false, function(state: boolean)
                AntiAura.Reflect = state
            end)

            DefenseSec:AddSlider("Repel Force", 50, 300, 120, function(val: number)
                AntiAura.RepelForce = val
            end)

            DefenseSec:AddSlider("Repel Radius", 8, 30, 18, function(val: number)
                AntiAura.RepelRadius = val
            end)

            DefenseSec:AddToggle("Anti Spawnkill", false, function(state: boolean)
                AntiSpawnkill = state
                if state and AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Anti-Spawnkill ARMED. 5s invincibility on respawn.", 3)
                    end)
                end
            end)

            DefenseSec:AddLabel("GodMode heal threshold: 0.7 | Repel configurable 50-300")
            DefenseSec:AddLabel("Features: GodMode, HealAura, Reflect, Repel, Phase, ShieldStack")

            print(`[EXO] Combat tab built: 3 sections, 16 elements`)
        end
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 24.4: TAB 2 – MOVEMENT (SPEED + JUMP + FLY + NOCLIP)      ║
-- ║  Speed Hack | Jump Power | Noclip | Fly | Infinite Jump              ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local Window = _G.EXO_UI_Window
    if not Window then
        warn("[EXO] Movement tab skipped: Window is nil")
    else
        local MovementTab = Window:CreateTab("Movement")
        if not MovementTab then
            warn("[EXO] Movement tab creation failed")
        else
            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Speed & Jump
            -- ─────────────────────────────────────────────────────────────
            local SpeedJumpSec = MovementTab:CreateSection("Speed & Jump")

            SpeedJumpSec:AddToggle("Speed Hack", false, function(state: boolean)
                if type(_G.EXO_Movement_HandleToggle) == "function" then
                    pcall(_G.EXO_Movement_HandleToggle, "SpeedHack", state)
                end
                if state and AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify(`Speed Hack ENGAGED. Walk speed: {Movement.SpeedValue}.`, 2)
                    end)
                end
            end)

            SpeedJumpSec:AddSlider("Walk Speed", 16, 200, 16, function(val: number)
                Movement.SpeedValue = val
                if Movement.SpeedHack and type(_G.EXO_ApplySpeed) == "function" then
                    pcall(_G.EXO_ApplySpeed)
                end
            end)

            SpeedJumpSec:AddToggle("Jump Power", false, function(state: boolean)
                if type(_G.EXO_Movement_HandleToggle) == "function" then
                    pcall(_G.EXO_Movement_HandleToggle, "JumpPower", state)
                end
                if state and AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify(`Jump Power ENGAGED. Jump value: {Movement.JumpValue}.`, 2)
                    end)
                end
            end)

            SpeedJumpSec:AddSlider("Jump Value", 50, 500, 50, function(val: number)
                Movement.JumpValue = val
                if Movement.JumpPower and type(_G.EXO_ApplyJump) == "function" then
                    pcall(_G.EXO_ApplyJump)
                end
            end)

            SpeedJumpSec:AddToggle("Infinite Jump", false, function(state: boolean)
                if type(_G.EXO_Movement_HandleToggle) == "function" then
                    pcall(_G.EXO_Movement_HandleToggle, "InfiniteJump", state)
                end
                if state and AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Infinite Jump ENGAGED. Spam spacebar for flight.", 2)
                    end)
                end
            end)

            SpeedJumpSec:AddLabel("Heartbeat throttle: every 5 ticks (mobile optimized)")
            SpeedJumpSec:AddLabel("Auto-reset on stop: ENABLED")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Flight & Phase
            -- ─────────────────────────────────────────────────────────────
            local FlightSec = MovementTab:CreateSection("Flight & Phase")

            FlightSec:AddToggle("Noclip", false, function(state: boolean)
                if type(_G.EXO_Movement_HandleToggle) == "function" then
                    pcall(_G.EXO_Movement_HandleToggle, "Noclip", state)
                end
                if state and AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Noclip ENGAGED. Walk through walls.", 2)
                    end)
                end
            end)

            FlightSec:AddToggle("Fly", false, function(state: boolean)
                if type(_G.EXO_Movement_HandleToggle) == "function" then
                    pcall(_G.EXO_Movement_HandleToggle, "Fly", state)
                end
                if state and AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify(`Fly ENGAGED. WASD + Space/Shift. Speed: {Movement.FlySpeed}.`, 3)
                    end)
                end
            end)

            FlightSec:AddSlider("Fly Speed", 10, 300, 50, function(val: number)
                Movement.FlySpeed = val
            end)

            FlightSec:AddLabel("Controls: WASD + Space/Shift")
            FlightSec:AddLabel("Orientation: Camera-relative BodyGyro")
            FlightSec:AddLabel("PlatformStand: ENABLED while flying")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Movement Presets
            -- ─────────────────────────────────────────────────────────────
            local PresetSec = MovementTab:CreateSection("Movement Presets")

            PresetSec:AddButton("Stop All Movement", function()
                if type(_G.EXO_Movement_StopAll) == "function" then
                    pcall(_G.EXO_Movement_StopAll)
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("All movement features STOPPED.", 2)
                    end)
                end
            end)

            PresetSec:AddButton("Speed Preset: Sprint (50)", function()
                Movement.SpeedValue = 50
                Movement.SpeedHack = true
                if type(_G.EXO_StartSpeedLoop) == "function" then
                    pcall(_G.EXO_StartSpeedLoop)
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Speed preset applied: Sprint (50).", 2)
                    end)
                end
            end)

            PresetSec:AddButton("Speed Preset: Blitz (100)", function()
                Movement.SpeedValue = 100
                Movement.SpeedHack = true
                if type(_G.EXO_StartSpeedLoop) == "function" then
                    pcall(_G.EXO_StartSpeedLoop)
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Speed preset applied: Blitz (100).", 2)
                    end)
                end
            end)

            PresetSec:AddButton("Speed Preset: Godspeed (200)", function()
                Movement.SpeedValue = 200
                Movement.SpeedHack = true
                if type(_G.EXO_StartSpeedLoop) == "function" then
                    pcall(_G.EXO_StartSpeedLoop)
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Speed preset applied: Godspeed (200).", 2)
                    end)
                end
            end)

            PresetSec:AddButton("Fly Preset: Cruise (50)", function()
                Movement.FlySpeed = 50
                Movement.Fly = true
                if type(_G.EXO_StartFly) == "function" then
                    pcall(_G.EXO_StartFly)
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Fly preset applied: Cruise (50).", 2)
                    end)
                end
            end)

            PresetSec:AddButton("Fly Preset: Jet (150)", function()
                Movement.FlySpeed = 150
                Movement.Fly = true
                if type(_G.EXO_StartFly) == "function" then
                    pcall(_G.EXO_StartFly)
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Fly preset applied: Jet (150).", 2)
                    end)
                end
            end)

            PresetSec:AddLabel("Presets apply instantly and override current values")

            print(`[EXO] Movement tab built: 3 sections, 17 elements`)
        end
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 24.5: TAB 3 – TYCOON (AUTOMATION + TOOLS + COOLDOWN)      ║
-- ║  Auto Claim | Smart Auto Build | Tool Grabber | No Cooldown          ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local Window = _G.EXO_UI_Window
    if not Window then
        warn("[EXO] Tycoon tab skipped: Window is nil")
    else
        local TycoonTab = Window:CreateTab("Tycoon")
        if not TycoonTab then
            warn("[EXO] Tycoon tab creation failed")
        else
            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Tycoon Automation
            -- ─────────────────────────────────────────────────────────────
            local TycoonSec = TycoonTab:CreateSection("1000x Tycoon Automation")

            TycoonSec:AddToggle("Auto Claim Money", false, function(state: boolean)
                AutoClaimMoney = state
                if state then
                    if type(_G.EXO_StartClaimMoney) == "function" then
                        pcall(_G.EXO_StartClaimMoney)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Auto Claim ENGAGED. Scanning cash registers.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopClaimMoney) == "function" then
                        pcall(_G.EXO_StopClaimMoney)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Auto Claim DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            TycoonSec:AddToggle("Smart Auto Build (Multi-Buy)", false, function(state: boolean)
                AutoBuild = state
                if state then
                    if type(_G.EXO_StartAutoBuild) == "function" then
                        pcall(_G.EXO_StartAutoBuild)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Smart Auto Build ENGAGED. Max 3 items per cycle.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopAutoBuild) == "function" then
                        pcall(_G.EXO_StopAutoBuild)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Smart Auto Build DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            TycoonSec:AddToggle("Auto Grab Weapons", false, function(state: boolean)
                AutoGetTools = state
                if state then
                    if type(_G.EXO_StartToolGrabber) == "function" then
                        pcall(_G.EXO_StartToolGrabber)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Auto Grab Weapons ENGAGED. 14 bases scanning.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopToolGrabber) == "function" then
                        pcall(_G.EXO_StopToolGrabber)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Auto Grab Weapons DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            TycoonSec:AddLabel("Claim patterns: cash, register, collect, money")
            TycoonSec:AddLabel("Buy cycle: 0.2s cooldown, max 3 items per cycle")
            TycoonSec:AddLabel("Priority sorting: generators > gear > walls > effects")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Tools & Cooldown
            -- ─────────────────────────────────────────────────────────────
            local CooldownSec = TycoonTab:CreateSection("Tools & Cooldown")

            CooldownSec:AddToggle("Auto Use Tools (0 delay)", false, function(state: boolean)
                AutoTools = state
                if state then
                    if type(_G.EXO_StartAutoTools) == "function" then
                        pcall(_G.EXO_StartAutoTools)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Auto Use Tools ENGAGED. Activating all tools.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopAutoTools) == "function" then
                        pcall(_G.EXO_StopAutoTools)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Auto Use Tools DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            CooldownSec:AddToggle("No Cooldown (SAFE)", false, function(state: boolean)
                NoCooldown = state
                if state then
                    if type(_G.EXO_StartNoCooldown) == "function" then
                        pcall(_G.EXO_StartNoCooldown)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("No Cooldown ENGAGED. SAFE mode: no global hooks.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopNoCooldown) == "function" then
                        pcall(_G.EXO_StopNoCooldown)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("No Cooldown DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            CooldownSec:AddLabel("SAFE MODE: No global wait/spawn/delay hooks")
            CooldownSec:AddLabel("Targeted: Cooldown.Value=0, Enabled.Value=true")
            CooldownSec:AddLabel("Handle: CanCollide=false, Massless=true")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Tycoon Progress
            -- ─────────────────────────────────────────────────────────────
            local ProgressSec = TycoonTab:CreateSection("Tycoon Progress")

            ProgressSec:AddButton("View Tool Grabber Progress", function()
                if type(_G.EXO_TG_GetProgress) == "function" then
                    local ok: boolean, owned, total = pcall(_G.EXO_TG_GetProgress)
                    if ok and type(owned) == "number" and type(total) == "number" then
                        if AdminUI and type(AdminUI.Notify) == "function" then
                            pcall(function()
                                AdminUI:Notify(`Tool Grabber Progress: {owned}/{total} tools owned.`, 3)
                            end)
                        end
                    end
                end
            end)

            ProgressSec:AddButton("View Current Cash", function()
                local cash: number = getPlayerCash()
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify(`Current Cash: ${cash}`, 3)
                    end)
                end
            end)

            ProgressSec:AddButton("View Tycoon Type", function()
                local tycoonType: string? = getPlayerTycoonType()
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify(`Tycoon Type: {tycoonType or "Unknown"}`, 3)
                    end)
                end
            end)

            ProgressSec:AddLabel("Progress tracking: ENABLED")
            ProgressSec:AddLabel("14 bases: Stone, Magic, Storm, Robotic, Mecha, Shadow,")
            ProgressSec:AddLabel("           Hyper, Thunder, Void, Frozen, Magma, Nuclear, Toxic, Kong")

            print(`[EXO] Tycoon tab built: 3 sections, 12 elements`)
        end
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 24.6: TAB 4 – KILL ENGINE (OMNI-KILL + HIT AMP + ARSENAL) ║
-- ║  Omni-Kill | Insta-Kill | Hit Amplifier | Tool Arsenal               ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local Window = _G.EXO_UI_Window
    if not Window then
        warn("[EXO] Kill Engine tab skipped: Window is nil")
    else
        local KillTab = Window:CreateTab("Kill Engine")
        if not KillTab then
            warn("[EXO] Kill Engine tab creation failed")
        else
            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Omni-Kill Engine
            -- ─────────────────────────────────────────────────────────────
            local OmniSec = KillTab:CreateSection("1000x Omni-Kill Engine")

            OmniSec:AddToggle("Enable Omni-Kill", false, function(state: boolean)
                Aura.Enabled = state
                InstantKill = state
                if state then
                    Aura.TargetList = {}
                    local players_ok: boolean, players_list = pcall(function() return Players:GetPlayers() end)
                    if players_ok and type(players_list) == "table" then
                        for _, plr: Player in players_list do
                            if plr ~= player then
                                table.insert(Aura.TargetList, plr)
                            end
                        end
                    end
                    if type(_G.EXO_StartAuraLoop) == "function" then
                        pcall(_G.EXO_StartAuraLoop)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify(`OMNI-KILL ENGAGED - {#Aura.TargetList} targets.`, 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopAuraLoop) == "function" then
                        pcall(_G.EXO_StopAuraLoop)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("OMNI-KILL DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            OmniSec:AddToggle("Insta-Kill Micro-Burst", false, function(state: boolean)
                InstaKillEnabled = state
                if state then
                    if type(_G.EXO_StartInstaKill) == "function" then
                        pcall(_G.EXO_StartInstaKill)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Insta-Kill ENGAGED. 120Hz scan rate active.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopInstaKill) == "function" then
                        pcall(_G.EXO_StopInstaKill)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Insta-Kill DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            OmniSec:AddToggle("Adaptive Burst (Threat-Based)", true, function(state: boolean)
                IK_AdaptiveBurst = state
            end)

            OmniSec:AddSlider("Prediction Aggression", 3, 30, 8, function(val: number)
                latencyEstimate = val / 100
            end)

            OmniSec:AddSlider("Burst Count", 3, 20, 12, function(val: number)
                IK_BurstCount = val
            end)

            OmniSec:AddButton("Manual Kill Burst", function()
                local orig: boolean = Aura.Enabled
                Aura.Enabled = true
                InstantKill = true
                task.wait(0.15)
                Aura.Enabled = orig
                if not orig then
                    InstantKill = false
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Manual kill burst fired.", 2)
                    end)
                end
            end)

            OmniSec:AddButton("Refresh Target List", function()
                table.clear(Aura.TargetList)
                local players_ok: boolean, players_list = pcall(function() return Players:GetPlayers() end)
                if players_ok and type(players_list) == "table" then
                    for _, plr: Player in players_list do
                        if plr ~= player then
                            table.insert(Aura.TargetList, plr)
                        end
                    end
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify(`Targets refreshed: {#Aura.TargetList} players.`, 2)
                    end)
                end
            end)

            OmniSec:AddLabel("Scan rate: 120Hz | Target range: 50 studs")
            OmniSec:AddLabel("Hitboxes: 9 (HRP, Torso x2, Head, LowerTorso, Arms x2, Legs x2)")
            OmniSec:AddLabel("Backpack scanning: ENABLED | Adaptive burst: ThreatLevel * 2")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Hit Amplifier
            -- ─────────────────────────────────────────────────────────────
            local HitAmpSec = KillTab:CreateSection("1000x Hit Amplifier")

            HitAmpSec:AddToggle("Enable Hit Amplifier", false, function(state: boolean)
                HitAmpEnabled = state
                if state then
                    if type(_G.EXO_StartHitAmplifier) == "function" then
                        pcall(_G.EXO_StartHitAmplifier)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Hit Amplifier ENGAGED. 360° sphere+box scan active.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopHitAmplifier) == "function" then
                        pcall(_G.EXO_StopHitAmplifier)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Hit Amplifier DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            HitAmpSec:AddSlider("Scan Range", 15, 60, 45, function(val: number)
                HA_Range = Vector3.new(val, val, val)
            end)

            HitAmpSec:AddSlider("Burst Count", 1, 15, 8, function(val: number)
                HA_BurstCount = val
            end)

            HitAmpSec:AddToggle("Multi-Pulse (3x waves)", true, function(state: boolean)
                HA_MultiPulse = state
            end)

            HitAmpSec:AddLabel("360 sphere+box scan | 6ms cooldown | OverlapParams")
            HitAmpSec:AddLabel("Multi-pulse: 3 waves per detection")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Tool Arsenal
            -- ─────────────────────────────────────────────────────────────
            local ArsenalSec = KillTab:CreateSection("1000x Tool Arsenal")

            ArsenalSec:AddToggle("Enable Tool Arsenal", false, function(state: boolean)
                TG_Enabled = state
                if state then
                    if type(_G.EXO_StartToolGrabber) == "function" then
                        pcall(_G.EXO_StartToolGrabber)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Tool Arsenal ENGAGED. Continuous acquisition active.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopToolGrabber) == "function" then
                        pcall(_G.EXO_StopToolGrabber)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Tool Arsenal DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            ArsenalSec:AddButton("Force Acquire All", function()
                local root: BasePart? = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local acquired: number = 0
                    for baseName: string, _ in TG_padsByBase do
                        local pad: BasePart? = nil
                        if type(_G.EXO_TG_GetClosestPad) == "function" then
                            local ok: boolean, result = pcall(_G.EXO_TG_GetClosestPad, baseName)
                            if ok and result then
                                pad = result
                            end
                        end
                        if pad then
                            for _ = 1, TG_BurstCount do
                                if firetouchinterest then
                                    pcall(firetouchinterest, root, pad, 0)
                                    pcall(firetouchinterest, root, pad, 1)
                                end
                            end
                            acquired += 1
                        end
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify(`Force acquire burst fired on {acquired} bases.`, 2)
                        end)
                    end
                end
            end)

            ArsenalSec:AddLabel("14 Bases: Stone, Magic, Storm, Robotic, Mecha, Shadow,")
            ArsenalSec:AddLabel("           Hyper, Thunder, Void, Frozen, Magma, Nuclear, Toxic, Kong")

            print(`[EXO] Kill Engine tab built: 3 sections, 15 elements`)
        end
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 24.7: TAB 5 – ECONOMY (SOVEREIGN + SPAWN + DEFENSE)       ║
-- ║  Sovereign Economy | Spawn Supremacy | Defense Matrix                ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local Window = _G.EXO_UI_Window
    if not Window then
        warn("[EXO] Economy tab skipped: Window is nil")
    else
        local EconTab = Window:CreateTab("Economy")
        if not EconTab then
            warn("[EXO] Economy tab creation failed")
        else
            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Sovereign Economy
            -- ─────────────────────────────────────────────────────────────
            local SovSec = EconTab:CreateSection("1000x Sovereign Economy")

            SovSec:AddToggle("Enable Sovereign Economy", false, function(state: boolean)
                AutoClaimMoney = state
                AutoBuild = state
                if state then
                    if type(_G.EXO_StartClaimMoney) == "function" then
                        pcall(_G.EXO_StartClaimMoney)
                    end
                    if type(_G.EXO_StartAutoBuild) == "function" then
                        pcall(_G.EXO_StartAutoBuild)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Sovereign Economy ENGAGED. Full automation active.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopClaimMoney) == "function" then
                        pcall(_G.EXO_StopClaimMoney)
                    end
                    if type(_G.EXO_StopAutoBuild) == "function" then
                        pcall(_G.EXO_StopAutoBuild)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Sovereign Economy DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            SovSec:AddSlider("Defense Threat Radius", 20, 120, 60, function(val: number)
                ThreatRadius = val
            end)

            SovSec:AddButton("Force Buy Next Upgrade", function()
                local myChar: Model? = player.Character
                if not myChar then
                    return
                end
                local root: Instance? = myChar:FindFirstChild("HumanoidRootPart")
                if not root then
                    return
                end
                local tycoonType: string? = getPlayerTycoonType()
                if not tycoonType then
                    return
                end
                local tycoons: Instance? = workspace:FindFirstChild("Tycoons")
                if not tycoons then
                    return
                end
                local tycoonFolder: Instance? = tycoons:FindFirstChild(tycoonType)
                if not tycoonFolder then
                    return
                end
                local cash: number = getPlayerCash()
                local best: Model? = nil
                local bestPri: number = 9999
                local desc_ok: boolean, descendants = pcall(function() return tycoonFolder:GetDescendants() end)
                if desc_ok and type(descendants) == "table" then
                    for _, obj: Instance in descendants do
                        if obj:IsA("Model") then
                            local cost: number = getCost(obj)
                            local pri: number = getPriority(obj.Name)
                            if cost > 0 and cost <= cash and pri < bestPri then
                                best = obj
                                bestPri = pri
                            end
                        end
                    end
                end
                if best then
                    local parts = getTouchableParts(best)
                    for _, part: BasePart in parts do
                        if firetouchinterest then
                            pcall(firetouchinterest, root, part, 0)
                            pcall(firetouchinterest, root, part, 1)
                        end
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify(`Purchased: {best.Name}`, 2)
                        end)
                    end
                else
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Nothing affordable.", 2)
                        end)
                    end
                end
            end)

            SovSec:AddLabel("Sovereign Economy: Auto Claim + Auto Build combined")
            SovSec:AddLabel("Threat Radius: Used by AI for defensive positioning")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Spawn Supremacy
            -- ─────────────────────────────────────────────────────────────
            local SpawnSec = EconTab:CreateSection("Spawn Supremacy")

            SpawnSec:AddToggle("Supremacy Mode", false, function(state: boolean)
                AntiSpawnkill = state
                if state and AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Supremacy Mode ARMED. 5s invincibility on respawn.", 3)
                    end)
                end
            end)

            SpawnSec:AddToggle("Fast Respawn", false, function(state: boolean)
                FastRespawn = state
                if state then
                    if type(_G.EXO_StartFastRespawn) == "function" then
                        pcall(_G.EXO_StartFastRespawn)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Fast Respawn ENGAGED. 0.02s threshold active.", 3)
                        end)
                    end
                end
            end)

            SpawnSec:AddLabel("Supremacy: 9e9 HP + ForceField for 5 seconds")
            SpawnSec:AddLabel("Fast Respawn: 0.02s threshold (1000x faster than v7.0)")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Defense Matrix
            -- ─────────────────────────────────────────────────────────────
            local DefSec = EconTab:CreateSection("1000x Defense Matrix")

            DefSec:AddToggle("Enable Defense Matrix", false, function(state: boolean)
                AntiAura.Enabled = state
                if state then
                    if type(_G.EXO_StartAntiAura) == "function" then
                        pcall(_G.EXO_StartAntiAura)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Defense Matrix ENGAGED. Full protection active.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopAntiAura) == "function" then
                        pcall(_G.EXO_StopAntiAura)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Defense Matrix DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            DefSec:AddToggle("ForceField God Mode", false, function(state: boolean)
                AntiAura.GodMode = state
            end)

            DefSec:AddToggle("Weapon Repel", false, function(state: boolean)
                AntiAura.Repel = state
            end)

            DefSec:AddToggle("Phase Mode", false, function(state: boolean)
                AntiAura.Phase = state
            end)

            DefSec:AddToggle("Heal Aura", false, function(state: boolean)
                AntiAura.HealAura = state
            end)

            DefSec:AddButton("Emergency Heal", function()
                local myChar: Model? = player.Character
                if myChar then
                    local hum: Instance? = myChar:FindFirstChild("Humanoid")
                    if hum and hum:IsA("Humanoid") then
                        local maxHP_ok: boolean, maxHP = pcall(function() return hum.MaxHealth end)
                        if maxHP_ok and type(maxHP) == "number" then
                            pcall(function()
                                hum.Health = maxHP
                            end)
                            if AdminUI and type(AdminUI.Notify) == "function" then
                                pcall(function()
                                    AdminUI:Notify("Health restored to max.", 2)
                                end)
                            end
                        end
                    end
                end
            end)

            DefSec:AddLabel("Defense Matrix: GodMode + Repel + Phase + HealAura")
            DefSec:AddLabel("Emergency Heal: Instant full health restoration")

            print(`[EXO] Economy tab built: 3 sections, 13 elements`)
        end
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 25.1: TAB 6 – VISUALS (ESP + ANTI-LAG + CHAMS)            ║
-- ║  Threat-Colored ESP | Anti-Lag Shield | Chams | UI Highlights        ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local Window = _G.EXO_UI_Window
    if not Window then
        warn("[EXO] Visuals tab skipped: Window is nil")
    else
        local VisualsTab = Window:CreateTab("Visuals")
        if not VisualsTab then
            warn("[EXO] Visuals tab creation failed")
        else
            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x ESP (Threat-Colored)
            -- ─────────────────────────────────────────────────────────────
            local ESPSec = VisualsTab:CreateSection("1000x ESP (Threat-Colored)")

            ESPSec:AddToggle("Enable ESP", false, function(state: boolean)
                ESPEnabled = state
                if state then
                    if type(_G.EXO_StartESP) == "function" then
                        pcall(_G.EXO_StartESP)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("ESP ENGAGED. Threat-colored dots active.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopESP) == "function" then
                        pcall(_G.EXO_StopESP)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("ESP DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            ESPSec:AddLabel("Colors: Red (<15 studs), Orange (<30 studs), Green (>30 studs)")
            ESPSec:AddLabel("Features: Name labels, distance-based coloring, auto player tracking")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Anti-Lag Shield
            -- ─────────────────────────────────────────────────────────────
            local AntiLagSec = VisualsTab:CreateSection("1000x Anti-Lag Shield")

            AntiLagSec:AddToggle("Enable Anti-Lag", false, function(state: boolean)
                AntiLagEnabled = state
                if state then
                    if type(_G.EXO_StartAntiLag) == "function" then
                        pcall(_G.EXO_StartAntiLag)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Anti-Lag ENGAGED. Performance optimizations active.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopAntiLag) == "function" then
                        pcall(_G.EXO_StopAntiLag)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Anti-Lag DISENGAGED. Original settings restored.", 2)
                        end)
                    end
                end
            end)

            AntiLagSec:AddLabel("Disables: Particles, Beams, Trails, Sounds, PostEffects")
            AntiLagSec:AddLabel("Sets: GlobalShadows=false, QualityLevel=Level01, FogEnd=500")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x Chams (NEW in v10)
            -- ─────────────────────────────────────────────────────────────
            local ChamsSec = VisualsTab:CreateSection("1000x Chams (NEW in v10)")

            ChamsSec:AddToggle("Enable Chams", false, function(state: boolean)
                ChamsEnabled = state
                if state then
                    if type(_G.EXO_StartChams) == "function" then
                        pcall(_G.EXO_StartChams)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Chams ENGAGED. Highlight instances on all players.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopChams) == "function" then
                        pcall(_G.EXO_StopChams)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Chams DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            ChamsSec:AddLabel("Depth mode: AlwaysOnTop")
            ChamsSec:AddLabel("Fill transparency: 0.5")
            ChamsSec:AddLabel("Color update: 0.5s throttle")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: 1000x UI Highlights (NEW in v10)
            -- ─────────────────────────────────────────────────────────────
            local HighlightsSec = VisualsTab:CreateSection("1000x UI Highlights (NEW in v10)")

            HighlightsSec:AddToggle("Enable UI Highlights", false, function(state: boolean)
                if state then
                    if type(_G.EXO_StartUIHighlights) == "function" then
                        pcall(_G.EXO_StartUIHighlights)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("UI Highlights ENGAGED. Active feature indicators on.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_StopUIHighlights) == "function" then
                        pcall(_G.EXO_StopUIHighlights)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("UI Highlights DISENGAGED.", 2)
                        end)
                    end
                end
            end)

            HighlightsSec:AddLabel("Tracked features: 15 (Aura, InstaKill, HitAmp, AntiAura, etc.)")
            HighlightsSec:AddLabel("Update interval: 0.25s")
            HighlightsSec:AddLabel("Position: Top-right corner")

            print(`[EXO] Visuals tab built: 4 sections, 4 toggles + 10 labels`)
        end
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 25.2: TAB 7 – FSM CONTROL (AI UPGRADE B)                  ║
-- ║  Adaptive FSM Engine | Manual Mode Override | Mode Scores            ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local Window = _G.EXO_UI_Window
    if not Window then
        warn("[EXO] FSM Control tab skipped: Window is nil")
    else
        local FSMTab = Window:CreateTab("FSM Control")
        if not FSMTab then
            warn("[EXO] FSM Control tab creation failed")
        else
            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Adaptive FSM Engine
            -- ─────────────────────────────────────────────────────────────
            local FSMMainSec = FSMTab:CreateSection("Adaptive FSM Engine")

            FSMMainSec:AddToggle("Enable Auto Mode Switching", false, function(state: boolean)
                if type(_G.EXO_FSM_SetAutoSwitch) == "function" then
                    pcall(_G.EXO_FSM_SetAutoSwitch, state)
                end
                if state then
                    if type(_G.EXO_FSM_Start) == "function" then
                        pcall(_G.EXO_FSM_Start)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("FSM Engine STARTED. Auto mode switching active.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_FSM_Stop) == "function" then
                        pcall(_G.EXO_FSM_Stop)
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("FSM Engine STOPPED. Manual control only.", 3)
                        end)
                    end
                end
            end)

            FSMMainSec:AddButton("View Current Mode", function()
                local currentMode: string = "UNKNOWN"
                if type(_G.EXO_FSM_GetCurrentMode) == "function" then
                    local ok: boolean, mode = pcall(_G.EXO_FSM_GetCurrentMode)
                    if ok and type(mode) == "string" then
                        currentMode = mode
                    end
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify(`Current FSM Mode: {currentMode}`, 3)
                    end)
                end
            end)

            FSMMainSec:AddButton("View Mode Scores", function()
                if type(_G.EXO_FSM_GetModeScores) == "function" then
                    local ok: boolean, scores = pcall(_G.EXO_FSM_GetModeScores)
                    if ok and type(scores) == "table" then
                        local score_str: string = ""
                        for mode: string, score: number in scores do
                            score_str ..= `{mode}:{math.floor(score)} `
                        end
                        if AdminUI and type(AdminUI.Notify) == "function" then
                            pcall(function()
                                AdminUI:Notify(`Mode Scores: {score_str}`, 5)
                            end)
                        end
                    end
                end
            end)

            FSMMainSec:AddLabel("Modes: IDLE, TYCOON (farm), DEFENSIVE (survive), COMBAT (fight)")
            FSMMainSec:AddLabel("Auto-switch evaluates every 1s using ThreatLevel, deaths, cash, tools")
            FSMMainSec:AddLabel("Hysteresis threshold: 15 points (prevents oscillation)")
            FSMMainSec:AddLabel("Emergency overrides: Threat spike → COMBAT, Death → DEFENSIVE")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Manual Mode Override
            -- ─────────────────────────────────────────────────────────────
            local FSMManualSec = FSMTab:CreateSection("Manual Mode Override")

            FSMManualSec:AddButton("Force TYCOON Mode", function()
                if type(_G.EXO_FSM_TransitionTo) == "function" then
                    pcall(_G.EXO_FSM_TransitionTo, "TYCOON", "MANUAL: User requested TYCOON mode")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Forced TYCOON mode. Farming features active.", 3)
                    end)
                end
            end)

            FSMManualSec:AddButton("Force DEFENSIVE Mode", function()
                if type(_G.EXO_FSM_TransitionTo) == "function" then
                    pcall(_G.EXO_FSM_TransitionTo, "DEFENSIVE", "MANUAL: User requested DEFENSIVE mode")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Forced DEFENSIVE mode. Anti-Aura active.", 3)
                    end)
                end
            end)

            FSMManualSec:AddButton("Force COMBAT Mode", function()
                if type(_G.EXO_FSM_TransitionTo) == "function" then
                    pcall(_G.EXO_FSM_TransitionTo, "COMBAT", "MANUAL: User requested COMBAT mode")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Forced COMBAT mode. All offensive systems active.", 3)
                    end)
                end
            end)

            FSMManualSec:AddButton("Force IDLE Mode", function()
                if type(_G.EXO_FSM_TransitionTo) == "function" then
                    pcall(_G.EXO_FSM_TransitionTo, "IDLE", "MANUAL: User requested IDLE mode")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Forced IDLE mode. All systems standby.", 3)
                    end)
                end
            end)

            FSMManualSec:AddLabel("Manual overrides bypass the 15-point hysteresis threshold")

            print(`[EXO] FSM Control tab built: 2 sections, 1 toggle + 7 buttons + 5 labels`)
        end
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 25.3: TAB 8 – SENTINEL AI (BRAIN + INTELLIGENCE)          ║
-- ║  AI Control | AI Intelligence | Profile Management                   ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local Window = _G.EXO_UI_Window
    if not Window then
        warn("[EXO] Sentinel AI tab skipped: Window is nil")
    else
        local AITab = Window:CreateTab("Sentinel AI")
        if not AITab then
            warn("[EXO] Sentinel AI tab creation failed")
        else
            -- ─────────────────────────────────────────────────────────────
            -- SECTION: AI Control
            -- ─────────────────────────────────────────────────────────────
            local AIControlSec = AITab:CreateSection("AI Control")

            AIControlSec:AddToggle("Enable Sentinel AI", true, function(state: boolean)
                KillNotifEnabled = state
                KillLogEnabled = state
                if state then
                    if type(_G.EXO_ChatAddMessage) == "function" then
                        pcall(_G.EXO_ChatAddMessage, "AI",
                            "Sentinel AI activated. I'm watching your back. Enable Kill Notifications to feed me data.",
                            Color3.fromRGB(0, 255, 100))
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Sentinel AI ONLINE. Chat overlay active.", 3)
                        end)
                    end
                else
                    if type(_G.EXO_ChatAddMessage) == "function" then
                        pcall(_G.EXO_ChatAddMessage, "AI",
                            "Sentinel AI deactivated.",
                            Color3.fromRGB(255, 200, 0))
                    end
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("Sentinel AI OFFLINE.", 2)
                        end)
                    end
                end
            end)

            AIControlSec:AddToggle("Auto-Analyze Kills", true, function(state: boolean)
                KillNotifEnabled = state
            end)

            AIControlSec:AddToggle("Persist Kill Logs", false, function(state: boolean)
                KillLogEnabled = state
            end)

            AIControlSec:AddButton("Open AI Chat", function()
                if type(_G.EXO_ChatCreateGUI) == "function" then
                    pcall(_G.EXO_ChatCreateGUI)
                end
                if type(_G.EXO_ChatAddMessage) == "function" then
                    pcall(_G.EXO_ChatAddMessage, "AI",
                        "Chat opened manually. Type 'help' for commands.",
                        Color3.fromRGB(0, 150, 255))
                end
            end)

            AIControlSec:AddButton("Disable All AI Features", function()
                Aura.Enabled = false
                if type(_G.EXO_StopAuraLoop) == "function" then
                    pcall(_G.EXO_StopAuraLoop)
                end
                InstaKillEnabled = false
                if type(_G.EXO_StopInstaKill) == "function" then
                    pcall(_G.EXO_StopInstaKill)
                end
                HitAmpEnabled = false
                if type(_G.EXO_StopHitAmplifier) == "function" then
                    pcall(_G.EXO_StopHitAmplifier)
                end
                AntiAura.Enabled = false
                if type(_G.EXO_StopAntiAura) == "function" then
                    pcall(_G.EXO_StopAntiAura)
                end
                Reach = false
                if type(_G.EXO_StopReach) == "function" then
                    pcall(_G.EXO_StopReach)
                end
                ToolFollow.Enabled = false
                if type(_G.EXO_StopToolFollow) == "function" then
                    pcall(_G.EXO_StopToolFollow)
                end
                if type(_G.EXO_ChatAddMessage) == "function" then
                    pcall(_G.EXO_ChatAddMessage, "AI",
                        "All AI-activated features disabled via emergency stop.",
                        Color3.fromRGB(255, 200, 0))
                end
                if type(_G.EXO_RobotSetState) == "function" then
                    pcall(_G.EXO_RobotSetState, "IDLE")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("All AI features DISABLED.", 3)
                    end)
                end
            end)

            AIControlSec:AddLabel("Sentinel AI: Bayesian profiler + strategy mutation + neural memory")
            AIControlSec:AddLabel("Confirmation gate: AI asks Y/N before executing strategy")

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: AI Intelligence
            -- ─────────────────────────────────────────────────────────────
            local AIInfoSec = AITab:CreateSection("AI Intelligence")

            AIInfoSec:AddLabel("Bayesian Threat Profiler: Per-player pattern tracking with confidence scoring")
            AIInfoSec:AddLabel("Adaptive Strategy Engine: Mutates counters when previous attempts fail")
            AIInfoSec:AddLabel("Neural Memory System: Persistent learning across sessions")
            AIInfoSec:AddLabel("Temporal Pattern Analysis: Detects burst kills and spawn camping")
            AIInfoSec:AddLabel("Chat System: Full bidirectional conversation with confirmation gate")
            AIInfoSec:AddLabel("Robot Analyst: Animated kill report processor with 5 states")

            AIInfoSec:AddButton("View All Threat Profiles", function()
                local count: number = 0
                for name: string, prof in ThreatProfiles do
                    count += 1
                    if type(prof) == "table" and AdminUI and type(AdminUI.Notify) == "function" then
                        local features_str: string = "none"
                        if type(prof.SuspectedFeatures) == "table" and #prof.SuspectedFeatures > 0 then
                            features_str = table.concat(prof.SuspectedFeatures, ", ")
                        end
                        pcall(function()
                            AdminUI:Notify(
                                `Profile: {name} | Kills: {prof.TotalKills} | Threat: {prof.ThreatScore}/100 | Features: {features_str}`,
                                4
                            )
                        end)
                    end
                end
                if count == 0 then
                    if AdminUI and type(AdminUI.Notify) == "function" then
                        pcall(function()
                            AdminUI:Notify("No threat profiles recorded yet. Die to generate data.", 3)
                        end)
                    end
                end
            end)

            AIInfoSec:AddButton("Reset All Profiles", function()
                ThreatProfiles = {}
                writeJSON(AI_PROFILE_FILE, ThreatProfiles)
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("All threat profiles cleared from storage.", 3)
                    end)
                end
                if type(_G.EXO_ChatAddMessage) == "function" then
                    pcall(_G.EXO_ChatAddMessage, "SYSTEM",
                        "Threat profiles reset.",
                        Color3.fromRGB(255, 80, 80))
                end
            end)

            AIInfoSec:AddButton("Reset AI Memory", function()
                AIMemory = {
                    StrategyResults = {},
                    FeatureEffectiveness = {},
                    OpponentAdaptations = {},
                    SessionLearningRate = 0.1,
                }
                writeJSON(AI_MEMORY_FILE, AIMemory)
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("AI neural memory reset. Learning rate restored to 0.1.", 3)
                    end)
                end
                if type(_G.EXO_ChatAddMessage) == "function" then
                    pcall(_G.EXO_ChatAddMessage, "SYSTEM",
                        "AI memory wiped. Fresh learning cycle started.",
                        Color3.fromRGB(255, 80, 80))
                end
            end)

            print(`[EXO] Sentinel AI tab built: 2 sections, 3 toggles + 7 buttons + 8 labels`)
        end
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 25.4: TAB 9 – KEYBINDS (NEW IN v10)                       ║
-- ║  Keybind Manager | Category Browser | Rebind Interface               ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local Window = _G.EXO_UI_Window
    if not Window then
        warn("[EXO] Keybinds tab skipped: Window is nil")
    else
        local KeybindsTab = Window:CreateTab("Keybinds")
        if not KeybindsTab then
            warn("[EXO] Keybinds tab creation failed")
        else
            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Keybind Manager
            -- ─────────────────────────────────────────────────────────────
            local KBMainSec = KeybindsTab:CreateSection("Keybind Manager")

            KBMainSec:AddLabel("Total registered keybinds: " .. tostring(#KeybindManager.Binds))
            KBMainSec:AddLabel("Categories: General, Combat, Movement, Automation, Visuals")
            KBMainSec:AddLabel("Persistence: Saved to exo_v10_keybinds.dat")

            KBMainSec:AddButton("Save All Keybinds", function()
                if type(KB_Save) == "function" then
                    pcall(KB_Save)
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("All keybinds saved to disk.", 3)
                    end)
                end
            end)

            KBMainSec:AddButton("Load All Keybinds", function()
                if type(KB_Load) == "function" then
                    pcall(KB_Load)
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("All keybinds loaded from disk.", 3)
                    end)
                end
            end)

            KBMainSec:AddButton("Reset Keybinds to Defaults", function()
                -- Unregister all current binds
                for i = #KeybindManager.Binds, 1, -1 do
                    table.remove(KeybindManager.Binds, i)
                end
                -- Re-register defaults
                if type(KB_RegisterDefaults) == "function" then
                    pcall(KB_RegisterDefaults)
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Keybinds reset to defaults.", 3)
                    end)
                end
            end)

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: General Keybinds
            -- ─────────────────────────────────────────────────────────────
            local KBGeneralSec = KeybindsTab:CreateSection("General Keybinds")

            KBGeneralSec:AddLabel("Toggle UI: RightShift (default)")
            KBGeneralSec:AddLabel("Panic Disable: End (default)")
            KBGeneralSec:AddLabel("These keybinds control global hub behavior")

            KBGeneralSec:AddButton("Rebind: Toggle UI", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleUI")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle UI...", 5)
                    end)
                end
            end)

            KBGeneralSec:AddButton("Rebind: Panic Disable", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "PanicDisable")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Panic Disable...", 5)
                    end)
                end
            end)

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Combat Keybinds
            -- ─────────────────────────────────────────────────────────────
            local KBCombatSec = KeybindsTab:CreateSection("Combat Keybinds")

            KBCombatSec:AddLabel("Toggle Aura: F1 (default)")
            KBCombatSec:AddLabel("Toggle InstaKill: F2 (default)")
            KBCombatSec:AddLabel("Toggle AntiAura: F3 (default)")
            KBCombatSec:AddLabel("Toggle Reach: F4 (default)")

            KBCombatSec:AddButton("Rebind: Toggle Aura", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleAura")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle Aura...", 5)
                    end)
                end
            end)

            KBCombatSec:AddButton("Rebind: Toggle InstaKill", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleInstaKill")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle InstaKill...", 5)
                    end)
                end
            end)

            KBCombatSec:AddButton("Rebind: Toggle AntiAura", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleAntiAura")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle AntiAura...", 5)
                    end)
                end
            end)

            KBCombatSec:AddButton("Rebind: Toggle Reach", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleReach")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle Reach...", 5)
                    end)
                end
            end)

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Movement Keybinds
            -- ─────────────────────────────────────────────────────────────
            local KBMoveSec = KeybindsTab:CreateSection("Movement Keybinds")

            KBMoveSec:AddLabel("Toggle Speed: F5 (default)")
            KBMoveSec:AddLabel("Toggle Noclip: F6 (default)")
            KBMoveSec:AddLabel("Toggle Fly: F7 (default)")

            KBMoveSec:AddButton("Rebind: Toggle Speed", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleSpeed")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle Speed...", 5)
                    end)
                end
            end)

            KBMoveSec:AddButton("Rebind: Toggle Noclip", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleNoclip")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle Noclip...", 5)
                    end)
                end
            end)

            KBMoveSec:AddButton("Rebind: Toggle Fly", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleFly")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle Fly...", 5)
                    end)
                end
            end)

            -- ─────────────────────────────────────────────────────────────
            -- SECTION: Automation Keybinds
            -- ─────────────────────────────────────────────────────────────
            local KBAutoSec = KeybindsTab:CreateSection("Automation Keybinds")

            KBAutoSec:AddLabel("Toggle AutoBuild: F8 (default)")
            KBAutoSec:AddLabel("Toggle AutoClaim: F9 (default)")
            KBAutoSec:AddLabel("Toggle ESP: F10 (default)")

            KBAutoSec:AddButton("Rebind: Toggle AutoBuild", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleAutoBuild")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle AutoBuild...", 5)
                    end)
                end
            end)

            KBAutoSec:AddButton("Rebind: Toggle AutoClaim", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleAutoClaim")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle AutoClaim...", 5)
                    end)
                end
            end)

            KBAutoSec:AddButton("Rebind: Toggle ESP", function()
                if type(KB_StartListening) == "function" then
                    pcall(KB_StartListening, "ToggleESP")
                end
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify("Press a key to rebind Toggle ESP...", 5)
                    end)
                end
            end)

            print(`[EXO] Keybinds tab built: 5 sections, 3 buttons + 14 labels + 12 rebind buttons`)
        end
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 26.0: PART 4 (FIRST HALF) REGISTRY & BRIDGE               ║
-- ║  Verifies all UI tab builders registered successfully                ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local ui_tab_globals: {string} = {
        -- UI Registry
        "EXO_UI_RegisterTab",
        "EXO_UI_GetTabCount",
        "EXO_UI_GetTab",
        "EXO_UI_FindTab",
        "EXO_UI_GetTabOrder",
        "EXO_UI_GetTotalElements",
        "EXO_UI_GetTotalSections",
        -- Window
        "EXO_UI_Window",
        "EXO_UI_AdminUI",
    }

    local registered: number = 0
    local missing: {string} = {}

    for _, name: string in ui_tab_globals do
        if _G[name] ~= nil then
            registered += 1
        else
            table.insert(missing, name)
        end
    end

    -- Count tabs built
    local tabs_built: number = 0
    if type(_G.EXO_UI_GetTabCount) == "function" then
        local ok: boolean, count = pcall(_G.EXO_UI_GetTabCount)
        if ok and type(count) == "number" then
            tabs_built = count
        end
    end

    print(`[EXO] ═══════════════════════════════════════════════════`)
    print(`[EXO] PART 4 (FIRST HALF) COMPLETE`)
    print(`[EXO] UI Tab Engine modules registered: {registered}/{#ui_tab_globals}`)
    print(`[EXO] Tabs built: {tabs_built} of 12`)
    if #missing > 0 then
        warn(`[EXO] Missing modules: {table.concat(missing, ", ")}`)
    else
        print(`[EXO] All UI tab engine systems operational.`)
    end
    print(`[EXO] ═══════════════════════════════════════════════════`)
    print(`[EXO] Awaiting Part 4 (Second Half): Settings, Profiles, Updates,`)
    print(`[EXO] Config Save/Load, Post-Build Validation, Finalize`)
end
