---
--- Author: Administrator
--- DateTime: 2025-02-27 14:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local TimeUtil = require("Utils/TimeUtil")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local TipsUtil = require("Utils/TipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ActorUtil = require("Utils/ActorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")

local EventID = require("Define/EventID")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local ClosetCfg = require("TableCfg/ClosetCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ClosetCharismCfg = require("TableCfg/ClosetCharismCfg")
local SystemLightCfg = require("TableCfg/SystemLightCfg")

local SystemLightCfg = require("TableCfg/SystemLightCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local EventID = require("Define/EventID")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local CameraFocusCfgMap = require("Game/Wardrobe/WardrobeCameraFocusCfgMap")
local EquipmentCameraControlDataLoader = require("Game/Equipment/EquipmentCameraControlDataLoader")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local SaveKey = require("Define/SaveKey")

local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local WardrobeMainPanelVM = require("Game/Wardrobe/VM/WardrobeMainPanelVM")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")

local EquipmentBGPath = "Class'/Game/UI/Render2D/Equipment/BP_EquipmentBackground.BP_EquipmentBackground_C'"
local EquipmentPartList = ProtoCommon.equip_part
local SettingsTabRole = nil
local LSTR = _G.LSTR

---@class WardrobeMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot1 WardrobeBagSlotItemView
---@field BagSlot2 WardrobeBagSlotItemView
---@field BtnBox UFButton
---@field BtnCamera UToggleButton
---@field BtnCharm UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnCollect UToggleButton
---@field BtnCollect2 UFButton
---@field BtnHand UToggleButton
---@field BtnHat UToggleButton
---@field BtnHatStyle UToggleButton
---@field BtnInfo CommInforBtnView
---@field BtnInfo3 CommInforBtnView
---@field BtnPose UToggleButton
---@field BtnPresets UFButton
---@field BtnReduce UFButton
---@field BtnScreener CommScreenerBtnView
---@field BtnSearch CommSearchBtnView
---@field BtnStain UFButton
---@field BtnSuit UFButton
---@field BtnUnlock UFButton
---@field BtnUnlock1 CommBtnLView
---@field CommEmpty CommBackpackEmptyView
---@field CommonBkg CommonBkg01View
---@field CommonTitle CommonTitleView
---@field Common_Render2D_UIBP CommonRender2DView
---@field DropDownList CommDropDownListView
---@field EFF UFCanvasPanel
---@field EFF_Reward UFCanvasPanel
---@field EffectUnlock UFCanvasPanel
---@field FHorizontalName UFHorizontalBox
---@field FHorizontalNo UFHorizontalBox
---@field FHorizontalSlot UFHorizontalBox
---@field ImgDisable3 UFImage
---@field ImgLine UFImage
---@field ImgMask UFImage
---@field ImgPresets UFImage
---@field ImgUnlock UFImage
---@field PanelArrow UFCanvasPanel
---@field PanelArrow2 UFCanvasPanel
---@field PanelBg UFCanvasPanel
---@field PanelBtn UFCanvasPanel
---@field PanelBtnUnlock UFCanvasPanel
---@field PanelCanStain UFCanvasPanel
---@field PanelCharmNum UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field PanelName UFCanvasPanel
---@field PanelReduce UFCanvasPanel
---@field PanelSlot UFCanvasPanel
---@field PanelStain UFCanvasPanel
---@field PanelSwitch UFCanvasPanel
---@field PanelTab UFCanvasPanel
---@field PanelUnStain UFCanvasPanel
---@field RedDotQuickUnlock CommonRedDotView
---@field ScaleBox UScaleBox
---@field SearchBar CommSearchBarView
---@field SizeBoxX USizeBox
---@field TabList UTableView
---@field TableViewEquipment UTableView
---@field TableViewJump UTableView
---@field TableViewPosition UTableView
---@field TextCharm UFTextBlock
---@field TextCharmNum UFTextBlock
---@field TextName UFTextBlock
---@field TextNo UFTextBlock
---@field TextNum UFTextBlock
---@field TextPresets UFTextBlock
---@field TextReduce UFTextBlock
---@field TextStain UFTextBlock
---@field TextStain2 UFTextBlock
---@field TextStain3 UFTextBlock
---@field TextSubtitle URichTextBox
---@field TextTitle UFTextBlock
---@field TextUnlock UFTextBlock
---@field TextUnlock2 UFTextBlock
---@field TextUnlock2_1 UFTextBlock
---@field ToggleBtnSwitch UToggleButton
---@field WardrobeJob WardrobeJobItemView
---@field WardrobeOperateItem WardrobeOperateItemView
---@field AnimBtnUnlock UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeMainPanelView = LuaClass(UIView, true)

function WardrobeMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot1 = nil
	--self.BagSlot2 = nil
	--self.BtnBox = nil
	--self.BtnCamera = nil
	--self.BtnCharm = nil
	--self.BtnClose = nil
	--self.BtnCollect = nil
	--self.BtnCollect2 = nil
	--self.BtnHand = nil
	--self.BtnHat = nil
	--self.BtnHatStyle = nil
	--self.BtnInfo = nil
	--self.BtnInfo3 = nil
	--self.BtnPose = nil
	--self.BtnPresets = nil
	--self.BtnReduce = nil
	--self.BtnScreener = nil
	--self.BtnSearch = nil
	--self.BtnStain = nil
	--self.BtnSuit = nil
	--self.BtnUnlock = nil
	--self.BtnUnlock1 = nil
	--self.CommEmpty = nil
	--self.CommonBkg = nil
	--self.CommonTitle = nil
	--self.Common_Render2D_UIBP = nil
	--self.DropDownList = nil
	--self.EFF = nil
	--self.EFF_Reward = nil
	--self.EffectUnlock = nil
	--self.FHorizontalName = nil
	--self.FHorizontalNo = nil
	--self.FHorizontalSlot = nil
	--self.ImgDisable3 = nil
	--self.ImgLine = nil
	--self.ImgMask = nil
	--self.ImgPresets = nil
	--self.ImgUnlock = nil
	--self.PanelArrow = nil
	--self.PanelArrow2 = nil
	--self.PanelBg = nil
	--self.PanelBtn = nil
	--self.PanelBtnUnlock = nil
	--self.PanelCanStain = nil
	--self.PanelCharmNum = nil
	--self.PanelContent = nil
	--self.PanelEmpty = nil
	--self.PanelMain = nil
	--self.PanelName = nil
	--self.PanelReduce = nil
	--self.PanelSlot = nil
	--self.PanelStain = nil
	--self.PanelSwitch = nil
	--self.PanelTab = nil
	--self.PanelUnStain = nil
	--self.RedDotQuickUnlock = nil
	--self.ScaleBox = nil
	--self.SearchBar = nil
	--self.SizeBoxX = nil
	--self.TabList = nil
	--self.TableViewEquipment = nil
	--self.TableViewJump = nil
	--self.TableViewPosition = nil
	--self.TextCharm = nil
	--self.TextCharmNum = nil
	--self.TextName = nil
	--self.TextNo = nil
	--self.TextNum = nil
	--self.TextPresets = nil
	--self.TextReduce = nil
	--self.TextStain = nil
	--self.TextStain2 = nil
	--self.TextStain3 = nil
	--self.TextSubtitle = nil
	--self.TextTitle = nil
	--self.TextUnlock = nil
	--self.TextUnlock2 = nil
	--self.TextUnlock2_1 = nil
	--self.ToggleBtnSwitch = nil
	--self.WardrobeJob = nil
	--self.WardrobeOperateItem = nil
	--self.AnimBtnUnlock = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot1)
	self:AddSubView(self.BagSlot2)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.BtnInfo3)
	self:AddSubView(self.BtnScreener)
	self:AddSubView(self.BtnSearch)
	self:AddSubView(self.BtnUnlock1)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.Common_Render2D_UIBP)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.RedDotQuickUnlock)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.WardrobeJob)
	self:AddSubView(self.WardrobeOperateItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeMainPanelView:OnInit()
	self.VM = WardrobeMainPanelVM
	-- 装备菜单列表
	self.AppearanceTabListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPosition, self.OnAppearanceTabListChanged, true)
	-- 装备二级标签列表
	self.AppearanceSecTabListAdapter = UIAdapterTableView.CreateAdapter(self, self.TabList, self.OnAppearanceSecTabListChanged, true)
	-- 装备部件列表
	self.AppearanceListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewEquipment, self.OnAppearanceListChanged, true, true)
	-- 成就列表
	self.AchievementListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewJump, nil)

	-- 初始化Binders
	self.Binders = {
		--列表
		{ "AppearanceTabList",  UIBinderUpdateBindableList.New(self, self.AppearanceTabListAdapter)},
		{ "AppearanceSecTabList",  UIBinderUpdateBindableList.New(self, self.AppearanceSecTabListAdapter)},
		{ "AppearanceList",  UIBinderUpdateBindableList.New(self, self.AppearanceListAdapter)},
		{ "AchievementList",  UIBinderUpdateBindableList.New(self, self.AchievementListAdapter)},
		--按钮控件
		{ "BtnCameraChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnCamera)},
		{ "BtnHandChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnHand)},
		{ "BtnPoseChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnPose)},
		{ "BtnHatChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnHat)},
		{ "BtnHatStyleChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnHatStyle)},
		{ "BtnHatStyleVisible", UIBinderSetIsVisible.New(self, self.WardrobeOperateItem.BtnHatStyle, false, true)},
		{ "BtnSuitSwitchChecked", UIBinderSetIsChecked.New(self, self.ToggleBtnSwitch)},

		{ "BtnSuitVisible", UIBinderSetIsVisible.New(self, self.BtnSuit, false, true)},
		{ "AppearanceTabText", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle)},
		{ "CharmNumText", UIBinderSetText.New(self, self.TextCharmNum)},
		{ "CharmNumText", UIBinderSetText.New(self, self.TextNum)},
		{ "AppearanceName", UIBinderSetText.New(self, self.TextName)},
		{ "PanelStainVisible", UIBinderSetIsVisible.New(self, self.PanelStain)},
		{ "PanelUnStainVisible", UIBinderSetIsVisible.New(self, self.PanelUnStain)},
		{ "PanelCanStainVisible", UIBinderSetIsVisible.New(self, self.PanelCanStain)},
		{ "JobBoxVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob)},
		{ "UnlockBoxVisible", UIBinderSetIsVisible.New(self, self.FHorizontalSlot)},
		{ "ReduceCondVisible", UIBinderSetIsVisible.New(self, self.PanelReduce)},
		{ "PanelBtnVisible", UIBinderSetIsVisible.New(self, self.PanelBtn)},
		{ "QuickUnlockVisible", UIBinderSetIsVisible.New(self, self.PanelBtnUnlock)},
		{ "BtnUnlockEnable", UIBinderSetIsEnabled.New(self, self.BtnUnlock1.Button, false , true)},
		{ "BtnUnlockText", UIBinderSetText.New(self, self.BtnUnlock1.TextContent)},
		{ "GenderCondText", UIBinderSetText.New(self, self.WardrobeJob.TextGender) },
		{ "ProfCondText", UIBinderSetText.New(self, self.WardrobeJob.TextJob) },
		{ "ProfLevelText", UIBinderSetText.New(self, self.WardrobeJob.TextJobLevel) },
		{ "RaceCondText", UIBinderSetText.New(self, self.WardrobeJob.TextRace) },
		{ "UnlockVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob.TextUnlock)},
		{ "UnlockTextVisible", UIBinderSetIsVisible.New(self, self.TextUnlock)},
		{ "DetailProfVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob.BtnInfo2, false, true)},
		{ "GenderCondColor", UIBinderSetColorAndOpacityHex.New(self, self.WardrobeJob.TextGender) },
		{ "ProfCondColor", UIBinderSetColorAndOpacityHex.New(self, self.WardrobeJob.TextJob) },
		{ "ProfLevelColor", UIBinderSetColorAndOpacityHex.New(self, self.WardrobeJob.TextJobLevel) },
		{ "RaceCondColor", UIBinderSetColorAndOpacityHex.New(self, self.WardrobeJob.TextRace) },
		{ "BagSlot1Visible", UIBinderSetIsVisible.New(self, self.BagSlot1)},
		{ "BagSlot2Visible", UIBinderSetIsVisible.New(self, self.BagSlot2)},
		{ "IsSearching", UIBinderSetIsVisible.New(self, self.SearchBar)},
		{ "IsSearching", UIBinderSetIsVisible.New(self, self.BtnScreener, true)},
		{ "IsSearching", UIBinderSetIsVisible.New(self, self.DropDownList, true)},
		{ "IsSearching", UIBinderSetIsVisible.New(self, self.BtnSearch, true)},
		{ "EmptyVisible", UIBinderSetIsVisible.New(self, self.CommEmpty)},
		{ "EmptyVisible", UIBinderSetIsVisible.New(self, self.ImgEmptyBg)},
		{ "EmptyText", UIBinderSetText.New(self, self.CommEmpty.Text_SearchAgain)},
		{ "PanelNameVisible", UIBinderSetIsVisible.New(self, self.PanelName)},
		{ "PanelNameVisible", UIBinderSetIsVisible.New(self, self.BtnUnlock1, false, true)},
		{ "PanelNameVisible", UIBinderSetIsVisible.New(self, self.BtnCollect, false, true)},
		{ "CharmEffVisible", UIBinderSetIsVisible.New(self, self.EFF_Reward)},
		{ "CurAppUnlockedVisible", UIBinderSetIsVisible.New(self, self.BtnInfo3, false, true)},
		{ "CurAppUnlockConditionVisible", UIBinderSetIsVisible.New(self, self.FHorizontalNo, true)},
		{ "CurAppUnlockCondition", UIBinderSetText.New(self, self.TextNo)},
		{ "CurAppUnlockLevelConditon", UIBinderSetIsVisible.New(self, self.WardrobeJob.SizeBoxX)},
		{ "CurAppUnlockProfCondVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob.SizeBoxX2)},
		{ "CurAppUnlockGenderCondVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob.SizeBoxX3)},
		{ "CurAppUnlockRaceCondVisible", UIBinderSetIsVisible.New(self, self.WardrobeJob.SizeBoxX4)},
	}

	-- 初始化变量
	self.CurPartID = nil   --左侧部位当前部位
	self.CurPartSubName = "" --左侧部位副区域
	self.CurWeaponProfID = nil --当前穿戴武器职业ID
	self.CurAppearanceID = nil --当前外观ID
	self.CurDropDownIndex = 0  --职业下拉框选中下标
	self.DefaultDropDownIndex = 0   --默认职业下拉框选中下标
	self.DropDownDataList = {}	--职业下拉框数据列表
	self.TabRecordList = {}	-- 记录部位最后一个选中外观
	self.IsFiltering = false  --是否正在筛选
	self.IsFirstEnter = true  --是否第一次进入界面
	self.IsFirstSelect = true --是否第一次进入选中
	self.IsPlaySelectedAnim = false --是否播放选中动画
	self.NeededChangeSearch = true  --是否切换搜索
	self.bReadyToInitCamera = false --是否相机初始化
	self.ShowModelType = nil   --模型展示类型
	self.LastHandBtnTime = 0   --最后一次点击武器时间
	self.LastHatBtnTime = 0	   --最后一次点击头部时间
	self.LastHatStyleBtnTime = 0 --最后一次点击头部机关时间
	self.LastPoseBtnTime = 0 -- 最后一次点击展示武器时间
	self.WeaponPoseTimerID = 0 -- 展示武器定时器
	self.CurViewPage = UIViewID.WardrobeMainPanel

	self.CameraFocusCfgMap = CameraFocusCfgMap.New() --镜头参数
	self.CreateRenderActorIsOver = false -- 只置为true一次，第一次Creat时 Render2D.ChildActor为空
	self.ShowTipsEnable = true
	self.NoUnclothing = false
end

function WardrobeMainPanelView:OnDestroy()

end


function WardrobeMainPanelView:OnViewHide(ViewID)
	if ViewID == UIViewID.LegendaryWeaponPanel then
		self.Common_Render2D_UIBP.bCameraSwitchedToRenderActor = false
		self.Common_Render2D_UIBP:ChangeUIState(false)
	end
	
end

function WardrobeMainPanelView:OnShow()
	self:InitText()
	self.VM.EmptyText = LSTR(1080023)
	self.VM:InitFavoriteData()
	UIUtil.SetIsVisible(self.CommonBkg, true)
	_G.HUDMgr:SetIsDrawHUD(false)
	self.IsFirstSelect = true 
	-- UIUtil.SetIsVisible(self.PanelCharmNum, true, false)
	self.Common_Render2D_UIBP.bCreateShandowActor = true
	self.Common_Render2D_UIBP:SetShadowActorType(ActorUtil.ShadowType.Wardrobe)
	self:CreateRenderActor()
	self.Common_Render2D_UIBP:SetShadowActorPos(_G.UE.FVector(-50, 0, 100002))

	-- 灯光设置
	self.Common_Render2D_UIBP.bIgnoreTodAffective = true
	_G.LightMgr:EnableUIWeather(4)
	--_G.LightMgr:LoadLightLevel(LightLevelID.LIGHT_LEVEL_ID_WARDROBE)
	_G.SpeechBubbleMgr:ShowSpeechBubbleAll(false)
	_G.BuoyMgr:ShowAllBuoys(false)

	--初始化按钮状态
	self:InitModelBtnState()
	self:WeaponVisibleSwitch(self.VM.BtnHandChecked)
	self:HatVisibleSwitch(self.VM.BtnHatChecked)
	self:HatStyleSwitch(self.VM.BtnHatStyleChecked)
	self.VM.BtnPoseChecked = false
	self:PoseStyleSwitch(self.VM.BtnPoseChecked)
	self.VM.BtnCameraChecked = false
	self.BtnCamera:SetChecked(self.VM.BtnCameraChecked)
	self.ToggleBtnSwitch:SetChecked(self.VM.BtnSuitSwitchChecked)
	self.WardrobeJob:SetButtonStyle(HelpInfoUtil.HelpInfoType.NewTips)
	self.BtnInfo3:SetButtonStyle(HelpInfoUtil.HelpInfoType.NewTips)

	--更新列表
	self.VM:InitAppearanceTabList()
	self.VM:UpdateCharismNum()
	-- 
	local Length = #WardrobeMgr:GetQuickUnlockAppearanceList()
	if Length > 0 then
		self.TextUnlock2_1:SetText(string.format(_G.LSTR(1080126), Length))
		UIUtil.SetIsVisible(self.EffectUnlock, true)
		self:PlayAnimation(self.AnimBtnUnlock)
		self:RegisterTimer(function ()
			UIUtil.SetIsVisible(self.EffectUnlock, false)
		end, self.AnimBtnUnlock:GetEndTime(), 0, 1)

	else
		UIUtil.SetIsVisible(self.EffectUnlock, false)
	end
	self.VM:UpdateQuickUnlockState()
	self.IsFirstEnter = true
	self:InitDropDownList()
	self.IsFirstEnter = false
	self.IsPlaySelectedAnim = false
	self.AppearanceTabListAdapter:SetSelectedIndex(1)
	self.IsPlaySelectedAnim = true
	self.NeededChangeSearch = true
	self.VM.BtnSuitVisible = false 

	--记录按钮状态
	self.RecordHandState = self.VM.BtnHandChecked
	self.RecordHatState = self.VM.BtnHatChecked
	self.RecordHatStyleState = self.VM.BtnHatStyleChecked

	--初始化通用控件回调函数
	self.BagSlot1:SetCallback(self, self.OnClickedBagSlotItemView1)
	self.BagSlot2:SetCallback(self, self.OnClickedBagSlotItemView2)
	self.SearchBar:SetCallback(self, self.OnChangeSearchBar, nil, self.OnClickCancelSearchBar)
	self.WardrobeJob:SetCallback(self, self.OnClickedBtnInfo2)

	--红点
	self.RedDotQuickUnlock:SetRedDotIDByID(WardrobeDefine.RedDotList.QuickUnlock)
	self.RedDotQuickUnlock:SetStyle(RedDotDefine.RedDotStyle.NormalStyle)

	--前往解锁界面
	if self.Params ~= nil and self.Params.UnlockAppID ~= nil then
		self:OpenWardrobeUnlockPanel(self.Params.UnlockAppID)
	end

	WardrobeMgr:SendClosetQueryReq()

	self:UpdateModelEquipment()

	local IsSpec = ProfUtil.IsProductionProf(MajorUtil.GetMajorProfID()) 
	UIUtil.SetIsVisible(self.WardrobeOperateItem.BtnPose, not IsSpec, true)
	

end

function WardrobeMainPanelView:OnHide()
	self:UpdateBtnStateToServer()
	self.TabRecordList = {}
	WardrobeMgr:ClearViewSuit()
	WardrobeMgr:PlaySgActorAnim(false)
	_G.LightMgr:DisableUIWeather()
	_G.SpeechBubbleMgr:ShowSpeechBubbleAll(true)
	_G.BuoyMgr:ShowAllBuoys(true)
	_G.HUDMgr:SetIsDrawHUD(true)
	if self.WeaponPoseTimerID ~= 0 then
		_G.TimerMgr:CancelTimer(self.WeaponPoseTimerID)
		self.WeaponPoseTimerID = 0
	end
	if self.BackgroundActor ~= nil then
		CommonUtil.DestroyActor(self.BackgroundActor)
		self.BackgroundActor = nil
	end
end

function WardrobeMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBox, self.OnClickedBtnBox)
	UIUtil.AddOnClickedEvent(self, self.BtnUnlock, self.OnClickedBtnUnlock)
	UIUtil.AddOnClickedEvent(self, self.BtnPresets, self.OnClickedBtnPresets)
	UIUtil.AddOnClickedEvent(self, self.BtnCharm, self.OnClickedBtnCharm)
	UIUtil.AddOnClickedEvent(self, self.BtnStain, self.OnClickedBtnStain)
	UIUtil.AddOnClickedEvent(self, self.BtnReduce, self.OnClickedBtnReduce)
	UIUtil.AddOnClickedEvent(self, self.BtnUnlock1.Button, self.OnClickSingleEquipmentBtnUnlock)
	UIUtil.AddOnClickedEvent(self, self.BtnInfo3.BtnInfor, self.OnClickedBagSlotItemView3)
	UIUtil.AddOnClickedEvent(self, self.BtnCollect2, self.OnClickedBtnCollect2)

	UIUtil.AddOnClickedEvent(self, self.BtnSuit, self.OnClickedBtnSuit)

	UIUtil.AddOnStateChangedEvent(self, self.BtnScreener, self.OnClickedBtnScreener)
	UIUtil.AddOnStateChangedEvent(self, self.BtnCollect, self.OnClickedBtnCollect)

	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnCamera, self.OnClickedBtnCamera)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnHand, self.OnClickedBtnHand)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnHat, self.OnClickedBtnHat)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnHatStyle, self.OnClickedBtnHatStyle)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnPose, self.OnClickedBtnPose)
	
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnSwitch, self.OnClickedBtnSwitch)
	UIUtil.AddOnClickedEvent(self, self.BtnSearch.BtnSearch, self.OnClickedBtnSearch)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnDropDownListSelectionChanged)
end

function WardrobeMainPanelView:OnRegisterGameEvent()
	-- 衣橱基本更新
	self:RegisterGameEvent(EventID.WardrobeUpdate, self.OnWardrobeDataUpdate)
	-- 衣橱染色更新
	self:RegisterGameEvent(EventID.WardrobeDyeUpdate, self.OnWardrobeDataUpdate)
	-- 衣橱染色更新
	self:RegisterGameEvent(EventID.WardrobeRegionDyeUpdate, self.OnWardrobeDataUpdate)
	-- 衣橱解锁更新
	self:RegisterGameEvent(EventID.WardrobeUnlockUpdate, self.OnWardrobeUnlockUpdate)
	-- 衣橱收藏更新
	self:RegisterGameEvent(EventID.WardrobeCollectUpdate, self.OnAppearanceListCollectUpdate)
	-- 衣橱穿戴更新
	self:RegisterGameEvent(EventID.WardrobeClothingUpdate, self.OnWardrobeClothingUpdate)
	-- 衣橱穿戴更新
	self:RegisterGameEvent(EventID.WardrobeUnClothingUpdate, self.OnWardrobeUnClothingUpdate)
	-- 衣橱魅力值更新
	self:RegisterGameEvent(EventID.WardrobeCharismValueUpdate, self.OnWardrobeCharismValueUpdate)
	-- 模型组装
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	-- 衣橱通用筛选更新
	self:RegisterGameEvent(EventID.ScreenerResult, self.OnScreenerAction)
	-- 背包更新
	self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateBag)
	-- 衣橱数据解锁更新
	self:RegisterGameEvent(EventID.WardrobeUnlockIDUpdate, self.OnWardrobeAppearnceDataUpdate)
	-- 魅力值奖励更新
	self:RegisterGameEvent(EventID.WardrobeCollectReward, self.OnWardrobeCollectReward)
	self:RegisterGameEvent(_G.EventID.HideUI, self.OnViewHide)
