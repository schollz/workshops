// 1. first run this!
// it will load in the buffer
(
// tested using this file: https://op1.fun/users/3sleeves/patches/boombap1
//b=Buffer.read(s,"/home/zns/Documents/sampletutorial/boombap.wav");
b=Buffer.read(s,"/home/zns/Documents/sampletutorial/pianochords.wav");
)


// 2. then run this!
// determine all the onsets in the file!
(
SynthDef.removeAt("OnsetDetection");
~pos1=List.new();
o = OSCFunc({ arg msg, time;
	[time, msg].postln;
	~pos1.add(msg[3]);
},'/tr', s.addr);

SynthDef("OnsetDetection", {
	arg bufnum, out, threshold;
	var sig, chain, onsets, pips, pos, env, speedup=1;

	env=EnvGen.ar(
		Env.new(
			levels: [0,1,1,0],
			times: [0,BufDur.kr(bufnum)/speedup,0],
			curve:\sine,
		),
		doneAction: Done.freeSelf
	);

	pos=Phasor.ar(0, BufRateScale.kr(bufnum)*speedup, 0, BufFrames.kr(bufnum),0);
	sig = BufRd.ar(2, bufnum, pos,0);

	chain = FFT(LocalBuf(512), sig[0]+sig[1]);

	onsets = Onsets.kr(chain, threshold, \rcomplex);

	// You'll hear percussive "ticks" whenever an onset is detected
	pips = WhiteNoise.ar(EnvGen.kr(Env.perc(0.001, 0.1, 0.2), onsets));
	SendTrig.kr(onsets,0,Clip.kr((pos-300)/BufFrames.kr(bufnum),0,1));
	Out.ar(out,Pan2.ar(sig, -0.75, 0.2) + Pan2.ar(pips, 0.75, 1));
}).add;
)

(
b=Buffer.read(s,"/home/zns/Documents/sampletutorial/pianochords.wav",action:{
Synth("OnsetDetection",[\out,0,\bufnum,b.bufnum,\threshold,0.4]);
});
)


// 3. now run this!
// this is the sample player
(
x=SynthDef(\go, {
	// basic arguments
	arg out=0, bufnum=0,
	rate=1,fadeout=0.01,loops=1,
	t_trig, start,end;

	// variables
	var env,snd;
	var startA=0,endA=1;
	var bFrames;
	var sampleLength;

	// toggle between
	startA=Latch.kr(start,t_trig);
	endA=Latch.kr(end,t_trig);

	bFrames = BufFrames.kr(bufnum);
	sampleLength=loops*(endA-startA);
	env=EnvGen.ar(
		Env.new(
			levels: [0,1,1,0],
			times: [0.005,sampleLength*(bFrames/48000/rate.abs)-fadeout-0.005,fadeout],
			curve:\sine,
		),
		gate: t_trig,
	);

	snd=BufRd.ar(2,bufnum,
		Phasor.ar(
			trig:t_trig,
			rate:BufRateScale.kr(bufnum)*rate,
			start:((startA*(rate>0))+(endA*(rate<0)))*bFrames,
			end:((endA*(rate>0))+(startA*(rate<0)))*bFrames,
			resetPos:startA*bFrames
		),
		interpolation:4
	);
	Out.ar(out,snd*env);
}).play(s, [\out, 0, \bufnum,b,\rate,1]);
)


// 4. assign a function to play samples
f = {arg i;x.set(\t_trig,1,\start,~pos1[i],\end,~pos1[i+1]);}
g = {arg i; b.loadToFloatArray(~pos1[i]*b.numFrames,(~pos1[i+1]-~pos1[i])*b.numFrames,{arg array; a=array; {a.plot}.defer; })};
g.value(0);
f.value(0);

// 5. play a sample!
f.value(4);
g.value(4); // visualize it

// 6. sequence the samples!
(
~player=[1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,1,4,2,1,3,5,6,1,0,7,8,6,6,0,7,1,3,4,5,1,6,0,6,1,0,5,4,1,7,0,7];
t = Task({
	inf.do({ arg i;
		var toPlay;
		0.25.wait;
		toPlay = ~player[i%~player.size].postln;
		if (toPlay>0,{
			toPlay.postln;
			x.set(\t_trig,1,\start,~pos1[toPlay-1],\end,~pos1[toPlay],\loops,5);
		},{});
	});
}).play;
)

(
~player=[1,1,1,1,2,2,2,2,3,3,3,3,4,4,0,0];
t = Task({
	inf.do({ arg i;
		var toPlay;
		0.125.wait;
		toPlay = ~player[i%~player.size].postln;
		if (toPlay>0,{
			toPlay.postln;
			x.set(\t_trig,1,\start,~pos1[toPlay-1],\end,~pos1[toPlay],\loops,1);
		},{});
	});
}).play;
)


