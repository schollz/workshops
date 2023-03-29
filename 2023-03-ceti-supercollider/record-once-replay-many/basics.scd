//////// PART I ////////


//////// -- first steps + samples -- ////////
// This part will teach the basics of SuperCollider, using modulation
// and making samples

// boots the server
s.boot;
s.meter;
s.plotTree;
s.freqscope;

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
// semicolons make functions
// you can assign global variables using letters a-z or with ~variableName
// execute each step, incrementally

// step 1: create functions stored in a variable
(
a={"I love SuperCollider".postln;};
~someVariable={"SuperCollider loves me".postln;};
)
// step 2a: run the first function
a.value; // .value evaluates the function stored in "a"
// step 2b: run the second function
~someVariable.value;





//////// 6 ////////
// functions can have arguments and variables!
// arguments and variables are similar, except that arguments can be passed into functions when the function is called.
// step 1: create a function that contains arguments and variable
(
a={
	arg name; // arguments must be defined first
	var something; // then variables must be defined next
	something="SuperCollider"; // variables can be assigned later
	(name++", do you like "++something++"?").postln;
};
)

// step 2: execute the function
a.value("zack");




//////// 7 ////////
// let's get into the music now!
// we need to boot the server to start music making:
// goto Server -> Boot Server
// or press <Ctl>+B (windows)





//////// 8 ////////
// lets make a function that generates a Sine wave
// SuperCollider generates things with a "UGen"
// the UGen for Sine waves is called "SinOsc"
(
{
	SinOsc.ar(freq:220);
}.plot(0.02); // .plot(x) will plot it for x seconds
)




//////// 9 ////////
// finally lets make a sound!
// just add .play to our function
(
{
	SinOsc.ar(freq:220);
}.play; // .play will play it
)
// stop it using <Ctl>+.
// you just made a synth!
// it makes one sound and only one sound,
// but who cares!? you did it!




//////// 10  ////////
// lets have the synth make another sound
// by adding an argument (see 6)
// and also save it to a variable (see 5)
(
// save a variable and a Sine UGen to the "x" variable
x={
	arg freq=220;
	SinOsc.ar(freq:freq);
}.play; // .play will play it
)
// now you can run each of these lines to change it!
x.set(\freq,440);
x.set(\freq,60.midicps); // .midicps converts midi note to frequency (cycles per second)
x.free; // we can stop the synth running this line




//////// 11 ////////
// UGens constantly generate numbers
// but they can also be treated like numbers,
// you can add and subtract them.
// for instance, we can add volume:
(
x={
	arg freq=220, amp=0.5;
	SinOsc.ar(freq:freq)*amp;
}.play;
)
// lowers the volume
x.set(\amp,0.1);
// raise the volume and set the frequency (you can do multiple things)
x.set(\amp,0.7,\freq,440);
// free the synths!
x.free;




//////// 12 ////////
// UGens have all sorts of parameters
// SinOsc happens to have one that gets multiplied, call "mul".
// highlight "SinOsc" and press <Ctl>+D [win] or <command>+D [mac] to see the parameters
(
x={
	arg freq=220, amp=0.5;
	SinOsc.ar(freq:freq,mul:amp);
}.play; // .play will play it
)
x.free;
// note: this is exactly the same as in 11
// in SuperCollider there are always many ways to do the same thing




//////// 13 ////////
// lets use Out.ar to specify the sound
// Out will output the result to the "bus"
// bus "0" is the audio out
(
x={
	arg freq=220, amp=0.5;
	var snd;
	snd=SinOsc.ar(freq:freq,mul:amp);
	Out.ar(0,snd);
}.play;
)
x.free;
// note: this is exactly the same as 11 and 12
// in 11 and 12, SuperCollider assumed this is what
// we wanted