end

function WardrobeMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
	self.BagSlot1:SetParams({ Data = self.VM.BagSlotItemVM1})
	self.BagSlot2:SetParams({ Data = self.VM.BagSlotItemVM2})
end

function WardrobeMainPanelView:OnInactive()
	if self.BackgroundActor ~= nil then
		CommonUtil.DestroyActor(self.BackgroundActor)
		self.BackgroundActor = nil
	end
end

function WardrobeMainPanelView:OnActive()
	self.BackgroundActor = CommonUtil.SpawnActor(_G.ObjectMgr:GetClass(EquipmentBGPath),self.Common_Render2D_UIBP.RenderActor:K2_GetActorLocation())
	self.Common_Render2D_UIBP.bCameraSwitchedToRenderActor = false
	self.Common_Render2D_UIBP:ChangeUIState(false)
end

---------------------------------------- 协议相关逻辑 ----------------------------------------
---
function WardrobeMainPanelView:OnWardrobeAppearnceDataUpdate(AppID)
	if self.CurAppearanceID == nil then
		return
	end
	if self.CurAppearanceID ~= AppID then
		return
	end

	self:UpdateCurrentAppearance()
end

function WardrobeMainPanelView:OnWardrobeDataUpdate(Params)
	-- 更新魅力值
	self.VM:UpdateCharismNum()
	-- 更新外观菜单栏
	self.VM:UpdateAppearanceTabList()
	-- 更新外观List
	self.VM:UpdateAppearanceListState(self.CurPartID)
	-- 更新是否有快速解锁/染色/降低条件的图标显示
	self.VM:UpdateQuickUnlockState()
	-- 更新当前选中的外观信息
	self:UpdateCurrentAppearance()

	if Params and Params.bUpdate then
		self:UpdateModelEquipment()
		self:SelectClothingViewSuit(self.CurPartID)
		self.IsFirstSelect = false
	end
end

function WardrobeMainPanelView:OnWardrobeUnlockUpdate(Params)
	-- 更新外观菜单栏
	self.VM:UpdateAppearanceTabList()
	-- 更新外观List
	self.VM:UpdateAppearanceListState(self.CurPartID)
	-- 更新是否有快速解锁/染色/降低条件的图标显示
	self.VM:UpdateQuickUnlockState()

	-- 更新当前选中的外观信息
	self:UpdateCurrentAppearance()

	-- 如果当前解锁的外观 选中状态，直接穿戴上去
	local UnlockAppearanceList = Params.UnlockAppearanceList
	for _, v in ipairs(UnlockAppearanceList) do
		for i = 1, self.AppearanceListAdapter:GetNum() do
			local TempAppearanceItem = self.AppearanceListAdapter:GetItemDataByIndex(i)
			if TempAppearanceItem and TempAppearanceItem.ID == v.AppearanceID and TempAppearanceItem.IsSelected then
				local CanEquiped = WardrobeMgr:CanEquipAppearance(v.AppearanceID)
				if CanEquiped then
					WardrobeMgr:SendClosetClothingReq(v.AppearanceID, self.CurPartID)
				end
			end
		end
	end
