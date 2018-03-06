pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
end
-->8
function _update()
end
-->8
function _draw()
end
-->8
--oop
local m = {}
local function make(vars)
	required = {}
	for k,v in pairs(vars) do
		if v == 'req' then
			add(required, k)
			vars[k] = nil
		end
	end
 return function(self, input)
 	for v in all(required) do
 		assert(
 			input[v] != nil,
 			'missing constructor argument ' .. v
 		)
 	end
 	tools.assign(self, vars)
 	tools.assign(self, input)
 end
end
local function search(k, list)
  for v in all(list) do
    local result = v[k]
    if result then return result end
  end
end
local function metatable_check(f)
  return function(class, ...)
    if not getmetatable(class) then
      setmetatable(class, {})
    end
    f(class, ...)
  end
end
local function parent_function(parents)
  if #parents == 1 then
    parent = parents[1]
  else
    parent = function(t, k)
      return search(k, parents)
    end
  end
  return parent
end
m.inherit = metatable_check(
function(class, ...)
  getmetatable(class).__index = parent_function({...})
end
)
m.makecall = metatable_check(
function(class, properties)
  local instance_mt = tools.assign({}, getmetatable(class))
  instance_mt.__index = class

  local makeinstance = make(properties)
  local function new(self, input)
    tools.print(input)
    local instance = setmetatable({}, instance_mt)
    makeinstance(instance, input)
    return instance
  end
  getmetatable(class).__call = new
end
)
oop = m
-->8
--tools
local m = {}
function m.tstring(t)
  local string = ''
  for k, v in pairs(t) do
    string = string .. tostr(k) .. ': ' .. tostr(v) .. '\n'
  end
		string = sub(string, 1, -2)
  return string
end
function m.print(...)
		printh("\n")
	 for v in all({...}) do
	 		if type(v) == "table" then
	 				m.tprint(v)
	 		else
	 				printh(v)
	 		end
	 end
end
function m.tprint(t)
  printh(m.tstring(t))
end
function m.assign(initial, t)
  for k, v in pairs(t) do
    initial[k] = v
  end
  return initial
end
tools = m
