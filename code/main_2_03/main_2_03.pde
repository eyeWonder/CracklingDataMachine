import java.util.*;
//Contains the collections framework, legacy collection classes, event model, 
//date and time facilities, internationalization, and miscellaneous utility classes 
//(a string tokenizer, a random-number generator, and a bit array).
//https://docs.oracle.com/javase/7/docs/api/java/util/package-summary.html
Data dataX;
//Debug mode
Data dataY;
String[] urls = {
  "http://www.reuters.com/legal/", 
  "http://www.reuters.com/finance/", 
  "http://www.reuters.com/finance/markets/", 
  "http://www.reuters.com/news/world/", 
  "http://www.reuters.com/news/health", 
  "http://www.reuters.com/politics/", 
  "http://www.reuters.com/news/technology/", 
  "http://blogs.reuters.com/breakingviews/", 
  "http://www.reuters.com/news/lifestyle", 
  "http://www.reuters.com/finance/deals", 
  "http://www.reuters.com/finance/commodities", 
  //curating some urls
  //make a text file with urls list and archive data in allowed server
  //Ex.: String[] urls = {"http://alitnani.com/cracklingDataMachine/dataArchive.txt" };
};
String[] list;
//Debug mode
String[] Debuglist;

//oscP5 is an OSC implementation for the programming environment processing. 
//OSC is the acronym for Open Sound Control, a network protocol developed at cnmat, UC Berkeley.
//Open Sound Control is a protocol for communication among computers, sound synthesizers, 
//and other multimedia devices that is optimized for modern networking technology 
//and has been used in many application areas. for further specifications and application implementations
//http://www.sojamo.de/libraries/oscP5/reference/index.html
//https://www.cs.princeton.edu/~prc/ChucKU/Code/OSCAndMIDIExamples/VideoAction/oscP5/

import netP5.*;
import oscP5.*;
OscP5 oscP5;
/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myRemoteLocation;

//Carnivore is a Processing library that allows you to perform surveillance on data networks. 
//Carnivore listens to Internet traffic (email, web surfing, etc.) on a specific local network.
import org.rsg.carnivore.*;
import org.rsg.carnivore.cache.*;
import org.rsg.carnivore.net.*;
import org.rsg.lib.Log;
CarnivoreP5 c;

//offline mode
// Flag for online/offline modes.
boolean isOnline = true;

void setup() {

  //create a new instance of Data.
  dataX = new Data(50);
  //create a new instance of Data for debug mode
  dataY = new Data(1000);

  //create a new instance of CarnivoreP5
  c = new CarnivoreP5(this);
  c.setVolumeLimit(7);
  c.setShouldSkipUDP(false);

  ///* create a new osc properties object */
  //OscProperties properties = new OscProperties();

  ///* set a default NetAddress. sending osc messages with no NetAddress parameter 
  // * in oscP5.send() will be sent to the default NetAddress.
  // */
  //properties.setRemoteAddress("127.0.0.1",12000);

  ///* the port number you are listening for incoming osc packets. */
  //properties.setListeningPort(12000);


  ///* Send Receive Same Port is an option where the sending and receiving port are the same.
  // * this is sometimes necessary for example when sending osc packets to supercolider server.
  // * while both port numbers are the same, the receiver can simply send an osc packet back to
  // * the host and port the message came from.
  // */
  //properties.setSRSP(OscProperties.ON);

  ///* set the datagram byte buffer size. this can be useful when you send/receive
  // * huge amounts of data, but keep in mind, that UDP is limited to 64k
  //*/
  //properties.setDatagramSize(1024);

  ///* initialize oscP5 with our osc properties */
  //oscP5 = new OscP5(this,properties);    

  ///* print your osc properties */
  //println(properties.toString());


  //create a new instance of oscP5. 12000 is the port number you are listening for incoming osc messages.
  oscP5 = new OscP5(this, 12000);

  //create a new NetAddress. a NetAddress is used when sending osc messages with the oscP5.send method.
  //the address of the osc broadcast server
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
}
void draw() {
  //Debug mode
  String[] debugList = dataY.loadData(Debuglist);
  String debugList_1 = join(debugList, " ");
  println(debugList_1.length() + " : " + debugList_1);
}

// This is the callback for the online mode, i.e. Carnivore library triggers this method

