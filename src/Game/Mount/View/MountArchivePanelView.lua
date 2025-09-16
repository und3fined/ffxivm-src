---
--- Author: jamiyang
--- DateTime: 2023-03-07 20:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local EventID = require("Define/EventID")
local EventMgr = _G.EventMgr
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
--local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
--local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")

local MountMgr = _G.MountMgr
local MountVM = require("Game/Mount/VM/MountVM")
local MountArchivePanelVM = require("Game/Mount/VM/MountArchivePanelVM")
local MountDetailVM = require("Game/Mount/VM/MountDetailVM")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local MajorUtil = require("Utils/MajorUtil")
local EquipmentMgr = _G.EquipmentMgr
local RenderActorPath = "Class'/Game/UI/Render2D/BP_Render2DLoginActor_%s.BP_Render2DLoginActor_%s_C'"
local BoardType = require("Define/BoardType")

---@class MountArchivePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBGM UFButton
---@field BtnChat UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnDetail UFButton
---@field BtnFilter UToggleButton
---@field BtnMount UFButton
---@field BtnShop Comm2BtnLView
---@field BtnSort UFButton
---@field Common_Render2D_UIBP CommonRender2DView
---@field DetailTips MountArchiveDetailTipsView
---@field ImgIcon1 UFImage
---@field ImgIcon2 UFImage
---@field ImgMountType UFImage
---@field ImgSortIcon UFImage
---@field MountMsgPanel MountMsgPanelView
---@field PanelBtnBar UFCanvasPanel
---@field PanelFilterBar UFCanvasPanel
---@field PanelNone UFCanvasPanel
---@field PanelSortBar UFCanvasPanel
---@field RichTextNone URichTextBox
---@field SearchBar CommSearchBarView
---@field SearchBtn UFButton
---@field SingleBox CommSingleBoxView
---@field SkillSlot1 UFCanvasPanel
---@field SkillSlot2 UFCanvasPanel
---@field TableViewFilterList UTableView
---@field TableViewGridList UTableView
---@field TableViewMountList UTableView
---@field TextFilterType UFTextBlock
---@field TextGetWay UFTextBlock
---@field TextID UFTextBlock
---@field TextMember UFTextBlock
---@field TextMountName UFTextBlock
---@field TextSort UFTextBlock
---@field TextTitleName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountArchivePanelView = LuaClass(UIView, true)

function MountArchivePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBGM = nil
	--self.BtnChat = nil
	--self.BtnClose = nil
	--self.BtnDetail = nil
	--self.BtnFilter = nil
	--self.BtnMount = nil
	--self.BtnShop = nil
	--self.BtnSort = nil
	--self.Common_Render2D_UIBP = nil
	--self.DetailTips = nil
	--self.ImgIcon1 = nil
	--self.ImgIcon2 = nil
	--self.ImgMountType = nil
	--self.ImgSortIcon = nil
	--self.MountMsgPanel = nil
	--self.PanelBtnBar = nil
	--self.PanelFilterBar = nil
	--self.PanelNone = nil
	--self.PanelSortBar = nil
	--self.RichTextNone = nil
	--self.SearchBar = nil
	--self.SearchBtn = nil
	--self.SingleBox = nil
	--self.SkillSlot1 = nil
	--self.SkillSlot2 = nil
	--self.TableViewFilterList = nil
	--self.TableViewGridList = nil
	--self.TableViewMountList = nil
	--self.TextFilterType = nil
	--self.TextGetWay = nil
	--self.TextID = nil
	--self.TextMember = nil
	--self.TextMountName = nil
	--self.TextSort = nil
	--self.TextTitleName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountArchivePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnShop)
	self:AddSubView(self.Common_Render2D_UIBP)
	self:AddSubView(self.DetailTips)
	self:AddSubView(self.MountMsgPanel)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountArchivePanelView:OnInit()
	self.ViewModel = MountArchivePanelVM.New()
	self.DetailViewModel = MountDetailVM.New()

	--图标样式展示方式
	self.MountTableGridView = UIAdapterTableView.CreateAdapter(self, self.TableViewGridList, self.OnMountTableViewSelectChange, false)
	self.MountTableGridView:SetScrollbarIsVisible(true)
	--图文展示方式
	self.MountTableRowView = UIAdapterTableView.CreateAdapter(self, self.TableViewMountList, self.OnMountTableViewSelectChange, false)
	self.MountTableRowView:SetScrollbarIsVisible(true)

	self.FilterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewFilterList, self.OnFilterTableViewSelectChange, false)
	self.FilterTableView:SetScrollbarIsVisible(false)

	self.SearchBar:SetCallback(self, self.ChangeCallback, self.OnSearchInputFinish);

	self.Common_Render2D_UIBP:SetClick(self, self.OnSingleClick, self.OnDoubleClick)

