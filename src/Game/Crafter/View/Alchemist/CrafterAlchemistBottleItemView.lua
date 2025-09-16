---
--- Author: chriswang
--- DateTime: 2023-08-31 17:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local ItemCfg = require("TableCfg/ItemCfg")
local CatalystCfg = require("TableCfg/CatalystCfg")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local AlchemistBottleItemVM = require("Game/Crafter/Alchemist/AlchemistBottleItemVM")
local AlchemistMainVM = require("Game/Crafter/Alchemist/AlchemistMainVM")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local CrafterConfig = require("Define/CrafterConfig")
local AudioUtil = require("Utils/AudioUtil")
local SkillUtil = require("Utils/SkillUtil")


local UKismetInputLibrary = UE.UKismetInputLibrary
local UEMath = UE.UKismetMathLibrary

---@class CrafterAlchemistBottleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBottle UFButton
---@field ImgBottleColor UFImage
---@field ImgMask UFImage
---@field ImgNumberMask UFImage
---@field TextLevel UFTextBlock
---@field TextNumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterAlchemistBottleItemView = LuaClass(UIView, true)

local MaskType =
{
	CostNum = 1,
	NotLearned = 2,
	SkillCD = 3,
	SkillCost = 4,
}

function CrafterAlchemistBottleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBottle = nil
	--self.ImgBottleColor = nil
	--self.ImgMask = nil
	--self.ImgNumberMask = nil
	--self.TextLevel = nil
	--self.TextNumber = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterAlchemistBottleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterAlchemistBottleItemView:OnInit()
	self.BaseBtnVM = AlchemistBottleItemVM.New()
	self.MaskFlag = 0
end

function CrafterAlchemistBottleItemView:OnDestroy()

end

function CrafterAlchemistBottleItemView:OnShow()
end

function CrafterAlchemistBottleItemView:OnHide()
end

function CrafterAlchemistBottleItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBottle, self.OnClickBtnBottle)
end