synchronized void packetEvent(CarnivorePacket packet) {

  if (isOnline) {
    //OSC-Receive setup from Processing
    //(
    //n = NetAddr("127.0.0.1", nil);
    //q.oscRX = OSCdef(\oscMSG, {|msg, time, addr, recvPort|
    //msg.postln;
    //msg.removeAt(0);
    //q.pxlBuffer = q.pxlBuffer ++ msg;
    //}, '/chat', n);
    //);
    // make a new OSC Address Pattern : "/newAddr" to send the packet header
    OscMessage myMessage = new OscMessage("/chat");
    //timestamp, sender, receiver
    String metadata = packet.header();
    //The content of the packet converted into ASCII characters. 
    //(Note: any bytes outside of the simple ASCII range [greater than 31 and less than 127] 
    //are printed as whitespace.)

    // make a new OSC Address Pattern : "/newAddr" to send a string of charcter & the packet header (timestamp, sender, receiver)
    String data_1 = packet.ascii();
    myMessage.add(metadata + data_1);

    // make a new OSC Address Pattern : "/newAddr" to send an arrau of bytes
    //The content of the packet as bytes.
    byte[] data_2 = packet.data;
    myMessage.add(data_2);
    //send and clear myMessage
    oscP5.send(myMessage, myRemoteLocation);
    myMessage.clear();
    //(
    //q.nextFreqs = { |q|
    //  20.do{
    //    q.freq = q.pxlBuffer.pop;
    //    if ( q.freq > q.space,
    //      {q.freqsFilt = q.freqsFilt ++ q.freq;});
    //  };
    //  q.freqsFilt;
    //};
    //);
  }
}

void oscEvent(OscMessage theOscMessage) {
  if (isOnline) {

    //Wait for the incoming osc message from SC
    
    //OSC-Send setup for Processing
    //(
    //m = NetAddr("127.0.0.1", 12000); //define remote adress and port
    //q.oscTX = { |q, val1 |
    //m.sendMsg("/sendMe", val1);
    //};
    //);

    int sendYou = theOscMessage.get(0).intValue();
    if (sendYou == 1) {

      //String to ascii 

      String[] textToPrint = dataX.loadData(list); 
      String textToPrint_1 = join(textToPrint, " ");
      int countChar = textToPrint_1.length();

      int[] asciiToPrint = new int[countChar];
      for (int y = 0; y < countChar; y++) {
        char character = textToPrint_1.charAt(y);//charAt(int) return an index
        asciiToPrint[y] = character;
      }

      //An OSC message consists of an OSC Address Pattern followed by an OSC Type Tag String followed by zero or more OSC Arguments.
      //send data to Supercollider
      OscMessage myMessage = new OscMessage("/chat");
      myMessage.add(asciiToPrint); 
      oscP5.send(myMessage, myRemoteLocation);
      myMessage.clear();
      println("sendReceived");
    }
  }
}

//Grab and filter data

class Data { 

  int currentAmount;

  //Constructor
  public Data(int constAmount) {
    currentAmount = constAmount;
  }

  //loadData fuction
  String[] loadData(String[] list) {
    String data_1 ="";
    //array of string 
    //A variable to keep all the data loaded in an empty string
    //  String allData ="";
    //load from a constant String[] urls
    // Look at each URL

    for (int i = 0; i < urls.length; i++) {
      String[] lines = loadStrings(urls[i]);
      
      //Filter#1 : data splitting and joining to get out some "dirty character"
      String Data_0 = join(lines, " ");
      String[] words = splitTokens(Data_0, "\t+\n <>=\\-!@#$%^&*(),.;:/?\"\'1234567890_°{}[]$€");/*à mentionner l'argument string comme constante*/

      for (int j = 0; j < words.length; j++) {
        //Removes whitespace characters from the beginning and end of a String and removes the Unicode "nbsp" character
        words[j] = words[j].trim();
        //Converts all of the characters in the string to lowercase
        words[j] = words[j].toLowerCase();
      }
      //Sorts the array in place
      words = sort(words);
      //Combines an array of Strings into one String, each separated by the character(s) used for the separator parameter.
      data_1 += join(words, " ");//first output to list
    }

    String[] words = split(data_1, " ");
    words = sort(words);
    data_1  = join(words, " ");
    //Filter#2 : removes duplicated words or character
    String[] data_2 = split(data_1, " ");
    Set<String> set = new HashSet<String>();
    Collections.addAll(set, data_2);
    String[] data_3 = set.toArray(new String[0]);//second output to list

    //Filter#3 : pick a random list of data with the currentAmount defined in setup method as argment of the loadData function
    IntList lottery;
    //get an index
    int number = (data_3.length) - currentAmount;
    lottery = new IntList();
    for (int i = 0; i < number; i++) {
      lottery.append(i);
    }
    for (int i = 0; i < 1; i++) {
      int index = int(random(lottery.size()));
      list = subset(data_3, index, currentAmount);//thired output to list
    }
    return list;
  }
}