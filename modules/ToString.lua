-- Extracted from Ketamine: ToString
    modules[objects["Instance6"]] = function()
        local script = objects["Instance6"];
local function normalize(str)
    return (str:gsub("\n", "\\n"):gsub("\t", "\\t"):gsub("\r", "\\r"):gsub("\"", "\\\""):gsub("\0", "\\0"))
end

local function escapePattern(str)
    return str:gsub("%%", "%%%%")
        :gsub("%.", "%%.")
        :gsub("%?", "%%?")
        :gsub("%!", "%%!")
        :gsub("%,", "%%,")
        :gsub("%[", "%%[")
        :gsub("%]", "%%]")
        :gsub("%(", "%%(")
        :gsub("%)", "%%)")
        :gsub("%{", "%%{")
        :gsub("%}", "%%}")
end

local alphabet = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm_1234567890"
local function isValidSymbol(s)
    return alphabet:find(escapePattern(s)) ~= nil
end

local function isValidVariableName(var)
    var = tostring(var)
    if not var or tonumber(var:sub(1,1)) then
        return false
    end

    for char in var:gmatch(".") do
        if not isValidSymbol(char) then
            return false
        end
    end

    return true
end

local function getPath(obj, normalNil, dontGetService)
    if not obj then
        return "nil"
    elseif obj == workspace.Parent or obj == game then
        return "game"
    elseif obj and not obj.Parent then
        local env = getfenv()
        local name = env.getnilinstances and "getnilinstances" or env.getnils and "getnils"
        if not normalNil and name then
            return ("(function()\n  local function getNil(objType, objName)\n    for _, v in %s() do\n      if v.ClassName == objType and v.Name == objName then\n        return v\n      end\n    end\n  end\n  return getNil(\"%s\", \"%s\")\nend)()")
                :format(name, obj.ClassName, normalize(obj.Name))
        elseif normalNil then
            return "(nil)[\"" .. normalize(obj.Name) .. "\"]"
        else
            return "(nil)[\"" .. normalize(obj.Name) .. "\"] --[[ Object is parented to nil; getnilinstances does not exist ]]"
        end
    end

    local path = ""
    while obj.Parent do
        if (obj.Parent == game or obj.Parent == workspace.Parent) and not dontGetService and pcall(game.GetService, game, obj.ClassName) and game:GetService(obj.ClassName) then
            path = "game:GetService(\"" .. obj.ClassName:gsub(" ", "") .. "\")" .. path
            break
        elseif (obj.Parent == game or obj.Parent == workspace.Parent) and obj == workspace or obj == game:GetService("Workspace") then
            path = "workspace" .. path
            break
        end

        local siblings = obj.Parent:GetChildren()
        local sameNameCount = 0
        local index = nil

        for i, v in siblings do
            if v.Name == obj.Name then
                sameNameCount = sameNameCount + 1
                if v == obj then
                    index = i
                end
            end
        end

        if sameNameCount > 1 and index and index ~= 1 and not dontGetService then
            path = ":GetChildren()[" .. index .. "]" .. path
        else
            local notInstance = typeof(obj.Parent[obj.Name]) ~= "Instance"
            if not isValidVariableName(obj.Name) or notInstance then
                if notInstance then
                    path = ":FindFirstChild(\"" .. normalize(obj.Name) .. "\")" .. path
                else
                    path = "[\"" .. normalize(obj.Name) .. "\"]"
                end
            else
                path = "." .. obj.Name .. path
            end
        end

        obj = obj.Parent
    end

    if not obj.Parent then
        path = "game" .. path
    end

    return (path:gsub("game:GetService%(\"Workspace\"%)", "workspace"))
end

