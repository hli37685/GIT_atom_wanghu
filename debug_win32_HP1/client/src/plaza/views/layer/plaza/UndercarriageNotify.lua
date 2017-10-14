--
-- 下架通知提示界面
-- 
--

local UndercarriageNotifyLayer = class("UndercarriageNotifyLayer", cc.Layer)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")



function UndercarriageNotifyLayer:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("Bag/UndercarriageNotifyLayer.csb", self)
	self.mCsbNode = csbNode

    --按钮
    local btnOk = csbNode:getChildByName("btnClose")
    btnOk:addTouchEventListener(handler(self, self.onBtnCloseCbk))

    self._txtContentList = {}
    for i = 1, 5 do
        local txtContent = csbNode:getChildByName("txtContent"..i)
        table.insert(self._txtContentList, txtContent)
    end
end

function UndercarriageNotifyLayer:onExit()
    
end

--返回按钮事件
function UndercarriageNotifyLayer:onBtnCloseCbk(sender, type)
	if type == ccui.TouchEventType.ended then
        self.mScene:onKeyBack()
    end
end

function UndercarriageNotifyLayer:setInfo(args)
    if args then
        for i = 1, #args do
            self._txtContentList[i]:setString(args[i])
        end
    end
end


return UndercarriageNotifyLayer
