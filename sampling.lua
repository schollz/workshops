-- sampling
--
-- play samples!

-- we will define the engine
-- "engine" is a special variable
-- engine.name="X" will look for Engine_X.scd in all the folders
engine.name="Sampling"

-- we will use "lattice" for sequencing
lattice=require "lattice"

-- a list of the samples that are available
samples={
  {name="upright_16beats_bpm90.wav",bpm=90,beats=16},
  {name="drums1_8beats_bpm90.wav",bpm=90,beats=8},
}

-- we will define the "init()" function, 
-- a special function that runs when the script starts
function init()

  -- lets add some parameters
  for i=1,2 do
    params:add{type="control",id="rate"..i,name="rate"..i,
      -- controlspec is the control
      -- this one goes from -1-1, linearly, default is 1 and the
      -- step size is 0.01 and it shows the word "x" next to it
      controlspec=controlspec.new(-1,1,'lin',0,1,'x',0.01/2),
      action=function(v)
        print("new rate for sound "..i..": "..v)
        engine.rate(i,v)
      end
    }
  end

  -- the lattice
  local latticeclock=lattice:new()
  latticeclock:new_pattern{
    division=1/4,
    action=function(t)
      print(t)
    end
  }

  -- update drawing
  clock.run(redrawer)
end

-- key(<key>,<off/on>) is a special function
-- that listens to the norns keys
function key(k,z)
end

-- enc(<knob>,<turn>) is a special function
-- that listens to the turn of the knob
function enc(k,d)
  if k==2 then
    params:delta("rate1",d)
  elseif k==3 then
    params:delta("rate2",d)
  end
end

-- redraw is a special function that will
-- draw stuff on the screen
function redraw()
  -- https://monome.org/docs/norns/api/modules/screen.html
  screen.clear()
  screen.level(15)
  screen.font_size(8)
  screen.move(64,20)
  screen.text_center("rate 1: "..params:get("rate1"))
  screen.move(64,30)
  screen.text_center("rate 2: "..params:get("rate2"))
  screen.update()
end


--
-- my functions
--

-- redrawer simply constantly redraws the screen
function redrawer()
  while true do
    clock.sleep(1/15)
    redraw()
  end
end