end

function MountArchivePanelView:OnDestroy()

end

function MountArchivePanelView:OnShow()
	-- 清除筛选
	MountVM:RefreshFilterValue()
	--MountMgr:SendMountListQuery()
	self.ViewModel:GetAllMounts()
	self:ShowPlayerMountActor()
end

function MountArchivePanelView:OnLoadMountModel()

	self.ViewModel.IsShowPlayer = false
	-- 提审版本屏蔽
	self:OnSearch()
	--self.MountTableGridView:SetSelectedIndex(1)
	self.ViewModel:UpdateData()
	-- 默认选中第一个
	self:OnSetTableMountState(1)
end
function MountArchivePanelView:OnSetTableMountState(Index)
	if self.ViewModel.ListSlotVM == nil then return end
	local SlotVM = self.ViewModel.ListSlotVM[Index]
	if SlotVM == nil then return end
	--self.MountTableGridView:SetSelectedIndex(Index)
	self.MountTableGridView:SetSelectedIndex(Index)
	self:OnMountTableViewSelectChange(Index)
	--SlotVM.IsSelect = true
end

function MountArchivePanelView:OnHide()
	self.Common_Render2D_UIBP:SwitchOtherLights(true)
	self.ViewModel.IsShowFilter = false
	self.ViewModel.IsSearch = false
	self.SearchBar:SetText("")
	MountVM:ClearNew()
end

function MountArchivePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.SearchBtn, self.OnSearch)
	UIUtil.AddOnClickedEvent(self, self.BtnSort, self.OnShowChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnMount, self.OnShowPlayer)
	UIUtil.AddOnClickedEvent(self, self.BtnDetail, self.OnShowDetail)
	UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnShowBoard)

	UIUtil.AddOnStateChangedEvent(self, self.BtnFilter, self.OnBtnFilterClick)
	--UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnSingleBoxClick)
	self.SingleBox:SetStateChangedCallback(self, self.OnSingleBoxClick)
end

function MountArchivePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(_G.EventID.MountRefreshList, self.OnMountListChange)
	self:RegisterGameEvent(_G.EventID.MountFilterUpdate, self.OnMountFilterUpdate)
end

