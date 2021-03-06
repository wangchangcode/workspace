module(...,package.seeall)

require"common"
--[[
  ADS1115 四通道同时采集VDDIO输出电压，单位mV
  http://henrysbench.capnfatz.com/henrys-bench/arduino-voltage-measurements/arduino-ads1115-module-getting-started-tutorial/
  https://github.com/adafruit/Adafruit_ADS1X15/blob/master/Adafruit_ADS1015.cpp
]]
local i2cid = 2
---------------------------------------------------
--ADDR引脚接地
local ADS1115_ADDRESS               = 0x48;
---------------------------------------------------
-- CONVERSION DELAY = in mS;
local ADS1015_CONVERSIONDELAY       = 0x01;
local ADS1115_CONVERSIONDELAY       = 0x08;

---------------------------------------------------
-- POINTER REGISTER
local ADS1015_REG_POINTER_MASK        = 0x03;
local ADS1015_REG_POINTER_CONVERT     = 0x00;
local ADS1015_REG_POINTER_CONFIG      = 0x01;
local ADS1015_REG_POINTER_LOWTHRESH   = 0x02;
local ADS1015_REG_POINTER_HITHRESH    = 0x03;

---------------------------------------------------
-- CONFIG REGISTER
local ADS1015_REG_CONFIG_OS_MASK      = 0x8000;
local ADS1015_REG_CONFIG_OS_SINGLE    = 0x8000;  -- Write: Set to start a single-conversion
local ADS1015_REG_CONFIG_OS_BUSY      = 0x0000;  -- Read: Bit = 0 when conversion is in progress
local ADS1015_REG_CONFIG_OS_NOTBUSY   = 0x8000;  -- Read: Bit = 1 when device is not performing a conversion

local ADS1015_REG_CONFIG_MUX_MASK     = 0x7000;
local ADS1015_REG_CONFIG_MUX_DIFF_0_1 = 0x0000;  -- Differential P = AIN0, N = AIN1 = default;
local ADS1015_REG_CONFIG_MUX_DIFF_0_3 = 0x1000;  -- Differential P = AIN0, N = AIN3
local ADS1015_REG_CONFIG_MUX_DIFF_1_3 = 0x2000;  -- Differential P = AIN1, N = AIN3
local ADS1015_REG_CONFIG_MUX_DIFF_2_3 = 0x3000;  -- Differential P = AIN2, N = AIN3
local ADS1015_REG_CONFIG_MUX_SINGLE_0 = 0x4000;  -- Single-ended AIN0
local ADS1015_REG_CONFIG_MUX_SINGLE_1 = 0x5000;  -- Single-ended AIN1
local ADS1015_REG_CONFIG_MUX_SINGLE_2 = 0x6000;  -- Single-ended AIN2
local ADS1015_REG_CONFIG_MUX_SINGLE_3 = 0x7000;  -- Single-ended AIN3

local ADS1015_REG_CONFIG_PGA_MASK     = 0x0E00;
local ADS1015_REG_CONFIG_PGA_6_144V   = 0x0000;  -- +/-6.144V range = Gain 2/3
local ADS1015_REG_CONFIG_PGA_4_096V   = 0x0200;  -- +/-4.096V range = Gain 1
local ADS1015_REG_CONFIG_PGA_2_048V   = 0x0400;  -- +/-2.048V range = Gain 2 = default;
local ADS1015_REG_CONFIG_PGA_1_024V   = 0x0600;  -- +/-1.024V range = Gain 4
local ADS1015_REG_CONFIG_PGA_0_512V   = 0x0800;  -- +/-0.512V range = Gain 8
local ADS1015_REG_CONFIG_PGA_0_256V   = 0x0A00;  -- +/-0.256V range = Gain 16

local ADS1015_REG_CONFIG_MODE_MASK    = 0x0100;
local ADS1015_REG_CONFIG_MODE_CONTIN  = 0x0000;  -- Continuous conversion mode
local ADS1015_REG_CONFIG_MODE_SINGLE  = 0x0100;  -- Power-down single-shot mode = default;

local ADS1015_REG_CONFIG_DR_MASK      = 0x00E0;  
local ADS1015_REG_CONFIG_DR_128SPS    = 0x0000;  -- 128 samples per second
local ADS1015_REG_CONFIG_DR_250SPS    = 0x0020;  -- 250 samples per second
local ADS1015_REG_CONFIG_DR_490SPS    = 0x0040;  -- 490 samples per second
local ADS1015_REG_CONFIG_DR_920SPS    = 0x0060;  -- 920 samples per second
local ADS1015_REG_CONFIG_DR_1600SPS   = 0x0080;  -- 1600 samples per second = default;
local ADS1015_REG_CONFIG_DR_2400SPS   = 0x00A0;  -- 2400 samples per second
local ADS1015_REG_CONFIG_DR_3300SPS   = 0x00C0;  -- 3300 samples per second

