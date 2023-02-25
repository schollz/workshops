(
s.waitForBoot({
	~drones=List.new();
	PathName.new(thisProcess.nowExecutingPath.dirname++"/library").files.do({ arg v,i;
		if (v.asAbsolutePath.load.isNil,{
			("error parsing"+v.fileNameWithoutExtension+". see message above ^").postln;

		},{
			~drones.add(v.fileNameWithoutExtension);
			("added"+v.fileNameWithoutExtension).postln;
		});
	});

	// make a SynthDef for effects
	SynthDef("effects",{
		// grab the sound before its output to the speakers
		// default bus is "0"
		var snd = In.ar(0,2);

		// add reverb
		snd = SelectX.ar(MouseY.kr(0.025,0.5),[snd,Fverb.ar(snd[0],snd[1],60,decay:70)]);

		// limit the sound
		snd = Limiter.ar(snd,6.neg.dbamp);

		// replace the output
		ReplaceOut.ar(0,snd);
	}).add;


	// sync the SuperCollider server
	s.sync;


	// start the effets synth
	Synth.tail("effects");
	x=Synth("ducks",[\hz,60]);
});
)

x=Synth("toshiya",[\hz,60*4]);
x=Synth("starlids",[\hz,60*4]);
x.set(\gate,0);
