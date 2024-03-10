#ifndef __ommeter4_H
#define __ommeter4_H
// --
#define LCD_RD PB5
#define LCD_WR PB6
#define LCD_CD PB7
#define LCD_CS PB8
#define LCD_RESET PB9
// --
#define RD_PIN 5
#define WR_PIN 6
#define CD_PIN 7
#define CS_PIN 8
#define RESET_PIN 9
// --
#define BLACK 0x0000
#define BLUE 0x001F
#define RED 0xF800
#define GREEN 0x07E0
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define YELLOW 0xFFE0
#define WHITE 0xFFFF
// --
#ifndef min
#define min(a, b) (((a) < (b)) ? (a) : (b))
#endif
// --
#endif /* __ommeter4_H */

