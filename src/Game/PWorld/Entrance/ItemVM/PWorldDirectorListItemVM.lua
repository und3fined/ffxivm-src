--[[
Author: jususchen jususchen@tencent.com
Date: 2024-07-29 16:16:58
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-30 11:09:45
FilePath: \Script\Game\PWorld\Entrance\ItemVM\PWorldDirectorListItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PworldCfg = require("TableCfg/PworldCfg")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")


--- @class PWorldDirectorListItemVM : UIViewModel
local PWorldDirectorListItemVM = LuaClass(UIViewModel)

function PWorldDirectorListItemVM:Ctor()
    self.PWorldID = nil
    self.Name = ""
    self.Icon = ""
    self.BannerImg = ""
    self.Level = ""
    self.bPreConditonFinished = false
    self.bPass = false

    self.EntType = nil
end

function PWorldDirectorListItemVM:UpdateVM(Value)
    self.PWorldID = Value.ID
    self.bPreConditonFinished = Value.bPreConditonFinished

    local PCfg = PworldCfg:FindCfgByKey(self.PWorldID)
    local SECfg = SceneEnterCfg:FindCfgByKey(self.PWorldID)
    self.EntType = SECfg and SECfg.TypeID
    local SETCfg = SceneEnterTypeCfg:FindCfgByKey(self.EntType)
    self.Icon = SETCfg and SETCfg.Icon or ""
    self.BannerImg = SECfg and SECfg.BackgroudImageIcon or ""
    self.Name = PCfg and PCfg.PWorldName or ""
    if self.bPreConditonFinished then
        self.bPass = require("Game/PWorld/Entrance/PWorldEntUtil").PreCheck(self.PWorldID, self.EntType)
    end
    self.Level = tostring(PCfg and PCfg.PlayerLevel) .. _G.LSTR(1320087)
end

function PWorldDirectorListItemVM:IsEqualVM(Value)
    return Value and self.PWorldID == Value.PWorldID
end

function PWorldDirectorListItemVM:AdapterOnGetCanBeSelected()
	return false
end

function PWorldDirectorListItemVM:AdapterOnGetWidgetIndex()
	return 1
end


return PWorldDirectorListItemVM


