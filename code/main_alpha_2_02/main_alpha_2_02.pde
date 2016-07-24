//Java packages and librairies
import java.util.*;
//oscP5 is an OSC implementation for the programming environment processing. 
//OSC is the acronym for Open Sound Control, a network protocol developed at cnmat, UC Berkeley.
//Open Sound Control is a protocol for communication among computers, sound synthesizers, 
//and other multimedia devices that is optimized for modern networking technology 
//and has been used in many application areas. for further specifications and application implementations
//oscP5 website at http://www.sojamo.de/oscP5
import netP5.*;
import oscP5.*;

Data dataX;
//Debug mode
Data dataY;
OscP5 oscP5;
/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myRemoteLocation;

//variables
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

//Data
String[] list;
//Debug mode
String[] Debuglist;

//variables to be use in the oscEvent function
String name = "alpha";
int[] pxl;
int loc;
float r, g, b;
PImage alpha;
int[] charList;

void setup() {

  //create a new instance of Data.
  dataX = new Data(398);
  //create a new instance of Data for debug mode
  dataY = new Data(100);

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