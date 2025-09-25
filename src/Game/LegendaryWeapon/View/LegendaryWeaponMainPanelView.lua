--- 创建时间: 2024-01-10 15:36 ---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local MajorUtil = require("Utils/MajorUtil")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local RenderActorPath = ModelDefine.StagePath.Universe
local ItemCfg = require("TableCfg/ItemCfg")
local CommonUtil = require("Utils/CommonUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local EquipPart = ProtoCommon.equip_part
local EventID = require("Define/EventID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local DataReportUtil = require("Utils/DataReportUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LegendaryWeaponMainPanelVM = require("Game/LegendaryWeapon/VM/LegendaryWeaponMainPanelVM")
local LegendaryWeaponMgr = require("Game/LegendaryWeapon/LegendaryWeaponMgr")
local LegendaryWeaponDefine = require("Game/LegendaryWeapon/LegendaryWeaponDefine")
local SystemLightCfg = require("TableCfg/SystemLightCfg")
local EquipmentType = ProtoRes.EquipmentType
local TipsUtil = require("Utils/TipsUtil")
local ShopMgr = require("Game/Shop/ShopMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LightMgr = require("Game/Light/LightMgr")
local ActorUtil = require("Utils/ActorUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EquipmentMgr = _G.EquipmentMgr
local UCommonUtil = _G.UE.UCommonUtil
local LSTR = _G.LSTR

---@class LegendaryWeaponMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnArchive UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnCraft CommBtnLView
---@field BtnPose UToggleButton
---@field BtnStore UFButton
---@field CommGesture_UIBP CommGestureView
---@field CommTabs_UIBP CommTabsView
---@field CommTabs_UIBP_1 CommTabsView
---@field CommonTitle CommonTitleView
---@field Common_Render2D_UIBP CommonRender2DView
---@field Common_Render2D_UIBP_1 CommonRender2DView
---@field DropDownList CommDropDownListView
---@field EFF_Activate UFCanvasPanel
---@field FCanvasPanel1 UFCanvasPanel
---@field Material1 LegendaryWeaponMaterialItemView
---@field Material2 LegendaryWeaponMaterialItemView
---@field Material3 LegendaryWeaponMaterialItemView
---@field Material4 LegendaryWeaponMaterialItemView
---@field Material5 LegendaryWeaponMaterialItemView
---@field Material6 LegendaryWeaponMaterialItemView
---@field Material7 LegendaryWeaponMaterialItemView
---@field Material8 LegendaryWeaponMaterialItemView
---@field MaterialPage LegendaryWeaponMaterialPageView
---@field PanelCraftGuide UFCanvasPanel
---@field PanelIconTab UFCanvasPanel
---@field PanelLeft UFCanvasPanel
---@field PanelMaterial UFCanvasPanel
---@field PanelMaterial1 UFCanvasPanel
---@field PanelMaterial2 UFCanvasPanel
---@field PanelMaterial3 UFCanvasPanel
---@field PanelMaterial4 UFCanvasPanel
---@field PanelMaterial5 UFCanvasPanel
---@field PanelMaterial6 UFCanvasPanel
---@field PanelMaterial7 UFCanvasPanel
---@field PanelMaterial8 UFCanvasPanel
---@field PanelModel UFCanvasPanel
---@field PanelProbar UFCanvasPanel
---@field PanelRight UFCanvasPanel
---@field PanelStat UFCanvasPanel
---@field PanelStatSwitch UFCanvasPanel
---@field PanelTop UFCanvasPanel
---@field PanelTopRight UFCanvasPanel
---@field RaidalCD URadialImage
---@field ScalePanel UFCanvasPanel
---@field ScrollBoxCraftGuide UScrollBox
---@field TableViewPages UTableView
---@field TableViewStat1 UTableView
---@field TableViewStat2 UTableView
---@field TextCraftGuide UFTextBlock
---@field TextCraftTips UFTextBlock
---@field TextLevel UFTextBlock
---@field TextRightTitle UFTextBlock
---@field ToggleBtnShowState UToggleButton
---@field VerIconTabs CommVerIconTabsView
---@field VerticalShowBtns UFVerticalBox
---@field AnimIn UWidgetAnimation
---@field AnimMake UWidgetAnimation
---@field AnimMaterialIn UWidgetAnimation
---@field AnimNext UWidgetAnimation
---@field AnimRefresh UWidgetAnimation
---@field AnimReturn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponMainPanelView = LuaClass(UIView, true)

function LegendaryWeaponMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnArchive = nil
	--self.BtnClose = nil
	--self.BtnCraft = nil
	--self.BtnPose = nil
	--self.BtnStore = nil
	--self.CommGesture_UIBP = nil
	--self.CommTabs_UIBP = nil
	--self.CommTabs_UIBP_1 = nil
	--self.CommonTitle = nil
	--self.Common_Render2D_UIBP = nil
	--self.Common_Render2D_UIBP_1 = nil
	--self.DropDownList = nil
	--self.EFF_Activate = nil
	--self.FCanvasPanel1 = nil
	--self.Material1 = nil
	--self.Material2 = nil
	--self.Material3 = nil
	--self.Material4 = nil
	--self.Material5 = nil
	--self.Material6 = nil
	--self.Material7 = nil
	--self.Material8 = nil
	--self.MaterialPage = nil
	--self.PanelCraftGuide = nil
	--self.PanelIconTab = nil
	--self.PanelLeft = nil
	--self.PanelMaterial = nil
	--self.PanelMaterial1 = nil
	--self.PanelMaterial2 = nil
	--self.PanelMaterial3 = nil
	--self.PanelMaterial4 = nil
	--self.PanelMaterial5 = nil
	--self.PanelMaterial6 = nil
	--self.PanelMaterial7 = nil
	--self.PanelMaterial8 = nil
	--self.PanelModel = nil
	--self.PanelProbar = nil
	--self.PanelRight = nil
	--self.PanelStat = nil
	--self.PanelStatSwitch = nil
	--self.PanelTop = nil
	--self.PanelTopRight = nil
	--self.RaidalCD = nil
	--self.ScalePanel = nil
	--self.ScrollBoxCraftGuide = nil
	--self.TableViewPages = nil
	--self.TableViewStat1 = nil
	--self.TableViewStat2 = nil
	--self.TextCraftGuide = nil
	--self.TextCraftTips = nil
	--self.TextLevel = nil
	--self.TextRightTitle = nil
	--self.ToggleBtnShowState = nil
	--self.VerIconTabs = nil
	--self.VerticalShowBtns = nil
	--self.AnimIn = nil
	--self.AnimMake = nil
	--self.AnimMaterialIn = nil
	--self.AnimNext = nil
	--self.AnimRefresh = nil
	--self.AnimReturn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnCraft)
	self:AddSubView(self.CommGesture_UIBP)
	self:AddSubView(self.CommTabs_UIBP)
	self:AddSubView(self.CommTabs_UIBP_1)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.Common_Render2D_UIBP)
	self:AddSubView(self.Common_Render2D_UIBP_1)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.Material1)
	self:AddSubView(self.Material2)
	self:AddSubView(self.Material3)
	self:AddSubView(self.Material4)
	self:AddSubView(self.Material5)
	self:AddSubView(self.Material6)
	self:AddSubView(self.Material7)
	self:AddSubView(self.Material8)
	self:AddSubView(self.MaterialPage)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponMainPanelView:OnInit()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_LEGEND_WEAPON, true) then
		return
	end

	-- self:SetCurrentIndexToToggleGroup()
	self.AdapterChapterTabList = UIAdapterTableView.CreateAdapter(self, self.TableViewPages)
	self.AdapterLAttrList = UIAdapterTableView.CreateAdapter(self, self.TableViewStat1)
	self.AdapterSAttrList = UIAdapterTableView.CreateAdapter(self, self.TableViewStat2)
	self.viewModel = LegendaryWeaponMainPanelVM
	self.TimerMaps = {}
	self.TopicIndex = 1
	-- self.SelectedTabIndex = 1
	self.Binders = {
		{"WeaponDesc", UIBinderSetText.New(self, self.TextCraftGuide)},
		{"IsComposeMode", UIBinderSetIsVisible.New(self, self.PanelMaterial) },
		{"IsComposeMode", UIBinderSetIsVisible.New(self, self.VerticalShowBtns, true) },
		{"IsComposeMode", UIBinderSetIsVisible.New(self, self.PanelStat) },
		{"IsComposeMode", UIBinderSetIsVisible.New(self, self.PanelCraftGuide, true) },
		{"IsShowWeaponModel", UIBinderValueChangedCallback.New(self, nil, self.SetShowWeaponModel) },
		{"SelectWeaponID", UIBinderValueChangedCallback.New(self, nil, self.SetSelectWeaponID) },
		{"CameraFOV", UIBinderValueChangedCallback.New(self, nil, self.SetFieldOfView) },
	}
end

function LegendaryWeaponMainPanelView:OnShow()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_LEGEND_WEAPON, true) then
		print(" ========= 【光武界面未激活】 ======== ")
		return
	end
	if self.BtnArchive then
		UIUtil.SetIsVisible(self.BtnArchive, false)			--光武图鉴不做了
	end
	if self.FCanvasPanel1 then
		UIUtil.SetIsVisible(self.FCanvasPanel1, true)		--显示界面UI
	end
	self.viewModel:OnShow()
	UCommonUtil.OpenWaitForLegendaryWeaponTextureMips()
	self.CommonTitle.CommInforBtn.HelpInfoID = 11183
	self.bHoldWeapon = false
	self.bIsFirstWeapon = true
	LightMgr:EnableUIWeather(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_LEGENDARY_WEAPON)
	self:ShowPlayerWeaponActor()							--创建角色
	self:LoadSceneActor()  									--创建场景
	if self.Params then
		self:OnTLog(self.Params)
		self.IsGoToItemID = self.Params.ItemID
		if self.IsGoToItemID then
			--途径跳转
			self.viewModel:GoToWeaponByItemID(self.Params.ItemID)
		else
			--默认位置
			self:SetDropDownListIndex()
			self:SetChapterID()
		end
	end
	
	self.TopicTabList = self.viewModel:GetTopicTabList()	--更新主题
	self.VerIconTabs:UpdateItems(self.TopicTabList, self.viewModel.TopicID)
	--self:ShowWeaponModel()
	self:RefreshComposePanel()
	self.DropDownList:SetForceTrigger(true)
	LegendaryWeaponMgr:BindCommGesture(self.CommGesture_UIBP)
	self:PlayAnimation(self.AnimIn)
	_G.BuoyMgr:ShowAllBuoys(false)
	_G.HUDMgr:SetIsDrawHUD(false)
	_G.HUDMgr:HideAllActors()
