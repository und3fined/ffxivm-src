--- Author: jamiyang
--- DateTime: 2023-08-07 10:39
--- Description: 此为坐骑图鉴的主界面
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local UIViewMgr = require("UI/UIViewMgr")
local EventID = require("Define/EventID")
local BgmCfg = require("TableCfg/BgmCfg")
local TipsUtil = require("Utils/TipsUtil")
local UIViewID = require("Define/UIViewID")
local RideCfg = require("TableCfg/RideCfg")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local BoardType = require("Define/BoardType")
local ProtoRes = require("Protocol/ProtoRes")
local CommonUtil = require("Utils/CommonUtil")
local MountVM = require("Game/Mount/VM/MountVM")
local RideSkillCfg = require("TableCfg/RideSkillCfg")
local DataReportUtil = require("Utils/DataReportUtil")
local SkillTipsMgr = require("Game/Skill/SkillTipsMgr")
local SystemLightCfg = require("TableCfg/SystemLightCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local CameraUtil = require("Game/Common/Camera/CameraUtil")
local MountDetailVM = require("Game/Mount/VM/MountDetailVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MountCustomMadeVM = require("Game/Mount/VM/MountCustomMadeVM")
local MountArchivePanelVM = require("Game/Mount/VM/MountArchivePanelVM")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local LSTR = _G.LSTR
local EventMgr = _G.EventMgr
local MountMgr = _G.MountMgr
local EquipmentMgr = _G.EquipmentMgr
local ModuleType = ProtoRes.module_type

---@class MountArchiveNewPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnChat UFButton
---@field BtnCustomMade UFButton
---@field BtnDescribeTipsBG UFButton
---@field BtnDetail UFButton
---@field BtnGo UFButton
---@field CommonTitle CommonTitleView
---@field Common_Render2D_UIBP CommonRender2DView
---@field DescribeTips MountDescribeTipsView
---@field DropDownListGetWay CommDropDownListView
---@field FButton_127 UFButton
---@field FSafeZone UFSafeZone
---@field GetWayTips MountArchiveGetWayTipsView
---@field HorizontalID UHorizontalBox
---@field HorizontalPeople UHorizontalBox
---@field ImgHide UFImage
---@field ImgMountType UFImage
---@field NewSearchBtn CommSearchBtnView
---@field PanelBtnBar UFVerticalBox
---@field PanelCustomMade UFCanvasPanel
---@field PanelFilter UFCanvasPanel
---@field PanelInforBar UFCanvasPanel
---@field PanelLeftEmpty UFCanvasPanel
---@field PanelMountDescribe UFCanvasPanel
---@field PanelNone UFCanvasPanel
---@field PanelSingleBox UFCanvasPanel
---@field RedDot CommonRedDotView
---@field RichTextNone URichTextBox
---@field SearchBar CommSearchBarView
---@field SearchBtn UFButton
---@field SingleBox CommSingleBoxView
---@field SkillActionBG UFButton
---@field TableViewAction UTableView
---@field TableViewGridList UTableView
---@field TextCustomMade UFTextBlock
---@field TextEmpty UFTextBlock
---@field TextGet UFTextBlock
---@field TextGetWay UFTextBlock
---@field TextGo UFTextBlock
---@field TextHowtogetit UFTextBlock
---@field TextID UFTextBlock
---@field TextMountName UFTextBlock
---@field TextNumber UFTextBlock
---@field TextRide UFTextBlock
---@field TextRideNumber UFTextBlock
---@field ToggleBtnBGM UToggleButton
---@field ToggleBtnMount UToggleButton
---@field AnimChangeSlot UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountArchiveNewPanelView = LuaClass(UIView, true)

function MountArchiveNewPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnChat = nil
	--self.BtnCustomMade = nil
	--self.BtnDescribeTipsBG = nil
	--self.BtnDetail = nil
	--self.BtnGo = nil
	--self.CommonTitle = nil
	--self.Common_Render2D_UIBP = nil
	--self.DescribeTips = nil
	--self.DropDownListGetWay = nil
	--self.FButton_127 = nil
	--self.FSafeZone = nil
	--self.GetWayTips = nil
	--self.HorizontalID = nil
	--self.HorizontalPeople = nil
	--self.ImgHide = nil
	--self.ImgMountType = nil
	--self.NewSearchBtn = nil
	--self.PanelBtnBar = nil
	--self.PanelCustomMade = nil
	--self.PanelFilter = nil
	--self.PanelInforBar = nil
	--self.PanelLeftEmpty = nil
	--self.PanelMountDescribe = nil
	--self.PanelNone = nil
	--self.PanelSingleBox = nil
	--self.RedDot = nil
	--self.RichTextNone = nil
	--self.SearchBar = nil
	--self.SearchBtn = nil
	--self.SingleBox = nil
	--self.SkillActionBG = nil
	--self.TableViewAction = nil
	--self.TableViewGridList = nil
	--self.TextCustomMade = nil
	--self.TextEmpty = nil
	--self.TextGet = nil
	--self.TextGetWay = nil
	--self.TextGo = nil
	--self.TextHowtogetit = nil
	--self.TextID = nil
	--self.TextMountName = nil
	--self.TextNumber = nil
	--self.TextRide = nil
	--self.TextRideNumber = nil
	--self.ToggleBtnBGM = nil
	--self.ToggleBtnMount = nil
	--self.AnimChangeSlot = nil
	--self.AnimIn = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountArchiveNewPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.Common_Render2D_UIBP)
	self:AddSubView(self.DescribeTips)
	self:AddSubView(self.DropDownListGetWay)
	self:AddSubView(self.GetWayTips)
	self:AddSubView(self.NewSearchBtn)
	self:AddSubView(self.RedDot)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountArchiveNewPanelView:OnInit()
	self.ZSMDHB = 1001	--滑板ID
	self.ViewModel = MountArchivePanelVM.New()
	self.DetailViewModel = MountDetailVM.New()
	self.MountTableGridView = UIAdapterTableView.CreateAdapter(self, self.TableViewGridList, self.OnMountTableViewSelectChange, false)
	self.MountTableGridView:SetScrollbarIsVisible(true)

	self.ActionTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewAction)

	self.SearchBar:SetCallback(self, self.ChangeCallback, self.OnSearchInputFinish);

	self.Common_Render2D_UIBP:SetClick(self, self.OnSingleClick, self.OnDoubleClick)

