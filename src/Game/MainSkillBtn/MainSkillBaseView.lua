---
--- Author: anypkvcai
--- DateTime: 2021-01-12 10:02
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local SkillUtil = require("Utils/SkillUtil")
local EventID = require("Define/EventID")
local ProtoRes = require ("Protocol/ProtoRes")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local SkillSystemReplaceCfg = require("TableCfg/SkillSystemReplaceCfg")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillCastType = SkillCommonDefine.SkillCastType
local SkillButtonStateMgr = require("Game/Skill/SkillButtonStateMgr")
local SkillBtnState = SkillButtonStateMgr.SkillBtnState
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local CommonUtil = require("Utils/CommonUtil")
local SkillBaseBtnVM = require("Game/MainSkillBtn/SkillBaseBtnVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgTipsID = require("Define/MsgTipsID")
local AttrType = ProtoCommon.attr_type
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")

local KIL = _G.UE.UKismetInputLibrary
local WBL = _G.UE.UWidgetBlueprintLibrary

local OneVector2D = _G.UE.FVector2D(1, 1)



---@class MainSkillBaseView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY

---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainSkillBaseView = LuaClass(UIView, true)

function MainSkillBaseView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY

	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainSkillBaseView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainSkillBaseView:OnInit()
	self.SkillCD = 0
	self.ReChargeCD = 0

	self.HasCDConfig = true
	self.HasReChargeConfig = false

	self.IsLimitSkill = false	--是否是极限技

	--技能系统表现，点击时会展开一个额外的替换按钮
	--单次按下抬起操作是否进入了模拟替换流程
	self.bEnterSimulateReplace = false
	--当前是否显示模拟替换界面
	self.bDisplaySimulateReplace = false

	self.BaseBtnVM = SkillBaseBtnVM.New()

	rawset(self, "LongClickTimerID", nil)
end

function MainSkillBaseView:OnDestroy()
end

function MainSkillBaseView:OnEntityIDUpdate(EntityID, bMajor)
	self.EntityID = EntityID
	self.bMajor = bMajor

	--按下后是否切换技能面板(战斗/非战斗)
	--加速技用的通用交互面板，这里先特殊处理下
	self.bSwitchPanel = false
	if self.bMajor then
		if MajorUtil.IsGpProf() then
			self.bSwitchPanel = self.ButtonIndex == SkillCommonDefine.SkillButtonIndexRange.Normal
		else
			self.bSwitchPanel = self.ButtonIndex ~= SkillCommonDefine.SkillButtonIndexRange.Speed
		end
	end
end

function MainSkillBaseView:OnShow()

	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData == nil then
		--这里直接返回，避免卡loading
		return
	end
	local SkillID = LogicData:GetBtnSkillID(self.ButtonIndex)
	self.BtnSkillID = 0 --相同SkillID的技能不会执行替换流程，因此这里将BtnSkillID设为0以确保替换流程顺利执行

	-- 技能系统专用替换
	if not self.bMajor then
		local Cfg = SkillSystemReplaceCfg:FindCfgByKey(SkillID)
		if Cfg then
			SkillID = Cfg.ReplaceSkillID
		end
	end

	self:OnSkillReplace({SkillIndex = self.ButtonIndex, SkillID = SkillID})
end

function MainSkillBaseView:OnHide()
	self:OnLongClickReleased()
	self:StopLongClickTimer()

	self:UnRegisterAsyncTask()
end

function MainSkillBaseView:OnRegisterUIEvent()

end

function MainSkillBaseView:OnRegisterGameEvent()
	if self.bMajor then
		local RegisterGameEventFunc = self.RegisterGameEvent
		if self.HasCDConfig then
			RegisterGameEventFunc(self, EventID.SkillCDUpdateLua, self.OnSkillCDUpdate)
			RegisterGameEventFunc(self, EventID.SkillCDGroupUpdateLua, self.OnSkillCDGroupUpdate)
		end
		RegisterGameEventFunc(self, EventID.InputActionSkillPressed, self.OnInputActionSkillPressed)
		RegisterGameEventFunc(self, EventID.InputActionSkillReleased, self.OnInputActionSkillReleased)
		RegisterGameEventFunc(self, EventID.CastPreInputChange, self.StopPreInputAnimation)

		RegisterGameEventFunc(self, EventID.PWorldMapEnter, self.OnPWorldMapEnter)
		RegisterGameEventFunc(self, EventID.SkillResSync, self.OnSkillResSync)

		--able btn先不监听这事件
		if not self.bAbleBtn then
			RegisterGameEventFunc(self, EventID.SkillReplace, self.OnSkillReplaceBase)
		end

		--技能主界面/坐骑界面的技能不监听该事件，由父蓝图分发
		if not self:CanParentPanelRouteEvent() then
			RegisterGameEventFunc(self, EventID.MajorUseSkill, self.OnGameEventMajorUseSkillBase)
			RegisterGameEventFunc(self, EventID.SimulateMajorSkillCast, self.OnSimulateMajorSkillCast)
			RegisterGameEventFunc(self, EventID.MajorSkillCastFailed, self.OnSkillCastFailed)
		end

		RegisterGameEventFunc(self, EventID.SkillStatusUpdate, self.OnSkillStatusUpdate)
	end
end

function MainSkillBaseView:OnRegisterTimer()

end

function MainSkillBaseView:OnRegisterBinder()

end

function MainSkillBaseView:CanParentPanelRouteEvent()
	local Parent = rawget(self, "ParentView")
	return Parent and (rawget(Parent, "bMainSkillPanel") or rawget(Parent, "bMainMountPanel") or rawget(Parent, "bMultiSkillPanel"))
	--NewMainSkillView/MainMountPanelView/SkillMultiChoiceDisplayView
end

function MainSkillBaseView:OnPWorldMapEnter(_)

	if self:IsVisible() then
		--切换副本后，如果界面仍显示，则手动执行一次OnShow里的逻辑
		self:OnShow()
	end
end

function MainSkillBaseView:OnSkillStatusUpdate()
	-- 仅主角需要更新技能状态
	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if LogicData then
		local Count = LogicData:GetButtonIndexState(self.ButtonIndex)
		self:SetCommonMask(Count > 0)
	end
end

function MainSkillBaseView:OnGameEventMajorUseSkillBase(Params)
	if Params.ULongParam1 == self.ButtonIndex then
		self:OnGameEventMajorUseSkill(Params)
	end
end

function MainSkillBaseView:OnGameEventMajorUseSkill(Params)
end

function MainSkillBaseView:OnPlayerUseSkill(Params)
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	LogicData:SkillMoveNext(Params.SkillID, Params.Index)
end

-- 通用黑色遮罩
-- 应用包括但不限于CD遮罩，蓝量不足遮罩，权重遮罩和异常状态遮罩
function MainSkillBaseView:SetCommonMask(bVisible)
	if bVisible == nil then
		return
	end
	self.BaseBtnVM.bCommonMask = bVisible
end

function MainSkillBaseView:ChangeSkillIcon(SkillID)
	if SkillID == nil then
		return
	end

	local IconPath = SkillMainCfg:FindValue(SkillID, "Icon")
	if IconPath == nil or IconPath == "None" then
		return
	end

	self.BaseBtnVM.SkillIcon = IconPath
	self.BaseBtnVM.bSkillIcon = true
end

function MainSkillBaseView:UnRegisterAsyncTask()
	local ReplaceTaskID = rawget(self, "ReplaceTaskID")
	if ReplaceTaskID then
		_G.UIAsyncTaskMgr:UnRegisterTask(ReplaceTaskID)
		rawset(self, "ReplaceTaskID", nil)
	end
end

function MainSkillBaseView:OnSkillReplaceBase(Params, bSync)
	if Params.SkillIndex == self.ButtonIndex then
		self:OnSkillReplace(Params, bSync)
	end
end

function MainSkillBaseView:OnSkillReplace(Params, bSync)
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData == nil then
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag("MainSkillBaseView:OnSkillReplace")
	self.BtnSkillID = Params.SkillID
	if not bSync and LogicData:AllowAsync() then
		_G.UIAsyncTaskMgr:UnRegisterTask(rawget(self, "ReplaceTaskID"))
		local co = coroutine.create(self.SkillReplaceCO)
        local ReplaceTaskID = _G.UIAsyncTaskMgr:RegisterTask(co, self, Params)
		rawset(self, "ReplaceTaskID", ReplaceTaskID)
		--先执行一次
		coroutine.resume(co, self, Params)
	else
		self:OnSkillReplaceLogic_Internal(Params)
		self:OnSkillReplaceDisplay_Internal(Params)
		self:OnSkillReplaceFinal_Internal(Params)
	end
end

function MainSkillBaseView:SkillReplaceCO(Params)
	self:OnSkillReplaceLogic_Internal(Params)
	coroutine.yield()
	self:OnSkillReplaceDisplay_Internal(Params)
	coroutine.yield()
	self:OnSkillReplaceFinal_Internal(Params)
	rawset(self, "ReplaceTaskID", nil)
end

function MainSkillBaseView:OnSkillReplaceLogic_Internal(Params)
	local _ <close> = CommonUtil.MakeProfileTag("MainSkillBaseView:OnSkillReplaceLogic_Internal")
	self:OnSkillReplaceLogic(Params)
end

function MainSkillBaseView:OnSkillReplaceDisplay_Internal(Params)
	local _ <close> = CommonUtil.MakeProfileTag("MainSkillBaseView:OnSkillReplaceDisplay_Internal")
	self:OnSkillReplaceDisplay(Params)
end

function MainSkillBaseView:OnSkillReplaceFinal_Internal(Params)
	local _ <close> = CommonUtil.MakeProfileTag("MainSkillBaseView:OnSkillReplaceFinal_Internal")
	self:OnSkillReplaceFinal(Params)
end

--技能替换当前帧执行的逻辑
function MainSkillBaseView:OnSkillReplaceLogic(Params)
	local SkillID = Params.SkillID
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	LogicData:UpdateAllStateList(Params.SkillIndex, Params.SkillID)

	if self.bMajor then
		local SkillCDMgr = _G.SkillCDMgr
		if self.HasCDConfig then
			self.SkillCD = SkillCDMgr:GetSkillRealCDValue(SkillID)
		end

		if self.HasReChargeConfig then
			self.ReChargeCD = SkillCDMgr:GetReChargeCD(SkillID)
		end
	end
end

local AttrType2ButtonStatus = 
{
    [ProtoCommon.attr_type.attr_mp] = SkillBtnState.SkillMP,
    [ProtoCommon.attr_type.attr_gp] = SkillBtnState.SkillGP
}

--OnSkillReplaceLogic后，延迟1-2帧执行表现
function MainSkillBaseView:OnSkillReplaceDisplay(Params)
	local BaseBtnVM = self.BaseBtnVM
	BaseBtnVM:SetSkillID(Params.SkillID)
	if self.bMajor then
		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		local InValidCount = LogicData:GetButtonIndexState(Params.SkillIndex)
		if self.HasCDConfig and self.SkillCD == 0 then
			self:ClearCDMask(false)
		end
		self:SetCommonMask(InValidCount > 0)
	end

	self:ChangeSkillIcon(Params.SkillID)

	if Params.Type ~= nil and self.AnimAlternate ~= nil then
		self:PlayAnimation(self.AnimAlternate)
	end
end

--OnSkillReplaceDisplay后，延迟1-2帧执行结束逻辑
function MainSkillBaseView:OnSkillReplaceFinal(Params)
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if self.bMajor and LogicData then
		--重新计算每个状态的flag
		LogicData:RefreshAllAffectedFlag(Params.SkillIndex, Params.SkillID)
	end
end


function MainSkillBaseView:ClearCDMask(bPlayAnim)
	self.SkillCD = 0
	self.BaseBtnVM.bNormalCD = false
	self.BaseBtnVM.SkillCDText = ""
	if bPlayAnim == true and self.AnimCDFinish ~= nil then
		self:PlayAnimation(self.AnimCDFinish, 0, 1, nil, 1, true)
	end
end
--技能CD更新
function MainSkillBaseView:OnSkillCDUpdate(Params)
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData == nil then
		return
	end
	local ButtonIndex = self.ButtonIndex
	if LogicData:GetBtnSkillID(ButtonIndex) == 0 then
		return
	end
	if not LogicData:GetButtonState(ButtonIndex, SkillBtnState.SkillLearn) then
		self:ClearCDMask(false)
		return
	end

	if self.bCurSelectSkill == true and self.SelectIdList and self.MultiChoicePanel then
		for index, value in ipairs(self.SelectIdList) do
			if value.ID == Params.SkillID then
				self.MultiChoicePanel:OnUpdateSelectCD(index, Params.SkillCD / Params.BaseCD)
			end
		end
		return
	end

	local SkillID = Params.SkillID

	if SkillID ~= self.BtnSkillID then
		return
	end

	local CurrentCD = Params.SkillCD
	self.SkillCD = CurrentCD
	local CDPercent = CurrentCD / Params.BaseCD
	self:DoNormalCDUpdate(CDPercent, CurrentCD)
end

local function GetValidGroupCDInfo(SkillID, GroupID, EntityID, SkillCD, BaseCD)
	local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
	if Cfg and Cfg.CDGroup == GroupID then

		local SkillCDInfo = _G.SkillCDMgr:GetSkillCD(SkillID) or {}
		--当前技能普通CD大于组CD，直接pass
		local CurSkillCD = SkillCDInfo.SkillCD or -0.001
		if CurSkillCD >= SkillCD then
			return nil
		end

		local QuickAttrInvalid = Cfg.QuickAttrInvalid
		if QuickAttrInvalid == 0 then
			local ShortenCDRate = 0
			local AttributeComp = ActorUtil.GetActorAttributeComponent(EntityID)
			if AttributeComp ~= nil then
				ShortenCDRate = AttributeComp:GetAttrValue(AttrType.attr_shorten_cd_time) / 10000
			end
			BaseCD = BaseCD * (1 - ShortenCDRate)
		end

		return { SkillID = SkillID, BaseCD = BaseCD, SkillCD = SkillCD }
	end

	return nil
end

function MainSkillBaseView:OnSkillCDGroupUpdate(Params)
	local GroupID = Params.GroupID
	local SkillCD = Params.SkillCD
	local BaseCD = Params.BaseCD

	if self.bCurSelectSkill == true and self.SelectIdList then
		for _, value in ipairs(self.SelectIdList) do
			local CDInfo = GetValidGroupCDInfo(value.ID, GroupID, self.EntityID, SkillCD, BaseCD)
			if CDInfo then
				self:OnSkillCDUpdate(CDInfo)
			end
		end
		return
	end

	local CDInfo = GetValidGroupCDInfo(self.BtnSkillID, GroupID, self.EntityID, SkillCD, BaseCD)
	if CDInfo then
		self:OnSkillCDUpdate(CDInfo)
	end
end

function MainSkillBaseView:DoNormalCDUpdate(Percent, CurrentCD)

	self.BaseBtnVM.bNormalCD = true
	if Percent > 1 then Percent = 1 end
	self.BaseBtnVM.NormalCDPercent = 1 - Percent
	self.BaseBtnVM.SkillCDText = tostring(math.ceil(CurrentCD))

	if CurrentCD <= 0 then
		self:ClearCDMask(true)
		return
	end
end

function MainSkillBaseView:OnInputActionSkillPressed(Params)
	if Params ~= self.ButtonIndex then return end

	self:OnPrepareCastSkill()
end

function MainSkillBaseView:OnInputActionSkillReleased(Params)
	if Params ~= self.ButtonIndex then return end

	self:OnCastSkill()
end

--是否为蓄力/副摇杆/引导技能
function MainSkillBaseView:IsAdvanceSkill(SkillID)
	local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
	if Cfg then
		return Cfg.IsStorage ~= 0 or Cfg.IsGuide ~= 0 or Cfg.IsEnableSkillJoyStick ~= 0
	end
	return false
end

function MainSkillBaseView:OnPrepareCastSkill()

	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if LogicData == nil then
		FLOG_WARNING("[MainSkillBaseView]LogicData nil, skillid=" .. tostring(self.BtnSkillID or -1))
		return false
	end

	--技能处于按键间隔时不能释放
	if LogicData:CanSkillPressUp(self.ButtonIndex) == false then
		return false
	end


	local _ <close> = CommonUtil.MakeProfileTag("MainSkillBaseView:OnPrepareCastSkill")
	if self.bMajor then

		local bAdvanceSkill = self:IsAdvanceSkill(self.BtnSkillID)
		local bMultiSkill = rawget(self.BaseBtnVM, "bMultiSkill")
		local SkillCD = self.SkillCD
		local bAllowLongClickTips = (not bAdvanceSkill or SkillCD > 0) and not bMultiSkill
		if bAllowLongClickTips then
			self:StartLongClickTimer()
		end

		local SkillType = SkillMainCfg:FindValue(self.BtnSkillID, "SkillFirstClass")
		if SkillType == ProtoRes.skill_first_class.LIFE_SKILL
			or SkillType == ProtoRes.skill_first_class.PRODUCTION_SKILL then

			if SkillCD > 0 or LogicData:CanCastSkill(self.ButtonIndex, true) == false then
				return false
			end
			return true
		end

		if bAdvanceSkill and SkillCD > 0 then
			--高级技能不允许预输入
			return false
		end

		if _G.SkillStorageMgr:GetSkillID() > 0 then
			return false
		end

		local ToleranceTime = _G.SkillSingEffectMgr:GetToleranceTime(self.EntityID)
		--角色处于真实吟唱中
		if ToleranceTime == -1 then
			return
		end

		--不满足预输入最短时间的技能不能释放
		if math.max(ToleranceTime, SkillCD, self.ReChargeCD) * 1000 > _G.SkillPreInputMgr:GetMaxPreInputTime() then
			return false
		end

		if LogicData:CanCastSkill(self.ButtonIndex, true, SkillBtnState.SkillBtnControl, SkillBtnState.SkillWeight) == false then
			return false
		end
	end

	if self.bMajor then
		SkillUtil.PrepareCastSkill(self.EntityID, self.ButtonIndex)
	else
		SkillUtil.PlayerPrepareCastSkill(self.EntityID, self.ButtonIndex, self.BtnSkillID, self.bEnterSimulateReplace)
	end
	return true
end

function MainSkillBaseView:bSupportSecondJoyStick()
	return false
end

function MainSkillBaseView:DoDragSkillStart(MyGeometry, MouseEvent)
	FLOG_WARNING("[MainSkillBaseView]Unimplemented the DoDragSkillStart interface, check it!")
	return
end

function MainSkillBaseView:DoDragSkillMove(MyGeometry, MouseEvent)
	FLOG_WARNING("[MainSkillBaseView]Unimplemented the DoDragSkillMove interface, check it!")
	return
end

function MainSkillBaseView:DoDragSkillEnd()
	FLOG_WARNING("[MainSkillBaseView]Unimplemented the DoDragSkillEnd interface, check it!")
	return
end

function MainSkillBaseView:bSupportSimulateReplace()
	return false
end

function MainSkillBaseView:bSupportStorageSkill()
	return false
end

function MainSkillBaseView:OnMouseCaptureLost()
	--print("MainSkillBaseView:OnMouseCaptureLost" .. tostring(self.ButtonIndex))
	self:OnMouseButtonUp(nil, nil)
end

local function IsValidEffectingButton(MouseEvent)
	return KIL.Key_IsValid(KIL.PointerEvent_GetEffectingButton(MouseEvent)) and KIL.PointerEvent_IsTouchEvent(MouseEvent)
end

function MainSkillBaseView:OnMouseButtonDown(MyGeometry, MouseEvent)
	
	self:SetRenderScale(OneVector2D * SkillCommonDefine.SkillBtnClickFeedback)

	local Handled = WBL.Handled()
	if (self.BtnSkillID or 0) == 0 then return WBL.CaptureMouse(Handled, self) end

	-- 屏蔽一下测试的多指操作
	if not self.bMajor then
		if _G.SkillSystemMgr.PressedButtonIndex ~= nil then
			return WBL.CaptureMouse(Handled, self)
		end
		_G.SkillSystemMgr.PressedButtonIndex = self.ButtonIndex
	else
		if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_USE_SKILL, true) then
			return WBL.CaptureMouse(Handled, self)
		end
	end
	
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if ActorUtil.IsDeadState(self.EntityID) == false and IsValidEffectingButton(MouseEvent) then
		local _ <close> = CommonUtil.MakeProfileTag("MainSkillBaseView:OnMouseButtonDown")
		self.MouseEnter = true
		self.MouseDown = true

		self.bEnterSimulateReplace = false
		if self:bSupportSimulateReplace() and not self.bDisplaySimulateReplace then
			self.bDisplaySimulateReplace = true
			self.bEnterSimulateReplace = true
			self:OnPrepareCastSkill()
			
			LogicData:SetSkillPressFlag(self.ButtonIndex, true)	--只有处于按下状态的按钮才应当执行抬起流程
			self.PressSkill = self.BtnSkillID  --按下时记录当前按钮技能ID，抬起时ID相同才能释放
			return WBL.CaptureMouse(Handled, self)
		end

		--三选一技能直接调用MainSkillButton方法
		if self.bCurSelectSkill then
			self.PressSkill = self.BtnSkillID
			local RetTemp = self:MainSkillButtonDown(MyGeometry, MouseEvent)
			return RetTemp
		end

		if self.IsLimitSkill and not self:CanCastLimitSkill() then
			return WBL.CaptureMouse(Handled, self)
		end

		self.bFirstMove = false
		
		if self:OnPrepareCastSkill() == true then
			LogicData:SetSkillPressFlag(self.ButtonIndex, true)	--只有处于按下状态的按钮才应当执行抬起流程
			self.PressSkill = self.BtnSkillID  --按下时记录当前按钮技能ID，抬起时ID相同才能释放

			--主角才能开启副摇杆
			local bDragSubSkill = SkillMainCfg:FindValue(self.BtnSkillID, "IsEnableSkillJoyStick") or 0
			local bDrag = bDragSubSkill ~= 0 and self.bMajor and self:bSupportSecondJoyStick()
			if bDrag == true then
				self.bDragSkill = true
				self:DoDragSkillStart(MyGeometry, MouseEvent)
			end
		end
	end

	return WBL.CaptureMouse(Handled, self)
