//////// -- first steps + samples -- ////////

s.boot;
s.meter;
s.plotTree;


//////// 1 ////////
// this is a comment! it is valid code but doesn't do anything




//////// 2 ////////
// now, this is a line of code that does something!
// this line prints something in the window over there ->
// run any line of code by putting your cursor on it and then
// press <Ctl>+<Enter>
"I love SuperCollider".postln; // <- make sure to always have a ";" after code




//////// 3 ////////
// parentheses make it easy to
// run multiple lines of code with <Ctl>+<Enter>
(
"I love SuperCollider".postln;
"SuperCollider loves me".postln;
)




//////// 4 ////////
// disorder of operations!
// there is no order of operations in SuperCollider!
// beware beware beware beware
(
 (100+2/2).postln; // what does this equal?
 (100+(2/2)).postln; // force order of operations using parentheses
)




//////// 5 ////////
// semicolons make functions -> { <stuff> } = function
// you can assign variables using letters a-z or with ~variableName
// you can assign functions to variables!
(
// functions stored in a variable
a={"I love SuperCollider".postln;};
~someVariable={"SuperCollider loves me".postln;};
// run the functions
a.value; // .value evaluates the function stored in "a"
~someVariable.value;
)




//////// 6 ////////
// functions can have arguments and variables!
(
a={
	arg name; // arguments must be defined first
	var something; // then variables must be defined next
	something="SuperCollider"; // variables can be assigned later
	(name++", do you like "++something++"?").postln;
};
a.value("your name");
)




//////// 7 ////////
// let's get into the music now!
// we need to boot the server to start music making:
// goto Server -> Boot Server
// or press <Ctl>+B (windows)




//////// 8 ////////
// to play samples we first need to load a sample into a "buffer"
// ~someBuffer=Buffer.read(s,<filename>) will read the file into the buffer ~someBuffer
// load any one of these three! (Ctl+Enter on any line)
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_16beats_bpm90.wav");
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_24beats_bpm90.wav");
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_32beats_bpm90.wav");
~bufferPiano.plot; // we can visualize this buffer
~bufferPiano.numFrames/~bufferPiano.sampleRate; // length in time
// lets load another buffer
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums1_8beats_bpm90.wav");
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums2_8beats_bpm90.wav");
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums3_8beats_bpm90.wav");
~bufferDrums.plot; // we can visualize this buffer
~bufferDrums.numFrames/~bufferPiano.sampleRate; // length in time




//////// 9 ////////
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

	// now the cool stuff.
	// PlayBuf is a "UGen" whose purpose is to play a sound
    snd=PlayBuf.ar(                   // PlayBuf will play a sound in a buffer
		numChannels:2,               // we are dealing with stereo samples, so 2 channels
		bufnum:bufnum,               // bufnum is the buffer number from arguments
		loop: 1,                     // loop forever
		rate:BufRateScale.kr(bufnum) // BufRateScale will calculate the
	);                               // difference between the server sampling

	Out.ar(0,snd); // Out.ar will output the sound into channel "0" (your speakers)
}).add; // .add will add it to our server to be used anytime we want!
)


//////// 10  ////////
// now lets play our defined synth!
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




//////// 11 ////////
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
// you can add as many arguments as you want and toggle any/all of them
// x.set(\arg1,val1,\arg2,val2,...)


//////// 12 ////////
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




//////// 13 ////////
// lets add a "argument" that can toggle a scratch fx
(
SynthDef("samplePlayer1scratchy2", {
	arg bufnum=0, amp=1, fx_scratch=0; // add arguments
    var snd, rate; // add rate variable to make things look better

	amp=Lag.kr(amp,1);

	rate=BufRateScale.kr(bufnum); // basic rate
	// a mathematic toggle
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
x.set(\fx_scratch,4.5);
x.set(\fx_scratch,0);


//////// 14 ////////
// other fx!
(
SynthDef("samplePlayer1morefx", {
	arg bufnum=0, amp=1,
	fx_filter=20000, fx_scratch=0, fx_delay;
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

	// delay only works when  fx_delay > 0
	snd=snd+CombC.ar(snd,0.2,0.2,2,fx_delay);

	// a filter fx works with an argument too
	snd=MoogFF.ar(snd,fx_filter);

	Out.ar(0,snd*amp);
}).add;
)
x=Synth("samplePlayer1morefx", [\bufnum, ~bufferPiano]);
x.set(\fx_filter,10000,\fx_scratch,3.5,\fx_delay,1);
x.set(\fx_filter,15000,\fx_scratch,0,\fx_delay,0);




//////// 15 ////////
// your turn!
// there are four more fx added to this SynthDef
// uncomment one of them (select and hit Ctl+/ )
// and then add an argument for it (e.g. fx_reverb)
// and use that argument to toggle it / change it somehow
(
SynthDef("samplePlayer1evenmorefx", {
	arg bufnum=0, amp=1,
	fx_filter=20000, fx_scratch=0, fx_delay;
    var snd, rate,local;

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

	// delay only works when  fx_delay > 0
	snd=snd+CombC.ar(snd,0.2,0.2,2,fx_delay);

	// reverb - add a toggle for this!
	// local = LocalIn.ar(2)+snd;
	// 15.do({local=AllpassN.ar(local,0.06,Rand(0.001,0.06),3)});
	// LocalOut.ar(local*MouseX.kr());
	// snd = (snd+local)/2;

	// distortion - add a toggle for this!
	// snd=(snd*(1+LinExp.kr(MouseY.kr(),0,1,0.0001,10))).tanh*0.5;

	// autopaning - add a toggle for this!
	// snd=Balance2.ar(snd[0],snd[1],SinOsc.kr(1));

	// tremelo - add a toggle for this!
	snd=LFPar.ar(4)*snd;

	snd=MoogFF.ar(snd,fx_filter);

	Out.ar(0,snd*amp);
}).add;
)
x=Synth("samplePlayer1evenmorefx", [\bufnum, ~bufferPiano]);
x.set(\fx_filter,10000,\fx_scratch,3.5,\fx_delay,1);
x.set(\fx_filter,15000,\fx_scratch,0,\fx_delay,0);





// bonus: granulation


(
~bufferPianoMono=Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/upright_16beats_bpm90.wav",channels:0);
SynthDef("sampleGranulator1", {
	arg bufnum=0;
	var snd;

    snd=GrainBuf.ar(
		numChannels:2,
		trigger:Dust.kr(30),
		dur:1/30,
		sndbuf:bufnum,
		rate:LFNoise1.kr.range(1,1.01),
		pos:MouseX.kr(0,1),
	).poll;

	snd = FreeVerb.ar(snd);
	Out.ar(0,snd);
}).add;
)

x=Synth("sampleGranulator1", [\bufnum, ~bufferPianoMono]); // will start playing
