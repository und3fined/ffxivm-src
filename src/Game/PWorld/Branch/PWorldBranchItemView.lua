---
--- Author: peterxie
--- DateTime: 2024-06-14 09:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")


---@class PWorldBranchItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF UFCanvasPanel
---@field ImgState UFImage
---@field TextBranchName UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldBranchItemView = LuaClass(UIView, true)

function PWorldBranchItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF = nil
	--self.ImgState = nil
	--self.TextBranchName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldBranchItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldBranchItemView:OnInit()

end

function PWorldBranchItemView:OnDestroy()

end

function PWorldBranchItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Line = Params.Data
	if nil == Line then
		return
	end

	local PWorldMgr = _G.PWorldMgr
	local CurrMapTableCfg = PWorldMgr:GetCurrMapTableCfg()

	local BranchText = string.format("%s（%02d）", CurrMapTableCfg.DisplayName, Line.LineID)
	self.TextBranchName:SetText(BranchText)

	local BranchStateIcon = PWorldMgr:GetPWorldLineStateIconPath(Line.PlayerNum)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgState, BranchStateIcon)

	UIUtil.SetIsVisible(self.EFF, Line.LineID == PWorldMgr:GetCurrPWorldLineID())
end

function PWorldBranchItemView:OnHide()

end

function PWorldBranchItemView:OnRegisterUIEvent()

end

function PWorldBranchItemView:OnRegisterGameEvent()

end

function PWorldBranchItemView:OnRegisterBinder()

end

return PWorldBranchItemView