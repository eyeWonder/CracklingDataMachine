import rita.*;
import java.util.*;
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;
String[] urls = {
  //"http://www.mrmartinweb.com", 
  //"http://boxesandarrows.com/researching-user-experience-a-knowledge-ecology-model/", 
  //"http://slash-paris.com", 
  "http://www.technologyreview.com/", 
  //"http://internetactu.blog.lemonde.fr/", 
  //"http://www.future-cities-lab.net/", 
  //"http://www.theatlantic.com", 
  //"http://www.dichtung-digital.org", 
  //"http://www.framablog.org", 
  //"http://archee.qc.ca", 
  //"http://www.olats.org", 
  //"http://www.eda.admin.ch/eda/de/home.html", 
  //"http://www.ubuweb.com/", 
  //"http://sccode.org/", 
  "http://www.instructables.com/tag/type-id/?sort=RECENT", 
  //"http://www.eve-rave.ch/",
};
int width = 595;
int height = 842;
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
boolean doFonction=false;
String name;
int[] pxl;

void setup() {
  size(width, height);
  frameRate(24);
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
  t1 = new Intervalometre(100000);
  t2 = new Intervalometre(1000);
}


//draw!!!

void draw() {
  
  if (t1.verifierIntervalle()) {
    thread("loadData");
    
    //in not finished, dónt draw something new!!!
  }
  if (t2.verifierIntervalle()) {
  }
  
  
  if (frameCount % 24 == 0) {
    background(255);
    if (!finished) {
    } 
    else {
      String[] words = split(allData, " ");
      Set<String> set = new HashSet<String>();
      Collections.addAll(set, words);
      String[] uniques = set.toArray(new String[0]);
      println(uniques.length);
      String[] uniques1 = subset(uniques, 0, uniques.length/3);
      String[] uniques2 = subset(uniques, uniques.length/3, (uniques.length/3)*2);
      //String[] uniques3 = subset(uniques, ((uniques.length/3)*2), uniques.length);
      RiText[] text = new RiText[uniques.length];
      RiText.defaults.alignment = CENTER;
      RiText.defaultFont("Georgia", 12);

      //Visuel! buqule
      for (int j = 0; j < RiIncrim ; j++) {
        text[j] = new RiText(this, uniques[j], xpos+=j, ypos+=10);  //random??
        if (xpos>=width) xpos = 0;
        if (ypos>=height) ypos = 0;
        text[j].draw();
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
    String[] words = splitTokens(allTxt, "\t+\n <>=\\-!@#$%^&*(),.;:/?\"\'[]{}|");  //delimiter list, pas enlever tous???
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
  if (key == 's') {

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

    /////Resultion bitcrusher???

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int loc = x + y*width;
        float r = red(alpha.pixels[loc]);
        float g = green(alpha.pixels[loc]);
        float b = blue(alpha.pixels[loc]);
        if ((r != 255) && (g !=255) && (b !=255)) {
          //int blackPixels = 0;
          pxl[loc] = 1;
        }
        else if ((r == 255) && (g ==255) && (b ==255)) {
          pxl[loc] = 0;
        }
      }
    }
    //println(pxl);
    println(alpha);
    updatePixels();
  }

  if (key == 'c') {
    //in the following different ways of creating osc messages are shown by example */
    OscMessage myMessage = new OscMessage("/line");
    //myMessage.add(loc);
    myMessage.add(new float[] {
      //r, g, b
    }
    ); /* add an int array to the osc message */
    println(myMessage);
    //send the message
    oscP5.send(myMessage, myRemoteLocation);
  }

  if (key == 'e') {
    exit();  // Stops the program
  }
}


////OSC
/* incoming osc message are forwarded to the oscEvent method. */

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}




//////////////
//////////////
// Metods & Classes

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
    if (sketchPath!=null) prefix=savePath(prefix);
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
    } 
    while (!ok);
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
    } 
    else {
      return false;
    }
  }
}

