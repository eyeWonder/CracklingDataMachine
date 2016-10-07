///////////////////////////
////////////////////////////////
///Crackling Data Machines
//////////////////////////////
//2014-2016, Ali Tnani & Lukas Truniger
//////////////////////////

/*
///////////////////
TODO!!!!!!!!!!!!
//!!!!!!!!!!!!!!!!!!!!!!!!!!
--> wait for data

--> impulse rid???

--> negative direction on paper...?
--> character pixel randomizer
--> network activity riddim
--> scale impression
*/

(

//___________________________________________________________________________________________________
/////////////////////////////////////////////////////////////////////////////////////////////////////
///////SETUP
///////Setup routine (boot audio server, initialize printer)

(
Tdef(\setup, {

	//start audio server
	0.5.wait;
	s.quit;
	0.5.wait;
	s = Server.local;
	0.5.wait;
	s.options.memSize = 65536;
	0.5.wait;
	s.options.blockSize = 512;
	0.5.wait;
	s.boot;
	8.wait;

	//printSetup: head position
	q.arduino.send($r, $b);
	1.wait;
	while({ q.crashRX == 1 },
		{ q.arduino.send($w, $s, 1, q.direct-1);
			0.05.wait;
			q.arduino.send($r, $b);
			0.05.wait;
	});

	//printSetup: take paper
	250.do{
		q.arduino.send($w, $t, 10, 1); //stepper y (speed, steps) *80!!!
		0.1.wait;
	};

	//get first Data
	"first Data".postln;
	q.oscTX(1);
	60.wait;

	//start Loop
	Tdef(\boucle).play;
}).play;
);


//___________________________________________________________________________________________________
/////////////////////////////////////////////////////////////////////////////////////////////////////
//global dictionary

q = ();   //set variable as dictionary

//////////////////////////////////////////
//Serial Communication for Arduino

q.crashRX; //dictionary variable for crash sensor

(
q.arduino = ArduinoSMS(
	"/dev/ttyUSB0",    //edit to match your port. SerialPort.listDevices
	baudrate: 38400    //check that baudrate is the same as in arduino sketch
);
q.arduino.action = { |... msg| q.crashRX = msg[0]; };
);


//q.arduino.close;
//q.arduino.send($w, $o); //solenoid
//q.arduino.send($w, $s, 1, 1); //stepper x (speed, steps)
//q.arduino.send($w, $t, 1, 1); //stepper y (speed, steps)
//q.arduino.send($w, $s, 1, 1); //stepper x (speed, steps)
//q.arduino.send($w, $t, 7, 1); //stepper y (speed, steps)


/////////////////////////////////
//Global Variables and Buffers

q.pxlRes =  [350, 350];
q.charBuffer = [111, 110, 113, 180, 32, 114, 116, 110, 80, 111, 110, 113, 180, 32, 116, 110, 80, 111, 110, 113, 180, 114, 116, 110, 80, 111, 32, 113, 180, 111, 110, 113, 180, 114, 116, 110, 32, 80, 111, 110, 113, 180, 114, 116, 110, 80, 32, 111, 110, 113, 180, 114, 116, 32, 110, 80, 111, 110, 113, 180, 114, 116, 110, 80];

//variables printin
q.printSpeed = 0.13; //duration of each step, min 0.04
q.stepsPerLine = 7;
q.font = Font("Arial", 14);
q.direct = 1;
q.image;
q.imagePixel;


//variables sound
q.space = 32;
q.freq;
q.charFreqs = [];
q.charFreqsRevIndex = 64;


///////////////////////////
//Print Function

//only runs on appClock (inside tdef add .defer)
q.newImage = { |q|
	q.image = Image.new(q.pxlRes[0], q.pxlRes[1]);
	q.image.draw({
		var xpos = 0, ypos = 0;
		var xrand = rrand(-0.9, 1.9);
		var yrand = rrand(1.7, 5.1);
		q.wordBuffer.size.do{ |i|
			xpos = xpos+(i*xrand);
			ypos = ypos+yrand;
			Pen.stringAtPoint(q.wordBuffer[i], Point(xpos, ypos), q.font, Color.black);
			if(xpos >= q.pxlRes[0], { xpos = 0 });
			if(xpos < 0, { xpos =  q.pxlRes[0]-1});
			if(ypos >= q.pxlRes[1], { ypos = 0 });
		};
		Pen.fill;
	});//.plot(freeOnClose:true, background:Color.white);
	q.imagePixel = q.image.pixels;
	q.image.free;
};


//////////////////////////////
//OSC-Setup for communication with Processing
(
m = NetAddr("127.0.0.1", 12000);  //define remote adress and port
q.oscTX = { |q, val1 |
	m.sendMsg("/sendMe", val1);
};
);

//q.oscTX(1); send me some data

(
n = NetAddr("127.0.0.1", nil);
q.rxPrint = OSCdef(\rxPrint, {|msg, time, addr, recvPort|
	msg.postln;
	msg.removeAt(0);
	msg.size.postln;
	q.charBuffer = msg; //write to ascii character buffer
	q.wordBuffer = [];
	q.charBuffer.size.do{ |i|
		var char;
		char = q.charBuffer[i].asAscii;
		q.wordBuffer = q.wordBuffer++char
	};
	q.wordBuffer = q.wordBuffer.join.asString.removeEvery("/_&%§$<>|\ß~+[]{}…").split($ ); //make a string //.removeItems(items: ",().?/!?;:_")
	{q.newImage}.defer;
}, '/chat', n);
);

/////////////////
//Event Setup for Arduino (mechanic riddims)

///mapping
q.mapping = (
	rls: [$d, 2],
	srv: [$s, 3],
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
	q.charFreqs = [];
	20.do{ |i|
		q.freq = q.charBuffer[q.charFreqsRevIndex];
		q.charFreqs = q.charFreqs++(q.freq);
		/*if ( q.freq > q.space,
		{q.charFreqs = q.charFreqs++q.freq;});*/
		q.charFreqsRevIndex = q.charFreqsRevIndex -1;
		if ( q.charFreqsRevIndex <= 0, {q.charFreqsRevIndex = q.charBuffer.size }; );
	};
	q.charFreqs;
};
);

