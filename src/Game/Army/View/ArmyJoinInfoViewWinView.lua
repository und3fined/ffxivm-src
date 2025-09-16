---
--- Author: Administrator
--- DateTime: 2025-01-16 19:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local ArmyJoinInfoActivityItemVM = require("Game/Army/ItemVM/ArmyJoinInfoActivityItemVM")
local ArmyJoinInfoViewJobItemVM = require("Game/Army/ItemVM/ArmyJoinInfoViewJobItemVM")
local BitUtil = require("Utils/BitUtil")
local ProtoCS = require("Protocol/ProtoCS")
local GroupRecruitStatus = ProtoCS.GroupRecruitStatus
local GroupActivityDataCfg = require("TableCfg/GroupActivityDataCfg")
local GroupActivityTimeCfg = require("TableCfg/GroupActivityTimeCfg")
local GroupRecruitProfCfg = require("TableCfg/GroupRecruitProfCfg")
local GroupReputationLevelCfg = require("TableCfg/GroupReputationLevelCfg")
local TipsUtil = require("Utils/TipsUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local LocalizationUtil = require("Utils/LocalizationUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyJoinArmyPageVM = nil
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
local TimeUtil = require("Utils/TimeUtil")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local GlobalCfgType = ArmyDefine.GlobalCfgType
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ArmyFlagTextColors = ArmyDefine.ArmyFlagTextColors
local FLinearColor = _G.UE.FLinearColor

local MaxJoinTextLen = nil --- 申请入队留言最大长度

---@class ArmyJoinInfoViewWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyBadgeItem ArmyBadgeItemView
---@field BG Comm2FrameLView
---@field BtnCopy UFButton
---@field BtnHouseName UFButton
---@field BtnLeader UFButton
---@field BtnReport UFButton
---@field BtnSave CommBtnLView
---@field ImgArmyBg UFImage
---@field ImgArmyFlag UFImage
---@field ImgIcon UFImage
---@field ImgPeopleIcon UFImage
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field RichTextPeople URichTextBox
---@field TableViewJob UTableView
---@field TableView_62 UTableView
---@field Text UFTextBlock
---@field TextActivityTime UFTextBlock
---@field TextArmyName UFTextBlock
---@field TextArmyName02 UFTextBlock
---@field TextArmykind UFTextBlock
---@field TextDate UFTextBlock
---@field TextGade UFTextBlock
---@field TextGadeLevel UFTextBlock
---@field TextGade_1 UFTextBlock
---@field TextGade_2 UFTextBlock
---@field TextGade_3 UFTextBlock
---@field TextGade_4 UFTextBlock
---@field TextGade_5 UFTextBlock
---@field TextGade_6 UFTextBlock
---@field TextHouseName UFTextBlock
---@field TextLeader UFTextBlock
---@field TextRelation UFTextBlock
---@field TextSlogan UFTextBlock
---@field TextleaderName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyJoinInfoViewWinView = LuaClass(UIView, true)

function ArmyJoinInfoViewWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyBadgeItem = nil
	--self.BG = nil
	--self.BtnCopy = nil
	--self.BtnHouseName = nil
	--self.BtnLeader = nil
	--self.BtnReport = nil
	--self.BtnSave = nil
	--self.ImgArmyBg = nil
	--self.ImgArmyFlag = nil
	--self.ImgIcon = nil
	--self.ImgPeopleIcon = nil
	--self.PlayerHeadSlot = nil
	--self.RichTextPeople = nil
	--self.TableViewJob = nil
	--self.TableView_62 = nil
	--self.Text = nil
	--self.TextActivityTime = nil
	--self.TextArmyName = nil
	--self.TextArmyName02 = nil
	--self.TextArmykind = nil
	--self.TextDate = nil
	--self.TextGade = nil
	--self.TextGadeLevel = nil
	--self.TextGade_1 = nil
	--self.TextGade_2 = nil
	--self.TextGade_3 = nil
	--self.TextGade_4 = nil
	--self.TextGade_5 = nil
	--self.TextGade_6 = nil
	--self.TextHouseName = nil
	--self.TextLeader = nil
	--self.TextRelation = nil
	--self.TextSlogan = nil
	--self.TextleaderName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyJoinInfoViewWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyBadgeItem)
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyJoinInfoViewWinView:OnInit()
	---活动列表
	self.TableViewActivityAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_62)
	self.TableViewActivityAdapter:SetOnClickedCallback(self.OnActivityItemClicked)
	self.ActivityList = UIBindableList.New( ArmyJoinInfoActivityItemVM )
	---职业列表
	self.TableViewJobAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewJob)
	self.TableViewJobAdapter:SetOnClickedCallback(self.OnJobItemClicked)
	self.JobList = UIBindableList.New( ArmyJoinInfoViewJobItemVM )
	MaxJoinTextLen = GroupGlobalCfg:GetValueByType(GlobalCfgType.ApplyMsgMaxLimit)
	self.PlayerHeadSlot:SetIsTriggerClick(true)
