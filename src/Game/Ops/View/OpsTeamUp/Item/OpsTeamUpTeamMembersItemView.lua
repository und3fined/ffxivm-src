---
--- Author: Administrator
--- DateTime: 2025-05-30 20:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local OpsTeamUpDefine = require("Game/Ops/OpsTeamUp/OpsTeamUpDefine")

local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

---@class OpsTeamUpTeamMembersItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInvite UFButton
---@field CommHead CommHeadView
---@field PaneIinvite UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsTeamUpTeamMembersItemView = LuaClass(UIView, true)

function OpsTeamUpTeamMembersItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInvite = nil
	--self.CommHead = nil
	--self.PaneIinvite = nil
	--self.RedDot = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsTeamUpTeamMembersItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommHead)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsTeamUpTeamMembersItemView:OnInit()
	self.Binders = {
		{ "TextName", UIBinderSetText.New(self, self.TextName) },
		{ "TextName", UIBinderValueChangedCallback.New(self, nil, self.OnTextNameChanged) },
		{ "RedDotName", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotNameChanged) },
	}
	self.CommHead:SetIsTriggerClick(true)
end

function OpsTeamUpTeamMembersItemView:OnDestroy()

end

function OpsTeamUpTeamMembersItemView:OnTextNameChanged(TextName)
	if TextName then
		UIUtil.SetIsVisible(self.PaneIinvite, false)
		UIUtil.SetIsVisible(self.CommHead, true)
	else
		UIUtil.SetIsVisible(self.CommHead, false)
		UIUtil.SetIsVisible(self.PaneIinvite, true)
	end
end

function OpsTeamUpTeamMembersItemView:OnShow()
	local Params = self.Params
    if nil == Params then return end

    local ItemVM = Params.Data
    if nil == ItemVM then return end

    FLOG_INFO("[LoginNewFriendItemView:OnShow] Name:%s, IconUrl:%s", ItemVM.TextName, ItemVM.HeaderUrl)
    self:ShowIconByUrl(ItemVM.HeaderUrl)
end

function OpsTeamUpTeamMembersItemView:OnHide()
    local ImageDownloader = self.ImageDownloader
    if ImageDownloader and ImageDownloader:IsValid() then
        ImageDownloader:Stop()
    end
end

function OpsTeamUpTeamMembersItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnInvite, self.OnClickedBtnInvite)
end

function OpsTeamUpTeamMembersItemView:OnRegisterGameEvent()

end

function OpsTeamUpTeamMembersItemView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then return end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

function OpsTeamUpTeamMembersItemView:OnRoleIDChanged(RoleID)
	if RoleID then
		if RoleID ~= 0 then
			self.CommHead:SetInfo(RoleID)
			UIUtil.SetIsVisible(self.CommHead, true)
			UIUtil.SetIsVisible(self.PaneIinvite, false)
		else
			UIUtil.SetIsVisible(self.PaneIinvite, true)
			UIUtil.SetIsVisible(self.CommHead, false)
		end
	end
end

function OpsTeamUpTeamMembersItemView:OnRedDotNameChanged(RedDotName)
	self.RedDot:SetRedDotNameByString(RedDotName)
end

function OpsTeamUpTeamMembersItemView:ShowIconByUrl(IconUrl)
    if string.isnilorempty(IconUrl) then
		UIUtil.SetIsVisible(self.CommHead.IconSilhouette, true)
        return
    end

    ---@type UImageDownloader
    local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("MemberHeadIcon", true, OpsTeamUpDefine.DefaultFriendImageMax)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
        function(_, texture)
            if texture then
                FLOG_INFO("[OpsTeamUpTeamMembersItemView:ShowIconByUrl] Download success")
                if self and self:IsValid() and self.CommHead and self.CommHead:IsValid() then
					UIUtil.SetIsVisible(self.CommHead.IconSilhouette, false)
					self.CommHead:SetIconByTextureResource(texture)
                else
                    FLOG_ERROR("[OpsTeamUpTeamMembersItemView:ShowIconByUrl] ImgPlayer is invalid")
                end
            end
        end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
        function()
            FLOG_ERROR("[OpsTeamUpTeamMembersItemView:ShowIconByUrl] Download failed...")
			if self and self:IsValid() and self.CommHead and self.CommHead:IsValid() then
            	UIUtil.SetIsVisible(self.CommHead.IconSilhouette, true)
			end
        end
    )

	if self.ImageDownloader and self.ImageDownloader:IsValid() then
		self.ImageDownloader:Stop()
	end
	self.ImageDownloader = ImageDownloader
	ImageDownloader:Start(IconUrl, "", true)
end

function OpsTeamUpTeamMembersItemView:OnClickedBtnInvite()
	_G.OpsTeamUpMgr:NodeJump(OpsTeamUpDefine.MemberNodeID)
end

return OpsTeamUpTeamMembersItemView