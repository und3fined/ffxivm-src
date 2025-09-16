---
--- Author: chriswang
--- DateTime: 2022-05-13 14:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MainSkillBaseView = require("Game/MainSkillBtn/MainSkillBaseView")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local EventMgr = _G.EventMgr
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ESlateVisibility = _G.UE.ESlateVisibility
local KIL = _G.UE.UKismetInputLibrary
local WBL = _G.UE.UWidgetBlueprintLibrary
local SBL = _G.UE.USlateBlueprintLibrary
local AudioUtil = require("Utils/AudioUtil")
local MsgTipsID = require("Define/MsgTipsID")

---@class SkillLimitBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtn_Skill UFButton
---@field FImg_CD URadialImage
---@field FImg_CDBar UFImage
---@field FImg_Ready UFImage
---@field Icon_Skill UFImage
---@field LBMode1 UFHorizontalBox
---@field LBMode2 UFCanvasPanel
---@field SecondJoyStick SecondJoyStickView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillLimitBtnView = LuaClass(MainSkillBaseView, true)

--读条结束的特效
local SingOverEff = {
	[1] = "Animshifang1",
	[2] = "Animshifang2",
	[3] = "Animshifang",
}

--每满一格播放的特效
local PhaseBarEff = {
	[1] = {"AnimFirstBar1"},
	[2] = {"AnimSecondBar1", "AnimSecondBar2"},
	[3] = {"AnimFirstBar", "AnimSecondBar", "AnimThirdBar"},
}

function SkillLimitBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FBtn_Skill = nil
	--self.FImg_CD = nil
	--self.FImg_CDBar = nil
	--self.FImg_Ready = nil
	--self.Icon_Skill = nil
	--self.LBMode1 = nil
	--self.LBMode2 = nil
	--self.SecondJoyStick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillLimitBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SecondJoyStick)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
	for _, value in ipairs(self.SubViews) do
		value.EntityID = self.EntityID
		value.bMajor = self.bMajor
	end
end

function SkillLimitBtnView:OnInit()
	self.Super:OnInit()

	local LimitSkillIndex = _G.SkillLimitMgr:GetLimitSkillIndex()
	local LimitSkillID = _G.SkillLimitMgr:GetLimitSkillID()

	self.ButtonIndex = 16
	FLOG_INFO("SkillLimitBtn OnInit LimitSkillIndex:%d LimitSkillID:%d", LimitSkillIndex, LimitSkillID)
	if LimitSkillID > 0 and LimitSkillIndex > 0 then
		self.ButtonIndex = LimitSkillIndex
	end

	-- self.LastSkillID = 0
	self.IsEntrance = false
end

function SkillLimitBtnView:SetParentView(NewMainSkillView)
	self.MainSkillPanelView = NewMainSkillView
end

function SkillLimitBtnView:OnDestroy()

end

function SkillLimitBtnView:OnShow()
	--不触发基类的MainSkillBaseView:OnShow()，自己显示技能图标等
	self.Super:OnShow() --使用基类的  （这里的OnSkillReplace就不实现了，使用基类的）
	
	local LimitSkillID = _G.SkillLimitMgr:GetLimitSkillID()
	local LimitSkillIndex = _G.SkillLimitMgr:GetLimitSkillIndex()
	if LimitSkillID > 0 then
		FLOG_INFO("SkillLimitBtn OnShow SkillIndex:%d, SkillID:%d", LimitSkillIndex, LimitSkillID)
		self:SkillReplace({SkillIndex = LimitSkillIndex, SkillID = LimitSkillID})
	end

	self.IsLimitSkill = true

	self:RefreshUI()
end

--因为ButtonIndex和ButtonSkillID可能会变的
function SkillLimitBtnView:SkillReplace(Params)
	self.ButtonIndex = Params.SkillIndex

	self.Super:OnSkillReplace(Params)
end

