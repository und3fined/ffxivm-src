---
--- Author: Administrator
--- DateTime: 2024-09-13 11:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local RightMenuItemsCfg = require("TableCfg/RightMenuItemsCfg")
local MajorUtil = require("Utils/MajorUtil")
local ArmyMgr = require("Game/Army/ArmyMgr")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local ProtoRes = require("Protocol/ProtoRes")
local Main2ndPanelDefine = require("Game/Main2nd/Main2ndPanelDefine")
--local QuestMgr = require("Game/Quest/QuestMgr")
local ModuleType = ProtoRes.module_type
local ProtoCS = require("Protocol/ProtoCS")
local AdventureRecommendTaskMgr = require("Game/Adventure/AdventureRecommendTaskMgr")
local QuestHelper = require("Game/Quest/QuestHelper")
--local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local TipsUtil = require("Utils/TipsUtil")
local HelpCfg = require("TableCfg/HelpCfg")
local UUIUtil = _G.UE.UUIUtil
local FVector2D = _G.UE.FVector2D
local UIUtil = require("Utils/UIUtil")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local OperationUtil = require("Utils/OperationUtil")
local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local CommSideBarUtil = require("Utils/CommSideBarUtil")
local CommonDefine = require("Define/CommonDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local EventMgr = _G.EventMgr
local EventID = _G.EventID

---@class Main2ndPanelNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSidebarFrame CommSidebarFrameSView
---@field TableView_Menu UTableView
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Main2ndPanelNewView = LuaClass(UIView, true)

local TableItems
local BarItems
local LstCameraMode
local MenuType = Main2ndPanelDefine.MenuType
function Main2ndPanelNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSidebarFrame = nil
	--self.TableView_Menu = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Main2ndPanelNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSidebarFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Main2ndPanelNewView:OnInit()
	TableItems = {}
	BarItems = {}
	self.CameraParams = nil --保存二级界面角色镜头参数

	local RTagTable = RightMenuItemsCfg:FindAllCfg()

	if RTagTable == nil  then
		_G.FLOG_ERROR("RTagTable is Nil")
		return
	end
	-- local TableItems = {}
	local Row = 1
	local Column = 1
	local EndRow = math.ceil(#RTagTable / 3)
	--local DealyUnitTime = 1 / 15
	--local DelayAllTime = 0
	for index, Info in ipairs(RTagTable) do --tableview每行3Item
		--local Item = table.shallowcopy(Info)
		if Info.IsOpen == 1 then
			local Item = {}
			Item.ID = Info.ID
			Item.SortID = Info.SortID
			Item.Icon = Info.Icon
			Item.BtnName = Info.BtnName
			Item.BtnEntranceID = Info.BtnEntranceID
			Item.BtnRedDotID = Info.BtnRedDotID
			Item.RecLockHelpID = Info.RecLockHelpID
			Item.RecUnlockHelpID = Info.RecUnlockHelpID
			Item.IsShowTaskUI = Info.IsShowTaskUI == 1

			Item.Row = math.ceil(index / 4)
			if Row > EndRow then
				Row = 1
				Column = Column + 1
			end
			Item.Row = Row
			Item.Column = Column
			Row = Row + 1
			--Item.AnimInDelayTime = (EndRow - Item.Row) + (Item.Column - 1)
			--Item.AnimInDelayTime = Item.AnimInDelayTime * DealyUnitTime
			Item.BtnEntranceID = Item.BtnEntranceID

			--DelayAllTime = DelayAllTime + Item.AnimInDelayTime
			table.insert(TableItems, Item)
		end
	end
	---二级界面按SortID排序，无SortID或者配置出错导致相等时使用ID排序
	table.sort(TableItems, function(a, b) 
		if a.SortID and b.SortID and a.SortID ~= b.SortID then
			return a.SortID < b.SortID
		else
			return a.ID < b.ID
		end
	end)
	-- TickCount = DelayAllTime / 0.3 + 5
	self.TableViewMenuAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_Menu)
	self.TableViewMenuAdapter:SetOnClickedCallback(self.OnMenuItemClicked)
end

function Main2ndPanelNewView:OnDestroy()
	TableItems = nil
	BarItems = nil
	LstCameraMode = nil
end

function Main2ndPanelNewView:OnShow()
	-- LSTR string:菜单
	self.CommSidebarFrame:SetTitleText(LSTR(1210003))

	self.TableViewMenuAdapter:UpdateAll(TableItems)

	--隐藏其他玩家,NPC名字
	_G.HUDMgr:SetIsDrawHUD(false)
	_G.UE.USelectEffectMgr.Get():ShowDecal(false)
	_G.TargetMgr:SetHardLockEffectMask(CommonDefine.HardLockEffectMaskType.SecondMenu, true)
	-- _G.HUDMgr:UpdateActorVisibility(MajorUtil.GetMajorEntityID(), false, false)
	-- _G.HUDMgr:HideAllNpc()

	_G.EventMgr:SendEvent(EventID.TutorialShowView, self.ViewID)
end

function Main2ndPanelNewView:PlayAnimDelayTime()
	--EventMgr:SendEvent(EventID.Main2ndPanelMenuAnimNotify, nil)
end

function Main2ndPanelNewView:OnEditableTextNameChanged(_, Text)
	local Major = MajorUtil.GetMajor()
	local Camera = Major:GetCameraControllComponent()
	local CameraParams = _G.UE.FCameraResetParam()
	local Params = {}
	Params.CameraConfig = 1
	    -- 相机设置
	if Params.CameraConfig ~= 0 then

		if(Camera:IsCameraInUIAnimation() == false) then
			self.RawCameraParams = _G.UE.FCameraResetParam() --摄像机原来的参数
			self.RawCameraParams.Distance = Camera:GetTargetArmLength()
			self.RawCameraParams.Rotator = Camera:GetCameraBoomRelativeRotation()
			self.RawCameraParams.SocketExternOffset = Camera:GetSocketTargetOffset() -- Camera:GetSocketExternOffset()
			self.RawCameraParams.FOV = Camera:GetATPCCameraFOV()
			self.RawCameraParams.bRelativeRotator = false
		end

		local Param = string.split(Text, ",")
		if #Param < 7 then -- (Distance[1],Rotator[3],TargetOffset[3])
			Camera:ResetSpringArmForUI(CameraParams, 0.5)
			return
		end

		CameraParams.Distance = string.format("%d", Param[1])
		CameraParams.Rotator = _G.UE.FRotator(string.format("%d", Param[2]), string.format("%d", Param[3]), string.format("%d", Param[4]))
		CameraParams.SocketExternOffset = _G.UE.FVector(string.format("%d", Param[5]), string.format("%d", Param[6]), string.format("%d", Param[7]))
		--CameraParams.FOV = Camera:GetATPCCameraFOV()
		Camera:ResetSpringArmForUI(CameraParams, 0.5)
	end

end

function Main2ndPanelNewView:OnHide()
	UIViewMgr:HideView(UIViewID.OperationChannelPanel)
	--显示其他玩家,NPC名字
	_G.HUDMgr:SetIsDrawHUD(true)
	_G.UE.USelectEffectMgr.Get():ShowDecal(true)
	_G.TargetMgr:SetHardLockEffectMask(CommonDefine.HardLockEffectMaskType.SecondMenu, false)
	-- _G.HUDMgr:ShowAllPlayer()
	-- _G.HUDMgr:ShowAllNpc()
	OperationUtil.HasInitOperationMenuItems = false
end

function Main2ndPanelNewView:OnRegisterUIEvent()

end

function Main2ndPanelNewView:OnRegisterGameEvent()
    --self:RegisterGameEvent(EventID.UpdateQuest, self.OnUpdateQuest)
end

-- function Main2ndPanelNewView:OnUpdateQuest(Params)

-- end

function Main2ndPanelNewView:OnRegisterBinder()

end

function Main2ndPanelNewView:OnMenuItemClicked(Index, ItemData, ItemView)
	local IsShowUnOpenTips = false
	local IsNeedHidePanel = true

	if ItemView == nil then
		return
	end

	if ItemView.BtnEntranceID == MenuType.Transaction then
		if _G.MarketMgr:CanUnLockMarket() == false then
			self:ShowLockTips(ItemData, ItemView)
			return
		end
	else
		if not _G.ModuleOpenMgr:CheckOpenState(ItemView.ModuleID) then
			self:ShowLockTips(ItemData, ItemView)
			return
		end
	end

	if ItemView and ItemView.RedDotID ~= nil then
		_G.RedDotMgr:DelRedDotByID(ItemView.RedDotID)
		_G.ModuleOpenMgr.NeesShowRedDotList[ItemView.ModuleID] = nil
		if ItemData.BtnRedDotID and ItemData.BtnRedDotID ~= 0 then
			ItemView.CommonRedDot_UIBP:SetRedDotIDByID(ItemData.BtnRedDotID)
		end
	end

	if MenuType.Team == ItemData.BtnEntranceID then
		ArmyMgr:OpenArmyMainPanel()
	elseif MenuType.Social == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.SocialMainPanel)
		--OperationUtil.ShowGameBotRedDot(false)
	elseif MenuType.Settings == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.Settings)
		-- UIViewMgr:ShowView(UIViewID.CameraModify)
	elseif MenuType.PWorld == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.PWorldEntrancePanel)
	elseif MenuType.Mount == ItemData.BtnEntranceID then
		DataReportUtil.ReportMountInterfaceFlowData("MountInterfaceFlow", 2, 0)
		DataReportUtil.ReportMountInterSystemFlowData(1, 1)
		CommSideBarUtil.ShowSideBarByType(SideBarDefine.PanelType.EasyToUse, SideBarDefine.EasyToUseTabType.Mount, {bOpen = true})
	elseif MenuType.Glamours == ItemData.BtnEntranceID then
		_G.WardrobeMgr:OpenWardrobeMainPanel()
	elseif MenuType.GatheringLog == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.GatheringLogMainPanelView)
	elseif MenuType.MakeNotes == ItemData.BtnEntranceID then
		if (_G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()) then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.CannotFightSkillPanel)
			return
		end
		UIViewMgr:ShowView(UIViewID.CraftingLog)
	elseif MenuType.FishNotes == ItemData.BtnEntranceID then
		DataReportUtil.ReportSystemFlowData("FishingNotesInfo", 1, 2)
		UIViewMgr:ShowView(UIViewID.FishInghole)
	elseif MenuType.Transaction == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.MarketMainPanel)
		--UIViewMgr:ShowView(UIViewID.MarketMainPanel, {TabIndex = MarketTabType.MarketTypeBuy})
		--UIViewMgr:ShowView(UIViewID.MarketMainPanel, {TabIndex = MarketTabType.MarketTypeSell})
		--UIViewMgr:ShowView(UIViewID.MarketMainPanel, {JumpToBuyItemID = 62600028})
		--UIViewMgr:ShowView(UIViewID.MarketMainPanel, {JumpToSellItemGID = 3310608027510473305})
		--UIViewMgr:ShowView(UIViewID.MarketMainPanel, {JumpToSellItemGID = 3310608027891234812})
	elseif MenuType.Shop == ItemData.BtnEntranceID then
		_G.ShopMgr:OpenInletMainView(1)
	elseif MenuType.TutorialGuide == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.TutorialGuidePanel)
	elseif MenuType.Mail == ItemData.BtnEntranceID then
		_G.MailMgr:OpenMailMainView()
	elseif MenuType.Buddy == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.BuddyMainPanel)
	elseif MenuType.Companion == ItemData.BtnEntranceID then
		DataReportUtil.ReportEasyUseFlowData(1,3)
		CommSideBarUtil.ShowSideBarByType(SideBarDefine.PanelType.EasyToUse, SideBarDefine.EasyToUseTabType.Companion, {bOpen = true})
    elseif MenuType.GoldSauserMainPanel == ItemData.BtnEntranceID then
		GoldSauserMainPanelMgr:OpenGoldSauserMainPanel()
	elseif MenuType.LeveQuest == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.LeveQuestMainPanel)
	elseif MenuType.MusicPerformance == ItemData.BtnEntranceID then
		if (_G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()) then
			local Content = LSTR(830128)
			MsgTipsUtil.ShowTips(Content)
			return
		end
		if _G.MusicPerformanceMgr:CanPerformance() then
			UIViewMgr:ShowView(UIViewID.MusicPerformanceSelectPanelView)
		end
	elseif MenuType.Bag == ItemData.BtnEntranceID then
		if not _G.LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_BAG, true) then
			return
		end
		UIViewMgr:ShowView(UIViewID.BagMain)
	elseif MenuType.LegendaryWeapon == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.LegendaryWeaponPanel, {OpenSource = 2})
	elseif MenuType.Achievement == ItemData.BtnEntranceID then
		_G.AchievementMgr:OpenAchievementEntryPanelView()
	elseif MenuType.AtlasEntrance == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.GuideMainPanelView)
	elseif MenuType.FootPrint == ItemData.BtnEntranceID then
		_G.FootPrintMgr:OpenFootPrintMainPanel(true)
	elseif MenuType.CollectiblesTrade == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.CollectablesMainPanelView)
	elseif MenuType.PVPInfo == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.PVPInfoPanel)
	elseif MenuType.TreasureHunt == ItemData.BtnEntranceID then
		_G.WorldExploraMgr:OpenWorldExploreMain()
	elseif MenuType.Ornament == ItemData.BtnEntranceID then
		CommSideBarUtil.ShowSideBarByType(SideBarDefine.PanelType.EasyToUse, SideBarDefine.EasyToUseTabType.FashionDeco, {bOpen = true})
	elseif MenuType.Store == ItemData.BtnEntranceID then
		if _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MALL, true) then
		    _G.StoreMgr:ShowMainPanel()
		end
	elseif MenuType.OperationMore == ItemData.BtnEntranceID then
		local OperationMenuItems = OperationUtil.GetOperationMenuItems()
		if #OperationMenuItems > 0 then
			UIViewMgr:ShowView(UIViewID.OperationChannelPanel, { InWidget = ItemView, EntrySpacing = self.TableView_Menu:GetEntrySpacing() })
			IsNeedHidePanel = false
		else
			IsShowUnOpenTips = true
		end
	elseif MenuType.BattlePass == ItemData.BtnEntranceID then
		if not _G.LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_PASSPORT, true) then
			return
		end
		UIViewMgr:ShowView(UIViewID.BattlePassMainView)
	elseif MenuType.Announcement == ItemData.BtnEntranceID then
		_G.PandoraMgr:OpenAnnouncement()
	elseif MenuType.OperationActivity == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.OpsActivityMainPanel)
	elseif MenuType.GameBot == ItemData.BtnEntranceID then
		OperationUtil.OpenGameBot("")
		OperationUtil.ShowGameBotRedDot(false, 1)
	elseif MenuType.CompanySeal == ItemData.BtnEntranceID then
		_G.CompanySealMgr:OpenCompanyTaskView()
	else
		---LSTR 提示 LSTR 暂未开放，敬请期待!
		--_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10032), LSTR(10062), nil)
		IsShowUnOpenTips = true
	end

	if IsShowUnOpenTips then
		---LSTR 提示 LSTR 暂未开放，敬请期待!
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10032), LSTR(10062), nil)
	end

	if IsNeedHidePanel == true then
		self:Hide()
	end
