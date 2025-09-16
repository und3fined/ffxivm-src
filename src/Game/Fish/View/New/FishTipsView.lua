---
--- Author: Administrator
--- DateTime: 2025-01-08 16:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")

local FishReleaseTipVM = require("Game/Fish/ItemVM/FishReleaseTipVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UILayer = require("UI/UILayer")

---@class FishTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBtnS CommBtnSView
---@field FishNotesSlot1 FishNotesSlotItemView
---@field FishNotesSlot5 FishNotesSlotItemView
---@field IconSkill5 UFImage
---@field ImgArrow5 UFImage
---@field ImgBg2 UFImage
---@field ImgBg3 UFImage
---@field ImgPoint5 UFImage
---@field PanelProBar UFCanvasPanel
---@field PanelSlot1 UFCanvasPanel
---@field PanelSlot5 UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field ProBarCD UProgressBar
---@field TableViewSlot UTableView
---@field TextName UFTextBlock
---@field TextState UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishTipsView = LuaClass(UIView, true)

function FishTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBtnS = nil
	--self.FishNotesSlot1 = nil
	--self.FishNotesSlot5 = nil
	--self.IconSkill5 = nil
	--self.ImgArrow5 = nil
	--self.ImgBg2 = nil
	--self.ImgBg3 = nil
	--self.ImgPoint5 = nil
	--self.PanelProBar = nil
	--self.PanelSlot1 = nil
	--self.PanelSlot5 = nil
	--self.PanelTips = nil
	--self.ProBarCD = nil
	--self.TableViewSlot = nil
	--self.TextName = nil
	--self.TextState = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtnS)
	self:AddSubView(self.FishNotesSlot1)
	self:AddSubView(self.FishNotesSlot5)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishTipsView:OnInit()
	self.BaitListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.TableViewBaitSelected)
	self.FishReleaseTipVM = FishReleaseTipVM.New()
	self.FishID = nil
	self.ItemView = nil
	self.TextTitle:SetText(_G.LSTR(180048))--鱼饵/以小钓大

	self.MultiBinders = {
		{
			ViewModel = self.FishReleaseTipVM,
			Binders = {
				{ "BtnText", UIBinderSetText.New(self, self.CommBtnS.TextContent) },
				{ "ReleaseFishText", UIBinderSetText.New(self, self.TextName) },
				{ "TextState", UIBinderSetText.New(self, self.TextState) },
				{ "FishTime", UIBinderSetText.New(self, self.TextTime) },
				{ "bIsknown",UIBinderSetIsVisible.New(self, self.CommBtnS, false, true)},
				{ "bFishWindowBarVisible",UIBinderSetIsVisible.New(self, self.PanelProBar, false, true)},
				{ "FishTimePercent", UIBinderSetPercent.New(self, self.ProBarCD) },
			}
		},
		{
			ViewModel = self.FishReleaseTipVM.BaitsInfo,
			Binders = {
				{"FishDetailBaitList", UIBinderUpdateBindableList.New(self, self.BaitListAdapter)},
				{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconSkill5) },
				{ "PointIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgPoint5) },
			}
		},
	}

	UIUtil.SetIsVisible(self.FishNotesSlot1.BtnItem, true, true, true)
	UIUtil.SetIsVisible(self.FishNotesSlot5.BtnItem, true, true, true)
end

function FishTipsView:OnDestroy()

end

function FishTipsView:OnShow()
	local Params = self.Params
	if Params then
		local Item = Params.Item
		if Item then
			self.FishReleaseTipVM:UpdateReleaseFishData(Item)
			self.FishID = Item.ResID
		end
		local View = Params.ItemView
		if View then
			self.ItemView = View
		end
	end
end

function FishTipsView:OnHide()

end

function FishTipsView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end
function FishTipsView:OnTimer()
	if self.FishID ~= nil then
		local Fish = _G.FishNotesMgr:GetFishDataByItemID(self.FishID)
		self.FishReleaseTipVM:RefreshFishTime(Fish)
	end
end

function FishTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnS, self.OnClickBtnRelease)
end

function FishTipsView:OnRegisterGameEvent()

end

function FishTipsView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
	local BaitsInfo = self.FishReleaseTipVM.BaitsInfo
    self.FishNotesSlot1:SetParams({Data = BaitsInfo.BaitSlotVM1})
    self.FishNotesSlot5:SetParams({Data = BaitsInfo.BaitSlotVM5})
end

function FishTipsView:OnClickBtnRelease()
	self.FishReleaseTipVM:UpdateAutoRelease()
	_G.UIViewMgr:FindView(_G.UIViewID.FishMainPanel):StorageReleaseFishData(self.FishID)
end

function FishTipsView:UpdateItem(Item,PosData,ItemView)
	self.FishReleaseTipVM:UpdateReleaseFishData(Item)
	if ItemView then
		self.ItemView = ItemView
	end
	if Item then
		self.FishID = Item.ResID
	end
end

function FishTipsView:UpdatePanelPos(PosData)
	if PosData then
		UIUtil.AdjustTipsPosition(self.PanelTips, PosData.SelectedWidget, PosData.Offset)
	end
end

function FishTipsView:TableViewBaitSelected(_, ItemData, ItemView)
	local FishSlot = ItemData.FishSlot
	if FishSlot and _G.FishNotesMgr:CheckFishUnlockInFround(FishSlot.ID) then
		ItemTipsUtil.ShowTipsByResID(FishSlot.ItemID, ItemView.FishNotesSlot2)
		_G.UIViewMgr:ChangeLayer(_G.UIViewID.ItemTips, UILayer.Tips)
	end
end

return FishTipsView