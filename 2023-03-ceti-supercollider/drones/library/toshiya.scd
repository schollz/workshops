(
SynthDef("toshiya",{
	arg hz=440,amp=1.0;
	var snd,fx,y,z;
	var note=hz.cpsmidi;
	var numOscillators = 12;
	snd=Mix.ar({
		var osc1,osc2,env,snd;
		snd=SinOsc.ar((note+rrand(-0.05,0.05)).midicps);
		snd=LPF.ar(snd,LinExp.kr(SinOsc.kr(rrand(1/30,1/10),rrand(0,2*pi)),-1,1,20,12000),2);
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/NRand(10,20,3) );
		Pan2.ar(snd,LFNoise2.kr(1/2))/numOscillators
	}!numOscillators);
	snd=MoogLadder.ar(snd.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*2,hz*10));

	// // add some klank underneath everything
	snd=snd+(Amplitude.kr(snd)*LFNoise2.kr(1).range(0.5,2)*Klank.ar(`[[hz, hz*2+23, hz*4+53], nil, [1, 1, 1]], PinkNoise.ar([0.007, 0.007])));

	Out.ar(0,amp*snd*EnvGen.ar(Env.adsr(3,3,1,3,curve:4),\gate.kr(1),doneAction:2));
}).add;
)
