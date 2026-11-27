
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/oxireun/UiLibrary/refs/heads/main/2049.lua"))()

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Environment = (type(getgenv) == "function" and getgenv()) or _G

local ScriptToken = {}
Environment.OxireunAWolfOrOtherToken = ScriptToken

local function IsRunning()
    return Environment.OxireunAWolfOrOtherToken == ScriptToken
end

local Window = Library:NewWindow("A Wolf or Other")

Window:SetFooter("Dc: https://discord.gg/qgV6v9WcE9", 128337196312757, 1)

local MainSection = Window:NewSection("Main")
local CreditsSection = Window:NewSection("Credits")

local AutoCollectEnabled = false
local AutoProtectEnabled = false

MainSection:CreateToggle("Auto Collect", false, function(value)
    AutoCollectEnabled = value
end)

MainSection:CreateToggle("Auto Protect Me From Wolf", false, function(value)
    AutoProtectEnabled = value
end)

CreditsSection:CreateButton("Copy YouTube", function()
    setclipboard("https://youtube.com/@oxireunn?si=S0wXYpSBX3RAs2MB")
    Library:SendNotification("Copied!", "YouTube link copied to clipboard!", 2, 108320733835485, 1, "red")
end)

CreditsSection:CreateButton("Copy Discord", function()
    setclipboard("https://discord.gg/qgV6v9WcE9")
    Library:SendNotification("Copied!", "Discord invite copied to clipboard!", 2, 119731774091515, 1, "blue")
end)

local TELEPORT_INTERVAL = 0.1
local WOLF_DISTANCE = 15
local ESCAPE_HEIGHT = 20
local PICKUP_HEIGHT = 2.5
local PENDING_TIME = 1.5

local PICKUP_TAG = "HarvestPickup"

local Config = nil
local HarvestState = nil
local HarvestReady = false

local Ingredients = {}
local Pending = {}

local WolfLatched = false
local WolfDangerActive = false
local TeleportBusy = false

local SafePlatform = workspace:FindFirstChild("OxireunWolfSafePlatform", true)

if SafePlatform and not SafePlatform:IsA("BasePart") then
    SafePlatform = nil
end

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetRoot(character)
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("Torso")
        or character.PrimaryPart
end

local function PlaceSinglePlatform(position)

    if SafePlatform and SafePlatform.Parent then

        SafePlatform.CFrame = CFrame.new(
            position + Vector3.new(0, -3.5, 0)
        )

        return SafePlatform
    end

    local platform = Instance.new("Part")

    platform.Name = "OxireunWolfSafePlatform"
    platform.Size = Vector3.new(9, 0.8, 9)
    platform.Anchored = true
    platform.CanCollide = true
    platform.CanTouch = false
    platform.CanQuery = false
    platform.Transparency = 0.25
    platform.Material = Enum.Material.SmoothPlastic

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Brick
    mesh.Parent = platform

    platform.CFrame = CFrame.new(
        position + Vector3.new(0, -3.5, 0)
    )

    platform.Parent = workspace

    SafePlatform = platform

    return platform
end

local function FindWolf(root)

    if not root then
        return false
    end

    local myPosition = Vector3.new(
        root.Position.X,
        0,
        root.Position.Z
    )

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local character = player.Character

            if not character or not character.Parent then
                character = workspace:FindFirstChild(player.Name)
            end

            if character then

                local wolfTag = character:FindFirstChild("WolfTag", true)
                local wolfRoot = GetRoot(character)

                if wolfTag and wolfRoot then

                    local wolfPosition = Vector3.new(
                        wolfRoot.Position.X,
                        0,
                        wolfRoot.Position.Z
                    )

                    local distance = (
                        myPosition - wolfPosition
                    ).Magnitude

                    if distance <= WOLF_DISTANCE then
                        return true, player.Name
                    end
                end
            end
        end
    end

    return false
end

local function EscapeWolf()

    if TeleportBusy then
        return false
    end

    TeleportBusy = true

    local success = pcall(function()

        local character = GetCharacter()
        local root = GetRoot(character)

        if not root then
            error("Character unavailable")
        end

        local newPosition = root.Position + Vector3.new(
            0,
            ESCAPE_HEIGHT,
            0
        )

        local rotation = root.CFrame - root.Position

        root.CFrame = CFrame.new(newPosition) * rotation

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        PlaceSinglePlatform(root.Position)

    end)

    TeleportBusy = false

    return success
