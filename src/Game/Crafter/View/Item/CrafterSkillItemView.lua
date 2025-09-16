---
--- Author: chriswang
--- DateTime: 2023-08-31 17:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")
local EventID = require("Define/EventID")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")

local CrafterSkillItemVM = require("Game/Crafter/CrafterSkillItemVM")
local CrafterConfig = require("Define/CrafterConfig")
local UIBinderSetIsVisibleByBit = require("Binder/UIBinderSetIsVisibleByBit")
local SwitchSkillMap = CrafterConfig.SwitchSkillMap

local SwitchOnAssetPath  <const> = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Crafter_Img_Normal_png.UI_Skill_Crafter_Img_Normal_png'"
local SwitchOffAssetPath <const> = "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Crafter_Img_Grey_png.UI_Skill_Crafter_Img_Grey_png'"

local CrafterSkillCheckMgr <const> = _G.CrafterSkillCheckMgr
local CrafterMgr           <const> = _G.CrafterMgr
local SkillTipsMgr         <const> = _G.SkillTipsMgr
local OneVector2D          <const> = _G.UE.FVector2D(1, 1)



---@class CrafterSkillItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSkill UFButton
---@field IconSkill UFImage
---@field IconSkillSwitc UFImage
---@field ImgLock UFImage
---@field ImgMask UFImage
---@field ImgSlot UFImage
---@field ImgSlotFrame UFImage
---@field PanelNum UFCanvasPanel
---@field TextLevel UFTextBlock
---@field TextNum UFTextBlock
---@field Text_SkillCD UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimClickIn UWidgetAnimation
---@field AnimClickOut UWidgetAnimation
---@field AnimDisable UWidgetAnimation
---@field ButtonIndex int
---@field Color_Enough LinearColor
---@field Color_NotEnough LinearColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterSkillItemView = LuaClass(UIView, true)

local EMaskType = 
{
	SkillCD = 1,
	NotLearned = 2,
	SkillMP = 3,       -- 技能制作力或者耐久不够
	Blacksmith = 4,    -- 锻铁/铸甲的特殊技能遮罩
	Culinarian = 5,    -- 烹饪相关的Mask
	AfflatusLock = 6,  -- 烹饪秘技释放针对同一元素的mask
	AfflatusFirstly = 7,
	AfflatusInspireStorm = 8,
	OtherSkillCasting = 9,
	Condition = 10,  -- 技能条件遮罩
	RandomEvent = 11,
}

function CrafterSkillItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSkill = nil
	--self.IconSkill = nil
	--self.IconSkillSwitc = nil
	--self.ImgLock = nil
	--self.ImgMask = nil
	--self.ImgSlot = nil
	--self.ImgSlotFrame = nil
	--self.PanelNum = nil
	--self.TextLevel = nil
	--self.TextNum = nil
	--self.Text_SkillCD = nil
	--self.AnimClick = nil
	--self.AnimClickIn = nil
	--self.AnimClickOut = nil
	--self.AnimDisable = nil
	--self.ButtonIndex = nil
	--self.Color_Enough = nil
	--self.Color_NotEnough = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterSkillItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterSkillItemView:OnInit()
	self.BaseBtnVM = CrafterSkillItemVM.New()
end

function CrafterSkillItemView:OnDestroy()
end

function CrafterSkillItemView:OnShow()
	self.EntityID = MajorUtil.GetMajorEntityID()

	self.LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if self.LogicData == nil then
		return
	end

	local SkillID = self.LogicData:GetBtnSkillID(self.ButtonIndex)
	self:OnSkillReplace(self.ButtonIndex, SkillID)

	local ProfID = CrafterMgr.ProfID
	self.ProfID = ProfID
	CrafterMgr:RegisterSkillView(ProfID, self.ButtonIndex, self)
end

local CostType_Attr <const> = ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR
local CostValueType_Fix <const> = ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX
local CostValueType_Rate <const> = ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE
local AttrType_MK <const> = ProtoCommon.attr_type.attr_mk

