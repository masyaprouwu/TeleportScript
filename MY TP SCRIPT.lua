local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Функция для создания интерфейса
local function createGUI()
    -- Удаляем старый GUI, если он существует
    if player.PlayerGui:FindFirstChild("TeleportGUI") then
        player.PlayerGui.TeleportGUI:Destroy()
    end

    -- Создаем новый GUI
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "TeleportGUI"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0.2, 0, 0.8, 0) -- Ширина 20%, высота 80%
    frame.Position = UDim2.new(0.8, 0, 0.1, 0) -- Правый край экрана, немного отступ сверху
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.AnchorPoint = Vector2.new(0, 0) -- Закрепляем в правом верхнем углу

    -- Верхняя панель для перемещения и кнопка сворачивания
    local dragBar = Instance.new("Frame", frame)
    dragBar.Size = UDim2.new(1, 0, 0.1, 0) -- 10% высоты фрейма (в 2 раза выше)
    dragBar.Position = UDim2.new(0, 0, 0, 0)
    dragBar.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    dragBar.Active = true
    dragBar.Draggable = false -- Отключаем стандартное перетаскивание

    -- Кнопка сворачивания (вытянута вверх в 2 раза)
    local toggleButton = Instance.new("TextButton", dragBar)
    toggleButton.Size = UDim2.new(0.1, 0, 1, 0) -- 10% ширины панели, высота 100%
    toggleButton.Position = UDim2.new(0.9, 0, 0, 0)
    toggleButton.Text = "-"
    toggleButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    toggleButton.TextScaled = true

    -- Список игроков
    local playerList = Instance.new("ScrollingFrame", frame)
    playerList.Size = UDim2.new(0.9, 0, 0.7, 0) -- Уменьшаем высоту, чтобы учесть увеличенную панель и текстовое поле
    playerList.Position = UDim2.new(0.05, 0, 0.1, 0) -- Сдвигаем вниз из-за увеличенной панели
    playerList.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Автоматически увеличивается при добавлении игроков
    playerList.ScrollBarThickness = 8 -- Толщина полосы прокрутки

    -- Текстовое поле для ввода ника
    local textBox = Instance.new("TextBox", frame)
    textBox.Size = UDim2.new(0.9, 0, 0.05, 0)
    textBox.Position = UDim2.new(0.05, 0, 0.85, 0)
    textBox.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    textBox.TextColor3 = Color3.new(1, 1, 1)
    textBox.PlaceholderText = "Введите ник"
    textBox.TextScaled = true

    -- Кнопка "Отправить"
    local sendButton = Instance.new("TextButton", frame)
    sendButton.Size = UDim2.new(0.9, 0, 0.05, 0)
    sendButton.Position = UDim2.new(0.05, 0, 0.91, 0)
    sendButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    sendButton.TextColor3 = Color3.new(1, 1, 1)
    sendButton.Text = "Отправить"
    sendButton.TextScaled = true

    -- Переменные для перетаскивания
    local dragging = false
    local dragStartPos
    local frameStartPos

    -- Переменная для состояния сворачивания
    local isCollapsed = false

    -- Функция для сворачивания/разворачивания таблицы
    local function toggleCollapse()
        isCollapsed = not isCollapsed
        if isCollapsed then
            playerList.Visible = false
            textBox.Visible = false
            sendButton.Visible = false
            frame.Size = UDim2.new(0.2, 0, 0.1, 0) -- Размер фрейма уменьшается до размера верхней панели
            toggleButton.Text = "+"
        else
            playerList.Visible = true
            textBox.Visible = true
            sendButton.Visible = true
            frame.Size = UDim2.new(0.2, 0, 0.8, 0) -- Возвращаем исходный размер фрейма
            toggleButton.Text = "-"
        end
    end

    -- Обработчик нажатия на кнопку сворачивания
    toggleButton.MouseButton1Click:Connect(toggleCollapse)

    -- Обработчик нажатия на верхнюю панель
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
            frameStartPos = frame.Position
        end
    end)

    -- Обработчик перемещения мыши
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local dragDelta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
            frame.Position = UDim2.new(frameStartPos.X.Scale, frameStartPos.X.Offset + dragDelta.X, frameStartPos.Y.Scale, frameStartPos.Y.Offset + dragDelta.Y)
        end
    end)

    -- Обработчик отпускания кнопки мыши
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Функция для обновления списка игроков
    local function updatePlayerList()
        playerList:ClearAllChildren()
        local playerCount = 0

        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                playerCount = playerCount + 1

                local playerButton = Instance.new("TextButton", playerList)
                playerButton.Size = UDim2.new(0.9, 0, 0.1, 0)
                playerButton.Position = UDim2.new(0.05, 0, 0.1 * (playerCount - 1), 0)
                playerButton.Text = otherPlayer.Name
                playerButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
                playerButton.TextScaled = true

                -- Обработчик нажатия на ник игрока
                playerButton.MouseButton1Click:Connect(function()
                    local targetPlayer = otherPlayer
                    local targetCharacter = targetPlayer.Character
                    local myCharacter = player.Character

                    if targetCharacter and myCharacter then
                        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                        local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")

                        if targetRoot and myRoot then
                            -- Телепортируемся к игроку
                            myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 5, 0) -- Немного выше, чтобы не застрять
                        end
                    end
                end)
            end
        end

        -- Обновляем размер CanvasSize для ScrollingFrame
        playerList.CanvasSize = UDim2.new(0, 0, 0.1 * playerCount, 0)
    end

    -- Функция для телепортации к игроку по нику
    local function teleportToPlayerByName(name)
        local targetPlayer = Players:FindFirstChild(name)
        if targetPlayer then
            local targetCharacter = targetPlayer.Character
            local myCharacter = player.Character

            if targetCharacter and myCharacter then
                local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")

                if targetRoot and myRoot then
                    -- Телепортируемся к игроку
                    myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 5, 0) -- Немного выше, чтобы не застрять
                    print("Телепортирован к игроку: " .. name)
                end
            end
        else
            print("Игрок с ником " .. name .. " не найден!")
        end
    end

    -- Обработчик нажатия на кнопку "Отправить"
    sendButton.MouseButton1Click:Connect(function()
        local playerName = textBox.Text
        if playerName ~= "" then
            teleportToPlayerByName(playerName)
        end
    end)

    -- Обновляем список игроков при запуске
    updatePlayerList()

    -- Обновляем список игроков при подключении нового игрока
    Players.PlayerAdded:Connect(updatePlayerList)

    -- Обновляем список игроков при отключении игрока
    Players.PlayerRemoving:Connect(updatePlayerList)
end

-- Функция для перезапуска GUI после смерти
local function handleDeath()
    player.CharacterAdded:Wait() -- Ждём, пока персонаж появится
    createGUI() -- Создаём GUI заново
end

-- Создаём GUI при запуске
createGUI()

-- Отслеживаем смерть игрока
player.CharacterAdded:Connect(handleDeath)
player.CharacterRemoving:Connect(function()
    -- Удаляем старый GUI при смерти
    if player.PlayerGui:FindFirstChild("TeleportGUI") then
        player.PlayerGui.TeleportGUI:Destroy()
    end
end)