end

function Main2ndPanelNewView:OnAnimationFinished(Animation)
	if self.AnimOut1 == Animation then
		UIViewMgr:HideView(_G.UIViewID.Main2ndPanel)
	end
end

function Main2ndPanelNewView:ShowLockTips(ItemData, ItemView)
	if ItemView == nil then
		return
	end
	local ModuleOpenData = _G.ModuleOpenMgr:GetCfgByModuleID(ItemView.ModuleID) 
	local IsRecommendTask = false
	local TaskID
	local HelpInfoID = ItemData.RecLockHelpID
	if ModuleOpenData then
		---目前只显示一个任务,默认显示配置第一个
		for _, ID in ipairs(ModuleOpenData.PreTask) do
			local QuestCfg = QuestHelper.GetQuestCfgItem(ID)
			if QuestCfg ~= nil then
				local RecommendTask =  AdventureRecommendTaskMgr:GetRecommendTask()
				if RecommendTask then
					IsRecommendTask =  table.contain(RecommendTask, QuestCfg.ChapterID)
				end
				break
			end
		end
		if IsRecommendTask then
			HelpInfoID = ItemData.RecUnlockHelpID
		end
		if ModuleOpenData.PreTask and ModuleOpenData.PreTask[1] then
			TaskID = ModuleOpenData.PreTask[1]
		end
	end
	local TargetWidget = ItemView.ImgLockIcon or ItemView
	local Offset = FVector2D( 0, 0)
	local TargetWidgetSize = UUIUtil.GetLocalSize(TargetWidget)
	--- 显示未解锁提示文本tips
	local Params
	---美术同学要求无任务tips使用通用文本tips
	if ItemData.IsShowTaskUI and TaskID then
		Params = {
			ID = HelpInfoID,
			-- LSTR string:解锁条件
			TitleText = LSTR(1210001),
			InTargetWidget =TargetWidget,	
			Offset = Offset,
			Alignment = FVector2D( 1, 0),
			IsAutoFlip = true,
			TaskID = TaskID,
			IsShowTaskUI = ItemData.IsShowTaskUI,
		}
		UIViewMgr:ShowView(UIViewID.Main2ndHelpInfoTips, Params)
	else
		---通用tips无反转逻辑，需要额外处理
		local IsFlip = not self:PosIsUpInViewport(TargetWidget)
		if TargetWidget then
			TargetWidgetSize = UUIUtil.GetLocalSize(TargetWidget)
			Offset = FVector2D( - TargetWidgetSize.X, 0)
		end
		local Alignment
		if IsFlip then
			Alignment = FVector2D(1, 1)
			Offset.Y = Offset.Y + TargetWidgetSize.Y
		else
			Alignment = FVector2D(1, 0)
			Offset.Y = Offset.Y  + 5
		end
		local HelpCfgs = HelpCfg:FindAllHelpIDCfg(HelpInfoID)
		local TipsContent = HelpInfoUtil.ParseText(HelpInfoUtil.ParseContent(HelpCfgs))
		if TipsContent then
			TipsUtil.ShowInfoTitleTips(TipsContent, TargetWidget, Offset, Alignment, false)
		end
	end
end

---计算控件是否在屏幕上半部分
function Main2ndPanelNewView:PosIsUpInViewport(Widget)
	local TargetWidget = Widget
	local WindowAbsolute = UIUtil.ScreenToWidgetAbsolute(FVector2D(0, 0), false) or FVector2D(0, 0)
	local ViewportSize = UIUtil.GetViewportSize()
	local TragetAbsolute = UIUtil.GetWidgetAbsolutePosition(TargetWidget)
	if TragetAbsolute.Y - WindowAbsolute.Y  > ViewportSize.Y / 2 then
		return false
	else
		return true
	end
end

return Main2ndPanelNewView