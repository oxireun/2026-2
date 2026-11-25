
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local StartCFrame = CFrame.new(
    -234.481323, 13.2305183, -442.051086,
    0.846630275, 3.61271701e-09, 0.532181501,
    -7.41305772e-09, 1, 5.00468733e-09,
    -0.532181501, -8.18221224e-09, 0.846630275
)

local ClaimCFrame = CFrame.new(
    -163.213409, 11.0149536, -588.380127,
    0.853993535, 1.13863159e-08, -0.52028358,
    3.0461031e-08, 1, 7.18835693e-08,
    0.52028358, -7.72364785e-08, 0.853993535
)

local AutoObbyRunning = false

local function GetCharacter()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        or Character:WaitForChild("Humanoid")
    local Root = Character:FindFirstChild("HumanoidRootPart")
        or Character:WaitForChild("HumanoidRootPart")

    return Character, Humanoid, Root
end

local function Teleport(Target)
    local Character, Humanoid, Root = GetCharacter()

    Root.AssemblyLinearVelocity = Vector3.zero
    Root.AssemblyAngularVelocity = Vector3.zero
    Root.CFrame = Target
end

local function FindObby(ActiveObby)
    for _, Tag in ipairs({"%ObbyReveal", "ObbyReveal"}) do
        local Success, Objects = pcall(function()
            return CollectionService:GetTagged(Tag)
        end)

        if Success then
            for _, Object in ipairs(Objects) do
                if Object:IsDescendantOf(workspace)
                    and (Object:GetAttribute("Obby") or "Obby") == ActiveObby then
                    return Object
                end
            end
        end
    end
end

local function GetParts(Object)
    local Parts = {}

    if Object:IsA("BasePart") then
        table.insert(Parts, Object)
    end

    for _, Descendant in ipairs(Object:GetDescendants()) do
        if Descendant:IsA("BasePart") then
            table.insert(Parts, Descendant)
        end
    end

    return Parts
end

local function GetPieceData(Object)
    local Parts = GetParts(Object)

    if #Parts == 0 then
        return nil
    end

    local BestPart
    local HighestY = -math.huge
    local BestVolume = -math.huge

    for _, Part in ipairs(Parts) do
        if Part.Parent
            and Part.CanCollide
            and Part.LocalTransparencyModifier < 0.99 then

            local TopPosition = Part.CFrame:PointToWorldSpace(
                Vector3.new(0, Part.Size.Y / 2, 0)
            )

            local Volume = Part.Size.X * Part.Size.Z

            if TopPosition.Y > HighestY
                or (TopPosition.Y == HighestY and Volume > BestVolume) then

                HighestY = TopPosition.Y
                BestVolume = Volume
                BestPart = Part
            end
        end
    end

    if not BestPart then
        return nil
    end

    return {
        Object = Object,
        Parts = Parts,
        LandingPart = BestPart,
        TopPosition = BestPart.CFrame:PointToWorldSpace(
            Vector3.new(0, BestPart.Size.Y / 2, 0)
        )
    }
end

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude
RayParams.RespectCanCollide = true

local function IsLandedOnPiece(Data)
    local Character, Humanoid, Root = GetCharacter()

    RayParams.FilterDescendantsInstances = {Character}

    local Distance = Humanoid.HipHeight + Root.Size.Y / 2 + 6

    local Result = workspace:Raycast(
        Root.Position,
        Vector3.new(0, -Distance, 0),
        RayParams
    )

    if not Result then
        return false
    end

    return Result.Instance == Data.Object
        or Result.Instance:IsDescendantOf(Data.Object)
end

local function MoveToPiece(Data)
    local Character, Humanoid, Root = GetCharacter()

    local Part = Data.LandingPart

    if not Part or not Part.Parent then
        return false
    end

    local TargetPosition = Data.TopPosition + Vector3.new(
        0,
        Humanoid.HipHeight + Root.Size.Y / 2 + 0.12,
        0
    )

    local Rotation = Root.CFrame - Root.Position

    Root.AssemblyLinearVelocity = Vector3.zero
    Root.AssemblyAngularVelocity = Vector3.zero

    Root.CFrame = CFrame.new(TargetPosition) * Rotation

    return true
