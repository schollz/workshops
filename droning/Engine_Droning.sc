// CroneEngine_Droning
Engine_Droning : CroneEngine {

	//////// 1 ////////
	// we will initialize variables here
	// the only variable we need is one
	// to store the synth we create
	var synthDrone;


	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {

		//////// 2 ////////
		// define the drone here!
		SynthDef("TheDrone", {
    arg freq=110.0,amp=0;
    var local, in, ampcheck,movement, snd;

	in = Splay.ar(Pulse.ar(Lag.kr(freq*
		LinLin.kr(SinOsc.kr(LFNoise0.kr(1)/2),-1,1,0.99,1.01),1),
		LinLin.kr(SinOsc.kr(LFNoise0.kr(1)),-1,1,0.45,0.55)
	)!1)/1;
	in = Balance2.ar(in[0] ,in[1],SinOsc.kr(
		LinLin.kr(LFNoise0.kr(0.1),-1,1,0.05,0.2)
	)*0.1);

	// from tape example
	// https://depts.washington.edu/dxscdoc/Help/Classes/LocalOut.html
    ampcheck = Amplitude.kr(Mix.ar(in));
    in = in * (ampcheck > 0.02); // noise gate
    local = LocalIn.ar(2);
    local = OnePole.ar(local, 0.4);
    local = OnePole.ar(local, -0.08);
    local = Rotate2.ar(local[0], local[1],0.2);
	local = DelayN.ar(local, 0.3,
		VarLag.kr(LinLin.kr(LFNoise0.kr(0.1),-1,1,0.15,0.3),1/0.1,warp:\sine)
	);
    local = LeakDC.ar(local);
    local = ((local + in) * 1.25).softclip;

	// for the drone
    local = LPF.ar(local,
		VarLag.kr(LinLin.kr(LFNoise0.kr(0.3),-1,1,ArrayMin.kr([freq,80]),16000),1/0.3,warp:\sine)
	);
	LocalOut.ar(local*
		VarLag.kr(LinLin.kr(LFNoise0.kr(2),-1,1,1.01,1.5),1/2,warp:\sine)
	);
	snd = Balance2.ar(local[0] * 0.2,local[1]*0.2,SinOsc.kr(
		LinLin.kr(LFNoise0.kr(0.1),-1,1,0.05,0.2)
	)*0.1)*amp;
	Out.ar(0,snd);
			// arg amp=0,freq=220;
			// var snd;
			// snd=Saw.ar(freq:[freq,freq/2],mul:[amp,amp/10]);
			// snd=Mix.ar(snd);
			// snd=Splay.ar(snd);
			// Out.ar(0,snd);
		}).add;


        context.server.sync;

		//////// 3 ////////
		// create the drone here!
		// it will run forever :)
        synthDrone = Synth("TheDrone", target:context.xg);

        context.server.sync;

		//////// 4 ////////
		// define commands for the lua
		// script here
        this.addCommand("amp","f", { arg msg;
        	synthDrone.set(\amp,msg[1]);
        });
        this.addCommand("hz","f", { arg msg;
        	synthDrone.set(\freq,msg[1]);
        });
        this.addCommand("note","i", { arg msg;
        	synthDrone.set(\freq,msg[1].midicps);
        });

	}


    free {
		//////// 5 ////////
		// free any variable we create
		// otherwise it won't ever stop!
		synthDrone.free;
    }
}
