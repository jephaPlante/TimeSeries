FloatTable data;
float dataMin, dataMax;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int rowCount;
int columnCount;
int currentColumn = 0;

int yearMin, yearMax;
int[] years;

int yearInterval = 2;
float volumeInterval = 1.0;
float volumeIntervalMinor = 0.2;

PFont plotFont; 


void setup() {
  size(720, 405);
  
  data = new FloatTable("price-of-chicken.tsv");
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();
  
  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length - 1];
  
  //println(data.getTableMin());
  dataMin = 0; //data.getTableMin();
  //dataMax = data.getTableMax();
  dataMax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;
  println(dataMax);

  // Corners of the plotted time series
  plotX1 = 120; 
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;
  
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);

  smooth();
}


void draw() {
  background(180,255,210);
  textSize(30);
  fill(100,140,220);
  textAlign(CENTER);
  text("Chicken Vs. Egg Price", 500, 40);
  // Show the plot area as a white box  
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);
  
  drawTitleTabs();
  drawAxisLabels(currentColumn);
  drawYearLabels();
  drawVolumeLabels();

  noStroke();
  fill(14,190,220);
  drawDataArea(currentColumn);   
  drawDataPoints(currentColumn); 
  drawDataHighlight(currentColumn);
}


void drawTitle() {
  fill(0);
  textSize(20);
  textAlign(LEFT);
  String title = data.getColumnName(currentColumn);
  text(title, plotX1, plotY1 - 10);
}


float[] tabLeft, tabRight;  // Add above setup()
float tabTop, tabBottom;
float tabPad = 10;

void drawTitleTabs() {
  rectMode(CORNERS);
  noStroke();
  textSize(20);
  textAlign(LEFT);

  // On first use of this method, allocate space for an array
  // to store the values for the left and right edges of the tabs
  if (tabLeft == null) {
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  
  float runningX = plotX1; 
  tabTop = plotY1 - textAscent() - 15;
  tabBottom = plotY1;
  
  for (int col = 0; col < columnCount; col++) {
    String title = data.getColumnName(col);
  
    tabLeft[col] = runningX; 
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    
    // If the current tab, set its background white, otherwise use pale gray
    fill(col == currentColumn ? 255 : 200,230,255);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    
    // If the current tab, use black for the text, otherwise use dark gray
    fill(col == currentColumn ? 0 : 64);
    text(title, runningX + tabPad, plotY1 - 10);
    
    runningX = tabRight[col];
  }
}

void drawDataPoints(int col) {
   stroke(12,100,190);
    strokeWeight(5);
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      point(x, y);
    }
  }
}

void mousePressed() {
  if (mouseY > tabTop && mouseY < tabBottom) {
    for (int col = 0; col < columnCount; col++) {
      if (mouseX > tabLeft[col] && mouseX < tabRight[col]) {
        setCurrent(col);
      }
    }
  }
}


void setCurrent(int col) {
  currentColumn = col;
}


void drawAxisLabels(int col) {
  fill(0);
  textSize(13);
  textLeading(15);
   String title = data.getColumnName(col);
    if (title.equals("Eggs")){
  
  textAlign(CENTER, CENTER);
  text("Price in\nconstant\ndollars\nby dozen", labelX, (plotY1+plotY2)/2);
  }
  else {
    textAlign(CENTER, CENTER);
    text("Price in\nconstant\ndollars\nper pound", labelX, (plotY1+plotY2)/2);
  }
  
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
}

void drawDataHighlight(int col) {//here is where i did the hover over functionality.
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      if (dist(mouseX, mouseY, x, y) < 3) {
        strokeWeight(10);
        stroke(13,180,13);
        point(x, y);
        fill(0);
        textSize(10);
        textAlign(CENTER);
        noFill();
        stroke(255,255,255,200);
        strokeWeight(20);
        rect(x-21, y-15, x+23, y-15);
        fill(0);
        text(nf(value, 0, 2) + " (" + years[row] + ")", x, y-10);
        textAlign(LEFT);
      }
    }
  }
}

void drawYearLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER);
  
  // Use thin, gray lines to draw the grid
  stroke(224);
  strokeWeight(1);
  
  for (int row = 0; row < rowCount; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + textAscent() + 10);
      line(x, plotY1, x, plotY2);
    }
  }
}


void drawVolumeLabels() { //This method took a lot of rigging to make functional.
  fill(0);                //It really didnt like the float points, it rounded them.
  textSize(10);
  textAlign(RIGHT);
  
  stroke(128);
  strokeWeight(1);
  float v = dataMin; 
//for (float v = dataMin; v <= dataMax; v += volumeIntervalMinor){
  while (v <= dataMax) {
    if (v==1.4000001){ //I was having a lot of trouble with the rounding and 
      v=1.4;             //had to go the hard way to fix it, only on two numbers.
    }
    if (v==1.8000001){
      v=1.8;
    }
    
    //println(v);
  //  float a = v / volumeIntervalMinor;
    if (floor(v / volumeIntervalMinor) == v / volumeIntervalMinor) {     // If a tick mark
    //println("minor tick" + dataMax);
      float y = map(v, dataMin, dataMax, plotY2, plotY1);  
     // float b = v / volumeInterval;
      if (floor(v / volumeInterval) == v / volumeInterval) {        // If a major tick mark
    //  println("major tick" + v);
        float textOffset = textAscent()/2;  // Center vertically
        if (v == dataMin) {
          textOffset = 0;                   // Align by the bottom
        } else if (v == dataMax) {
          textOffset = textAscent();        // Align by the top
        }
        text(floor(v), plotX1 - 10, y + textOffset);
        line(plotX1 - 4, y, plotX1, y);     // Draw major tick
      } else {
        line(plotX1 - 2, y, plotX1, y);     // Draw minor tick
      }
    }
   
     v = v+ volumeIntervalMinor;//increment by .2
  }
}

void drawDataLine(int col) {  
  beginShape();
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);      
      vertex(x, y);
    }
  }
  endShape();
}

void drawDataArea(int col) {
  beginShape();
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x, y);
    }
  }
  // Draw the lower-right and lower-left corners
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);
}


void keyPressed() {
  if (key == '[') {
    currentColumn--;
    if (currentColumn < 0) {
      currentColumn = columnCount - 1;
    }
  } else if (key == ']') {
    currentColumn++;
    if (currentColumn == columnCount) {
      currentColumn = 0;
    }
  }
}
