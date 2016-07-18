import rita.*;
import java.util.*;
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

//Why it dosn't work with some urls?
//Sans Erreur

String[] urls = {
  "http://www.mrmartinweb.com", 
  //"http://boxesandarrows.com/researching-user-experience-a-knowledge-ecology-model/", 
  "http://slash-paris.com", 
  "http://www.technologyreview.com/", 
  "http://internetactu.blog.lemonde.fr/", 
  "http://www.future-cities-lab.net/", 
  "http://www.theatlantic.com", 
  "http://www.dichtung-digital.org", 
  //"http://www.framablog.org", 
  "http://archee.qc.ca", 
  "http://www.olats.org", 
  //"http://www.eda.admin.ch/eda/de/home.html", 
  "http://www.ubuweb.com/", 
  //"http://sccode.org/", 
  "http://www.instructables.com/tag/type-id/?sort=RECENT", 
  "http://www.reuters.com/finance/markets"
};

boolean finished = false;
float percent = 0;
String allData;
String allTxt;
int xpos;
int ypos;
int RiIncrim = 1000;
int loc = 0;
float r, g, b;
Intervalometre t1;
Intervalometre t2;
boolean doSave=false;
String name;
int[] pxl;
int[] charList;
boolean d = false;
boolean e = false;
boolean f = false;
boolean eraser = true;


void setup() {
  //background(0);
  size(1920, 1080);
  frameRate(0.1);
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
  thread("loadData");
  t1 = new Intervalometre(50000);
  t2 = new Intervalometre(1000);
}


///////////////
//draw!!!


void draw() {

  //  if (t1.verifierIntervalle()) {
  //    thread("loadData");
  //    //in not finished, dónt draw something new!!!
  //  }

  /*
  if (t2.verifierIntervalle()){
   thread("loadData");
   //in not finished, dónt draw something new!!!
   }
   */
  if (frameCount % 1 == 0) {
    //background(255);
    if (!finished) {
    } else {
      background(255);
      String[] words = split(allData, " ");
      Set<String> set = new HashSet<String>();
      Collections.addAll(set, words);
      String[] uniques = set.toArray(new String[0]);
      //println(uniques.length);
      //définir les variables int start & int count en fonction du nouveau int unique.length :
      int start1 = 0;
      int count = uniques.length/3;
      int start2 = count-1;
      //      int count2 = count1;
      int start3 = (count*2)-1;
      //      int count3 = count1;
      String[] uniques1 = subset(uniques, start1, count);
      String[] uniques2 = subset(uniques, start2, count);
      String[] uniques3 = subset(uniques, start3, count);
      RiText[] text1 = new RiText[uniques1.length];
      RiText[] text2 = new RiText[uniques2.length];
      RiText[] text3 = new RiText[uniques3.length];
      RiText.defaults.alignment = CENTER;
      RiText.defaultFont("Georgia", 12);
      //RiText.defaultFill(255, 255, 255, 255);

      if (d && eraser) {
        for (int i = 0; i < RiIncrim; i++) {
          text1[i] = new RiText(this, uniques1[i], xpos+=(i*1.2), ypos+=1);  
          if (xpos>=width) xpos = 0;
          if (ypos>=height) ypos = 0;
          text1[i].draw();
        }
      }
      if (e && eraser) {

        for (int j = 0; j < RiIncrim; j++) {
          text2[j] = new RiText(this, uniques2[j], xpos+=(j*1.5), ypos+=1.3);  
          if (xpos>=width) xpos = 0;
          if (ypos>=height) ypos = 0;
          text2[j].draw();
        }
      }
      if (f && eraser) {
        for (int k = 0; k < RiIncrim; k++) {
          text3[k] = new RiText(this, uniques3[k], xpos+=(k*1.6), ypos+=1.5);  
          if (xpos>=width) xpos = 0;
          if (ypos>=height) ypos = 0;
          text3[k].draw();
        }
      }
    }
  }
}


////loadData

