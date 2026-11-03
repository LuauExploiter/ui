-- Extracted from Ketamine: HookFunction
    modules[objects["Instance7"]] = function()
        local script = objects["Instance7"];
return function(shared)
    local onClose = shared.OnCloseEvent.Event
    local hooks = shared:AddObject({ })

    onClose:Connect(function()
        for _, v in hooks do
            if v[1] == "F" then
                getfenv().hookfunction(v[2], v[3])
            else
                getfenv().hookmetamethod(game, v[2], v[3])
            end
        end
    end)

    local function isc(f)
        return (getfenv().iscclosure and getfenv().iscclosure(f) or not getfenv().iscclosure) and debug.info(f, "s") == "[C]" and (debug.getinfo and debug.getinfo(f).what == "C" and debug.getinfo(f).source:match("%[C%]") or not debug.getinfo)
    end

    local function newc(closure)
        return getfenv().newcclosure and getfenv().newcclosure(closure) or getfenv().clonefunction and getfenv().clonefunction(closure) or function(...) return closure(...) end
    end
    local function newl(closure)
        local cloned = getfenv().clonefunction and getfenv().clonefunction(function(...) return closure(...) end) or function(...) return closure(...) end
        return function(...) return cloned(...) end
    end

    local function safeClosure(original, hooked)
        if isc(original) then
            return newc(newl(hooked))
        else
            return newl(newc(hooked))
        end
    end
    
    local loggedMetaMethod = false
    return shared:AddObject({
        HookFunction = function(target, new)
            local old
            local function hooked(...)
                return new(old, ...)
            end

            old = getfenv().hookfunction(target, safeClosure(target, hooked))
            table.insert(hooks, shared:AddObject({ "F", target, old }))

            return target -- we don't need to slide the old function
        end,
        UnHookFunction = function(target)
            while true do
                local found = false
                for idx, hook in hooks do
                    if hook[1] == "F" and hook[2] == target then
                        found = idx
                        break
                    end
                end
                
                if found then
                    local found = table.remove(hooks, found)
                    getfenv().hookfunction(found[2], found[3])
                else
                    break
                end
            end
        end,
        HookMetaMethod = function(method, new)
            local old
            local function hooked(...)
                return new(old, ...)
            end
            
            old = getfenv().hookmetamethod(game, method, safeClosure(pcall, hooked)) -- used pcall as random C closure; pcall was not affected
            if not loggedMetaMethod then
                loggedMetaMethod = true
                table.insert(hooks, shared:AddObject({ "MM", method, old }))
            end
            
            -- we don't need to return function
        end
    })
end
    end;

