--[[
Author: v_hggzhang <v_hggzhang@tencent.com>
Date: 2024-06-28 11:16:37
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-08-02 19:15:45
FilePath: \Script\Game\PWorld\Entrance\PWorldEntEntityVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE_G.PWorldMatchMgr
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PWorldEntEntityVM = LuaClass(UIViewModel)

local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")


function PWorldEntEntityVM:Ctor()
    self.IsLock = false
    self.IsSelected = false
    self.IsMatching = false
    self.PWorldName = ""
    self.ID = 0
    self.IsDailyRandom = false
    self.EntranceCfg = nil
    self.BackgroudImageIcon = ""
    self.bShowLock = false
    
    self.bPrettyHard = false
end

function PWorldEntEntityVM:UpdateNormPol()
    self.EntranceCfg = SceneEnterCfg:FindCfgByKey(self.ID)

    self.PWorldID = self.EntranceCfg.ID
    local PCfg = PworldCfg:FindCfgByKey(self.PWorldID)
    self.PWorldName = PCfg and PCfg.PWorldName or ""
end

function PWorldEntEntityVM:UpdateCrystallinePol()
    self.EntranceCfg = SceneEnterCfg:FindCfgByKey(self.ID)
    self.PWorldID = self.EntranceCfg.ID
    local PCfg = PworldCfg:FindCfgByKey(self.PWorldID)
    if PWorldEntUtil.IsCrystallineExercise(self.EntranceCfg.TypeID) then
        self.PWorldName = _G.LSTR(1320137)
    elseif PWorldEntUtil.IsCrystallineRank(self.EntranceCfg.TypeID) then
        self.PWorldName = _G.LSTR(1320138)
    else
        self.PWorldName = PCfg and PCfg.PWorldName or ""
    end
end

function PWorldEntEntityVM:UpdateRamdomTrackPol()
    self.PWorldID = self.ID
    -- LSTR string: 陆行鸟竞赛 随机赛道
    self.PWorldName = _G.LSTR(430008)
    self.EntranceCfg = SceneEnterCfg:FindCfgByKey(self.ID)
end

function PWorldEntEntityVM:UpdateDailyRandomPol()
    self.EntranceCfg = SceneEnterDailyRandomCfg:FindCfgByKey(self.ID)
    self.PWorldName = self.EntranceCfg.Name
end

function PWorldEntEntityVM:UpdateVM(Value)
    self.ID = Value.ID
    self.Type = Value.Type
    self.IsChocoboRandomTrack = PWorldEntUtil.IsChocoboRandomTrack(self.Type)
    self.IsDailyRandom = PWorldEntUtil.IsDailyRandom(self.Type)
    local IsCrystalline = PWorldEntUtil.IsCrystalline(self.Type)

    self.bPrettyHard = PWorldEntUtil.IsPrettyHardPWorld(self.ID)

    if self.IsDailyRandom then
        self:UpdateDailyRandomPol()
    elseif self.IsChocoboRandomTrack then
        self:UpdateRamdomTrackPol()
    elseif IsCrystalline then
        self:UpdateCrystallinePol()
    else
        self:UpdateNormPol()
    end
    
    local BannerImagePath = self.EntranceCfg and self.EntranceCfg.BackgroudImageIcon or ""
    if self.IsChocoboRandomTrack then
        BannerImagePath = PWorldEntDefine.ChocoboRandomTrackBannerImagePath
    end
    self:SetBgIcon(BannerImagePath)
    self:UpdMatch(Value.bNotShowMatch)
    self:UpdLock()
end

function PWorldEntEntityVM:IsEqualVM(Value)
	return Value ~= nil and self.ID == Value.ID and self.Type == Value.Type
end

function PWorldEntEntityVM:AdapterOnGetWidgetIndex()
	return 1
end

function PWorldEntEntityVM:SetSelected(IsSelected)
	self.IsSelected = IsSelected
end

function PWorldEntEntityVM:UpdMatch(bNotShowMatch)
	self.IsMatching = not bNotShowMatch and _G.PWorldMatchMgr:IsPWorldMatching(self.ID, self.Type)
    self:UpdateShowLock()
end

function PWorldEntEntityVM:UpdLock()
    local IsPreCheckOK = PWorldEntUtil.PreCheck(self.ID, self.Type)
    self.IsLock = not IsPreCheckOK
    self:UpdateShowLock()
end

function PWorldEntEntityVM:SetBgIcon(Icon)
    self.BackgroudImageIcon = Icon or ""
end

function PWorldEntEntityVM:UpdateShowLock()
    self.bShowLock = self.IsLock and not self.IsMatching
end

return PWorldEntEntityVM