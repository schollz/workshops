//////// PART I ////////

// changing default audio interface
// o = Server.default.options;
// o.outDevice_("MME : PT-RZ570 (Intel(R) Display Audi");
// o.inDevice_("MME : PT-RZ570 (Intel(R) Display Audi");
// Server.default.reboot;

//////// -- first steps + samples -- ////////
// This part will teach the basics of SuperCollider, using modulation
// and making samples





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
// you can assign global  variables using letters a-z or with ~variableName
// execute each step, incrementally
// local variables are setup by writing "var" before the word (GOTCHA: local variables need to be set first)
// step 1: create functions stored in a variable

(
var localVariable=123;

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
// create a function that contains arguments and variable
(
a={
	arg name; // arguments must be defined first
	var something; // then variables must be defined next
	something="SuperCollider"; // variables can be assigned later
	(name++", do you like "++something++"?").postln;
};
)

// execute the function
a.value("hello");





//////// 7 ////////
// let's get into the music now!
// we need to boot the server to start music making:
// goto Server -> Boot Server
// or press <Ctl>+B (windows)
// to restart EVERYTHING you can do <Ctrl>+<Shift>+L and then <Ctrl>+B
// when in doubt, turn it off and on.





//////// 8 ////////
// to play samples we first need to load a sample into a "buffer" using a file or recording

// ~someBuffer=Buffer.read(s,<filename>) will read the file into the buffer ~someBuffer
// on server "s"
~buffer=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/kalimba.wav");

// plot the buffer
~buffer.plot;

// play the buffer
~buffer.play;





//////// 9 ////////
// lets play the buffer using the PlayBuf "UGen"
// "UGen" stands for "unit generator" is the main mode of processing/generating streams of numbers
(
{
	var snd; // define a variable to hold our sound
	snd=PlayBuf.ar( // PlayBuf will play a sound in a buffer
		numChannels:2, // we are dealing with stereo samples, so 2 channels
		bufnum:~buffer, // the buffer
		loop: 1,
	);
	Out.ar(0,snd); // send to Out UGen to channel 0 (default speakers)
}.play; // .play will play the sound immediately!
)





//////// 10 ////////
// lets record into a buffer
// define a new buffer that is 3 seconds long
~buffer=Buffer.alloc(s,s.sampleRate*3,2);
// then define a function to record into that buffer
(
{
	RecordBuf.ar(SoundIn.ar([0,1]), ~buffer, loop:0, doneAction:2)
}.play; // .play will play this synth that records from the input audio
)
// lets see if it worked!
~buffer.plot;
~buffer.play;

// TRY! try recording and plotting/playing your recording





//////// 11 ////////
// lets define how our sample will playback
// first we will define what is called a "SynthDef", a synth definition
// SynthDef(<name>,<function>).add
(
SynthDef("musicbox", {
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
	);                               // difference between the server sampling and the audio file

	Out.ar(0,snd);
}).add; // .add will add it to our server to be used anytime we want!
)





//////// 12  ////////
// now let's play our defined synth using the "Synth" function
// we can then create a synth that plays the sound!
~syn=Synth("musicbox",[\bufnum,~buffer]);
~syn.free; // will stop playing

// you can also stop *everything* with <Ctl>+.
// (this will stop ANY and ALL synths)





//////// 13 ////////
// aside: lets learn some modulation to mangle the musicbox
// you can use many different Ugens for modulation!
(
{
	[LorenzL.ar(5000), LFTri.ar(100), LFNoise0.kr(100),LFNoise1.kr(100),LFNoise2.kr(100)]
}.plot(0.1)
)

// modulation ranges from -1 to 1, but you can set any range you want with `.range`
// btw, you can notice a difference between .ar and .kr at this fast speed (100 hz)
// .ar is needed if you are in audio rate (>~30 hz)
(
{	[SinOsc.ar(100).range(3,4),SinOsc.kr(100).range(3,4),Saw.ar(100).range(5,6),Saw.kr(100).range(5,6)]
}.plot(0.1)
)

// TRY! try making some different modulation and plotting it
// you can use <Ctrl>+D to search for modulation
// and you can add / multiply to your hearts content
// for example:
(
{
	SinOscFB.kr(30,LFNoise0.kr(300)) + WhiteNoise.ar(0.1)
}.plot(0.5);
)





//////// 14 ////////
// note lets create a synthdef with some modulation
(
SynthDef("musicbox", {
	// buffers have an index, and the buffer index will be supplied later using
	// an argument, "arg":
	arg bufnum = 0;
	// after arguments, we will declare variables that we will use with "var":
	var snd;
	var rate;

	rate = BufRateScale.kr(bufnum)*MouseX.kr(0.9,1.1); // use the mouse to modulate the rate

	snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		loop: 1,
		rate: rate,
	);

	snd = Pan2.ar(snd,LFNoise2.kr(1)); // use "LFNoise2" to modulate panning randomly

	snd[0] = snd[0] * LFPar.ar(5).range(0,1); // use "LFPar" to modulate the amplitude
	snd[1] = snd[1] * LFPar.ar(5.1).range(0,1); // use "LFPar" to modulate the amplitude slightly differently

	Out.ar(0,snd);
}).add; // .add will add it to our server to be used anytime we want!
)

