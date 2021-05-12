// Server.default.record; // Start recording
// Server.default.stopRecording; // Stop recording.

// 1. load a buffer
(
  b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/pianochords.wav");
)


// 2. a simple player using PlayBuf
(
SynthDef("PlayBufPlayer", {
    arg out = 0, bufnum = 0;
    var snd;
    snd=PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction: Done.freeSelf);
    Out.ar(out,snd)
}).play(s, [\out, 0, \bufnum, b]);
)


// the problem with above is that it does not allow you to set the end point!

// solution:
// 3. use BufRd + Phasor for precise playback
(
x=SynthDef("PlayBufPlayer", {
    arg out=0, bufnum=0, rate=1, start=0, end=1;
    var snd,pos,frames;

    rate = rate*BufRateScale.kr(bufnum);
    frames = BufFrames.kr(bufnum);

    pos=Phasor.ar(
        rate:rate,
        start:start*frames,
        end:end*frames,
        resetPos:start*frames,
    );

    snd=BufRd.ar(
        numChannels:2,
        bufnum:bufnum,
        phase:pos,
        loop:0,
        interpolation:4,
    );
    Out.ar(out,snd)
}).play(s, [\out, 0, \bufnum, b]);
)

// the Phasor is like a sawtooth that increments at a specific rate
// and returns to the beginning at the end OR if it receives a trigger.
// afaik there is no other UGen that is triggerable, loopable, and has start+end points.
{ Phasor.kr(0,0.5,0,100) }.plot(1)
{ Phasor.ar(0,0.005,50,90) }.plot(1)

// try it
// note: start and endpoints are denoting by fractional position (0 = start, 1 = end)
x.set(\start,0,\end,1)
x.set(\start,0,\end,0.1)
x.set(\start,0.5,\end,0.6)

// the problem with above is that it doesn't let you reset!

// solution:
// 4. use trigger to allow resetting sample
(
x=SynthDef("PlayBufPlayer", {
    arg out=0, bufnum=0, rate=1, start=0, end=1, t_trig=0;
    var snd,pos,frames;

    rate = rate*BufRateScale.kr(bufnum);
    frames = BufFrames.kr(bufnum);

    pos=Phasor.ar(
        trig:t_trig,
        rate:rate,
        start:start*frames,
        end:end*frames,
        resetPos:start*frames,
    );

    snd=BufRd.ar(
        numChannels:2,
        bufnum:bufnum,
        phase:pos,
        loop:0,
        interpolation:4,
    );
    Out.ar(out,snd)
}).play(s, [\out, 0, \bufnum, b]);
)

// this will abruptly restart it!
x.set(\t_trig,1,\start,0,\end,1)
x.set(\t_trig,1,\start,0.5,\end,1)

// the problem with above is that it won't let you change the size of loop!

// solution:
// 5. use an Envelope to control looping
(
x=SynthDef("PlayBufPlayer", {
    arg out=0, bufnum=0, rate=1, start=0, end=1, t_trig=1,
    loops=1;
    var snd,pos,frames,duration,env;

    rate = rate*BufRateScale.kr(bufnum);
    frames = BufFrames.kr(bufnum);
    duration = frames*(end-start)/rate/s.sampleRate*loops;

    // envelope to clamp looping
    env=EnvGen.ar(
        Env.new(
            levels: [0,1,1,0],
            times: [0,duration-0.01,0.01],
            curve:\sine,
        ),
        gate:t_trig,
    );

    pos=Phasor.ar(
        trig:t_trig,
        rate:rate,
        start:start*frames,
        end:end*frames,
        resetPos:start*frames,
    );

    snd=BufRd.ar(
        numChannels:2,
        bufnum:bufnum,
        phase:pos,
        interpolation:4,
    );

    snd = snd * env;

    Out.ar(out,snd)
}).play(s, [\out, 0, \bufnum, b]);
)

x.set(\t_trig,1,\start,0.0,\end,0.15,\loops,1)
x.set(\t_trig,1,\start,0.5,\end,0.52,\loops,6)

x.set(\t_trig,1,\start,0.5,\end,0.6,\loops,1)

// envelope of one second

