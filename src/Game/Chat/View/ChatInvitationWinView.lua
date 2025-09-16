---
--- Author: ds_herui
--- DateTime: 2023-05-05 15:28
--- Description:
---
---
local ProtoRes = require("Protocol/ProtoRes")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local LSTR = _G.LSTR
local NewbieMgr = _G.NewbieMgr

---@class ChatInvitationWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnEXP UFButton
---@field BtnRefuse CommBtnLView
---@field BtnSubmit CommBtnLView
---@field InforBtn CommInforBtnView
---@field PopUpBG CommonPopUpBGView
---@field RichTextInviter URichTextBox
---@field TextAdd UFTextBlock
---@field TextIntroduction UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatInvitationWinView = LuaClass(UIView, true)

function ChatInvitationWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnEXP = nil
	--self.BtnRefuse = nil
	--self.BtnSubmit = nil
	--self.InforBtn = nil
	--self.PopUpBG = nil
	--self.RichTextInviter = nil
	--self.TextAdd = nil
	--self.TextIntroduction = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatInvitationWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnRefuse)
	self:AddSubView(self.BtnSubmit)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatInvitationWinView:OnInit()
	self.TextTitle:SetText(LSTR(50090))
	self.TextIntroduction:SetText(LSTR(50091))
	self.TextTips:SetText(LSTR(50092))
	self.BtnRefuse:SetText(LSTR(50093)) -- 10093("暂不加入")
	self.BtnSubmit:SetText(LSTR(50094)) -- 10094("接受邀请")
	self.TextAdd:SetText("+50%")
end

function ChatInvitationWinView:OnDestroy()

end

function ChatInvitationWinView:OnShow()
	if nil == self.Params or nil == self.Params.InviteRoleName then
		return
	end
	local Name = RichTextUtil.GetText(self.Params.InviteRoleName, "4D85B4")
	-- 10054("资深冒险者")、10055("邀请您加入新人频道！")
	self.RichTextInviter:SetText(LSTR(50054) .. Name .. LSTR(50055))
end

function ChatInvitationWinView:OnHide()

end

function ChatInvitationWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSubmit, self.OnClickBtnSubmit)
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse, self.OnClickBtnRefuse)
	UIUtil.AddOnClickedEvent(self, self.BtnEXP, self.OnClickBtnEXP)
end

function ChatInvitationWinView:OnRegisterGameEvent()

end

function ChatInvitationWinView:OnRegisterBinder()

end

function ChatInvitationWinView:OnClickBtnSubmit()
	NewbieMgr:ClearNewbieSidebar()
	NewbieMgr:RspInviteJoinNewbieChannelReq(true)
	NewbieMgr:QueryLastInviterInfo(true)
	self:Hide()
end

function ChatInvitationWinView:OnClickBtnRefuse()
	self:Hide()
	NewbieMgr:QueryLastInviterInfo(true)
end

function ChatInvitationWinView:OnClickBtnEXP()
	ItemTipsUtil.ShowTipsByResID(ProtoRes.SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP, self.BtnEXP, {X = 0,Y = 0}, nil)
end

return ChatInvitationWinView