end

function LegendaryWeaponMainPanelView:OnHide()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_LEGEND_WEAPON, true) then
		return
	end
	local CameraMgr = _G.UE.UCameraMgr.Get()
	if CameraMgr ~= nil then
		if CommonUtil.IsObjectValid(self.viewModel.BP_SceneActor) then
			CameraMgr:ResumeCamera(0, true, self.viewModel.BP_SceneActor)
		else
			print("[LegendaryWeaponMainPanelView] OnHide BP_SceneActor is nil ")
		end
	end
	self:ShowWeaponVFX(false)
	if self.WeaponActor ~= nil then
		_G.UE.UActorManager:Get():RemoveClientActor(self.WeaponActor:GetActorEntityID())
	end
	if self.SubWeaponActor ~= nil then
		_G.UE.UActorManager:Get():RemoveClientActor(self.SubWeaponActor:GetActorEntityID())
	end
	UCommonUtil.CloseWaitForLegendaryWeaponTextureMips()
	self.LastLoadWeapon = nil
	self.WeaponActorRef = nil
	self.WeaponActor = nil
	self.SubWeaponActorRef = nil
	self.SubWeaponActor = nil
	self.viewModel.BP_SceneActor = nil
	self.viewModel.Render2DActor = nil
	if self.Common_Render2D_UIBP_1.RenderActor ~= nil then
		self.Common_Render2D_UIBP_1.RenderActor:Destroy()
	end
	LightMgr:DisableUIWeather()
	local UActorManager = _G.UE.UActorManager.Get()
	if self.CreatedNPCEntityID ~= nil then
		UActorManager:RemoveClientActor(self.CreatedNPCEntityID)
		self.CreatedNPCEntityID = nil
	end
	if self.CreatedSubNPCEntityID ~= nil then
		UActorManager:RemoveClientActor(self.CreatedSubNPCEntityID)
		self.CreatedSubNPCEntityID = nil
	end
	self.Common_Render2D_UIBP:SwitchOtherLights(true)
	self.viewModel.ChapterID = nil

	for _, Timer in pairs(self.TimerMaps) do
		if Timer then
			_G.TimerMgr:CancelTimer(Timer)
		end
	end
	self.TimerMaps = {}
	if self.ShowVFXTimerID ~= 0 then
		_G.TimerMgr:CancelTimer(self.ShowVFXTimerID)
	end
	self.ShowVFXTimerID = 0
	if self.WeaponPoseTimerID ~= 0 then
		_G.TimerMgr:CancelTimer(self.WeaponPoseTimerID)
	end
	self.WeaponPoseTimerID = 0
	if self.CompletionEndTimerID then
		_G.TimerMgr:CancelTimer(self.CompletionEndTimerID)
		self.CompletionEndTimerID = nil
	end
	if self.TimerHandle ~= nil then
		self:UnRegisterTimer(self.TimerHandle)
		self.TimerHandle = nil
	end
	_G.BuoyMgr:ShowAllBuoys(true)
	_G.HUDMgr:SetIsDrawHUD(true)
	_G.HUDMgr:ShowAllActors()
end

function LegendaryWeaponMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnTabSelectChanged)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnShowState, self.OnClickedButtonShow)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnSelectionChangedDropDownList)
	-- UIUtil.AddOnStateChangedEvent(self, self.CommTabs_UIBP, self.OnToggleGroupCheckChanged)
	-- UIUtil.AddOnClickedEvent(self, self.ToggleBtnItem1, self.OnToggleBtnItem1Click)
	-- UIUtil.AddOnClickedEvent(self, self.ToggleBtnItem2, self.OnToggleBtnItem2Click)
	UIUtil.AddOnClickedEvent(self, self.BtnCraft.Button, self.OnBtnCraftClick)
	UIUtil.AddOnClickedEvent(self, self.BtnStore, self.OnBtnStoreClick)
	UIUtil.AddOnClickedEvent(self, self.BtnPose, self.OnBtnPoseClick)
	-- self.BtnInfor:SetCallback(self, self.OnInforBtnClickHelp)
	self.BtnClose:SetCallback(self, self.OnClickButtonClose)
	self.CommTabs_UIBP:SetCallBack(self, self.OnToggleGroupCheckChanged)
	self.CommTabs_UIBP_1:SetCallBack(self, self.OnToggleGroupCheckChanged1)
end

function LegendaryWeaponMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(EventID.LegendaryChapterItemClick, self.OnChapterItemClick)
	self:RegisterGameEvent(EventID.BagUpdate, self.RefreshComposePanel)
	self:RegisterGameEvent(EventID.LegendaryMatItemClick, self.OnMatItemClick)
	self:RegisterGameEvent(EventID.LegendaryCompletionStatus, self.SetBtnCompletionText)
	self:RegisterGameEvent(EventID.LegendaryPlayCompletionAnim, self.PlayAnimMake)	--开始制作
	self:RegisterGameEvent(EventID.LegendaryCompletionEnd, self.CompletionEnd)		--结束制作
end

function LegendaryWeaponMainPanelView:OnRegisterBinder()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_LEGEND_WEAPON, true) then
		return
	end

	self:RegisterBinders(self.viewModel, self.Binders)
end

-- 在显示状态
function LegendaryWeaponMainPanelView:OnActive()
	if (self.viewModel.IsShowWeaponModel == true) and CommonUtil.IsObjectValid(self.WeaponActor) then
		self.WeaponActor:HideMasterHand(false)		--显示武器false
		self:ShowWeaponVFX(true)
	end
	if (self.viewModel.IsShowWeaponModel == true) and self.viewModel.SelectSubWeaponID ~= 0 and CommonUtil.IsObjectValid(self.SubWeaponActor) then
		self.SubWeaponActor:HideMasterHand(false)
	end
	if self.IsCraf == true then
		LightMgr:EnableUIWeather(ProtoRes.SYSTEM_LIGHT_ID.SYSTEM_LIGHT_ID_LEGENDARY_WEAPON)
		self.IsCraf = nil
	end

	if UCommonUtil.IsObjectValid(self.viewModel.BP_SceneActor) then
		local CameraMgr = _G.UE.UCameraMgr.Get()
		if CameraMgr then
			CameraMgr:SwitchCamera(self.viewModel.BP_SceneActor, 0)   --重新切换相机为传奇武器场景
		end
	end
end

-- 不活跃状态
function LegendaryWeaponMainPanelView:OnInactive()
	if (self.viewModel.IsShowWeaponModel == true) and CommonUtil.IsObjectValid(self.WeaponActor) then
		self.WeaponActor:HideMasterHand(true)		--隐藏武器true
		self:ShowWeaponVFX(false)
	end
	if (self.viewModel.IsShowWeaponModel == true) and self.viewModel.SelectSubWeaponID ~= 0 and CommonUtil.IsObjectValid(self.SubWeaponActor) then
		self.SubWeaponActor:HideMasterHand(true)
	end
	if UIViewMgr:IsViewVisible(UIViewID.CraftingLog) then
		self.IsCraf = true
		LightMgr:DisableUIWeather()
	end

end

function LegendaryWeaponMainPanelView:OnClickedButtonShow()
	self.viewModel.IsShowWeaponModel = not self.viewModel.IsShowWeaponModel
	if self.viewModel.IsShowWeaponModel == true then
		self.ToggleBtnShowState:SetCheckedState(_G.UE.EToggleButtonState.Unchecked, false)
	else
		self.ToggleBtnShowState:SetCheckedState(_G.UE.EToggleButtonState.checked, false)
	end
end

--- 切换武器/角色
function LegendaryWeaponMainPanelView:SetShowWeaponModel(flag)
	if flag == true then
		-- 显示武器
		if self.BtnPose then
			if self.bHoldWeapon == true then
				self:OnBtnPoseClick()
				self.BtnPose:SetChecked(false, true)
			end
			UIUtil.SetIsVisible(self.BtnPose, false)
		end
		UIUtil.SetIsVisible(self.CommGesture_UIBP, true, true)
		self.Common_Render2D_UIBP:HidePlayer(true)	--隐藏角色
		self.Common_Render2D_UIBP:HoldOnWeapon(false)	--切换到武器时，角色姿势会影响武器显示效果
		self.Common_Render2D_UIBP:SetCanRotate(false)
		self:StartLoadWeaponModel()

		--LegendaryWeaponMgr:PlaySequence4(true)		  --（策划说需求变更：切换武器不再旋转）

	else
		-- 显示角色
		LegendaryWeaponMgr:SetFade(self.Common_Render2D_UIBP.ChildActor, 0.8, true, 0, true)
		UIUtil.SetIsVisible(self.BtnPose, true, true)
		UIUtil.SetIsVisible(self.CommGesture_UIBP, false, false, false)

		if CommonUtil.IsObjectValid(self.WeaponActor) then
			self.WeaponActor:HideMasterHand(true)		--隐藏武器
			self:ShowWeaponVFX(false)
		end
		if CommonUtil.IsObjectValid(self.SubWeaponActor) then
			self.SubWeaponActor:HideMasterHand(true)	--隐藏子武器
		end
		self.Common_Render2D_UIBP:HidePlayer(false)
		self.Common_Render2D_UIBP:SetCanRotate(true)
		if self.bIsFirstWeapon then
			self.bIsFirstWeapon = false
			self:PreViewEquipment(self.viewModel.SelectWeaponID, EquipPart.EQUIP_PART_MASTER_HAND, 0)
			if self.viewModel.SelectSubWeaponID ~= 0 then
				self:PreViewEquipment(self.viewModel.SelectSubWeaponID, EquipPart.EQUIP_PART_SLAVE_HAND, 0)
			end
		end
		self:SetWeaponTransform()
	end
end

--- 切换主题
function LegendaryWeaponMainPanelView:OnTabSelectChanged(Index, ItemData, ItemView)
	if self.TopicTabList and self.TopicTabList[Index] and self.TopicTabList[Index].IsLock then
		MsgTipsUtil.ShowTips(LSTR(220016))	--"完成主题任务后解锁"
		self.VerIconTabs:SetSelectedIndex(self.TopicIndex)
		if Index ~= 1 then return end
	else
		self.TopicIndex = Index
	end
	
	local TopicTabInfo = self.TopicTabList and self.TopicTabList[Index] or nil
	self.TopicTabInfo = TopicTabInfo
	if TopicTabInfo then
		self.CommonTitle.TextSubtitle:SetText(TopicTabInfo.Name)
		self.viewModel.TopicID = TopicTabInfo.ID
	end
	self.ChapterList = self.viewModel:GetChapterList(Index)
	self.AdapterChapterTabList:UpdateAll(self.ChapterList)	--更新章节
 	--踩坑记录：上面UpdateAll更新列表时，会重新初始化新列表，若执行广播事件则旧View注册的事件会先执行，新列表此时尚未注册到该事件
	self.TimerMaps[#self.TimerMaps + 1] = _G.TimerMgr:AddTimer(self, function()
		if self.IsGoToItemID then
			self.IsGoToItemID = nil
		else
			self:SetChapterID()
		end
		local ChapterIndex = self.viewModel.ChapterID or 1
		_G.EventMgr:SendEvent(EventID.LegendaryChapterItemClick, ChapterIndex)
	end, 0.01, 0, 1)
