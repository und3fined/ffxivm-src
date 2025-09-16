---
--- Author: Administrator
--- DateTime: 2023-11-15 16:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class TreasureHuntTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TreasureHuntTipsView = LuaClass(UIView, true)

function TreasureHuntTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TreasureHuntTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TreasureHuntTipsView:OnInit()

end

function TreasureHuntTipsView:OnDestroy()

end

function TreasureHuntTipsView:OnShow()
	self.TextTips:SetText(_G.LSTR(640043)) --发现宝箱
end

function TreasureHuntTipsView:OnHide()

end

function TreasureHuntTipsView:OnRegisterUIEvent()

end

function TreasureHuntTipsView:OnRegisterGameEvent()

end

function TreasureHuntTipsView:OnRegisterBinder()

end

return TreasureHuntTipsView