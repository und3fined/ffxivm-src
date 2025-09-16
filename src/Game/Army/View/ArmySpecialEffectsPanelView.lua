---
--- Author: Administrator
--- DateTime: 2024-05-31 11:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local GlobalCfgType = ArmyDefine.GlobalCfgType
local ArmySpecialEffectsPanelVM = nil
local ArmyMgr
local UIViewMgr
local UIViewID
local ProtoRes = require("Protocol/ProtoRes")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local TipsUtil = require("Utils/TipsUtil")

---@class ArmySpecialEffectsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnHelp CommInforBtnView
---@field BtnPriceTips UFButton
---@field ImgArmyIcon UFImage
---@field ImgBG UFImage
---@field ImgMask UFImage
---@field MoneySlot CommMoneySlotView
---@field RichTextBuff URichTextBox
---@field RichTextPrice URichTextBox
---@field TableViewGet UTableView
---@field TableViewSkillList UTableView
---@field TableViewWorking UTableView
---@field TextBuff UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTitle02 UFTextBlock
---@field TextWorking UFTextBlock
---@field AnimBGID1 UWidgetAnimation
---@field AnimBGID2 UWidgetAnimation
---@field AnimBGID3 UWidgetAnimation
---@field AnimBGLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySpecialEffectsPanelView = LuaClass(UIView, true)

function ArmySpecialEffectsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnHelp = nil
	--self.BtnPriceTips = nil
	--self.ImgArmyIcon = nil
	--self.ImgBG = nil
	--self.ImgMask = nil
	--self.MoneySlot = nil
	--self.RichTextBuff = nil
	--self.RichTextPrice = nil
	--self.TableViewGet = nil
	--self.TableViewSkillList = nil
	--self.TableViewWorking = nil
	--self.TextBuff = nil
	--self.TextTitle = nil
	--self.TextTitle02 = nil
	--self.TextWorking = nil
	--self.AnimBGID1 = nil
	--self.AnimBGID2 = nil
	--self.AnimBGID3 = nil
	--self.AnimBGLoop = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.MoneySlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsPanelView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	UIViewID = _G.UIViewID
	UIViewMgr = _G.UIViewMgr
	ArmySpecialEffectsPanelVM = ArmyMainVM:GetArmySpecialEffectsPanelVM()
	---生效中的列表
	self.TableViewUsedBonusStateAdapter  = UIAdapterTableView.CreateAdapter(self, self.TableViewWorking)
	self.TableViewUsedBonusStateAdapter:SetOnClickedCallback(self.OnClickedUsedBonusStateItem)
	---特效组列表
	self.TableViewBonusStateGroupAdapter  = UIAdapterTableView.CreateAdapter(self, self.TableViewSkillList)
	self.TableViewBonusStateGroupAdapter:SetOnClickedCallback(self.OnClickedBonusStateGroupItem)
	---购买获取特效列表
	self.TableViewBonusStateAdapter  = UIAdapterTableView.CreateAdapter(self, self.TableViewGet)
	--self.TableViewBonusStateAdapter:SetOnClickedCallback(self.OnClickedBonusStateItem)
    self.Binders = {
        {"UsedBonusStateList", UIBinderUpdateBindableList.New(self, self.TableViewUsedBonusStateAdapter)}, 
		{"AllBonusStateGroupList", UIBinderUpdateBindableList.New(self, self.TableViewBonusStateGroupAdapter)}, 
        {"SelectedBonusStateList", UIBinderUpdateBindableList.New(self, self.TableViewBonusStateAdapter)}, 
		{"GainNum", UIBinderValueChangedCallback.New(self, nil, self.OnGainNumChanged)},
		{"CurBonusStateGroupName", UIBinderSetText.New(self, self.TextBuff)}, 
		{"CurBonusStateGroupDesc", UIBinderSetText.New(self, self.RichTextBuff)}, 
		{"BonusStateNumStr", UIBinderSetText.New(self, self.TextTitle02)}, 
		{"GrandTypeIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG)}, 
        {"GrandCompanyType", UIBinderValueChangedCallback.New(self, nil, self.OnGrandCompanyTypeChange)},
		{"BGMaskColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgMask) },
		{"GrandFlagIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgArmyIcon)}, 
		{"SaleText", UIBinderSetText.New(self, self.RichTextPrice)}, 
    }

	self.BtnBack:AddBackClick(self, self.OnClickedBtnBack)
	self.MoneySlot:SetIsHideTipsPanelOwn(true)
end

function ArmySpecialEffectsPanelView:OnDestroy()

end

function ArmySpecialEffectsPanelView:OnShow()
	-- LSTR string:部队特效
	self.TextTitle:SetText(LSTR(910257))
	-- LSTR string:当前生效
	self.TextWorking:SetText(LSTR(910323))
	--- 背景动画循环播放
	self:PlayAnimation(self.AnimBGLoop, 0, 0)
	if self.Params then
		self.IsOutOpen = self.Params.IsOutOpen
	end
end

function ArmySpecialEffectsPanelView:OnHide()
	ArmySpecialEffectsPanelVM:SetCurBonusStateGroupSelectedIndex()
end

function ArmySpecialEffectsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPriceTips, self.OnClickedBtnPrice)
end

function ArmySpecialEffectsPanelView:OnRegisterGameEvent()

end

function ArmySpecialEffectsPanelView:OnRegisterBinder()
    self:RegisterBinders(ArmySpecialEffectsPanelVM, self.Binders)
end

---生效中的列表item点击
function ArmySpecialEffectsPanelView:OnClickedUsedBonusStateItem(Index, ItemData, ItemView)
	ArmySpecialEffectsPanelVM:SetUsedBonusStateGroupSelected(Index,ItemData)
end
---特效组列表item点击
function ArmySpecialEffectsPanelView:OnClickedBonusStateGroupItem(Index, ItemData, ItemView)
	ArmySpecialEffectsPanelVM:SetBonusStateGroupSelected(Index)
end
---获取特效列表item点击
-- function ArmySpecialEffectsPanelView:OnClickedUsedBonusStateItem(Index, ItemData, ItemView)

-- end

function ArmySpecialEffectsPanelView:OnGainNumChanged(GainNum)
	local ScoreType = SCORE_TYPE.SCORE_TYPE_GROUP_PERFORMANCE
	self.MoneySlot:UpdateView(ScoreType, false, nil, true)
    self.MoneySlot.TextMoneyAmount:SetText(GainNum)
end

function ArmySpecialEffectsPanelView:OnClickedBtnBack()
	UIViewMgr:HideView(UIViewID.ArmySEPanel)
	if not self.IsOutOpen then
		ArmyMgr:OpenArmyMainPanel()
	end
end

function ArmySpecialEffectsPanelView:OnGrandCompanyTypeChange(GrandCompanyType)
    ---  部队背景动画处理
    if GrandCompanyType == ArmyDefine.GrandCompanyType.HeiWo then
        self:PlayAnimation(self.AnimBGID1)
    elseif GrandCompanyType == ArmyDefine.GrandCompanyType.ShuangShe then
        self:PlayAnimation(self.AnimBGID2)
    elseif GrandCompanyType == ArmyDefine.GrandCompanyType.HengHui then
        self:PlayAnimation(self.AnimBGID3)
    end
end



function ArmySpecialEffectsPanelView:OnClickedBtnPrice()
	if ArmySpecialEffectsPanelVM then
		local Data = ArmySpecialEffectsPanelVM:GetReputationTipsData()
		TipsUtil.ShowSimpleTipsView(Data, self.BtnPriceTips, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), false)
	end
end

return ArmySpecialEffectsPanelView