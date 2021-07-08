//////// -- modulation -- ////////


//////// 1 ////////
// UGens can be used as an audio rate signal with ".ar", e.g.
// SinOsc.ar(...)
// but most UGens can ALSO be used as a control rate signal with ".kr", e.g.
// SinOsc.kr(...)
// control rate signals are not fast enough to generate audio:
(
{
	SinOsc.kr(220)	// will result in no sound!
}.play
)
// but they can be used to modulate any parameter!
(
{
	// use .ar for playing sound, and .kr for parameters
	SinOsc.ar(220+SinOsc.kr(1,mul:20)).dup*0.1
}.play
)

// lets take a tour of modulation...


//////// 2 ////////
// stepped randomness
// using LFNoise0 to generate steps
(
{
	LFNoise0.kr(freq:10)
}.plot(1)
)

(
{
	var mod=LFNoise0.kr(freq:10,mul:20);
	SinOsc.ar(220+mod).dup*0.1;
}.play
)


//////// 3 ////////
// random oscillations
// you can modulate modulations! put LFNoise into a SinOsc!
(
{
	SinOsc.kr(freq:LFNoise0.kr(freq:3)*6)
}.plot(1)
)


(
{
	var mod=SinOsc.kr(freq:LFNoise0.kr(freq:3)*6,mul:20);
	SinOsc.ar(220+mod).dup*0.1;
}.play
)


//////// 4 ////////
// drunken walk
// lets use VarLag to slew the LFNoise
({
	VarLag.kr(LFNoise0.kr(20),1/20,warp:\sine)
}.plot(1))

(
{
	var mod=20*VarLag.kr(LFNoise0.kr(2),1/2,warp:\sine);
	SinOsc.ar(220+mod).dup*0.1;
}.play
)


//////// 5 ////////
// we can easily change the scale of any modulation using
// X.range(low,hi)
({
	SinOsc.kr(freq:LFNoise0.kr(freq:3)*6).range(0,100)
}.plot(1))


// when dealing with frequencies, its useful to use exponential mappings
//
// this spends a lot of time in inaudible ranges:
(
{
	LFTri.kr(10).range(10,20000)
}.plot(1)
)

// whereas, this helps to keep it close to audible:
(
{
	LinExp.kr(LFTri.kr(10),-1,1,10,20000)
}.plot(1)
)


//////// 6 ////////
// lets modulate!
// let's use the following as the starting synth
// it is a Pulse waveform with 3 oscillators at frequencies
// spaced across three octaves
(
x={
	//set some arguments for frequency and amplitude
	arg freq=110, amp=0.1;
	//set a variable to hold the waveform
	var snd;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		snd2=PulseDPW.ar(
			freq:freq2,
			mul:1/(2**i),
			width:0.5,
		);
	});
	//add in a mixer
	snd=Mix.ar(snd);
	//spread the sound across the stereo field
	snd=Splay.ar(snd);
	//pass the sounds through a Moog-inspired VCF, using 
	//the mouse's X position to modulate the cutoff frequency
	snd=MoogFF.ar(snd,LinExp.kr(MouseX.kr(),0,1,100,12000));
	//send the sound to a bus, applying amplification
	Out.ar(0,snd*amp);
}.play;
)


//////// 7 ////////
// bank of modulators
// lets use a bank of modulators
// rrand(lo,hi) will generate an unique value on initialization
(
{
	{
		LFTri.kr(LFNoise0.kr(rrand(10/60,100/3)).range(10/60,100/3))
	}!4;
}.plot(1)
)
// and use the first one in the bank to do pulse width and volume modulation
// each time you run this it will sound a little different, because rrand
// initializes differently each time
(
x={
	arg freq=110, amp=0.1;
	var snd;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/10,1)).range(1/10,1))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		snd2=PulseDPW.ar(
			freq:freq2,
			mul:modAmp/(2**i),
			width:modWidth,
		);
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);
	Out.ar(0,snd*amp);
}.play;
)


//////// 8 ////////
// modulating frequency
// we can use .midicps and .cpsmidi to convert between midi notes and frequency
(
x={
	arg freq=110, amp=0.1;
	var snd;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/10,1)).range(1/10,1))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		// get midi note
		var midinote=freq2.cpsmidi;
		// detune by 1/2 of note
		var detune=0.5;
		// convert the range of one of the modulators in the bank
		var modFreq=modBank[2].range(midinote-detune,midinote+detune).midicps;
		snd2=PulseDPW.ar(
			freq:modFreq,
			mul:modAmp/(2**i),
			width:modWidth,
		);
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);
	Out.ar(0,snd*amp);
}.play;
)




//////// 9 ////////
// your turn!
// take the synth in #8 and try changing things, including:
// - try changing the main oscillator (try VarSaw, SinOsc, LFTri, ..)
// - try changing the frequency
// - try changing the number of oscillators (instead of 3, do 1, 2, ..)
// - try changing the numbers in the .range(..) functions
// - try changing the amount of detuning
// - try changing type of modulation (instead of LFTri, use SinOsc, Pulse, ..)
// - try making the "detune" parameter an argument and set it while its playing
