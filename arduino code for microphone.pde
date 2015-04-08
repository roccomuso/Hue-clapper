/*
* Clapper project
* Author: Manoj Kunthu
* Update: 2/2/13
*/

/*-----------------------------
*   Method Prototypes
*-----------------------------*/

void initialize();
void runDetector();
boolean clapDetected();

int detectClaps(int numClaps);
void indicateClaps();
void readMic();

void printStats();

/*-----------------------------
*   Variable Declarations
*-----------------------------*/

int TOTAL_CLAPS_TO_DETECT = 2; //The number of claps detected before output is toggled
int offset = 20;    // The point above average that the clap is detected
int CLAP_TIME=4000; // The time allowed between each clap


int sensorValue = 0; //the value read through mic 

int toggleOutput = -1;

int SIZE = 3;
int buffer[3];
int loopIteration = 0;
int average = 0;
int total = 0;



//BOARD INPUT MIC
const int inPin0 = A0; 

//BOARD OUTPUT SIGNALS
const int clapLed1 = 12, clapLed2 = 11, out = 10, readyPin = 13;

//CLAP STATE CONSTANTS
const int FINAL_DETECTED = 0, LOST_CONTINUITY = 1, CLAP_NOT_DETECTED = 2;

void setup() {
  Serial.begin(9600);
  
  //direct representation of the light bulb that toggles on/off  
  pinMode(out, OUTPUT);
  
  //once initialize() runs the ready pin turns on
  pinMode(readyPin, OUTPUT);
  
  //respective clap LEDs, more can be added
  pinMode(clapLed1, OUTPUT);
  pinMode(clapLed2, OUTPUT);
}


void loop() {
  initialize();
  runDetector();
}

/**
* Purpose: Prepares the buffer to recognize ambient noise levels in room.
*/
void initialize()
{
  loopIteration = 0; 
  total = 0;
  average =0;
  
  digitalWrite(clapLed1, LOW);
  digitalWrite(clapLed2, LOW);
  digitalWrite(out, LOW);
  
  for(int i = 0; i < SIZE; i++)
  {
    readMic();
    
    buffer[i] = sensorValue;
    total = total + sensorValue;
    average = (total/(i+1));
    
    Serial.print("INIT - AVE: ");
    Serial.print(average);
    Serial.print("    Total: ");
    Serial.print(total); 
    Serial.print("    Sensor: ");
    Serial.print(sensorValue); 
    Serial.print("    Change: ");
    Serial.println(sensorValue-average); 
      
    delay(50);
  }
  digitalWrite(readyPin, HIGH);
}

/**
* Purpose: Runs the detector algorithm. Developers can change the number of claps by adjusting TOTAL_CLAPS_TO_DETECT variable up at the top.
*/
void runDetector()
{
  while(true)
  {
    int clapState = detectClaps(TOTAL_CLAPS_TO_DETECT);
    
    if(clapState == FINAL_DETECTED || clapState == LOST_CONTINUITY)
    {
       Serial.println("--done--");
       indicateClap(0);//turn off any clap indicating lights
    }
  }
}

/**
* Purpose:  Detects the number of claps specified. This method is recursive
*/
int detectClaps(int numClaps)
{
  int clapNum = numClaps;
  
  //Base Case - if clapNum is 0, then all claps have been accounted.
  if(clapNum == 0)
  {
    //the output can now be toggled.
    toggleOutput *= -1;
    indicateClap(clapNum);
    
    Serial.println("-----  Clap Limit Reached - Output Toggled -----");
    Serial.println("OK");
    
    return FINAL_DETECTED;
  }
  
  //Read from mic and update ambient noise levels.
  readMic();

  total = (total - buffer[loopIteration]) + sensorValue; 
  average = (total/SIZE);
  buffer[loopIteration] = sensorValue;
  
  loopIteration = (loopIteration+1)%SIZE;
  
  if(clapDetected())
  { 
    Serial.print("detectClaps - Claps:");
    Serial.println(TOTAL_CLAPS_TO_DETECT + 1 - numClaps); 
    
    printStats();
    indicateClap(clapNum);
    
    delay(100);
    for(int i = 0; i < CLAP_TIME; i++)
    {
      int clapState = detectClaps(clapNum - 1);   
      
      if(clapState == FINAL_DETECTED || clapState == LOST_CONTINUITY)
      {
         return clapState;
      }
    }
    return LOST_CONTINUITY;
  }
  return CLAP_NOT_DETECTED;
}

/**
* Purpose: Turns the LED on appropriately to signal a clap detection.
*/
void indicateClap(int clapNum)
{
  if(clapNum == 0)
  {
    if(toggleOutput == 1)
    {
      digitalWrite(out, HIGH);
    }
    else
    {
      digitalWrite(out, LOW);
    }
    digitalWrite(clapLed1, LOW);
    digitalWrite(clapLed2, LOW);
  }
  else if(clapNum == 1)
  {
     digitalWrite(clapLed1, HIGH);
  }
  else if(clapNum == 2)
  {
     digitalWrite(clapLed2, HIGH);
  }
  delay(110);
}

/**
* Purpose: Prints basic statistics data for more info with sensor readouts and data points.
*/
void printStats()
{
  Serial.print("--- AVE: ");
  Serial.print(average);
  Serial.print("    Total: ");
  Serial.print(total); 
  //Serial.print("    iterNum: ");
  //Serial.print(loopIteration); 
  Serial.print("    Sensor: ");
  Serial.print(sensorValue); 
  Serial.print("    Change: ");
  Serial.println(sensorValue-average); //This is what I used to determine the 'offset' value
}

/**
* Purpose:  A clap is detected when the sensor value is greater than the average plus 
*     an offset.  The offset might need to be fine tuned for different sound sensors.
*/
boolean clapDetected()
{
    return sensorValue > average + offset;
}

/**
* Purpose: Reads mic input and stores it in a global variable.
*/
void readMic()
{
  sensorValue = analogRead(inPin0);  
}
