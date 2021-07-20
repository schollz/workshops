//////// 1 ////////
// let's get into samples
// we need to boot the server (if not already booted) to start:
// goto Server -> Boot Server
// or press <Ctl>+B (windows)



//////// 2 ////////
// to play samples we first need to load a sample into a "buffer"
// ~someBuffer=Buffer.read(s,<filename>) will read the file into the buffer ~someBuffer
// load any one of these three! (Ctl+Enter on any line)

// pick one of the three buffers below and load it
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_16beats_bpm90.wav");
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_24beats_bpm90.wav");
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_32beats_bpm90.wav");

// plot the buffer
~bufferPiano.plot; // we can visualize this buffer
// check the buffer length
~bufferPiano.numFrames/~bufferPiano.sampleRate; // length in time


// lets load another buffer: pick one of the three buffers below and load it
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums1_8beats_bpm90.wav");
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums2_8beats_bpm90.wav");
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums3_8beats_bpm90.wav");

// visualize the buffer
~bufferDrums.plot; // we can visualize this buffer
// check the buffer length
~bufferDrums.numFrames/~bufferPiano.sampleRate; // length in time




//////// 3 ////////
// lets play the buffer using the PlayBuf "UGen"
(
{
	var snd; // define a variable to hold our sound
	snd=PlayBuf.ar( // PlayBuf will play a sound in a buffer
		numChannels:2, // we are dealing with stereo samples, so 2 channels
		bufnum:~bufferPiano, // the buffer
	);
	Out.ar(0,snd); // send to Out UGen to channel 0 (default speakers)
}.play; // .play will play the sound immediately!
)


//////// 4 ////////
// lets define how our sound will work
// first we will define what is called a "SynthDef", a synth definition
// SynthDef(<name>,<function>).add
(
SynthDef("samplePlayer1", {
	// buffers have an index, and the buffer index will be supplied later using
	// an argument, "arg":
	arg bufnum = 0;
	// after arguments, we will declare variables that we will use with "var":
    var snd;

    snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop: 1,                     // loop forever
		rate:BufRateScale.kr(bufnum) // BufRateScale will calculate the
	);                               // difference between the server sampling

	Out.ar(0,snd);
}).add; // .add will add it to our server to be used anytime we want!
)


//////// 5  ////////
// now let's play our defined synth using the "Synth" function
// we can then create a synth that plays the sound!
~synthPiano=Synth("samplePlayer1",[\bufnum,~bufferPiano]); // will start playing piano
// we can create more at the same time!
~synthDrums=Synth("samplePlayer1",[\bufnum,~bufferDrums]); // will start playing drums
// to stop them we ".free"
~synthPiano.free; // will stop playing piano
~synthDrums.free; // will stop playing drums

// you can also stop *everything* with <Ctl>+.

// we can load in different drums
(
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums3_8beats_bpm90.wav",action:{
	~synthDrums.set(\bufnum,~bufferDrums);
});
)




//////// 6 ////////
// lets modify our synth with a volume control
(
SynthDef("samplePlayer1", {
	arg bufnum=0, amp=1; // introduce a new argument called "amp"
    var snd;

	amp=Lag.kr(amp,1); // Lag is a UGen that makes things change slowly

    snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop:1,
		rate:BufRateScale.kr(bufnum)
	);

	Out.ar(0,snd*amp); // multiple snd times "amp"
}).add;
)


x=Synth("samplePlayer1", [\bufnum, ~bufferPiano]); // will start playing
x.set(\amp,0); // this will turn it off
x.set(\amp,1); // this will turn it on
x.set(\amp,0.5); // this will reduce the volume in half

// you can add as many arguments as you want and toggle any/all of them
// x.set(\arg1,val1,\arg2,val2,...)


//////// 7 ////////
// record scratch!!!
// sometimes for testing, its useful to use the built-in MouseX/MouseY controls!
// lets add a scratch fx
(
SynthDef("samplePlayer1scratchy", {
	arg bufnum=0, amp=1; // introduce a new argument called "amp"
    var snd;

	amp=Lag.kr(amp,1); // Lag is a UGen that makes things change slowly

    snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop:1,
		rate:BufRateScale.kr(bufnum)*MouseX.kr(-1,1) // control rate with mouse
	);

	Out.ar(0,snd*amp);
}).add;
)
// put mouse all the way to the right, all the way left, and move it around fast!
x=Synth("samplePlayer1scratchy", [\bufnum, ~bufferPiano]);




//////// 8 ////////
// lets add a "argument" that can toggle a scratch fx
(
SynthDef("samplePlayer1scratchy2", {
	arg bufnum=0, amp=1, fx_scratch=0; // add arguments
    var snd, rate; // add rate variable to make things look better

	amp=Lag.kr(amp,1);

	rate=BufRateScale.kr(bufnum); // basic rate

	// a mathematic toggle to change rate based on argument
	// if fx_scratch<1 then we have (rate + 0)
	// if fx_scratch>1 then we have (0 + SinOsc)
	rate=((fx_scratch<1)*rate)+((fx_scratch>1)*SinOsc.kr(fx_scratch));

    snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop:1,
		rate:rate;
	);

	Out.ar(0,snd*amp);
}).add;
)
x=Synth("samplePlayer1scratchy2", [\bufnum, ~bufferPiano]);
x.set(\fx_scratch,3.5);
x.set(\fx_scratch,0);
x.free;

