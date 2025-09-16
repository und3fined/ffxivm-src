local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

local RideCfg = require("TableCfg/RideCfg")

---@class MountArchiveDetailVM : UIViewModel
local MountArchiveDetailVM = LuaClass(UIViewModel)

function MountArchiveDetailVM:Ctor()
    self.ResID = nil
    self.Name = nil
    self.SeatCount = nil
    self.SkeletonId = nil
    self.PatternId = nil
    self.ImeChanId = nil
    self.MountText = nil
    self.MountBgm = nil
end

-- message Mount
-- {
-- int32 ResID = 1;
-- int32 Flag = 2;
-- MountFrom From = 3;
-- }
function MountArchiveDetailVM:UpdateDetail(Mount)
    self.ResID = Mount.ResID
    local c_ride_cfg = RideCfg:FindCfgByKey(self.ResID)
    self.Name = c_ride_cfg.Name
    self.SeatCount = c_ride_cfg.SeatCount
    self.SkeletonId = c_ride_cfg.SkeletonId
    self.PatternId = c_ride_cfg.PatternId
    self.ImeChanId = c_ride_cfg.ImeChanId
    self.MountBgm = c_ride_cfg.MountBgm
    -- 坐骑文本，需要新建表
    -- self.MountText
end

function MountArchiveDetailVM:OnBtnFavoriteClick(ButtonState)
    local FavoriteToggle = self.FavoriteToggle
    self.FavoriteToggle = ButtonState == _G.UE.EToggleButtonState.Checked
    _G.MountMgr:SendMountLike(self.ResID, self.FavoriteToggle)
    --恢复按钮状态，等后台协议返回再修改
    self.FavoriteToggle = FavoriteToggle
end

return MountArchiveDetailVM