---
--- Author: Administrator
--- DateTime: 2024-12-18 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsCrystalSunmmoingVM = require("Game/Ops/VM/OpsCrystalSunmmoingVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local UIViewMgr = require("UI/UIViewMgr")
local EventID = require("Define/EventID")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local NodeType = ProtoRes.Game.ActivityNodeType
local NodeOpType = ProtoCS.Game.Activity.NodeOpType
local EToggleButtonState = _G.UE.EToggleButtonState

local TabDefine = {
	TaskTab = 1,
	InviteTab = 2,
}

local ActType = {
	Invitee = 1,
	Inviter = 2,
}
---@class OpsCrystalSunmmoingPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBinding CommBtnLView
---@field BtnCopy UFButton
---@field BtnCopyMyInviteCode CommBtnLView
---@field Comm96Slot CommBackpack96SlotView
---@field CommonRedDotTab1 CommonRedDotView
---@field CommonRedDotTab2 CommonRedDotView
---@field IconState UFImage
---@field InputBox CommInputBoxView
---@field OpsActivityPreviewBtn_UIBP OpsActivityPreviewBtnView
---@field OpsActivityTime OpsActivityTimeItemView
---@field PanelBound UFCanvasPanel
---@field PanelCall UFCanvasPanel
---@field PanelCallBG UFCanvasPanel
---@field PanelInviteList UFCanvasPanel
---@field PanelInviter UFCanvasPanel
---@field PanelTaskList UFCanvasPanel
---@field PanelTitle UFVerticalBox
---@field PanelUnbound UFCanvasPanel
---@field RichTextBound URichTextBox
---@field TableViewInviteList UTableView
---@field TableViewTaskList UTableView
---@field TextAddition UFTextBlock
---@field TextBindingHint UFTextBlock
---@field TextInfo UFTextBlock
---@field TextInvitationCodeNumber2 UFTextBlock
---@field TextInviteCode UFTextBlock
---@field TextInvited UFTextBlock
---@field TextLevel UFTextBlock
---@field TextMyInviteCode UFTextBlock
---@field TextOnline UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTab1 UFTextBlock
---@field TextTab2 UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTitleCall UFTextBlock
---@field Time OpsActivityTimeItemView
---@field ToggleBtnTab1 UToggleButton
---@field ToggleBtnTab2 UToggleButton
---@field AnimChangeTab UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCrystalSunmmoingPanelView = LuaClass(UIView, true)

function OpsCrystalSunmmoingPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBinding = nil
	--self.BtnCopy = nil
	--self.BtnCopyMyInviteCode = nil
	--self.Comm96Slot = nil
	--self.CommonRedDotTab1 = nil
	--self.CommonRedDotTab2 = nil
	--self.IconState = nil
	--self.InputBox = nil
	--self.OpsActivityPreviewBtn_UIBP = nil
	--self.OpsActivityTime = nil
	--self.PanelBound = nil
	--self.PanelCall = nil
	--self.PanelCallBG = nil
	--self.PanelInviteList = nil
	--self.PanelInviter = nil
	--self.PanelTaskList = nil
	--self.PanelTitle = nil
	--self.PanelUnbound = nil
	--self.RichTextBound = nil
	--self.TableViewInviteList = nil
	--self.TableViewTaskList = nil
	--self.TextAddition = nil
	--self.TextBindingHint = nil
	--self.TextInfo = nil
	--self.TextInvitationCodeNumber2 = nil
	--self.TextInviteCode = nil
	--self.TextInvited = nil
	--self.TextLevel = nil
	--self.TextMyInviteCode = nil
	--self.TextOnline = nil
	--self.TextSubTitle = nil
	--self.TextTab1 = nil
	--self.TextTab2 = nil
	--self.TextTitle = nil
	--self.TextTitleCall = nil
	--self.Time = nil
	--self.ToggleBtnTab1 = nil
	--self.ToggleBtnTab2 = nil
	--self.AnimChangeTab = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCrystalSunmmoingPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBinding)
	self:AddSubView(self.BtnCopyMyInviteCode)
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.CommonRedDotTab1)
	self:AddSubView(self.CommonRedDotTab2)
	self:AddSubView(self.InputBox)
	self:AddSubView(self.OpsActivityPreviewBtn_UIBP)
	-- self:AddSubView(self.OpsActivityTime)
	-- self:AddSubView(self.Time)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCrystalSunmmoingPanelView:OnInit()
	self.ViewModel = OpsCrystalSunmmoingVM.New()
	self.InputBox:SetCallback(self, self.OnBindInputBoxTextChanged)
	
	self.TaskTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTaskList)
	self.InviteTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewInviteList)
	self.Binders = {
		{"StrParamText1", UIBinderSetText.New(self, self.OpsActivityPreviewBtn_UIBP.Text01)},
		{"StrParamText2", UIBinderSetText.New(self, self.OpsActivityPreviewBtn_UIBP.Text02)},
		{"TaskVMList", UIBinderUpdateBindableList.New(self, self.TaskTableViewAdapter)},
		{"InviteVMList", UIBinderUpdateBindableList.New(self, self.InviteTableViewAdapter)},
    }