end

function ArmyJoinInfoViewWinView:OnDestroy()

end

function ArmyJoinInfoViewWinView:OnShow()
	local Params = self.Params
	self:SetDefaultUIText()
	self:UpdateData(Params)
	self:UpdateUIShow()
end

---更新UI显示
function ArmyJoinInfoViewWinView:UpdateUIShow()
	self:SetRecruitSloganText(self.RecruitSlogan) ---招募设置
	self:SetEmblemUI(self.Emblem) ---设置队徽显示
	self:SetGrandCompanyUI(self.GrandCompanyType, self.Reputation) ---设置国防联军UI
	self:SetMemberUI(self.MemberCount, self.MaxMemberCount) ---设置成员数量
	self.TextGadeLevel:SetText(self.ArmyLevel) ---设置等级文本
	self:SetCreateTime(self.CreateTime)
	self:SetActivityTimeText(self.ActivityTimeType)
	self.TextArmyName:SetText(self.Name)
	local AliasStr = string.format("[%s]", self.Alias)
	self.TextArmyName02:SetText(AliasStr)
	self:SetLeaderInfo(self.LeaderID)
	self:SetBtnState()
end

function ArmyJoinInfoViewWinView:UpdateView(Params)
	self.Params = Params
	self:UpdateData(Params)
	self:UpdateUIShow()
end

function ArmyJoinInfoViewWinView:SendUpdateReq()
	_G.ArmyMgr:OpenArmyJoinInfoPanel(self.LeaderID)
end

