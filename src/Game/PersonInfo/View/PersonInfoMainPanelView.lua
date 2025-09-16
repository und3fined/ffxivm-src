---
--- Author: xingcaicao
--- DateTime: 2023-04-13 15:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ProtoCS = require("Protocol/ProtoCS")
local LoginMgr = require("Game/Login/LoginMgr")
local RaceCfg = require("TableCfg/RaceCfg")
local EquipmentCameraControlDataLoader = require("Game/Equipment/EquipmentCameraControlDataLoader")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local SystemLightCfg = require("TableCfg/SystemLightCfg")

local UIBinderSetHead = require("Binder/UIBinderSetHead")
local UIBinderSetFrameIcon = require("Binder/UIBinderSetFrameIcon")

local ProtoCommon = require("Protocol/ProtoCommon")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProfUtil = require("Game/Profession/ProfUtil")

local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ActorUtil = require("Utils/ActorUtil")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local MajorUtil = require("Utils/MajorUtil")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")

local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")

local SimpleViewSource = PersonInfoDefine.SimpleViewSource

local LightDefine = require("Game/Light/LightDefine")
local LightLevelID = LightDefine.LightLevelID
local LightID = LightLevelID.LIGHT_LEVEL_ID_EQUIP

local LSTR = _G.LSTR
local ClientSetupKey = ProtoCS.ClientSetupKey
local ModuleType = PersonInfoDefine.ModuleType
local RenderActorPath = ModelDefine.StagePath.Universe 
local TipsUtil = require("Utils/TipsUtil")
local MSDKDefine = require("Define/MSDKDefine")
local OperationUtil = require("Utils/OperationUtil")

local WeatgerTODID = 25

---@class PersonInfoMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyBadge ArmyBadgeItemView
---@field ArmyDetailNode UFHorizontalBox
---@field BaseInfoNode UFCanvasPanel
---@field BtnAddFriend UFButton
---@field BtnAndArmyNode UFButton
---@field BtnArmy UFButton
---@field BtnChangeofName UFButton
---@field BtnChat UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnEditSign UFButton
---@field BtnFormerName UFButton
---@field BtnHoursSet UFButton
---@field BtnLaunchPrivilege UFButton
---@field BtnMoreProf UFButton
---@field BtnOnlineSet UFButton
---@field BtnPortraitEdit UFButton
---@field BtnPrivilege UFButton
---@field BtnProfSet UFButton
---@field BtnSet UFButton
---@field BtnStyleSet UFButton
---@field BtnTitleSet UFButton
---@field CommTabsModule CommVerIconTabsView
---@field CommonBkg CommonBkg01View
---@field CommonRedDot CommonRedDotView
---@field CommonRedDotPortrait CommonRedDotView
---@field CommonRedDotSet CommonRedDotView
---@field CommonRender2D CommonRender2DView
---@field CommonTitle CommonTitleView
---@field EditBtnImg UFImage
---@field EquiPanel PersonInfoEquiPanelView
---@field FHorizontalNoneSignTips UFHorizontalBox
---@field IconEdit UFImage
---@field IconGood UFImage
---@field IconJob UFImage
---@field IconOnline UFImage
---@field IconPrivilege UFImage
---@field IconStart UFImage
---@field ImgArrow UFImage
---@field ImgBtnArmySet UFImage
---@field ImgBtnBg UFImage
---@field ImgOnlineSet UFImage
---@field ImgRank UFImage
---@field ImgServer UFImage
---@field ImgTitleSet UFImage
---@field InfoBtnPanel PersonlnfoSetTipsView
---@field Mask UFButton
---@field Mask_InfoPanel UFButton
---@field MulEditTextSign CommMultilineInputBoxView
---@field NameBtnPanel PersonlnfoSetTipsView
---@field PanelArrow UFCanvasPanel
---@field PanelPrivilege UFCanvasPanel
---@field PanelRank UFCanvasPanel
---@field PanelSet UFCanvasPanel
---@field PanelStart UFCanvasPanel
---@field PersonInfoPlayer PersonInfoPlayerItemView
---@field PersonInfoProf PersonInfoProfPanelView
---@field PortraitNode CommonPlayerPortraitItemView
---@field RankAndArmyState UFCanvasPanel
---@field ServerNode UHorizontalBox
---@field SizeBox1 USizeBox
---@field SizeBox2 USizeBox
---@field SizeBoxEdit USizeBox
---@field TableViewProf UTableView
---@field TableViewRestDayL UTableView
---@field TableViewRestDayR UTableView
---@field TableViewStyle UTableView
---@field TableViewWeekdayL UTableView
---@field TableViewWeekdayR UTableView
---@field TextArmyName UFTextBlock
---@field TextGood UFTextBlock
---@field TextGoodNothing UFTextBlock
---@field TextGoodTitle UFTextBlock
---@field TextJobLevel UFTextBlock
---@field TextNoneArmyTips UFTextBlock
---@field TextNoneArmyTips2 UFTextBlock
---@field TextNoneSignTips UFTextBlock
---@field TextNotes UFTextBlock
---@field TextOnline UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextPlayerTitle UFTextBlock
---@field TextPlayerTitle2 UFTextBlock
---@field TextPreference UFTextBlock
---@field TextPrivilege UFTextBlock
---@field TextRank UFTextBlock
---@field TextRank2 UFTextBlock
---@field TextRestDay UFTextBlock
---@field TextServer UFTextBlock
---@field TextStart UFTextBlock
---@field TextStyle UFTextBlock
---@field TextTime UFTextBlock
---@field TextTime2 UFTextBlock
---@field TextTimeTitle UFTextBlock
---@field TextWeekday UFTextBlock
---@field AnimChangeTab UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimRankUp UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoMainPanelView = LuaClass(UIView, true)

function PersonInfoMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyBadge = nil
	--self.ArmyDetailNode = nil
	--self.BaseInfoNode = nil
	--self.BtnAddFriend = nil
	--self.BtnAndArmyNode = nil
	--self.BtnArmy = nil
	--self.BtnChangeofName = nil
	--self.BtnChat = nil
	--self.BtnClose = nil
	--self.BtnEditSign = nil
	--self.BtnFormerName = nil
	--self.BtnHoursSet = nil
	--self.BtnLaunchPrivilege = nil
	--self.BtnMoreProf = nil
	--self.BtnOnlineSet = nil
	--self.BtnPortraitEdit = nil
	--self.BtnPrivilege = nil
	--self.BtnProfSet = nil
	--self.BtnSet = nil
	--self.BtnStyleSet = nil
	--self.BtnTitleSet = nil
	--self.CommTabsModule = nil
	--self.CommonBkg = nil
	--self.CommonRedDot = nil
	--self.CommonRedDotPortrait = nil
	--self.CommonRedDotSet = nil
	--self.CommonRender2D = nil
	--self.CommonTitle = nil
	--self.EditBtnImg = nil
	--self.EquiPanel = nil
	--self.FHorizontalNoneSignTips = nil
	--self.IconEdit = nil
	--self.IconGood = nil
	--self.IconJob = nil
	--self.IconOnline = nil
	--self.IconPrivilege = nil
	--self.IconStart = nil
	--self.ImgArrow = nil
	--self.ImgBtnArmySet = nil
	--self.ImgBtnBg = nil
	--self.ImgOnlineSet = nil
	--self.ImgRank = nil
	--self.ImgServer = nil
	--self.ImgTitleSet = nil
	--self.InfoBtnPanel = nil
	--self.Mask = nil
	--self.Mask_InfoPanel = nil
	--self.MulEditTextSign = nil
	--self.NameBtnPanel = nil
	--self.PanelArrow = nil
	--self.PanelPrivilege = nil
	--self.PanelRank = nil
	--self.PanelSet = nil
	--self.PanelStart = nil
	--self.PersonInfoPlayer = nil
	--self.PersonInfoProf = nil
	--self.PortraitNode = nil
	--self.RankAndArmyState = nil
	--self.ServerNode = nil
	--self.SizeBox1 = nil
	--self.SizeBox2 = nil
	--self.SizeBoxEdit = nil
	--self.TableViewProf = nil
	--self.TableViewRestDayL = nil
	--self.TableViewRestDayR = nil
	--self.TableViewStyle = nil
	--self.TableViewWeekdayL = nil
	--self.TableViewWeekdayR = nil
	--self.TextArmyName = nil
	--self.TextGood = nil
	--self.TextGoodNothing = nil
	--self.TextGoodTitle = nil
	--self.TextJobLevel = nil
	--self.TextNoneArmyTips = nil
	--self.TextNoneArmyTips2 = nil
	--self.TextNoneSignTips = nil
	--self.TextNotes = nil
	--self.TextOnline = nil
	--self.TextPlayerName = nil
	--self.TextPlayerTitle = nil
	--self.TextPlayerTitle2 = nil
	--self.TextPreference = nil
	--self.TextPrivilege = nil
	--self.TextRank = nil
	--self.TextRank2 = nil
	--self.TextRestDay = nil
	--self.TextServer = nil
	--self.TextStart = nil
	--self.TextStyle = nil
	--self.TextTime = nil
	--self.TextTime2 = nil
	--self.TextTimeTitle = nil
	--self.TextWeekday = nil
	--self.AnimChangeTab = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimRankUp = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyBadge)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommTabsModule)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.CommonRedDotPortrait)
	self:AddSubView(self.CommonRedDotSet)
	self:AddSubView(self.CommonRender2D)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.EquiPanel)
	self:AddSubView(self.InfoBtnPanel)
	self:AddSubView(self.MulEditTextSign)
	self:AddSubView(self.NameBtnPanel)
	self:AddSubView(self.PersonInfoPlayer)
	self:AddSubView(self.PersonInfoProf)
	self:AddSubView(self.PortraitNode)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoMainPanelView:OnInit()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()

	self.TableAdapterProf = UIAdapterTableView.CreateAdapter(self, self.TableViewProf)
	self.TableAdapterStyle = UIAdapterTableView.CreateAdapter(self, self.TableViewStyle)

	self.TableAdapterWeekdayL = UIAdapterTableView.CreateAdapter(self, self.TableViewWeekdayL)
	self.TableAdapterWeekdayR = UIAdapterTableView.CreateAdapter(self, self.TableViewWeekdayR)
	self.TableAdapterRestDayL = UIAdapterTableView.CreateAdapter(self, self.TableViewRestDayL)
	self.TableAdapterRestDayR = UIAdapterTableView.CreateAdapter(self, self.TableViewRestDayR)

	self.BtnClose:SetCallback(self, self.OnClickCloseButton)
	self.MulEditTextSign:SetCallback(self, nil, self.OnTextCommittedSign)

	self.BindersPersonInfoVM = {
		{ "CurPerferredProfVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterProf) },
		{ "CurGameStyleVMList", 	UIBinderUpdateBindableList.New(self, self.TableAdapterStyle) },
		{ "IsPerferredProfEmpty", 	UIBinderSetIsVisible.New(self, self.PerferredProfEmptyTips) },
		{ "IsPerferredProfEmpty", 	UIBinderSetIsVisible.New(self, self.TextPreference, true) },
		{ "IsPerferredProfEmpty", 	UIBinderSetIsVisible.New(self, self.TableViewProf, true) },
		{ "ArmySimpleInfo", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedArmySimpleInfo) },

		{ "bIsHoldWeapon", 			UIBinderValueChangedCallback.New(self, nil, self.PoseStyleSwitch) },
		{ "bIsShowHead", 			UIBinderValueChangedCallback.New(self, nil, self.HatVisibleSwitch) },
	}

	self.Binders = {
		{ "HeadFrameID", UIBinderSetFrameIcon.New(self, self.PersonInfoPlayer.ImgFrame) },
		{ "HeadInfo", 	UIBinderSetHead.New(self, self.PersonInfoPlayer.ImgPlayer) },
		{ "Prof", 		UIBinderSetProfIcon.New(self, self.IconJob) },
		{ "Level", 		UIBinderSetText.New(self, self.TextJobLevel) },
		{ "TitleID",  	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedTitleID) },
		-- { "LevelColor", UIBinderSetColorAndOpacityHex.New(self, self.TextJobLevel) },
		{ "MVPTimes",   UIBinderValueChangedCallback.New(self, nil, self.OnBindCBMvpTimes) },
	}

	self.BindersExMajor = {
		{ "OnlineStatus", UIBinderValueChangedCallback.New(self, nil, self.UpdateMajorOnlineStatus) },
		{ "OnlineStatusCustomID", UIBinderValueChangedCallback.New(self, nil, self.UpdateMajorOnlineStatus) },
	}

	self.BindersEx = {
		{ "OnlineStatusName", UIBinderSetText.New(self, self.TextOnline) },
		{ "OnlineStatusIcon", UIBinderSetImageBrush.New(self, self.IconOnline) },
	}

	self:InitLSTR()

end

function PersonInfoMainPanelView:InitLSTR()
	self.CommonTitle:SetTextTitleName(LSTR(620045))

	-- self.TextTitleName:SetText(LSTR(620045))

	self.TextNoneArmyTips:SetText(LSTR(620046))
	self.TextPreference:SetText(LSTR(620047))
	self.TextNoneArmyTips2:SetText(LSTR(620060))

	-- 暂时先不用了
	-- self.TextGood:SetText(LSTR(620048))
	-- UIUtil.SetIsVisible(self.TextGood, false)

	self.TextStyle:SetText(LSTR(620049))
	self.TextWeekday:SetText(LSTR(620050))
	self.TextRestDay:SetText(LSTR(620051))

	self.TextGoodNothing:SetText(LSTR(620136))
	self.TextTime:SetText(LSTR(620062))
	self.TextTime2:SetText(LSTR(620063))

	self.TextPlayerTitle2:SetText(LSTR(620120))
	self.TextRank2:SetText(LSTR(620121))
	self.TextGoodTitle:SetText(LSTR(620122))
	self.TextTimeTitle:SetText(LSTR(620123))

	self.TextNoneSignTips:SetText(LSTR(620137))
end

function PersonInfoMainPanelView:OnDestroy()

end

function PersonInfoMainPanelView:OnShow()
	self.PortraitNode:SetParams({Data = PersonInfoVM.RoleVM})

	_G.PersonPortraitMgr:QueryInitData()
	_G.HUDMgr:SetIsDrawHUD(false)

	--展示背景
	self:ShowModuleBg()

	self.CurTabIdx = 1 
	self.IsMajor = PersonInfoVM.IsMajor 

	if self.IsMajor then
		self.CommonRedDot:SetRedDotIDByID(201)
		self.CommonRedDotSet:SetRedDotIDByID(201)
		_G.PersonPortraitHeadMgr:ReqQueryFantasyStat()
		MajorUtil.UpdMvpTimes()

		local ShowSaveTips = PersonInfoVM.IsShowPortraitInitSaveTips
		PersonInfoVM:UpdatePortraitInitSaveTipsRedDot(ShowSaveTips)

		if ShowSaveTips then
			MsgTipsUtil.ShowTips(LSTR(620014))
		end
	else
		self.CommonRedDot:SetRedDotIDByID(0)
		self.CommonRedDotSet:SetRedDotIDByID(0)
	end

	self.MulEditTextSign:SetIsHideNumber(true)
	
	self.ModuleList = self.IsMajor and PersonInfoDefine.ModuleListSelf or PersonInfoDefine.ModuleListOther

	if self.Params then
		--模块类型
		local Type = self.Params.ModuleType
		if Type then
			_, self.CurTabIdx = table.find_by_predicate(self.ModuleList, function(e)
				return e.Type == Type
			end)
		end

	end

	UIUtil.SetIsVisible(self.BtnEditSign, self.IsMajor, true)

	local Hint = self.IsMajor and LSTR(620052) or LSTR(620053)
	self.MulEditTextSign:SetHintText(Hint)

	--Tabs
	self.CommTabsModule:UpdateItems(self.ModuleList, self.CurTabIdx or 1)

	self:SetServerInfo()
	self:InitActiveHours()
	self:UpdateSignText()
	self:UpdateTopRightPanel()

	-- _G.LightMgr:LoadLightLevel(LightID)
    _G.LightMgr:EnableUIWeather(WeatgerTODID)

	self:ShowLaunchPrivilege()

	self:InitLSTR()
	self:SetChangeNameCardCDInfo()