end

function WardrobeMainPanelView:OnAppearanceListCollectUpdate() 
	-- 更新是否有快速解锁/染色/降低条件的图标显示
	self.VM:UpdateAppearanceListState(self.CurPartID)
	-- 更新当前选中的外观信息
	self:UpdateCurrentAppearance()
end

function WardrobeMainPanelView:OnWardrobeClothingUpdate(Params)
	if Params == nil then
		return
	end

	if Params.AppID == nil and Params.Part == nil then
		return
	end

	local PartID = Params.Part
	local AppID = Params.AppID

	self:PreviewAppearance(PartID, AppID)
end

function WardrobeMainPanelView:OnWardrobeUnClothingUpdate(Params)
	if Params == nil then
		return
	end
	
	if Params.PartID == nil then
		return
	end
	
	local EquipList = EquipmentVM.ItemList
	for _ , part in pairs(WardrobeDefine.EquipmentTab) do
		if Params.PartID == part then
			local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(part)
			if CurrentAppID ~= 0 then
				local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
				local ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
				local RegionDyes = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
				local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(CurrentAppID)
				self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, IsAppRegionDye and 0 or ColorID)
				self:StainPartForSection(CurrentAppID, tonumber(part), RegionDyes)
			else
				local TempEquip = EquipList[part]
				if TempEquip ~= nil then
					local EquipID = TempEquip.ResID
					self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, 0)
				else
					self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
				end
			end
		end
	end

	--处理副手
	-- if  Params.PartID == EquipmentPartList.EQUIP_PART_MASTER_HAND then
	-- 	for _ , part in pairs(WardrobeDefine.EquipmentTab) do
	-- 		if part == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
	-- 			local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(part)
	-- 			if CurrentAppID ~= 0 then
	-- 				local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
	-- 				local ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
	-- 				local RegionDyes = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
	-- 				self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, ColorID)
	-- 				self:StainPartForSection(CurrentAppID, tonumber(part), RegionDyes)
	-- 			else
	-- 				local TempEquip = EquipList[part]
	-- 				if TempEquip ~= nil then
	-- 					local EquipID = TempEquip.ResID
	-- 					self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, 0)
	-- 				else
	-- 					self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
end

function WardrobeMainPanelView:OnWardrobeCharismValueUpdate()
	if self.VM then
		self.VM:UpdateCharismNum()
	end
end

function WardrobeMainPanelView:OnWardrobeCollectReward()

	local AwardInfoList, AwardSelectIndex = self:GetAwardInfo()
	local Params = {}
	Params.AwardList = AwardInfoList
	Params.AwardSelectIndex = AwardSelectIndex
	Params.CollectedNum = WardrobeMgr:GetCharismNum()
	Params.MaxCollectNum = WardrobeMgr:GetCharismTotalNum()
	local View = UIViewMgr:FindView(UIViewID.CollectionAwardPanel)
	if View ~= nil then
		View:RefreshData(Params)
		View:RefreshTitle()
	end
end

function WardrobeMainPanelView:OnUpdateBag()
	self.VM:UpdateQuickUnlockState()
	WardrobeMgr:SetRedDot()
	self:UpdateCurrentAppearance()
	if self.CurAppearanceID ~= nil then
	self.VM:UpdateCurrentAppearanceInfo(self.CurAppearanceID)
	end

end

---------------------------------------- 界面相关逻辑 ----------------------------------------
function WardrobeMainPanelView:InitText()
	self.CommonTitle:SetTextTitleName(_G.LSTR(1080073))
	self.TextTitle:SetText(_G.LSTR(1080073))
	self.TextCharm:SetText(_G.LSTR(1080074))
	self.TextUnlock:SetText(_G.LSTR(1080075))

	self.TextReduce:SetText(_G.LSTR(1080083)) -- 降低条件
	self.TextStain3:SetText(_G.LSTR(1080084))  --可染色
	self.TextStain2:SetText(_G.LSTR(1080054)) -- 不可染色
	self.TextStain:SetText(_G.LSTR(1080071)) -- 试染

	self.TextPresets:SetText(_G.LSTR(1080106)) -- 预设
	self.TextUnlock2:SetText(_G.LSTR(1080107)) -- 解锁

	self.SearchBar:SetIllegalTipsText(LSTR(10057)) --10057("当前文本不可使用，请重新输入")


	self.CommEmpty.RichTextNone:SetText(_G.LSTR(1080108))  -- 暂无对应外观
	self.CommEmpty.RichTextNoneBright:SetText(_G.LSTR(1080108)) -- 暂无对应外观
end

--初始化按钮数据
function WardrobeMainPanelView:InitModelBtnState()
	self.VM.BtnHandChecked = self:GetSettingsTabRole().ShowWeaponIdx == 1
	self.VM.BtnHatChecked = self:GetSettingsTabRole():GetShowHead() == 1
	-- self:InitBtnHatStyleState()
end

-- 初始化显示/隐藏头部机关
function WardrobeMainPanelView:InitBtnHatStyleState()
	local HasGimmick = WardrobeMgr:CheckHeadHasGimmick()
    self.VM.BtnHatStyleVisible = HasGimmick
	
    if HasGimmick then
		self.VM.BtnHatStyleChecked = self:GetSettingsTabRole().SwitchHelmetIdx == 1
        local toggleState = self.VM.BtnHatStyleChecked and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.Unchecked
        self.WardrobeOperateItem.BtnHatStyle:SetCheckedState(toggleState, false)
        self.Common_Render2D_UIBP:SwitchHelmet(self.VM.BtnHatStyleChecked)
    end

    local btnHatState = self.VM.BtnHatChecked and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.Unchecked
    self.BtnHat:SetCheckedState(btnHatState, false)
    self.Common_Render2D_UIBP:HideHead(not self.VM.BtnHatChecked)
end

