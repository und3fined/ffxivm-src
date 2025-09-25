---
--- Author: xingcaicao
--- DateTime: 2023-04-21 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local PersoninfoBtnCfg = require("TableCfg/PersoninfoBtnCfg")
local ChatDefine = require("Game/Chat/ChatDefine")

local ProtoCS = require("Protocol/ProtoCS")
local RoleGroupState = ProtoCS.RoleGroupState
local LoginMgr = require("Game/Login/LoginMgr")


local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoModuleID = ProtoCommon.ModuleID

local UIBinderSetHead = require("Binder/UIBinderSetHead")
local UIBinderSetFrameIcon = require("Binder/UIBinderSetFrameIcon")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local OnlineStatusIdentify = ProtoRes.OnlineStatusIdentify
local SimpleViewSource = PersonInfoDefine.SimpleViewSource
local PopupBtnType = PersonInfoDefine.PopupBtnType
local LSTR = _G.LSTR
local TeamMgr
local ArmyMgr
local PersonInfoMgr
local FVector2D = _G.UE.FVector2D

local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetText = require("Binder/UIBinderSetText")
local BtnSortFunc = function(lhs, rhs)
	return lhs.Priority < rhs.Priority
end

---@class PersonInfoSimplePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnArmy UFButton
---@field BtnGo UFButton
---@field BtnMask UFButton
---@field IconOnline UFImage
---@field ImgFrame UFImage
---@field ImgFrameBg UFImage
---@field PersonInfoPlayer PersonInfoPlayerItemView
---@field PortraitPanel PersonInfoPortraitItemView
---@field SizeBox2 USizeBox
---@field TableViewBtn UTableView
---@field TextArmyName UFTextBlock
---@field TextHomepage UFTextBlock
---@field TextJobLevel UFTextBlock
---@field TextNoneArmyTips UFTextBlock
---@field TextOnline UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextRemark UFTextBlock
---@field TextTeam UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoSimplePanelView = LuaClass(UIView, true)

function PersonInfoSimplePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnArmy = nil
	--self.BtnGo = nil
	--self.BtnMask = nil
	--self.IconOnline = nil
	--self.ImgFrame = nil
	--self.ImgFrameBg = nil
	--self.PersonInfoPlayer = nil
	--self.PortraitPanel = nil
	--self.SizeBox2 = nil
	--self.TableViewBtn = nil
	--self.TextArmyName = nil
	--self.TextHomepage = nil
	--self.TextJobLevel = nil
	--self.TextNoneArmyTips = nil
	--self.TextOnline = nil
	--self.TextPlayerName = nil
	--self.TextRemark = nil
	--self.TextTeam = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoSimplePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PersonInfoPlayer)
	self:AddSubView(self.CommonPlayerPortraitItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoSimplePanelView:OnInit()
	ArmyMgr = _G.ArmyMgr
	PersonInfoMgr = _G.PersonInfoMgr
	TeamMgr = _G.TeamMgr
	self.TableAdapterBtn = UIAdapterTableView.CreateAdapter(self, self.TableViewBtn, self.OnAdpButtonFunction, true)

	self.BindersPersonInfoVM = {
		{ "BtnVMList", 			UIBinderUpdateBindableList.New(self, self.TableAdapterBtn) },
		{ "ArmySimpleInfo", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedArmySimpleInfo) },
	}

	self.BindersRoleVM = {
		-- { "HeadFrameID", 		UIBinderSetFrameIcon.New(self, self.PersonInfoPlayer.ImgFrame) },
		-- { "HeadInfo", 			UIBinderSetHead.New(self, self.PersonInfoPlayer.ImgPlayer) },
		{ "OnlineStatusName", UIBinderValueChangedCallback.New(self, nil, self.UpdOnlineName) },
		{ "OnlineStatusIcon", 	UIBinderSetImageBrush.New(self, self.IconOnline) },
		{ "Prof", 				UIBinderSetProfIcon.New(self, self.IconJob) },
		{ "Level", 				UIBinderSetText.New(self, self.TextJobLevel) },
		-- { "LevelColor", 		UIBinderSetColorAndOpacityHex.New(self, self.TextJobLevel) },
	}

	self:InitLSTR()
end

function PersonInfoSimplePanelView:InitLSTR()
	self.TextHomepage:SetText(LSTR(620059))
	self.TextNoneArmyTips:SetText(LSTR(620060))
end

function PersonInfoSimplePanelView:OnDestroy()

end

