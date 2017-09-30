
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("base/src/")
cc.FileUtils:getInstance():addSearchPath("base/res/")


require "config"
require "cocos.init"


-- 日志输出到output同时
function babe_tostring(...)  
    local num = select("#",...) 
    local args = {...} 
    local outs = {}
    for i = 1, num do  
        if i > 1 then  
            outs[#outs+1] = "\t"
        end  
        outs[#outs+1] = tostring(args[i])
    end  
    return table.concat(outs)
end  
      
local babe_print = print;  
local babe_output = function(...)  
    babe_print(...)
      
    if decoda_output ~= nil then  
        local str = babe_tostring(...)
        decoda_output(str)  
    end  
end  

local only_output = function(...)  
    if decoda_output ~= nil then  
        local str = babe_tostring(...)
        decoda_output(str)  
    end  
end  

just_output = only_output
all_output = babe_output
-- 

local function main()
    
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
