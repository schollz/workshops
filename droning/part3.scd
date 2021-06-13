//////// -- filters + fx -- ////////
// lets take the oscillator from end of part 2 and give it more character
// there are many filters to choose from - HPF, LPF, BPF, RHPF, RLPF, MoogFF, ...
// lets add one and modulate it


//////// 1 ////////
// advanced multichannel expansion
// we can use rrand to generate random numbers on initialization
(
{
	Array.fill(2,{arg i; SinOsc.kr(1+rrand(0,100))});
	// shorthand version:
	// {SinOsc.kr(1+rrand(0,100))}!2
}.plot(1)
)


//////// 2 ////////
// lets add a resonant low-pass filter and modulate both frequency and q
(
x={
	arg freq=220, amp=0.5;
	var snd;
	snd=Array.fill(3,{arg i;
		var modFreq=freq*0.02*LFNoise0.kr(rrand(5,15));
		var modAmp=SinOsc.kr(LFNoise0.kr(rrand(5,15))).range(0.1,1);
		var modWidth=VarLag.kr(LFNoise0.kr(2),1/2,warp:\sine).range(0.3,0.8);
		VarSaw.ar(
			freq:freq+modFreq,
			mul:amp/(2**i)*modAmp,
			width:modWidth,
		)
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);

	// add filter!
	snd=RLPF.ar(snd,
		freq:LinExp.kr(LFTri.kr(0.24),-1,1,freq,20000),
		rq:SinOsc.kr(0.23).range(0.1,1)
	);


	Out.ar(0,snd*amp);
}.play;
)


//////// 3 ////////
// lets add delay! there are many delays: https://doc.sccode.org/Browse.html#UGens%3EDelays
// CombC, DelayC
(
x={
	arg freq=220, amp=0.5;
	var snd;
	snd=Array.fill(7,{arg i;
		var modFreq=freq*0.02*LFNoise0.kr(rrand(5,15));
		var modAmp=SinOsc.kr(LFNoise0.kr(rrand(5,15))).range(0.1,1);
		var modWidth=VarLag.kr(LFNoise0.kr(2),1/2,warp:\sine).range(0.3,0.8);
		VarSaw.ar(
			freq:freq+modFreq,
			mul:amp/(2**i)*modAmp,
			width:modWidth,
		)
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);

	// add filter!
	snd=RLPF.ar(snd,
		freq:LinExp.kr(LFTri.kr(0.24),-1,1,freq,20000),
		rq:SinOsc.kr(0.23).range(0.1,1)
	);

	// add delay!
	snd = snd + CombC.ar(snd,
		maxdelaytime:0.5,
		delaytime:VarLag.kr(LFNoise0.kr(2),1/2,warp:\sine).range(0.48,0.5),
		decaytime:3,
	);
	snd=LeakDC.ar(snd); // remove DC bias JIC


	Out.ar(0,snd*amp);
}.play;
)

//////// 4 ////////
// lets add distortion
// multiple ways to do this
// snd = (snd * X).tanhl
// snd = CrossoverDistortion.ar(snd);
(
x={
	arg freq=220, amp=0.1;
	var snd;
	snd=Array.fill(7,{arg i;
		var modFreq=freq*0.02*LFNoise0.kr(rrand(5,15));
		var modAmp=SinOsc.kr(LFNoise0.kr(rrand(5,15))).range(0.1,1);
		var modWidth=VarLag.kr(LFNoise0.kr(2),1/2,warp:\sine).range(0.3,0.8);
		VarSaw.ar(
			freq:freq+modFreq,
			mul:amp/(2**i)*modAmp,
			width:modWidth,
		)
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);

	// add filter!
	snd=RLPF.ar(snd,
		freq:LinExp.kr(LFTri.kr(0.24),-1,1,freq,20000),
		rq:SinOsc.kr(0.23).range(0.1,1)
	);

	// add delay!
	snd = snd + CombC.ar(snd,
		maxdelaytime:0.5,
		delaytime:VarLag.kr(LFNoise0.kr(2),1/2,warp:\sine).range(0.48,0.5),
		decaytime:3,
	);
	snd=LeakDC.ar(snd); // remove DC bias JIC

	// UGen for distortion
	// snd = CrossoverDistortion.ar(snd);
	// simple tanh
	snd = (snd*10).tanh;

	Out.ar(0,snd*amp);
}.play;
)



//////// 6 ////////
// lets rearrange!
// what if the filter applied to each synth?
// what if we had 7 synths?
(
x={
	arg freq=220, amp=0.1;
	var snd;
	snd=Array.fill(7,{arg i;
		var modFreq=freq*0.005*LFNoise0.kr(rrand(10,20));
		var modAmp=SinOsc.kr(LFNoise0.kr(freq:rrand(5,20))).range(0.1,1);
		var modWidth=VarLag.kr(LFNoise0.kr(rrand(1,3)),1/2,warp:\sine).range(0.0,1.0);
		var snd2=Pulse.ar(
			freq:freq+(modFreq*i),
			mul:amp*modAmp,
			width:modWidth,
		);
		snd2=RLPF.ar(snd2,
			freq:LinExp.kr(LFTri.kr(rrand(0.1,1)),-1,1,freq/2,20000),
			rq:SinOsc.kr(0.23).range(0.2,1)
		);
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);

	// add delay!
	snd = snd + CombC.ar(snd,
		maxdelaytime:0.5,
		delaytime:VarLag.kr(LFNoise0.kr(2),1/2,warp:\sine).range(0.48,0.5),
		decaytime:4,
	);
	snd=LeakDC.ar(snd); // remove DC bias JIC

	Out.ar(0,snd*amp);
}.play;
)