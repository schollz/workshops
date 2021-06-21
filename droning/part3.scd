//////// -- filters + fx -- ////////
// lets take the oscillator from end of part 2 and give it more character
// there are many filters to choose from - HPF, LPF, BPF, RHPF, RLPF, MoogFF, ...
// lets add one and modulate it


//////// 1 ////////
// lets start from where we left off, with our modulated Pulse synth
(
x={
	arg freq=110, amp=0.5;
	var snd;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/60,1/3)).range(1/60,1/3))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		var midinote=freq2.cpsmidi;
		var detune=0.5;
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

//////// 2 ////////
// envelopes!
// lets give the synth a better introduction by using an envelope to open it
// envelopes are defined in many many ways.
({
	// a very simple envelope with slow attack
	EnvGen.kr(Env.asr(rrand(0.1,10)))
}.plot(1))

(
x={
	arg freq=110, amp=0.5;
	var snd;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/60,1/3)).range(1/60,1/3))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		var midinote=freq2.cpsmidi;
		var detune=0.5;
		var modFreq=modBank[2].range(midinote-detune,midinote+detune).midicps;
		snd2=PulseDPW.ar(
			freq:modFreq,
			mul:modAmp/(2**i),
			width:modWidth,
		);

		// each voice comes in slowly, at different speeds using rrand(lo,hi)
		snd2=snd2*EnvGen.kr(Env.asr(rrand(1,10)));
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);
	Out.ar(0,snd*amp);
}.play;
)

//////// 3 ////////
// filters!
// next lets add a filter to each of the voices
// lots of filters to choose from: LPF, HPF, RHPF, RLPF, MoogFF
(
x={
	arg freq=110, amp=0.5;
	var snd;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/60,1/3)).range(1/60,1/3))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		var midinote=freq2.cpsmidi;
		var detune=0.5;
		var modFreq=modBank[2].range(midinote-detune,midinote+detune).midicps;
		snd2=PulseDPW.ar(
			freq:modFreq,
			mul:modAmp/(2**i),
			width:modWidth,
		);

		// the envelope
		snd2=snd2*EnvGen.kr(Env.asr(rrand(1,10)));

		// add filter, a resonant lpf
		// each part of it is modulated
		snd2=RLPF.ar(snd2,
			freq:LinExp.kr(modBank[4],-1,1,freq,20000),
			rq:modBank[5].range(0.01,1)
		);
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);
	Out.ar(0,snd*amp);
}.play;
)


//////// 4 ////////
// panning!
// next lets add random panning to each voice
// lots of pans to choose from, Pan2, Rotate2, Balance2
(
x={
	arg freq=110, amp=0.5;
	var snd;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/60,1/3)).range(1/60,1/3))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		var midinote=freq2.cpsmidi;
		var detune=0.5;
		var modFreq=modBank[2].range(midinote-detune,midinote+detune).midicps;
		snd2=PulseDPW.ar(
			freq:modFreq,
			mul:modAmp/(2**i),
			width:modWidth,
		);

		// the envelope
		snd2=snd2*EnvGen.kr(Env.asr(rrand(1,10)));

		// add filter, a resonant lpf
		// each part of it is modulated
		snd2=RLPF.ar(snd2,
			freq:LinExp.kr(modBank[4],-1,1,freq,20000),
			rq:modBank[5].range(0.01,1)
		);

		// add panning
		snd2=Pan2.ar(snd2,modBank[6].range(-0.5,0.5));

	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);
	Out.ar(0,snd*amp);
}.play;
)




//////// 5 ////////
// delay!
// finally, lets add delay. there are many delays: AllpassC, CombC, DelayC
// each one is a little different and they can be used to make
// delays as well as flangers and phasers and reverb-ish things
(
x={
	arg freq=110, amp=0.5;
	var snd;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/60,1/3)).range(1/60,1/3))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		var midinote=freq2.cpsmidi;
		var detune=0.5;
		var modFreq=modBank[2].range(midinote-detune,midinote+detune).midicps;
		snd2=PulseDPW.ar(
			freq:modFreq,
			mul:modAmp/(2**i),
			width:modWidth,
		);

		// the envelope
		snd2=snd2*EnvGen.kr(Env.asr(rrand(1,10)));

		// add filter, a resonant lpf
		// each part of it is modulated
		snd2=RLPF.ar(snd2,
			freq:LinExp.kr(modBank[4],-1,1,freq,20000),
			rq:modBank[5].range(0.01,1)
		);

		// add panning
		snd2=Pan2.ar(snd2,modBank[6].range(-0.5,0.5));

		// add delay!
		snd2 = snd2 + CombC.ar(snd2,
			maxdelaytime:0.5,
			delaytime:rrand(0.2,0.5)+VarLag.kr(LFNoise0.kr(rrand(1/60,1/3)),1/2,warp:\sine).range(-0.2,0),
			decaytime:rrand(5,15),
		);
		snd2=LeakDC.ar(snd2); // remove DC bias JIC
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);
	Out.ar(0,snd*amp);
}.play;
)