local http = game:GetService("HttpService")
local tostr
local function convertArg(arg, indent)
    local t = typeof(arg)
    if t == "string" then
        local success, decoded = pcall(http.JSONDecode, http, arg)
        if success and not tonumber(arg) then
            return "game:GetService(\"HttpService\"):JSONEncode(" .. tostr(decoded) .. ")"
        else
            if #arg == 38 and arg:sub(1, 1) == "{" and arg:sub(-1) == "}" and arg:sub(10, 10) == "-" and arg:sub(15, 15) == "-" and arg:sub(20, 20) == "-" and arg:sub(25, 25) == "-" then
                return "game:GetService(\"HttpService\"):GenerateGUID(true) --[[" .. arg .. "]]"
            elseif #arg == 36 and arg:sub(9, 9) == "-" and arg:sub(14, 14) == "-" and arg:sub(19, 19) == "-" and arg:sub(24, 24) == "-" then
                return "game:GetService(\"HttpService\"):GenerateGUID(false) --[[" .. arg .. "]]"
            end
            
            return "\"" .. normalize(arg) .. "\""
        end
    elseif t == "number" then
        if arg == math.huge then
            return "math.huge"
        elseif arg == -math.huge then
            return "-math.huge"
        elseif arg ~= arg then
            return "(0 / 0) -- [[ nan ]]"
        elseif math.abs(tick() - arg) <= 2.5 then
            if math.floor(arg) == arg then
                return "os.time() --[[" .. arg .. "]]"
            else
                return "tick() --[[" .. arg .. "]]"
            end
        elseif math.abs(workspace:GetServerTimeNow() - arg) <= 2.5 then
            return "workspace:GetServerTimeNow() --[[" .. arg .. "]]"
        elseif math.abs(os.clock() - arg) <= 2.5 then
            return "os.clock() --[[" .. arg .. "]]"
        elseif math.abs(time() - arg) <= 2.5 and math.floor(arg) ~= arg then
            return "time() --[[" .. arg .. "]]"
        end
        
        return tostring(arg)
    elseif t == "boolean" or t == "nil" then
        return tostring(arg)
    elseif t == "Color3" then
        local r255 = arg.R * 255
        local g255 = arg.G * 255
        local b255 = arg.B * 255

        if math.abs(r255 - math.floor(r255 + 0.5)) < 1e-6 and math.abs(g255 - math.floor(g255 + 0.5)) < 1e-6 and math.abs(b255 - math.floor(b255 + 0.5)) < 1e-6 then
            return string.format("Color3.fromRGB(%d, %d, %d)", math.round(r255), math.round(g255), math.round(b255))
        else
            return string.format("Color3.new(%f, %f, %f)", arg.R, arg.G, arg.B)
        end
    elseif t == "BrickColor" then
        return "BrickColor.new(\"" .. arg.Name .. "\")"
    elseif t == "UDim" then
        if arg.Scale == 0 and arg.Offset == 0 then
            return "UDim.new()"
        end
        return string.format("UDim.new(%f, %d)", arg.Scale, arg.Offset)
    elseif t == "UDim2" then
        if arg.X.Scale == 0 and arg.X.Offset == 0 and arg.Y.Scale == 0 and arg.Y.Offset == 0 then
            return "UDim2.new()"
        elseif arg.X.Scale == 0 and arg.Y.Scale == 0 then
            return string.format("UDim2.fromOffset(%d, %d)", arg.X.Offset, arg.Y.Offset)
        elseif arg.X.Offset == 0 and arg.Y.Offset == 0 then
            return string.format("UDim2.fromScale(%f, %f)", arg.X.Scale, arg.Y.Scale)
        else
            return string.format("UDim2.new(%f, %d, %f, %d)", arg.X.Scale, arg.X.Offset, arg.Y.Scale, arg.Y.Offset)
        end
    elseif t == "Ray" then
        return "Ray.new(" .. convertArg(arg.Origin, indent) .. ", " .. convertArg(arg.Direction, indent) .. ")"
    elseif t == "EnumItem" then
        return "Enum." .. arg.EnumType.Name .. "." .. arg.Name
    elseif t == "Enum" then
        return "Enum." .. arg.Name
    elseif t == "NumberRange" then
        return string.format("NumberRange.new(%f, %f)", arg.Min, arg.Max)
    elseif t == "NumberSequenceKeypoint" then
        return string.format("NumberSequenceKeypoint.new(%f, %f, %f)", arg.Time, arg.Value, arg.Envelope)
    elseif t == "ColorSequenceKeypoint" then
        return string.format("ColorSequenceKeypoint.new(%f, Color3.new(%f, %f, %f))", arg.Time, arg.Value.R, arg.Value.G, arg.Value.B)
    elseif t == "PhysicalProperties" then
        return string.format("PhysicalProperties.new(%f, %f, %f, %f, %f)", arg.Density, arg.Friction, arg.Elasticity, arg.FrictionWeight, arg.ElasticityWeight)
    elseif t == "Rect" then
        return string.format("Rect.new(Vector2.new(%f, %f), Vector2.new(%f, %f))", arg.Min.X, arg.Min.Y, arg.Max.X, arg.Max.Y)
    elseif t == "Region3" then
        return string.format("Region3.new(Vector3.new(%f, %f, %f), Vector3.new(%f, %f, %f))", arg.CFrame.Position.X, arg.CFrame.Position.Y, arg.CFrame.Position.Z, arg.CFrame.Position.X, arg.CFrame.Position.Y, arg.CFrame.Position.Z)
    elseif t == "Region3int16" then
        return string.format("Region3int16.new(Vector3int16.new(%d, %d, %d), Vector3int16.new(%d, %d, %d))", arg.Min.X, arg.Min.Y, arg.Min.Z, arg.Max.X, arg.Max.Y, arg.Max.Z)
    elseif t == "TweenInfo" then
        return string.format("TweenInfo.new(%f, Enum.EasingStyle.%s, Enum.EasingDirection.%s, %d, %s, %f)", arg.Time, arg.EasingStyle.Name, arg.EasingDirection.Name, arg.RepeatCount, tostring(arg.Reverses), arg.DelayTime)
    elseif t == "function" then
        local n = debug.info(arg, "n")
        if not n or n == "" or not getfenv()[n] then
            return "function() end"
        else
            return n
        end
    elseif t == "thread" then
        return "coroutine.create(function() --[[ Unable to get content ]] end)"
    elseif t == "userdata" then
        return "newproxy()"
    elseif t == "buffer" then
        local s1 = buffer.tostring(arg)
        local s2 = ""
        local allZeros = true
        
        for i = 1, #s1 do
            local v = s1:sub(i, i)
            local byte = string.byte(v)
            
            if byte ~= 0 then
                allZeros = false
            end
            
            if byte <= 31 or byte >= 127 then
                if byte == 10 then
                    s2 ..= "\\n"
                elseif byte == 13 then
                    s2 ..= "\\r"
                elseif byte == 9 then
                    s2 ..= "\\t"
                else
                    s2 ..= "\\" .. byte
                end
            else
                s2 ..= v:gsub("\"", "\\\"")
            end
        end
        
        if allZeros then
            return "buffer.create(" .. #s1 .. ")"
        end
        
        return "buffer.fromstring(\"" .. s2 .. "\")"
    elseif t == "Instance" then
        return getPath(arg)
    elseif t == "table" then
        return tostr(arg, indent)
    else
        local obj = getfenv()[t]

        if typeof(obj) == "table" and obj.new then
            if pcall(obj.new) and tostring(obj.new()) == tostring(arg) then
                return t .. ".new()"
            end

            return t .. ".new(" .. tostring(arg) .. ")"
        else
            return "--[[ unknown type: " .. t .. "; values: " .. tostring(arg):gsub("%]%]", "] ]") .. " ]]"
        end
    end