function SkillLimitBtnView:RefreshUI(IsPlayPhaseBarEff)
	local MaxValue = _G.SkillLimitMgr:GetLimitMaxValue()
	local Value = _G.SkillLimitMgr:GetLimitValue()
	local LimitSkillID = _G.SkillLimitMgr:GetLimitSkillID()
	local MaxPhase = _G.SkillLimitMgr:GetMaxPhase()
	if MaxPhase and MaxValue > 0 and LimitSkillID > 0 and MaxPhase > 0 then
		-- if self.LastSkillID ~= LimitSkillID then
		-- 	local MainSkillCfg = SkillMainCfg:FindCfgByKey(LimitSkillID)
		-- 	if MainSkillCfg then
		-- 		self.LastSkillID = LimitSkillID
		-- 		UIUtil.ImageSetBrushFromAssetPath(self.Icon_Skill, MainSkillCfg.Icon)
		-- 	end
		-- end

		--这个是极限值的进度，不是cd
		local ValuePerPhase = _G.SkillLimitMgr:GetValuePerPhase()
		local CurPhaseValue = _G.SkillLimitMgr:GetCurPhaseValue()
		self.FImg_CD:SetRenderOpacity(1)
		self.FImg_CD:SetPercent(CurPhaseValue / ValuePerPhase)

		local CurPhase = _G.SkillLimitMgr:GetCurPhase()
		if MaxPhase > 0 and CurPhase == MaxPhase then
			UIUtil.SetIsVisible(self.FImg_Ready, true)
			self.FImg_Ready:SetRenderOpacity(1)
		else
			UIUtil.SetIsVisible(self.FImg_Ready, false)
		end

		if MaxPhase == 1 or MaxPhase == 3 then
			UIUtil.SetIsVisible(self.LBMode1, true)
			UIUtil.SetIsVisible(self.LBMode2, false)

			if MaxPhase == 1 then
				UIUtil.SetIsVisible(self.LimitBar1, false)
				UIUtil.SetIsVisible(self.LimitBar3, false)
				UIUtil.SetIsVisible(self.LimitBar2, true)

				if not IsPlayPhaseBarEff then
					if CurPhase == 1 then
						self.FImg_Full2:SetRenderOpacity(1)
						UIUtil.SetToggleButtonSlotType(self.FImg_Full2, _G.UE.EToggleButtonState.Unchecked)
					else
						UIUtil.SetToggleButtonSlotType(self.FImg_Full2, _G.UE.EToggleButtonState.Checked)
					end
				end
			else
				UIUtil.SetIsVisible(self.LimitBar1, true)
				UIUtil.SetIsVisible(self.LimitBar3, true)
				UIUtil.SetIsVisible(self.LimitBar2, true)

				if not IsPlayPhaseBarEff then
					for index = 1, 3 do
						local ImgFull = self["FImg_Full" .. index]
						if index <= CurPhase then
							ImgFull:SetRenderOpacity(1)
							UIUtil.SetToggleButtonSlotType(ImgFull, _G.UE.EToggleButtonState.Unchecked)
						else
							UIUtil.SetToggleButtonSlotType(ImgFull, _G.UE.EToggleButtonState.Checked)
						end
					end
				end
			end
		else	-- 2
			UIUtil.SetIsVisible(self.LBMode1, false)
			UIUtil.SetIsVisible(self.LBMode2, true)
			self.LBMode2:SetRenderOpacity(1)
			if not IsPlayPhaseBarEff then
				for index = 1, 2 do
					local ImgFull = self["FImg_Full2" .. index]
					if index <= CurPhase then
						ImgFull:SetRenderOpacity(1)
						UIUtil.SetToggleButtonSlotType(ImgFull, _G.UE.EToggleButtonState.Unchecked)
					else
						UIUtil.SetToggleButtonSlotType(ImgFull, _G.UE.EToggleButtonState.Checked)
					end
				end
			end
		end

		if IsPlayPhaseBarEff and CurPhase and PhaseBarEff[MaxPhase] then
			local BeginIndex = _G.SkillLimitMgr:GetLastPhase() + 1
			for index = BeginIndex, CurPhase do
				local AnimName = PhaseBarEff[MaxPhase][index]
				-- print("limit Play phase anim " .. index .. "   AnimName: " .. AnimName)
				if AnimName then
					local EffAnim = self[AnimName]
					if EffAnim then
						self:PlayAnimation(EffAnim)
					end
				end
			end
		end
	end
end

function SkillLimitBtnView:OnHide()

end

function SkillLimitBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtn_Skill, self.OnClickBtn)
end

function SkillLimitBtnView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.EndUseLimitSkill, self.OnLimitSkillEnd)
	self:RegisterGameEvent(EventID.BeginUseLimitSkill, self.OnLimitSkillBegin)
	--对于break，是在StopSingLoopAnim那面监听这2个事件，然后处理的
	-- self:RegisterGameEvent(EventID.ThirdPlayerSkillSingBreak, self.OnOtherSingBreak)
	-- self:RegisterGameEvent(EventID.MajorBreakSing, self.OnMajorSingBreak)
	self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