function MountArchivePanelView:OnRegisterBinder()
	local Binders = {
		{ "ListSlotVM", UIBinderUpdateBindableList.New(self, self.MountTableGridView) },
		{ "ListSlotVM", UIBinderUpdateBindableList.New(self, self.MountTableRowView) },
		{ "IsShowFilter", UIBinderSetIsChecked.New(self, self.BtnFilter, true) },
		{ "IsShowFilter", UIBinderSetIsVisible.New(self, self.TableViewFilterList) },
		{ "FilterItemList", UIBinderUpdateBindableList.New(self, self.FilterTableView) },
		{ "IsSearch", UIBinderSetIsVisible.New(self, self.PanelFilterBar, true) },
		{ "IsSearch", UIBinderSetIsVisible.New(self, self.SearchBtn, true, true) },
		{ "IsSearch", UIBinderSetIsVisible.New(self, self.SearchBar) },
		{ "IsShowMessage", UIBinderSetIsVisible.New(self, self.MountMsgPanel) },
		--{ "TextOwnNubmber", UIBinderSetText.New(self, self.TextOwn)},
		{ "TextShowName", UIBinderSetText.New(self, self.TextMountName)},
		{ "TextShowMember", UIBinderSetText.New(self, self.TextMember)},
		{ "IsShowGridMount", UIBinderSetIsVisible.New(self, self.TableViewGridList) },
		{ "IsShowRowMount", UIBinderSetIsVisible.New(self, self.TableViewMountList) },
		{ "TextSortType", UIBinderSetText.New(self, self.TextSort)},
		{ "IsOnlyShowOwned", UIBinderSetIsChecked.New(self, self.SingleBox, true) },
		{ "IsShowExpository", UIBinderSetIsVisible.New(self, self.DetailTips) },
		{ "TextShowName", UIBinderSetText.New(self, self.SubViews[4].TextHeading) },
		{ "TextShowExpository", UIBinderSetText.New(self, self.SubViews[4].TextSummary) },
		{ "TextShowDesc", UIBinderSetText.New(self, self.SubViews[4].TextDesc) },
		{ "TextGetSource", UIBinderSetText.New(self, self.TextGetWay)},
		{ "IsShowShop", UIBinderSetIsVisible.New(self, self.BtnShop) },
		{ "TextShowID", UIBinderSetText.New(self, self.TextID)},
		{ "ShowMountList", UIBinderValueChangedCallback.New(self, nil, self.OnMountListChange) },
		{ "IsShowPanelNone", UIBinderSetIsVisible.New(self, self.PanelNone) },
		{ "IsShowPanelBtnBar", UIBinderSetIsVisible.New(self, self.PanelBtnBar) },
		--{ "IsShowTextGetWay", UIBinderSetIsVisible.New(self, self.TextGetWay) },
		-- 版本屏蔽
		{ "IsShowVersion", UIBinderSetIsVisible.New(self, self.TextGetWay) },
		{ "IsShowVersion", UIBinderSetIsVisible.New(self, self.SkillSlot1) },
		{ "IsShowVersion", UIBinderSetIsVisible.New(self, self.SkillSlot2) },
		{ "IsShowVersion", UIBinderSetIsVisible.New(self, self.BtnBGM) },
	}
	self:RegisterBinders(self.ViewModel, Binders)

	local Binders1 = {
		{ "MountList", UIBinderValueChangedCallback.New(self, nil, self.OnMountListChange) },
	}
	self:RegisterBinders(MountVM, Binders1)
end

function MountArchivePanelView:OnShowBoard()
	-- 未选择则不打开留言板
	if self.ViewModel.SelectedMountID == nil then return end
	local Params = {
		BoardTypeID = BoardType.Mount, -- 留言板类型ID
		SelectObjectID = self.ViewModel.SelectedMountID -- 图鉴中的物品ID
	}
	UIViewMgr:ShowView(UIViewID.MessageBoardPanel, Params)
	self.ViewModel.IsShowCommonBoard = true
end

function MountArchivePanelView:OnSearch()
	self.ViewModel.IsSearch = true
end

function MountArchivePanelView:OnShowChanged()
	self.ViewModel.IsShowGridMount = not self.ViewModel.IsShowGridMount
	self.ViewModel.IsShowRowMount = not self.ViewModel.IsShowRowMount
	if (self.ViewModel.IsShowGridMount) then
		self.ViewModel.TextSortType = "缩略图模式"
	else
		self.ViewModel.TextSortType = "图文模式"
	end
	-- 同步两个列表所选数据
	self.MountTableGridView:SetSelectedIndex(self.ViewModel.SelectedMountIndex)
	self.MountTableRowView:SetSelectedIndex(self.ViewModel.SelectedMountIndex)
	self:OnMountTableViewSelectChange(self.ViewModel.SelectedMountIndex)
end

function MountArchivePanelView:ChangeCallback(Text, Length)
	self.ViewModel:UpdateMountList(Text)
	self.SingleBox:SetText(self.ViewModel.TextOwnNubmber)
end

function MountArchivePanelView:OnSearchInputFinish()
end

