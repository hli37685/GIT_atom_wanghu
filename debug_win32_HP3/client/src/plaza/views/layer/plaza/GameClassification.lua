--
-- 游戏分类层
--
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local GameClassification = class("GameClassification", cc.Layer)

function GameClassification:ctor(scene)
	self.mScene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("Lobby/GameClassification.csb", self)
	self.mCsbNode = csbNode

    --棋牌游戏
	self._btnGameCar = csbNode:getChildByName("GameCar")
    self._btnGameCar:addTouchEventListener(handler(self, self.onBtnGameCar))
    --多人游戏
	self._btnGameMulti = csbNode:getChildByName("GameMulti")
    self._btnGameMulti:addTouchEventListener(handler(self, self.onBtnGameMulti))
    --休闲游戏
	self._btnGameLeisure = csbNode:getChildByName("GameLeisure")
    self._btnGameLeisure:addTouchEventListener(handler(self, self.onBtnGameLeisure))
    --捕鱼游戏
	self._btnGameFish = csbNode:getChildByName("GameFish")
    self._btnGameFish:addTouchEventListener(handler(self, self.onBtnGameFish))
end

function GameClassification:onBtnGameCar()

    self.mScene:onChangeShowMode(yl.SCENE_GAMELIST, yl.GAMECLASS_CARD)
    
end

function GameClassification:onBtnGameMulti()

     self.mScene:onChangeShowMode(yl.SCENE_GAMELIST, yl.GAMECLASS_MULTI) 

end

function GameClassification:onBtnGameLeisure()

    self.mScene:onChangeShowMode(yl.SCENE_GAMELIST, yl.GAMECLASS_LEISURE)
    
end

function GameClassification:onBtnGameFish()

    self.mScene:onChangeShowMode(yl.SCENE_GAMELIST, yl.GAMECLASS_FISH)

end

return GameClassification