void loadData() {
  finished = false;
  allData = "";
  allTxt = "";

  for (int i = 0; i < urls.length; i++) {
    percent = float(i)/urls.length;
    percent = percent*100;
    println("loading " + percent + " %");
    String[] lines = loadStrings(urls[i]);
    String allTxt = join(lines, " ");//Combines an array of Strings into one String, each separated by the character(s) used for the separator parameter
    //data processing
    String[] words = splitTokens(allTxt, "\t+\n<>=\\-!@#$%^&*(),.;:/?\"\'[]{}|0  123456789");  //delimiter list, pas enlever tous??? --> <>=\\-!@#$%^&*(),.;:/?\"\'[]{}|
    for (int j = 0; j < words.length; j++) {
      words[j] = words[j].trim();//Removes whitespace characters from the beginning and end of a String.
      words[j] = words[j].toLowerCase();
    }
    words = sort(words);
    allData += join(words, " ");
  }
  String[] words = split(allData, " ");
  words = sort(words);
  allData = join(words, " ");

  finished = true; // The thread is completed!
  println("Finished loading");
}



//Keapreassure Tests

void keyPressed() {

  if (key == 'c') {
    //in the following different ways of creating osc messages are shown by example */
    OscMessage myMessage = new OscMessage("/chat");
    myMessage.add(1); /* add an int array to the osc message */
    println(myMessage);
    //send the message
    oscP5.send(myMessage, myRemoteLocation);
  }

  if (key == 'd') { 
    d = true;
  }
  if (key == 'e') {
    e = true;
  }
  if (key == 'f') { 
    f = true;
  }
  if (key == 'q') {
    d = false;
    e = false;
    f = false;
    eraser = true;
  }
}


////OSC
/* incoming osc message are forwarded to the oscEvent method. */

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());


  //sendSC Pixels
  int sendYou = theOscMessage.get(0).intValue();
  if (sendYou == 1)
  {
    println("sendReceived");
    name = getIncrementalFilename("alpha-####.jpg");
    //saveFrame(sketchPath("data"+java.io.File.separator+name));
    saveFrame(sketchPath(name));
    doSave=false;
    // have a look in the data folder
    java.io.File folder = new java.io.File(sketchPath(""));
    // this is the filter (returns true if file's extension is .jpg)
    java.io.FilenameFilter jpgFilter = new java.io.FilenameFilter() {
      public boolean accept(File dir, String name) {
        return name.toLowerCase().endsWith(".jpg");
      }
    };
    // list the files in the data folder
    String[] filenames = folder.list(jpgFilter);
    // get the number of jpg files
    println(filenames.length + " jpg files in specified directory");

    PImage alpha;
    alpha = loadImage(sketchPath(name));

    int[] pxl = new int[width*height];

    loadPixels();  
    alpha.loadPixels();



    /////Black & White propre

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int loc = x + y*width;
        float r = red(alpha.pixels[loc]);
        float g = green(alpha.pixels[loc]);
        float b = blue(alpha.pixels[loc]);
        /*     
         if ((r != 255) && (g !=255) && (b !=255)) {
         pxl[loc] = 1;
         }
         else if ((r == 255) && (g ==255) && (b ==255)) {
         pxl[loc] = 0;
         }
         */
        if (r + g + b < 383) {
          pxl[loc] = 1;
        } else if (r + g + b >= 383) {
          pxl[loc] = 0;
        }
      }
    }


    //translate Data in Ascii Numbers


    int countChar = allData.length();
    println(countChar);
    int[] charList = new int[countChar];

    for (int y = 0; y < countChar; y++) {
      char lettre = allData.charAt(y);
      int lnumber = int(lettre);
      charList[y] = lettre;
    }


    int parts = countChar/2000;
    int startPxl1 = 0;
    int startPxl2 = parts-1;
    int startPxl3 = (parts*2)-1;
    int startPxl4 = (parts*3)-1;
    int startPxl5 = (parts*4)-1;
    int startPxl6 = (parts*5)-1;
    int[] pxl1 = subset(charList, startPxl1, parts);
    int[] pxl2 = subset(charList, startPxl2, parts);
    int[] pxl3 = subset(charList, startPxl3, parts);
    int[] pxl4 = subset(charList, startPxl4, parts);
    int[] pxl5 = subset(charList, startPxl5, parts);
    int[] pxl6 = subset(charList, startPxl6, parts);


    OscMessage myMessage1 = new OscMessage("/chat");
    myMessage1.add(pxl1); /* add an int array to the osc message */
    println(myMessage1);
    //send the message
    oscP5.send(myMessage1, myRemoteLocation);


    ///////////////separate the Data



    //    //in the following different ways of creating osc messages are shown by example */
    //    int countPxl = pxl.length/6;
    //    int startPxl1 = 0;
    //    int startPxl2 = countPxl-1;
    //    int startPxl3 = (countPxl*2)-1;
    //    int startPxl4 = (countPxl*3)-1;
    //    int startPxl5 = (countPxl*4)-1;
    //    int startPxl6 = (countPxl*5)-1;
    //    int[] pxl1 = subset(pxl, startPxl1, countPxl);
    //    int[] pxl2 = subset(pxl, startPxl2, countPxl);
    //    int[] pxl3 = subset(pxl, startPxl3, countPxl);
    //    int[] pxl4 = subset(pxl, startPxl4, countPxl);
    //    int[] pxl5 = subset(pxl, startPxl5, countPxl);
    //    int[] pxl6 = subset(pxl, startPxl6, countPxl);
    //
    //    //Send all Data in 6 messages
    //
    //    OscMessage myMessage1 = new OscMessage("/chat");
    //    myMessage1.add(pxl1); /* add an int array to the osc message */
    //    println(myMessage1);
    //    //send the message
    //    oscP5.send(myMessage1, myRemoteLocation);
    //
    //    OscMessage myMessage2 = new OscMessage("/chat");
    //    myMessage2.add(pxl2); /* add an int array to the osc message */
    //    println(myMessage2);
    //    //send the message
    //    oscP5.send(myMessage2, myRemoteLocation);
    //
    //    OscMessage myMessage3 = new OscMessage("/chat");
    //    myMessage3.add(pxl3); /* add an int array to the osc message */
    //    println(myMessage2);
    //    //send the message
    //    oscP5.send(myMessage3, myRemoteLocation);
    //
    //
    //    OscMessage myMessage4 = new OscMessage("/chat");
    //    myMessage4.add(pxl4); /* add an int array to the osc message */
    //    println(myMessage2);
    //    //send the message
    //    oscP5.send(myMessage4, myRemoteLocation);
    //
    //    OscMessage myMessage5 = new OscMessage("/chat");
    //    myMessage5.add(pxl5); /* add an int array to the osc message */
    //    println(myMessage2);
    //    //send the message
    //    oscP5.send(myMessage5, myRemoteLocation);
    //
    //    OscMessage myMessage6 = new OscMessage("/chat");
    //    myMessage6.add(pxl6); /* add an int array to the osc message */
    //    println(myMessage2);
    //    //send the message
    //    oscP5.send(myMessage6, myRemoteLocation);

    println(alpha);
    updatePixels();
  }



  //changePXL1
  int change1 = theOscMessage.get(0).intValue();
  if (change1 == 2)
  {
    println("changeReceived1");
    d = true;
  } 

  //changePXL2
  int change2 = theOscMessage.get(0).intValue();
  if (change2 == 3)
  {
    println("changeReceived2");
    e = true;
  }  

  //changePXL3
  int change3 = theOscMessage.get(0).intValue();
  if (change3 == 4)
  {
    println("chageReceived3");
    f = true;
  }  

  //ereasePXL
  int erease = theOscMessage.get(0).intValue();
  if (erease == 5)
  {
    println("ereaseReceived");
    d = false;
    e = false;
    f = false;
    eraser = true;
    background(255);
  }
}