end

function MainSkillBaseView:OnMouseEnter(MyGeometry, MouseEvent)
	if (self.BtnSkillID or 0) == 0 then return end

	if self.MouseDown == true and IsValidEffectingButton(MouseEvent) then
		--FLOG_ERROR("MainSkillBaseView:OnMouseEnter")
		self.MouseEnter = true
	end
end

function MainSkillBaseView:OnMouseLeave(MouseEvent)
	if (self.BtnSkillID or 0) == 0 then return end

	if self.MouseDown == true and IsValidEffectingButton(MouseEvent) then
		--FLOG_ERROR("MainSkillBaseView:OnMouseLeave")
		self.MouseEnter = false

		self:StopLongClickTimer()
	end
end

function MainSkillBaseView:OnMouseMove(MyGeometry, MouseEvent)
	local Handled = WBL.Handled()
	if (self.BtnSkillID or 0) == 0 then return Handled end

	if IsValidEffectingButton(MouseEvent) then
		if self.bDragSkill == true then
			self:DoDragSkillMove(MyGeometry, MouseEvent)
		elseif self.CanPressSelectSkill then
			return self:MainSkillButtonMouseMove(MyGeometry, MouseEvent)
		end
	end
	return Handled
end

function MainSkillBaseView:OnMouseButtonUp(MyGeometry, MouseEvent)
	self:SetRenderScale(OneVector2D)
	local Handled = WBL.Handled()
	if (self.BtnSkillID or 0) == 0 then return Handled end

	if not self.bMajor then
		if _G.SkillSystemMgr.PressedButtonIndex ~= self.ButtonIndex then
			return WBL.Unhandled()
		end
		_G.SkillSystemMgr.PressedButtonIndex = nil
	end

	if self.MouseDown and (not MouseEvent or IsValidEffectingButton(MouseEvent)) then
		self.MouseDown = false
		if rawget(self, "LongClickTimerID") then
			local CurTime = _G.UE.UTimerMgr:Get().GetLocalTimeMS()
			if CurTime - self.StartLongClickTime > SkillCommonDefine.SkillTipsClickTime * 1000 then
				self:StopLongClickTimer()
				self:OnLongClickReleased()
				return WBL.ReleaseMouseCapture(Handled)
			else
				self:StopLongClickTimer()
			end
		end
		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		if not LogicData or not LogicData:IsSkillPress(self.ButtonIndex) then
			self:SkillCastFailed()
			return WBL.ReleaseMouseCapture(Handled)
		end
	
		LogicData:SetSkillPressFlag(self.ButtonIndex, false)
		if self.PressSkill ~= self.BtnSkillID then
			self:SkillCastFailed()
			return WBL.ReleaseMouseCapture(Handled)
		end --按下和抬起的技能ID不匹配，不能释放



		local _ <close> = CommonUtil.MakeProfileTag("MainSkillBaseView:OnMouseButtonUp")
		if self:bSupportSimulateReplace() and self.bEnterSimulateReplace then
			self:DoSimulateReplace()
			return WBL.ReleaseMouseCapture(Handled)
		end

		local bMajor = self.bMajor
		if bMajor and not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_USE_SKILL, true) then
			self:SkillCastFailed()
			self:CancelPressStatus()
			return WBL.ReleaseMouseCapture(Handled)
		end

		if self.bCurSelectSkill then
			local RetTemp = self:MainSkillButtonUp(MyGeometry, MouseEvent)
			return RetTemp
		end

		if self.IsLimitSkill and not self:CanCastLimitSkill() then
			return WBL.ReleaseMouseCapture(Handled)
		end

		local CurrentSkillID = self.BtnSkillID
		if self.bDragSkill == true then
			self:DoDragSkillEnd()
			self.bDragSkill = false
		elseif self.MouseEnter == true or _G.SkillStorageMgr:IsStorageSkill(CurrentSkillID) == true or _G.SkillGuideMgr:IsCurrentGuideSkill(CurrentSkillID) then
			if not self:OnCastSkill() then
				self:SkillCastFailed()
			end
		end
	end
	return WBL.ReleaseMouseCapture(Handled)
