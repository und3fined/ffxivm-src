---
--- Author: ghnvbnvb
--- DateTime: 2023-04-18 10:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CraftingLogVM = require("Game/CraftingLog/CraftingLogVM")
local CraftingLogMgr = require("Game/CraftingLog/CraftingLogMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MajorUtil = require("Utils/MajorUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")

---@class CraftingLogListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field Comm96Slot CommBackpack96SlotView
---@field FImage_601 UFImage
---@field ImgAFFalse UFImage
---@field ImgAFTrue UFImage
---@field ImgBg UFImage
---@field ImgBgSelect UFImage
---@field ImgCraftStar1 UFImage
---@field ImgCraftStar2 UFImage
---@field ImgCraftStar3 UFImage
---@field ImgCraftStar4 UFImage
---@field ImgCraftStar5 UFImage
---@field ImgDifficulty UFImage
---@field ImgLock UFImage
---@field RedDot2 CommonRedDot2View
---@field RichTextName URichTextBox
---@field TextLevel UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CraftingLogListItemView = LuaClass(UIView, true)

function CraftingLogListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.Comm96Slot = nil
	--self.FImage_601 = nil
	--self.ImgAFFalse = nil
	--self.ImgAFTrue = nil
	--self.ImgBg = nil
	--self.ImgBgSelect = nil
	--self.ImgCraftStar1 = nil
	--self.ImgCraftStar2 = nil
	--self.ImgCraftStar3 = nil
	--self.ImgCraftStar4 = nil
	--self.ImgCraftStar5 = nil
	--self.ImgDifficulty = nil
	--self.ImgLock = nil
	--self.RedDot2 = nil
	--self.RichTextName = nil
	--self.TextLevel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CraftingLogListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CraftingLogListItemView:OnInit()
	self.Binders = {
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.Comm96Slot.Icon)},
		{"bImgDoneShow", UIBinderSetIsVisible.New(self, self.Comm96Slot.IconChoose)},
		{"ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.Comm96Slot.ImgQuanlity)},
		{"PropName", UIBinderSetText.New(self, self.RichTextName)},
		{"PropLevel", UIBinderSetText.New(self, self.TextLevel)},
		{"bLeveQuestMarked", UIBinderSetIsVisible.New(self, self.FImage_601)},
		{"bCraftStar1Show", UIBinderSetIsVisible.New(self, self.ImgCraftStar1)},
		{"bCraftStar2Show", UIBinderSetIsVisible.New(self, self.ImgCraftStar2)},
		{"bCraftStar3Show", UIBinderSetIsVisible.New(self, self.ImgCraftStar3)},
		{"bCraftStar4Show", UIBinderSetIsVisible.New(self, self.ImgCraftStar4)},
		{"bCraftStar5Show", UIBinderSetIsVisible.New(self, self.ImgCraftStar5)},
		{"bIsAFStarTrue", UIBinderSetIsVisible.New(self, self.ImgAFTrue)},
		{"bImgAFFalse", UIBinderSetIsVisible.New(self, self.ImgAFFalse)},
		{"SelectShow", UIBinderSetIsVisible.New(self, self.ImgBgSelect)},
		{"bImgDifficultyShow", UIBinderSetIsVisible.New(self, self.ImgDifficulty)},
		{"bLockGray", UIBinderSetIsVisible.New(self, self.ImgLock)},
		{"bLockGray", UIBinderSetIsVisible.New(self, self.Comm96Slot.ImgMask)},
		{ "ID", UIBinderValueChangedCallback.New(self, nil, self.UpdateRedDot) },
	}
end

function CraftingLogListItemView:OnDestroy()
end

function CraftingLogListItemView:OnShow()
	UIUtil.SetIsVisible(self.Comm96Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.Comm96Slot.RichTextQuantity, false)
end

function CraftingLogListItemView:OnHide()
end

function CraftingLogListItemView:UpdateRedDot()
	if self.Params == nil then
		return
	end
	local Data = self.Params.Data
	if Data.ID == nil then
		return
	end	
	local RedDotName = CraftingLogMgr.ItemRedDotNameList and CraftingLogMgr.ItemRedDotNameList[Data.ID]
	if RedDotName then
		self.RedDot2:SetRedDotNameByString(RedDotName)
	else
		self.RedDot2:SetRedDotNameByString("")
	end	

	if Data.bSelect then
		self:DelRedDot()
	end
end

