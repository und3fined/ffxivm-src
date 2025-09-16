---
--- Author: xingcaicao
--- DateTime: 2023-11-29 12:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local MajorUtil = require("Utils/MajorUtil")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local PersonPortraitMgr = require("Game/PersonPortrait/PersonPortraitMgr")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")
local AnimationUtil = require("Utils/AnimationUtil")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local PortraitDesignCfg = require("TableCfg/PortraitDesignCfg")
local ObjectMgr = require("Object/ObjectMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")
local QuestMgr = require("Game/Quest/QuestMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local EmotionCfg = require("TableCfg/EmotionCfg")

local LSTR = _G.LSTR
local TabTypes = PersonPortraitDefine.TabTypes
local UnlockTypes = ProtoRes.PortraitUnlockType
local PortraitResState = ProtoCS.Role.Portrait.PortraitResState

local AppearTipsIcon = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Icon_NewAttire.UI_PersonPortrait_Icon_NewAttire'"
local LockIcon = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Icon_Lock.UI_PersonPortrait_Icon_Lock'"

local ResTipsType = {
    Empty       = 0,
    InUse       = 1, -- 使用中
    CannotUse  	= 2, -- 不可使用 
}

---@class PersonPortraitMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field BtnBack CommBackBtnView
---@field Btnsave CommBtnLView
---@field Comm58Slot CommBackpack58SlotView
---@field CommMenu CommMenuView
---@field DecoratePanel PersonPortraitDecoratePanelView
---@field DropDownListProf CommDropDownListView
---@field EmotionPanel PersonPortraitEmotionPanelView
---@field FBtnGoToTask UFButton
---@field FBtnSaveStrategySettings UFButton
---@field FHorizontalTitle UFHorizontalBox
---@field ImgObtainBg UFImage
---@field ImgTaskIcon UFImage
---@field LightingPanel PersonPortraitLightingPanelView
---@field ListPanel UFCanvasPanel
---@field MainPanel UFCanvasPanel
---@field ModelEditPanel PersonPortraitModelEditPanelView
---@field ModelPos1 UFCanvasPanel
---@field ModelPos2 UFCanvasPanel
---@field ObtainPanel UFCanvasPanel
---@field PlayProbarPanel UFCanvasPanel
---@field PortraitDesignRet PersonPortraitDesignRetView
---@field ProgressBarPlay UProgressBar
---@field RightPanel UFCanvasPanel
---@field SliderPlay USlider
---@field TaskPanel UFCanvasPanel
---@field TextName UFTextBlock
---@field TextPanel UFCanvasPanel
---@field TextTitle UFTextBlock
---@field TextUnlockDesc UFTextBlock
---@field TextUseTips UFTextBlock
---@field TipsPanel UFCanvasPanel
---@field ToggleBtnPlayState UToggleButton
---@field TopPanel UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimRefresh UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonPortraitMainPanelView = LuaClass(UIView, true)

function PersonPortraitMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg = nil
	--self.BtnBack = nil
	--self.BtnInfor = nil
	--self.BtnSave = nil
	--self.Comm58Slot = nil
	--self.CommMenu = nil
	--self.DecoratePanel = nil
	--self.DropDownListProf = nil
	--self.EmotionPanel = nil
	--self.FBtnGoToTask = nil
	--self.FBtnSaveStrategySettings = nil
	--self.FHorizontalTitle = nil
	--self.ImgObtainBg = nil
	--self.ImgTaskIcon = nil
	--self.LightingPanel = nil
	--self.ListPanel = nil
	--self.MainPanel = nil
	--self.ModelEditPanel = nil
	--self.ModelPos1 = nil
	--self.ModelPos2 = nil
	--self.ObtainPanel = nil
	--self.PlayProbarPanel = nil
	--self.PortraitDesignRet = nil
	--self.ProgressBarPlay = nil
	--self.RightPanel = nil
	--self.SliderPlay = nil
	--self.TaskPanel = nil
	--self.TextName = nil
	--self.TextPanel = nil
	--self.TextTitle = nil
	--self.TextUnlockDesc = nil
	--self.TextUseTips = nil
	--self.TipsPanel = nil
	--self.ToggleBtnPlayState = nil
	--self.TopPanel = nil
	--self.AnimIn = nil
	--self.AnimRefresh = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonPortraitMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnInfor)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.Comm58Slot)
	self:AddSubView(self.CommMenu)
	self:AddSubView(self.DecoratePanel)
	self:AddSubView(self.DropDownListProf)
	self:AddSubView(self.EmotionPanel)
	self:AddSubView(self.LightingPanel)
	self:AddSubView(self.ModelEditPanel)
	self:AddSubView(self.PortraitDesignRet)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonPortraitMainPanelView:OnInit()
	self.Binders = {
		{ "ListPanelVisible", 		UIBinderSetIsVisible.New(self, self.ListPanel) },
		{ "DecoratePanelVisible", 	UIBinderSetIsVisible.New(self, self.DecoratePanel) },
		{ "EmotionPanelVisible", 	UIBinderSetIsVisible.New(self, self.EmotionPanel) },
		{ "LightingPanelVisible", 	UIBinderSetIsVisible.New(self, self.LightingPanel) },
		{ "PlayProbarPanelVisible", UIBinderSetIsVisible.New(self, self.PlayProbarPanel) },

		{ "RightPanelVisible", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedRightPanelVisible) },
		{ "DesignRetVisible", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedDesignRetVisible) },
		{ "ModelEditPanelVisible", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedEditPanelVisible) },
		{ "CurSelectResID", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurSelectResID) },

		{ "CurSelectActionID", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurSelectActionID) },
		{ "CurSelectEmotionID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurSelectEmotionID) },
	}

	self.TextTitle:SetText(LSTR(60009)) -- "肖像编辑"
	self.TextUseTips:SetText(LSTR(60010)) -- "使用中"

	self.BtnSave:SetBtnName(LSTR(10011)) -- "保  存"
