---
--- Author: Administrator
--- DateTime: 2025-02-26 11:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobeJumpItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field ImgArrow UFImage
---@field ImgFinish UFImage
---@field ImgItemBg UFImage
---@field ImgItemIcon UFImage
---@field TextQuestName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeJumpItemView = LuaClass(UIView, true)

function WardrobeJumpItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.ImgArrow = nil
	--self.ImgFinish = nil
	--self.ImgItemBg = nil
	--self.ImgItemIcon = nil
	--self.TextQuestName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeJumpItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeJumpItemView:OnInit()
	self.Binders = {
		{ "AchievementName", UIBinderSetText.New(self, self.TextQuestName) },
		{ "AchievementStatus", UIBinderSetIsVisible.New(self, self.ImgFinish) },
		{ "AchievementStatus", UIBinderSetIsVisible.New(self, self.ImgArrow, true) },
	}
end

function WardrobeJumpItemView:OnDestroy()

end

function WardrobeJumpItemView:OnShow()

end

function WardrobeJumpItemView:OnHide()

end

function WardrobeJumpItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, 		self.OnBtnClickGO)
end

function WardrobeJumpItemView:OnRegisterGameEvent()

end

function WardrobeJumpItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function WardrobeJumpItemView:OnBtnClickGO()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	if ViewModel.AchievementID ~= nil then
		if ViewModel.ItemID ~= nil then
			-- local CfgList = ItemUtil.GetItemGetWayList(ViewModel.ItemID)
			-- if _G.UIViewMgr:IsViewVisible(_G.UIViewID.AchievementMainPanel) then
			-- 	_G.MsgTipsUtil.ShowTipsByID(CfgList[1].RepeatJumpTipsID)
			-- 	return
			-- end
	
			local Params = {AchievemwntID = ViewModel.AchievementID}
			_G.AchievementMgr:OpenAchievementMainPanelView(Params)
		end
	end
end

return WardrobeJumpItemView