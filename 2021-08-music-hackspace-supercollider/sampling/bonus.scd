//////// 0 ////////
// setup a very rudimentary sequencer in SuperCollider

// load the player from end of part 3
(
SynthDef("samplePlayer", {
	arg out=0, bufnum=0, rate=1, rateLag=0.2,start=0, end=1, reset=0, t_trig=1,
	loops=1, amp=0.5;
	var snd,snd1,snd2,pos,pos2,frames,duration,env;
	var startA,endA,startB,endB,resetA,resetB,crossfade,aOrB;

	// latch to change trigger between the two
	aOrB=ToggleFF.kr(t_trig);
	startA=Latch.kr(start,aOrB);
	endA=Latch.kr(end,aOrB);
	resetA=Latch.kr(reset,aOrB);
	startB=Latch.kr(start,1-aOrB);
	endB=Latch.kr(end,1-aOrB);
	resetB=Latch.kr(reset,1-aOrB);
	crossfade=Lag.ar(K2A.ar(aOrB),0.05);

	rate = Lag.kr(rate,rateLag);
	rate = rate*BufRateScale.kr(bufnum);

	frames = BufFrames.kr(bufnum);
	duration = frames*(end-start)/rate.abs/s.sampleRate*loops;

	// envelope to clamp looping
	env=EnvGen.ar(
		Env.new(
			levels: [0,1,1,0],
			times: [0,duration-0.05,0.05],
		),
		gate:t_trig,
	);

	pos=Phasor.ar(
		trig:aOrB,
		rate:rate,
		start:(((rate>0)*startA)+((rate<0)*endA))*frames,
		end:(((rate>0)*endA)+((rate<0)*startA))*frames,
		resetPos:(((rate>0)*resetA)+((rate<0)*endA))*frames,
	);
	snd1=BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:pos,
		interpolation:4,
	);

	// add a second reader
	pos2=Phasor.ar(
		trig:(1-aOrB),
		rate:rate,
		start:(((rate>0)*startB)+((rate<0)*endB))*frames,
		end:(((rate>0)*endB)+((rate<0)*startB))*frames,
		resetPos:(((rate>0)*resetB)+((rate<0)*endB))*frames,
	);
	snd2=BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:pos2,
		interpolation:4,
	);

	snd = (crossfade*snd1)+((1-crossfade)*snd2) * env * amp;

	snd=Decimator.ar(snd,MouseX.kr(800,44100,1),MouseX.kr(8,32));

	snd=LPF.ar(snd,MouseY.kr(20,20000,1));

	Out.ar(out,snd)
}).add;
)


//////// 1 ////////
// a simple sequencer - play two sounds in sync
// lets play them in sync
(
s.makeBundle(nil,{
	// set tempo
	~bpm=120;
	// load files and their bpms and their beate numbers
	~files=["pad2_64beats_bpm100.wav","drums1_8beats_bpm90.wav"];
	~bpms=[100,90];
	~beats=[64,8];
	// load the files into buffers
	~buffers=Array.fill(2,{arg i;
		Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/"++~files[i]);
	});
	// array to keep track of positions
	~pos=Array.fill(2,{arg i; 0});
	s.sync;

	// make the synths
	~synths=Array.fill(2,{arg i;
		Synth("samplePlayer", [\out, 0, \bufnum, ~buffers[i].bufnum,\rate,~bpm/~bpms[i]]);
	});

	// rudimentary sequencer using "Task" and ().wat
	~syncEvery=2; // beats
	t = Task({
		inf.do({ arg beat;
			2.do({arg j;
				var pos2;
				~pos[j]=((beat*~syncEvery)%~beats[j])/~beats[j];
				~pos[j].postln;
				pos2=~pos[j]+(~syncEvery/~beats[j])+0.01;
				~synths[j].set(\t_trig,1,\reset,~pos[j],\start,~pos[j],\end,pos2);
			});
			(60/~bpm*~syncEvery).wait;
		});
	}).play;
});
)

// effects based on the start/stop/rates!
~synths[0].set(\t_trig,1,\reset,~pos[0],\start,~pos[0],\end,~pos[0]+(0.125/~beats[0]),\loops,10)
~synths[1].set(\t_trig,1,\reset,~pos[1],\start,~pos[1],\end,~pos[1]+(0.125/~beats[1]),\loops,10)
~synths[0].set(\rate,~bpm.neg/~bpms[0]);
~synths[0].set(\rate,~bpm/~bpms[0]);
~synths[1].set(\rate,~bpm.neg/~bpms[1]);
~synths[1].set(\rate,~bpm/~bpms[1]);
