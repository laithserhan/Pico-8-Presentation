pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- ok, we'll move
-- bright moth games

step = .03333 -- our framerate, 1/30

function _init()
	menuitem(1, "next demo", loadnextdemo)
	frames = { 3, 4, 2, 1}
	frametime	= 0
	frameidx = 1
	
	-- lets define a movement speed
	speed = 30
	-- we'll also need some 
	-- variables to track our 
	-- position
	x,y = 60, 60
	-- and whether or not we're
	-- walking
	walking = false
	-- and finally, if we're
	-- facing left or not
	left = false
end

function _update()
	frametime += 1
	-- always reset our walking
	-- flag so the walking
	-- animation doesn't play if
	-- we aren't moving
	walking = false
	
	-- if we pressed left...
	if(btn(0)) then
		-- move left, set our walking
		-- and facing left flags to
		-- true
		x -= speed * step 
		walking = true 
		left = true
	end
	
	-- if we pressed right...
	if(btn(1)) then
		-- move right, set our walking
		-- flag to true and our facing
		-- left flag to false
		x += speed * step 
		walking = true 
		left = false
	end
	
	-- if we're walking
	if(walking) then
		-- do all the frame updating
		-- stuff we just coded in 
		-- the last demo.
		if(frametime > 5) then
			frametime = 0 
			frameidx += 1
		end
		if(frameidx > 4) then
			frameidx = 1
		end
	else
		-- otherwise, reset the
		-- animation state.
		frametime = 0
		frameidx = 1
	end
end

function _draw()
	cls(12)
	map(0, 0, 0, 28, 16, 16)
	if(walking) then
		-- if we're walking, draw our
		-- animation pass in our
		-- facing left flag to flip
		-- the sprite if necessary
		spr(frames[frameidx], x, y, 1, 1, left)
	else 
		-- draw our standing still
		-- frame.
		spr(0,x,y,1,1,left) 
	end
	print("control", 100, 122, 7)
end

-->8
-- demo switching

function loadnextdemo()
	load('jump.p8', 'previous demo')	
end
__gfx__
002d2200002d2200002d2200002d2200002d2200002d2200028d2200000000000000000000000000000000000000000000000000000000000000000000000000
00822400008224000082240000822400008224000882440028224400000000000000000000000000000000000000000000000000000000000000000000000000
00824400008244000082440000824400008244000822440022224400002d22000000000000000000000000000000000000000000000000000000000000000000
00229a0000229a0000229a0000229a0000229a0002229a4004429a00008244000000000000000000000000000000000000000000000000000000000000000000
00024a0000024a000004aa400042a40000024a000049aa000009aa40008244000000000000000000000000000000000000000000000000000000000000000000
000a4a00000aa40000094a0000099a40000aa400049aad0000aaad0000229a400000000000000000000000000000000000000000000000000000000000000000
0000d1000000d10000010d00000d01000000dd000010d00000010d00000244900000000000000000000000000000000000000000000000000000000000000000
0000d1000000d00000100d0000d0010000001000010000000000100000919ad00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3b3b3b444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b3b3b3444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44344434444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131313131313131313131313131313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