end

function MainSkillBaseView:OnCastSkill(Params)
	local _ <close> = CommonUtil.MakeProfileTag("MainSkillBaseView:OnCastSkill")
	if self.bSwitchPanel == true then
		EventMgr:SendEvent(EventID.SkillBtnClick, {BtnIndex = self.ButtonIndex, SkillID = self.BtnSkillID})
	end
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if not LogicData then
		return
	end

	LogicData:SetSkillPressUp(self.ButtonIndex)

	if self.bMajor then
		if not LogicData:CanCastSkill(self.ButtonIndex, true, SkillBtnState.SkillBtnControl, SkillBtnState.SkillWeight) then
			return
		end

		--生活类技能走新的协议与流程
		local SkillType = SkillMainCfg:FindValue(self.BtnSkillID, "SkillFirstClass")
		--生活技能不存在蓄力，因此判断角色死亡放在这里
		local bMajorDead = MajorUtil.IsMajorDead()
		if (SkillType == ProtoRes.skill_first_class.LIFE_SKILL
			or SkillType == ProtoRes.skill_first_class.PRODUCTION_SKILL)
			 and not bMajorDead then
			return SkillUtil.CastLifeSkill(self.ButtonIndex, self.BtnSkillID)
		end
		local ToleranceTime = _G.SkillSingEffectMgr:GetToleranceTime(self.EntityID)
		local CastType, RetParams = SkillUtil.CastSkill(self.EntityID, self.ButtonIndex, self.BtnSkillID, math.max(self.ReChargeCD, self.SkillCD, ToleranceTime), Params)
		if CastType then
			return true
		end
	else
		-- 对于蓄力技能, 蓄力到一定程度自动释放, 这里松开按钮时不再执行一遍Cast的逻辑
		local EntityID = self.EntityID
		local BtnSkillID = self.BtnSkillID
		local SkillStorageMgr = SkillStorageMgr
		if SkillStorageMgr:IsStorageSkill(BtnSkillID) and SkillStorageMgr.EntityID ~= EntityID then
			return true
		end

		local Cfg = SkillMainCfg:FindCfgByKey(BtnSkillID)
		local bJoyStick = Cfg and (Cfg.IsEnableSkillJoyStick > 0) or nil
		-- 清状态
		_G.SkillSystemMgr:ClearAllSkillSystemEffectWithoutFade() 
		SkillUtil.PlayerCastSkill(EntityID, self.ButtonIndex, BtnSkillID, bJoyStick)
		return true
	end
