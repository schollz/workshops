// Part 2
// This part will teach the basics of SuperCollider
// and how to load and play buffers. At the end of this
// tutorial, different types of effects will be explored.

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
~bufferPiano.numFrames/~bufferPiano.sampleRate; // length in seconds


// lets load another buffer: pick one of the three buffers below and load it
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums1_8beats_bpm90.wav");
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums2_8beats_bpm90.wav");
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums3_8beats_bpm90.wav");

// plot the buffer
~bufferDrums.plot; // we can visualize this buffer
// check the buffer length
~bufferDrums.numFrames/~bufferPiano.sampleRate; // length in seconds




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

// we can load in different drums by redefining the value of the variable ~bufferDrums

// step 1: create an instance of the samplePlayer SynthDef called '~synthDrums'
~synthDrums=Synth("samplePlayer1",[\bufnum,~bufferDrums]); // will start playing drums

// step 2: change the drum sample by redefining ~bufferDrums and sending the new sample to the SynthDef instance
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
x=Synth("samplePlayer1scratchy", [\bufnum, ~bufferDrums]);




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



// TANGENT- OSC definitions //
(
n = NetAddr("127.0.0.1", 57120); // local machine
o.free;
o=OSCFunc({ |msg,time,addr,recvPort|
	[msg,time,addr,recvPort].postln;
	x.set(\fx_scratch,msg[1]);
}, '/hello');
)



//////// 9 ////////
// lets add delay and a filter with the mouse
(
SynthDef("samplePlayer1morefx", {
	arg bufnum=0, amp=1,
	fx_scratch=0;
    var snd, rate;

	amp=Lag.kr(amp,1);

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




//////// 10 ////////
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




//////// 11 ////////
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




//////// 12 ////////
// bonus: granulation
// instead of PlayBuf, lets use something called GrainBuf
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
		rate:TChoose.kr(newGrain,[1,1,1,1,1,1,1,1,2]),
		pos:MouseX.kr(0,1)+LFNoise0.kr(newGrain).range(-0.05,0.05),
	).poll;

	snd = FreeVerb.ar(snd);
	Out.ar(0,snd);
}).add;
)
~bufferPianoMono=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/upright_16beats_bpm90.wav",channels:0);

x=Synth("sampleGranulator1", [\bufnum, ~bufferPianoMono]); // will start playing
x.free();




// your turn!
// try playing with #11 or #12 (for example, in #12, try changing the value of the variable 'maxFreq')
// try making arguments for the fx in #11 them
// try adding your own fx




