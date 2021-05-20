
```h
## Connections

BlueVGA uses pins: 
  * **PA9** as Horizontal Sync VGA signal
  * **PB6** as Vertical Sync VGA signal
  * **PB13** for Blue VGA signal
  * **PB14** for Green VGA signal
  * **PB15** for Red VGA signal
  * **G** (BluePill ground) must be connected to GND pin of VGA
```

https://github.com/RoCorbera/BlueVGA/issues/4

```c
file:
bluevgadriver.c
func:

void video_init(uint8_t flashFont)


For using GPIO B:

const uint8_t *GPIO __attribute__((aligned(32))) = (uint8_t*)(&(GPIOB_REG)->ODR);

Line 213 to 215 :: activate pin 13, 14, 15 on GPIOA or GPIOB instead of GPIOC:
For using GPIO A:

  GPIOA_REG->CRH = (GPIOA_REG->CRH & 0x000FFF0F) | 0x333000B0;
  GPIOB_REG->CRL = (GPIOB_REG->CRL & 0xF0FFFFFF) | 0x0B000000;
  //GPIOC_REG->CRH = 0x33333333;

For using GPIO B:

  GPIOA_REG->CRH = (GPIOA_REG->CRH & 0xFFFFFF0F) | 0x000000B0;
  GPIOB_REG->CRL = (GPIOB_REG->CRL & 0xF0FFFFFF) | 0x0B000000;
  GPIOB_REG->CRH = (GPIOB_REG->CRH & 0x000FFFFF) | 0x33300000;
  
```