---更新UI数据
function ArmyJoinInfoViewWinView:UpdateData(Params)
	local PanelBaseInfo = Params.PanelBaseInfo ---服务器下发数据
	local Info = Params.Info --- 加入界面传入数据
	self.IsCloseRecurit = true
	self.IsApplyCD = nil
	if PanelBaseInfo then
		local ActivityDatas = {}
		if PanelBaseInfo.ActivityIcons then
            for Index = 0, 64 do
                local ActivityIsOn = BitUtil.IsBitSetByInt64(PanelBaseInfo.ActivityIcons, Index, false)
				if ActivityIsOn then
					local Cfg = GroupActivityDataCfg:FindCfgByKey(Index + 1)
					if Cfg then
						local Item = {ID = Index + 1, Icon = Cfg.Icon}
						table.insert(ActivityDatas, Item)
					end
				end
            end
        end
		self.ActivityList:UpdateByValues(ActivityDatas)
		self.TableViewActivityAdapter:UpdateAll(self.ActivityList)

		local RecruitProfDatas = {}
		if PanelBaseInfo.RecruitProfs then
            for Index = 0, 64 do
                local RecruitProfsIsOn = BitUtil.IsBitSetByInt64(PanelBaseInfo.RecruitProfs, Index, false)
				if RecruitProfsIsOn then
					local Cfg = GroupRecruitProfCfg:FindCfgByKey(Index + 1)
					if Cfg then
						local Item = {ID = Index + 1, Icon = Cfg.Icon}
						table.insert(RecruitProfDatas, Item)
					end
				end
            end
        end
		self.JobList:UpdateByValues(RecruitProfDatas)
		self.TableViewJobAdapter:UpdateAll(self.JobList)

		self.ActivityTimeType = PanelBaseInfo.ActivityTimeType or PanelBaseInfo.ActivityTime--- 活动时间
		self.IsCloseRecurit =  PanelBaseInfo.RecruitStatus  == GroupRecruitStatus.GROUP_RECRUIT_STATUS_Closed ---招募状态
		self.RecruitSlogan = PanelBaseInfo.RecruitSlogan ---招募标语
		self.Reputation =  PanelBaseInfo.Reputation or {Level = 1, Exp = 0} ---友好关系
		self.Emblem = PanelBaseInfo.Emblem ---队徽
		--- 国防联军类型等待服务器数据
		self.GrandCompanyType = PanelBaseInfo.GrandCompanyType or 1 --- 国防联军类型
		self.ArmyLevel = PanelBaseInfo.GroupLevel --- 部队等级
		self.MemberCount = PanelBaseInfo.MemberCount or 1 ---成员数量
		self.MaxMemberCount = _G.ArmyMgr:GetArmyMemberMaxCount(self.ArmyLevel) --最大成员数量
		self.IsFull = self.MemberCount >= self.MaxMemberCount
		--- 创建时间等待服务器数据
		self.CreateTime = PanelBaseInfo.CreateTime or 0
		self.Name = PanelBaseInfo.GroupName
		self.Alias = PanelBaseInfo.GroupAlias
		self.LeaderID = PanelBaseInfo.LeaderID
		self.ArmyID = PanelBaseInfo.ID
		 ---校验是否在申请CD
		 local ApplyHistories = PanelBaseInfo.ApplyHistories
		 if ApplyHistories then
			self.IsApplyCD = false
		 end
		 local SelfRoleID = MajorUtil.GetMajorRoleID()
		 local CurTime = TimeUtil.GetServerTime()
		if ApplyHistories then
			for _, ApplyHistory in ipairs(ApplyHistories) do
				if ApplyHistory.RoleID == SelfRoleID then
					local WaitTime = CurTime - ApplyHistory.Time
					local WaitCD = GroupGlobalCfg:FindCfgByKey(ProtoRes.GroupGlobalConfigType.GlobalCfgGroupApplyCD).Value[1]
					if WaitCD then
						WaitCD = WaitCD * 60
						if WaitTime < WaitCD then
							self.IsApplyCD = true
							break
						end
					end
				end
			end
		end
	end
	if Info then
		if self.IsApplyCD == nil then
			self.IsApplyCD = Info.IsApplyCD
		end
		self.OpenPath = Info.OpenPath --- 打开途径
		self.ArmyID = self.ArmyID or Info.ArmyID ---无服务器下发使用传入数据
		self.IsHideBtn = Info.IsHideBtn
	end
end

---活动item点击
function ArmyJoinInfoViewWinView:OnActivityItemClicked(Index, ItemData, ItemView)
	local ID = ItemData.ID
	local Cfg = GroupActivityDataCfg:FindCfgByKey(ID)
	if Cfg then
	local TipsText = Cfg.TipsText
		if TipsText then
			TipsUtil.ShowInfoTips(TipsText, ItemView, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0))
		end
	end
end

---职业item点击
function ArmyJoinInfoViewWinView:OnJobItemClicked(Index, ItemData, ItemView)
	local ID = ItemData.ID
	local Cfg = GroupRecruitProfCfg:FindCfgByKey(ID)
	if Cfg then
		local TipsText = Cfg.TipsText
		if TipsText then
			TipsUtil.ShowInfoTips(TipsText, ItemView, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0))
		end
	end
