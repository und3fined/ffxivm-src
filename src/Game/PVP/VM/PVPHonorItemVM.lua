local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local PVPHonorCfg = require("TableCfg/PVPHonorCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")

local PVPInfoMgr = _G.PVPInfoMgr
local LSTR = _G.LSTR

---@class PVPHonorItemVM : UIViewModel
local PVPHonorItemVM = LuaClass(UIViewModel)

function PVPHonorItemVM:Ctor()
    self.ID = nil
    self.Icon = nil
    self.Name = nil
    self.Level = nil
    self.GetDate = nil
    self.Condition = nil
    self.IsOwn = nil
end

function PVPHonorItemVM:UpdateVM(Params)
    local Cfg = PVPHonorCfg:FindCfgByKey(Params.ID)
    if Cfg == nil then return end

    local HonorID = Cfg.ID
    self.ID = HonorID
    self.Icon = Cfg.Icon
    self.Name = Cfg.Name
    self.Level = Cfg.Level
    self.Condition = Cfg.ConditionNote

    local IsOwn = PVPInfoMgr:IsOwnHonor(HonorID)
    self:UpdateOwnString(Cfg, IsOwn)
    self.IsOwn = IsOwn
end

function PVPHonorItemVM:UpdateOwnString(Cfg, IsOwn)
    local OwnString = nil
    if IsOwn then
        local GetTime = PVPInfoMgr:GetHonorGetTime(Cfg.ID)
        local TimeString = TimeUtil.GetTimeFormat("%Y/%m/%d", GetTime)
        OwnString = string.format(LSTR(130048), TimeString)
        OwnString = LocalizationUtil.LocalizeStringDate(OwnString)
    else
        local NowCount = PVPInfoMgr:GetHonorParam(Cfg.ID)
        local NeedCount = Cfg.ConditionParam
        OwnString = string.format(LSTR(130049), NowCount, NeedCount)
    end

    self.GetDate = OwnString
end

return PVPHonorItemVM