end

function PersonInfoMainPanelView:SetChangeNameCardCDInfo()
	if not self.IsMajor then return end

	local RenameCardDefine = PersonInfoDefine.RenameCardID
	local Num = _G.BagMgr:GetItemNum(RenameCardDefine)
	local ItemCfg = require("TableCfg/ItemCfg")
	local Cfg = ItemCfg:FindCfgByKey(RenameCardDefine)
	if Cfg and Cfg.FreezeGroup and Num > 0 then
		_G.BagMgr:SendMsgBagItemCDInfo(Cfg.FreezeGroup)
	end
end

function PersonInfoMainPanelView:OnHide()
	PersonInfoVM:ClearPortraitInitSaveTips()

	_G.HUDMgr:SetIsDrawHUD(true)

	-- loiafeng: 在线状态界面也有关闭这个界面的逻辑，因此将关闭处理相关的逻辑从OnClickCloseButton移动到了OnHide
	PersonInfoVM:Clear()
	self.CameraFocusCfgMap:SetAssetUserData(nil)
	self.CommonRender2D:SwitchOtherLights(true)

	-- _G.LightMgr:UnLoadLightLevel(LightID)
	_G.LightMgr:DisableUIWeather()
end

function PersonInfoMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.PersonInfoPlayer.BtnPlayer, 		self.OnClickButtonHeadSet)
	UIUtil.AddOnClickedEvent(self, self.BtnTitleSet, 		self.OnClickButtonTitleSet)
	UIUtil.AddOnClickedEvent(self, self.BtnOnlineSet, 		self.OnClickButtonOnlineSet)
	UIUtil.AddOnClickedEvent(self, self.BtnArmy, 			self.OnClickButtonArmy)
	UIUtil.AddOnClickedEvent(self, self.BtnMoreProf, 		self.OnClickButtonMoreProf)
	UIUtil.AddOnClickedEvent(self, self.BtnProfSet, 		self.OnClickButtonProfSet)
	UIUtil.AddOnClickedEvent(self, self.BtnStyleSet, 		self.OnClickButtonStyleSet)
	UIUtil.AddOnClickedEvent(self, self.BtnHoursSet, 		self.OnClickButtonHoursSet)
	UIUtil.AddOnClickedEvent(self, self.BtnPortraitEdit, 	self.OnClickButtonPortraitEdit)

	UIUtil.AddOnClickedEvent(self, self.BtnEditSign, 		self.OnEditSign)
	
	UIUtil.AddOnClickedEvent(self, self.BtnChat, 	self.OnClickBtnChat)
	UIUtil.AddOnClickedEvent(self, self.BtnAddFriend, 	self.OnBtnAddFriend)
	UIUtil.AddOnClickedEvent(self, self.BtnChangeofName, 	self.OnBtnName)
	UIUtil.AddOnClickedEvent(self, self.BtnFormerName, 	self.OnBtnFormer)
	UIUtil.AddOnClickedEvent(self, self.BtnPrivilege, 	self.OnClickBtnPrivilege)
	UIUtil.AddOnClickedEvent(self, self.BtnLaunchPrivilege, 	self.OnClickBtnLaunchPrivilege)

	UIUtil.AddOnClickedEvent(self, self.BtnSet, 	self.OnClickBtnSetting)
	UIUtil.AddOnClickedEvent(self, self.Mask_InfoPanel, 		self.OnClickInfoPanelMask)

	UIUtil.AddOnClickedEvent(self, self.BtnAndArmyNode, 	self.OnClickBtnComp)

	UIUtil.AddOnClickedEvent(self, self.Mask, 		self.OnClickNamePanelMask)
	-- UIUtil.AddOnClickedEvent(self, self.BtnTitleSet, 		self.OnClickButtonTitleSet)

	
	UIUtil.AddOnSelectionChangedEvent(self, self.CommTabsModule, self.OnSelectionChangedTabs)
end

function PersonInfoMainPanelView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnEveMouseDown)
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnEventClientSetupPost)
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(EventID.GetHistoryNameSuccess, self.OnGetHistoryName)
	self:RegisterGameEvent(EventID.ChaneNameNotify, self.OnChangeNameNotify)
	self:RegisterGameEvent(EventID.CompanySealRankUp, self.OnChangeCompanyRankNotify)
end

function PersonInfoMainPanelView:OnRegisterBinder()
	--玩家数据
	local RoleVM = PersonInfoVM.RoleVM
	self.RoleVM = RoleVM

	self:RegisterBinders(PersonInfoVM, self.BindersPersonInfoVM)

	if RoleVM then
		-- loiafeng: 应策划需求，对于玩家自己的个人信息主页面，这里需要特殊处理，显示与状态设置界面的当前状态一致
		if MajorUtil.IsMajorByRoleID(RoleVM.RoleID) then
			table.merge_table(self.Binders, self.BindersExMajor)
		else
			table.merge_table(self.Binders, self.BindersEx)
		end

		self:RegisterBinders(RoleVM, self.Binders)
	end
end

function PersonInfoMainPanelView:OnPostActive()
	if self.TabType ~= ModuleType.EquipInfo then
		self.CommonRender2D:ShowCharacter(false)
		self.CommonRender2D:SwitchRenderLights(false)
	end
end

---服务器信息
function PersonInfoMainPanelView:SetServerInfo()
	local RoleVM = PersonInfoVM.RoleVM
	if not RoleVM then return end

	local OriWorldID = RoleVM.WorldID or RoleVM.CurWorldID

	if not OriWorldID then
		UIUtil.SetIsVisible(self.ServerNode, false) 
		return
	end

	local ServerName = LoginMgr:GetMapleNodeName(OriWorldID)
	if string.isnilorempty(ServerName) then
		UIUtil.SetIsVisible(self.ServerNode, false) 
		return
	end

	self.TextServer:SetText(ServerName)
	UIUtil.SetIsVisible(self.ServerNode, true) 
end

function PersonInfoMainPanelView:OnAssembleAllEnd(Params)
	local ChildActor = self.CommonRender2D:GetCharacter()
	if (ChildActor == nil) then return end
	local EntityID = Params.ULongParam1
	local ObjType = Params.IntParam1
	local AttrComp = ChildActor:GetAttributeComponent()

	if EntityID == AttrComp.EntityID and ObjType == AttrComp.ObjType then
		self.CommonRender2D:UpdateAllLights()
		local UIComplexCharacter = self.CommonRender2D.UIComplexCharacter
		if UIComplexCharacter then
			UIComplexCharacter:GetAvatarComponent():SetForcedLODForAll(1)
		end
	end

	-- self:SetCameraFocus()
end

function PersonInfoMainPanelView:OnGetHistoryName(NameData)
	if not UIViewMgr:IsViewVisible(UIViewID.UseRenameCard) then
		if NameData and next(NameData) then
			_G.RoleInfoMgr:ShowFormerNameTips(self.BtnFormerName, _G.UE.FVector2D(0, 0), NameData)
		else
			_G.MsgTipsUtil.ShowTips(_G.LSTR(620018))
		end
	end
end

function PersonInfoMainPanelView:OnChangeCompanyRankNotify(MaxRank)
	self:SetCompany(MaxRank)
	self:PlayAnimation(self.AnimRankUp)
end

function PersonInfoMainPanelView:OnChangeNameNotify(RoleID, EntityID, NewName)
	local CurRoleID = self.RoleVM.RoleID or 0
	if RoleID and CurRoleID == RoleID and not string.isnilorempty(NewName) then
		self.TextPlayerName:SetText(NewName)
	end