end

--- 切换章节
function LegendaryWeaponMainPanelView:OnChapterItemClick(ID)
	self:PlayAnimMaterial(1)
	self.viewModel.ChapterID = ID	--第几章节
	self.DropDownList:SetForceTrigger(true)
	-- 更新下拉菜单
    self.ProfList = self.viewModel:GetProfList()
	local SelectIndex = self.viewModel.SelectWeaponIndex or 1
	if self.viewModel.DownListVMList then
    	self.viewModel.DownListVMList:UpdateByValues(self.ProfList)
		self.DropDownList:UpdateItems(self.viewModel.DownListVMList, SelectIndex)
	end
end

function LegendaryWeaponMainPanelView:OnMatItemClick(bIsSpecial, ItemID)
	self:PlayAnimation(self.AnimNext)
	UIUtil.SetIsVisible(self.PanelLeft, false)
	UIUtil.SetIsVisible(self.PanelMaterial, false)
	UIUtil.SetIsVisible(self.PanelRight, false)
	UIUtil.SetIsVisible(self.PanelTopRight, false)
	UIUtil.SetIsVisible(self.MaterialPage, true)
	self.viewModel.SelectItemID = ItemID
	self.MaterialPage:Setup(bIsSpecial, ItemID)
end

function LegendaryWeaponMainPanelView:CloseMatPanel()
	UIUtil.SetIsVisible(self.MaterialPage, false)
	UIUtil.SetIsVisible(self.PanelLeft, true)
	UIUtil.SetIsVisible(self.PanelMaterial, true)
	UIUtil.SetIsVisible(self.PanelRight, true)
	UIUtil.SetIsVisible(self.PanelTopRight, true)
	self.viewModel.MaterialResID = nil
	self:PlayAnimation(self.AnimReturn)
end

--- 切换武器、章节、职业时，变更为对应武器
function LegendaryWeaponMainPanelView:OnSelectionChangedDropDownList(Index)
	self.DropDownList:SetForceTrigger(false)
	self.viewModel:SelectWeapon(Index)
	self:RefreshComposePanel()
	self:PlayAnimMaterial(1)

	if self.ScrollBoxCraftGuide then
		self.ScrollBoxCraftGuide:ScrollToStart()
	end

	-- if self.viewModel.IsComposeMode then
	-- 	self:PlayRInterpToWeapon(true)
	-- else
	--  	LegendaryWeaponMgr:PlaySequence4(true)	  --（策划说需求变更：切换武器不再旋转）
	-- end
end

--- 打开界面时,继续切换到关闭前的位置（切换武器介绍界面1/材料球制作界面2）
-- function LegendaryWeaponMainPanelView:SetCurrentIndexToToggleGroup()
-- 	self.CommTabs_UIBP:SetSelectedIndex(LegendaryWeaponMgr.ToggleGroupIndex)
-- end

--- 切换展示武器/材料球制作界面
function LegendaryWeaponMainPanelView:OnToggleGroupCheckChanged(Index)
	if self.viewModel == nil then return end
	-- LegendaryWeaponMgr.ToggleGroupIndex = Index
	local bIsComposeMode = Index == 2
	self.viewModel.IsComposeMode = bIsComposeMode
	if bIsComposeMode then
		if not self.viewModel.IsShowWeaponModel then
			self:OnClickedButtonShow()
		end
	end
	LegendaryWeaponMgr.bEnableRotator = not bIsComposeMode
	self:PlayRInterpToWeapon(bIsComposeMode)
	self:PlayAnimMaterial(1)
	self:RefreshComposePanel()
end

--- 刷新材料界面
function LegendaryWeaponMainPanelView:RefreshComposePanel()
	self:SetNewRedDot()
	if self.viewModel.IsComposeMode then
		local Cfg = ItemCfg:FindCfgByKey(self.viewModel.SelectWeaponID)
		if Cfg then
			self.TextRightTitle:SetText(ItemCfg:GetItemName(self.viewModel.SelectWeaponID))
			self.TextLevel:SetText(string.format(LSTR(220017),Cfg.ItemLevel))	--"装备品级%d"
		end
		if self.viewModel.ProfInfo and self.PanelStatSwitch then
			local WeaponCfg = self.viewModel.ProfInfo.WeaponCfg
			local bHaveSubEquip = (WeaponCfg.SubEquipmentID ~= 0)
			UIUtil.SetIsVisible(self.PanelStatSwitch, bHaveSubEquip)
		end
		self.CommTabs_UIBP_1:SetSelectedIndex(1, true)
		self:RefreshCompletionStatus()
		self:RefreshMaterialList()
		self.CommonTitle.TextTitleName:SetText(LSTR(220059))		--"材料详情"
	else
		self.TextRightTitle:SetText(LSTR(220018))					--"武器制作指南"
		self.CommonTitle.TextTitleName:SetText(LSTR(220008))		--"传奇武器"
	end
end

