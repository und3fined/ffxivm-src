---
--- Author: sammrli
--- DateTime: 2024-09-02 09:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class NewQuestPropItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackpack126Slot CommBackpack126SlotView
---@field ImgTaskNormal UFImage
---@field ImgTaskSelect UFImage
---@field ImgTaskSelectCheck UFImage
---@field TextNum URichTextBox
---@field TextTaskName URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewQuestPropItemView = LuaClass(UIView, true)

function NewQuestPropItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackpack126Slot = nil
	--self.ImgTaskNormal = nil
	--self.ImgTaskSelect = nil
	--self.ImgTaskSelectCheck = nil
	--self.TextNum = nil
	--self.TextTaskName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewQuestPropItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpack126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewQuestPropItemView:OnInit()
	-- 覆盖itemview Binder
	self.CommBackpack126Slot.OnRegisterBinder = function() end
end

function NewQuestPropItemView:OnDestroy()

end

function NewQuestPropItemView:OnShow()
	if not self.Params.Data then return end

	local Data = self.Params.Data

	if Data.Name then
		self.TextTaskName:SetText(Data.Name)
	else
		self.TextTaskName:SetText("")
	end

	self:UpdateSubmitNumber(Data)

	UIUtil.SetIsVisible(self.CommBackpack126Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.CommBackpack126Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.CommBackpack126Slot.RichTextQuantity, false)
end

function NewQuestPropItemView:OnHide()

end

function NewQuestPropItemView:OnRegisterUIEvent()
	self.CommBackpack126Slot:SetClickButtonCallback(self, self.OnClickItemHandle)
end

function NewQuestPropItemView:OnRegisterGameEvent()

end

function NewQuestPropItemView:OnRegisterBinder()
	local Params = self.Params
    if not Params then return end

    local ViewModel = Params.Data
    if not ViewModel or not ViewModel.RegisterBinder then
        return
    end

    if not self.Binders then
        self.Binders = {
			{
				"IsSelect",
				UIBinderValueChangedCallback.New(self, nil, self.OnSelectValueChangedHandle)
			},
			{
                "Icon",
                UIBinderSetBrushFromAssetPath.New(self, self.CommBackpack126Slot.Icon)
            },
			{
                "ItemQualityIcon",
                UIBinderSetBrushFromAssetPath.New(self, self.CommBackpack126Slot.ImgQuanlity)
            },
        }
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

function NewQuestPropItemView:UpdateSubmitNumber(ItemVM)
	if not ItemVM then
		return
	end

	local NeedNum = ItemVM.Num or 1
	if self.Params and self.Params.Adapter then
		local ItemSubmitVM = self.Params.Adapter.Params.ViewModel
		self.IsCanSelected = ItemSubmitVM.IsMagicsparNeed
		for i, RequiredVM in ipairs(ItemSubmitVM.RequiredItemVMList:GetItems()) do
			if RequiredVM.ResID == ItemVM.ResID then
				NeedNum = RequiredVM.Num
			end
		end
	end

	local HadNum = 0
	if ItemUtil.CheckIsEquipmentByResID(ItemVM.ResID) then --装备不能叠加,拥有和需提交数量特殊显示
		if self.IsCanSelected then
			NeedNum = ItemVM.IsSelect and 1 or 0
		else
			NeedNum = 1
		end
		HadNum = 1
	else
		HadNum = _G.BagMgr:GetItemNum(ItemVM.ResID)
	end

	if (ItemVM.bOnlyShowHaveNum == true) then
		self.TextNum:SetText(string.format("%s", tostring(HadNum)))
	else
		self.TextNum:SetText(string.format("%s/%s", tostring(HadNum), tostring(NeedNum)))
	end
end

function NewQuestPropItemView:OnSelectValueChangedHandle(Val)
	UIUtil.SetIsVisible(self.ImgTaskSelect, Val)
	--UIUtil.SetIsVisible(self.ImgTaskSelectCheck, Val)

	local Params = self.Params
	if not Params then return end
	local ViewModel = Params.Data
	self:UpdateSubmitNumber(ViewModel)
end

function NewQuestPropItemView:OnClickItemHandle()
	local Params = self.Params
    if not Params then return end

    local ViewModel = Params.Data
    if not ViewModel then
        return
    end
	ItemTipsUtil.ShowTipsByGID(ViewModel.GID, self)
end

return NewQuestPropItemView