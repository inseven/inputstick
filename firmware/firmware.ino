#include <bluefruit.h>
#include <TinyUSB_Mouse_and_Keyboard.h>

BLEDfu bledfu;
BLEUart bleuart;

void setup() {

  pinMode(PIN_BUTTON1, INPUT_PULLUP);
  Keyboard.begin();
  
  Bluefruit.begin();
  Bluefruit.setTxPower(4);    // Check bluefruit.h for supported values
  bledfu.begin();  // To be consistent OTA DFU should be added first if it exists
  bleuart.begin();  // Configure and start the BLE Uart service
  startAdv();  // Set up and start advertising
};

void startAdv(void) {

  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  
  // Include the BLE UART (AKA 'NUS') 128-bit UUID
  Bluefruit.Advertising.addService(bleuart);

  // Secondary Scan Response packet (optional)
  // Since there is no room for 'Name' in Advertising packet
  Bluefruit.ScanResponse.addName();

  /* Start Advertising
   * - Enable auto advertising if disconnected
   * - Interval:  fast mode = 20 ms, slow mode = 152.5 ms
   * - Timeout for fast mode is 30 seconds
   * - Start(timeout) with timeout = 0 will advertise forever (until connected)
   * 
   * For recommended advertising interval
   * https://developer.apple.com/library/content/qa/qa1931/_index.html   
   */
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);                // 0 = Don't stop advertising after n seconds  
}

bool lastButtonState = false;
bool keyboardInputActive = true;


void loop() {

  // Read the button and only act on button release transitions (LOW -> HIGH).
  // TODO: Consider debouncing the button (see https://www.arduino.cc/en/Tutorial/BuiltInExamples/Debounce).
  int buttonState = digitalRead(PIN_BUTTON1);
  if (lastButtonState != buttonState) {
    lastButtonState = buttonState;
    if (buttonState == HIGH) {  // Key release.
      keyboardInputActive = !keyboardInputActive;
      if (keyboardInputActive) {
        ledOn(PIN_LED1);
        ledOn(PIN_LED2);
      } else {
        ledOff(PIN_LED1);
        ledOff(PIN_LED2);
      }
    }
  }

  if (bleuart.available()) {

    // Read a character and echo it.
    char c =  bleuart.read();
    bleuart.write(c);

    // Inject the key if enabled.
    if (keyboardInputActive) {
      Keyboard.press(c);
      Keyboard.release(c);
    }

  }

  // TODO: Is this really necessary?
  delay(10);
}