--- 刷新材料信息
function LegendaryWeaponMainPanelView:RefreshMaterialList()
	if self.viewModel == nil then return end
	if self.viewModel.IsComposeMode == false then return end
	if self.viewModel.bIsCompletion == true then
		--已制作的武器不显示材料
		for i = 1, 8 do
			UIUtil.SetIsVisible(self["Material"..i], false)
			UIUtil.SetIsVisible(self["PanelMaterial"..i], false)
		end
		return
	else
		for i = 1, 8 do
			UIUtil.SetIsVisible(self["Material"..i], true)
			UIUtil.SetIsVisible(self["PanelMaterial"..i], true)
		end
	end
	if not self.viewModel or not self.viewModel.ProfInfo then
		return
	end
	local WeaponCfg = self.viewModel.ProfInfo.WeaponCfg
	local Count = 1
	local bHaveSpecial = (#WeaponCfg.SpecialItems > 0 and WeaponCfg.SpecialItems[1].ResID ~= 0)
	self.bHaveSpecial = bHaveSpecial
	UIUtil.SetIsVisible(self.Material2, true)
	self.Material2:SetData(true, WeaponCfg.SpecialItems, WeaponCfg.SpecialItemsIcon, self.RaidalCD)
	UIUtil.SetIsVisible(self.PanelProbar, bHaveSpecial)
	for _, ConsumeItem in pairs(WeaponCfg.ConsumeItems) do
		if Count == 2 then
			local bSpecialActivate = bHaveSpecial and self.viewModel:CheckSpecialMaterialEnough()
			UIUtil.SetIsVisible(self.EFF_Activate, bSpecialActivate)	-- 若魂晶数量满足时，显示特殊动效
			if bHaveSpecial then
				--print("LegendaryWeaponMainPanelView:RefreshMaterialList Special",Count)
				Count = Count + 1
			end
		end
		if ConsumeItem.ResID ~= 0 then
			--print("LegendaryWeaponMainPanelView:RefreshMaterialList Normal",Count)
			UIUtil.SetIsVisible(self["Material"..Count], true)
			UIUtil.SetIsVisible(self["PanelMaterial"..Count], true)
			self["Material"..Count]:SetData(false, ConsumeItem)
			Count = Count + 1
		end
	end
	for i=Count,8 do
		UIUtil.SetIsVisible(self["Material"..i], false)
		UIUtil.SetIsVisible(self["PanelMaterial"..i], false)
	end
end

--- 制作按钮 未获得
function LegendaryWeaponMainPanelView:RefreshNotCompletionStatus()
	if not self.BtnCraft then return end
	if not self.viewModel then return end
	local ChapterID = self.viewModel.ChapterID or 1		--第几章节
	if ChapterID == 1 then
		self.BtnCraft:SetText(LSTR(220020))	--"制  作"
	elseif ChapterID > 1 then
		self.BtnCraft:SetText(LSTR(220021))	--"强  化"
	end

	local bIsEnough = self.viewModel:CheckMaterialEnough()	--判断材料是否满足
	local bIsCanUse, TipsText = self:GetMajorSate()			--判断主角当前状态是否满足
	if bIsEnough then
		--材料满足时，判断特殊状态
		if bIsCanUse then
			self.BtnCraft:SetIsRecommendState(true)
			UIUtil.SetIsVisible(self.TextCraftTips, false)
		else
			self.BtnCraft:SetIsDisabledState(true, true)
			UIUtil.SetIsVisible(self.TextCraftTips, true)
			self.TextCraftTips:SetText(TipsText)
		end
	else
		--材料不满足时，优先显示材料不足
		self.BtnCraft:SetIsEnabled(true)
		self.BtnCraft:SetIsDisabledState(true, true)
		UIUtil.SetIsVisible(self.TextCraftTips, true)
		self.TextCraftTips:SetText(LSTR(220019))	--"材料不足"
	end
end

--- 制作按钮 已获得
function LegendaryWeaponMainPanelView:RefreshIsCompletionStatus()
	if not self.BtnCraft then return end
	if not self.viewModel then return end

	self.BtnCraft:SetIsDoneState(true)
	if self.viewModel.ChapterID == 1 then
		self.BtnCraft:SetText(LSTR(220022))	--"已获得"
	else
		self.BtnCraft:SetText(LSTR(220060))	--"已强化"
	end

	local Color = "#9B8888FF"
	self.BtnCraft:SetTextColorAndOpacityHex(Color)

	if self.TextCraftTips then
		UIUtil.SetIsVisible(self.TextCraftTips, false)
	end
end

--- 刷新制作按钮
function LegendaryWeaponMainPanelView:RefreshCompletionStatus()
	if self.viewModel == nil then return end
	if self.viewModel.IsComposeMode == false then return end

	local WeaponCfg = self.viewModel.WeaponCfg
	if WeaponCfg and WeaponCfg.ID then
		if LegendaryWeaponMgr.QueryList and LegendaryWeaponMgr.QueryList[WeaponCfg.ID] then
			-- 已获得
			self.viewModel.bIsCompletion = true
			self:SetBtnCompletionText()
		else
			-- 未获得时
			self.viewModel.bIsCompletion = false
			self:RefreshNotCompletionStatus()
		end
	end
end

function LegendaryWeaponMainPanelView:SetSelectWeaponID(WeaponID)
	if WeaponID ~= 0 then
		-- self:SetShowWeaponModel(self.viewModel.IsShowWeaponModel)
		self:PreViewEquipment(WeaponID, EquipPart.EQUIP_PART_MASTER_HAND, 0)
		-- 处理副手显示
		if self.viewModel.SelectSubWeaponID ~= 0 then
			self:PreViewEquipment(self.viewModel.SelectSubWeaponID, EquipPart.EQUIP_PART_SLAVE_HAND, 0)
		else
			if CommonUtil.IsObjectValid(self.SubWeaponActor) then
				self.SubWeaponActor:HideMasterHand(true)
			end
		end
		self:StartLoadWeaponModel()
	end
end

-- 开始加载单独的武器模型，隐藏状态下不执行（更新武器ID会调用）
function LegendaryWeaponMainPanelView:StartLoadWeaponModel()
	if not self.viewModel.IsShowWeaponModel then
		return
	end
	self.Common_Render2D_UIBP:HidePlayer(true)
	self.Common_Render2D_UIBP:SetCanRotate(false)

	if self.LastLoadWeapon == nil or self.LastLoadWeapon ~= self.viewModel.SelectWeaponID then
		-- 与上一次加载武器不同，则加载新武器
		local Target = self.WeaponActor
		if CommonUtil.IsObjectValid(Target) then
			Target:HideMasterHand(false)	--显示武器
			local BPActor = self.viewModel.BP_SceneActor
			if BPActor ~= nil then
				BPActor:SetWeaponMasterCharacter(self.WeaponActor)
			end
			--self.WeaponActor:TakeOffAvatarPart(ProtoRes.EquipmentType.WEAPON_MASTER_HAND,true)
			Target:GetAvatarComponent():LoadWeaponOnly(self.viewModel.SelectWeaponID, true,true)
			--local NewEntityID = _G.UE.UActorManager:Get():AllocClientEntityID(_G.UE.EActorType.UIActor, 0)
			--Target:UpdateEntityID(NewEntityID)--给主武器添加EntityID
            Target:GetAvatarComponent():WaitForTextureMipsByReason(_G.UE.EAvatarWaitTextureStreamReason.EAWTSR_LegendaryWeapon)
			if self.viewModel.SelectSubWeaponID ~= 0 then
				local SubTarget = self.SubWeaponActor
				if BPActor ~= nil then
					BPActor:SetWeaponSlaveCharacter(self.SubWeaponActor)
				end
				if CommonUtil.IsObjectValid(SubTarget) then
					SubTarget:HideMasterHand(false)
					--self.SubWeaponActor:TakeOffAvatarPart(ProtoRes.EquipmentType.WEAPON_Slave_HAND,true)
					SubTarget:GetAvatarComponent():LoadWeaponOnly(self.viewModel.SelectSubWeaponID, true,true)
                    SubTarget:GetAvatarComponent():WaitForTextureMipsByReason(_G.UE.EAvatarWaitTextureStreamReason.EAWTSR_LegendaryWeapon)
                end
				--local NewEntityID = _G.UE.UActorManager:Get():AllocClientEntityID(_G.UE.EActorType.UIActor, 0)
				--SubTarget:UpdateEntityID(NewEntityID)
			elseif self.viewModel.SelectSubWeaponID == 0 then
				if CommonUtil.IsObjectValid(self.SubWeaponActor) then
					self.SubWeaponActor:HideMasterHand(true)	--隐藏武器
				end
			end
			self.LastLoadWeapon = self.viewModel.SelectWeaponID
		end
	else
		-- 若和上次加载的武器相同则不重复加载，仅更新一下武器位置、旋转、特效等
		if CommonUtil.IsObjectValid(self.WeaponActor) then
			self.WeaponActor:HideMasterHand(false)		--显示武器
		end
		if self.viewModel.SelectSubWeaponID ~= 0 then
			if CommonUtil.IsObjectValid(self.SubWeaponActor) then
				self.SubWeaponActor:HideMasterHand(false)
			end
		end
		self:SetWeaponTransform()
		self:ShowWeaponVFX(true)
	end
end

function LegendaryWeaponMainPanelView:OnAssembleAllEnd(Params)
	if nil == Params then
		return
	end
	local EntityID = Params.ULongParam1
	local ID_Role = nil
	if nil == self.Common_Render2D_UIBP then
		return
	end
	if self.Common_Render2D_UIBP.ChildActor and self.Common_Render2D_UIBP.ChildActor:GetAttributeComponent() then
		ID_Role = self.Common_Render2D_UIBP.ChildActor:GetAttributeComponent().EntityID
	end
	local ID_Weapon = nil
	if CommonUtil.IsObjectValid(self.WeaponActor) and self.WeaponActor:GetAttributeComponent() then
		ID_Weapon = self.WeaponActor:GetAttributeComponent().EntityID
	end
	local ID_SubWeapon = nil
	if CommonUtil.IsObjectValid(self.SubWeaponActor) and self.SubWeaponActor:GetAttributeComponent() then
		ID_SubWeapon = self.SubWeaponActor:GetAttributeComponent().EntityID
	end
	if EntityID == ID_Role or EntityID == ID_Weapon or EntityID == ID_SubWeapon then
		--入场和切换武器时，都会运行到这里
		local SceneActor = self.viewModel.BP_SceneActor
		if not UCommonUtil.IsObjectValid(SceneActor) then return end
		local CameraMgr = _G.UE.UCameraMgr.Get()
		if CameraMgr ~= nil then
			CameraMgr:SwitchCamera(SceneActor, 0)   --切换相机为传奇武器场景
		end
		self:UpdateWeaponTransformCfg()
		local Time = SceneActor:GetActorSequenceTime()
		if Time > 0 and Time < 1.7 then
			-- 在场景入场时组装
		else
			-- 切换武器时组装
			self:SetWeaponTransform()
		end
		self:ShowWeaponVFX(true)
		self.Common_Render2D_UIBP:UpdateAllLights()
		-- 切模型在iOS上进行GC
		_G.ObjectMgr:CollectGarbage(false, true, false)
		self:SetFieldOfView(60)
		if EntityID == ID_Role and self.Common_Render2D_UIBP.ChildActor then
			local AvatarCom = self.Common_Render2D_UIBP.ChildActor:GetAvatarComponent()
			local IsHoldWeapon = self.Common_Render2D_UIBP.ChildActor:IsHoldWeapon()
			if AvatarCom and IsHoldWeapon then
				--修复从战士拔刀状态切换到双武器职业时会导致副武器特效丢失问题
				AvatarCom:UpdateWeaponToState(_G.UE.EAvatarPartType.WEAPON_SLAVE_HAND, 0)
			end
		end
	end
end

--- 调整传奇武器位置
function LegendaryWeaponMainPanelView:SetWeaponTransform()
	local BPActor = self.viewModel.BP_SceneActor

	--- 调整主武器  注意两个坑 正确应该是用ChildActor调位置和缩放 用mesh调旋转FRotator(Pitch, Yaw, Roll)分别对应(y, z, x)
	if (self.viewModel.IsShowWeaponModel == true) and CommonUtil.IsObjectValid(self.WeaponActor) then
		if BPActor ~= nil then
			BPActor:SetWeaponMasterCharacter(self.WeaponActor)
		end
		self.WeaponActor:DoClientModeEnter()
		if CommonUtil.IsObjectValid(self.WeaponActor.CharacterMovement) then
			self.WeaponActor.CharacterMovement:DisableMovement()
			self.WeaponActor.CharacterMovement:SetComponentTickEnabled(false)	
		end

		local WeaponLocation = _G.UE.FVector(self.WeaponLocationX, self.WeaponLocationY, self.WeaponLocationZ)
		local WeaponRotation = _G.UE.FRotator(self.WeaponRotationY, self.WeaponRotationZ, self.WeaponRotationX)
		local WeaponScale = _G.UE.FVector(self.WeaponScale)
		self.WeaponActor:K2_SetActorLocation(WeaponLocation, false, nil, false)
		if self.viewModel.BP_SceneActor then
			local WeaponMesh = self.viewModel.BP_SceneActor.WeaponMesh
			if WeaponMesh then
				WeaponMesh:K2_SetWorldRotation(WeaponRotation, false, nil, false)
			end
		end
		self.WeaponActor:SetActorScale3D(WeaponScale)
	end

	--- 调整副武器
	if (self.viewModel.IsShowWeaponModel == true) and self.viewModel.SelectSubWeaponID ~= 0 and CommonUtil.IsObjectValid(self.SubWeaponActor) then
		if BPActor ~= nil then
			BPActor:SetWeaponSlaveCharacter(self.SubWeaponActor)
		end
		self.SubWeaponActor:DoClientModeEnter()
		if CommonUtil.IsObjectValid(self.SubWeaponActor.CharacterMovement) then
			self.SubWeaponActor.CharacterMovement:DisableMovement()
			self.SubWeaponActor.CharacterMovement:SetComponentTickEnabled(false)	
		end

		local SubWeaponLocation = _G.UE.FVector(self.SubWeaponLocationX, self.SubWeaponLocationY, self.SubWeaponLocationZ)
		local SubWeaponRotation = _G.UE.FRotator(self.SubWeaponRotationY, self.SubWeaponRotationZ, self.SubWeaponRotationX)
		local WeaponScale = _G.UE.FVector(self.WeaponScale)
		self.SubWeaponActor:K2_SetActorLocation(SubWeaponLocation, false, nil, false)
		if self.viewModel.BP_SceneActor then
			local SubWeaponMesh = self.viewModel.BP_SceneActor.SubWeaponMesh
			if SubWeaponMesh then
				SubWeaponMesh:K2_SetWorldRotation(SubWeaponRotation, false, nil, false)
			end
		end
		self.SubWeaponActor:SetActorScale3D(WeaponScale)
	end

	--- 角色
	if (self.viewModel.IsShowWeaponModel == false) and self.Common_Render2D_UIBP ~= nil and self.Common_Render2D_UIBP.ChildActor ~= nil then
		self.Common_Render2D_UIBP:SwitchCharacterIK(false)
		
		local CharacterLocationX = LegendaryWeaponMgr.CharacterLocationX
		local CharacterLocationY = LegendaryWeaponMgr.CharacterLocationY
		local CharacterLocationZ = LegendaryWeaponMgr.CharacterLocationZ
		local CharacterScale = LegendaryWeaponMgr.CharacterScale
		
		local function IsValidCha(Value)
			return Value ~= nil and Value ~= "" and Value ~= 0
		end

		local RenderActor = self.Common_Render2D_UIBP.ChildActor
		if RenderActor then
			CharacterLocationX = IsValidCha(CharacterLocationX) and CharacterLocationX or RenderActor:K2_GetActorLocation().X
			CharacterLocationY = IsValidCha(CharacterLocationY) and CharacterLocationY or RenderActor:K2_GetActorLocation().Y
			CharacterLocationZ = IsValidCha(CharacterLocationZ) and (CharacterLocationZ + 100000) or RenderActor:K2_GetActorLocation().Z
			local CharacterLocation = _G.UE.FVector(CharacterLocationX, CharacterLocationY, CharacterLocationZ)
			RenderActor:K2_SetActorLocation(CharacterLocation, false, nil, false)
			CharacterScale = IsValidCha(CharacterScale) and CharacterScale or 1
			RenderActor:SetActorScale3D(_G.UE.FVector(CharacterScale))
		end
	end

	--- 若在展示材料制作界面，则重置一次起始位置，用于插值到配置位置的切换效果
	-- if self.viewModel.IsComposeMode and self.Common_Render2D_UIBP_1.RenderActor then
	--	self.Common_Render2D_UIBP_1.RenderActor:SetWeaponMeshRotation(60, 0, 90)
	--	self.Common_Render2D_UIBP_1.RenderActor:SetSubWeaponMeshRotation(60, 0, 90)
	-- end
end

--- 更新配置，校验有效的Transform
function LegendaryWeaponMainPanelView:UpdateWeaponTransformCfg()
	if not self.viewModel.WeaponCfg then return end
	local function IsValid(Value)
		return Value ~= nil and Value ~= ""
	end
	self.WeaponLocationX = self.viewModel.WeaponCfg.WeaponLocationX
	self.WeaponLocationY = self.viewModel.WeaponCfg.WeaponLocationY
	self.WeaponLocationZ = self.viewModel.WeaponCfg.WeaponLocationZ + 100000
	self.WeaponRotationX = self.viewModel.WeaponCfg.WeaponRotationX
	self.WeaponRotationY = self.viewModel.WeaponCfg.WeaponRotationY
	self.WeaponRotationZ = self.viewModel.WeaponCfg.WeaponRotationZ
	self.SubWeaponLocationX = self.viewModel.WeaponCfg.SubWeaponLocationX
	self.SubWeaponLocationY = self.viewModel.WeaponCfg.SubWeaponLocationY
	self.SubWeaponLocationZ = self.viewModel.WeaponCfg.SubWeaponLocationZ + 100000
	self.SubWeaponRotationX = self.viewModel.WeaponCfg.SubWeaponRotationX
	self.SubWeaponRotationY = self.viewModel.WeaponCfg.SubWeaponRotationY
	self.SubWeaponRotationZ = self.viewModel.WeaponCfg.SubWeaponRotationZ
	self.WeaponScale = self.viewModel.WeaponCfg.WeaponScale

	if self.WeaponActor then
		self.WeaponLocationX = IsValid(self.WeaponLocationX) and self.WeaponLocationX or self.WeaponActor:K2_GetActorLocation().X
		self.WeaponLocationY = IsValid(self.WeaponLocationY) and self.WeaponLocationY or self.WeaponActor:K2_GetActorLocation().Y
		self.WeaponLocationZ = IsValid(self.WeaponLocationZ) and self.WeaponLocationZ or self.WeaponActor:K2_GetActorLocation().Z
	end
	self.WeaponRotationX = IsValid(self.WeaponRotationX) and self.WeaponRotationX or 0
	self.WeaponRotationY = IsValid(self.WeaponRotationY) and self.WeaponRotationY or 0
	self.WeaponRotationZ = IsValid(self.WeaponRotationZ) and self.WeaponRotationZ or 0
	if self.SubWeaponActor then
		self.SubWeaponLocationX = IsValid(self.SubWeaponLocationX) and self.SubWeaponLocationX or self.SubWeaponActor:K2_GetActorLocation().X
		self.SubWeaponLocationY = IsValid(self.SubWeaponLocationY) and self.SubWeaponLocationY or self.SubWeaponActor:K2_GetActorLocation().Y
		self.SubWeaponLocationZ = IsValid(self.SubWeaponLocationZ) and self.SubWeaponLocationZ or self.SubWeaponActor:K2_GetActorLocation().Z
	end
	self.SubWeaponRotationX = IsValid(self.SubWeaponRotationX) and self.SubWeaponRotationX or 0
	self.SubWeaponRotationY = IsValid(self.SubWeaponRotationY) and self.SubWeaponRotationY or 0
	self.SubWeaponRotationZ = IsValid(self.SubWeaponRotationZ) and self.SubWeaponRotationZ or 0
	self.WeaponScale = self.WeaponScale > 0.1 and self.WeaponScale or 1

	local SceneActor = self.viewModel.BP_SceneActor
	if UCommonUtil.IsObjectValid(SceneActor) then
		SceneActor.WeaponRotation.Roll = self.WeaponRotationX
		SceneActor.WeaponRotation.Pitch = self.WeaponRotationY
		SceneActor.WeaponRotation.Yaw = self.WeaponRotationZ		-- FRotator(Pitch, Yaw, Roll)分别对应(y, z, x)
		SceneActor.SubWeaponRotation = _G.UE.FRotator(self.SubWeaponRotationY, self.SubWeaponRotationZ, self.SubWeaponRotationX)
		SceneActor.WeaponLocation = _G.UE.FVector(self.WeaponLocationX, self.WeaponLocationY, self.WeaponLocationZ)
		SceneActor.SubWeaponLocation = _G.UE.FVector(self.SubWeaponLocationX, self.SubWeaponLocationY, self.SubWeaponLocationZ)
		SceneActor.WeaponScale = self.WeaponScale
		SceneActor.UseCenterRotator = self.viewModel.SelectSubWeaponID ~= 0
	end
end

--- 在制作材料界面时，需要插值调整武器旋转到最佳位置，然后停止武器自动旋转
function LegendaryWeaponMainPanelView:PlayRInterpToWeapon(bIsComposeMode)
	local SceneActor = self.viewModel.BP_SceneActor
	if UCommonUtil.IsObjectValid(SceneActor) then
		SceneActor.bIsComposeMode = bIsComposeMode
		if bIsComposeMode then
			self:UpdateWeaponTransformCfg()
			LegendaryWeaponMgr:PlaySequence4(true)
		else
			LegendaryWeaponMgr:PlaySequence4(false)
		end
	end
end

--- 当存在子武器时，用来切换主、子武器的属性值面板
function LegendaryWeaponMainPanelView:OnToggleGroupCheckChanged1(Index)
	self:PlayAnimation(self.AnimRefresh)
	if Index == 1 then
		self:UpdateEquipPanel(true)
		local Cfg = ItemCfg:FindCfgByKey(self.viewModel.SelectWeaponID)
		if Cfg then
			self.TextRightTitle:SetText(ItemCfg:GetItemName(self.viewModel.SelectWeaponID))
		end
	else
		self:UpdateEquipPanel(false)
		local Cfg = ItemCfg:FindCfgByKey(self.viewModel.SelectSubWeaponID)
		if Cfg then
			self.TextRightTitle:SetText(ItemCfg:GetItemName(self.viewModel.SelectSubWeaponID))
		end
	end
end

--- 点击制作按钮
function LegendaryWeaponMainPanelView:OnBtnCraftClick()
	print("------------[LegendaryWeapon] ---------------------------------",
	"\n当前武器:", self.viewModel.WeaponCfg.ID, 
	"\n校验当前武器", LegendaryWeaponMgr.QueryList[self.viewModel.WeaponCfg.ID], 
	"\n是否已制作:", self.viewModel.bIsCompletion,
	"\n按钮显示的字体:", self.BtnCraft:GetText(),
	"\n-------------[LegendaryWeapon] ---------------------------------")

	if self.viewModel.bIsCompletion == true then
		MsgTipsUtil.ShowTips(LSTR(220022))	--"已获得"
		self:SetBtnCompletionText()
		return
	end

	local bIsEnough = self.viewModel:CheckMaterialEnough()	--判断材料是否满足
	local bIsCanUse, TipsText = self:GetMajorSate()
	if bIsEnough == true and bIsCanUse == true then
		local TopicTab = self.viewModel:GetTopicTabList()
		local Title = LSTR(220023)	--"制作武器"
		local Message1 = TopicTab and TopicTab.Name or LSTR(220024)	--"上古武器"
		local Message2 = ""
		if self.viewModel.SelectSubWeaponID ~= 0 then
			Message2 = ItemCfg:GetItemName(self.viewModel.SelectWeaponID) .. "&" .. ItemCfg:GetItemName(self.viewModel.SelectSubWeaponID)
		else
			Message2 = ItemCfg:GetItemName(self.viewModel.SelectWeaponID)
		end
		Message2 = string.format("<span color=\"#%s\">%s</>", "E1CB9C", Message2)
		local RedTips = string.format("<span color=\"#%s\">%s</>", "B03A38", LSTR(220025))	--"所有需求材料将被消耗"
		local Message = string.format(LSTR(220026), Message1, Message2)	  --"即将制作%s:%s\n请问是否继续？"
		local function CallBack1()
			print("[传奇武器]：点击发送制作请求，开始制作：", Message2)
			self.viewModel:OnBtnCraftClick()  		--发送制作请求
		end
		local function CallBack2()
			print("[传奇武器]：点击取消制作", Message2)
			return
		end
		local RightBtnName = LSTR(10003)	--"取 消"
		local LeftBtnName = LSTR(10065)	--"确 定"
		local Params = {bUseTips = true, TipsText = RedTips}
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, Title, Message, CallBack1, CallBack2, RightBtnName, LeftBtnName, Params) --打开确认弹窗
	elseif bIsEnough == false then
		MsgTipsUtil.ShowTips(LSTR(220027))	--"材料不足，无法制作"
	elseif bIsCanUse == false and not string.isnilorempty(TipsText) then
		MsgTipsUtil.ShowTips(TipsText)
	end
