-- Extracted from Ketamine: Shared
    modules[objects["Instance4"]] = function()
        local script = objects["Instance4"];
local global = typeof(getfenv().getgenv) == "function" and typeof(getfenv().getgenv()) == "table" and getfenv().getgenv() or _G -- I never made normal require in my plugin, so thats a reason why I made that
local idx = "__KetamineShared"

if global[idx] then
    return global[idx]
end

local useEnv = getfenv().getgenv ~= nil
if useEnv then
    local found = {
        ["print"] = false,
        ["getgenv"] = false,
        ["vector"] = false,
        ["error"] = false,
        ["loadstring"] = false
    }

    for i, _ in getfenv().getgenv() do
        if typeof(found[i]) ~= "nil" then
            found[i] = true
        end
    end

    for _, v in found do
        if not v then
            useEnv = false
            break
        end
    end
end

local function pressKey(isDown, key)
    game:GetService("VirtualInputManager"):SendKeyEvent(isDown, Enum.KeyCode[key], false, game)
    for i=1, 2 do game:GetService("RunService").RenderStepped:Wait() end
end

local shared = {
    Version = "BETA",
    Connections = { },
    SidePanelEvent = Instance.new("BindableEvent", script),
    Settings = require(script.Parent.Settings),
    CodeBox = require(script.Parent.CodeBox),
    Global = global,
    _idx = idx,
    UseEnv = useEnv and getfenv().getgenv,
    OnCloseEvent = Instance.new("BindableEvent", script),
    ToString = require(script.Parent.ToString),
    CSpyObjects = setmetatable({ }, { __mode = "kv" }),
    Changelogs = require(script.Parent.Changelogs),
    AddObject = function(self, tbl)
        if (typeof(tbl) == "table" or typeof(tbl) == "function") and not self:IsCSpy(tbl) then
            table.insert(self.CSpyObjects, tbl)
            if typeof(tbl) == "table" then
                for i, v in tbl do
                    self:AddObject(i) -- who knows, mb "i" is not a number or string
                    self:AddObject(v)
                end
            end
        end
        
        return tbl
    end,
    Clipboard = getfenv().toclipboard or getfenv().setclipboard or function(text)
        local ui = Instance.new("ScreenGui", game:GetService("CoreGui"))
        task.delay(1, ui.Destroy, ui)
        
        local tb = Instance.new("TextBox", ui)
        tb.Size = UDim2.fromOffset(1, 1)
        tb.BackgroundTransparency = 1
        tb.TextTransparency = 1
        tb.Text = text
        
        tb:CaptureFocus()

        for i=1, 2 do game:GetService("RunService").RenderStepped:Wait() end
        pressKey(true, "LeftControl")
        pressKey(true, "A")
        pressKey(false, "A")
        pressKey(true, "C")
        pressKey(false, "C")
        pressKey(false, "LeftControl")
        
        tb:ReleaseFocus()
    end,
    IsCSpy = function(self, obj)
        return table.find(self.CSpyObjects, obj)
    end,
    AddButton = function(self, button)
        local cont = button.Contents
        local source = cont.BackgroundTransparency
        local In = false

        button.MouseEnter:Connect(function()
            In = true
            cont.BackgroundTransparency = source + 0.025
        end)
        button.MouseLeave:Connect(function()
            In = false
            cont.BackgroundTransparency = source
        end)
        button.MouseButton1Down:Connect(function()
            cont.BackgroundTransparency = source - 0.05
        end)
        button.MouseButton1Up:Connect(function()
            cont.BackgroundTransparency = source + (In and 0.025 or 0)
        end)
        
        return button
    end
}

shared:AddObject(shared.Connections)
shared:AddObject(shared.Settings)
shared:AddObject(shared.ToString)
shared:AddObject(shared.CodeBox)
shared:AddObject(shared.CSpyObjects)
shared:AddObject(shared.Changelogs)

shared.HookFunction = require(script.Parent.HookFunction)(shared)
shared.SidePanelEvent.Name = "SidePanel"
shared.OnCloseEvent.Name = "OnClose"

global[idx] = shared

return shared
    end;