//////////////
//////////////
// Methods & Classes

public String getIncrementalFilename(String what) {

  String s="", prefix, suffix, padstr, numstr;
  int index=0, first, last, count;
  File f;
  boolean ok;
  first=what.indexOf('#');
  last=what.lastIndexOf('#');
  count=last-first+1;
  if ( (first!=-1)&& (last-first>0)) {
    prefix=what.substring(0, first);
    suffix=what.substring(last+1);
    // Comment out if you want to use absolute paths
    // or if you're not using this inside PApplet
    //if (sketchPath != null) prefix=savePath(prefix);
    index=0;
    ok=false;
    do {
      padstr="";
      numstr=""+index;
      for (int i=0; i<count-numstr.length(); i++) padstr+="0";       
      s=prefix+padstr+numstr+suffix;
      f=new File(s);
      ok=!f.exists();
      index++;
      // Provide a panic button. If index > 10000 chances are it's an 
      // invalid filename.
      if (index>10000) ok=true;
    } while (!ok);
    // Panic button - comment out if you know what you're doing
    if (index>10000) {
      return prefix+"ERR"+suffix;
    }
  }
  return s;
}


class Intervalometre {
  int intervalle;
  int dernier_tic;
  Intervalometre(int intervalle_initial) {
    intervalle = intervalle_initial;
    dernier_tic = millis();
  }
  boolean verifierIntervalle() {
    if (millis() > dernier_tic + intervalle) {
      dernier_tic = millis();
      return true;
    } else {
      return false;
    }
  }
}