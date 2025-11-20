---
--- Author: kofhuang
--- DateTime: 2025-03-22 16:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local FieldTestTabItemVM = require("Game/Test/FieldTest/ViewModel/FieldTestTabItemVM")
local MultiLanguageTestLogVM = require("Game/Test/MultiLanguage/MultiLanguageTestLogVM")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local AchievementCfgTable = require("TableCfg/AchievementCfg")
local SingstateCfgTable = require("TableCfg/SingstateCfg")
local YellCfgTable = require("TableCfg/YellCfg")
local BalloonCfgTable = require("TableCfg/BalloonCfg")
local SysnoticeCfgTable = require("TableCfg/SysnoticeCfg")
local MonsterCfgTable = require("TableCfg/MonsterCfg")
local NpcCfgTable = require("TableCfg/NpcCfg")
local EObjCfgTable = require("TableCfg/EobjCfg")
local BuffCfgTable = require("TableCfg/BuffCfg")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ItemCfgTable = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableBuffList = require("Game/Buff/VM/UIBindableBuffList")
local BuffDefine = require("Game/Buff/BuffDefine")
local EventID = require("Define/EventID")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")
local PathMgr = require("Path/PathMgr")
local ActorUtil = require("Utils/ActorUtil")
local CommonUtil = require("Utils/CommonUtil")
local ScoreCfg = require("TableCfg/ScoreCfg")
local HUDType = require("Define/HUDType")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")


local ItemTypeDetail = ProtoCommon.ITEM_TYPE_DETAIL
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local GMMgr = _G.GMMgr
local TimerMgr = _G.TimerMgr
local UE = _G.UE
local UCameraMgr = _G.UE.UCameraMgr.Get()
local MediaUtil = _G.UE.UMediaUtil
local LOOT_TYPE = ProtoCS.LOOT_TYPE
local HUDMgr = _G.HUDMgr

local GMType = {
	Information = 1,
	Entity = 2,
	BluePrint = 3,
}

---@class MultiLanguageTestPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BImg UImage
---@field Bg_7 UFImage
---@field Bg_8 UFImage
---@field Bg_9 UFImage
---@field BtnDrag UFButton
---@field BtnMini UFButton
---@field BtnReturn UFButton
---@field BtnStart UFButton
---@field CommSearchBar_UIBP CommSearchBarView
---@field CommonCloseBtn CommonCloseBtnView
---@field CurGM UFTextBlock
---@field FHorizontalBox UFHorizontalBox
---@field FSearchBar UFHorizontalBox
---@field ItemList UFTreeView
---@field ItemView UBorder
---@field LeftPanel UFCanvasPanel
---@field MajorBuffInfoTips MainBuffInfoTipsNewView
---@field Maximum UEditableText
---@field Minimum UEditableText
---@field MovePanel UFCanvasPanel
---@field NewBagItemTips NewBagItemTipsView
---@field RightPanel UFCanvasPanel
---@field Runnum UFTextBlock
---@field TabList UTableView
---@field TextDrag UFTextBlock
---@field TextMinimize UFTextBlock
---@field TextReturn UFTextBlock
---@field TextStart UFTextBlock
---@field Timeinterval UEditableText
---@field TitleText_4 UFTextBlock
---@field TitleText_5 UFTextBlock
---@field IsDrag bool
---@field MovePanelSlot CanvasPanelSlot
---@field Offset Vector2D
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MultiLanguageTestPanelView = LuaClass(UIView, true)

function MultiLanguageTestPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BImg = nil
	--self.Bg_7 = nil
	--self.Bg_8 = nil
	--self.Bg_9 = nil
	--self.BtnDrag = nil
	--self.BtnMini = nil
	--self.BtnReturn = nil
	--self.BtnStart = nil
	--self.CommSearchBar_UIBP = nil
	--self.CommonCloseBtn = nil
	--self.CurGM = nil
	--self.FHorizontalBox = nil
	--self.FSearchBar = nil
	--self.ItemList = nil
	--self.ItemView = nil
	--self.LeftPanel = nil
	--self.MajorBuffInfoTips = nil
	--self.Maximum = nil
	--self.Minimum = nil
	--self.MovePanel = nil
	--self.NewBagItemTips = nil
	--self.RightPanel = nil
	--self.Runnum = nil
	--self.TabList = nil
	--self.TextDrag = nil
	--self.TextMinimize = nil
	--self.TextReturn = nil
	--self.TextStart = nil
	--self.Timeinterval = nil
	--self.TitleText_4 = nil
	--self.TitleText_5 = nil
	--self.IsDrag = nil
	--self.MovePanelSlot = nil
	--self.Offset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.SubPanelViews = {}
	self.SubPanelID = 0
	self.GMStartIndex = 0
	self.GMEndIndex = 0
	self.GMTimer = nil
	self.GMCounts = 0
	self.SearchText = ""
	self.SearchTextLength = 0
	self.LastTableID = 0
	self.GMType = GMType.Information
	self.BuffList = UIBindableBuffList.New()
	self.LastEobj = 0
	self.BufferVMList = UIBindableBuffList.New()
	self.TakeScreenshotTime = 0.5
	self.LastMonsterEntityID = 0
	self.LastNPCEntityID = 0
	self.LastEobjEntityID = 0