~buffer=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/kalimba.wav");

x=Synth("musicbox", [\bufnum, ~buffer]); // will start playing

// TRY! try putting the modulation you created into this synthdef and playing





//////// 15 ////////
// lets modify our synth with some EFFECTS!
// there are many effects
// filters: RLPF, LPF, HPF, BPF
// delays: CombC, DelayC
// distortion: .tanh, .softclip, .distort
(
SynthDef("musicbox", {
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

	snd = CombC.ar(snd,0.5,MouseY.kr(0.05,0.5)); // add delay

	snd = (snd * SinOsc.kr(0.1).range(1,10)).tanh * 0.1; // add distortion

	Out.ar(0,snd);
}).add; // .add will add it to our server to be used anytime we want!
)

~buffer=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/kalimba.wav");

x=Synth("musicbox", [\bufnum, ~buffer]); // will start playing

// TRY! change up the effects, the filters, the distortion, the modulation





//////// 16 ////////
// PlayBuf is missing an important feature sometimes needed:
// it is designed to always play to the end of a buffer.
// there are multiple ways around this, but to generally get
// more control over playback/recording position we can use
// the "Phasor" Ugen
// here is a little looper using a Phasor for recording and
// two Phasors for reading (two-head playback)
(
SynthDef("recorder",{ arg rate=1,bufnum=0;
	var in;
	var phase;
	// setup phase, which sample of the buffer to play
	phase = Phasor.ar(0, BufRateScale.kr(bufnum) * rate, 0, BufFrames.kr(bufnum));
	// collect input from microphone
	in=SoundIn.ar([0,1]);
	// write the input to the buffer, at the phase location
	BufWr.ar(in, bufnum, phase,loop:0);
	// free after specified time
	FreeSelf.kr(TDelay.kr(Trig.kr(1),BufDur.kr(bufnum)));
	// disable output to resist feedback
	Out.ar(0,in*0); // could also use Silent.ar()
}).add;

// define a player to do the playback (with crossfades!) using
// two headed playback
SynthDef("player",{ arg rate=1,bufnum=0,fadeOut=0.0;
	var snd;
	var phase1,phase2;
	// define play duration to the duration, minus the fadeout
	var playDur = BufDur.kr(bufnum)-fadeOut;
	// trigger the start every play duration
	var trig1 = Impulse.kr(1/(playDur/rate));
	// trigger a toggle to switch between two-headed playback
	var aOn = ToggleFF.kr(trig1);
	// define total frames
	var totalFrames = BufFrames.kr(bufnum);

	// define rate
	rate = BufRateScale.kr(bufnum) * rate;

	// setup phasors for two-head reader
	// phasors have a start AND end position
	phase1=Phasor.ar(trig:aOn, rate:rate, start:0, end:totalFrames);
	phase2=Phasor.ar(trig:1-aOn, rate:rate, start:0, end:totalFrames);

	// remove clips using fadeout/fadein (buffer must be total time + fade out)
	snd = Lag.kr(aOn,fadeOut*0.9)*BufRd.ar(2,bufnum,phase1);
	snd = snd+(Lag.kr(1-aOn,fadeOut*0.9)*BufRd.ar(2, bufnum, phase2));

	// effects
	snd=LPF.ar(snd,MouseX.kr(20,20000,1));
	Out.ar(0,snd*Line.ar());
}).add;
)

// lets define a codeblock to initialize some synths and buffers
(
var fadeOut=0.1; // cross-fade time
var syns=List.new(); // synths we will make
var bufs=List.new(); // buffers we will make
var loopTimes=[1,2,3,4,5,6]; // in seconds
loopTimes.do({ arg v,i;
	Buffer.alloc(s,(s.sampleRate*(v+fadeOut)).postln,2,{
		// this function runs once the buffer is allocated
		arg b;
		// create a new buffer
		bufs.add(b);
		// create a new synth with this buffer
		syns.add(Synth("player",[\bufnum,b,\fadeOut,fadeOut]));
	});
});
// define a function to do the recording
r= {arg i; Synth("recorder",[\bufnum,bufs[i]])};
)

// .. and record one at a time
r.(0); // record into first loop (0-index)
r.(1); // record into second loop
r.(2); // ..
r.(3); // ..
r.(4); // ..
r.(5); // ..
r.(6); // ..

// TRY it! try changing to different loop times
// or try adding effects modulation to the "player" SynthDef





//////// 17 ////////
// __   __  _______  _______
// |  | |  ||  _    ||       |
// |  | |  || |_|   ||    ___|
// |  |_|  ||       ||   |___
// |       ||  _   | |    ___|
// |       || |_|   ||   |___
// |_______||_______||_______|
//
// ube is a little tool I made to play with all these ideas:
// it is a "macrogranulator" that modulates all sorts of things of buffers
// and does recording/playback with the buffers
//
// before running this you must first save `Ube.sc` to the extensions directory.
// open `Ube.sc` in SuperCollider.
// now save it by doing `File -> Save As Extension...` and type `Ube.sc`.

