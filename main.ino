#include "HX711.h"

HX711 scale;

uint8_t dataPin = 6;
uint8_t clockPin = 7;

uint32_t start, stop;
volatile float f;

void setup() {
    Serial.begin(115200);

    scale.begin(dataPin, clockPin);
}

void loop() {
    
}