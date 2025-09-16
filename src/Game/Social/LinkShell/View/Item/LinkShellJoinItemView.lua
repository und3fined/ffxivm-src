---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local TipsUtil = require("Utils/TipsUtil")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LinkshellDefineCfg = require("TableCfg/LinkshellDefineCfg")

local LSTR = _G.LSTR
local FVector2D = _G.UE.FVector2D
local RECRUITING_SET = LinkShellDefine.RECRUITING_SET

---@class LinkShellJoinItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChat UFButton
---@field BtnJoin UFButton
---@field HorizontalBtn UFHorizontalBox
---@field ImgJoinGrey UFImage
---@field ImgJoinNormal UFImage
---@field TableViewActivity UTableView
---@field TextManifesto UFTextBlock
---@field TextMem UFTextBlock
---@field TextName UFTextBlock
---@field TextTips UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellJoinItemView = LuaClass(UIView, true)

function LinkShellJoinItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChat = nil
	--self.BtnJoin = nil
	--self.HorizontalBtn = nil
	--self.ImgJoinGrey = nil
	--self.ImgJoinNormal = nil
	--self.TableViewActivity = nil
	--self.TextManifesto = nil
	--self.TextMem = nil
	--self.TextName = nil
	--self.TextTips = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellJoinItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellJoinItemView:OnInit()
	self.TableAdapterActivity = UIAdapterTableView.CreateAdapter(self, self.TableViewActivity, self.OnSelectChangedAct, true)

	self.Binders = {
		{ "Name", 		UIBinderSetText.New(self, 			self.TextName) },
		{ "MemDesc", 	UIBinderSetText.New(self, 			self.TextMem) },
		{ "StrTips", 	UIBinderSetText.New(self, 			self.TextTips) },
		{ "Manifesto", 	UIBinderSetText.New(self, 			self.TextManifesto) },
		{ "ActVMList", 	UIBinderUpdateBindableList.New(self, self.TableAdapterActivity) },

		{ "IsAllowPrivateChat", UIBinderSetIsVisible.New(self, self.BtnChat, false, true) },
		{ "IsApplyCD", UIBinderSetIsVisible.New(self, self.ImgJoinGrey) },
		{ "IsApplyCD", UIBinderSetIsVisible.New(self, self.ImgJoinNormal, true) },
		{ "IsShowJoinBtn", UIBinderSetIsVisible.New(self, self.HorizontalBtn) },
	}
end

function LinkShellJoinItemView:OnDestroy()

end

function LinkShellJoinItemView:OnShow()

end

function LinkShellJoinItemView:OnHide()

end

function LinkShellJoinItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnJoin, self.OnClickButtonJoin)
    UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnClickButtonChat)
end

function LinkShellJoinItemView:OnRegisterGameEvent()

end

function LinkShellJoinItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel 
	self:RegisterBinders(ViewModel, self.Binders)
end

function LinkShellJoinItemView:OnSelectChangedAct(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	local Desc = ItemData.Name
	if not string.isnilorempty(Desc) then
		if UIViewMgr:IsViewVisible(UIViewID.CommHelpInfoTipsView) then
			UIViewMgr:HideView(UIViewID.CommHelpInfoTipsView)
		end

		local Node = ItemView:GetTipsWinPosNode()
		if nil ~= Node then
			TipsUtil.ShowInfoTips(Desc, Node, FVector2D(-20, 20), FVector2D(0, 1))
		end
	end
end


-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellJoinItemView:OnClickButtonJoin()
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	if ViewModel.IsApplyCD then
		MsgTipsUtil.ShowTips(LSTR(40080)) -- "通讯贝已申请，稍后再试"
		return
	end

	local LinkShellID = ViewModel.ID 
	if nil == LinkShellID then
		return
	end

	-- "通讯贝已达到加入上限"
    if not LinkShellMgr:CheckLinkshellNumLimit(40116) then
		return
	end

    if self.ViewModel.RecruitSet == RECRUITING_SET.OPEN then
		LinkShellMgr:SendMsgJoinLinkShellReq(LinkShellID, "")

    else
        local Params = {
			Title = LSTR(40081), -- "申请加入通讯贝"
            Desc = LSTR(40082), -- "通讯贝申请留言"
            HintText = LSTR(40083), -- "在此处输入申请留言"
            ConfirmButtonText = LSTR(40084), -- "发送申请"
			EnableLineBreak = true,
            MaxTextLength = LinkshellDefineCfg:GetApplyJoinMsgMaxLength(),
            SureCallback = function(Remark)
                LinkShellMgr:SendMsgJoinLinkShellReq(LinkShellID, Remark)
            end
        }

        UIViewMgr:ShowView(UIViewID.CommonPopupMultiLineInput, Params)
    end
end

function LinkShellJoinItemView:OnClickButtonChat()
	local VM = self.ViewModel
	if VM then
		_G.ChatMgr:GoToPlayerChatView(VM.CreatorRoleID)
	end
end


return LinkShellJoinItemView