end

function LegendaryWeaponMainPanelView:SetBtnCompletionText(Params)
	local WeaponCfg = self.viewModel and self.viewModel.WeaponCfg or nil
	local WeaponID = WeaponCfg and WeaponCfg.ID or nil
	if LegendaryWeaponMgr.QueryList and LegendaryWeaponMgr.QueryList[WeaponID] then
		if Params ~= nil then
			--制作完成时的刷新
			if nil ~= self.viewModel then
				self.viewModel.bIsCompletion = true
			end
			self:PlayAnimMaterial(-1)
		end
	
		self:RefreshIsCompletionStatus()
	end
end

--- 开始制作动画 (白屏前)
function LegendaryWeaponMainPanelView:PlayAnimMake()
	if self.AnimMake then
		self:PlayAnimation(self.AnimMake)
	end

	if self.TableViewPages then
		UIUtil.SetIsVisible(self.TableViewPages, false, false)
	end
	if self.BtnCraft then
		UIUtil.SetIsVisible(self.BtnCraft, false, false)
	end
	if self.PanelTopRight then
		UIUtil.SetIsVisible(self.PanelTopRight, false, false)
	end
end

--- 结束制作动画 (奖励后)
function LegendaryWeaponMainPanelView:CompletionEnd(Params)
	if self.PanelMaterial then
		self:PlayAnimationReverse(self.AnimMake)
	end
	-- LegendaryWeaponMgr:PlayLoopSequence(true)
	if Params and Params.WeaponID then
		LegendaryWeaponMgr:ShowTaskCompletionTips(Params.WeaponID)
		LegendaryWeaponMgr:ShowTipsMJS(Params)
	end

	if self.CompletionEndTimerID then
		_G.TimerMgr:CancelTimer(self.CompletionEndTimerID)
		self.CompletionEndTimerID = nil
	end
	self.CompletionEndTimerID = _G.TimerMgr:AddTimer(self, function()
		if self.TableViewPages then
			UIUtil.SetIsVisible(self.TableViewPages, true, true)
		end
		if self.BtnCraft then
			UIUtil.SetIsVisible(self.BtnCraft, true, true)
		end
		if self.PanelTopRight then
			UIUtil.SetIsVisible(self.PanelTopRight, true, true)
		end
	end, 3)

