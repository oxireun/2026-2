local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/oxireun/UiLibrary/refs/heads/main/2049.lua"))()

local Window = Library:NewWindow("Script")

Window:SetFooter("Dc: https://discord.gg/qgV6v9WcE9", 128337196312757, 1)

local MainSection = Window:NewSection("Main")

MainSection:CreateButton("Collect", function()
    local Folder = workspace:FindFirstChild("UGCEventCollectibles")

    if not Folder then
        Library:SendNotification("Error!", "UGCEventCollectibles folder not found!", 3, 108320733835485, 1, "red")
        return
    end

    if type(fireproximityprompt) ~= "function" then
        Library:SendNotification("Error!", "fireproximityprompt is not supported!", 3, 108320733835485, 1, "red")
        return
    end

    local Collected = 0
    local Character = game.Players.LocalPlayer.Character

    for _, Model in ipairs(Folder:GetChildren()) do
        if not Character or not Character.Parent then
            Character = game.Players.LocalPlayer.Character
        end

        if Character then
            for _, Prompt in ipairs(Model:GetDescendants()) do
                if Prompt:IsA("ProximityPrompt") and Prompt.Enabled then
                    local PromptPart = Prompt.Parent

                    while PromptPart and not PromptPart:IsA("BasePart") do
                        PromptPart = PromptPart.Parent
                    end

                    if PromptPart then
                        Character:PivotTo(CFrame.new(PromptPart.Position + Vector3.new(0, 3, 0)))
                        task.wait(0.15)

                        local Success = pcall(function()
                            fireproximityprompt(Prompt)
                        end)

                        if Success then
                            Collected = Collected + 1
                        end

                        task.wait(0.15)
                    end
                end
            end
        end
    end

    Library:SendNotification("Collect Finished!", "Triggered prompts: " .. Collected, 3, 108320733835485, 1, "green")
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