end

function SkillLimitBtnView:OnRegisterBinder()

end

function SkillLimitBtnView:OnSkillReplace(Params)
    if Params.SkillIndex == self.ButtonIndex then
		self.Super:OnSkillReplace(Params)
    end
end

function SkillLimitBtnView:OnLimitSkillBegin(Params)
	if Params and Params.EntityID then
		if MajorUtil.GetMajorEntityID() == Params.EntityID then
			print("limit major cast limitskill")
		else
			print("limit other cast limitskill")
			_G.SkillLimitMgr.EntranceLoopAniming = true

			if self.IsEntrance then
				self:PlaySingLoopAnim()
			end
		end
	end
end

function SkillLimitBtnView:OnLimitSkillEnd(Params)
	Params.EntityID = Params.EntityID or 0
	local MaxPhase = _G.SkillLimitMgr:GetMaxPhase()
	if MajorUtil.GetMajorEntityID() == Params.EntityID then
		print("limit major cast limitskill over =======")
	else
		_G.SkillLimitMgr.EntranceLoopAniming = false
		print("limit other cast limitskill over =======")
		if self.IsEntrance then
			-- self:StopSingLoopAnim()

			if Params.IsMsgUpdateLimit then
				local CurPhase = _G.SkillLimitMgr:GetCurPhase()
				if MaxPhase >= 1 and MaxPhase <= 3 and CurPhase < Params.LastPhase then
					self:PlayAnimation(self[SingOverEff[MaxPhase]])
				end
			end
		end
	end
end

function SkillLimitBtnView:PlaySingLoopAnim()
	print("limit Play sing loopanim")
	-- UIUtil.SetIsVisible(self.FImg_Ready, true)
	UIUtil.SetIsVisible(self.EFF_UI_CircleGlow_03, true)
	UIUtil.SetIsVisible(self.EFF_UI_IconGlow_04, true)
	self:PlayAnimation(self.AnimLoopNotImmediately)
end

function SkillLimitBtnView:StopSingLoopAnim(IsBreak)
	print("limit stop sing loopanim")
	self:PlayAnimation(self.AnimLoopStop)
	UIUtil.SetIsVisible(self.EFF_UI_CircleGlow_03, false)
	UIUtil.SetIsVisible(self.EFF_UI_IconGlow_04, false)

	if not IsBreak then
		-- UIUtil.SetIsVisible(self.FImg_Ready, false)
	else
		AudioUtil.LoadAndPlayUISound(
			"/Game/WwiseAudio/Events/UI/UI_SYS/LIMIT/Play_se_ui_new_limit_close.Play_se_ui_new_limit_close")
	end
end

--NewMainSkill会控制该按钮是否透传（右上角的是可点击，右下角的是透传的）
function SkillLimitBtnView:OnClickBtn()
	if self.MainSkillPanelView then
		local ParentView = self.MainSkillPanelView.ParentView
		if ParentView and ParentView.GetIsPeaceAniming and ParentView:GetIsPeaceAniming() then
			-- FLOG_INFO("             ================== SkillLimit ===========")
			return 
		end

		_G.EventMgr:SendEvent(EventID.SkillLimitEntranceClick)
		self.MainSkillPanelView:SwitchToLimitSkillCastState()
	end
end

function SkillLimitBtnView:CanCastLimitSkill()
	-- if _G.SkillLimitMgr.SkillSingUILoopAniming then
	-- 	print("limit CanCastLimitSkill   major is singing")
	-- 	return false
	-- end
	
	if _G.SkillLimitMgr:IsOtherLimitSkilling() then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.LimitSkillOtherCasting)  -- 队友正在施放极限技
		return false
	elseif _G.SkillLimitMgr:IsMajorLimitSkilling() then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.LimitSkillMajorCasting)  -- 主角自己正在施放极限技
		return false
	end

	print("limit CanCastLimitSkill true")

	return true
end

function SkillLimitBtnView:MainSkillButtonDown(MyGeometry, MouseEvent)
	if not _G.SkillLogicMgr:CanCastSkill(self.ButtonIndex) then
		return
	end

	_G.SkillLogicMgr:SetSkillPress(self.ButtonIndex, true)
	local Handled = WBL.Handled()
	return WBL.CaptureMouse(Handled, self)
