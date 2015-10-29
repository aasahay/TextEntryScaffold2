import java.util.Arrays;
import java.util.Collections;



String[] phrases; //contains all of the phrases
int totalTrialNum = 4; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
int userX;
int userY; // current mouse Y coordinate
final int DPIofYourDeviceScreen = 469; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
                                      //http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!

//Variables for my silly implementation. You can delete this:
char currentLetters = 'a';

// ----- Set up for grid drawing---------------

int cols = 7; // For 28 total keys, the alphabet plus space and delete
int rows = 4;

Key[][] grid;

// --------------------------------------------

// Key class for each key

class Key {
  // A key object knows about its location in the grid 
  // as well as its size with the variables x,y,w,h
  float x,y;   // x,y location
  float w,h;   // width and height
  char letter; // letter that the key has
  float lx,ly; // x,y of letter
  
  // Cell Constructor
  Key(float tempX, float tempY, float tempW, float tempH, char l) {
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
    letter = l;
    lx = tempX + (.5*tempW);
    ly = tempY + (.6*tempH);
  } 

  void display() {
    stroke(255);
    // Color calculated using sine wave
    fill(0);
    rect(x,y,w,h);
    //print("| x: " +x+ "y: " + y + "width: " + w + "height: " + h + " ");
    fill(255);
    text(letter, lx,ly); // draw letter in middle of square
  }
}



//You can modify anything in here. This is just a basic implementation.
void setup()
{
  userX = mouseX;
  userY = mouseY;
  println("UserX: " + userX + " and userY: " + userY);
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases
    
  orientation(PORTRAIT); //can also be LANDSCAPE -- sets orientation on android device
  size(1080, 1920); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 35)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
  
  // TODO: Initialize grid of keys, then: TODO: Draw keys on screen
  // NOTE: Will need to change hardcoded key size, etc for size of screen
  
  char inputLetter = 'a';
  grid = new Key[cols][rows];
  for (int j = 0; j < rows; j++) {
   for (int i = 0; i < cols; i++) {
     // Initialize each object parameters
     float x = 0;
     float y = 0;
     float w= 0;
     float h= 0;
    
     int charIndex = j*7+i;
     if (charIndex < 26) {// 0-25 for alphabet characters.  Input letter initialized to a, so increase only from first to last
       x = i*float(1)/7*sizeOfInputArea+200;
       y = (j+1)*float(1)/5*sizeOfInputArea+200; // (j+1) to leave room for char input space
       w = float(1)/7*sizeOfInputArea;
       h = float(1)/5*sizeOfInputArea;
       if (charIndex >= 1)
        inputLetter++;
     }
     else if (charIndex == 26) {// If 25, then alphabet is done.  Draw space in bottom right corner
       inputLetter = '_';
       x = 5*float(1)/7*sizeOfInputArea+200; // Hard code to bottom right
       y = 4*float(1)/5*sizeOfInputArea+200; // Hard code to bottom right
       w = float(2)/7*sizeOfInputArea;
       h = float(1)/5*sizeOfInputArea;
     }
     else if (charIndex == 27) {// If 26, 
       inputLetter = '<';
       x = 6*float(1)/7*sizeOfInputArea+200; // Hard code to top right
       y = 200; // Hard code to top right
       w = float(1)/7*sizeOfInputArea;
       h = float(1)/5*sizeOfInputArea;
     }
     //print(float(1)/7 * 5);
     println("x: " +x+ "y: " + y + "width: " + w + "height: " + h + "letter: " + inputLetter);

     // Initialize the Key object
     grid[i][j] = new Key(x,y,w,h, inputLetter);  //  // TODO: ADD IN RIGHT LETTER
     
     
     
   }
  }
}

