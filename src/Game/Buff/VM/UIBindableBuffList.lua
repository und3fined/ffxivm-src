---
--- Author: loiafeng
--- DateTime: 2024-06-18 09:41:14
--- Description: 通用buffVM列表
---

local UIBindableList = require("UI/UIBindableList")
local ActorBufferVM = require("Game/Actor/ActorBufferVM")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")

---@class UIBindableBuffList : UIBindableList
local UIBindableBuffList = {}
UIBindableBuffList.Super = UIBindableList
UIBindableBuffList.__BaseType = UIBindableList
setmetatable(UIBindableBuffList, {__index = UIBindableList})

---New
---@return UIBindableBuffList
function UIBindableBuffList.New(UpdateVMParams)
    local Object = UIBindableList.New(ActorBufferVM, UpdateVMParams)
    getmetatable(Object).__index = UIBindableBuffList
    Object:Ctor(ActorBufferVM, UpdateVMParams)
	return Object
end

---Ctor
---@param ViewModelClass nil | UIViewModel 传递ViewModelClass参数后，UIBindableList 如果是手动创建列表的对象 不要传递这个参数
---@param UpdateVMParams any @UpdateVM的参数
function UIBindableBuffList:Ctor(ViewModelClass, UpdateVMParams)
end

---FindBuffVM
---@param BuffID number
---@param GiverID number
---@param BuffType BuffDefine.BuffSkillType
function UIBindableBuffList:FindBuffVM(BuffID, GiverID, BuffType)
    return self:Find(function(BuffVM)
        return (BuffVM.BuffID == BuffID) and
            (BuffVM.GiverID == 0 or BuffVM.GiverID == GiverID) and
            (BuffVM.BuffSkillType == BuffType)
    end)
end

function UIBindableBuffList:ContainBuff(BuffID)
    if BuffID then
        return self:Find(function(BuffVM)
            return BuffVM.BuffID == BuffID
        end) ~= nil
    end
end

---AddOrUpdateBuff 新增或者刷新Buff
---@param Params BuffVMParams
function UIBindableBuffList:AddOrUpdateBuff(Params)
    local VM = self:FindBuffVM(Params.BuffID, Params.GiverID, Params.BuffSkillType)
    if nil ~= VM then
        VM:UpdateVM(Params)
    else
        self:AddByValue(Params)
        self:Sort(BuffUIUtil.SortBuffDisplay)
    end
end

---RemoveBuff
---@param BuffID number
---@param GiverID number
---@param BuffSkillType BuffDefine.BuffSkillType
---@return boolean
function UIBindableBuffList:RemoveBuff(BuffID, GiverID, BuffSkillType)
    local VM = self:FindBuffVM(BuffID, GiverID, BuffSkillType)
    if nil ~= VM then
        self:Remove(VM)
        return true
    end
    return false
end

---UpdateBuffsLeftTime 更新Buff剩余时间
function UIBindableBuffList:UpdateBuffsLeftTime()
    for index = 1, self:Length() do
        local BuffVM = self:Get(index)
        BuffVM:UpdateLeftTime()
        BuffVM:UpdateBuffTimeDisplay()
    end
end

return UIBindableBuffList