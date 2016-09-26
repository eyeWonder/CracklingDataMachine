///////////////////////////
////////////////////////////////
///Crackling Data Machines
//////////////////////////////
//2014-2016, Ali Tnani & Lukas Truniger
//////////////////////////

/*
///////////////////
TODO!!!!!!!!!!!!
--> character randomizer
*/


q = ();

(
q.arduino = ArduinoSMS(
	"/dev/ttyACM0",    //edit to match your port. SerialPort.listDevices
	baudrate: 38400    //check that baudrate is the same as in arduino sketch
);
);

//q.arduino.close;
q.arduino.send($w, $o); //solenoid
q.arduino.send($w, $s,1, 1); //stepper x (speed, steps)
q.arduino.send($w, $t, 1, 1); //stepper y (speed, steps)
q.arduino.send($w, $s, 1, 1); //stepper x (speed, steps)
q.arduino.send($w, $t, 6, 1); //stepper y (speed, steps)


/////////////////////////////////////////
//get letters from p5 and place it in meaningful manners

q.wordBuffer = q.charBuffer.asAscii.asString.split($ );
//removeItems (items: ",().?/!?;:_")

(
var red, green, blue, alpha, font, xpos = 0, ypos = 0, word;
q.image = Image.new(q.pxlRes[0], q.pxlRes[1]);
q.image.draw({
	var xrand = rrand(0.2, 1.9);
	var yrand = rrand(0.8, 2.1);
	q.wordBuffer.size.do{ |i|
		xpos = xpos+(i*xrand);
		ypos = ypos+yrand;
		Pen.stringAtPoint(q.wordBuffer[i], Point(xpos, ypos), font, Color.black);
		if(xpos >= q.pxlRes[0], { xpos = 0 });
		if(ypos >= q.pxlRes[1], { ypos = 0 });
	};
	Pen.fill;
}).plot(freeOnClose:true, background:Color.white);
//q.imagePixel = q.image.pixels;
//i.free;
//p.postln;
//p.size.postln;

p[3000].postln;
red = p[3000] >> 24 & 0xFF;
red.postln;
green = p[3000] >> 16 & 0xFF;
green.postln;
blue = p[3000] >> 8 & 0xFF;
blue.postln;
alpha = p[3000] & 0xFF;
alpha.postln;
)


//appClock!!
var red, green, blue, alpha, font, xpos = 0, ypos = 0;

q.newImage = {
	q.image = Image.new(q.pxlRes[0], q.pxlRes[1]);
	q.image.draw({
		var xpos = 0, ypos = 0;
		var xrand = rrand(0.2, 1.9);
		var yrand = rrand(0.8, 2.1);
		q.wordBuffer.size.do{ |i|
			xpos = xpos+(i*xrand);
			ypos = ypos+yrand;
			Pen.stringAtPoint(q.wordBuffer[i], Point(xpos, ypos), q.font, Color.black);
			if(xpos >= q.pxlRes[0], { xpos = 0 });
			if(ypos >= q.pxlRes[1], { ypos = 0 });
		};
		Pen.fill;
	});
	q.imagePixel = q.image.pixels;
	q.image.free;
	//q.imagePixel.postln;
	q.imagePixel[5000].postln;
};




Tdef(\imageTester, {
	loop{
	{q.newImage}.defer;
		5.wait;
	}
}).play;


////////////////////////////////////
//printTester
(
Tdef(\printTester, {
	var direct = 0, line = Int32Array.new(350), point, red;
	350.do{ |y|

		line = Int32Array.new(350);
		350.do{ |i|
			line.add(p.pop);
		};

		350.do{ |x|

			q.arduino.send($w, $s, 1, direct);
			q.printSpeed.wait;
			if(direct == 0, { point = line.pop; },
				{ point = line[x]; });
			red = point >> 24 & 0xFF;
			if(red >= 96, {
				q.arduino.send($w, $o);
				q.printSpeed.wait;
			});
		};

		q.arduino.send($w, $t, q.stepsPerLine, 1);
		(q.printSpeed*2).wait;
		direct = 1-direct;
	};
}).play;
)

