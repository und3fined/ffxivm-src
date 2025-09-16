---
--- Author: yutingzhan
--- DateTime: 2024-12-16 17:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local OpsPhoneBindingPanelVM = require("Game/Ops/VM/OpsPhoneBindingPanelVM")

---@class OpsPhoneBindingPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field BtnLAgree CommBtnLView
---@field BtnLRelease CommBtnLView
---@field BtnMBinding CommBtnMView
---@field BtnMRelease CommBtnMView
---@field FTextBlock_283 URichTextBox
---@field GetVerificationCode CommBtnSView
---@field InputBoxPhoneNumber CommInputBoxView
---@field InputBoxVerificationCode CommInputBoxView
---@field PanelBound UFCanvasPanel
---@field PanelBtn2 UFCanvasPanel
---@field PanelSent UFCanvasPanel
---@field PanelUnbound UFCanvasPanel
---@field PanelVerificationCode UFCanvasPanel
---@field SlotFist CommBackpack152SlotView
---@field SlotPerMonth CommBackpack152SlotView
---@field TextBindPhone UFTextBlock
---@field TextContent UFTextBlock
---@field TextFirst UFTextBlock
---@field TextHint UFTextBlock
---@field TextPerMonth UFTextBlock
---@field TextPhoneNumber UFTextBlock
---@field TextTitle UFTextBlock
---@field TextVerificationCode UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsPhoneBindingPanelView = LuaClass(UIView, true)

local LSTR = _G.LSTR
function OpsPhoneBindingPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.BtnLAgree = nil
	--self.BtnLRelease = nil
	--self.BtnMBinding = nil
	--self.BtnMRelease = nil
	--self.FTextBlock_283 = nil
	--self.GetVerificationCode = nil
	--self.InputBoxPhoneNumber = nil
	--self.InputBoxVerificationCode = nil
	--self.PanelBound = nil
	--self.PanelBtn2 = nil
	--self.PanelSent = nil
	--self.PanelUnbound = nil
	--self.PanelVerificationCode = nil
	--self.SlotFist = nil
	--self.SlotPerMonth = nil
	--self.TextBindPhone = nil
	--self.TextContent = nil
	--self.TextFirst = nil
	--self.TextHint = nil
	--self.TextPerMonth = nil
	--self.TextPhoneNumber = nil
	--self.TextTitle = nil
	--self.TextVerificationCode = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

