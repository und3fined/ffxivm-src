--
-- Author: haialexzhou
-- Date: 2020-12-23 15:23:43
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")

local TextColorType = {
	Normal = {
		TextColorHex = "FFFFFFFF",
		OutlineColorHex = "00000099", -- 描边透明度60%
	},
	Finished = {
		-- 整体透明度减半
		TextColorHex = "FFFFFF80",
		OutlineColorHex = "0000004C",
	},
}

local PWorldStageInfoItemView = LuaClass(UIView, true)

---@class PWorldStageInfoItemView : UIView
--AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY

--AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
function PWorldStageInfoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.StageName = nil
	--self.StageProgress = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldStageInfoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldStageInfoItemView:OnInit()

end

function PWorldStageInfoItemView:OnDestroy()

end

function PWorldStageInfoItemView:OnShow()
	local Index = self.Params.Index
	local Data = self.Params.Data

	self.StageName:SetText(Data.Text)

	local CurrStage = _G.PWorldStageMgr.CurrStage
	local CurrProcess = _G.PWorldStageMgr.CurrProcess

	--print("Index=" .. Index .. "; Data.Text=" .. Data.Text)
	if (Index >= CurrStage) then
		if (Index == CurrStage) then
			self.StageProgress:SetText(string.format("%d/%d", CurrProcess, Data.MaxProgress))
			self:SetStageTextColorType((CurrProcess < Data.MaxProgress)
				and TextColorType.Normal or TextColorType.Finished)
		else
			self.StageProgress:SetText(string.format("%d/%d", 0, Data.MaxProgress))
			self:SetStageTextColorType(TextColorType.Normal)
		end

		-- if (Index > _G.PWorldStageMgr.CurrStage) then
		-- 	self.StageName:SetText("??????")
		-- end
	else
		self.StageProgress:SetText(string.format("%d/%d", Data.MaxProgress, Data.MaxProgress))
		self:SetStageTextColorType(TextColorType.Finished)
	end
end

function PWorldStageInfoItemView:SetStageTextColorType(ColorType)
	UIUtil.TextBlockSetColorAndOpacityHex(self.StageName, ColorType.TextColorHex)
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.StageName, ColorType.OutlineColorHex)
	UIUtil.TextBlockSetColorAndOpacityHex(self.StageProgress, ColorType.TextColorHex)
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.StageProgress, ColorType.OutlineColorHex)
end

function PWorldStageInfoItemView:OnHide()

end

function PWorldStageInfoItemView:OnRegisterUIEvent()

end

function PWorldStageInfoItemView:OnRegisterGameEvent()

end

function PWorldStageInfoItemView:OnRegisterTimer()

end

function PWorldStageInfoItemView:OnRegisterBinder()

end

return PWorldStageInfoItemView