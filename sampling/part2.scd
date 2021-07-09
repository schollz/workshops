// lets make a really nice sample player

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
// this is the basic sample player from before
(
SynthDef("samplePlayer1", {
	arg out = 0, bufnum = 0;
	var snd;
	snd=PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum));
	Out.ar(out,snd)
}).add;
)

x=Synth("samplePlayer1", [\bufnum, ~bufferPiano]);

// this works well, but what if we want to truncate the sample?
// PlayBuf.ar doesn't have any way to change the end position


//////// 2 ////////
// lets improve it!
// we can choose an end point if we use two UGens:
// Phasor is a ramp that we can control accurately and
// BufRd is a player that plays at any position you want
(
x=SynthDef("samplePlayer2", {
	arg out=0, bufnum=0, rate=1, start=0, end=1; // add start and end to arguments
	var snd,pos,frames;

	// rate is modified by BufRateScale to convert between sampling rates
	rate = rate*BufRateScale.kr(bufnum);
	// frames is the number of frames
	frames = BufFrames.kr(bufnum);

	// Phasor is a ramp
	pos=Phasor.ar(
		rate:rate,
		start:start*frames,
		end:end*frames,
		resetPos:start*frames,
	);

	// BufRd does the playing
	snd=BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:pos,
		loop:0,
		interpolation:4,
	);
	Out.ar(out,snd)
}).add;
)

// the Phasor is like a sawtooth that increments at a specific rate
// and returns to the beginning at the end OR if it receives a trigger.
// afaik there is no other UGen that is triggerable, loopable, and has start+end points.
{ Phasor.kr(0,0.5,0,100) }.plot(0.5)
{ Phasor.ar(0,0.005,50,90) }.plot(0.5)

// try it
// note: start and endpoints are denoting by fractional position (0 = start, 1 = end)
x=Synth("samplePlayer2", [\bufnum, ~bufferPiano]); // will start playing
x.set(\start,0.26,\end,0.28)
x.set(\start,0,\end,1)

// the problem with above is that you cannot reset the position quickly to any given setpoint
x.set(\start,0,\end,1) // play this many times fast, nothing happens!




//////// 3 ////////
// lets improve it!
// use a special argument, "x_trig" which serves as a "trigger"
// and can reset UGens, like Phasor
(
x=SynthDef("samplePlayer3", {
	arg out=0, bufnum=0, rate=1, start=0, end=1, t_trig=0;
	var snd,pos,frames;

	rate = rate*BufRateScale.kr(bufnum);
	frames = BufFrames.kr(bufnum);

	pos=Phasor.ar(
		trig:t_trig, // add in the trigger, when it is 1, it will reset
		rate:rate,
		start:start*frames,
		end:end*frames,
		resetPos:start*frames, // the reset position
	);

	snd=BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:pos,
		loop:0,
		interpolation:4,
	);
	Out.ar(out,snd)
}).add;
)

// this will abruptly restart it!
x=Synth("samplePlayer3", [\bufnum, ~bufferPiano]); // will start playing
x.set(\t_trig,1,\start,0,\end,1) // play this many times!

// the problem with above is that it won't let you change the number of loops
// what if we just want to play it once?





//////// 4 ////////
// lets improve it!
// we can use "envelopes" to keep the sound on for a certain period of time
// an envelope:
(
{
	EnvGen.ar(
		Env.new(
			levels: [0,1,1,0],
			times: [0,0.2,0.01],
			curve:\sine,
		),
		gate:1
	);
}.plot(0.3)
)

// adding an envelope to the sample player:
(
x=SynthDef("samplePlayer4", {
	arg out=0, bufnum=0, rate=1, start=0, end=1, t_trig=1,
	loops=1;
	var snd,pos,frames,duration,env;

	rate = rate*BufRateScale.kr(bufnum);
	frames = BufFrames.kr(bufnum);
	duration = frames*(end-start)/rate/s.sampleRate*loops;

	// envelope to clamp looping
	env=EnvGen.ar(
		Env.new(
			levels: [0,1,1,0],
			times: [0,duration-0.01,0.01],
			curve:\sine,
		),
		gate:t_trig,
	);

	pos=Phasor.ar(
		trig:t_trig,
		rate:rate,
		start:start*frames,
		end:end*frames,
		resetPos:start*frames,
	);

	snd=BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:pos,
		interpolation:4,
	);

	snd = snd * env;

	Out.ar(out,snd)
}).add;
)

x=Synth("samplePlayer4", [\bufnum, ~bufferPiano]); // will start playing
x.set(\t_trig,1,\start,0.0,\end,0.16,\loops,1)
x.set(\t_trig,1,\start,0.5,\end,0.51,\loops,12)

// new problem:
// now this won't play if we set the rate to be negative...
x.set(\t_trig,1,\start,0.5,\end,0.6,\loops,3,\rate,-1)

// solution to the new problem:
// we have to change start and positions manually when the rate is negative...
x.set(\t_trig,1,\start,0.6,\end,0.5,\loops,3,\rate,-1)



//////// 5 ////////
// lets improve it!
// we can automatically detect reversing and swap start/end points
(
x=SynthDef("samplePlayer5", {
	arg out=0, bufnum=0, rate=1, start=0, end=1, t_trig=1,
	loops=1;
	var snd,pos,frames,duration,env;

	rate = rate*BufRateScale.kr(bufnum);
	frames = BufFrames.kr(bufnum);
	duration = frames*(end-start)/rate.abs/s.sampleRate*loops; // use rate.abs instead now

	// envelope to clamp looping
	env=EnvGen.ar(
		Env.new(
			levels: [0,1,1,0],
			times: [0,duration,0],
		),
		gate:t_trig,
	);

	pos=Phasor.ar(
		trig:t_trig,
		rate:rate,
		// a little bit of math will swap the start and end points
		start:(((rate>0)*start)+((rate<0)*end))*frames,
		end:(((rate>0)*end)+((rate<0)*start))*frames,
		resetPos:(((rate>0)*start)+((rate<0)*end))*frames,
	);

	snd=BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:pos,
		interpolation:4,
	);

	snd = snd * env;

	Out.ar(out,snd)
}).add;
)
x=Synth("samplePlayer5", [\bufnum, ~bufferPiano]); // will start playing
x.set(\t_trig,1,\start,0.5,\end,0.6,\loops,3,\rate,-1)
x.set(\t_trig,1,\start,0.5,\end,0.6,\loops,3,\rate,1)

// one more problem...
// there is a lot of "clickiness" when starting samples at certain positions
// try running this many times in a row:
x.set(\t_trig,1,\start,0.5,\end,1,\loops,1,\rate,1)




//////// 5 ////////
// lets improve it!
// we can crossfade between two buffers (which are playing the same buffer)
(
SynthDef("samplePlayer6", {
	arg out=0, bufnum=0, rate=1, rateLag=0,start=0, end=1, reset=0, t_trig=1,
	loops=1, amp=0.5;
	var snd,snd2,pos,pos2,frames,duration,env;
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
	snd=BufRd.ar(
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

	Out.ar(out,(crossfade*snd)+((1-crossfade)*snd2) * env * amp)
}).add;
)


x=Synth("samplePlayer6", [\bufnum, ~bufferPiano]); // will start playing
x.set(\t_trig,1,\start,0.5,\end,1,\loops,1,\rate,1) // no more clicking if you run this a bunch in a row