end

---设置默认UI文本
function ArmyJoinInfoViewWinView:SetDefaultUIText()
	---LSTR 部队长
	self.TextLeader:SetText(LSTR(910264))
	---LSTR 成员
	self.Text:SetText(LSTR(910128))
	---LSTR 等级
	self.TextGade:SetText(LSTR(910260))
	---LSTR 创建时间
	self.TextGade_1:SetText(LSTR(910374))
	---LSTR 活动时间
	self.TextGade_2:SetText(LSTR(910372))
	---LSTR 主要活动
	self.TextGade_3:SetText(LSTR(910373))
	---LSTR 招募职业
	self.TextGade_4:SetText(LSTR(910375))
	---LSTR 招募标语
	self.TextGade_5:SetText(LSTR(910136))
	---LSTR 部队情报
	self.BG:SetTitleText(LSTR(910371))
end

---招募标语
function ArmyJoinInfoViewWinView:SetRecruitSloganText(RecruitSlogan)
	if RecruitSlogan then
		self.TextSlogan:SetText(RecruitSlogan)
	end
end

---设置国防联军UI
function ArmyJoinInfoViewWinView:SetGrandCompanyUI(GrandCompanyType, Reputation)
	if Reputation then
		local Level = Reputation.Level
		local Cfg = GroupReputationLevelCfg:FindCfgByKey(Level)
		if Cfg then
			local Str = string.format(LSTR(910376), Cfg.Text)
			self.TextRelation:SetText(Str) --设置关系文本
			if Cfg.Color then
				local LinearColor = _G.UE.FLinearColor.FromHex(Cfg.Color)
				if LinearColor then
					self.TextRelation:SetColorAndOpacity(LinearColor) ---设置颜色
				end
			end
		end
	end
	local GrandCompanyName = ""
	local Cfg =  GrandCompanyCfg:FindCfgByKey(GrandCompanyType)
	if Cfg then
		GrandCompanyName = Cfg.Name or GrandCompanyName
	end
	self.TextArmykind:SetText(GrandCompanyName)  ---设置国防联军名字
    if Cfg and Cfg.BgIcon then
		if Cfg.BgIcon then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgArmyBg, Cfg.BgIcon)
		end
		if Cfg.EditIcon then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgArmyFlag, Cfg.EditIcon)
		end
	end
	---设置文本颜色		
	local Colors
    if GrandCompanyType == ArmyDefine.GrandCompanyType.ShuangShe then
        Colors = ArmyFlagTextColors.Dark
    else
        Colors = ArmyFlagTextColors.Nomal
    end
	local LeaderNameColor = Colors.LeaderNameColor
	local ContentColor = Colors.ContentColor
	UIUtil.SetColorAndOpacityHex(self.TextArmykind, LeaderNameColor)-- 国防联军文本颜色
	UIUtil.SetColorAndOpacityHex(self.TextArmyName, LeaderNameColor)-- 部队名字文本颜色
	UIUtil.SetColorAndOpacityHex(self.TextArmyName02, ContentColor)-- 部队简称文本颜色

end

---设置队徽显示
function ArmyJoinInfoViewWinView:SetEmblemUI(Emblem)
	self.ArmyBadgeItem:SetBadgeData(Emblem)
end

function ArmyJoinInfoViewWinView:SetMemberUI(MemberCount, MaxMemberCount)
	local Str = string.format("%s/%s", MemberCount, MaxMemberCount)
	self.RichTextPeople:SetText(Str)
end

function ArmyJoinInfoViewWinView:SetCreateTime(Time)
	local GainTimeStr = TimeUtil.GetTimeFormat("%Y/%m/%d", Time)
	local LocalGainTimeStr =  LocalizationUtil.GetTimeForFixedFormat(GainTimeStr)
	self.TextDate:SetText(LocalGainTimeStr)
