--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2023-12-20 08:34:36
FilePath: \Client\Source\Script\Game\GatheringJob\View\GatheringJobSkillPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2023-12-08 17:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local SkillUtil = require("Utils/SkillUtil")
local TipsUtil = require("Utils/TipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local LifeskillCollectionDescriptionCfg = require("TableCfg/LifeskillCollectionDescriptionCfg")
local EventID = require("Define/EventID")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local OneVector2D          <const> = _G.UE.FVector2D(1, 1)

---@class GatheringJobSkillPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAttack UFButton
---@field BtnPenetrate UFButton
---@field BtnPriceUp UFButton
---@field BtnSteady UFButton
---@field CollectionPopup GatheringCollectionPanelNewView
---@field GatheringJobBar GatheringJobBarItemView
---@field GatheringSkill1 GatheringSkillItemView
---@field GatheringSkill2 GatheringSkillItemView
---@field GatheringSkill3 GatheringSkillItemView
---@field GatheringSkill4 GatheringSkillItemView
---@field GatheringSkill5 GatheringSkillItemView
---@field ImgGray UFImage
---@field ImgIcon UFImage
---@field ImgPenetrateIcon UFImage
---@field ImgPenetrateIcon_1 UFImage
---@field JobSkillTips GatheringJobSkillTipsView
---@field MainMajorInfoPanel MainMajorInfoPanelView
---@field PanelAttackBtn UFCanvasPanel
---@field PanelSkill UFCanvasPanel
---@field PanelSkillNew UFCanvasPanel
---@field PanelSkillTips UFCanvasPanel
---@field PanelUnfold UFCanvasPanel
---@field TextPriceUpNumber UFTextBlock
---@field TextSteadyNumber UFTextBlock
---@field AnimAttackClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimProBarSubtract UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringJobSkillPanelView = LuaClass(UIView, true)

function GatheringJobSkillPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAttack = nil
	--self.BtnPenetrate = nil
	--self.BtnPriceUp = nil
	--self.BtnSteady = nil
	--self.CollectionPopup = nil
	--self.GatheringJobBar = nil
	--self.GatheringSkill1 = nil
	--self.GatheringSkill2 = nil
	--self.GatheringSkill3 = nil
	--self.GatheringSkill4 = nil
	--self.GatheringSkill5 = nil
	--self.ImgGray = nil
	--self.ImgIcon = nil
	--self.ImgPenetrateIcon = nil
	--self.ImgPenetrateIcon_1 = nil
	--self.JobSkillTips = nil
	--self.MainMajorInfoPanel = nil
	--self.PanelAttackBtn = nil
	--self.PanelSkill = nil
	--self.PanelSkillNew = nil
	--self.PanelSkillTips = nil
	--self.PanelUnfold = nil
	--self.TextPriceUpNumber = nil
	--self.TextSteadyNumber = nil
	--self.AnimAttackClick = nil
	--self.AnimIn = nil
	--self.AnimProBarSubtract = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringJobSkillPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CollectionPopup)
	self:AddSubView(self.GatheringJobBar)
	self:AddSubView(self.GatheringSkill1)
	self:AddSubView(self.GatheringSkill2)
	self:AddSubView(self.GatheringSkill3)
	self:AddSubView(self.GatheringSkill4)
	self:AddSubView(self.GatheringSkill5)
	self:AddSubView(self.JobSkillTips)
	self:AddSubView(self.MainMajorInfoPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringJobSkillPanelView:OnInit()
    self.WidgetLocPos = UIUtil.CanvasSlotGetPosition(self.probarlight)
    self.WidgetSize = UIUtil.CanvasSlotGetSize(self.probarlight)

    self.PassiveSkillGroupView = {
        [1] = self.BtnPriceUp,
        [2] = self.BtnPenetrate,
        [3] = self.BtnSteady
    }
    self.Binders = {
        --head相关
        {"GatherPointName", UIBinderSetText.New(self, self.TextPlace)},
        {"GatherLevel", UIBinderSetText.New(self, self.TextLevel)},
        {"LeftTimesInfo", UIBinderSetText.New(self, self.TextNumber)},
        -- left/4
        {"GatherHPBarPercent", UIBinderSetPercent.New(self, self.ProBar)},
        {"GatherHPBarPercent", UIBinderValueChangedCallback.New(self, nil, self.OnGatherHPBarPercent)},
        --3个提纯技能按钮上显示的数值
        --提纯
        {"ScourSkill", UIBinderSetText.New(self, self.GatheringSkill5.MiddleNumber)},
        --大胆提纯
        {"BrazenSkill", UIBinderSetText.New(self, self.GatheringSkill4.MiddleNumber)},
        --慎重提纯
        {"MetiSkill", UIBinderSetText.New(self, self.GatheringSkill3.MiddleNumber)},
        --2个被动技能按钮上显示的概率
        {"ValueUpRate", UIBinderSetText.New(self, self.TextPriceUpNumber)}, --价值提升
        {"FreeMetiProb", UIBinderSetText.New(self, self.TextSteadyNumber)}, --沉稳
        --洞察生效
        {"bCollectorStandard", UIBinderSetIsVisible.New(self, self.ImgPenetrateIcon_1, false)},
        {"bCollectorStandard", UIBinderSetIsVisible.New(self, self.GatheringSkill4.ImgLight, false)},
        {"bCollectorStandard", UIBinderSetIsVisible.New(self, self.GatheringSkill3.ImgLight, false)},
        --洞察/集中检查增益
        {"bArrow1", UIBinderSetIsVisible.New(self, self.GatheringSkill3.ImgMiddleUp, false)},
        {"bArrow1", UIBinderSetIsVisible.New(self, self.GatheringSkill4.ImgMiddleUp, false)},
        {"bArrow2", UIBinderSetIsVisible.New(self, self.GatheringSkill5.ImgMiddleUp, false)},
        --采集按钮
        {"bCanCollect", UIBinderSetIsVisible.New(self, self.ImgGray, true)},
    }
end

function GatheringJobSkillPanelView:OnDestroy()
end

function GatheringJobSkillPanelView:OnShow()
    --CollectionMgr在ShowView之前先执行了EnterCollection()，初始化网络数据和panel数据
    UIUtil.SetIsVisible(self.PanelSkillTips, false)
    UIUtil.SetIsVisible(self.MainMajorInfoPanel.ImgSwitch, false)

    self:InitSkillGroup()
    UIUtil.SetIsVisible(self.GatheringJobBar, false)
    self.GatheringJobBar:RefreshBarViewByEntityID(_G.InteractiveMgr.CurInteractEntityID or 0)
end

function GatheringJobSkillPanelView:InitSkillGroup()
    local ProfID = MajorUtil.GetMajorProfID()
    local SkillGroup = _G.GatheringJobSkillPanelVM.SkillGroup[ProfID]
    SkillUtil.ChangeSkillIcon(SkillGroup[0], self.ImgIcon)
end

function GatheringJobSkillPanelView:OnHide()
end

function GatheringJobSkillPanelView:OnGatherHPBarPercent()
    local WidgetLocPos = self.WidgetLocPos
    local WidgetSize = self.WidgetSize
    local VM = _G.GatheringJobSkillPanelVM
    local CurPercent = VM.GatherHPBarPercent
    UIUtil.CanvasSlotSetPosition(self.probarlight, _G.UE.FVector2D(WidgetSize.X * CurPercent, WidgetLocPos.Y))
    if VM.LastLeftTimes and VM.TotalCount then
        local LastPercent = VM.LastLeftTimes / VM.TotalCount
        UIUtil.CanvasSlotSetSize(self.probarlight, _G.UE.FVector2D(WidgetSize.X * (LastPercent - CurPercent), WidgetSize.Y))
    else
        _G.FLOG_ERROR("GatheringJobSkillPanelView: VM.LastLeftTimes or VM.TotalCount is nil")
    end
    self:PlayAnimation(self.AnimProBarSubtract)
end

function GatheringJobSkillPanelView:OnRegisterBinder()
    self:RegisterBinders(_G.GatheringJobSkillPanelVM, self.Binders)
end

--region-----------------------------UIEvent---------------------------------
---@type 提纯5_大胆提纯4_慎重提纯3_集中检查2_采集收藏0
function GatheringJobSkillPanelView:OnRegisterUIEvent()
    --采集
    UIUtil.AddOnPressedEvent(self, self.BtnAttack, self.OnPressed)
	UIUtil.AddOnReleasedEvent(self, self.BtnAttack, self.OnReleased)
    UIUtil.AddOnClickedEvent(self, self.BtnAttack, self.OnClickCollectSkill)
    UIUtil.AddOnLongClickedEvent(self, self.BtnAttack, self.OnLongClickedScour, 0)
    UIUtil.AddOnLongClickReleasedEvent(self, self.BtnAttack, self.OnLongClickReleasedScour)

    --价值提升
    UIUtil.AddOnLongClickedEvent(self, self.BtnPriceUp, self.OnLongClickedpassive, 1)
    UIUtil.AddOnLongClickReleasedEvent(self, self.BtnPriceUp, self.OnLongClickReleasedpassive, 1)
    --洞察
    UIUtil.AddOnLongClickedEvent(self, self.BtnPenetrate, self.OnLongClickedpassive, 2)
    UIUtil.AddOnLongClickReleasedEvent(self, self.BtnPenetrate, self.OnLongClickReleasedpassive, 2)
    --沉稳
    UIUtil.AddOnLongClickedEvent(self, self.BtnSteady, self.OnLongClickedpassive, 3)
    UIUtil.AddOnLongClickReleasedEvent(self, self.BtnSteady, self.OnLongClickReleasedpassive, 3)

    self.CollectionPopup.CloseBtn:SetCallback(self, self.OnClickExitBtn)
end

-------------------------------采集技能--------------------------------------
---@type cast采集收藏品技能
function GatheringJobSkillPanelView:OnClickCollectSkill()
    _G.CollectionMgr.OnClickCollectSkill = true
    if _G.GatheringJobSkillPanelVM.bCanCollect then
        FLOG_INFO("Gather Collection Click Collect Skill")
        local ProfID = MajorUtil.GetMajorProfID()
        local SkillID = _G.GatheringJobSkillPanelVM.SkillGroup[ProfID][0]
        _G.CollectionMgr:CastSkill(0, SkillID, true)
        self:PlayAnimation(self.AnimAttackClick)
    else
        MsgTipsUtil.ShowTipsByID(MsgTipsID.CollectionSKillLock)
    end
end

---@type 长按采集技能
function GatheringJobSkillPanelView:OnLongClickedScour(index)
    --tip
    local ProfID = MajorUtil.GetMajorProfID()
    self.JobSkillTips:UPdateSkillInfo(_G.GatheringJobSkillPanelVM.SkillGroup[ProfID][index], ProfID)
    UIUtil.SetIsVisible(self.PanelSkillTips, true)

    local btnsize = UIUtil.CanvasSlotGetSize(self.PanelAttackBtn)
    local InPosition = UIUtil.CanvasSlotGetPosition(self.PanelAttackBtn) - _G.UE.FVector2D(btnsize.X * 0.7 , 0)
    UIUtil.CanvasSlotSetPosition(self.PanelSkillTips, InPosition)
end

---@type 松开采集技能
function GatheringJobSkillPanelView:OnLongClickReleasedScour()
    --当松开的时候，隐藏tip
    UIUtil.SetIsVisible(self.PanelSkillTips, false)
end

function GatheringJobSkillPanelView:OnPressed()
	self.PanelAttackBtn:SetRenderScale(OneVector2D * SkillCommonDefine.SkillBtnClickFeedback)
end

function GatheringJobSkillPanelView:OnReleased()
	self.PanelAttackBtn:SetRenderScale(OneVector2D)
end

-------------------------------被动技能---------------------------------
---@type 长按被动技能
function GatheringJobSkillPanelView:OnLongClickedpassive(index)
    local rsp = _G.GatheringJobSkillPanelVM.CollectionRsp
    local tips = LifeskillCollectionDescriptionCfg:FindAllCfg()

    local Desc = ""
    if index == 1 or index == 2 then
        Desc = tips[index].Desc
    else
        Desc = string.format(tips[index].Desc, math.floor(rsp.FreeMetiProb / 100))
    end

    local Params = {}
    Params.Title = tips[index].Name
    Params.Content = Desc
    local BtnSize = UIUtil.CanvasSlotGetSize(self.PassiveSkillGroupView[index])
    TipsUtil.ShowSimpleTipsView(
        Params,
        self.PassiveSkillGroupView[index],
        _G.UE.FVector2D(-(BtnSize.X) - 15, 100),
        _G.UE.FVector2D(1, 1),
        true
    )
end

---@type 松开被动技能
function GatheringJobSkillPanelView:OnLongClickReleasedpassive()
    --当松开的时候，隐藏tip
    _G.UIViewMgr:HideView(_G.UIViewID.CommHelpInfoSimpleTipsView)
end


---@type 离开收藏品界面
function GatheringJobSkillPanelView:OnClickExitBtn()
    _G.CollectionMgr:ExitCollectionStateReq()
end
--endregion

--region-----------------------------GameEvent---------------------------------
function GatheringJobSkillPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.OnCastSkillUpdateMask, self.OnCastSkillUpdateMask)
    --self:RegisterGameEvent(EventID.TargetChangeMajor, self.OnGameEventTargetChangeMajor)
    self:RegisterGameEvent(EventID.Attr_Change_GP, self.OnGameEventActorGPChange)
end

-- function GatheringJobSkillPanelView:OnGameEventTargetChangeMajor(TargetID)
--     self.GatheringJobBar:RefreshBarViewByEntityID(TargetID)
-- end

---OnGameEventActorGPChange
---@param Params FEventParams
function GatheringJobSkillPanelView:OnGameEventActorGPChange(Params)
	if Params ~= nil then
		local EntityID = Params.ULongParam1
        if MajorUtil.IsMajor(EntityID) and MajorUtil.IsGatherProf() then
            local CurGP = Params.ULongParam3
            local MaxGP = Params.ULongParam4
            self:OnCastSkillUpdateMask()
        end
	end
end

-----@type 当技能释放时所有技能都置灰
function GatheringJobSkillPanelView:OnCastSkillUpdateMask(OnCast)
    if OnCast == nil then
        OnCast = self.OnCast --药品使用后更新
    else
        self.OnCast = OnCast --技能使用后更新
    end
    _G.GatheringJobSkillPanelVM:SetAttackBtnMask(OnCast)
end
--endregion

return GatheringJobSkillPanelView