// discussion point: what is the SinOsc UGen doing to the rate?




//////// 9 ////////
// lets add delay and a filter with the mouse
(
SynthDef("samplePlayer1morefx", {
	arg bufnum=0, amp=1,
	fx_scratch=0;
    var snd, rate;

	amp=Lag.kr(amp,1);
	fx_filter=Lag.kr(fx_filter,1);
	fx_delay=Lag.kr(fx_delay,2); // lag the delay

	rate=BufRateScale.kr(bufnum);
	rate=((fx_scratch<1)*rate)+((fx_scratch>1)*SinOsc.kr(fx_scratch));

    snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop:1,
		rate:rate;
	);

	snd=snd+CombC.ar(snd,0.5,MouseX.kr(0.05,0.5));

	snd=MoogFF.ar(snd,MouseY.kr(20,20000,1));

	Out.ar(0,snd*amp);
}).add;
)
x=Synth("samplePlayer1morefx", [\bufnum, ~bufferPiano]);
x.set(\fx_scratch,3.5);
x.set(\fx_scratch,0);
x.free;




//////// 9 ////////
// lets create arguments to control the delay and filter
(
SynthDef("samplePlayer1evenmorefx", {
	arg bufnum=0, amp=1,
	fx_scratch=0,
	fx_delay=0,fx_filter=20000; // define new arguments with the defaults
    var snd, rate;

	amp=Lag.kr(amp,1);
	fx_filter=Lag.kr(fx_filter,1);

	rate=BufRateScale.kr(bufnum);
	rate=((fx_scratch<1)*rate)+((fx_scratch>1)*SinOsc.kr(fx_scratch));

    snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop:1,
		rate:rate;
	);

	// (fx_delay>0) will ensure the CombC only works if fx_delay is active
	snd=snd+CombC.ar(snd,0.5,fx_delay,mul:fx_delay>0);

	snd=MoogFF.ar(snd,fx_filter);

	Out.ar(0,snd*amp);
}).add;
)
x=Synth("samplePlayer1evenmorefx", [\bufnum, ~bufferPiano]);
x.set(\fx_scratch,3.5);
x.set(\fx_scratch,0);
x.set(\fx_delay,0.2);
x.set(\fx_delay,0);
x.set(\fx_filter,400);
x.set(\fx_filter,20000);
x.free;



//////// 15 ////////
// there are four more fx added to this SynthDef
// uncomment one of them (select and hit Ctl+/ )
(
SynthDef("samplePlayer1mostfx", {
	arg bufnum=0, amp=1,
	fx_filter=20000, fx_scratch=0, fx_delay;
    var snd, rate,local;

	amp=Lag.kr(amp,1);
	fx_filter=Lag.kr(fx_filter,1);

	rate=BufRateScale.kr(bufnum);
	rate=((fx_scratch<1)*rate)+((fx_scratch>1)*SinOsc.kr(fx_scratch));

    snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop:1,
		rate:rate;
	);


	///////////////////////////////////////
	// distortion - try creating an argument to control this
	// snd=(snd*(1+LinExp.kr(MouseY.kr(),0,1,0.0001,10))).tanh*0.5;

	///////////////////////////////////////
	// autopaning - try creating an argument to control this
	// snd=Balance2.ar(snd[0],snd[1],SinOsc.kr(1));

	///////////////////////////////////////
	// tremelo - try creating an argument to control this
	// snd=LFPar.ar(4)*snd;

	// delay
	snd=snd+CombC.ar(snd,0.5,fx_delay,mul:fx_delay>0);

	// filter
	snd=MoogFF.ar(snd,fx_filter);

	Out.ar(0,snd*amp);
}).add;
)
x=Synth("samplePlayer1mostfx", [\bufnum, ~bufferPiano]);
x.set(\fx_filter,400,\fx_scratch,3.5,\fx_delay,0.1);
x.set(\fx_filter,15000,\fx_scratch,0,\fx_delay,0);
x.free();


// your turn!
// try playing with #15
// try uncommenting those fx and making arguments for them
// try adding your own fx


// bonus: granulation
(
SynthDef("sampleGranulator1", {
	arg bufnum=0;
	var snd;
	var maxFreq=10;
	var newGrain=Impulse.kr(maxFreq)+Dust.kr(maxFreq/2);

    snd=GrainBuf.ar(
		numChannels:2,
		trigger:newGrain,
		dur:MouseY.kr(1,maxFreq)/maxFreq,
		sndbuf:bufnum,
		rate:TChoose.kr(newGrain,[1,1,1,1,1,1,1,1,2,2,4]),
		pos:MouseX.kr(0,1)+LFNoise0.kr(newGrain).range(-0.05,0.05),
	).poll;

	snd = FreeVerb.ar(snd);
	Out.ar(0,snd);
}).add;
)
~bufferPianoMono=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/upright_16beats_bpm90.wav",channels:0);

x=Synth("sampleGranulator1", [\bufnum, ~bufferPianoMono]); // will start playing
x.free();









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




