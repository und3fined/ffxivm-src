---
--- Author: Administrator
--- DateTime: 2024-10-25 16:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local ItemUtil = require("Utils/ItemUtil")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local DataReportUtil = require("Utils/DataReportUtil")
local ReportButtonType = require("Define/ReportButtonType")

---@class OpsActivityShareTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field FCanvasPanel_17 UFCanvasPanel
---@field IconGold UFImage
---@field IconGoldSizeBox USizeBox
---@field IconShare UFImage
---@field IconShareSizeBox USizeBox
---@field ImgBG UFImage
---@field RichText URichTextBox
---@field BG Color LinearColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityShareTipsItemView = LuaClass(UIView, true)

function OpsActivityShareTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.FCanvasPanel_17 = nil
	--self.IconGold = nil
	--self.IconGoldSizeBox = nil
	--self.IconShare = nil
	--self.IconShareSizeBox = nil
	--self.ImgBG = nil
	--self.RichText = nil
	--self.BG Color = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityShareTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityShareTipsItemView:OnInit()

end

function OpsActivityShareTipsItemView:OnDestroy()

end


function OpsActivityShareTipsItemView:OnShow()
	if self.Params == nil or self.Params.NodeList == nil then
		return
	end
	local ShareNode, ShareNodeCfg = self:GetShareCommonNodeInfo()

	UIUtil.SetIsVisible(self.FCanvasPanel_17, ShareNode ~= nil and ShareNodeCfg ~= nil)
	if ShareNode and  ShareNodeCfg then
		if ShareNode.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
			self.RichText:SetText(_G.LSTR(970008))
			UIUtil.SetIsVisible(self.IconGold, false)
		else
			self.RichText:SetText(ShareNodeCfg.NodeDesc)
			if ShareNodeCfg.Rewards[1] and ShareNodeCfg.Rewards[1].ItemID and ShareNodeCfg.Rewards[1].ItemID > 0 then
				local IconPath = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ShareNodeCfg.Rewards[1].ItemID))
				UIUtil.ImageSetBrushFromAssetPath( self.IconGold, IconPath) 
				UIUtil.SetIsVisible(self.IconGold, true)
			else
				UIUtil.SetIsVisible(self.IconGold, false)
			end
		end
	end
end

function OpsActivityShareTipsItemView:GetShareCommonNodeInfo()
	if self.Params == nil then
		return
	end

    local NodeList = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypePictureShare)
	for _, Node in ipairs(NodeList) do
		local NodeID  = Node.Head.NodeID
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
		if NodeCfg.ParamNum < 2 or NodeCfg.Params[2] == 1 then
			return Node, NodeCfg
		end
	end

    return
end

function OpsActivityShareTipsItemView:OnHide()
	
end

function OpsActivityShareTipsItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickShareBtn)
end

function OpsActivityShareTipsItemView:OnClickShareBtn()
	if self.Params and self.Params.ActivityID then
		local ShareNode, ShareNodeCfg = self:GetShareCommonNodeInfo()
		if ShareNodeCfg and ShareNodeCfg.Params then
			_G.ShareMgr:OpenShareActivityUI(self.Params.ActivityID, ShareNodeCfg.Params[1])
			DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.OpsActivityShare), "0", self.Params.ActivityID)
		end
	end
end

function OpsActivityShareTipsItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ShareOpsActivitySuccess, self.OnShareOpsActivitySuccess)
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.OnShow)

end


function OpsActivityShareTipsItemView:OnRegisterBinder()

end

function OpsActivityShareTipsItemView:OnShareOpsActivitySuccess(Param)
	if Param == nil then
		return 
	end
	if self.Params and self.Params.ActivityID == Param.ActivityID then
		local ShareNode, ShareNodeCfg = self:GetShareCommonNodeInfo()
		if ShareNodeCfg then
			_G.OpsActivityMgr:SendActivityEventReport(ActivityNodeType.ActivityNodeTypePictureShare, ShareNodeCfg.Params)
		end
	end
end

return OpsActivityShareTipsItemView