end

local SysID = 25
function PersonInfoMainPanelView:GetLightPath(AttachType)
	local LightConfig = nil

	local SystemLightCfgItem = SystemLightCfg:FindCfgByKey(SysID)
    if SystemLightCfgItem then
        LightConfig = SystemLightCfgItem.LightPresetPaths
    end

	print('test info SystemLightCfgItem')
	print(table_to_string_block(LightConfig))

	if not LightConfig then
		return ""
	end

	if AttachType == "c0901" or AttachType == "c1101" then
	else
		AttachType = "c0101"
	end

	local RetPath = LightConfig[1]
	if SystemLightCfgItem then
		for _, Path in pairs(LightConfig) do
			local Random = string.find(Path, AttachType)
			if Random then
				RetPath = Path
			end
		end
	end

	return RetPath
end

function PersonInfoMainPanelView:ShowModuleBg()
	self.CommonRender2D:SetShadowActorType(ActorUtil.ShadowType.OtherEquipment)
	self.CommonRender2D.bCreateShandowActor = true
	if nil == self.RoleVM then
		return
	end

	local Cfg = RaceCfg:FindCfgByRaceIDTribeGender(self.RoleVM.Race, self.RoleVM.Tribe, self.RoleVM.Gender)
	if nil == Cfg then
		return
	end

	--根据种族取对应的RenderActor
	local AttachType = Cfg.AttachType
	local RenderActorPathForRace = string.format(RenderActorPath, AttachType, AttachType)

	-- 加载相机参数
	local CameraParams = EquipmentCameraControlDataLoader:GetCameraControlParams(AttachType,
		CameraControlDefine.FocusType.WholeBody)
	self.CommonRender2D:SetCameraControlParams(CameraParams)

    local CallBack = function(bSucc)
        if bSucc then
			self.VignetteIntensityDefaultValue = self.CommonRender2D:GetPostProcessVignetteIntensity()
			self.CommonRender2D:SwitchOtherLights(false)
            self.CommonRender2D:ChangeUIState(false)
			self.CommonRender2D:DisableEnvironmentLights()
			self.CommonRender2D.bIgnoreTodAffective = true
			--展示玩家人物模型
			-- 区分主角和其他玩家（可能是离线的角色）
			if self.RoleVM.RoleID ~= MajorUtil.GetMajorRoleID() then
				self.CommonRender2D:UpdateAvatarByRoleSimple(self.RoleVM.RoleSimple)
			else
				local EntityID = ActorUtil.GetEntityIDByRoleID(self.RoleVM.RoleID)
				self.CommonRender2D:SetUICharacterByEntityID(EntityID)
			end
			self.CameraFocusCfgMap:SetAssetUserData(self.CommonRender2D:GetEquipmentConfigAssetUserData())
			-- self.CommonRender2D.bAutoInitSpringArm = false
            self:SetModelSpringArmToDefault(false, AttachType)
			self.CommonRender2D:UpdateAllLights()
        end
    end

	local ReCreateCallBack = function()
        self.CameraFocusCfgMap:SetAssetUserData(self.CommonRender2D:GetEquipmentConfigAssetUserData())
    end

	local Light = self:GetLightPath(AttachType)

    self.CommonRender2D:CreateRenderActor(
		RenderActorPathForRace,
		_G.EquipmentMgr:GetEquipmentCharacterClass(), 
		Light,
		true, 
		CallBack, 
		ReCreateCallBack)
end

-- function PersonInfoMainPanelView:SetCameraFocus()
-- 	local Cfg = RaceCfg:FindCfgByRaceIDTribeGender(self.RoleVM.Race, self.RoleVM.Tribe, self.RoleVM.Gender)
-- 	if nil == Cfg then
-- 		return
-- 	end

-- 	local AttachType = Cfg.AttachType
-- 	local CameraFocusCfg = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, MajorUtil.GetMajorProfID(), ProtoCommon.equip_part.EQUIP_PART_BODY)
-- 	local DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
-- 	local ViewportSize = UIUtil.GetViewportSize()/DPIScale
-- 	local UIX = ViewportSize.X/2
-- 	local UIY = ViewportSize.Y/2 - 100
-- 	local Dis = 350

-- 	self.CommonRender2D:SetCameraFocusScreenLocation(UIX * DPIScale, UIY * DPIScale, CameraFocusCfg.SocketName, Dis)
-- end


function PersonInfoMainPanelView:SetModelSpringArmToDefault(bInterp, AttachType)
	self.CommonRender2D:EnableRotator(true)
	self.CommonRender2D:EnablePitch(true)
	self.CommonRender2D:SetCameraFocusScreenLocation(nil, nil, nil, nil)

	local SpringArmRotation = self.CommonRender2D:GetSpringArmRotation()
	self.CommonRender2D:SetSpringArmRotation(0, SpringArmRotation.Yaw, SpringArmRotation.Roll, true)
	self.CommonRender2D:SetModelRotation(0, 0 , 0, true)

	local DefaultArmDistance = self.CameraFocusCfgMap:GetSpringArmDistance(AttachType) + 100
    self.CommonRender2D:SetSpringArmDistance(DefaultArmDistance, bInterp)
	self.CommonRender2D:SetSpringArmLocation(
		0, -- self.CameraFocusCfgMap:GetSpringArmOriginX(AttachType), 
		self.CameraFocusCfgMap:GetSpringArmOriginY(AttachType), 
		self.CameraFocusCfgMap:GetSpringArmOriginZ(AttachType), bInterp)
	self.CommonRender2D:SetCameraFOV(self.CameraFocusCfgMap:GetOriginFOV(AttachType))
	self.CommonRender2D:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
end

-------------------------------------------------------------------------------------------------------
---@region expand weapon/hat, copy from EquipmentNewMainView

-- weapon

function PersonInfoMainPanelView:PoseStyleSwitch()
	local Prof = PersonInfoVM.RoleVM.Prof
	local IsSpe = ProfUtil.IsProductionProf(Prof)
	self.CommonRender2D:HoldOnWeapon(PersonInfoVM.bIsHoldWeapon and not IsSpe)
	self:UpdateWeaponHideState()
end

function PersonInfoMainPanelView:UpdateWeaponHideState()
	local bHideMasterHand = self:IsHideMasterHand()
	local bHideSlaveHand = self:IsHideSlaveHand()
	self.CommonRender2D:HideMasterHand(bHideMasterHand)
	self.CommonRender2D:HideSlaveHand(bHideSlaveHand)

	self.CommonRender2D:HideAttachMasterHand(self:IsHideAttachMasterHand())
	self.CommonRender2D:HideAttachSlaveHand(self:IsHideAttachSlaveHand())
end

-- 判断是否隐藏主手武器，拔刀必定显示武器
-- 生产职业预览副手，隐藏主手
function PersonInfoMainPanelView:IsHideMasterHand()
	local bIsHideWeapon = not (PersonInfoVM.bIsShowWeapon or PersonInfoVM.bIsHoldWeapon)
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local bIsPreviewSlaveHand = false --self.SelectSlotPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND
	return bIsHideWeapon or (bIsProductProf and bIsPreviewSlaveHand)
end

-- 判断是否隐藏副手武器，拔刀必定显示武器
-- 生产职业非预览副手状态隐藏副手
function PersonInfoMainPanelView:IsHideSlaveHand()
	local bIsHideWeapon = not (PersonInfoVM.bIsShowWeapon or PersonInfoVM.bIsHoldWeapon)
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local bIsPreviewSlaveHand = false --self.SelectSlotPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND
	return bIsHideWeapon or (bIsProductProf and not bIsPreviewSlaveHand)
end

-- 判断是否隐藏主手武器挂件，继承主手武器隐藏状态，但只有拔刀时才显示
function PersonInfoMainPanelView:IsHideAttachMasterHand()
	return self:IsHideMasterHand() or not PersonInfoVM.bIsHoldWeapon
