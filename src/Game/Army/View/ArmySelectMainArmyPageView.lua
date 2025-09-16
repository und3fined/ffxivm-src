---
--- Author: daniel
--- DateTime: 2023-03-07 17:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ArmyChooseFlagItemVM = require("Game/Army/ItemVM/ArmyChooseFlagItemVM")
local UIUtil = require("Utils/UIUtil")

---@class ArmySelectMainArmyPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyChooseFlagItem_UIBP ArmyChooseFlagItemView
---@field ArmyChooseFlagItem_UIBP_1 ArmyChooseFlagItemView
---@field ArmyChooseFlagItem_UIBP_2 ArmyChooseFlagItemView
---@field BtnInfo CommInforBtnView
---@field BtnYes CommBtnLView
---@field ImgLine UFImage
---@field TextInfo UFTextBlock
---@field TextSubtitle UFTextBlock
---@field AnimCheck1 UWidgetAnimation
---@field AnimCheck2 UWidgetAnimation
---@field AnimCheck3 UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimInFlagID1 UWidgetAnimation
---@field AnimInFlagID2 UWidgetAnimation
---@field AnimInFlagID3 UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimReturn UWidgetAnimation
---@field AnimSelect1StartAtLeft UWidgetAnimation
---@field AnimSelect1StartAtRight UWidgetAnimation
---@field AnimSelect2StartAtLeft UWidgetAnimation
---@field AnimSelect2StartAtRight UWidgetAnimation
---@field AnimSelect3StartAtLeft UWidgetAnimation
---@field AnimSelect3StartAtRight UWidgetAnimation
---@field AnimSelectChange UWidgetAnimation
---@field ValueCheckIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySelectMainArmyPageView = LuaClass(UIView, true)

function ArmySelectMainArmyPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyChooseFlagItem_UIBP = nil
	--self.ArmyChooseFlagItem_UIBP_1 = nil
	--self.ArmyChooseFlagItem_UIBP_2 = nil
	--self.BtnInfo = nil
	--self.BtnYes = nil
	--self.ImgLine = nil
	--self.TextInfo = nil
	--self.TextSubtitle = nil
	--self.AnimCheck1 = nil
	--self.AnimCheck2 = nil
	--self.AnimCheck3 = nil
	--self.AnimIn = nil
	--self.AnimInFlagID1 = nil
	--self.AnimInFlagID2 = nil
	--self.AnimInFlagID3 = nil
	--self.AnimOut = nil
	--self.AnimReturn = nil
	--self.AnimSelect1StartAtLeft = nil
	--self.AnimSelect1StartAtRight = nil
	--self.AnimSelect2StartAtLeft = nil
	--self.AnimSelect2StartAtRight = nil
	--self.AnimSelect3StartAtLeft = nil
	--self.AnimSelect3StartAtRight = nil
	--self.AnimSelectChange = nil
	--self.ValueCheckIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySelectMainArmyPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyChooseFlagItem_UIBP)
	self:AddSubView(self.ArmyChooseFlagItem_UIBP_1)
	self:AddSubView(self.ArmyChooseFlagItem_UIBP_2)
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.BtnYes)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySelectMainArmyPageView:OnInit()
	self.FlagDataList = {}
	self.FlagViewList = 
	{
		LeftFlagView = self.ArmyChooseFlagItem_UIBP_1,
		MiddleFlagView = self.ArmyChooseFlagItem_UIBP,
		RightFlagView = self.ArmyChooseFlagItem_UIBP_2,
	}
	self:InitFlagViewData()
	self.Binders = {
		--{ "GrandCompanyName", UIBinderSetText.New(self, self.TextName)},
        { "GrandCompanyDesc", UIBinderSetText.New(self, self.TextInfo)},
        { "GrandLineIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgLine)},
	}
	self.AnimGuardTime = 0.5
	self.IsAnimGuardState = false
end

function ArmySelectMainArmyPageView:SetVM(VM)
	self.VM = VM
end

function ArmySelectMainArmyPageView:InitFlagViewData()
	for _, View in pairs(self.FlagViewList) do
		local ItemVM = ArmyChooseFlagItemVM.New()
		ItemVM:OnInit()
		View:SetItemVM(ItemVM)
		View:SetOnClickedCallback(self, self.OnFlagSelectChanged)
	end
end

function ArmySelectMainArmyPageView:SetFlagData()
	local ItemViewList = {}
	for _, View in pairs(self.FlagViewList) do
		table.insert(ItemViewList, View)
	end
	local DataList = self.VM:GetAllGrandCompanyData()
	for Index, Data in ipairs(DataList) do
		if ItemViewList and ItemViewList[Index] then
			ItemViewList[Index]:UpdateFlagData(Data)
		end
	end
end

function ArmySelectMainArmyPageView:SetSelectFlag(FlagView)
	if self.SelectedFlagView and FlagView then
		local AnimIndex = self:GetFlagViewAnimIndex(FlagView)
		local OldAnimIndex = self:GetFlagViewAnimIndex(FlagView)
		self:PlayFlagViewSwitchAnim(AnimIndex, OldAnimIndex)	
	end
	self.SelectedFlagView = FlagView
	self.VM:SetSelectedGrandCompanyID(self.SelectedFlagView:GetFlagID())
	self.VM.SetBGCallbak(self.SelectedFlagView:GetFlagID())
end

function ArmySelectMainArmyPageView:SetSelectFlagByID(ID)
	local OldFlagView = self.SelectedFlagView
	self.VM:SetSelectedGrandCompanyID(ID)
	self.SelectedFlagView = self:GetFlagViewByID(ID) or self.FlagViewList.MiddleFlagView
	if self.SelectedFlagView and OldFlagView then
		local AnimIndex = self:GetFlagViewAnimIndex(self.SelectedFlagView)
		local OldAnimIndex = self:GetFlagViewAnimIndex(OldFlagView)
		self:PlayFlagViewSwitchAnim(AnimIndex, OldAnimIndex)
	end
	self.VM.SetBGCallbak(ID)
end

function ArmySelectMainArmyPageView:GetFlagViewByID(ID)
	for _, View in pairs(self.FlagViewList) do
		if ID == View:GetFlagID() then
			return View
		end
	end
end

function ArmySelectMainArmyPageView:OnFlagSelectChanged(ID)
	---防止动画问题，短时间不接受第二次点击
	if self.IsAnimGuardState then
		return
	end
	self.IsAnimGuardState = true
	self:RegisterTimer( function()
		self.IsAnimGuardState = false
	end,
	self.AnimGuardTime)

	self:SetSelectFlagByID(ID)
	for _, FlagView in pairs(self.FlagViewList) do
		if FlagView == self.SelectedFlagView then
			FlagView:SetIsSelected(true)
		else
			FlagView:SetIsSelected(false)
		end
	end
end

function ArmySelectMainArmyPageView:SetSelectCallBack(Owner, SelectCallBack)
	self.Owner = Owner
	self.SelectCallBack = SelectCallBack
end

function ArmySelectMainArmyPageView:OnDestroy()

end

function ArmySelectMainArmyPageView:OnShow()
	-- LSTR string:请选择大国防联军
	self.TextSubtitle:SetText(LSTR(910321))
	if self.VM == nil then
		return
	end
	self:SetFlagData()
	self:SetSelectFlag(self.FlagViewList.MiddleFlagView)
	-- if self.IsPlayAnimInFlag then
	-- 	self:PlayAnimInFlag()
	-- 	self.IsPlayAnimInFlag = false
	-- end
	self.IsAnimGuardState = false
	self:OnFlagSelectChanged(self.FlagViewList.MiddleFlagView:GetFlagID())
	if self.VM:GetIsPlayAnimReturn() then
		self:PlayAnimation(self.AnimReturn)
		self.VM:SetIsPlayAnimReturn(false)
	end

	-- LSTR string:确定选择
	self.BtnYes:SetText(LSTR(910184))
end


function ArmySelectMainArmyPageView:FlagSortRandomly()
	self.VM:FlagSortRandomly()
end

function ArmySelectMainArmyPageView:OnHide()
	self.IsAnimGuardState = false
end

function ArmySelectMainArmyPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnYes, self.OnClickedBtnYes)
end

