#include <Adafruit_GFX.h> // Hardware-specific library
#include <mcufriend_blue_pill.h>
mcufriend_blue_pill tft;

void setup()
{
    // put your setup code here, to run once:
    Serial.begin(9600);
    tft.reset();
    uint16_t identifier = tft.readID();
    Serial.print("ID = 0x");
    Serial.println(identifier, HEX);

    if (identifier == 0xEFEF) identifier = 0x9486;
    if (identifier == 0xD3D3) identifier = 0x9481; // write-only shield
    if (identifier == 0x0101) identifier = 0x1581; // write-only shield
    if (identifier == 0x2121) identifier = 0x1581; // write-only shield

    tft.begin(identifier);
    //  tft.fillScreen(BLACK);
}

char *msg[] = { "PORTRAIT", "LANDSCAPE", "PORTRAIT_REV", "LANDSCAPE_REV" };
uint8_t aspect;

void loop()
{
    // put your main code here, to run repeatedly:
    uint16_t x = 50, y = 100;
    tft.setRotation(aspect);
    tft.fillScreen(0x0000);
    tft.setCursor(0, 0);
    tft.setTextSize(2);
    tft.println(msg[aspect]);
    tft.setCursor(x, y);
    tft.println("[x=" + String(x) + ",y=" + String(y) + "]");
    delay(5000);
    tft.println("INVERT ON");
    tft.invertDisplay(true);
    delay(1000);
    tft.invertDisplay(false);
    tft.println("INVERT OFF");
    delay(1000);
    if (++aspect >= 4) aspect = 0;
}
