---
--- Author: Administrator
--- DateTime: 2024-09-23 11:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local ItemVM = require("Game/Item/ItemVM")
local FishMgr = _G.FishMgr

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")

local FishDefine = require("Game/Fish/FishDefine")

---@class FishTipsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field Btnsure CommBtnLView
---@field RichText URichTextBox
---@field Slot1 CommBackpackSlotView
---@field SlotBG2 UFImage
---@field TextSpecies UFTextBlock
---@field TextTaxRate UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishTipsWinView = LuaClass(UIView, true)

function FishTipsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.Btnsure = nil
	--self.RichText = nil
	--self.Slot1 = nil
	--self.SlotBG2 = nil
	--self.TextSpecies = nil
	--self.TextTaxRate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishTipsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.Btnsure)
	self:AddSubView(self.Slot1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishTipsWinView:OnInit()
	self.ItemVM = nil
	self.Binder = {
        {"Icon", UIBinderSetBrushFromAssetPath.New(self, self.Slot1.FImg_Icon)},
		{"Name", UIBinderSetText.New(self, self.TextSpecies)},
    }
	self:UIInit()
end

function FishTipsWinView:OnDestroy()

end

function FishTipsWinView:OnShow()
	local Params = self.Params
	if Params then
		local FishValue = Params.FishValue or 0
		self.RichText:SetText(string.format(FishDefine.FishTipsWinText.RichText,FishValue))
	end
end

function FishTipsWinView:OnHide()

end

function FishTipsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnCollectionCancel)
	UIUtil.AddOnClickedEvent(self, self.Btnsure, self.OnCollectionConfirm)
	UIUtil.AddOnClickedEvent(self, self.BG.ButtonClose, self.OnCollectionCancel)
end

function FishTipsWinView:OnRegisterGameEvent()

end

function FishTipsWinView:OnRegisterBinder()
	local Params = self.Params
	if Params then
		local ItemID = Params.CollectItemID
		if not self.ItemVM then
			self.ItemVM = ItemVM.New()
		end
		self.ItemVM:UpdateVM({ResID = ItemID})
	end

	self:RegisterBinders(self.ItemVM, self.Binder)
end

function FishTipsWinView:OnCollectionCancel()
	FishMgr:OnFishLiftAnimFinish(false)
	self:Hide()
end

function FishTipsWinView:OnCollectionConfirm()
	FishMgr:OnFishLiftAnimFinish(true)
	self:Hide()
end

function FishTipsWinView:UIInit()
	self.TextTaxRate:SetText(FishDefine.FishTipsWinText.TextTaxRate)
	self.BG.FText_Title:SetText(FishDefine.FishTipsWinText.TitleText)
	self.BtnCancel.TextContent:SetText(FishDefine.FishTipsWinText.CancelText)
	self.Btnsure.TextContent:SetText(FishDefine.FishTipsWinText.ConfirmText)
end

return FishTipsWinView