Tdef(\printTester).pause;
Tdef(\printTester).resume;



//(

//___________________________________________________________________________________________________
/////////////////////////////////////////////////////////////////////////////////////////////////////
///////SETUP


/////////////////////////////
//Boot audio server

(
Tdef(\setup, {
	s.quit;
	0.5.wait;
	s = Server.local;
	0.5.wait;
	s.options.memSize = 65536;
	0.5.wait;
	s.options.blockSize = 512;
	0.5.wait;
	s.boot;
	3.wait;
	Tdef(\boucle).play;
}).play;
);


q = ();   //set variable as dictionary

//////////////////////////////////////////
//Serial Communication for Arduino

(
	q.arduino = ArduinoSMS(
		"/dev/ttyACM0",    //edit to match your port. SerialPort.listDevices
		baudrate: 115200    //check that baudrate is the same as in arduino sketch
	);
);

/////////////////////////////////
//Global Variables and Buffers

q.pxlRes =  [350, 350];
q.charBuffer = [];

//variables printin
q.printSpeed = 0.04; //duration of each step, min 0.04
q.stepsPerLine = 7;
q.font = Font("Arial", 14);
q.direct = 0;
q.imagePixel;
q.image;

//variables sound
q.freqsFilt = [60, 68, 60, 62, 60, 62, 60];
q.space = 32;
q.freq = 0;


//PixelArrray for one line
q.nextLine = { |q|
	q.currentLine = [];
	q.pxlRes[0].do{
		var pxl = q.pxlBuffer.pop;
		q.currentLine = q.currentLine ++ pxl;
	};
	\nextline;
};


//////////////////////////////
//OSC-Send setup for Processing
(
m = NetAddr("127.0.0.1", 12000);  //define remote adress and port
q.oscTX = { |q, val1 |
	m.sendMsg("/sendMe", val1);
};
);

//q.oscTX(1); !!wait!!

////////////////////////////////
//OSC-Receive setup from Processing

(
n = NetAddr("127.0.0.1", nil);
q.oscRX = OSCdef(\oscMSG, {|msg, time, addr, recvPort|
	msg.postln;
	msg.removeAt(0);
	msg.size.postln;
	q.charBuffer = msg;
}, '/chat', n);
);






/////////////////
//Event Setup for Aruino

///mapping
q.mapping = (
	rls: [$d, 2],
	srv: [$s, 3],
	led: [$a, 5],
	stp: [$t, 8]
);

///EventType
q.motorOffset = 0;
q.p5Offset = -10;

(
Event.addEventType(\mechan, {
	var adst = ~adst ? $d;
	var pin = ~pin ? 2;
	var val = ~val ? 0;
	var val1 = ~val1, val2 = ~val2, val3 = ~val3;
	if(pin.isNumber.not) {			// map symbols across dictionary
		pin = q.mapping.at(pin);
		adst = pin[0];
		pin = pin[1];
	};
	//thisThread.clock.sched( ~timingOffset ? 0.0 + q.motorOffset, {
	q.arduino.send($w, adst, pin, val);
	//});
	//thisThread.clock.sched( ~timingOffset ? 0.0 + q.p5Offset, {
	q.oscTX(val1, val2, val3);
	//"val1, val2, val3".postln;
	//});

});
);



/////////////////
//collect Pixel data to use it as sound frequency

(
q.nextFreqs = { |q|
	20.do{
		q.freq = q.pxlBuffer.pop;
		if ( q.freq > q.space,
			{q.freqsFilt = q.freqsFilt ++ q.freq;});
	};
	q.freqsFilt;
};
);



//____________________________________________________________________________________________________________________________________
////////////////////////////////////////////////////////////////////////////////////////////////
///////SOUND SETUP

Ndef.clear;


///WiFiAktivity (aka microphone Input)