end


function SkillLimitBtnView:MainSkillButtonMouseMove(MyGeometry, MouseEvent)
	-- local MousePosition = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	-- local SelectIndex = self.MultiChoicePanel:GetHoverButtonIndex(MousePosition, false)
	-- _G.SkillLogicMgr.SkillMultiChoiceDisplay:OnHoverSkillSelect(SelectIndex)
	return true
end

function SkillLimitBtnView:MainSkillButtonUp(MyGeometry, MouseEvent)
	-- if _G.SkillLimitMgr.EntranceLoopAniming then
	-- 	print("limit MainSkillButtonUp other is singing")
	-- 	return
	-- end

	-- print("limit MainSkillButtonUp cast skill")
	-- EventMgr:SendEvent(EventID.SkillBtnClick, {BtnIndex = self.ButtonIndex, SkillID = self.BtnSkillID})
	_G.SkillLogicMgr:SetSkillPress(self.ButtonIndex, false)
	local Handled = WBL.Handled()
	return WBL.ReleaseMouseCapture(Handled)
end

local SkillUtil = require("Utils/SkillUtil")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
-- local KIL = _G.UE.UKismetInputLibrary
local MinMoveDistSquared = 200	--拖拽视为移动时的最小判定
local UIViewID = require("Define/UIViewID")

function SkillLimitBtnView:bSupportSecondJoyStick()
	return true
end

function SkillLimitBtnView:DoDragSkillStart(_, MouseEvent)
	local SubSkillID = SkillUtil.MainSkill2SubSkill(self.BtnSkillID)
	self.DragStartPos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	UIUtil.SetIsVisible(self.SecondJoyStick, true)

	local Params = {OnMoveCallbackPtr = self.SecondJoyStick, OnMoveCallback = self.SecondJoyStick.OnCancelJSMoveCB, bInvalidateWhenEnter = true}
	self.CancelJoyStickView = _G.UIViewMgr:ShowView(UIViewID.SkillCancelJoyStick, Params)
	if self.CancelJoyStickView then
		self.CancelJoyStickView:OnDragSkillStart(Params)
	end
	
	if self.IsLimitSkill then
		_G.EventMgr:SendEvent(EventID.DragSkillBegin)
	end
	self.SecondJoyStick:InitSkillData(self.BtnSkillID, SubSkillID)
end

function SkillLimitBtnView:DoDragSkillMove(MyGeometry, MouseEvent)
	local CurPos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if self.bFirstMove == false then
		local DistSquared = _G.UE.FVector2D.DistSquared(self.DragStartPos, CurPos)
		if DistSquared > MinMoveDistSquared then
			self.bFirstMove = true
			self.SecondJoyStick:InitGeometryData()
			self.SecondJoyStick:OnJoyStickMove(CurPos)
		end
	else
		self.SecondJoyStick:OnJoyStickMove(CurPos)
	end

	if self.CancelJoyStickView then
		self.CancelJoyStickView:RouteMouseMove(MyGeometry, MouseEvent)
	end
end

function SkillLimitBtnView:DoDragSkillEnd()
	local bCancelEnter = self.CancelJoyStickView:GetCancelStatus()
	if bCancelEnter == false then
		local JoystickValid = self.SecondJoyStick:IsJoystickValid()
		local DecalState = self.SecondJoyStick:GetDecalState()
		if JoystickValid == true and DecalState == true then
			self:OnCastSkill({Position = self.SecondJoyStick:GetAbsolutePosition(), Angle = self.SecondJoyStick:GetAbsoluteAngle()})
		elseif JoystickValid == true then
			_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillCannotSeeTarget)--"看不见目标"
		else
			self:OnCastSkill()
		end
	else
		if self.bSwitchPanel == true then
			EventMgr:SendEvent(EventID.SkillBtnClick, {BtnIndex = self.ButtonIndex, SkillID = self.BtnSkillID})
		end
		local LogicData = _G.SkillLogicMgr:GetSkillLogicData(self.EntityID)
		if LogicData then
			LogicData:SetSkillPressFlag(self.ButtonIndex, false)
		end
	end
	UIUtil.SetIsVisible(self.SecondJoyStick, false)
	_G.UIViewMgr:HideView(UIViewID.SkillCancelJoyStick, true)

	if self.IsLimitSkill then
		_G.EventMgr:SendEvent(EventID.DragSkillEnd)
	end
end

return SkillLimitBtnView