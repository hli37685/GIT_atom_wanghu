--
-- 客服层
-- LiuXueCheng 2017-03-17
--
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local KeFuLayer = class("KeFuLayer", cc.Layer)

function KeFuLayer:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("KeFu/KeFuLayer.csb", self)
	self.mCsbNode = csbNode

    --返回按钮
    local btnBack = csbNode:getChildByName("Btn_Back")
    btnBack:addTouchEventListener(handler(self, self.onBtnBack))

    --复制qq按钮
    local btnCopyQQ = csbNode:getChildByName("Image_1"):getChildByName("Button_qq")
    btnCopyQQ:addTouchEventListener(handler(self, self.onBtnCopyQQ))
    --复制微信按钮
    local btnCopyWeChat = csbNode:getChildByName("Image_1"):getChildByName("Button_weixin")
    btnCopyWeChat:addTouchEventListener(handler(self, self.onBtnCopyWeChat))
end

--返回按钮事件
function KeFuLayer:onBtnBack(sender, type)
	if type == ccui.TouchEventType.ended then
        self.mScene:onKeyBack()
    end
end

--复制qq按钮事件
function KeFuLayer:onBtnCopyQQ(sender, eventtype)
	if eventtype ~= ccui.TouchEventType.ended then
       return 
    end
    
    local res, msg = MultiPlatform:getInstance():copyToClipboard("4006665516")
    if true == res then
        showToast(self, "QQ号码(电话号码)已经复制到粘贴板!", 1)
    else
        if type(msg) == "string" then
            showToast(self, msg, 1, cc.c3b(250,0,0))
        end
    end
end

--复制微信按钮事件
function KeFuLayer:onBtnCopyWeChat(sender, eventtype)

	local res, msg = MultiPlatform:getInstance():copyToClipboard("16亿游戏")
    if true == res then
        showToast(self, "微信公众号已经复制到粘贴板!", 1)
    else
        if type(msg) == "string" then
            showToast(self, msg, 1, cc.c3b(250,0,0))
        end
    end

end




return KeFuLayer