-- 初始化职业下拉框
function WardrobeMainPanelView:InitDropDownList()
	local ItemList = {}
	self.DropDownDataList = {}
	for index, v in ipairs(WardrobeDefine.FilterProfList) do
		local Name = nil
		local ClassType = v.ClassType
		local ProfID = v.ProfID
		local IsVersionOpen = true
		if v.ClassType ==  WardrobeDefine.ProfClass.ClassType then
			IsVersionOpen = true
			if ProfID ~= -1 then
				Name = v.ProfID == 0 and _G.LSTR(1080128) or ProtoEnumAlias.GetAlias(ProtoCommon.class_type, v.ProfID)
			else
				Name = _G.LSTR(1080037)
			end
		elseif v.ClassType == WardrobeDefine.ProfClass.BasicType then
			local Cfg = RoleInitCfg:FindCfgByKey(v.ProfID) 
			IsVersionOpen = Cfg ~= nil and Cfg.IsVersionOpen == 1
			Name = ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, v.ProfID)
		elseif v.ClassType == WardrobeDefine.ProfClass.AdvanceType then
			local Cfg = RoleInitCfg:FindCfgByKey(v.ProfID) 
			IsVersionOpen = Cfg ~= nil and Cfg.IsVersionOpen == 1
			if Cfg ~= nil then
				Name = string.format("%s/%s", ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, v.ProfID), ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, Cfg.AdvancedProf))
			end
		end
		if Name ~= nil and IsVersionOpen then
			table.insert(ItemList, {ID = index, Index = #ItemList + 1, Name = Name, ClassType = ClassType, ProfID = ProfID})
		end
	end

	self.DropDownDataList = ItemList

	self.DropDownList:UpdateItems(ItemList)
end

-- 职业下拉框筛选
function WardrobeMainPanelView:OnDropDownListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	self.CurDropDownIndex = Index
	if not self.IsFirstEnter then
		self.VM:UpdateAppearanceList(self.CurPartID, self.CurPartSubName, self:GetFilterProfListIndex(self.CurDropDownIndex), self.ScreenerSelectedInfo)
		self.AppearanceListAdapter:CancelSelected()
		self:SelectClothingViewSuit(self.CurPartID)
	end
end

-- 获取下拉框下标
function WardrobeMainPanelView:GetDropDownListSelectedIndex()
	local MarjorProfID = MajorUtil.GetMajorProfID()
	local SelectedIndex = 1

	for i = 1, #self.DropDownDataList do
		local Data = self.DropDownDataList[i]
		if Data.ClassType == WardrobeDefine.ProfClass.BasicType then
			if MarjorProfID == Data.ProfID then
				return Data.Index
			end
		elseif Data.ClassType == WardrobeDefine.ProfClass.AdvanceType then
			local Cfg = RoleInitCfg:FindCfgByKey(Data.ProfID)
			if Cfg ~= nil then
				if MarjorProfID == Data.ProfID or MarjorProfID == Cfg.AdvancedProf then
					return Data.Index
				end
			end
		end
	end

	return SelectedIndex
end

-- 获取下拉框职业ID
function WardrobeMainPanelView:GetFilterProfListIndex(Index)
	for i = 1, #self.DropDownDataList do
		local Data = self.DropDownDataList[i]
		if Data.Index == Index then
			return Data.ID
		end
	end

	return 1
end

-- 重置职业下拉框
function WardrobeMainPanelView:ResetDropDownList()
	self.IsFirstEnter = true
	self:InitDropDownList()
	self.IsFirstEnter = false
	self.DropDownList:SetSelectedIndex(self.DefaultDropDownIndex)
end

-- 获取设置节点
function WardrobeMainPanelView:GetSettingsTabRole()
	if not SettingsTabRole then
		SettingsTabRole = require("Game/Settings/SettingsTabRole")
	end

	return SettingsTabRole
end

--上传按钮状态
function WardrobeMainPanelView:UpdateBtnStateToServer()
	if self.RecordHandState ~= self.VM.BtnHandChecked then
		local Idx = self.VM.BtnHandChecked and 1 or 2
		self:GetSettingsTabRole():SetShowWeapon(Idx, true)
	end

	-- 特殊一点
	if self.RecordHatState ~= self.VM.BtnHatChecked then
		if self.VM.BtnHatChecked  then
			_G.EquipmentMgr:SendEquipOn({{Part = ProtoCommon.equip_part.EquipHeadShow, GID = 1}})
		else
			_G.EquipmentMgr:SendEquipOn({{Part = ProtoCommon.equip_part.EquipHeadShow, GID = 0}})
		end
		local Idx = self.VM.BtnHatChecked and 1 or 2
		_G.UE.USaveMgr:SetInt(SaveKey.ShowHead, Idx, true)
		self:GetSettingsTabRole().ShowHeadIdx = Idx
		_G.ClientSetupMgr:SendSetReq(ClientSetupID.ShowHead, tostring(Idx))
	end

	if self.RecordHatStyleState ~= self.VM.BtnHatStyleChecked then
		local HatStyleIdx = self.VM.BtnHatStyleChecked and 1 or 2
		self:GetSettingsTabRole():SetHelmetGimmickOn(HatStyleIdx, true)
	end
end

-- 装备菜单列表选中变更
function WardrobeMainPanelView:OnAppearanceTabListChanged(Index, ItemData, ItemView)
	self.ScreenerSelectedInfo = {}
	local ItemID = ItemData.ID
	self.CurPartID = ItemID
	self:RefreshScreenerChecked()
	self:ResetDropDownList()
	self.VM.AppearanceTabText = ProtoEnumAlias.GetAlias(ProtoCommon.equip_part, ItemID)
	self.DefaultDropDownIndex = self:GetDropDownListSelectedIndex()
	self.CurDropDownIndex = self.DefaultDropDownIndex
	self.DropDownList:SetSelectedIndex(self.DefaultDropDownIndex, nil, true)
	self.IsPlaySelectedAnim = false
	self.VM:UpdateAppearanceSecTabList(ItemID)

	if self.VM.BtnCameraChecked then
		_G.FLOG_INFO(string.format("WardrobeMainPanelView 切换镜头到 %s", ProtoEnumAlias.GetAlias(ProtoCommon.equip_part, self.CurPartID)))
		self:ShowModelFocusPart(self.CurPartID)
	else
		if self.ShowModelType ~= WardrobeDefine.ShowModelType.All then
			self:ShowAllModel(false)
		end
	end

	local SecTabList
	if self.TabRecordList[ItemID] == nil then
		SecTabList = 1
	else
		local RecordIndex = self.TabRecordList[ItemID]
		SecTabList = RecordIndex
	end

	self.AppearanceSecTabListAdapter:SetSelectedIndex(SecTabList)
	self.AppearanceSecTabListAdapter:ScrollToIndex(SecTabList)

	self.IsPlaySelectedAnim = true
	self.VM.IsSearching = false
	self.IsFiltering = false
end

-- 更新当前选中的外观信息
function WardrobeMainPanelView:UpdateCurrentAppearance()
	if self.CurAppearanceID == nil then
		return
	end

	local ID = self.CurAppearanceID
	self.VM:UpdateCurrentAppearanceInfo(ID)
	self.VM:UpdateUnlockBtnTextState(ID)
	self:UpdateCurrentAppearanceBtnState(ID)
end

-- 装备列表二级菜单选中变更
function WardrobeMainPanelView:OnAppearanceSecTabListChanged(Index, ItemData, ItemView)
	if Index == 0 then
		return
	end

	self.CurPartSubName = ItemData.TabName
	self:RefreshScreenerChecked()
	self.VM:UpdateAppearanceList(self.CurPartID, ItemData.TabName, self:GetFilterProfListIndex(self.CurDropDownIndex), self.ScreenerSelectedInfo)

	if self.IsPlaySelectedAnim then
		for i = 1, self.AppearanceSecTabListAdapter:GetNum() do
			if i == Index then
			local TempAppearanceItem = self.AppearanceSecTabListAdapter:GetChildWidget(Index)
				if TempAppearanceItem then
					TempAppearanceItem:PlaySelectedAnimation()
				end
			end
		end
	end

	self.TabRecordList[self.CurPartID] = Index
	local PartViewSuitID = WardrobeMgr:GetClothingViewSuit(self.CurPartID)
	if PartViewSuitID ~= nil then
		self:SelectClothingViewSuit(self.CurPartID)
	end

	if self.NeededChangeSearch then
		self.VM.IsSearching = false
	end
end

-- 当前部位正在穿戴的外观
function WardrobeMainPanelView:SelectClothingViewSuit(PartID)
	self.ShowTipsEnable = false
	local PartViewSuitID = WardrobeMgr:GetClothingViewSuit(PartID)
	if PartViewSuitID then
		for i = 1, self.AppearanceListAdapter:GetNum() do
			local TempAppearanceItem = self.AppearanceListAdapter:GetItemDataByIndex(i)
			if TempAppearanceItem and TempAppearanceItem.ID == PartViewSuitID then
				--self.AppearanceListAdapter:ScrollToIndex(i)
				--计算当前行第一个的index，这样就不会越界了
				self.AppearanceListAdapter:CancelSelected()
				self.AppearanceListAdapter:ScrollToIndex(math.floor((i - 1) / 3) * 3 + 1)
				self.AppearanceListAdapter:SetSelectedIndex(i)
				self.ShowTipsEnable = true
				return
			end
		end
	end

	self.AppearanceListAdapter:CancelSelected()
	self.AppearanceListAdapter:ScrollToIndex(1)

	self.ShowTipsEnable = true
end

function WardrobeMainPanelView:CheckMasterSlaveWeaponSameProf(AppID, PartID)
	--Todo 如果是副手，判断自己跟主手的职业是否相交。
	if PartID ~= ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND then
		return true
	end
	
	local CurProfID = self.CurWeaponProfID == nil and MajorUtil.GetMajorProfID() or self.CurWeaponProfID
	local EquipID = WardrobeUtil.GetIsSpecial(AppID) and WardrobeUtil.GetUnlockCostItemID(AppID) or WardrobeUtil.GetClosetCfgEquipIDByAppearanceID(AppID)
	local SlaveItemCfg = ItemCfg:FindCfgByKey(EquipID)
	if SlaveItemCfg ~= nil and #SlaveItemCfg.ProfLimit == 0 then
		return true
	end
	if SlaveItemCfg ~= nil then
		for _,  ProfID in ipairs(SlaveItemCfg.ProfLimit or {}) do
			if ProfID == CurProfID then
				return true
			end
		end
	end
	return false
end

function WardrobeMainPanelView:OnAppearanceListChanged(Index, ItemData, ItemView, bByClick)
	local AppID = ItemData.ID
    local IsUnlock = WardrobeMgr:GetIsUnlock(AppID)
    local IsSelected = ItemData.IsSelected
    local PartID = self.CurPartID


	-- 外观行为
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CLOSET_CLOTHING, true) then
		return
	end

    -- 更新UI状态
    self:UpdateUIState(AppID, IsSelected)
    
    -- 处理武器职业pose
    self:UpdateWeaponPose(AppID, IsSelected)


    -- 处理装备穿戴逻辑
	-- # TODO - 这里先简单处理下, 主副手武器不相同就不穿了
	local bSameProf =self:CheckMasterSlaveWeaponSameProf(AppID, PartID)
	if bSameProf then
		-- 特殊逻辑
		local IsSpec = ProfUtil.IsProductionProf(self.CurWeaponProfID) 
		if IsSpec then
			self.VM.BtnPoseChecked = false
			self:PoseStyleSwitch(false)
		end
    	self:HandleDressingLogic(AppID, PartID, IsUnlock, IsSelected, bByClick)
	-- else
	-- 	 -- 主副手武器职业不相同
	-- 	if PartID == EquipmentPartList.EQUIP_PART_MASTER_HAND or PartID == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
	-- 		MsgTipsUtil.ShowTipsByID(147035)
	-- 	end 
	end

	-- 处理提示信息
	self:HandleTips(AppID, PartID, IsUnlock, IsSelected, bSameProf)
    
end

--- 更新UI
function WardrobeMainPanelView:UpdateUIState(AppID, IsSelected)
    self.CurAppearanceID = IsSelected and AppID or nil
    self.VM.PanelNameVisible = IsSelected
	self.VM.BtnSuitVisible = false
	self.CurSuitID = nil
    if IsSelected then
        self:UpdateCurrentAppearanceBtnState(AppID)
        self.VM:UpdateCurrentAppearanceInfo(AppID)
		self.CurSuitID = self.VM:UpdateSuitBtnState(AppID)
    end
end

--- 更新手里拿着的武器的职业，调整pose
function WardrobeMainPanelView:UpdateWeaponPose(AppID, IsSelected)
    if self.CurPartID ~= WardrobeDefine.EquipmentTab[EquipmentPartList.EQUIP_PART_MASTER_HAND] then return end

    local ProfID = IsSelected and self:GetWeaponProfID(AppID) or MajorUtil.GetMajorProfID()
    self.Common_Render2D_UIBP:OnProfSwitch({ProfID = ProfID})
    self.CurWeaponProfID = ProfID
	self:ResetWeaponPreview()
	if not IsSelected then
		self:LoadGladiatorAndPaladinWeapon()
	end
    if IsSelected then
        self:LoadSpecialWeapons(AppID)
    end

	local IsSpec = ProfUtil.IsProductionProf(ProfID) 
	UIUtil.SetIsVisible(self.WardrobeOperateItem.BtnPose, not IsSpec, true)
end

function WardrobeMainPanelView:HandleTips(AppID, PartID, IsUnlock, IsSelected, IsSameProf)
	if not IsSelected then
		return
	end

	local EquipID = WardrobeUtil.GetWeaponEquipIDByAppearanceID(AppID)

	local bShowPartHideTips = false      --是否显示隐藏了头盔/武器的Tips
	local bShowConjoinedAppTips = false  --是否显示连体外观Tips

	local bShowSlaveHandTips = false      --是否展示副手不显示逻辑

	local CurWeaponProfID = self.CurWeaponProfID == nil and MajorUtil.GetMajorProfID() or self.CurWeaponProfID
	if IsSelected and PartID == EquipmentPartList.EQUIP_PART_SLAVE_HAND and IsSameProf and ProfUtil.IsProductionProf(CurWeaponProfID) then
		bShowSlaveHandTips = true
	end

	local PartHideTips = ""
	local ConjoinedAppTips = _G.LSTR(1080104)
	local CanPreviewTips = _G.LSTR(1080099)
	local CannotPreviewTips = _G.LSTR(1080024)

	-- 是否弹隐藏部分部位tips
	if PartID == EquipmentPartList.EQUIP_PART_MASTER_HAND or PartID == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
		bShowPartHideTips = not self.VM.BtnHandChecked 
		PartHideTips = _G.LSTR(1080103) -- 当前隐藏主手及副手外观
	elseif PartID == EquipmentPartList.EQUIP_PART_HEAD then
		bShowPartHideTips = not self.VM.BtnHatChecked
		PartHideTips = _G.LSTR(1080102) -- 当前隐藏头部外观
	end

	local ECfg = ClosetCfg:FindCfgByKey(AppID)
	if ECfg ~= nil then
		bShowConjoinedAppTips = ECfg.IsCover == 1
	end

	local CanEquiped, CanPreview
	local Reason	--这里要返回不可装备的具体原因EquipOrCanPreviewErrorType
	if IsUnlock then
		CanEquiped, Reason = WardrobeMgr:CanEquipedAppearanceByServerData(AppID)
		CanPreview = WardrobeMgr:CanPreviewAppearanceByServerData(AppID)
	else
		CanEquiped, Reason = WardrobeMgr:CanEquipedAppearanceByClientData(AppID)
		CanPreview = WardrobeMgr:CanPreviewAppearanceByClientData(AppID)
	end

	-- 分层提示判断逻辑
	if not self.ShowTipsEnable then
		return
	end
	
	--主副手不一致
	if not IsSameProf and (PartID == EquipmentPartList.EQUIP_PART_MASTER_HAND or PartID == EquipmentPartList.EQUIP_PART_SLAVE_HAND)then
		MsgTipsUtil.ShowTipsByID(147035)
		return
	end

	if CanEquiped then
	    -- 可装备时的提示优先级：隐藏提示 > 连体外观提示
	    if bShowPartHideTips then
	        MsgTipsUtil.ShowTips(PartHideTips)
	    elseif bShowConjoinedAppTips then
	        MsgTipsUtil.ShowTips(ConjoinedAppTips)
		elseif bShowSlaveHandTips then
			MsgTipsUtil.ShowTips(_G.LSTR(1080129))
	    end
	else
	    -- 不可装备时的提示逻辑
	    if CanPreview then
	        -- 可预览时的提示优先级：隐藏提示 > 连体外观提示 > 常规预览提示
	        if bShowPartHideTips then
	            MsgTipsUtil.ShowTips(PartHideTips)
	        elseif bShowConjoinedAppTips then
	            MsgTipsUtil.ShowTips(ConjoinedAppTips)
	        else
				-- local TipsID = WardrobeDefine.EquipOrCanPreviewErrorTips[Reason]
				-- if TipsID then
				-- 	MsgTipsUtil.ShowTips(_G.LSTR(TipsID))
				-- end
				if bShowSlaveHandTips then
					MsgTipsUtil.ShowTips(_G.LSTR(1080129))
				else
					MsgTipsUtil.ShowTips(CanPreviewTips)
				end
	        end
	    else
	        -- 不可预览时的提示优先级：隐藏提示 > 连体外观提示 > 不可预览提示
	        if bShowPartHideTips then
	            MsgTipsUtil.ShowTips(PartHideTips)
	        elseif bShowConjoinedAppTips then
	            MsgTipsUtil.ShowTips(ConjoinedAppTips)
	        else
	            MsgTipsUtil.ShowTips(CannotPreviewTips)
	        end
	    end
	end
end

function WardrobeMainPanelView:HandleDressingLogic(AppID, PartID, IsUnlock, IsSelected, bByClick)
	local CanEquiped = false
	local CanPreview = false
	if IsUnlock then
		CanEquiped =  WardrobeMgr:CanEquipedAppearanceByServerData(AppID)
		CanPreview = WardrobeMgr:CanPreviewAppearanceByServerData(AppID)
	else
		CanEquiped = WardrobeMgr:CanEquipedAppearanceByClientData(AppID)
		CanPreview = WardrobeMgr:CanPreviewAppearanceByClientData(AppID)
	end

	local CurAppearanceIDList = WardrobeMgr:GetCurAppearanceList()
	-- local PartViewSuitID = WardrobeMgr:GetClothingViewSuit(PartID)

	if CanEquiped then
		if IsSelected then
			if not IsUnlock or (CurAppearanceIDList[PartID] and CurAppearanceIDList[PartID].Avatar == AppID) then
				self:WearAppearance(AppID, PartID, true)
				return
			end
			if IsUnlock then
				self:WearAppearance(AppID, PartID, true)
				WardrobeMgr:SendClosetClothingReq(AppID, PartID)
			end
		else
			if WardrobeMgr:GetIsClothing(AppID, PartID) and not self.IsFirstSelect then
				if not self.NoUnclothing and bByClick ~= nil then
					WardrobeMgr:SendClosetUnClothingReq(PartID)
				end
				self.NoUnclothing = false
			else
				if bByClick ~= nil then
					self:WearAppearance(AppID, PartID, false)
				end
			end
		end
	elseif CanPreview then
		self:WearAppearance(AppID, PartID, IsSelected)
	end
end

function WardrobeMainPanelView:GetWeaponProfID(AppID)
    local TempItemCfg = ItemCfg:FindCfgByKey(
        WardrobeUtil.GetWeaponEquipIDByAppearanceID(AppID)
    )
    return TempItemCfg and TempItemCfg.ProfLimit[1] or MajorUtil.GetMajorProfID()
end

-- 重置手上的状态
function WardrobeMainPanelView:ResetWeaponPreview()
    self.Common_Render2D_UIBP:PreViewEquipment(nil, EquipmentPartList.EQUIP_PART_MASTER_HAND, 0)
    self.Common_Render2D_UIBP:PreViewEquipment(nil, EquipmentPartList.EQUIP_PART_SLAVE_HAND, 0)
end

-- 处理特殊武器
function WardrobeMainPanelView:LoadSpecialWeapons(AppID)
    local EquipID = WardrobeUtil.GetWeaponEquipIDByAppearanceID(AppID) -- 新增
	--骑士/剑斗士
	self:LoadGladiatorAndPaladinWeapon()
	--格斗家/武僧
    self:LoadPugilistAndMonkWeapon(EquipID)
end

-- 更新当前外观的信息
function WardrobeMainPanelView:UpdateCurrentAppearanceBtnState(ApperanceID)
	local IsUnlock = WardrobeMgr:GetIsUnlock(ApperanceID)
	local DyeEnable = WardrobeMgr:GetDyeEnable(ApperanceID)

	self.BtnCollect:SetChecked(WardrobeMgr:GetIsFavorite(ApperanceID))
	self.VM:UpdateUnlockBtnTextState(ApperanceID)
	self.VM:UpdateTryStainState(ApperanceID)
	self.VM:UpdateReduceCondState(ApperanceID)

	-- 未解锁
	if not IsUnlock then
		if #WardrobeUtil.GetAchievementIDList(ApperanceID) > 0 then
			self.BtnUnlock1:SetIsDisabledState(true, true)
		else
			self.BtnUnlock1:SetIsRecommendState(true)
		end
	else
		-- 未解锁染色，不可染色 禁用态
		-- 可解锁染色，已解锁染色 推荐
		-- 染色不可用，无法预览时，禁用态，但是可以点击
		local CanPreview = WardrobeMgr:CanPreviewAppearanceByServerData(ApperanceID)
		if DyeEnable and CanPreview then
			self.BtnUnlock1:SetIsRecommendState(true)
		else
			self.BtnUnlock1:SetIsDisabledState(true, true)
		end

		if not CanPreview and not DyeEnable then
			self.BtnUnlock1:SetIsDisabledState(true, true)
		end
	end
end

------------------------------------------------- 创建模型相关 --------------------------------------
function WardrobeMainPanelView:CreateRenderActor()
	local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	local CameraParams = EquipmentCameraControlDataLoader:GetCameraControlParams(AttachType,
	CameraControlDefine.FocusType.WholeBody)
	self.Common_Render2D_UIBP:SetCameraControlParams(CameraParams)

	local CallBack = function()
		self.VignetteIntensityDefaultValue = self.Common_Render2D_UIBP:GetPostProcessVignetteIntensity()
		self.BackgroundActor = CommonUtil.SpawnActor(_G.ObjectMgr:GetClass(EquipmentBGPath),
			self.Common_Render2D_UIBP.RenderActor:K2_GetActorLocation())
		UIUtil.SetIsVisible(self.CommonBkg, false)
		self.Common_Render2D_UIBP:SwitchOtherLights(false)
        self.Common_Render2D_UIBP:ChangeUIState(false)
        self.Common_Render2D_UIBP:SetUICharacterByEntityID(MajorUtil.GetMajorEntityID())
		self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
		self.Common_Render2D_UIBP:InitSpringArmEndPos()
		self.Common_Render2D_UIBP.bAutoInitSpringArm = false
		self.Common_Render2D_UIBP:EnableZoom(true)
		self.Common_Render2D_UIBP.DefaultIsCanZoom = true
		self.CreateRenderActorIsOver = true
		self.IsCreatedActor = true
		self.bReadyToInitCamera = true

		self:CreateRenderActorCallback()
	end

	local ReCreateCallBack = function()
		_G.FLOG_INFO("WardrobeMainPanelView:CreateRenderActor ReCreateCallBack ")
	end

	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
	if AvatarComp ~= nil then
		local AttachType = AvatarComp:GetAttachTypeIgnoreChangeRole()
		local RenderActorPath = string.format(WardrobeDefine.RenderActorPath, AttachType, AttachType)
		local LightType = self:GetLightConfigType(AttachType)
		local PathList
		local SystemLightCfgItem = SystemLightCfg:FindCfgByKey(4)
		if SystemLightCfgItem ~= nil then
			PathList = SystemLightCfgItem.LightPresetPaths
		end
		--默认灯光预设
		local LightPath = "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_Equipment/Equipment_c0101.Equipment_c0101'"
		if PathList and next(PathList) then
			LightPath = PathList[WardrobeDefine.LightConfig[LightType]]
		else
			_G.FLOG_INFO("WardrobeMainPanel LightPreset Init Faild")
		end
		-- local LightConfigPath = (AttachType ~= "c0901" and AttachType ~= "c1101") and string.format(WardrobeDefine.LightConfig, "c0101", "c0101") or string.format(WardrobeDefine.LightConfig, AttachType, AttachType) 

		if self.Common_Render2D_UIBP then
			self.Common_Render2D_UIBP:CreateRenderActor(RenderActorPath, _G.EquipmentMgr:GetEquipmentCharacterClass(), LightPath,
														false, CallBack, ReCreateCallBack)
		end
	end
end

--- 创建模型完成回调
function WardrobeMainPanelView:CreateRenderActorCallback()
	if self.VM == nil then
		return
	end
	self.Common_Render2D_UIBP:HideHead(not self.VM.BtnHatChecked)
	self:InitBtnHatStyleState()
	self:PoseStyleSwitch(self.VM.BtnPoseChecked)
	local Character = self.Common_Render2D_UIBP:GetUIComplexCharacter()
	if Character then
		Character:ClearDelegateHandle()
	end
end

function WardrobeMainPanelView:GetLightConfigType(Type)
	return "e_c0101"
end

-- 监听模型组件组装完成事件
function WardrobeMainPanelView:OnAssembleAllEnd(Params)
	if (self.Common_Render2D_UIBP == nil) then return end
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	if (ChildActor == nil) then return end
	local EntityID = Params.ULongParam1
	local ObjType = Params.IntParam1
	local AttrComp = ChildActor:GetAttributeComponent()
	if EntityID == AttrComp.EntityID and ObjType == AttrComp.ObjType then
		local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
		if UIComplexCharacter then
			UIComplexCharacter:GetAvatarComponent():SetForcedLODForAll(1)
		end
	 	self.Common_Render2D_UIBP:UpdateAllLights()
		UIUtil.SetIsVisible(self.CommonBkg, false)
		
		if self.bReadyToInitCamera then
			self.Common_Render2D_UIBP:UpdateFocusLocation(false)
			self:SetModelSpringArmToDefault(false)
			self.bReadyToInitCamera = false
			self:UpdateWeaponHideState()
			if self.CurViewPage == UIViewID.WardrobeUnlockPanel then
				self:ModelMoveToUnlockPanel(true)
			end
		end
		if self.VM.BtnHatStyleChecked and not self.VM.BtnHatStyleVisible then
			self.Common_Render2D_UIBP:SwitchHelmet(self.VM.BtnHatStyleChecked)
		end
	end
end

function WardrobeMainPanelView:SetModelSpringArmToDefault(bInterp)
	local DefaultSpringArmLength = nil
	if nil ~= self.Common_Render2D_UIBP.CamControlParams then
		DefaultSpringArmLength = self.Common_Render2D_UIBP.CamControlParams.DefaultViewDistance
	end
	
	self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-50, DefaultSpringArmLength)
	self.Common_Render2D_UIBP:EnableRotator(true)
	self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(nil, nil, nil, nil)
	self.Common_Render2D_UIBP:SetModelRotation(0, 0 , 0, true)
	self.Common_Render2D_UIBP:ResetViewDistance(bInterp)
	self.Common_Render2D_UIBP:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self.Common_Render2D_UIBP:EnableZoom(true)
	
	local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	local WeaponProfID = self.CurWeaponProfID == nil and MajorUtil.GetMajorProfID() or self.CurWeaponProfID
	local CameraParams = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, WeaponProfID, ProtoCommon.equip_part.EQUIP_PART_BODY)

	if CameraParams ~= nil then
		_G.FLOG_INFO(string.format("WardrobeMainPanelView:SetModelSpringArmToDefault Fov %s ", tostring(CameraParams.FOV)))
		self.Common_Render2D_UIBP:ResetViewDistance(bInterp)
	end