end

function ArmyJoinInfoViewWinView:SetActivityTimeText(Type)
	local CfgType = Type
	if Type == 0 then
		CfgType = 1 --默认为1
	end
	local Cfg = GroupActivityTimeCfg:FindCfgByKey(CfgType)
	if Cfg then
		self.TextActivityTime:SetText(Cfg.Text)
	end
end

function ArmyJoinInfoViewWinView:SetLeaderInfo(LeaderID)
	local Callback = function(_, RoleVM)
		local View = _G.UIViewMgr:FindView(_G.UIViewID.ArmyJoinInfoViewWin)
		if View then
			View:SetLeaderUI(RoleVM)
		end
	end
	_G.RoleInfoMgr:QueryRoleSimple(LeaderID, Callback, self, false)
end

function ArmyJoinInfoViewWinView:SetLeaderUI(RoleVM)
	if RoleVM.RoleID == self.LeaderID then
		self.TextleaderName:SetText(RoleVM.Name)
		self.PlayerHeadSlot:SetInfo(self.LeaderID)
	end
end

function ArmyJoinInfoViewWinView:SetBtnState()
	if self.IsHideBtn then
		---不显示按钮
		UIUtil.SetIsVisible(self.BtnSave, false)
		return
	else
		UIUtil.SetIsVisible(self.BtnSave, true, true)
	end
	if self.OpenPath == ArmyDefine.ArmyOpenJoinInfoType.JoinPanel then
		self:SetApplyBtnState()
	elseif self.OpenPath == ArmyDefine.ArmyOpenJoinInfoType.InvitePanel then
		local ArmyState = _G.ArmyMgr:GetArmyState()
		if self.IsCloseRecurit then
			self.BtnSave:SetIsDisabledState(true, true)
		elseif ArmyState ~= ProtoCS.RoleGroupState.RoleGroupStateInit then
			self.BtnSave:SetIsDisabledState(true, true)
		elseif self.IsFull then
			self.BtnSave:SetIsDisabledState(true, true)
		else
			self.BtnSave:SetIsRecommendState(true)
		end
		-- LSTR string:加入部队
		self.BtnSave:SetBtnName(LSTR(910076))
	elseif self.OpenPath == ArmyDefine.ArmyOpenJoinInfoType.OuterPanel then
		self:SetApplyBtnState()
	end
end

function ArmyJoinInfoViewWinView:OnHide()

end

function ArmyJoinInfoViewWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnApplyJoinArmy)
	UIUtil.AddOnClickedEvent(self, self.BtnCopy, self.OnClickedCopy)
	UIUtil.AddOnClickedEvent(self, self.BtnReport, self.OnClickedReport)
end

--- 复制部队ID
function ArmyJoinInfoViewWinView:OnClickedCopy()
    if nil == self.ArmyID or 0 == self.ArmyID then
        _G.FLOG_ERROR("ArmyID is invalid")
        return
    end
	_G.CommonUtil.ClipboardCopy(self.ArmyID)
    -- LSTR string:拷贝成功
    _G.MsgTipsUtil.ShowTips(LSTR(910142))
end