end

function LegendaryWeaponMainPanelView:OnBtnStoreClick()
	if nil == self.TopicTabInfo then return end
	local ShopID = self.TopicTabInfo.ShopID
	local FirstType = self.TopicTabInfo.FirstType
	ShopMgr:OpenShop(ShopID, FirstType)
end

--- 切换拔刀姿势（角色）
function LegendaryWeaponMainPanelView:OnBtnPoseClick()
	self.bHoldWeapon = not self.bHoldWeapon
	self.Common_Render2D_UIBP:HoldOnWeapon(self.bHoldWeapon)

	if self.Common_Render2D_UIBP.ChildActor and self.bHoldWeapon then
		local UIComplexCharacter = self.Common_Render2D_UIBP.ChildActor:Cast(_G.UE.AUIComplexCharacter)
		if not UIComplexCharacter then return end
		local CharacterAnimCom = UIComplexCharacter:GetAnimationComponent()
		if not CharacterAnimCom then return end
		local AnimInst = CharacterAnimCom:GetPlayerAnimInstance()
		local PlayerAnimParam = AnimInst:GetPlayerAnimParam()
		PlayerAnimParam.bIgnoreRestTime = false
		PlayerAnimParam.bCanRest = true
		PlayerAnimParam.IdleToRestTime = 2	-- 在2s后进入战斗闲置
		AnimInst:UpdatePlayerAnimParam(PlayerAnimParam)
	end
end

function LegendaryWeaponMainPanelView:UpdateEquipPanel(bIsMaster)
	if not self.viewModel or not self.viewModel.ProfInfo then
		return
	end
	local WeaponCfg = self.viewModel.ProfInfo.WeaponCfg
	if not WeaponCfg then
		return
	end
	local EuqipID = WeaponCfg.EquipmentID
	if not bIsMaster and WeaponCfg.SubEquipmentID ~= 0 then
		EuqipID = WeaponCfg.SubEquipmentID
	end
	local LAttrMsg, SAttrMsg = self.viewModel:GetAttriInfo(EuqipID)
	self.AdapterLAttrList:UpdateAll(LAttrMsg)
	self.AdapterSAttrList:UpdateAll(SAttrMsg)
end

function LegendaryWeaponMainPanelView:GetSkeletalMeshComponent(Actor)
    if nil == Actor then
        return
    end

    local Component = Actor:GetComponentByClass(_G.UE.USkeletalMeshComponent)
    if Component == nil then
        return
    end
    return Component:Cast(_G.UE.USkeletalMeshComponent)
end

--武器变体模型
-- function LegendaryWeaponMainPanelView:ProcessWeaponPossessableActor(Pos, WeaponInfo, ActorType, Guid, SequenceName, ListID)
--     -- local Target = self:CreateClientActor(0, ListID, ActorType)
--     -- if (Target ~= nil) then
--         local ModelPath = string.format("w%04d", WeaponInfo.SkeletonId)
--         local SubModelPath = string.format("b%04d", WeaponInfo.PatternId)
--         Target:GetAvatarComponent():LoadWeaponAvatar(ModelPath, SubModelPath, WeaponInfo.ImageChangeId, WeaponInfo.StainingId)

--         self:AddPossessableActorInfo(Target, Pos, Guid, SequenceName, false, false, true)
--     -- end
-- end

-- 初始化三维展示模型（创建角色模型）
function LegendaryWeaponMainPanelView:ShowPlayerWeaponActor()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	self.viewModel.AttachType = (LegendaryWeaponMgr.AttachType ~= nil) and LegendaryWeaponMgr.AttachType or "c0101"
	--根据种族取对应的RenderActor
	local RenderActorPathForRace = string.format(RenderActorPath, self.viewModel.AttachType, self.viewModel.AttachType)
	--local RenderActorPath = "Class'/Game/UI/Render2D/BP_Render2DLoginActor_Mount.BP_Render2DLoginActor_Mount_C'"
    local CallBack = function(bSucc)
        if (bSucc) then
			self.VignetteIntensityDefaultValue = self.Common_Render2D_UIBP:GetPostProcessVignetteIntensity()
			self.Common_Render2D_UIBP:SwitchOtherLights(false)
            self.Common_Render2D_UIBP:ChangeUIState(false)
            
			self.Common_Render2D_UIBP:SetUICharacterByEntityID(MajorUtil.GetMajorEntityID())	--同步主角外观
			local Character = self.Common_Render2D_UIBP:GetUIComplexCharacter()
			if Character then
				Character:ClearDelegateHandle()	--解除后续同步主角外观
			end

			self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
			self.Common_Render2D_UIBP:HidePlayer(true)
			self:TurnOffAmbientLight()
			self.viewModel.Render2DActor = self.Common_Render2D_UIBP.ChildActor
        end
    end
	local ReCreateCallBack = function()
        self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
    end
    self.Common_Render2D_UIBP:CreateRenderActor(RenderActorPathForRace,
	EquipmentMgr:GetEquipmentCharacterClass(), nil--[[EquipmentMgr:GetLightConfig()]],
	false, CallBack, ReCreateCallBack)
end

--装备预览
function LegendaryWeaponMainPanelView:PreViewEquipment(EquipID, Part, ColorID)
	if self.Common_Render2D_UIBP.ChildActor then
		local UIComplexCharacter = self.Common_Render2D_UIBP.ChildActor:Cast(_G.UE.AUIComplexCharacter)
		if UIComplexCharacter then
			-- 先脱下原本的装备
			-- local PosKey = EquipmentDefine.EquipmentTypeMap[Part]
			-- UIComplexCharacter:TakeOffAvatarEquip(PosKey, false) 
			if Part == EquipPart.EQUIP_PART_MASTER_HAND then
				local TempItemCfg = ItemCfg:FindCfgByKey(self.viewModel.SelectWeaponID)
				if TempItemCfg then
					self.Common_Render2D_UIBP:OnProfSwitch({ProfID = TempItemCfg.ProfLimit[1]})
				end
				--print("LegendaryWeaponMainPanelView:PreViewEquipment OnProfSwitch:",TempItemCfg.ProfLimit[1])
				UIComplexCharacter:TakeOffAvatarEquip(EquipmentType.WEAPON_MASTER_HAND, false)
				UIComplexCharacter:TakeOffAvatarEquip(EquipmentType.WEAPON_SLAVE_HAND, false)
				UIComplexCharacter:HandleAvatarEquip(EquipID, Part, ColorID)	
			else
				UIComplexCharacter:TakeOffAvatarEquip(EquipmentType.WEAPON_SLAVE_HAND, false)
				UIComplexCharacter:HandleAvatarEquip(EquipID, Part, ColorID)					
			end
			-- UIComplexCharacter:StartLoadAvatar()
		end
	end
end

