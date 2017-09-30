--[[
	背包界面
	2016_07_06 Ravioyla
]]

local BagLayer = class("BagLayer", function(scene)
		local bagLayer = display.newLayer(cc.c4b(0, 0, 0, 125))
    return bagLayer
end)


return BagLayer