end

function MainSkillBaseView:StopPreInputAnimation(_)
	if self.PreInputAnimTimer ~= nil then
		self:UnRegisterTimer(self.PreInputAnimTimer)
		self.PreInputAnimTimer = nil
		self:StopAnimation(self.AnimImportLoop)
		self:PlayAnimation(self.AnimHide)
	end
end

function MainSkillBaseView:StartLongClickTimer()
	local LongClickTimerID = rawget(self, "LongClickTimerID")
	if LongClickTimerID then
		self:UnRegisterTimer(LongClickTimerID)
	end

	self.StartLongClickTime = _G.UE.UTimerMgr:Get().GetLocalTimeMS()
	LongClickTimerID = self:RegisterTimer(self.OnLongClick, SkillCommonDefine.SkillTipsClickTime, 1, 1)
	rawset(self, "LongClickTimerID", LongClickTimerID)
end

function MainSkillBaseView:StopLongClickTimer()
	local LongClickTimerID = rawget(self, "LongClickTimerID")
	if LongClickTimerID then
		self:OnLongClickReleased()
		self:UnRegisterTimer(LongClickTimerID)
		rawset(self, "LongClickTimerID", nil)
	end
end

function MainSkillBaseView:OnLongClick()
	-- FLOG_INFO("MainSkillBaseView:OnLongClick")