local TotalVerifyTime = 60
function OpsPhoneBindingPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnLAgree)
	self:AddSubView(self.BtnLRelease)
	self:AddSubView(self.BtnMBinding)
	self:AddSubView(self.BtnMRelease)
	self:AddSubView(self.GetVerificationCode)
	self:AddSubView(self.InputBoxPhoneNumber)
	self:AddSubView(self.InputBoxVerificationCode)
	self:AddSubView(self.SlotFist)
	self:AddSubView(self.SlotPerMonth)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsPhoneBindingPanelView:OnInit()
	UIUtil.SetIsVisible(self.SlotFist.RichTextLevel, false)
	UIUtil.SetIsVisible(self.SlotPerMonth.RichTextLevel, false)
	UIUtil.SetIsVisible(self.SlotFist.IconChoose, false)
	UIUtil.SetIsVisible(self.SlotPerMonth.IconChoose, false)

	self.TextFirst:SetText(LSTR(100050))	--首次绑定
	self.TextPerMonth:SetText(LSTR(100051))	--每月验证
	self.TextPhoneNumber:SetText(LSTR(100052))	--手机号：
	self.TextVerificationCode:SetText(LSTR(100053))	--验证码：
	self.ViewModel = OpsPhoneBindingPanelVM.New()
	self.Binders = {
        {"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextHint", UIBinderSetText.New(self, self.TextHint)},
		{"FirstBindRewardNum", UIBinderSetText.New(self, self.SlotFist.RichTextQuantity)},
		{"PerMonthRewardNum", UIBinderSetText.New(self, self.SlotPerMonth.RichTextQuantity)},
		{"FirstRewardNumVisiable", UIBinderSetIsVisible.New(self, self.SlotFist.RichTextQuantity)},
		{"MonthRewardNumVisiable", UIBinderSetIsVisible.New(self, self.SlotPerMonth.RichTextQuantity)},
		{"FirstBindRewardIcon", UIBinderSetBrushFromAssetPath.New(self, self.SlotFist.Icon)},
		{"FirstBindRewardImgQuality", UIBinderSetBrushFromAssetPath.New(self, self.SlotFist.ImgQuanlity)},
		{"FirstBindRewardReceieved", UIBinderSetIsVisible.New(self, self.SlotFist.IconReceived)},
		{"FirstBindRewardReceieved", UIBinderSetIsVisible.New(self, self.SlotFist.ImgMask)},
		{"MonthRewardReceieved", UIBinderSetIsVisible.New(self, self.SlotPerMonth.IconReceived)},
		{"MonthRewardReceieved", UIBinderSetIsVisible.New(self, self.SlotPerMonth.ImgMask)},
		{"PerMonthRewardIcon", UIBinderSetBrushFromAssetPath.New(self, self.SlotPerMonth.Icon)},
		{"PerMonthRewardImgQuality", UIBinderSetBrushFromAssetPath.New(self, self.SlotPerMonth.ImgQuanlity)},
		{"PanelBoundVisiable", UIBinderSetIsVisible.New(self, self.PanelBound)},
		{"PanelUnboundVisiable", UIBinderSetIsVisible.New(self, self.PanelUnbound)},
		{"PanelBtn2Visiable", UIBinderSetIsVisible.New(self, self.PanelBtn2)},
		{"BtnLReleaseVisiable", UIBinderSetIsVisible.New(self, self.BtnLRelease)},
		{"PanelVerificationVisiable", UIBinderSetIsVisible.New(self, self.PanelVerificationCode)},
		{"TextBindPhone", UIBinderSetText.New(self, self.TextBindPhone)},
		{"PhoneBindInfo", UIBinderSetText.New(self, self.FTextBlock_283)},
		{ "FirstBindRewardAvailable", UIBinderSetIsVisible.New(self, self.SlotFist.PanelAvailable) },
		{ "MonthRewardAvailable", UIBinderSetIsVisible.New(self, self.SlotPerMonth.PanelAvailable) },
    }
end

function OpsPhoneBindingPanelView:OnDestroy()

end

function OpsPhoneBindingPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self.GetVerificationCode:SetText(LSTR(100046))	--获取验证码
	self.BtnLAgree:SetButtonText(LSTR(100047))	--同意并绑定
	self.BtnLRelease:SetButtonText(LSTR(100048))	--解除绑定
	self.BtnMBinding:SetButtonText(LSTR(100049))	--绑定手机
	self.BtnMRelease:SetButtonText(LSTR(100048))	--解除绑定
	self.InputBoxVerificationCode:SetHintText(LSTR(100054))	--请输入验证码
	self.InputBoxPhoneNumber:SetHintText(LSTR(100055))	--请输入手机号
	self.InputBoxVerificationCode.PreviewHintTextColor = true
	self.InputBoxPhoneNumber.PreviewHintTextColor = true
	self.ViewModel:Update(self.Params)
	local RedDotName = OpsActivityDefine.RedDotName .. '/' .. self.ViewModel.ClassifyID .. '/' .. self.ViewModel.ActivityID .. '/' .. "Month"
	self.SlotPerMonth.RedDot2:SetRedDotNameByString(RedDotName )
	OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.PhoneBindNodeID, ProtoCS.Game.Activity.NodeOpType.NodeOpTypePhoneBindAgreements, {})

end

function OpsPhoneBindingPanelView:OnHide()
    self:UnRegisterVerifyTimeID()
end

function OpsPhoneBindingPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.SlotFist.Btn, self.OnClickFirstReward)
	UIUtil.AddOnClickedEvent(self,  self.SlotPerMonth.Btn, self.OnClickMonthReward)
	UIUtil.AddOnClickedEvent(self,  self.BtnLAgree, self.OnClickBtnAgreeBind)
	UIUtil.AddOnClickedEvent(self,  self.GetVerificationCode, self.OnClickGetVerificationCode)
	UIUtil.AddOnClickedEvent(self,  self.BtnLRelease, self.OnClickBtnLRelease)
	UIUtil.AddOnClickedEvent(self,  self.BtnMRelease, self.OnClickBtnMRelease)
	UIUtil.AddOnClickedEvent(self,  self.BtnMBinding, self.OnClickBtnMBind)
	UIUtil.AddOnClickedEvent(self,  self.BtnCheck, self.OnBtnCheck)
	UIUtil.AddOnHyperlinkClickedEvent(self, self.FTextBlock_283, self.OnHyperlinkClicked)