end

function OpsCrystalSunmmoingPanelView:OnRegisterBinder()
	if self.ViewModel then
		self:RegisterBinders(self.ViewModel, self.Binders)
	end
end

function OpsCrystalSunmmoingPanelView:OnShow()
	if not self.Params then return end

	self.ViewModel:Update(self.Params)
	self:SetActContentShow()
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextTab1, "0000007F")
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextTab2, "0000007F")
end

function OpsCrystalSunmmoingPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCopy, self.OnClickCopy)
	UIUtil.AddOnClickedEvent(self, self.BtnBinding, self.OnClickBind)
	UIUtil.AddOnClickedEvent(self, self.Comm96Slot.Btn, self.OnClickItemTips)
	UIUtil.AddOnClickedEvent(self, self.BtnCopyMyInviteCode, self.OnClickInvite)
	UIUtil.AddOnClickedEvent(self, self.OpsActivityPreviewBtn_UIBP.BtnView, self.OnClickPreview)
	UIUtil.AddOnClickedEvent(self, self.OpsActivityTime.InforBtn.BtnInfor, self.OnClickBtnInfor)
	UIUtil.AddOnClickedEvent(self, self.Time.InforBtn.BtnInfor, self.OnClickBtnInfor)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnTab1, self.OnCommTabIndexChanged, 1)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnTab2, self.OnCommTabIndexChanged, 2)
end

function OpsCrystalSunmmoingPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.UpdateOriginDataShow)
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.UpdateOriginDataShow)
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OpsActivityUpdateInfo)
	self:RegisterGameEvent(EventID.OpsActivityReportSuccess, self.OnReportSuccess)
	self:RegisterGameEvent(EventID.LootItemUpdateRes, self.OnLootItemUpdateRes)
	self:RegisterGameEvent(EventID.FriendUpdate, self.UpdateInviteListBtnState)
end

function OpsCrystalSunmmoingPanelView:UpdateOriginDataShow()
	local NodeData = OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID)
	if NodeData and NodeData.NodeList then
		self.Params.NodeList = NodeData.NodeList
	end

	self.ViewModel:Update(self.Params)
end

function OpsCrystalSunmmoingPanelView:OnReportSuccess()
	if self.ViewModel.ShareRewardStatus and self.ViewModel.ShareRewardStatus ~= ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		OpsActivityMgr:SendQueryActivity(self.Params.ActivityID)
	end
end

function OpsCrystalSunmmoingPanelView:UpdateInviteListBtnState()
	if self.CacheInviteRoleData and next(self.CacheInviteRoleData) then
		self.ViewModel:SetInviteList(self.CacheInviteRoleData)
	end
end

