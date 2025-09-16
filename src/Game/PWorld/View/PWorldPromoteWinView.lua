---
--- Author: Administrator
--- DateTime: 2025-02-10 15:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local PromoteLevelUpVM = require("Game/PromoteLevelUp/PromoteLevelUpVM")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class PWorldPromoteWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field IconJob UFImage
---@field RichTextHint URichTextBox
---@field RichTextJobLevel URichTextBox
---@field TableViewEntrance UTableView
---@field TextCloseTips UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldPromoteWinView = LuaClass(UIView, true)

function PWorldPromoteWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPopUpBG = nil
	--self.IconJob = nil
	--self.RichTextHint = nil
	--self.RichTextJobLevel = nil
	--self.TableViewEntrance = nil
	--self.TextCloseTips = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldPromoteWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldPromoteWinView:OnInit()
	if PromoteLevelUpVM == nil then
		PromoteLevelUpVM = _G.PromoteLevelUpVM
	end

	self.AdapterTableEntrance = UIAdapterTableView.CreateAdapter(self, self.TableViewEntrance, self.OnSelectChanged, true, false)
	self.PromoteBinders = {
		{ "TextTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "RichTextJobLevel", UIBinderSetText.New(self, self.RichTextJobLevel)},
		{ "RichTextHint", UIBinderSetText.New(self, self.RichTextHint)},
		{ "IconJob", UIBinderSetBrushFromAssetPath.New(self, self.IconJob)},
		{ "PromoteList", UIBinderUpdateBindableList.New(self, self.AdapterTableEntrance) },
	}
end

function PWorldPromoteWinView:OnShow()
	if PromoteLevelUpVM == nil then
		return
	end
	self.TextCloseTips:SetText(LSTR(100034))
	PromoteLevelUpVM:UpdateList()
end

function PWorldPromoteWinView:OnHide()

end

function PWorldPromoteWinView:OnRegisterUIEvent()

end

function PWorldPromoteWinView:OnRegisterGameEvent()

end

function PWorldPromoteWinView:OnRegisterBinder()
	if PromoteLevelUpVM == nil then
		return
	end
	self:RegisterBinders(PromoteLevelUpVM, self.PromoteBinders)

end

function PWorldPromoteWinView:OnSelectChanged()

end

return PWorldPromoteWinView