end

function OpsPhoneBindingPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.UpdatePhoneBind)
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.UpdateNodeGetReward)
end

function OpsPhoneBindingPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsPhoneBindingPanelView:OnHyperlinkClicked(_, LinkID)
	if tonumber(LinkID) == 1 then
		self.IsUnbindAll = false
	elseif tonumber(LinkID) == 2 then
		self.IsUnbindAll = true
	end
	self:SetUnBindAuthState()
end

function OpsPhoneBindingPanelView:OnClickFirstReward()
	if self.ViewModel.FirstBindRewardAvailable then
		_G.LootMgr:SetDealyState(true)
		OpsActivityMgr:SendActivityGetReward(self.ViewModel.ActivityID)
	else
		ItemTipsUtil.ShowTipsByResID(self.ViewModel.FirstBindRewardItemID, self.SlotFist, nil, nil, 30)
	end
end

function OpsPhoneBindingPanelView:OnClickMonthReward()
	if self.ViewModel.MonthRewardAvailable then
		_G.LootMgr:SetDealyState(true)
		OpsActivityMgr:SendActivityGetReward(self.ViewModel.ActivityID)
	else
		ItemTipsUtil.ShowTipsByResID(self.ViewModel.PerMonthRewardItemID, self.SlotPerMonth, nil, nil, 30)
	end
end

function OpsPhoneBindingPanelView:OnClickGetVerificationCode()
	if self.ViewModel.PhoneBindData == nil then
		return
	end
	if self.ViewModel.PhoneBindData.Status == OpsActivityDefine.BindState.Expired then
		self:SendVerificationCode(self.ViewModel.PhoneBindData.PhoneNum, ProtoCS.Game.Activity.PhoneBindMode.PhoneBindMode_Renew)
	elseif self.ViewModel.PhoneBindData.Status == OpsActivityDefine.BindState.Binded then
		self:SendVerificationCode(self.ViewModel.PhoneBindData.PhoneNum, ProtoCS.Game.Activity.PhoneBindMode.PhoneBindMode_Unbind)
	elseif self.ViewModel.PhoneBindData.Status == OpsActivityDefine.BindState.None then
		local PhoneNumber = self.InputBoxPhoneNumber:GetText()
		if PhoneNumber == "" then
			MsgTipsUtil.ShowTips(LSTR(100056))	--请输入绑定手机号
		elseif not self:IsValidPhoneNumber(PhoneNumber) then
			MsgTipsUtil.ShowTips(LSTR(100057))	--请输入正确手机号
		else
			self:SendVerificationCode(PhoneNumber, ProtoCS.Game.Activity.PhoneBindMode.PhoneBindMode_Bind)
		end
	end
end

function OpsPhoneBindingPanelView:SendVerificationCode(PhoneNumber, Mode)
	local Data = {Phone = PhoneNumber, Mode = Mode}
	OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.PhoneBindNodeID, 
	ProtoCS.Game.Activity.NodeOpType.NodeOpTypePhoneBindCode, {PhoneBindCode = Data})
end

function OpsPhoneBindingPanelView:SetSendVerificationBtnStatus()
	UIUtil.SetIsVisible(self.GetVerificationCode, false)
	UIUtil.SetIsVisible(self.PanelSent, true)
	if self.VerifyTimeID == nil then
		self.ReminVerifyTime = TotalVerifyTime
		self.VerifyTimeID = self:RegisterTimer(self.UpdateVerificationBtnTime, 0, 1, 0)
	end
end

function OpsPhoneBindingPanelView:UpdateVerificationBtnTime()
	self.ReminVerifyTime = self.ReminVerifyTime - 1
	self.TextContent:SetText(string.format(LSTR(100059), self.ReminVerifyTime))	--%s秒
	if self.ReminVerifyTime <= 0 then
		self:UnRegisterVerifyTimeID()
	end
end

function OpsPhoneBindingPanelView:UnRegisterVerifyTimeID()
	if self.VerifyTimeID then
		self:UnRegisterTimer(self.VerifyTimeID)
		self.VerifyTimeID = nil
		UIUtil.SetIsVisible(self.GetVerificationCode, true)
		UIUtil.SetIsVisible(self.PanelSent, false)
	end
