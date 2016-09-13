/*
ALI TNANI
 Crackling Data Machine
 2016
 Version 2.2.1
 http://alitnani.com/
 https://processingfoundation.org/
 */

import java.io.*;//InputStreamReader;File;
import java.util.*;//Set;HashSet;Collections;Scanner;
import netP5.*;
import oscP5.*;

Data dataX;
OscP5 oscP5;
NetAddress myRemoteLocation;
String[] list;
StringBuilder sb = null;
boolean finished;
final String delim = "\t+\n <>=\\-!@#$€%^&*(),.;:/?\"\'1234567890_°{}[]";
String[] theSource = {
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
  "http://www.reuters.com/finance/commodities"
};

class Data {

  //Attributes
  int currentAmount;
  String[] urls;

  //Constructor
  Data(int constAmount, String[] theSource) {
    currentAmount = constAmount;
    urls = theSource;
  }

  public int getCurrentAmount() {
    return currentAmount;
  }

  public void setCurrentAmount(int a) {
    this.currentAmount = a;
  }

  public  String[] getUrls() {
    return urls;
  }

  public void setUrls(String[] u) {
    this.urls = u;
  }

  public String[] loadData(String[] list) {
    finished = false;
    String data_1 ="";
    try {
      for (int i = 0; i < urls.length; i++) {
        String[] lines = loadStrings(urls[i]);
        String Data_0 = join(lines, " ");
        String[] words = splitTokens(Data_0, delim);
        for (int j = 0; j < words.length; j++) {
          words[j] = words[j].trim();
          words[j] = words[j].toLowerCase();
        }
        words = sort(words);
        data_1 += join(words, " ");
      }

      String[] words = split(data_1, " ");
      words = sort(words);
      data_1  = join(words, " ");
      String[] data_2 = split(data_1, " ");
      Set<String> set = new HashSet<String>();
      Collections.addAll(set, data_2);
      String[] data_3 = set.toArray(new String[0]);
      IntList lottery;
      int number = (data_3.length) - currentAmount;
      lottery = new IntList();

      for (int i = 0; i < number; i++) {
        lottery.append(i);
      }

      for (int i = 0; i < 1; i++) {
        int index = int(random(lottery.size()));
        list = subset(data_3, index, currentAmount);
      }
      finished = true;
    }
    catch (Exception e) {
      System.out.println("Error e");
      try {
        File file = new File("/Users/alitnani/Desktop/main_2_2_1/data/[0].txt");
        Scanner sc = new Scanner(file);
        while (sc.hasNext()) {
          list = loadStrings("[0].txt");
        }
        sc.close();
      }
      catch (FileNotFoundException e1) {
        System.out.println("Error e1");
        System.exit(0);
      }
    }
    return list;
  }
}

void setup() {

  try {
    Process ping = Runtime.getRuntime().exec("ping " +" -c "+" 1 "+"www.google.com" );
    BufferedReader br = new BufferedReader(new InputStreamReader(ping.getInputStream()));
    sb = new StringBuilder();
    String line;
    while ((line = br.readLine ()) != null) {
      sb.append(line);
      sb.append("\n");
    }
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
  if (sb.toString().trim().equals("")) {
    System.out.println("You Are Not Connected to the Internet");
    System.exit(0);
  }
  System.out.println("You Are Connected to the Internet");

  //create a new instance of Data.
  dataX = new Data(50, theSource);
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
}

void draw() {
}

void oscEvent(OscMessage theOscMessage) {
  if (finished) {

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