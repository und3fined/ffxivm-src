---
--- Author: enqingchen
--- DateTime: 2022-02-14 16:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommMoneyBarVM = require("Game/Common/Bar/CommMoneyBarVM")

local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetScoreIcon = require("Binder/UIBinderSetScoreIcon")

---@class CommMoneyBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Icon UFImage
---@field Text_Money UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommMoneyBarView = LuaClass(UIView, true)

function CommMoneyBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Icon = nil
	--self.Text_Money = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommMoneyBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommMoneyBarView:OnInit()
	self.ViewModel = CommMoneyBarVM.New()
end

function CommMoneyBarView:OnDestroy()

end

function CommMoneyBarView:OnShow()

end

function CommMoneyBarView:OnHide()

end

function CommMoneyBarView:OnRegisterUIEvent()

end

function CommMoneyBarView:OnRegisterGameEvent()

end

function CommMoneyBarView:OnRegisterBinder()
	local Binders = {
		{ "ScoreID", UIBinderSetScoreIcon.New(self, self.FImg_Icon) },
		{ "ScoreValue", UIBinderSetTextFormatForMoney.New(self, self.Text_Money) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

--ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
function CommMoneyBarView:UpdateMoneyByID(ScoreID)
	self.ViewModel:UpdateByScoreID(ScoreID)
end

return CommMoneyBarView