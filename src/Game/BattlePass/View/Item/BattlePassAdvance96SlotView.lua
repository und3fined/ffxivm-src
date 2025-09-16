---
--- Author: Administrator
--- DateTime: 2024-12-11 16:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class BattlePassAdvance96SlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BattlePassRewardSlot BattlePassRewardSlotView
---@field BtnCheck UFButton
---@field Comm96Slot CommBackpack96SlotView
---@field PanelGetNow UFCanvasPanel
---@field TextGetNow UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassAdvance96SlotView = LuaClass(UIView, true)

function BattlePassAdvance96SlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BattlePassRewardSlot = nil
	--self.BtnCheck = nil
	--self.Comm96Slot = nil
	--self.PanelGetNow = nil
	--self.TextGetNow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassAdvance96SlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BattlePassRewardSlot)
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassAdvance96SlotView:OnInit()
	self.Binders = {
		{"IsGetNow", UIBinderSetIsVisible.New(self, self.PanelGetNow)},
		{"IsPreview", UIBinderSetIsVisible.New(self, self.BtnCheck, false, true)},
	}
end

function BattlePassAdvance96SlotView:OnDestroy()

end

function BattlePassAdvance96SlotView:OnShow()

end

function BattlePassAdvance96SlotView:OnHide()

end

function BattlePassAdvance96SlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnClickCheckBtn)
	UIUtil.AddOnClickedEvent(self, self.Comm96Slot.Btn, self.OnClickedItem)
end

function BattlePassAdvance96SlotView:OnRegisterGameEvent()

end

function BattlePassAdvance96SlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)

	self.BattlePassRewardSlot:SetParams({Data = VM.ItemVM})
end

function BattlePassAdvance96SlotView:OnClickCheckBtn()
	if self.ViewModel == nil then
		return
	end
	if self.ViewModel.JumpID ~= nil then
		_G.PreviewMgr:OpenPreviewView(self.ViewModel.JumpID)
		return
	end
	_G.PreviewMgr:OpenPreviewView(self.ViewModel.ResID)
end

function BattlePassAdvance96SlotView:OnClickedItem()
	local Params = self.Params
    if nil == Params then
        return
    end
    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end
    Adapter:OnItemClicked(self, Params.Index)

	-- ItemTipsUtil.ShowTipsByResID(self.ViewModel.ResID, self.Comm96Slot)
end

return BattlePassAdvance96SlotView