end

function OpsPhoneBindingPanelView:AuthOperate(Mode)
	if self.ViewModel.PhoneBindData == nil then
		return
	end
	local VerifyCode = self.InputBoxVerificationCode:GetText()
	local Data = {Code = VerifyCode, Mode = Mode}
	if self.ViewModel.PhoneBindData.Status == OpsActivityDefine.BindState.None then
		local PhoneNumber = self.InputBoxPhoneNumber:GetText()
		if PhoneNumber == "" then
			MsgTipsUtil.ShowTips(LSTR(100056))	--请输入绑定手机号
		elseif not self:IsValidPhoneNumber(PhoneNumber) then
			MsgTipsUtil.ShowTips(LSTR(100057))	--请输入正确手机号
		elseif VerifyCode == "" then
			MsgTipsUtil.ShowTips(LSTR(100060))	--请输入手机验证码
		else
			OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.PhoneBindNodeID, 
			ProtoCS.Game.Activity.NodeOpType.NodeOpTypePhoneBindAuth, {PhoneBindAuth = Data})
		end
	else
		if VerifyCode == "" then
			MsgTipsUtil.ShowTips(LSTR(100060))	--请输入手机验证码
		else
			if Mode == ProtoCS.Game.Activity.PhoneBindMode.PhoneBindMode_Unbind then
				Data.UnbindAll = self.IsUnbindAll
				local Msg = ""
				if self.IsUnbindAll then
					Msg = self.ViewModel.Agreements["UnbindGameConfirmation"]
				else
					Msg = self.ViewModel.Agreements["UnbindChannelConfirmation"]
				end
				MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(100048), Msg, --解除绑定后，将无法及时接收游戏活动、更新等消息，确定要解除绑定吗？
				function ()
					OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.PhoneBindNodeID, ProtoCS.Game.Activity.NodeOpType.NodeOpTypePhoneBindAuth, {PhoneBindAuth = Data})
				end, 
				function ()
					if self.ViewModel.PhoneBindData.Status == OpsActivityDefine.BindState.Expired then
						UIViewMgr:HideView(UIViewID.CommonMsgBox)
					else
						self:SetCancelUnbind()
					end
				end)
			else
				OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.PhoneBindNodeID, 
			ProtoCS.Game.Activity.NodeOpType.NodeOpTypePhoneBindAuth, {PhoneBindAuth = Data})
			end
		end
	end
end

function OpsPhoneBindingPanelView:OnClickBtnAgreeBind()
	self:AuthOperate(ProtoCS.Game.Activity.PhoneBindMode.PhoneBindMode_Bind)
end

function OpsPhoneBindingPanelView:OnClickBtnMBind()
	if self.BtnMBinding:GetText() == LSTR(100049) then	--绑定手机
		self:AuthOperate(ProtoCS.Game.Activity.PhoneBindMode.PhoneBindMode_Renew)
	else
		self:AuthOperate(ProtoCS.Game.Activity.PhoneBindMode.PhoneBindMode_Unbind)
	end
end

function OpsPhoneBindingPanelView:OnClickBtnMRelease()
	if self.BtnMRelease:GetText() == LSTR(10003) then	--取 消
		self:SetCancelUnbind()
	else
		self:AuthOperate(ProtoCS.Game.Activity.PhoneBindMode.PhoneBindMode_Unbind)
	end
end

function OpsPhoneBindingPanelView:SetCancelUnbind()
	self.ViewModel.PanelBtn2Visiable = false
	self.ViewModel.BtnLReleaseVisiable = true
	self.ViewModel.PanelVerificationVisiable = false
end

function OpsPhoneBindingPanelView:OnClickBtnLRelease()
	self.IsUnbindAll = false
	self:SetUnBindAuthState()
end

function OpsPhoneBindingPanelView:SetUnBindAuthState()
	self.ViewModel.PanelBtn2Visiable = true
	self.ViewModel.BtnLReleaseVisiable = false
	self.ViewModel.PanelVerificationVisiable = true
	self.BtnMRelease:SetButtonText(LSTR(10003))	--取 消
	self.BtnMBinding:SetButtonText(LSTR(100048))	--解除绑定
	self.InputBoxVerificationCode:SetText("")