end

function MountArchiveNewPanelView:OnDestroy()

end

function MountArchiveNewPanelView:OnShow()
	_G.MountMgr:SetAssembleID(0)
	-- 清除筛选
	MountVM:RefreshFilterValue()
	--MountMgr:SendMountListQuery()
	self.ViewModel:GetAllMounts()
	self.ViewModel.RequestQueue = {}
	self.Common_Render2D_UIBP.bCreateShandowActor = true
	self.Common_Render2D_UIBP:SetShadowActorType(ActorUtil.ShadowType.Mount)
	self.Common_Render2D_UIBP:SetShadowActorPos(_G.UE.FVector(0, 0, 100000.0))
	self:ShowPlayerMountActor()
	local IsChecked = self.ViewModel.IsShowBGM
	self.ToggleBtnBGM:SetCheckedState(IsChecked and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.UnChecked, false)
	MountMgr:StopMountBGM()
	_G.LightMgr:EnableUIWeather(10)
	self.SearchBar:SetHintText(LSTR(1090027))
	local bShow = _G.LoginMgr:CheckModuleSwitchOn(ModuleType.MODULE_MOUNT_PREVIEW, true)
	UIUtil.SetIsVisible(self.FSafeZone, bShow)
	self:InitText()
	
	self.ViewModel:UpdateFilterItemList()

	if self.BtnChat then
		UIUtil.SetIsVisible(self.BtnChat, false)	--留言板暂不开放 策划让屏蔽掉
	end
	if self.TextHowtogetit then
		UIUtil.SetIsVisible(self.TextHowtogetit, false)
	end

	if self.HorizontalID then
		UIUtil.SetIsVisible(self.HorizontalID, false, false)
		if self.HorizontalPeople then
			--需求将坐骑的编号内容删除，乘坐人数等信息依次往上排
			self.HorizontalPeople:SetRenderTranslation(_G.UE.FVector2D(0,-40))
		end
	end
	_G.HUDMgr:SetIsDrawHUD(false)
end

function MountArchiveNewPanelView:InitText()
	self.TextGet:SetText(LSTR(1090029))
	self.RichTextNone:SetText(LSTR(1090030))
	self.TextCustomMade:SetText(LSTR(1090031))
	-- self.TextHowtogetit:SetText(LSTR(1090032))
	self.TextGo:SetText(LSTR(1090033))
	-- self.TextEmpty:SetText(LSTR(1090034))
	self.TextID:SetText(LSTR(1090035))
	self.TextRide:SetText(LSTR(1090036))
	if self.CommonTitle then
		self.CommonTitle.TextTitleName:SetText(LSTR(1090026))
	end
end

function MountArchiveNewPanelView:OnHide()
	self.Common_Render2D_UIBP:SwitchOtherLights(true)
	self.ViewModel.IsShowFilter = false
	self.ViewModel.IsSearch = false
	if self.PlayingID then
		_G.UE.UAudioMgr:Get():StopBGM(self.PlayingID)
		if MountMgr:IsInRide() then
			MountMgr:PlayMountBGM()
		end
		self.PlayingID = nil
	end
	_G.MountMgr:SetAssembleID(0)
	_G.LightMgr:DisableUIWeather(true)
	self.SearchBar:SetText("")
	--MountVM:ClearNew()
	self:OnSkillTipsBGClick()
	_G.HUDMgr:SetIsDrawHUD(true)
	self.ViewModel.RequestQueue = {}
end

function MountArchiveNewPanelView:OnActive()
	local SlotVM = self.ViewModel.ListSlotVM[self.ViewModel.SelectedMountIndex]
	if SlotVM == nil then
		return
	end
	local MountID = SlotVM.ResID
	local Mount = self.ViewModel.AllMountMp[MountID]
	if Mount == nil then
		return
	end
	if MountVM.MountMap[MountID] ~= nil then
		self:SetCustomMade(MountID, MountVM.MountMap[MountID].Facade)
	end
end

function MountArchiveNewPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, self.OnBackClick)
	UIUtil.AddOnClickedEvent(self, self.SearchBtn, self.OnSearch)
	UIUtil.AddOnClickedEvent(self, self.SearchBar.BtnCancel, self.OnClickedCloseSearch)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMount, self.OnShowPlayer)
	UIUtil.AddOnClickedEvent(self, self.BtnDetail, self.OnShowDetail)
	UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnShowBoard)
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnShowGetWay)
	UIUtil.AddOnClickedEvent(self, self.BtnDescribeTipsBG, self.OnClickDescribeBG)
	UIUtil.AddOnClickedEvent(self, self.BtnCustomMade, self.OnClickBtnCustomMade)
	UIUtil.AddOnClickedEvent(self, self.SkillActionBG, self.OnSkillTipsBGClick)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownListGetWay, self.OnSelectionChangedDropDownList)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnBGM, self.OnShowBGM)
	self.SingleBox:SetStateChangedCallback(self, self.OnSingleBoxClick)
end

function MountArchiveNewPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(EventID.MountRefreshList, self.OnMountListChange)
	self:RegisterGameEvent(EventID.MountFilterUpdate, self.OnMountFilterUpdate)
end

function MountArchiveNewPanelView:OnRegisterBinder()
	local Binders = {
		{ "ListSlotVM", UIBinderUpdateBindableList.New(self, self.MountTableGridView) },
		{ "GetWayFilterTypes", UIBinderValueChangedCallback.New(self, nil, self.OnGetWayFilterTypesChanged) },
		{ "IsShowSkillTips", UIBinderSetIsVisible.New(self, self.SkillActionBG, nil, true) },
		-- { "FilterItemList", UIBinderUpdateBindableList.New(self, self.FilterTableView) },
		{ "ActionTableList", UIBinderUpdateBindableList.New(self, self.ActionTableViewAdapter) },
		{ "IsSearch", UIBinderSetIsVisible.New(self, self.DropDownListGetWay, true) },
		{ "IsSearch", UIBinderSetIsVisible.New(self, self.SearchBtn, true, true) },
		{ "IsSearch", UIBinderSetIsVisible.New(self, self.SearchBar) },
		{ "IsSearch", UIBinderSetIsVisible.New(self, self.PanelSingleBox, true) },
		--{ "IsShowID", UIBinderSetIsVisible.New(self, self.HorizontalID) },
		--{ "IsShowRideNum", UIBinderSetIsVisible.New(self, self.HorizontalPeople) },
		{ "TextShowName", UIBinderSetText.New(self, self.TextMountName)},
		{ "TextShowMember", UIBinderSetText.New(self, self.TextRideNumber)},
		{ "TextShowID", UIBinderSetText.New(self, self.TextNumber)},

		{ "IsShowGridMount", UIBinderSetIsVisible.New(self, self.TableViewGridList) },
		{ "IsOnlyShowOwned", UIBinderSetIsChecked.New(self, self.SingleBox, true) },
		{ "IsShowExpository", UIBinderSetIsVisible.New(self, self.BtnDescribeTipsBG, nil, true) },
		{ "DescribeTitle", UIBinderSetText.New(self, self.DescribeTips.TextTitle) },
		{ "TextShowExpository", UIBinderSetText.New(self, self.DescribeTips.Text01) },
		{ "TextShowDesc", UIBinderSetText.New(self, self.DescribeTips.Text02) },
		{ "TextGetSource", UIBinderSetText.New(self, self.TextGetWay)},
		{ "ShowGetSourceText", UIBinderSetIsVisible.New(self, self.TextGetWay) },
		--{ "IsShowShop", UIBinderSetIsVisible.New(self, self.BtnShop) },
		{ "ShowMountList", UIBinderValueChangedCallback.New(self, nil, self.OnMountListChange) },
		{ "IsShowPanelNone", UIBinderSetIsVisible.New(self, self.PanelNone) },
		--{ "IsShowPanelBtnBar", UIBinderSetIsVisible.New(self, self.PanelBtnBar) },
		{ "IsSearchEmpty", UIBinderSetIsVisible.New(self, self.PanelLeftEmpty) },
		{ "IsSearchEmpty", UIBinderSetIsVisible.New(self, self.PanelInforBar, true)},
		{ "bShowActionBtn", UIBinderSetIsVisible.New(self, self.TableViewAction, false, true)},
		{ "bShowPanelCustomMadeBtn", UIBinderSetIsVisible.New(self, self.PanelCustomMade, false, true)},
		{ "EmptyText", UIBinderSetText.New(self, self.TextEmpty)},
		{ "IsSelectedOwned", UIBinderSetIsVisible.New(self, self.PanelBtnBar)},
		{ "ShowBtnGo", UIBinderSetIsVisible.New(self, self.BtnGo, false, true)},
		{ "IsShowImgMountType", UIBinderSetIsVisible.New(self, self.ImgMountType)},
		{ "MountTrackIcon",  UIBinderSetBrushFromAssetPath.New(self, self.ImgMountType, true) },

		{ "IsShowTextGetWay", UIBinderSetIsVisible.New(self, self.GetWayTips) },

		{ "IsShowNameImg", UIBinderSetIsVisible.New(self, self.ImgHide) },
		{ "IsShowNameImg", UIBinderSetIsVisible.New(self, self.TextMountName, true) },

		{ "IsShowPlayer", UIBinderSetIsChecked.New(self, self.ToggleBtnMount, true) },
		{ "ProportionText", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle) },
		{ "IsCustomMadeRedDotVisible", UIBinderValueChangedCallback.New(self, nil, self.OnSetCustomMadeRedDot)},
	}
	self:RegisterBinders(self.ViewModel, Binders)

	local Binders1 = {
		{ "NewMap", UIBinderValueChangedCallback.New(self, nil, self.OnCustomMadeNewMapChanged) },
	}
	self:RegisterBinders(MountCustomMadeVM, Binders1)
