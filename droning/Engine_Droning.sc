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
			arg amp=0,freq=220;
			var snd;
			snd=Saw.ar(freq:[freq,freq/2],mul:[amp,amp/10]);
			snd=Mix.ar(snd);
			snd=Splay.ar(snd);
			Out.ar(0,snd);
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
