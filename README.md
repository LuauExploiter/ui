# KetamineUI

Real Ketamine hierarchy + useful modules only.
Spy features (HTTPSpy/RSpy/ESpy/scanners) removed.

## files

```
init.lua          -- main library (objects hierarchy embedded + helpers) ~475KB
Objects.lua       -- same objects (also standalone)
modules/
  CodeBox.lua     -- real code editor
  Shared.lua
  ToString.lua
  HookFunction.lua
  Settings.lua
  Changelogs.lua
```

## load (folder)

```lua
local UI = require(path.to.KetamineUI_final)

-- clean API window
local Window = UI:CreateWindow({ Title = "My Tool", Size = UDim2.new(0, 900, 0, 560) })

-- or build original hierarchy
local objects = UI:BuildOriginal()
local screenGui = objects["Instance0"]
```

## loadstring single file

upload `init.lua` and:

```lua
local UI = loadstring(game:HttpGet("URL/init.lua"))()
```

note: modules/ won't auto-load with pure loadstring unless you also host them and patch require. for loadstring, the CreateWindow API + embedded objects work. CodeBox module needs the folder layout or manual injection.

## CreateWindow example

```lua
local UI = loadstring(game:HttpGet("URL/init.lua"))()

local Window = UI:CreateWindow({ Title = "HTTP Spy", Size = UDim2.new(0, 920, 0, 580) })
local left, right = Window:CreateSplitLayout(280)

UI:CreateFilterChips(left, {"All", "GET", "POST", "WS"}, function(f) end)

local logs = UI:CreateLogList(left, {
    Position = UDim2.new(0, 4, 0, 40),
    Size = UDim2.new(1, -8, 1, -48)
})

local tabs = Window:CreateTabContainer()
local tab = tabs:CreateTab("Request")
local box = tab:CreateCodeBox({ Title = "Body" })

logs:AddItem("[GET] https://example.com", UI.Theme.Method.GET, function()
    box:SetText("GET / HTTP/1.1")
end)

Window:SetStatus("Ready", UI.Theme.Success)
```

## modules

when used as a folder, real modules are on `UI.Modules`:
- `UI.Modules.CodeBox`
- `UI.Modules.Shared`
- `UI.Modules.ToString`
- `UI.Modules.HookFunction`
- `UI.Modules.Settings`
- `UI.Modules.Changelogs`

icons: `UI.Icons.Shadow`, `UI.Icons.Logo`, etc.
theme: `UI.Theme`