end

function MultiLanguageTestPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSearchBar_UIBP)
	self:AddSubView(self.CommonCloseBtn)
	self:AddSubView(self.MajorBuffInfoTips)
	self:AddSubView(self.NewBagItemTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MultiLanguageTestPanelView:OnInit()
	self.AdapterTabList = UIAdapterTableView.CreateAdapter(self, self.TabList)
	self.TabVMList = UIBindableList.New(FieldTestTabItemVM)

	self.GMDataList = UIBindableList.New(MultiLanguageTestLogVM)
	self.RecordList = UIBindableList.New(MultiLanguageTestLogVM)
	self.AdapterCategoryTable = UIAdapterTableView.CreateAdapter(self, self.ItemList, nil)

	self.CommSearchBar_UIBP:SetCallback(self, self.OnSearchTextChange, nil, self.OnClickCancelSearchBar)

	self.DPIScale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
end

function MultiLanguageTestPanelView:OnDestroy()
	self.AdapterTabList:OnDestroy()
	self.AdapterTabList = nil
	self.TabVMList = nil
	if self.UpdateTimerID then
		TimerMgr:CancelTimer(self.UpdateTimerID)
		self.UpdateTimerID = nil
	end
	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end
end

function MultiLanguageTestPanelView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewType = Params.ViewType
	self.TabVMList:Clear()

	if self.ViewType == LSTR("信息自动化") then
		self.TabVMList:AddByValue({Key = 1, Name = "系统通知", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 2, Name = "balloon", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 3, Name = "气泡表", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 4, Name = "成就表", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 5, Name = "交互表", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.GMType = GMType.Information
	elseif self.ViewType == LSTR("实体创建") then
		self.TabVMList:AddByValue({Key = 1, Name = "怪物", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 2, Name = "NPC", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 3, Name = "EOBJ", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 4, Name = "buff表", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.GMType = GMType.Entity
	elseif self.ViewType == LSTR("蓝图检查") then
		self.TabVMList:AddByValue({Key = 1, Name = "物品弹窗", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 2, Name = "物品快捷", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 3, Name = "物品详细", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.TabVMList:AddByValue({Key = 4, Name = "buff表", PanelView = self, CallBack = self.OnSelectedTabIndex})
		self.GMType = GMType.BluePrint
	end


	self.TextDrag:SetText(_G.LSTR(1440003)) --拖拽
	UIUtil.SetIsVisible(self.CommSearchBar_UIBP.FImageSearchDark, false)
	UIUtil.SetIsVisible(self.CommSearchBar_UIBP.FImageSearchLight, false)
	UIUtil.SetIsVisible(self.FSearchBar, true)
	UIUtil.SetIsVisible(self.BtnReturn, false)
	UIUtil.SetIsVisible(self.NewBagItemTips, false)
	UIUtil.SetIsVisible(self.MajorBuffInfoTips, false)

	self.AdapterTabList:UpdateAll(self.TabVMList)
	self.AdapterTabList:SetSelectedIndex(1)
	self.CurGM:SetText("")
	self.Runnum:SetText("")
	self.SubPanelID = 1

	self.LastMapResID = _G.PWorldMgr:GetCurrMapResID()
	self.GMDataList:FreeAllItems()
	self.RecordList:FreeAllItems()

	UIUtil.SetIsVisible(self.LeftPanel, true)
	UIUtil.SetIsVisible(self.FSearchBar, true)
	local Position = _G.UE.FVector2D(0, 0)
	UIUtil.CanvasSlotSetPosition(self.MovePanel, Position)

	CommonUtil.ConsoleCommand("r.HudZtest.Enable 0")
end

function MultiLanguageTestPanelView:OnHide()
	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end
	self:ClearClientActor()
	CommonUtil.ConsoleCommand("r.HudZtest.Enable 1")
end

function MultiLanguageTestPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMini, self.OnMinimizeClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnBtnStartClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnReturn, self.OnClickReturn)
end

function MultiLanguageTestPanelView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.UpdateBuff, self.OnGameEventUpdateBuff)
	self:RegisterGameEvent(EventID.GMReceiveRes, self.OnGMReceiveRes)
	self:RegisterGameEvent(EventID.ShowUI, self.OnNotifyUIShow)
	-- self:RegisterGameEvent(EventID.NPCCreate, self.OnNPCCreate)
	-- self:RegisterGameEvent(EventID.MonsterCreate, self.OnMonsterCreate)
	self:RegisterGameEvent(EventID.DealLootItem, self.OnDealLootItem)
end


function MultiLanguageTestPanelView:GetActorCreateLoc()
	local PosVector = _G.UE.FVector(0, 0, 0)

	local Major = MajorUtil.GetMajor()

    if (Major ~= nil) then
		local CameraComp = UCameraMgr:GetCurrentCameraComp()
		if not CameraComp then
			return PosVector
		end

		local CameraForward = CameraComp:GetForwardVector()
		local CameraRight = CameraComp:GetRightVector()
		CameraForward.Z = 0
		CameraForward:Normalize()
		CameraRight.Z = 0
		CameraRight:Normalize()

		local CameraDown = -CameraForward
		local CameraLeft = -CameraRight

		local CameraData = CameraLeft + CameraDown

		CameraData:Normalize()

		local OffsetDistance = 360;

		local Actorlocation = Major:K2_GetActorLocation()

		local SpawnLocation = Actorlocation + CameraData * OffsetDistance;
		SpawnLocation.Z = Actorlocation.Z - 70

		PosVector = SpawnLocation

	end

	return PosVector
end

function MultiLanguageTestPanelView:ClearClientActor()
	if self.LastMonsterEntityID ~= 0 then
		_G.UE.UActorManager.Get():RemoveClientActor(self.LastMonsterEntityID)
		self.LastMonsterEntityID = 0
	end
	if self.LastNPCEntityID ~= 0 then
		_G.UE.UActorManager.Get():RemoveClientActor(self.LastNPCEntityID)
		self.LastNPCEntityID = 0
	end
	if self.LastEobjEntityID ~= 0 then
		_G.UE.UActorManager.Get():RemoveClientActor(self.LastEobjEntityID)
		self.LastEobjEntityID = 0
	end
end

function MultiLanguageTestPanelView:OnSelectedTabIndex(Index)
	--FLOG_INFO(string.format("MultiLanguageTestPanelView:OnSelectedTabIndex:%s", Index))
	UIUtil.SetIsVisible(self.NewBagItemTips, false)
	UIUtil.SetIsVisible(self.MajorBuffInfoTips, false)
	self.AdapterTabList:SetSelectedIndex(Index)
	self.SubPanelID = Index
	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end
	self.CurGM:SetText("")
	self:ClearClientActor()
end

function MultiLanguageTestPanelView:TakeScreenshot(ShowText)
	FLOG_INFO(string.format("koff MultiLanguageTestPanelView:TakeScreenshot"))
	print(ShowText)

	if ShowText:find("%^") ~= nil then
		local DateTimestr = os.date("%Y-%m-%d")
		local CurCultureName = CommonUtil.GetCurrentCultureName()
		local CfgTableID = tostring(self.CfgTableID)
		local FolderStr = self.ViewType.."_"..CfgTableID
		local PathStr = DateTimestr.."/"..CurCultureName.."/"..self.ViewType.."_"..self.GMName.."/"
		-- local TextStr = folderStr..string.format("MyScreenShot_%d", self.CfgTableID)
		local TextStr = string.format("%d", self.CfgTableID)

		TimerMgr:AddTimer(self, function() 
			MediaUtil.TakeScreenshotRequest(TextStr, false, true, function(_, Width, Height, Colors)
				local ScreenshotFilename = MediaUtil.BitmapToSaveFile(Width, Height, Colors, PathStr)
				self.ScreenshotPath = MediaUtil.GetScreenshotPath() .. PathMgr.GetCleanFilename(ScreenshotFilename)
				FLOG_INFO(string.format("koff self.ScreenshotPath:%s", self.ScreenshotPath))
			end)
		end, self.TakeScreenshotTime, 1, 1, nil)
	end
end


function MultiLanguageTestPanelView:OnMinimizeClicked()
	UIUtil.SetIsVisible(self.LeftPanel, false)
	UIUtil.SetIsVisible(self.FSearchBar, false)

	local Position = _G.UE.FVector2D(-1250, 0)
	UIUtil.CanvasSlotSetPosition(self.MovePanel, Position)
	-- local BuffInfoPosition = _G.UE.FVector2D(1237, -212)
	-- UIUtil.CanvasSlotSetPosition(self.MajorBuffInfoTips, BuffInfoPosition)


	self.BtnReturn:SetVisibility(_G.UE.ESlateVisibility.Visible)

	if self.GMTimer == nil then
		self:StartGMCommand()
	end
end

function MultiLanguageTestPanelView:OnBtnStartClicked()
	if self.GMTimer == nil then
		self:StartGMCommand()
	end
end

function MultiLanguageTestPanelView:StartGMCommand()
	FLOG_INFO(string.format("koff MultiLanguageTestPanelView:StartGMCommand,self.SubPanelID:%s,self.GMType:%s",self.SubPanelID,self.GMType))
	local CfgTable = SysnoticeCfgTable:FindAllCfg() or {}
	local GMCur = "当前GM命令:"
	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end
	self.CurGM:SetText("")
	self.Runnum:SetText("")
	self.GMCounts = 0

	self.GMDataList:FreeAllItems()
	self.RecordList:FreeAllItems()
	self.AdapterCategoryTable:UpdateAll(self.RecordList)

	self.GMStartIndex = tonumber(self.Minimum:GetText())
	self.GMStartIndex = math.max(1,self.GMStartIndex)
	self.GMEndIndex = tonumber(self.Maximum:GetText())
	self.Timeintervals = tonumber(self.Timeinterval:GetText())

	local GMStr = ""
	self.LastTableID = 0
	self.GMName = ""


	if self.GMType == GMType.Information then
		if self.SubPanelID == 1 then
			CfgTable = SysnoticeCfgTable:FindAllCfg() or {}
			GMStr = "client sysnotice %d"
			self.GMName = "系统通知"
		elseif self.SubPanelID == 2 then
			CfgTable = BalloonCfgTable:FindAllCfg() or {}
			GMStr = "client PlayBalloon %d"
			self.GMName = "balloon"
		elseif self.SubPanelID == 3 then
			CfgTable = YellCfgTable:FindAllCfg() or {}
			GMStr = "client PlayYell %d"
			self.GMName = "气泡表"
		elseif self.SubPanelID == 4 then
			GMMgr:ReqGM("role achieve clear")
			CfgTable = AchievementCfgTable:FindAllCfg() or {}
			GMStr = "role achieve setcomp %d"
			self.GMName = "成就表"																		
		elseif self.SubPanelID == 5 then
			CfgTable = SingstateCfgTable:FindAllCfg() or {}
			GMStr = "client sing %d"
			self.GMName = "交互表"
		end
	elseif self.GMType == GMType.Entity then
		if self.SubPanelID == 1 then
			CfgTable = MonsterCfgTable:FindAllCfg() or {}
			GMStr = "scene monster create %d"
			self.GMName = "怪物"
			local Major = MajorUtil.GetMajor()
			if Major ~= nil then
				local Camera = Major:GetCameraControllComponent()
				if Camera ~= nil then
					Camera:SetMaxCameraDistance(2000)
					Camera:SetTargetArmLength(2000)
				end
			end
		elseif self.SubPanelID == 2 then
			CfgTable = NpcCfgTable:FindAllCfg() or {}
			GMStr = "scene npc create %d"
			self.GMName = "NPC"
			local Major = MajorUtil.GetMajor()
			if Major ~= nil then
				local Camera = Major:GetCameraControllComponent()
				if Camera ~= nil then
					Camera:SetMaxCameraDistance(2000)
					Camera:SetTargetArmLength(2000)
				end
			end
		elseif self.SubPanelID == 3 then
			CfgTable = EObjCfgTable:FindAllCfg() or {}
			GMStr = "scene eobj create %d"
			self.GMName = "EOBJ"
		elseif self.SubPanelID == 4 then
			CfgTable = BuffCfgTable:FindAllCfg() or {}
			GMStr = "cell buff add %d"
			self.GMName = "buff表"																	
		end
	elseif self.GMType == GMType.BluePrint then
		if self.SubPanelID == 1 then
			CfgTable = ItemCfgTable:FindAllCfg() or {}
			GMStr = "role bag add %d 1"
			self.GMName = "物品弹窗"
		elseif self.SubPanelID == 2 then
			CfgTable = ItemCfgTable:FindAllCfg() or {}
			GMStr = "role bag add %d 1"
			self.GMName = "物品快捷"
		elseif self.SubPanelID == 3 then
			CfgTable = ItemCfgTable:FindAllCfg() or {}
			GMStr = "role bag add %d 1"
			self.GMName = "物品详细"
		elseif self.SubPanelID == 4 then
			CfgTable = BuffCfgTable:FindAllCfg() or {}
			GMStr = "cell buff add %d"
			self.GMName = "buff表"																
		end
	end

	self.GMEndIndex = math.min(#CfgTable,self.GMEndIndex)

	local MajorID = MajorUtil.GetMajorEntityID()
	_G.SwitchTarget:SwitchToTarget(MajorID, true)

	if self.GMType == GMType.BluePrint then
		GMMgr:ReqGM("role bag clear")--蓝图检查前先把物品清理一遍
	end


	local FinshCallback = function ()
		if self.GMStartIndex > self.GMEndIndex then
			if self.GMTimer ~= nil then
				TimerMgr:CancelTimer(self.GMTimer)
				self.GMTimer = nil
			end
		else
			self.CfgTableID = 0
			if self.GMType == GMType.BluePrint and self.SubPanelID ~= 4 then
				self.CfgTableID = CfgTable[self.GMStartIndex].ItemID
			else
				self.CfgTableID = CfgTable[self.GMStartIndex].ID
			end

			if self.CfgTableID ~= nil then
				local GMText = string.format(GMStr, self.CfgTableID)
				local Data = {}
				self.TakeScreenshotTime = 0.5


				if self.GMType == GMType.Information then
					if self.SubPanelID == 1 then
						if UIViewMgr:IsViewVisible(UIViewID.CommonMsgBox) then
							UIViewMgr:HideView(UIViewID.CommonMsgBox)
						end
						if UIViewMgr:IsViewVisible(UIViewID.InfoMissionTips) then
							UIViewMgr:HideView(UIViewID.InfoMissionTips)
						end
						local Content = SysnoticeCfgTable:FindCfgByKey(self.CfgTableID).Content[1]

						_G.MsgTipsUtil.ShowTipsByID(self.CfgTableID)
						if Content then
							self:TakeScreenshot(Content)
						end
					elseif self.SubPanelID == 2 then
						local CloseTime = math.max(0.5,self.Timeintervals - 0.5)
						TimerMgr:AddTimer(self, function() 
							_G.SpeechBubbleMgr:HideBalloonByID(MajorID)
						end, CloseTime, 1, 1, nil)


						_G.SpeechBubbleMgr:ShowBalloonTest(self.CfgTableID)
						local CurrBalloon = BalloonCfgTable:FindCfgByKey(self.CfgTableID)
						if CurrBalloon ~= nil then
							self:TakeScreenshot(CurrBalloon.Text)
						end
					elseif self.SubPanelID == 3 then
						_G.SpeechBubbleMgr:ShowBubbleTest(self.CfgTableID)
						local BubbleInfo = _G.SpeechBubbleMgr:GetBubbleInfoByBubbleID(self.CfgTableID)
						if BubbleInfo ~= nil then
							self:TakeScreenshot(BubbleInfo.Content)
						end
					elseif self.SubPanelID == 4 then
						local AchievementMgr = _G.AchievementMgr
						for i = self.GMStartIndex, #CfgTable do
							if i > self.GMEndIndex then
								if self.GMTimer ~= nil then
									TimerMgr:CancelTimer(self.GMTimer)
									self.GMTimer = nil
									return
								end
							else
								self.CfgTableID = CfgTable[i].ID
								local Info = AchievementMgr:GetAchievementInfo(self.CfgTableID)
								if Info == nil then
									FLOG_INFO(string.format("无效的成就ID:%d", self.CfgTableID))
									self.GMStartIndex = self.GMStartIndex + 1
									goto continue
								else
									break
								end
							end
							::continue::
						end
						GMText = string.format(GMStr, self.CfgTableID)
						_G.LeftSidebarMgr:ResetDefaultStayTimeForTest(0.5)
						GMMgr:ReqGM(GMText)																
					elseif self.SubPanelID == 5 then
						_G.SingBarMgr:MajorSingBySingStateIDWithoutInteractiveID(self.CfgTableID, nil)
						local SingstateCfg = SingstateCfgTable:FindCfgByKey(self.CfgTableID)
						if SingstateCfg ~= nil then
							self:TakeScreenshot(SingstateCfg.SingName)
						end
					end
				elseif self.GMType == GMType.Entity then
					if self.SubPanelID == 1 then
						if self.LastMonsterEntityID ~= 0 then
							_G.UE.UActorManager.Get():RemoveClientActor(self.LastMonsterEntityID)
						end

						for i = self.GMStartIndex, #CfgTable do
							if i > self.GMEndIndex then
								if self.GMTimer ~= nil then
									TimerMgr:CancelTimer(self.GMTimer)
									self.GMTimer = nil
									return
								end
							else
								if CfgTable[i].IsHideName ~= 0 then
									self.GMStartIndex = self.GMStartIndex + 1
									goto continue
								else
									break
								end
							end
							::continue::
						end
						self.CfgTableID = CfgTable[self.GMStartIndex].ID

						local pos = self:GetActorCreateLoc()
						local CreatedEntityID = _G.UE.UActorManager.Get():CreateClientActor(_G.UE.EActorType.Monster, 0, self.CfgTableID, pos,_G.UE.FRotator(0,0,0))

						local Name = ActorUtil.GetActorName(CreatedEntityID)

						self.LastMonsterEntityID = CreatedEntityID

						self.TakeScreenshotTime = 1.5
						self:TakeScreenshot(Name)
					elseif self.SubPanelID == 2 then
						if self.LastNPCEntityID ~= 0 then
							_G.UE.UActorManager.Get():RemoveClientActor(self.LastNPCEntityID)
						end

						for i = self.GMStartIndex, #CfgTable do
							if i > self.GMEndIndex then
								if self.GMTimer ~= nil then
									TimerMgr:CancelTimer(self.GMTimer)
									self.GMTimer = nil
									return
								end
							else
								if CfgTable[i].Name == "" then
									self.GMStartIndex = self.GMStartIndex + 1
									goto continue
								else
									break
								end
							end
							::continue::
						end

						self.CfgTableID = CfgTable[self.GMStartIndex].ID

						local pos = self:GetActorCreateLoc()
						local CreatedEntityID = _G.UE.UActorManager.Get():CreateClientActor(_G.UE.EActorType.NPC, 0, self.CfgTableID, pos,_G.UE.FRotator(0,0,0))

						local Name = ActorUtil.GetActorName(CreatedEntityID)

						self.LastNPCEntityID = CreatedEntityID

						self.TakeScreenshotTime = 1.5
						self:TakeScreenshot(Name)
					elseif self.SubPanelID == 3 then
						if self.LastEobjEntityID ~= 0 then
							_G.UE.UActorManager.Get():RemoveClientActor(self.LastEobjEntityID)
						end

						for i = self.GMStartIndex, #CfgTable do
							if i > self.GMEndIndex then
								if self.GMTimer ~= nil then
									TimerMgr:CancelTimer(self.GMTimer)
									self.GMTimer = nil
									return
								end
							else
								if CfgTable[i].Name == "" then
									self.GMStartIndex = self.GMStartIndex + 1
									goto continue
								else
									break
								end
							end
							::continue::
						end

						self.CfgTableID = CfgTable[self.GMStartIndex].ID

						local pos = self:GetActorCreateLoc()
						local CreatedEntityID = _G.UE.UActorManager.Get():CreateClientActor(_G.UE.EActorType.Eobj, 0, self.CfgTableID, pos,_G.UE.FRotator(0,0,0))
						local Name = ActorUtil.GetActorName(CreatedEntityID)

						self.LastEobjEntityID = CreatedEntityID

						self.TakeScreenshotTime = 1.5
						self:TakeScreenshot(Name)
					elseif self.SubPanelID == 4 then
						local DB = BuffCfgTable:FindCfgByKey(self.CfgTableID)
						if nil ~= DB then 
							local EntityID = MajorUtil.GetMajorEntityID()
							local BufferID = DB.ID

							if ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_POSITIVE == DB.DisplayType then
								HUDMgr:ShowBufferEffect(EntityID, BufferID, HUDType.MajorBufferAdd, 0, 0)
							else
								HUDMgr:ShowBufferEffect(EntityID, BufferID, HUDType.MajorDBufferAdd, 0, 0)
							end


							self:TakeScreenshot(DB.BuffName)
						end																
					end
				elseif self.GMType == GMType.BluePrint then
					if self.SubPanelID == 1 then
						if _G.BagMgr:GetBagLeftNum() <= 350 then
							GMMgr:ReqGM("role bag clear")
						end

						GMMgr:ReqGM(GMText)
					elseif self.SubPanelID == 2 then
						for i = self.GMStartIndex, #CfgTable do
							if i > self.GMEndIndex then
								if self.GMTimer ~= nil then
									TimerMgr:CancelTimer(self.GMTimer)
									self.GMTimer = nil
									return
								end
							else
								local EasyUse = CfgTable[i].EasyUse
								if EasyUse ~= 1 then
									self.GMStartIndex = self.GMStartIndex + 1
									goto continue
								else
									break
								end
							end
							::continue::
						end

						self.CfgTableID = CfgTable[self.GMStartIndex].ItemID
						GMText = string.format(GMStr, self.CfgTableID)
						local Item = ItemUtil.CreateItem(self.CfgTableID)
						self:PopUpEasyUse(Item)
					elseif self.SubPanelID == 3 then
						local Item = ItemUtil.CreateItem(self.CfgTableID)
						Item.Attr = {
							Equip = {
								IsInScheme = false,
								GemInfo = {
									CarryList = {}
								}
							}
						}

						UIUtil.SetIsVisible(self.NewBagItemTips, true)
						self.NewBagItemTips:UpdateItem(Item)
						local ItemName = ItemCfgTable:GetItemName(self.CfgTableID)
						if ItemName ~= "" then
							self:TakeScreenshot(ItemName)
						end
						local EffectText = ItemCfgTable:GetItemEffectDesc(self.CfgTableID)
						if EffectText ~= "" then
							self:TakeScreenshot(EffectText)
						end
						local IntroText = ItemCfgTable:GetItemDesc(self.CfgTableID)
						if IntroText ~= "" then
							self:TakeScreenshot(IntroText)
						end
					elseif self.SubPanelID == 4 then
						self.BufferVMList:Clear()

						local DB = BuffCfgTable:FindCfgByKey(self.CfgTableID)
						if nil ~= DB then 
							local Value = nil

							local EntityID = MajorUtil.GetMajorEntityID()

							local CombatBuffInfo = {
								BuffID = DB.ID,
								Giver = EntityID,
								ExpdTime = 0,
								Pile = 1,
								AddTime = 0,
							}


							local BuffType = DB.Type
							if BuffType ==  BuffDefine.BuffSkillType.Combat then
								Value = BuffUIUtil.CombatBuff2BuffVMParams(EntityID, DB.ID, CombatBuffInfo)
							elseif BuffType == BuffDefine.BuffSkillType.Life then
								Value = BuffUIUtil.LifeSkillBuff2BuffVMParams(EntityID, DB.ID, CombatBuffInfo)
							elseif BuffType == BuffDefine.BuffSkillType.BonusState then
								Value = BuffUIUtil.BonusState2BuffVMParams(EntityID, DB.ID, CombatBuffInfo)
							end

							if Value == nil then
								Value = BuffUIUtil.CombatBuff2BuffVMParams(EntityID, DB.ID, CombatBuffInfo)
							end

							self.BufferVMList:AddOrUpdateBuff(Value)

							local BuffVM = self.BufferVMList.Items[1]

							BuffVM.BuffIcon = DB.BuffIcon
							BuffVM.IsEffective = true
							BuffVM.LeftTime = DB.LiveTime / 1000
							BuffVM.IsFromMajor = true
							BuffVM.Name = DB.BuffName
							BuffVM.Desc = DB.Desc
							BuffVM.Pile = 1


							local CloseTime = math.max(0.5,self.Timeintervals - 0.5)

							UIUtil.SetIsVisible(self.MajorBuffInfoTips, true)
							TimerMgr:AddTimer(self, function() 
									UIUtil.SetIsVisible(self.MajorBuffInfoTips, false)
							end, CloseTime, 1, 1, nil)

							self.MajorBuffInfoTips:ChangeVMAndUpdate(BuffVM)

							if DB.BuffName:find("%^") ~= nil then
								self:TakeScreenshot(DB.BuffName)
							else
								self:TakeScreenshot(DB.Desc)
							end
						end														
					end
				end

				Data.Text = GMText
				self.RecordList:AddByValue(Data)

				GMText = GMCur..GMText
				self.CurGM:SetText(GMText)
				self.GMCounts = self.GMCounts + 1
				UIViewMgr:HideView(UIViewID.GMMain)

				self.LastTableID = self.CfgTableID
				self:SetDataList(self.RecordList)
			end
		end
		self.GMStartIndex = self.GMStartIndex + 1
	end

	self.GMTimer = TimerMgr:AddTimer(self, FinshCallback, 0, self.Timeintervals, 0, nil)
end

function MultiLanguageTestPanelView:OnNotifyUIShow(InViewID)
	FLOG_INFO(string.format("koff MultiLanguageTestPanelView:OnNotifyUIShow:%s", InViewID))
	if InViewID == UIViewID.SidePopUpEasyUse then
		local SidePopUpEasyUseView = _G.UIViewMgr:FindView(UIViewID.SidePopUpEasyUse)
		if SidePopUpEasyUseView then
			--物品快捷
			if self.GMType == GMType.BluePrint and self.SubPanelID == 2 then
				local Text = SidePopUpEasyUseView.TextTitle:GetText()
				self:TakeScreenshot(Text)
			end
		end
	end

	if InViewID == UIViewID.SidebarLeft then
		local SidebarLeftView = _G.UIViewMgr:FindView(UIViewID.SidebarLeft)
		if SidebarLeftView then
			if self.GMType == GMType.Information and self.SubPanelID == 4 then
				local Text = SidebarLeftView.RichTextContent:GetShowText()
				self:TakeScreenshot(Text)
			end
		end
	end
end

function MultiLanguageTestPanelView:SetDataList(DataList)
	if self.SearchTextLength > 0  then
		local OldList = self.RecordList:GetItems()

		self.GMDataList:FreeAllItems()

		for i = 1, #OldList do
			local NameStr = OldList[i].Text
			if string.find(NameStr, self.SearchText) then
				local Data = OldList[i]
				self.GMDataList:AddByValue(Data)
			end
		end
	
		self.AdapterCategoryTable:UpdateAll(self.GMDataList)
		self.AdapterCategoryTable:ScrollToBottom()
	else
		self.AdapterCategoryTable:UpdateAll(self.RecordList)
		self.AdapterCategoryTable:ScrollToBottom()
	end

	self.Runnum:SetText(self.GMStartIndex)
end

function MultiLanguageTestPanelView:OnSearchTextChange(SearchText, Length)
	self.SearchTextLength = Length
	if Length <= 0 then
        if self.RecordList ~= nil then
			self:SetDataList(self.RecordList)
		end
        return
    end

	self.SearchText = SearchText
	self:SetDataList(self.RecordList)
end

function MultiLanguageTestPanelView:OnClickCancelSearchBar()
	if self.RecordList ~= nil then
		self:SetDataList(self.RecordList)
	end
end

function MultiLanguageTestPanelView:OnClickReturn()
	UIUtil.SetIsVisible(self.LeftPanel, true)
	UIUtil.SetIsVisible(self.FSearchBar, true)
	UIUtil.SetIsVisible(self.BtnReturn, false)
	local Position = _G.UE.FVector2D(0, 0)
	UIUtil.CanvasSlotSetPosition(self.MovePanel, Position)
	-- local BuffInfoPosition = _G.UE.FVector2D(-13, -212)
	-- UIUtil.CanvasSlotSetPosition(self.MajorBuffInfoTips, BuffInfoPosition)
end

function MultiLanguageTestPanelView:PopUpEasyUse(Item)
    if UIViewMgr:IsViewVisible(UIViewID.SidePopUpEasyUse) then
		_G.SidePopUpMgr:RemoveSidePopUp(UIViewID.SidePopUpEasyUse)
    end

	_G.SidePopUpMgr:AddSidePopUp(ProtoRes.side_popup_type.SIDE_POPUP_EASY_USE, UIViewID.SidePopUpEasyUse, Item, function(Item)
		local ItemResID = Item.ResID
		local CurItemCfg = ItemCfgTable:FindCfgByKey(ItemResID)
		if CurItemCfg == nil then
			return false
		end

		if CurItemCfg.EasyUse == 1 then
			if CurItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemCollage then
				if CurItemCfg.ItemType == ItemTypeDetail.COLLAGE_COIFFURE then
					_G.HaircutMgr:SendMsgHairQuery()
				end
			end

			return true
		end

		return false
	end)
end


function MultiLanguageTestPanelView:OnGMReceiveRes(MsgBody)
    if nil ~= MsgBody then
		if "eobj" == MsgBody.Cmd then
			local function WaitCreateFinish()
				local ActorTable =_G.UE.UActorManager.Get():GetActorsByResID(self.LastTableID)

				local Length = ActorTable:Length()
				if ActorTable and Length == 1 then
					if self.LastEobj == self.LastTableID then
						return
					end

					self.LastEobj = self.LastTableID

					local Actor = ActorTable:Get(1)
					local CameraComp = UCameraMgr:GetCurrentCameraComp()
					if not CameraComp then
						return
					end

					local CameraForward = CameraComp:GetForwardVector()
					local CameraRight = CameraComp:GetRightVector()
					CameraForward.Z = 0
					CameraForward:Normalize()
					CameraRight.Z = 0
					CameraRight:Normalize()

					local CameraDown = -CameraForward
					local CameraLeft = -CameraRight

					local CameraData = CameraLeft + CameraDown

					CameraData:Normalize()

					local OffsetDistance = 180;

					local Actorlocation = Actor:K2_GetActorLocation()

					local SpawnLocation = Actorlocation + CameraData * OffsetDistance;
					SpawnLocation.Z = Actorlocation.Z

					Actor:K2_SetActorLocation(SpawnLocation, false, nil, false)

					local EntityID = Actor:GetAttributeComponent().EntityID
					local Name = ActorUtil.GetActorName(EntityID)
					-- FLOG_INFO(string.format("koff OnGMReceiveRes LastTableID:%d,Name:%s",self.LastTableID,Name))

					if self.GMType == GMType.Entity and self.SubPanelID == 3 then
						self:TakeScreenshot(Name)
					end

					-- FLOG_INFO(string.format("koff OnGMReceiveRes LastTableID:%d,location.x:%f,location.y:%f,location.z:%f",self.LastTableID,SpawnLocation.X,SpawnLocation.Y,SpawnLocation.Z))
					-- FLOG_INFO(string.format("koff OnGMReceiveRes LastTableID:%d,location.x:%f,location.y:%f,location.z:%f",self.LastTableID,SpawnLocation.X,SpawnLocation.Y,SpawnLocation.Z))
				end
			end

			self.AnimTimerID = _G.TimerMgr:AddTimer(nil, WaitCreateFinish, 0.05, 0, 1)
        end
    end
end

function MultiLanguageTestPanelView:OnDealLootItem(LootItem)
	if LootItem.Type == LOOT_TYPE.LOOT_TYPE_ITEM then --物品
		local Item = ItemCfgTable:FindCfgByKey(LootItem.Item.ResID)
		if not Item then
			return
		end

		local ItemName = ItemCfgTable:GetItemName(LootItem.Item.ResID)
		-- FLOG_INFO(string.format("koff LOOT_TYPE.LOOT_TYPE_ITEM:%s",ItemName))
		if self.GMType == GMType.BluePrint and self.SubPanelID == 1 then
			self:TakeScreenshot(ItemName)
		end
	elseif LootItem.Type == LOOT_TYPE.LOOT_TYPE_SCORE then -- 积分
		local ScoreInfo = ScoreCfg:FindCfgByKey(LootItem.Score.ResID)
		if ScoreInfo == nil then
			return
		end
		-- FLOG_INFO(string.format("koff LOOT_TYPE.LOOT_TYPE_SCORE:%s",ScoreInfo.NameText))
		if self.GMType == GMType.BluePrint and self.SubPanelID == 1 then
			self:TakeScreenshot(ScoreInfo.NameText)
		end
	end

end

return MultiLanguageTestPanelView