({
EnvGen.ar(
    Env.new(
        levels: [0,1,1,0],
        times: [0,1,0],
    ),
)
}.plot(2);)

// with fancier fadeout/fadein
(
{ EnvGen.ar(
    Env.new(
        levels: [0,1,1,0],
        times: [0.2,1-0.4,0.2],
        curve:\sine,
    ),
)
}.plot(2);
)

// new problem:
// now this won't play!
x.set(\t_trig,1,\start,0.5,\end,0.6,\loops,3,\rate,-1)
// we have to change start and positions manually...?
x.set(\t_trig,1,\start,0.6,\end,0.5,\loops,3,\rate,-1)


// solution:
// 6. automatically detect reversing and swap start/end points
(
x=SynthDef("PlayBufPlayer", {
    arg out=0, bufnum=0, rate=1, start=0, end=1, t_trig=1,
    loops=1;
    var snd,pos,frames,duration,env;

    rate = rate*BufRateScale.kr(bufnum);
    frames = BufFrames.kr(bufnum);
    duration = frames*(end-start)/rate.abs/s.sampleRate*loops; // use rate.abs instead now

    // envelope to clamp looping
    env=EnvGen.ar(
        Env.new(
            levels: [0,1,1,0],
            times: [0,duration,0],
        ),
        gate:t_trig,
    );

    pos=Phasor.ar(
        trig:t_trig,
        rate:rate,
        start:(((rate>0)*start)+((rate<0)*end))*frames,
        end:(((rate>0)*end)+((rate<0)*start))*frames,
        resetPos:(((rate>0)*start)+((rate<0)*end))*frames,
    );

    snd=BufRd.ar(
        numChannels:2,
        bufnum:bufnum,
        phase:pos,
        interpolation:4,
    );

    snd = snd * env;

    Out.ar(out,snd)
}).play(s, [\out, 0, \bufnum, b]);
)
x.set(\t_trig,1,\start,0.5,\end,0.6,\loops,3,\rate,-1)
x.set(\t_trig,1,\start,0.5,\end,0.6,\loops,3,\rate,1)

// problem, triggering this a lot causes bad pops!
x.set(\t_trig,1,\start,0.2,\end,0.6,\loops,1,\rate,1)

// solution:
// 7. crossfade loops
(
x=SynthDef("PlayBufPlayer", {
    arg out=0, bufnum=0, rate=1, start=0, end=1, reset=0, t_trig=0,
    loops=1;
    var snd,snd2,pos,pos2,frames,duration,env;
    var startA,endA,startB,endB,resetA,resetB,crossfade,aOrB;

    // latch to change trigger between the two
    aOrB=ToggleFF.kr(t_trig);
    startA=Latch.kr(start,aOrB);
    endA=Latch.kr(end,aOrB);
	resetA=Latch.kr(reset,aOrB);
    startB=Latch.kr(start,1-aOrB);
    endB=Latch.kr(end,1-aOrB);
    resetB=Latch.kr(reset,1-aOrB);
    crossfade=Lag.ar(K2A.ar(aOrB),0.05);


    rate = rate*BufRateScale.kr(bufnum);
    frames = BufFrames.kr(bufnum);
    duration = frames*(end-start)/rate.abs/s.sampleRate*loops;

    // envelope to clamp looping
    env=EnvGen.ar(
        Env.new(
            levels: [0,1,1,0],
            times: [0,duration-0.05,0.05],
        ),
        gate:t_trig,
    );

    pos=Phasor.ar(
        trig:aOrB,
        rate:rate,
        start:(((rate>0)*startA)+((rate<0)*endA))*frames,
        end:(((rate>0)*endA)+((rate<0)*startA))*frames,
        resetPos:(((rate>0)*resetA)+((rate<0)*endA))*frames,
    );
    snd=BufRd.ar(
        numChannels:2,
        bufnum:bufnum,
        phase:pos,
        interpolation:4,
    );

    // add a second reader
    pos2=Phasor.ar(
        trig:(1-aOrB),
        rate:rate,
        start:(((rate>0)*startB)+((rate<0)*endB))*frames,
        end:(((rate>0)*endB)+((rate<0)*startB))*frames,
        resetPos:(((rate>0)*resetB)+((rate<0)*endB))*frames,
    );
    snd2=BufRd.ar(
        numChannels:2,
        bufnum:bufnum,
        phase:pos2,
        interpolation:4,
    );

    Out.ar(out,(crossfade*snd)+((1-crossfade)*snd2) * env)
}).play(s, [\out, 0, \bufnum, b]);
)

