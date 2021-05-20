// --
#include <SPI.h>
#include "Adafruit_GFX.h"
#include <MCUFRIEND_kbv.h>
#include "ommeter3.h"
// --
MCUFRIEND_kbv tft;
// --

#define LED PC13
#define MOSFET PC12

#define INPUT_SENSOR1 PA8
#define INPUT_SENSOR2 PA9

#define RESISTANCE_MIN 1.0
#define RESISTANCE_MAX 55

float adc_sensor_1;
float adc_sensor_2;

float U_power = 14.0; // power voltage
float electric_current;
float resistance;
float shunt = 0.005;
float correction = -0.30;
// --
#define R1 330.0 // resistor feedback to ground
#define R2 22000.0 // resistor feedback
#define DELTA_GAIN1 0.86 // calibration of an error

#define R3 1.0 // resistor feedback to ground
#define R4 1.0 // resistor feedback
#define DELTA_GAIN2 1.0 // calibration of an error

#define GRIDSPACE 48

float gain_amplifier1 = R1 / R2 * DELTA_GAIN1; // mcp-601 4k3/100k = 0.043, for test
float gain_amplifier2 = R3 / R4 * DELTA_GAIN2; // mcp-601 4k3/100k = 0.043, for test
uint32_t pause = 50;
// --
void setup(void);
void loop(void);
void measure1(void);
void measure2(void);
void tft_show1(void);
void tft_show2(void);
void write_grid(void);

void delay_us(uint32_t volatile us)
{
  if(!us) return;
  us *=(SystemCoreClock/1000000)/5;
  while(us--);
}

/*
  begn seting
*/
void setup(void)
{
  pinMode(LED, OUTPUT);
  pinMode(MOSFET, OUTPUT);
  pinMode(INPUT_SENSOR1, INPUT_ANALOG); // set up pin for analog input
  // http://docs.leaflabs.com/static.leaflabs.com/pub/leaflabs/maple-docs/latest/lang/api/analogread.html
  pinMode(INPUT_SENSOR2, INPUT_ANALOG); // set up pin for analog input
  // --
  Serial.begin(9600);
  // Serial.println("Serial took " + String((millis() - when)) + "ms to start");
  uint16_t ID = tft.readID(); // Serial.print("ID = 0x");
  Serial.println(ID, HEX);

  if (ID == 0xEFEF) ID = 0x9486; // write-only shield
  if (ID == 0xD3D3) ID = 0x9481; // write-only shield
  if (ID == 0x0101) ID = 0x1581; // write-only shield
  if (ID == 0x2121) ID = 0x1581; // write-only shield

  // --
  tft.begin(ID); // initialize tft;
  tft.setRotation(0); // orientation
  tft.fillScreen(BLACK); // clear display
  // --
  tft.setTextColor(YELLOW, BLACK); // color yellow - backcolor black
  tft.setTextSize(3); // multiplier font size
  tft.setCursor(0, 30); // begin cursor positio x-y
  tft.print("tft 0x"); // show model tft display
  tft.println(ID, HEX); // show model tft display
  delay(500);
  tft.fillScreen(BLACK); // clear display
}

/*
  main loop
*/
void loop(void)
{
  delay(1);
  measure1();
  measure2();
  tft_show1();
  tft_show2();
}

/*
  measure function
*/
void measure1(void)
{
  digitalWrite(LED, HIGH);
  digitalWrite(MOSFET, HIGH);
  delay_us(5); // state
  // --
  float adcValue = 0;
  uint8_t adc_count = 128; // adc average
  uint32_t partAdcValue = 0;
  // --
  for (uint8_t i = 0; i < adc_count; i++)
  {
    partAdcValue += (float)analogRead(INPUT_SENSOR1);
  }
  adcValue = partAdcValue * (3.30 / 4095.0) / adc_count; // real adc value
  adc_sensor_1 = adcValue * gain_amplifier1; // adc value multiplicative on gain amplifier
  // --
  electric_current = adc_sensor_1 / shunt;
  resistance = U_power / electric_current + correction;
  // --
  // overload protection
  if ((resistance < RESISTANCE_MIN) || (resistance > RESISTANCE_MAX)) // minimal and maximal resistace gate
  {
    digitalWrite(LED, LOW);
    digitalWrite(MOSFET, LOW);
    delay_us(100000);
    // если отключился нагреватель, уменьшаем время нагрева, для плавного разогрева
    pause = 0;
    return;
  }
  // --
  if(pause>=30000) pause = 30000;
  delay_us(pause);
  pause += 50;
  // --
  digitalWrite(LED, LOW);
  digitalWrite(MOSFET, LOW);
  // --
  delay_us(50000);
  // --
}

