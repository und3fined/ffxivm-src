--[[
Author: xingcaicao
Date: 2023-05-18 19:17
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-09-09 20:16:34
FilePath: \Script\Game\TeamRecruit\View\Item\TeamRecruitItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSceneModeIcon = require("Binder/UIBinderSetSceneModeIcon")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

local LSTR = _G.LSTR

local TeamIcon = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_RecruitNormal_png.UI_Team_Icon_RecruitNormal_png'"
local FriendIcon = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_RecruitFriend_png.UI_Team_Icon_RecruitFriend_png'"
local ArmyIcon = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_RecruitArmy_png.UI_Team_Icon_RecruitArmy_png'"
local TeamLeadIcon = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_061521_png.UI_Icon_061521_png'"
local TeammateIcon = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_061522_png.UI_Icon_061522_png'"

---@class TeamRecruitItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BoxRelation USizeBox
---@field BtnSearch UFButton
---@field CommBtnS CommBtnSView
---@field FImgLock UFImage
---@field FImgState UFImage
---@field IconCrossServer UFImage
---@field ImgBg UFImage
---@field ImgOnlineStatus UFImage
---@field ImgOnlineStatus2 UFImage
---@field ImgSelect UFImage
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field RichTextMsg URichTextBox
---@field SizeBoxLock USizeBox
---@field SizeBoxState USizeBox
---@field TableViewMemProf UTableView
---@field TextEquipLevel UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextRecruitName UFTextBlock
---@field MsgLimitWidth float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitItemView = LuaClass(UIView, true)

function TeamRecruitItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BoxRelation = nil
	--self.BtnSearch = nil
	--self.CommBtnS = nil
	--self.FImgLock = nil
	--self.FImgState = nil
	--self.IconCrossServer = nil
	--self.ImgBg = nil
	--self.ImgOnlineStatus = nil
	--self.ImgOnlineStatus2 = nil
	--self.ImgSelect = nil
	--self.PlayerHeadSlot = nil
	--self.RichTextMsg = nil
	--self.SizeBoxLock = nil
	--self.SizeBoxState = nil
	--self.TableViewMemProf = nil
	--self.TextEquipLevel = nil
	--self.TextPlayerName = nil
	--self.TextRecruitName = nil
	--self.MsgLimitWidth = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtnS)
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitItemView:OnInit()
	self.TableAdapterMemberProf = UIAdapterTableView.CreateAdapter(self, self.TableViewMemProf)

	local UIBinderSetIsVisiblePred = require("Binder/UIBinderSetIsVisiblePred")
	self.Binders = {
		{ "ContentName", 	UIBinderSetText.New(self, self.TextRecruitName) },
		{ "HasPassword", 	UIBinderSetIsVisible.New(self, self.SizeBoxLock) },
		{ "HasPassword", 	UIBinderSetIsVisible.New(self, self.FImgLock) },
		{ "ContentName", 	UIBinderSetText.New(self, self.TextRecruitName) },
		
		{ "EquipLv", 		UIBinderValueChangedCallback.New(self, nil, self.OnEquipLvChanged) },
		{ "SceneMode", 		UIBinderValueChangedCallback.New(self, nil, function(_, V)
			UIUtil.ImageSetBrushFromAssetPath(self.FImgState, TeamRecruitUtil.GetSceneModeIconByOp((V or 0)+1))
		end)},
		{ "ItemOpacity", 	UIBinderSetRenderOpacity.New(self, self.BorderBg) },
		{ "Message", 		UIBinderSetText.New(self, self.RichTextMsg) },
		{ "MemberSimpleProfVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterMemberProf) },
		{ "ContentID",	UIBinderSetIsVisiblePred.NewByPred(TeamRecruitUtil.HasDifficultyConfig, self, self.SizeBoxState)},
		{ "RoleID", UIBinderSetIsVisiblePred.NewByPred(MajorUtil.IsMajorByRoleID, self, self.ImgSelect)}
	}

	self.RoleBinders = {
		{ "Name", 	UIBinderSetText.New(self, self.TextPlayerName) },
		{ "CurWorldID", TeamRecruitUtil.NewCrossServerShowBinder(nil, self, self.IconCrossServer)},
		{ "OnlineStatusIcon", UIBinderSetImageBrush.New(self, self.ImgOnlineStatus2)},
	}

	self.RecruitBinders = {
		{"IsRecruiting", UIBinderValueChangedCallback.New(self, nil, function()
			self:UpdateJoinBtnInfo()
		end)},
	}

	UIUtil.SetIsVisible(self.ImgSelect, false)
end

function TeamRecruitItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSearch, self.OnBtnSearchClick)
	UIUtil.AddOnClickedEvent(self, self.CommBtnS.Button, self.OnBtnJoinClick)
end

function TeamRecruitItemView:OnRegisterBinder()
	if not self.Params or not self.Params.Data then
		return
	end

	self.ViewModel = self.Params.Data
	self:RegisterBinders(self.ViewModel, self.Binders)
	self:RegisterBinders(_G.RoleInfoMgr:FindRoleVM(self:GetRecruitRoleID(), true), self.RoleBinders)

	local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
	self:RegisterBinders(TeamRecruitVM, self.RecruitBinders)
end

function TeamRecruitItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TeamIDUpdate, self.OnTeamIDUpdate)
end

