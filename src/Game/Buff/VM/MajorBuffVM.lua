local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableBuffList = require("Game/Buff/VM/UIBindableBuffList")
local BuffDefine = require("Game/Buff/BuffDefine")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require("Protocol/ProtoCS")

local MajorBuffVM = LuaClass(UIViewModel)

function MajorBuffVM:Ctor()
    self.BuffList = UIBindableBuffList.New()
    self.UnShowBuffTable = {} -- 不显示的BUFF
    self.IsMajorBuffDetailVisiable = false
    self.MainSelectedIdx = nil
    self.MainSelectedItem = nil
end

---AddOrUpdateBuff 新增或者刷新Buff
---@param BuffID number
---@param BuffType BuffDefine.BuffSkillType
---@param Params FCombatBuff|LifeSkillBuffInfo|BonusState
function MajorBuffVM:AddOrUpdateBuff(BuffID, BuffType, Params)
    local Value = nil

    local EntityID = MajorUtil.GetMajorEntityID()
    if BuffType ==  BuffDefine.BuffSkillType.Combat then
        Value = BuffUIUtil.CombatBuff2BuffVMParams(EntityID, BuffID, Params)
    elseif BuffType == BuffDefine.BuffSkillType.Life then
        Value = BuffUIUtil.LifeSkillBuff2BuffVMParams(EntityID, BuffID, Params)
    elseif BuffType == BuffDefine.BuffSkillType.BonusState then
        Value = BuffUIUtil.BonusState2BuffVMParams(EntityID, BuffID, Params)
    end

    if nil ~= Value then
        if (BuffUIUtil.CheckBuffDisplay(Value)) then
            self.BuffList:AddOrUpdateBuff(Value)
            self:CheckMainSelected()
        else
            -- 这里检测一下，看是不是已经存在的BUFF
            local Exist = false
            for Key, Value in pairs(self.UnShowBuffTable) do
                if (Value == BuffID) then
                    Exist = true
                    break
                end
            end
            
            if (not Exist) then
                table.insert(self.UnShowBuffTable, BuffID)
            end
        end
    end
end

---RemoveBuff
---@param BuffID number
---@param GiverID number
---@param BuffSkillType BuffDefine.BuffSkillType
function MajorBuffVM:RemoveBuff(BuffID, GiverID, BuffSkillType)
    local bOK = self.BuffList:RemoveBuff(BuffID, GiverID, BuffSkillType)
    if bOK then
        self:CheckMainSelected()
    end

    local TargetIndex = nil
    for Key,Value in pairs(self.UnShowBuffTable) do
        if (Value == BuffID) then
            TargetIndex = Key
            break
        end
    end
    
    if (TargetIndex ~= nil) then
        self.UnShowBuffTable[TargetIndex] = nil
    end
end

function MajorBuffVM:UpdateBuffs()
    local Values = BuffUIUtil.GetEntityBuffVMParamsList(MajorUtil.GetMajorEntityID(), true)
    self.BuffList:UpdateByValues(Values, BuffUIUtil.SortBuffDisplay)
    self:CheckMainSelected()
end

function MajorBuffVM:UpdateBuffEffective(BuffSkillType, BuffID, GiverID, BuffStatus)
    local VM = self.BuffList:FindBuffVM(BuffID, GiverID, BuffSkillType)
    if nil == VM then
        return
    end

    --BuffStatus枚举改成bool
    VM:SetEffective(BuffStatus)
end

function MajorBuffVM:OnBegin()
end

---被AcotrMgr驱动
function MajorBuffVM:OnTimer()
    if nil == self.BuffList then return end
    self.BuffList:UpdateBuffsLeftTime()
end

function MajorBuffVM:OnEnd()
end

function MajorBuffVM:SetIsMajorBuffDetailVisiable(V)
    self.IsMajorBuffDetailVisiable = V
end

function MajorBuffVM:GetBuffLen()
    return self.BuffList:Length()
end

function MajorBuffVM:CheckMainSelected()
    if self.MainSelectedItem then
        local Len = self:GetBuffLen()

        if Len == 0 then
            self:SetIsMajorBuffDetailVisiable(false)
            self:SetMainSelectedIdx(nil)
        else
            local Idx = self.BuffList:GetItemIndex(self.MainSelectedItem)

            if not Idx then
                self:SetMainSelectedIdx(1)
                return
            end

            if Idx ~= self.MainSelectedIdx then
                self:SetMainSelectedIdx(Idx)
            end
        end
    end
end

function MajorBuffVM:SetMainSelectedIdx(Idx)
    if (not Idx) or Idx <= 0 then
        self.MainSelectedIdx = nil
        self.MainSelectedItem = nil
        return
    end

    local Len = self:GetBuffLen()
    if Idx <= Len then
        self.MainSelectedIdx = Idx
        self.MainSelectedItem = self.BuffList:Get(Idx)
    else
        _G.FLOG_ERROR("ERROR: MajorBuffVM:SetMainSelectedIdx Idx > Len Idx = " .. tostring(Idx))
    end
end

---清理所有生活技能Buff，一般配合LifeSkillBuffMgr:PullBuffs()使用
function MajorBuffVM:ClearLifeSkillBuffs()
    self.BuffList:RemoveItemsByPredicate(function(Item) return Item.BuffSkillType == BuffDefine.BuffSkillType.Life end)
end

return MajorBuffVM