function CraftingLogListItemView:DelRedDot()
	local Data = self.Params.Data	
	if Data.ID == nil or table.is_nil_empty(CraftingLogMgr.ItemRedDotNameList) then
		return
	end	
	local RedDotName = CraftingLogMgr.ItemRedDotNameList[Data.ID]
	if RedDotName then
		local RedDot = _G.RedDotMgr:FindRedDotNodeByName(RedDotName)
		if RedDot then
			local isDel = _G.RedDotMgr:DelRedDotByName(RedDotName)
			if isDel then
				CraftingLogMgr.ItemRedDotNameList[Data.ID] = nil
				self.RedDot2:SetRedDotNameByString("")
				local ParentRedDot = RedDot.ParentRedDotNode
				if ParentRedDot.SubRedDotList == nil or #ParentRedDot.SubRedDotList == 0 then
					_G.RedDotMgr:DelRedDotByName(ParentRedDot.RedDotName)
					local HorNode = ParentRedDot.ParentRedDotNode
					local HorIndex = HorNode.HorIndex
					if HorIndex == nil or HorIndex == 1 then
						CraftingLogMgr:SendMsgRemoveDropNewData(Data.ItemData.Craftjob, ParentRedDot.DropDownIndex)
					elseif HorIndex == 2 then
						local ReadVersion = nil
						local Volume = 0
						if ParentRedDot.DropDownIndex ==  GatheringLogDefine.SpecialType.SpecialTypeCollection then
							ReadVersion = CraftingLogMgr:RoundFive(MajorUtil.GetMajorLevelByProf(Data.ItemData.Craftjob))
                            --CraftingLogMgr:SendMsgRemoveDropNewData(Data.ItemData.Craftjob, nil, ParentRedDot.DropDownIndex, ReadVersion,true)
                            CraftingLogMgr:SendMsgRemoveDropNewData(Data.ItemData.Craftjob, 100)
                            CraftingLogMgr.SpecialDropRedDotLists[Data.ItemData.Craftjob][3] = nil
                            CraftingLogMgr:SpecialRedDotDataUpdate(Data.ItemData.Craftjob)
						else
							ReadVersion = CraftingLogMgr.GameVersionNum
							if CraftingLogMgr.UseEsotericaProf[Data.ItemData.Craftjob][1] then
								--Volume = Volume|(1<<1)
                                CraftingLogMgr:SendMsgRemoveDropNewData(Data.ItemData.Craftjob, nil, ParentRedDot.DropDownIndex, ReadVersion,true, 1)
							end
							if CraftingLogMgr.UseEsotericaProf[Data.ItemData.Craftjob][2] then
								--Volume = Volume|(1<<2)
                                CraftingLogMgr:SendMsgRemoveDropNewData(Data.ItemData.Craftjob, nil, ParentRedDot.DropDownIndex, ReadVersion,true, 2)
							end
						end
						--CraftingLogMgr:SendMsgRemoveDropNewData(Data.ItemData.Craftjob, nil, ParentRedDot.DropDownIndex, ReadVersion,true, Volume)
					end
				end
			end
		end
	end
end

function CraftingLogListItemView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnAddFavor, self.OnFavorClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnBtnItemClicked)
    self.Comm96Slot:SetClickButtonCallback(self.Comm126Slot, self.OnSlotClicked)
end

function CraftingLogListItemView:OnFavorClicked()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	
	if ViewModel.bIsAFStarTrue == false  then
		return
	end
	CraftingLogMgr:SendMsgMarkOrNotinfo(ViewModel.ItemData.ID, not ViewModel.bIsAFStarTrue)
end

function CraftingLogListItemView:OnBtnItemClicked()
	local Params = self.Params
	if nil == Params then
		return
	end
	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	if CraftingLogMgr.NowPropData and ViewModel.ItemData.ID == CraftingLogMgr.NowPropData.ID then
		return
	end
	CraftingLogVM:PropItemOnClick(ViewModel.ItemData, CraftingLogMgr.CraftingState)
	_G.EventMgr:SendEvent(_G.EventID.CraftingLogUpdateItemAnim)

	--红点删除
	self:DelRedDot()
end

function CraftingLogListItemView:OnSlotClicked()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
    
	if not ViewModel.ItemID or ViewModel.ItemID == 0 then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ViewModel.ItemID, self)
end

function CraftingLogListItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.LeveQuestMarkedItem, self.OnLeveQuestMarkedItem)
	self:RegisterGameEvent(_G.EventID.LeveQuestCancelMarkedItem, self.OnLeveQuestCancelMarkedItem)
end

function CraftingLogListItemView:OnLeveQuestMarkedItem(ItemID)
	local VM = self.Params and self.Params.Data
	if VM and (VM.ProductID == ItemID or VM.HQProductIDD == ItemID) then
		self.ViewModel.bLeveQuestMarked = true
	end
end

function CraftingLogListItemView:OnLeveQuestCancelMarkedItem(ItemID)
	local VM = self.Params and self.Params.Data
	if VM and (VM.ProductID == ItemID or VM.HQProductIDD == ItemID) then
		self.ViewModel.bLeveQuestMarked = false
	end
end

function CraftingLogListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
    self.Comm96Slot:SetParams({Data = nil})
end

return CraftingLogListItemView