function ArmySelectMainArmyPageView:OnClickedBtnYes()
	if self.VM and self.SelectCallBack then
		if self.SelectedFlagView then
			local AnimIndex = self:GetFlagViewAnimIndex(self.SelectedFlagView)
			self.SwitchAnimName = string.format("AnimCheck%d", AnimIndex)
			self:PlayAnimation(self[self.SwitchAnimName])
			--local HideTime = self[AnimName]:GetEndTime()
        	--self:RegisterTimer(self.OpenEditPanel, HideTime, HideTime, 1)
		end
	end
end

function ArmySelectMainArmyPageView:OpenEditPanel()
	if self.VM and self.SelectCallBack then
		self.SelectCallBack(self.Owner, self.VM:GetSelectedGrandCompanyID())
	end
end

function ArmySelectMainArmyPageView:OnRegisterGameEvent()

end

function ArmySelectMainArmyPageView:OnRegisterBinder()
	if self.VM == nil then
		return
	end
	self:RegisterBinders(self.VM, self.Binders)
end

function ArmySelectMainArmyPageView:GetFlagViewAnimIndex(FlagView)
	local AnimIndex = 0
	if FlagView == self.FlagViewList.LeftFlagView then
		AnimIndex = 1
	elseif FlagView == self.FlagViewList.MiddleFlagView then
		AnimIndex = 2
	elseif FlagView == self.FlagViewList.RightFlagView then
		AnimIndex = 3
	end
	return AnimIndex
end

function ArmySelectMainArmyPageView:PlayFlagViewSwitchAnim(PlayIndex, OldIndex)
	if PlayIndex and PlayIndex ~= 0 and OldIndex then
		local AnimName
		---初始在左边
		if OldIndex - PlayIndex == 1 or OldIndex - PlayIndex == -2 then
			AnimName = string.format("AnimSelect%dStartAtLeft", PlayIndex)
		---初始在右边
		elseif OldIndex - PlayIndex == -1 or OldIndex - PlayIndex == 2 then
			AnimName = string.format("AnimSelect%dStartAtRight", PlayIndex)
		end
		if AnimName then
			self:PlayAnimation(self[AnimName])
			self.CurFlagAnim = self[AnimName]
		end
	end
end

-- function ArmySelectMainArmyPageView:PlayAnimReturn()
-- 	self:PlayAnimation(self.AnimReturn)
-- end

--- ArmySelectMainArmyPageView是靠绑定触发显示的，onshow比ArmyCreatePanelView先触发，这里已经有选中数据了
function ArmySelectMainArmyPageView:PlayAnimInFlag()
	if self.VM then
		local GrandCompanyID = self.VM:GetSelectedGrandCompanyID()
		self:PlayAnimation(self[string.format("AnimInFlagID%d", GrandCompanyID)])
	end
end

function ArmySelectMainArmyPageView:OnAnimationFinished(Anim)
	if self.SwitchAnimName and self[self.SwitchAnimName] == Anim then
		if self.CurFlagAnim and self:IsAnimationPlaying(self.CurFlagAnim) then
			self:StopAnimation(self.CurFlagAnim)
			--self:PlayAnimation(self.CurFlagAnim)
			--UIUtil.PlayAnimationTimePointPct(self, self.CurFlagAnim, 1, 1, _G.UE.EUMGSequencePlayMode.Forward, 1, false)
		end
		self:OpenEditPanel()
	end
end

-- function ArmySelectMainArmyPageView:SetIsPlayAnimInFlag(IsPlayAnimInFlag)
-- 	self.IsPlayAnimInFlag = IsPlayAnimInFlag
-- end

return ArmySelectMainArmyPageView