(
Ndef(\wifi, { | amp = 3.5|
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
Ndef(\wifiLoop, { |amp = 2.0, start = 0, bufnum = 1, trig|
	var in = Ndef.ar(\wifi, 1, 0) ;
	var son = PanAz.ar(2, in,
		Duty.kr(1, 0, Drand([-1, -0.5, 0.0, 0.5], inf)),
		amp,
		0.5, 0);
	son
});
);

(
Ndef(\wifiChan, { |amp = 1.2, start = 0, bufnum = 0, trig|
	var in = Ndef.ar(\wifi, 1, 0) ;
	var son = in ! 2;
	son * amp
});
);

//Ndef(\wifiLoop).play;
//Ndef(\wifiLoop).stop;
//Ndef(\wifiChan).playN(outs: [0, 1, 2, 3]);
//Ndef(\wifiChan).stop;


//droneOndesModulation

Ndef(\droneOndes, { |amp = 0.2|
	var freqs = q.nextFreqs * 1;
	var in = Ndef.ar(\wifi, 1, 0) ;
	var analyze = Amplitude.ar(in);
	var son = SinOsc.ar(freqs * SinOsc.ar(0.01).range(-0.1, 0.1)).sum * in;
	son = PanAz.ar(2, son,
		SinOsc.kr(0.05),
		amp,
		0.5, 0);

});

//Ndef(\droneOndes).play;
//Ndef(\droneOndes).stop;


//impulse Rythm

(
Ndef(\impulseRid, { |amp = 0.9|
	var son = PanAz.ar(
		2,                 // numChans
		Impulse.ar(Duty.kr(0.1, 0,
			Drand([0.01, 0.01, 0.01, 0.02, 0.02, 0.02, 0.5, 1, 1.5, 2.0, 3.0, 4.0, 2.5], inf))),     // in
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
		\dur, Pseq([0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.7, 0.7, 0.6, 0.6, 0.5, 0.5, 0.4, 0.4, 0.3, 0.3, 0.2, 0.2, 0.1, 0.1, 0.05, 0.05, 0.05, 0.05, 0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5, 0.6, 0.6, 0.7, 0.7], inf)
	);
);
);

//Ndef(\impulseRid).play;
//Ndef(\impulseRid).stop;

(
Ndef(\blipRid, { |amp = 0.7|
	var son = PanAz.ar(
		2,                 // numChans
		Blip.ar(0.5, 100 * SinOsc.kr(0.01).range(0.8, 10)),     // in
		LFSaw.kr(0.9), // pos
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

(
Tdef(\droneSin, {
	loop{
		Ndef(\sin, {
			var son = SinOsc.ar(q.nextFreqs.choose * 1.2, 0, Rand(0.6, 0.9));
			son = son * (Ndef.ar(\wifi, 1, 0) * 2);
			Out.ar(0, PanAz.ar(2, son,
				Duty.kr(LFPulse.kr(WhiteNoise.kr().range(0.1, 2.0)).range(3.0, 0.001), 0,
					Drand([-0.5, 0, 0.5, 1], inf)), 0.5, 2)
			* EnvGen.kr(Env.perc(20, 20, 0.5), 0.6, 0.5, doneAction: 2), 0.1);
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
			var son = LFPulse.ar([80, 81, 121, 160, 239].choose, 0, Rand(0.5, 1));
			//son = RLPF.ar(son, 1000, 0.5);
			Out.ar(0, PanAz.ar(2, son,
				Duty.kr(LFPulse.kr(WhiteNoise.kr().range(0.1, 2.0)).range(3.0, 0.001), 0,
					Drand([-0.5, 0, 0.5, 1], inf)), 0.5, 2)
			* EnvGen.kr(Env.perc(20, 20, 0.5), 0.8, 0.3, doneAction: 2), 0.1);
		}).play;
		8.wait;
	}.tanh;
});
);

//Tdef(\dronePulse).play;
//Tdef(\dronePulse).stop;

///////////DelayClicks

(
Ndef(\delay, {
	var input, delayTime, outDelay;
	// input from sound card
	input = Ndef.ar(\wifi, 1, 0) * 3.8;
	// delay time jumps every 2 seconds
	delayTime = Demand.kr(Impulse.kr(0.2), 0, Dseq([0.4, 0.6, 0.9, 0.3, 0.7], inf));
	// CombC - delay with feedback
	CombC.ar(input ! 2, 16, delayTime, 6) + input;
	input = PanAz.ar(2, input, LFSaw.kr(SinOsc.kr(0.5).range(0.01, 0.05)));
	input = input * 2;
	input
});
);

//Ndef(\delay).play;
//Ndef(\delay).stop;



//____________________________________________________________________________________________________________________________________
//////////////////
///////PATTERNS SETUP


Tdef(\printPxl, {
	loop{
		q.nextLine;
		0.4.wait;
		q.currentLine.postln;
		q.counter = 0;
		0.4.wait;
		q.arduino.send($w, $c, 1, 550); //DC get Back
		1.5.wait;
		//q.arduino.send($w, $d, 1, 400); //DC to starting Point, Hardware starting Point?
		//1.wait;
		q.arduino.send($w, $s, 10, 7); //Stepper next Line
		1.5.wait;
		//q.arduino.send($w, $o);
		//0.1.wait;
		q.pxlRes[0].do( //For each Line
			{
				var pxl = q.currentLine[q.counter];
				q.counter = q.counter + 1;
				if(pxl == 1, {
					q.arduino.send($w, $o);  //Pen up or down --> black or white
				});
				0.05.wait;
				q.arduino.send($w, $d, 1, 1.0);   				//DC next Pixel
				pxl.postln;
				0.05.wait;

		});
		0.1.wait;
		//q.arduino.send($w, $o);
		//0.1.wait;
	};

});


//Tdef(\printPxl).play;
//Tdef(\printPxl).stop;


/////
//RandomPrint

Tdef(\printRand, {
	loop{
		q.nextLine;
		0.4.wait;
		q.currentLine.postln;
		q.counter = 0;
		0.4.wait;
		q.arduino.send($w, $c, 1, 550); //DC get Back
		rrand(1.5, 2.5).wait;
		//q.arduino.send($w, $d, 1, 400); //DC to starting Point, Hardware starting Point?
		//1.wait;
		q.arduino.send($w, $s, 10, 7); //Stepper next Line
		rrand(1.5, 2.5).wait;
		//q.arduino.send($w, $o);
		//0.1.wait;
		q.pxlRes[0].do( //For each Line
			{
				var pxl = q.currentLine[q.counter];
				q.counter = q.counter + 1;
				if(pxl == 1, {
					q.arduino.send($w, $o);  //Pen up or down --> black or white
				});
				rrand(0.01, 0.2).wait;
				q.arduino.send($w, $d, 1, 1.0);   				//DC next Pixel
				pxl.postln;
				rrand(0.01, 0.2).wait;

		});
		0.1.wait;
		//q.arduino.send($w, $o);
		//0.1.wait;
	};

});


//Tdef(\printRand).play;
//Tdef(\printRand).stop;


//____________________________________________________________________________________________________________________________________
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////LOOP


Tdef(\boucle, {
	var chooser;
	loop{

		/*
		Ndef(\mechaLoop).set(\start, 0, \amp, 0.3, \trig, 0);
		Ndef(\mechaLoopNoise).set(\start, 0, \amp, 1.7, \trig, 0);
		q.arduino.send($w, $d, 2, 0);
		*/

		"Data".postln;

		//send me some pxlData
		q.oscTX(1);
		2.5.wait;

		//Crackling
		"Crackling".postln;
		chooser = [[Ndef(\wifiLoop)],
			[Ndef(\droneOndes)],
			[Ndef(\impulseRid), Pdef(\impulseRid)],
			[Ndef(\blipRid), Pdef(\blipRid)],
			[Tdef(\droneSin)],
			[Ndef(\delay)]].choose;
		//[Tdef(\dronePulse)]
		chooser.postln;
		chooser[0].play;
		try{ chooser[1].play; };
		try{ chooser[2].play; };

		rrand(15, 45).wait;

		Ndef(\wifiLoop).stop(60);
		Ndef(\droneOndes).stop(50);
		Ndef(\impulseRid).stop(60);
		Pdef(\impulseRid).stop;
		Ndef(\blipRid).stop(50);
		Pdef(\blipRid).stop;
		Ndef(\delay).stop(45);
		Tdef(\droneSin).stop;
		Tdef(\dronePulse).stop;
		15.wait;

		//1_Print
		"1_mechaLoop".postln;
		Tdef(\printPxl).play;
		rrand(28, 107).wait;
		Tdef(\printPxl).stop;

		//Crackling
		"Crackling".postln;
		chooser = [[Ndef(\wifiLoop)],
			[Ndef(\droneOndes)],
			[Ndef(\impulseRid), Pdef(\impulseRid)],
			[Ndef(\blipRid), Pdef(\blipRid)],
			[Tdef(\droneSin)],
			[Ndef(\delay)]].choose;
		//[Tdef(\dronePulse)]
		chooser.postln;
		chooser[0].play;
		try{ chooser[1].play; };
		try{ chooser[2].play; };

		rrand(19, 41).wait;

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
		rrand(41, 97).wait;
		Tdef(\printRand).stop;

	};
});

);


/*
////////////////////////////////////////////////
//Anexe

//////////////////////////
//Serial Tests
(
Tdef(\tester, {
	350.do{
		q.arduino.send($w, $s, 1, 0);
		0.1.wait;
		q.arduino.send($w, $o);
		0.1.wait;
	};
}).play;
)

(
Tdef(\tester, {
	var direct = 0;
	350.do{|y|
		350.do{|x|
			q.arduino.send($w, $s, 1, direct);
			0.05.wait;
			if(0.5.coin==true,  {q.arduino.send($w, $o);});
			//q.arduino.send($w, $o);
			0.05.wait;
		};
		q.arduino.send($w, $t, 6, 1);
		0.1.wait;
		direct = 1-direct;
	};
}).play;
)

Tdef(\tester).stop;


/////////////////////////////////////////
//pixels = array --> an Int32Array of size receiver.width * receiver.height containing all pixel values as 32bit Integer

(
var red, green, blue, alpha;
i = Image.new(350,350);
f = Font("Arial", 18);
i.draw({ |ii|
	35.do{
		35.do{
			Pen.stringAtPoint("A".asString, Point(rrand(0, 350), rrand(0, 350)), f, Color.black);
		};
	};
	Pen.fill;
}).plot(freeOnClose:true); //background:Color.white);
p = i.pixels;
//i.free;
p.postln;
p.size.postln;

p[3000].postln;
red = p[3000] >> 24 & 0xFF;
red.postln;
green = p[3000] >> 16 & 0xFF;
green.postln;
blue = p[3000] >> 8 & 0xFF;
blue.postln;
alpha = p[3000] & 0xFF;
alpha.postln;
)

350*350
p[122149]
p = Int32Array.fill(350*350, {|i| 3.rand });
p.plot;


////////////////////////////////
//visual tester (not working at the moment)
(
var red, point;
w = Window.new("tester", Rect(50, 50, 350, 350)).front;
w.view.background_(Color.white);
w.drawFunc = {
	Pen.color = Color.black;
	350.do{ |y|
		350.do{ |x|
			point = ((x+1)*(y+1))-1;
			red = p[point] >> 24 & 0xFF;
			if(p[((x+1)*(y+1))-1]==1, { Pen.line(Point(x, y), Point(x+1,y+1)); });  //p[((x+1)*(y+1))-1]==1, red >= 128
		};
	};
	Pen.stroke;
};
w.refresh;
)



*/




