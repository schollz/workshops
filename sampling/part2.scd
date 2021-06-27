// lets make a really nice sample player

//////// 1 ////////
// again choose any buffer you want
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_16beats_bpm90.wav");
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_24beats_bpm90.wav");
~bufferPiano=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/upright_32beats_bpm90.wav");
~bufferPiano.plot; // we can visualize this buffer
~bufferPiano.numFrames/b.sampleRate; // length in time
// lets load another buffer
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums1_8beats_bpm90.wav");
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums2_8beats_bpm90.wav");
~bufferDrums=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/drums3_8beats_bpm90.wav");
~bufferDrums.plot; // we can visualize this buffer
~bufferDrums.numFrames/b.sampleRate; // length in time

//////// 2 ////////
// this is the basic sample player from before
(
SynthDef("samplePlayer1", {
	arg out = 0, bufnum = 0;
	var snd;
	snd=PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum));
	Out.ar(out,snd)
}).add;
)

x=Synth("samplePlayer1", [\bufnum, ~bufferPiano]);

// this works well, but what if we want to truncate the sample?
// PlayBuf.ar doesn't have any way to change the end position


//////// 3 ////////
// we can choose an end point if we use two UGens:
// Phasor is a ramp that we can control accurately and
// BufRd is a player that plays at any position you want
(
x=SynthDef("samplePlayer2", {
	arg out=0, bufnum=0, rate=1, start=0, end=1; // add start and end to arguments
	var snd,pos,frames;

	// rate is modified by BufRateScale to convert between sampling rates
	rate = rate*BufRateScale.kr(bufnum);
	// frames is the number of frames
	frames = BufFrames.kr(bufnum);

	// Phasor is a ramp
	pos=Phasor.ar(
		rate:rate,
		start:start*frames,
		end:end*frames,
		resetPos:start*frames,
	);

	// BufRd does the playing
	snd=BufRd.ar(
		numChannels:2,
		bufnum:bufnum,
		phase:pos,
		loop:0,
		interpolation:4,
	);
	Out.ar(out,snd)
}).add;
)

// the Phasor is like a sawtooth that increments at a specific rate
// and returns to the beginning at the end OR if it receives a trigger.
// afaik there is no other UGen that is triggerable, loopable, and has start+end points.
{ Phasor.kr(0,0.5,0,100) }.plot(0.5)
{ Phasor.ar(0,0.005,50,90) }.plot(0.5)

// try it
// note: start and endpoints are denoting by fractional position (0 = start, 1 = end)
x=Synth("samplePlayer2", [\bufnum, ~bufferPiano]); // will start playing
x.set(\start,0.26,\end,0.28)
x.set(\start,0,\end,1)