end

-- 展示全镜头
function WardrobeMainPanelView:ShowAllModel(bInterp)
	self:SetModelSpringArmToDefault(bInterp)
	self.ShowModelType = WardrobeDefine.ShowModelType.All
	self.VM.BtnCameraChecked = false
end

-- 展示对应部位镜头
function WardrobeMainPanelView:ShowModelFocusPart(Part)
	if type(Part) ~= 'number' then
		return
	end

	local CurProfID = self.CurWeaponProfID == nil and MajorUtil.GetMajorProfID() or self.CurWeaponProfID

	local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	if Part == EquipmentPartList.EQUIP_PART_MASTER_HAND or Part == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
		Part = 0
	end
	local CameraFocusCfg = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, CurProfID, Part)
	if CameraFocusCfg == nil then return end
	-- _G.FLOG_INFO(string.format("WardrobeMainPanelView:ShowModelFocusPart Fov %s ", tostring(CameraFocusCfg.FOV)))
	self.Common_Render2D_UIBP:SetCameraLockedFOV(CameraFocusCfg.FOV)
	-- self.Common_Render2D_UIBP:SetSpringArmDistance(CameraFocusCfg.Distance, false)
	local DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
	local ViewportSize = UIUtil.GetViewportSize() / DPIScale
	local UIX = ViewportSize.X / 2 + CameraFocusCfg.UIX 
	local UIY = ViewportSize.Y / 2 + CameraFocusCfg.UIY
	self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(UIX * DPIScale, UIY * DPIScale, CameraFocusCfg.SocketName,
	CameraFocusCfg.Distance)
	
	-- 角色模型
	self.Common_Render2D_UIBP:SetModelRotation(0, CameraFocusCfg.Yaw , 0, true)

	-- 输入限制
	self.Common_Render2D_UIBP:EnableZoom(false)
	self.Common_Render2D_UIBP:EnablePitch(false)
	self.Common_Render2D_UIBP:EnableRotator(false)
	self.Common_Render2D_UIBP:SetCameraFocusEndCallback(function() self.Common_Render2D_UIBP:EnableRotator(true) end)

	self.ShowModelType = WardrobeDefine.ShowModelType.Part
end

-- 移动镜头到左边(染色)
function WardrobeMainPanelView:ModelMoveToStainPanel()
	self.CurViewPage = UIViewID.WardrobeStainPanel
	local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()

	local Part = self.CurPartID
	if self.CurPart == EquipmentPartList.EQUIP_PART_MASTER_HAND or self.CurPart == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
		Part = 0
	end
	local CameraParams = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, self.CurWeaponProfID, Part)
	if CameraParams ~= nil then
		if not self.VM.BtnCameraChecked then
			CameraParams = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, self.CurWeaponProfID, 0)
			local Location = self.Common_Render2D_UIBP:GetSpringArmLocation()
			self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-50 + WardrobeDefine.StainPanelOffsetY, CameraParams.Distance)
			local CurViewDist = self.Common_Render2D_UIBP:NormalizeTargetArmLength(self.Common_Render2D_UIBP:GetSpringArmDistance() - self.Common_Render2D_UIBP.ZoomScale * 60)
			self.Common_Render2D_UIBP:SetSpringArmLocation(Location.X, self.Common_Render2D_UIBP.CamToTargetRadians * CurViewDist, Location.Z, true)
		else
			local Location = self.Common_Render2D_UIBP:GetSpringArmLocation()
			self.Common_Render2D_UIBP:SetSpringArmLocation(Location.X, Location.Y + WardrobeDefine.StainPanelOffsetY, Location.Z, true)
			self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-50 + WardrobeDefine.StainPanelOffsetY, CameraParams.Distance)
		end
	end
	self.Common_Render2D_UIBP:EnableZoom(not self.VM.BtnCameraChecked)
end

function WardrobeMainPanelView:ModelStainPanelMoveToMainPanel(PartID)
	self.CurViewPage = UIViewID.WardrobeMainPanel
	local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	local Part = PartID
	if PartID == EquipmentPartList.EQUIP_PART_MASTER_HAND or PartID == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
		Part = 0
	end
	local CameraParams = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, self.CurWeaponProfID, Part)
	if CameraParams ~= nil then
		if not self.VM.BtnCameraChecked then
			CameraParams = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, self.CurWeaponProfID, 0)
			local Location = self.Common_Render2D_UIBP:GetSpringArmLocation()
			self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-50, CameraParams.Distance)
			self.Common_Render2D_UIBP.SpringArmLocationTarget = nil
			local CurViewDist = self.Common_Render2D_UIBP:NormalizeTargetArmLength(self.Common_Render2D_UIBP:GetSpringArmDistance() - self.Common_Render2D_UIBP.ZoomScale * 60)
			self.Common_Render2D_UIBP:SetSpringArmLocation(Location.X, self.Common_Render2D_UIBP.CamToTargetRadians * CurViewDist, Location.Z, true)
		else
			local Location = self.Common_Render2D_UIBP:GetSpringArmLocation()
			self.Common_Render2D_UIBP:SetSpringArmLocation(Location.X, Location.Y - WardrobeDefine.StainPanelOffsetY, Location.Z, true)
			self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-50, CameraParams.Distance)
		end
	end
	self.Common_Render2D_UIBP:EnableZoom(not self.VM.BtnCameraChecked)
end

-- 移动镜头到左边（解锁）
function WardrobeMainPanelView:ModelMoveToUnlockPanel(bDelay)
	self.CurViewPage = UIViewID.WardrobeUnlockPanel
	self:SetModelSpringArmToDefault(false)
	self.VM.BtnCameraChecked = false
	self.WardrobeOperateItem.BtnCamera:SetChecked(self.VM.BtnCameraChecked, false)
	local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	local CameraParams = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, self.CurWeaponProfID, ProtoCommon.equip_part.EQUIP_PART_BODY)
	if CameraParams ~= nil then
		local Location = self.Common_Render2D_UIBP:GetSpringArmLocation()
		self.Common_Render2D_UIBP:SetSpringArmLocation(Location.X, Location.Y + WardrobeDefine.UnlockPanelOffsetY, Location.Z, true)
		self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-60 +  WardrobeDefine.UnlockPanelOffsetY, CameraParams.Distance)
	end
	self.Common_Render2D_UIBP:EnableZoom(true)
end

function WardrobeMainPanelView:ModelMoveToPresetPanel()
	self.CurViewPage = UIViewID.WardrobePresetsPanel
	self:SetModelSpringArmToDefault(false)
	self.VM.BtnCameraChecked = false
	self.WardrobeOperateItem.BtnCamera:SetChecked(self.VM.BtnCameraChecked, false)
	local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	local CameraParams = self.CameraFocusCfgMap:GetCfgByRaceAndProf(AttachType, self.CurWeaponProfID, ProtoCommon.equip_part.EQUIP_PART_BODY)
	if CameraParams ~= nil then
		local Location = self.Common_Render2D_UIBP:GetSpringArmLocation()
		self.Common_Render2D_UIBP:SetSpringArmLocation(Location.X, Location.Y + WardrobeDefine.PresetPanelOffsetY, Location.Z, true)
		self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(-60 +  WardrobeDefine.UnlockPanelOffsetY, CameraParams.Distance)
	end
	self.Common_Render2D_UIBP:EnableZoom(true)
