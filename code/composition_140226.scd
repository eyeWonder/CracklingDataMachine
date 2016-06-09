////////////////////////
//Crackling Data Machnies
/////////////////
//compositionLoop

//to do:
//Ndef.fadeTime
//Ndef(inputJitter?)!!!
//startPos
//loop machine glitchBlack


Tdef(\boucle).play;
Tdef(\boucle).stop;


(
Tdef(\boucle, {
	var machine;
	loop{
		/*
		Ndef(\mechaLoop).set(\start, 0, \amp, 0.3, \trig, 0);
		Ndef(\mechaLoopNoise).set(\start, 0, \amp, 1.7, \trig, 0);
		q.arduino.send($w, $d, 2, 0);
		*/
		//Produce Data;
		//RANDOM DICHTE!!!!
		q.oscTX(2);
		1.0.wait;
		//send me some pxlData
		q.oscTX(1);
		0.2;

		q.oscTX(5);
		0.2;

		//1_Print
		"1_mechaLoop".postln;
		Tdef(\printPxl).play;

		rrand(60, 177).wait;
		Tdef(\printPxl).stop;

		//Crackling
		"Crackling".postln;
		machine = [[Ndef(\wifiLoop)],
			[Ndef(\droneOndes)],
			[Ndef(\impulseRid), Pdef(\impulseRid)],
			[Ndef(\blipRid), Pdef(\blipRid)],
			[Tdef(\droneSin)],
			[Ndef(\delay)],
			[Tdef(\dronePulse)]].choose;
		machine[0].play;
		try{ machine[1].play; };
		try{ machine[2].play; };

		rrand(66, 121).wait;

		Ndef(\wifiLoop).stop;
		Ndef(\droneOndes).stop(30);
		Ndef(\impulseRid).stop(20);
		Pdef(\impulseRid).stop;
		Ndef(\blipRid).stop;
		Pdef(\blipRid).stop;
		Ndef(\delay).stop(35);
		Tdef(\droneSin).stop;
		Tdef(\dronePulse).stop;
		15.wait;



		//2_PrintRand
		"2_printRand".postln;
		Tdef(\printRand).play;

		rrand(61, 127).wait;
		Tdef(\printRand).stop;


		//Crackling
		"Crackling".postln;
		machine = [[Ndef(\wifiLoop)],
			[Ndef(\droneOndes)],
			[Ndef(\impulseRid), Pdef(\impulseRid)],
			[Ndef(\blipRid), Pdef(\blipRid)],
			[Tdef(\droneSin)],
			[Ndef(\delay)],
			[Tdef(\dronePulse)]].choose;
		machine[0].play;
		try{ machine[1].play; };
		try{ machine[2].play; };

		rrand(64, 122).wait;

		Ndef(\wifiLoop).stop;
		Ndef(\droneOndes).stop(30);
		Ndef(\impulseRid).stop(20);
		Pdef(\impulseRid).stop;
		Ndef(\blipRid).stop;
		Pdef(\blipRid).stop;
		Ndef(\delay).stop(35);
		Tdef(\droneSin).stop;
		Tdef(\dronePulse).stop;
		15.wait;



	};
});
);

Tdef(\boucle).play;

/*

//1_mechaLoop
Ndef(\mechaLoop).set(\start, 0, \amp, 0.5, \trig, 0);
Ndef(\mechaLoopNoise).set(\start, 0, \amp, 3.0, \trig, 0);

Ndef(\mechaLoop).playN(outs: [0, 1, 2, 3]);
Ndef(\mechaLoop).set(\start, 0, \amp, 0.3, \trig, 1);
Ndef(\mechaLoopNoise).play;
Ndef(\mechaLoopNoise).set(\start, 0, \amp, 2.0, \trig, 1);
Ndef(\mechaLoop).stop(10);
Ndef(\mechaLoopNoise).stop(20);



//2_mechaLoop
Ndef(\mechaLoop).playN(outs: [0, 1, 2, 3]);
Ndef(\mechaLoop).set(\start, 100, \amp, 0.1);
Ndef(\mechaLoopNoise).play;
Ndef(\mechaLoopNoise).set(\start, 100, \amp, 3.0);
Ndef(\mechaLoop).stop;
Ndef(\mechaLoopNoise).stop;

//3
Ndef(\mechaLoop).playN(outs: [4]);
Ndef(\mechaLoop).set(\start, 100, \amp, 1.5);
Pdef(\hinundher).play;
Ndef(\mechaLoop).stop;
Pdef(\hinundher).stop;
Tdef(\stopSTP).play;


//impulseRiddim

Pdef(\impulseRid).play;
Ndef(\impulseRid).play;

Ndef(\piezo1).playN(outs: [0, 1, 2, 3]);
Ndef(\piezo2).playN(outs: [0, 1, 2, 3]);
Ndef(\piezo2).set(\amp, 1);
Ndef(\piezo1).stop;
Ndef(\piezo2).stop;
//früherFertig:
Pdef(\impulseRid).stop;
//später
Ndef(\impulseRid).stop;


//droneSynth

Tdef(\droneSin).play;
Tdef(\droneSin).stop;


//blipSynth

Ndef(\blipRid).play;
Pdef(\blipRid).play;

Ndef(\blipRid).stop;
Pdef(\blipRid).stop;



//machine
//servoMelody

Pdef(\motorMelody).play;
Pdef(\servoRid).play;
Ndef(\inputJitter).play;

//petitRiddim

[Ndef(\delay).play,
	Pdef(\hinundher).play]


//bordel

[Pdef(\hitrand).play,
	Ndef(\tubes).play]


Pdef(\motorMelody).stop;
Pdef(\servoRid).stop;
Ndef(\inputJitter).stop(20);
Ndef(\delay).stop(20);
Pdef(\hinundher).stop;
Pdef(\hitrand).stop;
Ndef(\tubes).stop(20);







//

[Tdef(\stopSTP), Pdef(\hinundher), Ndef(\delay)].choose.play;


Tdef(\stopSTP).play;

*/