function CrafterSkillItemView:OnSkillReplace(ButtonIndex, SkillID)
	if self.LogicData == nil then
		return
	end

	local VM = self.BaseBtnVM
	self.ButtonIndex = ButtonIndex
	self.BtnSkillID = SkillID
	VM.SkillID = SkillID

	if SwitchSkillMap[SkillID] == true then
		VM.bIsSwitch = true
		VM.bIsSwitchOn = false
	end
	
	self.MaskFlag = 0

	local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
	if not Cfg then
		return
	end
	local IconPath = Cfg.Icon
	if IconPath == nil or IconPath == "None" then
		return
	end

	local CostList = Cfg.CostList or {}
	local AttrComp = MajorUtil.GetMajorAttributeComponent()
	for _, Cost in pairs(CostList) do
		local AssetId = Cost.AdditionAssetId > 0 and Cost.AdditionAssetId or Cost.AssetId
        if Cost.AssetType == CostType_Attr and AssetId == AttrType_MK then
            local ValueType = Cost.ValueType
			local MakeCost = 0
			if ValueType == CostValueType_Fix then
				MakeCost = Cost.AssetCost
			elseif ValueType == CostValueType_Rate then
				self.bMakeCostType_Rate = true
				self.MakeCostRate = Cost.AssetCost / 10000
				local AttrValue = AttrComp and AttrComp:GetAttrValue(AttrType_MK) or 0
				MakeCost = AttrValue * self.MakeCostRate
			end

			if MakeCost > 0 then
				VM.bShowMakeCost = true
				VM.MakeCost = MakeCost
			end
			break
        end
    end


	local bLearnedSkill, LockLevel = self.LogicData:IsSkillLearned(SkillID)
	self.LockLevel = LockLevel or 0
	self:SetLearnedInfo(bLearnedSkill == SkillUtil.SkillLearnStatus.Learned)

	-- 等级够了，学习过了，但可能有工次等问题，所以还需要mask 
	local CDInfo = CrafterSkillCheckMgr:GetSkillCDInfo(SkillID)
	if CDInfo and CDInfo.SkillCD and CDInfo.SkillCD > 0 then
		self:SetSkillCD(CDInfo.BaseCD, CDInfo.SkillCD)
	else
		self:ClearCD()
	end

	self:RefreshMask()

	VM.SkillIcon = IconPath

	local InitMaskMap = self.InitMaskMap or {}
	for MaskType, bHasMask in pairs(InitMaskMap) do
		self:UpdateMaskFlag(bHasMask, MaskType)
	end
end

function CrafterSkillItemView:OnHide()
	self.LogicData = nil
	self.MaskFlag = nil
	local InitMaskMap = self.InitMaskMap
	if InitMaskMap then
		for k, _ in pairs(InitMaskMap) do
			InitMaskMap[k] = nil
		end
	end
	CrafterMgr:UnRegisterSkillView(self.ProfID, self.ButtonIndex, self)
end

function CrafterSkillItemView:RefreshMask()
	-- FLOG_WARNING("=== Crafter MaskFlag : %d", self.MaskFlag)
	if self.MaskFlag > 0 then
		self:SetCommonMask(true)
	else
		self:SetCommonMask(false)
	end
end

function CrafterSkillItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSkill, self.OnClicked)
	UIUtil.AddOnPressedEvent(self, self.BtnSkill, self.OnPressed)
	UIUtil.AddOnReleasedEvent(self, self.BtnSkill, self.OnReleased)
	UIUtil.AddOnLongClickedEvent(self, self.BtnSkill, self.OnLongClicked)
	UIUtil.AddOnLongClickReleasedEvent(self, self.BtnSkill, self.OnLongClickReleased)
end

