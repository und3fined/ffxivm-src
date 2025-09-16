---
--- Author: v_zanchang
--- DateTime: 2022-10-19 14:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local BagMgr = require("Game/Bag/BagMgr")
-- local ActorMgr = require("Game/Actor/ActorMgr")
local ItemUtil = require("Utils/ItemUtil")
local TimeUtil = require("Utils/TimeUtil")
local SkillDrugVM = require("Game/MainSkillBtn/SkillDrugVM")
local ItemCfg = require("TableCfg/ItemCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsID = require("Define/MsgTipsID")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

local OneVector2D = _G.UE.FVector2D(1, 1)
local WBL         = _G.UE.UWidgetBlueprintLibrary

---@class SkillDrugBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_Goup UCanvasPanel
---@field IconMedicineNormel UFImage
---@field ImgCD URadialImage
---@field ImgDrug UFImage
---@field ImgSlot UFImage
---@field ImgSlotFrame UFImage
---@field Panel UFCanvasPanel
---@field TextDrugCD UFTextBlock
---@field TextDrugNumber UFTextBlock
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillDrugBtnView = LuaClass(UIView, true)

function SkillDrugBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_Goup = nil
	--self.IconMedicineNormel = nil
	--self.ImgCD = nil
	--self.ImgDrug = nil
	--self.ImgSlot = nil
	--self.ImgSlotFrame = nil
	--self.Panel = nil
	--self.TextDrugCD = nil
	--self.TextDrugNumber = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillDrugBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillDrugBtnView:OnInit()
end

function SkillDrugBtnView:OnDestroy()
end

function SkillDrugBtnView:OnShow()
	if self.EntityID == 0 then
		return
	end
	-- 初始化CD
	SkillDrugVM.IsHaveCD = false
	self.ImgCD:SetPercent(0)
	UIUtil.SetIsVisible(self.TextDrugCD, false)
	UIUtil.SetIsVisible(self.ImgCD, false)
	local MajorProfID = MajorUtil:GetMajorProfID()-- 玩家当前职业Prof.ProfList[10].ProfID
	if not self.bMajor then
		MajorProfID = _G.SkillSystemMgr.ProfID or MajorProfID
	end
	if  BagMgr.ProfMedicineTable == nil or BagMgr:IsMedicineItem(BagMgr.ProfMedicineTable[MajorProfID]) == false then --未进行药品设置
		UIUtil.ImageSetBrushFromAssetPath(self.ImgDrug, "PaperSprite'/Game/UI/Atlas/MainSkill/Frames/UI_Skill_Fish_Btn_Medicine_png.UI_Skill_Fish_Btn_Medicine_png'")
		UIUtil.SetIsVisible(self.TextDrugNumber, false)
		SkillDrugVM.DrugGID = nil
		SkillDrugVM.ResID = nil
		return
	end

	SkillDrugVM.ResID = BagMgr.ProfMedicineTable[MajorProfID]
	SkillDrugVM.Num = BagMgr:GetItemNum(SkillDrugVM.ResID)

	local Item = BagMgr:GetItemByResID(SkillDrugVM.ResID)
	if Item then
		SkillDrugVM.DrugGID = Item.GID
	end

	local Cfg = ItemCfg:FindCfgByKey(SkillDrugVM.ResID)
	if nil == Cfg then
		_G.FLOG_WARNING("ItemCfg:FindCfgByKey can't find item cfg, ResID =%d", SkillDrugVM.ResID)
		return
	end

	local FreezeGroup = Cfg.FreezeGroup
	SkillDrugVM.GroupID = FreezeGroup
	UIUtil.SetIsVisible(self.TextDrugNumber, true)
	self.TextDrugNumber:SetText(tostring(SkillDrugVM.Num)) -- 药品数量
	UIUtil.ImageSetBrushFromAssetPath(self.ImgDrug, UIUtil.GetIconPath(Cfg.IconID)) -- 药品图标

	local FreezeCDData = BagMgr.FreezeCDTable[FreezeGroup]
	if FreezeCDData ~= nil then
		self:OnFreezeCD(FreezeGroup, FreezeCDData.EndTime, FreezeCDData.FreezeCD)
	end
end

function SkillDrugBtnView:OnEntityIDUpdate(EntityID, bMajor)
	self.bMajor = bMajor
	self.EntityID = EntityID
end

function SkillDrugBtnView:OnHide()
end

function SkillDrugBtnView:OnRegisterUIEvent()
end

function SkillDrugBtnView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BagFreezeCD, self.OnFreezeCD)
	self:RegisterGameEvent(EventID.BagManualSetMedicine, self.OnShow)
    self:RegisterGameEvent(_G.EventID.BagUpdate, self.OnBagUpdate)
