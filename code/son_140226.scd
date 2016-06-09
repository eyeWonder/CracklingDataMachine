/////////////////////////////////////
///Crackling Data Machnies
//////////////////////////
//son//////////////////


//wifi In
//dust, blip
//drone mit wifi mod
//tdef timeMod


//-->Execute here for AudioProcesses
(

Ndef.clear;


//////////////////////////////////////
///WiFiInput


(
Ndef(\wifi, { | amp = 1.0|
	var in = SoundIn.ar(0) * 10;
	var son = Limiter.ar(Compander.ar(in, in, 0.7, 		// threshold
		1, 		// below threshold slope
		0.3		// above threshold slope
		), 0.9, 0.01);
	son = BPeakEQ.ar(son, 9000, 2, -6);
	son * amp
});
);




//Ndef(\wifi).play;
//Ndef(\wifi).stop;


(
Ndef(\wifiLoop, { |amp = 1.0, start = 0, bufnum = 1, trig|
	var in = Ndef.ar(\wifi, 1, 0) ;
	var son = PanAz.ar(4, in,
	Duty.kr(1, 0, Drand([-1, -0.5, 0.0, 0.5], inf)),
	amp,
	0.5, 0);
	son
});
);

/*

(
Ndef(\wifiLoop, { |amp = 1.0, start = 0, bufnum = 1, trig|
	var in = Ndef.ar(\wifi, 1, 0) ;
	var son = PanAz.ar(4, in,
	SinOsc.ar(0.05),
	amp,
	0.5, 0);
	son
});
);

*/



(
Ndef(\wifiChan, { |amp = 0.4, start = 0, bufnum = 0, trig|
	var in = Ndef.ar(\wifi, 1, 0) ;
	var son = in ! 4;
	son * amp
});
);



//Ndef(\wifiLoop).play;
//Ndef(\wifiLoop).stop;
//Ndef(\wifiChan).playN(outs: [0, 1, 2, 3]);
//Ndef(\wifiChan).stop;



//////////////////
//droneOndesMod

Ndef(\droneOndes, { |amp = 1|
	var in = Ndef.ar(\wifi, 1, 0) ;
	var analyze = Amplitude.ar(in);
	var son = SinOsc.ar([50, 100, 200, 300, 400] * SinOsc.ar(0.01).range(-0.1, 0.1)).sum * in;
	son = PanAz.ar(4, son,
		SinOsc.kr(0.05),
	amp,
	0.2, 0);

});


//Ndef(\droneOndes).play;
//Ndef(\droneOndes).stop;


//////////////////
//impulse Riddim


(
Ndef(\impulseRid, { |amp = 1|
	var son = PanAz.ar(
		4,                 // numChans
		Impulse.ar(Duty.kr(0.1, 0, Drand([0.5, 1, 1.5, 2.0], inf))),     // in
		Duty.kr(0.1, 0, Drand([-1, -0.5, 0.0, 0.5], inf)), // pos
		1.2,            // level
		1.5, 0           // width
		);
	son
});
);


(
Pdef(\impulseRid,
	Pbind(
	\type, \mechan,
	\pin, \rls,
	\val, Pseq([50, 0], inf),
	\dur, 0.8
	);
);
);


//Pdef(\impulseRid).play;
//Pdef(\impulseRid).stop;
//Ndef(\impulseRid).play;
//Ndef(\impulseRid).stop;


(
Ndef(\blipRid, { |amp = 1|
	var son = PanAz.ar(
		4,                 // numChans
		Blip.ar(0.5, 100 * SinOsc.kr(0.01).range(0.8, 10)),     // in
		LFSaw.kr(0.5), // pos
		amp,            // level
		1.2           // width
		);
	son
});
);


(
Pdef(\blipRid,
	Pbind(
	\type, \mechan,
	\pin, \rls,
	\val, Pseq([50, 0], inf),
	\dur, 0.416666667 * 8
	);
);
);



//Ndef(\blipRid).play;
//Ndef(\blipRid).stop;
//Pdef(\blipRid).play;
//Pdef(\blipRid).stop;


(
Tdef(\droneSin, {
	loop{
		Ndef(\sin, {
		var son = SinOsc.ar(ExpRand(1500, 50), 0, Rand(0.5, 1));
			son = son * (Ndef.ar(\wifi, 1, 0) * 2);
		Out.ar(0, PanAz.ar(4, son,
			Duty.kr(LFPulse.kr(WhiteNoise.kr().range(0.1, 2.0)).range(3.0, 0.001), 0,
			Drand([-0.5, 0, 0.5, 1], inf)), 0.5, 2)
		* EnvGen.kr(Env.perc(20, 20, 0.5), 0.5, 0.1, doneAction: 2), 0.1);
		}).play;
	8.wait;
	}.tanh;
});
);





//Tdef(\droneSin).play;
//Tdef(\droneSin).stop;


(
Tdef(\dronePulse, {
	loop{
		Ndef(\sin, {
		var son = LFPulse.ar(ExpRand(50, 300), 0, Rand(0.5, 1));
			//son = RLPF.ar(son, 1000, 0.5);
		Out.ar(0, PanAz.ar(4, son,
			Duty.kr(LFPulse.kr(WhiteNoise.kr().range(0.1, 2.0)).range(3.0, 0.001), 0,
			Drand([-0.5, 0, 0.5, 1], inf)), 0.5, 2)
		* EnvGen.kr(Env.perc(20, 20, 0.5), 0.5, 0.1, doneAction: 2), 0.1);
		}).play;
	8.wait;
	}.tanh;
});
);

//Tdef(\dronePulse).play;
//Tdef(\dronePulse).stop;


////////////////////////
///////////DelayClicks


(
Ndef(\delay, {
       var input, delayTime, outDelay;
       // input from sound card
       input = Ndef.ar(\wifi, 1, 0) * 1.8;
       // delay time jumps every 2 seconds
       delayTime = Demand.kr(Impulse.kr(0.2), 0, Dseq([0.4, 0.6, 0.9, 0.3, 0.7], inf));
       // CombC - delay with feedback
      CombC.ar(input ! 2, 16, delayTime, 6) + input;
	input = PanAz.ar(4, input, LFSaw.kr(SinOsc.kr(0.5).range(0.01, 0.05)));
	input
});
);


//Ndef(\delay).play;
//Ndef(\delay).stop;



)





