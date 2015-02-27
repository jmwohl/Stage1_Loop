/**
 * Getting Started with Capture.
 * 
 * Reading and displaying an image from an attached Capture device. 
 */
import com.jonwohl.*;
import processing.video.*;
import gab.opencv.*;
import processing.serial.*;
import cc.arduino.*;

int displayW = 1024;
int displayH = 768;

int camW = 320;
int camH = 240;

PVector resizeRatio = new PVector(displayW / camW, displayH / camH);

Arduino arduino;
int buttonPin = 4;
int potPin = 0;

Capture cam;

OpenCV opencv;
PImage out, bw;
boolean addBall = false;
int countdown = 0;
int counter = 0;
Attention attention;
PImage src, dst;
boolean debug;
int fillColor = 0;

boolean buttonDown = false;

void setup() {
  size(displayW,displayH, P2D);
  frameRate(30);
//  String[] ards = Arduino.list();
//  println(ards);
  
  // for Mac
  // arduino = new Arduino(this, ards[ards.length - 1], 57600);
  
  // for Odroid
//  arduino = new Arduino(this, ards[0], 57600);
//  arduino.pinMode(4, Arduino.INPUT);
  
  // mac
  cam = new Capture(this, camW, camH);
    
  // odroid
//  cam = new Capture(this, camW, camH, "/dev/video0", 30);

  cam.start();
  
  // instantiate focus passing an initial input image
  attention = new Attention(this, cam);
  out = attention.focus(cam, cam.width, cam.height);
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  
  // show attention view on buttonpress
//  if (arduino.digitalRead(buttonPin) == Arduino.HIGH){
//    buttonDown = true; 
//  } else {
//    buttonDown = false;
//  }
  
  if (!buttonDown) {
    out = attention.focus(cam, cam.width, cam.height);
    out.filter(THRESHOLD, map(mouseY, 0, 786, 0, 1));
    image(out, 0, 0, width, height);
  } else {
    out = cam;
    image(out, 0, 0, width, height);
    drawAttention();
  }
  
//  out.filter(THRESHOLD, map(arduino.analogRead(0), 0, 1024, 0, 1));
//  out.filter(THRESHOLD, map(mouseY, 0, 786, 0, 1));
//  out.filter(BLUR, 1);

  if (debug){
//    showUI();
  }
}


void drawAttention() {
 
    int yOffset = 20;
  
    ArrayList<PVector> vertices = attention.getPoints();
    ArrayList<PVector> tVs = new ArrayList<PVector>();
    println(vertices);
    int size = vertices.size();

    // draw lines
    for (int i = 0; i < size; i++) {
      tVs.add(new PVector());
      tVs.get(i).set(vertices.get(i));
      tVs.get(i).x = tVs.get(i).x * resizeRatio.x;
      tVs.get(i).y = tVs.get(i).y * resizeRatio.y + yOffset;
    }
    
    // draw matte
    noStroke();  
    fill(0, 0, 0, 150);
    
    PShape s;
    s = createShape();
    s.beginShape();
    s.vertex(0, 0);
    s.vertex(displayW, 0);
    s.vertex(displayW, displayH);
    s.vertex(0, displayH);
    s.vertex(tVs.get(3).x, tVs.get(3).y);
    s.vertex(tVs.get(2).x, tVs.get(2).y);
    s.vertex(tVs.get(1).x, tVs.get(1).y);
    s.vertex(tVs.get(0).x, tVs.get(0).y);
    s.vertex(tVs.get(3).x, tVs.get(3).y);
    s.vertex(0, displayH);
    s.vertex(0, 0);
    s.endShape();
    shape(s, 0, 0);
    
    // draw lines
    stroke(0, 255, 0);
    strokeWeight(5);
    noFill();
    for (int i = 0; i < size; i++) {
      PVector a = tVs.get(i);
      PVector b;
      if (i < tVs.size() - 1) {
        b = tVs.get(i + 1);
      } else {
        b = tVs.get(0);
      }

      line(a.x, a.y, b.x, b.y);
    }
    // draw vertices
//    for (int i = 0; i < size; i++) {
//      vertices.get(i).draw();
//    }
  }

void keyPressed() {
  if (key == 'C' || key == 'c') {
    countdown = 60;
    addBall = true;
  } else if (key == 'D' || key == 'd'){
    debug = !debug;
  } else if (key == 'B' || key == 'b'){
    buttonDown = !buttonDown;
  }
}

void keyReleased() {
  if (key == 'B' || key == 'b'){
//    buttonDown = false;
  }
}
