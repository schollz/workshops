// 1. Tone
(
x = SynthDef("basic",
    {
        arg hz=131.81, amp=0.5;
        var sig; // define variables we need

        // the drone zone!
        sig = SinOsc.ar(
            freq:hz,
            mul:amp,
        );

        // make two versions, one for left and one for right
        sig = sig.dup;

        // make sound!
        Out.ar(0,sig);
    }
).play;
)

x.set("hz",65.41*4); // up can octave
x.set("amp",0.01); // volume down



// 2. Add overtones
(
x = SynthDef("basic_w_overtones",
    {
        arg hz=131.81, amp=0.5;
        var sig;

        // the drone zone!
        sig = Mix.ar([
            SinOsc.ar(
                freq: hz,
                mul: amp,
            ),
            SinOsc.ar(
                freq: hz*2,
                mul: amp/2,
            ),
            SinOsc.ar(
                freq: hz*4,
                mul: amp/4,
            )
        ]);

        // spread the signal
        sig = Splay.ar(sig);

        // make sound!
        Out.ar(0,sig);
    }
).play;
)




// 3. Different oscillators
(
x = SynthDef("basic_w_overtones_varsaw",
    {
        arg hz=131.81, amp=0.5;
        var sig;

        // the drone zone!
        sig = Mix.ar([
            VarSaw.ar(
                freq: hz,
                mul: amp,
            ),
            VarSaw.ar(
                freq: hz*2,
                mul: amp/2,
            ),
            VarSaw.ar(
                freq: hz*4,
                mul: amp/4,
            )
        ]);

        // spread the signal
        sig = Splay.ar(sig);

        // make sound!
        Out.ar(0,sig);
    }
).play;
)


// 4. Add modulation

// stepped randomness
{LFNoise0.kr(freq:10)}.plot(1)

// oscillating randomness
{SinOsc.kr(freq:LFNoise0.kr(freq:2)*4)}.plot(4)

// drunken walk
{VarLag.kr(LFNoise0.kr(5).range(0,100),1/5,warp:\sine)}.plot(4)


(
x = SynthDef("basic_w_overtones_varsaw_modulation",
    {
        arg hz=131.81, amp=0.5;
        var sig;

        // the drone zone!
        sig = Mix.ar(
            VarSaw.ar(
                freq: Lag.kr(hz * SinOsc.kr(LFNoise0.kr(1)).range(0.99,1.01),1),
                width: SinOsc.kr(LFNoise0.kr(1)).range(0.4,0.6),
                mul: amp ,
            ) +
            VarSaw.ar(
                freq: Lag.kr(2*hz * SinOsc.kr(LFNoise0.kr(1)).range(0.99,1.01),1),
                width: SinOsc.kr(LFNoise0.kr(1)).range(0.4,0.6),
                mul: amp/2,
            ) +
            VarSaw.ar(
                freq: Lag.kr(4*hz * SinOsc.kr(LFNoise0.kr(1)).range(0.99,1.01),1),
                width: SinOsc.kr(LFNoise0.kr(1)).range(0.4,0.6),
                mul: amp/4,
            )
        );

        // spread the signal
        sig = Splay.ar(sig);

        // pan
        sig = Balance2.ar(sig[0] ,sig[1],SinOsc.kr(
            LFNoise0.kr(0.1).range(0.05,0.2)
        )*0.1);

        // make sound!
        Out.ar(0,sig);
    }
).play;
)


// 5. Add filter + effects
(
x = SynthDef("dreamcrusher",
    {
        arg hz=131.81, amp=0.5,t_trig=0;
        var local, ampcheck, sig, env;

		// envelope to clamp looping
		env=EnvGen.ar(
			Env.new(
				levels: [0,1,1,0],
				times: [0.5,1,0.5],
			),
			gate:t_trig,
		);

        // the oscillator part
        sig = Mix.ar(
            VarSaw.ar(
                freq: Lag.kr(hz * SinOsc.kr(LFNoise0.kr(1)).range(0.99,1.01),1),
                width: SinOsc.kr(LFNoise0.kr(1)).range(0.4,0.6),
                mul: amp,
            ) +
            VarSaw.ar(
                freq: Lag.kr(2*hz * SinOsc.kr(LFNoise0.kr(1)).range(0.99,1.01),1),
                width: SinOsc.kr(LFNoise0.kr(1)).range(0.4,0.6),
                mul: amp/2,
            ) +
            VarSaw.ar(
                freq: Lag.kr(4*hz * SinOsc.kr(LFNoise0.kr(1)).range(0.99,1.01),1),
                width: SinOsc.kr(LFNoise0.kr(1)).range(0.4,0.6),
                mul: amp/4,
            )
        );

        // spread the signal
        sig = Splay.ar(sig);

        // pan
        sig = Balance2.ar(sig[0] ,sig[1],SinOsc.kr(
            LFNoise0.kr(0.1).range(0.05,0.5)
        )*0.1);

        // feedback directly taken from the docs
        // https://depts.washington.edu/dxscdoc/Help/Classes/LocalOut.html
        ampcheck = Amplitude.kr(sig);
        sig = sig * (ampcheck > 0.02); // noise gate
        local = LocalIn.ar(2);
        local = OnePole.ar(local, 0.4);
        local = OnePole.ar(local, -0.08);
        local = Rotate2.ar(local[0], local[1],0.2);
        local = DelayN.ar(local, 0.3,
            VarLag.kr(LFNoise0.kr(0.1).range(0.15,0.3),1/0.1,warp:\sine)
        );
        local = LeakDC.ar(local);
        sig = ((local + sig) * 1.25).softclip;

        // filter with drunken walk modulation
        sig = LPF.ar(sig,
            VarLag.kr(LFNoise0.kr(0.3).range(hz,16000),1/0.3,warp:\sine)
        );

        // feedback
        LocalOut.ar(sig*
            VarLag.kr(LFNoise0.kr(2).range(0.9,1.2),1/2,warp:\sine)
        );

        // panning
        sig = Balance2.ar(sig[0] * 0.2,sig[1]*0.2,SinOsc.kr(
            LFNoise0.kr(0.1).range(0.05,0.2)
        )*0.1)*amp;

        // send it out
        Out.ar(0,sig);
    }
).play;
)

// other effects?

// add filter
sig = MoogLadder.ar(sig,
        VarLag.kr(LFNoise0.kr(5).range(80,2000),1/5,warp:\sine),
        VarLag.kr(LFNoise0.kr(5).range(0,1.0),1/5,warp:\sine)
);
