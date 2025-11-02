-- Voidware Rivals | Ultimate Edition
-- Auto ON | Mobile & PC | No Key

repeat task.wait() until game:IsLoaded()

-- === 서비스 ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- === 게임 확인 ===
local RIVALS_PLACE_ID = 18164378524
local gameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
local isRivals = (game.PlaceId == RIVALS_PLACE_ID) or string.find(string.lower(gameInfo.Name), "rivals") ~= nil

if not isRivals then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Voidware",
        Text = "Rivals 전용 스크립트입니다.",
        Duration = 6
    })
    return
end

-- === GUI 생성 ===
local VapeGui = Instance.new("ScreenGui")
VapeGui.Name = "VoidwareRivals"
VapeGui.ResetOnSpawn = false
VapeGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
VapeGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(600, 450)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false  -- 시작은 숨김
MainFrame.Parent = VapeGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 170, 255)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- 제목
local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromScale(1, 0.12)
Title.BackgroundTransparency = 1
Title.Text = "Voidware Rivals | Ultimate"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 26
Title.Parent = MainFrame

-- 드래그
local dragging, dragInput, dragStart, startPos
local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

Title.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- === 설정 ===
local Settings = {
    Aimbot = true,
    ESP = true,
    GodMode = true,
    NoRecoil = true,
    Fly = false,
    FlySpeed = 100,
    WalkSpeed = 100,
    JumpPower = 100,
    InfiniteJump = true,
    FOV = 120,
    FOVVisible = true
}

-- === FOV 원 (시각화) ===
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 30
FOVCircle.Radius = Settings.FOV
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = Settings.FOVVisible

RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.FOVVisible and Settings.Aimbot
end)

-- === 유틸 함수 ===
local function getClosestPlayer()
    local closest, dist = nil, math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid").Health > 0 then
            local hrp = plr.Character.HumanoidRootPart
            local d = (hrp.Position - root.Position).Magnitude
            if d < dist then
                closest, dist = plr, d
            end
        end
    end
    return closest
end

local function getAimTarget()
    local target = getClosestPlayer()
    if not target or not target.Character then return nil end
    local head = target.Character:FindFirstChild("Head")
    if not head then return nil end

    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
    if not onScreen then return nil end

    local mousePos = UserInputService:GetMouseLocation()
    local distance = (Vector2.new(mousePos.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
    if distance > Settings.FOV then return nil end

    return head
end

-- === Fly 시스템 ===
local FlyBody = nil
local function startFly()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    FlyBody = Instance.new("BodyVelocity")
    FlyBody.Velocity = Vector3.new(0, 0, 0)
    FlyBody.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    FlyBody.Parent = hrp
end

local function stopFly()
    if FlyBody then FlyBody:Destroy() FlyBody = nil end
end

local function updateFly()
    if not Settings.Fly or not FlyBody then return end
    local cam = Camera.CFrame
    local move = Vector3.new()
    local speed = Settings.FlySpeed

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end

    FlyBody.Velocity = move.Unit * speed
end

-- === GUI 요소 생성 ===
local function createSlider(name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 0.08)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(0.4, 1)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.fromScale(0.55, 0.8)
    slider.Position = UDim2.fromScale(0.4, 0.1)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    slider.Text = ""
    slider.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale((default - min) / (max - min), 1)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.Parent = slider

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X
            local sliderPos = slider.AbsolutePosition.X
            local sliderSize = slider.AbsoluteSize.X
            local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local value = math.floor(min + percent * (max - min))
            fill.Size = UDim2.fromScale(percent, 1)
            label.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

-- 슬라이더 추가
createSlider("FOV", 50, 300, 120, function(v) Settings.FOV = v end)
createSlider("Fly Speed", 50, 300, 100, function(v) Settings.FlySpeed = v end)
createSlider("WalkSpeed", 16, 300, 100, function(v) Settings.WalkSpeed = v end)
createSlider("JumpPower", 50, 300, 100, function(v) Settings.JumpPower = v end)

-- === 메인 루프 ===
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    -- God Mode
    if Settings.GodMode then
        humanoid.Health = humanoid.MaxHealth
    end

    -- WalkSpeed & JumpPower
    humanoid.WalkSpeed = Settings.WalkSpeed
    humanoid.JumpPower = Settings.JumpPower

    -- No Recoil
    if Settings.NoRecoil then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                tool.Handle.Velocity = Vector3.new()
                tool.Handle.RotVelocity = Vector3.new()
            end
        end
    end

    -- Aimbot
    if Settings.Aimbot then
        local target = getAimTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- Fly 업데이트
    updateFly()
end)

-- === 키 입력 ===
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.F then
        Settings.Fly = not Settings.Fly
        if Settings.Fly then startFly() else stopFly() end
    elseif input.KeyCode == Enum.KeyCode.Space and Settings.InfiniteJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- === ESP 루프 ===
spawn(function()
    while task.wait(0.5) do
        if not Settings.ESP then continue end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local esp = head:FindFirstChild("RivalsESP") or Instance.new("BillboardGui", head)
                esp.Name = "RivalsESP"
                esp.Size = UDim2.fromOffset(120, 60)
                esp.StudsOffset = Vector3.new(0, 3.5, 0)
                esp.AlwaysOnTop = true

                local label = esp:FindFirstChild("Label") or Instance.new("TextLabel", esp)
                label.Size = UDim2.fromScale(1, 1)
                label.BackgroundTransparency = 1
                label.Text = plr.Name .. " [" .. math.floor((plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                label.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.GothamBold
                label.TextSize = 16
            end
        end
    end
end)

-- === 알림 ===
game.StarterGui:SetCore("SendNotification", {
    Title = "Voidware Rivals",
    Text = "Insert로 GUI 토글 | F로 Fly | 모든 기능 자동 ON!",
    Duration = 10
})

print("[Voidware Rivals] Ultimate Loaded!")