//////// 14 ////////
// "multichannel expansion" is SuperCollider's secret sauce.
// "multichannel expansion" also sounds cool to drop in conversation.
// "multichannel expansion" means that SuperCollider will automatically
// generate multiple UGens for you when a parameter has an array
// and assign each UGen to an audio channel (e.g. left and right speakers).
(
x={
	arg freq=220, amp=0.5;
	var snd;
	snd=SinOsc.ar(freq:[freq,freq*2],mul:[amp,amp/2]);
	Out.ar(0,snd);
}.play;
)
// you should hear
// lower frequency at higher volume in left ear
// higher frequency at lower volume in right ear
x.free;




//////// 15 ////////
// sometimes you don't want multichannel expansion
// so you can mix it down to a single channel using the
// Mix.ar UGen
// then you can split it across the left/right using Splay
(
x={
	arg freq=220, amp=0.5;
	var snd;
	snd=SinOsc.ar(freq:[freq,freq*2,freq*4],mul:[amp,amp/2,amp/8]);
	snd=Mix.ar(snd); // mixes the three channels into 1
	snd=Splay.ar(snd);
	Out.ar(0,snd);
}.play;
)
x.free;




//////// 16 ////////
// lets define a synth to use multiple times
// using a "SynthDef"
(
SynthDef("coolsynth",{ // add SynthDef here, with a name
	arg freq=220, amp=0.1;
	var snd;
	snd=SinOsc.ar(freq:[freq,freq*2,freq*4],mul:[amp,amp/2,amp/8]);
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);
	Out.ar(0,snd);
}).add; // use "add" instead of play
)

// now you can create multiple instances of them!
(
x = Synth("coolsynth",[\freq,60.midicps]);
y = Synth("coolsynth",[\freq,62.midicps]);
z = Synth("coolsynth",[\freq,65.midicps]);
)

// and each can be set later!
(
x.set(\freq,58.midicps);
y.set(\freq,62.midicps);
z.set(\freq,67.midicps);
)
(
x.set(\freq,60.midicps);
y.set(\freq,62.midicps);
z.set(\freq,65.midicps);
)

// set them all free!
(
x.free;
y.free;
z.free;
)




//////// 17 ////////
// you can treat UGens like numbers
// lets add them together and make a new oscillator
// famous oscillators to play with:
// SinOsc, LFSaw, Tri
(
SynthDef("coolsynth",{
	arg freq=110, amp=0.1;
	var snd;
	// you can directly Mix
	snd=Mix.ar(
		SinOsc.ar(freq:[freq,freq*2,freq*4],mul:[amp,amp/2,amp/4])
	);
	// lets add some harmonic from a saw wave
	snd=snd+(0.1*Mix.ar(
		Saw.ar(freq:[freq,freq*2,freq*3,freq*4],mul:[amp,amp/2,amp/3,amp/4]))
	);
	// note: the following doesn't work, why not?
	// snd=snd+0.5*Mix.ar(Saw.ar(freq:[freq,freq*2],mul:[amp,amp/2]));
	snd=Splay.ar(snd);
	Out.ar(0,snd);
}).play;
)



//////// 18 ////////
// fancy multiexpansion
// use Array.fill(<num>,{arg i; <code>})
// to easily create an additive synth
// this is same as 17
(
SynthDef("coolsynth",{
	arg freq=110, amp=0.1;
	var snd;
	// you can directly Mix
	snd=Mix.ar(
		Array.fill(2,{arg i; SinOsc.ar(freq:freq*(2**i),mul:amp/(2**i))})
	);
	// lets add some harmonic from a saw wave
	snd=snd+(0.1*Mix.ar(
		Array.fill(4,{arg i; Saw.ar(freq:freq*(i+1),mul:amp/(i+1))}))
	);
	snd=Splay.ar(snd);
	Out.ar(0,snd);
}).play;
)



//////// 19 ////////
// also, you can plot waveforms!
(
{
	[SinOsc.ar(220),Saw.ar(220)]
}.plot(10/220); // plot for 10 cycles at 220hz
)