end

-- 判断是否隐藏副手武器挂件，继承副手武器隐藏状态，但只有拔刀时才显示
function PersonInfoMainPanelView:IsHideAttachSlaveHand()
	return self:IsHideSlaveHand() or not PersonInfoVM.bIsHoldWeapon
end

--hat

function PersonInfoMainPanelView:HatVisibleSwitch()
	-- self:SendClientSetupPost(ClientSetupID.RoleHatVisible, self.ViewModel.bHideHead)
	local bHideHead = PersonInfoVM.bIsShowHead
	self.CommonRender2D:HideHead(bHideHead)
end

-- function PersonInfoMainPanelView:HideHead(IsHide, IsSave)
-- 	if not IsHide == self.bIsShowHead then
-- 		return
-- 	end
-- 	self.bIsShowHead = not IsHide

-- 	FLOG_INFO("Setting HideHead %s", tostring(IsHide))
-- 	-- local Major = MajorUtil.GetMajor()
-- 	-- if Major then
-- 	-- 	Major:HideHead(IsHide)
-- 	-- end

-- 	if IsSave then
-- 		if self.bIsShowHead then
-- 			_G.EquipmentMgr:SendEquipOn({{Part = ProtoCommon.equip_part.EquipHeadShow, GID = 1}})
-- 		else
-- 			_G.EquipmentMgr:SendEquipOn({{Part = ProtoCommon.equip_part.EquipHeadShow, GID = 0}})
-- 		end
	
-- 		local Idx = IsHide and 2 or 1
-- 		_G.UE.USaveMgr:SetInt(SaveKey.ShowHead, Idx, true)
-- 		self:GetSettingsTabRole().ShowHeadIdx = Idx
-- 		_G.ClientSetupMgr:SendSetReq(ClientSetupID.ShowHead, tostring(Idx))
-- 	end
-- end


-------------------------------------------------------------------------------------------------------
---基础信息

function PersonInfoMainPanelView:SetBaseInfo()
	local RoleVM = self.RoleVM
	if nil == RoleVM then
		return
	end

	self.CommonRender2D:ShowCharacter(false)
	self.CommonRender2D:SwitchRenderLights(false)

	UIUtil.SetIsVisible(self.EquiPanel, false)
	UIUtil.SetIsVisible(self.BaseInfoNode, true)
	UIUtil.SetIsVisible(self.PersonInfoProf, false)

	local IsMajor = self.IsMajor

	--功能设置按钮
	UIUtil.SetIsVisible(self.PersonInfoPlayer.BtnPlayer, 		IsMajor, true)
	UIUtil.SetIsVisible(self.BtnTitleSet, 		IsMajor, true)
	UIUtil.SetIsVisible(self.ImgTitleSet, 		IsMajor)
	UIUtil.SetIsVisible(self.BtnOnlineSet, 		IsMajor, true)
	UIUtil.SetIsVisible(self.ImgOnlineSet, 		IsMajor)

	-- UIUtil.SetIsVisible(self.BtnChangeofName, 		IsMajor, true)
	-- UIUtil.SetIsVisible(self.BtnArmy, 			IsMajor, true)
	UIUtil.SetIsVisible(self.BtnProfSet, 		IsMajor, true)
	UIUtil.SetIsVisible(self.BtnStyleSet, 		IsMajor, true)
	UIUtil.SetIsVisible(self.BtnHoursSet, 		IsMajor, true)

	UIUtil.SetIsVisible(self.BtnPortraitEdit, 	IsMajor, true)
	UIUtil.SetIsVisible(self.ImgBtnBg, 	IsMajor)
	UIUtil.SetIsVisible(self.EditBtnImg, 	IsMajor)


	UIUtil.SetIsVisible(self.CommonRedDotPortrait, 	IsMajor, true)

	UIUtil.SetIsVisible(self.BtnMoreProf, 	IsMajor, true)

	-- UIUtil.SetIsVisible(self.MulEditTextSign, 	IsMajor)
	self.MulEditTextSign:SetIsEnabled(IsMajor)

	--玩家名字
	self.TextPlayerName:SetText(RoleVM.Name or "")

	--称号
	self:SetTitleInfo(RoleVM.TitleID, RoleVM.Gender)

	self:SetCompany()
end

function PersonInfoMainPanelView:InitActiveHours()
	local Data = {}

	for i = 1, 48 do
		table.insert(Data, { ID = i })

		if i == 12 then
			self.TableAdapterWeekdayL:UpdateAll(Data)
		elseif i == 24 then 
			self.TableAdapterWeekdayR:UpdateAll(Data)
		elseif i == 36 then 
			self.TableAdapterRestDayL:UpdateAll(Data)
		elseif i == 48 then 
			self.TableAdapterRestDayR:UpdateAll(Data)
		end

		if i % 12 == 0 then
			Data = {}
		end
	end
end

---本地玩家的在线状态
function PersonInfoMainPanelView:OnBindCBMvpTimes( Val )
	self.TextGood:SetText(tostring(Val))
	UIUtil.SetIsVisible(self.TextGoodNothing, Val == 0)
	UIUtil.SetIsVisible(self.TextGood, Val ~= 0)
	UIUtil.SetIsVisible(self.IconGood, Val ~= 0)
end

--- mvp次数
function PersonInfoMainPanelView:UpdateMajorOnlineStatus( )
	local Icon, Name = OnlineStatusUtil.GetMajorPersonInfoStatusRes()
	UIUtil.ImageSetBrushFromAssetPath(self.IconOnline, Icon)
	self.TextOnline:SetText(Name)
end


---设置称号
function PersonInfoMainPanelView:SetTitleInfo(TitleID, Gender)
	local TitleName = _G.TitleMgr:GetTargetTitleText(TitleID, Gender)
	local IsNil = string.isnilorempty(TitleName)
	TitleName = IsNil and LSTR(620019) or TitleName
	local ColorFmt = IsNil and "828282FF" or "d5d5d5FF"
	local Color = _G.UE.FLinearColor.FromHex(ColorFmt)
	self.TextPlayerTitle:SetColorAndOpacity(Color)
	self.TextPlayerTitle:SetText(TitleName)
end

-- 军票
function PersonInfoMainPanelView:SetCompany(InRank)
	local RoleVM = self.RoleVM
	if not RoleVM then return end

	local Rank = InRank or RoleVM.GrandCompRank
	if RoleVM.GrandCompID and RoleVM.GrandCompID ~= 0 and Rank then
	-- print('test info RoleVM.GrandCompRank rank = ' .. tostring(RoleVM.GrandCompRank))
		local Info = _G.CompanySealMgr:GetRankInfo(RoleVM.GrandCompID, Rank)
		UIUtil.SetIsVisible(self.PanelRank, true)
		UIUtil.SetIsVisible(self.TextNoneArmyTips, false)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgRank, Info.Icon)
		self.TextRank:SetText(Info.RankName or "")
	else
		UIUtil.SetIsVisible(self.PanelRank, false)
		UIUtil.SetIsVisible(self.TextNoneArmyTips, true)
	end

	local IsMajor = MajorUtil.GetMajorRoleID() == RoleVM.RoleID 
	if IsMajor then
		local CanPro = _G.CompanySealMgr:CheckPromotioState()
		UIUtil.SetIsVisible(self.ImgArrow, CanPro, true)
		UIUtil.SetIsVisible(self.PanelArrow, CanPro)
	else
		UIUtil.SetIsVisible(self.PanelArrow, false)
		UIUtil.SetIsVisible(self.ImgArrow, false)
	end
end

function PersonInfoMainPanelView:OnValueChangedTitleID(ID)
	local RoleVM = self.RoleVM
	if RoleVM then
		self:SetTitleInfo(ID, RoleVM.Gender)
	end
end

-------------------------------------------------------------------------------------------------------
---公会

