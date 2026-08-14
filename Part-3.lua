-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  PART 3 (FIRST HALF): VISUALS + AUTOMATION (INITIAL)                 ║
-- ║  Sections 17.1-19.0 | EXO HUB v10.0 SENTINEL PRIME                   ║
-- ║  All sub-modules isolated in do...end blocks for register safety     ║
-- ╚══════════════════════════════════════════════════════════════════════╝

print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] PART 3 (FIRST HALF): VISUALS + AUTOMATION LOADING`)
print(`[EXO] Modules: ESP, AntiLag, Chams, Highlights, Tycoon, ToolGrabber`)
print(`[EXO] ═══════════════════════════════════════════════════`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 17.1: 1000x ESP SYSTEM                                    ║
-- ║  Threat-colored dots | Name labels | Distance-based coloring         ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _esp_gui: ScreenGui? = nil
    local _esp_dots: {[Player]: Frame} = {}
    local _esp_render_conn: RBXScriptConnection? = nil

    local function _esp_create_dot(plr: Player): ()
        if not plr then
            return
        end
        if _esp_dots[plr] then
            return -- Already exists
        end
        if not _esp_gui then
            return
        end

        local container_ok: boolean, container = pcall(function()
            local c: Frame = Instance.new("Frame")
            c.Size = UDim2.new(0, 60, 0, 20)
            c.BackgroundTransparency = 1
            c.Parent = _esp_gui
            return c
        end)
        if not container_ok or not container then
            return
        end

        local dot_ok: boolean, dot = pcall(function()
            local d: Frame = Instance.new("Frame")
            d.Size = UDim2.new(0, 8, 0, 8)
            d.Position = UDim2.new(0.5, -4, 0, 0)
            d.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            d.BorderSizePixel = 0
            d.Parent = container
            Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
            return d
        end)

        local name_ok: boolean, nameLabel = pcall(function()
            local n: TextLabel = Instance.new("TextLabel")
            n.Size = UDim2.new(1, 0, 0, 10)
            n.Position = UDim2.new(0, 0, 0, 10)
            n.BackgroundTransparency = 1
            n.Text = plr.Name
            n.TextColor3 = Color3.fromRGB(230, 240, 255)
            n.TextSize = 8
            n.Font = Enum.Font.Gotham
            n.Parent = container
            return n
        end)

        if dot_ok and dot then
            _esp_dots[plr] = container
        end
    end

    local function _esp_destroy_dot(plr: Player): ()
        if _esp_dots[plr] then
            pcall(function()
                _esp_dots[plr]:Destroy()
            end)
            _esp_dots[plr] = nil
        end
    end

    local function startESP(): ()
        if _esp_gui then
            return
        end

        local gui_ok: boolean, gui = pcall(function()
            local g: ScreenGui = Instance.new("ScreenGui")
            g.Name = "EXO_ESP"
            g.ResetOnSpawn = false
            return g
        end)
        if not gui_ok or not gui then
            warn("[EXO] Failed to create ESP GUI")
            return
        end

        pcall(function()
            gui.Parent = CoreGui
        end)
        if not gui.Parent then
            pcall(function()
                gui.Parent = player:WaitForChild("PlayerGui")
            end)
        end
        if not gui.Parent then
            warn("[EXO] ESP GUI has no parent")
            return
        end
        _esp_gui = gui

        -- Create dots for all existing players
        local players_ok: boolean, players_list = pcall(function() return Players:GetPlayers() end)
        if players_ok and type(players_list) == "table" then
            for _, plr: Player in players_list do
                if plr ~= player then
                    _esp_create_dot(plr)
                end
            end
        end

        -- Handle new players joining
        Players.PlayerAdded:Connect(function(plr: Player)
            if plr ~= player and ESPEnabled then
                _esp_create_dot(plr)
            end
        end)

        -- Handle players leaving
        Players.PlayerRemoving:Connect(function(plr: Player)
            _esp_destroy_dot(plr)
        end)

        -- Render loop: Update positions + threat colors
        if _esp_render_conn then
            pcall(function() _esp_render_conn:Disconnect() end)
        end
        _esp_render_conn = RunService.RenderStepped:Connect(function()
            if not ESPEnabled then
                return
            end
            local cam: Camera? = workspace.CurrentCamera
            if not cam then
                return
            end
            local myChar: Model? = player.Character
            local myPos: Vector3? = nil
            if myChar then
                local myRoot: Instance? = myChar:FindFirstChild("HumanoidRootPart")
                if myRoot and myRoot:IsA("BasePart") then
                    local pos_ok: boolean, pos_val = pcall(function() return myRoot.Position end)
                    if pos_ok and typeof(pos_val) == "Vector3" then
                        myPos = pos_val
                    end
                end
            end

            for plr: Player, container: Frame in _esp_dots do
                if container and container.Parent then
                    local char_ok: boolean, plrChar = pcall(function() return plr.Character end)
                    if char_ok and plrChar then
                        local hrp: Instance? = plrChar:FindFirstChild("HumanoidRootPart")
                        if hrp and hrp:IsA("BasePart") then
                            local vp_ok: boolean, pos, onScreen = pcall(function()
                                return cam:WorldToViewportPoint(hrp.Position)
                            end)
                            if vp_ok and typeof(pos) == "Vector3" then
                                pcall(function()
                                    container.Position = UDim2.new(0, pos.X - 30, 0, pos.Y - 10)
                                    container.Visible = onScreen
                                end)

                                -- Threat coloring based on distance
                                if myPos then
                                    local dist_ok: boolean, dist = pcall(function()
                                        return (hrp.Position - myPos).Magnitude
                                    end)
                                    if dist_ok and type(dist) == "number" then
                                        local dot: Frame? = container:FindFirstChildOfClass("Frame")
                                        if dot then
                                            local newColor: Color3
                                            if dist < 15 then
                                                newColor = Color3.fromRGB(255, 0, 0)
                                            elseif dist < 30 then
                                                newColor = Color3.fromRGB(255, 150, 0)
                                            else
                                                newColor = Color3.fromRGB(0, 255, 100)
                                            end
                                            pcall(function()
                                                dot.BackgroundColor3 = newColor
                                            end)
                                        end
                                    end
                                end
                            end
                        else
                            pcall(function()
                                container.Visible = false
                            end)
                        end
                    else
                        pcall(function()
                            container.Visible = false
                        end)
                    end
                end
            end
        end)
    end

    local function stopESP(): ()
        if _esp_render_conn then
            pcall(function() _esp_render_conn:Disconnect() end)
            _esp_render_conn = nil
        end
        if _esp_gui then
            pcall(function()
                _esp_gui:Destroy()
            end)
            _esp_gui = nil
        end
        table.clear(_esp_dots)
    end

    _G.EXO_StartESP = startESP
    _G.EXO_StopESP = stopESP

    print(`[EXO] Section 17.1 complete. ESP System registered.`)
    print(`[EXO]   Colors: Red (<15), Orange (<30), Green (>30) studs`)
    print(`[EXO]   Features: Name labels, auto player tracking`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 17.2: 1000x ANTI-LAG SHIELD                               ║
-- ║  Particles, Beams, Trails, Sounds, PostEffects, Shadows, Fog         ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _antilag_applied: boolean = false
    local _antilag_original_fog: number = 100000
    local _antilag_original_brightness: number = 2

    local function startAntiLag(): ()
        if _antilag_applied then
            return
        end

        -- Save original lighting values for restoration
        local fog_ok: boolean, fog_val = pcall(function() return Lighting.FogEnd end)
        if fog_ok and type(fog_val) == "number" then
            _antilag_original_fog = fog_val
        end
        local bright_ok: boolean, bright_val = pcall(function() return Lighting.Brightness end)
        if bright_ok and type(bright_val) == "number" then
            _antilag_original_brightness = bright_val
        end

        pcall(function()
            -- Disable particles, beams, trails, sounds
            local desc_ok: boolean, descendants = pcall(function() return workspace:GetDescendants() end)
            if desc_ok and type(descendants) == "table" then
                for _, obj: Instance in descendants do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                        pcall(function()
                            obj.Enabled = false
                        end)
                    end
                    if obj:IsA("Sound") then
                        local playing_ok: boolean, isPlaying = pcall(function() return obj.Playing end)
                        if playing_ok and isPlaying then
                            pcall(function()
                                obj.Volume = 0
                            end)
                        end
                    end
                end
            end

            -- Lighting optimizations
            pcall(function()
                Lighting.GlobalShadows = false
            end)
            pcall(function()
                Lighting.Brightness = 1
            end)
            pcall(function()
                Lighting.FogEnd = 500
            end)

            -- Disable post-processing effects
            local lighting_ok: boolean, lighting_children = pcall(function() return Lighting:GetChildren() end)
            if lighting_ok and type(lighting_children) == "table" then
                for _, effect: Instance in lighting_children do
                    if effect:IsA("PostEffect") then
                        pcall(function()
                            effect.Enabled = false
                        end)
                    end
                end
            end
        end)

        -- Set rendering quality to lowest level
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        _antilag_applied = true
    end

    local function stopAntiLag(): ()
        if not _antilag_applied then
            return
        end

        pcall(function()
            pcall(function()
                Lighting.GlobalShadows = true
            end)
            pcall(function()
                Lighting.Brightness = _antilag_original_brightness
            end)
            pcall(function()
                Lighting.FogEnd = _antilag_original_fog
            end)

            local lighting_ok: boolean, lighting_children = pcall(function() return Lighting:GetChildren() end)
            if lighting_ok and type(lighting_children) == "table" then
                for _, effect: Instance in lighting_children do
                    if effect:IsA("PostEffect") then
                        pcall(function()
                            effect.Enabled = true
                        end)
                    end
                end
            end
        end)

        _antilag_applied = false
    end

    _G.EXO_StartAntiLag = startAntiLag
    _G.EXO_StopAntiLag = stopAntiLag

    print(`[EXO] Section 17.2 complete. Anti-Lag Shield registered.`)
    print(`[EXO]   Optimizations: Particles, Beams, Trails, Sounds, PostEffects`)
    print(`[EXO]   Quality: Level01 | Original values saved for restoration`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 17.3: 1000x CHAMS SYSTEM (NEW IN v10)                     ║
-- ║  Highlight instances on all players | Team-based coloring            ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _chams_folder: Folder? = nil
    local _chams_highlights: {[Player]: Highlight} = {}
    local _chams_update_conn: RBXScriptConnection? = nil

    local function _chams_create_highlight(plr: Player): ()
        if not plr then
            return
        end
        if _chams_highlights[plr] then
            return
        end
        local plrChar: Model? = plr.Character
        if not plrChar then
            return
        end
        if not _chams_folder then
            return
        end

        local hl_ok: boolean, hl = pcall(function()
            local h: Highlight = Instance.new("Highlight")
            h.Adornee = plrChar
            h.FillColor = Color3.fromRGB(255, 50, 50)
            h.FillTransparency = 0.5
            h.OutlineColor = Color3.fromRGB(0, 150, 255)
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = _chams_folder
            return h
        end)
        if hl_ok and hl then
            _chams_highlights[plr] = hl
        end
    end

    local function _chams_destroy_highlight(plr: Player): ()
        if _chams_highlights[plr] then
            pcall(function()
                _chams_highlights[plr]:Destroy()
            end)
            _chams_highlights[plr] = nil
        end
    end

    local function _chams_update_colors(): ()
        if not ChamsEnabled then
            return
        end
        local myChar: Model? = player.Character
        local myPos: Vector3? = nil
        if myChar then
            local myRoot: Instance? = myChar:FindFirstChild("HumanoidRootPart")
            if myRoot and myRoot:IsA("BasePart") then
                local pos_ok: boolean, pos_val = pcall(function() return myRoot.Position end)
                if pos_ok and typeof(pos_val) == "Vector3" then
                    myPos = pos_val
                end
            end
        end

        for plr: Player, hl: Highlight in _chams_highlights do
            if hl and hl.Parent then
                local plrChar: Model? = plr.Character
                if plrChar then
                    local hrp: Instance? = plrChar:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:IsA("BasePart") and myPos then
                        local dist_ok: boolean, dist = pcall(function()
                            return (hrp.Position - myPos).Magnitude
                        end)
                        if dist_ok and type(dist) == "number" then
                            local newColor: Color3
                            if dist < 15 then
                                newColor = Color3.fromRGB(255, 0, 0)
                            elseif dist < 30 then
                                newColor = Color3.fromRGB(255, 150, 0)
                            else
                                newColor = Color3.fromRGB(0, 255, 100)
                            end
                            pcall(function()
                                hl.FillColor = newColor
                            end)
                        end
                    end
                end
            end
        end
    end

    local function startChams(): ()
        if _chams_folder then
            return
        end

        local folder_ok: boolean, folder = pcall(function()
            local f: Folder = Instance.new("Folder")
            f.Name = "EXO_Chams"
            f.Parent = CoreGui
            return f
        end)
        if not folder_ok or not folder then
            -- Fallback to PlayerGui
            pcall(function()
                local f: Folder = Instance.new("Folder")
                f.Name = "EXO_Chams"
                f.Parent = player:WaitForChild("PlayerGui")
                folder = f
            end)
            if not folder then
                warn("[EXO] Failed to create Chams folder")
                return
            end
        end
        _chams_folder = folder

        -- Create highlights for all existing players
        local players_ok: boolean, players_list = pcall(function() return Players:GetPlayers() end)
        if players_ok and type(players_list) == "table" then
            for _, plr: Player in players_list do
                if plr ~= player then
                    _chams_create_highlight(plr)
                end
            end
        end

        -- Handle new players
        Players.PlayerAdded:Connect(function(plr: Player)
            if plr ~= player and ChamsEnabled then
                -- Wait for character to load
                task.delay(1, function()
                    if ChamsEnabled then
                        _chams_create_highlight(plr)
                    end
                end)
            end
        end)

        -- Handle players leaving
        Players.PlayerRemoving:Connect(function(plr: Player)
            _chams_destroy_highlight(plr)
        end)

        -- Handle character respawns (re-attach highlight)
        Players.PlayerAdded:Connect(function(plr: Player)
            if plr ~= player then
                plr.CharacterAdded:Connect(function()
                    if ChamsEnabled then
                        task.delay(0.5, function()
                            _chams_destroy_highlight(plr)
                            _chams_create_highlight(plr)
                        end)
                    end
                end)
            end
        end)

        -- Also hook current players' CharacterAdded
        if players_ok and type(players_list) == "table" then
            for _, plr: Player in players_list do
                if plr ~= player then
                    plr.CharacterAdded:Connect(function()
                        if ChamsEnabled then
                            task.delay(0.5, function()
                                _chams_destroy_highlight(plr)
                                _chams_create_highlight(plr)
                            end)
                        end
                    end)
                end
            end
        end

        -- Color update loop (throttled to every 0.5s)
        if _chams_update_conn then
            pcall(function() _chams_update_conn:Disconnect() end)
        end
        local _last_update: number = 0
        _chams_update_conn = RunService.Heartbeat:Connect(function()
            if not ChamsEnabled then
                return
            end
            if tick() - _last_update < 0.5 then
                return
            end
            _last_update = tick()
            _chams_update_colors()
        end)
    end

    local function stopChams(): ()
        if _chams_update_conn then
            pcall(function() _chams_update_conn:Disconnect() end)
            _chams_update_conn = nil
        end
        for plr: Player, hl: Highlight in _chams_highlights do
            pcall(function()
                hl:Destroy()
            end)
        end
        table.clear(_chams_highlights)
        if _chams_folder then
            pcall(function()
                _chams_folder:Destroy()
            end)
            _chams_folder = nil
        end
    end

    _G.EXO_StartChams = startChams
    _G.EXO_StopChams = stopChams

    print(`[EXO] Section 17.3 complete. Chams System registered.`)
    print(`[EXO]   Depth mode: AlwaysOnTop`)
    print(`[EXO]   Fill transparency: 0.5`)
    print(`[EXO]   Color update: 0.5s throttle`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 17.4: 1000x UI HIGHLIGHTS SYSTEM (NEW IN v10)             ║
-- ║  Active feature indicators | Pulsing outlines | Status colors        ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _highlights_gui: ScreenGui? = nil
    local _highlights_frame: Frame? = nil
    local _highlight_labels: {[string]: TextLabel} = {}
    local _highlights_update_conn: RBXScriptConnection? = nil

    local _feature_states: {[string]: () -> boolean} = {
        Aura = function() return Aura.Enabled end,
        InstaKill = function() return InstaKillEnabled end,
        HitAmp = function() return HitAmpEnabled end,
        AntiAura = function() return AntiAura.Enabled end,
        Reach = function() return Reach end,
        ToolFollow = function() return ToolFollow.Enabled end,
        ESP = function() return ESPEnabled end,
        Chams = function() return ChamsEnabled end,
        AntiLag = function() return AntiLagEnabled end,
        NoCooldown = function() return NoCooldown end,
        AutoBuild = function() return AutoBuild end,
        AutoClaim = function() return AutoClaimMoney end,
        Speed = function() return Movement.SpeedHack end,
        Fly = function() return Movement.Fly end,
        Noclip = function() return Movement.Noclip end,
    }

    local function _highlights_create_gui(): ()
        if _highlights_gui then
            return
        end

        local gui_ok: boolean, gui = pcall(function()
            local g: ScreenGui = Instance.new("ScreenGui")
            g.Name = "EXO_Highlights"
            g.ResetOnSpawn = false
            return g
        end)
        if not gui_ok or not gui then
            return
        end

        pcall(function()
            gui.Parent = CoreGui
        end)
        if not gui.Parent then
            pcall(function()
                gui.Parent = player:WaitForChild("PlayerGui")
            end)
        end
        if not gui.Parent then
            return
        end
        _highlights_gui = gui

        -- Main container frame (top-right corner)
        local frame_ok: boolean, frame = pcall(function()
            local f: Frame = Instance.new("Frame")
            f.Name = "ActiveFeatures"
            f.Size = UDim2.new(0, 180, 0, 20)
            f.Position = UDim2.new(1, -190, 0, 10)
            f.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
            f.BackgroundTransparency = 0.3
            f.BorderSizePixel = 0
            f.AutomaticSize = Enum.AutomaticSize.Y
            f.Parent = gui
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
            local stroke: UIStroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(0, 150, 255)
            stroke.Thickness = 1
            stroke.Parent = f
            return f
        end)
        if frame_ok and frame then
            _highlights_frame = frame

            -- Add a list layout for stacking feature labels
            pcall(function()
                local layout: UIListLayout = Instance.new("UIListLayout")
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 2)
                layout.Parent = frame
                local padding: UIPadding = Instance.new("UIPadding")
                padding.PaddingTop = UDim.new(0, 4)
                padding.PaddingBottom = UDim.new(0, 4)
                padding.PaddingLeft = UDim.new(0, 4)
                padding.PaddingRight = UDim.new(0, 4)
                padding.Parent = frame
            end)
        end
    end

    local function _highlights_update(): ()
        if not _highlights_frame then
            return
        end

        local order_index: number = 0
        for feature_name: string, state_fn in _feature_states do
            local is_active: boolean = false
            local fn_ok: boolean, result = pcall(state_fn)
            if fn_ok and type(result) == "boolean" then
                is_active = result
            end

            if is_active then
                order_index += 1
                if not _highlight_labels[feature_name] then
                    -- Create new label
                    local label_ok: boolean, label = pcall(function()
                        local l: TextLabel = Instance.new("TextLabel")
                        l.Name = feature_name
                        l.Size = UDim2.new(1, 0, 0, 14)
                        l.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                        l.BackgroundTransparency = 0.7
                        l.BorderSizePixel = 0
                        l.Text = `  ● {feature_name}`
                        l.TextColor3 = Color3.fromRGB(0, 255, 100)
                        l.TextSize = 10
                        l.Font = Enum.Font.GothamBold
                        l.TextXAlignment = Enum.TextXAlignment.Left
                        l.LayoutOrder = order_index
                        l.Parent = _highlights_frame
                        Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)
                        return l
                    end)
                    if label_ok and label then
                        _highlight_labels[feature_name] = label
                    end
                else
                    -- Update existing label
                    local label: TextLabel? = _highlight_labels[feature_name]
                    if label and label.Parent then
                        pcall(function()
                            label.LayoutOrder = order_index
                            label.Visible = true
                        end)
                    end
                end
            else
                -- Hide inactive feature label
                if _highlight_labels[feature_name] then
                    local label: TextLabel? = _highlight_labels[feature_name]
                    if label then
                        pcall(function()
                            label.Visible = false
                        end)
                    end
                end
            end
        end
    end

    local function startUIHighlights(): ()
        _highlights_create_gui()
        if _highlights_update_conn then
            pcall(function() _highlights_update_conn:Disconnect() end)
        end
        local _last_update: number = 0
        _highlights_update_conn = RunService.Heartbeat:Connect(function()
            if tick() - _last_update < 0.25 then
                return
            end
            _last_update = tick()
            _highlights_update()
        end)
    end

    local function stopUIHighlights(): ()
        if _highlights_update_conn then
            pcall(function() _highlights_update_conn:Disconnect() end)
            _highlights_update_conn = nil
        end
        if _highlights_gui then
            pcall(function()
                _highlights_gui:Destroy()
            end)
            _highlights_gui = nil
            _highlights_frame = nil
        end
        table.clear(_highlight_labels)
    end

    _G.EXO_StartUIHighlights = startUIHighlights
    _G.EXO_StopUIHighlights = stopUIHighlights

    print(`[EXO] Section 17.4 complete. UI Highlights System registered.`)
    print(`[EXO]   Tracked features: {table.count(_feature_states)}`)
    print(`[EXO]   Update interval: 0.25s`)
    print(`[EXO]   Position: Top-right corner`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 18.1: 1000x TYCOON ENGINE                                 ║
-- ║  Auto Claim | Smart Auto Build (Multi-Buy) | Priority Sorting        ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _claim_conn: RBXScriptConnection? = nil
    local _build_conn: RBXScriptConnection? = nil
    local _last_buy_time: number = 0

    local function startClaimMoney(): ()
        if _claim_conn then
            pcall(function() _claim_conn:Disconnect() end)
        end

        _claim_conn = RunService.PreSimulation:Connect(function()
            if not AutoClaimMoney then
                return
            end
            local myChar: Model? = player.Character
            if not myChar then
                return
            end
            local root: Instance? = myChar:FindFirstChild("HumanoidRootPart")
            if not root or not root:IsA("BasePart") then
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

            -- Scan for ALL cash registers and money collectors
            local desc_ok: boolean, descendants = pcall(function() return tycoonFolder:GetDescendants() end)
            if not desc_ok or type(descendants) ~= "table" then
                return
            end
            for _, obj: Instance in descendants do
                local name_ok: boolean, objName = pcall(function() return obj.Name end)
                if name_ok and type(objName) == "string" then
                    local n: string = objName:lower()
                    if n:find("cash") or n:find("register") or n:find("collect") or n:find("money") then
                        if obj:IsA("Model") or obj:IsA("BasePart") then
                            local parts = getTouchableParts(obj)
                            for _, part: BasePart in parts do
                                if firetouchinterest then
                                    pcall(firetouchinterest, root, part, 0)
                                    pcall(firetouchinterest, root, part, 1)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    local function stopClaimMoney(): ()
        if _claim_conn then
            pcall(function() _claim_conn:Disconnect() end)
            _claim_conn = nil
        end
    end

    local function startAutoBuild(): ()
        if _build_conn then
            pcall(function() _build_conn:Disconnect() end)
        end
        _last_buy_time = 0

        _build_conn = RunService.PreSimulation:Connect(function()
            if not AutoBuild then
                return
            end
            -- 1000x: faster buy cycle (0.2s vs original 0.4s)
            if tick() - _last_buy_time < 0.2 then
                return
            end

            local myChar: Model? = player.Character
            if not myChar then
                return
            end
            local root: Instance? = myChar:FindFirstChild("HumanoidRootPart")
            if not root or not root:IsA("BasePart") then
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

            -- Collect all buyable items using pre-allocated buffer
            table.clear(_buf_buttons)
            local desc_ok: boolean, descendants = pcall(function() return tycoonFolder:GetDescendants() end)
            if not desc_ok or type(descendants) ~= "table" then
                return
            end
            for _, obj: Instance in descendants do
                if obj:IsA("Model") then
                    local cost: number = getCost(obj)
                    if cost > 0 then
                        table.insert(_buf_buttons, {
                            Model = obj,
                            Cost = cost,
                            Priority = getPriority(obj.Name),
                        })
                    end
                end
            end

            if #_buf_buttons == 0 then
                return
            end

            -- Sort by priority, then by cost
            table.sort(_buf_buttons, function(a, b)
                if a.Priority == b.Priority then
                    return a.Cost < b.Cost
                end
                return a.Priority < b.Priority
            end)

            -- 1000x: Buy MULTIPLE items per cycle if affordable (max 3)
            local bought: number = 0
            for _, btnData in _buf_buttons do
                if cash >= btnData.Cost and bought < 3 then
                    local parts = getTouchableParts(btnData.Model)
                    for _, part: BasePart in parts do
                        if firetouchinterest then
                            pcall(firetouchinterest, root, part, 0)
                            pcall(firetouchinterest, root, part, 1)
                        end
                    end
                    cash -= btnData.Cost
                    bought += 1
                end
            end
            if bought > 0 then
                _last_buy_time = tick()
            end
        end)
    end

    local function stopAutoBuild(): ()
        if _build_conn then
            pcall(function() _build_conn:Disconnect() end)
            _build_conn = nil
        end
    end

    -- Force buy a single highest-priority item (manual trigger)
    local function forceBuyNext(): ()
        local myChar: Model? = player.Character
        if not myChar then
            return false
        end
        local root: Instance? = myChar:FindFirstChild("HumanoidRootPart")
        if not root or not root:IsA("BasePart") then
            return false
        end
        local tycoonType: string? = getPlayerTycoonType()
        if not tycoonType then
            return false
        end
        local tycoons: Instance? = workspace:FindFirstChild("Tycoons")
        if not tycoons then
            return false
        end
        local tycoonFolder: Instance? = tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then
            return false
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
            return true
        end
        return false
    end

    _G.EXO_StartClaimMoney = startClaimMoney
    _G.EXO_StopClaimMoney = stopClaimMoney
    _G.EXO_StartAutoBuild = startAutoBuild
    _G.EXO_StopAutoBuild = stopAutoBuild
    _G.EXO_ForceBuyNext = forceBuyNext

    print(`[EXO] Section 18.1 complete. Tycoon Engine registered.`)
    print(`[EXO]   Claim patterns: cash, register, collect, money`)
    print(`[EXO]   Buy cycle: 0.2s cooldown, max 3 items per cycle`)
    print(`[EXO]   Priority sorting: generators > gear > walls > effects`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 18.2: 1000x TOOL GRABBER (14 BASES + WAVE PRIORITY)       ║
-- ║  Continuous grab loop | Progress tracking | Burst acquisition        ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local _tg_tool_rules: {{Pattern: string, Base: string}} = {
        {Pattern = "Energy Sword", Base = "Stone"},
        {Pattern = "Staff", Base = "Magic"},
        {Pattern = "Axe", Base = "Storm"},
        {Pattern = "Fist", Base = "Robotic"},
        {Pattern = "Blade Arms", Base = "Mecha"},
        {Pattern = "Shadow Claws", Base = "Shadow"},
        {Pattern = "Hyper Claws", Base = "Hyper"},
        {Pattern = "Thunder Claws", Base = "Thunder"},
        {Pattern = "Void Claws", Base = "Void"},
        {Pattern = "Frozen Claws", Base = "Frozen"},
        {Pattern = "Magma Claws", Base = "Magma"},
        {Pattern = "Nuclear Claws", Base = "Nuclear"},
        {Pattern = "Toxic Claws", Base = "Toxic"},
        {Pattern = "Punch", Base = "Kong"},
    }

    local function tgHasTool(pattern: string): boolean
        if type(pattern) ~= "string" then
            return false
        end
        local patternLower: string = pattern:lower()

        -- Check Backpack
        local bp: Instance? = player:FindFirstChildOfClass("Backpack")
        if bp then
            local bp_ok: boolean, bp_children = pcall(function() return bp:GetChildren() end)
            if bp_ok and type(bp_children) == "table" then
                for _, item: Instance in bp_children do
                    if item:IsA("Tool") then
                        local name_ok: boolean, name_val = pcall(function() return item.Name end)
                        if name_ok and type(name_val) == "string" and name_val:lower():find(patternLower, 1, true) then
                            return true
                        end
                    end
                end
            end
        end

        -- Check Character (equipped tools)
        local char: Model? = player.Character
        if char then
            local char_ok: boolean, char_children = pcall(function() return char:GetChildren() end)
            if char_ok and type(char_children) == "table" then
                for _, item: Instance in char_children do
                    if item:IsA("Tool") then
                        local name_ok: boolean, name_val = pcall(function() return item.Name end)
                        if name_ok and type(name_val) == "string" and name_val:lower():find(patternLower, 1, true) then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    local function tgGetClosestPad(baseName: string): BasePart?
        if type(baseName) ~= "string" then
            return nil
        end
        local root: BasePart? = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then
            return nil
        end
        local pads: {BasePart}? = TG_padsByBase[baseName]
        if not pads or #pads == 0 then
            return nil
        end
        local closest: BasePart? = nil
        local bestDist: number = 10000
        for _, pad: BasePart in pads do
            if pad and pad.Parent then
                local pos_ok: boolean, padPos = pcall(function() return pad.Position end)
                local rootPos_ok: boolean, rootPos = pcall(function() return root.Position end)
                if pos_ok and rootPos_ok and typeof(padPos) == "Vector3" and typeof(rootPos) == "Vector3" then
                    local d: number = (padPos - rootPos).Magnitude
                    if d < bestDist then
                        bestDist = d
                        closest = pad
                    end
                end
            end
        end
        return closest
    end

    local function tgGetProgress(): number, number
        local owned: number = 0
        local total: number = #_tg_tool_rules
        for _, rule in _tg_tool_rules do
            if tgHasTool(rule.Pattern) then
                owned += 1
            end
        end
        return owned, total
    end

    local function startToolGrabberLoop(): ()
        if TG_Enabled then
            return
        end
        TG_Enabled = true

        if not getgenv().EXO_TG_Loop then
            getgenv().EXO_TG_Loop = true
            task.spawn(function()
                while getgenv().EXO_TG_Loop do
                    if TG_Enabled then
                        local root: BasePart? = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            for _, rule in _tg_tool_rules do
                                if not tgHasTool(rule.Pattern) then
                                    local pad: BasePart? = tgGetClosestPad(rule.Base)
                                    if pad then
                                        for _ = 1, TG_BurstCount do
                                            if firetouchinterest then
                                                pcall(firetouchinterest, root, pad, 0)
                                                pcall(firetouchinterest, root, pad, 1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.08)
                end
            end)
        end
    end

    local function stopToolGrabberLoop(): ()
        TG_Enabled = false
        getgenv().EXO_TG_Loop = false
    end

    local function tgForceAcquireAll(): ()
        local root: BasePart? = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then
            return 0
        end
        local acquired: number = 0
        for baseName: string, _ in TG_padsByBase do
            local pad: BasePart? = tgGetClosestPad(baseName)
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
        return acquired
    end

    _G.EXO_TG_HasTool = tgHasTool
    _G.EXO_TG_GetClosestPad = tgGetClosestPad
    _G.EXO_TG_GetProgress = tgGetProgress
    _G.EXO_StartToolGrabber = startToolGrabberLoop
    _G.EXO_StopToolGrabber = stopToolGrabberLoop
    _G.EXO_TG_ForceAcquireAll = tgForceAcquireAll

    print(`[EXO] Section 18.2 complete. Tool Grabber registered.`)
    print(`[EXO]   Bases: 14 (Stone, Magic, Storm, Robotic, Mecha, Shadow,`)
    print(`[EXO]           Hyper, Thunder, Void, Frozen, Magma, Nuclear, Toxic, Kong)`)
    print(`[EXO]   Grab interval: 0.08s`)
    print(`[EXO]   Burst count: {TG_BurstCount}`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 19.0: PART 3 (FIRST HALF) REGISTRY & BRIDGE               ║
-- ║  Verifies all visuals + initial automation modules registered        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local visuals_automation_globals: {string} = {
        -- Visuals
        "EXO_StartESP",
        "EXO_StopESP",
        "EXO_StartAntiLag",
        "EXO_StopAntiLag",
        "EXO_StartChams",
        "EXO_StopChams",
        "EXO_StartUIHighlights",
        "EXO_StopUIHighlights",
        -- Automation
        "EXO_StartClaimMoney",
        "EXO_StopClaimMoney",
        "EXO_StartAutoBuild",
        "EXO_StopAutoBuild",
        "EXO_ForceBuyNext",
        "EXO_TG_HasTool",
        "EXO_TG_GetClosestPad",
        "EXO_TG_GetProgress",
        "EXO_StartToolGrabber",
        "EXO_StopToolGrabber",
        "EXO_TG_ForceAcquireAll",
    }

    local registered: number = 0
    local missing: {string} = {}

    for _, name: string in visuals_automation_globals do
        if type(_G[name]) == "function" then
            registered += 1
        else
            table.insert(missing, name)
        end
    end

    print(`[EXO] ═══════════════════════════════════════════════════`)
    print(`[EXO] PART 3 (FIRST HALF) COMPLETE`)
    print(`[EXO] Visuals + Automation modules registered: {registered}/{#visuals_automation_globals}`)
    if #missing > 0 then
        warn(`[EXO] Missing modules: {table.concat(missing, ", ")}`)
    else
        print(`[EXO] All visuals + initial automation systems operational.`)
    end
    print(`[EXO] ═══════════════════════════════════════════════════`)
    print(`[EXO] Awaiting Part 3 (Second Half): Kill Intel, AI Chat, Robot`)
end
