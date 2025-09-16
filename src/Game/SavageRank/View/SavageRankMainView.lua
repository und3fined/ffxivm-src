---
--- Author: Administrator
--- DateTime: 2024-12-24 15:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SavageRankMainVM = require("Game/SavageRank/View/SavageRankMainVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local SavageRankMgr = require("Game/SavageRank/SavageRankMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local LocalizationUtil = require("Utils/LocalizationUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")


local LSTR = _G.LSTR


---@class SavageRankMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChangeList UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnSelf UButton
---@field CommDropDownList CommDropDownListView
---@field CommEmpty CommEmptyView
---@field CommInforBtn CommInforBtnView
---@field HorizontalTitle UFHorizontalBox
---@field ImgBG UFImage
---@field ImgBadge UFImage
---@field ImgNormal UFImage
---@field ImgSelfBG UFImage
---@field PanelChangeList UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelSelf UFCanvasPanel
---@field RichTextTips URichTextBox
---@field TableViewList UTableView
---@field TableViewPlayer UTableView
---@field TableView_63 UTableView
---@field TextClass UFTextBlock
---@field TextClass02 UFTextBlock
---@field TextNumber UFTextBlock
---@field TextRankNumber UFTextBlock
---@field TextSelfNumber UFTextBlock
---@field TextTeammate UFTextBlock
---@field TextTime UFTextBlock
---@field TextTime_1 UFTextBlock
---@field TextTitle UFTextBlock
---@field VerticalList UFVerticalBox
---@field AnimChangeSelfRank UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimTableViewListSelectionChanged UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SavageRankMainView = LuaClass(UIView, true)

function SavageRankMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChangeList = nil
	--self.BtnClose = nil
	--self.BtnSelf = nil
	--self.CommDropDownList = nil
	--self.CommEmpty = nil
	--self.CommInforBtn = nil
	--self.HorizontalTitle = nil
	--self.ImgBG = nil
	--self.ImgBadge = nil
	--self.ImgNormal = nil
	--self.ImgSelfBG = nil
	--self.PanelChangeList = nil
	--self.PanelEmpty = nil
	--self.PanelSelf = nil
	--self.RichTextTips = nil
	--self.TableViewList = nil
	--self.TableViewPlayer = nil
	--self.TableView_63 = nil
	--self.TextClass = nil
	--self.TextClass02 = nil
	--self.TextNumber = nil
	--self.TextRankNumber = nil
	--self.TextSelfNumber = nil
	--self.TextTeammate = nil
	--self.TextTime = nil
	--self.TextTime_1 = nil
	--self.TextTitle = nil
	--self.VerticalList = nil
	--self.AnimChangeSelfRank = nil
	--self.AnimIn = nil
	--self.AnimTableViewListSelectionChanged = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SavageRankMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommDropDownList)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommInforBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SavageRankMainView:OnInit()
	self.ViewModel = SavageRankMainVM.New()
	self.TeamTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_63, self.OnTeamItemSelectChanged, true)
	self.SelfTeamTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPlayer, self.TeamSelfItemSelect, true)
	self.PworldTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnPworldItemSelectChanged)
	self.Binders = {
		{ "CurTeamInfoList", UIBinderUpdateBindableList.New(self, self.TeamTableViewAdapter) },
		{ "CurPworldInfoList", UIBinderUpdateBindableList.New(self, self.PworldTableViewAdapter) },
		{ "CurSelfTeamInfoList", UIBinderUpdateBindableList.New(self, self.SelfTeamTableViewAdapter) },
		{ "SelfLvText", UIBinderSetText.New(self, self.TextClass02) },
		{ "SelfTimeText", UIBinderSetText.New(self, self.TextTime_1) },
		{ "SelfRankText", UIBinderSetText.New(self, self.TextSelfNumber) },
		{ "SelfRankIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBadge) },	
		{ "SelfBgImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgSelfBG) },	
		{ "SelfImgBadgeVisible", UIBinderSetIsVisible.New(self, self.ImgBadge) },
		{ "SelfImgNormalVisible", UIBinderSetIsVisible.New(self, self.ImgNormal) },	
		{ "BgImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG) },
	}
end

function SavageRankMainView:OnDestroy()

end

function SavageRankMainView:OnShow()
	self.JumpSenceID = 0
	if self.Params and self.Params.ScenceID then
		self.JumpSenceID = self.Params.ScenceID
	end
	self.TabSelectIndex = 0
	self:SetTitleText()
	-- self.TeamInfoList = SavageRankMgr:GetRankTeamInfo()
	-- if #self.TeamInfoList > 0 then
	-- 	UIUtil.SetIsVisible(self.PanelEmpty, false)
	-- else
	-- 	UIUtil.SetIsVisible(self.PanelEmpty, true)
	-- 	UIUtil.SetIsVisible(self.PanelSelf, false)
	-- end
	UIUtil.SetIsVisible(self.PanelEmpty, false)
	UIUtil.SetIsVisible(self.PanelSelf, false)
	self:UpdatePworldInfo()
	UIUtil.SetIsVisible(self.PanelChangeList, false)
end


function SavageRankMainView:OnHide()
	SavageRankMgr:ClearWaitInfo()
end

function SavageRankMainView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommDropDownList, self.OnSelectionChangedDropDownList)
	UIUtil.AddOnClickedEvent(self,  self.BtnChangeList, self.OnBtnChangedClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnSelf, self.OpenSelfTeamInfo)
end

function SavageRankMainView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SavageRankUpdateData, self.UpdateChoseRankInfo)
	self:RegisterGameEvent(EventID.SavageRankUpdateDrop, self.UpdateChoseRankDrop)
end

function SavageRankMainView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function SavageRankMainView:SetTitleText()
	self.TextTitle:SetText(LSTR(1450001))--零式排行榜
	self.RichTextTips:SetText(LSTR(1450002))--开启倒计时
	self.TextNumber:SetText(LSTR(1450003))--排名
	self.TextTeammate:SetText(LSTR(1450004))--参与队员
	self.TextClass:SetText(LSTR(1450005))--平均品级
	self.TextTime:SetText(LSTR(1450006))--通关时长
	self.CommEmpty:UpdateText(LSTR(1450007))--暂未开启
	self.TextRankNumber:SetText(LSTR(1450003))--排名
end

function SavageRankMainView:UpdateDropList(IsChosed)
	local Data = SavageRankMgr:GetDropDwonList()
	if #Data > 0 then
		UIUtil.SetIsVisible(self.CommDropDownList, true)
		self.CommDropDownList:UpdateItems(Data)
		self.TabList = Data
		self:SetTableViewState(true)
		if IsChosed then
			local List = SavageRankMgr:GetCurRankTeamInfo(1)
			self:UpdateTeamInfo(List, 1)
		end
	else
		self:SetTableViewState(false)
	end
end

function SavageRankMainView:OnPworldItemSelectChanged(Index, ItemData, ItemView)
	local _ <close> = _G.CommonUtil.MakeProfileTag("OnPworldItemSelectChanged")

	if Index == self.TabSelectIndex then
		return
	end
	
	UIUtil.SetIsVisible(self.CommDropDownList, false)
	UIUtil.SetIsVisible(self.TableView_63, false)
	self.TabSelectIndex = Index
	self.CurIsOpen = ItemData.IsOpen
	local SceneID = SavageRankMgr.SavageRankCfg[ItemData.ID].SceneID
	--local Offset = self.TabList[Index].Offset
	SavageRankMgr.CurChosedSceneID = SceneID
	SavageRankMgr:GetSceneRankAllInfo(SceneID)
	self:UpdateTimeText(ItemData.ID)
	self.ViewModel:UpdateBgImg(Index)
	local SlefTeamSelectIndex = SavageRankMgr.RankSlefIndexList[SavageRankMgr.CurChosedSceneID] or 1
    self.CurSelectSelfIndex = SlefTeamSelectIndex
	if self.CurSelfTeamInfo and self.CurSelfTeamInfo[SlefTeamSelectIndex] then
		self.ViewModel:UpdateSelfTeamInfo(self.CurSelfTeamInfo[SlefTeamSelectIndex])
	end
end

function SavageRankMainView:TeamSelfItemSelect(Index, ItemData, ItemView)
	_G.PersonInfoMgr:ShowPersonalSimpleInfoView(ItemData.RoleID)
end

function SavageRankMainView:OnTeamItemSelectChanged(Index, ItemData, ItemView)
	local Data = {}
	Data.Rank = ItemData.RankNumber
	Data.Time = ItemData.TimeText
	Data.EquipLv = ItemData.EquipLvText
	Data.PassDate = ItemData.PassDate
	Data.TeamList = ItemData.TeamInfo
	Data.RankIcon = ItemData.RankIcon
	UIViewMgr:ShowView(UIViewID.SavageRankTeamInfoWinView, Data)
end

function SavageRankMainView:OnSelectionChangedDropDownList(Index, ItemData, ItemView)
	local List = SavageRankMgr:GetCurRankTeamInfo(Index)
	self:UpdateTeamInfo(List, Index)
end

function SavageRankMainView:OnBtnChangedClick()
	self.CurSelectSelfIndex = self.CurSelectSelfIndex + 1
	if self.CurSelectSelfIndex > #self.CurSelfTeamInfo then
		self.CurSelectSelfIndex = 1
	end

	SavageRankMgr.RankSlefIndexList[SavageRankMgr.CurChosedSceneID] = self.CurSelectSelfIndex
	self.ViewModel:UpdateSelfTeamInfo(self.CurSelfTeamInfo[self.CurSelectSelfIndex])
end

function SavageRankMainView:UpdateTeamInfo(List, Index)
	local TeamList = {}
	if List then
		for i, Info in pairs(List) do
			local Data = {}
			Data.Rank = (Index - 1) * 100 + i
			Data.TeamInfo = Info.TeamMembers
			Data.PassTime = Info.PassTime
			Data.ElapsedTime = Info.ElapsedTime
			Data.EquipLevel = self.ViewModel:GetAverageLv(Info.TeamMembers)
			table.insert(TeamList, Data)
		end
	end

 	self.ViewModel:UpdateTeamInfo(TeamList)
end

function SavageRankMainView:UpdateChoseRankInfo()
	self:GetSelfRankInfo()
end

function SavageRankMainView:UpdateChoseRankDrop(IsChosed)
	self:UpdateDropList(IsChosed)
end

function SavageRankMainView:GetSelfRankInfo()
	local RoleID = MajorUtil.GetMajorRoleID()
	local InfoList = SavageRankMgr:GetRoleIDRankInfo(RoleID)
	local Data = {}
	for _, Info in ipairs(InfoList) do
		if Info.SceneID == SavageRankMgr.CurChosedSceneID then
			table.insert(Data, Info)
		end
	end
	self.CurSelfTeamInfo = Data
	if #Data > 0 then
		if #Data > 1 then
			UIUtil.SetIsVisible(self.PanelChangeList, true)
		else
			UIUtil.SetIsVisible(self.PanelChangeList, false)
		end

		UIUtil.SetIsVisible(self.PanelSelf, true)
		self.CurSelectSelfIndex = 1
		self.ViewModel:UpdateSelfTeamInfo(Data[1])
	else
		UIUtil.SetIsVisible(self.PanelSelf, false)
	end

end

function SavageRankMainView:UpdatePworldInfo()
	local RankList = SavageRankMgr:GetSavageRankCfg()
	self.ViewModel:UpdatePworldInfo(RankList)
	self.CurRankList = RankList
	local ChosedIndex = 1
	if self.JumpSenceID then
		for Index, Value in ipairs(RankList) do
			if Value.SceneID == self.JumpSenceID then
				ChosedIndex = Index
				break
			end
		end
	end

	self.PworldTableViewAdapter:SetSelectedIndex(ChosedIndex)
end

function SavageRankMainView:UpdateTimeText(ID)
	if not SavageRankMgr.SavageRankCfg[ID] then
		FLOG_ERROR("SavageRankCfg ID = NIL")
		return
	end 

	self.OpenTime = SavageRankMgr.SavageRankCfg[ID].OpenTime
	self.RemoveTime = SavageRankMgr.SavageRankCfg[ID].RemoveTime
	local ServerTime = _G.TimeUtil.GetServerLogicTime()
	self.CurrentTime = os.date("%Y-%m-%d_%H:%M:%S", ServerTime)
	if self.CurrentTime >= self.OpenTime and self.CurrentTime < self.RemoveTime then
		if self.TimeID == nil then
			self.TimeID = self:RegisterTimer(self.SetOffTimeText, 0, 1, 0)
		else
			self:UnRegisterTimer(self.TimeID)
			self.TimeID = nil
			self.TimeID = self:RegisterTimer(self.SetOffTimeText, 0, 1, 0)
		end
	elseif self.CurrentTime < self.OpenTime then
		if self.TimeID == nil then
			self.TimeID = self:RegisterTimer(self.SetOpenTimeText, 0, 1, 0)
		else
			self:UnRegisterTimer(self.TimeID)
			self.TimeID = nil
			self.TimeID = self:RegisterTimer(self.SetOpenTimeText, 0, 1, 0)
		end
	elseif self.CurrentTime >= self.RemoveTime then
		if self.TimeID then
			self:UnRegisterTimer(self.TimeID)
			self.TimeID = nil
		end

		self.RichTextTips:SetText(LSTR(1450016)) --"当前榜单挑战已结束！"
	end
end

--未开启时距离开启的时间
function SavageRankMainView:SetOpenTimeText()
	local OpenTime = self.OpenTime
	local CurrentTime = self.CurrentTime

	local OpenTimeSec = self:StringToTime(OpenTime)
	local CurrentTimeSec = self:StringToTime(CurrentTime)
	local Diff = OpenTimeSec - CurrentTimeSec
	local TimeString = LocalizationUtil.GetCountdownTimeForLongTime(Diff)
	self.RichTextTips:SetText(string.format("%s: %s", LSTR(1450017), TimeString))--开启倒计时
end

--开启时距离结束的时间
function SavageRankMainView:SetOffTimeText()
	local RemoveTime = self.RemoveTime
	local CurrentTime = self.CurrentTime

	local RemoveTimeSec = self:StringToTime(RemoveTime)
	local CurrentTimeSec = self:StringToTime(CurrentTime)
	local Diff = RemoveTimeSec - CurrentTimeSec
	local TimeString = LocalizationUtil.GetCountdownTimeForLongTime(Diff)
	self.RichTextTips:SetText(string.format("%s: %s", LSTR(1450018), TimeString))--剩余挑战时间
end

function SavageRankMainView:StringToTime(Time)
	return os.time({
		year = tonumber(Time:sub(1, 4)),
		month = tonumber(Time:sub(6, 7)),
		day = tonumber(Time:sub(9, 10)),
		hour = tonumber(Time:sub(12, 13)),
		min = tonumber(Time:sub(15, 16)),
		sec = tonumber(Time:sub(18, 19))
	})
end

function SavageRankMainView:SetTableViewState(Value)
	UIUtil.SetIsVisible(self.TableView_63, Value)
	UIUtil.SetIsVisible(self.PanelEmpty, not Value)
	if not Value then
		if self.CurIsOpen then
			self.CommEmpty:UpdateText(LSTR(1450019))--暂无队伍上榜
		else
			self.CommEmpty:UpdateText(LSTR(1450007))--暂未开启
		end
	end
end


function SavageRankMainView:OpenSelfTeamInfo()
	if not self.CurSelfTeamInfo[self.CurSelectSelfIndex] then
		FLOG_ERROR("OpenSelfTeamInfo CurSelfTeamInfo = nil")
		return
	end

	local List = self.CurSelfTeamInfo[self.CurSelectSelfIndex]
	local InfoList = self.ViewModel:GetSelfTeamInfo(List)
	local Data = {}
	Data.Rank = InfoList.Rank
	Data.Time = InfoList.TimeText
	Data.EquipLv = InfoList.EquipLv
	Data.PassDate = InfoList.PassDate
	Data.TeamList = InfoList.TeamList
	Data.RankIcon = InfoList.RankIcon
	
	UIViewMgr:ShowView(UIViewID.SavageRankTeamInfoWinView, Data)
end

return SavageRankMainView