//////// 19 ////////
// also, you can use functions as arguments!
(
{
	[Saw.ar(220),Saw.ar(220*Saw.ar(440).range(0,1))]
}.plot(10/220);
)


//////// 20 ////////
// there are all sorts of cool oscillators to use as modulation
(
{
	[
		LFNoise0.kr(100), // defaults to -1 to 1
		LFNoise1.kr(100).range(0,1), // can set range
		LinLin.kr(LFNoise2.kr(100),-1,1,5,10), // another way to set range
	]
}.plot(10/100); // press "n" on the plot to zoom in
)



// TAKE A BREATH!!!!!!!!!!!!!!!












//////// PART II ////////



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
~buffer=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/windchimes.wav");

// plot the buffer
~buffer.plot; // we can visualize this buffer

// play the buffer
~buffer.play;



//////// 3 ////////
// lets play the buffer using the PlayBuf "UGen"
(
{
	var snd; // define a variable to hold our sound
	snd=PlayBuf.ar( // PlayBuf will play a sound in a buffer
		numChannels:2, // we are dealing with stereo samples, so 2 channels
		bufnum:buffer, // the buffer
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
~syn=Synth("samplePlayer1",[\bufnum,~buffer]); // will start playing piano
~syn.free; // will stop playing

// you can also stop *everything* with <Ctl>+.





//////// 6 ////////
// lets modify our synth with some MODULATION and panning
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
	
	snd = Pan2.ar(snd,LFNoise2.kr(1)); // pans randomly left and right
	
	Out.ar(0,snd);
}).add; // .add will add it to our server to be used anytime we want!
)


x=Synth("samplePlayer1", [\bufnum, ~buffer]); // will start playing




//////// 7 ////////
// lets modify our synth with some EFFECTS!
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
	
	snd = Pan2.ar(snd,LFNoise2.kr(1)); // pans randomly left and right
	
	snd = RLPF.ar(snd, MouseX.kr(10,20000,1),0.5); // effects controlled by mouse!
	
	snd = CombC.ar(snd,0.2,0.2); // add delay
	
	Out.ar(0,snd);
}).add; // .add will add it to our server to be used anytime we want!
)


x=Synth("samplePlayer1", [\bufnum, ~buffer]); // will start playing




