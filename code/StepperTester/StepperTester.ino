/*
  This is a test sketch for the Adafruit assembled Motor Shield for Arduino v2
  It won't work with v1.x motor shields! Only for the v2's with built in PWM
  control

  For use with the Adafruit Motor Shield v2
  ---->	http://www.adafruit.com/products/1438
*/


#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_MS_PWMServoDriver.h"

// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS = Adafruit_MotorShield();
// Or, create it with a different I2C address (say for stacking)
// Adafruit_MotorShield AFMS = Adafruit_MotorShield(0x61);

// Connect a stepper motor with 200 steps per revolution (1.8 degree)
// to motor port #2 (M3 and M4)
Adafruit_StepperMotor *myMotor = AFMS.getStepper(48, 1);
Adafruit_StepperMotor *myMotor2 = AFMS.getStepper(96, 2);


void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("Stepper test!");

  AFMS.begin();  // create with the default frequency 1.6KHz
  //AFMS.begin(1000);  // OR with a different frequency, say 1KHz

  myMotor->setSpeed(10);  // 10 rpm
  myMotor2->setSpeed(10);
}

void loop() {
  Serial.println("Single coil steps");
  myMotor->step(200, FORWARD, SINGLE);
  myMotor->release();
  myMotor2->step(200, FORWARD, SINGLE);
  myMotor2->release();
  myMotor->step(200, BACKWARD, SINGLE);
  myMotor->release();
  myMotor2->step(200, BACKWARD, SINGLE);
  myMotor2->release();
  delay(1000);

  Serial.println("Double coil steps");
  myMotor->step(200, FORWARD, DOUBLE);
  myMotor->release();
  myMotor2->step(200, FORWARD, DOUBLE);
  myMotor2->release();
  myMotor->step(200, BACKWARD, DOUBLE);
  myMotor->release();
  myMotor2->step(200, BACKWARD, DOUBLE);
  myMotor2->release();
  delay(1000);

  Serial.println("Interleave coil steps");
  myMotor->step(200, FORWARD, INTERLEAVE);
  myMotor->release();
  myMotor2->step(200, FORWARD, INTERLEAVE);
  myMotor2->release();
  myMotor->step(200, BACKWARD, INTERLEAVE);
  myMotor->release();
  myMotor2->step(200, BACKWARD, INTERLEAVE);
  myMotor2->release();
  delay(1000);

  Serial.println("Microstep steps");
  myMotor->step(100, FORWARD, MICROSTEP);
  myMotor->release();
  myMotor2->step(100, FORWARD, MICROSTEP);
  myMotor2->release();
  myMotor->step(100, BACKWARD, MICROSTEP);
  myMotor->release();
  myMotor2->step(100, BACKWARD, MICROSTEP);
  myMotor2->release();
  delay(1000);
}
