import peasy.*;

PeasyCam cam;

float threshold = 0.01;

String filename = "Factorio";

boolean display = false;
PImage input, output;
PVector[] points, centers;
color[] centerCols;
int[] pointAssocs, prevPointAssocs, pointsOwned;
int scale = 10;

void setup(){
  input = loadImage(filename + ".png");
  
  //cam = new PeasyCam(this, 500);
  
  //size(500, 500, P3D);
  size(800, 800);
  //colorMode(HSB);
  //frameRate(1);
  background(0);
  
  points = new PVector[input.pixels.length / scale];
  pointAssocs = new int[points.length];
  prevPointAssocs = new int[points.length];
  centers = new PVector[8];
  centerCols = new color[8];
  pointsOwned = new int[8];
  
  for(int i = 0; i < points.length; i++){
    points[i] = new PVector(red(input.pixels[i * scale]), green(input.pixels[i * scale]), blue(input.pixels[i * scale]));
  }
  
  for(int i = 0; i < centers.length; i++){
    float cx = random(255);
    float cy = random(255);
    float cz = random(255);
    centers[i] = new PVector(cx, cy, cz);
    centerCols[i] = color(cx, cy, cz);
  }
  
  println(points.length);
}

void draw(){
  background(0);
  if(display){
    for(int i = 0; i < points.length; i++){
      PVector c = centers[pointAssocs[i]];
      noStroke();
      fill(c.x, c.y, c.z);
      int x = i % (input.width / scale);
      int y = floor(i / (input.width));
      square(x * scale / 2, y * scale / 2, scale / 2);
    }
    /*for(int i = 0; i < centers.length; i++){
      noStroke();
      fill(centerCols[i]);
      //strokeWeight(pointsOwned[i] / 100);
      push();
      translate(centers[i].x, centers[i].y, centers[i].z);
      sphere(pointsOwned[i] / (points.length / 200));
      pop();
    }*/
  } else {
    for(int i = 0; i < points.length; i++){
      float minDist = width * height;
      color col = color(255, 255, 255);
      for(int j = 0; j < centers.length; j++){
        float currDist = dist(points[i].x, points[i].y, points[i].z, centers[j].x, centers[j].y, centers[j].z);
        color currCol = color(centerCols[j]);
        if(currDist < minDist){
          minDist = currDist;
          pointAssocs[i] = j;
          col = currCol;
        }
      }
      stroke(col);
      strokeWeight(3);
      point(points[i].x, points[i].y, points[i].z);
    }
    
    int totalChanged = 0;
    for(int i = 0; i < points.length; i++){
      if(pointAssocs[i] != prevPointAssocs[i]){
        totalChanged++;
      }
    }
    
    println(totalChanged);
    
    if(totalChanged <= (points.length * threshold) && frameCount > 2){
      for(PVector c : centers){
        println(c);
      }
      display = true;
      
      PGraphics pg = createGraphics(input.width, input.height);
      pg.beginDraw();
      for(int i = 0; i < points.length; i++){
        PVector c = centers[pointAssocs[i]];
        int x = i % (input.width / scale);
        int y = floor(i / (input.width));
        pg.noStroke();
        pg.fill(c.x, c.y, c.z);
        pg.square(x * scale, y * scale, scale);
      }
      pg.endDraw();
      pg.save(filename + " " + centers.length + " " + scale + ".png");
    } else {
      for(int i = 0; i < centers.length; i++){
        centerCols[i] = color(centers[i].x, centers[i].y, centers[i].z);
        
        stroke(centerCols[i]);
        strokeWeight(10);
        point(centers[i].x, centers[i].y, centers[i].z);
        
        PVector total = centers[i];
        int totalColPoints = 1;
        for(int j = 0; j < points.length; j++){
          if(pointAssocs[j] == i){
            total.add(points[j]);
            totalColPoints++;
          }
        }
        pointsOwned[i] = totalColPoints;
        total.div(totalColPoints);
        centers[i] = total;
        prevPointAssocs = pointAssocs.clone();
      }
    }
  }
}