function CrafterAlchemistBottleItemView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(_G.EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
    -- self:RegisterGameEvent(_G.EventID.BagUpdate, self.OnBagUpdate)
	-- self:RegisterGameEvent(_G.EventID.CrafterSkillCDUpdate, self.OnCrafterSkillCDUpdate)
end

function CrafterAlchemistBottleItemView:OnRegisterBinder()
	if self.Params and self.Params.Data then
		self.BaseBtnVM = self.Params.Data
	end

	local Binders = {
		{"SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBottleColor)},
		{"SkillIconColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgBottleColor) },
		{"bCommonMask", UIBinderSetIsVisible.New(self, self.ImgMask)},
		{"bLevelText", UIBinderSetIsVisible.New(self, self.TextLevel)},
		{"LevelText", UIBinderSetTextFormat.New(self, self.TextLevel, _G.LSTR(170061)) },  -- %d级

		{"bImgNumberMask", UIBinderSetIsVisible.New(self, self.ImgNumberMask)},
		{"bBtnBottle", UIBinderSetIsVisible.New(self, self.BtnBottle, false, true)},
		{"bItemNum", UIBinderSetIsVisible.New(self, self.TextNumber)},
		{ "SetItemNumColorType", UIBinderValueChangedCallback.New(self, nil, self.OnSetItemNumColorType) },
		{"ItemNum", UIBinderSetTextFormat.New(self, self.TextNumber, "%d") },
		
		-- {"NormalCDPercent", UIBinderSetPercent.New(self, self.Img_CD) },
		-- {"bNormalCD", UIBinderSetIsVisible.New(self, self.Img_CD)},
		{"SkillCDText", UIBinderSetText.New(self, self.Text_SkillCD)},
	}

	if type(self.BaseBtnVM) == "string" then
		self.BaseBtnVM = AlchemistBottleItemVM.New()
	end

	self:RegisterBinders(self.BaseBtnVM, Binders)
end

function CrafterAlchemistBottleItemView:OnMajorLevelUpdate(Params)
	if not self.CatalystInfo then
		return 
	end

	local Level = Params.RoleDetail.Simple.Level
	if Level >= self.LockLevel then
		self:SetLearnedInfo(true)
	else
		self:SetLearnedInfo(false)
	end

	self:RefreshMask()
end

function CrafterAlchemistBottleItemView:OnUpdateSkillCostMaskFlag(Params)
	self:UpdateSkillCostMaskFlag()
	self:RefreshMask()
end

function CrafterAlchemistBottleItemView:UpdateSkillCostMaskFlag()
	if not self.CatalystInfo then
		return
	end

	local CostOk = _G.CrafterSkillCheckMgr:CheckSkillCost(self.BtnSkillID)
	if not CostOk then
		self.MaskFlag = self.MaskFlag | (1 << MaskType.SkillCost)
	else
		self.MaskFlag = self.MaskFlag & (~(1 << MaskType.SkillCost))
	end
end

function CrafterAlchemistBottleItemView:OnSetItemNumColorType(ColorType)
	if ColorType == 1 then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextNumber, "#DC5868FF")
	else
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextNumber, "d5d5d5FF")
	end
end

function CrafterAlchemistBottleItemView:RefreshMask()
	if self.MaskFlag > 0 then
		self:SetCommonMask(true)
	else
		self:SetCommonMask(false)
	end
end

function CrafterAlchemistBottleItemView:SetCommonMask(bVisible)
	if bVisible == nil then
		self.BaseBtnVM.bBtnBottle = false
		return
	end

	self.BaseBtnVM.bCommonMask = bVisible

	--不显示遮罩，但是催化剂数量为0，
	if bVisible == false and self.BaseBtnVM.ItemNum == 0 then
		self.BaseBtnVM.bBtnBottle = true
	else
		self.BaseBtnVM.bBtnBottle = bVisible
	end
end

function CrafterAlchemistBottleItemView:SetSkillCD(BaseCD, CurrentCD)
	-- local CDPercent = CurrentCD / BaseCD
	-- -- self.BaseBtnVM.bNormalCD = true
	-- if CDPercent > 1 then
	-- 	CDPercent = 1
	-- end

	-- self.BaseBtnVM.NormalCDPercent = 1 - CDPercent
	self.BaseBtnVM.SkillCDText = string.format(_G.LSTR(150069), CurrentCD)  -- %d工次
	self.MaskFlag = self.MaskFlag | (1 << MaskType.SkillCD)
end

function CrafterAlchemistBottleItemView:ClearCD()
	-- self.BaseBtnVM.bNormalCD = false
	self.BaseBtnVM.SkillCDText = ""
	self.MaskFlag = self.MaskFlag & (~(1 << MaskType.SkillCD))
end

function CrafterAlchemistBottleItemView:UpdateCatalystInfo(ButtonIndex, CatalystInfo, LogicData)
	if not CatalystInfo or not LogicData then
		return
	end

	if type(self.BaseBtnVM) == "string" then
		self.BaseBtnVM = AlchemistBottleItemVM.New()
	end
	
	self.ButtonIndex = ButtonIndex
	self.BtnSkillID = CatalystInfo.SkillID
	self.CatalystInfo = CatalystInfo
	self.BaseBtnVM.SkillID = CatalystInfo.SkillID
	self.BaseBtnVM.ButtonIndex = ButtonIndex

	local CatalystConfig = CatalystCfg:FindCfgByKey(CatalystInfo.CatalystID)
	if not CatalystConfig then
		return 
	end
	
	self.ItemID = CatalystConfig.ItemID
	self.MaskFlag = 0

	local Cfg = ItemCfg:FindCfgByKey(CatalystConfig.ItemID)
	if Cfg then
		local IconPath = UIUtil.GetIconPath(Cfg.IconID)
		self.BaseBtnVM.SkillIcon = IconPath
	end

	local bLearnedSkill, LockLevel = LogicData:IsSkillLearned(self.BtnSkillID)
	self.LockLevel = LockLevel or 0
	self:SetLearnedInfo(bLearnedSkill == SkillUtil.SkillLearnStatus.Learned)

	self:CheckBagItemNum()
	
	self.LogicData = LogicData
	local CDInfo = _G.CrafterSkillCheckMgr:GetSkillCDInfo(self.BtnSkillID)
	if CDInfo and CDInfo.SkillCD and CDInfo.SkillCD > 0 then
		self:SetSkillCD(CDInfo.BaseCD, CDInfo.SkillCD)
	else
		self:ClearCD()
	end

	self:UpdateSkillCostMaskFlag()
	self:RefreshMask()
end

function CrafterAlchemistBottleItemView:CheckBagItemNum()
	if not self.CatalystInfo then
		return 
	end

	local ItemNum =  _G.BagMgr:GetItemNum(self.ItemID)
	self.BaseBtnVM.ItemNum = ItemNum

	if self.CatalystInfo.CostNum > ItemNum then
		-- self.MaskFlag = self.MaskFlag | (1 << MaskType.CostNum)
		self.BaseBtnVM.SetItemNumColorType = 1
	else
		-- self.MaskFlag = self.MaskFlag & (~(1 << MaskType.CostNum))
		self.BaseBtnVM.SetItemNumColorType = 0
	end
end

function CrafterAlchemistBottleItemView:GetBagItemNum()
	return self.BaseBtnVM.ItemNum
end

function CrafterAlchemistBottleItemView:GetLearned()
	return not self.BaseBtnVM.bLevelText
end

function CrafterAlchemistBottleItemView:OnBagUpdate()
	self:CheckBagItemNum()
	self:RefreshMask()
end

function CrafterAlchemistBottleItemView:SetLearnedInfo(bLearnedSkill)
	if not bLearnedSkill then
		self.MaskFlag = self.MaskFlag | (1 << MaskType.NotLearned)
		self.BaseBtnVM.LevelText = self.LockLevel
		self.BaseBtnVM.bLevelText = true
	else
		self.MaskFlag = self.MaskFlag & (~(1 << MaskType.NotLearned))
		self.BaseBtnVM.bLevelText = false
	end
end

function CrafterAlchemistBottleItemView:OnCrafterSkillCDUpdate(Params)
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

function CrafterAlchemistBottleItemView:OnMouseButtonDown(InGeo, InMouseEvent)
	UIUtil.SetInputMode_UIOnly()

    if not self.BaseBtnVM or self.MaskFlag > 0 then
        return 
    end

    print("crafter OnMouseButtonDown")
    self.IsMouseDown = true
	
	AlchemistMainVM.bDragSuccess = false
	
	self.IsCheckingDrag = true
	self.IsDragDetected = false
	self.DragStartPos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)

	return _G.UE.UWidgetBlueprintLibrary.DetectDragIfPressed(InMouseEvent, self, _G.UE.FKey("LeftMouseButton"))
