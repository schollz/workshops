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
	SinOsc.ar(220+SinOsc.kr(1,mul:20))
}.play
)

// lets take a tour of modulation...


//////// 2 ////////
// stepped randomness
// using LFNoise0 to generate steps
({
	LFNoise0.kr(freq:10)
}.plot(1))

(
{
	var mod=LFNoise0.kr(freq:10,mul:20);
	SinOsc.ar(220+mod);
}.play
)


//////// 3 ////////
// random oscillations
// you can modulate modulations! put LFNoise into a SinOsc!
({
	SinOsc.kr(freq:LFNoise0.kr(freq:3)*6)
}.plot(1))


(
{
	var mod=SinOsc.kr(freq:LFNoise0.kr(freq:3)*6,mul:20);
	SinOsc.ar(220+mod);
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
	var mod=20*VarLag.kr(LFNoise0.kr(20),1/20,warp:\sine);
	SinOsc.ar(220+mod);
}.play
)


//////// 5 ////////
// we can easily change the scale of any modulation using
// X.range(low,hi)
({
	SinOsc.kr(freq:LFNoise0.kr(freq:3)*6).range(0,100)
}.plot(1))


// when dealing with frequencies, its useful to deal with exponentials
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
// take the synth from step #15 and modulate frequency
(
x={
	arg freq=220, amp=0.5;
	var snd;
	snd=Array.fill(3,{arg i;
		var modFreq=freq*0.02*LFNoise0.kr(5);
		VarSaw.ar(
			freq:freq+modFreq,
			mul:amp/(2**i),
		)
	});
	snd=Mix.ar(snd); // mixes the three channels into 1
	snd=Splay.ar(snd);
	Out.ar(0,snd*amp);
}.play;
)

//////// 7 ////////
// take the synth from step #15 and modulate frequency
// and modulate amplitude
(
x={
	arg freq=220, amp=0.5;
	var snd;
	snd=Array.fill(3,{arg i;
		var modFreq=freq*0.02*LFNoise0.kr(10);
		var modAmp=SinOsc.kr(LFNoise0.kr(freq:10)).range(0.1,1);
		VarSaw.ar(
			freq:freq+modFreq,
			mul:amp/(2**i)*modAmp,
		)
	});
	snd=Mix.ar(snd); // mixes the three channels into 1
	snd=Splay.ar(snd);
	Out.ar(0,snd*amp);
}.play;
)


//////// 7 ////////
// take the synth from step #15 and modulate frequency
// and modulate amplitude and modulate pulse width
(
x={
	arg freq=220, amp=0.5;
	var snd;
	snd=Array.fill(3,{arg i;
		var modFreq=freq*0.02*LFNoise0.kr(10);
		var modAmp=SinOsc.kr(LFNoise0.kr(freq:10)).range(0.1,1);
		var modWidth=VarLag.kr(LFNoise0.kr(2),1/2,warp:\sine).range(0.3,0.8);
		VarSaw.ar(
			freq:freq+modFreq,
			mul:amp/(2**i)*modAmp,
			width:modWidth,
		)
	});
	snd=Mix.ar(snd); // mixes the three channels into 1
	snd=Splay.ar(snd);
	Out.ar(0,snd*amp);
}.play;
)


//////// 8 ////////
// your turn!
// try changing the modulation of modFreq, modAmp, or modWidth
// try changing the number of oscillators, e.g. Array.fill(<your favorite number>...
// try changing the oscillator type: https://doc.sccode.org/Browse.html#UGens%3EGenerators%3EDeterministic