function OpsCrystalSunmmoingPanelView:OnLootItemUpdateRes(InLootList, InReason)
	if not InLootList or not next(InLootList) then return end
	if not string.find(InReason, "Activity") then return end

	local TaskData = self.ViewModel and self.ViewModel.TaskData or {}
	local ItemList = {}
	for i, v in ipairs(TaskData) do
		if string.find(InReason, tostring(v.NodeID)) then
			local LOOT_TYPE = ProtoCS.LOOT_TYPE
   			for k, v in pairs(InLootList) do
        		if v.Type == LOOT_TYPE.LOOT_TYPE_ITEM then 
        		    table.insert(ItemList, {ResID = v.Item.ResID, Num = v.Item.Value})
        		elseif v.Type == LOOT_TYPE.LOOT_TYPE_SCORE then 
        		    table.insert(ItemList, {ResID = v.Score.ResID, Num = v.Score.Value})
        		end
			end

			break
		end
	end

    if next(ItemList) then
        UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, {ItemList = ItemList})
    end
end

function OpsCrystalSunmmoingPanelView:OpsActivityUpdateInfo(MsgBody)
	self:UpdateOriginDataShow()
	
	if not MsgBody then return end
	local NodeOperate = MsgBody.NodeOperate or {}
	if NodeOperate.OpType == NodeOpType.NodeOpTypeBindCallCode then
		local Activity = self.Params and self.Params.Activity or {}
		self:RefreshInviteeContent(Activity)
		self:RefreshBindReward()

		local BindReward = self.ViewModel:GetBindReward()
		local Data = {
			ResID = BindReward.ItemID,
			Num = BindReward.Num
		}
	
		UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, {ItemList = {[1] = Data}})
	end
	
	if NodeOperate.OpType == NodeOpType.NodeOpTypePullBindRole then
		local Result = NodeOperate.Result or {}
		local ParamsType = Result.Data or "BindAccount"
		local RoleData = Result[ParamsType] and Result[ParamsType].BindRole or {}

		self.TextInvited:SetText(string.format(LSTR(100069), #RoleData, self.ViewModel:GetBindTotalNum()))
		self.CacheInviteRoleData = RoleData
		self.ViewModel:SetInviteList(RoleData)
	end

	if NodeOperate.OpType == NodeOpType.NodeOpTypeUnBindInvitee then
		OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.GetInviteListNodeID, NodeOpType.NodeOpTypePullBindRole, {})
		MsgTipsUtil.ShowTips(LSTR(100100))
	end
end

function OpsCrystalSunmmoingPanelView:RefreshToggleBtnState()
	self.ToggleBtnTab1:SetCheckedState(self.SelectTabIndex == TabDefine.TaskTab and EToggleButtonState.Checked or EToggleButtonState.Unchecked)
	self.ToggleBtnTab2:SetCheckedState(self.SelectTabIndex == TabDefine.InviteTab and EToggleButtonState.Checked or EToggleButtonState.Unchecked)
	local NomalColorHex = "FFFFFF"
	local SelectColorHex = "b3b3b3" 
	UIUtil.TextBlockSetOutlineSize(self.TextTab1, self.SelectTabIndex == TabDefine.TaskTab and 2 or 0)
	UIUtil.TextBlockSetOutlineSize(self.TextTab2, self.SelectTabIndex == TabDefine.InviteTab and 2 or 0)
	UIUtil.SetColorAndOpacityHex(self.TextTab1, self.SelectTabIndex == TabDefine.TaskTab and NomalColorHex or SelectColorHex)
	UIUtil.SetColorAndOpacityHex(self.TextTab2, self.SelectTabIndex == TabDefine.InviteTab and NomalColorHex or SelectColorHex)
end

function OpsCrystalSunmmoingPanelView:OnCommTabIndexChanged(Index)
	if not self.SelectTabIndex or self.SelectTabIndex ~= Index then
		self.SelectTabIndex = Index
		self:RefreshToggleBtnState()
	else
		self:RefreshToggleBtnState()
		return
	end

	self:PlayAnimation(self.AnimChangeTab)
	if Index == TabDefine.InviteTab then
		UIUtil.SetIsVisible(self.PanelInviteList, true)
		UIUtil.SetIsVisible(self.PanelTaskList, false)
		OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.GetInviteListNodeID, NodeOpType.NodeOpTypePullBindRole, {})
	else
		UIUtil.SetIsVisible(self.PanelTaskList, true)
		UIUtil.SetIsVisible(self.PanelInviteList, false)
	end