//__________________________________________________________________________________________________________________
////////////////////////////////////////////////////////////////////////////////////////////////
///////SOUND SETUP

Ndef.clear;


///WiFiAktivity (aka microphone Input)

(
Ndef(\wifi, { | amp = 3.2|
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
Ndef(\wifiLoop, { |amp = 1.5, start = 0, bufnum = 1, trig|
	var in = Ndef.ar(\wifi, 1, 0) ;
	var son = PanAz.ar(2, in,
		Duty.kr(1, 0, Drand([-1, -0.5, 0.0, 0.5], inf)),
		amp,
		0.5, 0);
	son
});
);

//Ndef(\wifiLoop).play;
//Ndef(\wifiLoop).stop;


//droneOndesModulation

Ndef(\droneOndes, { |amp = 0.5|
	var freqs = q.nextFreqs;
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
Ndef(\impulseRid, { |amp = 1.1|
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
Ndef(\blipRid, { |amp = 1.1|
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
			var son = SinOsc.ar(q.nextFreqs.choose * 1.25, 0, Rand(0.6, 0.9), 0.8);
			//son = son * (Ndef.ar(\wifi, 1, 0) * 2);
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
		Ndef(\pulse, {
			var son = LFPulse.ar(q.nextFreqs.choose, 0, Rand(0.5, 1), 0.5);
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
	input = Ndef.ar(\wifi, 1, 0) * 1.6;
	// delay time jumps every 2 seconds
	delayTime = Demand.kr(Impulse.kr(0.2), 0, Dseq([0.4, 0.6, 0.9, 0.3, 0.7], inf));
	// CombC - delay with feedback
	CombC.ar(input ! 2, 16, delayTime, 6) + input;
	input = PanAz.ar(2, input, LFSaw.kr(SinOsc.kr(0.5).range(0.01, 0.05)));
	input = input * 0.5;
	input
});
);

//Ndef(\delay).play;
//Ndef(\delay).stop;


//___________________________________________________________________________________________________________________
//////////////////
///////PATTERNS SETUP

/////////Printer
(
Tdef(\printer, {
	var direct = 1, line, point, red;
	loop{
		q.pxlRes[1].do{ |y|

			line = Int32Array.new(q.pxlRes[0]);
			q.pxlRes[0].do{ |i|
				line.add(q.imagePixel.pop);
			};

			q.pxlRes[0].do{ |x|

				q.arduino.send($w, $s, 1, direct);
				q.printSpeed.wait;
				if(direct == 1, { point = line.pop; },
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
		1.wait;
		"new Data".postln;
		//send me some pxlData
		q.oscTX(1);
		60.wait;
		//?wait for data? OSC??
	}

});
);


//Tdef(\printer).play;
//Tdef(\printer).pause;
//Tdef(\printer).resume;

//__________________________________________________________________________________________________________________
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////LOOP

(
Tdef(\boucle, {
	var chooser;

	//printer
	"printer".postln;
	Tdef(\printer).play;
	//rrand(28, 107).wait;
	//Tdef(\printer).stop;

	2.wait;

	loop{

		/*
		Ndef(\mechaLoop).set(\start, 0, \amp, 0.3, \trig, 0);
		Ndef(\mechaLoopNoise).set(\start, 0, \amp, 1.7, \trig, 0);
		q.arduino.send($w, $d, 2, 0);
		*/

		0.1.wait;
		q.nextFreqs;
		0.1.wait;

		//Crackling
		"Crackling".postln;
		chooser = [[Ndef(\wifiLoop)],
			[Ndef(\droneOndes)],
			[Ndef(\impulseRid), Pdef(\impulseRid)],
			[Ndef(\blipRid), Pdef(\blipRid)],
			[Tdef(\droneSin)],
			[Ndef(\delay)],
			[Tdef(\dronePulse)]].choose;
		chooser.postln;
		chooser[0].play;
		try{ chooser[1].play; };

		rrand(2, 10).wait;
		Tdef(\printer).resume;

		rrand(15, 60).wait;

		Ndef(\wifiLoop).stop(rrand(15, 30));
		0.15.wait;
		Ndef(\droneOndes).stop(rrand(15, 30));
		0.15.wait;
		Ndef(\impulseRid).stop(rrand(15, 30));
		0.15.wait;
		Pdef(\impulseRid).stop;
		0.15.wait;
		Ndef(\blipRid).stop(rrand(15, 30));
		0.15.wait;
		Pdef(\blipRid).stop;
		0.15.wait;
		Ndef(\delay).stop(rrand(15, 30));
		0.15.wait;
		Tdef(\droneSin).stop;
		0.15.wait;
		Tdef(\dronePulse).stop;
		0.15.wait;

		rrand(2, 10).wait;
		Tdef(\printer).pause;
		rrand(8, 30).wait;


	};
});
);

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
q.imagePixel = q.image.pixels;
//i.free;
//p.postln;
//p.size.postln;

q.imagePixel[3000].postln;
red = q.imagePixel[3000] >> 24 & 0xFF;
red.postln;
green = q.imagePixel[3000] >> 16 & 0xFF;
green.postln;
blue = q.imagePixel[3000] >> 8 & 0xFF;
blue.postln;
alpha = q.imagePixel[3000] & 0xFF;
alpha.postln;
)



//only runs on appClock (.defer)

q.newImage = { |q|
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
}).plot(freeOnClose:true, background:Color.white);
q.imagePixel = q.image.pixels;
//q.image.free;
};


Tdef(\imageTester, {
loop{
{q.newImage}.defer;
5.wait;
}
}).play;



*/




