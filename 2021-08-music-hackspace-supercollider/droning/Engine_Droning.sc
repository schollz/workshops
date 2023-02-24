//////// 0 ////////
// name your engine - Engine_Droning should match the filename
Engine_Droning : CroneEngine {

	//////// 1 ////////
	// we will initialize variables here
	// the only variable we need is one
	// to store the synth we create
	var synthDrone;

	// don't change this
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	// alloc is where we will define things
	alloc {

		//////// 2 ////////
		// define the drone here!
		SynthDef("TheDrone", {
		    arg freq=110.0,amp=0;
		    var snd;
		    snd=SinOsc.ar([freq,freq+2]);
			Out.ar(0,snd*amp);
		}).add;

		context.server.sync;

		//////// 3 ////////
		// create the drone here!
		// it will run forever :)
        synthDrone = Synth("TheDrone", target:context.server);

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
