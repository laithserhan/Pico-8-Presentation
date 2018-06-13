pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- kitties on the prowl!
-- bright moth games

step = .01667 -- our framerate, 1/60

function _init()
	menuitem(1, "next demo", loadnextdemo)
	ontitle = true
	camx = 0
	speed = 30
	-- we're expanding the map so
	-- lets store it's width
	mapwidth = 46
	hoopframe = 1
	hoopframetime = 0
	hoopframes = {88, 89, 90, 91, 90, 92}
	-- we're adding a generic
	-- collides method so we need
	-- to be able to track our
	-- hitbox edges.
	hoops = {
		{ x = 76, y = 48, left = 1, right = 6 },
		{ x = 168, y = 40, left = 1, right = 6 },
		{ x = 272, y = 64, left = 1, right = 6 },
	}
	
	player = {
		x = 4, 
		y = 84,
		frames = { 3, 4, 2, 1},
		jumpframe = 5,
		fallframe = 6,
		standframe = 0,
		walking = false,
		-- renamed left to faceleft
		-- to make our collide method
		-- easier to read
		faceleft = false,
		jumping = false,
		onground = false,
		jumptime = 0,
		crouched = false,
		frameidx = 1,
		frametime	= 0,
		crouchframe = 9,
		hoopsacquired = 0,
		-- as with hoops, store hitbox
		-- edges
		left = 3, 
		right = 5
	}
	
	-- create a table to track the
	-- state of the cat, use the
	-- same variable names as for
	-- the player
	cat = {
		x = 180,
		y = 56,
		frameidx = 10,
		frametime	= 0,
		frames = { 10, 12, 10, 11 },
		jumpframe = 13,
		fallframe = 14,
		standframe = 10,
		walking = true,
		running = true,
		faceleft = true,
		jumping = false,
		onground = false,
		jumptime = 0,
		run = { 13, 14, 15 },
		crouchframe = 71,
		-- as above, but also store
		-- the top as it's non-0
		top = 4,
		left = 2,
		right = 8
	}
	
end

