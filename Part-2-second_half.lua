-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  PART 2 (SECOND HALF): MOVEMENT + FSM ENGINE                         ║
-- ║  Sections 15.1-16.0 | EXO HUB v10.0 SENTINEL PRIME                   ║
-- ║  All sub-modules isolated in do...end blocks for register safety     ║
-- ╚══════════════════════════════════════════════════════════════════════╝

print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] PART 2 (SECOND HALF): MOVEMENT + FSM LOADING`)
print(`[EXO] Modules: Speed, Jump, Noclip, Fly, InfiniteJump, FSM`)
print(`[EXO] ═══════════════════════════════════════════════════`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15.1: 1000x SPEED SYSTEM                                  ║
-- ║  Heartbeat-driven WalkSpeed override | Auto-reset on respawn         ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _speed_conn: RBXScriptConnection? = nil
    local _speed_tick: number = 0

    local function _apply_speed(): ()
        if not Movement.SpeedHack then
            return
        end
        local char: Model? = player.Character
        if not char then
            return
        end
        local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum:IsA("Humanoid") then
            return
        end
        local ok: boolean = pcall(function()
            hum.WalkSpeed = Movement.SpeedValue
        end)
        if not ok then
            warn("[EXO-MOVE] Speed apply failed")
        end
    end

    local function _reset_speed(): ()
        local char: Model? = player.Character
        if not char then
            return
        end
        local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum:IsA("Humanoid") then
            return
        end
        pcall(function()
            hum.WalkSpeed = 16
        end)
    end

    local function startSpeedLoop(): ()
        if _speed_conn then
            pcall(function() _speed_conn:Disconnect() end)
        end
        _speed_tick = 0

        _speed_conn = RunService.Heartbeat:Connect(function()
            -- Throttle to every 5 heartbeats to save CPU on mobile
            _speed_tick += 1
            if _speed_tick % 5 ~= 0 then
                return
            end
            if not Movement.SpeedHack then
                return
            end
            _apply_speed()
        end)
    end

    local function stopSpeedLoop(): ()
        if _speed_conn then
            pcall(function() _speed_conn:Disconnect() end)
            _speed_conn = nil
        end
        _speed_tick = 0
        _reset_speed()
    end

    -- Expose via _G for cross-part access
    _G.EXO_StartSpeedLoop = startSpeedLoop
    _G.EXO_StopSpeedLoop = stopSpeedLoop
    _G.EXO_ApplySpeed = _apply_speed
    _G.EXO_ResetSpeed = _reset_speed

    print(`[EXO] Section 15.1 complete. Speed System registered.`)
    print(`[EXO]   Default value: {Movement.SpeedValue}`)
    print(`[EXO]   Heartbeat throttle: every 5 ticks (mobile optimized)`)
    print(`[EXO]   Auto-reset on stop: ENABLED`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15.2: 1000x JUMP POWER SYSTEM                             ║
-- ║  JumpPower override | UseJumpPower toggle | Auto-reset               ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _jump_conn: RBXScriptConnection? = nil
    local _jump_tick: number = 0

    local function _apply_jump(): ()
        if not Movement.JumpPower then
            return
        end
        local char: Model? = player.Character
        if not char then
            return
        end
        local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum:IsA("Humanoid") then
            return
        end
        pcall(function()
            hum.JumpPower = Movement.JumpValue
            hum.UseJumpPower = true
        end)
    end

    local function _reset_jump(): ()
        local char: Model? = player.Character
        if not char then
            return
        end
        local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum:IsA("Humanoid") then
            return
        end
        pcall(function()
            hum.JumpPower = 50
            hum.UseJumpPower = false
        end)
    end

    local function startJumpLoop(): ()
        if _jump_conn then
            pcall(function() _jump_conn:Disconnect() end)
        end
        _jump_tick = 0

        _jump_conn = RunService.Heartbeat:Connect(function()
            -- Throttle to every 5 heartbeats
            _jump_tick += 1
            if _jump_tick % 5 ~= 0 then
                return
            end
            if not Movement.JumpPower then
                return
            end
            _apply_jump()
        end)
    end

    local function stopJumpLoop(): ()
        if _jump_conn then
            pcall(function() _jump_conn:Disconnect() end)
            _jump_conn = nil
        end
        _jump_tick = 0
        _reset_jump()
    end

    _G.EXO_StartJumpLoop = startJumpLoop
    _G.EXO_StopJumpLoop = stopJumpLoop
    _G.EXO_ApplyJump = _apply_jump
    _G.EXO_ResetJump = _reset_jump

    print(`[EXO] Section 15.2 complete. Jump Power System registered.`)
    print(`[EXO]   Default value: {Movement.JumpValue}`)
    print(`[EXO]   UseJumpPower toggle: ENABLED while active`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15.3: 1000x NOCLIP SYSTEM                                 ║
-- ║  Stepped-driven CanCollide disable | Full restore on stop            ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _noclip_conn: RBXScriptConnection? = nil

    local function _disable_collision(): ()
        if not Movement.Noclip then
            return
        end
        local char: Model? = player.Character
        if not char then
            return
        end
        local children_ok: boolean, children = pcall(function() return char:GetDescendants() end)
        if not children_ok or type(children) ~= "table" then
            return
        end
        for _, part: Instance in children do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CanCollide = false
                end)
            end
        end
    end

    local function _restore_collision(): ()
        local char: Model? = player.Character
        if not char then
            return
        end
        local children_ok: boolean, children = pcall(function() return char:GetDescendants() end)
        if not children_ok or type(children) ~= "table" then
            return
        end
        for _, part: Instance in children do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CanCollide = true
                end)
            end
        end
    end

    local function startNoclip(): ()
        if _noclip_conn then
            pcall(function() _noclip_conn:Disconnect() end)
        end
        -- Use Stepped for highest priority (runs before physics)
        _noclip_conn = RunService.Stepped:Connect(function()
            if not Movement.Noclip then
                return
            end
            _disable_collision()
        end)
    end

    local function stopNoclip(): ()
        if _noclip_conn then
            pcall(function() _noclip_conn:Disconnect() end)
            _noclip_conn = nil
        end
        _restore_collision()
    end

    _G.EXO_StartNoclip = startNoclip
    _G.EXO_StopNoclip = stopNoclip
    _G.EXO_RestoreCollision = _restore_collision

    print(`[EXO] Section 15.3 complete. Noclip System registered.`)
    print(`[EXO]   Priority: Stepped (runs before physics)`)
    print(`[EXO]   Full restore on stop: ENABLED`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15.4: 1000x FLY SYSTEM                                    ║
-- ║  BodyVelocity + BodyGyro | WASD + Space/Shift | Camera-relative      ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _fly_conn: RBXScriptConnection? = nil
    local _fly_body_vel: BodyVelocity? = nil
    local _fly_body_gyro: BodyGyro? = nil
    local _fly_camera: Camera? = nil
    local _fly_anchor_hrp: BasePart? = nil

    local function _cleanup_fly_objects(): ()
        if _fly_body_vel and _fly_body_vel.Parent then
            pcall(function() _fly_body_vel:Destroy() end)
            _fly_body_vel = nil
        end
        if _fly_body_gyro and _fly_body_gyro.Parent then
            pcall(function() _fly_body_gyro:Destroy() end)
            _fly_body_gyro = nil
        end
        _fly_camera = nil
        _fly_anchor_hrp = nil
    end

    local function startFly(): ()
        if _fly_conn then
            pcall(function() _fly_conn:Disconnect() end)
        end

        local char: Model? = player.Character
        if not char then
            return
        end
        local hrp: Instance? = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp:IsA("BasePart") then
            return
        end
        _fly_anchor_hrp = hrp
        _fly_camera = workspace.CurrentCamera

        -- Create BodyVelocity for movement
        local bv_ok: boolean, bv = pcall(function()
            local b: BodyVelocity = Instance.new("BodyVelocity")
            b.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            b.Velocity = Vector3.zero
            b.P = 10000
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

        -- Disable gravity influence on character while flying
        local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
        if hum and hum:IsA("Humanoid") then
            pcall(function()
                hum.PlatformStand = true
            end)
        end

        _fly_conn = RunService.RenderStepped:Connect(function()
            if not Movement.Fly then
                return
            end
            if not _fly_body_vel or not _fly_body_gyro then
                return
            end
            if not _fly_camera then
                _fly_camera = workspace.CurrentCamera
                if not _fly_camera then
                    return
                end
            end

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

            -- Mobile fallback: if no keyboard input detected, hover in place
            -- (Mobile users can use the UI joystick via future integration)

            -- Normalize and apply speed
            if moveVec.Magnitude > 0 then
                moveVec = moveVec.Unit * Movement.FlySpeed
            end

            pcall(function()
                if _fly_body_vel then
                    _fly_body_vel.Velocity = moveVec
                end
            end)
            pcall(function()
                if _fly_body_gyro then
                    _fly_body_gyro.CFrame = camCF
                end
            end)
        end)
    end

    local function stopFly(): ()
        if _fly_conn then
            pcall(function() _fly_conn:Disconnect() end)
            _fly_conn = nil
        end
        _cleanup_fly_objects()

        -- Restore platform stand
        local char: Model? = player.Character
        if char then
            local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
            if hum and hum:IsA("Humanoid") then
                pcall(function()
                    hum.PlatformStand = false
                end)
            end
        end
    end

    _G.EXO_StartFly = startFly
    _G.EXO_StopFly = stopFly

    print(`[EXO] Section 15.4 complete. Fly System registered.`)
    print(`[EXO]   Controls: WASD + Space/Shift`)
    print(`[EXO]   Speed: {Movement.FlySpeed} studs/s`)
    print(`[EXO]   Orientation: Camera-relative BodyGyro`)
    print(`[EXO]   PlatformStand: ENABLED while flying`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15.5: 1000x INFINITE JUMP SYSTEM                          ║
-- ║  JumpRequest listener | HumanoidState override                       ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _infjump_conn: RBXScriptConnection? = nil

    local function startInfiniteJump(): ()
        if _infjump_conn then
            pcall(function() _infjump_conn:Disconnect() end)
        end

        _infjump_conn = UserInputService.JumpRequest:Connect(function()
            if not Movement.InfiniteJump then
                return
            end
            local char: Model? = player.Character
            if not char then
                return
            end
            local hum: Instance? = char:FindFirstChildOfClass("Humanoid")
            if not hum or not hum:IsA("Humanoid") then
                return
            end
            -- Check if humanoid is alive before forcing jump
            local health_ok: boolean, health = pcall(function() return hum.Health end)
            if not health_ok or type(health) ~= "number" or health <= 0 then
                return
            end
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end)
    end

    local function stopInfiniteJump(): ()
        if _infjump_conn then
            pcall(function() _infjump_conn:Disconnect() end)
            _infjump_conn = nil
        end
    end

    _G.EXO_StartInfiniteJump = startInfiniteJump
    _G.EXO_StopInfiniteJump = stopInfiniteJump

    print(`[EXO] Section 15.5 complete. Infinite Jump System registered.`)
    print(`[EXO]   Trigger: UserInputService.JumpRequest`)
    print(`[EXO]   Method: HumanoidStateType.Jumping override`)
    print(`[EXO]   Health check: ENABLED (no jump on dead humanoid)`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15.6: MOVEMENT MASTER TOGGLE & RESPAWN RESET              ║
-- ║  Central dispatcher for all movement features                        ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local function movementHandleToggle(feature: string, state: boolean): ()
        if type(feature) ~= "string" then
            return
        end

        if feature == "SpeedHack" then
            Movement.SpeedHack = state
            if state then
                if type(_G.EXO_StartSpeedLoop) == "function" then
                    pcall(_G.EXO_StartSpeedLoop)
                end
            else
                if type(_G.EXO_StopSpeedLoop) == "function" then
                    pcall(_G.EXO_StopSpeedLoop)
                end
            end
        elseif feature == "JumpPower" then
            Movement.JumpPower = state
            if state then
                if type(_G.EXO_StartJumpLoop) == "function" then
                    pcall(_G.EXO_StartJumpLoop)
                end
            else
                if type(_G.EXO_StopJumpLoop) == "function" then
                    pcall(_G.EXO_StopJumpLoop)
                end
            end
        elseif feature == "Noclip" then
            Movement.Noclip = state
            if state then
                if type(_G.EXO_StartNoclip) == "function" then
                    pcall(_G.EXO_StartNoclip)
                end
            else
                if type(_G.EXO_StopNoclip) == "function" then
                    pcall(_G.EXO_StopNoclip)
                end
            end
        elseif feature == "Fly" then
            Movement.Fly = state
            if state then
                if type(_G.EXO_StartFly) == "function" then
                    pcall(_G.EXO_StartFly)
                end
            else
                if type(_G.EXO_StopFly) == "function" then
                    pcall(_G.EXO_StopFly)
                end
            end
        elseif feature == "InfiniteJump" then
            Movement.InfiniteJump = state
            if state then
                if type(_G.EXO_StartInfiniteJump) == "function" then
                    pcall(_G.EXO_StartInfiniteJump)
                end
            else
                if type(_G.EXO_StopInfiniteJump) == "function" then
                    pcall(_G.EXO_StopInfiniteJump)
                end
            end
        end
    end

    local function movementStopAll(): ()
        Movement.SpeedHack = false
        Movement.JumpPower = false
        Movement.Noclip = false
        Movement.Fly = false
        Movement.InfiniteJump = false
        if type(_G.EXO_StopSpeedLoop) == "function" then pcall(_G.EXO_StopSpeedLoop) end
        if type(_G.EXO_StopJumpLoop) == "function" then pcall(_G.EXO_StopJumpLoop) end
        if type(_G.EXO_StopNoclip) == "function" then pcall(_G.EXO_StopNoclip) end
        if type(_G.EXO_StopFly) == "function" then pcall(_G.EXO_StopFly) end
        if type(_G.EXO_StopInfiniteJump) == "function" then pcall(_G.EXO_StopInfiniteJump) end
    end

    -- Auto-reset all movement on character respawn
    player.CharacterAdded:Connect(function()
        task.defer(function()
            if type(_G.EXO_ResetSpeed) == "function" then
                pcall(_G.EXO_ResetSpeed)
            end
            if type(_G.EXO_ResetJump) == "function" then
                pcall(_G.EXO_ResetJump)
            end
            -- Stop fly and noclip on respawn to prevent orphaned BodyMovers
            if Movement.Fly and type(_G.EXO_StopFly) == "function" then
                pcall(_G.EXO_StopFly)
                Movement.Fly = false
            end
            if Movement.Noclip and type(_G.EXO_StopNoclip) == "function" then
                pcall(_G.EXO_StopNoclip)
                Movement.Noclip = false
            end
        end)
    end)

    _G.EXO_Movement_HandleToggle = movementHandleToggle
    _G.EXO_Movement_StopAll = movementStopAll

    print(`[EXO] Section 15.6 complete. Movement Master Toggle registered.`)
    print(`[EXO]   Features: SpeedHack, JumpPower, Noclip, Fly, InfiniteJump`)
    print(`[EXO]   Auto-reset on respawn: ENABLED`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15.7: FSM STATE DEFINITIONS & MODE CONFIGS                ║
-- ║  Type-safe mode enum | Per-mode feature matrices                     ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    -- FSM Mode type (Luau: string union for type safety)
    -- Already declared in Part 1 Section 12.5 as FSMMode
    -- Re-declare mode config table here for FSM engine consumption

    local fsm_mode_configs: {[string]: {[string]: boolean}} = {
        IDLE = {
            Aura = false,
            InstantKill = false,
            AntiAura = false,
            AutoBuild = false,
            AutoClaimMoney = false,
            ToolFollow = false,
            SpeedHack = false,
            Noclip = false,
        },
        TYCOON = {
            Aura = false,
            InstantKill = false,
            AntiAura = false,
            AutoBuild = true,
            AutoClaimMoney = true,
            ToolFollow = false,
            SpeedHack = true, -- Faster farming movement
            Noclip = false,
        },
        DEFENSIVE = {
            Aura = false,
            InstantKill = false,
            AntiAura = true,
            AutoBuild = false,
            AutoClaimMoney = false,
            ToolFollow = false,
            SpeedHack = true, -- Faster escape movement
            Noclip = false,
        },
        COMBAT = {
            Aura = true,
            InstantKill = true,
            AntiAura = true,
            AutoBuild = false,
            AutoClaimMoney = false,
            ToolFollow = true,
            SpeedHack = false,
            Noclip = false,
        },
    }

    -- Expose mode configs globally for FSM engine and UI
    _G.EXO_FSM_MODE_CONFIGS = fsm_mode_configs

    print(`[EXO] Section 15.7 complete. FSM Mode Configs registered.`)
    print(`[EXO]   Modes defined: 4 (IDLE, TYCOON, DEFENSIVE, COMBAT)`)
    print(`[EXO]   Features per mode: 8`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15.8: FSM SCORING ENGINE                                  ║
-- ║  Real-time mode score calculation from threat + economy data         ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local function fsmCalculateModeScores(): {[string]: number}
        local scores: {[string]: number} = {
            IDLE = 10, -- Baseline to prevent oscillation
            TYCOON = 0,
            DEFENSIVE = 0,
            COMBAT = 0,
        }

        local timeSinceDeath: number = tick() - LastDeathTime
        local timeSinceSpawn: number = tick() - LastSpawnTime

        -- ═══════════════════════════════════════════════════════════
        -- TYCOON SCORE: High when safe + alive for a while + cash
        -- ═══════════════════════════════════════════════════════════
        if ThreatLevel <= 2 then
            scores.TYCOON += 30
        end
        if timeSinceDeath > 30 then
            scores.TYCOON += 25
        end
        if timeSinceSpawn > 10 then
            scores.TYCOON += 15
        end
        local cash: number = getPlayerCash()
        if cash > 0 then
            scores.TYCOON += 20
        end
        if cash > 1000 then
            scores.TYCOON += 10
        end

        -- ═══════════════════════════════════════════════════════════
        -- DEFENSIVE SCORE: High when moderate threat + recently died
        -- ═══════════════════════════════════════════════════════════
        if ThreatLevel >= 3 and ThreatLevel <= 5 then
            scores.DEFENSIVE += 35
        end
        if timeSinceDeath < 10 then
            scores.DEFENSIVE += 30
        end
        if DeathCount > 0 and timeSinceDeath < 20 then
            scores.DEFENSIVE += 20
        end
        if ThreatTrend > 0 then
            scores.DEFENSIVE += 15
        end

        -- ═══════════════════════════════════════════════════════════
        -- COMBAT SCORE: High when critical threat + armed
        -- ═══════════════════════════════════════════════════════════
        if ThreatLevel > 5 then
            scores.COMBAT += 40
        end
        if PeakThreat > 7 then
            scores.COMBAT += 20
        end

        -- Check if player has combat tools equipped
        local hasCombatTool: boolean = false
        local myChar: Model? = player.Character
        if myChar then
            local children_ok: boolean, children = pcall(function() return myChar:GetChildren() end)
            if children_ok and type(children) == "table" then
                for _, item: Instance in children do
                    if item:IsA("Tool") then
                        hasCombatTool = true
                        break
                    end
                end
            end
        end
        if hasCombatTool then
            scores.COMBAT += 25
        end

        -- Check AI profiles for known threats nearby
        local knownThreatsNearby: number = 0
        for name: string, prof in ThreatProfiles do
            if type(prof) == "table" and type(prof.ThreatScore) == "number" and prof.ThreatScore > 50 then
                if type(prof.LastSeen) == "number" and os.time() - prof.LastSeen < 60 then
                    knownThreatsNearby += 1
                end
            end
        end
        if knownThreatsNearby > 0 then
            scores.COMBAT += knownThreatsNearby * 10
        end

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

    _G.EXO_FSM_CalculateModeScores = fsmCalculateModeScores
    _G.EXO_FSM_DetermineOptimalMode = fsmDetermineOptimalMode

    print(`[EXO] Section 15.8 complete. FSM Scoring Engine registered.`)
    print(`[EXO]   Score inputs: ThreatLevel, deaths, spawn time, cash, tools, profiles`)
    print(`[EXO]   Output: Optimal mode selection`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15.9: FSM TRANSITION & APPLICATION ENGINE                 ║
-- ║  Mode switching with hysteresis | Feature application                ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local function fsmApplyMode(mode: string): ()
        local configs = _G.EXO_FSM_MODE_CONFIGS
        if type(configs) ~= "table" then
            return
        end
        local config = configs[mode]
        if type(config) ~= "table" then
            return
        end

        -- Apply Aura setting
        if config.Aura ~= Aura.Enabled then
            Aura.Enabled = config.Aura
            if config.Aura then
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
            else
                if type(_G.EXO_StopAuraLoop) == "function" then
                    pcall(_G.EXO_StopAuraLoop)
                end
            end
        end

        -- Apply InstantKill setting
        if config.InstantKill ~= InstantKill then
            InstantKill = config.InstantKill
        end

        -- Apply InstaKillEnabled for actual kill loop
        if config.InstantKill ~= InstaKillEnabled then
            InstaKillEnabled = config.InstantKill
            if config.InstantKill then
                if type(_G.EXO_StartInstaKill) == "function" then
                    pcall(_G.EXO_StartInstaKill)
                end
            else
                if type(_G.EXO_StopInstaKill) == "function" then
                    pcall(_G.EXO_StopInstaKill)
                end
            end
        end

        -- Apply AntiAura setting
        if config.AntiAura ~= AntiAura.Enabled then
            AntiAura.Enabled = config.AntiAura
            if config.AntiAura then
                AntiAura.GodMode = true
                AntiAura.Repel = true
                AntiAura.Phase = true
                if type(_G.EXO_StartAntiAura) == "function" then
                    pcall(_G.EXO_StartAntiAura)
                end
            else
                if type(_G.EXO_StopAntiAura) == "function" then
                    pcall(_G.EXO_StopAntiAura)
                end
            end
        end

        -- Apply AutoBuild setting
        if config.AutoBuild ~= AutoBuild then
            AutoBuild = config.AutoBuild
            if config.AutoBuild then
                if type(_G.EXO_StartAutoBuild) == "function" then
                    pcall(_G.EXO_StartAutoBuild)
                end
            else
                if type(_G.EXO_StopAutoBuild) == "function" then
                    pcall(_G.EXO_StopAutoBuild)
                end
            end
        end

        -- Apply AutoClaimMoney setting
        if config.AutoClaimMoney ~= AutoClaimMoney then
            AutoClaimMoney = config.AutoClaimMoney
            if config.AutoClaimMoney then
                if type(_G.EXO_StartClaimMoney) == "function" then
                    pcall(_G.EXO_StartClaimMoney)
                end
            else
                if type(_G.EXO_StopClaimMoney) == "function" then
                    pcall(_G.EXO_StopClaimMoney)
                end
            end
        end

        -- Apply ToolFollow setting
        if config.ToolFollow ~= ToolFollow.Enabled then
            ToolFollow.Enabled = config.ToolFollow
            if config.ToolFollow then
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
            else
                if type(_G.EXO_StopToolFollow) == "function" then
                    pcall(_G.EXO_StopToolFollow)
                end
            end
        end

        -- Apply SpeedHack setting
        if config.SpeedHack ~= Movement.SpeedHack then
            Movement.SpeedHack = config.SpeedHack
            if config.SpeedHack then
                if type(_G.EXO_StartSpeedLoop) == "function" then
                    pcall(_G.EXO_StartSpeedLoop)
                end
            else
                if type(_G.EXO_StopSpeedLoop) == "function" then
                    pcall(_G.EXO_StopSpeedLoop)
                end
            end
        end

        -- Apply Noclip setting
        if config.Noclip ~= Movement.Noclip then
            Movement.Noclip = config.Noclip
            if config.Noclip then
                if type(_G.EXO_StartNoclip) == "function" then
                    pcall(_G.EXO_StartNoclip)
                end
            else
                if type(_G.EXO_StopNoclip) == "function" then
                    pcall(_G.EXO_StopNoclip)
                end
            end
        end
    end

    local function fsmTransitionTo(newMode: string, reason: string): ()
        if type(newMode) ~= "string" then
            return
        end
        if type(reason) ~= "string" then
            reason = "unspecified"
        end

        -- Access FSMEngine state via global bridge
        local engine = _G.EXO_FSM_ENGINE_STATE
        if type(engine) ~= "table" then
            return
        end

        if newMode == engine.CurrentMode then
            return -- Already in this mode
        end

        engine.PreviousMode = engine.CurrentMode
        engine.CurrentMode = newMode
        engine.ModeStartTime = tick()
        engine.TransitionCount += 1

        -- Apply the new mode's configuration
        fsmApplyMode(newMode)

        -- Log transition to chat if available
        if type(_G.EXO_ChatAddMessage) == "function" then
            pcall(_G.EXO_ChatAddMessage, "SYSTEM",
                `FSM TRANSITION: {engine.PreviousMode} → {newMode} ({reason})`,
                Color3.fromRGB(0, 255, 255))
        end

        -- Log to console
        print(`[EXO-FSM] Transition: {engine.PreviousMode} → {newMode} | Reason: {reason}`)
    end

    _G.EXO_FSM_ApplyMode = fsmApplyMode
    _G.EXO_FSM_TransitionTo = fsmTransitionTo

    print(`[EXO] Section 15.9 complete. FSM Transition Engine registered.`)
    print(`[EXO]   Features applied per mode: 8`)
    print(`[EXO]   Chat logging: ENABLED`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15.10: FSM HEARTBEAT ENGINE & EMERGENCY OVERRIDES         ║
-- ║  Main evaluation loop | Hysteresis | Threat spike handling           ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    -- Initialize FSM engine state (persisted across section boundaries)
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
    local SWITCH_THRESHOLD: number = 15 -- Hysteresis threshold

    local function fsmStartEngine(): ()
        if _fsm_conn then
            pcall(function() _fsm_conn:Disconnect() end)
        end

        local engine = _G.EXO_FSM_ENGINE_STATE
        engine.AutoSwitchEnabled = true

        _fsm_conn = RunService.Heartbeat:Connect(function(dt: number)
            if not engine.AutoSwitchEnabled then
                return
            end

            -- Throttle evaluations to EvaluationInterval
            if tick() - engine.LastEvaluation < engine.EvaluationInterval then
                return
            end
            engine.LastEvaluation = tick()

            -- Update mode duration
            engine.ModeDuration = tick() - engine.ModeStartTime

            -- Calculate mode scores based on real-time data
            local scores: {[string]: number}? = nil
            if type(_G.EXO_FSM_CalculateModeScores) == "function" then
                local ok: boolean, result = pcall(_G.EXO_FSM_CalculateModeScores)
                if ok and type(result) == "table" then
                    scores = result
                end
            end
            if not scores then
                return
            end

            -- Determine optimal mode
            local optimalMode: string = "IDLE"
            if type(_G.EXO_FSM_DetermineOptimalMode) == "function" then
                local ok: boolean, result = pcall(_G.EXO_FSM_DetermineOptimalMode, scores)
                if ok and type(result) == "string" then
                    optimalMode = result
                end
            end

            -- Hysteresis: Only switch if optimal mode has significantly higher score
            local currentScore: number = scores[engine.CurrentMode] or 0
            local optimalScore: number = scores[optimalMode] or 0

            if optimalMode ~= engine.CurrentMode and optimalScore > currentScore + SWITCH_THRESHOLD then
                local reason: string = `score {optimalScore} vs current {currentScore}`
                if type(_G.EXO_FSM_TransitionTo) == "function" then
                    pcall(_G.EXO_FSM_TransitionTo, optimalMode, reason)
                end
            end

            -- Emergency override: If threat spikes suddenly, force COMBAT mode
            if ThreatLevel > 7 and engine.CurrentMode ~= "COMBAT" then
                if type(_G.EXO_FSM_TransitionTo) == "function" then
                    pcall(_G.EXO_FSM_TransitionTo, "COMBAT", "EMERGENCY: Threat spike detected")
                end
            end

            -- Emergency override: If just died, force DEFENSIVE mode
            local timeSinceDeath: number = tick() - LastDeathTime
            if timeSinceDeath < 3 and engine.CurrentMode ~= "DEFENSIVE" and DeathCount > 0 then
                if type(_G.EXO_FSM_TransitionTo) == "function" then
                    pcall(_G.EXO_FSM_TransitionTo, "DEFENSIVE", "EMERGENCY: Recent death detected")
                end
            end
        end)
    end

    local function fsmStopEngine(): ()
        if _fsm_conn then
            pcall(function() _fsm_conn:Disconnect() end)
            _fsm_conn = nil
        end
        local engine = _G.EXO_FSM_ENGINE_STATE
        if type(engine) == "table" then
            engine.AutoSwitchEnabled = false
        end
    end

    local function fsmSetAutoSwitch(enabled: boolean): ()
        local engine = _G.EXO_FSM_ENGINE_STATE
        if type(engine) ~= "table" then
            return
        end
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
        if type(_G.EXO_FSM_CalculateModeScores) == "function" then
            local ok: boolean, result = pcall(_G.EXO_FSM_CalculateModeScores)
            if ok and type(result) == "table" then
                return result
            end
        end
        return {IDLE = 0, TYCOON = 0, DEFENSIVE = 0, COMBAT = 0}
    end

    _G.EXO_FSM_Start = fsmStartEngine
    _G.EXO_FSM_Stop = fsmStopEngine
    _G.EXO_FSM_SetAutoSwitch = fsmSetAutoSwitch
    _G.EXO_FSM_GetCurrentMode = fsmGetCurrentMode
    _G.EXO_FSM_GetModeScores = fsmGetModeScores

    print(`[EXO] Section 15.10 complete. FSM Heartbeat Engine registered.`)
    print(`[EXO]   Evaluation interval: 1.0s`)
    print(`[EXO]   Hysteresis threshold: {SWITCH_THRESHOLD} points`)
    print(`[EXO]   Emergency overrides: Threat spike → COMBAT, Death → DEFENSIVE`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 16.0: PART 2 REGISTRY & CROSS-MODULE BRIDGE               ║
-- ║  Verifies all movement + FSM modules registered successfully         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local movement_fsm_globals: {string} = {
        -- Movement
        "EXO_StartSpeedLoop",
        "EXO_StopSpeedLoop",
        "EXO_ApplySpeed",
        "EXO_ResetSpeed",
        "EXO_StartJumpLoop",
        "EXO_StopJumpLoop",
        "EXO_ApplyJump",
        "EXO_ResetJump",
        "EXO_StartNoclip",
        "EXO_StopNoclip",
        "EXO_RestoreCollision",
        "EXO_StartFly",
        "EXO_StopFly",
        "EXO_StartInfiniteJump",
        "EXO_StopInfiniteJump",
        "EXO_Movement_HandleToggle",
        "EXO_Movement_StopAll",
        -- FSM
        "EXO_FSM_CalculateModeScores",
        "EXO_FSM_DetermineOptimalMode",
        "EXO_FSM_ApplyMode",
        "EXO_FSM_TransitionTo",
        "EXO_FSM_Start",
        "EXO_FSM_Stop",
        "EXO_FSM_SetAutoSwitch",
        "EXO_FSM_GetCurrentMode",
        "EXO_FSM_GetModeScores",
    }

    local registered: number = 0
    local missing: {string} = {}

    for _, name: string in movement_fsm_globals do
        if type(_G[name]) == "function" then
            registered += 1
        else
            table.insert(missing, name)
        end
    end

    -- Verify FSM engine state table
    local engineStateOk: boolean = type(_G.EXO_FSM_ENGINE_STATE) == "table"
    local modeConfigsOk: boolean = type(_G.EXO_FSM_MODE_CONFIGS) == "table"

    print(`[EXO] ═══════════════════════════════════════════════════`)
    print(`[EXO] PART 2 (SECOND HALF) COMPLETE`)
    print(`[EXO] Movement + FSM modules registered: {registered}/{#movement_fsm_globals}`)
    print(`[EXO] FSM Engine State: {if engineStateOk then "OK" else "MISSING"}`)
    print(`[EXO] FSM Mode Configs: {if modeConfigsOk then "OK" else "MISSING"}`)
    if #missing > 0 then
        warn(`[EXO] Missing modules: {table.concat(missing, ", ")}`)
    else
        print(`[EXO] All movement + FSM systems operational.`)
    end
    print(`[EXO] ═══════════════════════════════════════════════════`)
    print(`[EXO] PART 2 FULLY COMPLETE: Combat + Movement + FSM`)
    print(`[EXO] Next: Part 3 – Visuals, Automation, Kill Intel, AI Chat`)
end
