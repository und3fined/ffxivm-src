--
-- Author: henghaoli
-- Date: 2025-02-18 15:01:00
-- Description: 管理技能Tips
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local CommonUtil = require("Utils/CommonUtil")
local SkillTipsUtil = require("Utils/SkillTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local PworldCfg = require("TableCfg/PworldCfg")

local UIViewID_CommSkillTips <const> = UIViewID.CommSkillTipsView
local SkillTipsType          <const> = SkillCommonDefine.SkillTipsType
local EAnchorType_BottomLeft <const> = SkillTipsUtil.EAnchorType.BottomLeft
local InvalidHandleID        <const> = -1

local ViewParams = {
    Type = SkillTipsType.None,
    SkillID = 0,
    Pos = UE.FVector2D(),
    ProfID = 0,
    bIsPassiveSkill = false,
    bIsPvpSkill = false,
    bSync = false,
    bHideAfterClick = false,
}



---@class SkillTipsMgr : MgrBase
local SkillTipsMgr = LuaClass(MgrBase)

function SkillTipsMgr:OnInit()
    self.HandleCnt = 0
    self.CurrentTipsType = SkillTipsType.None
end

function SkillTipsMgr:OnBegin()
end

function SkillTipsMgr:OnEnd()
end

function SkillTipsMgr:OnShutdown()
end

function SkillTipsMgr:OnRegisterNetMsg()
end

function SkillTipsMgr:OnRegisterGameEvent()
end


--region 对外接口
-- 因为显示Tips的发起者不一定是Major, 需要传入ProfID和Level

--- 显示战斗技能的Tips
---@param SkillID number
---@param Pos FVector2D - Tips显示位置
---@param ProfID number - 职业ID
---@param Level number - 等级
---@param bIsPassiveSkill boolean - 是否是被动技能, 默认false
---@param bIsPvpSkill boolean - 是否是PVP技能, 默认false
---@param bIsLimitSkill boolean - 是否极限技, 默认false
---@return number - 返回一个HandleID, 隐藏Tips时需要这个HandleID
function SkillTipsMgr:ShowCombatSkillTips(SkillID, Pos, ProfID, Level, bIsPassiveSkill, bIsPvpSkill, bIsLimitSkill)
    return self:ShowTipsInternal(
        SkillTipsType.Combat, SkillID, Pos, ProfID, Level, bIsPassiveSkill, bIsPvpSkill, bIsLimitSkill)
end

--- 显示生产技能的Tips
---@param SkillID number
---@param Pos FVector2D - Tips显示位置
---@param ProfID number - 职业ID
---@param Level number - 等级
---@return number - 返回一个HandleID, 隐藏Tips时需要这个HandleID
function SkillTipsMgr:ShowCrafterSkillTips(SkillID, Pos, ProfID, Level)
    return self:ShowTipsInternal(SkillTipsType.Crafter, SkillID, Pos, ProfID, Level, false, false, false)
end

--- 显示采集技能的Tips
---@param SkillID number
---@param Pos FVector2D - Tips显示位置
---@param ProfID number - 职业ID
---@param Level number - 等级
---@return number - 返回一个HandleID, 隐藏Tips时需要这个HandleID
function SkillTipsMgr:ShowGatherSkillTips(SkillID, Pos, ProfID, Level)
    return self:ShowTipsInternal(SkillTipsType.Gather, SkillID, Pos, ProfID, Level, false, false, false)
end

--- 显示坐骑技能的Tips
---@param Params table - 坐骑技能相关的参数
---@param boolean bHideAfterClick - 是否点击屏幕后隐藏
---@return number - 返回一个HandleID, 隐藏Tips时需要这个HandleID
function SkillTipsMgr:ShowMountSkillTips(Params, bHideAfterClick)
    ViewParams.MountParams = Params
    -- 坐骑技能同步更新
    return self:ShowTipsInternal(SkillTipsType.Mount, nil, nil, nil, nil, nil, nil, nil, true, bHideAfterClick)
end

--- 显示主角的战斗技能的Tips, 简化调用
---@param SkillID number
---@param Widget UWidget - 挂靠的控件
---@return number - 返回一个HandleID, 隐藏Tips时需要这个HandleID
function SkillTipsMgr:ShowMajorCombatSkillTips(SkillID, Widget)
    if self.bDisableMajorTips then
        return InvalidHandleID
    end
    local Pos = SkillTipsUtil.GetWidgetAnchorPos(Widget, EAnchorType_BottomLeft)
	local ProfID = MajorUtil.GetMajorProfID()
	local Level = MajorUtil.GetMajorLevel()
    local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local CanPK = PworldCfg:FindValue(CurrPWorldResID, "CanPK")
    local bPVP = not (CanPK == 0)
	return self:ShowCombatSkillTips(SkillID, Pos, ProfID, Level, false, bPVP, false)
end

--- 显示主角极限技Tips
function SkillTipsMgr:ShowMajorLimitSkillTips(SkillID, Widget)
    local Pos = SkillTipsUtil.GetWidgetAnchorPos(Widget, EAnchorType_BottomLeft)
    local ProfID = MajorUtil.GetMajorProfID()
	local Level = MajorUtil.GetMajorLevel()
    return self:ShowCombatSkillTips(SkillID, Pos, ProfID, Level, false, false, true)
end

--- 显示主角的生产技能的Tips, 简化调用
---@param SkillID number
---@param Widget UWidget - 挂靠的控件
---@return number - 返回一个HandleID, 隐藏Tips时需要这个HandleID
function SkillTipsMgr:ShowMajorCrafterSkillTips(SkillID, Widget)
    if self.bDisableMajorTips then
        return InvalidHandleID
    end
    local Pos = SkillTipsUtil.GetWidgetAnchorPos(Widget, EAnchorType_BottomLeft)
	local ProfID = MajorUtil.GetMajorProfID()
	local Level = MajorUtil.GetMajorLevel()
	return self:ShowCrafterSkillTips(SkillID, Pos, ProfID, Level)
end

--- 显示主角的采集技能的Tips, 简化调用
---@param SkillID number
---@param Widget UWidget - 挂靠的控件
---@return number - 返回一个HandleID, 隐藏Tips时需要这个HandleID
function SkillTipsMgr:ShowMajorGatherSkillTips(SkillID, Widget)
    if self.bDisableMajorTips then
        return InvalidHandleID
    end
    local Pos = SkillTipsUtil.GetWidgetAnchorPos(Widget, EAnchorType_BottomLeft)
	local ProfID = MajorUtil.GetMajorProfID()
	local Level = MajorUtil.GetMajorLevel()
	return self:ShowGatherSkillTips(SkillID, Pos, ProfID, Level)
end

--- 自动根据主角职业选择合适的Tips类型
---@param SkillID number
---@param Widget UWidget - 挂靠的控件
---@return number - 返回一个HandleID, 隐藏Tips时需要这个HandleID
function SkillTipsMgr:ShowMajorSkillTips(SkillID, Widget)
    if self.bDisableMajorTips then
        return InvalidHandleID
    end

    local ProfID = MajorUtil.GetMajorProfID()
    if ProfUtil.IsCombatProf(ProfID) then
        -- 这里后面看需要是不是判断下极限技
        return self:ShowMajorCombatSkillTips(SkillID, Widget)
    elseif ProfUtil.IsCrafterProf(ProfID) then
        return self:ShowMajorCrafterSkillTips(SkillID, Widget)
    else
        -- 采集和捕鱼人共用一套
        return self:ShowMajorGatherSkillTips(SkillID, Widget)
    end
end

--- 显示陆行鸟竞赛技能的Tips
---@param Params table - 陆行鸟竞赛技能的参数
---@param Widget UWidget - 挂靠的控件
---@return number - 返回一个HandleID, 隐藏Tips时需要这个HandleID
function SkillTipsMgr:ShowChocoboRaceSkillTips(Params, Widget)
    ViewParams.ChocoboRaceParams = Params
    local Pos = SkillTipsUtil.GetWidgetAnchorPos(Widget, EAnchorType_BottomLeft)
    return self:ShowTipsInternal(SkillTipsType.ChocoboRace, nil, Pos, nil, nil, nil, nil, nil, true)
end

--- 隐藏战斗技能Tips
---@return boolean - 是否成功
function SkillTipsMgr:HideCombatSkillTips()
    return self:HideTipsByType(SkillTipsType.Combat)
end

--- 隐藏生产技能Tips
---@return boolean - 是否成功
function SkillTipsMgr:HideCrafterSkillTips()
    return self:HideTipsByType(SkillTipsType.Crafter)
end

--- 隐藏采集技能Tips
---@return boolean - 是否成功
function SkillTipsMgr:HideGatherSkillTips()
    return self:HideTipsByType(SkillTipsType.Gather)
end

--- 隐藏坐骑技能Tips
---@return boolean - 是否成功
function SkillTipsMgr:HideMountSkillTips()
    return self:HideTipsByType(SkillTipsType.Mount)
end

--- 隐藏陆行鸟竞赛技能Tips
---@return boolean - 是否成功
function SkillTipsMgr:HideChocoboRaceSkillTips()
    return self:HideTipsByType(SkillTipsType.ChocoboRace)
end

--- 隐藏指定类型Tips
---@param Type number - 显示类型
---@return boolean - 是否成功
function SkillTipsMgr:HideTipsByType(Type)
    if self.CurrentTipsType ~= Type then
        return false
    end
    return self:HideTipsByHandleID(self.HandleCnt)
end

--- 隐藏Tips
---@param HandleID number
---@return boolean 是否成功
function SkillTipsMgr:HideTipsByHandleID(HandleID)
    if HandleID ~= self.HandleCnt then
        return false
    end

    self.CurrentTipsType = SkillTipsType.None
    UIViewMgr:HideView(UIViewID_CommSkillTips)
    return true
end

--endregion


function SkillTipsMgr:ShowTipsInternal(Type, SkillID, Pos, ProfID, Level, bIsPassiveSkill, bIsPvpSkill, bIsLimitSkill, bSync, bHideAfterClick)
    local _ <close> = CommonUtil.MakeProfileTag("SkillTipsMgr:ShowTipsBySkillID")
    ViewParams.Type = Type
    ViewParams.SkillID = SkillID or 0
    if Pos then
        -- 使用Pos的副本, 防止因异步出现问题
        local ViewParamsPos =  ViewParams.Pos
        ViewParamsPos.X = Pos.X
        ViewParamsPos.Y = Pos.Y
    end

    local HandleID = self.HandleCnt + 1
    self.HandleCnt = HandleID
    self.CurrentTipsType = Type

    ViewParams.ProfID = ProfID or 0
    ViewParams.Level = Level or 0
    ViewParams.bIsPassiveSkill = bIsPassiveSkill or false
    ViewParams.bIsPvpSkill = bIsPvpSkill or false
    ViewParams.bIsLimitSkill = bIsLimitSkill or false
    ViewParams.bSync = bSync or false
    ViewParams.bHideAfterClick = bHideAfterClick or false
    ViewParams.HandleID = HandleID

    -- 先Hide再Show, 即后显示的Tips会覆盖原来的
    UIViewMgr:HideView(UIViewID_CommSkillTips)
    UIViewMgr:ShowView(UIViewID_CommSkillTips, ViewParams)

    return HandleID
end

return SkillTipsMgr
