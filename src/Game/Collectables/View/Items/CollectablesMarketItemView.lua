---
--- Author: Administrator
--- DateTime: 2025-03-04 15:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local CollectablesVM = require("Game/Collectables/CollectablesVM")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CollectablesMgr = require("Game/Collectables/CollectablesMgr")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ProtoCommon = require("Protocol/ProtoCommon")

local ProfessType = ProtoCommon.prof_type
local EToggleButtonState = _G.UE.EToggleButtonState


---@class CollectablesMarketItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfor CommInforBtnView
---@field FHorizontalStar UFHorizontalBox
---@field FImage_177 UFImage
---@field FImage_93 UFImage
---@field ImgItemTicket UFImage
---@field ItemSlot74 CommBackpack74SlotView
---@field PanelSubmit UFCanvasPanel
---@field RedDot CommonRedDot2View
---@field SizeBox1 USizeBox
---@field SizeBox2 USizeBox
---@field SizeBox3 USizeBox
---@field TextItemLevel UFTextBlock
---@field TextItemName UFTextBlock
---@field TextItemNum UFTextBlock
---@field TextItemReward UFTextBlock
---@field TextItemValue UFTextBlock
---@field ToggleBtnItem UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CollectablesMarketItemView = LuaClass(UIView, true)

function CollectablesMarketItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfor = nil
	--self.FHorizontalStar = nil
	--self.FImage_177 = nil
	--self.FImage_93 = nil
	--self.ImgItemTicket = nil
	--self.ItemSlot74 = nil
	--self.PanelSubmit = nil
	--self.RedDot = nil
	--self.SizeBox1 = nil
	--self.SizeBox2 = nil
	--self.SizeBox3 = nil
	--self.TextItemLevel = nil
	--self.TextItemName = nil
	--self.TextItemNum = nil
	--self.TextItemReward = nil
	--self.TextItemValue = nil
	--self.ToggleBtnItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CollectablesMarketItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnInfor)
	self:AddSubView(self.ItemSlot74)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CollectablesMarketItemView:OnInit()
	UIUtil.SetIsVisible(self.FHorizontalStar, true)
    UIUtil.SetIsVisible(self.ItemSlot74.IconChoose, false)
    UIUtil.SetIsVisible(self.ItemSlot74.RichTextLevel, false)
    UIUtil.SetIsVisible(self.ItemSlot74.RichTextQuantity, false)
    UIUtil.SetIsVisible(self.ItemSlot74.IconReceived, false)
	self.ItemSlot74:SetClickButtonCallback(self, self.ItemSlotClickCallback)
    self.Binders = {
        {"Name", UIBinderSetText.New(self, self.TextItemName)},
        {"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ItemSlot74.Icon)},
        {"TicketIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgItemTicket)},
        {"CollectionLevel", UIBinderSetText.New(self, self.TextItemLevel)},
        {"CollectValueRange", UIBinderSetText.New(self, self.TextItemValue)},
        {"TicketRewardText", UIBinderSetText.New(self, self.TextItemReward)},
        {"HoldingNum", UIBinderValueChangedCallback.New(self, nil, self.OnHoldingNumChanged)},
        {"bIsSelect", UIBinderValueChangedCallback.New(self, nil, self.OnIsSelectChanged)},
        {"bSelect", UIBinderSetIsVisible.New(self, self.BtnInfor)},
        {"StarLevel", UIBinderValueChangedCallback.New(self, nil, self.StarLevelChanged)},
		{"ID", UIBinderValueChangedCallback.New(self, nil, self.OnIDChanged)},
    }
    self.BtnInfor:SetButtonStyle(HelpInfoUtil.HelpInfoType.Tips)
end

function CollectablesMarketItemView:OnDestroy()

end

function CollectablesMarketItemView:OnShow()

end

function CollectablesMarketItemView:OnHide()

end

function CollectablesMarketItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnItem, self.OnToggleBtnItemClick)
    --UIUtil.AddOnClickedEvent(self, self.BtnInfor.BtnInfor, self.OnBtnInforClick)
    self.BtnInfor:SetCallback(self, self.OnBtnInforClick)
end

function CollectablesMarketItemView:OnRegisterGameEvent()

end

function CollectablesMarketItemView:OnRegisterBinder()
	local Params = self.Params or {}
    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    self.ViewMode = ViewModel
    self:RegisterBinders(ViewModel, self.Binders)
end

---@type 点击选中该收藏品
function CollectablesMarketItemView:OnToggleBtnItemClick()
    local ViewModel = self.ViewMode
    if nil == ViewModel then
        return
    end
   
    local LastSelectData = CollectablesMgr.LastSelectData
    local ID = ViewModel.ID
    local CutID = LastSelectData.CollectIDMap[LastSelectData.ProfID]
    if CutID ~= ID then 
        CollectablesVM:OnSelectChanged(ID)
    end
end

---@type 点击展开获得的奖励列表
function CollectablesMarketItemView:OnBtnInforClick()
    local ViewModel = self.ViewMode
    if nil == ViewModel then
        return
    end
    --传过去点击的哪个按钮
    CollectablesMgr.ClickBtn = self.BtnInfor

    local NeedCollectablesTransactionData = self:SetFormatAndGetData()
    CollectablesVM:UpdateRewardList(NeedCollectablesTransactionData)

    EventMgr:SendEvent(EventID.SetBtnShutWinVisibleEvent)
    --显示报酬并且更新位置
    local TipsView = UIViewMgr:ShowView(UIViewID.CollectablesTransactionTipsView)
    if TipsView then
        local TipsSize = UIUtil.GetWidgetSize(TipsView.PanelTips)
        local BtnSize = UIUtil.GetWidgetSize(self.BtnInfor)
        local InOffste = _G.UE.FVector2D(-TipsSize.X -BtnSize.X -20 , 0) 
        TipsUtil.AdjustTipsPosition(TipsView, self.BtnInfor, InOffste, _G.UE.FVector2D(0, 0))    
    end
end

---@type 设置格式并返回需要的数据
function CollectablesMarketItemView:SetFormatAndGetData()
    local ViewModel = self.ViewMode
    if nil == ViewModel then
        return
    end
    --{1, 10, 20} 转化成 {1~9, 10~19, 20~} LV = LowValue, MV = MidValue, HV = HighValue
    local NeedCollectablesTransactionData = {}
    local RebuildCollectValue = {}
    local DefaultMax = 1000
    local VMCollectValue = ViewModel.CollectValue
    local LVIndex = 1
    local MVIndex = 2
    local HVIndex = 3
    RebuildCollectValue[LVIndex] = string.format("%s~%s", VMCollectValue[LVIndex], VMCollectValue[MVIndex] - 1)
    RebuildCollectValue[MVIndex] = string.format("%s~%s", VMCollectValue[MVIndex], VMCollectValue[HVIndex] - 1)
    RebuildCollectValue[HVIndex] = string.format("%s~", VMCollectValue[HVIndex])
    local LastSelectData = CollectablesMgr.LastSelectData
    local SelectProfID = LastSelectData.ProfID
    if SelectProfID == ProfessType.PROF_TYPE_MINER or SelectProfID == ProfessType.PROF_TYPE_BOTANIST then
        RebuildCollectValue[HVIndex] = DefaultMax
    end
    local CollectValue = RebuildCollectValue
    local LowTicketReward = ViewModel.LowTicketReward
    local HighTicketReward = ViewModel.HighTicketReward
    local ExperienceReward = ViewModel.ExperienceReward
    for i = 1, #CollectValue do
        local TempTable = {}
        TempTable.CollectValue = CollectValue[i]
        TempTable.LowTicketReward = LowTicketReward[i]
        TempTable.HighTicketReward = HighTicketReward[i]
        TempTable.ExperienceReward = ExperienceReward[i]
        TempTable.TicketIcon = ViewModel.TicketIcon
        TempTable.bIsMaxLevelCollect = ViewModel.bIsMaxLevelCollect
        table.insert(NeedCollectablesTransactionData, TempTable)
    end
    return NeedCollectablesTransactionData
end

--收藏星级变动
function CollectablesMarketItemView:StarLevelChanged(NewValue)
    for i = 1, self.FHorizontalStar:GetChildrenCount() do
        UIUtil.SetIsVisible(self.FHorizontalStar:GetChildAt(i - 1), false)
    end
    if NewValue < 0 or NewValue > 3 then
        return
    end
    for i = 1, NewValue do
        UIUtil.SetIsVisible(self.FHorizontalStar:GetChildAt(i - 1), true)
    end
end

function CollectablesMarketItemView:ItemSlotClickCallback()
    local ViewModel = self.ViewMode
    if nil ~= ViewModel then
		ItemTipsUtil.ShowTipsByResID(ViewModel.ID, self.ItemSlot74,  {X =0, Y = 0}, nil)
    end
end

function CollectablesMarketItemView:OnHoldingNumChanged(NewValue)
	self.TextItemNum:SetText(tostring(NewValue))
	UIUtil.SetIsVisible(self.PanelSubmit, NewValue > 0 )
end

function CollectablesMarketItemView:OnIDChanged()
    local ViewModel = self.ViewMode
    if nil ~= ViewModel then
		local RedDotName = ""
		if CollectablesMgr:CheckRedDot(ViewModel.ID) then
			RedDotName = CollectablesMgr:GetRedDotName(ViewModel.ID)
		end
		self.RedDot:SetRedDotNameByString(RedDotName)
	end
end

function CollectablesMarketItemView:OnIsSelectChanged(NewValue, OldValue)
    self.ToggleBtnItem:SetCheckedState(NewValue)
    if NewValue == EToggleButtonState.Checked then
        local ViewModel = self.ViewMode
        if nil == ViewModel then
            return
        end
        local ID = ViewModel.ID
        CollectablesMgr:RemoveRedDot(ID)
        self.RedDot:SetRedDotNameByString("")
    end
end

return CollectablesMarketItemView