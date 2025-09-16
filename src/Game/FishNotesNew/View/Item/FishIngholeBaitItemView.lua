---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FishIngholeBaitItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBait UFButton
---@field FishNotesSlot1 FishNotesSlotItemView
---@field FishNotesSlot5 FishNotesSlotItemView
---@field IconSkill5 UFImage
---@field ImgArrow5 UFImage
---@field ImgPoint5 UFImage
---@field PanelSlot1 UFCanvasPanel
---@field PanelSlot5 UFCanvasPanel
---@field TableViewSlot UTableView
---@field TextTitle UFTextBlock
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeBaitItemView = LuaClass(UIView, true)

function FishIngholeBaitItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBait = nil
	--self.FishNotesSlot1 = nil
	--self.FishNotesSlot5 = nil
	--self.IconSkill5 = nil
	--self.ImgArrow5 = nil
	--self.ImgPoint5 = nil
	--self.PanelSlot1 = nil
	--self.PanelSlot5 = nil
	--self.TableViewSlot = nil
	--self.TextTitle = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeBaitItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FishNotesSlot1)
	self:AddSubView(self.FishNotesSlot5)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeBaitItemView:OnInit()
	self.BaitListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.TableViewBaitSelected, true, false)
end

function FishIngholeBaitItemView:OnDestroy()

end

function FishIngholeBaitItemView:OnShow()
	self.TextTitle:SetText(_G.LSTR(180048))--鱼饵/以小钓大
	UIUtil.SetIsVisible(self.FishNotesSlot1.BtnItem, true, true, true)
	UIUtil.SetIsVisible(self.FishNotesSlot5.BtnItem, true, true, true)
end

function FishIngholeBaitItemView:OnHide()

end

function FishIngholeBaitItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBait, self.OnClickButtonOpenBaitView)
end

function FishIngholeBaitItemView:OnRegisterGameEvent()

end

function FishIngholeBaitItemView:OnRegisterBinder()
	local FishIngholeBaitsInfo = _G.FishIngholeVM.FishIngholeBaitsInfo
	self.MultiBinders = {
		{
			ViewModel = FishIngholeBaitsInfo,
			Binders = {
				{"FishDetailBaitList", UIBinderUpdateBindableList.New(self, self.BaitListAdapter)},
				{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconSkill5) },
				{ "PointIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgPoint5) },
			}
		},
		{
			ViewModel = _G.FishIngholeVM,
			Binders = {
				{"bFishDetailBaitBtn", UIBinderSetIsVisible.New(self, self.BtnBait, false, true, true)},
			}
		},
	}
	self:RegisterMultiBinders(self.MultiBinders)
    self.FishNotesSlot1:SetParams({Data = FishIngholeBaitsInfo.BaitSlotVM1})
    self.FishNotesSlot5:SetParams({Data = FishIngholeBaitsInfo.BaitSlotVM5})
end

function FishIngholeBaitItemView:OnClickButtonOpenBaitView()
	_G.UIViewMgr:ShowView(_G.UIViewID.FishNotesOtherBait)
end

function FishIngholeBaitItemView:TableViewBaitSelected(_, ItemData, ItemView)
	local FishSlot = ItemData.FishSlot
	if FishSlot and _G.FishNotesMgr:CheckFishUnlockInFround(FishSlot.ID,  _G.FishIngholeVM.SelectLocationID) then
		ItemTipsUtil.ShowTipsByResID(FishSlot.ItemID, ItemView.FishNotesSlot2)
	end
end

return FishIngholeBaitItemView