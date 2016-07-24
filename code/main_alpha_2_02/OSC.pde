//OSC-string
//A sequence of non-null ASCII characters followed by a null, followed by 0-3 additional null characters to make the total number of bits a multiple of 32.

//OpenSound Control Spec Examples : http://opensoundcontrol.org/spec-1_0-examples#OSCstrings

void oscEvent(OscMessage theOscMessage) {

  //Wait for the incoming osc message from SC

  /* get and print the address pattern and the typetag of the received OscMessage */
  //println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  //theOscMessage.print();

  int sendYou = theOscMessage.get(0).intValue();

  if (sendYou == 1) {
    println("sendReceived");
  }

  //String to ascii or hexa or binary Converter

  String[] textToPrint = dataX.loadData(list); 
  String textToPrint_1 = join(textToPrint, " ");
  int countChar = textToPrint_1.length();
  int[] ascii = new int[countChar];
  for (int y = 0; y < countChar; y++) {
    char character = textToPrint_1.charAt(y);//charAt(int) return an index
    ascii[y] = character;
  }
  
  
  //An OSC message consists of an OSC Address Pattern followed by an OSC Type Tag String followed by zero or more OSC Arguments.
  //send data to Supercollider
  OscMessage myMessage = new OscMessage("/chat");
  myMessage.add(ascii); 
  //println(myMessage1);
  oscP5.send(myMessage, myRemoteLocation);


  //changePXL1
  int change1 = theOscMessage.get(0).intValue();
  if (change1 == 2) {
    //println("changeReceived1");
  } 

  //changePXL2
  int change2 = theOscMessage.get(0).intValue();
  if (change2 == 3) {
    //println("changeReceived2");
  }  

  //changePXL3
  int change3 = theOscMessage.get(0).intValue();
  if (change3 == 4) {
    //println("chageReceived3");
  }
}