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
function physics.togrid(pos)
	--return tools.map(pos, function(num)
	--return flr(num / 8)
	--end)
	return {flr(pos[1]/8), flr(pos[2]/8)}
end
function physics.fromgrid(pos)
	return {pos[1]*8, pos[2]*8}
end
physics.world = oop.class{
 bodies={},
 gravity={0, .5},
 grid="req",
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
   if body.check then
    body.collisions = {}
    for body2 in all(self.bodies) do
     if body ~= body2 then
      body:checkcollided(
      	body2, 
      	band(body.layer, body2.layer) != 0
      )
     end
    end
    body.tcollisions = {}
	   body:gridcollided(self)
   end
   body:update()
  end
 end
end
function physics.world:addbody(body)
 add(self.bodies, body)
 return body
end
function physics.world:gettile(pos)
	local x = self.grid[pos[1]] 
	if x then
		return x[pos[2]] 
 end
end
physics.body = oop.class({
 pos="req",
 size="req",
 vel={0, 0},
 mass={1, 1},
 weight={1, 1},
 friction={.1, 0},
 collisions={},
 tcollisions={},
 static=false,
 layer=0x1,
 check=false,
}, {}, function(self)
	self.tsize = physics.togrid(
		self.size
	)
end)
local body = physics.body
function body:shove(vel)
 for i=1,2 do
  self.vel[i] += vel[i] * self.mass[i]
 end
end
function body:update()
 for i=1,2 do
  self.pos[i] += self.vel[i]
 end
end
function body:slow(vel)
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
function body:align(i, body)
 if self.vel[i] >= 0 then
  self.pos[i] = body.pos[i] - self.size[i]
 else
  self.pos[i] = body.pos[i] + body.size[i]
 end  
	self.vel[i] = 0
end
function body:checkcollided(body, move)
 local oldpos = tools.assign(self.pos)
 local checks = {}
 for i=1,2 do
  local pos = tools.assign(oldpos)
  pos[i] += self.vel[i]
 	--if self:collided(body, pos) then
		if physics.collided({
			pos=pos, size=self.size
		}, body) then
	  checks[i] = true
 		add(self.collisions, body)
			if move then
				self:align(i, body)
			end
		end
 end
 if
 	not checks[1] and 
 	not checks[2]
 then
 	local pos = {
 		oldpos[1] + self.vel[1],
 		oldpos[2] + self.vel[2],
 	}
 	--if self:collided(body, pos) then
 	if physics.collided({
			pos=pos, size=self.size
		}, body) then
 		add(self.collisions, body)
 		if move then
				for i=1,2 do
					self:align(i, body)
				end
			end
		end
 end
end
function body:gridcollided(world)
	local oldpos = tools.assign(self.pos)
 for i=1,2 do
  local pos = tools.assign(oldpos)
  pos[i] += self.vel[i]

		local tpos = self:findtpos(pos)
  for pos in all(tpos) do
  	tile = world:gettile(pos)
  	if tile then
  		if band(self.layer, tile) != 0 then
   		self:align(i, {
   			pos=physics.fromgrid(pos),
   			size={8, 8}
   		})
 			end
  		add(self.tcollisions, pos)
  		break
  	end
  end
	end
	if #self.tcollisions == 0 then
		local tpos = self:findtpos({
 		oldpos[1] + self.vel[1],
 		oldpos[2] + self.vel[2],
 	})
 	for pos in all(tpos) do
  	tile = world:gettile(pos)
  	if tile then
  		if band(self.layer, tile) != 0 then
   		for i=1,2 do
    		self:align(i, {
    			pos=physics.fromgrid(pos),
    			size={8, 8}
    		})
 				end
 			end
  		add(self.tcollisions, pos)
  		break
  	end
		end
	end
end
function body:findtpos(pos)
	local tpos = physics.togrid(pos)
	local poss = {tpos}

	for size in all{
 	{1, 1},
 	{1, 0},
 	{0, 1},
	} do
 	local tpos2 = physics.togrid{
 		pos[1]+(self.size[1]-1)*size[1],
 		pos[2]+(self.size[2]-1)*size[2],
  } 
  if tpos2[1] != tpos[1] or
  			tpos2[2] != tpos[2] then
 		add(poss, tpos2)
 	end
	end
	return poss
end
--[[
function physics.collided(body, pos)
	return physics.collided({
		pos=pos, size=self.size
	}, body)
end
