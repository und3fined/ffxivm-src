---
--- Author: v_zanchang
--- DateTime: 2022-11-21 15:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local UIUtil = require("Utils/UIUtil")

---@class TeamRollINumbertemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DecadeTextNumber UFTextBlock
---@field EFF_ADD_Inst_15 UFImage
---@field EFF_ADD_Inst_15a UFImage
---@field EFF_ADD_Inst_15b UFImage
---@field EFF_ADD_Inst_15c UFImage
---@field EFF_Clip_Inst1 UFImage
---@field EFF_Sequence_1_Inst_12 UFImage
---@field EFF_Sequence_1_Inst_12a UFImage
---@field ImgNumberBkgGet UFImage
---@field ImgNumberBkgGet_1 UFImage
---@field UintTextNumber UFTextBlock
---@field AnimHideAll UWidgetAnimation
---@field AnimRollend UWidgetAnimation
---@field AnimRollendWin UWidgetAnimation
---@field AnimRolling UWidgetAnimation
---@field AnimShowResult UWidgetAnimation
---@field AnimShowWaitWinLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRollINumbertemView = LuaClass(UIView, true)

function TeamRollINumbertemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DecadeTextNumber = nil
	--self.EFF_ADD_Inst_15 = nil
	--self.EFF_ADD_Inst_15a = nil
	--self.EFF_ADD_Inst_15b = nil
	--self.EFF_ADD_Inst_15c = nil
	--self.EFF_Clip_Inst1 = nil
	--self.EFF_Sequence_1_Inst_12 = nil
	--self.EFF_Sequence_1_Inst_12a = nil
	--self.ImgNumberBkgGet = nil
	--self.ImgNumberBkgGet_1 = nil
	--self.UintTextNumber = nil
	--self.AnimHideAll = nil
	--self.AnimRollend = nil
	--self.AnimRollendWin = nil
	--self.AnimRolling = nil
	--self.AnimShowResult = nil
	--self.AnimShowWaitWinLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRollINumbertemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRollINumbertemView:OnInit()

end

function TeamRollINumbertemView:OnDestroy()

end

function TeamRollINumbertemView:OnShow()

end

function TeamRollINumbertemView:OnHide()

end

function TeamRollINumbertemView:OnRegisterUIEvent()

end

function TeamRollINumbertemView:OnRegisterGameEvent()

end

function TeamRollINumbertemView:OnRegisterBinder()

end

function TeamRollINumbertemView:OnAnimationFinished(Animation)
	local Params = self.Params
	if nil == Params or Params.OnItemAnimationFinished == nil then
		return
	end

	Params.OnItemAnimationFinished(Params.View, self, Animation)
end

return TeamRollINumbertemView