//////// 6 ////////
// distortion!
// lets add distortion and a global filter
// distortion can be as simple as ().tanh
// or you can use things like CrossoverDistortion, or SineShaper
(
x={
	arg freq=110, amp=0.25;
	var snd;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/60,1/3)).range(1/60,1/3))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		var midinote=freq2.cpsmidi;
		var detune=0.5;
		var modFreq=modBank[2].range(midinote-detune,midinote+detune).midicps;
		snd2=PulseDPW.ar(
			freq:modFreq,
			mul:modAmp/(2**i),
			width:modWidth,
		);

		// the envelope
		snd2=snd2*EnvGen.kr(Env.asr(rrand(1,10)));

		// add filter, a resonant lpf
		// each part of it is modulated
		snd2=RLPF.ar(snd2,
			freq:LinExp.kr(modBank[4],-1,1,freq,20000),
			rq:modBank[5].range(0.01,1)
		);

		// add panning
		snd2=Pan2.ar(snd2,modBank[6].range(-0.5,0.5));

		// add delay!
		snd2 = snd2 + CombC.ar(snd2,
			maxdelaytime:0.5,
			delaytime:rrand(0.2,0.5)+VarLag.kr(LFNoise0.kr(rrand(1/60,1/3)),1/2,warp:\sine).range(-0.2,0),
			decaytime:rrand(5,15),
		);
		snd2=LeakDC.ar(snd2); // remove DC bias JIC
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);

	// global moog filter
	snd=MoogFF.ar(snd,LinExp.kr(MouseX.kr(),0,1,200,20000),1)*8;
	// distortion
	snd=(snd*(1+LinExp.kr(MouseY.kr(),0,1,0.0001,10))).tanh*0.5;

	Out.ar(0,snd*amp);
}.play;
)


//////// 7 ////////
// reverb!
// lets add distortion and a global filter
// distortion can be as simple as ().tanh
// or you can use things like CrossoverDistortion, or SineShaper
(
x={
	arg freq=110, amp=0.1, feedback=0.8;
	var snd;
	var local;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/60,1/3)).range(1/60,1/3))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		var midinote=freq2.cpsmidi;
		var detune=0.5;
		var modFreq=modBank[2].range(midinote-detune,midinote+detune).midicps;
		snd2=PulseDPW.ar(
			freq:modFreq,
			mul:modAmp/(2**i),
			width:modWidth,
		);

		// the envelope
		snd2=snd2*EnvGen.kr(Env.asr(rrand(1,10)));

		// add filter, a resonant lpf
		// each part of it is modulated
		snd2=RLPF.ar(snd2,
			freq:LinExp.kr(modBank[4],-1,1,freq,20000),
			rq:modBank[5].range(0.01,1)
		);

		// add panning
		snd2=Pan2.ar(snd2,modBank[6].range(-0.5,0.5));

		// add delay!
		snd2 = snd2 + CombC.ar(snd2,
			maxdelaytime:0.5,
			delaytime:rrand(0.2,0.5)+VarLag.kr(LFNoise0.kr(rrand(1/60,1/3)),1/2,warp:\sine).range(-0.2,0),
			decaytime:rrand(5,15),
		);
		snd2=LeakDC.ar(snd2); // remove DC bias JIC
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);

	// global moog filter
	snd=MoogFF.ar(snd,LinExp.kr(MouseX.kr(),0,1,20,20000),1)*8;
	// distortion
	snd=(snd*(1+LinExp.kr(MouseY.kr(),0,1,0.0001,10))).tanh*0.5;

	// reverb with feedback
	local = LocalIn.ar(2)+snd;
	15.do({local=AllpassN.ar(local,0.06,Rand(0.001,0.06),3)});
	LocalOut.ar(local*feedback);
	snd = (snd+local)/2;

	Out.ar(0,snd*amp);
}.play;
)

//////// 6 ////////
// your turn!
// take the synth in #5 or #6 and try changing things, including:
// - try changing the main oscillator (try VarSaw, SinOsc, LFTri, ..)
// - try changing the frequency
// - try changing the number of oscillators (instead of 3, do 1, 2, ..)
// - try changing the numbers in the .range(..) functions
// - try changing type of modulation (instead of LFTri, use SinOsc, Pulse, ..)
// - try changing a "rrand(..)" function into a source of modulation, e.g. rrand(5,15) => modBank[7].range(5,15)
// - try making the "detune" parameter an argument and set it while its playing
// - try making the "delaytime" and "decaytime" parameter in the delay
// - change a modBank[x] into your own modulator (see previous)
// - make into a SynthDef and play a chord (see #16 of part 1)

