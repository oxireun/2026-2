local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/oxireun/UiLibrary/refs/heads/main/2049.lua"))()

local Window = Library:NewWindow("Script")
Window:SetFooter("Dc: https://discord.gg/qgV6v9WcE9", 128337196312757, 1)

local MainSection = Window:NewSection("Main")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local SPEED = 20
local DIST = 1.25
local AutoFarm = false
local farmToken = 0
local targets = {}
local visited = {}

local function addTarget(obj)
    if obj:IsA("BasePart") and obj.Name == "CoinGiver" then
        targets[obj] = true
    end
end

for _, obj in ipairs(workspace:GetDescendants()) do
    addTarget(obj)
end

workspace.DescendantAdded:Connect(addTarget)

workspace.DescendantRemoving:Connect(function(obj)
    targets[obj] = nil
    visited[obj] = nil
end)

MainSection:CreateToggle("Auto farm", false, function(value)
    AutoFarm = value
    farmToken += 1
    local token = farmToken

    if not value then return end

    task.spawn(function()
        local character, hrp, fly
        local collisions = {}
        local direction = Vector3.new(0, 0, -1)

        local function cleanup()
            for part, old in pairs(collisions) do
                if part.Parent then
                    part.CanCollide = old
                end
            end
            table.clear(collisions)

            if fly then fly:Destroy() fly = nil end
        end

        while AutoFarm and farmToken == token do
            character = player.Character
            hrp = character and character:FindFirstChild("HumanoidRootPart")

            if hrp then
                if not fly or fly.Parent ~= hrp then
                    cleanup()
                    direction = hrp.CFrame.LookVector

                    fly = Instance.new("BodyVelocity")
                    fly.Name = "OxireunFly"
                    fly.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    fly.P = 30000
                    fly.Parent = hrp
                end

                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if collisions[part] == nil then
                            collisions[part] = part.CanCollide
                        end
                        part.CanCollide = false
                    end
                end

                local nearest, distance = nil, math.huge

                for obj in pairs(targets) do
                    if obj.Parent and not visited[obj] then
                        local d = (obj.Position - hrp.Position).Magnitude
                        if d < distance then
                            nearest, distance = obj, d
                        end
                    end
                end

                if not nearest then
                    table.clear(visited)

                    for obj in pairs(targets) do
                        if obj.Parent then
                            local d = (obj.Position - hrp.Position).Magnitude
                            if d < distance then
                                nearest, distance = obj, d
                            end
                        end
                    end
                end

                if nearest then
                    local delta = nearest.Position - hrp.Position

                    if delta.Magnitude <= DIST then
                        visited[nearest] = true
                    elseif delta.Magnitude > 0 then
                        direction = delta.Unit
                    end
                end

                fly.Velocity = direction * SPEED
            end

            RunService.Heartbeat:Wait()
        end

        cleanup()
    end)
end)

local CreditsSection = Window:NewSection("Credits")

CreditsSection:CreateButton("Copy YouTube", function()
    setclipboard("https://youtube.com/@oxireunn?si=S0wXYpSBX3RAs2MB")
    Library:SendNotification("Copied!", "YouTube link copied to clipboard!", 2, 108320733835485, 1, "red")
end)

CreditsSection:CreateButton("Copy Discord", function()
    setclipboard("https://discord.gg/qgV6v9WcE9")
    Library:SendNotification("Copied!", "Discord invite copied to clipboard!", 2, 119731774091515, 1, "blue")
end)
