---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:58
--- Description:
---

local UIView = require("UI/UIView")
local HeadPortraitCfg = require("TableCfg/HeadPortraitCfg")
local LoginMgr = require("Game/Login/LoginMgr")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local PersonPortraitHeadHelper = require("Game/PersonPortraitHead/PersonPortraitHeadHelper")
local PersonPortraitHeadDefine = require("Game/PersonPortraitHead/PersonPortraitHeadDefine")

---@class LoginNewSeverListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgSeverBg UFImage
---@field ImgSeverSelect UFImage
---@field LoginNewPlayer LoginNewPlayerItemView
---@field LoginNewSever LoginNewSeverItemView
---@field TextSever UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewSeverListItemView = LuaClass(UIView, true)

function LoginNewSeverListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgSeverBg = nil
	--self.ImgSeverSelect = nil
	--self.LoginNewPlayer = nil
	--self.LoginNewSever = nil
	--self.TextSever = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewSeverListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LoginNewPlayer)
	self:AddSubView(self.LoginNewSever)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewSeverListItemView:OnInit()
end

function LoginNewSeverListItemView:OnDestroy()

end

function LoginNewSeverListItemView:OnShow()
	local Params = self.Params
	if nil == Params then return end

	---@type ServerListItemVM
	local ServerListItemVM = Params.Data
	if nil == ServerListItemVM then return end

	self.TextSever:SetText(ServerListItemVM.Name)
	self.LoginNewSever:SetWorldID(ServerListItemVM.WorldID)
	self.LoginNewSever:SetState(ServerListItemVM.State)

	if ServerListItemVM.HeadId and ServerListItemVM.HeadType then
		UIUtil.SetIsVisible(self.LoginNewPlayer, true)
		--local HeadIcon = HeadPortraitCfg:GetHeadIcon(ServerListItemVM.HeadPortraitID)
		--UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.LoginNewPlayer.ImgPlayer, HeadIcon, 'Texture')

		--@todo 兼容后台,参考 function RoleVM:SetHeadInfo( HeadIdx, HeadType, HeadUrl, Race )
		if ServerListItemVM.HeadId == 0 then
			ServerListItemVM.HeadId = 1
		end

		local bShowDefaultIcon = ServerListItemVM.HeadType == PersonPortraitHeadDefine.HeadType.Default
		UIUtil.SetIsVisible(self.LoginNewPlayer.IconSilhouette, bShowDefaultIcon)
		UIUtil.SetIsVisible(self.LoginNewPlayer.ImgPlayer, not bShowDefaultIcon)

		if not bShowDefaultIcon then
			local HeadInfo = {}
			HeadInfo.HeadType = ServerListItemVM.HeadType
			HeadInfo.HeadIdx = ServerListItemVM.HeadId
			HeadInfo.HeadUrl = ServerListItemVM.HeadUrl
			HeadInfo.Race = PersonPortraitHeadHelper.GetHeadRace(ServerListItemVM.Race, ServerListItemVM.Gender, ServerListItemVM.Tribe)
			PersonPortraitHeadHelper.SetHeadByHeadInfo(self.LoginNewPlayer.ImgPlayer, HeadInfo)
		end
		--print("[Login] LoginNewSeverListItemView:OnShow Show +++", ServerListItemVM.Name)
	else
		UIUtil.SetIsVisible(self.LoginNewPlayer, false)
		--print("[Login] LoginNewSeverListItemView:OnShow Hide ---", ServerListItemVM.Name)
	end
end

function LoginNewSeverListItemView:OnHide()

end

function LoginNewSeverListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickBtn)
end

function LoginNewSeverListItemView:OnRegisterGameEvent()

end

function LoginNewSeverListItemView:OnRegisterBinder()

end

function LoginNewSeverListItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSeverSelect, IsSelected)
end

---@see LoginNewFriendSeverListItemView:OnClickBtnGo
function LoginNewSeverListItemView:OnClickBtn()
	if self.Params.Data.WorldID ~= LoginNewVM.WorldID then
		_G.QueueMgr:CancelQueue()
	end

	LoginNewVM.WorldID = self.Params.Data.WorldID
	LoginNewVM.WorldState = self.Params.Data.State
	LoginNewVM.NodeTag = self.Params.Data.Tag
	LoginMgr.OverseasSvrAreaId = self.Params.Data.CustomValue2

	UIViewMgr:HideView(UIViewID.LoginServerList)
	_G.EventMgr:SendEvent(_G.EventID.LoginShowMainPanel)
end

return LoginNewSeverListItemView