end

function OpsCrystalSunmmoingPanelView:OnBindInputBoxTextChanged(Text, Len)
	self.InputBox:SetText(Text)
end

function OpsCrystalSunmmoingPanelView:OnClickItemTips()
	local ItemTipsUtil = require("Utils/ItemTipsUtil")
	local RewardData = self.ViewModel:GetBindReward()
	local ResID = RewardData.ItemID
	ItemTipsUtil.ShowTipsByResID(ResID, self.Comm96Slot)
end

function OpsCrystalSunmmoingPanelView:OnClickInvite()
	if CommonUtil.IsInternationalChina() then
		if self.ViewModel.ShareRewardStatus and self.ViewModel.ShareRewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
			OpsActivityMgr:SendActivityEventReport(NodeType.ActivityNodeTypeShareInviterCode, self.ViewModel.ShareParams)
		end
		
		DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, 2)
		_G.ShareMgr:ShareCrystalSummon("sCode="..(self.ViewModel:GetInviteCode() or ""), "")
	else
		CommonUtil.ClipboardCopy(string.format(LSTR(100070), self.ViewModel:GetInviteCode()))
		MsgTipsUtil.ShowTips(LSTR(100071))
		DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, 3)
	end
end

function OpsCrystalSunmmoingPanelView:OnClickPreview()
	if self.ViewModel and self.ViewModel.PreviewMonutID then
		UIViewMgr:ShowView(_G.UIViewID.PreviewMountView, {MountId = self.ViewModel.PreviewMonutID})
	end
end

function OpsCrystalSunmmoingPanelView:OnClickBtnInfor()
	local HelpInfoUtil = require("Utils/HelpInfoUtil")
	HelpInfoUtil.ShowHelpInfo(self.Time.InforBtn)
end

function OpsCrystalSunmmoingPanelView:OnClickCopy()
	CommonUtil.ClipboardCopy(string.format(LSTR(100070), self.ViewModel:GetInviteCode()))
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, 3)
    MsgTipsUtil.ShowTips(LSTR(100071))
end

function OpsCrystalSunmmoingPanelView:OnClickBind()
	local InviteCodeStr = self.InputBox:GetText()
	if string.isnilorempty(InviteCodeStr) then
		MsgTipsUtil.ShowTips(LSTR(100072))
	else
		MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(100073), LSTR(100074), function()
			local Data = {InviterCode = InviteCodeStr}
			OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.BindNodeID, NodeOpType.NodeOpTypeBindCallCode, {BindInviterCode = Data})
		end)
	end
end

function OpsCrystalSunmmoingPanelView:SetActContentShow()
	local Activity = self.Params and self.Params.Activity or {}
	local IsInviteeType = self.ViewModel:IsInviteeType()

	UIUtil.SetIsVisible(self.PanelCall, IsInviteeType)
	UIUtil.SetIsVisible(self.OpsActivityTime, IsInviteeType)
	UIUtil.SetIsVisible(self.PanelInviter, not IsInviteeType)
	UIUtil.SetIsVisible(self.PanelTitle, not IsInviteeType)
	UIUtil.SetIsVisible(self.OpsActivityPreviewBtn_UIBP, not IsInviteeType)
	UIUtil.SetIsVisible(self.PanelCallBG, IsInviteeType)
	if IsInviteeType then
		self:RefreshInviteeContent(Activity)
	else
		self:SetInviterContent(Activity)
		self:OnCommTabIndexChanged(TabDefine.TaskTab)
	end

	self:InitTimeHelpInfoShow()
end

function OpsCrystalSunmmoingPanelView:InitTimeHelpInfoShow()
	self.OpsActivityTime.TextTime:SetText(LSTR(100093))
	self.Time.TextTime:SetText(LSTR(100093))

	local Activity = self.Params and self.Params.Activity or {}
	if Activity and Activity.ChinaActivityHelpInfoID and Activity.ChinaActivityHelpInfoID > 0 then
		UIUtil.SetIsVisible(self.OpsActivityTime.BtnInfo, true)
		UIUtil.SetIsVisible(self.Time.BtnInfo, true)
		self.OpsActivityTime.InforBtn:SetHelpInfoID(Activity.ChinaActivityHelpInfoID)
		self.Time.InforBtn:SetHelpInfoID(Activity.ChinaActivityHelpInfoID)
	else
		UIUtil.SetIsVisible(self.OpsActivityTime.BtnInfo, false)
		UIUtil.SetIsVisible(self.Time.BtnInfo, false)
	end
