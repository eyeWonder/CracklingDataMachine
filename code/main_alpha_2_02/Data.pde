//Grab and filter data
//references
//https://github.com/processing/processing-docs/blob/master/content/examples/Topics/Advanced%20Data/Threads/Threads.pde
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
      data_1 += join(words, " ");//first output
    }

    String[] words = split(data_1, " ");
    words = sort(words);
    data_1  = join(words, " ");
    //Filter#2 : removes duplicated words or character
    String[] data_2 = split(data_1, " ");
    Set<String> set = new HashSet<String>();
    Collections.addAll(set, data_2);
    String[] data_3 = set.toArray(new String[0]);

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
      list = subset(data_3, index, currentAmount);
    }
    return list;
  }
}