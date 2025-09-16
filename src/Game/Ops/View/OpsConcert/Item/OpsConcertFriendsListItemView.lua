---
--- Author: usakizhang
--- DateTime: 2025-03-06 15:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local DataReportUtil = require("Utils/DataReportUtil")
local PersonPortraitHeadHelper = require("Game/PersonPortraitHead/PersonPortraitHeadHelper")
local AccountUtil = require("Utils/AccountUtil")
local Json = require("Core/Json")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")
local WeChatMiniAppCfg = {
	AppID = "gh_417667c90c73",
	Link = "pages/index/index?",
	TumbPath = "https://game.gtimg.cn/images/ff14/act/a20250318reflux/share.png"
}
local QQMiniAppCfg = {
	Link = "https://ff14m.qq.com/cp/a20250616reflux/index.html?",
	TumbPath = "https://game.gtimg.cn/images/ff14/cp/a20250616reflux/share.png",
}
local NodeType = ProtoRes.Game.ActivityNodeType
local LSTR = _G.LSTR
---@class OpsConcertFriendsListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImageIcon UImage
---@field ImgBtn UFImage
---@field ImgListBight UFImage
---@field ImgListDark UFImage
---@field RichTextName URichTextBox
---@field TextGrandTotal UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsConcertFriendsListItemView = LuaClass(UIView, true)

function OpsConcertFriendsListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImageIcon = nil
	--self.ImgBtn = nil
	--self.ImgListBight = nil
	--self.ImgListDark = nil
	--self.RichTextName = nil
	--self.TextGrandTotal = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsConcertFriendsListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsConcertFriendsListItemView:OnInit()
	self.Binders = {
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBtn)},
		{"FriendName", UIBinderSetText.New(self, self.RichTextName)},
		{"GameNameDec", UIBinderSetText.New(self, self.TextGrandTotal)},
		{ "HeadUrl", UIBinderValueChangedCallback.New(self, nil, self.OnHeadUrlChange) },
	}
end

function OpsConcertFriendsListItemView:OnDestroy()

end

function OpsConcertFriendsListItemView:OnShow()
	UIUtil.AddOnClickedEvent(self,  self.Btn, self.OnClickShareButton)
end

function OpsConcertFriendsListItemView:OnHide()

end

function OpsConcertFriendsListItemView:OnRegisterUIEvent()

end

function OpsConcertFriendsListItemView:OnRegisterGameEvent()

end

function OpsConcertFriendsListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function OpsConcertFriendsListItemView:OnClickShareButton()
	DataReportUtil.ReportActivityFlowData("ConcertActionTypeClickFlow", tostring(self.Params.ActivityID), "3")
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	_G.FLOG_INFO("点击了")
	self:ShareMiniApp("sCode="..(ViewModel.InviterCode or ""), ViewModel.UserOpenID)
	_G.EventMgr:SendEvent(_G.EventID.OpsConcertInvite)
end

function OpsConcertFriendsListItemView:ShareMiniApp(Params, UserOpenID)
	if _G.LoginMgr:IsQQLogin() then
		_G.FLOG_INFO("拉起小程序")
		if not AccountUtil.IsQQInstalled() then
			MsgTipsUtil.ShowTips(LSTR(1600030)) --"未安装应用"
			return
		end
		local DynamicData = {}
        DynamicData.prompt = LSTR(1600031)
        DynamicData.title = LSTR(1600001)
        DynamicData.desc = LSTR(1600032)
        DynamicData.preview = QQMiniAppCfg.TumbPath
        DynamicData.jumpUrl = QQMiniAppCfg.Link..Params
        local DynamicParams = Json.encode(DynamicData)
        _G.FLOG_INFO(string.format("DynamicParams:%s", DynamicParams))
		_G.FLOG_INFO("发送了")
		_G.FLOG_INFO(string.format("UserOpenID:%s", UserOpenID))
		local FriendOpenIDList = {}
    	table.insert(FriendOpenIDList, UserOpenID)
        _G.ShareMgr:GetArkInfo(FriendOpenIDList, DynamicParams, true)
	elseif _G.LoginMgr:IsWeChatLogin() then
		if not AccountUtil.IsWeChatInstalled() then
			MsgTipsUtil.ShowTips(LSTR(1600030)) --"未安装应用"
			return
		end
		local Path = WeChatMiniAppCfg.Link..Params
		AccountUtil.SendWechatMiniApp(UserOpenID or "",
			Path,
			WeChatMiniAppCfg.TumbPath,
			WeChatMiniAppCfg.AppID,
			0,
			"MSG_INVITE",
			Path,
			"")
	end
end

function OpsConcertFriendsListItemView:OnHeadUrlChange(NewValue)
    PersonPortraitHeadHelper.SetHeadByUrl(self.ImageIcon, NewValue)
end
return OpsConcertFriendsListItemView