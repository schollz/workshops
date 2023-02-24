// first goto https://github.com/schollz/airsynth/releases/latest
// download the version for your computer
// open and run "airsynth"

s.boot;

// this is the drone
// replace with whatever you want
(
SynthDef("drone",{
	arg amp=0.5,cFilter=1,cFreq=0,cAmp=0;
	var snd;
	var local;
	var freq;
	var scaleD=Scale.minorPentatonic;
	var scaleFull=32+(scaleD.degrees++(24+scaleD.degrees)++(48+scaleD.degrees));
	cFilter=Lag.kr(cFilter,0.2);
	cFreq=Lag.kr(cFreq,0.02);
	cAmp=Lag.kr(cAmp,0.2);
	freq = (Select.kr(Lag.kr(LinLin.kr(cFreq,0,1,0,scaleFull.size),0.05),scaleFull)).midicps;
	snd=Array.fill(3,{arg i;
		var snd2;
		var freq2=freq*(2**i);
		var modBank={LFTri.kr(LFNoise0.kr(rrand(1/60,1/3)).range(1/60,1/3))}!8;
		var modAmp=modBank[0].range(0.2,0.5); // convert to correct range
		var modWidth=modBank[1].range(0.2,0.8);
		var midinote=freq2.cpsmidi;
		var detune=0.05;
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
			// rq:modBank[5].range(0.01,1)
		);

		// add panning
		snd2=Pan2.ar(snd2,modBank[6].range(-0.5,0.5));

		// add delay!
		snd2 = snd2 + CombC.ar(snd2,
			maxdelaytime:0.5,
			delaytime:rrand(0.1,0.3),
			decaytime:rrand(5,15),
		);
		snd2=LeakDC.ar(snd2); // remove DC bias JIC
	});
	snd=Mix.ar(snd);
	snd=Splay.ar(snd);

	// global moog filter
	snd=MoogFF.ar(snd,LinExp.kr(cFilter.poll,0,1,20,10000).poll,Clip.kr(LinExp.kr(cAmp,1,0,0.1,1),0.1,1));

	snd = (snd*LinExp.kr(cAmp,0,1,0.5,10)).tanh*0.5;

	snd = FreeVerb2.ar(snd[0],snd[1],room:1);
	Out.ar(0,snd);
}).add;
)


// once "airsynth" is running you can run this code
// and it will listen to your hands
// open/close hands = filter open close
// raise hand = increase volume
// hand left/right = change pitch
(
x=Synth("drone");
~o1 = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln;
	x.set(\cFreq,msg[1],\cAmp,msg[2],\cFilter,msg[3]);
}, '/right');
y=Synth("drone");
~o2 = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln;
	y.set(\cFreq,msg[1],\cAmp,msg[2]*1.5,\cFilter,msg[3]);
}, '/left');
)

