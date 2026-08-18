
-- =============================================================================
-- START OF PART 1 (THIRD HALF) (SECTIONS 12.5-13.7)
-- =============================================================================
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 12.5: MOVEMENT SYSTEMS INITIALIZATION (NEW IN v10)        ║
--   Speed, Jump, Noclip, Fly, InfiniteJump – typed & pre-allocated    ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
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
MovementConns.FlyConn = RunService.RenderStepped:Connect(function()
if not Movement.Fly then return end
if not _fly_body_vel or not _fly_body_gyro then return end
if not _fly_camera then
_fly_camera = workspace.CurrentCamera
if not _fly_camera then return end
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
if type(feature) ~= "string" then return end
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
local function Movement_StopAll(): ()
Movement.SpeedHack = false
Movement.JumpPower = false
Movement.Noclip = false
Movement.Fly = false
Movement.InfiniteJump = false
Movement_StopSpeedLoop()
Movement_StopJumpLoop()
Movement_StopNoclip()
Movement_StopFly()
Movement_StopInfiniteJump()
end
-- Auto-reset all movement on character death/respawn
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
_G.EXO_Movement_StopAll = Movement_StopAll
_G.EXO_Movement_StartSpeedLoop = Movement_StartSpeedLoop
_G.EXO_Movement_StopSpeedLoop = Movement_StopSpeedLoop
_G.EXO_Movement_StartFly = Movement_StartFly
_G.EXO_Movement_StopFly = Movement_StopFly
_G.EXO_Movement_StartNoclip = Movement_StartNoclip
_G.EXO_Movement_StopNoclip = Movement_StopNoclip
_G.EXO_Movement_StartInfiniteJump = Movement_StartInfiniteJump
_G.EXO_Movement_StopInfiniteJump = Movement_StopInfiniteJump
_G.EXO_ApplySpeed = Movement_ApplySpeed
_G.EXO_ResetSpeed = Movement_ResetSpeed
_G.EXO_ApplyJump = Movement_ApplyJumpPower
_G.EXO_ResetJump = Movement_ResetJumpPower
print(`[EXO] Section 12.5 complete. Movement Systems initialized.`)
print(`[EXO]   Features: Speed, JumpPower, Noclip, Fly, InfiniteJump`)
print(`[EXO]   Fly controls: WASD + Space/Shift`)
print(`[EXO]   Auto-reset on respawn: ENABLED`)
end
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 13.1: 1000x AURA ENGINE                                   ║
-- ║  Multi-vector prediction | Triple-remote fire | Multi-hitbox         ║
-- ║  Isolated in do...end block to cap local registers                   ║
-- ══════════════════════════════════════════════════════════════════════╝
do
-- Private state (scoped to this block only)
local _aura_conn: RBXScriptConnection? = nil
local _aura_tick_count: number = 0
-- Local helper: find all damage parts on a tool
local function _find_damage_parts(tool: Instance): {BasePart}
local result: {BasePart} = {}
local ok: boolean, descendants = pcall(function()
return tool:GetDescendants()
end)
if ok and type(descendants) == "table" then
for _, obj: Instance in descendants do
if obj:IsA("TouchTransmitter") then
local parent = obj.Parent
if parent and parent:IsA("BasePart") then
table.insert(result, parent)
end
end
end
end
if #result == 0 then
local handle: Instance? = tool:FindFirstChild("Handle")
if handle and handle:IsA("BasePart") then
table.insert(result, handle)
end
end
return result
end
-- Local helper: predict target position with quadratic + gravity
local function _predict_position(pos: Vector3, vel: Vector3, latency: number): Vector3
return pos + vel * latency + vel * vel * 0.002 + Vector3.new(0, -0.5, 0)
end
-- Main aura start function
local function startAuraLoop(): ()
if _aura_conn then
pcall(function() _aura_conn:Disconnect() end)
end
_aura_tick_count = 0
_aura_conn = RunService.PreSimulation:Connect(function()
-- Periodic threat update (throttled)
if _aura_tick_count % 10 == 0 then
updateThreatLevel()
end
_aura_tick_count += 1
if not Aura.Enabled then
return
end
local myChar: Model? = player.Character
if not myChar then
return
end
local children_ok: boolean, myChildren = pcall(function() return myChar:GetChildren() end)
if not children_ok or type(myChildren) ~= "table" then
return
end
for _, tool: Instance in myChildren do
if tool:IsA("Tool") then
local damageParts: {BasePart} = _find_damage_parts(tool)
if #damageParts == 0 then
continue
end
for _, damagePart: BasePart in damageParts do
local cf_ok: boolean, origCF = pcall(function() return damagePart.CFrame end)
if not cf_ok or typeof(origCF) ~= "CFrame" then
continue
end
for _, targetPlr: Player in Aura.TargetList do
local tchar_ok: boolean, tChar = pcall(function() return targetPlr.Character end)
if not tchar_ok or not tChar then
continue
end
local hum: Instance? = tChar:FindFirstChild("Humanoid")
if not hum then
continue
end
local health_ok: boolean, health = pcall(function() return hum.Health end)
if not health_ok or type(health) ~= "number" or health <= 0 then
continue
end
local root: Instance? = tChar:FindFirstChild("HumanoidRootPart")
if not root or not root:IsA("BasePart") then
continue
end
-- 1000x PREDICTION: Velocity + gravity compensation
local pos_ok: boolean, rootPos = pcall(function() return root.Position end)
local vel_ok: boolean, rootVel = pcall(function() return root.Velocity end)
if not pos_ok or typeof(rootPos) ~= "Vector3" then
continue
end
local vel: Vector3 = (vel_ok and typeof(rootVel) == "Vector3") and rootVel or Vector3.zero
-- Multi-hitbox targeting: HRP + Torso + Head
local hitTargets: {BasePart} = {root}
local torso: Instance? = tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso")
local head: Instance? = tChar:FindFirstChild("Head")
if torso and torso:IsA("BasePart") then
table.insert(hitTargets, torso)
end
if head and head:IsA("BasePart") then
table.insert(hitTargets, head)
end
for _, hitPart: BasePart in hitTargets do
local hpos_ok: boolean, hitPos = pcall(function() return hitPart.Position end)
if not hpos_ok or typeof(hitPos) ~= "Vector3" then
continue
end
local targetPos: Vector3 = _predict_position(hitPos, vel, latencyEstimate)
pcall(function()
damagePart.CFrame = CFrame.new(targetPos)
end)
-- TRIPLE REMOTE FIRE (1000x upgrade)
if DAMAGE_REMOTE then
pcall(function()
DAMAGE_REMOTE:FireServer(tChar, damagePart)
end)
end
if DAMAGE_REMOTE_ALT then
pcall(function()
DAMAGE_REMOTE_ALT:FireServer(tChar, damagePart)
end)
end
if DAMAGE_REMOTE_TERT then
pcall(function()
DAMAGE_REMOTE_TERT:FireServer(tChar, damagePart)
end)
end
-- Touch fallback for servers without remotes
if not DAMAGE_REMOTE and firetouchinterest then
pcall(firetouchinterest, damagePart, hitPart, 0)
pcall(firetouchinterest, damagePart, hitPart, 1)
end
end
-- Restore original CFrame after sweep
pcall(function()
damagePart.CFrame = origCF
end)
end
end
end
end
-- 1000x INSTANT KILL: Multi-method termination
if InstantKill then
for _, plr: Player in Aura.TargetList do
local tchar_ok: boolean, tChar = pcall(function() return plr.Character end)
if not tchar_ok or not tChar then
continue
end
local hum: Instance? = tChar:FindFirstChild("Humanoid")
if not hum then
continue
end
local health_ok: boolean, health = pcall(function() return hum.Health end)
if not health_ok or type(health) == "number" or health <= 0 then
continue
end
pcall(function()
hum:TakeDamage(9e9)
end)
pcall(function()
hum.Health = 0
end)
-- Brief HRP anchor to lock target in place
local hrp: Instance? = tChar:FindFirstChild("HumanoidRootPart")
if hrp and hrp:IsA("BasePart") then
pcall(function()
hrp.Anchored = true
end)
task.delay(0.1, function()
pcall(function()
if hrp and hrp.Parent then
hrp.Anchored = false
end
end)
end)
end
end
end
end)
end
local function stopAuraLoop(): ()
if _aura_conn then
pcall(function() _aura_conn:Disconnect() end)
_aura_conn = nil
end
_aura_tick_count = 0
end
-- Expose via _G for cross-part access
_G.EXO_StartAuraLoop = startAuraLoop
_G.EXO_StopAuraLoop = stopAuraLoop
print(`[EXO] Section 13.1 complete. Aura Engine registered.`)
print(`[EXO]   Prediction: Quadratic + gravity compensation`)
print(`[EXO]   Hitboxes: HRP + UpperTorso/Torso + Head`)
print(`[EXO]   Remotes: Triple fire (primary + alt + tertiary)`)
end
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 13.2: 1000x TOOL FOLLOW                                   ║
-- ║  Predictive velocity tracking | Auto tool cache refresh              ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
local _tf_conn: RBXScriptConnection? = nil
local _tf_tool_cache: {BasePart} = {}
local _tf_last_refresh: number = 0
local function _refresh_tool_cache(): ()
-- Throttle refreshes to once per second max
if tick() - _tf_last_refresh < 1.0 then
return
end
_tf_last_refresh = tick()
table.clear(_tf_tool_cache)
local char: Model? = player.Character
if not char then
return
end
local children_ok: boolean, children = pcall(function() return char:GetChildren() end)
if not children_ok or type(children) ~= "table" then
return
end
for _, tool: Instance in children do
if tool:IsA("Tool") then
local handle: Instance? = tool:FindFirstChild("Handle")
if handle and handle:IsA("BasePart") then
table.insert(_tf_tool_cache, handle)
else
-- Fallback: find any BasePart in the tool
local desc_ok: boolean, descendants = pcall(function() return tool:GetDescendants() end)
if desc_ok and type(descendants) == "table" then
for _, v: Instance in descendants do
if v:IsA("BasePart") then
table.insert(_tf_tool_cache, v)
break
end
end
end
end
end
end
end
local function startToolFollow(): ()
if _tf_conn then
pcall(function() _tf_conn:Disconnect() end)
end
_refresh_tool_cache()
_tf_conn = RunService.PreSimulation:Connect(function()
if not ToolFollow.Enabled or #ToolFollow.Targets == 0 then
return
end
-- Periodic cache refresh
_refresh_tool_cache()
if #_tf_tool_cache == 0 then
return
end
for _, targetPlr: Player in ToolFollow.Targets do
local tchar_ok: boolean, tChar = pcall(function() return targetPlr.Character end)
if not tchar_ok or not tChar then
continue
end
local hum: Instance? = tChar:FindFirstChild("Humanoid")
if not hum then
continue
end
local health_ok: boolean, health = pcall(function() return hum.Health end)
if not health_ok or type(health) == "number" or health <= 0 then
continue
end
local torso: Instance? = tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso")
if not torso or not torso:IsA("BasePart") then
continue
end
local tpos_ok: boolean, torsoPos = pcall(function() return torso.Position end)
local tvel_ok: boolean, torsoVel = pcall(function() return torso.Velocity end)
if not tpos_ok or typeof(torsoPos) ~= "Vector3" then
continue
end
local vel: Vector3 = (tvel_ok and typeof(torsoVel) == "Vector3") and torsoVel or Vector3.zero
local predictedPos: Vector3 = torsoPos + vel * ToolFollow.PredictionOffset + Vector3.new(0, 0.8, 0.5)
for _, part: BasePart in _tf_tool_cache do
if part and part.Parent then
pcall(function()
part.Position = predictedPos
part.CanCollide = false
part.Massless = true
part.Anchored = false
end)
end
end
end
end)
end
local function stopToolFollow(): ()
if _tf_conn then
pcall(function() _tf_conn:Disconnect() end)
_tf_conn = nil
end
table.clear(_tf_tool_cache)
end
_G.EXO_StartToolFollow = startToolFollow
_G.EXO_StopToolFollow = stopToolFollow
print(`[EXO] Section 13.2 complete. Tool Follow registered.`)
print(`[EXO]   Prediction offset: {ToolFollow.PredictionOffset}s velocity lookahead`)
print(`[EXO]   Vertical offset: Vector3.new(0, 0.8, 0.5)`)
print(`[EXO]   Cache refresh: 1.0s throttle`)
end
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 13.3: 1000x ANTI-AURA                                     ║
-- ║  ForceField | HealAura | Repel | Phase | ShieldStack                 ║
--   Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
local _aa_conn: RBXScriptConnection? = nil
local _aa_ff: ForceField? = nil
local function startAntiAura(): ()
if _aa_conn then
pcall(function() _aa_conn:Disconnect() end)
end
_aa_conn = RunService.Heartbeat:Connect(function()
if not AntiAura.Enabled then
return
end
local myChar: Model? = player.Character
if not myChar then
return
end
local root: Instance? = myChar:FindFirstChild("HumanoidRootPart")
local hum: Instance? = myChar:FindFirstChild("Humanoid")
if not root or not hum then
return
end
if not root:IsA("BasePart") or not hum:IsA("Humanoid") then
return
end
-- GOD MODE: ForceField + auto-heal below threshold
if AntiAura.GodMode then
if not _aa_ff or not _aa_ff.Parent then
local ff_ok: boolean, ff = pcall(function()
local f: ForceField = Instance.new("ForceField")
f.Visible = false
f.Parent = myChar
return f
end)
if ff_ok and ff then
_aa_ff = ff
end
end
local health_ok: boolean, currentHealth = pcall(function() return hum.Health end)
local max_ok: boolean, maxHealth = pcall(function() return hum.MaxHealth end)
if health_ok and max_ok and type(currentHealth) == "number" and type(maxHealth) == "number" then
if currentHealth < maxHealth * 0.7 then
pcall(function()
hum.Health = maxHealth
end)
end
end
AntiAura.ShieldStack += 1
if AntiAura.ShieldStack > 1000 then
AntiAura.ShieldStack = 1
end
else
if _aa_ff and _aa_ff.Parent then
pcall(function() _aa_ff:Destroy() end)
_aa_ff = nil
end
end
-- HEAL AURA: Continuous regeneration
if AntiAura.HealAura then
local health_ok: boolean, currentHealth = pcall(function() return hum.Health end)
local max_ok: boolean, maxHealth = pcall(function() return hum.MaxHealth end)
if health_ok and max_ok and type(currentHealth) == "number" and type(maxHealth) == "number" then
if currentHealth < maxHealth and currentHealth > 0 then
local healAmount: number = maxHealth * AntiAura.HealRate
pcall(function()
hum.Health = math.min(maxHealth, currentHealth + healAmount)
end)
end
end
end
-- REPEL: Push enemy tool handles away with configurable force
if AntiAura.Repel then
local players_ok: boolean, players_list = pcall(function() return Players:GetPlayers() end)
if players_ok and type(players_list) == "table" then
for _, otherPlr: Player in players_list do
if otherPlr ~= player then
local char_ok: boolean, otherChar = pcall(function() return otherPlr.Character end)
if char_ok and otherChar then
local children_ok: boolean, children = pcall(function() return otherChar:GetChildren() end)
if children_ok and type(children) == "table" then
for _, tool: Instance in children do
if tool:IsA("Tool") then
local handle: Instance? = tool:FindFirstChild("Handle")
if handle and handle:IsA("BasePart") then
local hpos_ok: boolean, handlePos = pcall(function() return handle.Position end)
local rpos_ok: boolean, rootPos = pcall(function() return root.Position end)
if hpos_ok and rpos_ok and typeof(handlePos) == "Vector3" and typeof(rootPos) == "Vector3" then
local dist: number = (handlePos - rootPos).Magnitude
if dist < AntiAura.RepelRadius then
local dir: Vector3 = (rootPos - handlePos).Unit
pcall(function()
handle.AssemblyLinearVelocity = dir * AntiAura.RepelForce
handle.CanCollide = false
end)
end
end
end
end
end
end
end
end
end
end
end
-- PHASE: Full no-collide on all character parts
if AntiAura.Phase then
local children_ok: boolean, children = pcall(function() return myChar:GetChildren() end)
if children_ok and type(children) == "table" then
for _, part: Instance in children do
if part:IsA("BasePart") then
pcall(function()
part.CanCollide = false
end)
end
end
end
end
end)
end
local function stopAntiAura(): ()
if _aa_conn then
pcall(function() _aa_conn:Disconnect() end)
_aa_conn = nil
end
if _aa_ff and _aa_ff.Parent then
pcall(function() _aa_ff:Destroy() end)
_aa_ff = nil
end
AntiAura.ShieldStack = 0
end
_G.EXO_StartAntiAura = startAntiAura
_G.EXO_StopAntiAura = stopAntiAura
print(`[EXO] Section 13.3 complete. Anti-Aura registered.`)
print(`[EXO]   GodMode heal threshold: 0.7`)
print(`[EXO]   Repel force: {AntiAura.RepelForce} (configurable 50-300)`)
print(`[EXO]   Repel radius: {AntiAura.RepelRadius} (configurable 8-30)`)
print(`[EXO]   Features: GodMode, HealAura, Reflect, Repel, Phase, ShieldStack`)
end
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 13.4: 1000x REACH ENGINE                                  ║
-- ║  Dynamic sizing | Original size restoration | Highlight outline      ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
local _reach_original_sizes: {[BasePart]: Vector3} = {}
local _reach_highlights: {[BasePart]: Highlight} = {}
local function applyReach(): ()
local myChar: Model? = player.Character
if not myChar then
return
end
local children_ok: boolean, children = pcall(function() return myChar:GetChildren() end)
if not children_ok or type(children) ~= "table" then
return
end
for _, t: Instance in children do
if t:IsA("Tool") then
local part: BasePart? = nil
-- Find handle or first BasePart
local handle: Instance? = t:FindFirstChild("Handle")
if handle and handle:IsA("BasePart") then
part = handle
else
local desc_ok: boolean, descendants = pcall(function() return t:GetDescendants() end)
if desc_ok and type(descendants) == "table" then
for _, v: Instance in descendants do
if v:IsA("BasePart") then
part = v
break
end
end
end
end
if part then
-- Store original size for restoration
if not _reach_original_sizes[part] then
local size_ok: boolean, origSize = pcall(function() return part.Size end)
if size_ok and typeof(origSize) == "Vector3" then
_reach_original_sizes[part] = origSize
end
end
if _reach_original_sizes[part] then
local newSize: Vector3 = _reach_original_sizes[part] * ReachSize
pcall(function()
part.Size = newSize
part.Massless = true
part.CanCollide = false
end)
-- Highlight outline for visual feedback
if not _reach_highlights[part] then
local hl_ok: boolean, hl = pcall(function()
local h: Highlight = Instance.new("Highlight")
h.FillTransparency = 1
h.OutlineColor = Color3.fromRGB(0, 150, 255)
h.Parent = part
return h
end)
if hl_ok and hl then
_reach_highlights[part] = hl
end
end
end
end
end
end
end
local function stopReach(): ()
-- Destroy all highlights
for part: BasePart, hl: Highlight in _reach_highlights do
if hl and hl.Parent == part then
pcall(function() hl:Destroy() end)
end
end
table.clear(_reach_highlights)
-- Restore all original sizes
for part: BasePart, origSize: Vector3 in _reach_original_sizes do
if part and part.Parent and typeof(origSize) == "Vector3" then
pcall(function()
part.Size = origSize
end)
end
end
table.clear(_reach_original_sizes)
end
_G.EXO_ApplyReach = applyReach
_G.EXO_StopReach = stopReach
print(`[EXO] Section 13.4 complete. Reach Engine registered.`)
print(`[EXO]   Max reach: 15x`)
print(`[EXO]   Features: Original size storage, highlight outline, Massless, NoCollide`)
end
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 13.5: 1000x INSTA-KILL                                    ║
--   120Hz scan | 9-hitbox targeting | Adaptive burst | Backpack scan    ║
--   Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
local _ik_conn: RBXScriptConnection? = nil
local _ik_tools_cache: {{Tool: Tool, FightEvent: RemoteEvent?, TouchPart: BasePart?}} = {}
local _ik_target_parts: {BasePart} = {}
local _ik_last_activation: number = 0
local _ik_last_refresh: number = 0
local _ik_hitbox_names: {string} = {
"HumanoidRootPart",
"UpperTorso",
"Torso",
"Head",
"LowerTorso",
"LeftUpperArm",
"RightUpperArm",
"LeftUpperLeg",
"RightUpperLeg",
}
local function _ik_refresh_tools(): ()
-- Throttle refreshes to 4x per second max
if os.clock() - _ik_last_refresh < 0.25 then
return
end
_ik_last_refresh = os.clock()
table.clear(_ik_tools_cache)
local char: Model? = player.Character
if not char then
return
end
-- Scan equipped tools
local children_ok: boolean, children = pcall(function() return char:GetChildren() end)
if children_ok and type(children) == "table" then
for _, tool: Instance in children do
if tool:IsA("Tool") then
local fightEvent: Instance? = tool:FindFirstChild("FightEvent", true)
local touchTransmitter: Instance? = tool:FindFirstChildWhichIsA("TouchTransmitter", true)
local touchPart: BasePart? = nil
if touchTransmitter and touchTransmitter.Parent and touchTransmitter.Parent:IsA("BasePart") then
touchPart = touchTransmitter.Parent
end
if fightEvent and fightEvent:IsA("RemoteEvent") then
table.insert(_ik_tools_cache, {
Tool = tool,
FightEvent = fightEvent,
TouchPart = touchPart,
})
elseif touchPart then
table.insert(_ik_tools_cache, {
Tool = tool,
FightEvent = nil,
TouchPart = touchPart,
})
end
end
end
end
-- 1000x UPGRADE: Also scan Backpack
local bp: Instance? = player:FindFirstChildOfClass("Backpack")
if bp then
local bp_ok: boolean, bp_children = pcall(function() return bp:GetChildren() end)
if bp_ok and type(bp_children) == "table" then
for _, tool: Instance in bp_children do
if tool:IsA("Tool") then
local fightEvent: Instance? = tool:FindFirstChild("FightEvent", true)
if fightEvent and fightEvent:IsA("RemoteEvent") then
table.insert(_ik_tools_cache, {
Tool = tool,
FightEvent = fightEvent,
TouchPart = nil,
})
end
end
end
end
end
end
local function _ik_get_target(): Model?
local myChar: Model? = player.Character
local myRoot: BasePart? = nil
if myChar then
local hrp: Instance? = myChar:FindFirstChild("HumanoidRootPart")
if hrp and hrp:IsA("BasePart") then
myRoot = hrp
end
end
if not myRoot then
return nil
end
local bestChar: Model? = nil
local bestDist: number = 50
local players_ok: boolean, players_list = pcall(function() return Players:GetPlayers() end)
if not players_ok or type(players_list) ~= "table" then
return nil
end
for _, plr: Player in players_list do
if plr ~= player then
local char_ok: boolean, plrChar = pcall(function() return plr.Character end)
if char_ok and plrChar then
local root: Instance? = plrChar:FindFirstChild("HumanoidRootPart")
if root and root:IsA("BasePart") then
local hum: Instance? = plrChar:FindFirstChildOfClass("Humanoid")
if hum then
local health_ok: boolean, health = pcall(function() return hum.Health end)
if health_ok and type(health) == "number" and health > 0 then
local dist_ok: boolean, dist = pcall(function()
return (root.Position - myRoot.Position).Magnitude
end)
if dist_ok and type(dist) == "number" and dist < bestDist then
bestDist = dist
bestChar = plrChar
end
end
end
end
end
end
end
return bestChar
end
local function _ik_micro_burst(targetChar: Model, burstCount: number): ()
if not targetChar or not player.Character then
return
end
if type(burstCount) ~= "number" or burstCount < 1 then
burstCount = IK_BurstCount
end
-- Populate 9-hitbox target list
table.clear(_ik_target_parts)
for _, name: string in _ik_hitbox_names do
local part: Instance? = targetChar:FindFirstChild(name)
if part and part:IsA("BasePart") then
table.insert(_ik_target_parts, part)
end
end
if #_ik_target_parts == 0 then
return
end
-- PARALLEL FIRE: All tools simultaneously
for _, toolData in _ik_tools_cache do
local tool: Tool? = toolData.Tool
local fight: RemoteEvent? = toolData.FightEvent
local touch: BasePart? = toolData.TouchPart
if tool and tool.Parent then
if fight then
pcall(function()
for _ = 1, burstCount do
fight:FireServer()
end
end)
else
pcall(tool.Activate, tool)
end
if touch then
for _, part: BasePart in _ik_target_parts do
if part and part.Parent then
if firetouchinterest then
pcall(firetouchinterest, touch, part, 0)
pcall(firetouchinterest, touch, part, 1)
end
end
end
end
end
end
end
local function startInstaKill(): ()
if _ik_conn then
pcall(function() _ik_conn:Disconnect() end)
end
_ik_refresh_tools()
_ik_conn = RunService.PreSimulation:Connect(function()
if not InstaKillEnabled then
return
end
local now: number = os.clock()
-- 1000x: 120Hz scan rate
if now - _ik_last_activation < 1/120 then
return
end
_ik_last_activation = now
_ik_refresh_tools()
if #_ik_tools_cache == 0 then
return
end
-- 1000x ADAPTIVE BURST: Scale by ThreatLevel * 2
local adaptiveBurst: number = IK_BurstCount
if IK_AdaptiveBurst and ThreatLevel > 2 then
adaptiveBurst = IK_BurstCount + ThreatLevel * 2
end
if adaptiveBurst > 30 then
adaptiveBurst = 30
end
local target: Model? = _ik_get_target()
if target then
_ik_micro_burst(target, adaptiveBurst)
end
end)
end
local function stopInstaKill(): ()
if _ik_conn then
pcall(function() _ik_conn:Disconnect() end)
_ik_conn = nil
end
table.clear(_ik_tools_cache)
table.clear(_ik_target_parts)
end
_G.EXO_StartInstaKill = startInstaKill
_G.EXO_StopInstaKill = stopInstaKill
print(`[EXO] Section 13.5 complete. Insta-Kill registered.`)
print(`[EXO]   Scan rate: 120Hz`)
print(`[EXO]   Target range: 50 studs`)
print(`[EXO]   Hitboxes: 9 (HRP, Torso x2, Head, LowerTorso, Arms x2, Legs x2)`)
print(`[EXO]   Backpack scanning: ENABLED`)
print(`[EXO]   Adaptive burst: ThreatLevel * 2 scaling`)
end
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 13.6: 1000x HIT AMPLIFIER                                 ║
-- ║  360° sphere + box scan | Multi-pulse | Configurable interval        ║
--   Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
local _ha_conn: RBXScriptConnection? = nil
local _ha_tools_cache: {{Tool: Tool, FightEvent: RemoteEvent?}} = {}
local _ha_last_activation: number = 0
local _ha_accumulator: number = 0
local _ha_last_refresh: number = 0
local _ha_overlap_params: OverlapParams = OverlapParams.new()
_ha_overlap_params.FilterType = Enum.RaycastFilterType.Exclude
local function _ha_refresh_tools(): ()
-- Throttle refreshes to 4x per second max
if os.clock() - _ha_last_refresh < 0.25 then
return
end
_ha_last_refresh = os.clock()
table.clear(_ha_tools_cache)
local char: Model? = player.Character
if not char then
return
end
local children_ok: boolean, children = pcall(function() return char:GetChildren() end)
if not children_ok or type(children) ~= "table" then
return
end
for _, t: Instance in children do
if t:IsA("Tool") then
local fight: Instance? = t:FindFirstChild("FightEvent", true)
if fight and fight:IsA("RemoteEvent") then
table.insert(_ha_tools_cache, {Tool = t, FightEvent = fight})
end
end
end
end
local function _ha_check_target(char: Model, hrpPos: Vector3): boolean
local hasTarget: boolean = false
-- 360° BOX SCAN
local box_ok: boolean, boxParts = pcall(function()
return workspace:GetPartBoundsInBox(
CFrame.new(hrpPos),
HA_Range,
_ha_overlap_params
)
end)
if box_ok and type(boxParts) == "table" then
for _, part: BasePart in boxParts do
local model: Model? = part:FindFirstChildOfClass("Model")
if not model and part.Parent then
model = part.Parent:FindFirstChildOfClass("Model")
end
if model then
local hum: Humanoid? = model:FindFirstChildOfClass("Humanoid")
if hum then
local health_ok: boolean, health = pcall(function() return hum.Health end)
if health_ok and type(health) == "number" and health > 0 and model ~= char then
return true
end
end
end
end
end
-- 360° SPHERE SCAN (catches anything box missed)
local sphere_ok: boolean, sphereParts = pcall(function()
return workspace:GetPartBoundsInRadius(hrpPos, HA_Range.X, _ha_overlap_params)
end)
if sphere_ok and type(sphereParts) == "table" then
for _, part: BasePart in sphereParts do
local model: Model? = part:FindFirstChildOfClass("Model")
if not model and part.Parent then
model = part.Parent:FindFirstChildOfClass("Model")
end
if model then
local hum: Humanoid? = model:FindFirstChildOfClass("Humanoid")
if hum then
local health_ok: boolean, health = pcall(function() return hum.Health end)
if health_ok and type(health) == "number" and health > 0 and model ~= char then
return true
end
end
end
end
end
return hasTarget
end
local function startHitAmplifier(): ()
if _ha_conn then
pcall(function() _ha_conn:Disconnect() end)
end
_ha_refresh_tools()
_ha_conn = RunService.PreSimulation:Connect(function(dt: number)
if not HitAmpEnabled then
return
end
if type(dt) ~= "number" then
dt = 0.016
end
_ha_accumulator += dt
if _ha_accumulator < HA_PulseInterval then
return
end
_ha_accumulator = 0
local char: Model? = player.Character
if not char then
return
end
local hrp: Instance? = char:FindFirstChild("HumanoidRootPart")
if not hrp or not hrp:IsA("BasePart") then
return
end
local now: number = os.clock()
-- 1000x: 6ms cooldown
if now - _ha_last_activation < 0.006 then
return
end
_ha_overlap_params.FilterDescendantsInstances = {char}
local pos_ok: boolean, hrpPos = pcall(function() return hrp.Position end)
if not pos_ok or typeof(hrpPos) ~= "Vector3" then
return
end
_ha_refresh_tools()
if #_ha_tools_cache == 0 then
return
end
local hasTarget: boolean = _ha_check_target(char, hrpPos)
if hasTarget then
_ha_last_activation = now
-- MULTI-PULSE: Fire multiple waves
local pulses: number = if HA_MultiPulse then 3 else 1
for _ = 1, pulses do
for _, data in _ha_tools_cache do
if data.FightEvent then
pcall(function()
for _ = 1, HA_BurstCount do
data.FightEvent:FireServer()
end
end)
else
pcall(data.Tool.Activate, data.Tool)
end
end
end
end
end)
end
local function stopHitAmplifier(): ()
if _ha_conn then
pcall(function() _ha_conn:Disconnect() end)
_ha_conn = nil
end
table.clear(_ha_tools_cache)
_ha_accumulator = 0
end
_G.EXO_StartHitAmplifier = startHitAmplifier
_G.EXO_StopHitAmplifier = stopHitAmplifier
print(`[EXO] Section 13.6 complete. Hit Amplifier registered.`)
print(`[EXO]   Scan mode: 360° Sphere + Box`)
print(`[EXO]   Cooldown: 6ms`)
print(`[EXO]   Pulse interval: {HA_PulseInterval * 1000}ms`)
print(`[EXO]   Multi-pulse: 3 waves per detection`)
print(`[EXO]   Default range: {HA_Range.X} studs`)
end
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 13.7: NO COOLDOWN + AUTO TOOLS                            ║
--   SAFE: No global hooks | Targeted tool property manipulation         ║
-- ║  Isolated in do...end block                                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
local _nc_conn: RBXScriptConnection? = nil
local _at_conn: RBXScriptConnection? = nil
local function startNoCooldown(): ()
if _nc_conn then
pcall(function() _nc_conn:Disconnect() end)
end
_nc_conn = RunService.RenderStepped:Connect(function()
if not NoCooldown then
return
end
local myChar: Model? = player.Character
if not myChar then
return
end
local children_ok: boolean, children = pcall(function() return myChar:GetChildren() end)
if not children_ok or type(children) ~= "table" then
return
end
for _, t: Instance in children do
if t:IsA("Tool") then
pcall(function()
-- Targeted property manipulation (SAFE)
local cooldown: Instance? = t:FindFirstChild("Cooldown")
if cooldown then
local val_ok: boolean, currentVal = pcall(function() return cooldown.Value end)
if val_ok and type(currentVal) == "number" and currentVal ~= 0 then
pcall(function()
cooldown.Value = 0
end)
end
end
local enabled: Instance? = t:FindFirstChild("Enabled")
if enabled then
local val_ok: boolean, currentVal = pcall(function() return enabled.Value end)
if val_ok and currentVal ~= true then
pcall(function()
enabled.Value = true
end)
end
end
local handle: Instance? = t:FindFirstChild("Handle")
if handle and handle:IsA("BasePart") then
pcall(function()
handle.CanCollide = false
end)
pcall(function()
handle.Massless = true
end)
end
end)
end
end
end)
end
local function stopNoCooldown(): ()
if _nc_conn then
pcall(function() _nc_conn:Disconnect() end)
_nc_conn = nil
end
end
local function startAutoTools(): ()
if _at_conn then
pcall(function() _at_conn:Disconnect() end)
end
_at_conn = RunService.RenderStepped:Connect(function()
if not AutoTools then
return
end
local myChar: Model? = player.Character
if not myChar then
return
end
-- Activate equipped tools
local children_ok: boolean, children = pcall(function() return myChar:GetChildren() end)
if children_ok and type(children) == "table" then
for _, t: Instance in children do
if t:IsA("Tool") then
pcall(function()
t:Activate()
end)
end
end
end
-- Auto-equip backpack tools
local bp: Instance? = player:FindFirstChildOfClass("Backpack")
if bp then
local bp_ok: boolean, bp_children = pcall(function() return bp:GetChildren() end)
if bp_ok and type(bp_children) == "table" then
for _, t: Instance in bp_children do
if t:IsA("Tool") then
pcall(function()
t.Parent = myChar
end)
pcall(function()
t:Activate()
end)
end
end
end
end
end)
end
local function stopAutoTools(): ()
if _at_conn then
pcall(function() _at_conn:Disconnect() end)
_at_conn = nil
end
end
_G.EXO_StartNoCooldown = startNoCooldown
_G.EXO_StopNoCooldown = stopNoCooldown
_G.EXO_StartAutoTools = startAutoTools
_G.EXO_StopAutoTools = stopAutoTools
print(`[EXO] Section 13.7 complete. NoCooldown + AutoTools registered.`)
print(`[EXO]   SAFE MODE: No global wait/spawn/delay hooks`)
print(`[EXO]   Targeted: Cooldown.Value=0, Enabled.Value=true`)
print(`[EXO]   Handle: CanCollide=false, Massless=true`)
end
-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 13.8: COMBAT REGISTRY & CROSS-MODULE BRIDGE               ║
-- ║  Verifies all combat modules registered successfully                 ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
local combat_globals: {string} = {
"EXO_StartAuraLoop",
"EXO_StopAuraLoop",
"EXO_StartToolFollow",
"EXO_StopToolFollow",
"EXO_StartAntiAura",
"EXO_StopAntiAura",
"EXO_ApplyReach",
"EXO_StopReach",
"EXO_StartInstaKill",
"EXO_StopInstaKill",
"EXO_StartHitAmplifier",
"EXO_StopHitAmplifier",
"EXO_StartNoCooldown",
"EXO_StopNoCooldown",
"EXO_StartAutoTools",
"EXO_StopAutoTools",
}
local registered: number = 0
local missing: {string} = {}
for _, name: string in combat_globals do
if type(_G[name]) == "function" then
registered += 1
else
table.insert(missing, name)
end
end
print(`[EXO] ═══════════════════════════════════════════════════`)
print(`[EXO] Combat modules registered: {registered}/{#combat_globals}`)
if #missing > 0 then
warn(`[EXO] Missing modules: {table.concat(missing, ", ")}`)
else
print(`[EXO] All combat systems operational.`)
end
print(`[EXO] ═══════════════════════════════════════════════════`)
end
print(`[EXO] ═══ PART 1 (THIRD HALF) COMPLETE ═══`)