end

-- 穿戴外观
function WardrobeMainPanelView:WearAppearance(AppID, PartID, IsSelected)
	local EquipList = EquipmentVM.ItemList

	if IsSelected then
		self:PreviewAppearance(PartID, AppID)
		return
	end
	local IsPreview = true
	if PartID == EquipmentPartList.EQUIP_PART_HEAD then
		IsPreview = self.VM.BtnHatChecked
	elseif PartID == EquipmentPartList.EQUIP_PART_MASTER_HAND or PartID == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
		IsPreview = self.VM.BtnHandChecked
	end
	for _, part in pairs(WardrobeDefine.EquipmentTab) do
		if PartID == tonumber(part) then
			local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(PartID)
			if CurrentAppID ~= 0 then
				local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
				local ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
				local RegionDyes = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
				local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(CurrentAppID)
				-- 多区域染色逻辑
				self.Common_Render2D_UIBP:PreViewEquipment(IsPreview and EquipID or nil, PartID,  IsAppRegionDye and 0 or ColorID)
				self:StainPartForSection(CurrentAppID, tonumber(part), RegionDyes)
				WardrobeMgr:SetViewSuit(PartID, CurrentAppID, ColorID, RegionDyes)
				break
			else
				local TempEquip = EquipList[part]
				if TempEquip ~= nil then
					local EquipID = TempEquip.ResID
					self.Common_Render2D_UIBP:PreViewEquipment(IsPreview and EquipID or nil, PartID, 0)
					WardrobeMgr:SetViewSuit(PartID, nil, 0, {})
					break
				else
					_G.FLOG_INFO("身上没有穿着装备, 装备脱下")
					self.Common_Render2D_UIBP:PreViewEquipment(nil, PartID, 0)
					WardrobeMgr:SetViewSuit(PartID, nil, 0, {})
					break
				end
			end
		end
	end
end

-- 预览装备
function WardrobeMainPanelView:PreviewAppearance(PartID, AppID)
	local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(AppID)
	local IsClothing = WardrobeMgr:GetIsClothing(AppID)
	local Color = IsClothing and WardrobeMgr:GetCurAppearanceDyeColor(AppID) or WardrobeMgr:GetDyeColor(AppID) 
	local Item = {}
	Item.EquipID = WardrobeMgr:IsRandomAppID(AppID) and WardrobeMgr:GetEquipIDByRandomApp(AppID) or EquipID
	Item.AppID = AppID
	Item.ColorID = Color
	Item.PartID = PartID
	Item.RegionDye = IsClothing and WardrobeMgr:GetCurAppearanceRegionDyes(AppID) or WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID)
	WardrobeMgr:SetViewSuit(PartID, AppID, Color, Item.RegionDye)
	self:RenderPreviewEquipmentList({Item})
	-- 检查头部是否能穿戴
	if PartID == EquipmentPartList.EQUIP_PART_HEAD then
		self:CheckedBtnStyleCheckedState(AppID)
	end
end

function WardrobeMainPanelView:RenderPreviewEquipmentList(Items)
	for i = 1, #Items do
		if Items[i] ~= nil and Items[i] ~= 0 then
			local AppID = Items[i].AppID
			local Color = Items[i].ColorID or 0
			local PartID = Items[i].PartID
			local EquipID = Items[i].EquipID
			local RegionDye = Items[i].RegionDye
			local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)
			if PartID == EquipmentPartList.EQUIP_PART_HEAD then
				if self.VM ~= nil and self.VM.BtnHatChecked ~= nil then
					if self.VM.BtnHatChecked then
						self.Common_Render2D_UIBP:PreViewEquipment(EquipID, PartID, IsAppRegionDye and 0 or Color)
						self:StainPartForSection(AppID, PartID, RegionDye)
					else
						self.Common_Render2D_UIBP:PreViewEquipment(nil, PartID, 0)
					end
				end
			elseif PartID == EquipmentPartList.EQUIP_PART_SLAVE_HAND or PartID == EquipmentPartList.EQUIP_PART_MASTER_HAND then
				if self.VM ~= nil and self.VM.BtnHandChecked ~= nil then
					if self.VM.BtnHandChecked or self.VM.BtnPoseChecked then
						self.Common_Render2D_UIBP:PreViewEquipment(EquipID, PartID, IsAppRegionDye and 0 or Color)
						--Todo 区域染色逻辑
						self:StainPartForSection(AppID, PartID, RegionDye)
					else
						self.Common_Render2D_UIBP:PreViewEquipment(nil, PartID, 0)
					end
				end
			else
				self.Common_Render2D_UIBP:PreViewEquipment(EquipID, PartID, IsAppRegionDye and 0 or Color)
				self:StainPartForSection(AppID, PartID, RegionDye)
			end
		end
	end
end

function WardrobeMainPanelView:CheckedBtnStyleCheckedState(AppID)
	if _G.EquipmentMgr:IsEquipHasGimmick(WardrobeUtil.GetEquipIDByAppearanceID(AppID)) then
		self.VM.BtnHatStyleVisible = true
		self.Common_Render2D_UIBP:SwitchHelmet(self.VM.BtnHatStyleChecked)
	else
		self.VM.BtnHatStyleVisible = false
	end
end

function WardrobeMainPanelView:LoadGladiatorAndPaladinWeapon()
	local CurProfID = self.CurWeaponProfID
	local EquipList = EquipmentVM.ItemList
	if CurProfID == ProtoCommon.prof_type.PROF_TYPE_GLADIATOR or CurProfID == ProtoCommon.prof_type.PROF_TYPE_PALADIN then
		self.Common_Render2D_UIBP:PreViewEquipment(nil, EquipmentPartList.EQUIP_PART_MASTER_HAND, 0)
		self.Common_Render2D_UIBP:PreViewEquipment(nil, EquipmentPartList.EQUIP_PART_SLAVE_HAND, 0)

		for _, part in pairs(WardrobeDefine.EquipmentTab) do
			if part == EquipmentPartList.EQUIP_PART_MASTER_HAND or part == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
				local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(part)
				if CurrentAppID ~= 0 then
					local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
					local ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
					local RegionDye = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
					local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(CurrentAppID)
					self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, IsAppRegionDye and 0 or ColorID)
					self:StainPartForSection(CurrentAppID, tonumber(part), RegionDye)
				else
					local TempEquip = EquipList[part]
					if TempEquip ~= nil then
						local EquipID = TempEquip.ResID
						self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, 0)
					else
						self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
					end
				end
			end
		end
	end
end

function WardrobeMainPanelView:LoadPugilistAndMonkWeapon(EquipID)
	local CurProfID = self.CurWeaponProfID
	local EquipList = EquipmentVM.ItemList
	if CurProfID == ProtoCommon.prof_type.PROF_TYPE_PUGILIST or CurProfID == ProtoCommon.prof_type.PROF_TYPE_MONK then
		for _, part in pairs(WardrobeDefine.EquipmentTab) do
			if part == EquipmentPartList.EQUIP_PART_MASTER_HAND or part == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
				self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, 0)
			end
		end
	end
end

----------------------------------- 点击事件 -----------------------------------
--- 点击通用筛选
function WardrobeMainPanelView:OnClickedBtnScreener(ToggleButton, State)
	UIViewMgr:ShowView(UIViewID.ScreenerWin,	
	{RelatedSystem = ProtoRes.ScreenerRelatedSystem.WARDROBE_SYSTEM, 
	SystemRelatedValue = 2,
	ScreenerSelectedInfo = self.ScreenerSelectedInfo})
	self:RefreshScreenerChecked()
	self:ResetDropDownList()
end

--- 刷新筛选按钮状态
function WardrobeMainPanelView:RefreshScreenerChecked()
	if self.ScreenerSelectedInfo and next(self.ScreenerSelectedInfo) then
		self.BtnScreener:SetChecked(true)
	else
		self.BtnScreener:SetChecked(false)
	end
end

function WardrobeMainPanelView:OnScreenerAction(ScreenerResult)
	self.ScreenerSelectedInfo = ScreenerResult and ScreenerResult.ScreenerList or {}
	self:RefreshScreenerChecked()
	self:ResetDropDownList()
	-- 没有选择任何筛选项目
	if ScreenerResult == nil then
		---根据当前的刷新
		self.BtnScreener:SetChecked(false, true)
		self.VM:UpdateAppearanceList(self.CurPartID, self.CurPartSubName, self:GetFilterProfListIndex(self.CurDropDownIndex))
	else
		self.BtnScreener:SetChecked(true, false)
		self.IsFiltering = true
		self.VM:UpdateAppearanceList(self.CurPartID, self.CurPartSubName, self:GetFilterProfListIndex(self.CurDropDownIndex), ScreenerResult and ScreenerResult.ScreenerList or {})
	end
	self:SelectClothingViewSuit(self.CurPartID)
end

-- 点击显示/隐藏武器
function WardrobeMainPanelView:OnClickedBtnHand(ToggleButton, State)
	local LocalTime  = TimeUtil.GetLocalTime()
	if LocalTime - self.LastHandBtnTime < 2 and self.LastHandBtnTime ~= 0  then
		self.WardrobeOperateItem.BtnHand:SetChecked(self.VM.BtnHandChecked, false)
		return false
	end
	self.LastHandBtnTime = LocalTime
	local IsShow = State == _G.UE.EToggleButtonState.Checked

	self:WeaponVisibleSwitch(IsShow)
	-- self:ShowWeaopenTips(IsShow)

	-- 切换回来的时候更新武器
	if self.VM.BtnHandChecked then
		if self.Common_Render2D_UIBP ~= nil then
			local ViewSuit = WardrobeMgr:GetViewSuit()
			local HasEquipWeaponViewSuit = false
			for key, v in pairs(ViewSuit) do
				if key == EquipmentPartList.EQUIP_PART_MASTER_HAND or key == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
					HasEquipWeaponViewSuit = true
					local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(v.Avatar)
					local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(v.Avatar)
					self.Common_Render2D_UIBP:PreViewEquipment(EquipID, key, IsAppRegionDye and 0 or v.Color)
					-- Todo 区域染色逻辑
					self:StainPartForSection(v.Avatar, tonumber(key), v.RegionDye)
				end
			end

			if not HasEquipWeaponViewSuit then
				local EquipList = EquipmentVM.ItemList
				for _, part in pairs(WardrobeDefine.EquipmentTab) do
					if EquipmentPartList.EQUIP_PART_MASTER_HAND == part or EquipmentPartList.EQUIP_PART_MASTER_HAND == part then
						-- 判断当前装备
						local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(part)
						if CurrentAppID ~= 0 then
							local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
							local ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
							local RegionDye = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
							local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(CurrentAppID)
							self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, IsAppRegionDye and 0 or ColorID)
							--Todo 区域染色逻辑
							self:StainPartForSection(CurrentAppID, tonumber(part), RegionDye)
						else
							local TempEquip = EquipList[part]
							if TempEquip ~= nil then
								local EquipID = TempEquip.ResID
								self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, 0)
							else
								self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
							end
						end
					end
				end
			end
		end
	end

	-- 更新一下Pose的状态
	if self.CurWeaponProfID then
		self.Common_Render2D_UIBP:OnProfSwitch({ProfID = self.CurWeaponProfID})
	else
		self.Common_Render2D_UIBP:OnProfSwitch({ProfID = MajorUtil.GetMajorProfID()})
	end

	return true
end

-- 点击显示/隐藏头部
function WardrobeMainPanelView:OnClickedBtnHat(ToggleButton, State)
	local LocalTime  = TimeUtil.GetLocalTime()
	if LocalTime - self.LastHatBtnTime < 2 and self.LastHatBtnTime ~= 0  then
		self.WardrobeOperateItem.BtnHat:SetChecked(self.VM.BtnHatChecked, false)
		return false
	end

	if not _G.EquipmentMgr:GetCanSwitchHatVisble() then
		return false
	end

	self.LastHatBtnTime = LocalTime

	local IsShow = State == _G.UE.EToggleButtonState.Checked
	self:HatVisibleSwitch(IsShow)
	-- self:ShowHatTips(IsShow)

	if self.VM.BtnHatChecked then
		if self.Common_Render2D_UIBP ~= nil then
			local ViewSuit = WardrobeMgr:GetViewSuit()
			local HasEquipHeadViewSuit = false
			for key, v in pairs(ViewSuit) do
				if key == EquipmentPartList.EQUIP_PART_HEAD then
					HasEquipHeadViewSuit = true
					local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(v.Avatar)
					local RegionDye =  WardrobeMgr:GetCurAppearanceRegionDyes(v.Avatar)
					local IsAppRegionDye =  WardrobeUtil.IsAppRegionDye(v.Avatar)
					self.Common_Render2D_UIBP:PreViewEquipment(EquipID, key, IsAppRegionDye and 0 or v.Color)
					self:StainPartForSection(v.Avatar, tonumber(key), RegionDye)
				end
			end

			if not HasEquipHeadViewSuit then
				local EquipList = EquipmentVM.ItemList
				for _, part in ipairs(WardrobeDefine.EquipmentTab) do
					if EquipmentPartList.EQUIP_PART_HEAD == tonumber(part) then
						-- 判断当前装备
						local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(part)
						if CurrentAppID ~= 0 then
							local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
							local ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
							local RegionDyes = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
							local IsAppRegionDye =  WardrobeUtil.IsAppRegionDye(CurrentAppID)
							self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, IsAppRegionDye and 0 or ColorID)
							self:StainPartForSection(CurrentAppID, tonumber(part), RegionDyes)
						else
							local TempEquip = EquipList[part]
							if TempEquip ~= nil then
								local EquipID = TempEquip.ResID
								self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, 0)
							else
								self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
							end
						end
					end
				end
			end
		end
	end

	return true
end

-- 切换头部显隐状态
function WardrobeMainPanelView:HatVisibleSwitch(IsShow)
	self.VM:ShowHead(IsShow, true)
	self.Common_Render2D_UIBP:HideHead(not IsShow)