function TeamRecruitItemView:OnShow()
	self.PlayerHeadSlot:SetInfo(self:GetRecruitRoleID())
	self:UpdateJoinBtnInfo()
	self:UpdateRelationIcon()
end

function TeamRecruitItemView:OnTeamIDUpdate()
	self:UpdateJoinBtnInfo()
	self:UpdateRelationIcon()
end

function TeamRecruitItemView:UpdateJoinBtnInfo()
	local bCanJoin
	local BtnName
	if  _G.TeamMgr:IsTeamMemberByRoleID(self:GetRecruitRoleID()) then
		BtnName = LSTR(1310039)
	elseif MajorUtil.GetMajorRoleID() == self:GetRecruitRoleID() then
		BtnName = LSTR(1300072) 
	elseif TeamRecruitUtil.IsUnOpenTask((self.ViewModel or {}).ContentID) then
		BtnName = LSTR(1310041)
	else
		BtnName = LSTR(1310040)
		local TeamRecruitMgr = require("Game/TeamRecruit/TeamRecruitMgr")
		bCanJoin = not TeamRecruitMgr:IsRecruiting()
	end

	self.CommBtnS:SetBtnName(BtnName)
	self.CommBtnS:SetIsEnabled(bCanJoin, bCanJoin)
	if not bCanJoin then
		self.CommBtnS:SetIsDoneState(true, BtnName)
	end
end


function TeamRecruitItemView:UpdateRelationIcon()
	local Icon
	local RoleID = self:GetRecruitRoleID()
	if _G.TeamMgr:IsTeamMemberByRoleID(RoleID) or RoleID == MajorUtil.GetMajorRoleID() then
		Icon = RoleID == MajorUtil.GetMajorRoleID() and TeamLeadIcon or TeammateIcon
	elseif _G.FriendMgr:IsFriend(RoleID) then
		Icon = FriendIcon
	elseif _G.ArmyMgr:GetIsArmyMemberByRoleID(RoleID) then
		Icon = ArmyIcon
	end

	UIUtil.SetIsVisible(self.BoxRelation, Icon ~= nil)
	if Icon then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgOnlineStatus, Icon)
	end
end

function TeamRecruitItemView:OnEquipLvChanged(EquipLv)
	if EquipLv <= 0 then
		self.TextEquipLevel:SetText(LSTR(1310012))

	else
		self.TextEquipLevel:SetText(tostring(EquipLv))
	end
end


function TeamRecruitItemView:OnBtnSearchClick()
	if self.ViewModel and  self.ViewModel.RoleID then
		_G.TeamRecruitMgr:QueryRecruitInfoReq(self.ViewModel.RoleID)
	end
end

function TeamRecruitItemView:OnBtnJoinClick()
	if nil == self.ViewModel then
		return
	end

	local RoleID = self.ViewModel.RoleID
	if nil == RoleID then
		return
	end

	local ContentID = (self.ViewModel or {}).ContentID
	if self.ViewModel.HasPassword then
		_G.UIViewMgr:ShowView(_G.UIViewID.TeamRecruitCode, {RoleID=RoleID, FromView=self, ContentID = ContentID})
	else
		_G.TeamRecruitMgr:TryJoinRecruit(self, RoleID, nil, ContentID)
	end
end

function TeamRecruitItemView:GetRecruitRoleID()
	return self.ViewModel and self.ViewModel.RoleID or nil
end

return TeamRecruitItemView