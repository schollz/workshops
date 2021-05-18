-- droning
-- 
-- play a drone!

-- //////// 1 ////////
-- we will define the engine
engine.name="Droning"

-- //////// 2 ////////
-- this variable keeps track of if we are playing
play_sound = false

function init()
  -- //////// 2 ////////
  -- this variable keeps track of if we are playing
  -- add some parameters!
  params:add{type="control",id="amp",name="amp",
  	controlspec=controlspec.new(0,1.0,'lin',0,0.5,'amp',0.01/0.5),
  	action=function(v)
  	print("new amp: "..v)
  end
  }
  params:add{type="control",id="midi",name="midi",
  	controlspec=controlspec.new(0,100,'lin',0,60,'',1/100),
  	action=function(v)
  	print("new midi note: "..v)
  end
  }


  setup_midi()

  -- update drawing
  clock.run(redrawer)
end

function setup_midi()
  -- connect to every midi device :)
  for _,dev in pairs(midi.devices) do
    print("connected to "..dev.name)
    m = midi.connect(dev.port)
    m.event = function(data)
      local d = midi.to_msg(data)
      if d.type == "note_on" then 
        print(d.note)
      end
    end
  end
end

function key(k,z)
	if z==1 then 
		play_sound = not play_sound
		if play_sound then 
			print("playing sound!")
		end
	end
end

function enc(k,d)
	if k==2 then 
		params:delta("midi",d)
	elseif k==3 then 
		params:delta("amp",d)
	end
end

function redrawer()
	while true do
		clock.sleep(1/15)
		redraw()
	end
end

function redraw()
	screen.clear()
	screen.level(15)
	screen.font_size(16)
	screen.move(64,32)
	if play_sound then
		screen.text_center("press any key to stop")
	else
		screen.text_center("press any key to drone")
	end
	screen.update()
end