x.set(\t_trig,1,\start,0.2,\end,0.6,\loops,1,\rate,1)
x.set(\t_trig,1,\start,0.2,\end,0.6,\loops,1,\rate,-1)


// COOL! now what do we do with all of this!
// 8. bonus: detect onsets and make patterns
(
SynthDef.removeAt("OnsetDetection");

o = OSCFunc({ arg msg, time;
	[time, msg].postln;
	if (msg[3]-~pos1.last>(0.15*s.sampleRate/b.numFrames),{
		"added".postln;
		~pos1.add(msg[3]);
	},{});
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

    onsets = Onsets.kr(chain, threshold, \rcomplex,mingap:160);

    // You'll hear percussive "ticks" whenever an onset is detected
    pips = WhiteNoise.ar(EnvGen.kr(Env.perc(0.001, 0.1, 0.2), onsets));
    SendTrig.kr(onsets,0,Clip.kr((pos-300)/BufFrames.kr(bufnum),0,1));
    Out.ar(out,Pan2.ar(sig, -0.75, 0.2) + Pan2.ar(pips, 0.75, 1));
}).add;
)

(
~pos1=List.new();
~pos1.add(0);
b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/pianochords.wav",
    action:{
        Synth("OnsetDetection",[\out,0,\bufnum,b.bufnum,\threshold,2.0]); // CHANGE THRESHOLD TO SOMETHING THAT WORKS
});
)

Server.default.record; // Start recording
 Server.default.stopRecording; // Stop recording.



// play back splices
f = {arg i;x.set(\t_trig,1,\start,~pos1[i],\end,~pos1[i+1]);}
f.value(0);
f.value(1);

// visualize splices
g = {arg i; b.loadToFloatArray(~pos1[i]*b.numFrames,(~pos1[i+1]-~pos1[i])*b.numFrames,{arg array; a=array; {~temp=a.plot;~temp.setProperties(\gridOnX,false,\gridOnY,false)}.defer; })};
g.value(0);
g.value(1); // visualize it

// sequence the splices
(
~player=[1,0,2,0,2,0,0,0,3,3,3,3,4,0,3,0];
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

t.stop;


// breakbeats
(
b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/breakbeats_160bpm_4beats.wav");
)

(
t.stop;x.set(\rate,0);
t = Task({
	var bpm=160;
	var beats=4;
	var subdivision=4;
	x.set(\t_trig,1,\start,0,\end,1,\rate,1,\loops,1000);
    inf.do({ arg i;
		var curtick;
		(60/bpm/(subdivision)).wait;
		curtick=i%(beats*subdivision);
		curtick.postln;

		// random lock in to the actual beat
		if (16.rand>13,{
			"locking".postln;
			x.set(\t_trig,1,\reset,curtick/(beats*subdivision),\start,0,\end,1,\rate,1,\loops,1000);
		},{});
		// randomly break the beat
		if (16.rand>12,{
			"breaking".postln;
			x.set(\t_trig,1,\start,curtick/(beats*subdivision),\reset,curtick/(beats*subdivision),\end,(curtick+((beats*subdivision)-curtick).rand)/(beats*subdivision),\rate,(2.rand*2-1),\loops,1000);
		},{});

		// randomly reverse
		if (32.rand>30,{
			"reversing?".postln;
			x.set(\rate,(2.rand*2-1));
		},{});
		// randomly slow
		if (32.rand>30,{
			"slowdown".postln;
			x.set(\rate,(2.rand*2-1)*0.5);
		},{});
		// randomly speed
		if (32.rand>30,{
			"speedup".postln;
			x.set(\rate,(2.rand*2-1)*2);
		},{});
    });
}).play;
)
// stop it
t.stop;x.set(\rate,0);