//-----------------




Spring.ar
DynKlang.ar
DynKlank.ar


//bitcrush!!!!!!

Decimator.ar();
{Decimator.ar(SinOsc.ar([400, 404], 0, 0.2), MouseX.kr(0, 44100), MouseY.kr(0, 31))}.play
{Decimator.ar(SoundIn.ar(2), MouseX.kr(0, 44100), MouseY.kr(0, 31))}.play


//MoogFilter
x = { MoogFF.ar(SoundIn.ar(0), MouseY.kr(100, 10000, 1), MouseX.kr(0, 4)) }.play;
x.free



//StringResonant
{ Streson.ar(LFSaw.ar([220, 180], 0, mul:EnvGen.kr(Env.asr(0.5, 1, 0.02), 1.0) * 0.2), LinExp.kr(LFCub.kr(0.1, 0.5*pi), -1, 1, 280, 377).reciprocal, 0.9, 0.3) }.play

(
Ndef(\dynklank, {|freqScale = 1, decayFac = 0.2, width = 0, amp = 0.7|
	var in = \in.ar([0, 1]);
	DynKlank.ar(
		`[
			[120, 500, 1200, 1800, 4000] * freqScale * SinOsc.ar(0.01).range(0.9, 1.1) *
			Amplitude.kr(Ndef.ar(\parcel), 2, 10).explin(0.001, 0.2, 0.5, 4),
			[0.1 , 1, 0.5, 0.8, 0.1] / 10,
			[1, 0.5, 0.8, 0.23847] * decayFac
		],
	in
	).tanh + (in / 2)
});

);




(
Ndef(\dynklank2, {|freqScale = 1, decayFac = 0.5, width = 0.1, amp = 0.02|
	var in = \in.ar([0, 1]);
	DynKlank.ar(
		`[
			[120, 1071, 1153, 1723].collect{|val, i|
				(val * Rand(0.5, 2))
			} * freqScale * Dust.ar(1).range(0.2, 1),
			[0.1 , 0.4, 0.5, 0.4] * amp,
			[1, 0.5, 0.8, 0.23847] * decayFac
		],
	in
	).tanh + (in / 4)
});

);



(
Ndef(\reso, {|freq = 500, rq = 1, amp = 0.8|
	var in = \in.ar([0, 1]);
	(Resonz.ar(in, freq, rq, amp)) * (0.9/rq) + (in / 2)
});
);



(
Ndef(\deepreso, {|freq = 100, rq = 0.5, amp = 1|
	var in = \in.ar([0, 1]);
	(Resonz.ar(in, freq * SinOsc.ar(0.01).range(0.9, 1.1), rq, amp)) * (1/rq)	//stereo?
});
);