--- 创建环境动效
function LegendaryWeaponMainPanelView:LoadSceneActor()
	if self.Common_Render2D_UIBP_1 == nil then
		return
	end

	local CallBack = function(bSucc)
        if (bSucc) then
			if not self.viewModel then return end
			self.viewModel.BP_SceneActor = self.Common_Render2D_UIBP_1.RenderActor
			local BPActor = self.viewModel.BP_SceneActor
			if BPActor ~= nil then
				
				--切换摄像机
			--	if nil == BPActor.CameraActor then
			--		print("[LegendaryWeapon] Switch Camera :", BPActor.CameraActor)
			--		local CameraMgr = _G.UE.UCameraMgr.Get()
			--		if CameraMgr ~= nil then
			--			CameraMgr:SwitchCamera(BPActor, 0)
			--		end
			--	end
				--显示武器

				if BPActor.WeaponActor then
                    local Params = _G.UE.FCreateClientActorParams()
				    Params.bUIActor = true
					local Location  = BPActor.WeaponActor.ChildActor:K2_GetActorLocation()
				    local tempEntity = _G.UE.UActorManager:Get():CreateClientActorByParams(_G.UE.EActorType.ClientShow, 0, 0,Location ,BPActor.WeaponActor.ChildActor:K2_GetActorRotation(),Params)
				    self.WeaponActor = ActorUtil.GetActorByEntityID(tempEntity)
					self.WeaponActorRef = _G.UnLua.Ref(self.WeaponActor)
					BPActor:SetWeaponMasterCharacter(self.WeaponActor)

					if CommonUtil.IsObjectValid(self.WeaponActor) then
						--self.WeaponActor:SetSimulatedHoldWeapon(true)
						self.WeaponActor:HideMasterHand(false)  --显示武器
						local AvatarCom = self.WeaponActor:GetAvatarComponent()
						if AvatarCom ~= nil then
							if self.viewModel.SelectWeaponID ~= 0 then
								--AvatarCom:CustomInit()
								--self.WeaponActor:TakeOffAvatarPart(ProtoRes.EquipmentType.WEAPON_MASTER_HAND,true)
								AvatarCom:LoadWeaponOnly(self.viewModel.SelectWeaponID, true,true)
							end
							AvatarCom:SetForcedLODForAll(1)
                            AvatarCom:WaitForTextureMipsByReason(_G.UE.EAvatarWaitTextureStreamReason.EAWTSR_LegendaryWeapon)
							self:ShowWeaponVFX(true)
						end
					end
				end
				if BPActor.SubWeaponActor then
                    local Params = _G.UE.FCreateClientActorParams()
				    Params.bUIActor = true
					local Location  = BPActor.SubWeaponActor.ChildActor:K2_GetActorLocation()
				    local tempEntity = _G.UE.UActorManager:Get():CreateClientActorByParams(_G.UE.EActorType.ClientShow, 0, 0,Location ,BPActor.SubWeaponActor.ChildActor:K2_GetActorRotation(),Params)
				    self.SubWeaponActor = ActorUtil.GetActorByEntityID(tempEntity)
					self.SubWeaponActorRef = _G.UnLua.Ref(self.SubWeaponActor)
					BPActor:SetWeaponSlaveCharacter(self.SubWeaponActor)
					if CommonUtil.IsObjectValid(self.SubWeaponActor) and self.viewModel.SelectSubWeaponID ~= 0 then
						self.SubWeaponActor:HideMasterHand(false)
						local AvatarCom = self.SubWeaponActor:GetAvatarComponent()
						if AvatarCom ~= nil then
							--AvatarCom:CustomInit()

							--self.SubWeaponActor:SetSimulatedHoldWeapon(true)
							--self.SubWeaponActor:TakeOffAvatarPart(ProtoRes.EquipmentType.WEAPON_Slave_HAND,true)
							AvatarCom:LoadWeaponOnly(self.viewModel.SelectSubWeaponID, true,true)
                            AvatarCom:WaitForTextureMipsByReason(_G.UE.EAvatarWaitTextureStreamReason.EAWTSR_LegendaryWeapon)
							AvatarCom:SetForcedLODForAll(1)
						end
					end
				end
			end
		end
	end
	self.Common_Render2D_UIBP_1:CreateSimpleRenderActor(LegendaryWeaponDefine.SceneActorPath, false, CallBack)
end

--- 关闭角色灯光，采用系统灯光
function LegendaryWeaponMainPanelView:TurnOffAmbientLight()
	if self.Common_Render2D_UIBP ~= nil and self.Common_Render2D_UIBP.RenderActor then
		local BPActor = self.Common_Render2D_UIBP.RenderActor  --渲染人物Actor
		--[[关闭聚光灯
		local SpotLightList = BPActor:K2_GetComponentsByClass(_G.UE.USpotLightComponent)
		local Count = SpotLightList:Length()
		for i = 1, Count do
			local SpotLightComponent = SpotLightList:Get(i)
			SpotLightComponent:SetVisibility(false)
			SpotLightComponent:SetActive(false)
		end
		--关闭特效]]
		local ParticleSystemCom = BPActor:K2_GetComponentsByClass(_G.UE.UParticleSystemComponent)
		local Count = ParticleSystemCom:Length()
		for i = 1, Count do
			local ParticleSystemComponent = ParticleSystemCom:Get(i)
			ParticleSystemComponent:SetVisibility(false)
			ParticleSystemComponent:SetActive(false)
		end

		local SystemLightCfgItem = SystemLightCfg:FindCfgByKey(5)
		if SystemLightCfgItem then
			local PathList = SystemLightCfgItem.LightPresetPaths
			if not PathList then return end
			local AvatarComp = MajorUtil.GetMajorAvatarComponent()
			local RaceName = AvatarComp and AvatarComp:GetAttachType() or "c0101"
			local LightPresetPath = PathList[1]
			for _, Path in pairs(PathList) do
				local Random = string.find(Path, RaceName)
				if Random then
					LightPresetPath = Path
				end
			end
			self.Common_Render2D_UIBP:ResetLightPreset(LightPresetPath)
		end
	end
end

--- 打开主界面时，显示当前职业的武器
function LegendaryWeaponMainPanelView:SetDropDownListIndex()
	if self.viewModel == nil then return end
	local AttrCmp = MajorUtil.GetMajorAttributeComponent()
	if AttrCmp == nil then return end
	local ProfID = MajorUtil.GetMajorAttributeComponent().ProfID
	local Specialization = RoleInitCfg:FindProfSpecialization(ProfID)
	local IsCrafterProf = Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	-- 若当前为生产职业，则默认选中"骑士"职业武器
	if IsCrafterProf then
		self.viewModel.SelectWeaponIndex = 1
		MsgTipsUtil.ShowTips(LSTR(220028))	--"当前职业为生产职业，默认显示骑士职业的传奇武器"
		return
	end
	
	-- 进入界面默认选中玩家当前职业
	local WeaponProf = LegendaryWeaponDefine.ProfIdToWeaponProf[ProfID]
	if WeaponProf then
		ProfID = WeaponProf
	end

	self.ProfList = self.viewModel:GetProfList(1, 1)
	if self.ProfList == nil then return end
	for i, value in ipairs(self.ProfList) do
		if value.Prof == ProfID then
			if self.viewModel.SelectWeaponIndex then
				self.viewModel.SelectWeaponIndex = i
				return
			end
		end
	end
end

--- 界面说明按钮
function LegendaryWeaponMainPanelView:OnInforBtnClickHelp()
	local Content1 = string.format("<span color=\"#%s\">%s</>", "bfab82", LSTR(220029))	--"传奇武器介绍"
	local Content2 = string.format(LSTR(220030))	--"1、传奇武器的外观和品级会跟随着章节的推进不断地进行升级。"
	local Content3 = string.format(LSTR(220031))	--"2、已制作好的传奇武器不可进行丢弃和回收。"
	local Content4 = string.format(LSTR(220032))	--"3、新推出的职业不会更新推出之前的传奇武器。"
	local Content = string.format("%s\n %s\n %s\n %s", Content1, Content2, Content3, Content4)

	TipsUtil.ShowInfoTips(Content, self.BtnInfor, _G.UE.FVector2D(-10, 0), _G.UE.FVector2D(0, 0))
end

--- 获取主角当前状态，特殊状态不满足制作条件
function LegendaryWeaponMainPanelView:GetMajorSate()
	local Major = MajorUtil.GetMajor()
	local TipsText = nil
	local bIsCanUse = true

	if MajorUtil.IsMajorCombat() then
		TipsText = LSTR(220033)	--"战斗中无法制作传奇武器"
        bIsCanUse = false
    end
	
	if _G.BagMgr:GetBagLeftNum() <= 0 then
		TipsText = LSTR(220034)	--"背包已满无法制作传奇武器"
        bIsCanUse = false
	end

	if _G.SingBarMgr:GetMajorIsSinging() then
		TipsText = LSTR(220035)	--"歌唱中无法制作传奇武器"
		bIsCanUse = false
	end

	if _G.FishMgr:IsInFishState() then
		TipsText = LSTR(220036)	--"钓鱼中无法制作传奇武器"
        bIsCanUse = false
    end

	if MajorUtil.GetMajorCurHp() <= 0 then
		TipsText = LSTR(220037)	--"死亡无法制作传奇武器"
        bIsCanUse = false
    end

	if _G.NpcDialogMgr:IsDialogPlaying() then
		TipsText = LSTR(220038)	--"对话中无法制作传奇武器"
		bIsCanUse = false
	end
	
	if Major and Major:GetRideComponent():IsInRide() then
		TipsText = LSTR(220039)	--"坐骑上无法制作传奇武器"
		bIsCanUse = false
	end

	if Major and Major:IsInFly() then
		TipsText = LSTR(220040)	--"飞行中无法制作传奇武器"
		bIsCanUse = false
	end

	if _G.GatherMgr:IsGatherState() then
		TipsText = LSTR(220041)	--"采集中无法制作传奇武器"
        bIsCanUse = false
	end

	if _G.CrafterMgr:GetIsMaking() then
        TipsText = LSTR(220042)	--"制作中无法制作传奇武器"
        bIsCanUse = false
	end

	local Cnt = _G.PWorldVoteMgr:GetEnterSceneRoleCnt()
	if Cnt > 0 then
		TipsText = LSTR(220043)	--"玩家进入副本确认中无法制作传奇武器"
		bIsCanUse = false
	end

	if _G.PWorldEntourageMgr:GetConfirmState() then
		TipsText = LSTR(220044)	--"副本进入确认中无法制作传奇武器"
		bIsCanUse = false
	end
	
	local StateCom = MajorUtil:GetMajorStateComponent()
	local IsInDungeon = StateCom and StateCom:IsInDungeon() or false
	if IsInDungeon then	--在副本中
		-- if (_G.PWorldMgr:GetCurrPWorldSubType() == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_8R) then
		-- 	bIsCanUse = false	--在主城PWORLD_SUB_TYPE_DUNGEON、野外PWORLD_SUB_TYPE_WILD_FIELD
		-- end
		TipsText = LSTR(220044)	--"副本进入确认中无法制作传奇武器"
		bIsCanUse = false
	end

	if self.viewModel and self.viewModel.ProfInfo then
		local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
		local ProfID = self.viewModel.ProfInfo.Prof
		if nil == RoleDetail or nil == RoleDetail.Prof.ProfList[ProfID] then
			TipsText = LSTR(220046)	--"请转为特职后进行制作！"
			bIsCanUse = false
		end
	end

	return bIsCanUse, TipsText
end