end

function CrafterAlchemistBottleItemView:OnMouseButtonUp(InGeo, InMouseEvent)
	self:ClearDragState()
	
    if not self.BaseBtnVM then
        return
    end

	self:OnClickBtnBottle()

    print("crafter OnMouseButtonUp， IsDragDetected = ", self.IsDragDetected)
    self.IsMouseDown = false
	self.IsCheckingDrag = false
end

function CrafterAlchemistBottleItemView:OnClickBtnBottle()
    print("crafter OnClickBtnBottle")
	ItemTipsUtil.ShowTipsByResID(self.ItemID, self)
end

function CrafterAlchemistBottleItemView:OnMouseMove(InGeo, InMouseEvent)
    if not self.IsCheckingDrag then
        return false
    end

    if not self.BaseBtnVM  or self.MaskFlag > 0 then
        return false
    end

    --print("OnMouseMove")
    local AbsMousePos = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InMouseEvent)
    if UEMath.Distance2D(self.DragStartPos, AbsMousePos) >= 5 then
        self.IsCheckingDrag = false
        if UKismetInputLibrary.Key_IsValid(UKismetInputLibrary.PointerEvent_GetEffectingButton(InMouseEvent)) then
            self.DragOffset = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeo, AbsMousePos)
		else
            self.IsCheckingDrag = true
            self.IsDragDetected = false
        end
    end

    return false
end

function CrafterAlchemistBottleItemView:OnDragDetected(MyGeometry, PointerEvent, Operation)
    print("crafter detect drag")

    self.IsDragDetected = true
    self.IsMouseDown = false

	AudioUtil.LoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID()
		, CrafterConfig.SoundPaths.PickUpBottleSountPath)

	AlchemistMainVM.bBottleDropEnterPanel = true
	
    Operation = _G.NewObject(_G.UE.UDragDropOperation, self, nil, "Game/Crafter/Alchemist/AlchemistBottleDragDropOp")
    Operation.DragOffset = self.DragOffset
    Operation.WidgetReference = self
    Operation.Pivot = _G.UE.EDragPivot.CenterCenter

    local DragVisual = _G.UIViewMgr:CreateView(_G.UIViewID.CrafterBottleItem, self, true)
	local DraggedVM = AlchemistMainVM.BottleDragVM
	DraggedVM:OnDragVMPrepare(self.BaseBtnVM)
    DragVisual:ShowView({Data = DraggedVM})
    UIUtil.SetIsVisible(DragVisual, true)

    Operation.DefaultDragVisual = DragVisual

    self.BaseBtnVM:OnDragDetected()

    return Operation
end

function CrafterAlchemistBottleItemView:OnDragCancelled(PointerEvent, Operation)
    print("crafter drag cancelled")
	self:ClearDragState()

	if not AlchemistMainVM.bDragSuccess then
		AudioUtil.LoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID()
			, CrafterConfig.SoundPaths.ReturnBottleSountPath)
	end

    local DraggedVM = Operation.WidgetReference.BaseBtnVM
    DraggedVM:OnDragCancelled()

	if Operation.SetDragBottom then
		Operation:SetDragBottom()
	end
end

function CrafterAlchemistBottleItemView:ClearDragState()
	UIUtil.SetInputMode_GameAndUI()
	AlchemistMainVM.bBottleDropEnterPanel = false
end

return CrafterAlchemistBottleItemView