(
Tdef(\filtmelody, {
	loop{
		Ndef(\reso).set(\freq , rrand(2000, 3000), \rq, 1/10, \amp, 0.5);
		(type: \augment, n: (0..7), cue: q.timecrash2 + 400).play;
		rrand(2.0, 4.0).wait;
		Ndef(\reso).set(\freq , rrand(1000, 4000), \rq, 1/10, \amp, 0.5);
		(type: \augment, n: rrand(0, 7), cue: rrand(0, 9999)).play;
		0.2.wait;
		Ndef(\reso).set(\freq , rrand(1000, 4000), \rq, 1/10, \amp, 0.5);
		(type: \augment, n: rrand(0, 7), cue: rrand(0, 9999)).play;
		0.1.wait;
		Ndef(\reso).set(\freq , rrand(1000, 4000), \rq, 1/10, \amp, 0.5);
		(type: \augment, n: rrand(0, 7), cue: rrand(0, 9999)).play;
		0.1.wait;
	}
});
);



(
Ndef(\bitPulse, { |amp = 1|
	var son = PanAz.ar(
		4,                 // numChans
		Decimator.ar(LFPulse.ar(100 * LFSaw.kr(10).range(1.0, 5.0)), 8000, 6)
		* LFPulse.kr(2, width: LFPulse.kr(0.1).range(0.1, 0.4)), //in
		LFSaw.kr(0.3), // pos
		0.5,            // level
		2           // width
		);
	son
});
);


//Ndef(\bitPulse).play;
//Ndef(\bitPulse).stop;




////////////////////////////////
////////Outputs


(
Ndef(\4out, { |amp = 1|
	var in0, in1, in2, in3, in = \in.ar([0, 1, 2, 3]);
	in = BPeakEQ.ar(in);
	in = Limiter.ar(in, 0.999);
	in * amp
});
)


(
Ndef(\transD, { |amp = 1|
	var in = \in.ar([0, 1]);
	in * amp
});
)



////////////////////////////////////
/////Audio Routing

Ndef.clear;


Ndef(\x, { \in1.ar(0) + \in2.ar(0) })
Ndef(\x) <<>.in1 Ndef(\y)
Ndef(\x) <<>.in2 Ndef(\z)



Ndef(\out, { |amp = 1|
	var in = \in.ar([0, 1]);
	in * amp
});


Ndef(\4out) <<> Ndef(\piezo1);
Ndef(\4out) <<> Ndef(\sin);
Ndef(\4out).play;
Ndef(\4out).stop;



/////////////////////////////////
/////////////////panningTests


Ndef(\panTest1, { |amp =1|
	var son = Impulse.ar(LFNoise1.kr(3).range(0.001, 30)) * 7.5 ! 2;
	son
});

Ndef(\panTest1).playN(outs: [6, 7], amps: [0.5, 2.5])
Ndef(\panTest).stop


Ndef(\panTest, { |amp =1|
	var son = Pulse.ar(100) * 0.1;
	son = PanAz.ar(4, son, SinOsc.kr(0.1).range(-1.0, 1.0), 1, width: 1);
	son
});

Ndef(\panTest).play(out: 0, numChannels: 4)
Ndef(\panTest).clear



///DroneSin Versions

(
Tdef(\droneSin, {
	loop{
		Ndef(\sin, {
		var son = SinOsc.ar(ExpRand(2000, 50), 0, Rand(0.5, 1));
		Out.ar(0, PanAz.ar(4, son, rrand(-1.0, 1.0)) * EnvGen.kr(Env.perc(20, 20, 0.5), 0.5, 0.1, 			doneAction: 2), 0.1);
		}).play;
	2.wait;
	}.tanh;
});
);



(
Tdef(\droneSin, {
	loop{
		Ndef(\sin, {
		var son = SinOsc.ar(ExpRand(2000, 50), 0, Rand(0.5, 1));
		son = Decimator.ar(son, rrand(5000, 44100), 7);
		Out.ar(0, PanAz.ar(4, son, rrand(-1.0, 1.0), 0.5, 2)
		* EnvGen.kr(Env.perc(20, 20, 0.5), 0.5, 0.1, doneAction: 2), 0.1);
		}).play;
	2.wait;
	}.tanh;
});
);


(
Tdef(\droneSin, {
	loop{
		Ndef(\sin, {
		var son = SinOsc.ar(ExpRand(2000, 50), 0, Rand(0.5, 1));
		son = Decimator.ar(son, rrand(5000, 44100), 7);
		Out.ar(0, PanAz.ar(4, son, Duty.kr(1, 0,
			Drand([-0.5, 0, 0.5, 1], inf)), 0.5, 2)
		* EnvGen.kr(Env.perc(20, 20, 0.5), 0.5, 0.1, doneAction: 2), 0.1);
		}).play;
	2.wait;
	}.tanh;
});
);






///////////////////////////////////
// four channel circular panning



(
Ndef(\impulse, { |amp = 1|
	var son = PanAz.ar(
		4,                 // numChans
		Impulse.ar(2.2),     // in
		LFSaw.kr(MouseX.kr(0.2, 8, 'exponential')), // pos
		0.5,            // level
		3           // width
		);
	son
});
);





