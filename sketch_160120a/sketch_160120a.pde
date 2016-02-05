import processing.serial.*;
Serial myPort;
String datastr;
PrintWriter output;
String tmptime;
String prevtime;
String endtime = "2016/01/26 10:00:00";
int count;
int tempX;
int tempY;
int humiX;
int humiY;
int infoX;
int infoY;
int plotWidth;
int plotHeight;
int blockHeight;
int marginX = 80;
int marginY;
float[][] temp;
float[][] humi;
float[] tmpData;
float[] sumData;
 
void setup()
{
  surface.setTitle("Temp/Humi Monitor");
  smooth(4);
  output = createWriter("tmphum"+ nf(year(),2) + nf(month(),2) + nf(day(),2) + "_" + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + ".csv");
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[11], 9600);
  myPort.clear();
  /* init val */
  size(800, 900);
  plotWidth = width - 2 * marginX;
  plotHeight = height/4; 
  blockHeight = height/3;
  marginY = (blockHeight - plotHeight)/2;
  tempX = 0;
  tempY = 0;
  humiX = 0;
  humiY = 1 * blockHeight;
  infoX = 0;
  infoY = 2 * blockHeight;
  temp = new float[2][plotWidth];
  humi = new float[2][plotWidth];
  tmpData = new float[2];
  sumData = new float[2];
  sumData[0] = 0.0;
  sumData[1] = 0.0;
  /**/
  tmptime = time();
  prevtime = tmptime;
  count = 0;
  for(int i=0; i < temp[0].length; i++){
    temp[0][i] = i; 
    humi[0][i] = i; 
    temp[1][i] = 0; 
    humi[1][i] = 0; 
  }
  PFont font = createFont("Ricty", 18, true);
  textFont(font);
}

void draw()
{
  tmptime = time();
  if (tmptime.equals(endtime) == true) {
    output.flush();
    output.close();
    exit();
  }else if(int(split(tmptime, ":")[1]) == int(split(prevtime, ":")[1])){
    if ( myPort.available() > 0) {
      count++;
      delay(100);
      String datastr = myPort.readString();
      tmpData = float(split(datastr, ','));
      String tempstr = String.format("% 4.2f,% 4.2f",tmpData[0],tmpData[1]);
      sumData[0] += tmpData[0];
      sumData[1] += tmpData[1];
      println(tmptime, prevtime, tempstr);
    }
  }else if(int(split(tmptime, ":")[1]) != int(split(prevtime, ":")[1])){
    output.println(prevtime + "," + sumData[0]/count + "," + sumData[1]/count);
    output.flush();
    prevtime = tmptime;
    sumData[0] = 0.0;
    sumData[1] = 0.0;
    count = 0;
  }else{
    output.println("time error." + tmptime + prevtime + endtime + count);
    output.flush();
    output.close();
    exit();
  }
  drawGraph();
}

void drawGraph(){
  background(100);
  
  for(int i=0; i < temp[1].length - 1; i++){
    temp[1][i] = temp[1][i+1]; 
    humi[1][i] = humi[1][i+1]; 
  }
  temp[1][temp[0].length - 1] = tmpData[0];
  humi[1][humi[0].length - 1] = tmpData[1];
  float tmpTempMax = tmpData[0] + 0.5;
  float tmpTempMin = tmpData[0] - 0.5;
  float tmpHumiMax = tmpData[1] + 0.5;
  float tmpHumiMin = tmpData[1] - 0.5;
  
  
  point(tempX, tempY);
  fill(0);
  text("Temperature", width/2 - textWidth("Temperature")/2, tempY + marginY - 2);
  text(nf(tmpTempMax,2,2), width - marginX + 3, tempY + marginY);
  text(nf(tmpTempMin,2,2), width - marginX + 3, tempY + blockHeight - marginY);
  fill(255,0,255);
  text(nf(tmpData[0],2,2) + char(unhex("00b0")) + "C", width - marginX + 3, tempY + (blockHeight)/2);
  pushMatrix(); 
  translate(tempX+marginX, tempY+blockHeight-marginY);
  scale(1, -1);
  fill(0); 
  stroke(255);
  rect(0, 0, plotWidth, plotHeight); 
  //line(0, 0, plotWidth, plotHeight);
  stroke(255, 0, 255);
  for(int i=0; i < temp[1].length; i++){
    if(tmpTempMin <= temp[1][i] && temp[1][i] <= tmpTempMax){
      point(temp[0][i], (temp[1][i] - tmpTempMin) * (plotHeight/(tmpTempMax - tmpTempMin))); 
    }
  }
  popMatrix();
     
  point(humiX, humiY);
  fill(0);
  text("Humidity", width/2 - textWidth("Humidity")/2, humiY + marginY -2);
  text(nf(tmpHumiMax,2,2), width - marginX + 3, humiY + marginY);
  text(nf(tmpHumiMin,2,2), width - marginX + 3, humiY + blockHeight - marginY);
  fill(0,255,255);
  text(nf(tmpData[1],2,2) + "%", width - marginX + 3, humiY + (blockHeight)/2);
  pushMatrix(); 
  translate(humiX+marginX, humiY+blockHeight-marginY);
  scale(1, -1);
  fill(0); 
  stroke(255);
  rect(0, 0, plotWidth, plotHeight); 
  //line(0, 0, plotWidth, plotHeight)
  stroke(0,255,255);
  //text(tmpData[1], plotWidth + 3, (tmpData[1] - tmpHumiMin) * (plotHeight/(tmpHumiMax - tmpHumiMin)));
  for(int i=0; i < humi[1].length; i++){
    if(tmpHumiMin <= humi[1][i] && humi[1][i] <= tmpHumiMax){
      point(humi[0][i], (humi[1][i] - tmpHumiMin) * (plotHeight/(tmpHumiMax - tmpHumiMin))); 
    }
  }
  popMatrix();
   
  pushMatrix();
  translate(infoX+marginX, infoY+marginY);
  fill(0);
  text("now : " + tmptime + "  prev : " + prevtime, 0, 0);
  text("end : " + endtime, 0, textAscent());
  text("count : " + count + "  Temperature average : " + nf(sumData[0]/count,2,2) + char(unhex("00b0")) + "C  Humidity average : " + nf(sumData[1]/count,2,2) + "%", 0, 3 * textAscent());
  popMatrix();
  point(0, 2 * blockHeight);
  point(0, 3 * blockHeight);
}

String time(){
 return nf(year(),2)+"/"+nf(month(),2)+"/"+nf(day(),2)+" "+nf(hour(),2) + ":" + nf(minute(),2) + ":" + nf(second(),2);
}