function _update60()
	if(ontitle) then
		if(btn(4) or btn(5)) then	
			ontitle = false
		end
		return
	end
	updateplayer()
	-- update the cat!
	updatecat(cat)
	
	hoopframetime += 1
	if(hoopframetime > 6) hoopframe += 1 hoopframetime = 0
	if(hoopframe > #hoopframes) hoopframe = 1
	for h in all(hoops) do
		-- use our new collides method
		if(collides(player, h)) then 
			del(hoops, h)
			player.hoopsacquired += 1
			sfx(11)
		end
	end

	-- if we hit a cat, we lose!
	if(collides(player, cat)) then
		_init()
	end

	if(#hoops < 1 and isexit(getplayercell())) then
		_init()
	end
end

function _draw()
	cls(12)
	if(ontitle) then
		drawtitle()
	else
		camera(camx, 0)	
		map(0, 0, 0 + round(camx * .80), 2, 35, 8)
		map(0, 26, 12 + round(camx * .70), 23, 35, 8)
		map(0, 36, -13 + round(camx * .55), 68, 42, 3)
		map(0, 8, 0, 52, mapwidth, 10)
		if(#hoops < 1) then
			--draw our open door over
			-- the map's closed one
			spr(106, 320, 76, 2, 2)
		end
		
		-- draw the cat!
		drawent(cat)
		drawent(player)

		for h in all(hoops) do
			spr(hoopframes[hoopframe], h.x, h.y, 1, 1)
		end
	end

	camera(0, 0)
	print("obstacles", 92, 122, 7)
end

function drawtitle()
	map(0, 0, -81, 1, 35, 8)
	map(0, 26, -4, 45, 35, 8)
	fillp(0b1010010110100101)
	rectfill(0, 109, 128, 120, 0x3b)
	fillp()
	rectfill(0,121, 128, 128, 4, 4)
	spr(66, 45, 50, 5, 2)
	spr(100, 42, 60, 6, 2)
	spr(64, 10, 86, 2, 4)
	spr(98, 54, 34, 2, 2)
	rectfill(32, 96, 96, 100, 0)
	rectfill(33, 95, 95, 101, 0)
	print("press ❎ or 🅾️", 37, 96, 7)
end

function drawent(obj)
	spr(getframe(obj), obj.x, obj.y, 1, 1, obj.faceleft) 
end
 
function framereset(obj)
	obj.frametime += 1
	obj.waswalking = obj.walking
	obj.wasrunning = obj.running
	obj.wasonground = obj.onground
	obj.walking = false
	obj.jumping = false
	obj.crouched = false
	obj.onground = false
	obj.running = false
end

function setonground(obj)
	local belowcells = getbottomcells(obj)
	if(hardtop(belowcells.a) or hardtop(belowcells.b)) then
		obj.onground = true
		obj.jumptime = 0
	end
end

function updateplayer()
	framereset(player)
	local cells = getleftcells(player)
	if(btn(0) and player.x > 0 and not hardright(cells.a) and not hardright(cells.b)) then
		player.x -= speed * step
		player.walking = true 
		player.faceleft = true
		if(camx > 0 and player.x - camx < 28) camx -= speed * step
	end

	local cells = getrightcells(player)
	if(btn(1) and player.x < mapwidth * 8 - player.right and not hardleft(cells.a) and not hardleft(cells.b)) then
		player.x += speed * step 
		player.walking = true 
		player.faceleft = false
		if(camx + 128 < mapwidth * 8 and player.x - camx > 64) camx += speed * step
	end

	setonground(player)
	
	if(btn(3) and not player.walking and player.onground) then
		player.crouched = true
	end
	
	if(btn(5) and (player.onground or player.jumptime < 36)) then
		player.jumping = true
		if(player.onground) then
			sfx(8)
		end
		player.onground = false
		player.y -= speed * step
	end
	updateframe(player)
	if(player.walking and player.frametime == 0) then
		if(player.frameidx == 1) sfx(9)
		if(player.frameidx == 3) sfx(10)
	end
end

-- create a function to handle
-- updating the cat
function updatecat()
	-- first we reset our state.
	framereset(cat)
	-- the cat is pretty much
	-- always moving
	cat.walking = true
	-- determine how far the
	-- player is to the cat
	local dist = abs(player.x - cat.x)
	-- if we're far away from the
	-- player, lie down.
	if(dist > 56) then
		cat.walking = false
		cat.crouched = true
	end
	-- if the player is close,
	-- start running. if we're
	-- already running, we need to
	-- expand the range a little
	-- bit to prevent resetting 
	-- the frame each time.
	if(dist < 48 or cat.wasrunning and dist < 50) then 
		if(not cat.wasrunning) then
			-- if we're not already
			-- running, reset the frame
			-- counter
			cat.frameidx = 1
			cat.frametime = 0
		end
		cat.running = true
	elseif(cat.wasrunning) then
		-- we're far enough away to
		-- walk, so if we were running
		--, reset the frame counter
		cat.frameidx = 1
		cat.frametime = 0
	end
	-- ensure the onground flag is
	-- set properly
	setonground(cat)
	-- then update our frame
	updateframe(cat)
	-- if our frametime has reset
	-- to zero, it's time to move
	-- a bit.
	if(cat.frametime == 0 and cat.walking) then
		-- set our walking speed
		local speed = 1
		-- determine where to look
		-- for a map tile, 8 + our
		-- speed of 1 gets the tile 
		-- directly to our right
		cx = cat.x + 9
		if(cat.running) then
			-- if we're running, go
			-- twice as fast
			speed += 1
			cx += 1
		end
		if(cat.faceleft) then
			-- if we're going left,
			-- invert the speed
			speed *= -1
			-- we also need to check to
			-- the left now instead
			cx = cat.x - (cat.running and 2 or 1)
		end

		-- see if there's a hard cell
		-- where we're trying to go.
		local cell = getcell(cx, cat.y + 4)
		if(cat.faceleft and hardright(cell)) then
			-- if we hit a wall to the
			-- left, stop (or slow down
			-- if running) and turn
			-- around
			cat.faceleft = false
			speed += 1
		elseif(not cat.faceleft and hardleft(cell)) then
			-- same for the right.
			cat.faceleft = true
			speed -= 1
		end

		cat.x += speed
	end
end

-- create a function to deal
-- with hit detection
function collides(obj_a, obj_b)
	-- first we determine our
	-- hitbox edges. the bottom is
	-- always + 8
	local right_a = obj_a.x + (obj_a.right or 8)
	local left_a = obj_a.x + (obj_a.left or 0)
	local right_b = obj_b.x + (obj_b.right or 8)
	local left_b = obj_b.x + (obj_b.left or 0)
	local top_a = obj_a.y + (obj_a.top or 0)
	local top_b= obj_b.y + (obj_a.top or 0)

	-- if the sprite's facing left
	-- way, we need to invert the
	-- side edges
	if(obj_a.faceleft) then
		right_a = obj_a.x + 8 - obj_a.left
		left_a =  obj_a.x + 7 - obj_a.right
	end
	if(obj_b.faceleft) then
		right_b = obj_b.x + 8 - obj_b.left
		left_b = obj_b.x + 7 - obj_b.right
	end

	-- check to see if we hit
	if(left_a > right_b or top_a > obj_b.y + 8 or right_a < left_b or obj_a.y + 8 < top_b) then
		return false
	end
	-- we missed!
	return true
end

function updateframe(obj)
	if(not obj.onground) then
		if(obj.jumping) then
			obj.jumptime += 1
		else
			obj.y += speed * step
			obj.jumptime = 36			
		end
	else
		obj.jumptime = 0
		if(obj.walking) then
			if(obj.running) then
				-- our cat can run, so let's
				-- handle that case too
				if(obj.frametime > 6) then
					obj.frameidx += 1
					if(obj.frameidx > 3) then
						obj.frameidx = 1
					end
					obj.frametime = 0
				end
			else
				if(obj.frametime > 10) then
					obj.frametime = 0
					obj.frameidx += 1	
				end
				if(obj.frameidx > 4) then
					obj.frameidx = 1
				end
			end
		elseif(not obj.crouched) then
			obj.frametime = 0
		end
	end
end

function getplayercell()
	return getcell(player.x + 4, player.y + 4)
end

function getleftcells(obj)
	local cells = {}
	cells.a = getcell(obj.x + 1, obj.y + 4)
	cells.b = getcell(obj.x + 1, obj.y + 7)
	return cells
end

function getrightcells(obj)
	local cells = {}
	cells.a = getcell(obj.x + 6, obj.y + 4)
	cells.b = getcell(obj.x + 6, obj.y + 7)
	return cells
end

function getbottomcells(obj)
	local cells = {}
	cells.a = getcell(obj.x + 3, obj.y + 8)
	cells.b = getcell(obj.x + 5, obj.y + 8)
	return cells
end

function getframe(obj)
	local frame = obj.frameidx
	if(not obj.onground) then
		if(obj.jumping) then
			frame = obj.jumpframe
		else
			frame = obj.fallframe
		end
	elseif(obj.walking) then
		-- make sure we handle the
		-- running case for the cat!
		if(obj.running) then
			frame = obj.run[obj.frameidx]
		else
			frame = obj.frames[obj.frameidx]
		end
	elseif(obj.crouched) then
		frame = obj.crouchframe
	else
		frame = obj.standframe
	end

	return frame
end

function getcell(wx, wy)
	local cell = {}
	cell.x = flr(wx / 8)
	cell.y = flr((wy + 12)/8)
	return cell
end

function round(number)
	return flr(number + .5)
end

function hardleft(cell)
	local cellid = mget(cell.x, cell.y)
	return fget(cellid, 1)
end

function hardright(cell)
	local cellid = mget(cell.x, cell.y)
	return fget(cellid, 2)
end

function hardtop(cell)
	local cellid = mget(cell.x, cell.y)
	return fget(cellid, 0)
end

function isexit(cell)
	local cellid = mget(cell.x, cell.y)
	return fget(cellid, 7)
end

-->8
-- demo switching

function loadnextdemo()
	load('music.p8', 'previous demo')	
end
__gfx__
002d2200002d2200002d2200002d2200002d2200002d2200028d2200220000000000000000000000000000000000000000000000000000000000000000000000
00822400008224000082240000822400008224000882440028224400022800000000000000000000000000000000000000000000000000002000000000000000
008244000082440000824400008244000082440008224400222244000282d200028d2200002d2200002000000020000000200000020000200200000000020000
00229a0000229a0000229a0000229a0000229a0002229a4004429a00022244002822440000822400020002020200020202000202020000dd0020002000200020
00024a0000024a000004aa400042a40000024a000049aa000009aa4000224400222244000082440002000ddd02000ddd02000ddd0200d1dd000dd0dd002000dd
000a4a00000aa4000009490000099a40000aa400049aad0000aaad0000049a4000029a4000229a40002dd1dd002dd1dd002dd1dd002dddd2002dd1dd0002d1dd
0000d5000001d50000050d00000d05000001dd0000d01000000d01000049aad00004aaa000024a9000ddddd000ddddd000ddddd0000dd0000000ddd00000ddd0
000011000000100000100100001001000000100001000000000010000000151000914a100091a410002020200202000200022020002d0000000000d200002200
00000000111111111000000130000003000000000000000000000000000000000000000000000000000000000000000000000006000000000000000060000000
000000001111115511000055b30000bb000000000000000000000000000000000000000000000000000000000000000000000077000000000000000066000000
0000000011111511111005113b300b33000000000000000000000000000000000033bb0000000000000000000000000000000766000000666600000066600000
000000001111115511115155b3b333bb000000bbbb000000000000000000000003bbbbb003b00000000000000000000000006677000066776666000066660000
0000000011115511111155113b33bb330000bb333333000000000000000000003bb3b4bb3bbb03b0000000000000000000067766000677666666600066666000
000000001155115511551155b3bb33bb00bb33bbbbbbbb0000000000000000003b43bbbb3bb43bbb000000000000000000776677007766776666660066666600
0000000015115511151155113b33bb330b33bb3333333330000000000000000003b434b0b4bbbb4b000000000000000007667766076677666666666066666660
00000000115511551155115533bb33bb33bb33bbbbbbbbbb00000000000000000444444004440440000000000000000066776677667766776666666666666666
5511551100000003300000000000000110000000bb33bb3300777700000000001111111115115511111111113333333300000006776677666666666660000000
11551155000000bbbb000000000000551100000033bb33bb0777777007700000111111111155115551111111bbbbbbbb00000077667766776666666666000000
5511551100000b33333000000000051111100000bb33bb3377777677777707701111111111115511151111113333333300000766776677666666666666600000
11551155000033bbbbbb0000000011551111000033bb33bb7777776777767777111111111111115551511111bbbbbbbb00006677667761551116666666660000
551155110003bb33333330000001551111111000bb33bb3367777767777767771111111111111511151511113333333300067766776655111111666666666000
1155115500bb33bbbbbbbb00005511551111110033bb33bb6777777767776776111111111111115551515111bbbbbbbb00776677665511551111116666666600
551155110b33bb33333333300511551111111110bb33bb3306667777766777001111111111111111151515113333333307667755551155111111111116666660
1155115533bb33bbbbbbbbbb115511551111111133bb33bb0006666667700000111111111111111151515151bbbbbbbb55dd55dd115511551111111111661111
33333333444444443333333333333333444444333344444433444444444443333344433300000000333333330000000077667766776677666666666666666666
33333333444444443333333333333333444443333334444433344444444444333334443300000000333333330000000066776677667766776666666666666666
44344434444444443334443444344333444444344344444433444444444443334344443400000000334443330000000077667766776677666666666666666666
44444444444444443334444444444433444444444444444433344444444444334444444400000000333444330000000011576677667766776666666666666111
44444444444444443344444444444333444444444444444433444444444443334444444400000000334443330000000055117766776677666666666666661111
44444444444444443334444444444433444444444444444433344444444444334444444400000000333444330000000011551177667766776666666666111111
44444444444444443344444444444333444444444444444433444444444443334444444400000000334443330000000055115511776677666666666611111111
44444444444444443344444444444433444444444444444433344444444444334444444400000000333444330000000011551155667766776666666611111111
000002222200000001111110011111111111111110011111111111000000000000000000000000000000000000000000000000000ff00ff0ff0000ff00000000
00002e222220000001188111011881888888818810118811888881100000000000000000000000000f0000f00f0000f000ffff00f000000ff000000f00066000
0002eee2222200000118881111188188888881881118881888888810000000000000000000f00f0000f00f00000ff0000f0000f0f00ff00f00f00f0066666666
00088e2244400000011888811118818811111188118881188111881000000000000ff000000ff000000ff00000f00f000f0ff0f0f0f00f000000000000665600
0082282253440000011888881118818811111188188811188111881000000202000ff000000ff000000ff00000f00f000f0ff0f000f00f000000000000666600
0022282443440000011888888118818811111188888110188111881000000ddd0000000000f00f0000f00f00000ff0000f0000f0f00ff00f00f00f0000066000
02228224444440000118818888188188888811888811001881118810002dd1dd00000000000000000f0000f00f0000f000ffff00f000000ff000000f00000000
02222224e4440000011881188888818888881188888110188111881000d222d000000000000000000000000000000000000000000ff00ff0ff0000ff00000000
022222444440000001188111888881881111118818881118811188100006660000aaaa00009aaa00000aa000000aa00000aaa900000000000000000000000000
02222244420000000118811118888188111111881188811881118810006656600a0000a009a009a000a99a00000aa0000a900a90000000000000000000000000
022299a7779900000118811111888188888881881118881888888810000666000a0000a009a009a000a99a00000aa0000a900a9000066500000aa90000000000
0029999a79a990000118811111188188888881881111881188888110000060000a0000a009a009a000a99a00000aa0000a900a900065065000a90a9000000000
0009999aaaaa90000111111011111111111111111011111111111110000560000a0000a009a009a000a99a00000aa0000a900a900065065000a90a9000000000
0000444aaaaa00000111111001111111111111111001110111111100000065000a0000a009a009a000a99a00000aa0000a900a900065065000a90a9000000000
0004449a999440000000000000000000000000000000000000000000000560000a0000a009a009a000a99a00000aa0000a900a9000066500000aa90000000000
0004409aaa94440000000000000000000000000000000000000000000000000000aaaa00009aaa00000aa000000aa00000aaa900000000000000000000000000
0044409aaaa044400000000000000000000000000000000000000000000009000000009999000000000011111111000000001111111100000000111111110000
04440099aa9004440000000000000000000900000000009000000099900092900000992222900000000155555555100000012155551210000001222112221000
444009aaaaaa004400000000002222000092900900000929000009222900929000092299992900000015cccccccc5100001221cccc1221000012222112222100
44409aaaaaaaa00000000000022002200092909290000929000092992290929000929900092900000015cccccccc5100001221cccc1221000012222112222100
0009a9a9a9a9aa000000000022000022009290929000092290009290992992290092900092900000015cccccccccc510012221cccc1222100122222112222210
09aa9aa9a9aa9aaa0200020020000022092229222900092229092290009092290922900092900000015cccccccccc510012221cccc1222100122222112222210
009aaa9aaa9aaaa002ddd20000000022092922292900929929092900000009290929000009000000015cccccccccc510012221cccc1222100122222112222210
0000aaaaaaaaa0000dadad1000000220092992992900929922992900000009229929000000000000015cccccccccc510012221cccc1222100122222112222210
000005a505a500000ddedd1ddddd2220922909092900929229092900099009229929000000000000015cccccccccc510012221cccc1222100122222112222210
00000d50005d000000ddd15dddddd200922900092900922929092900922900929929900000000000015cccccccccc510012221cccc1222100122222112222210
0000dd0000dd0000000015dddddddd009290000929092299229922900929009299229000000000000f5cccccccccc5f0012f21cccc12f2100122f92112f92210
0001dd1000dd100000000ddddddddd00929000922992290092909290092900922992900000000000095cccccccccc590012921cccc1292100122992112992210
0001111001d1100000000dd555ddddd0929000929009290092909299929290922992990009900000015cccccccccc510012221cccc1222100122222112222210
00011110011110000000dd500055ddd0929000929092900092909222299290092909229992290000015333333333351001222133331222100122222112222210
0015110001115100000dd05005500d20090000090092900092900992299290092900992229900000015333333333351001222133331222100122222112222210
01111100011111100022002022002200000000000009000009000009900900009000009990000000015333333333351001222133331222100122222112222210
00320202028282829202020202028282828282822102020202828282824200000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
32020202028282828292020202028282828282110202020202828282828242000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004151000000415100000041510000004151000000415100000041510000004151000000415100000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001252b222001252b222001252b222001252b222001252b222001252b222001252b222001252b222000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
125252b2b2315252b2b2315252b2b2315252b2b2315252b2b2315252b2b2315252b2b2315252b2b2220000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000263600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000273700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04140024344454640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05150025354555650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06160046566676869600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07170047576777879700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101030501010305010007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000026270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000026270000000000000000000000000000262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000002627000000000000000000000000000000002627000000000026270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2627000000000000000000000000000000262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000262700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000026270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000026270000000000000000000000000000000000000000000000002627000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000191818000000000000000000000000000000000000000000003631000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000001918000000000000000032303030330000000000000000000000000000000000000000003631000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000323300000000000000003631313134330000000000000000000000000000006e6f0000003631000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000181900001932353433181800001932303531313131371918190000000000000000000000007e7f0000323531000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030353131343030303030353131313131313430303030303030303030303030303030303030353131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313131313131313131313131313131313131313131313131313131313131313131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000001d1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000001c3d3e1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000001c3d3d3e3e1f000000000000001d1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001d1e000000002c2d3c2d2e3f2e2f00000000002c2d2e2f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000002c2d2e2f00002320202020282828282400000023202028282400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000232020282824232020202020282828282824002320202028282824000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000c53010531135311753118531005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010200000c61018033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000c6101a033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00002453530530305213051130515005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
