// 1. load a buffer
// (everything here assumes you have a STEREO file, but its possible to do this with mono too)
// tested using this file: https://op1.fun/users/3sleeves/patches/boombap1

(
//b=Buffer.read(s,"/home/zns/Documents/sampletutorial/boombap.wav");
b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/sounds/pianochords.wav");
)
// a simple player using PlayBuf
(
SynthDef("PlayBufPlayer", {
    arg out = 0, bufnum = 0;
    var snd;
    snd=PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction: Done.freeSelf);
    Out.ar(out,snd)
}).play(s, [\out, 0, \bufnum, b]);
)

// the problem with above is that it does not allow you to set the end point!


// solution: use BufRd
// we can control playback precisely using an index of sample position
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
x.set(\start,0.5,\end,0.1)


// problem: it doesn't reset!
// solution: use triggers to reset it
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


// problem: it loops infinitely! lets have it loop just once.
// solution: use an envelope to clamp the loop.
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

x.set(\t_trig,1,\start,0.5,\end,0.6,\loops,2)
x.set(\t_trig,1,\start,0.5,\end,0.6,\loops,0.5)
// but now this won't play!
x.set(\t_trig,1,\start,0.5,\end,0.6,\loops,3,\rate,-1)
// we have to change start and positions manually...?
x.set(\t_trig,1,\start,0.6,\end,0.5,\loops,3,\rate,-1)


// envelope of one second
(
{ EnvGen.ar(
    Env.new(
        levels: [0,1,1,0],
        times: [0,1,0],
    ),
)
}.plot(2);
)

// with fancier fadeout
(
{ EnvGen.ar(
    Env.new(
        levels: [0,1,1,0],
        times: [0,1-0.05,0.05],
        curve:\sine,
    ),
)
}.plot(2);
)

// problem: negative rates don't start at the end!
// solution: add in logic to flip start and end points on reverse
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

// problem chord
x.set(\t_trig,1,\start,0.2,\end,0.6,\loops,1,\rate,1)

// problem: lets remove the "pop" when changing samples fast"
// solution: cross-fade automatically between two loopers
(
x=SynthDef("PlayBufPlayer", {
    arg out=0, bufnum=0, rate=1, start=0, end=1, t_trig=0,
    loops=1;
    var snd,snd2,pos,pos2,frames,duration,env;
    var startA,endA,startB,endB,crossfade,aOrB;

    // latch to change trigger between the two
    aOrB=ToggleFF.kr(t_trig);
    startA=Latch.kr(start,aOrB);
    endA=Latch.kr(end,aOrB);
    startB=Latch.kr(start,1-aOrB);
    endB=Latch.kr(end,1-aOrB);
    crossfade=Lag.ar(K2A.ar(aOrB),0.05);


    rate = rate*BufRateScale.kr(bufnum);
    frames = BufFrames.kr(bufnum);
    duration = frames*(end-start)/rate.abs/s.sampleRate*loops; // use rate.abs instead now

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
        resetPos:(((rate>0)*startA)+((rate<0)*endA))*frames,
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
        resetPos:(((rate>0)*startB)+((rate<0)*endB))*frames,
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


~pos1.last
b.numFrames

// 2. then run this!
// determine all the onsets in the file!
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
b=Buffer.read(s,thisProcess.nowExecutingPath.dirname++"/sounds/pianochords.wav",
    action:{
        Synth("OnsetDetection",[\out,0,\bufnum,b.bufnum,\threshold,2.5]);
});
)



// 4. assign a function to play samples
f = {arg i;x.set(\t_trig,1,\start,~pos1[i],\end,~pos1[i+1]);}
g = {arg i; b.loadToFloatArray(~pos1[i]*b.numFrames,(~pos1[i+1]-~pos1[i])*b.numFrames,{arg array; a=array; {~temp=a.plot;~temp.setProperties(\gridOnX,false,\gridOnY,false)}.defer; })};
g.value(0);

f.value(0);

// 5. play a sample!
f.value(0);
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


x.set(\rate,1.25);

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
