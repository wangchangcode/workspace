module(...,package.seeall)

--require"pm"
require"led"

-- AT command supportted
-- example    串口uart1收到"AT=FLIP"，执行led()程序
--------------------------------------------------------------------------------
local LOAD_CONFIG                    = "LOADCONFIG";
local UPDATE_CONFIG                  = "UPDATECONFIG";
local QUERY_STATUS                   = "QUERYSTATUS";
local MAKE_REPORT                    = "MAKEREPORT";
local DEVICE_POLL                    = "DEVICEPOLL"
local DEVICE_REBOOT                  = "DEVICEREBOOT";
--------------------------------------------------------------------------------

local function print(...)
  _G.print("uartdemo",...)
end

--------------------------------------------------------------------------------
--串口ID,1对应uart1
--如果要修改为uart2，把UART_ID赋值为2即可
local UART_ID = 1
--帧头类型以及帧尾
--local CMD_SCANNER,CMD_GPIO,CMD_PORT,FRM_TAIL = 1,2,3,string.char(0xC0)
--串口读到的数据缓冲区
local rdbuf = ""

--[[
函数名：parse
功能  ：按照帧结构解析处理一条完整的帧数据
参数  ：
    data：所有未处理的数据
返回值：第一个返回值是一条完整帧报文的处理结果，第二个返回值是未处理的数据
]]
local function parse(data)
  if not data then return end 
  
  local tail = string.find(data,"\r\n")
  if not tail then return false,data end
  
  local head = string.find(data,"AT+")
  if not head then return false,"" end 
  
  local cmdbreak = string.find(data,"=")
  local cmd, body, result
  if cmdbreak then
  
    cmd = string.sub(data,head+3,cmdbreak-1)
    body = string.sub(data,cmdbreak+1,tail-1)
  else
    cmd =string.sub(data,head+3,tail-1)
  end
   
  print("parse",cmd,(body and body or ""))
  
 -- if cmd == LOAD_CONFIG then
   
  -- print("write","hello")
   
   -- print("reee : ",cmd,(body and body or ""))
    --write(assetconfig.getconfigpack())
 -- elseif cmd == QUERY_STATUS then
  -- write("status report like this")    -- TODO  
 -- elseif cmd == UPDATE_CONFIG then
  --  assetconfig.updateconfig(body)
  --  write("ok")
 -- elseif cmd == SWITCH_MODE then
    -- sys.dispatch("SWITCH_WORK_MODE",body)
 -- elseif cmd == DEVICE_POLL then
    -- query
  --  write("query")
 -- elseif cmd == MAKE_REPORT then
    -- make report 
 --   write("make report")
 -- elseif cmd == DEVICE_REBOOT then
   -- sys.restart("reboot requested")
   
 -- else
  --  write("CMD_ERROR")
 -- end
  -- proc(data)
   print("write","hello")
 -- return true,string.sub(data,tail+1,-1)  
  return cmd
end
--local uartconfig = assetconfig.getParam("uart")
--local UART_ID,BAUDRATE,PARITY,DATABITS,STOPBITS = uartconfig.id,uartconfig.baudrate,uartconfig.par,uartconfig.data,uartconfig.stop



--[[
函数名：read
功能  ：读取串口接收到的数据
参数  ：无
返回值：无
]]
local function read()
  local data = ""
  while true do
    data = uart.read(UART_ID,"*l",0)
    if not data or string.len(data) == 0 then break end
    print("received : ",data)
  
     if data == "AT=FLIP" then
      print("play : ",data)
      
     led.CloseTimerFunc1()
     end 
  end   
end

--------------------------------------------------------------------------
-- config window keep open
--保持系统处于唤醒状态，此处只是为了测试需要，所以此模块没有地方调用pm.sleep("test")休眠，不会进入低功耗休眠状态
--在开发“要求功耗低”的项目时，一定要想办法保证pm.wake("test")后，在不需要串口时调用pm.sleep("test")
--pm.wake("uartdemo")
--注册串口的数据接收函数，串口收到数据后，会以中断方式，调用read接口读取数据
sys.reguart(UART_ID,read)
--配置并且打开串口
uart.setup(UART_ID,9600,8,uart.PAR_NONE,uart.STOP_1)
uart.write(UART_ID,"stech_ready\r\n")

--sys.timer_loop_start(read,2000)
