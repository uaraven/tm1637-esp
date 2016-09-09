---
-- @description Driver for 4-digit 7-segment displays controlled by TM1637 chip
-- @date September 08, 2016
-- @author ovoronin
---
--------------------------------------------------------------------------------

local M = {}

local I2C_COMM1 = 0x40
local I2C_COMM2 = 0xC0
local I2C_COMM3 = 0x80

local cmd_power_on = 0x88
local cmd_power_off = 0x80

local pin_clk
local pin_dio
local brightness = 0x0f
local power = cmd_power_on

local alphabet = {
  [0] = 0x3F, 
  [1] = 0x06, 
  [2] = 0x5B, 
  [3] = 0x4F, 
  [4] = 0x66, 
  [5] = 0x6D, 
  [6] = 0x7D, 
  [7] = 0x07, 
  [8] = 0x7F, 
  [9] = 0x6F  
}
local digits = {0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F}
local _dot = 0x80
local _dash = 0x40

local function clk_high()
  gpio.write(pin_clk, gpio.HIGH)
end

local function clk_low()
  gpio.write(pin_clk, gpio.LOW)
end

local function dio_high()
  gpio.write(pin_dio, gpio.HIGH)
end

local function dio_low()
  gpio.write(pin_dio, gpio.LOW)
end


local function i2c_start()
  clk_high()
  dio_high()
  tmr.delay(2)
  dio_low()
end

local function i2c_ack ()
  clk_low()
  dio_high()
  tmr.delay(5)

  gpio.mode(pin_dio, gpio.INPUT)
  while ( gpio.read(pin_dio) == gpio.HIGH) do
  end
  gpio.mode(pin_dio, gpio.OUTPUT)

  clk_high()
  tmr.delay(2)
  clk_low()
end

local function i2c_stop()
  clk_low()
  tmr.delay(2)
  dio_low()
  tmr.delay(2)
  clk_high()
  tmr.delay(2)
  dio_high()
end

local function i2c_write(b)
  for i = 0, 7, 1
  do
    clk_low()
    if bit.band(b, 1) == 1 then
      dio_high()
    else
      dio_low()
    end
    tmr.delay(3)
    b = bit.rshift(b, 1)
    clk_high()
    tmr.delay(3)
  end
end

local function _clear()
 i2c_start()
    i2c_write(I2C_COMM2)
    i2c_ack()
    i2c_write(0)
    i2c_ack()
    i2c_write(0)
    i2c_ack();
    i2c_write(0)
    i2c_ack()
    i2c_write(0)
    i2c_ack()
  i2c_stop()
end

local function init_display()
    i2c_start()
    i2c_write(I2C_COMM1)
    i2c_ack()
    i2c_stop()
    _clear()
    i2c_write(cmd_power_on + brightness)
end

local function write_byte(b, pos)
    i2c_start()
    i2c_write(I2C_COMM2 + pos)
    i2c_ack()
    i2c_write(b)
    i2c_ack()
    i2c_stop()
end

function M.init(clk, dio)
    pin_clk = clk
    pin_dio = dio

    gpio.mode(pin_dio, gpio.OUTPUT)
    gpio.mode(pin_clk, gpio.OUTPUT)

    init_display()
end

function M.set_brightness(b)
  if b > 7 then b = 7 end
  brightness = bit.band(b, 7)

  i2c_start()
  i2c_write( power + brightness )
  i2c_ack()
  i2c_stop()
end

function M.write_string(str)
  local pos = 3
  local i = #str
  local dot
  while (i >= 1) do
    local s = str:sub(i,i)
    if s == '.' then 
      dot = true
      i = i - 1
      s = str:sub(i,i)
    else
      dot = false 
    end
    local digit = tonumber(s)
    local bt = digits[digit+1]
    if dot then bt = bt + _dot end
    write_byte(bt, pos)
    pos = pos - 1
    i = i - 1
  end
end

function M.clear()
  _clear()
end

return M