end

function OpsCrystalSunmmoingPanelView:RefreshInviteeContent(Activity)
	self.TextTitleCall:SetText(Activity.Title or "")
	self.TextInfo:SetText(Activity.SubTitle or "")
	local BindCode = self.ViewModel:GetHasBindInviteCode()
	UIUtil.SetIsVisible(self.PanelBound, BindCode ~= "")
	UIUtil.SetIsVisible(self.PanelUnbound, BindCode == "")
	self:RefreshBindReward()
	if BindCode ~= "" then
		self.RichTextBound:SetText(string.format(LSTR(100075), BindCode))
		self.BtnBinding:SetText(LSTR(100076))
		self.BtnBinding:SetIsDisabledState(true)
	else
		self.InputBox:SetHintText(LSTR(100077))
		self.TextInviteCode:SetText(LSTR(100078))
		self.BtnBinding:SetText(LSTR(100079))
		self.BtnBinding:SetIsRecommendState(true)
		self.TextBindingHint:SetText(LSTR(100080))
	end
end

function OpsCrystalSunmmoingPanelView:SetInviterContent(Activity)
	self:InitCommonTab()
	self.TextTitle:SetText(Activity.Title or "")
	self.TextSubTitle:SetText(Activity.SubTitle or "")
	self.TextLevel:SetText(LSTR(100081))
	self.TextOnline:SetText(LSTR(100082))
	self.TextMyInviteCode:SetText(LSTR(100083))
	self.BtnCopyMyInviteCode:SetText(LSTR(100084))
	self.TextInvitationCodeNumber2:SetText(self.ViewModel:GetInviteCode())
	local IsChinaVersion = _G.CommonUtil.IsInternationalChina()
	UIUtil.SetIsVisible(self.BtnCopy, IsChinaVersion, true)
	if not IsChinaVersion then
		self.BtnCopyMyInviteCode:SetText(LSTR(100092))
	end
end

function OpsCrystalSunmmoingPanelView:InitCommonTab()
	self.CommonRedDotTab1:SetRedDotNameByString(OpsActivityMgr:GetRedDotName(self.Params.Activity.ClassifyID, self.Params.ActivityID))
	self.TextTab1:SetText(LSTR(100085))
	self.TextTab2:SetText(LSTR(100086))
end

function OpsCrystalSunmmoingPanelView:RefreshBindReward()
	local RewardData = self.ViewModel:GetBindReward()
	local ItemCfg = require("TableCfg/ItemCfg")
	local ItemUtil = require("Utils/ItemUtil")
	local ResID = RewardData.ItemID
	local Cfg = ItemCfg:FindCfgByKey(ResID) or {}
	local ImgPath = Cfg.IconID and ItemCfg.GetIconPath(Cfg.IconID) or ""
	self.Comm96Slot:SetIconImg(ImgPath)
	self.Comm96Slot:SetQualityImg(ItemUtil.GetItemColorIcon(ResID))
	self.Comm96Slot:SetNum(RewardData.Num)
	UIUtil.SetIsVisible(self.Comm96Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm96Slot.RichTextLevel, false)
	self.TextAddition:SetText(LSTR(100087))
	local BindCode = self.ViewModel:GetHasBindInviteCode()
	local IsRecieved = not string.isnilorempty(BindCode)
	UIUtil.SetIsVisible(self.Comm96Slot.IconReceived, IsRecieved)
	UIUtil.SetIsVisible(self.Comm96Slot.ImgMask, IsRecieved)
end

function OpsCrystalSunmmoingPanelView:OnHide()
	self.SelectTabIndex = nil
end

function OpsCrystalSunmmoingPanelView:OnDestroy()

end

return OpsCrystalSunmmoingPanelView