--- 申请加入部队
function ArmyJoinInfoViewWinView:OnApplyJoinArmy()
	local ArmyState = _G.ArmyMgr:GetArmyState()

	---需要设置一下joinvm那边的cd
	if self.OpenPath == ArmyDefine.ArmyOpenJoinInfoType.JoinPanel then
		---加入按钮点击判断
		local IsCanApply = self:CheckApplyBtn()
		if not IsCanApply then
			return
		end
		local JoinPanelVM = ArmyMainVM:GetJoinPanelVM()
		local ArmyJoinArmyPageVM = JoinPanelVM:GetArmyJoinPageVM()
		_G.UIViewMgr:ShowView(_G.UIViewID.ArmyApplyJoinPanel, {
			MaxTextLength = MaxJoinTextLen,
			-- LSTR string:请输入申请留言
			HintText =  _G.LSTR(910230),
			Callback = function(Message)
				---确认做申请实时禁用，本地计时可以接受，重新申请数据时会被服务器正确数据覆盖
				if nil ~= ArmyJoinArmyPageVM then
					local RoleID = MajorUtil.GetMajorRoleID()
					local ApplyHistory
					if ArmyJoinArmyPageVM.CurSelectedItemData and ArmyJoinArmyPageVM.CurSelectedItemData.ApplyHistories then
						ApplyHistory = table.find_by_predicate(ArmyJoinArmyPageVM.CurSelectedItemData.ApplyHistories, function(Element)
							return Element.RoleID == RoleID
						end)
					end
					if ApplyHistory then
						ApplyHistory.Time = TimeUtil.GetServerTime()
					else
						ApplyHistory = {}
						ApplyHistory.Time = TimeUtil.GetServerTime()
						ApplyHistory.RoleID = RoleID
						if ArmyJoinArmyPageVM.CurSelectedItemData then
							if  nil == ArmyJoinArmyPageVM.CurSelectedItemData.ApplyHistories then
								ArmyJoinArmyPageVM.CurSelectedItemData.ApplyHistories = {}
							end
							table.insert(ArmyJoinArmyPageVM.CurSelectedItemData.ApplyHistories, ApplyHistory)
						else
							_G.FLOG_ERROR("[ArmyJoinArmyPageView] CurArmyData is nil, RoleID:", RoleID)
						end
					end
					ArmyJoinArmyPageVM.IsApplyCD = true
					---更新弹窗界面的状态
					if ArmyJoinArmyPageVM.CurSelectedItemData and self.ArmyID == ArmyJoinArmyPageVM.CurSelectedItemData.ID then
						self.IsApplyCD = true
						self:SetBtnState()
					end
				end
				if ArmyJoinArmyPageVM and ArmyJoinArmyPageVM.CurSelectedItemData then
					_G.ArmyMgr:SendArmyApplyJoinMsg({ArmyJoinArmyPageVM.CurSelectedItemData.ID}, Message)
				elseif self.ArmyID then
					_G.FLOG_ERROR("[ArmyJoinArmyPageView] ArmyJoinArmyPageVM.CurSelectedItemData is nil")
				end
			end
		})
	elseif self.OpenPath == ArmyDefine.ArmyOpenJoinInfoType.InvitePanel then
		---邀请界面拦截判断
		if self.IsCloseRecurit then
			-- LSTR string:无法加入，该部队未开启招募
			MsgTipsUtil.ShowTips(LSTR(910383))
			return
		elseif  ArmyState == ProtoCS.RoleGroupState.RoleGroupStateGainedPetition then
			---创建中
			-- LSTR string:无法加入，当前在创建部队状态中
			MsgTipsUtil.ShowTips(LSTR(910384))
			return
		elseif  ArmyState == ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition then
			---已署名
			-- LSTR string:无法加入，当前在署名部队状态中
			MsgTipsUtil.ShowTips(LSTR(910385))
			return
		elseif self.IsFull then
			-- LSTR string:无法加入，该部队已满员
			MsgTipsUtil.ShowTips(LSTR(910386))
			return
		end
		_G.ArmyMgr:SendArmyAcceptInviteMsg(self.ArmyID)
		_G.ArmyMgr:ClearInvitePopUpInfo()
	elseif self.OpenPath == ArmyDefine.ArmyOpenJoinInfoType.OuterPanel then
		---外部打开
		---加入按钮点击判断
		local IsCanApply = self:CheckApplyBtn()
		if not IsCanApply then
			return
		end
		_G.UIViewMgr:ShowView(_G.UIViewID.ArmyApplyJoinPanel, {
			MaxTextLength = MaxJoinTextLen,
			-- LSTR string:请输入申请留言
			HintText =  _G.LSTR(910230),
			Callback = function(Message)
				---更新弹窗界面的状态
				self.IsApplyCD = true
				self:SetBtnState()
				if self.ArmyID then
					_G.ArmyMgr:SendArmyApplyJoinMsg({self.ArmyID }, Message)
				else
					_G.FLOG_ERROR("[ArmyJoinInfoViewWinView] self.ArmyID is nil")
				end
			end
		})
	end
