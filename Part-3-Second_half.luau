-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  PART 3 (SECOND HALF): KILL INTEL + CHAT/ROBOT AI                    ║
-- ║  Sections 20.1-23.0 | EXO HUB v10.0 SENTINEL PRIME                   ║
-- ║  All sub-modules isolated in do...end blocks for register safety     ║
-- ╚══════════════════════════════════════════════════════════════════════╝

print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] PART 3 (SECOND HALF): KILL INTEL + CHAT AI LOADING`)
print(`[EXO] Modules: KillIntel, KillNotif, ChatUI, Robot, Pipeline, NLI`)
print(`[EXO] ═══════════════════════════════════════════════════`)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 20.1: 1000x KILL INTELLIGENCE ENGINE                      ║
-- ║  Behavioral analysis | TTK tracking | 10 detection rules             ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local function analyzeKill(killer: string?, weaponName: string?, distance: number?, ttk: number?): {
        Killer: string,
        Weapon: string,
        Distance: number,
        TTK: number,
        TimeSinceRespawn: number,
        Suspected: {string},
        Counter: {string},
        Threat: number,
        Time: string,
        DeathCount: number,
    }
        local suspected: {string} = {}
        local counter: {string} = {}
        local threat: number = 1

        -- Type validation for all inputs
        local k: string = type(killer) == "string" and killer or "Unknown"
        local w: string = type(weaponName) == "string" and weaponName or "Unknown"
        local d: number = type(distance) == "number" and distance or 0
        local t: number = type(ttk) == "number" and ttk or 999

        local timeSinceRespawn: number = tick() - LastSpawnTime
        if type(timeSinceRespawn) ~= "number" then
            timeSinceRespawn = 999
        end

        -- ═══════════════════════════════════════════════════════════
        -- BEHAVIORAL DETECTION RULES (10 rules total)
        -- ═══════════════════════════════════════════════════════════

        -- Rule 1: LOOPBRING detection
        if t < 0.3 and d < 8 then
            table.insert(suspected, "LoopBring")
            table.insert(counter, "FastRespawn + AntiSpawnkill + GodMode + Phase")
            threat += 4
        end

        -- Rule 2: KILL AURA detection
        if d > 5 and d < 15 and t < 0.5 then
            table.insert(suspected, "KillAura")
            table.insert(counter, "Anti-Aura + Repel + Phase")
            threat += 3
        end

        -- Rule 3: REACH detection
        if d > 25 then
            table.insert(suspected, "Reach")
            table.insert(counter, "Match Reach + Phase")
            threat += 3
        end

        -- Rule 4: EXTREME REACH / LOOPBRING hybrid
        if d > 40 then
            table.insert(suspected, "Extreme Reach / LoopBring")
            threat += 2
        end

        -- Rule 5: FAST KILL / REMOTE SPAM detection
        if t < 0.2 then
            table.insert(suspected, "FastKill / RemoteSpam")
            table.insert(counter, "GodMode + HealAura")
            threat += 3
        end

        -- Rule 6: FIGHT EVENT ABUSE detection
        if w == "Unknown" and t < 0.5 then
            table.insert(suspected, "FightEvent Abuse")
            table.insert(counter, "ForceField GodMode")
            threat += 3
        end

        -- Rule 7: HIT AMPLIFIER detection
        if d > 15 and d <= 30 and t < 0.8 then
            table.insert(suspected, "HitAmplifier")
            table.insert(counter, "Phase + Repel")
            threat += 2
        end

        -- Rule 8: TOOL FOLLOW / CLOSE COMBAT detection
        if d < 3 then
            table.insert(suspected, "ToolFollow / Close Combat")
            table.insert(counter, "Repel + Phase")
            threat += 1
        end

        -- Rule 9: SPAWN KILL detection
        if timeSinceRespawn < 2 then
            table.insert(suspected, "SpawnKill")
            table.insert(counter, "AntiSpawnkill + GodMode")
            threat += 3
        end

        -- Rule 10: BURST KILL PATTERN detection (temporal clustering)
        if #DeathTimestamps >= 3 then
            local recentWindow: number = 0
            for i = #DeathTimestamps, math.max(1, #DeathTimestamps - 4), -1 do
                if DeathTimestamps[i] and DeathTimestamps[i - 1] then
                    recentWindow += DeathTimestamps[i] - DeathTimestamps[i - 1]
                end
            end
            if recentWindow < 5 and recentWindow > 0 then
                table.insert(suspected, "BurstKillPattern")
                table.insert(counter, "GodMode + HealAura + FastRespawn")
                threat += 2
            end
        end

        -- Clamp threat level and add escalation counters
        threat = math.clamp(threat, 1, 10)
        if threat >= 10 then
            table.insert(counter, "CRITICAL: FULL DEFENSE MATRIX NOW")
        end
        if threat >= 7 then
            table.insert(counter, "Enable full Defense Matrix")
        end

        return {
            Killer = k,
            Weapon = w,
            Distance = math.floor(d),
            TTK = t,
            TimeSinceRespawn = timeSinceRespawn,
            Suspected = suspected,
            Counter = counter,
            Threat = threat,
            Time = os.date("%H:%M:%S"),
            DeathCount = DeathCount,
        }
    end

    -- Expose globally
    _G.EXO_AnalyzeKill = analyzeKill

    print(`[EXO] Section 20.1 complete. Kill Intelligence Engine registered.`)
    print(`[EXO]   Detection rules: 10`)
    print(`[EXO]   TTK tracking: ENABLED via DeathTimestamps`)
    print(`[EXO]   SpawnKill detection: ENABLED via LastSpawnTime`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 20.2: KILL NOTIFICATION SYSTEM                            ║
-- ║  CharacterAdded hook | Died event | Creator tag extraction           ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local function setupKillNotifications(): ()
        player.CharacterAdded:Connect(function(char: Model)
            if not char then
                return
            end

            -- Update spawn time for SpawnKill detection
            LastSpawnTime = tick()

            local hum_ok: boolean, hum = pcall(function()
                return char:WaitForChild("Humanoid", 10)
            end)
            if not hum_ok or not hum then
                return
            end

            hum.Died:Connect(function()
                DeathCount += 1
                KillStreak = 0
                LastDeathTime = tick()

                -- TTK tracking via DeathTimestamps
                table.insert(DeathTimestamps, tick())
                if #DeathTimestamps > 20 then
                    table.remove(DeathTimestamps, 1)
                end

                if not KillNotifEnabled then
                    return
                end

                -- Extract creator tag (who killed us)
                local creator: Instance? = hum:FindFirstChild("creator")
                local killerName: string = "Unknown"
                local weaponName: string = "Unknown"
                local distance: number = 0
                local ttk: number = 999

                if creator then
                    local creator_val_ok: boolean, creator_val = pcall(function() return creator.Value end)
                    if creator_val_ok and creator_val then
                        local name_ok: boolean, name_val = pcall(function() return creator_val.Name end)
                        if name_ok and type(name_val) == "string" then
                            killerName = name_val
                        end

                        local killerChar_ok: boolean, killerChar = pcall(function() return creator_val.Character end)
                        if killerChar_ok and killerChar then
                            -- Calculate distance between us and killer
                            local myRoot: Instance? = char:FindFirstChild("HumanoidRootPart")
                            local theirRoot: Instance? = killerChar:FindFirstChild("HumanoidRootPart")
                            if myRoot and theirRoot then
                                local dist_ok: boolean, dist_val = pcall(function()
                                    return (myRoot.Position - theirRoot.Position).Magnitude
                                end)
                                if dist_ok and type(dist_val) == "number" then
                                    distance = dist_val
                                end
                            end

                            -- Detect killer's weapon
                            local children_ok: boolean, children = pcall(function() return killerChar:GetChildren() end)
                            if children_ok and type(children) == "table" then
                                for _, tool: Instance in children do
                                    if tool:IsA("Tool") then
                                        local tname_ok: boolean, tname = pcall(function() return tool.Name end)
                                        if tname_ok and type(tname) == "string" then
                                            weaponName = tname
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- Calculate TTK from timestamps
                if #DeathTimestamps >= 2 then
                    local delta: number = DeathTimestamps[#DeathTimestamps] - DeathTimestamps[#DeathTimestamps - 1]
                    if delta > 0 and delta < 10 then
                        ttk = delta
                    else
                        ttk = 1
                    end
                end

                -- Run behavioral analysis
                local analysis: {[string]: any}? = nil
                if type(_G.EXO_AnalyzeKill) == "function" then
                    local ok: boolean, result = pcall(_G.EXO_AnalyzeKill, killerName, weaponName, distance, ttk)
                    if ok and type(result) == "table" then
                        analysis = result
                    end
                end

                if not analysis then
                    return
                end

                -- Store in kill logs (capacity: 100 entries)
                if KillLogEnabled then
                    table.insert(KillLogs, analysis)
                    if #KillLogs > 100 then
                        table.remove(KillLogs, 1)
                    end
                    appendLog(analysis)
                end

                -- ═══ TRIGGER SENTINEL AI PIPELINE ═══
                if type(_G.EXO_OnKillDetected) == "function" then
                    pcall(_G.EXO_OnKillDetected, analysis)
                end

                -- UI notification (fallback-safe)
                if AdminUI and type(AdminUI.Notify) == "function" then
                    pcall(function()
                        AdminUI:Notify(
                            `SENTINEL AI - Kill Detected (Threat {analysis.Threat}/10) | Killer: {analysis.Killer}`,
                            5
                        )
                    end)
                end
            end)
        end)
    end

    -- Expose globally
    _G.EXO_SetupKillNotifications = setupKillNotifications

    print(`[EXO] Section 20.2 complete. Kill Notification System registered.`)
    print(`[EXO]   Hook: CharacterAdded → Humanoid.Died`)
    print(`[EXO]   Creator tag extraction: ENABLED`)
    print(`[EXO]   Kill log capacity: 100 entries`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 21.1: CHAT UI SYSTEM                                      ║
-- ║  Persistent GUI | ScrollFrame | Input | Drag | Minimize              ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    -- Forward declaration for Chat_AddMessage (assigned after Chat_CreateGUI)
    local Chat_AddMessage: ((sender: string, text: string, color: Color3?) -> ())? = nil

    local function Chat_CreateGUI(): ()
        if ChatSystem.GUI then
            return
        end

        local gui_ok: boolean, gui = pcall(function()
            local g: ScreenGui = Instance.new("ScreenGui")
            g.Name = "EXO_SentinelChat"
            g.ResetOnSpawn = false
            g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            return g
        end)
        if not gui_ok or not gui then
            warn("[EXO] Failed to create Chat GUI")
            return
        end

        pcall(function() gui.Parent = CoreGui end)
        if not gui.Parent then
            pcall(function() gui.Parent = player:WaitForChild("PlayerGui") end)
        end
        if not gui.Parent then
            warn("[EXO] Chat GUI has no parent")
            return
        end
        ChatSystem.GUI = gui

        -- Main chat window
        local mainFrame: Frame = Instance.new("Frame")
        mainFrame.Name = "ChatMain"
        mainFrame.Size = UDim2.new(0, 380, 0, 460)
        mainFrame.Position = UDim2.new(1, -400, 0.5, -230)
        mainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Parent = gui
        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

        local stroke: UIStroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 150, 255)
        stroke.Thickness = 2
        stroke.Parent = mainFrame

        -- Title bar
        local titleBar: Frame = Instance.new("Frame")
        titleBar.Name = "TitleBar"
        titleBar.Size = UDim2.new(1, 0, 0, 36)
        titleBar.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
        titleBar.BorderSizePixel = 0
        titleBar.Parent = mainFrame
        Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

        local titleLabel: TextLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -80, 1, 0)
        titleLabel.Position = UDim2.new(0, 40, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "EXO SENTINEL AI"
        titleLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
        titleLabel.TextSize = 14
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = titleBar

        -- Status indicator dot
        local statusDot: Frame = Instance.new("Frame")
        statusDot.Name = "StatusDot"
        statusDot.Size = UDim2.new(0, 8, 0, 8)
        statusDot.Position = UDim2.new(0, 12, 0.5, -4)
        statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        statusDot.BorderSizePixel = 0
        statusDot.Parent = titleBar
        Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

        -- Minimize button
        local minBtn: TextButton = Instance.new("TextButton")
        minBtn.Size = UDim2.new(0, 24, 0, 24)
        minBtn.Position = UDim2.new(1, -30, 0.5, -12)
        minBtn.BackgroundTransparency = 1
        minBtn.Text = "—"
        minBtn.TextColor3 = Color3.fromRGB(120, 140, 170)
        minBtn.TextSize = 16
        minBtn.Font = Enum.Font.GothamBold
        minBtn.Parent = titleBar

        -- Robot display area
        local robotArea: Frame = Instance.new("Frame")
        robotArea.Name = "RobotArea"
        robotArea.Size = UDim2.new(1, 0, 0, 80)
        robotArea.Position = UDim2.new(0, 0, 0, 36)
        robotArea.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
        robotArea.BorderSizePixel = 0
        robotArea.Parent = mainFrame

        -- Robot body
        local robotBody: Frame = Instance.new("Frame")
        robotBody.Name = "RobotBody"
        robotBody.Size = UDim2.new(0, 40, 0, 40)
        robotBody.Position = UDim2.new(0, 15, 0.5, -20)
        robotBody.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        robotBody.BorderSizePixel = 0
        robotBody.Parent = robotArea
        Instance.new("UICorner", robotBody).CornerRadius = UDim.new(0, 8)

        -- Robot eyes
        local eyeL: Frame = Instance.new("Frame")
        eyeL.Name = "EyeL"
        eyeL.Size = UDim2.new(0, 8, 0, 8)
        eyeL.Position = UDim2.new(0, 8, 0, 12)
        eyeL.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        eyeL.BorderSizePixel = 0
        eyeL.Parent = robotBody
        Instance.new("UICorner", eyeL).CornerRadius = UDim.new(1, 0)

        local eyeR: Frame = Instance.new("Frame")
        eyeR.Name = "EyeR"
        eyeR.Size = UDim2.new(0, 8, 0, 8)
        eyeR.Position = UDim2.new(0, 24, 0, 12)
        eyeR.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        eyeR.BorderSizePixel = 0
        eyeR.Parent = robotBody
        Instance.new("UICorner", eyeR).CornerRadius = UDim.new(1, 0)

        -- Robot mouth
        local mouth: Frame = Instance.new("Frame")
        mouth.Name = "Mouth"
        mouth.Size = UDim2.new(0, 16, 0, 3)
        mouth.Position = UDim2.new(0, 12, 0, 28)
        mouth.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        mouth.BorderSizePixel = 0
        mouth.Parent = robotBody

        -- Robot arm (for thumbs up animation)
        local arm: Frame = Instance.new("Frame")
        arm.Name = "Arm"
        arm.Size = UDim2.new(0, 6, 0, 20)
        arm.Position = UDim2.new(1, 2, 0, 15)
        arm.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        arm.BorderSizePixel = 0
        arm.Parent = robotBody
        Instance.new("UICorner", arm).CornerRadius = UDim.new(0, 3)

        RobotAnim.Body = robotBody
        RobotAnim.Eyes = {eyeL, eyeR}
        RobotAnim.Arm = arm

        -- Robot status text
        local robotStatus: TextLabel = Instance.new("TextLabel")
        robotStatus.Name = "RobotStatus"
        robotStatus.Size = UDim2.new(1, -80, 0, 60)
        robotStatus.Position = UDim2.new(0, 70, 0, 10)
        robotStatus.BackgroundTransparency = 1
        robotStatus.Text = "SENTINEL ONLINE\nAwaiting combat data..."
        robotStatus.TextColor3 = Color3.fromRGB(0, 150, 255)
        robotStatus.TextSize = 11
        robotStatus.Font = Enum.Font.Gotham
        robotStatus.TextXAlignment = Enum.TextXAlignment.Left
        robotStatus.TextYAlignment = Enum.TextYAlignment.Top
        robotStatus.TextWrapped = true
        robotStatus.Parent = robotArea
        ChatSystem.StatusLabel = robotStatus

        -- Chat scroll area
        local scrollFrame: ScrollingFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = "ChatScroll"
        scrollFrame.Size = UDim2.new(1, -10, 1, -155)
        scrollFrame.Position = UDim2.new(0, 5, 0, 118)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollFrame.Parent = mainFrame

        local listLayout: UIListLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 4)
        listLayout.Parent = scrollFrame

        ChatSystem.ScrollFrame = scrollFrame

        -- Input area
        local inputArea: Frame = Instance.new("Frame")
        inputArea.Name = "InputArea"
        inputArea.Size = UDim2.new(1, -10, 0, 32)
        inputArea.Position = UDim2.new(0, 5, 1, -38)
        inputArea.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
        inputArea.BorderSizePixel = 0
        inputArea.Parent = mainFrame
        Instance.new("UICorner", inputArea).CornerRadius = UDim.new(0, 8)

        local inputBox: TextBox = Instance.new("TextBox")
        inputBox.Name = "ChatInput"
        inputBox.Size = UDim2.new(1, -45, 1, -4)
        inputBox.Position = UDim2.new(0, 5, 0, 2)
        inputBox.BackgroundTransparency = 1
        inputBox.PlaceholderText = "Type a message..."
        inputBox.PlaceholderColor3 = Color3.fromRGB(120, 140, 170)
        inputBox.Text = ""
        inputBox.TextColor3 = Color3.fromRGB(230, 240, 255)
        inputBox.TextSize = 12
        inputBox.Font = Enum.Font.Gotham
        inputBox.TextXAlignment = Enum.TextXAlignment.Left
        inputBox.ClearTextOnFocus = true
        inputBox.Parent = inputArea

        local sendBtn: TextButton = Instance.new("TextButton")
        sendBtn.Name = "SendBtn"
        sendBtn.Size = UDim2.new(0, 32, 0, 24)
        sendBtn.Position = UDim2.new(1, -37, 0.5, -12)
        sendBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        sendBtn.Text = "▶"
        sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        sendBtn.TextSize = 12
        sendBtn.Font = Enum.Font.GothamBold
        sendBtn.BorderSizePixel = 0
        sendBtn.Parent = inputArea
        Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 6)

        ChatSystem.InputBox = inputBox
        ChatSystem.SendButton = sendBtn

        -- Drag functionality
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                ChatSystem.Dragging = true
                ChatSystem.DragStart = input.Position
                ChatSystem.StartPos = mainFrame.Position
            end
        end)

        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                ChatSystem.Dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if ChatSystem.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                if ChatSystem.DragStart and ChatSystem.StartPos then
                    local delta = input.Position - ChatSystem.DragStart
                    mainFrame.Position = UDim2.new(
                        ChatSystem.StartPos.X.Scale, ChatSystem.StartPos.X.Offset + delta.X,
                        ChatSystem.StartPos.Y.Scale, ChatSystem.StartPos.Y.Offset + delta.Y
                    )
                end
            end
        end)

        -- Minimize toggle
        minBtn.MouseButton1Click:Connect(function()
            if mainFrame.Size == UDim2.new(0, 380, 0, 460) then
                TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 380, 0, 36),
                }):Play()
                minBtn.Text = "+"
            else
                TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 380, 0, 460),
                }):Play()
                minBtn.Text = "—"
            end
        end)

        -- Send message handler
        local function handleSend(): ()
            local text: string = inputBox.Text
            if type(text) ~= "string" or text == "" then
                return
            end
            inputBox.Text = ""
            if Chat_AddMessage then
                Chat_AddMessage("USER", text)
            end
            if ChatSystem.AwaitingReply and ChatSystem.ReplyCallback then
                ChatSystem.AwaitingReply = false
                local cb = ChatSystem.ReplyCallback
                ChatSystem.ReplyCallback = nil
                pcall(cb, text)
            else
                task.spawn(function()
                    if type(_G.EXO_ProcessUserMessage) == "function" then
                        pcall(_G.EXO_ProcessUserMessage, text)
                    end
                end)
            end
        end

        sendBtn.MouseButton1Click:Connect(handleSend)
        inputBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                handleSend()
            end
        end)

        ChatSystem.IsOpen = true
    end

    -- Define Chat_AddMessage and assign to the forward declaration
    Chat_AddMessage = function(sender: string, text: string, color: Color3?)
        if not ChatSystem.ScrollFrame then
            return
        end
        if type(text) ~= "string" then
            text = tostring(text)
        end

        ChatSystem.MessageCount += 1

        local msgFrame: Frame = Instance.new("Frame")
        msgFrame.Name = `Msg_{ChatSystem.MessageCount}`
        msgFrame.Size = UDim2.new(1, -8, 0, 0)
        msgFrame.AutomaticSize = Enum.AutomaticSize.Y
        msgFrame.BackgroundTransparency = 1
        msgFrame.LayoutOrder = ChatSystem.MessageCount
        msgFrame.Parent = ChatSystem.ScrollFrame

        local msgLabel: TextLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, -8, 0, 0)
        msgLabel.Position = UDim2.new(0, 4, 0, 0)
        msgLabel.AutomaticSize = Enum.AutomaticSize.Y
        msgLabel.BackgroundTransparency = 1
        msgLabel.TextWrapped = true
        msgLabel.TextSize = 11
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.TextXAlignment = Enum.TextXAlignment.Left
        msgLabel.TextYAlignment = Enum.TextYAlignment.Top
        msgLabel.Parent = msgFrame

        local prefix: string = ""
        local textColor: Color3 = color or Color3.fromRGB(230, 240, 255)

        if sender == "AI" then
            prefix = "[SENTINEL] "
            textColor = color or Color3.fromRGB(0, 150, 255)
        elseif sender == "USER" then
            prefix = "[YOU] "
            textColor = color or Color3.fromRGB(255, 255, 100)
        elseif sender == "SYSTEM" then
            prefix = "[SYSTEM] "
            textColor = color or Color3.fromRGB(255, 80, 80)
        end

        msgLabel.Text = prefix .. text
        msgLabel.TextColor3 = textColor

        -- Auto scroll to bottom
        task.defer(function()
            if ChatSystem.ScrollFrame then
                ChatSystem.ScrollFrame.CanvasPosition = Vector2.new(0, ChatSystem.ScrollFrame.AbsoluteCanvasSize.Y)
            end
        end)
    end

    -- Expose globally
    _G.EXO_ChatCreateGUI = Chat_CreateGUI
    _G.EXO_ChatAddMessage = Chat_AddMessage

    print(`[EXO] Section 21.1 complete. Chat UI System registered.`)
    print(`[EXO]   Features: Drag, minimize, bidirectional input, auto-scroll`)
    print(`[EXO]   Message types: AI, USER, SYSTEM`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 21.2: ROBOT ANIMATOR (5 STATES)                           ║
-- ║  IDLE | READING | THINKING | THUMBSUP | TALKING                    ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local function Robot_SetState(state: string): ()
        if type(state) ~= "string" then
            state = "IDLE"
        end
        RobotAnim.State = state

        if not ChatSystem.StatusLabel then
            return
        end

        if state == "READING" then
            ChatSystem.StatusLabel.Text = "ANALYZING KILL REPORT...\nScanning threat patterns..."
            task.spawn(function()
                for i = 1, 3 do
                    if RobotAnim.Eyes then
                        for _, eye in RobotAnim.Eyes do
                            TweenService:Create(eye, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
                        end
                        task.wait(0.2)
                        for _, eye in RobotAnim.Eyes do
                            TweenService:Create(eye, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                        end
                        task.wait(0.2)
                    end
                end
            end)

        elseif state == "THINKING" then
            ChatSystem.StatusLabel.Text = "FORMULATING COUNTER-STRATEGY...\nCross-referencing threat database..."
            if RobotAnim.Eyes then
                for _, eye in RobotAnim.Eyes do
                    TweenService:Create(eye, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                        BackgroundColor3 = Color3.fromRGB(0, 255, 200),
                    }):Play()
                end
            end

        elseif state == "THUMBSUP" then
            ChatSystem.StatusLabel.Text = "ANALYSIS COMPLETE ✓\nStrategy ready. Opening chat..."
            if RobotAnim.Arm then
                TweenService:Create(RobotAnim.Arm, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(1, 2, 0, -5),
                    Rotation = -30,
                }):Play()
            end
            if RobotAnim.Eyes then
                for _, eye in RobotAnim.Eyes do
                    TweenService:Create(eye, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}):Play()
                end
            end

        elseif state == "TALKING" then
            ChatSystem.StatusLabel.Text = "SENTINEL ONLINE\nReady for your commands."
            if RobotAnim.Eyes then
                for _, eye in RobotAnim.Eyes do
                    TweenService:Create(eye, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                end
            end
            if RobotAnim.Arm then
                TweenService:Create(RobotAnim.Arm, TweenInfo.new(0.3), {
                    Position = UDim2.new(1, 2, 0, 15),
                    Rotation = 0,
                }):Play()
            end

        elseif state == "IDLE" then
            ChatSystem.StatusLabel.Text = "SENTINEL ONLINE\nAwaiting combat data..."
        end
    end

    -- Expose globally
    _G.EXO_RobotSetState = Robot_SetState

    print(`[EXO] Section 21.2 complete. Robot Animator registered.`)
    print(`[EXO]   States: IDLE, READING, THINKING, THUMBSUP, TALKING`)
    print(`[EXO]   Animations: Eye blink, eye pulse, arm thumbs-up`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 21.3: KILL ANALYSIS PIPELINE                              ║
-- ║  READ → THINK → PROFILE → STRATEGY → THUMBSUP → CONFIRM            ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local function AI_OnKillDetected(killData: {[string]: any}): ()
        if type(killData) ~= "table" then
            return
        end

        -- Step 1: Robot starts reading
        if type(_G.EXO_RobotSetState) == "function" then
            pcall(_G.EXO_RobotSetState, "READING")
        end

        task.spawn(function()
            task.wait(1.5) -- Reading animation duration

            -- Step 2: Robot thinks
            if type(_G.EXO_RobotSetState) == "function" then
                pcall(_G.EXO_RobotSetState, "THINKING")
            end
            task.wait(1.0) -- Thinking animation duration

            -- Step 3: Update threat profile via Bayesian Profiler
            local profile: {[string]: any}? = nil
            if type(_G.EXO_AI_UpdateProfile) == "function" then
                local ok: boolean, result = pcall(_G.EXO_AI_UpdateProfile, killData.Killer, killData)
                if ok and type(result) == "table" then
                    profile = result
                end
            end
            if not profile then
                warn("[EXO] AI_OnKillDetected: profile update failed")
                return
            end

            -- Step 4: Formulate strategy
            local strategy: {[string]: any}? = nil
            if type(_G.EXO_AI_FormulateStrategy) == "function" then
                local ok: boolean, result = pcall(_G.EXO_AI_FormulateStrategy, profile, killData)
                if ok and type(result) == "table" then
                    strategy = result
                end
            end
            if not strategy then
                warn("[EXO] AI_OnKillDetected: strategy formulation failed")
                return
            end

            -- Step 5: Thumbs up
            if type(_G.EXO_RobotSetState) == "function" then
                pcall(_G.EXO_RobotSetState, "THUMBSUP")
            end
            task.wait(1.0)

            -- Step 6: Open chat and present
            if type(_G.EXO_RobotSetState) == "function" then
                pcall(_G.EXO_RobotSetState, "TALKING")
            end
            if type(_G.EXO_ChatCreateGUI) == "function" then
                pcall(_G.EXO_ChatCreateGUI)
            end

            local addMsg = _G.EXO_ChatAddMessage
            if type(addMsg) ~= "function" then
                return
            end

            -- Present the analysis
            addMsg("SYSTEM", "═══ KILL REPORT ═══", Color3.fromRGB(255, 50, 50))
            addMsg("AI", `Killer: {killData.Killer}`)
            addMsg("AI", `Weapon: {killData.Weapon}`)
            addMsg("AI", `Distance: {killData.Distance} studs`)
            addMsg("AI", `Time-to-Kill: {string.format("%.2f", killData.TTK)} seconds`)
            addMsg("AI", `Threat Level: {killData.Threat}/10`)
            addMsg("AI", "")

            -- Explain WHY you're losing
            addMsg("SYSTEM", "═══ WHY YOU'RE LOSING ═══", Color3.fromRGB(255, 200, 0))
            if type(strategy.Explanations) == "table" then
                for _, explanation: string in strategy.Explanations do
                    addMsg("AI", explanation)
                end
            end

            -- Show suspected features
            if type(profile.SuspectedFeatures) == "table" and #profile.SuspectedFeatures > 0 then
                addMsg("AI", "")
                addMsg("AI", `Detected opponent features: {table.concat(profile.SuspectedFeatures, ", ")}`)
                addMsg("AI", `Profile confidence: {profile.ThreatScore}/100`)
                addMsg("AI", `Total kills by this player: {profile.TotalKills}`)
            end

            addMsg("AI", "")
            addMsg("SYSTEM", "═══ PROPOSED COUNTER-STRATEGY ═══", Color3.fromRGB(0, 255, 100))
            addMsg("AI", `Priority: {strategy.Priority}`)
            addMsg("AI", `Confidence: {strategy.Confidence}%`)
            addMsg("AI", `Actions ({#strategy.Actions}):`)

            if type(strategy.Actions) == "table" then
                for i, action in strategy.Actions do
                    local desc: string = ""
                    if action.type == "enable" then
                        desc = `  {i}. ENABLE {action.feature}`
                    elseif action.type == "set" then
                        desc = `  {i}. SET {action.feature} = {tostring(action.value)}`
                    end
                    if action.reason then
                        desc ..= ` ({action.reason})`
                    end
                    addMsg("AI", desc, Color3.fromRGB(150, 255, 150))
                end
            end

            -- Ask for confirmation
            addMsg("AI", "")
            addMsg("AI", "Do you approve this strategy? Type Y to execute, N to cancel, or ask me a question.", Color3.fromRGB(255, 255, 0))

            AI_State.Current = "AWAITING_CONFIRM"
            AI_State.PendingStrategy = strategy
            ChatSystem.AwaitingReply = true
            ChatSystem.ReplyCallback = function(reply: string)
                local lower: string = reply:lower():gsub("%s+", "")
                if lower == "y" or lower == "yes" or lower == "confirm" or lower == "approve" or lower == "doit" then
                    addMsg("AI", "Strategy approved. Executing counter-measures now.", Color3.fromRGB(0, 255, 100))
                    if type(_G.EXO_AI_ExecuteStrategy) == "function" then
                        pcall(_G.EXO_AI_ExecuteStrategy, strategy)
                    end
                    AI_State.Current = "IDLE"

                    task.wait(0.5)
                    addMsg("AI", `All {#strategy.Actions} actions executed successfully.`)
                    addMsg("AI", "I'll continue monitoring. If they kill you again, I'll adapt the strategy.")
                    if type(_G.EXO_RobotSetState) == "function" then
                        pcall(_G.EXO_RobotSetState, "IDLE")
                    end

                elseif lower == "n" or lower == "no" or lower == "cancel" or lower == "deny" then
                    addMsg("AI", "Strategy cancelled. I'll keep monitoring. Let me know if you want me to suggest something else.", Color3.fromRGB(255, 200, 0))
                    AI_State.Current = "IDLE"
                    if type(_G.EXO_RobotSetState) == "function" then
                        pcall(_G.EXO_RobotSetState, "IDLE")
                    end

                else
                    -- They asked a question or gave other input
                    if type(_G.EXO_ProcessUserMessage) == "function" then
                        pcall(_G.EXO_ProcessUserMessage, reply)
                    end
                    task.wait(0.3)
                    addMsg("AI", "Still waiting for your decision. Type Y to approve or N to cancel.", Color3.fromRGB(255, 255, 0))
                    ChatSystem.AwaitingReply = true
                    ChatSystem.ReplyCallback = function(reply2: string)
                        local l2: string = reply2:lower():gsub("%s+", "")
                        if l2 == "y" or l2 == "yes" or l2 == "confirm" then
                            addMsg("AI", "Executing now.", Color3.fromRGB(0, 255, 100))
                            if type(_G.EXO_AI_ExecuteStrategy) == "function" then
                                pcall(_G.EXO_AI_ExecuteStrategy, strategy)
                            end
                            AI_State.Current = "IDLE"
                        else
                            addMsg("AI", "Cancelled.", Color3.fromRGB(255, 200, 0))
                            AI_State.Current = "IDLE"
                        end
                        if type(_G.EXO_RobotSetState) == "function" then
                            pcall(_G.EXO_RobotSetState, "IDLE")
                        end
                    end
                end
            end
        end)
    end

    -- Expose globally
    _G.EXO_OnKillDetected = AI_OnKillDetected

    print(`[EXO] Section 21.3 complete. Kill Analysis Pipeline registered.`)
    print(`[EXO]   Pipeline stages: READ → THINK → PROFILE → STRATEGY → THUMBSUP → CONFIRM`)
    print(`[EXO]   Confirmation gate: ENABLED (asks Y/N before executing)`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 22.1: NATURAL LANGUAGE INTERFACE                          ║
-- ║  13 commands | Command parser | Feature list formatter               ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    type CommandResult = {
        Handled: boolean,
        Command: string,
        Argument: string?,
    }

    local function AI_ParseCommand(text: string): CommandResult
        if type(text) ~= "string" then
            return {Handled = false, Command = "", Argument = nil}
        end
        local lower: string = text:lower()
        local trimmed: string = lower:gsub("^%s+", ""):gsub("%s+$", "")

        local cmd: string?, arg: string? = trimmed:match("^(%S+)%s+(.+)$")
        if cmd then
            return {Handled = true, Command = cmd, Argument = arg}
        end
        return {Handled = true, Command = trimmed, Argument = nil}
    end

    local function AI_FormatFeatureList(features: {string}): string
        if type(features) ~= "table" or #features == 0 then
            return "none"
        end
        return table.concat(features, ", ")
    end

    local function AI_GetSuccessRate(): number, number, number
        local successes: number = 0
        local failures: number = 0
        if type(AIMemory.StrategyResults) == "table" then
            for _, result in AIMemory.StrategyResults do
                if type(result) == "table" then
                    if result.Success == true then
                        successes += 1
                    elseif result.Success == false then
                        failures += 1
                    end
                end
            end
        end
        local total: number = successes + failures
        local rate: number = 0
        if total > 0 then
            rate = math.floor((successes / total) * 100)
        end
        return successes, failures, rate
    end

    local function AI_ProcessUserMessage(text: string): ()
        if type(text) ~= "string" or text == "" then
            return
        end

        local lower: string = text:lower()
        local parsed: CommandResult = AI_ParseCommand(text)
        local cmd: string = parsed.Command
        local arg: string? = parsed.Argument
        local addMsg = _G.EXO_ChatAddMessage
        if type(addMsg) ~= "function" then
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- HELP COMMAND
        -- ═══════════════════════════════════════════════════════════
        if lower:find("help") or lower:find("commands") then
            addMsg("AI", "═══ AVAILABLE COMMANDS ═══", Color3.fromRGB(0, 150, 255))
            addMsg("AI", "  'status' - Current threat status")
            addMsg("AI", "  'profiles' - View all threat profiles")
            addMsg("AI", "  'profile [name]' - View specific player profile")
            addMsg("AI", "  'strategy' - View active strategy")
            addMsg("AI", "  'threats' - Current threat assessment")
            addMsg("AI", "  'disable all' - Turn off all AI-activated features")
            addMsg("AI", "  'why' - Explain current situation")
            addMsg("AI", "  'target [name]' - Focus all systems on a player")
            addMsg("AI", "  'memory' - View AI learning statistics")
            addMsg("AI", "  'features' - View detected feature types")
            addMsg("AI", "  'killlogs' - View recent kill reports")
            addMsg("AI", "  'clear' - Clear chat history")
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- STATUS COMMAND
        -- ═══════════════════════════════════════════════════════════
        if lower:find("status") then
            addMsg("AI", "═══ CURRENT STATUS ═══", Color3.fromRGB(0, 150, 255))
            addMsg("AI", `  Threat Level: {ThreatLevel} (Peak: {PeakThreat})`)
            addMsg("AI", `  Deaths This Session: {DeathCount}`)
            addMsg("AI", `  Kill Streak: {KillStreak}`)
            addMsg("AI", `  Aura: {tostring(Aura.Enabled)} | InstaKill: {tostring(InstaKillEnabled)}`)
            addMsg("AI", `  AntiAura: {tostring(AntiAura.Enabled)} | GodMode: {tostring(AntiAura.GodMode)}`)
            addMsg("AI", `  Reach: {tostring(Reach)} ({ReachSize}x)`)
            addMsg("AI", `  AI State: {AI_State.Current}`)

            local profile_count: number = 0
            for _ in ThreatProfiles do
                profile_count += 1
            end
            addMsg("AI", `  Profiles Tracked: {profile_count}`)
            addMsg("AI", `  Strategies in Memory: {#AIMemory.StrategyResults}`)
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- PROFILES COMMAND (list all)
        -- ═══════════════════════════════════════════════════════════
        if lower:find("profiles") and not lower:find("profile%s") then
            addMsg("AI", "═══ THREAT PROFILES ═══", Color3.fromRGB(0, 150, 255))
            local count: number = 0
            for name: string, prof in ThreatProfiles do
                count += 1
                if type(prof) == "table" then
                    local features_str: string = AI_FormatFeatureList(prof.SuspectedFeatures or {})
                    addMsg("AI",
                        `  {name} | Kills: {prof.TotalKills} | Threat: {prof.ThreatScore}/100 | Features: {features_str}`)
                end
            end
            if count == 0 then
                addMsg("AI", "  No threat profiles recorded yet. Die to generate data.")
            end
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- PROFILE [NAME] COMMAND (specific lookup)
        -- ═══════════════════════════════════════════════════════════
        if cmd == "profile" and arg then
            local profileMatch: string = arg
            local found = nil
            local foundName: string = ""

            for name: string, prof in ThreatProfiles do
                if type(name) == "string" and name:lower():find(profileMatch:lower()) then
                    found = prof
                    foundName = name
                    break
                end
            end

            if found and type(found) == "table" then
                addMsg("AI", `═══ PROFILE: {foundName} ═══`, Color3.fromRGB(0, 150, 255))
                addMsg("AI", `  Total Kills: {found.TotalKills}`)
                addMsg("AI", `  Avg Distance: {math.floor(found.AvgDistance)} studs`)
                addMsg("AI", `  Avg TTK: {string.format("%.2f", found.AvgTTK)}s`)
                addMsg("AI", `  Threat Score: {found.ThreatScore}/100`)
                addMsg("AI", `  Suspected Features: {AI_FormatFeatureList(found.SuspectedFeatures or {})}`)
                addMsg("AI", "  Confidence Breakdown:")

                if type(found.Confidence) == "table" then
                    local has_confidence: boolean = false
                    for feat: string, conf: number in found.Confidence do
                        if type(conf) == "number" then
                            has_confidence = true
                            addMsg("AI", `    {feat}: {math.floor(conf)}%`)
                        end
                    end
                    if not has_confidence then
                        addMsg("AI", "    (no confidence data yet)")
                    end
                end

                if type(found.Weapons) == "table" then
                    addMsg("AI", "  Weapons Used:")
                    local has_weapons: boolean = false
                    for weapon: string, uses: number in found.Weapons do
                        has_weapons = true
                        addMsg("AI", `    {weapon}: {uses}x`)
                    end
                    if not has_weapons then
                        addMsg("AI", "    (no weapon data)")
                    end
                end
            else
                addMsg("AI", `No profile found for '{profileMatch}'.`)
            end
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- THREATS COMMAND
        -- ═══════════════════════════════════════════════════════════
        if lower:find("threats") or lower:find("threat") then
            addMsg("AI", "═══ LIVE THREAT ASSESSMENT ═══", Color3.fromRGB(0, 150, 255))
            addMsg("AI", `  Current Level: {ThreatLevel}`)
            local trend_str: string = if ThreatTrend > 0 then "RISING ↑" elseif ThreatTrend < 0 then "FALLING ↓" else "STABLE →"
            addMsg("AI", `  Trend: {trend_str}`)
            addMsg("AI", `  Peak: {PeakThreat}`)
            addMsg("AI", `  Radius: {ThreatRadius} studs`)

            local nearby: number = 0
            local myChar: Model? = player.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local myRoot: BasePart = myChar:FindFirstChild("HumanoidRootPart")
                local pos_ok: boolean, myPos = pcall(function() return myRoot.Position end)
                if pos_ok and typeof(myPos) == "Vector3" then
                    local players_ok: boolean, players_list = pcall(function() return Players:GetPlayers() end)
                    if players_ok and type(players_list) == "table" then
                        for _, plr: Player in players_list do
                            if plr ~= player then
                                local char_ok: boolean, plrChar = pcall(function() return plr.Character end)
                                if char_ok and plrChar then
                                    local theirRoot: Instance? = plrChar:FindFirstChild("HumanoidRootPart")
                                    if theirRoot then
                                        local tpos_ok: boolean, theirPos = pcall(function() return theirRoot.Position end)
                                        if tpos_ok and typeof(theirPos) == "Vector3" then
                                            local d: number = (theirPos - myPos).Magnitude
                                            if d < ThreatRadius then
                                                nearby += 1
                                                addMsg("AI",
                                                    `  ⚠ {plr.Name} - {math.floor(d)} studs away`,
                                                    Color3.fromRGB(255, 150, 50))
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if nearby == 0 then
                addMsg("AI", "  ✓ No players within threat radius.", Color3.fromRGB(0, 255, 100))
            end
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- MEMORY COMMAND
        -- ═══════════════════════════════════════════════════════════
        if lower:find("memory") then
            addMsg("AI", "═══ AI LEARNING STATISTICS ═══", Color3.fromRGB(0, 150, 255))
            addMsg("AI", `  Strategies Stored: {#AIMemory.StrategyResults}`)
            addMsg("AI", `  Learning Rate: {string.format("%.3f", AIMemory.SessionLearningRate)}`)

            local successes, failures, rate = AI_GetSuccessRate()
            addMsg("AI", `  Successful Counters: {successes}`)
            addMsg("AI", `  Failed Counters: {failures}`)
            if successes + failures > 0 then
                addMsg("AI", `  Success Rate: {rate}%`)
            end

            addMsg("AI", "  Feature Effectiveness:")
            if type(AIMemory.FeatureEffectiveness) == "table" then
                local has_data: boolean = false
                for feat: string, eff: number in AIMemory.FeatureEffectiveness do
                    if type(eff) == "number" then
                        has_data = true
                        local eff_pct: number = math.floor(eff * 100)
                        addMsg("AI", `    {feat}: {eff_pct}% effective`)
                    end
                end
                if not has_data then
                    addMsg("AI", "    (no effectiveness data yet)")
                end
            end

            addMsg("AI", `  Combinations Tried: {#StrategyEngine.FeatureCombinations}`)
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- DISABLE ALL COMMAND
        -- ═══════════════════════════════════════════════════════════
        if lower:find("disable all") or lower:find("stop all") or lower:find("turn off") then
            Aura.Enabled = false
            if type(_G.EXO_StopAuraLoop) == "function" then pcall(_G.EXO_StopAuraLoop) end
            InstaKillEnabled = false
            if type(_G.EXO_StopInstaKill) == "function" then pcall(_G.EXO_StopInstaKill) end
            HitAmpEnabled = false
            if type(_G.EXO_StopHitAmplifier) == "function" then pcall(_G.EXO_StopHitAmplifier) end
            AntiAura.Enabled = false
            if type(_G.EXO_StopAntiAura) == "function" then pcall(_G.EXO_StopAntiAura) end
            Reach = false
            if type(_G.EXO_StopReach) == "function" then pcall(_G.EXO_StopReach) end
            ToolFollow.Enabled = false
            if type(_G.EXO_StopToolFollow) == "function" then pcall(_G.EXO_StopToolFollow) end
            NoCooldown = false
            if type(_G.EXO_StopNoCooldown) == "function" then pcall(_G.EXO_StopNoCooldown) end

            addMsg("AI", "All AI-activated features disabled. You're back to manual control.", Color3.fromRGB(255, 200, 0))
            if type(_G.EXO_RobotSetState) == "function" then
                pcall(_G.EXO_RobotSetState, "IDLE")
            end
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- WHY COMMAND
        -- ═══════════════════════════════════════════════════════════
        if lower:find("why") then
            if #KillLogs == 0 then
                addMsg("AI", "No kill data yet. I need to observe at least one death to analyze why you're losing.")
            else
                local last = KillLogs[#KillLogs]
                if type(last) == "table" then
                    addMsg("AI", "═══ LAST KILL ANALYSIS ═══", Color3.fromRGB(255, 200, 0))
                    addMsg("AI", `  You were killed by {last.Killer} using {last.Weapon}`)
                    addMsg("AI", `  Distance: {last.Distance} studs`)
                    if last.TTK then
                        addMsg("AI", `  Time-to-Kill: {string.format("%.2f", last.TTK)}s`)
                    end
                    if type(last.Suspected) == "table" then
                        addMsg("AI", `  Suspected features: {AI_FormatFeatureList(last.Suspected)}`)
                    end
                    if type(last.Counter) == "table" then
                        addMsg("AI", `  Recommended counters: {table.concat(last.Counter, " | ")}`)
                    end
                end
            end
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- TARGET [NAME] COMMAND
        -- ═══════════════════════════════════════════════════════════
        if cmd == "target" and arg then
            local targetMatch: string = arg
            local targetPlr: Player? = nil

            local players_ok: boolean, players_list = pcall(function() return Players:GetPlayers() end)
            if players_ok and type(players_list) == "table" then
                for _, plr: Player in players_list do
                    local name_ok: boolean, name = pcall(function() return plr.Name end)
                    if name_ok and type(name) == "string" and name:lower():find(targetMatch:lower()) then
                        targetPlr = plr
                        break
                    end
                end
            end

            if targetPlr then
                Aura.TargetList = {targetPlr}
                Aura.Enabled = true
                InstaKillEnabled = true
                if type(_G.EXO_StartAuraLoop) == "function" then pcall(_G.EXO_StartAuraLoop) end
                if type(_G.EXO_StartInstaKill) == "function" then pcall(_G.EXO_StartInstaKill) end
                addMsg("AI",
                    `All systems locked onto {targetPlr.Name}. Aura + InstaKill active.`,
                    Color3.fromRGB(255, 50, 50))
            else
                addMsg("AI", `Player '{targetMatch}' not found in server.`)
            end
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- STRATEGY COMMAND
        -- ═══════════════════════════════════════════════════════════
        if lower:find("strategy") then
            if AI_State.PendingStrategy then
                local s = AI_State.PendingStrategy
                addMsg("AI", `═══ ACTIVE STRATEGY: {s.Target} ═══`, Color3.fromRGB(0, 150, 255))
                addMsg("AI", `  Priority: {s.Priority} | Confidence: {s.Confidence}%`)
                if s.MutatedFrom then
                    addMsg("AI", "  ⚡ MUTATED from previous failed strategy", Color3.fromRGB(255, 200, 0))
                end
                if type(s.Actions) == "table" then
                    for i, a in s.Actions do
                        if type(a) == "table" then
                            local val_str: string = if a.value then ` = {a.value}` else ""
                            addMsg("AI", `  {i}. {a.type:upper()} {a.feature}{val_str}`)
                        end
                    end
                end
            elseif StrategyEngine.ActiveStrategy then
                local s = StrategyEngine.ActiveStrategy
                addMsg("AI", `═══ LAST EXECUTED STRATEGY: {s.Target} ═══`, Color3.fromRGB(0, 150, 255))
                addMsg("AI", `  Priority: {s.Priority} | Confidence: {s.Confidence}%`)
                addMsg("AI", `  Executed at: {os.date("%H:%M:%S", StrategyEngine.LastStrategyTime)}`)
            else
                addMsg("AI", "No active strategy. I'll formulate one when you get killed.")
            end
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- FEATURES COMMAND
        -- ═══════════════════════════════════════════════════════════
        if lower:find("features") then
            addMsg("AI", "═══ DETECTABLE FEATURE TYPES ═══", Color3.fromRGB(0, 150, 255))
            addMsg("AI", "  LoopBring - Teleporting weapon to you (TTK < 0.3s, dist < 8)")
            addMsg("AI", "  KillAura - Proximity damage without swinging (dist 5-15, TTK < 0.5s)")
            addMsg("AI", "  Reach - Extended hitbox (dist > 25)")
            addMsg("AI", "  FastKill / RemoteSpam - Rapid remote firing (TTK < 0.2s)")
            addMsg("AI", "  FightEventAbuse - Direct FightEvent calls (no weapon, TTK < 0.5s)")
            addMsg("AI", "  HitAmplifier - OverlapParams scanning (dist 15-30, TTK < 0.8s)")
            addMsg("AI", "  ToolFollow - Weapons tracking your body (dist < 3, kills > 3)")
            addMsg("AI", "  SpawnKill - Camping respawn point (TSR < 2s)")
            addMsg("AI", "  BurstKillPattern - Clustered deaths (window < 5s)")
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- KILLLOGS COMMAND
        -- ═══════════════════════════════════════════════════════════
        if lower:find("killlogs") or lower:find("kill logs") then
            if #KillLogs == 0 then
                addMsg("AI", "No kill logs recorded this session.")
            else
                addMsg("AI", `═══ KILL LOGS ({#KillLogs} total) ═══`, Color3.fromRGB(0, 150, 255))
                local start_idx: number = math.max(1, #KillLogs - 4)
                for i = start_idx, #KillLogs do
                    local log = KillLogs[i]
                    if type(log) == "table" then
                        addMsg("AI",
                            `  [{i}] {log.Killer} | {log.Weapon} | {log.Distance} studs | Threat {log.Threat}/10`)
                    end
                end
            end
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- CLEAR COMMAND
        -- ═══════════════════════════════════════════════════════════
        if lower:find("clear") then
            if ChatSystem.ScrollFrame then
                local children_ok: boolean, children = pcall(function() return ChatSystem.ScrollFrame:GetChildren() end)
                if children_ok and type(children) == "table" then
                    for _, child: Instance in children do
                        if child:IsA("Frame") then
                            pcall(function() child:Destroy() end)
                        end
                    end
                end
                ChatSystem.MessageCount = 0
            end
            addMsg("AI", "Chat cleared.")
            return
        end

        -- ═══════════════════════════════════════════════════════════
        -- DEFAULT RESPONSE
        -- ═══════════════════════════════════════════════════════════
        addMsg("AI", `I understood your message: "{text}". Type 'help' for available commands.`)
    end

    -- Expose globally
    _G.EXO_ProcessUserMessage = AI_ProcessUserMessage

    print(`[EXO] Section 22.1 complete. Natural Language Interface registered.`)
    print(`[EXO]   Commands: help, status, profiles, profile, strategy, threats,`)
    print(`[EXO]   memory, disable all, why, target, features, killlogs, clear`)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 23.0: PART 3 (SECOND HALF) REGISTRY & BRIDGE              ║
-- ║  Verifies all kill intel + chat/robot modules registered             ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local killintel_chat_globals: {string} = {
        -- Kill Intelligence
        "EXO_AnalyzeKill",
        "EXO_SetupKillNotifications",
        -- Chat UI
        "EXO_ChatCreateGUI",
        "EXO_ChatAddMessage",
        -- Robot Animator
        "EXO_RobotSetState",
        -- Kill Analysis Pipeline
        "EXO_OnKillDetected",
        -- Natural Language Interface
        "EXO_ProcessUserMessage",
    }

    local registered: number = 0
    local missing: {string} = {}

    for _, name: string in killintel_chat_globals do
        if type(_G[name]) == "function" then
            registered += 1
        else
            table.insert(missing, name)
        end
    end

    print(`[EXO] ═══════════════════════════════════════════════════`)
    print(`[EXO] PART 3 (SECOND HALF) COMPLETE`)
    print(`[EXO] Kill Intel + Chat/Robot modules registered: {registered}/{#killintel_chat_globals}`)
    if #missing > 0 then
        warn(`[EXO] Missing modules: {table.concat(missing, ", ")}`)
    else
        print(`[EXO] All kill intel + chat/robot systems operational.`)
    end
    print(`[EXO] ═══════════════════════════════════════════════════`)
    print(`[EXO] PART 3 FULLY COMPLETE: Visuals + Automation + Kill Intel + AI Chat`)
    print(`[EXO] Next: Part 4 – UI Tab Construction, Settings, Finalize`)
end