end

local function GetNextPiece(Obby, Processed)
    local BestObject
    local BestOrder = math.huge

    for _, Object in ipairs(Obby:GetChildren()) do
        if not Processed[Object] then
            local Order = Object:GetAttribute("Order")

            if typeof(Order) == "number" and Order < BestOrder then
                BestObject = Object
                BestOrder = Order
            end
        end
    end

    return BestObject
end

local function ProcessPiece(Object, ActiveObby)
    local RevealDeadline = os.clock() + 15
    local Data

    repeat
        if Player:GetAttribute("ObbyRun") ~= ActiveObby then
            return false
        end

        if not Object.Parent then
            return false
        end

        Data = GetPieceData(Object)

        if Data then
            break
        end

        RunService.Heartbeat:Wait()
    until os.clock() >= RevealDeadline

    if not Data then
        return false
    end

    for Attempt = 1, 3 do
        if Player:GetAttribute("ObbyRun") ~= ActiveObby then
            return false
        end

        Data = GetPieceData(Object)

        if not Data then
            return false
        end

        if not MoveToPiece(Data) then
            return false
        end

        local LandingDeadline = os.clock() + 4

        repeat
            RunService.Heartbeat:Wait()

            if IsLandedOnPiece(Data) then
                task.wait(0.35)
                return true
            end
        until os.clock() >= LandingDeadline
    end

    return false
end

local function RunAutoObby()
    Teleport(StartCFrame)

    local ActiveObby
    local StartDeadline = os.clock() + 20

    repeat
        ActiveObby = Player:GetAttribute("ObbyRun")

        if ActiveObby ~= nil then
            break
        end

        task.wait(0.1)
    until os.clock() >= StartDeadline

    if ActiveObby == nil then
        return
    end

    local Obby
    local FindDeadline = os.clock() + 15

    repeat
        Obby = FindObby(ActiveObby)

        if Obby then
            break
        end

        task.wait(0.15)
    until os.clock() >= FindDeadline

    if not Obby then
        return
    end

    local Processed = {}
    local MissingDeadline = os.clock() + 20

    while Player:GetAttribute("ObbyRun") == ActiveObby do
        if Player:GetAttribute("CompletedObby") == true then
            break
        end

        local Object = GetNextPiece(Obby, Processed)

        if not Object then
            if os.clock() >= MissingDeadline then
                break
            end

            task.wait(0.15)
        else
            MissingDeadline = os.clock() + 20

            local Success = ProcessPiece(Object, ActiveObby)

            if not Success then
                break
            end

            Processed[Object] = true

            RunService.Heartbeat:Wait()
            task.wait(0.2)
        end
    end
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/oxireun/UiLibrary/refs/heads/main/2049.lua"))()

local Window = Library:NewWindow("Script")

Window:SetFooter("Dc: https://discord.gg/qgV6v9WcE9", 128337196312757, 1)

local MainSection = Window:NewSection("Main")

MainSection:CreateButton("Auto obby", function()
    if AutoObbyRunning then
        return
    end

    AutoObbyRunning = true

    task.spawn(function()
        pcall(RunAutoObby)
        AutoObbyRunning = false
    end)
end)

MainSection:CreateButton("Claim UGC", function()
    task.spawn(function()
        pcall(function()
            Teleport(ClaimCFrame)
        end)
    end)
end)

local MainSection = Window:NewSection("Credits")

MainSection:CreateButton("Copy YouTube", function()
    setclipboard("https://youtube.com/@oxireunn?si=S0wXYpSBX3RAs2MB")
    Library:SendNotification("Copied!", "YouTube link copied to clipboard!", 2, 108320733835485, 1, "red")
end)

MainSection:CreateButton("Copy Discord", function()
    setclipboard("https://discord.gg/qgV6v9WcE9")
    Library:SendNotification("Copied!", "Discord invite copied to clipboard!", 2, 119731774091515, 1, "blue")
end)
