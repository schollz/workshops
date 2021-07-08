-- droning
--
-- play a drone!

-- we will define the engine
-- "engine" is a special variable
-- engine.name="X" will look for Engine_X.scd in all the folders
engine.name="Droning" -- this will look for Engine_Droning.scd

-- we will import the "musicutil" library
-- https://monome.org/docs/norns/api/modules/lib.MusicUtil.html
-- useful for converting midi to note names
musicutil=require "musicutil"

-- this is a variable we will use
-- to keep track if a drone is playing or not
play_sound=false

-- we will define the "init()" function, 
-- a special function that runs when the script starts
function init()
  engine.amp(0) -- default is off

  -- lets add some parameters
  params:add{type="control",id="amp",name="amp",
    -- controlspec is the control
    -- this one goes from 0-1, linearly, default is 0.5 and the
    -- step size is 0.01 and it shows the word "amp" next to it
    controlspec=controlspec.new(0,1.0,'lin',0,0.5,'amp',0.01/0.5),
    action=function(v)
      print("new amp: "..v)
      if play_sound then
        engine.amp(v) -- engine.amp comes from the Engine_Droning
      end
    end
  }
  params:add{type="control",id="midi",name="midi",
    controlspec=controlspec.new(0,100,'lin',0,60,'',1/100),
    action=function(v)
      print("new midi note: "..v)
      engine.note(v) -- engine.note comes from the Engine_Droning
    end
  }


  -- this block of code looks at the connected
  -- midi devices (midi.devices) and connects to all of them
  for _,dev in pairs(midi.devices) do
    print("connected to "..dev.name)
    m=midi.connect(dev.port)
    -- m.event is a special function that runs on incoming midi msgs
    m.event=function(data)
      local d=midi.to_msg(data)
      if d.type=="note_on" then
        engine.note(d.note)
      end
    end
  end

  -- update drawing
  clock.run(redrawer)
end

-- key(<key>,<off/on>) is a special function
-- that listens to the norns keys
function key(k,z)
  if z==1 then
    play_sound=not play_sound
    if play_sound then
      print("playing sound!")
      engine.amp(params:get("amp"))
    else
      print("stopping sound!")
      engine.amp(0)
    end
  end
end

-- enc(<knob>,<turn>) is a special function
-- that listens to the turn of the knob
function enc(k,d)
  if k==2 then
    params:delta("midi",d)
  elseif k==3 then
    params:delta("amp",d)
  elseif k==1 then
    -- TODO: add your own modulation
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
  if play_sound then
    screen.text_center("press any key to stop")
  else
    screen.text_center("press any key to drone")
  end
  screen.move(64,30)
  screen.text_center("note: "..musicutil.note_num_to_name(math.floor(params:get("midi")),true))
  screen.move(64,40)
  screen.text_center("amp: "..params:get("amp"))
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