end

function OpsPhoneBindingPanelView:OnBtnCheck()
	_G.PreviewMgr:OpenPreviewView(self.ViewModel.FirstBindRewardItemID)
end

function OpsPhoneBindingPanelView:UpdatePhoneBind(MsgBody)
	if MsgBody == nil or MsgBody.NodeOperate == nil then
		return
	end
	local NodeOperate = MsgBody.NodeOperate
	if NodeOperate.OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypePhoneBindAuth then
		self:UnRegisterVerifyTimeID()
		self.ViewModel:UpdatePhoneBindState(self.Params)
		if self.ViewModel.PhoneBindData == nil then
			return
		end
		if self.ViewModel.PhoneBindData.Status == OpsActivityDefine.BindState.Binded or 
			not self.ViewModel.PhoneBindData.Status == OpsActivityDefine.BindState.Expired then
			MsgTipsUtil.ShowTips(LSTR(100063),nil,1)	--手机号绑定成功
		elseif self.ViewModel.PhoneBindData.Status == OpsActivityDefine.BindState.None then
			--MsgTipsUtil.ShowTips(LSTR(100064))	--手机号解绑成功
			local Msg = ""
			if self.IsUnbindAll then
				Msg = self.ViewModel.Agreements["UnbindGameResult"]
			else
				Msg = self.ViewModel.Agreements["UnbindChannelResult"]
			end
			MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(100121), Msg)	--解绑成功弹窗
			self.InputBoxPhoneNumber:SetText("")
			self.InputBoxVerificationCode:SetText("")
		end
	elseif NodeOperate.OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypePhoneBindCode then
		self.ViewModel:UpdatePhoneBindData(self.Params)
		MsgTipsUtil.ShowTips(LSTR(100065))	--已发送手机验证码，请注意查收
		self:SetSendVerificationBtnStatus()
	elseif NodeOperate.OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypePhoneBindAgreements then
		local Result = NodeOperate.Result
		if Result == nil or Result.PhoneBindAgreements == nil then
			return
		end
		self.ViewModel.Agreements = Result.PhoneBindAgreements.Agreements
		self.ViewModel.Version = Result.PhoneBindAgreements.Version
		self.ViewModel:UpdatePhoneBindState(self.Params)
	end
end

function OpsPhoneBindingPanelView:UpdateNodeGetReward()
	local Rewards  = {}
	if self.ViewModel.FirstBindRewardAvailable then
		table.insert(Rewards, {ResID = self.ViewModel.FirstBindRewardItemID, Num = tonumber(self.ViewModel.FirstBindRewardNum), ShowReceived = true})
	end

	if self.ViewModel.MonthRewardAvailable then
		table.insert(Rewards, {ResID = self.ViewModel.PerMonthRewardItemID, Num = tonumber(self.ViewModel.PerMonthRewardAmount), ShowReceived = true})
	end

	if #Rewards > 0 then
		local Params = {}
		Params.ShowBtn = false
		Params.ItemList = Rewards
		UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, Params)
	end

	self:UpdateRewardStatus()
end


function OpsPhoneBindingPanelView:UpdateRewardStatus()
	if self.Params and self.Params.NodeList then
        local ActivityNodeList = self.Params.NodeList
        for _, v in ipairs(ActivityNodeList) do
            if v.Head.NodeID == self.ViewModel.FirstBindNodeID then
                self.ViewModel.FirstBindRewardStatus = v.Head.RewardStatus
            elseif v.Head.NodeID == self.ViewModel.PerMonthNodeID then
                self.ViewModel.PerMonthRewardStatus = v.Head.RewardStatus
            end
        end
		self.ViewModel:UpdateRewardStatus(self.ViewModel.FirstBindRewardStatus, self.ViewModel.PerMonthRewardStatus)
    end
end


function OpsPhoneBindingPanelView:IsValidPhoneNumber(phoneNumber)
    if #phoneNumber ~= 11 then
        return false
    end

    if phoneNumber:sub(1, 1) ~= '1' then
        return false
    end

    for i = 1, #phoneNumber do
        local char = phoneNumber:sub(i, i)
        if not char:match("%d") then
            return false
        end
    end

    return true
end

return OpsPhoneBindingPanelView