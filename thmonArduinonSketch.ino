#include <LiquidCrystal.h>
#include <Wire.h>
 
#define HDC1000_ADDRESS 0x40 /* or 0b1000000 */
#define HDC1000_RDY_PIN A3   /* Data Ready Pin */
#define HDC1000_TEMPERATURE_POINTER     0x00
#define HDC1000_HUMIDITY_POINTER        0x01
#define HDC1000_CONFIGURATION_POINTER   0x02
#define HDC1000_SERIAL_ID1_POINTER      0xfb
#define HDC1000_SERIAL_ID2_POINTER      0xfc
#define HDC1000_SERIAL_ID3_POINTER      0xfd
#define HDC1000_MANUFACTURER_ID_POINTER 0xfe
#define HDC1000_CONFIGURE_MSB 0x10 /* Get both temperature and humidity */
#define HDC1000_CONFIGURE_LSB 0x00 /* 14 bit resolution */

LiquidCrystal LCD = LiquidCrystal(12, 11, 10, 5, 4, 3, 2);  // 配線 
 
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Wire.begin();
  /* HDC init */
  pinMode(HDC1000_RDY_PIN, INPUT);
  delay(15); /* Wait for 15ms */
  configure();
  /* LCD init */
  LCD.begin(16, 2);           /* LCDの設定(16文字2行) */
  LCD.clear();                /* LCDのクリア */
  LCD.setCursor(0, 0);        /* 0列0行から表示する */
  LCD.print("Hardware setup."); /* 文字列の表示 */
  delay(1000);
  LCD.clear();                /* LCDのクリア */
  /* Serial init*/
  //Serial.print("Manufacturer ID = 0x");
  //Serial.println(getManufacturerId(), HEX);
  //Serial.println();
}
 
void loop() {
  // put your main code here, to run repeatedly:
  float temperature, humidity;
 
  getTemperatureAndHumidity(&temperature, &humidity);
  Serial.print(temperature);
  Serial.print(",");
  Serial.println(humidity);
  //Serial.println("");

  LCDprint(temperature, humidity);
 
  delay(1000);
}

void LCDprint(float tmp, float hum){
  LCD.clear();                /* LCDのクリア */
  LCD.setCursor(0, 0);        /* 0列0行から表示する */
  LCD.print("Temp:"); /* 文字列の表示 */
  LCD.print(tmp); /* 文字列の表示 */
  LCD.print((char)223); /* 文字列の表示 */
  LCD.print("C"); /* 文字列の表示 */
  LCD.setCursor(0, 1);        /* 0列0行から表示する */
  LCD.print("Humi:"); /* 文字列の表示 */
  LCD.print(hum); /* 文字列の表示 */
  LCD.print("%"); /* 文字列の表示 */
}
 
void configure() {
  Wire.beginTransmission(HDC1000_ADDRESS);
  Wire.write(HDC1000_CONFIGURATION_POINTER);
  Wire.write(HDC1000_CONFIGURE_MSB);
  Wire.write(HDC1000_CONFIGURE_LSB);
  Wire.endTransmission();
}
 
int getManufacturerId() {
  int manufacturerId;
 
  Wire.beginTransmission(HDC1000_ADDRESS);
  Wire.write(HDC1000_MANUFACTURER_ID_POINTER);
  Wire.endTransmission();
 
  Wire.requestFrom(HDC1000_ADDRESS, 2);
  while (Wire.available() < 2) {
    ;
  }
 
  manufacturerId = Wire.read() << 8;
  manufacturerId |= Wire.read();
 
  return manufacturerId;
}
 
void getTemperatureAndHumidity(float *temperature, float *humidity) {
  unsigned int tData, hData;
 
  Wire.beginTransmission(HDC1000_ADDRESS);
  Wire.write(HDC1000_TEMPERATURE_POINTER);
  Wire.endTransmission();
 
  while (digitalRead(HDC1000_RDY_PIN) == HIGH) {
    ;
  }
 
  Wire.requestFrom(HDC1000_ADDRESS, 4);
  while (Wire.available() < 4) {
    ;
  }
 
  tData = Wire.read() << 8;
  tData |= Wire.read();
 
  hData = Wire.read() << 8;
  hData |= Wire.read();
 
  *temperature = tData / 65536.0 * 165.0 - 40.0;
  *humidity = hData / 65536.0 * 100.0;
}