end

function PersonPortraitMainPanelView:OnDestroy()

end

function PersonPortraitMainPanelView:OnShow()
	PersonPortraitVM:UpdateUnreadRedDots()

	-- Tabs
	self.CommMenu:UpdateItems(PersonPortraitVM:GetTabList(), false)
	self.CommMenu:SetSelectedKey(TabTypes.PreDesign, true)

	-- 职业下拉框
	self:UpdateProfDropDownList()

	-- 提示信息
	self.TextName:SetText("")
	UIUtil.SetIsVisible(self.TipsPanel, false)
end

function PersonPortraitMainPanelView:OnHide()
	self.CommMenu:CancelSelected()
	self.DropDownListProf:CancelSelected()

	self:StopAnim(self.ActionMontage)
	self:StopAnim(self.EmotionMontage)

	self.AnimComponent = nil 
	self.AnimInstance = nil
	self.ActionMontage = nil
	self.EmotionMontage = nil
	self.ActionMotageResPath = nil
	self.EmotionMotageResPath = nil 
	self.LastPlayPercent = nil 
	self.LastActionPosition = nil

	PersonPortraitVM:Clear()
	PersonPortraitVM:ClearAllRedDot()
	PersonPortraitMgr.IsSavingImg = false
end

function PersonPortraitMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnValueChangedEvent(self, self.SliderPlay, self.OnValueChangedSliderPlay)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnPlayState, self.OnStateChangedTogglePlayState)

	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, 			self.OnClickButtonBack)
	UIUtil.AddOnClickedEvent(self, self.FBtnGoToTask, 				self.OnClickButtonGoToTask)
	UIUtil.AddOnClickedEvent(self, self.BtnSave, 					self.OnClickButtonSave)
	UIUtil.AddOnClickedEvent(self, self.FBtnSaveStrategySettings,	self.OnClickButtonSaveStrategySettings)

	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu, 			self.OnSelectionChangedCommMenu)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownListProf, 	self.OnSelectionChangedDropDownListProf)
end

function PersonPortraitMainPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PersonPortraitRemoveAppearUpdateTips, self.OnEventRemoveAppearUpdateTips)
    self:RegisterGameEvent(_G.EventID.PersonPortraitGetDataSuc, self.OnEventGetPortraitDataSuc)
end

function PersonPortraitMainPanelView:OnRegisterBinder()
	self:RegisterBinders(PersonPortraitVM, self.Binders)
end

function PersonPortraitMainPanelView:OnAnimationFinished(Animation)
	if Animation == self.AnimIn then
		self.PortraitDesignRet:OnAnimationAnimInFinished()
	end
end

function PersonPortraitMainPanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.05, 0)
end

function PersonPortraitMainPanelView:OnTimer()
	if not self.IsShowView then
		return
	end

	local CurTab = PersonPortraitVM.CurTab
	if CurTab == TabTypes.Action or CurTab == TabTypes.Emotion then
		-- 动作
		local Montage = self.ActionMontage
		if Montage then
			local AnimInst = self:GetAnimInstance()
			if nil == AnimInst then
				return
			end

			local CurPos = AnimationUtil.GetMontagePosition(AnimInst, Montage) 
			if CurPos <= 0 then
				self:PlayActionByResPath(self.ActionMotageResPath)
			end

			if CurPos ~= self.LastActionPosition then
				self.LastActionPosition = CurPos
				self:SetPlaySliderValue(CurPos)
			end
		end
	end