function PersonInfoSimplePanelView:OnShow()
	local RoleID = (PersonInfoVM.RoleVM or {}).RoleID
	PersonInfoMgr:SendQueryGemInfoByRoleID(RoleID)

	self.PersonInfoPlayer:SetInfo((PersonInfoVM.RoleVM or {}).RoleID)
	self.CommonPlayerPortraitItem:SetParams({Data = PersonInfoVM.RoleVM})
	self.IsMajor = PersonInfoVM.IsMajor 
	self.RoleID = PersonInfoVM.RoleID

	if not self.IsMajor then
		PersonInfoMgr:ReportSystemFlowData(PersonInfoDefine.DataReportType.IsOther)
	end

	local RoleVM = self.RoleVM or {}

	--功能按钮状态
	-- self:UpdateFunctionBtns()

	--玩家名字
	self.TextPlayerName:SetText(RoleVM.Name or "")
	self:UpdTeamInfo()

	--当前职业信息
	if PersonInfoVM.RoleVM then
		self:UpdatePlayerProfInfo(PersonInfoVM.RoleVM.Prof)
	end

	--当前职业信息
	self:SetServerInfo()
end

---服务器信息
function PersonInfoSimplePanelView:SetServerInfo()
	local RoleVM = PersonInfoVM.RoleVM
	if not RoleVM then return end

	local OriWorldID = RoleVM.WorldID or RoleVM.CurWorldID

	-- print('testinfo wid = ' .. tostring(RoleVM.WorldID))
	-- print('testinfo cwid = ' .. tostring(RoleVM.CurWorldID))

	if not OriWorldID then
		UIUtil.SetIsVisible(self.FHorizontalServer, false) 
		return
	end

	local ServerName = LoginMgr:GetMapleNodeName(OriWorldID)
	if string.isnilorempty(ServerName) then
		UIUtil.SetIsVisible(self.FHorizontalServer, false) 
		return
	end

	self.TextServer:SetText(ServerName)
	UIUtil.SetIsVisible(self.FHorizontalServer, true) 
end

function PersonInfoSimplePanelView:OnHide()
	PersonInfoVM:Clear()
end

function PersonInfoSimplePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMask, 			self.OnClickButtonMask)
	UIUtil.AddOnClickedEvent(self, self.BtnArmy, 			self.OnClickButtonArmy)
	UIUtil.AddOnClickedEvent(self, self.BtnGo, 				self.OnClickPersonInfo)
end

function PersonInfoSimplePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TeamNumberInfoQuerySucc, self.OnEveQueryTeamNumber)

	self:RegisterGameEvent(EventID.FriendAddBlack, self.UpdateFunctionBtns)
	self:RegisterGameEvent(EventID.FriendAdd, self.UpdateFunctionBtns)
	self:RegisterGameEvent(EventID.FriendRemoved, self.UpdateFunctionBtns)
	self:RegisterGameEvent(EventID.FriendRemoveBlack, self.UpdateFunctionBtns)

end

function PersonInfoSimplePanelView:OnRegisterBinder()
	--玩家数据
	local RoleVM = PersonInfoVM.RoleVM
	self.RoleVM = RoleVM

	self:RegisterBinders(PersonInfoVM, self.BindersPersonInfoVM)

	if RoleVM then
		self:RegisterBinders(RoleVM, self.BindersRoleVM)
	end
end

function PersonInfoSimplePanelView:UpdatePlayerProfInfo(Prof)
	local UpdateProf = function(VMList)
		local ProfVM = VMList:Find(function(e) return e.ProfID == Prof end)
		if ProfVM then
			self.ProfInfo:UpdateProfInfo(ProfVM)
			return true
		end
	end

	return UpdateProf(PersonInfoVM.CombatProfVMList) or UpdateProf(PersonInfoVM.ProduceProfVMList) or UpdateProf(PersonInfoVM.GatherProfVMList)
end

-------------------------------------------------------------------------------------------------------
---组队

function PersonInfoSimplePanelView:UpdTeamInfo()
	UIUtil.SetIsVisible(self.TextTeam, false)

	local TeamID = (PersonInfoVM.RoleVM or {}).TeamID

	if TeamID then
		_G.PersonInfoMgr:SendQueryTeamInfo(TeamID)
	end
end

function PersonInfoSimplePanelView:OnEveQueryTeamNumber(Info)
	if not Info then return end
	local S = string.format('（%s %s/8）', _G.LSTR('队伍'), Info.Cnt)
	UIUtil.SetIsVisible(self.TextTeam, true)

	self.TextTeam:SetText(S)
end

-------------------------------------------------------------------------------------------------------
---公会

