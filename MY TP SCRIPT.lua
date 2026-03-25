-- Создаем GUI, если его нет вручную
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Создаем основной ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "SuperFlingGUI"
gui.Parent = player:WaitForChild("PlayerGui")

-- Создаем каркас для передвигаемого окна
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.5, -75) -- Центр экрана
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true -- Чтобы можно было перетаскивать
frame.Draggable = true -- Включаем возможность перетаскивания
frame.Parent = gui

-- Заголовок окна (для красоты)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
title.Text = "Anti-Cheat System"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

-- Кнопка флинга
local flingButton = Instance.new("TextButton")
flingButton.Size = UDim2.new(0.8, 0, 0, 40)
flingButton.Position = UDim2.new(0.1, 0, 0.4, 0)
flingButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
flingButton.Text = "PUNISH CHEATER"
flingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flingButton.Font = Enum.Font.GothamBold
flingButton.TextSize = 18
flingButton.Parent = frame

-- Текст состояния
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0.8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready to punish cheaters"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

-- Определяем цель: это тот, у кого открыто GUI (текущий игрок)
local targetPlayer = player -- GUI открыт у текущего игрока, значит и применяем к нему

local isFlinging = false
local flingConnection = nil
local autoKickTimer = nil

-- Функция для эффекта "телепортация + вращение"
local function startFling(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        statusLabel.Text = "Error: Character not found!"
        return false
    end
    
    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = target.Character.HumanoidRootPart
    
    if not humanoid or not rootPart then
        statusLabel.Text = "Error: Body parts not found!"
        return false
    end
    
    -- Отключаем гравитацию и делаем его неуязвимым для падения
    humanoid.PlatformStand = true
    
    -- Запускаем цикл телепортации каждый кадр
    local teleportCount = 0
    flingConnection = game:GetService("RunService").Stepped:Connect(function()
        if not isFlinging or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local currentRootPart = target.Character.HumanoidRootPart
        
        -- Генерируем случайные координаты вокруг текущей позиции
        local randomX = math.random(-150, 150)
        local randomZ = math.random(-150, 150)
        local randomY = math.random(20, 150)
        
        local newPos = currentRootPart.Position + Vector3.new(randomX, randomY, randomZ)
        
        -- Телепортируем
        currentRootPart.CFrame = CFrame.new(newPos)
        
        -- Вращаем его случайным образом
        local randomAngleY = math.random(0, 360)
        local randomAngleX = math.random(-60, 60)
        currentRootPart.CFrame = currentRootPart.CFrame * CFrame.Angles(math.rad(randomAngleX), math.rad(randomAngleY), 0)
        
        -- Добавляем скорость для эффекта "вылета"
        currentRootPart.Velocity = Vector3.new(math.random(-150, 150), math.random(50, 200), math.random(-150, 150))
        
        teleportCount = teleportCount + 1
        statusLabel.Text = "Punishment active: " .. teleportCount .. " teleports"
    end)
    
    statusLabel.Text = "Punishment started! Kick in 2 seconds..."
    return true
end

-- Функция для кика с английским сообщением о бане
local function kickPlayer(target)
    if target and target:IsA("Player") and target.Parent then
        -- Создаем сообщение о перманентном бане за читы
        local kickMessage = "You have been permanently banned for cheating/hacking. (Reason: Unauthorized third-party software detected.)"
        
        -- Кикаем игрока
        target:Kick(kickMessage)
        
        statusLabel.Text = "Player kicked for cheating!"
        return true
    end
    return false
end

-- Функция остановки флинга
local function stopFling()
    isFlinging = false
    
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
    
    if autoKickTimer then
        autoKickTimer:Disconnect()
        autoKickTimer = nil
    end
end

-- Обработчик кнопки
flingButton.MouseButton1Click:Connect(function()
    if isFlinging then
        -- Если уже флингует, то просто останавливаем (без кика)
        stopFling()
        
        flingButton.Text = "PUNISH CHEATER"
        flingButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        statusLabel.Text = "Punishment stopped"
    else
        -- Запускаем флинг на текущем игроке
        if not targetPlayer.Character then
            statusLabel.Text = "Error: No character found!"
            return
        end
        
        isFlinging = true
        local success = startFling(targetPlayer)
        
        if not success then
            isFlinging = false
            return
        end
        
        flingButton.Text = "STOP"
        flingButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        
        -- Автоматически кикнуть через 2 секунды
        autoKickTimer = game:GetService("RunService").Stepped:Connect(function()
            if autoKickTimer and isFlinging then
                -- Ждем 2 секунды
                wait(2)
                if isFlinging then
                    stopFling()
                    kickPlayer(targetPlayer)
                    flingButton.Text = "PUNISH CHEATER"
                    flingButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
                end
                if autoKickTimer then
                    autoKickTimer:Disconnect()
                    autoKickTimer = nil
                end
            end
        end)
    end
end)

-- Добавляем кнопку закрытия (опционально)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = frame

closeButton.MouseButton1Click:Connect(function()
    if isFlinging then
        stopFling()
    end
    gui:Destroy()
end)
