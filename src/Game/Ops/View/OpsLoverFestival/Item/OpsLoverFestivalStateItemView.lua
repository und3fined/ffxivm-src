---
--- Author: yutingzhan
--- DateTime: 2025-07-28 10:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")


---@class OpsLoverFestivalStateItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field Reward1 CommBackpack96SlotView
---@field Reward2 CommBackpack96SlotView
---@field Textnumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsLoverFestivalStateItemView = LuaClass(UIView, true)

function OpsLoverFestivalStateItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.Reward1 = nil
	--self.Reward2 = nil
	--self.Textnumber = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsLoverFestivalStateItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Reward1)
	self:AddSubView(self.Reward2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsLoverFestivalStateItemView:OnInit()

end

function OpsLoverFestivalStateItemView:OnDestroy()

end

function OpsLoverFestivalStateItemView:OnShow()
	UIUtil.SetIsVisible(self.Reward1.IconChoose, false)
	UIUtil.SetIsVisible(self.Reward2.IconChoose, false)
	UIUtil.SetIsVisible(self.Reward1.RichTextLevel, false)
	UIUtil.SetIsVisible(self.Reward2.RichTextLevel, false)
end

function OpsLoverFestivalStateItemView:OnHide()

end

function OpsLoverFestivalStateItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Reward1.Btn, self.OnClickReward1)
	UIUtil.AddOnClickedEvent(self, self.Reward2.Btn, self.OnClickReward2)
	UIUtil.AddOnClickedEvent(self, self.Reward1.BtnCheck, self.OnClickBtnCheck1)
	UIUtil.AddOnClickedEvent(self, self.Reward2.BtnCheck, self.OnClickBtnCheck2)
end

function OpsLoverFestivalStateItemView:OnRegisterGameEvent()

end

function OpsLoverFestivalStateItemView:OnRegisterBinder()

end

function OpsLoverFestivalStateItemView:OnClickReward1()
	local NodeData = self.NodeData
	if NodeData ~= nil then
		if NodeData.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
			OpsActivityMgr:SendActivityNodeGetReward(NodeData.ActivityNodeID)
		else
			ItemTipsUtil.ShowTipsByResID(NodeData.Rewards[1].ItemID, self.Reward1, nil, nil, 30)
		end
	end
end

function OpsLoverFestivalStateItemView:OnClickReward2()
	local NodeData = self.NodeData
	if NodeData ~= nil then
		if NodeData.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
			OpsActivityMgr:SendActivityNodeGetReward(NodeData.ActivityNodeID)
		else
			ItemTipsUtil.ShowTipsByResID(NodeData.Rewards[2].ItemID, self.Reward2, nil, nil, 30)
		end
	end
end

function OpsLoverFestivalStateItemView:OnClickBtnCheck1()
	_G.PreviewMgr:OpenPreviewView(self.NodeData.Rewards[1].ItemID)
end

function OpsLoverFestivalStateItemView:OnClickBtnCheck2()
	_G.PreviewMgr:OpenPreviewView(self.NodeData.Rewards[2].ItemID)
end

return OpsLoverFestivalStateItemView