end

task.spawn(function()

    while IsRunning() do

        if AutoProtectEnabled then

            local character = GetCharacter()
            local root = GetRoot(character)

            if root then

                local nearby = FindWolf(root)

                WolfDangerActive = nearby

                if nearby then

                    if not WolfLatched then

                        local success = EscapeWolf()

                        if success then
                            WolfLatched = true
                        end

                    end

                else

                    WolfLatched = false

                end

            end

        else

            WolfDangerActive = false
            WolfLatched = false

        end

        task.wait(TELEPORT_INTERVAL)

    end

end)

task.spawn(function()

    local success, result = pcall(function()

        local shared = ReplicatedStorage:WaitForChild("SharedModules", 20)
        assert(shared)

        local configModule = shared:WaitForChild("HarvestConfig", 20)
        assert(configModule)

        return require(configModule)

    end)

    if not IsRunning() or not success then
        return
    end

    Config = result

    if type(Config.Ingredients) ~= "table" then
        return
    end

    PICKUP_TAG = Config.PickupTag or "HarvestPickup"

    for _, ingredient in ipairs(Config.Ingredients) do

        if ingredient.Id then
            table.insert(Ingredients, tostring(ingredient.Id))
        end

    end

    table.sort(Ingredients, function(a, b)
        return #a > #b
    end)

    local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 20)

    if not playerScripts then
        return
    end

    local StateModule

    for i = 1, 100 do

        if not IsRunning() then
            return
        end

        StateModule = playerScripts:FindFirstChild("HarvestState", true)

        if StateModule and StateModule:IsA("ModuleScript") then
            break
        end

        task.wait(0.1)

    end

    if not StateModule then
        return
    end

    local stateSuccess, stateResult = pcall(require, StateModule)

    if not stateSuccess or type(stateResult.Get) ~= "function" then
        return
    end

    HarvestState = stateResult

    local deadline = os.clock() + 30

    repeat

        if not IsRunning() then
            return
        end

        local ok, state = pcall(function()
            return HarvestState.Get()
        end)

        if ok and type(state) == "table" then

            if state.Loaded == true
            or (
                type(state.Carried) == "table"
                and type(state.Collected) == "table"
            ) then

                HarvestReady = true
                break

            end

        end

        task.wait(0.2)

    until os.clock() >= deadline

end)

local function MatchIngredient(value)

    if type(value) ~= "string" then
        return nil
    end

    local normalized = value:lower():gsub("[^%w]", "")

    if normalized == "" then
        return nil
    end

    for _, id in ipairs(Ingredients) do

        local target = id:lower():gsub("[^%w]", "")

        if normalized == target
        or normalized:find(target, 1, true) then

            return id

        end

    end

    return nil
end

local AttributeNames = {
    "Ingredient",
    "IngredientId",
    "Food",
    "Item",
    "Id",
    "Type"
}

local function GetIngredient(model)

    if not model then
        return nil
    end

    for _, key in ipairs(AttributeNames) do

        local id = MatchIngredient(model:GetAttribute(key))

        if id then
            return id
        end

    end

    for _, object in ipairs(model:GetDescendants()) do

        local id = MatchIngredient(object.Name)

        if id then
            return id
        end

        for _, key in ipairs(AttributeNames) do

            local attributeId = MatchIngredient(
                object:GetAttribute(key)
            )

            if attributeId then
                return attributeId
            end

        end

        if object:IsA("StringValue") then

            local valueId = MatchIngredient(object.Value)

            if valueId then
                return valueId
            end

        end

    end

    return MatchIngredient(model.Name)

end

local function GetInventory()

    if not HarvestState then
        return {}, {}
    end

    local ok, state = pcall(function()
        return HarvestState.Get()
    end)

    if not ok or type(state) ~= "table" then
        return {}, {}
    end

    return state.Carried or {}, state.Collected or {}

end