end

function PersonPortraitMainPanelView:UpdateProfDropDownList()
	local Data, Index = self:GetProfDropDownParms()
	self.DropDownListProf:UpdateItems(Data, Index)
	self.DropDownListProf:SetIsSelectFunc(function(ItemVM)
		if ItemVM and ItemVM.IsShowRightIcon and ItemVM.RightIconPath == LockIcon then
			MsgTipsUtil.ShowTips(LSTR(60016)) -- "职业未解锁"
			return false
		end

		if PersonPortraitVM:CheckIsSetsChanged() then
			MsgBoxUtil.ShowMsgBoxTwoOp(
				self, 
				LSTR(10004), --"提 示"
				LSTR(60011), -- "当前有未保存的更改，切换后将不会保存当前职业肖像设置，是否确认切换？"
				function() 
					self.DropDownListProf:SetSelectedIndexByItemVM(ItemVM)
				end,
				nil, LSTR(10003), LSTR(10002)) -- "取 消"、"确 认"

			return false
		end

		return true
	end)
end

function PersonPortraitMainPanelView:GetProfDropDownParms()
	local Index = 1
	local Data = {}

	local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
	if nil == RoleDetail then
		return Data, Index 
	end

	local UnlockProfMap = (RoleDetail.Prof or {}).ProfList
	if nil == UnlockProfMap then
		return Data, Index
	end

	local DataList = {}
	local AllProfCfgList = RoleInitCfg:GetAllOpenProfCfgList()

	for _, v in ipairs(AllProfCfgList) do
		local Prof = v.Prof
		local Name = v.ProfName
		if Prof and not string.isnilorempty(Name) then
			-- 职业对应的特职
			local AdvancedProf = v.AdvancedProf 
			if nil == AdvancedProf or nil == UnlockProfMap[AdvancedProf] then
				table.insert(DataList, { Prof = Prof, Name = Name })
			end
		end
	end

	local MajorProfID = MajorUtil.GetMajorProfID()
    local TipsProfIDMap = table.invert(PersonPortraitVM.AppearUpdateProfIDs)

	for k, v in ipairs(DataList) do
		local Prof = v.Prof
		local Icon = nil
		if UnlockProfMap[Prof] == nil then -- 未解锁
			Icon = LockIcon
		elseif TipsProfIDMap[Prof] ~= nil then -- 外观变化提示
			Icon = AppearTipsIcon
		end

		table.insert(Data, { ID = v.Prof, Name = v.Name, RightIconPath = Icon, IsShowRightIcon = not string.isnilorempty(Icon)})

		if Prof == MajorProfID then 
			Index = k
		end
	end

	return Data, Index
end

function PersonPortraitMainPanelView:GetCommonRender2DToImageView()
	return self.PortraitDesignRet:GetCommonRender2DToImageView()
end

function PersonPortraitMainPanelView:UpdateLookAtType(IsFace, IsLook)
	self.PortraitDesignRet:UpdateLookAtType(IsFace, IsLook)
end

function PersonPortraitMainPanelView:ResetLookAtType(IsFace, IsLook)
	self.PortraitDesignRet:ResetLookAtType(IsFace, IsLook)
end

---获取当前设置中未解锁资源类型
function PersonPortraitMainPanelView:GetLockResTypes()
    local LockResTypes = {}

    local CurSetResIDs = PersonPortraitVM:GetCurSetResIDs()
    local StatusMap = PersonPortraitVM.ResStatusMap

    for _, v in pairs(CurSetResIDs) do
        local Cfg = v > 0 and PortraitDesignCfg:FindCfgByKey(v) or nil
        if Cfg then
            local Type = Cfg.TypeID
			if Type and StatusMap[v] ~= PortraitResState.PortraitResStateUnlock and Cfg.UnlockType ~= UnlockTypes.PortraitUnlockTypeDefault then
				table.insert(LockResTypes, Type)
			end
       end
	end

    return LockResTypes
end

