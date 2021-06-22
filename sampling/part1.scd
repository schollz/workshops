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
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/pianochords.wav");
~bufferPiano.plot; // we can visualize this buffer
~bufferPiano.numFrames/b.sampleRate; // length in time
// lets load another buffer
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/breakbeats_160bpm.wav");
~bufferDrums.plot; // we can visualize this buffer
~bufferDrums.numFrames/b.sampleRate; // length in time




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
    snd=PlayBuf.ar(                   // PlayBuf will play a sound in a buffer
		numChannels:2,               // we are dealing with stereo samples, so 2 channels
		bufnum:bufnum,               // bufnum is the buffer number from arguments
		rate:BufRateScale.kr(bufnum) // BufRateScale will calculate the
	);                               // difference between the server sampling

	Out.ar(0,snd); // Out.ar will output the sound into channel "0" (your speakers)
}).add; // .add will add it to our server to be used anytime we want!
)


//////// 10  ////////
// now lets play our defined synth!
// we can then create a synth that plays the sound!
~synthPiano=Synth("samplePlayer1",[\bufnum,~bufferPiano]); // will start playing piano
~synthPiano.free; // will stop playing piano
// we can create more at the same time!
~synthDrums=Synth("samplePlayer1",[\bufnum,~bufferDrums]); // will start playing drums
~synthDrums.free; // will stop playing drums

// you can also stop *everything* with <Ctl>+.




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
		rate:BufRateScale.kr(bufnum)
	);

	Out.ar(0,snd*amp); // multiple snd times "amp"
}).add;
)

x=Synth("samplePlayer1", [\bufnum, ~bufferPiano]); // will start playing
x.set(\amp,0); // this will turn it off
// you can add as many arguments as you want and toggle any/all of them
// x.set(\arg1,val1,\arg2,val2,...)


//////// 12 ////////
// sometimes for testing, its useful to use the built-in MouseX/MouseY controls!
// lets add a scratch fx and a filter with the mouse
(
SynthDef("samplePlayer1scratchy", {
	arg bufnum=0, amp=1; // introduce a new argument called "amp"
    var snd;

	amp=Lag.kr(amp,1); // Lag is a UGen that makes things change slowly

    snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		rate:BufRateScale.kr(bufnum)*MouseX.kr(-1,2) // control rate with mouse
	);

	// add filter to control with mouse
	snd=MoogFF.ar(snd,MouseY.kr(20,20000,1));

	Out.ar(0,snd*amp);
}).add;
)
x=Synth("samplePlayer1", [\bufnum, ~bufferDrums]);




//////// 13 ////////
// now lets convert those Mouse controls into arguments
// rate control -> scratch fx
// we can "toggle" this fx by doing boolean logic
(
SynthDef("samplePlayer1scratchy", {
	arg bufnum=0, amp=1, fx_filter=20000, fx_scratch=0; // add arguments
    var snd;

	amp=Lag.kr(amp,1);
	fx_filter=Lag.kr(fx_filter,1); // add lag to filter

    snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		rate:BufRateScale.kr(bufnum)*((fx_scratch>0)*SinOsc.kr(10));
	);

	// add filter to control with mouse
	snd=MoogFF.ar(snd,fx_filter);

	Out.ar(0,snd*amp);
}).add;
)
x=Synth("samplePlayer1", [\bufnum, ~bufferDrums]);
x.set(\fx_filter,1000,\fx_scratch,1);
x.set(\fx_filter,15000,\fx_scratch,0);


(
SynthDef("samplePlayer1wDelay", {
    arg out = 0, bufnum = 0, fx_delay=0;
    var snd;
    snd=PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum));
	snd=snd+CombC.ar(snd,0.2,0.2,5,fx_delay);
    Out.ar(out,snd)
}).add;
)
x=Synth("samplePlayer1wDelay", [\bufnum, b]); // will start playing
x.set(\fx_delay,1);
x.set(\fx_delay,0);


// sometimes you want "all on" or "all off", we can use > for that
(
SynthDef("samplePlayer1wDelayScratch", {
    arg out = 0, bufnum = 0, fx_delay=0, fx_scratch=0;
    var snd;
	snd=PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * ((fx_scratch>0)*SinOsc.kr(10)));
	snd=snd+CombC.ar(snd,0.2,0.2,5,fx_delay);
    Out.ar(out,snd)
}).add;
)
x=Synth("samplePlayer1wDelay", [\bufnum, b]); // will start playing
x.set(\fx_delay,1);
x.set(\fx_delay,0);





//////// 19 ////////
// your turn!
// take the synth in #18 and try changing things, including:
// - try changing the oscillators (try VarSaw, SinOsc, Pulse, LFTri, Saw, ..)
// - try changing the frequency
// - try changing the number of oscillators (instead of 3, do 1, 2, ..)