function PersonInfoSimplePanelView:OnValueChangedArmySimpleInfo(Info)
	Info = Info or {}
	local ArmyID = Info.ID 
	self:UpdateFunctionBtns()

	if nil == ArmyID or ArmyID <= 0 then
		UIUtil.SetIsVisible(self.ImgArmy, false)
		UIUtil.SetIsVisible(self.TextArmyName, false)
		UIUtil.SetIsVisible(self.TextNoneArmyTips, true)
		UIUtil.SetIsVisible(self.BtnArmy, false)
		UIUtil.SetIsVisible(self.ImgArmy, false)
		UIUtil.SetIsVisible(self.TextNoneArmyTips, true)
		UIUtil.SetIsVisible(self.ArmyBadge, false)
		return
	end
	UIUtil.SetIsVisible(self.TextNoneArmyTips, false)
	UIUtil.SetIsVisible(self.ImgArmy, true)
	UIUtil.SetIsVisible(self.TextArmyName, true)
	UIUtil.SetIsVisible(self.TextNoneArmyTips, false)
	UIUtil.SetIsVisible(self.BtnArmy, true, true)
	UIUtil.SetIsVisible(self.ImgArmy, true)
	UIUtil.SetIsVisible(self.ArmyBadge, true)

	--公会名称
	self.TextArmyName:SetText(Info.Name or "")
	self.ArmyBadge:SetBadgeData(Info.Emblem, true)
end

local MakeBtnEle = function(Cfg, IsAdd)
	return{
		ID = Cfg.ID,
		Name = Cfg.Name,
		Priority = Cfg.Priority,
		IsAdd = IsAdd,
		Icon = Cfg.BtnIcon,
	}
end

function PersonInfoSimplePanelView:CheckTeamCond()
	local Source = self.Params.Source
	if nil == Source then
		Source = SimpleViewSource.Default
	end

	return Source == SimpleViewSource.Team and TeamMgr:IsInTeam()
end

function PersonInfoSimplePanelView:CheckUpdBtnFence()
	if not PersonInfoVM.ArmySimpleInfo then
		return false
	end

	if not PersonInfoVM.RoleVM then
		return false
	end

	return true
end