--- 显示武器模型时，加载特效
function LegendaryWeaponMainPanelView:ShowWeaponVFX(bIsVisible)
	if bIsVisible == true then
		local function ShowVFX()
			if (self.viewModel.IsShowWeaponModel == true) and self.WeaponActor ~= nil then
				self.WeaponActor.bIsClientHoldWeapon = true		--播放武器的展开动画 并通知显示特效
				local AvatarCom = self.WeaponActor:GetAvatarComponent()
				if AvatarCom then
					AvatarCom:SimulatedSetWeaponActive(true)
					AvatarCom:WaitForTextureMipsByReason(_G.UE.EAvatarWaitTextureStreamReason.EAWTSR_LegendaryWeapon)
					-- AvatarCom:PlayEffect(ProtoRes.EquipmentType.WEAPON_MASTER_HAND, true, false)
					-- AvatarCom:PlayEffect(ProtoRes.EquipmentType.WEAPON_SLAVE_HAND, true, false)
				end
			end
			if (self.viewModel.IsShowWeaponModel == true) and self.viewModel.SelectSubWeaponID ~= 0 and self.SubWeaponActor ~= nil then
				self.SubWeaponActor.bIsClientHoldWeapon = true
				local AvatarCom = self.SubWeaponActor:GetAvatarComponent()
				if AvatarCom then
					AvatarCom:SimulatedSetWeaponActive(true)
					AvatarCom:WaitForTextureMipsByReason(_G.UE.EAvatarWaitTextureStreamReason.EAWTSR_LegendaryWeapon)
					-- AvatarCom:PlayEffect(ProtoRes.EquipmentType.WEAPON_MASTER_HAND, true, false)
					-- AvatarCom:PlayEffect(ProtoRes.EquipmentType.WEAPON_SLAVE_HAND, true, false)
				end
			end
		end

		if self.ShowVFXTimerID ~= 0 then
            _G.TimerMgr:CancelTimer(self.ShowVFXTimerID)
        end
        self.ShowVFXTimerID = _G.TimerMgr:AddTimer(self, ShowVFX, 0.8, 0, 1)		--稍微延迟到武器进场
		if self.WeaponActor ~= nil  then
			local AnimComp = self.WeaponActor:GetAnimationComponent()
			if AnimComp ~= nil then
				local SoftPath = _G.UE.FSoftObjectPath()
				SoftPath:SetPath("/Game/Assets/Character/Action/weapon/battle_idle.battle_idle")
				self.WeaponActor:SetSimulatedHoldWeapon(true)
				AnimComp:PlayWeaponAnimation(ProtoRes.EquipmentType.WEAPON_MASTER_HAND,SoftPath,1,0)
				AnimComp:PlayWeaponAnimation(ProtoRes.EquipmentType.WEAPON_SLAVE_HAND,SoftPath,1,0)
			end
			local AvatarCom = self.WeaponActor:GetAvatarComponent()
			if AvatarCom then
				AvatarCom:WaitForTextureMipsByReason(_G.UE.EAvatarWaitTextureStreamReason.EAWTSR_LegendaryWeapon)
			end
		end
		if self.SubWeaponActor ~= nil then
			local AnimComp = self.SubWeaponActor:GetAnimationComponent()
			if AnimComp ~= nil then
				local SoftPath = _G.UE.FSoftObjectPath()
				SoftPath:SetPath("/Game/Assets/Character/Action/weapon/battle_idle.battle_idle")
				self.SubWeaponActor:SetSimulatedHoldWeapon(true)
				AnimComp:PlayWeaponAnimation(ProtoRes.EquipmentType.WEAPON_MASTER_HAND,SoftPath,1,0)
				AnimComp:PlayWeaponAnimation(ProtoRes.EquipmentType.WEAPON_SLAVE_HAND,SoftPath,1,0)
			end
			local AvatarCom = self.SubWeaponActor:GetAvatarComponent()
			if AvatarCom then
				AvatarCom:WaitForTextureMipsByReason(_G.UE.EAvatarWaitTextureStreamReason.EAWTSR_LegendaryWeapon)
			end
		end

		LegendaryWeaponMgr:SetFade(self.WeaponActor, 0.8, true, 0, true)
		LegendaryWeaponMgr:SetFade(self.SubWeaponActor, 0.8, true, 0, true)
	end

	if bIsVisible == false then
		if self.WeaponActor ~= nil then
			local AvatarCom = self.WeaponActor:GetAvatarComponent()
			if AvatarCom then
				AvatarCom:BreakEffect(ProtoRes.EquipmentType.WEAPON_MASTER_HAND)	--隐藏主特效
				AvatarCom:BreakEffect(ProtoRes.EquipmentType.WEAPON_SLAVE_HAND)
			end
		end
		if self.SubWeaponActor ~= nil then
			local AvatarCom = self.SubWeaponActor:GetAvatarComponent()
			if AvatarCom then
				AvatarCom:BreakEffect(ProtoRes.EquipmentType.WEAPON_MASTER_HAND)	--隐藏子特效
				AvatarCom:BreakEffect(ProtoRes.EquipmentType.WEAPON_SLAVE_HAND)
			end
		end
		if self.ShowVFXTimerID ~= 0 then
            _G.TimerMgr:CancelTimer(self.ShowVFXTimerID)
        end
		self.ShowVFXTimerID = 0
	end
end

--- 点击关闭界面
function LegendaryWeaponMainPanelView:OnClickButtonClose()
	self:Hide()
	self.viewModel.IsShowWeaponModel = true  --在Hide之后执行，避免再次触发SetShowWeaponModel()
end

function LegendaryWeaponMainPanelView:SetFieldOfView(FOV)
	if self.Common_Render2D_UIBP_1 then
		self.Common_Render2D_UIBP_1:SetCameraFOV(FOV)
	end
end

--- 打开主界面时默认选中首个未制作的章节
function LegendaryWeaponMainPanelView:SetChapterID()
	local ProfList = self.viewModel:GetProfList(nil, 1)
	local SelectIndex = self.viewModel.SelectWeaponIndex or 1
	local SelectWeapon = ProfList[SelectIndex]
	if SelectWeapon and SelectWeapon.WeaponCfg then
		if self.viewModel:QueryOwnerChapter(SelectWeapon.WeaponCfg.ID, 1) then
			local ProfList2 = self.viewModel:GetProfList(nil, 2)
			local SelectWeapon2 = ProfList2[SelectIndex]
			if SelectWeapon2 and SelectWeapon2.WeaponCfg then
				local WeaponCfg = SelectWeapon2.WeaponCfg
				local bOpen2 = self.viewModel:IsOpenChapter(WeaponCfg.TopicID, 2)
				if bOpen2 then
					if self.viewModel:QueryOwnerChapter(WeaponCfg.ID, 2) then
						local bOpen3 = self.viewModel:IsOpenChapter(WeaponCfg.TopicID, 3)
						if bOpen3 then
							self.viewModel.ChapterID = 3
							return 3
						else
							self.viewModel.ChapterID = 2
							return 2
						end
					else
						self.viewModel.ChapterID = 2
						return 2
					end
				end
			end
		end
	end
	self.viewModel.ChapterID = 1
	return 1
end

function LegendaryWeaponMainPanelView:PlayAnimMaterial(int)
	if nil == self.AnimMaterialIn then
		return
	end

	if int >= 0 or int == nil then
		if self:IsAnimationPlaying(self.AnimMaterialIn) then
			return
		end
		self:PlayAnimation(self.AnimMaterialIn)
	end

	if int < 0 then
		if self:IsAnimationPlaying(self.AnimMaterialIn) then
			self:StopAnimation(self.AnimMaterialIn)
		end
		self:PlayAnimationReverse(self.AnimMaterialIn)

		for i = 1, 8 do
			UIUtil.SetIsVisible(self["Material"..i], false)
			UIUtil.SetIsVisible(self["PanelMaterial"..i], false)
		end
	end
end

--- 配置红点
function LegendaryWeaponMainPanelView:SetNewRedDot()
	--- 长延迟，在view都刷新完之后，再处理红点的逻辑
    if self.TimerHandle ~= nil then
		self:UnRegisterTimer(self.TimerHandle)
		self.TimerHandle = nil
	end
	self.TimerHandle = self:RegisterTimer(self.UpdateRedDot, 0.5)
end

function LegendaryWeaponMainPanelView:UpdateRedDot()
	-- 主题红点
	if self.TopicTabList then
		for k, Topic in pairs(self.TopicTabList) do
			if self.VerIconTabs ~= nil and nil ~= self.VerIconTabs.AdapterTabs then
				if self.VerIconTabs.AdapterTabs.ItemViewList[k] ~= nil then
					local RedDot = self.VerIconTabs.AdapterTabs.ItemViewList[k].CommonRedDot
					if RedDot ~= nil then
						UIUtil.SetIsVisible( RedDot, true )
						RedDot:SetRedDotIDByID(LegendaryWeaponDefine.TopicRedDotID[Topic.ID])
					end
				end
			end
		end
	end

	-- 切换到制作材料的红点
	if self.CommTabs_UIBP.RedDotSlot2 then
		local MakeRedDotID = LegendaryWeaponDefine.RedDotID.Make
		UIUtil.SetIsVisible( self.CommTabs_UIBP.RedDotSlot, true ,true, true)
		UIUtil.SetIsVisible( self.CommTabs_UIBP.RedDotSlot2, true ,true, true)
		self.CommTabs_UIBP.RedDotSlot2:SetRedDotIDByID(MakeRedDotID)
		self.CommTabs_UIBP.RedDotSlot:SetRedDotIDByID(MakeRedDotID)
	end
	if self.CommTabs_UIBP.PanelSlot3 then
		UIUtil.SetIsVisible( self.CommTabs_UIBP.PanelSlot3, false, false, false)
	end

	-- 下拉职业菜单
	if self.DropDownList then
		UIUtil.SetIsVisible( self.DropDownList.RedDot, true )
		self.DropDownList.RedDot:SetRedDotIDByID(LegendaryWeaponDefine.RedDotID.ProfChange)
		--local list = self.DropDownList.DropDownItemList

		for _, ProfList in pairs(self.ProfList) do
			ProfList.RedDotID = LegendaryWeaponDefine.ProfRedDotID[ProfList.Prof]
		end
		if self.viewModel.DownListVMList then
			self.viewModel.DownListVMList:UpdateByValues(self.ProfList)
		end
	end

	-- 制作按钮红点
	if self.RedDot then
		UIUtil.SetIsVisible( self.RedDot, true )
		local RedDotID = LegendaryWeaponDefine.RedDotID.MakeBtn
		self.RedDot:SetRedDotIDByID(RedDotID)
	end

	_G.EventMgr:SendEvent(EventID.LegendaryUpdateRedDot)  --更新红点
end

---TLOG上报界面访问情况
function LegendaryWeaponMainPanelView:OnTLog(Params)
	if not Params then return end
	local Source = Params.OpenSource
	if Source == 0 or Source == 1 then	
		DataReportUtil.ReportSystemFlowData("LegendaryWeaponsVisitFlow", "1")	--途径跳转
	elseif Source == 2 then
		DataReportUtil.ReportSystemFlowData("LegendaryWeaponsVisitFlow", "2")	--二级菜单
	elseif Source == 7 then
		DataReportUtil.ReportSystemFlowData("LegendaryWeaponsVisitFlow", "7")	--图鉴入口
	elseif Source == 9 then
		DataReportUtil.ReportSystemFlowData("LegendaryWeaponsVisitFlow", "9")	--GM命令
	end
end

return LegendaryWeaponMainPanelView