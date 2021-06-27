//////// 0 ////////
// again choose any buffer you want
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_16beats_bpm90.wav");
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_24beats_bpm90.wav");
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_32beats_bpm90.wav");
// lets load another buffer
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums1_8beats_bpm90.wav");
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums2_8beats_bpm90.wav");
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums3_8beats_bpm90.wav");




//////// 1 ////////
// lets add some fx to this sample plyaer!
// how would we add in a "reverse" fx?
(
SynthDef("samplePlayer", {
	arg out=0, bufnum=0, rate=1, rateLag=0,start=0, end=1, reset=0, t_trig=0,
	loops=1, amp=0.5,fx_scratch=0,fx_reverse;
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
	// the scratch fx from part 1
	rate=((fx_scratch<1)*rate)+((fx_scratch>0)*SinOsc.kr(fx_scratch));

	// a reverse effect...
	rate=((fx_reverse>0)*rate.neg)+((fx_reverse<1)*rate);
	rate.poll;

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

	Out.ar(out,snd)
}).add;
)

// lets play them in sync
(
t.stop;
x.free;
y.free;
~bpm=90;
x=Synth("samplePlayer", [\out, 0, \bufnum, ~bufferPiano,\rate,~bpm/90,\amp,0.3]);
y=Synth("samplePlayer", [\out, 0, \bufnum, ~bufferDrums,\rate,~bpm/90]);
~sequence1=[
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
];
~sequence2=[
	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,
];
t = Task({
	inf.do({ arg iterator;
		var toPlay;
		toPlay = ~sequence1[iterator%~sequence1.size];
		if (toPlay>0,{
			toPlay.postln;
			x.set(\t_trig,1,\start,(toPlay-1)/(4),\end,1,\loops,1);
		},{});
		toPlay = ~sequence2[iterator%~sequence2.size];
		if (toPlay>0,{
			y.set(\t_trig,1,\start,(toPlay-1)/(8*4),\end,1,\loops,1);
		},{});
		(60/~bpm/4).wait;
	});
}).play;
)

// play with effects
x.set(\fx_scratch,4.5)
x.set(\fx_scratch,0)
y.set(\fx_scratch,5.5)
y.set(\fx_scratch,0)
x.set(\fx_reverse,1)
x.set(\fx_reverse,0)

// play with modifying sequencer
(
~bpm=90;
x.set(\rate,~bpm/90);
y.set(\rate,~bpm/90);
~sequence1=[
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,
	2,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,
	3,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,
	4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
];
~sequence2=[
	16,12,13,14,15,0,0,8,9,10,11,12,13,14,15,16,
	1,2,1,2,3,4,1,2,9,10,11,12,13,14,15,16,
];
)
y.set(\rate,~bpm.neg/90);