end

function MainSkillBaseView:OnLongClickReleased()
	-- FLOG_INFO("MainSkillBaseView:OnLongClickReleased")
end

function MainSkillBaseView:OnSkillAssetAttrUpdate(Params)
end

function MainSkillBaseView:OnSkillResSync(Params)
	
	if self.BtnSkillID ~= Params.SkillID then
		return
	end
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
	if not LogicData then
		return
	end
	local Index = self.ButtonIndex
	local Key = AttrType2ButtonStatus[Params.ResType]
	local bValid, RequireCost = LogicData:PlayerAttrCheck(Index, self.BtnSkillID, Params.ResType)
	LogicData:SetSkillButtonState(Index, Key, bValid, RequireCost)
	self:OnSkillAssetAttrUpdate({Key = Key})
end

function MainSkillBaseView:OnSimulateMajorSkillCast(Index)
	if self.ButtonIndex == Index then
		self:OnPrepareCastSkill()
    	self:OnCastSkill()
	end
end

function MainSkillBaseView:OnSkillCastFailed(Index)
	if self.ButtonIndex == Index then
		self:SkillCastFailed()
	end
end

function MainSkillBaseView:SkillCastFailed()
	local AnimDisable = self.AnimDisable
	if AnimDisable then
		self:PlayAnimationToEndTime(AnimDisable)
	end
end

function MainSkillBaseView:CancelPressStatus()
end

return MainSkillBaseView