module(...,package.seeall)

--require"pm"
require"led"

-- AT command supportted
-- example    ����uart1�յ�"AT=FLIP"��ִ��led()����
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
--����ID,1��Ӧuart1
--���Ҫ�޸�Ϊuart2����UART_ID��ֵΪ2����
local UART_ID = 1
--֡ͷ�����Լ�֡β
--local CMD_SCANNER,CMD_GPIO,CMD_PORT,FRM_TAIL = 1,2,3,string.char(0xC0)
--���ڶ��������ݻ�����
local rdbuf = ""

--[[
��������parse
����  ������֡�ṹ��������һ��������֡����
����  ��
    data������δ���������
����ֵ����һ������ֵ��һ������֡���ĵĴ��������ڶ�������ֵ��δ���������
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
��������read
����  ����ȡ���ڽ��յ�������
����  ����
����ֵ����
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
--����ϵͳ���ڻ���״̬���˴�ֻ��Ϊ�˲�����Ҫ�����Դ�ģ��û�еط�����pm.sleep("test")���ߣ��������͹�������״̬
--�ڿ�����Ҫ�󹦺ĵ͡�����Ŀʱ��һ��Ҫ��취��֤pm.wake("test")���ڲ���Ҫ����ʱ����pm.sleep("test")
--pm.wake("uartdemo")
--ע�ᴮ�ڵ����ݽ��պ����������յ����ݺ󣬻����жϷ�ʽ������read�ӿڶ�ȡ����
sys.reguart(UART_ID,read)
--���ò��Ҵ򿪴���
uart.setup(UART_ID,9600,8,uart.PAR_NONE,uart.STOP_1)
uart.write(UART_ID,"stech_ready\r\n")

--sys.timer_loop_start(read,2000)
