module(...,package.seeall)
require"pins"
require"misc"

local function print(...)
  _G.print("workled",...)
end

PIN7 = {pin=pio.P0_7,dir=pio.OUTPUT,valid=0}
pins.reg(PIN7)


function TimerFunc1(id)
  pins.set(false,PIN7)
  print("TimerFunc1 "..id)  

  pins.set(true,PIN7)  
  print("TimerFunc2 "..id)  
end   


function TimerFunc2(id) 
    
   pins.set(true,PIN7)
   sys.timer_stop_all(TimerFunc1)
   print("gotoTimerFunc2"..id)
   sys.timer_start(CloseTimerFunc1,1000,0)
end

  local i=0
 function CloseTimerFunc1()
   i=i+1
   if i<3 then
   
   sys.timer_loop_start(TimerFunc1,100,"timer")

   sys.timer_start(TimerFunc2,1000,0)
   else 
   i=0
   end
end

--CloseTimerFunc1()















