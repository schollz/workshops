// CroneEngine_SimpleSample
Engine_SimpleSample : CroneEngine {

	var sampleBuff;
	var samplePlayer;
    var osfun;


	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {

		// sample loading + onset detection
		sampleBuff = Buffer.new(context.server);

		SynthDef("OnsetDetection", {
			arg bufnum, out, threshold=0.4;
			var sig, chain, onsets, pips, pos, env, speedup=1;
			
			env=EnvGen.ar(
				Env.new(
					levels: [0,1,1,0],
					times: [0,BufDur.kr(bufnum)/speedup,0],
					curve:\sine,
				),
				doneAction: Done.freeSelf
			);
			
			pos=Phasor.ar(0, BufRateScale.kr(bufnum)*speedup, 0, BufFrames.kr(bufnum),0);
			sig = BufRd.ar(2, bufnum, pos,0);
			
			chain = FFT(LocalBuf(512), sig[0]+sig[1]);
			
			onsets = Onsets.kr(chain, threshold, \rcomplex);
			
			// You'll hear percussive "ticks" whenever an onset is detected
			pips = WhiteNoise.ar(EnvGen.kr(Env.perc(0.001, 0.1, 0.2), onsets));
			SendTrig.kr(onsets,0,Clip.kr((pos-300)/BufFrames.kr(bufnum),0,1));
			Out.ar(out,Pan2.ar(sig, -0.75, 0.2) + Pan2.ar(pips, 0.75, 1));
		}).add;

		osfun = OSCFunc({ 
            arg msg, time; 
			[time, msg].postln;
			NetAddr("127.0.0.1", 10111).sendMsg("onset",0,msg[3]);
        },'/tr', context.server.addr);


        // sample playback

        SynthDef("CrossfadingPlayer", {
			// basic arguments
			arg out=0, bufnum=0,
			rate=1,fadeout=0.01,loops=1,
			t_trig, start,end;

			// variables
			var env,snd,crossfade;
			var startA=0,endA=1;
			var startB=0,endB=1;
			var aOrB=0;
			var bFrames;
			var sampleLength;

			// toggle between
			aOrB=ToggleFF.kr(t_trig);
			startA=Latch.kr(start,aOrB);
			endA=Latch.kr(end,aOrB);
			startB=Latch.kr(start,1-aOrB);
			endB=Latch.kr(end,1-aOrB);
			crossfade=Lag.ar(K2A.ar(aOrB),0.05);

			bFrames = BufFrames.kr(bufnum);
			sampleLength=loops*((aOrB*(endA-startA))+((1-aOrB)*(endB-startB)));
			env=EnvGen.ar(
				Env.new(
					levels: [0,1,1,0],
					times: [0,sampleLength*(bFrames/48000/rate.abs)-fadeout,fadeout],
					curve:\sine,
				),
				gate: t_trig,
			);

			snd=crossfade*BufRd.ar(2,bufnum,
				Phasor.ar(
					trig:aOrB,
					rate:BufRateScale.kr(bufnum)*rate,
					start:((startA*(rate>0))+(endA*(rate<0)))*BufFrames.kr(bufnum),
					end:((endA*(rate>0))+(startA*(rate<0)))*BufFrames.kr(bufnum),
					resetPos:startA*BufFrames.kr(bufnum)
				),
				interpolation:4
			);
			(1-aOrB);
			snd=snd+((1-crossfade)*BufRd.ar(2,bufnum,
				Phasor.ar(
					trig:(1-aOrB),
					rate:BufRateScale.kr(bufnum)*rate,
					start:((startB*(rate>0))+(endB*(rate<0)))*BufFrames.kr(bufnum),
					end:((endB*(rate>0))+(startB*(rate<0)))*BufFrames.kr(bufnum),
					resetPos:startB*BufFrames.kr(bufnum)
				),
				interpolation:4
			));

			Out.ar(out,snd*env);
		}).add;

        context.server.sync;

        samplePlayer = Synth("CrossfadingPlayer", target:context.xg);

        context.server.sync;

        // allow commands 
        this.addCommand("loadwav","sf", { arg msg;
            sampleBuff.free;
            sampleBuff = Buffer.read(context.server,msg[1],action:{
            	if (msg[2]>0,{
		            Synth("OnsetDetection",[\out,0,\bufnum,sampleBuff.bufnum,\threshold,msg[2]],target:context.xg);
        		},{});
            });
        });

        this.addCommand("play","fff", { arg msg;
        	samplePlayer.set(
        		\bufnum,sampleBuff,
        		\t_trig,1,
        		\start,msg[1],
        		\end,msg[2],
        		\loops,msg[3],
        	);
        });

	}


    free {
    	sampleBuff.free;
    	osfun.free;
    	samplePlayer.free;
    }
}
