---
--- Author: v_zanchang
--- DateTime: 2022-08-24 17:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local RightMenuItemsCfg = require("TableCfg/RightMenuItemsCfg")
local MajorUtil = require("Utils/MajorUtil")
local ArmyMgr = require("Game/Army/ArmyMgr")
local TutorialEvent = require("Game/Tutorial/TutorialEvent")
local MarketMainPanelView = require("Game/Market/View/MarketMainPanelView")
local MarketTabType = MarketMainPanelView.TabType
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local ArmyDefine = require("Game/Army/ArmyDefine")
local MailDefine = require("Game/Mail/MailDefine")
local SocialDefine = require("Game/Social/SocialDefine")
local AchievementDefine = require("Game/Achievement/AchievementDefine")
local MarketDefine = require("Game/Market/MarketDefine")
local BagDefine = require("Game/Bag/BagDefine")
local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local CommSideBarUtil = require("Utils/CommSideBarUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ModuleType = ProtoRes.module_type

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local EventMgr = _G.EventMgr
local EventID = _G.EventID
---@class Main2ndPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field TableView_Menu UTableView
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Main2ndPanelView = LuaClass(UIView, true)

local TableItems
local BarItems
-- local TickCount
local LstCameraMode

function Main2ndPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.TableView_Menu = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Main2ndPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Main2ndPanelView:OnActive()
	_G.EventMgr:SendEvent(EventID.TutorialRestart, {ViewID = self.ViewID})
end

function Main2ndPanelView:OnInit()
	TableItems = {}
	BarItems = {}
	self.CameraParams = nil --保存二级界面角色镜头参数

	local RTagTable = RightMenuItemsCfg:FindAllCfg()

	local MenuType = {Social = 1, Army = 2, GatheringLog = 5, CraftingLog = 6, Market = 10, LegendaryWeapon = 20,  Mail = 13, Achievement = 18, AtlasEntrance = 21, FootPrint = 22, Bag = 19} --映射【G二级界面表】按钮入口ID

	if RTagTable == nil  then
		_G.FLOG_ERROR("RTagTable is Nil")
	end
	-- local TableItems = {}
	local Row = 1
	local Column = 1
	local EndRow = math.ceil(#RTagTable / 3)
	local DealyUnitTime = 1 / 15
	local DelayAllTime = 0
	for index, Info in ipairs(RTagTable) do --tableview每行3Item
		--local Item = table.shallowcopy(Info)
		if Info.IsOpen == 1 then
			local Item = {}
			Item.ID = Info.ID
			Item.Icon = Info.Icon
			Item.BtnName = Info.BtnName
			Item.BtnEntranceID = Info.BtnEntranceID
	
			Item.Row = math.ceil(index / 4)
			if Row > EndRow then
				Row = 1
				Column = Column + 1
			end
			Item.Row = Row
			Item.Column = Column
			Row = Row + 1
			Item.AnimInDelayTime = (EndRow - Item.Row) + (Item.Column - 1)
			Item.AnimInDelayTime = Item.AnimInDelayTime * DealyUnitTime
			Item.BtnEntranceID = Item.BtnEntranceID

			if Item.BtnEntranceID == MenuType.Social then
				Item.RedDotID = SocialDefine.RedDotID.Social
			elseif Item.BtnEntranceID == MenuType.Army then
				Item.RedDotID = ArmyDefine.ArmyRedDotID.Army
			elseif Item.BtnEntranceID == MenuType.GatheringLog then
				Item.RedDotID = 7
			elseif Item.BtnEntranceID == MenuType.CraftingLog then
				Item.RedDotID = 9
			elseif Item.BtnEntranceID == MenuType.LegendaryWeapon then
				Item.RedDotID = 1000
			elseif Item.BtnEntranceID == MenuType.Mail then
				Item.RedDotID = MailDefine.MailMenuRedDotID
			elseif Item.BtnEntranceID == MenuType.AtlasEntrance then
				Item.RedDotID = 13 -- 二级菜单图鉴按钮红点表ID
			elseif Item.BtnEntranceID == MenuType.FootPrint then
				Item.RedDotID = 14 -- 二级菜单足迹按钮红点表ID
			elseif Item.BtnEntranceID == MenuType.Achievement then
				Item.RedDotID = AchievementDefine.RedDotID
			elseif Item.BtnEntranceID == MenuType.Bag then
				Item.RedDotID = BagDefine.RedDotID
			elseif Item.BtnEntranceID == MenuType.Market then
				Item.RedDotID = MarketDefine.MarketRedDotID.Market
			end
			DelayAllTime = DelayAllTime + Item.AnimInDelayTime
			table.insert(TableItems, Item)
		end
	end
	-- TickCount = DelayAllTime / 0.3 + 5
	self.TableViewMenuAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_Menu)
	self.TableViewMenuAdapter:SetOnClickedCallback(self.OnMenuItemClicked)
end

function Main2ndPanelView:OnDestroy()
	TableItems = nil
	BarItems = nil
	-- TickCount = nil
	LstCameraMode = nil
end

function Main2ndPanelView:OnShow()
	self.TableViewMenuAdapter:UpdateAll(TableItems)

	--隐藏其他玩家,NPC名字
	_G.HUDMgr:HideOtherPlayer()
	_G.HUDMgr:UpdateActorVisibility(MajorUtil.GetMajorEntityID(), false, false)
	_G.HUDMgr:HideAllNpc()
end

function Main2ndPanelView:PlayAnimDelayTime()
	EventMgr:SendEvent(EventID.Main2ndPanelMenuAnimNotify, nil)
end

function Main2ndPanelView:OnEditableTextNameChanged(_, Text)
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

function Main2ndPanelView:OnHide()
	--显示其他玩家,NPC名字
	_G.HUDMgr:UpdateActorVisibility(MajorUtil.GetMajorEntityID(), true, true)
	_G.HUDMgr:ShowAllPlayer()
	_G.HUDMgr:ShowAllNpc()
end

function Main2ndPanelView:OnRegisterUIEvent()
	local PlayCloseAni = function()
		self:PlayAnimation(self.AnimOut1, 0, 1)
	end
	self.CloseBtn:SetCallback(self, PlayCloseAni)
end

function Main2ndPanelView:OnRegisterGameEvent()

end

function Main2ndPanelView:OnRegisterBinder()

end

function Main2ndPanelView:OnMenuItemClicked(Index, ItemData, ItemView)
	local MenuType = {Social = 1, Team = 2, PWorld = 3, Glamours = 4, GatheringLog = 5, MakeNotes = 6, FishNotes = 7, Mount = 8, Store = 9,
	Transaction = 10, Settings = 11, TutorialGuide = 12, Mail = 13, Companion = 14, Buddy = 15, LeveQuest = 16, MusicPerformance = 17, Achievement = 18,
	Bag = 19, LegendaryWeapon = 20, AtlasEntrance = 21, FootPrint = 22, CollectiblesTrade = 23, GoldSauserMainPanel = 24, PVPInfo = 25,TreasureHunt = 26,} --映射【G二级界面表】按钮入口ID
	

	if not _G.ModuleOpenMgr:ModuleState(ItemView.ModuleID) then
		return
	end

	if ItemView.RedDotID ~= nil then
		_G.RedDotMgr:DelRedDotByID(ItemView.RedDotID)
		_G.ModuleOpenMgr.NeesShowRedDotList[ItemView.RedDotID] = nil
	end

	if MenuType.Team == ItemData.BtnEntranceID then
		ArmyMgr:OpenArmyMainPanel()
	elseif MenuType.Social == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.SocialMainPanel)
	elseif MenuType.Settings == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.Settings)
		-- UIViewMgr:ShowView(UIViewID.CameraModify)
	elseif MenuType.PWorld == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.PWorldEntrancePanel)
	elseif MenuType.Mount == ItemData.BtnEntranceID then
		CommSideBarUtil.ShowSideBarByType(SideBarDefine.PanelType.EasyToUse, SideBarDefine.EasyToUseTabType.Mount)
	elseif MenuType.Glamours == ItemData.BtnEntranceID then
		_G.WardrobeMgr:OpenWardrobeMainPanel()
	elseif MenuType.GatheringLog == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.GatheringLogMainPanelView)
	elseif MenuType.MakeNotes == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.CraftingLog)
	elseif MenuType.FishNotes == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.FishInghole)
	elseif MenuType.Transaction == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.MarketMainPanel)
		--UIViewMgr:ShowView(UIViewID.MarketMainPanel, {TabIndex = MarketTabType.MarketTypeBuy})
		--UIViewMgr:ShowView(UIViewID.MarketMainPanel, {TabIndex = MarketTabType.MarketTypeSell})
		--UIViewMgr:ShowView(UIViewID.MarketMainPanel, {JumpToBuyItemID = 62600028})
		--UIViewMgr:ShowView(UIViewID.MarketMainPanel, {JumpToSellItemGID = 3310608027510473305})
		--UIViewMgr:ShowView(UIViewID.MarketMainPanel, {JumpToSellItemGID = 3310608027891234812})
	elseif MenuType.Store == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.ShopInletPanelView)
	elseif MenuType.TutorialGuide == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.TutorialGuidePanel)
	elseif MenuType.Mail == ItemData.BtnEntranceID then
		_G.MailMgr:OpenMailMainView()
	elseif MenuType.Buddy == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.BuddyMainPanel)
	elseif MenuType.Companion == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.CompanionListPanel)
    elseif MenuType.GoldSauserMainPanel == ItemData.BtnEntranceID then
		GoldSauserMainPanelMgr:OpenGoldSauserMainPanel()
	elseif MenuType.LeveQuest == ItemData.BtnEntranceID then
		UIViewMgr:ShowView(UIViewID.LeveQuestMainPanel)
	elseif MenuType.MusicPerformance == ItemData.BtnEntranceID then
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
	-- elseif MenuType.PVPInfo == ItemData.BtnEntranceID then
	-- 	UIViewMgr:ShowView(UIViewID.PVPInfoPanel)
	elseif MenuType.TreasureHunt == ItemData.BtnEntranceID then
		_G.TreasureHuntMgr:OpenTreasureHuntMainPanel()
	else
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, "提示", "暂未开放，尽请期待!", nil)
	end

	self:Hide()
end

function Main2ndPanelView:OnAnimationFinished(Animation)
	if self.AnimOut1 == Animation then
		UIViewMgr:HideView(_G.UIViewID.Main2ndPanel)
	end
end

return Main2ndPanelView