function PersonPortraitMainPanelView:CheckSaveSettings()
	if self.PortraitDesignRet:IsModelLoading() then
        MsgTipsUtil.ShowTips(LSTR(60034)) -- "模型加载中，请稍后再尝试保存"
        return false
	end

    if PersonPortraitMgr.IsSavingImg then
        MsgTipsUtil.ShowTips(LSTR(60012)) -- "正在保存中..."
        return false
    end

	PersonPortraitMgr.IsSavingImg = true

	-- 1. 暂停动作
	self:PauseAction()

    -- 2. 肖像模型位置是否合法
	self.PortraitDesignRet:CheckPositionsIsValid()

    if not PersonPortraitVM.IsPositionValid then
		PersonPortraitMgr.IsSavingImg = false
        MsgTipsUtil.ShowErrorTips(LSTR(60014)) -- "请在肖像范围内正确展示玩家角色表情"
        return false
    end

	-- 3.是否有未解锁部件
	local LockResTypes = self:GetLockResTypes() 
    if #LockResTypes > 0 then
		PersonPortraitMgr.IsSavingImg = false

		MsgBoxUtil.ShowMsgBoxTwoOp(
            nil, 
			LSTR(10004), --"提 示"
            LSTR(60017), --"当前设置有未解锁部分，无法进行保存，确认后未解锁的部分将恢复为上次的保存"
			function()
				-- 还原未解锁设置
				for _, v in ipairs(LockResTypes) do
					local ServerResID = PersonPortraitVM:GetPortraitSrcSetResID(v)
					PersonPortraitVM:UpdateCurSelectID(ServerResID, v)
				end
			end,
			nil, LSTR(10003), LSTR(10002)) -- "取 消"、"确 认"
        return false
    end

    -- 在保存流程走完之后(收到PersonalPortrait_SaveDataList --> PersonalPortrait_Get 协议回包)，再重置flag
	-- PersonPortraitMgr.IsSavingImg = false

    return true
end

function PersonPortraitMainPanelView:OnValueChangedRightPanelVisible(IsVisible)
	UIUtil.SetIsVisible(self.RightPanel, IsVisible)

	if IsVisible then
		self:PlayAnimation(self.AnimRefresh) -- 播放动效
	end
end

function PersonPortraitMainPanelView:OnValueChangedDesignRetVisible(IsVisible)
	UIUtil.SetRenderOpacity(self.PortraitDesignRet, IsVisible and 1 or 0)
	self.PortraitDesignRet:SetIsEnabled(IsVisible)
end

function PersonPortraitMainPanelView:OnValueChangedEditPanelVisible(IsVisible)
	UIUtil.SetIsVisible(self.ModelEditPanel, IsVisible)

	-- 挪动模型位置
	local TargetWidget = IsVisible and self.ModelPos1 or self.ModelPos2
	if nil == TargetWidget then
		return
	end

	local TargetSlot = UIUtil.SlotAsCanvasSlot(TargetWidget)
	if nil == TargetSlot then
		return
	end

	local TargetParent = TargetSlot.Parent
	if nil == TargetParent then
		return
	end

	local TargetLocalPos = UIUtil.CanvasSlotGetPosition(TargetWidget)
	local ViewportPos = UIUtil.LocalToViewport(TargetParent, TargetLocalPos)
	local LocalPos = UIUtil.ViewportToLocal(self.MainPanel, ViewportPos) 

	UIUtil.CanvasSlotSetPosition(self.PortraitDesignRet, LocalPos)
end

function PersonPortraitMainPanelView:UpdateItemTipsInfo(ItemVM)
	if nil == ItemVM or table.empty(ItemVM)  then
		UIUtil.SetIsVisible(self.TipsPanel, false)
		return
	end

    local TipsType = ResTipsType.Empty
    if table.contain(PersonPortraitVM.CurProfSetResIDsServer, ItemVM.ID) then
        TipsType = ResTipsType.InUse

    elseif not ItemVM.IsOwned then
        TipsType = ResTipsType.CannotUse

		local Desc = ""
		local TaskID = nil
		local ItemResID = nil
		local GoToTaskVisible = false  

		if ItemVM.IsUnknown then -- 防剧透
			Desc = ItemVM.UnknownDesc or ""
			TaskID = (ItemVM.UnknownUnlockValue or {})[1]

		else -- 未解锁
			Desc = ItemVM.UnlockDesc or ""

			-- 解锁类型是否为任务解锁
			local UnlockType = ItemVM.UnlockType
			if UnlockType == UnlockTypes.PortraitUnlockTypeTask then
				GoToTaskVisible = true
				TaskID = (ItemVM.UnlockValue or {})[1]

			elseif UnlockType == UnlockTypes.PortraitUnlockTypeItem then
				ItemResID = (ItemVM.UnlockValue or {})[1]
			end
		end

		self.TextUnlockDesc:SetText(Desc)
		UIUtil.SetIsVisible(self.FBtnGoToTask, GoToTaskVisible, true)

		if TaskID then
			self:SetTaskIcon(TaskID)
			UIUtil.SetIsVisible(self.Comm58Slot, false)
			UIUtil.SetIsVisible(self.TaskPanel, true)

		elseif ItemResID then
			self:SetItem(ItemResID)
			UIUtil.SetIsVisible(self.TaskPanel, false)
			UIUtil.SetIsVisible(self.Comm58Slot, true)

		else
			UIUtil.SetIsVisible(self.Comm58Slot, false)
			UIUtil.SetIsVisible(self.TaskPanel, false)
		end
    end

	UIUtil.SetIsVisible(self.TextUseTips, 	TipsType == ResTipsType.InUse)
	UIUtil.SetIsVisible(self.ImgObtainBg, 	TipsType ~= ResTipsType.InUse)
	UIUtil.SetIsVisible(self.ObtainPanel, 	TipsType == ResTipsType.CannotUse)
	UIUtil.SetIsVisible(self.TipsPanel, 	TipsType ~= ResTipsType.Empty)