// Retrieves the letter of the currently moused-over cell
// Assumes that key is currently over alphabet keys
char getCurrentMousedOverLetter(int x, int y) {
  float keyWidth = sizeOfInputArea/7;
  float keyHeight = sizeOfInputArea/5;
  
  // ------ Short circuit for mouse over space and delete ------
  // Check for space
  
  
  //println("X in area for delete: " + (x > float(6)/7*sizeOfInputArea+200 & x < 200 + sizeOfInputArea));
  //println("Y in area for delete: " + (y > 200 & y < 200 + float(1)/5 * sizeOfInputArea));
  if (x > float(6)/7*sizeOfInputArea+200 & y < 200 + float(1)/5 * sizeOfInputArea) { // Bound by |__
    //println("X in area for delete: " + (x > float(6)/7*sizeOfInputArea+200 & x < 200 + sizeOfInputArea));
    if (y > 200 & x < 200 + sizeOfInputArea) { // Bound on top and right side
      return '<';
    }
  // Check for delete
  } else if (x > float(5)/7*sizeOfInputArea+200 & y > float(4)/5*sizeOfInputArea+200) {
    if (x < 200 + sizeOfInputArea & y < 200 + sizeOfInputArea) {
      //println("Recognizing space key");
      return '_';
    }
  }
  
  if (y < 200 + sizeOfInputArea/5) {
    return currentLetters;
  } else {
    // ------ If mouse is over any alphabet key ------
  
    int i = 0; // For cols
    int j = 0; // For rows
    
    // Get column index
    while (x - 200 - i * keyWidth > keyWidth) {
      i++;
    }
    
    // Get row index
    while (y - 200 - (j+1) * keyHeight > keyHeight) {
      j++;
    }
    
    // Set alphabet key
    Key userKey = grid[i][j];
    return userKey.letter;
  }
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(0); //clear background
  
 // image(watch,-200,200);
  fill(100);
  rect(200, 200, sizeOfInputArea, sizeOfInputArea); //input area should be 2" by 2"

  if (finishTime!=0) // Note: for end of exercise
  {
    fill(255);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(255);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped, 70, 140); //draw what the user has entered thus far 
    fill(255, 0, 0);
    rect(800, 00, 200, 200); //drag next button
    fill(255);
    text("NEXT > ", 850, 100); //draw next label


    // Harrison draw code
    textAlign(CENTER);
    text("" + currentLetters, 200+sizeOfInputArea/2, 200+sizeOfInputArea/10); // Draw current letter.  Given new dimensions of grid, this must be spaced 1/2 * 1/5 * sizeOf... to display above keyboard
    //fill(255, 0, 0);
    //rect(200, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
    //fill(0, 255, 0);
    //rect(200+sizeOfInputArea/2, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    
    // New draw code for alphabet grid // TODO: FIX SCAFFOLD CODE TO CHANGE SIZE OF TEXT DISPLAY AND GET RID OF CYCLE BUTTONS
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        // Oscillate and display each object
        grid[i][j].display();
      }
    }
    
    // set the currentLetters if user mouse is in designated area
    if (mouseX > 200 & mouseX < 200 + sizeOfInputArea)
    {
      if (mouseY > 200 & mouseY < 200 + sizeOfInputArea) // In drawing space
        currentLetters = getCurrentMousedOverLetter(mouseX,mouseY);
    }
  }
  
}  

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

boolean didMouseRelease(float x, float y, float w, float h) // same as above, but with better name for our purposes
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

void mousePressed()
{
  //You are allowed to have a next button outside the 2" area
  if (didMouseClick(800, 00, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

// Only want changes to currentLetters and currentTyped to happen upon "release" (i.e. when user takes finger off of screen)
void mouseReleased() {
  println("X: " + mouseX + ", Y: " + mouseY);
  if (didMouseRelease(200, 200, sizeOfInputArea, sizeOfInputArea)) //check if click occured in letter area
  {
    currentLetters = getCurrentMousedOverLetter(mouseX,mouseY);
    if (currentLetters=='_') //if underscore, consider that a space bar
      currentTyped+=" ";
    else if (currentLetters=='<' & currentTyped.length()>0) //if <, treat that as a delete command
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    else if (currentLetters!='<') //if not any of the above cases, add the current letter to the typed string
      currentTyped+=currentLetters;
  }
}

void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

    if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.length();
    lettersEnteredTotal+=currentTyped.length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output
    System.out.println("WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f)); //output
    System.out.println("==================");
    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  }
  else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

void updateUserMouse() // YOU CAN EDIT THIS
{
  // you can do whatever you want to userX and userY (you shouldn't touch mouseX and mouseY)
  userX += mouseX - pmouseX; //add to userX the difference between the current mouseX and the previous mouseX
  userY += mouseY - pmouseY; //add to userY the difference between the current mouseY and the previous mouseY
}

void mouseMoved() // Don't edit this
{
  updateUserMouse();
}

void mouseDragged() // Don't edit this
{
  updateUserMouse();
} 


//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}