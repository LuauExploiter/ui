-- Extracted from Ketamine: Settings
    modules[objects["Instance3"]] = function()
        local script = objects["Instance3"];
local tweenService = game:GetService("TweenService")
local http = game:GetService("HttpService")

local event = Instance.new("BindableEvent", script)
event.Name = "SettingChange"

local metatable

local settings = {
    {"SEPARATOR", "UI Settings"},
    {"Transparent", false, function(state)
        tweenService:Create(script.Parent.Parent.Main, TweenInfo.new(1), {BackgroundTransparency = not state and 0 or metatable.Has_shadow and 0.2 or 0.05}):Play()
    end},
    {"Rounded_corners", false, function(state)
        tweenService:Create(script.Parent.Parent.Main.UICorner, TweenInfo.new(1), {CornerRadius = UDim.new(state and 0.025 or 0.01)}):Play()
    end},
    {"Always_show_side_panel", {1, 1, 3}, function(state, instance)
        if instance then
            instance.Label.Text = state == 1 and "Dynamic side panel" or state == 2 and "Never show side panel" or "Always show side panel"
        end
    end},
    {"Window_scale", {100, 75, 155}},
    {"SEPARATOR", "UI Shadow Settings"},
    {"Has_shadow", true, function(state)
        metatable.Transparent = metatable.Transparent
        tweenService:Create(script.Parent.Parent.Shadow, TweenInfo.new(state and 0.75 or 1.25), {ImageTransparency = state and 0.2 or 1}):Play()
    end},
    {"Shadow_centered", false, function(state)
        script.Parent.Parent.Shadow:TweenPosition(state and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0.515, 0.525), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
    end},
    {"SEPARATOR", "Log Settings"},
    {"Log_executor_function_calls", {1, 1, 3}, function(state, instance)
        if instance then
            instance.Label.Text = state == 1 and "Log calls called only by game scripts" or state == 2 and "Log calls called by game & executor scripts" or "Log calls called only by executor scripts"
        end
    end},
    {"Create_arguments_as_variable", false},
    {"Create_event_as_variable", false},
    {"Maximum_log_amount", {10, 0, 20}, function(state, instance)
        if instance then
            instance.Label.Text = "Maximum log amount [ " .. math.max(1, state * 5) .. " ]"
        end
    end},
    {"Decompile_limit", {1, 1, 50}, function(state, instance)
        if instance then
            instance.Label.Text = "Decompile limit [ " .. state .. " / 50 scripts at the same time ]"
        end
    end},
    {"Ignore_spammy_logs", true}
}

local function find(index)
    for _, v in settings do
        if v[1] == index then
            return v
        end
    end
    return nil
end

local files = getfenv().writefile and getfenv().readfile and getfenv().makefolder
metatable = setmetatable({ }, {
    __index = function(self, index)
        index = index:sub(1,1):upper() .. index:sub(2)

        if index == "Values" then
            local vals = { }
            
            for _, v in settings do
                vals[#vals+1] = { v[1], v[2] }
            end
            
            return vals
        elseif index == "Event" or index == "Signal" or index == "Changed" then
            return event.Event
        elseif index == "Find" then
            return find
        else
            local setting = find(index)
            if setting then
                return typeof(setting[2]) == "table" and setting[2][1] or setting[2]
            else
                error("Unable to get value for setting: " .. tostring(index), 0)
            end
        end
    end,
    __newindex = function(self, index, value)
        index = index:sub(1, 1):upper() .. index:sub(2)
        local setting = find(index)
        assert(setting, "Setting not found: " .. tostring(index))
        assert(typeof(value) == typeof(setting[2]) or typeof(value) == "number" and typeof(setting[2]) == "table", ("Type mismatch for setting %s: expected %s got %s"):format(index, typeof(setting[2]), typeof(value)))

        local val = typeof(value) == "table" and value[1] or value

        setting[2] = value
        event:Fire(index, val)

        if setting[3] then
            task.spawn(setting[3], val, setting[4])
        end
        
        local auto = find("Auto_load_settings")
        if auto and auto[2] then
            if files then
                local saveFile = { }
                for _, v in self.Values do
                    local i = v[1]
                    local v = v[2]

                    if i ~= "SEPARATOR" then
                        saveFile[i] = v
                    end
                end

                task.spawn(getfenv().writefile, "Ketamine/Settings.json", http:JSONEncode(saveFile))
            end
        end
    end
})

if files then
    getfenv().makefolder("Ketamine")

    table.insert(settings, 1, {"Auto_load_settings", false, function(state)
        task.spawn(getfenv().writefile, "Ketamine/Settings.bool", state and "1" or "0")

        if state then
            local success, json = pcall(getfenv().readfile, "Ketamine/Settings.json")
            if success then
                for index, value in http:JSONDecode(json) do
                    if index ~= "Auto_load_settings" then
                        metatable[index] = typeof(value) == "table" and value[1] or value
                    end
                end
            end
        end
    end})
    
    table.insert(settings, 1, {"SEPARATOR", "Saves"})
    
    local success, value = pcall(getfenv().readfile, "Ketamine/Settings.bool")
    if success then
        task.delay(5, function()
            metatable.Auto_load_settings = value == "1"
        end)
    end
end

return metatable
    end;