end

function PersonPortraitMainPanelView:SetTaskIcon(TaskID)
	local IconPath = nil
	if TaskID then
		-- 任务图标
		IconPath = QuestMgr:GetQuestIconAtLog(TaskID) 
	end

	local ImgIcon = self.ImgTaskIcon 
	if string.isnilorempty(IconPath) then
		UIUtil.SetIsVisible(ImgIcon, false)
	else
		UIUtil.SetIsVisible(ImgIcon, true)
		UIUtil.ImageSetBrushFromAssetPath(ImgIcon, IconPath)
	end
end

function PersonPortraitMainPanelView:SetItem(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
		return
	end

	local ImgPath = ItemCfg.GetIconPath(Cfg.IconID or 0) or ""
	self.Comm58Slot:SetIconImg(ImgPath)
	self.Comm58Slot:SetQualityImg(ItemUtil.GetItemColorIcon(ResID))
	self.Comm58Slot:SetNumVisible(false)
	UIUtil.SetIsVisible(self.Comm58Slot.IconChoose, false)
	UIUtil.SetIsVisible(self.Comm58Slot.RichTextLevel, false)

	self.Comm58Slot:SetClickButtonCallback(self.Comm58Slot, function(View)
		ItemTipsUtil.ShowTipsByResID(ResID, View)
	end)
end

function PersonPortraitMainPanelView:OnValueChangedCurSelectResID()
	local ItemVM = PersonPortraitVM:GetCurSelectItemVM() or {}

	-- 资源名
	self.TextName:SetText(ItemVM.Name or "")

	-- 资源提示
	self:UpdateItemTipsInfo(ItemVM)
end

-------------------------------------------------------------------------------------------------------
-- 动作

function PersonPortraitMainPanelView:PlayAction(ActionID, Position)
	if nil == ActionID or ActionID <= 0 then
		self:StopAnim(self.ActionMontage)
		return
	end

	if PersonPortraitVM:IsSecretAndLocked(ActionID) then
		return
	end

	self.LastActionPosition = nil

	local ResPath = self:GetMotageResPath(ActionID)
	if string.isnilorempty(ResPath) then
		self.ActionMotageResPath = nil
		return
	end

	self.ActionMotageResPath = ResPath
	self:PlayActionByResPath(ResPath, Position)
end

function PersonPortraitMainPanelView:PlayDefaultCancelAction()
	---将动作设置为默认取消动作
	local ActionID = PersonPortraitDefine.DefaultCancelActionID
	local Cfg = PortraitDesignCfg:FindCfgByKey(ActionID) or {}
	local EmotionID = Cfg.EmotionID

	local Render2DBP
	if self.PortraitDesignRet and self.PortraitDesignRet.ModelToImage then
		Render2DBP =  self.PortraitDesignRet.ModelToImage:GetRender2DBP()
	end
	if Render2DBP == nil then
		_G.FLOG_WARNING("PersonPortraitMainPanelView:PlayDefaultCancelAction Render2DBP is nil ")
		return
	end

	local Actor = Render2DBP.UIComplexCharacter
	if Actor == nil then
		_G.FLOG_WARNING("PersonPortraitMainPanelView:PlayDefaultCancelAction Actor is nil ")
		return
	end

	local EmotionData = EmotionCfg:FindCfgByKey(EmotionID)
	if EmotionData == nil then
		_G.FLOG_WARNING("PersonPortraitMainPanelView:PlayDefaultCancelAction EmotionData is nil ")
		return
	end

	local AnimPath = EmotionAnimUtils.GetActorEmotionAnimPath(
		EmotionData.AnimPath,
		Actor,
		EmotionDefines.AnimType.NORMAL
	)
	self.LastActionPosition = nil
	if string.isnilorempty(AnimPath) then
		self.ActionMotageResPath = nil
		return
	end

	self.ActionMotageResPath = AnimPath
	self:PlayActionByResPath(AnimPath)
	return
end


function PersonPortraitMainPanelView:PlayActionByResPath(ResPath, Position)
	if string.isnilorempty(ResPath) then
		return
	end

	self:StopAnim(self.ActionMontage)

	self.ActionMontage = nil

	local Callback = function() 
		local AnimComp = self:GetAnimComponent()
		if nil == AnimComp then
			return
		end

		local AnimInst = self:GetAnimInstance()
		if nil == AnimInst then
			return
		end

		self:StopEmotionEye(true)

		local AnimRes = ObjectMgr:GetObject(ResPath)
		local PlayRate = Position and 0.00001 or 1
		local Montage = AnimationUtil.PlayMontage(AnimComp, AnimRes, nil, nil, AnimInst, nil, PlayRate, false, 0, 0, Position)
		self.ActionMontage = Montage
		AnimInst:DelayFrameDisableAnimNotifyState(0.2)
		if Position ~= nil and Position <= 0.0002 then
			AnimationUtil.MontagePause(AnimInst, Montage)
		end

		self:UpdateSliderLength()
		self.ToggleBtnPlayState:SetChecked(false, false)
	end

	ObjectMgr:LoadObjectAsync(ResPath, Callback, nil, Callback)
end

function PersonPortraitMainPanelView:OnValueChangedCurSelectActionID(NewValue, OldValue)
	if NewValue == PersonPortraitDefine.DefaultCancelActionID then
		self:PlayDefaultCancelAction()
	else
		self:PlayAction(NewValue)
	end
end

function PersonPortraitMainPanelView:SetEditVMActionPosition(Position)
	if nil == Position then
		return
	end

	local CurModelEditVM = PersonPortraitVM.CurModelEditVM
	if nil == CurModelEditVM then
		return
	end

	CurModelEditVM:SetActionPosition(Position)

	-- 检测模型位置
	self.PortraitDesignRet.IsCheckPositionsIsValid = true
end

function PersonPortraitMainPanelView:UpdateSliderLength()
	local Montage = self.ActionMontage
	if nil == Montage then
		return
	end

	local BlendTime = 0

	local AnimInst = self:GetAnimInstance()
	if AnimInst then
		BlendTime = AnimationUtil.MontageGetBlendTime(AnimInst, Montage)
	end

	local Length = Montage.SequenceLength - BlendTime
	self.SliderLength = Length <= 0 and 1 or Length
end

-------------------------------------------------------------------------------------------------------
-- 表情

function PersonPortraitMainPanelView:PlayEmotion(EmotionID)
	if nil == EmotionID or EmotionID <= 0 then
		self:StopAnim(self.EmotionMontage)
		return
	end

	if PersonPortraitVM:IsSecretAndLocked(EmotionID) then
		return
	end

	local ResPath = self:GetMotageResPath(EmotionID)
	if string.isnilorempty(ResPath) then
		self.EmotionMotageResPath = nil
		return
	end

	self.EmotionMotageResPath = ResPath
	self:PlayEmotionByResPath(ResPath)
end

function PersonPortraitMainPanelView:PlayEmotionByResPath(ResPath)
	if string.isnilorempty(ResPath) then
		return
	end

	self:StopAnim(self.EmotionMontage)

	local Callback = function() 
		local AnimComp = self:GetAnimComponent()
		if nil == AnimComp then
			return
		end

		local AnimInst = self:GetAnimInstance()
		if nil == AnimInst then
			return
		end

		self:StopEmotionEye(true)

		local AnimRes = ObjectMgr:GetObject(ResPath)
		local Montage = AnimationUtil.PlayMontage(AnimComp, AnimRes, nil, nil, AnimInst, nil, 0.00001, false, 0, 0, 0.1)

		self.EmotionMontage = Montage
		AnimInst:DelayFrameDisableAnimNotifyState(0.2)
	end

	ObjectMgr:LoadObjectAsync(ResPath, Callback, nil, Callback)
end

function PersonPortraitMainPanelView:OnValueChangedCurSelectEmotionID(NewValue, OldValue)
	self:PlayEmotion(NewValue)
	if NewValue == 0 then
		self.EmotionPanel:CancelSelectedEmotion()
	end
end

----------------------------------------------
--- 动作表情公共函数

function PersonPortraitMainPanelView:StopAnim(Montage)
	local AnimInst = self:GetAnimInstance()
	if AnimInst and Montage then
		AnimationUtil.MontageStop(AnimInst, Montage) 
	end
end

function PersonPortraitMainPanelView:SetPlaySliderValue(Value)
	local Percent = Value / (self.SliderLength or 1)
	self.LastPlayPercent = Percent

	self.ProgressBarPlay:SetPercent(Percent)
	self.SliderPlay:SetValue(Percent)
end

function PersonPortraitMainPanelView:GetMotageResPath(ResID)
	local Cfg = PortraitDesignCfg:FindCfgByKey(ResID) or {}
	local EmotionID = Cfg.EmotionID
	if nil == EmotionID then
		return
	end

	return EmotionAnimUtils.GetEmotionAtlPath(EmotionID)
end

function PersonPortraitMainPanelView:GetAnimComponent()
	local Ret = self.AnimComponent 
	if nil == Ret then
		local ComImageView = self:GetCommonRender2DToImageView()
		if ComImageView then
			Ret = ComImageView:GetAnimationComponent()
		end

		self.AnimComponent = Ret
	end

	return Ret
end

function PersonPortraitMainPanelView:GetAnimInstance()
	local AnimComp = self:GetAnimComponent()
	if nil == AnimComp then
		return
	end

	local Ret = self.AnimInstance
	if nil == Ret then
		Ret = AnimComp:GetAnimInstance()
		self.AnimInstance = Ret
	end

	return Ret
end

function PersonPortraitMainPanelView:IsPlayingAction()
	local AnimInst = self:GetAnimInstance()
	if nil == AnimInst then
		return false
	end

	local Montage = self.ActionMontage
	if nil == Montage then
		return false
	end

	return AnimationUtil.GetMontagePlayRate(AnimInst, Montage) > 0.1
end

function PersonPortraitMainPanelView:PauseAction()
	local AnimInst = self:GetAnimInstance()
	if nil == AnimInst then
		return
	end

	local Montage = self.ActionMontage
	if nil == Montage then
		return
	end

	if AnimationUtil.GetMontagePlayRate(AnimInst, Montage) <= 0.1 then
		return
	end

	local Position = AnimationUtil.GetMontagePosition(AnimInst, Montage) or 0
	Position = math.max(Position, PersonPortraitDefine.MontageZero)

	self:SetEditVMActionPosition(Position)
	self:PauseActionMontage(Position)
	self.ToggleBtnPlayState:SetChecked(true, false)
end

function PersonPortraitMainPanelView:StopEmotionEye(b)
	local ComImageView = self:GetCommonRender2DToImageView()
	if nil == ComImageView then
		return
	end

	local EmojiAnimInst = ComImageView:GetEmojiAnimInst()
	if EmojiAnimInst and EmojiAnimInst.SetNeedToPauseEye ~= nil then
		EmojiAnimInst:SetNeedToPauseEye(b)
	end
end

function PersonPortraitMainPanelView:PauseActionMontage(Position)
	local AnimInst = self:GetAnimInstance()
	if nil == AnimInst then
		return
	end

	local AnimComp = self:GetAnimComponent()
	if nil == AnimComp then
		return
	end

	local Montage = self.ActionMontage
	if nil == Montage then
		return
	end

	self:StopEmotionEye(true)
	AnimationUtil.MontageStop(AnimInst, Montage)
	self.ActionMontage = AnimationUtil.PlayMontage(AnimComp, Montage, nil, nil, AnimInst, nil, 0.00001, false, 0, 0, Position)
	AnimInst:DelayFrameDisableAnimNotifyState(0.2)
end

function PersonPortraitMainPanelView:ResumeActionMontage(Position)
	local AnimInst = self:GetAnimInstance()
	if nil == AnimInst then
		return
	end

	local Montage = self.ActionMontage
	if nil == Montage then
		return
	end

	local AnimComp = self:GetAnimComponent()
	if nil == AnimComp then
		return
	end

	self:StopEmotionEye(true)
	AnimationUtil.MontageStop(AnimInst, Montage) 
	self.ActionMontage = AnimationUtil.PlayMontage(AnimComp, Montage, nil, nil, AnimInst, nil, 1, false, 0, 0, Position)
end

-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function PersonPortraitMainPanelView:OnSelectionChangedCommMenu(_, ItemData)
	if nil == ItemData then
		return
	end

	PersonPortraitVM:SetCurTab(ItemData:GetKey())

	self:PauseAction()
end

function PersonPortraitMainPanelView:OnSelectionChangedDropDownListProf(_, ItemData)
	if nil == ItemData then
		return
	end

	PersonPortraitVM:ResetProfData()

	local ProfID = ItemData.ID
    PersonPortraitVM.CurProfID = ProfID 

	PersonPortraitMgr:SendGetPersonalPortraitData(ProfID)
	PersonPortraitMgr:SendRemoveAppearUpdateTips(ProfID)

	self.DecoratePanel:CancelSelectedItem()
	self.EmotionPanel:CancelSelectedEmotion()
end

function PersonPortraitMainPanelView:OnEventRemoveAppearUpdateTips(ProfID)
	local ItemVM = self.DropDownListProf:GetDropDownItemVM(ProfID)
	if ItemVM then
		ItemVM:SetIsShowRightIcon(false)
	end
end

function PersonPortraitMainPanelView:OnEventGetPortraitDataSuc()
	-- 资源提示
	self:UpdateItemTipsInfo(PersonPortraitVM:GetCurSelectItemVM())
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function PersonPortraitMainPanelView:OnValueChangedSliderPlay(_, Percent)
	if Percent == self.LastPlayPercent then  -- 用于解决超出滑动区域后，仍然会触发函数值变化
		return
	end

	self.LastPlayPercent = Percent
	self.ProgressBarPlay:SetPercent(Percent)

	-- 暂停播放
	self.ToggleBtnPlayState:SetChecked(true)

	-- 设置播放进度
	local AnimInst = self:GetAnimInstance()
	if AnimInst then
		local Montage = self.ActionMontage
		if Montage then
			local Position = Percent * (self.SliderLength or 1)
			Position = math.max(Position, PersonPortraitDefine.MontageZero)
            --ccppeng
			--小于0.0002默认就是0.0002
            --原因是默认位于首帧的AnimNotifyOffset是0.0001,慢速播放（暂停）会导致过几秒后触发，所以默认首帧直接触发
			if Position < 0.0002  then
				Position = 0.0002
			    AnimationUtil.SetMontagePosition(AnimInst, Montage, Position)
				AnimationUtil.MontagePause(AnimInst, Montage)

			else
				-- 处理滑动条滑动到最右边的时候，会自动播放的问题
				if Percent >= 1 then
					Position = Position - 0.01
				end

				self:PauseActionMontage(Position)
			end

			self:SetEditVMActionPosition(Position)
		end
	end
end

function PersonPortraitMainPanelView:OnStateChangedTogglePlayState(ToggleButton, State)
	local AnimInst = self:GetAnimInstance()
	if nil == AnimInst then
		return
	end

	local Montage = self.ActionMontage
	if nil == Montage then
		return
	end

	local Position = AnimationUtil.GetMontagePosition(AnimInst, Montage) or 0
	Position = math.max(Position, PersonPortraitDefine.MontageZero)

	if UIUtil.IsToggleButtonChecked(State) then
		self:PauseActionMontage(Position)
		self:SetEditVMActionPosition(Position)

	else
		self:ResumeActionMontage(Position)
		self:SetEditVMActionPosition(Position)
	end
end

function PersonPortraitMainPanelView:OnClickButtonBack()
	if PersonPortraitVM:CheckIsSetsChanged() then
		return MsgBoxUtil.ShowMsgBoxTwoOp(
			self, 
			LSTR(10004), --"提 示"
			LSTR(60018), -- "当前有未保存的更改，退出将不会保存，是否确认退出？"
			function() 
				self:Hide()
			end,
			nil, LSTR(10003), LSTR(10002)) -- "取 消"、"确 认"
	end

	self:Hide()
end

function PersonPortraitMainPanelView:OnClickButtonGoToTask()
	local ItemVM = PersonPortraitVM:GetCurSelectItemVM() or {}
	local UnlockValue = ItemVM.UnlockValue
	if nil == UnlockValue then
		return
	end

	local TaskID = UnlockValue[1]
	if TaskID then
		QuestMgr:OpenMapOrLogPanel(TaskID)
	end
end

function PersonPortraitMainPanelView:OnClickButtonSave()
	if self:CheckSaveSettings() then
		PersonPortraitMgr:SendSavePortraitImageData()
	end
end

function PersonPortraitMainPanelView:OnClickButtonSaveStrategySettings()
	_G.UIViewMgr:ShowView(_G.UIViewID.PersonPortraitSaveSetWin)
end

return PersonPortraitMainPanelView