end

local function isArray(tbl)
    if typeof(tbl) ~= "table" then
        return false
    end
    
    local isArray = true
    local allValid = true
    local count = 0

    for k in tbl do
        if typeof(k) ~= "number" or math.floor(k) ~= k then
            isArray = false
            break
        end

        count = math.max(count, k)
    end

    if isArray then
        isArray = #tbl == count
        allValid = false

        if isArray then
            for i = 1, count do
                if tbl[i] == nil then
                    isArray = false
                    break
                end
            end
        end
    else
        for k in tbl do
            if typeof(k) ~= "string" or not isValidVariableName(k) then
                allValid = false
                break
            end
        end
    end
    
    return isArray, allValid, count
end

local parsed = { }
function tostr(tbl, indent)
    indent = tonumber(indent) or 0
    
    local indentStr = string.rep("    ", math.max(indent, 0))
    local indentStrNext = string.rep("    ", math.max(indent, 0) + 1)

    if typeof(tbl) ~= "table" then
        return convertArg(tbl, math.max(indent, 0))
    elseif table.find(parsed, tbl) then
        return "{ --[[ recursive ]] }"
    end
    
    table.insert(parsed, tbl)

    local isArray, allValid, count = isArray(tbl)

    if isArray then
        if count == 0 then
            return "{ }"
        end

        local result = "{" .. (indent == -1 and "" or " ")
        for i = 1, count do
            result ..= (indent == -1 and "\n" .. indentStrNext or "") .. tostr(tbl[i], math.max(indent, 0) + 1)
            if i < count then
                result ..= ","
            end
            result ..= indent == -1 and "" or " "
        end

        return result .. (indent == -1 and "\n" or "") .. "}"
    else
        local result = "{\n"
        local first = true

        for k, v in tbl do
            if not first then
                result ..= ",\n"
            end

            first = false
            result ..= indentStrNext .. (allValid and k or "[" .. tostr(k, math.max(indent, 0) + 1) .. "]") .. " = " .. tostr(v, math.max(indent, 0) + 1)
        end

        return result .. "\n" .. indentStr .. "}"
    end
end

return {
    ToString = function(...)
        return tostr(...), table.clear(parsed)
    end,
    CreateArguments = function(tbl)
        local isArray = isArray(tbl)
        local str = tostr(tbl)
        
        table.clear(parsed)

        if isArray then
            if #tbl == 0 then
                return "()"
            end

            return "(" .. str:sub(3):sub(1, #str - 4) .. ")"
        else
            return (("(" .. str .. ")"):gsub("%(nil%)", "()"))
        end
    end,
    EscapePattern = escapePattern,
    GetPath = getPath
}
    end;

