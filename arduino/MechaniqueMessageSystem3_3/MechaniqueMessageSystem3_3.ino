/*
  ---- SimpleMessageSystem Example 1 ----
  Control Arduino board functions with the following messages:

  r a -> read analog pins
  r d -> read digital pins
  w d [pin] [value] -> write digital pin
  w a [pin] [value] -> write analog pin

  Base: Thomas Ouellet Fredericks
  Additions: Alexandre Quessy

*/

// Include de SimpleMessageSystem library

#include <SimpleMessageSystem.h>
#include <Servo.h>
#include <Stepper.h>
#define STEPS 48
#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_MS_PWMServoDriver.h"

Adafruit_MotorShield AFMS = Adafruit_MotorShield(0x60);

Adafruit_StepperMotor *myMotor1 = AFMS.getStepper(48, 1);

Adafruit_StepperMotor *myMotor2 = AFMS.getStepper(48, 2);


int solenoid = 5;


void setup()
{

  //stepper.setSpeed(30);
  Serial.begin(115200); //Baud set at 38400 for low ErrorRate

  AFMStop.begin();  // create with the default frequency 1.6KHz
  AFMSbot.begin();
  //AFMS.begin(1000);  // OR with a different frequency, say 1KHz

  //DC Motorboard
  ////////////////
  // Set the speed to start, from 0 (off) to 255 (max speed)
  myMotor1->setSpeed(150);
  myMotor1->run(FORWARD);
  // turn on motor
  myMotor1->run(RELEASE);


  //Stepper Motorboard
  /////////////
  myMotor2->setSpeed(10);  // 10 rpm
  myMotor3->setSpeed(10);  // 10 rpm
  myMotor4->setSpeed(10);  // 10 rpm


  //Solenoid
  pinMode(solenoid, OUTPUT);


}

void loop()
{

  if (messageBuild() > 0) { // Checks to see if the message is complete and erases any previous messages
    switch (messageGetChar()) { // Gets the first word as a character
      case 'r': // Read pins (analog or digital)
        readpins(); // Call the readpins function
        break; // Break from the switch
      case 'w': // Write pin
        writepin(); // Call the writepin function
    }

  }

}

void readpins() { // Read pins (analog or digital)

  switch (messageGetChar()) { // Gets the next word as a character

    case 'd': // READ digital pins

      messageSendChar('d');  // Echo what is being read
      for (char i = 2; i < 14; i++) {
        messageSendInt(digitalRead(i)); // Read pins 2 to 13
      }
      messageEnd(); // Terminate the message being sent
      break; // Break from the switch

    case 'a': // READ analog pins

      messageSendChar('a');  // Echo what is being read
      for (char i = 0; i < 6; i++) {
        messageSendInt(analogRead(i)); // Read pins 0 to 5
      }
      messageEnd(); // Terminate the message being sent

  }

}

void writepin() { // Write pin

  int pin;
  int state;
  uint8_t i;


  switch (messageGetChar()) { // Gets the next word as a character

    case 'l' :

      pin = messageGetInt();  // Gets the next word as an integer
      state = messageGetInt();  // Gets the next word as an integer
      pinMode(pin, OUTPUT); //Sets the state of the pin to an output
      digitalWrite(pin, state); //Sets the state of the pin HIGH (1) or LOW (0)
      break;


    //write MotorshieldDC

    case 'd' :


      pin = messageGetInt();  // Gets the next word as an integer
      state = messageGetInt();

      myMotor1->setSpeed(255);
      myMotor1->run(FORWARD);
      // turn on motor
      myMotor1->run(RELEASE);
      //int low =

      myMotor1->run(FORWARD);
      for (i = 177; i < 181; i++) {
        myMotor1->setSpeed(i);
        delay(1);
      }
      delay(state);
      myMotor1->run(RELEASE);


      break;


    case 'c' :


      pin = messageGetInt();  // Gets the next word as an integer
      state = messageGetInt();

      myMotor1->setSpeed(255);
      myMotor1->run(FORWARD);
      // turn on motor
      myMotor1->run(RELEASE);

      myMotor1->run(BACKWARD);
      for (i = 177; i < 181; i++) {
        myMotor1->setSpeed(i);
        delay(0.99999);
      }
      delay(state);
      myMotor1->run(RELEASE);

      break;


    //write Solenoid

    case 'o' :

      pin = messageGetInt();  // Gets the next word as an integer
      state = messageGetInt();
      digitalWrite(solenoid, HIGH);
      delay(30);
      digitalWrite(solenoid, LOW);

      break;


    //write MotorshieldStepper

    case 's' :

      pin = messageGetInt();  // Gets the next word as an integer
      state = messageGetInt();
      myMotor2->setSpeed(pin);
      //myMotor2->step(2, FORWARD, DOUBLE);
      myMotor2->step(state, BACKWARD, DOUBLE);
      delay(10);
      myMotor2->release();

      break;

    case 't' :

      pin = messageGetInt();  // Gets the next word as an integer
      state = messageGetInt();
      myMotor3->setSpeed(state);
      //myMotor2->step(2, FORWARD, DOUBLE);
      myMotor3->step(3, BACKWARD, DOUBLE);
      myMotor3->release();


  }

}



/*



  Servo myservo;

  Stepper stepper(STEPS, 14, 15, 16, 17);


  case 'a' : // WRITE an analog pin

  pin = messageGetInt(); // Gets the next word as an integer
  state = messageGetInt(); // Gets the next word as an integer
  pinMode(pin, OUTPUT); //Sets the state of the pin to an output
  analogWrite(pin, state); //Sets the PWM of the pin
  break;  // Break from the switch


  // WRITE a digital pin
  case 'd' :

  pin = messageGetInt();  // Gets the next word as an integer
  state = messageGetInt();  // Gets the next word as an integer
  pinMode(pin,OUTPUT);  //Sets the state of the pin to an output
  digitalWrite(pin,state);  //Sets the state of the pin HIGH (1) or LOW (0)
  break;

  //Write servo pin
  case 's' :

  pin = messageGetInt();
  state = messageGetInt();
  myservo.attach(pin);
  myservo.write(state);
  delay(20);
  break;

  //write stepper pin
  case 't' :
  pin = messageGetInt();
  state = messageGetInt();
  stepper.setSpeed(state);
  stepper.step(-state);
  break;

*/