function MountArchivePanelView:OnMountTableViewSelectChange(Index, ItemData, ItemView)
	--local Mount = MountVM.MountList[Index]
	--local Mount = self.ViewModel.AllMountList[Index]
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

	self.ViewModel.SelectedMountID = Mount.ResID
	-- 更新界面文本显示
	self.ViewModel:UpdateShowText(Mount)
	-- 加载坐骑三维模型
	self:SetMountModel(Mount.ResID)
	-- 处理隐藏坐骑
	if self.ViewModel.IsShowPanelNone == true then
		self:SetMountActorState(false)
	else
		self:SetMountActorState(true)
	end
	-- 恢复默认相机设置
	--self:SetModelSpringArmToDefault(false)
	self:ResettModelSpringArm()
	-- 更新图标状态
	MountVM:ClearNewByResID(Mount.ResID)
	SlotVM:UpdateArchiveData(Mount)
	-- 更新留言板图鉴数据事件
	if self.ViewModel.IsShowCommonBoard == true then
		if SlotVM.IsMountNotOwn == true or SlotVM.IsMountStory == true then
			UIViewMgr:HideView(UIViewID.MessageBoardPanel)
			self.ViewModel.IsShowCommonBoard = false
		else
			EventMgr:SendEvent(EventID.BoardObjectChange, self.ViewModel.SelectedMountID)
		end
	end
end

function MountArchivePanelView:OnMountListChange(Params)
	self.ViewModel:UpdateMountList()
	self.SingleBox:SetText(self.ViewModel.TextOwnNubmber)
end

function MountArchivePanelView:OnMountFilterUpdate(Params)
	local Key = Params[1]
	local bSelect = Params[2]
	self.ViewModel:GenFilterItemList(bSelect and Key or 0)
end

function MountArchivePanelView:OnBtnFilterClick(ToggleButton, ButtonState)
	MountVM:RefreshFilterValue()
	self.ViewModel.IsShowFilter = ButtonState == _G.UE.EToggleButtonState.Checked
	if self.ViewModel.IsShowFilter then
		self.ViewModel:GenFilterItemList(1)
	end
end

function MountArchivePanelView:OnSingleBoxClick(IsChecked)
	--self.ViewModel.IsOnlyShowOwned = ButtonState == _G.UE.EToggleButtonState.Checked
	self.ViewModel.IsOnlyShowOwned = IsChecked
	self.ViewModel:SetShowMounts()
	self.MountTableGridView:SetSelectedIndex(self.ViewModel.SelectedMountIndex)
	self.MountTableRowView:SetSelectedIndex(self.ViewModel.SelectedMountIndex)
	--self.ViewModel:UpdateMountList()
end

function MountArchivePanelView:OnShowPlayer()
	self.ViewModel.IsShowPlayer = not self.ViewModel.IsShowPlayer
	self.Common_Render2D_UIBP:HidePlayer(not self.ViewModel.IsShowPlayer)
end

-- 展示细节描述文本
function MountArchivePanelView:OnShowDetail()
	self.ViewModel.IsShowExpository = not self.ViewModel.IsShowExpository
end

-- 根据坐骑ID切换模型
function MountArchivePanelView:SetMountModel(MountID)
	--self.Common_Render2D_UIBP:ShowRenderActor(true)
	self.Common_Render2D_UIBP:SetUIRideCharacter(MountID)
	self.Common_Render2D_UIBP:HidePlayer(not self.ViewModel.IsShowPlayer)
	--获取模型缩放比例
	local Scale = self.ViewModel.ListMountSlotMp[MountID].Mount.ModelScaling
	if Scale == nil or Scale < 0.1 then
		Scale = 1.0
	end
	self.Common_Render2D_UIBP:SetModelScale(Scale)
end

