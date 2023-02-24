-- two turntables
--
-- play samples!

-- we will define the engine
-- "engine" is a special variable
-- engine.name="X" will look for Engine_X.scd in all the folders
engine.name="Sampling"

-- we will use "lattice" for sequencing
lattice=require "lattice"

-- a list of the samples that are available
sample_data={
  {file="upright_16beats_bpm90.wav",bpm=90,beats=16},
  {file="upright_24beats_bpm90.wav",bpm=90,beats=24},
  {file="upright_32beats_bpm90.wav",bpm=90,beats=32},
  {file="pad1_32beats_bpm140.wav",bpm=140,beats=32},
  {file="pad2_64beats_bpm100.wav",bpm=100,beats=64},
  {file="drums1_8beats_bpm90.wav",bpm=90,beats=8},
  {file="drums2_8beats_bpm90.wav",bpm=90,beats=8},
  {file="drums3_8beats_bpm90.wav",bpm=90,beats=8},
  {file="drums4_16beats_bpm150.wav",bpm=150,beats=16},
}
samples={sample_data[1],sample_data[2]}

-- we will define the "init()" function,
-- a special function that runs when the script starts
function init()

  -- lets add some parameters
  -- add a parameter to control the volume
  -- add one parameter for each of the two samples
  params:add{type="control",id="fader",name="fader",
    -- controlspec is the control
    -- this one goes from 0-1, linearly, default is 0.0 and the
    -- step size is 0.01 and it shows the word "amp" next to it
    controlspec=controlspec.new(-1,1,'lin',0,0.0,'amp',0.02/1),
    action=function(v)
      -- equal power crossfade: the the squares of the two crossfade gains should add to 1
      if v>0 then
        engine.amp(2,math.sqrt(0.5+v/2))
        engine.amp(1,math.sqrt(0.5-v/2))
      else
        engine.amp(1,math.sqrt(0.5+v/-2))
        engine.amp(2,math.sqrt(0.5-v/-2))
      end
    end
  }
  for i=1,2 do
    params:add{type="control",id="rate"..i,name="rate"..i,
      -- controlspec is the control
      -- this one goes from -1-1, linearly, default is 1 and the
      -- step size is 0.01 and it shows the word "x" next to it
      controlspec=controlspec.new(-1,1,'lin',0,1,'x',0.05/1),
      action=function(v)
        print("new rate for sound "..i..": "..v)
        engine.rate(i,v*clock.get_tempo()/samples[i].bpm)
      end
    }
    params:add{type="control",id="sample"..i,name="sample"..i,
      controlspec=controlspec.new(1,#sample_data,'lin',0,0.0,'',1/(#sample_data-1)),
      action=function(v)
        samples[i]=sample_data[math.floor(v)]
        engine.sample(i,_path.code.."ambulation/sampling/"..samples[i].file)
        engine.rate(i,params:get("rate"..i)*clock.get_tempo()/samples[i].bpm)
      end
    }
  end

  -- the lattice
  -- this keeps track of every beat
  latticeclock=lattice:new()
  local division=1/4 -- half notes
  latticeclock:new_pattern{
    division=division,
    action=function(t)
      local beat=t/latticeclock.ppqn -- get beat by dividing by parts-per-quarternote
      print("beat: "..beat)
      for i=1,2 do
        -- sync the samples
        samples[i].pos=(beat%samples[i].beats)/samples[i].beats
        local posEnd=samples[i].pos+(1.2/samples[i].beats)*(4*division)
        engine.pos(i,samples[i].pos,posEnd)
      end
    end
  }
  latticeclock:start()

  -- set defaults
  for i=1,2 do
    params:set("rate"..i,1)
  end
  params:set("fader",-1)
  params:set("sample1",5)
  params:set("sample2",6)

  params:bang()

  -- update drawing
  clock.run(redrawer)
end

-- key(<key>,<off/on>) is a special function
-- that listens to the norns keys
function key(k,z)
  if k==1 then
    -- ANY FX YOU WANT!
  elseif k==2 then
    -- ANY FX YOU WANT!
  elseif k==3 then
    -- ANY FX YOU WANT!
  end
end

-- enc(<knob>,<turn>) is a special function
-- that listens to the turn of the knob
function enc(k,d)
  if k==1 then
    params:delta("fader",d)
  elseif k==2 then
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
  screen.text_center("fader: "..math.floor(params:get("fader")*100)/100)
  screen.move(64,30)
  screen.text_center("rate 1: "..math.floor(params:get("rate1")*10)/10)
  screen.move(64,40)
  screen.text_center("rate 2: "..math.floor(params:get("rate2")*10)/10)
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