// to run this code, but a cursor anywhere in the code block (a code block is enclosed in parentheses)
// and hit <Ctrl>+Enter

// if you run into trouble, restart everything <Ctrl>+<Shift>+L and then <Ctrl>+Enter
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



		///////////////////////////////////////////////////////
		// ----- START ADDING YOUR OWN MODULATION HERE ----- //
		///////////////////////////////////////////////////////


		// LFO for the start point
		var lfoStart=SinOsc.kr(timescale/Rand(30,60),Rand(hi:2*pi)).range(1024,frames-10240);

		// LFO for the window lenth
		var lfoWindow=SinOsc.kr(timescale/Rand(60,120),Rand(hi:2*pi)).range(4096,frames/2);

		// LFO for the rate (right now its not an LFO)
		var lfoRate=baseRate;

		// LFO for switching between forward and reverse
		var lfoForward=Demand.kr(Impulse.kr(timescale/Rand(5,15)),0,Drand([0,1],inf));

		// LFO for the volume
		var lfoAmp=SinOsc.kr(timescale/Rand(10,30),Rand(hi:2*pi)).range(0.05,0.5);

		// LFO for the panning
		var lfoPan=SinOsc.kr(timescale/Rand(10,30),Rand(hi:2*pi)).range(-1,1);


		///////////////////////////////////////////////////////
		// ----- DONE ADDING YOUR OWN MODULATION HERE ------ //
		///////////////////////////////////////////////////////



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

		///////////////////////////////////////////////////////
		// --------- START ADDING ANY EFFECTS HERE --------- //
		///////////////////////////////////////////////////////

		snd = CombC.ar(snd,0.5,Rand(0.05,0.5),2); // random delay
		// snd = LPF.ar(snd,SinOsc.kr(0.1).exprange(20,2000)); // modulated filter
		// snd = (snd * MouseX.kr(1,10)).tanh / 2; // mouse-controlled distortion
		// ?????

		///////////////////////////////////////////////////////
		// -------=-- DONE ADDING ANY EFFECTS HERE --------- //
		///////////////////////////////////////////////////////

		// final output
		Out.ar(0,snd*volume/5);
	}).send(s);

	// basic players
	SynthDef("recorder",{
		arg buf,recLevel=1.0,preLevel=0.0;
		RecordBuf.ar(SoundIn.ar([0,1]),buf,0.0,recLevel,preLevel,loop:0,doneAction:2);
	}).send(s);

	// effects
	SynthDef("effects",{
		arg amp=1.0;

		// collect the sound coming from the bus "0" on 2 channels (stereo)
		var snd=In.ar(0,2);

		///////////////////////////////////////////////////////
		// ----- START ADDING YOUR GLOBAL EFFECTS HERE ----- //
		///////////////////////////////////////////////////////

		// add some nice tape compression
		// snd = AnalogTape.ar(snd,0.9,0.8,0.9,2);

		// add some delay
		snd = CombC.ar(snd,0.5,delaytime:0.25,decaytime:1.1);

		// add some reverb
		snd = SelectX.ar(LFNoise2.kr(1/3).range(0.1,0.5),[
			snd,
			FreeVerb2.ar(snd[0],snd[1],50)
			//Fverb.ar(snd[0],snd[1],50,decay:LFNoise2.kr(1/3).range(70,90))
		]);

		// // add some analog chewing (PortedPlugins needed)
		// snd = SelectX.ar(LFNoise2.kr(1/3).range(0,1),[
		// 	snd,
		// 	AnalogChew.ar(snd);
		// ]);

		///////////////////////////////////////////////////////
		// ----- DONE ADDING YOUR GLOBAL EFFECTS HERE ------ //
		///////////////////////////////////////////////////////

		// replace the output with the effected output
		ReplaceOut.ar(0,snd*Lag.kr(amp));
	}).send(s);

	// load the ube class
	u=Ube.new(Server.default);

	Routine {
		// either load a file into the tape
		u.loadTape(tape:1,filename:thisProcess.nowExecutingPath.dirname++"/kalimba.wav");
		// OR record another tape and play it
		// u.recordTape(tape:1,seconds:3,recLevel:2); 3.5.wait;

		0.5.wait; // give time for buffer to load
		// create players to play the tape
		u.playTape(tape:1,player:0,rate:1,db:0,timescale:1);
		u.playTape(tape:1,player:1,rate:0.5,db:3,timescale:1.0);
		u.playTape(tape:1,player:2,rate:0.25,db:6,timescale:1.0);
		u.playTape(tape:1,player:3,rate:0.125,db:9,timescale:1.0);
		u.playTape(tape:1,player:4,rate:2,db:-6,timescale:1.0);
		u.playTape(tape:1,player:5,rate:4,db:-12,timescale:1.0);
		// show gui
		u.gui;

	}.play;



});
)

// TRY IT! load your own sounds, record your own sounds
// change the modulation, change the effects

