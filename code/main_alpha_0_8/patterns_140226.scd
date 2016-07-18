///////////////////
//Crackling Data Machnies
////////////////
//Patterns

//-->Execute Patterns here
(

t = TempoClock.default;
t.tempo = 60 / 60;					// 60 BPM

//q.motorOffset = 0;
//q.p5Offset = -20;


q.lengthCount = 0;
//311,



(
Tdef(\printTest, {
311.do{
	q.arduino.send($w, $d, 1, 2.5);
	0.2.wait;
	q.arduino.send($w, $o);
	q.lengthCount = q.lengthCount + 1;
	0.2.wait;
	}
	}).play;
);


Tdef(\printTest).stop;

q.arduino.send($w, $s, 10, 10);



(
Tdef(\printTest, {
	loop{
		q.printPxl;
		0.1.wait;
	}
}).play;
);


(
Tdef(\printTest, {
	loop{
		Tdef(\printPxl).play;
		0.1.wait;
	}
}).play;
);



(
Tdef(\printTest, {
	loop{
		q.arduino.send($w, $p, 10, 10);
		0.1.wait;
	}
}).play;
);



Tdef(\printTest).stop;




(
Tdef(\stopTout, {
	q.arduino.send($w, $s, 3, 1);
	0.1.wait;
	q.arduino.send($w, $d, 2, 0);
	0.1.wait;
}).play;
);



(
Tdef(\glitcher, {
	loop{
	q.sendFace(10000);
	2.wait;
	};
});
);


///motorMelody
(
Pdef(\motorMelody,
	Pbind(
	\type, \mechan,
	\pin, \stp,
	\val, Pseq([20, 0, 25, 0, 30, 0, 35, 0, 40, 0, 50, 0, 60, 0, 70, 0, 80, 0], inf),
	\dur, Pstutter(2, Pseq([1/4, 1/8, 1/2, 1/3], inf))
	)
);
);


(
Pdef(\servoRid,
	Pbind(
	\type, \mechan,
	\pin, \srv,
	\val, Pseq([50, 50, 50, 50, 1, 1, 1, 1], inf),
	\dur, 1/2
	)
);
);



//Pdef(\motorMelody).play;
//Pdef(\servoRid).play;

//Pdef(\motorMelody).stop;
//Pdef(\servoRid).stop;


////////////////////


(
Pdef(\hinundher,
	Pbind(
	\type, \mechan,
	\pin, Pstutter(2, Pseq([\stp, \srv, \rls], inf)),
	\val, Pseq([50, 0, 50, 0, 50, 0, 50, 0, 50, 0], inf),
	\dur, Pstutter(2, Pseq([1/4, 1/8, 1/2, 1/3], inf))
	)
);
);


//Pdef(\hinundher).play;
//Pdef(\hinundher).stop;



//bordel

(
Pdef(\hitrand,
	Pbind(
	\type, \mechan,
	\pin, Pshuf([\srv, \stp, \rls], inf),
	\dur, Pseq([1/8, 1/8, 1/16, 1/16, 1/16, 1/16, 1/16, 1/4], inf),
	\val, Prand([50, 0], inf),
	\legato, 0
	);
);
);


//Pdef(\hitrand).play;
//Pdef(\hitrand).stop;

);



/*
(
Pdef(\hinundher,
	Pbind(
	\type, \mechan,
	\pin, Pstutter(2, Pseq([\stp, \srv, \rls], inf)),
	\val, Pseq([50, 0, 50, 0, 50, 0], inf),
	\dur, 1/4
	)
);
);

*/



Pdefn(\timing1, Pseq([0], inf));
Pdefn(\timing1, Pseq([2, 3, 2, 1, 2, 3, 1]/30, inf));
Pdefn(\timing3, Pseq([2, 3, 2, 1, 2, 3, 1]/20, inf));
Pdefn(\timing4, Pseq([2, 3, 2, 1]/10, inf));
Pdefn(\timing5, Pseq([2, 3, 2, 1], inf));
Pdefn(\timing1, Pseq([8, 6, 5, 4], inf));

Pdefn(\timing, Pdefn(\timing1));
Pdefn(\timing, Pdefn(\timing2));



(
Pdef(\polyR,
	Ppar([
	Pbind(
	\type, \mechan,
	\pin, Pstutter(2, Pseq([\stp, \srv, \led], inf)),
	\val, Pseq([50, 0, 50, 0, 50, 0], inf),
	\dur, 1/4
	),
	Pbind(
	\type, \mechan,
	\pin, \rls,
	\val, Pseq([100, 0], inf),
	\dur, 1/3
	)
]);
);
);


Pdef(\polyR).play;
Pdef(\polyR).stop;




(
Pdef(\first,
	Pbind(
	\type, \mechan,
	\pin, \rls,
	\dur, Pseq([0.1, 1, 0.3, 1, 0.5]/4, inf),
	\val, Pseq([1,0,1,0], inf)
	);
);
)


(
Pdef(\first,
	Pbind(
	\type, \mechan,
	\pin, \srv,
	\dur, Pseq([0.1, 1, 0.3, 1, 0.5]/4, inf),
	\val, Pseq([1,0,1,0], inf)
	);
);
)



(
Pdef(\first,
	Pbind(
	\type, \mechan,
	\pin, Pseq([\srv, \stp, \rls], inf),
	\dur, Pseq([0.1, 1, 0.3, 1, 0.5]/4, inf),
	\val, Pseq([1,0,1,0]*100, inf)
	);
);
)


Pdef(\first).play;
Pdef(\first).stop;



/*
(
Pdef(\glitchHer,
	Pbind(
	\type, \mechan,
	\val1, Pseq([10000, 0, 0, 8000, 0, 0], inf),
	\dur, 1/2
	)
);
);


Pdef(\glitchHer).play;
Pdef(\glitchHer).stop;
*/


q.pdefgui = PdefAllGui.new(30);
q.pdefgui.parent.bounds = Rect(240, 200, 268, 397);

q.tdefgui = TdefAllGui.new(30);
q.tdefgui.parent.bounds = Rect(540, 200, 268, 397);



