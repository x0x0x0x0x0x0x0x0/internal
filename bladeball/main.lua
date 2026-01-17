local Main = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local AutoParryEnabled = false
local AutoClashEnabled = false
local ParryThreshold = 0.55

local Parried = false
local LastBall = nil
local TargetConnection = nil

local Window = Main:CreateWindow({
    Title = "x0 hub",
    SubTitle = "by x0x0x0x0x0x0x0x0",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "swords" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local function GetRealBall()
    local ballsFolder = workspace:FindFirstChild("Balls")
    if ballsFolder then
        for _, ball in ipairs(ballsFolder:GetChildren()) do
            if ball:GetAttribute("realBall") then
                return ball
            end
        end
    end
    return nil
end

local function Click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function SpamClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function ResetConnection(ball)
    if TargetConnection then
        TargetConnection:Disconnect()
        TargetConnection = nil
    end
    
    if ball then
        TargetConnection = ball:GetAttributeChangedSignal("target"):Connect(function()
            Parried = false
        end)
    end
end

do
    local CombatSection = Tabs.Main:AddSection("Combat")
    
    CombatSection:AddToggle("AutoParry", {
        Title = "Auto Parry",
        Default = false,
        Callback = function(Value)
            AutoParryEnabled = Value
        end
    })
    
    CombatSection:AddToggle("AutoClash", {
        Title = "Auto Clash",
        Description = "Spams when distance is < 20",
        Default = false,
        Callback = function(Value)
            AutoClashEnabled = Value
        end
    })

    CombatSection:AddSlider("Threshold", {
        Title = "Parry Threshold",
        Description = "Time to impact (Distance/Speed)",
        Default = 0.55,
        Min = 0.35,
        Max = 0.85,
        Rounding = 2,
        Callback = function(Value)
            ParryThreshold = Value
        end
    })
end

do
    local PlayerSection = Tabs.Player:AddSection("Movement")
    
    PlayerSection:AddSlider("WalkSpeed", {
        Title = "Walk Speed",
        Default = 16,
        Min = 16,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end
    })
end

do
    local InterfaceSection = Tabs.Settings:AddSection("Interface")
    InterfaceSection:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = "RightShift" })
    Main.MinimizeKeybind = Main.Options.MenuKeybind
end

RunService.PreSimulation:Connect(function()
    if not AutoParryEnabled then return end

    local Ball = GetRealBall()
    
    if Ball ~= LastBall then
        LastBall = Ball
        Parried = false
        ResetConnection(Ball)
    end
    
    if not Ball or not LocalPlayer.Character then return end
    
    local HRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    if Ball:GetAttribute("target") ~= LocalPlayer.Name then 
        return 
    end

    local VelocityVector = Vector3.zero
    if Ball:FindFirstChild("zoomies") then
        VelocityVector = Ball.zoomies.VectorVelocity
    else
        VelocityVector = Ball.AssemblyLinearVelocity
    end

    local Speed = VelocityVector.Magnitude
    local Distance = (HRP.Position - Ball.Position).Magnitude
    
    if Speed <= 0 then return end
    
    local DirectionToPlayer = (HRP.Position - Ball.Position).Unit
    local VelocityUnit = VelocityVector.Unit
    local DotProduct = DirectionToPlayer:Dot(VelocityUnit)
    
    if DotProduct < 0 then
        return
    end
    
    if AutoClashEnabled and Distance < 20 then
        SpamClick()
        return
    end

    if not Parried and (Distance / Speed) <= ParryThreshold then
        Click()
        Parried = true
    end
end)

Main:Notify({
    Title = "x0 hub",
    Content = "Script loaded.",
    Duration = 5
})
