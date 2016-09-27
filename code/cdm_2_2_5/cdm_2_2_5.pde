/*
 Title : Crackling Data Machine
 Autors : ALI TNANI & Lukas Truniger
 Date : 2014-2016
 Medium : steel, single board computers, printer, sound, paper and custom software 
 Dimensions: 85 x 100 x 66 cm
 */

import java.util.*;
/**
https://docs.oracle.com/javase/7/docs/api/java/io/package-summary.html
*/
import java.io.*;
/**
https://docs.oracle.com/javase/7/docs/api/java/nio/charset/Charset.html
*/
import java.nio.charset.Charset;
/**
 */
import netP5.*;
import oscP5.*;
OscP5 oscP5;
//a NetAddress contains the ip address and port number of a remote location in the network.
NetAddress myRemoteLocation;

final String delim = "\t+\n <>=\\-!@#$€%^&*(),.;:/?\"“”\1234567890_°{}[]«";
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
  /**
   * @param  String[] urls           
   * @param  int currentAmount
   * @param  int currentAmount
   * @param  String Path
   * @return String[] list  
   */
  final String Path = "./data/backup.txt";
  int currentAmount;
  String[] urls;

  Data(int constAmount, String[] chapitre_1) {
    currentAmount = constAmount;
    urls = chapitre_1;
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

    /**
     * This method always returns immediately, whether or not the data exists. 
     */
    String data_1 ="";//a variable to keep all the data loaded in an empty string

    try {
      //Look at each url
      for (int i = 0; i < urls.length; i++) {
        String[] lines = loadStrings(urls[i]);
        /*data splitting and joining to get out some "dirty character"...
         Combines an array of Strings into one String, each separated by the character(s) used for the separator parameter*/
        String Data_0 = join(lines, " ");
        /*splits a String at one or many character delimiters or "tokens." 
         The delim parameter specifies the character or characters to be used as a boundary.*/
        String[] words = splitTokens(Data_0, delim);
        for (int j = 0; j < words.length; j++) {
          //Removes whitespace characters from the beginning and end of a String and removes the Unicode "nbsp" character.
          words[j] = words[j].trim();
          //Converts all of the characters in the string to lowercase.
          words[j] = words[j].toLowerCase();
        }
        //Sorts the array of words in place. This is the first data output.
        words = sort(words);
        data_1 += join(words, " ");
      }
      /*breaks a String into pieces using a character or string as the delimiter. 
       The delim parameter specifies the character or characters that mark the boundaries between each piece. 
       A String[] array is returned that contains each of the pieces.*/
      String[] words = split(data_1, " ");
      words = sort(words);
      data_1  = join(words, " ");
      //removes duplicated words or character
      String[] data_2 = split(data_1, " ");
      Set<String> set = new HashSet<String>();
      Collections.addAll(set, data_2);
      String[] data_3 = set.toArray(new String[0]);
      //pick a random list of data with the currentAmount defined in setup method.
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
    }
    catch (Exception e) {
      System.out.println("Error e : Bad, Not Found or Forbidden Request");
      //loads data from a backup text file 
      try {
        File file = new File(Path);
        Scanner sc = new Scanner(file);
        List<String> lines = new ArrayList<String>();
        while (sc.hasNextLine()) {
          lines.add(sc.nextLine());
        }
        sc.close();
        list = lines.toArray(new String[0]);
      }
      catch (FileNotFoundException e1) {
        System.out.println("Error e1 : File Not Found");
        System.exit(0);
      }
    }
    return list;
  }
}
Data dataX;
Data dataY;
String[] list;
StringBuilder sb = null;

public void setup() {
  //Internet parameters
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
  //  System.exit(0);
  }
  System.out.println("You Are Connected to the Internet");

  /*defines currentAmount : int average[100;1000]*/
  dataX = new Data(500, theSource);
  dataY = new Data(1000, theSource);

  //create a new osc properties object
  OscProperties properties = new OscProperties();
  /* set a default NetAddress. sending osc messages with no NetAddress parameter 
   * in oscP5.send() will be sent to the default NetAddress.*/
  properties.setRemoteAddress("127.0.0.1", 57120);
  //the port number you are listening for incoming osc packets.
  properties.setListeningPort(12000);
  /* Send Receive Same Port is an option where the sending and receiving port are the same.
   * this is sometimes necessary for example when sending osc packets to supercolider server.
   * while both port numbers are the same, the receiver can simply send an osc packet back to
   * the host and port the message came from.
   */
  properties.setSRSP(OscProperties.OFF);
  /* set the datagram byte buffer size. this can be useful when you send/receive
   * huge amounts of data, but keep in mind, that UDP is limited to 64k
   */
  properties.setDatagramSize(64000);
  //initialize oscP5 with our osc properties
  oscP5 = new OscP5(this, properties);
  //print your osc properties
  println(properties.toString());
}

public void oscEvent(OscMessage theOscMessage) {

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
    oscP5.send(myMessage);
    myMessage.clear();
    println("sendReceived");
  }
  //if (sendYou == 2) {
  //  String[] textToBytes = dataY.loadData(list);
  //  //System.out.println(Arrays.toString(textToBytes));
  //  byte[][] byteStrings = convertToBytes(textToBytes);
  //  System.out.println(Arrays.toString(byteStrings));
  //}
}

public void draw() {
  //String[] textToBytes = dataY.loadData(list);
  //System.out.println(Arrays.toString(textToBytes));
  //byte[][] byteStrings = convertToBytes(textToBytes);
  //System.out.println(Arrays.toString(byteStrings));
}

private static byte[][] convertToBytes(String[] strings) {
  byte[][] data = new byte[strings.length][];
  for (int i = 0; i < strings.length; i++) {
    String string = strings[i];
    data[i] = string.getBytes(Charset.defaultCharset()); // you can chose charset
  }
  return data;
}