end

function SkillDrugBtnView:OnRegisterBinder()
end

function SkillDrugBtnView:OnMainSkillButtonUp(IsSkillDrugBtn)
	if IsSkillDrugBtn == nil then
		return
	end
	if IsSkillDrugBtn then
		self:UseSkillDrug()

	end
end

function SkillDrugBtnView:OnBagUpdate()
	SkillDrugVM.Num = BagMgr:GetItemNum(SkillDrugVM.ResID)
	self.TextDrugNumber:SetText(tostring(SkillDrugVM.Num)) -- 药品数量
	local Item = BagMgr:GetItemByResID(SkillDrugVM.ResID)
	if Item then
		SkillDrugVM.DrugGID = Item.GID
	end

end

local LSTR = _G.LSTR
local CrafterMgr = _G.CrafterMgr

function SkillDrugBtnView:UseSkillDrug()
	local bMajor = self.bMajor
	if CrafterMgr:IsInTrain() then
		MsgTipsUtil.ShowTips(LSTR(140062), nil)  -- 训练制作中不能使用药品
		return false
	end
	if SkillDrugVM.IsHaveCD and bMajor then
		MsgTipsUtil.ShowTips(LSTR(140063), nil)  -- 药品冷却
		return false
	end
	if SkillDrugVM.ResID == nil then
		self.DrugGID = nil
		if bMajor or _G.SkillSystemMgr:ShouldOpenBagDrugSetPanel() then
			_G.UIViewMgr:ShowView(_G.UIViewID.BagDrugsSetPanel)
			return true
		else
			MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillSystemUseDrugProfUnlock)
		end
		return false
	end
	SkillDrugVM.Num = BagMgr:GetItemNum(SkillDrugVM.ResID)
	if SkillDrugVM.Num <= 0 and bMajor then
		MsgTipsUtil.ShowTips(LSTR(140065), nil)  -- 药品不足
		return false
	end

	--debug用的tips不要忘记屏蔽
	--MsgTipsUtil.ShowTips(LSTR("使用药品" .. ItemUtil.GetItemName(SkillDrugVM.ResID)), nil) --debug

	-- 技能系统仅弹提示, 主角才会走使用的逻辑
	if bMajor then
		SkillDrugVM.Num = SkillDrugVM.Num - 1
		self.TextDrugNumber:SetText(tostring(SkillDrugVM.Num)) -- 药品数量
		BagMgr:UseItem(SkillDrugVM.DrugGID, nil)
	else
		MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillSystemUseDrug)
	end
	return true
end


function SkillDrugBtnView:OnFreezeCD(GroupID, EndFreezeTime, FreezeCD)
	if SkillDrugVM.DrugGID == nil or not self.bMajor then -- 未进行战斗药品设置
		return
	end

	if GroupID == SkillDrugVM.GroupID then
		-- body
		local Percent = 0.0
		local CurTime = TimeUtil.GetServerTime()
		local CD = math.floor(EndFreezeTime - CurTime)
		if CD > 0 and FreezeCD > 0 then
			Percent = 1 - CD / FreezeCD
		end

		if CD < 1 or SkillDrugVM.Num == 0 or SkillDrugVM.Num == nil then
			self.ImgCD:SetPercent(1)
			UIUtil.SetIsVisible(self.TextDrugCD, false)
			UIUtil.SetIsVisible(self.ImgCD, false)
			SkillDrugVM.IsHaveCD = false
		else
			self.ImgCD:SetPercent(Percent)
			UIUtil.SetIsVisible(self.TextDrugCD, true)
			UIUtil.SetIsVisible(self.ImgCD, true)
			self.TextDrugCD:SetText(tostring(CD))
			SkillDrugVM.IsHaveCD = true
		end

	end
end

function SkillDrugBtnView:OnMouseButtonDown()
	self:SetRenderScale(OneVector2D * SkillCommonDefine.SkillBtnClickFeedback)
	local Handled = WBL.Handled()
	return WBL.CaptureMouse(Handled, self)
end

function SkillDrugBtnView:OnMouseCaptureLost()
    self:SetRenderScale(OneVector2D)
end

function SkillDrugBtnView:OnMouseButtonUp()
	self:SetRenderScale(OneVector2D)
	local bSuccess = false
	if self.bEnablePress then
		bSuccess = self:UseSkillDrug()
	end

	if not bSuccess then
		local Anim = self.AnimDisable
		if Anim then
			self:PlayAnimation(Anim)
		end
	end

	local Handled = WBL.Handled()
	return WBL.ReleaseMouseCapture(Handled)
end

return SkillDrugBtnView