function PersonInfoMainPanelView:OnValueChangedArmySimpleInfo(Info)
	Info = Info or {}
	local ArmyID = Info.ID 
	if nil == ArmyID or ArmyID <= 0 then
		UIUtil.SetIsVisible(self.ArmyDetailNode, false)
		UIUtil.SetIsVisible(self.BtnArmy, false)
		UIUtil.SetIsVisible(self.TextNoneArmyTips2, true)
	else
		self.ArmyBadge:SetBadgeData(Info.Emblem, true)
		self.TextArmyName:SetText(Info.Name or "")
		UIUtil.SetIsVisible(self.TextNoneArmyTips2, false)
		UIUtil.SetIsVisible(self.ArmyDetailNode, true)
		UIUtil.SetIsVisible(self.BtnArmy, true, true)
	end
end

-------------------------------------------------------------------------------------------------------
---加好友/聊天

function PersonInfoMainPanelView:UpdateTopRightPanel( )
	-- 
	-- UIUtil.SetIsVisible(self.BtnAddFriend, false)
	UIUtil.SetIsVisible(self.BtnChat, false)

	local IsMajor = PersonInfoVM.IsMajor
	-- if (self.Params or {}).Source == SimpleViewSource.Chat then
	-- 	UIUtil.SetIsVisible(self.BtnChat, false)
	-- else
	-- 	UIUtil.SetIsVisible(self.BtnChat, not IsMajor, true)
	-- end

	if IsMajor then
		UIUtil.SetIsVisible(self.BtnAddFriend, false)
	else
		local RoleID = (self.RoleVM or {}).RoleID or 0
		UIUtil.SetIsVisible(self.BtnAddFriend, not _G.FriendMgr:IsFriend(RoleID), true)
	end

	UIUtil.SetIsVisible(self.PanelSet, IsMajor, true)
end

-------------------------------------------------------------------------------------------------------
---个性签名

function PersonInfoMainPanelView:UpdateSignText( )
	local Text = PersonInfoVM.SignContent
	
	if string.isnilorempty(Text) then
		local IsMajor = PersonInfoVM.IsMajor
		UIUtil.SetIsVisible(self.MulEditTextSign, false)
		UIUtil.SetIsVisible(self.TextNoneSignTips, true)
		UIUtil.SetIsVisible(self.SizeBoxEdit, IsMajor)
	else
		UIUtil.SetIsVisible(self.SizeBoxEdit, false)
		UIUtil.SetIsVisible(self.TextNoneSignTips, false)
		UIUtil.SetIsVisible(self.MulEditTextSign, true)
		self.MulEditTextSign:SetText(Text)
	end
end

-------------------------------------------------------------------------------------------------------
---装备信息

function PersonInfoMainPanelView:SetEquipInfo()
	UIUtil.SetIsVisible(self.BaseInfoNode, false)
	UIUtil.SetIsVisible(self.EquiPanel, true)
	UIUtil.SetIsVisible(self.PersonInfoProf, false)

	
	self.CommonRender2D:ShowCharacter(true)
	self.CommonRender2D:EnableRotator(true)

	self:PoseStyleSwitch()
	self:HatVisibleSwitch()
end

-- -- 创建离线角色

-- function PersonInfoMainPanelView:CreatePreviewActor(RoleSimple)
--     if self.CreatedPreviewActorEntID then
--         self:DestroyPreviewActor()
-- 		return self.CreatedPreviewActorEntID
--     end

--     local TempResID = 29000080 -- 一个临时用的模型
--     -- local OpponentRace = RoleSimple.Race
-- 	local Loc = _G.UE.FVector(100000, 100000, 100000)
-- 	local MajorActor = MajorUtil.GetMajor()
-- 	local MajorPos = MajorActor:FGetActorLocation()
-- 	Loc = MajorPos

--     local CreatedNPCEntityID = _G.UE.UActorManager:Get():CreateClientActor(_G.UE.EActorType.Player, 0, TempResID, Loc, _G.UE.FRotator(0, 0, 0))
--     local Actor = ActorUtil.GetActorByEntityID(CreatedNPCEntityID)
--     if (Actor ~= nil) then
--         local Character = Actor:Cast(_G.UE.ABaseCharacter)
--         ActorUtil.UpdateAvatar(Character, RoleSimple)  
--     else
--         FLOG_ERROR("[PersonInfoMgr][CreatePreViewActor] create actor failed")
--     end

--     self.CreatedPreviewActorEntID = CreatedNPCEntityID

--     return CreatedNPCEntityID, Actor
-- end

-- function PersonInfoMainPanelView:DestroyPreviewActor()
--     if self.CreatedPreviewActorEntID then
--         _G.UE.UActorManager:Get():RemoveClientActor(self.CreatedPreviewActorEntID)
--         self.CreatedPreviewActorEntID = nil
--     end
-- end

-------------------------------------------------------------------------------------------------------
---装备信息

function PersonInfoMainPanelView:SetProfInfo()
	UIUtil.SetIsVisible(self.BaseInfoNode, false)
	UIUtil.SetIsVisible(self.EquiPanel, false)
	UIUtil.SetIsVisible(self.PersonInfoProf, true)
	self.CommonRender2D:ShowCharacter(false)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function PersonInfoMainPanelView:OnClickCloseButton()
	self:Hide()
end

function PersonInfoMainPanelView:OnClickButtonHeadSet()
	-- UIViewMgr:ShowView(UIViewID.PersonInfoHeadPanel)
	_G.PersonPortraitHeadMgr:OpenEditHeadView()
end

function PersonInfoMainPanelView:OnClickButtonTitleSet()
	UIViewMgr:ShowView(UIViewID.TitleMainPanelView)
end

function PersonInfoMainPanelView:OnClickButtonOnlineSet()
	UIViewMgr:ShowView(UIViewID.OnlineStatusSettingsPanel)
end

function PersonInfoMainPanelView:OnClickButtonArmy()
	_G.PersonInfoMgr:ShowPersonInfoArmyTipsView()
end

function PersonInfoMainPanelView:OnClickButtonProfSet()
	UIViewMgr:ShowView(UIViewID.PersonInfoPerferredProfPanel)
end

function PersonInfoMainPanelView:OnClickButtonMoreProf()
	UIViewMgr:ShowView(UIViewID.PersonInfoPerferredProfPanel)
end

function PersonInfoMainPanelView:OnClickButtonStyleSet()
	UIViewMgr:ShowView(UIViewID.PersonInfoGameStylePanel)
end

function PersonInfoMainPanelView:OnClickButtonHoursSet()
	UIViewMgr:ShowView(UIViewID.PersonInfoHoursPanel)
end

function PersonInfoMainPanelView:OnClickButtonPortraitEdit()
	PersonInfoVM:ClearPortraitInitSaveTips()

	UIViewMgr:ShowView(UIViewID.PersonPortraitMainPanel)
end

function PersonInfoMainPanelView:OnTextCommittedSign(Text, CommitMethod)
	local TextCommitOnEnter = _G.UE.ETextCommit.OnEnter

	if CommitMethod ~= TextCommitOnEnter then
		return
	end

	PersonInfoVM:SaveSignContent(Text)
end

function PersonInfoMainPanelView:OnEditSign()
	UIViewMgr:ShowView(UIViewID.PersonInfoSignPanel)
end

function PersonInfoMainPanelView:OnClickBtnChat()
	_G.ChatMgr:GoToPlayerChatView(PersonInfoVM.RoleID)
end

function PersonInfoMainPanelView:OnClickBtnComp()
	local IsMajor = PersonInfoVM.IsMajor
	if not IsMajor then return end

	local RoleVM = PersonInfoVM.RoleVM
	if RoleVM.GrandCompID and RoleVM.GrandCompID ~= 0 and RoleVM.GrandCompRank then
		local CompanySealMgr = _G.CompanySealMgr
		if CompanySealMgr:CheckPromotioState() then
			CompanySealMgr:OpenPromotionView(true)
		else
			if self.RoleVM and self.RoleVM.GrandCompID then
				CompanySealMgr:OpenCompanyRankView(self.RoleVM.GrandCompID)
			end
		end
	end
