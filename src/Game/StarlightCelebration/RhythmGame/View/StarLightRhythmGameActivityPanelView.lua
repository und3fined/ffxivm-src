---
--- Author: Administrator
--- DateTime: 2025-08-14 19:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ItemUtil = require("Utils/ItemUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require ("Protocol/ProtoRes")
local EventID = require("Define/EventID")

local EASY_NODE_ID = 2507210112
local HARD_NODE_ID = 2507210113

---@class StarLightRhythmGameActivityPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field BtnGo UFButton
---@field BtnGo2 UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommBackpack96Slot CommBackpack96SlotView
---@field CommBackpack96Slot2 CommBackpack96SlotView
---@field CommMoney CommMoneySlotView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field TextBtn UFTextBlock
---@field TextBtn2 UFTextBlock
---@field TextDifficult UFTextBlock
---@field TextNomal UFTextBlock
---@field TextReward UFTextBlock
---@field TextReward2 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StarLightRhythmGameActivityPanelView = LuaClass(UIView, true)

function StarLightRhythmGameActivityPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.BtnGo = nil
	--self.BtnGo2 = nil
	--self.CloseBtn = nil
	--self.CommBackpack96Slot = nil
	--self.CommBackpack96Slot2 = nil
	--self.CommMoney = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.TextBtn = nil
	--self.TextBtn2 = nil
	--self.TextDifficult = nil
	--self.TextNomal = nil
	--self.TextReward = nil
	--self.TextReward2 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StarLightRhythmGameActivityPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommBackpack96Slot)
	self:AddSubView(self.CommBackpack96Slot2)
	self:AddSubView(self.CommMoney)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StarLightRhythmGameActivityPanelView:OnInit()

end

function StarLightRhythmGameActivityPanelView:OnDestroy()
end

function StarLightRhythmGameActivityPanelView:OnShow()
	local LSTR = _G.LSTR
	self.TextTitle:SetText(LSTR(1710021))
	self.TextNomal:SetText(LSTR(1710022))
	self.TextDifficult:SetText(LSTR(1710023))
	self.TextReward:SetText(LSTR(1710024))
	self.TextReward2:SetText(LSTR(1710024))
	self.TextBtn:SetText(LSTR(1710025))
	self.TextBtn2:SetText(LSTR(1710025))
	
	--self.CommMoney:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS, false, nil, true)
	UIUtil.SetIsVisible(self.CommMoney, false)
	self:UpdateAward(EASY_NODE_ID, self.CommBackpack96Slot, "EasyAwardItemID")
	self:UpdateAward(HARD_NODE_ID, self.CommBackpack96Slot2, "HardAwardItemID")
end

function StarLightRhythmGameActivityPanelView:OnHide()

end

function StarLightRhythmGameActivityPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickBtnEasy)
	UIUtil.AddOnClickedEvent(self, self.BtnGo2, self.OnClickBtnHard)

	self.CommBackpack96Slot:SetClickButtonCallback(self, self.OnBtnItemClickedEasy)
	self.CommBackpack96Slot2:SetClickButtonCallback(self, self.OnBtnItemClickedHard)
end

function StarLightRhythmGameActivityPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MapFollowAdd, self.Hide)
end

function StarLightRhythmGameActivityPanelView:OnRegisterBinder()

end

function StarLightRhythmGameActivityPanelView:UpdateAward(NodeID, SlotUI, AwardIDField)
	local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
	if not NodeCfg or #NodeCfg.Rewards < 1 then
		return
	end

	local Reward = NodeCfg.Rewards[1]
	local ItemID = Reward.ItemID
	local Num = Reward.Num

	self[AwardIDField] = ItemID

	-- 更新UI
	local Cfg = ItemCfg:FindCfgByKey(ItemID)
	if Cfg then
		SlotUI:SetIconImg(UIUtil.GetIconPath(Cfg.IconID))
		SlotUI:SetNumVisible(true)
		SlotUI:SetNum(Num)
		SlotUI:SetQualityImg(ItemUtil.GetItemColorIcon(ItemID))
	end

	SlotUI:CommSetVisible(SlotUI.RedDot2, false)
	SlotUI:CommSetVisible(SlotUI.RichTextLevel, false)
	SlotUI:CommSetVisible(SlotUI.IconChoose, false)
end

function StarLightRhythmGameActivityPanelView:OnBtnItemClickedEasy(ItemView)
	if self.EasyAwardItemID and self.EasyAwardItemID > 0 then
		ItemTipsUtil.ShowTipsByResID(self.EasyAwardItemID, ItemView, _G.UE4.FVector2D(0, 0))
	end
end

function StarLightRhythmGameActivityPanelView:OnBtnItemClickedHard(ItemView)
	if self.HardAwardItemID and self.HardAwardItemID > 0 then
		ItemTipsUtil.ShowTipsByResID(self.HardAwardItemID, ItemView, _G.UE4.FVector2D(0, 0))
	end
end

function StarLightRhythmGameActivityPanelView:OnClickBtnEasy()
	local NodeID = 2507210112
	local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
	if NodeCfg then
		_G.OpsActivityMgr:Jump(NodeCfg.JumpType, NodeCfg.JumpParam)
	end
end

function StarLightRhythmGameActivityPanelView:OnClickBtnHard()
	local NodeID = 2507210113
	local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
	if NodeCfg then
		_G.OpsActivityMgr:Jump(NodeCfg.JumpType, NodeCfg.JumpParam)
	end
end

return StarLightRhythmGameActivityPanelView