// requires "Ube.sc" to be put into the Extensions directory
(
s.waitForBoot({
	var pairs;
	
	// define the "looper"
	
	SynthDef("looper",{
		// main arguments
		arg buf,tape,player,baseRate=1.0,amp=1.0,timescale=0.2;
		// variables to store UGens later
		var volume;
		var switch=0,snd,snd1,snd2,pos,pos1,pos2,posStart,posEnd,index;
		// store the number of frames and the duraiton
		var frames=BufFrames.kr(buf);
		var duration=BufDur.kr(buf);
		// LFO for the start point <-- tinker
		var lfoStart=SinOsc.kr(timescale/Rand(30,60),Rand(hi:2*pi)).range(1024,frames-10240);
		// LFO for the window lenth <-- tinker
		var lfoWindow=SinOsc.kr(timescale/Rand(60,120),Rand(hi:2*pi)).range(4096,frames/2);
		// LFO for the rate (right now its not an LFO)
		var lfoRate=baseRate;//*Select.kr(SinOsc.kr(1/Rand(10,30)).range(0,4.9),[1,0.25,0.5,1,2]);
		// LFO for switching between forward and reverse <-- tinker
		var lfoForward=Demand.kr(Impulse.kr(timescale/Rand(5,15)),0,Drand([0,1],inf));
		// LFO for the volume <-- tinker
		var lfoAmp=SinOsc.kr(timescale/Rand(10,30),Rand(hi:2*pi)).range(0.05,0.5);
		// LFO for the panning <-- tinker
		var lfoPan=SinOsc.kr(timescale/Rand(10,30),Rand(hi:2*pi)).range(-1,1);
		
		// calculate the final rate
		var rate=Lag.kr(lfoRate*(2*lfoForward-1),1)*BufRateScale.kr(buf);
		
		// modulate the start/stop
		posStart = lfoStart;
		posEnd = Clip.kr(posStart + lfoWindow,0,frames-1024);
		
		// LocalIn collects the a trigger whenever the playhead leaves the window
		switch=ToggleFF.kr(LocalIn.kr(1));
		
		// playhead 1 has a play position and buffer reader
		pos1=Phasor.ar(trig:1-switch,rate:rate,end:frames,resetPos:((lfoForward>0)*posStart)+((lfoForward<1)*posEnd));
		snd1=BufRd.ar(2,buf,pos1,1.0,4);
		
		// playhead 2 has a play position and buffer reader
		pos2=Phasor.ar(trig:switch,  rate:rate,end:frames,resetPos:((lfoForward>0)*posStart)+((lfoForward<1)*posEnd));
		snd2=BufRd.ar(2,buf,pos2,1.0,4);
		
		// current position changes according to the swtich
		pos=Select.ar(switch,[pos1,pos2]);
		
		// send out a trigger anytime the position is outside the window
		LocalOut.kr(
			Changed.kr(Stepper.kr(Impulse.kr(20),max:1000000000,
				step:(pos>posEnd)+(pos<posStart)
			))
		);
		
		// crossfade bewteen the two sounds over 50 milliseconds
		snd=SelectX.ar(Lag.kr(switch,0.05),[snd1,snd2]);
		
		// apply the volume lfo
		volume = amp*lfoAmp*EnvGen.ar(Env.new([0,1],[Rand(1,10)],4));
		
		// send data to the GUI
		SendReply.kr(Impulse.kr(25),"/position",[tape,player,posStart/frames,posEnd/frames,pos/frames,volume,(lfoPan+1)/2]);
		
		// do the panning
		snd=Balance2.ar(snd[0],snd[1],lfoPan);
		
		// final output
		Out.ar(0,snd*volume/5);
	}).send(s);
	
	
	// effects
	SynthDef("effects",{
		arg amp=1.0;
		var snd=In.ar(0,2);
		snd=HPF.ar(snd,80);
		// add some nice tape compression
		snd = AnalogTape.ar(snd,0.9,0.8,0.9,2);
		// add some reverb
		snd=SelectX.ar(LFNoise2.kr(1/3).range(0.1,0.5),[
			snd,
			Fverb.ar(snd[0],snd[1],50,decay:LFNoise2.kr(1/3).range(70,90))
		]);
		// add some analog chewing
		snd=SelectX.ar(LFNoise2.kr(1/3).range(0,1),[
			snd,
			AnalogChew.ar(snd);
		]);
		
		// replace the output with the effected output
		ReplaceOut.ar(0,snd*Lag.kr(amp));
	}).send(s);
	
	// load the ube class
	u=Ube.new(Server.default);
	
	// load a file into the tape
	u.loadTape(tape:1,filename:thisProcess.nowExecutingPath.dirname++"/windchimes.wav");
	
	// create players to play the tape
	u.playTape(tape:1,player:0,rate:1,db:0,timescale:1);
	u.playTape(tape:1,player:1,rate:0.5,db:3,timescale:1.0);
	u.playTape(tape:1,player:2,rate:0.25,db:6,timescale:1.0);
	u.playTape(tape:1,player:3,rate:0.125,db:9,timescale:1.0);
	u.playTape(tape:1,player:4,rate:2,db:-6,timescale:1.0);
	u.playTape(tape:1,player:5,rate:4,db:-12,timescale:1.0);
	
	// show gui
	u.gui;
});
)

// record another tape and play it
u.recordTape(tape:2,seconds:3,recLevel:0.5);
u.playTape(tape:2,player:5,rate:1,db:1,timescale:1.0);