end

function MountArchiveNewPanelView:OnLoadMountModel()
	self.ViewModel.IsShowPlayer = false
	self.ViewModel:UpdateData()

	self.ViewModel.RequestQueue[#self.ViewModel.RequestQueue + 1] = self.ViewModel.SelectedMountID
	self:ProcessNextRequest()

	self:OnSetTableMountState(1)	  --默认选中第一个坐骑
end

function MountArchiveNewPanelView:OnSetTableMountState(Index)
	if self.ViewModel.ListSlotVM == nil then return end
	local SlotVM = self.ViewModel.ListSlotVM[Index]
	if SlotVM == nil then return end
	self.MountTableGridView:SetSelectedIndex(Index)
	self:OnMountTableViewSelectChange(Index)
end

function MountArchiveNewPanelView:HoldTableSelectState()
	local ListSlot = self.ViewModel.ListSlotVM
	if ListSlot == nil or #ListSlot == 0 then 
		self.ViewModel.IsSelectedOwned = false
		return 
	end
	local Index = 1
	-- 计算新table的序号
	for i, v in ipairs (ListSlot) do
		if v.ResID == self.ViewModel.SelectedMountID then
			Index = i
		end
	end
	self.MountTableGridView:SetSelectedIndex(Index)
end

-- 所选图鉴发生变化
function MountArchiveNewPanelView:OnMountTableViewSelectChange(Index, ItemData, ItemView)
	if not self.ViewModel then return end
	self.ViewModel.SelectedMountIndex = Index
	local SlotVM = self.ViewModel.ListSlotVM[Index]
	if SlotVM == nil then
		return
	end
	local MountID = SlotVM.ResID
	local Mount = self.ViewModel.AllMountMp[MountID]
	if Mount == nil then
		return
	end
    -- if self.Common_Render2D_UIBP then
	-- 	local UICharacter = self.Common_Render2D_UIBP:GetCharacter()
	-- 	local RideComp = UICharacter and UICharacter:GetRideComponent() or nil
	-- 	if RideComp then
	-- 		local IsAssembling = RideComp:IsAssembling()
	-- 		if IsAssembling == true then
	-- 			print("[MountArchive]快速重复切换 IsAssembling =",IsAssembling)
	-- 			return
	-- 		end
	-- 	end
	-- end

	if self.ViewModel.SelectedMountID ~= Mount.ResID then	--相同坐骑不更新信息
		self.ViewModel.RequestQueue[#self.ViewModel.RequestQueue + 1] = MountID
		if self.IsMountLoading ~= true then
			self:ProcessNextRequest()
		end
	end

	-- self:ResettModelSpringArm()
	DataReportUtil.ReportMountInterSystemFlowData(3, 2, Mount.ResID)
	self.ViewModel.SelectedMountID = Mount.ResID
	self.ViewModel:UpdateShowText(Mount)	-- 更新界面文本显示
	local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
	if UIComplexCharacter and MountVM.MountMap[MountID] then
		MountMgr:SetCustomMadeID(UIComplexCharacter, MountID, MountVM.MountMap[MountID].Facade)
	end
	-- 更新图标状态
	MountVM:ClearNewByResID(Mount.ResID)
	SlotVM:UpdateArchiveData(Mount)
	-- 更新留言板图鉴数据事件
	if self.ViewModel.IsShowCommonBoard == true then
		if SlotVM.IsMountNotOwn == true or SlotVM.IsMountStory == true then
			self:OnCloseBoard(self.ViewModel)
		else
			EventMgr:SendEvent(EventID.BoardObjectChange, self.ViewModel.SelectedMountID)
		end
	end
	-- 关闭之前的坐骑详情
	self.ViewModel.IsShowExpository = false
	self:OnSkillTipsBGClick()
	self:OnSwitchBgm()
	self.ViewModel.IsCustomMadeRedDotVisible = MountCustomMadeVM:MountIsNew(Mount.ResID)
	self:LoadingActionItem()
	self:SetMountVisible()
end

--快速切换坐骑时，按队列只加载最后一个
function MountArchiveNewPanelView:ProcessNextRequest()
	local Len = #self.ViewModel.RequestQueue
	if Len <= 0 then
		return
	end
	local MountResID = self.ViewModel.RequestQueue[Len]
	self.ViewModel.RequestQueue = {}	-- 清空请求队列
	self.IsMountLoading = true
	self:SetMountModel(MountResID)
end

---------------------------------- Search Start --------------------------------------
function MountArchiveNewPanelView:OnSearch()
	self.ViewModel.IsSearch = true
end

function MountArchiveNewPanelView:OnGetWayFilterTypesChanged(NewValue, OldValue)
	if NewValue == nil then return end
	self.DropDownListGetWay:UpdateItems(self.ViewModel.DownListVMList, 1)
	self.DropDownListGetWay:SetIsCancelHideClearSelected(true)
end

function MountArchiveNewPanelView:OnMountFilterUpdate(Params)
	-- local Key = Params[1]
	-- local bSelect = Params[2]
	-- self.ViewModel:GenFilterItemList(bSelect and Key or 0)
end

function MountArchiveNewPanelView:SetCustomMade(MountResID, CustomMadeID)
	local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
	if UIComplexCharacter then
		_G.MountMgr:SetCustomMadeID(UIComplexCharacter, MountResID, CustomMadeID)
	end
end

-- 切换筛选器
function MountArchiveNewPanelView:OnSelectionChangedDropDownList(Index, ItemData, ItemView, IsByClick)
	local Data = ItemData.ItemData
	local FilterType = Data.FilterType
	if FilterType == 0 then
		self.ViewModel.ShowGetWayFilter = self.ViewModel.RideGetWay
		self.ViewModel.IsShowFilter = false
	else
		self.ViewModel.ShowGetWayFilter = {}
		self.ViewModel.ShowGetWayFilter[FilterType] = self.ViewModel.RideGetWay[FilterType]
		self.ViewModel.IsShowFilter = true
	end
	self:OnMountListChange()
end

-- 空白处关掉技能弹窗
function MountArchiveNewPanelView:OnSkillTipsBGClick()
	SkillTipsMgr.CurrentTipsType = 4
	if SkillTipsMgr:HideMountSkillTips() then
		self.ViewModel.IsShowSkillTips = false
		self.ViewModel.SkillTagList = nil
		_G.EventMgr:SendEvent(_G.EventID.ActionSelectChanged, { ID = 0 } )
	end
end

-- 搜索输入框变化
function MountArchiveNewPanelView:ChangeCallback(Text, Length)
	--self.ViewModel:UpdateMountList(Text)
	--self.SingleBox:SetText(self.ViewModel.TextOwnNubmber)
end

-- 搜索输入完成
function MountArchiveNewPanelView:OnSearchInputFinish(Text)
	self.ViewModel:UpdateMountList(Text)
	self:HoldTableSelectState()
	self:SetMountVisible()
end

-- 取消搜索
function MountArchiveNewPanelView:OnClickedCloseSearch()
	self.ViewModel.IsSearch = false
	self:OnMountListChange()
end

-- 未拥有
function MountArchiveNewPanelView:OnSingleBoxClick(IsChecked)
	--self.ViewModel.IsOnlyShowOwned = ButtonState == _G.UE.EToggleButtonState.Checked
	self.ViewModel.IsOnlyShowOwned = IsChecked
	self.ViewModel:SetShowMounts()
	-- self.MountTableGridView:SetSelectedIndex(self.ViewModel.SelectedMountIndex)
	-- self.ViewModel:UpdateMountList()
end

-- 列表更新
function MountArchiveNewPanelView:OnMountListChange(Params)
	self.ViewModel:UpdateMountList()
	self:HoldTableSelectState()
	self:SetFilterColor()
	self:SetMountVisible()
end
---------------------------------- Search End --------------------------------------

-- 展示细节描述文本
function MountArchiveNewPanelView:OnShowDetail()
	self.ViewModel.IsShowExpository = not self.ViewModel.IsShowExpository
	self:OnCloseBoard(self.ViewModel)
	DataReportUtil.ReportMountInterSystemFlowData(7, self.ViewModel.SelectedMountID)
end

-- 空白处关掉描述文本
function MountArchiveNewPanelView:OnClickDescribeBG()
	self.ViewModel.IsShowExpository = false
end

-- 获取途径
function MountArchiveNewPanelView:OnShowGetWay()
	--通过物品ID（self.ViewModel.ResID）在物品表配置了获取途径 弹出跳转途径弹窗
	if UIViewMgr:IsViewVisible(UIViewID.CommGetWayTipsView) then
		UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
	else
		local BtnSize = UIUtil.CanvasSlotGetSize(self.BtnGo)
		TipsUtil.ShowGetWayTips(self.ViewModel, nil, self.BtnGo, _G.UE.FVector2D(BtnSize.X, -15), _G.UE.FVector2D(1, 1), false)
		DataReportUtil.ReportMountInterSystemFlowData(5, 1, self.ViewModel.SelectedMountID)
	end
end

-- 打开留言板
function MountArchiveNewPanelView:OnShowBoard()
	-- 未选择则不打开留言板
	if self.ViewModel.SelectedMountID == nil then return end
	if self.ViewModel.IsShowCommonBoard then
		self:OnCloseBoard(self.ViewModel)
	else
		local Params = {
			BoardTypeID = BoardType.Mount, -- 留言板类型ID
			SelectObjectID = self.ViewModel.SelectedMountID, -- 图鉴中的物品ID
			MaskCloseFunc = self.OnCloseBoard,
			HostVM = self.ViewModel,
		}
		UIViewMgr:ShowView(UIViewID.MessageBoardPanel, Params)
		self.ViewModel.IsShowCommonBoard = true
	end
end
function MountArchiveNewPanelView:OnCloseBoard(HostVM)
	if HostVM then
		HostVM.IsShowCommonBoard = false
	end

	UIViewMgr:HideView(UIViewID.MessageBoardPanel)
end

-- 音效控制
function MountArchiveNewPanelView:OnShowBGM(_, State)
	self.ViewModel.IsShowBGM = State == _G.UE.EToggleButtonState.Checked
	self:PlayOrStopBgm()
	self:OnCloseBoard(self.ViewModel)
	DataReportUtil.ReportMountInterSystemFlowData(8, self.ViewModel.SelectedMountID, self.ViewModel.IsShowBGM == true)
end

function MountArchiveNewPanelView:PlayOrStopBgm()
	local SlotVM = self.ViewModel.ListSlotVM[self.ViewModel.SelectedMountIndex]
	if SlotVM == nil then
		return
	end
	local MountID = SlotVM.ResID
	local Mount = self.ViewModel.AllMountMp[MountID]
	if Mount == nil then
		return
	end
	if MountID == nil then
		return
	end
	local TempBgmCfg = BgmCfg:FindCfgByKey(Mount.BgmID)
	if TempBgmCfg ~= nil then
		if not self.ViewModel.IsShowBGM then
			_G.UE.UAudioMgr:Get():StopBGM(self.PlayingID)
			if MountMgr:IsInRide() then
				MountMgr:PlayMountBGM()
			end
		else
			if MountMgr:IsInRide() then
				MountMgr:StopMountBGM()
			end
			self.PlayingID =_G.UE.UAudioMgr:Get():PlayBGM(tonumber(Mount.BgmID), _G.UE.EBGMChannel.UI)
		end
	end
end

function MountArchiveNewPanelView:OnSwitchBgm()
	if self.ViewModel.IsShowBGM then
		--先停止原来的BGM
		if self.PlayingID then
			_G.UE.UAudioMgr:Get():StopBGM(self.PlayingID)
		end
		local SlotVM = self.ViewModel.ListSlotVM[self.ViewModel.SelectedMountIndex]
		if SlotVM == nil then
			return
		end
		local MountID = SlotVM.ResID
		local Mount = self.ViewModel.AllMountMp[MountID]
		if Mount == nil then
			return
		end
		if MountID == nil then
			return
		end
		local TempBgmCfg = BgmCfg:FindCfgByKey(Mount.BgmID)
		self.PlayingID =_G.UE.UAudioMgr:Get():PlayBGM(tonumber(Mount.BgmID), _G.UE.EBGMChannel.UI)
	end
end
----------------------------------- Model Loading Start---------------------------------------

function MountArchiveNewPanelView:OnShowPlayer()
	self.ViewModel.IsShowPlayer = not self.ViewModel.IsShowPlayer
	local SlotVM = self.ViewModel.ListSlotVM[self.ViewModel.SelectedMountIndex]
	if SlotVM then
		local MountID = SlotVM.ResID
		local Cfg = RideCfg:FindCfgByKey(MountID)
		if Cfg and Cfg.HideParts == 1 then
			local RideComponent = self.Common_Render2D_UIBP.UIComplexCharacter:GetRideComponent()
			if RideComponent then
				if self.ViewModel.IsShowPlayer then
					RideComponent:ShowRod()
				else
					RideComponent:HideRod()
				end
			end
		end
	end
	self.Common_Render2D_UIBP:HidePlayer(not self.ViewModel.IsShowPlayer)
	--ButtonState = self.ViewModel.IsShowPlayer
	self:OnCloseBoard(self.ViewModel)
end

-- 根据坐骑ID切换模型
function MountArchiveNewPanelView:SetMountModel(MountID)
	_G.MountMgr:SetAssembleID(MountID)
	self.Common_Render2D_UIBP:SetUIRideCharacter(MountID)
	self.Common_Render2D_UIBP:HidePlayer(not self.ViewModel.IsShowPlayer)
end

-- 坐骑模型整体缩放
function MountArchiveNewPanelView:SetMountModelScale(MountID)
	--获取模型缩放比例
	local MountMp = self.ViewModel.ListMountSlotMp
	if MountMp == nil or MountMp[MountID] == nil then return end
	local Scale = MountMp[MountID].Mount.ModelScaling
	if Scale == nil or Scale < 0.1 then
		Scale = 1.0
	end
	--self.Common_Render2D_UIBP:SetModelScale(Scale)
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	if ChildActor ~= nil then
	    ChildActor:SetScaleFactor(Scale, true)
		-- print("===== 缩放比例 ", Scale)
	end
end

-- 初始化三维展示模型
function MountArchiveNewPanelView:ShowPlayerMountActor()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	self.ViewModel.AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachType()
	self.Common_Render2D_UIBP.bAutoInitSpringArm = false -- 如果不忽视，OnAssembleAllEnd时，会把摄像机位置弄错(位置：CommonRender2DView:InitSpringArmEndPos())
	--根据种族取对应的RenderActor
	local RenderActorPathForRace = "Class'/Game/UI/Render2D/Mount/Bp_Reder2DForMount.Bp_Reder2DForMount_C'"
	-- Class'/Game/UI/Render2D/MountArchiveBp_Reder2DForMount.Bp_Reder2DForMount_C'
    local CallBack = function(bSucc)
        if (bSucc) then
			self.VignetteIntensityDefaultValue = self.Common_Render2D_UIBP:GetPostProcessVignetteIntensity()
			self.Common_Render2D_UIBP:SwitchOtherLights(false)
            self.Common_Render2D_UIBP:ChangeUIState(false)
            self.Common_Render2D_UIBP:SetUICharacterByEntityID(MajorUtil.GetMajorEntityID())
			self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
            self:SetModelSpringArmToDefault(false)
			self.Common_Render2D_UIBP:HidePlayer(true)
			self:OnLoadMountModel()
			local Actor = self.Common_Render2D_UIBP:GetCharacter()
			if Actor then
				local AvatarComponent = Actor:GetAvatarComponent()
				if AvatarComponent then
					AvatarComponent:SetForcedLODForAll(1)
				end
			end
			self:SetLight()
        end
    end
	local ReCreateCallBack = function()
        self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
    end

    self.Common_Render2D_UIBP:CreateRenderActor(RenderActorPathForRace,
	EquipmentMgr:GetEquipmentCharacterClass(), nil--[[EquipmentMgr:GetLightConfig()]],
	false, CallBack, ReCreateCallBack)
	--隐藏武器
	--self.Common_Render2D_UIBP:HideWeapon(true)
	--self.Common_Render2D_UIBP:UpdateAllLights()
	--self.Common_Render2D_UIBP:ChangeUIState(false)
	--self.Common_Render2D_UIBP:ShowRenderActor(true)
end

function MountArchiveNewPanelView:SetModelSpringArmToDefault(bInterp)
	local SpringArmRotation = self.Common_Render2D_UIBP:GetSpringArmRotation()
	self.Common_Render2D_UIBP:SetSpringArmRotation(0, SpringArmRotation.Yaw, SpringArmRotation.Roll, true)
	self.Common_Render2D_UIBP:SetSpringArmLocation(self.CameraFocusCfgMap:GetSpringArmOriginX("c0101"), 
													self.CameraFocusCfgMap:GetSpringArmOriginY("c0101"), 
													self.CameraFocusCfgMap:GetSpringArmOriginZ("c0101"), bInterp)
	local FovY = CameraUtil.FOVXToFOVY(self.CameraFocusCfgMap:GetOriginFOV("c0101"), 16/9)
	self.Common_Render2D_UIBP:SetFOVY(FovY)
	self.Common_Render2D_UIBP:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self:ResettModelSpringArm()
	self:ClearPreView()
	self.ViewModel.bIsHoldWeapon = false
end

function MountArchiveNewPanelView:ResettModelSpringArm()
--	self:SetCameraEnablePitch()
	if nil == self.CameraFocusCfgMap then return end
	local DefaultArmDistance = 350--self.CameraFocusCfgMap:GetSpringArmDistance("c0101")
	self.Common_Render2D_UIBP:SetSpringArmLocation(100, 80, 106, true)
	self.Common_Render2D_UIBP:SetSpringArmCompArmLength(DefaultArmDistance + 100)
	self.Common_Render2D_UIBP:EnableRotator(true)
	-- self.Common_Render2D_UIBP:SetModelRotation(0, 0 , 0, true)
	self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(80)
    self.Common_Render2D_UIBP:SetSpringArmDistance(DefaultArmDistance + 100, true)
	-- 应策划要求禁用缩放
	self.Common_Render2D_UIBP:EnableZoom(false)
end

function MountArchiveNewPanelView:OnSingleClick()
    --self.Common_Render2D_UIBP:SwitchActorAutoRotator()
end

function MountArchiveNewPanelView:OnDoubleClick()
end

function MountArchiveNewPanelView:ClearPreView()
	--self.PreViewMap = {}
	self.Common_Render2D_UIBP:ResumeAvatar()

end

-- 界面角色拼装完成
function MountArchiveNewPanelView:OnAssembleAllEnd(Params)
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	local EntityID = Params.ULongParam1
	local ObjType = Params.IntParam1
	if not ChildActor then return end
	local RideComp = ChildActor:GetRideComponent()
	if not RideComp then return end
	local AttrComp = ChildActor:GetAttributeComponent()
	if EntityID == AttrComp.EntityID and ObjType == AttrComp.ObjType then
		if nil == self.ViewModel.SelectedMountID then
			print("[MountArchive]SelectedMountID ",self.ViewModel.SelectedMountID)
			return
		end
		if RideComp:IsAssembling() then
			print("[MountArchive]RideComp.IsAssembling ",RideComp:IsAssembling())
			return
		end
		if RideComp.RideResID == 0 then
			print("[MountArchive]RideComp.RideResID ",RideComp.RideResID)
			return
		end

		-- print("===== 拼装完成 所选图鉴发生变化时 选中的ID", self.ViewModel.SelectedMountID)
		-- print("===== 拼装完成 坐骑组件当前的ID", RideComp.RideResID)

		if not self.ViewModel.ListSlotVM or not next(self.ViewModel.ListSlotVM) then return end
		local SlotVM = self.ViewModel.ListSlotVM[self.ViewModel.SelectedMountIndex]
		if SlotVM == nil then
			return
		end
		local MountID = SlotVM.ResID
		local Mount = self.ViewModel.AllMountMp[MountID]
		if Mount == nil then
			FLOG_ERROR("OnAssembleAllEnd Mount = nil! Mount ID =="..MountID)
			return
		end
		if MountID == _G.MountMgr.AssembleID then
			_G.MountMgr.AssembleID = 0
		end

		-- print("===== 拼装完成 SlotVM中当前数据ID", MountID)
		self.IsMountLoading = false
		self:ProcessNextRequest()

		-- 设置缩放
		self:SetMountModelScale(self.ViewModel.SelectedMountID)
		--处理贴图加载
		local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
		if UIComplexCharacter then
			UIComplexCharacter:GetAvatarComponent():WaitForTextureMips()
		end

		self.Common_Render2D_UIBP:SetRideMeshComponent()
		if SlotVM.ResID == self.ZSMDHB then
			--特殊处理滑板的倾斜
			if UIComplexCharacter and UIComplexCharacter:GetRideComponent() ~= nil then
				UIComplexCharacter:GetRideComponent():EnableAnimationRotating(false)
			end
			self.Common_Render2D_UIBP:RotatorUseWorldRotation(true)
		else
			if UIComplexCharacter and UIComplexCharacter:GetRideComponent() ~= nil then
				UIComplexCharacter:GetRideComponent():EnableAnimationRotating(true)
			end
		end
		self.Common_Render2D_UIBP:SetModelLocation(Mount.OffsetX or 0, Mount.OffsetY or 0, Mount.OffsetZ or 0)
		self.Common_Render2D_UIBP:SetModelRotation(Mount.RotationY, Mount.RotationX, Mount.RotationZ)
		local RideComponent = self.Common_Render2D_UIBP.UIComplexCharacter:GetRideComponent()
		if self.ViewModel.IsShowPlayer then
			RideComponent:ShowRod()
		else
			RideComponent:HideRod()
		end

	end
end

function MountArchiveNewPanelView:OnClickBtnCustomMade()
	DataReportUtil.ReportCustomizeUIFlowData(1, self.ViewModel.SelectedMountID, self.TextMountName:GetText(),"","",2)
	UIViewMgr:ShowView(UIViewID.MountCustomMadePanel, { MountResID = self.ViewModel.SelectedMountID } )
end

function MountArchiveNewPanelView:OnCustomMadeNewMapChanged()
	self.ViewModel.IsCustomMadeRedDotVisible = MountCustomMadeVM:MountIsNew(self.ViewModel.SelectedMountID)
end

function MountArchiveNewPanelView:OnSetCustomMadeRedDot(bVisible)
	if self.RedDot.ItemVM == nil then
		self.RedDot:InitData()
	end
	self.RedDot:SetRedDotUIIsShow(bVisible)
end

----------------------------------- Model Loading End---------------------------------------

function MountArchiveNewPanelView:LoadingActionItem()
	if not self.ViewModel.IsSelectedOwned then
		self.ViewModel.bShowActionBtn = false
		return
	end
	local SlotVM = self.ViewModel.ListSlotVM[self.ViewModel.SelectedMountIndex]
	if not SlotVM then return end
	local MountID = SlotVM.ResID
	local Cfg = RideCfg:FindCfgByKey(MountID)
	if Cfg == nil or nil == Cfg.PlayAction then return end
	if nil == Cfg.PlayAction[1] then
		self.ViewModel.bShowActionBtn = false
		return
	end
	self.ViewModel.bShowActionBtn = true
	
	local SkillList = {}
	for k, v in pairs(Cfg.PlayAction) do
		if nil ~= v and 0 ~= v then
			local Cfg = RideSkillCfg:FindCfgByKey(v)
			if nil ~= Cfg then
				table.insert(SkillList, {ID = v, Cfg = Cfg, ViewModel = self.ViewModel})
			end
		end
	end
	self.ViewModel.ActionTableList = SkillList
end

---启用镜头俯仰（上下）旋转
---@param MinPitch number @仰视角度
---@param MaxPitch number @俯视角度
function MountArchiveNewPanelView:SetCameraEnablePitch(MinPitch, MaxPitch)
	local Param = {}

	Param.MinPitch = MinPitch or -30
	Param.MaxPitch = MaxPitch or 13

	self.Common_Render2D_UIBP:SetCameraControlParams(Param)
	self.Common_Render2D_UIBP:EnablePitch(true)
end

--- 设置筛选颜色（规则：切换筛选项后，筛选标题上的文字变白色）
function MountArchiveNewPanelView:SetFilterColor()
	local FLinearColor = _G.UE.FLinearColor
	local Color = "9C9788FF"
	if self.ViewModel.IsShowFilter then
		Color = "ffffff"
	end
	self.DropDownListGetWay.TextContent:SetColorAndOpacity(FLinearColor.FromHex(Color))
end

function MountArchiveNewPanelView:SetMountActorState(bShow)
	if self.Common_Render2D_UIBP ~= nil then
		self.Common_Render2D_UIBP:ShowCharacter(bShow)
	end
end

function MountArchiveNewPanelView:SetMountVisible()
	local bShow = self.ViewModel:IsMountVisible()
	self:SetMountActorState(bShow)
end

function MountArchiveNewPanelView:SetLight()
	local LightCfg = SystemLightCfg:FindCfgByKey(10)
	local PathList = LightCfg and LightCfg.LightPresetPaths
	if not PathList then return end
	local LightPresetPath = PathList[1]
	self.Common_Render2D_UIBP:ResetLightPreset(LightPresetPath)
end

function MountArchiveNewPanelView:OnBackClick()
	UIViewMgr:HideView(self.ViewID)
end

return MountArchiveNewPanelView