function CrafterSkillItemView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.CrafterSkillCDUpdate, self.OnCrafterSkillCDUpdate)
	self:RegisterGameEvent(EventID.CrafterSkillRsp, self.UpdateSkillCostMaskFlag)
	-- self:RegisterGameEvent(_G.EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
end

function CrafterSkillItemView:OnRegisterBinder()
	local SwitchBitData = {}
	local PanelNumBitData = {}
	local Binders = {
		{"SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconSkill)},
		{"bCommonMask", UIBinderSetIsVisible.New(self, self.ImgMask) },
		{ "bLevelText", UIBinderSetIsVisible.New(self, self.TextLevel) },
		-- {"LevelText", UIBinderSetTextFormat.New(self, self.TextLevel, _G.LSTR(150079)) },--%d级
		{ "bLockedByLevel", UIBinderSetIsVisible.New(self, self.ImgLock) }, 

		-- {"NormalCDPercent", UIBinderSetPercent.New(self, self.Img_CD) },
		-- {"bNormalCD", UIBinderSetIsVisible.New(self, self.Img_CD)},
		{"SkillCDText", UIBinderSetText.New(self, self.Text_SkillCD) },
		{ "bIsSwitch", UIBinderSetIsVisibleByBit.New(self, self.IconSkillSwitc, SwitchBitData) },
		{ "bLockedByLevel", UIBinderSetIsVisibleByBit.New(self, self.IconSkillSwitc, SwitchBitData, true) },
		{ "bIsSwitchOn", UIBinderValueChangedCallback.New(self, self.IconSkillSwitc, self.OnSwitchStateChanged) },
		{ "bLockedByLevel", UIBinderSetIsVisibleByBit.New(self, self.PanelNum, PanelNumBitData, true) },
		{ "bShowMakeCost", UIBinderSetIsVisibleByBit.New(self, self.PanelNum, PanelNumBitData) },
		{ "bMKEnough", UIBinderValueChangedCallback.New(self, nil, self.OnMKEnoughChanged) },
		{ "MakeCost", UIBinderSetText.New(self, self.TextNum) },
	}

	local VM = self.BaseBtnVM
	VM.bIsSwitch = false
	VM.bIsSwitchOn = false
	VM.bShowMakeCost = false
	VM.bMKEnough = true
	VM.MakeCost = 0

	self:RegisterBinders(self.BaseBtnVM, Binders)
end

-- function CrafterSkillItemView:OnPrepareCastSkill()
-- end

-- function CrafterSkillItemView:OnCastSkill(Params)
-- end

-- function CrafterSkillItemView:OnGameEventMajorUseSkill(Params)
-- end

function CrafterSkillItemView:OnMajorLevelUpdate(Params)
	local Level = Params.RoleDetail.Simple.Level
	if Level >= self.LockLevel then
		self:SetLearnedInfo(true)
	else
		self:SetLearnedInfo(false)
	end

	self:RefreshMask()
end

function CrafterSkillItemView:OnClickBtnSkill(ExtraParams)
	if not self.ButtonIndex or not self.BtnSkillID then
		FLOG_ERROR("CrafterSkillItemView:OnClickBtnSkill Index or SkillID is nil")
		return false
	end
	
	if _G.CrafterMgr:CastLifeSkill(self.ButtonIndex, self.BtnSkillID, ExtraParams) then
		self:PlayAnimation(self.AnimClick)
		FLOG_INFO("==== Crafter OnClickBtnSkill, Idx:%d - %d", self.ButtonIndex, self.BtnSkillID)
		return true
	end
	return false
end

function CrafterSkillItemView:OnClicked()
	local bSuccess = self:OnClickBtnSkill()
	if bSuccess then
		return
	end

	local FailedAnim = self.AnimDisable
	if FailedAnim then
		self:PlayAnimation(FailedAnim)
	end
end

function CrafterSkillItemView:OnPressed()
	self:SetRenderScale(OneVector2D * SkillCommonDefine.SkillBtnClickFeedback)
end

function CrafterSkillItemView:OnReleased()
	self:SetRenderScale(OneVector2D)
end

function CrafterSkillItemView:OnLongClicked()
	self.TipsHandleID = SkillTipsMgr:ShowMajorCrafterSkillTips(self.BtnSkillID, self)
end

function CrafterSkillItemView:OnLongClickReleased()
	if self.TipsHandleID then
		SkillTipsMgr:HideTipsByHandleID(self.TipsHandleID)
		self.TipsHandleID = nil
	end
end

-- 通用黑色遮罩
-- 应用包括但不限于CD遮罩
function CrafterSkillItemView:SetCommonMask(bVisible)
	if bVisible == nil then
		return
	end

	self.BaseBtnVM.bCommonMask = bVisible
end

function CrafterSkillItemView:OnCrafterSkillCostUpdate(AttrCostMap)
	local VM = self.BaseBtnVM
	for AttrType, AttrValue in pairs(AttrCostMap) do
		if AttrType == AttrType_MK then
			if self.bMakeCostType_Rate then
				VM.MakeCost = AttrValue * self.MakeCostRate
			end
			VM.bMKEnough = AttrValue >= VM.MakeCost
			break
		end
	end
end

function CrafterSkillItemView:OnCrafterSkillCDUpdate(Params)
	if self.LogicData == nil then
		return
	end

	-- { SkillID = key, BaseCD = value.BaseCD, SkillCD = value.SkillCD })
	if Params.SkillID ~= self.BtnSkillID then
		return 
	end

	local CurrentCD = Params.SkillCD
	if CurrentCD <= 0 then
		self:ClearCD()
	else
		self:SetSkillCD(Params.BaseCD, CurrentCD)
	end

	self:RefreshMask()
end

function CrafterSkillItemView:UpdateSkillCostMaskFlag(MsgBody)
	if MsgBody and MsgBody.CrafterSkill then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
		if MajorEntityID == MsgBody.ObjID then
			local CostOk = CrafterSkillCheckMgr:CheckSkillCost(self.BtnSkillID)
			if not CostOk then
				self.MaskFlag = self.MaskFlag | (1 << EMaskType.SkillMP)
			else
				self.MaskFlag = self.MaskFlag & (~(1 << EMaskType.SkillMP))
			end

			self:RefreshMask()
        end
    end
end

function CrafterSkillItemView:UpdateMaskFlag(bHasMask, MaskType)
	if not self.MaskFlag then
		self.InitMaskMap = self.InitMaskMap or {}
		local InitMaskMap = self.InitMaskMap
		InitMaskMap[MaskType] = bHasMask
		return
	end

	if bHasMask then
		self.MaskFlag = self.MaskFlag | (1 << MaskType)
	else
		self.MaskFlag = self.MaskFlag & (~(1 << MaskType))
	end

	self:RefreshMask()
end

function CrafterSkillItemView:UpdateCulinarianMaskFlag(bHasMask)
	self:UpdateMaskFlag(bHasMask, EMaskType.Culinarian)
end

function CrafterSkillItemView:UpdateAfflatusLockMaskFlag(bHasMask)
	self:UpdateMaskFlag(bHasMask, EMaskType.AfflatusLock)
end

function CrafterSkillItemView:UpdateAfflatusFirstlyMaskFlag(bHasMask)
	self:UpdateMaskFlag(bHasMask, EMaskType.AfflatusFirstly)
end

function CrafterSkillItemView:UpdateAfflatusInspireStormMaskFlag(bHasMask)
	self:UpdateMaskFlag(bHasMask, EMaskType.AfflatusInspireStorm)
end

function CrafterSkillItemView:SetOutlineState(bShow)
	if bShow ~= self.bOutlineShow then
		if bShow then
			self:PlayAnimation(self.AnimClickIn)
		else
			self:PlayAnimation(self.AnimClickOut)
		end
		self.bOutlineShow = bShow
	end
end

function CrafterSkillItemView:UpdateBlacksmithMaskFlag(bHasMask)
	self:UpdateMaskFlag(bHasMask, EMaskType.Blacksmith)
	self:SetOutlineState(not bHasMask)
end

function CrafterSkillItemView:UpdateConditionMaskFlag(bHasMask)
	self:UpdateMaskFlag(bHasMask, EMaskType.Condition)
end

function CrafterSkillItemView:SetSkillCD(BaseCD, CurrentCD)
	-- local CDPercent = CurrentCD / BaseCD
	-- -- self.BaseBtnVM.bNormalCD = true
	-- if CDPercent > 1 then
	-- 	CDPercent = 1
	-- end

	-- self.BaseBtnVM.NormalCDPercent = 1 - CDPercent
	self.BaseBtnVM.SkillCDText = string.format(LSTR(150069), CurrentCD)--"%d工次"
	self.MaskFlag = self.MaskFlag | (1 << EMaskType.SkillCD)
end

function CrafterSkillItemView:ClearCD()
	-- self.LogicData:SetSkillButtonState(self.ButtonIndex, SkillBtnState.SkillCDMask, true)
	-- self.BaseBtnVM.bNormalCD = false
	self.BaseBtnVM.SkillCDText = ""
	self.MaskFlag = self.MaskFlag & (~(1 << EMaskType.SkillCD))
end

function CrafterSkillItemView:SetLearnedInfo(bLearnedSkill)
	if not bLearnedSkill then
		self.MaskFlag = self.MaskFlag | (1 << EMaskType.NotLearned)
		-- self.BaseBtnVM.LevelText = self.LockLevel
		-- self.BaseBtnVM.bLevelText = true
		self.BaseBtnVM.bLockedByLevel = true
	else
		self.MaskFlag = self.MaskFlag & (~(1 << EMaskType.NotLearned))
		-- self.BaseBtnVM.bLevelText = false
		self.BaseBtnVM.bLockedByLevel = false
	end
end

function CrafterSkillItemView:CheckViewCorrespondingToSkill(Index, SkillID)
	if Index ~= self.ButtonIndex or SkillID ~= self.BtnSkillID then
		_G.FLOG_ERROR(string.format(
			"[CrafterSkillCheck] Cached skill view in CrafterMgr not corresponding, index is: %d, id is: %d.",
			Index or 0, SkillID or 0
		))
		return false
	end
	return true
end

function CrafterSkillItemView:GetEMaskType()
	return EMaskType
end

function CrafterSkillItemView:OnSwitchStateChanged(bIsSwitchOn)
	if bIsSwitchOn then
		UIUtil.ImageSetBrushFromAssetPath(self.IconSkillSwitc, SwitchOnAssetPath, true)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.IconSkillSwitc, SwitchOffAssetPath, true)
	end
end

function CrafterSkillItemView:OnMKEnoughChanged(bIsEnough)
	if bIsEnough then
		self.TextNum:SetColorAndOpacity(self.Color_Enough)
	else
		self.TextNum:SetColorAndOpacity(self.Color_NotEnough)
	end
end

return CrafterSkillItemView