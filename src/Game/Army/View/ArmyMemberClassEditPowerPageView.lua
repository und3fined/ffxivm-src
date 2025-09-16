---
--- Author: Administrator
--- DateTime: 2024-05-09 16:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMemEditPowerPageVM = nil
local ArmyMemberPanelVM = nil
local ArmyMemberPageVM = nil
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local CommBtnLView = require("Game/Common/Btn/CommBtnLView")
local MsgBoxUtil = _G.MsgBoxUtil
local RichTextUtil = require("Utils/RichTextUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyTextColor = ArmyDefine.ArmyTextColor
local ProtoCS = require("Protocol/ProtoCS")
local GroupPermissionType = ProtoCS.GroupPermissionType
local ArmyMgr

---@class ArmyMemberClassEditPowerPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete CommBtnLView
---@field BtnDown UFButton
---@field BtnHelp CommInforBtnView
---@field BtnSaveBack CommBtnLView
---@field BtnSwitch UFButton
---@field BtnUp UFButton
---@field CommBackBtn_UIBP CommBackBtnView
---@field FTextBlock UFTextBlock
---@field FTextBlock_1 UFTextBlock
---@field FTextBlock_2 UFTextBlock
---@field FTextBlock_3 UFTextBlock
---@field FTextBlock_4 UFTextBlock
---@field FTextBlock_66 UFTextBlock
---@field ImgBG UFImage
---@field ImgIcon UFImage
---@field ImgIcon02 UFImage
---@field ImgIcon03 UFImage
---@field ImgMask UFImage
---@field InputBoxName CommInputBoxView
---@field PanelEmpty UFCanvasPanel
---@field PanelTop UFCanvasPanel
---@field Panelcontent UFCanvasPanel
---@field Panelcontent02 UFCanvasPanel
---@field Panelcontent03 UFCanvasPanel
---@field SingleBoxAll CommSingleBoxView
---@field TableView01 UTableView
---@field TableView02 UTableView
---@field TableView03 UTableView
---@field TableViewBatchList UTableView
---@field TableViewIcon UTableView
---@field TableViewPower UTableView
---@field TextAll UFTextBlock
---@field TextBatch UFTextBlock
---@field TextDown UFTextBlock
---@field TextEmptyTip UFTextBlock
---@field TextTitle UFTextBlock
---@field TextUp UFTextBlock
---@field ToggleTabs CommHorTabsView
---@field AnimBGID1 UWidgetAnimation
---@field AnimBGID2 UWidgetAnimation
---@field AnimBGID3 UWidgetAnimation
---@field AnimBGLoop UWidgetAnimation
---@field AnimChangePower UWidgetAnimation
---@field AnimChangeTab UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberClassEditPowerPageView = LuaClass(UIView, true)

local MenuListData = 
{
	-- LSTR string:信息调整
	[1] = { Name = LSTR(910045) }, 
	-- LSTR string:权限调整
	[2] = { Name = LSTR(910166) }, 
	-- LSTR string:组员调整
	[3] = { Name = LSTR(910201) }, 
}

function ArmyMemberClassEditPowerPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnDown = nil
	--self.BtnHelp = nil
	--self.BtnSaveBack = nil
	--self.BtnSwitch = nil
	--self.BtnUp = nil
	--self.CommBackBtn_UIBP = nil
	--self.FTextBlock = nil
	--self.FTextBlock_1 = nil
	--self.FTextBlock_2 = nil
	--self.FTextBlock_3 = nil
	--self.FTextBlock_4 = nil
	--self.FTextBlock_66 = nil
	--self.ImgBG = nil
	--self.ImgIcon = nil
	--self.ImgIcon02 = nil
	--self.ImgIcon03 = nil
	--self.ImgMask = nil
	--self.InputBoxName = nil
	--self.PanelEmpty = nil
	--self.PanelTop = nil
	--self.Panelcontent = nil
	--self.Panelcontent02 = nil
	--self.Panelcontent03 = nil
	--self.SingleBoxAll = nil
	--self.TableView01 = nil
	--self.TableView02 = nil
	--self.TableView03 = nil
	--self.TableViewBatchList = nil
	--self.TableViewIcon = nil
	--self.TableViewPower = nil
	--self.TextAll = nil
	--self.TextBatch = nil
	--self.TextDown = nil
	--self.TextEmptyTip = nil
	--self.TextTitle = nil
	--self.TextUp = nil
	--self.ToggleTabs = nil
	--self.AnimBGID1 = nil
	--self.AnimBGID2 = nil
	--self.AnimBGID3 = nil
	--self.AnimBGLoop = nil
	--self.AnimChangePower = nil
	--self.AnimChangeTab = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassEditPowerPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnDelete)
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.BtnSaveBack)
	self:AddSubView(self.CommBackBtn_UIBP)
	self:AddSubView(self.InputBoxName)
	self:AddSubView(self.SingleBoxAll)
	self:AddSubView(self.ToggleTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassEditPowerPageView:OnInit()
	---排查ios界面显示失败bug
	_G.FLOG_INFO("ArmyMemberClassEditPowerPageView:OnInit()")
	ArmyMgr = require("Game/Army/ArmyMgr")
	---分组列表
	self.TableViewCategoryAdapter =
	UIAdapterTableView.CreateAdapter(self, self.TableViewPower, self.OnCategorySelectChanged, true)
	---分组Icon列表
	self.TableViewCategoryIconAdapter =
	UIAdapterTableView.CreateAdapter(self, self.TableViewIcon, self.OnCategoryIconSelectChanged, true)
	--- 权限列表
	self.TableViewInfoEditPermisstionAdapter =
	UIAdapterTableView.CreateAdapter(self, self.TableView01)
	self.TableViewInfoEditPermisstionAdapter:SetOnClickedCallback(self.OnClickedPermisstionItem)

	self.TableViewStorePermisstionAdapter =
	UIAdapterTableView.CreateAdapter(self, self.TableView02)
	self.TableViewStorePermisstionAdapter:SetOnClickedCallback(self.OnClickedPermisstionItem)

	self.TableViewMemberEditPermisstionAdapter =
	UIAdapterTableView.CreateAdapter(self, self.TableView03)
	self.TableViewMemberEditPermisstionAdapter:SetOnClickedCallback(self.OnClickedPermisstionItem)

	--- 成员列表
	self.TableViewMemberEditCategoryAdapter =
	UIAdapterTableView.CreateAdapter(self, self.TableViewBatchList)
	self.TableViewMemberEditCategoryAdapter:SetOnClickedCallback(self.OnClickedMemberEditCategoryItem)

	self.Binders = {
        {"CategoryList", UIBinderUpdateBindableList.New(self, self.TableViewCategoryAdapter)},
        {"bInfoPanel", UIBinderSetIsVisible.New(self, self.Panelcontent)},
        {"bPermisstionPanel", UIBinderSetIsVisible.New(self, self.Panelcontent02)},
        {"bMemberPanel", UIBinderSetIsVisible.New(self, self.Panelcontent03)},
		{"IsSaveBtnEnabled", UIBinderValueChangedCallback.New(self, nil, self.OnSaveBtnStateChanged)},
		{"IsSaveBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnSaveBack, false, true)},
		{"IsDeleteBtnEnabled", UIBinderValueChangedCallback.New(self, nil, self.OnDeleteBtnStateChanged)},
		{"IsDeleteBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnDelete, false, true)},
        {"CategoryIconList", UIBinderUpdateBindableList.New(self, self.TableViewCategoryIconAdapter)},
        {"InfoEditPermisstionList", UIBinderUpdateBindableList.New(self, self.TableViewInfoEditPermisstionAdapter)},
        {"StorePermisstionList", UIBinderUpdateBindableList.New(self, self.TableViewStorePermisstionAdapter)},
        {"MemberPermisstionList", UIBinderUpdateBindableList.New(self, self.TableViewMemberEditPermisstionAdapter)},
		{"MemberEditCategoryList", UIBinderUpdateBindableList.New(self, self.TableViewMemberEditCategoryAdapter)},
		{"BatchStr", UIBinderSetText.New(self, self.TextBatch)},
		{"BatchBtnEnable", UIBinderSetIsEnabled.New(self, self.BtnSwitch)},
		{"UpdataMenuList", UIBinderValueChangedCallback.New(self, nil, self.OnUpdataMenuList)},
        {"BGIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG)},
		{"IsAllMemberSelected", UIBinderValueChangedCallback.New(self, nil, self.OnAllMemberSelectedChanged)},
        {"GrandCompanyType", UIBinderValueChangedCallback.New(self, nil, self.OnGrandCompanyTypeChange)},
		{"BGMaskColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgMask) },
		{"IsNoMember", UIBinderSetIsVisible.New(self, self.PanelEmpty) },
		{"IsNoMember", UIBinderSetIsVisible.New(self, self.PanelTop, true) },
    }
	ArmyMemberPanelVM = ArmyMainVM:GetMemberPanelVM()
    ArmyMemberPageVM = ArmyMemberPanelVM:GetArmyMemberPageVM()
    ArmyMemEditPowerPageVM = ArmyMemberPageVM:GetMemEditPowerPageVM()

	self.InputBoxName:SetCallback(self, nil, self.OnCategoryNameTextCommitted)
	--self.SingleBoxAll:SetStateChangedCallback(self, self.AllSelectedCallback)
	--- 返回按钮
	self.CommBackBtn_UIBP:AddBackClick(self, self.OnClickedBtnBack)
	self.IsInput = false
	self.IsWaitCheck = false
end

function ArmyMemberClassEditPowerPageView:OnDestroy()

end

function ArmyMemberClassEditPowerPageView:OnShow()
	---排查ios界面显示失败bug
	_G.FLOG_INFO("ArmyMemberClassEditPowerPageView:OnShow()")
	-- LSTR string:部队分组编辑
	self.TextTitle:SetText(LSTR(910310))
	-- LSTR string:信息编辑权限
	self.FTextBlock_1:SetText(LSTR(910311))
	-- LSTR string:成员管理权限
	self.FTextBlock_4:SetText(LSTR(910130))
	-- LSTR string:储物柜使用权限
	self.FTextBlock_3:SetText(LSTR(910312))
	-- LSTR string:全选
	self.TextAll:SetText(LSTR(910333))
	-- LSTR string:分组名称
	self.FTextBlock_66:SetText(LSTR(910328))
	-- LSTR string:分组排列
	self.FTextBlock:SetText(LSTR(910329))
	-- LSTR string:分组图标
	self.FTextBlock_2:SetText(LSTR(910332))
	-- LSTR string:上移
	self.TextUp:SetText(LSTR(910330))
	-- LSTR string:下移
	self.TextDown:SetText(LSTR(910331))

	-- LSTR string:分组名字
	self.InputBoxName:SetHintText(LSTR(910334))

	-- LSTR string:分组下无组员
	self.TextEmptyTip:SetText(LSTR(910422))

	--- 设置权限默认数据
	ArmyMemEditPowerPageVM:InitPermisstionList()
	---设置横版页签
	--self.ToggleTabs:CancelSelected()
	--self.ToggleTabs:SetSelectedIndex(1)
	---设置默认选中
	local SelectedIndex = ArmyMemEditPowerPageVM:GetSelectedCategoryIndex()
	self.TableViewCategoryAdapter:SetSelectedIndex(SelectedIndex)
	--self:SetMenuShow()
	local GrandCompanyType = ArmyMgr:GetArmyUnionType()
	ArmyMemEditPowerPageVM:SetBGIcon(GrandCompanyType)
	--- 背景动画循环播放
	self:PlayAnimation(self.AnimBGLoop, 0, 0)

	-- LSTR string:删除分组
	self.BtnDelete:SetText(LSTR(910072))
	-- LSTR string:保存修改
	self.BtnSaveBack:SetText(LSTR(910042))

end

function ArmyMemberClassEditPowerPageView:OnHide()
	self.IsInput = false
	self.IsWaitCheck = false
	--ArmyMemEditPowerPageVM:ClearChangeList()
	if UIViewMgr:IsViewVisible(UIViewID.CommJumpWayTipsView) then
        UIViewMgr:HideView(UIViewID.CommJumpWayTipsView)
    end
	ArmyMemEditPowerPageVM:ClearData()
end

function ArmyMemberClassEditPowerPageView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.ToggleTabs, self.OnGroupTabsSelectionChanged)
    UIUtil.AddOnClickedEvent(self, self.BtnUp, self.OnClickedBtnUp)
    UIUtil.AddOnClickedEvent(self, self.BtnDown, self.OnClickedBtnDown)
	UIUtil.AddOnClickedEvent(self, self.BtnSaveBack, self.OnClickedSave)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickedDel)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnClickedBtnSwitch)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxAll, self.AllSelectedCallback)

	UIUtil.AddOnFocusReceivedEvent(self, self.InputBoxName.InputText, self.OnTextFocusReceived)
end

function ArmyMemberClassEditPowerPageView:OnRegisterGameEvent()

end

function ArmyMemberClassEditPowerPageView:OnRegisterBinder()
	if ArmyMemEditPowerPageVM then
		self:RegisterBinders(ArmyMemEditPowerPageVM, self.Binders)
	end
end

---分组名修改框设置
function ArmyMemberClassEditPowerPageView:SetInputBoxNameData()
	local CurCategoryName = ArmyMemEditPowerPageVM:GetCurCategoryName()
	if CurCategoryName == "" then
		-- LSTR string:未命名新分组
		CurCategoryName = LSTR(910158)
	end
	self.InputBoxName:SetText(ArmyMemEditPowerPageVM:GetCurCategoryName())
	self.InputBoxName:SetIsEnabled(true)
	local MaxLen = GroupGlobalCfg:GetValueByType(ProtoRes.GroupGlobalConfigType.GroupGlobalConfigType_MaxMemberCategoryNameLen)
	self.InputBoxName:SetMaxNum(MaxLen)
end

--设置横版页签
function ArmyMemberClassEditPowerPageView:SetMenuShow()
	local SelectMenuIndex =  self.ToggleTabs:GetSelectedIndex() or 1
	self.ToggleTabs:CancelSelected()
	local CurCategoryID = ArmyMemEditPowerPageVM:GetCurCategoryID()
	local IsEditMember =  false
	IsEditMember =  ArmyMgr:GetSelfIsHavePermisstion( GroupPermissionType.GROUP_PERMISSION_TYPE_SetMemberCategory)

	--- 部队长无法编辑成员
	if CurCategoryID == ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_PRESIDENT or nil == IsEditMember then
		local MenuListDataTemp = table.clone(MenuListData)
		MenuListDataTemp[3] = nil
		if SelectMenuIndex == 3 then
			SelectMenuIndex = 1
		end
		self.ToggleTabs:UpdateItems(MenuListDataTemp, SelectMenuIndex)
	else
		self.ToggleTabs:UpdateItems(MenuListData, SelectMenuIndex)
	end
end

--- 设置排列按钮
function ArmyMemberClassEditPowerPageView:SetSortBtn()
	local SelectedIndex = ArmyMemEditPowerPageVM:GetSelectedCategoryIndex()
	local CurCategoryNum = ArmyMemEditPowerPageVM:GetCurCategoryNum()
	---调换位置，部队长、第二级不能上调
	if SelectedIndex <= 2 then
		self.BtnUp:SetRenderOpacity(0.4)
	else
		self.BtnUp:SetRenderOpacity(1.0)
	end
	---调换位置，倒数第一、部队长不能下调
	if SelectedIndex <= 1 or SelectedIndex >= CurCategoryNum then
		self.BtnDown:SetRenderOpacity(0.4)
	else
		self.BtnDown:SetRenderOpacity(1.0)
	end
end

--- 设置保存按钮状态
function ArmyMemberClassEditPowerPageView:OnSaveBtnStateChanged(IsSaveBtnEnabled)
	--self.BtnSaveBack.SetIsEnabled(IsSaveBtnEnabled)
	if IsSaveBtnEnabled then
		self.BtnSaveBack:SetIsRecommendState(true)
	else
		self.BtnSaveBack:SetIsDisabledState(true, true)
	end
end

--- 设置删除阶级按钮状态
function ArmyMemberClassEditPowerPageView:OnDeleteBtnStateChanged(IsSaveBtnEnabled)
	--self.BtnSaveBack.SetIsEnabled(IsSaveBtnEnabled)
	if IsSaveBtnEnabled then
		self.BtnDelete:SetIsNormalState(true)
	else
		self.BtnDelete:SetIsDisabledState(true, true)
	end
end

--------------------------------- 响应 start ------------------------------------
---关闭界面
function ArmyMemberClassEditPowerPageView:OnClickedBtnBack()
    UIViewMgr:HideView(UIViewID.ArmyCategoryEditPanel)
	ArmyMemEditPowerPageVM:OpenArmyPanel()
end

---修改名字·
function ArmyMemberClassEditPowerPageView:OnCategoryNameTextCommitted(Text, CommitMethod)
	self.IsInput = false
	self.IsWaitCheck = true
	--- 长度检测 ，max由输入框处理，这边只处理判空
	if Text == "" then
        -- LSTR string:分组名不能为空
        MsgTipsUtil.ShowTips(LSTR(910061))
		ArmyMemEditPowerPageVM:SetIsErrorName(true, nil, true)
		self.IsWaitCheck = false
		return
	end
	local Categories = ArmyMemEditPowerPageVM:GetCurCategories()
	local SelectedIndex = ArmyMemEditPowerPageVM:GetSelectedCategoryIndex()
	--- 输入未变化
	if Text == Categories[SelectedIndex].Name then
		self.IsWaitCheck = false
		self:OnSaveBtnStateChanged(ArmyMemEditPowerPageVM:GetIsSaveBtnEnabled())
		return
	end
	--- 变化检测
	if Text == Categories[SelectedIndex].OldName then
		ArmyMemEditPowerPageVM:SetIsNameChange(false)
		Categories[SelectedIndex].Name = Text
		ArmyMemEditPowerPageVM:UpdateCategoryList()
		--ArmyMemEditPowerPageVM:SetIsSaveBtnEnabled(false)
		self.IsWaitCheck = false
		return
	end
	--- 重名检测
	for _, CategoryData in ipairs(Categories) do
		if CategoryData.Name ==  Text then
			-- LSTR string:已有分组名
			MsgTipsUtil.ShowTips(LSTR(910109))
			ArmyMemEditPowerPageVM:SetIsErrorName(true, nil, false)
			self.IsWaitCheck = false
			return
		end
	end
	---查询文本是否合法（敏感词）
	ArmyMgr:CheckSensitiveText(Text, function( IsLegal )
		self.IsWaitCheck = false
		if IsLegal then
			ArmyMemEditPowerPageVM:SetIsErrorName(false)
			Categories[SelectedIndex].Name = Text
			ArmyMemEditPowerPageVM:SetIsNameChange(true)
			ArmyMemEditPowerPageVM:UpdateCategoryList()
			self.TableViewCategoryAdapter:SetSelectedIndex(SelectedIndex)
		else
			-- LSTR string:当前文本不可使用，请重新输入
			MsgTipsUtil.ShowErrorTips(LSTR(10057))
		end
	end)
end

function ArmyMemberClassEditPowerPageView:OnTextFocusReceived()
	self.IsInput = true
	self.BtnSaveBack:SetIsDisabledState(true, true)
end

--- Tab切换
---@param Index number @下标 从0开始
function ArmyMemberClassEditPowerPageView:OnGroupTabsSelectionChanged(Index, ItemData, ItemView)
	ArmyMemEditPowerPageVM:SetRightPanelShow(Index)
	self:PlayANimation(self.AnimChangeTab)
end

---分组切换响应
function ArmyMemberClassEditPowerPageView:OnCategorySelectChanged(Index, ItemData, ItemView)
	if ItemData.ID == -1 then
		---新增分组
		ArmyMemEditPowerPageVM:AddCategory()
		local SelectedIndex = ArmyMemEditPowerPageVM:GetSelectedCategoryIndex()
		self.TableViewCategoryAdapter:SetSelectedIndex(SelectedIndex)
        return
    end
	ArmyMemEditPowerPageVM:OnCategorySelectChanged(Index, ItemData, ItemView)
	self:PlayAnimation(self.AnimChangePower)
	---分组名修改框设置
	self:SetInputBoxNameData()
	---设置横版页签
	self:SetMenuShow()
	--- 设置排列按钮
	self:SetSortBtn()
end

---向上移动分组
function ArmyMemberClassEditPowerPageView:OnClickedBtnUp()
	local SelectedIndex = ArmyMemEditPowerPageVM:GetSelectedCategoryIndex()
	--local CurCategoryNum = ArmyMemEditPowerPageVM:GetCurCategoryNum()
	local Categories = ArmyMemEditPowerPageVM:GetCurCategories()
	---调换位置，第二级不能调
	if SelectedIndex > 2 then
		local CategoryDataTemp = Categories[SelectedIndex]
		Categories[SelectedIndex] = Categories[SelectedIndex - 1]
		Categories[SelectedIndex - 1] = CategoryDataTemp
		ArmyMemEditPowerPageVM:UpdateCategoryList()
		self.TableViewCategoryAdapter:SetSelectedIndex(SelectedIndex - 1)
		ArmyMemEditPowerPageVM:CheckOrderChange()
	end
end

---向下移动分组
function ArmyMemberClassEditPowerPageView:OnClickedBtnDown()
	local SelectedIndex = ArmyMemEditPowerPageVM:GetSelectedCategoryIndex()
	local CurCategoryNum = ArmyMemEditPowerPageVM:GetCurCategoryNum()
	local Categories = ArmyMemEditPowerPageVM:GetCurCategories()
	---调换位置，倒数第一级不能调
	if SelectedIndex > 1 and SelectedIndex < CurCategoryNum then
		local CategoryDataTemp = Categories[SelectedIndex]
		Categories[SelectedIndex] = Categories[SelectedIndex + 1]
		Categories[SelectedIndex + 1] = CategoryDataTemp
		ArmyMemEditPowerPageVM:UpdateCategoryList()
		self.TableViewCategoryAdapter:SetSelectedIndex(SelectedIndex + 1)
		ArmyMemEditPowerPageVM:CheckOrderChange()
	end
end

-- --- 组员分组调整
-- function ArmyMemberClassEditPowerPageView:OnClickedItem(ItemData)
--     local Params = ItemData
-- 	if nil ~= Params then
-- 		local CategoryID = ItemData.Data.ID
-- 		if not Params.IsSelected then
-- 			ArmyMgr:SendArmySetMemberCategoryMsg(ItemData.Data.RoleIDs, CategoryID)
-- 		end
-- 	end
	
--     if UIViewMgr:IsViewVisible(UIViewID.CommJumpWayTipsView) then
--         UIViewMgr:HideView(UIViewID.CommJumpWayTipsView)
--     end
-- end

---权限Item点击
function ArmyMemberClassEditPowerPageView:OnClickedPermisstionItem(Index, ItemData, ItemView)
	if not ItemData.bCanEdit then
		return
	end
	--local Categories = ArmyMemEditPowerPageVM:GetCurCategories()
	local SelectedIndex = ArmyMemEditPowerPageVM:GetSelectedCategoryIndex()
	local PermisstionType = ItemData.PermssionData.Type
	---权限添加 or 删除 ,需要重复判断
	ArmyMemEditPowerPageVM:PermisstionTypeDataChange(SelectedIndex, PermisstionType, not ItemData.bChecked)
	ItemData.bChecked =  not ItemData.bChecked
end

---分组图片选择
function ArmyMemberClassEditPowerPageView:OnCategoryIconSelectChanged(Index, ItemData, ItemView)
	ArmyMemEditPowerPageVM:OnCategoryIconSelectChanged(Index, ItemData, ItemView)
	--local SelectedIndex = ArmyMemEditPowerPageVM:GetSelectedCategoryIndex()
	--self.TableViewCategoryAdapter:SetSelectedIndex(SelectedIndex)
end

---保存修复并发送
function ArmyMemberClassEditPowerPageView:OnClickedSave()
	if self.IsWaitCheck or self.IsInput then
		MsgTipsUtil.ShowTipsByID(ArmyDefine.ArmyTipsID.InputCheck)
		return
	end
	if ArmyMemEditPowerPageVM:GetIsSaveBtnEnabled() then
		MsgBoxUtil.ShowMsgBoxTwoOp(
			self,
			-- LSTR string:确认保存修改
			LSTR(910186),
			-- LSTR string:确认保存本次修改？
			LSTR(910187),
			self.SaveAndSendData,
			nil,
			-- LSTR string:取消
			LSTR(910083),
			-- LSTR string:确定
			LSTR(910182)
		)
	else
		local SaveErrorStr = ArmyMemEditPowerPageVM:GetSaveErrorStr()
		if SaveErrorStr and SaveErrorStr ~= "" then
		MsgTipsUtil.ShowTips(SaveErrorStr)
		end
	end
	--ArmyMemEditPowerPageVM:SaveAndSendData()
end

function ArmyMemberClassEditPowerPageView:SaveAndSendData()
	ArmyMemEditPowerPageVM:SaveAndSendData()
end

---删除分组
function ArmyMemberClassEditPowerPageView:OnClickedDel()
	local Categories = ArmyMemEditPowerPageVM:GetCurCategories()
	if Categories == nil then
		return
	end
	---最小人数
	local MinNum = ArmyMgr:GetDefaultCategoryNum()

	local CurCategoryID = ArmyMemEditPowerPageVM:GetCurCategoryID()
	if CurCategoryID == ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_PRESIDENT then
		-- LSTR string:部队长分组不能删除
		MsgTipsUtil.ShowTips(LSTR(910265))
		return
	--- 最少分组数量配置
	elseif #Categories <= MinNum then
		-- LSTR string:分组不能少于两个
		MsgTipsUtil.ShowTips(LSTR(910059))
		return
	end
	local CurMemberList = ArmyMemEditPowerPageVM:GetCurMemberList()
	local CurCategoryName = ArmyMemEditPowerPageVM:GetCurCategoryName()
	local DelStr = ""
	if nil == CurMemberList or table.is_nil_empty(CurMemberList) then
		-- LSTR string:确认删除分组%s吗？在保存修改前这些变化不会正式生效
		DelStr = string.format(LSTR(910189),RichTextUtil.GetText(CurCategoryName,  ArmyTextColor.YellowHex))
	else
		--local CurCategoryID = ArmyMemEditPowerPageVM:GetCurCategoryID()
		local Len = #Categories
		local Name = ""
		if Categories and #Categories > 0 then
			if Categories[Len].ID == CurCategoryID then
				Name = Categories[Len - 1].Name
			else
				Name = Categories[Len].Name
			end
		end
		-- LSTR string:分组内仍有组员，现在删除将自动移动组员至分组%s。在保存修改前这些变化不会正式生效
		DelStr = string.format(LSTR(910060),RichTextUtil.GetText(Name,  ArmyTextColor.YellowHex))
	end

	MsgBoxUtil.ShowMsgBoxTwoOp(
        self,
        -- LSTR string:刪除分组
        LSTR(910074),
        DelStr,
        self.DelCurCategory,
        nil,
        -- LSTR string:取消删除
        LSTR(910084),
        -- LSTR string:确定删除
        LSTR(910183)
    )
end

function ArmyMemberClassEditPowerPageView:DelCurCategory()
	ArmyMemEditPowerPageVM:DelCurCategory()
	local SelectedIndex = ArmyMemEditPowerPageVM:GetSelectedCategoryIndex()
	self.TableViewCategoryAdapter:SetSelectedIndex(SelectedIndex)
end


--- 批量切换成员阶级
function ArmyMemberClassEditPowerPageView:OnClickedBtnSwitch()
	local RoleIDs = ArmyMemEditPowerPageVM:GetSelectedMemberList()
	ArmyMemEditPowerPageVM:OnClickedSwitchCategory(RoleIDs, self.BtnSwitch)
end

--- 成员选中
function ArmyMemberClassEditPowerPageView:OnClickedMemberEditCategoryItem(Index, ItemData, ItemView)
	ItemData.bChecked = not ItemData.bChecked
	if ItemData.bChecked then
		ArmyMemEditPowerPageVM:AddMembertoSelectedMemberList(ItemData.RoleID)
		-- if ArmyMemEditPowerPageVM:GetIsAllMemberSelected() then
		-- 	self.SingleBoxAll:SetChecked(true, false)
		-- end
	else
		ArmyMemEditPowerPageVM:DelMembertoSelectedMemberList(ItemData.RoleID)
		--self.SingleBoxAll:SetChecked(false, false)
	end
	ArmyMemEditPowerPageVM:UpdataAllSelectedData()
end

function ArmyMemberClassEditPowerPageView:AllSelectedCallback(ToggleButton, IsChecked)
	local AllChecked
	if IsChecked == 0 then
		AllChecked = false
	else
		AllChecked = true
	end
	ArmyMemEditPowerPageVM:AllMemberSelected(AllChecked)
end

function ArmyMemberClassEditPowerPageView:OnUpdataMenuList(UpdataMenuList)
	if UpdataMenuList then
		self:SetMenuShow()
		ArmyMemEditPowerPageVM.UpdataMenuList = false
	end
end

function ArmyMemberClassEditPowerPageView:OnAllMemberSelectedChanged(IsAll)
	self.SingleBoxAll:SetChecked(IsAll, false)
end

function ArmyMemberClassEditPowerPageView:OnGrandCompanyTypeChange(GrandCompanyType)
    ---  部队背景动画处理
    if GrandCompanyType == ArmyDefine.GrandCompanyType.HeiWo then
        self:PlayAnimation(self.AnimBGID1)
    elseif GrandCompanyType == ArmyDefine.GrandCompanyType.ShuangShe then
        self:PlayAnimation(self.AnimBGID2)
    elseif GrandCompanyType == ArmyDefine.GrandCompanyType.HengHui then
        self:PlayAnimation(self.AnimBGID3)
    end
end
--------------------------------- 响应 end ------------------------------------

return ArmyMemberClassEditPowerPageView