-- 初始化三维展示模型
function MountArchivePanelView:ShowPlayerMountActor()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	self.ViewModel.AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachType()
	--根据种族取对应的RenderActor
	local RenderActorPathForRace = string.format(RenderActorPath, self.ViewModel.AttachType, self.ViewModel.AttachType)
	--local RenderActorPath = "Class'/Game/UI/Render2D/BP_Render2DLoginActor_Mount.BP_Render2DLoginActor_Mount_C'"
    local CallBack = function(bSucc)
        if (bSucc) then
			self.VignetteIntensityDefaultValue = self.Common_Render2D_UIBP:GetPostProcessVignetteIntensity()
			self.Common_Render2D_UIBP:SwitchOtherLights(false)
            self.Common_Render2D_UIBP:ChangeUIState(false)
            self.Common_Render2D_UIBP:SetUICharacterByEntityID(MajorUtil.GetMajorEntityID())
			self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
            self:SetModelSpringArmToDefault(false)
			self.Common_Render2D_UIBP:UpdateAllLights()
			self.Common_Render2D_UIBP:HidePlayer(true)
			self:OnLoadMountModel()
        end
    end
	local ReCreateCallBack = function()
        self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
    end

    self.Common_Render2D_UIBP:CreateRenderActor(RenderActorPathForRace,
	EquipmentMgr:GetEquipmentCharacterClass(), EquipmentMgr:GetLightConfig(),
	false, CallBack, ReCreateCallBack)
	--隐藏武器
	--self.Common_Render2D_UIBP:HideWeapon(true)
	--self.Common_Render2D_UIBP:UpdateAllLights()
	--self.Common_Render2D_UIBP:ChangeUIState(false)
	--self.Common_Render2D_UIBP:ShowRenderActor(true)
end

function MountArchivePanelView:SetMountActorState(bShow)
	if self.Common_Render2D_UIBP ~= nil then
		self.Common_Render2D_UIBP:ShowCharacter(bShow)
	end
end
function MountArchivePanelView:SetModelSpringArmToDefault(bInterp)
	self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(nil, nil, nil, nil)

	local SpringArmRotation = self.Common_Render2D_UIBP:GetSpringArmRotation()
	self.Common_Render2D_UIBP:SetSpringArmRotation(0, SpringArmRotation.Yaw, SpringArmRotation.Roll, true)
	
    --self.Common_Render2D_UIBP:SetSpringArmDistance(DefaultArmDistance, bInterp)
	self.Common_Render2D_UIBP:SetSpringArmLocation(self.CameraFocusCfgMap:GetSpringArmOriginX(self.ViewModel.AttachType), 
													self.CameraFocusCfgMap:GetSpringArmOriginY(self.ViewModel.AttachType), 
													self.CameraFocusCfgMap:GetSpringArmOriginZ(self.ViewModel.AttachType), bInterp)
	self.Common_Render2D_UIBP:SetCameraFOV(self.CameraFocusCfgMap:GetOriginFOV(self.ViewModel.AttachType))
	self.Common_Render2D_UIBP:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self:ResettModelSpringArm()
	self:ClearPreView()
	self.ViewModel.bIsHoldWeapon = false
end

function MountArchivePanelView:ResettModelSpringArm()
	self.Common_Render2D_UIBP:EnableRotator(true)
	self.Common_Render2D_UIBP:SetModelRotation(0, 0 , 0, true)
	local DefaultArmDistance = self.CameraFocusCfgMap:GetSpringArmDistance(self.ViewModel.AttachType)
	self.Common_Render2D_UIBP:SetSpringArmLocation(100, 60, 106, true)
	self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(60)
    self.Common_Render2D_UIBP:SetSpringArmDistance(DefaultArmDistance + 100, true)
	-- 应策划要求禁用缩放
	self.Common_Render2D_UIBP:EnableZoom(false)
end

function MountArchivePanelView:OnSingleClick()
    self.Common_Render2D_UIBP:SwitchActorAutoRotator()
end

function MountArchivePanelView:OnDoubleClick()
end

function MountArchivePanelView:ClearPreView()
	--self.PreViewMap = {}
	self.Common_Render2D_UIBP:ResumeAvatar()

end

-- 界面角色拼装完成
function MountArchivePanelView:OnAssembleAllEnd(Params)
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	if ChildActor then
		self.Common_Render2D_UIBP:UpdateAllLights()
	end
end

return MountArchivePanelView