function PersonInfoSimplePanelView:UpdateFunctionBtns()
	if not self:CheckUpdBtnFence() then
		return
	end

	local RoleID = PersonInfoVM.RoleID

	local Source = (self.Params or {}).Source
	if nil == Source then
		Source = SimpleViewSource.Default
	end

	local List = {}

	local All = PersoninfoBtnCfg:FindAllCfg()
	local IsInBlackList = FriendMgr:IsInBlackList(RoleID)

	local RoleVM = PersonInfoVM.RoleVM
	

	local IsTargetOriServer = RoleVM.WorldID == (MajorUtil.GetMajorRoleVM() or {}).WorldID

	local IsMajor = (RoleID == MajorUtil.GetMajorRoleID())
	-- local RoleVM = self.RoleVM
	-- local MajorRoleVM = MajorUtil.GetMajorRoleVM()

	local MajorGroupID = nil
	local HasTargetArmyInfo = false
	local MajorGroupInfo = ArmyMgr:GetSelfArmyInfo()
	if MajorGroupInfo and MajorGroupInfo.Simple then
		MajorGroupID = MajorGroupInfo.Simple.ID
	end

	local TargetGroupID = nil
	local TargetGroupInfo = PersonInfoVM.ArmySimpleInfo
	if TargetGroupInfo then
		HasTargetArmyInfo = true
		TargetGroupID = TargetGroupInfo.ID
	end

    for ID, Item in ipairs(All or {}) do

		if ID == PopupBtnType.TeamInvite then
			if (not IsMajor) and (not IsInBlackList) then
				local IsTargetInTeam = TeamMgr:IsTeamMemberByRoleID(RoleID) or ActorUtil.HasTeam(ActorUtil.GetEntityIDByRoleID(RoleID))
				if (not IsTargetInTeam) then
					local Ele = MakeBtnEle(Item)
					table.insert(List, Ele)
				end
			end
		elseif (ID == PopupBtnType.TransferCaptain) or (ID == PopupBtnType.RemoveTeam) or (ID == PopupBtnType.DestroyTeam) or (ID == PopupBtnType.LeaveTeam) or (ID == PopupBtnType.Home) then
			--
		elseif ID == PopupBtnType.ArmyKick then
			if not IsMajor then
				local IsPermiss = ArmyMgr:GetSelfIsHavePermisstion(ProtoRes.GroupPermissionType.GROUP_PERMISSION_TYPE_KickMember)
				local MajorHasArmy = MajorGroupID ~= nil
				local RoleHasArmy = TargetGroupID ~= nil
				local IsSameArmy =  TargetGroupID == MajorGroupID
				-- print('testinfo alias = ' .. tostring(TargetGroupID))
				if MajorHasArmy and RoleHasArmy and IsSameArmy and IsPermiss then
					local Ele = MakeBtnEle(Item)
					table.insert(List, Ele)
				end
			end
		elseif ID == PopupBtnType.ArmyTransCap then
			if not IsMajor then
				local IsCap = ArmyMgr:IsLeader()
				local MajorHasArmy = MajorGroupID ~= nil
				local RoleHasArmy = TargetGroupID ~= nil
				local IsSameArmy =  TargetGroupID == MajorGroupID

				if IsTargetOriServer and MajorHasArmy and RoleHasArmy and IsSameArmy and IsCap then
					local Ele = MakeBtnEle(Item)
					table.insert(List, Ele)
				end
			end
		elseif ID == PopupBtnType.RideInvite then
			local IsSkip, NewName = self:GetRideBtnName()
			if not IsSkip then
				local Ele = MakeBtnEle(Item)
				Ele.Name = NewName
				table.insert(List, Ele)
			end
		elseif ID == PopupBtnType.ArmyInvite then
			local IsUnlcok = _G.ModuleOpenMgr:CheckOpenState(ProtoModuleID.ModuleIDArmy)
			if IsTargetOriServer and IsUnlcok and (not IsMajor) then
				local MajorHasArmy = MajorGroupID ~= nil
				local RoleHasArmy = (TargetGroupID ~= nil)
				local IsPermiss = ArmyMgr:GetSelfIsHavePermisstion(ProtoRes.GroupPermissionType.GROUP_PERMISSION_TYPE_SendInvite)
				if MajorHasArmy and (not RoleHasArmy) and IsPermiss then
					local NewName = LSTR(620042) 
					local Ele = MakeBtnEle(Item, true)
					Ele.Name = NewName
					table.insert(List, Ele)
				elseif RoleHasArmy and (not MajorHasArmy) and HasTargetArmyInfo then
					local NewName = LSTR(620041) 
					local Icon = "PaperSprite'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_AddArmy_png.UI_Profile_Icon_AddArmy_png'"
					local Ele = MakeBtnEle(Item, false)
					Ele.Name = NewName
					Ele.Icon = Icon
					table.insert(List, Ele)
				end
			end
		elseif ID == PopupBtnType.ArmySign then
			-- 策划要求不检查解锁
			local IsUnlcok = true --_G.ModuleOpenMgr:CheckOpenState(ProtoModuleID.ModuleIDArmy)
			if IsTargetOriServer and IsUnlcok and (not IsMajor) and TargetGroupInfo then
				local IsShow = false
				local MarjorStat =  _G.ArmyMgr:GetArmyState()
				local TargetStat = TargetGroupInfo.RoleGroupState
				local IsFull = _G.ArmyMgr:GetArmySignIsFull()

				if MarjorStat == RoleGroupState.RoleGroupStateGainedPetition and
					TargetStat == RoleGroupState.RoleGroupStateInit and 
						self.RoleVM.IsOnline and (not IsFull)
						then
						IsShow = true
						local Ele = MakeBtnEle(Item, IsShow)
						table.insert(List, Ele)
				end 
			end
		elseif ID == PopupBtnType.BlackList then
			if not IsMajor then
				local IsAdd = not FriendMgr:IsInBlackList(RoleID)
				local Ele = MakeBtnEle(Item, IsAdd)
				Ele.Name = IsAdd and LSTR(620015) or LSTR(620031)
				if not IsAdd then
					Ele.Icon = "PaperSprite'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_ChannelBlock_png.UI_Profile_Icon_ChannelBlock_png'"
				end
				table.insert(List, Ele)
			end
		elseif ID == PopupBtnType.NewbieChannel then
			if not IsMajor then
				local NewbieState = self:GetNewbieBtnState()
				if NewbieState ~= 0 then
					local IsAdd = NewbieState == 2
					--local NewName = IsAdd and LSTR(620044) or LSTR(620043)
					---屏蔽频道移除按钮
					if IsAdd then
						local NewName =  LSTR(620044)
						local Ele = MakeBtnEle(Item, IsAdd)
						Ele.Name = NewName
						if not IsAdd then
							Ele.Icon = "PaperSprite'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_ChannelRemoval_png.UI_Profile_Icon_ChannelRemoval_png'"
						end
						table.insert(List, Ele)
					end
				end
			end
		elseif ID == PopupBtnType.Friend then
			if not IsMajor then
				local IsAdd = not FriendMgr:IsFriend(RoleID)
				local NewName = IsAdd and LSTR(620009) or LSTR(620008)
				local Ele = MakeBtnEle(Item, IsAdd)
				Ele.Name = NewName
				if not IsAdd then
					Ele.Icon = "PaperSprite'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_DeleteFriend_png.UI_Profile_Icon_DeleteFriend_png'"
				end
				table.insert(List, Ele)
			end
		---添加面对面交易按钮
		elseif ID == PopupBtnType.MeetTrade then
			if _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_VIRTUAL_ACC_RECHARGE) >= 3000 then
				if not IsMajor and not _G.MeetTradeMgr:CheckOtherIsTooFarForTrade(RoleID) and not _G.PWorldMgr:CurrIsInDungeon()then
					local NewName = LSTR(1490004)
					local Ele = MakeBtnEle(Item)
					Ele.Name = NewName
					table.insert(List, Ele)
				end
			end
		elseif ID == PopupBtnType.Chat or ID == PopupBtnType.Report or ID == PopupBtnType.LinkShellInvite then
			if not IsMajor then
				table.insert(List,MakeBtnEle(Item))
			end
		else
			table.insert(List,MakeBtnEle(Item))
		end
	end

	table.sort(List, function(a, b)
		return a.Priority < b.Priority
	end)

    PersonInfoVM.BtnVMList:UpdateByValues(List)