local ADS1015_REG_CONFIG_CMODE_MASK   = 0x0010;
local ADS1015_REG_CONFIG_CMODE_TRAD   = 0x0000;  -- Traditional comparator with hysteresis = default;
local ADS1015_REG_CONFIG_CMODE_WINDOW = 0x0010;  -- Window comparator

local ADS1015_REG_CONFIG_CPOL_MASK    = 0x0008;
local ADS1015_REG_CONFIG_CPOL_ACTVLOW = 0x0000;  -- ALERT/RDY pin is low when active = default;
local ADS1015_REG_CONFIG_CPOL_ACTVHI  = 0x0008;  -- ALERT/RDY pin is high when active

local ADS1015_REG_CONFIG_CLAT_MASK    = 0x0004;  -- Determines if ALERT/RDY pin latches once asserted
local ADS1015_REG_CONFIG_CLAT_NONLAT  = 0x0000;  -- Non-latching comparator = default;
local ADS1015_REG_CONFIG_CLAT_LATCH   = 0x0004;  -- Latching comparator

local ADS1015_REG_CONFIG_CQUE_MASK    = 0x0003;
local ADS1015_REG_CONFIG_CQUE_1CONV   = 0x0000;  -- Assert ALERT/RDY after one conversions
local ADS1015_REG_CONFIG_CQUE_2CONV   = 0x0001;  -- Assert ALERT/RDY after two conversions
local ADS1015_REG_CONFIG_CQUE_4CONV   = 0x0002;  -- Assert ALERT/RDY after four conversions
local ADS1015_REG_CONFIG_CQUE_NONE    = 0x0003;  -- Disable the comparator and put ALERT/RDY in high state = default;

local function print(...) 
  _G.print("ADS1115",...)
end

--[[
  CPU is 320Mhz   1us will use 320 Instruction cycle
  we will use 6000 cycles to ensure its 10us passed
]]
local function delay10us()
  rtos.sleep(5)
  
--  local limit = 0
--  while limit < 6000 do
--  limit = limit + 1
--  end
end

local function readADCChannel(channel)
  if channel > 3 then return 0 end
    
  local cmd = {0xc3,0x84}
  if channel == 0 then
   cmd = {0xc3,0x84}
  elseif channel == 1 then
    cmd = {0xd3,0x84}
  elseif channel == 2 then
    cmd = {0xe3,0x84}
  elseif channel == 3 then
    cmd = {0xf3,0x84}
  end
  
  --写寄存器地址和数据
  --i2c.write(i2cid,ADS1015_REG_POINTER_LOWTHRESH,{0x7F,0xFF})  
  --i2c.write(i2cid,ADS1015_REG_POINTER_HITHRESH,{0x80,0x00})  

  local result= i2c.write(i2cid,ADS1015_REG_POINTER_CONFIG,cmd)
  print("write mode | result : ",common.binstohexs(cmd),result)
  if result ~= 2 then return 0xffff end
  
  --配置寄存器后，要等待2ms以后才可以去读数据，不然各通道电压值会乱码
  delay10us()

  result= i2c.read(i2cid,ADS1015_REG_POINTER_CONVERT,2)
  local _,voltage = pack.unpack(result or "0000",">h")  
   
  print("read voltage : ",channel, voltage)
  return voltage * 1247/ 10000
end


--[[
函数名：readchannels  相当于     init
功能  ：打开i2c，写初始化命令给从设备寄存器，并从从设备寄存器读取值
参数  ：无
返回值：无
说明  : 此函数演示setup、send和recv接口的使用方式
]]
function readchannels()
  local fre = i2c.setup(i2cid,i2c.SLOW,ADS1115_ADDRESS)
  if fre ~= i2c.SLOW then
    print("init fail !")
    return {0, 0, 0, 0}
  end
  
  local voltages = {0,0,0,0} 
  voltages[1] = readADCChannel(0)
  voltages[2] = readADCChannel(1)
  voltages[3] = readADCChannel(2)
  voltages[4] = readADCChannel(3)
  
  i2c.close(i2cid)
  print("voltage : ",voltages[1],voltages[2],voltages[3],voltages[4])
  return voltages
end

sys.timer_loop_start(readchannels,6000)