end

-- 展示显示/隐藏头部提示
function WardrobeMainPanelView:ShowHatTips(bShowHead)
	local OpenContent = (LSTR(1080027))
	local CloseContnet = (LSTR(1080028))
	local Text = bShowHead and OpenContent or CloseContnet
	_G.MsgTipsUtil.ShowTips(Text)
end

-- 点击打开/关闭头部机关
function WardrobeMainPanelView:OnClickedBtnHatStyle(ToggleButton, State)
	local LocalTime  = TimeUtil.GetLocalTime()
	if LocalTime - self.LastHatStyleBtnTime < 2 and self.LastHatStyleBtnTime ~= 0  then
		self.WardrobeOperateItem.BtnHatStyle:SetChecked(self.VM.BtnHatStyleChecked, false)
		return false
	end
	self.LastHatStyleBtnTime = LocalTime
	local IsShow = State == _G.UE.EToggleButtonState.Checked
	self:HatStyleSwitch(IsShow)
	-- self:ShowHatStyleTips(IsShow)
	return true
end

-- 切换打开/关闭头部机关
function WardrobeMainPanelView:HatStyleSwitch(bIsHelmetGimmickOn)
	self.Common_Render2D_UIBP:SwitchHelmet(bIsHelmetGimmickOn)
	self.VM.BtnHatStyleChecked = bIsHelmetGimmickOn
end

-- 展示切换头部机关提示
function WardrobeMainPanelView:ShowHatStyleTips(bShow)
	local OpenContent = (LSTR(1080030))
	local CloseContnet = (LSTR(1080031))
	local Text = bShow and OpenContent or CloseContnet
	_G.MsgTipsUtil.ShowTips(Text)
end

-- 点击切换战斗/待机姿势
function WardrobeMainPanelView:OnClickedBtnPose(ToggleButton, State)
	local LocalTime  = TimeUtil.GetLocalTime()
	if LocalTime - self.LastPoseBtnTime < 2 and self.LastPoseBtnTime ~= 0  then
		self.WardrobeOperateItem.BtnPose:SetChecked(self.VM.BtnPoseChecked, false)
		return false
	end

	self.LastPoseBtnTime = LocalTime
	local bShowPose = State == _G.UE.EToggleButtonState.Checked
	self:PoseStyleSwitch(bShowPose)
	-- self:ShowPoseStyleTips(bShowPose)

	if self.Common_Render2D_UIBP.ChildActor then
		local UIComplexCharacter = self.Common_Render2D_UIBP.ChildActor:Cast(_G.UE.AUIComplexCharacter)
		if UIComplexCharacter then
			if self.VM.BtnPoseChecked then
				-- 进入战斗姿势时的特效
				local AvatarCom = UIComplexCharacter:GetAvatarComponent()
				if AvatarCom then
					AvatarCom:PlayEffect(ProtoRes.EquipmentType.WEAPON_MASTER_HAND, true, false)
					AvatarCom:PlayEffect(ProtoRes.EquipmentType.WEAPON_SLAVE_HAND, true, false)
				end
			end

			if not self.VM.BtnPoseChecked then
				-- 退出战斗姿势时的特效
				local AvatarCom = UIComplexCharacter:GetAvatarComponent()
				if AvatarCom then
					AvatarCom:BreakEffect(ProtoRes.EquipmentType.WEAPON_MASTER_HAND)
					AvatarCom:BreakEffect(ProtoRes.EquipmentType.WEAPON_SLAVE_HAND)
				end
			end
		end
	end
	return true
end

-- 切换战斗/待机姿势
function WardrobeMainPanelView:PoseStyleSwitch(bHoldOn)
	self.VM.BtnPoseChecked = bHoldOn
	self.Common_Render2D_UIBP:HoldOnWeapon(self.VM.BtnPoseChecked)
	self:UpdateWeaponHideState()
end

-- 展示战斗/待机姿势提示
function WardrobeMainPanelView:ShowPoseStyleTips(bHoldWeapon)
	local OpenContent = (LSTR(1080032))
	local CloseContnet = (LSTR(1080033))
	local Text = bHoldWeapon and OpenContent or CloseContnet
	_G.MsgTipsUtil.ShowTips(Text)
end

-- 切换武器显隐状态
function WardrobeMainPanelView:WeaponVisibleSwitch(bIsShowWeapon)
	self.VM:SetIsShowWeapon(bIsShowWeapon, true)
	self:UpdateWeaponHideState()
end

-- 判断是否隐藏主手武器，拔刀必定显示武器
-- 如果当前的生产职业预览副手，隐藏主手
function WardrobeMainPanelView:IsHideMasterHand()
	local bIsHideWeapon = not (self.VM.BtnHandChecked or self.VM.BtnPoseChecked)
	local WeaponProfID =  self.CurWeaponProfID == nil and MajorUtil.GetMajorProfID() or self.CurWeaponProfID
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(WeaponProfID) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local bIsPreviewSlaveHand = false
	return bIsHideWeapon or (bIsPreviewSlaveHand and bIsProductProf)
end

-- 判断是否隐藏副手武器，拔刀必定显示武器
-- 生产职业非预览副手状态隐藏副手
function WardrobeMainPanelView:IsHideSlaveHand()
	local bIsHideWeapon = not (self.VM.BtnHandChecked or self.VM.BtnPoseChecked)
	local WeaponProfID =  self.CurWeaponProfID == nil and MajorUtil.GetMajorProfID() or self.CurWeaponProfID
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(WeaponProfID) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local bIsPreviewSlaveHand = false
	return bIsHideWeapon or (bIsProductProf and not bIsPreviewSlaveHand)
end

-- 判断是否隐藏主手武器挂件，继承主手武器隐藏状态，但只有拔刀时才显示
function WardrobeMainPanelView:IsHideAttachMasterHand()
	return self:IsHideMasterHand() or self.VM.BtnPoseChecked
end

-- 判断是否隐藏副手武器挂件，继承副手武器隐藏状态，但只有拔刀时才显示
function WardrobeMainPanelView:IsHideAttachSlaveHand()
	return self:IsHideSlaveHand() or self.VM.BtnPoseChecked
end

-- 更新武器隐藏状态
function WardrobeMainPanelView:UpdateWeaponHideState()
	local bHideMasterHand = self:IsHideMasterHand()
	self.Common_Render2D_UIBP:HideWeapon(bHideMasterHand)
end

-- 点击切换镜头
function WardrobeMainPanelView:OnClickedBtnCamera(ToggleButton, State)
	local IsShow = State == _G.UE.EToggleButtonState.Checked
	self.VM.BtnCameraChecked = IsShow
	if IsShow then
		_G.FLOG_INFO(string.format("WardrobeMainPanelView 切换镜头到 %s", ProtoEnumAlias.GetAlias(ProtoCommon.equip_part, self.CurPartID)))
		self:ShowModelFocusPart(self.CurPartID)
	else
		_G.FLOG_INFO(string.format("WardrobeMainPanelView 切换全身镜头"))
		self:ShowAllModel(true)
	end
end


function WardrobeMainPanelView:OnClickedBtnSuit()
	if self.CurSuitID ~= nil then
		self.VM.BtnSuitSwitchChecked = true
		self:ShowAllModel(true)
		UIUtil.SetIsVisible(self.PanelContent, false)
		UIViewMgr:ShowView(UIViewID.WardrobeSuitPanel, {SuperView = self, SuitID = self.CurSuitID})
	end
end

-- 点击切换套装
function WardrobeMainPanelView:OnClickedBtnSwitch(ToggleButton, State)
	if UIUtil.IsToggleButtonChecked(State) then
		self.VM.BtnSuitSwitchChecked = true
		self:ShowAllModel(true)
		UIUtil.SetIsVisible(self.PanelContent, false)
		UIViewMgr:ShowView(UIViewID.WardrobeSuitPanel, {SuperView = self})
	end
end

function WardrobeMainPanelView:OnClickedBagSlotItemView1()
	if self.CurAppearanceID == nil then
		return
	end

	local ID =  WardrobeUtil.GetUnlockCostItemID(self.CurAppearanceID)
	local Item = ItemUtil.CreateItem(ID)
	Item.NeedBuyNum = _G.BagMgr:GetItemNum(ID) - WardrobeUtil.GetUnlockCostItemNum(ID)
	ItemTipsUtil.ShowTipsByItem(Item, self.BagSlot1,  _G.UE4.FVector2D(0, 0),  _G.UE4.FVector2D(1, 1))
end

function WardrobeMainPanelView:OnClickedBagSlotItemView2()
	local ID = self.CurAppearanceID
	if ID == nil then
		return
	end
	local Params = {}
	Params.Data = self.VM:UpdateSameEquipmentList(ID)
	Params.TargetView = self.BagSlot2
	Params.Offset = _G.UE4.FVector2D(-80, -15)
	Params.Alignment = _G.UE4.FVector2D(1, 1)
	UIViewMgr:ShowView(UIViewID.WardrobeTips, Params)
end

function WardrobeMainPanelView:OnClickedBtnInfo2()
	if self.CurAppearanceID == nil then
		return
	end

	local ID = self.CurAppearanceID
	local Data = WardrobeMgr:GetUnlockAppearanceDataByID(ID)
	local ProfLimit = WardrobeMgr:GetProfLimit(Data)
	local ClassLimit = WardrobeMgr:GetClassLimits(Data)
	local Content = WardrobeUtil.GetDetailProfCondText(ProfLimit, ClassLimit)
	TipsUtil.ShowInfoTips(Content, self.WardrobeJob.BtnInfo2, _G.UE.FVector2D(-20, 0),  _G.UE.FVector2D(1, 1))
end


function WardrobeMainPanelView:OnClickedBagSlotItemView3()
	local ID = self.CurAppearanceID
	if ID == nil then
		return
	end
	local Params = {}
	Params.Data = self.VM:UpdateSameEquipmentList(ID)
	Params.TargetView = self.BtnInfo3
	Params.Offset = _G.UE4.FVector2D(10, 0)
	Params.Alignment = _G.UE4.FVector2D(0, 0)
	UIViewMgr:ShowView(UIViewID.WardrobeTips, Params)
end

-- 点击搜索
function WardrobeMainPanelView:OnClickedBtnSearch()
	self.VM.IsSearching = true
	local PartID = self.CurPartID
	self.ScreenerSelectedInfo = {}
	self:RefreshScreenerChecked()
	self:ResetDropDownList()
	self.AppearanceListAdapter:CancelSelected()
	self.SearchBar:SetHintText(string.format(LSTR(1080036), ProtoEnumAlias.GetAlias(ProtoCommon.equip_part, PartID)))
end

-- 监听取消搜索事件
function WardrobeMainPanelView:OnClickCancelSearchBar()
	self.VM.IsSearching = false
	self.SearchBar:SetText("")

	local AppearanceListAdapter = self.AppearanceListAdapter
	local SelectedData = AppearanceListAdapter:GetSelectedItemData()
	local TargetDropDownIndex = nil
	if SelectedData then
		TargetDropDownIndex = WardrobeUtil.GetFirstDropDownIndexByItemData(
			SelectedData, self.DropDownDataList, self.VM.GetDataByFilterIndex, self.CurDropDownIndex)
	end

	self:ResetDropDownList()
	self.SearchBar:SetText("")
	if TargetDropDownIndex then
		self.DropDownList:SetDropDownIndex(TargetDropDownIndex)
	end
	self.VM:UpdateAppearanceList(self.CurPartID, _G.LSTR(1080037), self:GetFilterProfListIndex(self.CurDropDownIndex), self.ScreenerSelectedInfo)
	if self.AppearanceListAdapter:GetNum() > 0 then
		self:SelectClothingViewSuit(self.CurPartID)
	end
end

-- 监听搜索框输入变化
function WardrobeMainPanelView:OnChangeSearchBar(SearchText)
	if string.isnilorempty(SearchText) then  --搜索是否String是null或其值为Empty
		return
	end

	_G.JudgeSearchMgr:QueryTextIsLegal(SearchText, function( IsLegal )
		if not IsLegal then
			self.SearchBar:SetText("")
			return
		end

		if self.AppearanceSecTabListAdapter:GetSelectedIndex() ~= 1 then
			self.NeededChangeSearch = false
			self.AppearanceSecTabListAdapter:SetSelectedIndex(1)
			self.AppearanceSecTabListAdapter:ScrollToIndex(1)
			self.NeededChangeSearch = true
		end
	
		self.VM:SearchEquipmentList(self.CurPartID, self.CurPartSubName, SearchText)

	end)
end

-- 点击职业外观收集界面
function WardrobeMainPanelView:OnClickedBtnCollect2()
	local BtnSize = UIUtil.GetLocalSize(self.BtnCollect2)
	local Params = {}
	Params.TargetView = self.BtnCollect2
	Params.Offset = _G.UE4.FVector2D(-25, BtnSize.Y)
	Params.Alignment = _G.UE4.FVector2D(1, 0)
	UIViewMgr:ShowView(UIViewID.WardrobeProfAppListWin, Params)
end

-- 点击收集奖励界面
function WardrobeMainPanelView:OnClickedBtnBox()
	local function OnGetAwardCallBack(Index, ItemData, ItemView)
        if ItemData then
			if ItemData.IsGetProgress then
			WardrobeMgr:SendClosetCharismRewardReq(Index)	
			end
        end
    end

	local LevelAwardInfoList = ClosetCharismCfg:FindAllCfg()

	if LevelAwardInfoList == nil then
		return
	end


	local function OnClickedItem(Index, ItemData, ItemView)
		if ItemData ~= nil then
			ItemTipsUtil.ShowTipsByResID(ItemData.AwardID, ItemView)
		end
	end

	local Params = {
		ModuleID = nil,
		CollectedNum = WardrobeMgr:GetCharismNum(),
		MaxCollectNum = WardrobeMgr:GetCharismTotalNum(),
		AreaName = nil,
		OnGetAwardCallBack = OnGetAwardCallBack,
		TextCurrent = LSTR(1080111),     -- "外观收集进度"
		IgnoreIsGetProgress = true,
		ItemClickCallback = OnClickedItem,
	}

	local AwardInfoList, AwardSelectIndex = self:GetAwardInfo()

	Params.AwardList = AwardInfoList
	Params.AwardSelectIndex = AwardSelectIndex

    UIViewMgr:ShowView(UIViewID.CollectionAwardPanel, Params)
