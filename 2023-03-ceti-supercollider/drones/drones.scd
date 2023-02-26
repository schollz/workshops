(
s.options.memSize = 32*8192;
s.waitForBoot({
	var size;

	var buf=Buffer.alloc(s,48000*240,2);
	// make a SynthDef for effects
	SynthDef("fx",{
		// grab the sound before its output to the speakers
		// default bus is "0"
		var snd = In.ar(0,2);

		// add reverb
		// snd = SelectX.ar(MouseY.kr(0.025,0.5),[snd,Fverb.ar(snd[0],snd[1],60,decay:LFNoise2.kr(1/3).range(70,90))]);

		// delay
		//snd = CombC.ar(snd,0.15,0.15,4);

		// limit the sound
		snd = Limiter.ar(snd,6.neg.dbamp);

		// replace the output
		ReplaceOut.ar(0,snd);
	}).send(s);


	~drones=List.new();
	PathName.new(thisProcess.nowExecutingPath.dirname++"/library").files.do({ arg v,i;
		if (v.asAbsolutePath.load.isNil,{
			("error parsing"+v.fileNameWithoutExtension+". see message above ^").postln;

		},{
			~drones.add(v.fileNameWithoutExtension);
			("added"+v.fileNameWithoutExtension).postln;
		});
	});


	// sync the SuperCollider server
	s.sync;


	// start the effects synth
	~play={
		arg name,hz=220;
		var startFx=false;
		if (~fx.isNil,{
			startFx=true;
		},{
			if (~fx.isRunning,{},{
				startFx=true;
			});
		});

		if (startFx,{
			~fx=Synth.tail(s,"fx");
			NodeWatcher.register(~fx);
		});
		Synth.before(~fx,name,[\hz,hz,\buf,buf]);
	};

	x=~play.value("sine",120)

});
)