local function ContainsIngredient(tbl, id)

    if type(tbl) ~= "table" then
        return false
    end

    local direct = tbl[id]

    if direct ~= nil and direct ~= false and direct ~= 0 then
        return true
    end

    for key, value in pairs(tbl) do

        if tostring(key) == tostring(id) then

            if value ~= false and value ~= 0 then
                return true
            end

        end

        if value == id then
            return true
        end

        if type(value) == "string" then

            if MatchIngredient(value) == id then
                return true
            end

        elseif type(value) == "table" then

            local itemId =
                value.Id
                or value.IngredientId
                or value.Ingredient
                or value.Name

            if MatchIngredient(itemId) == id then
                return true
            end

        end

    end

    return false

end

local function AlreadyHave(id)

    local carried, collected = GetInventory()

    return ContainsIngredient(carried, id)
        or ContainsIngredient(collected, id)

end

local function GetPickups()

    local found = {}

    local function Add(object)

        if not object or not object:IsDescendantOf(workspace) then
            return
        end

        local model

        if object:IsA("Model") then

            model = object

        elseif object:IsA("BasePart") then

            model = object:FindFirstAncestorOfClass("Model") or object

        end

        if model then
            found[model] = true
        end

    end

    for _, object in ipairs(CollectionService:GetTagged(PICKUP_TAG)) do
        Add(object)
    end

    local folder = workspace:FindFirstChild("HarvestPickups")

    if folder then

        for _, object in ipairs(folder:GetDescendants()) do

            if object:IsA("Model") or object:IsA("BasePart") then
                Add(object)
            end

        end
    end

    return found

end

local function GetPickupPosition(object)

    if not object or not object.Parent then
        return nil
    end

    if object:IsA("Model") then
        return object:GetPivot().Position

    elseif object:IsA("BasePart") then
        return object.Position

    end

    return nil

end

task.spawn(function()

    while IsRunning() do

        if AutoCollectEnabled and HarvestReady then

            local character = GetCharacter()
            local root = GetRoot(character)

            if root and not (AutoProtectEnabled and WolfDangerActive) then

                local pickups = GetPickups()
                local targets = {}

                for object in pairs(pickups) do

                    if object.Parent then

                        local id = GetIngredient(object)

                        if id and not AlreadyHave(id) then

                            local position = GetPickupPosition(object)

                            if position then

                                local expiry = Pending[id]

                                if not expiry or expiry <= os.clock() then

                                    table.insert(targets, {
                                        Model = object,
                                        Id = id,
                                        Position = position,
                                        Distance = (position - root.Position).Magnitude
                                    })

                                end

                            end
                        end
                    end
                end

                table.sort(targets, function(a, b)
                    return a.Distance < b.Distance
                end)

                for _, target in ipairs(targets) do

                    if not IsRunning() or not AutoCollectEnabled then
                        break
                    end

                    if AutoProtectEnabled then

                        local currentCharacter = GetCharacter()
                        local currentRoot = GetRoot(currentCharacter)

                        if currentRoot then

                            local danger = FindWolf(currentRoot)

                            if danger then
                                WolfDangerActive = true
                                break
                            end

                        end
                    end

                    if TeleportBusy then
                        break
                    end

                    character = GetCharacter()
                    root = GetRoot(character)

                    if not root then
                        break
                    end

                    local object = target.Model
                    local id = target.Id

                    if object.Parent and not AlreadyHave(id) then

                        local expiry = Pending[id]

                        if not expiry or expiry <= os.clock() then

                            local position = GetPickupPosition(object)

                            if position then

                                TeleportBusy = true

                                local success = pcall(function()

                                    local rotation = root.CFrame - root.Position

                                    root.CFrame = CFrame.new(
                                        position + Vector3.new(0, PICKUP_HEIGHT, 0)
                                    ) * rotation

                                    root.AssemblyLinearVelocity = Vector3.zero
                                    root.AssemblyAngularVelocity = Vector3.zero

                                end)

                                TeleportBusy = false

                                if success then
                                    Pending[id] = os.clock() + PENDING_TIME
                                end

                                task.wait(TELEPORT_INTERVAL)

                            end
                        end
                    end
                end
            end
        end

        task.wait(TELEPORT_INTERVAL)

    end

end)