end

function PersonInfoMainPanelView:OnBtnAddFriend()
	_G.FriendMgr:AddFriend(PersonInfoVM.RoleID, FriendDefine.AddSource.PersonHome)
end



function PersonInfoMainPanelView:OnBtnFormer()
	_G.RoleInfoMgr:GetPersonHistoryNameByRoleID(PersonInfoVM.RoleID)
end 

function PersonInfoMainPanelView:OnBtnCopyName()
	self:CopyName()
end

function PersonInfoMainPanelView:CopyName()
	_G.CommonUtil.ClipboardCopy(self.RoleVM.Name)
    _G.MsgTipsUtil.ShowTips(LSTR(910142))
end

function PersonInfoMainPanelView:OnBtnName()
	self:OpenNamePanel()
end

function PersonInfoMainPanelView:OnBtnChangeName()
	local RenameCardID = PersonInfoDefine.RenameCardID
	local ItemCfg = require("TableCfg/ItemCfg")
	local Cfg = ItemCfg:FindCfgByKey(RenameCardID)
	if not Cfg then return end
		
	local Num = _G.BagMgr:GetItemNum(RenameCardID)
	if Num > 0 then
		if _G.BagMgr.FreezeCDTable[Cfg.FreezeGroup] then
			local TimeUtil = require("Utils/TimeUtil")
			local CurTime = TimeUtil.GetServerTime()
			local EndTimte = _G.BagMgr.FreezeCDTable[Cfg.FreezeGroup].EndTime
			local LocalizationUtil = require("Utils/LocalizationUtil")
			_G.MsgTipsUtil.ShowTips(string.format(LSTR(620105), LocalizationUtil.GetCountdownTimeForSimpleTime(EndTimte - CurTime, "m")))
		else
			_G.UIViewMgr:ShowView(UIViewID.UseRenameCard)
		end
	else
		local RichTextUtil = require("Utils/RichTextUtil")
		local QuantityText = string.format(LSTR(620002), RichTextUtil.GetText("0", "dc5868"))
		local CostText = string.format(LSTR(620003), RichTextUtil.GetText(Cfg.ItemName, "d1ba8e"))
		local function GoShopping()
			_G.StoreMgr:JumpToGoods(RenameCardID, nil, true)
		end

		local Params = {ItemResID = RenameCardID, TextQuantity = QuantityText}
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(620039), CostText, GoShopping, nil, LSTR(620011), LSTR(620029), Params)
	end
end

function PersonInfoMainPanelView:OnSelectionChangedTabs( Index )
	if nil == self.RoleVM then
		return
	end

	local ModuleInfo = self.ModuleList[Index]
	if nil == ModuleInfo then
		return
	end

	local Type = ModuleInfo.Type
	self.TabType = Type
	-- if Type == ModuleType.EquipInfo then --检查是否可以切换在装备页签
	-- 	local EntityID = ActorUtil.GetEntityIDByRoleID(self.RoleVM.RoleID)
	-- 	if nil == EntityID or EntityID <= 0 then
	-- 		self.CommTabsModule:SetSelectedIndex(self.CurTabIdx)
	-- 		MsgTipsUtil.ShowTips(LSTR(620025))
	-- 		return
	-- 	end
	-- end

	self.CurTabIdx = Index
	PersonInfoVM.CurTabIdx = Index

	--模块名
	self.CommonTitle:SetTextSubtitle(ModuleInfo.Name or "")
	if Type == ModuleType.BaseInfo then
		self:SetBaseInfo()

	elseif Type == ModuleType.EquipInfo then
		self:SetEquipInfo()

	elseif Type == ModuleType.ProfInfo then
		self:SetProfInfo()
	end

	UIUtil.SetIsVisible(self.CommonBkg, Type ~= ModuleType.EquipInfo)

	if self.AnimChangeTab then
		self:PlayAnimation(self.AnimChangeTab)
	end

	UIUtil.SetIsVisible(self.BtnChat, false)

	local IsMajor = PersonInfoVM.IsMajor

	UIUtil.SetIsVisible(self.PanelSet, IsMajor and Type == ModuleType.BaseInfo, true)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function PersonInfoMainPanelView:OnEveMouseDown(MouseEvent)
	local MousePosition = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)

	if not UIUtil.IsUnderLocation(self.NameBtnPanel, MousePosition) then
		UIUtil.SetIsVisible(self.NameBtnPanel, false)
	end
end

function PersonInfoMainPanelView:OnEventClientSetupPost( EventParams )
	if not self.IsShowView or nil == EventParams or nil == self.RoleVM or not self.IsMajor then
		return
	end

	local Value = EventParams.StringParam1 or ""
	local SetupKey = EventParams.IntParam1
	local IsSetCB = EventParams.BoolParam1

	if SetupKey == ClientSetupKey.PerferredProf then 		--偏好职业
		self.RoleVM:UpdatePersonSetInfo(SetupKey, Value)
		PersonInfoVM:UpdatePerferredProf(self.RoleVM.ProfSimpleDataList, Value)

	elseif SetupKey == ClientSetupKey.ActiveHours then 		--活跃时段
		self.RoleVM:UpdatePersonSetInfo(SetupKey, Value)
		PersonInfoVM:UpdateActiveHoursSet(Value)

		if IsSetCB then
			MsgTipsUtil.ShowTips(LSTR(620022))
		end

	elseif SetupKey == ClientSetupKey.Playstyle then 		--游戏风格
		self.RoleVM:UpdatePersonSetInfo(SetupKey, Value)
		PersonInfoVM:UpdateGameStyleVMList(Value)

		if IsSetCB then
			MsgTipsUtil.ShowTips(LSTR(620023))
		end

	elseif SetupKey == ClientSetupKey.PersonalSignature then --个性签名
		self.RoleVM:UpdatePersonSetInfo(SetupKey, Value)
		PersonInfoVM:UpdateSignContent(Value)
		self:UpdateSignText()

		if IsSetCB then
			MsgTipsUtil.ShowTips(LSTR(620032))
		end
	end
end

function PersonInfoMainPanelView:ShowLaunchPrivilege()
	local Cfg = OperationUtil.GetOperationChannelFuncConfig()
	if nil ~= Cfg and
		((_G.LoginMgr:IsWeChatLogin() and Cfg.IsEnableWeChatLaunchPrivileges == 0) or 
		 (_G.LoginMgr:IsQQLogin() and Cfg.IsEnableQQLaunchPrivileges == 0)) then
		UIUtil.SetIsVisible(self.PanelStart, false)
		UIUtil.SetIsVisible(self.PanelPrivilege, false)
		return
	end

	self:ChangePrivilege()
	if self.IsMajor then
		if _G.LoginMgr:IsWeChatLogin() then
			if _G.LoginMgr:IsWakeUpByWeChatOrQQ(MSDKDefine.ChannelID.WeChat) then
				UIUtil.SetIsVisible(self.PanelPrivilege, true, true)
			end
			UIUtil.SetIsVisible(self.PanelStart, true, true)
			return
		end

		if _G.LoginMgr:IsQQLogin() then
			UIUtil.SetIsVisible(self.PanelStart, true, true)
			if not _G.LoginMgr:IsWakeUpByWeChatOrQQ(MSDKDefine.ChannelID.QQ) then
				local Gray = _G.UE.FLinearColor.FromHex("#696969")
				self.TextStart:SetColorAndOpacity(Gray)
				self.IconStart:SetColorAndOpacity(Gray)
			end
			UIUtil.SetIsVisible(self.PanelPrivilege, true, true)
		end
	else
		local LoginChannel = _G.LoginMgr:GetChannelID()
		_G.FLOG_INFO("PersonInfoMainPanelView:ShowLaunchPrivilege, RoleVM.LaunchType:%d, LoginChannel:%s", self.RoleVM.LaunchType, tostring(LoginChannel))
		if nil ~= self.RoleVM.LaunchType and self.RoleVM.LaunchType == LoginChannel then
			UIUtil.SetIsVisible(self.PanelStart, true, true)
		end
	end
