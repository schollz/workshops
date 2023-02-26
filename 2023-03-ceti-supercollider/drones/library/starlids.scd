(
SynthDef("starlids",{
    arg hz=440,amp=1.0;
	var snd,fx;
	// convert hertz into midi notes
	var note=hz.cpsmidi;
	// mix in 12 other oscillators (#12 is arbitary)
	snd=Mix.ar({
		var osc1,osc2,env,snd;
		// osc1+osc2 control the interval
		osc1=LFTri.kr(rrand(1/100,1/30),rrand(0,2*pi)).range(0,2).floor;
		osc2=LFTri.kr(rrand(1/100,1/30),rrand(0,2*pi)).range(0,2).floor;
		// define sawtooth oscillator with pitch oscillating between +0, +4, +5, and +9 semitones
		// those define intervals of a major third, major fourth and major sixth relative to root
		snd=SawDPW.ar((note+(4*osc1)+(5*osc2)).midicps);
		// each oscillator goes in and out according to a randomly oscillating LPF
		snd=LPF.ar(snd,LinExp.kr(SinOsc.kr(rrand(1/30,1/10),rrand(0,2*pi)),-1,1,20,12000));
		// each oscillator has a small delay which serves as a chorus effect
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
		// each oscillate indepedently oscillates in stereo field
		Pan2.ar(snd,LFNoise2.kr(1/rrand(2,4)))/12*amp
	}!16);
	// entire sound randomly modulates through a LPF
	snd=MoogLadder.ar(snd.tanh,LinExp.kr(LFNoise2.kr(1/6),-1,1,hz*8,hz*60));
	// cut out low frequencies
	snd=HPF.ar(snd,20);
	Out.ar(0,snd*EnvGen.ar(Env.adsr(3,3,1,3,curve:4),\gate.kr(1),doneAction:2));
}).add;
)