void measure2(void)
{
  delay_us(1); //
  // --
  float adcValue = 0;
  uint8_t adc_count = 128; // adc average
  uint32_t partAdcValue = 0;
  for (uint8_t i = 0; i < adc_count; i++)
  {
    partAdcValue += (float)analogRead(INPUT_SENSOR2);
  }
  adcValue = partAdcValue * (3.30 / 4095.0) / adc_count; // real adc value
  adc_sensor_2 = adcValue * gain_amplifier2; // adc value multiplicative on gain amplifier
  // --
  delay_us(500);
  // --
}

/*
  display function
*/
void tft_show1(void)
{
  uint16_t X_pos = 64;
  uint16_t Y_pos = 32;

  tft.setRotation(1); // orientation
  write_grid();
  tft.setRotation(0); // orientation

  // --
  delay_us(100);
  tft.setTextColor(CYAN, BLACK);
  tft.setTextSize(3);
  tft.setCursor(X_pos, Y_pos);
  tft.println("Voltage");
  tft.setTextSize(3);
  tft.setCursor(X_pos, Y_pos += GRIDSPACE);
  // tft.println(adcValue1);
  tft.println(adc_sensor_1);
  tft.setTextColor(GREEN, BLACK);
  tft.setTextSize(3);
  tft.setCursor(X_pos, Y_pos += GRIDSPACE);
  tft.println("Current");
  tft.setTextSize(3);
  tft.setCursor(X_pos, Y_pos += GRIDSPACE);
  tft.println(electric_current); // print out the value you read:
  tft.setTextColor(MAGENTA, BLACK);
  tft.setTextSize(3);
  tft.setTextColor(RED, BLACK);
  tft.setCursor(X_pos, Y_pos += GRIDSPACE);
  // --
  if (resistance < RESISTANCE_MIN) // warning: range min
  {
    tft.println("R small "); // print out the value you read:
    // tft.fillScreen(BLACK);
  }
  // check max range RESISTANCE_MAX
  if (resistance > RESISTANCE_MAX) // warning: range max
  {
    tft.println("R big   "); // print out the value you read:
    // tft.fillScreen(BLACK);
  }
  // --
  if (resistance > RESISTANCE_MIN && resistance < RESISTANCE_MAX) // normal range
  {
    tft.setTextColor(GREEN, BLACK);
    tft.println("R norm  "); // print out the value you read:
  }
  tft.setTextSize(3);
  tft.setCursor(X_pos, Y_pos += GRIDSPACE);
  if (resistance < 10) // если менее 10 то выводим два числа после десятичной точки
  {
    tft.println(resistance, 2); // print out the value you read, arg 2, two digit after point
  }
  // --
  if ((resistance > 10) && (resistance < RESISTANCE_MAX)) // если больше 10 то выводим одно число после десятичной точки
  {
    tft.println(resistance, 1); // print out the value you read, arg 1, one digit after point
  }
  // --
  // char str[10];
  // sprintf(str,"%.2f",resistance);
  // tft.println(str); // print out the value you read:
}
// --

/*
  display function
*/
void tft_show2(void)
{
  uint16_t X_pos = 64;
  uint16_t Y_pos = 320;

  tft.setRotation(1); // orientation
  write_grid();
  tft.setRotation(0); // orientation
  tft.setTextSize(3);
  tft.setTextColor(YELLOW, BLACK);
  tft.setCursor(X_pos, Y_pos);
  tft.println("Sensor volt"); // print out the value you read:
  tft.setCursor(X_pos, Y_pos += GRIDSPACE);
  tft.setTextSize(3);
  tft.println(adc_sensor_2);
  delay_us(10);
}
// --

/*
   draw grid
   координатная сетка
*/
void write_grid(void)
{
  uint8_t grid_size = 2;
  uint8_t cell_size = GRIDSPACE;
  uint8_t cell_size_half = cell_size / 2;
  for (uint16_t x = cell_size_half; x < tft.height() - 11; x += grid_size)for (uint16_t i = 8; i < tft.width() - 7; i += cell_size)tft.drawPixel(i, x, CYAN); // draw vertical dot line
  for (uint16_t x = cell_size_half; x < tft.height() - 11; x += cell_size)for (uint16_t i = 16; i < tft.width() - 15; i += grid_size)tft.drawPixel(i, x, WHITE); // draw horizontal dot line
}
// --
