(
i = Image.new(350,350);

i.draw({ arg image;
	Pen.translate(0, 0);
	300.do {
		400.do{
		// set the Color
		//Pen.color = Color.black; //green(rrand(0.0, 1), rrand(0.0, 0.5));
		f = Font("Arial", 18);
		Pen.stringAtPoint("A".asString, Point(rrand(0, 400), rrand(0, 300)), f, Color.rand);
	};
	};
	Pen.fill;
    }); //.plot(freeOnClose:true); //background:Color.white);
//p = i.pixels;
//p.postln;
//i.free;
p = i.pixels;
i.loadPixels(p);
i.free;
p.postln;
p.size.postln;
p[3000];
)