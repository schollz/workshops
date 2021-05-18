-- simplesampler
-- 
-- loads a thing and maps to keyboard

engine.name="AmpleSamples"

current_sample=-1
onsets = {}
function init()
    -- osc messages will come in with the onsets
  osc.event=function(path,args,from)
      if path=="onset" then
        local new_onset = tonumber(args[2])
        print(new_onset)
        table.insert(onsets,new_onset)
      end
  end

  -- https://monome.org/docs/norns/study-4/
  for _,dev in pairs(midi.devices) do
    print("connected to "..dev.name)
      m = midi.connect(dev.port)
      m.event = function(data)
        local d = midi.to_msg(data)
        if d.type == "note_on" then 
            print(d.note)
            local note = d.note  
            local sample = (d.note-48) % (#onsets-1)+1
            current_sample=sample
            engine.play(onsets[sample],onsets[sample+1],1)
        end
      end
  end

  -- load a file
  threshold=0
  engine.loadwav("/home/we/dust/code/ambulation/sampling/rhodes_bpm70_amin.wav",0)

  if threshold == 0 then
    -- default onsets
    table.insert(onsets,0)
    for i=1,32 do 
      table.insert(onsets,i/32)   
    end
  end

    -- update drawing
  clock.run(redrawer)
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
    if current_sample > -1 then
        screen.text_center(current_sample)
    end
    screen.update()
end


