-- Author: michaelyang_lightpaw
-- Date: 2024-11-15
-- Description:玩具基类
--

local LuaClass = require("Core/LuaClass")
local ToyCfg = require("TableCfg/ToyCfg")

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR

---@class GoldGameNewBase
local ToyBase = LuaClass()

function ToyBase:Ctor()
    self.ActiveTimeMS = 0 -- 激活的时间戳
    self.ToyType = 0
end

-- 玩具初始化 --
function ToyBase:Init(InToyID)
    local TargetCfg = ToyCfg:FindCfgByKey(InToyID)
    if (TargetCfg == nil) then
        return false
    end

    self.ToyID = InToyID
    self.ToyCfg = TargetCfg
    local result = self:OnInit(InToyID)
    return result
end

function ToyBase:GetToyID()
    return self.ToyID
end

function ToyBase:GetToyType()
    return self.ToyType
end

-- @ 记得要返回 true or false
function ToyBase:OnInit(InToyID)
    return true
end
-- END --

-- 玩具开始 --
function ToyBase:ToyBegin(InSceneID)
    self:OnToyBegin(InSceneID)
end

function ToyBase:OnToyBegin(InSceneID)
end
-- END --

-- 玩具取消 --
function ToyBase:ToyExit()
    self:OnToyExit()
end

function ToyBase:OnToyExit()
end
-- END --

-- 进入视野 --
function ToyBase:VisionEnter(InEntityType, InEntityID)
    self:OnVisionEnter(InEntityType, InEntityID)
end

function ToyBase:OnVisionEnter(InEntityType, InEntityID)
end
-- END --

-- 离开视野 --
function ToyBase:VisionLeave(InEntityType, InEntityID)
    self:OnVisionLeave(InEntityType, InEntityID)
end

function ToyBase:OnVisionLeave(InEntityType, InEntityID)
end
-- END--

return ToyBase