end

function PersonInfoMainPanelView:ChangePrivilege()
	UIUtil.SetIsVisible(self.PanelStart, false)
	UIUtil.SetIsVisible(self.PanelPrivilege, false)
	self.TextPrivilege:SetText(_G.LSTR(100007))
	if _G.LoginMgr:IsWeChatLogin() then
		self.TextStart:SetText(LSTR(620012))
		UIUtil.ImageSetBrushFromAssetPath(self.IconStart, "PaperSprite'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_WeChat1_png.UI_Profile_Icon_WeChat1_png'")
		UIUtil.ImageSetBrushFromAssetPath(self.IconPrivilege, "PaperSprite'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_WeChat2_png.UI_Profile_Icon_WeChat2_png'")
	elseif _G.LoginMgr:IsQQLogin() then
		self.TextStart:SetText(LSTR(620021))
		UIUtil.ImageSetBrushFromAssetPath(self.IconStart, "PaperSprite'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_QQ1_png.UI_Profile_Icon_QQ1_png'")
		UIUtil.ImageSetBrushFromAssetPath(self.IconPrivilege, "PaperSprite'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_QQ2_png.UI_Profile_Icon_QQ2_png'")
	end
end

function PersonInfoMainPanelView:OnClickBtnPrivilege()
	if _G.LoginMgr:IsQQLogin() then
		_G.AccountUtil.OpenUrl(LoginNewDefine.QQPrivilegeUrl, 1, false, true, "", false)
	end
end

function PersonInfoMainPanelView:OnClickBtnLaunchPrivilege()
	if _G.LoginMgr:IsWeChatLogin() then
		UIViewMgr:ShowView(UIViewID.WeChatPrivilegePanel)
	end
	if _G.LoginMgr:IsQQLogin() then
		_G.AccountUtil.OpenUrl(LoginNewDefine.QQPrivilegeUrl, 1, false, true, "", false)
	end
end

function PersonInfoMainPanelView:OnClickNamePanelMask()
	self:HideNameBtnTipsPanel()
end

function PersonInfoMainPanelView:HideNameBtnTipsPanel()
	UIUtil.SetIsVisible(self.NameBtnPanel, false)
	UIUtil.SetIsVisible(self.Mask, false)
end

function PersonInfoMainPanelView:OpenNamePanel()
	local RoleVM = self.RoleVM 
	if not RoleVM then return end

	local IsMajor = MajorUtil.GetMajorRoleID() == RoleVM.RoleID 
	if IsMajor then
		self.NameTable = {
			{
				Name = LSTR(620124),
				Callback = function()
					self:OnBtnChangeName()
					self:HideNameBtnTipsPanel()
				end,
			},
		
			{
				Name = LSTR(620125),
				Callback = function()
					self:OnBtnCopyName()
					self:HideNameBtnTipsPanel()
				end,
			},
		}
	else
		-- if _G.FriendMgr:IsFriend(RoleVM.RoleID) then
		-- 	self.NameTable = {
		-- 		{
		-- 			Name = LSTR(620124), -- 改成备注昵称
		-- 			Callback = function()
		-- 				self:OnBtnChangeName()
		-- 				self:HideNameBtnTipsPanel()
		-- 			end,
		-- 		},
			
		-- 		{
		-- 			Name = LSTR(620125),
		-- 			Callback = function()
		-- 				self:OnBtnCopyName()
		-- 				self:HideNameBtnTipsPanel()
		-- 			end,
		-- 		},
		-- 	}
		-- else
			self:CopyName()
			return
		-- end
	end

	self.NameBtnPanel:UpdateView(self.NameTable)
	UIUtil.SetIsVisible(self.NameBtnPanel, true)

	
	local InOffset = _G.UE.FVector2D(0, 0)
	TipsUtil.AdjustTipsPosition(self.NameBtnPanel, self.BtnChangeofName, InOffset, _G.UE.FVector2D(0, 0))

	UIUtil.SetIsVisible(self.Mask, true, true)
end

function PersonInfoMainPanelView:OpenInfoPanel()
	-- local RoleVM = self.RoleVM 
	-- if not RoleVM then return end

	-- local IsMajor = MajorUtil.GetMajorRoleID() == RoleVM.RoleID 

	-- if IsMajor then
	-- 	--
	-- end

	self.InfoTabel = {
		{
			Name = LSTR(620124), 
			Callback = function()
				self:OnBtnChangeName()
				self:HideInfoBtnTipsPanel()
			end,
		},

		{
			Name = LSTR(620126), 
			Callback = function()
				self:OnEditSign()
				self:HideInfoBtnTipsPanel()
			end,
		},

		{
			Name = LSTR(620127), 
			Callback = function()
				self:OnClickButtonOnlineSet()
				self:HideInfoBtnTipsPanel()
			end,
		},

		--

		{
			Name = LSTR(620128), 
			Callback = function()
				self:OnClickButtonTitleSet()
				self:HideInfoBtnTipsPanel()
			end,
		},

		{
			ReddotID = 201,
			Name = LSTR(620129), 
			Callback = function()
				self:OnClickButtonHeadSet()
				self:HideInfoBtnTipsPanel()
			end,
		},

		{
			Name = LSTR(620130), 
			Callback = function()
				self:OnClickButtonHeadSet()
				self:HideInfoBtnTipsPanel()
			end,
		},

		--

		{
			Name = LSTR(620131), 
			Callback = function()
				self:OnClickButtonProfSet()
				self:HideInfoBtnTipsPanel()
			end,
		},

		{
			Name = LSTR(620132), 
			Callback = function()
				self:OnClickButtonStyleSet()
				self:HideInfoBtnTipsPanel()
			end,
		},

		{
			Name = LSTR(620133), 
			Callback = function()
				self:OnClickButtonHoursSet()
				self:HideInfoBtnTipsPanel()
			end,
		},

		--

		{
			Name = LSTR(620134), 
			Callback = function()
				self:OnClickButtonPortraitEdit()
				self:HideInfoBtnTipsPanel()
			end,
		},

		--

		{
			Name = LSTR(620125), 
			Callback = function()
				self:OnBtnCopyName()
				self:HideInfoBtnTipsPanel()
			end,
		},
	}

	self.NameBtnPanel:UpdateView(self.InfoTabel)
	UIUtil.SetIsVisible(self.InfoBtnPanel, true)

	local InOffset = _G.UE.FVector2D(-100, 100)
	TipsUtil.AdjustTipsPosition(self.InfoBtnPanel, self.BtnSet, InOffset, _G.UE.FVector2D(0, 0))

	UIUtil.SetIsVisible(self.Mask_InfoPanel, true, true)
end

function PersonInfoMainPanelView:HideInfoBtnTipsPanel()
	UIUtil.SetIsVisible(self.InfoBtnPanel, false)
	UIUtil.SetIsVisible(self.Mask_InfoPanel, false)
end

function PersonInfoMainPanelView:OnClickInfoPanelMask()
	self:HideInfoBtnTipsPanel()
end

function PersonInfoMainPanelView:OnClickBtnSetting()
	self:OpenInfoPanel()
end

--临时修复，主干与分支代码差异比较大，与策划沟通临时修复此问题，等待主干合入其他代码
--【【现网】【个人信息】玩家B主武器为传武，玩家A点击玩家B个人名片-个人信息-装备信息点击传武获取路径到传武界面，关闭传武界面后，玩家B装备信息界面背景消失，显示为主界面】
--https://tapd.tencent.com/tapd_fe/20420083/bug/detail/1020420083145611976
function PersonInfoMainPanelView:OnActive()
	local CameraMgr = _G.UE.UCameraMgr.Get()
	if CameraMgr ~= nil then
		CameraMgr:SwitchCamera(self.CommonRender2D.RenderActor, 0)
	end
end

return PersonInfoMainPanelView