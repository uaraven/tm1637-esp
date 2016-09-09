# tm1637-esp
Module for controlling 4 digit numerical display based on TM1637 driver for NodeMcu lua on ESP8266

# Usage
```lua
-- initialize display
tm1637 = require('tm1637')
tm1637.init(clk, dio)

-- output numbers. dot after number will turn dot on the display for that digit
tm1637.write_string('1234')
tm1637.write_string('12.34')
tm1637.write_string('1.2.3.4.')

-- brightness can be set to any value from 0 to 7, zero being the dimmest and 7 being the brightest
tm1637.set_brightness(7) 

-- clears the display
tm1637.clear()
```