end

function ArmyJoinInfoViewWinView:OnClickedReport()
	local Params = {
        ReporteeRoleID = self.LeaderID,
        GroupID = self.ArmyID,
        GroupName = self.Name,
		ReportContentList = {
			Abbreviation = self.Alias,
			RecruitmentSlogan = self.RecruitSlogan,
		},
    }
	--- Params.ReportContentList  = { "Abbreviation" = "部队简称文本", "RecruitmentSlogan" = "招募标语文本"}
	_G.ReportMgr:OpenViewByArmyList(Params)
end

function ArmyJoinInfoViewWinView:OnRegisterGameEvent()

end

function ArmyJoinInfoViewWinView:CheckApplyBtn()
	local ArmyState = _G.ArmyMgr:GetArmyState()
	---加入界面拦截判断
	if self.IsCloseRecurit then
		-- LSTR string:无法申请，该部队未开启招募
		MsgTipsUtil.ShowTips(LSTR(910381))
		return false
	elseif ArmyState == ProtoCS.RoleGroupState.RoleGroupStateJoinedGroup then
		---加入部队
		-- LSTR string:无法申请，当前已有部队
		MsgTipsUtil.ShowTips(LSTR(910377))
		return false
	elseif  ArmyState == ProtoCS.RoleGroupState.RoleGroupStateGainedPetition then
		---创建中
		-- LSTR string:无法申请，当前在创建部队状态中
		MsgTipsUtil.ShowTips(LSTR(910378))
		return false
	elseif  ArmyState == ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition then
		---已署名
		-- LSTR string:无法申请，当前在署名部队状态中
		MsgTipsUtil.ShowTips(LSTR(910379))
		return false
	elseif self.IsCloseRecurit then
		-- LSTR string:无法申请，该部队未开启招募
		MsgTipsUtil.ShowTips(LSTR(910381))
		return false
	elseif self.IsFull then
		-- LSTR string:无法加入，该部队已满员
		MsgTipsUtil.ShowTips(LSTR(910386))
		return
	elseif self.IsApplyCD then
		-- LSTR string:已申请，请等待审批
		MsgTipsUtil.ShowTips(LSTR(910114))
		return false
	end
	return true
end

---设置加入按钮状态
function ArmyJoinInfoViewWinView:SetApplyBtnState()
	local ArmyState = _G.ArmyMgr:GetArmyState()
	if self.IsCloseRecurit then
		-- LSTR string:停止招募
		self.BtnSave:SetBtnName(LSTR(910049))
		self.BtnSave:SetIsDisabledState(true, true)
	elseif ArmyState ~= ProtoCS.RoleGroupState.RoleGroupStateInit then
		-- LSTR string:申请加入
		self.BtnSave:SetBtnName(LSTR(910179))
		self.BtnSave:SetIsDisabledState(true, true)
	elseif self.IsFull then
		-- LSTR string:申请加入
		self.BtnSave:SetBtnName(LSTR(910179))
		self.BtnSave:SetIsDisabledState(true, true)
	elseif self.IsApplyCD then
		-- LSTR string:已申请
		self.BtnSave:SetBtnName(LSTR(910113))
		self.BtnSave:SetIsDisabledState(true, true)
	else
		-- LSTR string:申请加入
		self.BtnSave:SetBtnName(LSTR(910179))
		self.BtnSave:SetIsRecommendState(true)
	end
end

function ArmyJoinInfoViewWinView:OnRegisterBinder()

end

return ArmyJoinInfoViewWinView