---
--- Author: v_vvxinchen
--- DateTime: 2025-06-10 10:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local FishCfg = require("TableCfg/FishCfg")

---@class FishIngholeBaitWinNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCollect UFButton
---@field BtnFishInherit UFButton
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommBackpack152Slot CommBackpack152SlotView
---@field TableViewList UTableView
---@field TextItemName UFTextBlock
---@field TextItemType URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeBaitWinNewView = LuaClass(UIView, true)

function FishIngholeBaitWinNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCollect = nil
	--self.BtnFishInherit = nil
	--self.Comm2FrameM_UIBP = nil
	--self.CommBackpack152Slot = nil
	--self.TableViewList = nil
	--self.TextItemName = nil
	--self.TextItemType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeBaitWinNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommBackpack152Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeBaitWinNewView:OnInit()
	self.TextItemType:SetText(_G.LSTR(180074))--"使用以下鱼饵才可以钓起该鱼类"
	self.BaitsListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.TableViewSelected, false, false)
	self.Binders = {
		{"FishDetailAllBaitList", UIBinderUpdateBindableList.New(self, self.BaitsListAdapter)},
		{"FishDetailsName", UIBinderSetText.New(self, self.TextItemName)},
		{"bBtnFishInheritVisible", UIBinderSetIsVisible.New(self, self.BtnFishInherit)},
		{"BtnCollectVisible", UIBinderSetIsVisible.New(self, self.BtnCollect)},
	}
	UIUtil.SetIsVisible(self.CommBackpack152Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.CommBackpack152Slot.RichTextQuantity, false)
	UIUtil.SetIsVisible(self.CommBackpack152Slot.IconChoose, false)
end

function FishIngholeBaitWinNewView:OnDestroy()

end

function FishIngholeBaitWinNewView:OnShow()
	self.Comm2FrameM_UIBP:SetTitleText(_G.LSTR(180073))--"目标可用钓饵"
	self:UpdateFishIcon(self.CommBackpack152Slot)
	local FishCfg = self.Params and self.Params.Cfg
	FishIngholeVM:InitFishBaitsList(FishCfg)
end

function FishIngholeBaitWinNewView:UpdateFishIcon(Slot)
	local Fish = self.Params or FishIngholeVM.SelectFishData
	if Fish then
		if _G.FishNotesMgr:CheckFishUnlockInFround(Fish.Cfg.ID) then
			local ItemData = Fish and ItemCfg:FindCfgByKey(Fish.Cfg.ItemID)
			if ItemData then
				UIUtil.ImageSetBrushFromAssetPath(Slot.Icon, UIUtil.GetIconPath(ItemData.IconID))
				UIUtil.ImageSetBrushFromAssetPath(Slot.ImgQuanlity, ItemUtil.GetItemColorIcon(ItemData.ItemID))
				UIUtil.SetIsVisible(Slot.Icon, true)
			end
		else
			UIUtil.SetIsVisible(Slot.Icon, false)
			if Fish.CanPrint and Fish.CanPrint ~= 0 then
				UIUtil.ImageSetBrushFromAssetPath(Slot.ImgQuanlity, FishNotesDefine.FishSlotCanPink)
			else
				UIUtil.ImageSetBrushFromAssetPath(Slot.ImgQuanlity, FishNotesDefine.FishSlotNotCanPink)
			end
		end
	end
end

function FishIngholeBaitWinNewView:OnHide()

end

function FishIngholeBaitWinNewView:OnRegisterUIEvent()
	self.CommBackpack152Slot:SetClickButtonCallback(self, self.OnClickBtnFish)
end

function FishIngholeBaitWinNewView:OnClickBtnFish()
	local Fish = self.Params or FishIngholeVM.SelectFishData
	if Fish and _G.FishNotesMgr:CheckFishUnlockInFround(Fish.Cfg.ID) then
		ItemTipsUtil.ShowTipsByResID(Fish.Cfg.ItemID, self.CommBackpack152Slot)
	end
end

function FishIngholeBaitWinNewView:OnRegisterGameEvent()

end

function FishIngholeBaitWinNewView:OnRegisterBinder()
	self:RegisterBinders(FishIngholeVM, self.Binders)
end

function FishIngholeBaitWinNewView:TableViewSelected(Index, ItemData, ItemView)
	if ItemData.ItemID == nil then
		_G.FLOG_ERROR("FishIngholeBaitWinView ItemID is nil")
		return
	end
	local FishData = FishCfg:FindCfg("ItemID = ".. ItemData.ItemID)
	if FishData then
		if _G.FishNotesMgr:CheckFishUnlockInFround(FishData.ID) then
			ItemTipsUtil.ShowTipsByResID(FishData.ItemID, ItemView)
		end
	else
		ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView)
	end
    self.BaitsListAdapter:CancelSelected()
end

return FishIngholeBaitWinNewView