end

function WardrobeMainPanelView:GetAwardInfo()
	local LevelAwardInfoList = ClosetCharismCfg:FindAllCfg()
	
	if LevelAwardInfoList == nil then
		return
	end
	
	local AwardSelectIndex = 1
	local AwardInfoList = {}
	for index, v in ipairs(LevelAwardInfoList) do
		local Reward = v.Rewards
		local AwardInfo = {
			CollectTargetNum = v.Charism,
			AwardID = Reward[1].ResID,
			AwardNum = Reward[1].Num,
			IsGetProgress =  v.Charism <= WardrobeMgr:GetCharismNum() and  not (index <= WardrobeMgr:GetClaimedCharismReward()), -- 是否已达到奖励进度
			IsCollectedAward = index <= WardrobeMgr:GetClaimedCharismReward(), -- 是否已领奖
		}
		AwardSelectIndex = WardrobeMgr:GetClaimedCharismReward() + 1
		table.insert(AwardInfoList, AwardInfo)
	end

	return AwardInfoList, AwardSelectIndex
end

--- 点击一键解锁
function WardrobeMainPanelView:OnClickedBtnUnlock()
	local AppearanceList = WardrobeMgr:GetQuickUnlockAppearanceList()
	if #AppearanceList > 0 then
		self:ModelMoveToUnlockPanel()
		UIUtil.SetIsVisible(self.PanelContent, false)
		WardrobeMgr:SetPlanUnlockAppearanceList(AppearanceList)
		UIViewMgr:ShowView(UIViewID.WardrobeUnlockPanel, {AppearanceList = AppearanceList, IsQuickUnlock = true, SuperView = self})
	end
end

-- 点击预设
function WardrobeMainPanelView:OnClickedBtnPresets()
	UIUtil.SetIsVisible(self.PanelContent, false)
	self:ModelMoveToPresetPanel()
	UIViewMgr:ShowView(UIViewID.WardrobePresetsPanel, {SuperView = self})
end

function WardrobeMainPanelView:OnClickedBtnCharm()
	UIViewMgr:ShowView(UIViewID.WardrobeAppearancePanel)
end

-- 点击染色
function WardrobeMainPanelView:OnClickedBtnStain()
	if self.CurAppearanceID == nil then return end

	local ID = self.CurAppearanceID

	local DyeEnable = WardrobeUtil.GetAppearanceCanBeDyed(ID)
	local CanPreview = WardrobeMgr:CanPreviewAppearance(ID)

	local AppearanceList = {ID}

	if DyeEnable and CanPreview then
		UIUtil.SetIsVisible(self.PanelContent, false)
		self:ModelMoveToStainPanel()
		UIViewMgr:ShowView(UIViewID.WardrobeStainPanel, {AppearanceList = AppearanceList, StainType = WardrobeDefine.StainType.TryStain, SuperView = self})
	end
end

-- 点击收藏
function WardrobeMainPanelView:OnClickedBtnCollect(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)

	if self.CurAppearanceID == nil then
		return
	end
	
	local CurState = WardrobeMgr:GetIsFavorite(self.CurAppearanceID)
	if CurState ~= IsChecked then
		WardrobeMgr:SendClosetCollectReq(self.CurAppearanceID, IsChecked)
	end
end

-- 点击降低条件
function WardrobeMainPanelView:OnClickedBtnReduce()
	if self.CurAppearanceID == nil then
		return
	end

	--查找装备中可以降低条件的装备
	self:ModelMoveToUnlockPanel()
	UIUtil.SetIsVisible(self.PanelContent, false)
	local AppearanceList = WardrobeMgr:GetQuickUnlockAppearanceList()
	WardrobeMgr:SetPlanUnlockAppearanceList(AppearanceList)
	UIViewMgr:ShowView(UIViewID.WardrobeUnlockPanel, {AppearanceList = AppearanceList, SelectedAppID = self.CurAppearanceID, IsQuickUnlock = false, ReduceCondition = true,  SuperView = self})
end

--- 点击外观列表下的解锁/染色按钮
function WardrobeMainPanelView:OnClickSingleEquipmentBtnUnlock()
	if self.CurAppearanceID == nil then
		return
	end

	local ID = self.CurAppearanceID
	local IsUnlock = WardrobeMgr:GetIsUnlock(ID)
	local CanUnlock = WardrobeUtil.JudgeUnlockAppearanceWithouItem(ID)
	
	if not IsUnlock then
		if not CanUnlock then
			local IsSpecial = WardrobeUtil.GetIsSpecial(ID)
			local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(ID)
			local Offset =  _G.UE4.FVector2D(-80, -15)
			local Alignment =  _G.UE4.FVector2D(1, 1)
			if IsSpecial then
				local ViewModel =  self.VM:UpdateSameEquipmentList(ID)
				ViewModel.ResID = WardrobeUtil.GetUnlockCostItemID(ID)
				local Params = {ViewModel = ViewModel, nil, InTagetView = self.BagSlot2, Offset = Offset, Alignment = Alignment, HidePopUpBG = true, ParentViewID = _G.UIViewID.WardrobeMainPanelView}
				ItemTipsUtil.OnClickedToGetBtn(Params)
				return
			end
			local Params = {}
			Params.Data = self.VM:UpdateSameEquipmentList(ID)
			Params.TargetView = self.BagSlot2
			Params.Offset = Offset
			Params.Alignment = Alignment
			UIViewMgr:ShowView(UIViewID.WardrobeTips, Params)
			return
		end

		if #WardrobeUtil.GetAchievementIDList(self.CurAppearanceID) > 0 then
			MsgTipsUtil.ShowTips(LSTR(1080112)) --暂未满足解锁条件
			return
		end
		
		local AppearanceList = WardrobeMgr:GetQuickUnlockAppearanceList()
		self:ModelMoveToUnlockPanel()
		UIUtil.SetIsVisible(self.PanelContent, false)
		WardrobeMgr:SetPlanUnlockAppearanceList(AppearanceList)
		UIViewMgr:ShowView(UIViewID.WardrobeUnlockPanel, {AppearanceList = AppearanceList, SelectedAppID = ID, IsQuickUnlock = false, SuperView = self})
		return
	end



	--- 判断是否能否穿戴
	local CanEquiped = WardrobeMgr:CanEquipedAppearanceByServerData(ID)
	local CanPreview = WardrobeMgr:CanPreviewAppearanceByServerData(ID)
	local DyeEnable = WardrobeMgr:GetDyeEnable(ID)

	if not DyeEnable then
		return
	end


	if not CanPreview then
		MsgTipsUtil.ShowTips(LSTR(1080035))
		return
	end

	if CanEquiped and CanPreview then
		UIUtil.SetIsVisible(self.PanelContent, false)
		self:ModelMoveToStainPanel()
		local StainAppList  = {}				
		for _, v in pairs(WardrobeMgr:GetCurAppearanceList()) do		
			if v.Avatar ~= 0 then 	
				table.insert(StainAppList, v.Avatar)
			end	
		end		

		UIViewMgr:ShowView(UIViewID.WardrobeStainPanel, {AppearanceList = StainAppList, StainType = WardrobeDefine.StainType.Normal, AppearanceID = ID, SuperView = self})
		return
	end

	if not CanEquiped and CanPreview then
		UIUtil.SetIsVisible(self.PanelContent, false)
		self:ModelMoveToStainPanel()
		UIViewMgr:ShowView(UIViewID.WardrobeStainPanel, {AppearanceList = {self.CurAppearanceID}, StainType = WardrobeDefine.StainType.OnlyLook, SuperView = self})
	end
end

-- 回到主界面 
function WardrobeMainPanelView:ShowMainPanel(bResetCamera, Part)
	--重新更新模型
	self.CurViewPage = UIViewID.WardrobeMainPanel
	if not bResetCamera then
		self:ModelStainPanelMoveToMainPanel(Part)
	else
		self:SetModelSpringArmToDefault(true)
		self.BtnCamera:SetChecked(false, false)
	end
	self:UpdateModelEquipment()
	-- 更新一下Pose的状态
	if self.CurWeaponProfID then
		self.Common_Render2D_UIBP:OnProfSwitch({ProfID = self.CurWeaponProfID})
	else
		self.Common_Render2D_UIBP:OnProfSwitch({ProfID = MajorUtil.GetMajorProfID()})
	end

	--把主界面显示打开
	UIUtil.SetIsVisible(self.PanelContent, true)
end


function WardrobeMainPanelView:ResetSelected()
	if self.CurPartID == nil then
		return
	end
	self.NoUnclothing = true
	self.ShowTipsEnable = false
	local PartViewSuitID = WardrobeMgr:GetClothingViewSuit(self.CurPartID)
	if PartViewSuitID == nil then
		PartViewSuitID = self.CurAppearanceID 
	end
	if PartViewSuitID then
		for i = 1, self.AppearanceListAdapter:GetNum() do
			local TempAppearanceItem = self.AppearanceListAdapter:GetItemDataByIndex(i)
			if TempAppearanceItem and TempAppearanceItem.ID == PartViewSuitID then
				--self.AppearanceListAdapter:ScrollToIndex(i)
				--计算当前行第一个的index，这样就不会越界了
				self.AppearanceListAdapter:CancelSelected()
				self.AppearanceListAdapter:ScrollToIndex(math.floor((i - 1) / 3) * 3 + 1)
				self.AppearanceListAdapter:SetSelectedIndex(i)
				self.ShowTipsEnable = true
				return
			end
		end
	end
end

---  解锁外观
function WardrobeMainPanelView:OpenWardrobeUnlockPanel(AppID)
	local AppearanceList = WardrobeMgr:GetQuickUnlockAppearanceList()
	if #AppearanceList > 0 then
	self:ModelMoveToUnlockPanel(true)
	UIUtil.SetIsVisible(self.PanelContent, false)
	WardrobeMgr:SetPlanUnlockAppearanceList(AppearanceList)
	UIViewMgr:ShowView(UIViewID.WardrobeUnlockPanel, {AppearanceList = AppearanceList, SelectedAppID = AppID, IsQuickUnlock = false, SuperView = self})
	end
end

-- 从主界面到解锁，解锁可以预览，但不记录在viewsuit里。
-- 从主界面到染色，只有正常染色，才记录在在viewsuit里。
-- 从主界面到预设界面，把当前的viewsuit 展示在预设界面。
-- 当切换预设的时候，更新的是预设套装里的外观穿戴在当前的Avatar.EquipList里。
-- 当保存/使用的时候，把viewsuit里可以穿戴的外观数据发送给服务器。根据服务器发送下来的数据更新当前模型。
-- 如果没有保存/使用 退出的时候。还是viewsuit的数据。
--  viewsuit只保存预览部位的，套装下的外观也只是保存的部位
function WardrobeMainPanelView:UpdateModelEquipment()
	local ItemList = {}
	local Suit = WardrobeMgr:GetViewSuit()
	local CurCurrentSuit = WardrobeMgr:GetCurAppearanceList()
	local EquipList = EquipmentVM.ItemList

	for index, partID in pairs(WardrobeDefine.EquipmentTab) do
		if Suit[partID] ~= nil and Suit[partID].Avatar ~= 0 then
			local AppID = Suit[partID].Avatar
			local EquipID = WardrobeMgr:IsRandomAppID(AppID) and WardrobeMgr:GetEquipIDByRandomApp(AppID) or WardrobeUtil.GetEquipIDByAppearanceID(AppID)
			local ColorID =  Suit[partID].Color
			local RegionDye = {}
			if  WardrobeUtil.GetRegionDye ~= nil then
				RegionDye = WardrobeUtil.GetRegionDye(AppID, Suit[partID].RegionDye or {})
			end
			if CurCurrentSuit[partID] ~= nil and CurCurrentSuit[partID].Avatar == Suit[partID].Avatar and CurCurrentSuit[partID].Color ~= Suit[partID].Color then
				ColorID = CurCurrentSuit[partID].Color
			end
			table.insert(ItemList, {AppID = AppID, EquipID = EquipID, PartID = partID, ColorID = ColorID, RegionDye = RegionDye})
		else
			local HasEquip = false
			for part, value in pairs(EquipList) do
				if partID == part then
					HasEquip = true
					local TempEquip = value
					local EquipID = TempEquip.ResID
					local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(partID)
					local ColorID = 0
					local RegionDye = {}
					if CurrentAppID ~= 0 then
						EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
						ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
						local TempRegionDye = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
						RegionDye = WardrobeUtil.GetRegionDye(CurrentAppID, TempRegionDye)
					end
					table.insert(ItemList, {EquipID = EquipID, AppID = CurrentAppID,  PartID = partID, ColorID = ColorID,  RegionDye = RegionDye})
				end
			end

			if not HasEquip then
				table.insert(ItemList, {EquipID = nil, AppID = 0, PartID = partID, ColorID = 0, RegionDye = {}})
			end
		end

	end

	-- 如果有预览效果
	self:RenderPreviewEquipmentList(ItemList)
end

function WardrobeMainPanelView:StainPartForSection(AppID, PartID, RegionDyes)
	if AppID == nil then
		return
	end

	for _, v in ipairs(RegionDyes or {}) do
		local SectionList = WardrobeUtil.ParseSectionIDList(AppID, v.ID)
		for _, sectionID in ipairs(SectionList) do
			self.Common_Render2D_UIBP:StainPartForSection(WardrobeDefine.StainPartType[PartID], sectionID, v.ColorID)
		end
	end	
end


return WardrobeMainPanelView