end

--- 获取新人频道相关按钮状态
---@return number @0，隐藏；1，已加入新人频道；2，未加入新人频道
function PersonInfoSimplePanelView:GetNewbieBtnState()
	local RoleVM = self.RoleVM
	if nil == RoleVM then
		return 0
	end

	-- 主角是否为指导者
	local RoleIdentity = (MajorUtil.GetMajorRoleVM() or {}).Identity
    local MajorIdentity = OnlineStatusUtil.QueryMentorRelatedIdentity(RoleIdentity)
	if MajorIdentity ~= OnlineStatusIdentify.OnlineStatusIdentifyMentor then
		return 0
	end

	-- 玩家是否已加入到新人频道中
	if RoleVM.IsJoinedNewbieChannel then
		return 1

	else
		RoleIdentity = RoleVM.Identity
		local Identity = OnlineStatusUtil.QueryMentorRelatedIdentity(RoleIdentity)
		if Identity == OnlineStatusIdentify.OnlineStatusIdentifyNewHand or Identity == OnlineStatusIdentify.OnlineStatusIdentifyReturner then -- 新人、回归者
			-- 角色等级要求
			if RoleVM.Level >= ChatDefine.NewbieChannelLowestLevel then
				return 2
			end
		end
	end

	return 0
end

function PersonInfoSimplePanelView:GetRideBtnName()
	local RoleID = PersonInfoVM.RoleID

	if nil == RoleID then
		return true
	end

	local Actor = ActorUtil.GetActorByRoleID(RoleID)
	if nil == Actor then -- 玩家不在视野范围内
		return true
	end

	-- 玩家和主角在同一个队伍里面
	if not TeamMgr:IsTeamMemberByRoleID(RoleID) then
		return true
	end

	local Major = MajorUtil.GetMajor()
	if nil == Major then
		return true
	end

	local RideComponent = Actor:GetRideComponent()
	if nil == RideComponent then
		return true
	end

	local MajorRideCom = Major:GetRideComponent()

	if MajorRideCom:IsInMultiplayerRide() and not RideComponent:IsInRide() then -- 主角在多人骑乘状态，玩家不在骑乘状态
		return false, LSTR(620040)

	elseif not MajorRideCom:IsInRide() and RideComponent:IsInMultiplayerRide() then -- 主角不在骑乘状态，玩家在多人骑乘状态
		return false, LSTR(620026)
	end

	return true
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function PersonInfoSimplePanelView:OnAdpButtonFunction(_, VM)
	PersonInfoVM:SimpleViewOnClickButtonFunction(VM)
end

function PersonInfoSimplePanelView:OnClickButtonMask()
	self:Hide()
end

function PersonInfoSimplePanelView:OnClickButtonArmy()
	PersonInfoMgr:ShowPersonInfoArmyTipsView()
	PersonInfoMgr:ReportSystemFlowData(PersonInfoDefine.DataReportType.ClickAmry)
end

function PersonInfoSimplePanelView:OnClickPersonInfo()
	PersonInfoMgr:OpenHomePage((self.Params or {}).Source)
	PersonInfoMgr:ReportSystemFlowData(PersonInfoDefine.DataReportType.ClickHome)
	self:Hide()
end

function PersonInfoSimplePanelView:UpdOnlineName( OnlineStatusName  )
	self.TextOnline:SetText(OnlineStatusName)
end

return PersonInfoSimplePanelView