local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local SkillUtil = require("Utils/SkillUtil")
local MajorUtil = require("Utils/MajorUtil")

local SkillMainCfg = require("TableCfg/SkillMainCfg")



---@class SkillGuideMgr : MgrBase
local SkillGuideMgr = LuaClass(MgrBase)

local DefaultGuideTime = 2000

function SkillGuideMgr:OnInit()
    self.SkillID = 0
end

function SkillGuideMgr:OnBegin()
end

function SkillGuideMgr:OnEnd()
end

function SkillGuideMgr:OnShutdown()

end

function SkillGuideMgr:OnRegisterNetMsg()
	
end

function SkillGuideMgr:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.WorldPreLoad, self.OnWorldPreLoad)
    self:RegisterGameEvent(EventID.SkillReplace, self.OnSkillReplace)
    self:RegisterGameEvent(EventID.MajorDead, self.OnSkillGuideBreak)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnSkillGuideBreak)
end


function SkillGuideMgr:IsGuide()
    return self.SkillID > 0
end

function SkillGuideMgr:IsCurrentGuideSkill(SkillID)
    return self.SkillID == SkillID
end

function SkillGuideMgr:PrepareCastSkill(SkillID, SkillIndex)
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if not Cfg then
        return false
    end

    if (Cfg.IsGuide or 0) == 0 then
        return false
    end
    self.SkillID = SkillID
    self.SkillIndex = SkillIndex
    self.PostGuideResult = Cfg.PostGuideResult
    local MaxGuideTime = Cfg.MaxGuideTime or 0
    if MaxGuideTime == 0 then
        MaxGuideTime = DefaultGuideTime
    end

    if SkillUtil.CastNormalSkillDirect(SkillID, SkillIndex, true) then
        self:RegisterTimer(self.OnSkillGuideEnd, MaxGuideTime / 1000, 1, 1)
        local EntityID = MajorUtil.GetMajorEntityID()
        _G.EventMgr:SendEvent(EventID.StartSkillSing, {SkillID = SkillID, EntityID = EntityID, Time = MaxGuideTime})
        _G.EventMgr:SendEvent(EventID.SkillGuideStart, {Index = SkillIndex, EntityID = EntityID, MaxTime = MaxGuideTime})
    else
        self.SkillID = 0
        self.SkillIndex = nil
    end
    return true
end

function SkillGuideMgr:CastSkill(SkillID, SkillIndex)
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if not Cfg then
        return false
    end
    if (Cfg.IsGuide or 0) == 0 then
        return false
    end

    if self.SkillID == SkillID then
        self:UnRegisterAllTimer()
        self:OnSkillGuideEnd()
    end
    return true
end

function SkillGuideMgr:OnSkillGuideEnd()
    local EntityID = MajorUtil.GetMajorEntityID()
    _G.EventMgr:SendEvent(EventID.StopSkillSing, {EntityID = EntityID})
    _G.EventMgr:SendEvent(EventID.SkillGuideEnd, {Index = self.SkillIndex, EntityID = EntityID, EndResult = true})
    self.SkillID = 0
    self.SkillIndex = nil
    local PostGuideResult = self.PostGuideResult
    if PostGuideResult == -1 then
        return
    elseif PostGuideResult == 0 then
        _G.SkillObjectMgr:BreakSkill(EntityID)
    else
        local SkillID = PostGuideResult
        local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
        if LogicData then
            local CanCastSkill = LogicData:CanCastSkillbyID(SkillID)
            if CanCastSkill then
                SkillUtil.CastNormalSkillDirect(SkillID, -1)
            end
        end
    end
end

function SkillGuideMgr:OnSkillGuideBreak()
    if self.SkillID > 0 or self.SkillIndex then
        local EntityID = MajorUtil.GetMajorEntityID()
        _G.EventMgr:SendEvent(EventID.StopSkillSing, {EntityID = EntityID})
        _G.EventMgr:SendEvent(EventID.SkillGuideEnd, {Index = self.SkillIndex, EntityID = EntityID, EndResult = false})
        self.SkillIndex = nil
        self.SkillID = 0
        self:UnRegisterAllTimer()
    end
end


function SkillGuideMgr:OnSkillReplace(Params)
    if Params.SkillIndex == self.SkillIndex then
        self:OnSkillGuideBreak()
    end
end



return SkillGuideMgr