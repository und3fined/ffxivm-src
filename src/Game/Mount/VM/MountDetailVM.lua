local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

local RideCfg = require("TableCfg/RideCfg")
local MountVM = require("Game/Mount/VM/MountVM")

local MountMgr = _G.MountMgr
---@class MountSlotVM : UIViewModel
local MountDetailVM = LuaClass(UIViewModel)

function MountDetailVM:Ctor()
    self.ResID = nil
    self.ItemColor = ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE
    self.Name = nil
    self.IsShowGetway = false
    self.StatusButtonVisible = false
    self.IsShowHorizontalBox = false
    self.IsEquipment = false
    self.IsShowItemGrade = false
    self.IsShowStatus = false
    self.TypeName = nil
    self.LevelName = nil
    self.LevelText = nil
    self.Desc = nil
    self.IsShowFavorite = true
    self.FavoriteToggle = false
    self.Icon = nil
end

-- message Mount
-- {
-- int32 ResID = 1;
-- int32 Flag = 2;
-- MountFrom From = 3;
-- }
function MountDetailVM:UpdateDetail(Mount)
    if Mount ~= nil then
        self.Mount = Mount
    else
        self.Name = nil
        return
    end
    self.ResID = self.Mount.ResID
    local c_ride_cfg = RideCfg:FindCfgByKey(self.ResID)
    self.Name = c_ride_cfg.Name
    if c_ride_cfg.MountType == ProtoCommon.MountType.MountFlying then
        self.TypeName = "浮空"
    else
        self.TypeName = "步行"
    end
    self.LevelName = "乘坐人数"
    self.LevelText = string.format("%d人", c_ride_cfg.SeatCount)
    self.Desc = MountMgr:GetMountDesc(self.ResID)
    self.FavoriteToggle = MountVM:IsFlagSet(self.Mount.Flag, ProtoCS.MountFlagBitmap.MountFlagLike)
    self.Icon = c_ride_cfg.MountIcon
end

function MountDetailVM:OnBtnFavoriteClick(ButtonState)
    local FavoriteToggle = self.FavoriteToggle
    self.FavoriteToggle = ButtonState == _G.UE.EToggleButtonState.Checked
    _G.MountMgr:SendMountLike(self.ResID, self.FavoriteToggle)
    --恢复按钮状态，等后台协议返回再修改
    self.FavoriteToggle = FavoriteToggle
end

return MountDetailVM