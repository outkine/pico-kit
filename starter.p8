pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	print = debug.print
end
-->8
function _update60()
end
-->8
function _draw()
 cls()
end
-->8
--pico-tools
oop = {}
local function make(vars, parents, new)
 local required = {}
 for k,v in pairs(vars) do
  if v == 'req' then
   add(required, k)
   vars[k] = nil
  end
 end
 return function(self, input)
  for v in all(required) do
   assert(
    input[v] ~= nil,
    'missing constructor argument ' .. v
   )
  end
  for parent in all(parents) do
   parent.new(self, input)
  end
  tools.deepassign(vars, self)
  tools.assign(input, self)
  if new then new(self) end
 end
end
local function search(k, list)
 for v in all(list) do
  if v[k] then return v[k] end
 end
end
local function parent_function(parents)
 local parent
 if #parents == 1 then
  parent = parents[1]
 else
  parent = function(t, k)
   return search(k, parents)
  end
 end
 return parent
end
function oop.class(properties, parents, new, metatable)
 local class = setmetatable({}, metatable or {})
 if parents and #parents ~= 0 then
  getmetatable(class).__index = parent_function(parents)
 end
 local instance_mt = {
  __index = class
 }
 class.new = make(properties, parents, new)
 function new(self, input)
  local instance = setmetatable({}, instance_mt)
  class.new(instance, input)
  return instance
 end
 getmetatable(class).__call = new
 return class
end

tools = {}
function tools.assign(t, initial)
 initial = initial or {}
 for k, v in pairs(t) do
  initial[k] = v
 end
 return initial
end
function tools.deepassign(t, initial)
 initial = initial or {}
 for k, v in pairs(t) do
  if type(v) == "table" then
   initial[k] = tools.deepassign(v)
  else
   initial[k] = v
  end
 end
 return initial
end

debug = {}
function debug.tstr(t, indent)
 indent = indent or 0
 local indentstr = ''
 for i=0,indent do
  indentstr = indentstr .. ' '
 end
 local str = ''
 for k, v in pairs(t) do
  if type(v) == 'table' then
   str = str .. indentstr .. k .. '\n' .. debug.tstr(v, indent + 1) .. '\n'
  else
   str = str .. indentstr .. tostr(k) .. ': ' .. tostr(v) .. '\n'
  end
 end
  str = sub(str, 1, -2)
 return str
end
function debug.print(...)
 printh("\n")
 for v in all{...} do
  if type(v) == "table" then
	 printh(debug.tstr(v))
  elseif type(v) == "nil" then
  	printh("nil")
  else
   printh(v)
  end
 end
end

physics = {}
function physics.collided(body1, body2)
 local result = true
 for i=1,2 do
  result = result and
   body1.pos[i] < body2.pos[i] + body2.size[i] and
   body2.pos[i] < body1.pos[i] + body1.size[i]
 end
 return result
end
physics.world = oop.class{
 bodies = {},
 gravity = {0, .5},
}
function physics.world:update()
 for body in all(self.bodies) do
  if not body.static then
   if body.mass[1] or body.mass[2] then
    body:shove{
     self.gravity[1] * body.weight[1], self.gravity[2] * body.weight[2]
    }
    if body.friction[1] ~= 0 or body.friction[2] ~= 0 then
     body:slow(body.friction)
    end
   end

   body.collisions = {}
   for body2 in all(self.bodies) do
    if band(body.layer, body2.layer) ~= 0 and body ~= body2 then
     body:checkcollided(body2)
    end
   end
   body:update()
  end
 end
end
function physics.world:addbody(body)
 add(self.bodies, body)
 return body
end
physics.body = oop.class{
 pos="req",
 size="req",
 vel={0, 0},
 mass={1, 1},
 weight={1, 1},
 friction={.1, 0},
 collisions={},
 static=false,
 layer=0x1,
}
function physics.body:shove(vel)
 for i=1,2 do
  self.vel[i] += vel[i] * self.mass[i]
 end
end
function physics.body:update()
 for i=1,2 do
  self.pos[i] += self.vel[i]
 end
end
function physics.body:slow(vel)
 for i=1,2 do
  if self.vel[i] > 0 then
   self.vel[i] -= vel[i] * self.mass[i]
   if self.vel[i] < 0 then
    self.vel[i] = 0
   end
  elseif self.vel[i] < 0 then
   self.vel[i] += vel[i] * self.mass[i]
   if self.vel[i] > 0 then
    self.vel[i] = 0
   end
  end
 end
end
function physics.body:checkcollided(body)
 local oldpos = tools.assign(self.pos)
 for i=1,2 do
  local pos = tools.assign(oldpos)
  pos[i] += self.vel[i]
  if physics.collided({pos=pos, size=self.size}, body) then
   add(self.collisions, body)
   if self.vel[i] >= 0 then
    self.pos[i] = body.pos[i] - self.size[i]
   else
    self.pos[i] = body.pos[i] + body.size[i]
   end
   self.vel[i] = 0
  end
 end
end
