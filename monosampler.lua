-- aaasample

engine.name="SimpleSample"

onsets = {}
function init()
  osc.event=function(path,args,from)
	  if path=="onset" then
	  	local new_onset = tonumber(args[2])
	  	print(new_onset)
	  	table.insert(onsets,new_onset)
	  end
  end

  -- https://monome.org/docs/norns/study-4/
  m = midi.connect(1)
  m.event = function(data)
  	tab.print(data)
  	local d = midi.to_msg(data)
  	if d.type == "note_on" then 
  		local note = d.note  
  		local sample = d.note % (#onsets-1)+1
		engine.play(onsets[sample],onsets[sample+1],1)
  	end
  end

  engine.loadwav("/home/we/dust/code/aaasample/boombap.wav",0.4)
end