x.set(\rate,1);

t.stop;


Server.default.record; // Start recording

Server.default.stopRecording; // Stop recording.



(
x=SynthDef("CrossfadingPlayer", {
	// basic arguments
	arg out=0, bufnum=0,
	rate=1,fadeout=0.01,loops=1,
	t_trig, start,end;

	// variables
	var env,snd,crossfade;
	var startA=0,endA=1;
	var startB=0,endB=1;
	var aOrB=0;
	var bFrames;
	var sampleLength;

	// toggle between
	aOrB=ToggleFF.kr(t_trig);
	startA=Latch.kr(start,aOrB);
	endA=Latch.kr(end,aOrB);
	startB=Latch.kr(start,1-aOrB);
	endB=Latch.kr(end,1-aOrB);
	crossfade=Lag.ar(K2A.ar(aOrB),0.05);

	bFrames = BufFrames.kr(bufnum);
	sampleLength=loops*((aOrB*(endA-startA))+((1-aOrB)*(endB-startB)));
	env=EnvGen.ar(
		Env.new(
			levels: [0,1,1,0],
			times: [0,sampleLength*(bFrames/48000/rate.abs)-fadeout,fadeout],
			curve:\sine,
		),
		gate: t_trig,
	);

	snd=crossfade*BufRd.ar(2,bufnum,
		Phasor.ar(
			trig:aOrB,
			rate:BufRateScale.kr(bufnum)*rate,
			start:((startA*(rate>0))+(endA*(rate<0)))*BufFrames.kr(bufnum),
			end:((endA*(rate>0))+(startA*(rate<0)))*BufFrames.kr(bufnum),
			resetPos:startA*BufFrames.kr(bufnum)
		),
		interpolation:4
	);
	(1-aOrB);
	snd=snd+((1-crossfade)*BufRd.ar(2,bufnum,
		Phasor.ar(
			trig:(1-aOrB),
			rate:BufRateScale.kr(bufnum)*rate,
			start:((startB*(rate>0))+(endB*(rate<0)))*BufFrames.kr(bufnum),
			end:((endB*(rate>0))+(startB*(rate<0)))*BufFrames.kr(bufnum),
			resetPos:startB*BufFrames.kr(bufnum)
		),
		interpolation:4
	));

	Out.ar(out,snd*env);
}).play(s, [\out, 0, \bufnum,b,\rate,1]);
)


x.set(\t_trig,1,\start,0.04445472497065235,\end,0.07781119822237129);

x.set(\t_trig,1,\start,0.0,\end,0.04445472497065235);
x.set(\t_trig,1,\start,0.07781119822237129,\end,0.13469767315109843);
x.set(\t_trig,1,\start,0.1346976731.5109843,\end,0.1798312091229247);
x.set(\t_trig,1,\start,0.1798312091229247,\end,0.2300635753815194);
x.set(\t_trig,1,\start,0.2300635753815194,\end,0.2822105232265638);
x.set(\t_trig,1,\start,0.2822105232265638,\end,0.3672209039074292);
x.set(\t_trig,1,\start,0.3672209039074292,\end,0.4481864162334396);
x.set(\t_trig,1,\start,0.4481864162334396,\end,0.49438800100620495);
x.set(\t_trig,1,\start,0.49438800100620495,\end,0.533773742243837);
x.set(\t_trig,1,\start,0.533773742243837,\end,0.6169773058862988);
x.set(\t_trig,1,\start,0.6169773058862988,\end,0.6598947132315949);
x.set(\t_trig,1,\start,0.6598947132315949,\end,0.7025626069092739);
x.set(\t_trig,1,\start,0.7025626069092739,\end,0.7508904284755995);
x.set(\t_trig,1,\start,0.7508904284755995,\end,0.7893259223545196);
x.set(\t_trig,1,\start,0.7893259223545196,\end,0.8775963566996478);
x.set(\t_trig,1,\start,0.8775963566996478,\end,0.9508596092570853);
x.set(\t_trig,1,\start,0.9508596092570853,\end,0.9773563935938285);


x.set(\t_trig,1,\start,0.9773563935938285,\end,1.0);

x.set(\t_trig,1,\start,0,\end,1);
x.set(\start,0.3,\end,0.4);
x.set(\t_trig,0,\start,0,\end,1);
x.set(\t_trig,1,\start,0.2,\end,0.22,\loops,15);
x.set(\t_trig,1,\start,0,\end,1);
x.set(\rate,1);
