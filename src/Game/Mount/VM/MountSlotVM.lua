local LuaClass = require("Core/LuaClass")
--local ItemVM = require("Game/Item/ItemVM")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local MountVM = require("Game/Mount/VM/MountVM")
local RideCfgTable = require("TableCfg/RideCfg")
local MountCustomMadeVM = require("Game/Mount/VM/MountCustomMadeVM")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

local ChocoboTransportMgr = _G.ChocoboTransportMgr

---@class MountSlotVM : UIViewModel
local MountSlotVM = LuaClass(UIViewModel)

function MountSlotVM:Ctor()
    self.ResID = nil
    self.Icon = nil
    self.IsMountNew = false
    self.IsCustomMadeEnabled = false
    self.IsMountLike = false
    self.IsChecked = false
    self.IsSelect = false
    self.IsMount = true
    self.Mount = nil
    self.IsMountNotOwn = false
    self.IsMountStory = false
    self.ItemMountName = "--"
    self.IsShowBlack = false
    self.IsShowIcon = true
    self.IconColor = "FFFFFFFF"
    self.IsShowRedPoint = false
    self.RedPointType = nil
end

function MountSlotVM:UpdateData(Mount)
    if Mount ~= nil then
        self.ResID = Mount.ResID
        self.Mount = Mount
    end
    self.Handbook = false
    local IsInChocoboTransport = _G.ChocoboTransportMgr:GetIsTransporting() -- 运输陆行鸟使用的陆行鸟不是玩家的陆行鸟，额外判断处理
    self.IsChecked = self.ResID == MountVM.CurRideResID and not IsInChocoboTransport and not MountVM.bRideProbationState
    self.IsMountNew = MountVM:IsNew(self.ResID)
    self.IsMountLike = self.IsMountNew == false and MountVM:IsFlagSet(self.Mount.Flag, ProtoCS.MountFlagBitmap.MountFlagLike)
    self.IsCustomMadeEnabled = _G.MountMgr:IsCustomMadeEnabled(self.ResID)

    local RideCfg = RideCfgTable:FindCfgByKey(self.ResID)
    if RideCfg then
        self.Icon = RideCfg.MountIcon
    end
    self:RefreshRedPoint()
end

function MountSlotVM:UpdateArchiveData(Mount)
    --针对坐骑图鉴的图标状态更新
    self.Handbook = true
    self.ResID = Mount.ResID
    self.Mount = Mount
    self.IsMountNotOwn = MountVM:IsNotOwnedMount(Mount.ResID)
    self.IsMountNew = MountVM:IsNew(Mount.ResID) and self.IsMountNotOwn == false
    self.IsMountStory = self.IsMountNotOwn == true and Mount.IsStoryProtect
    self.ItemMountName = Mount.Name
    self.IsShowBlack = self.IsMountNotOwn
    self.IsShowIcon = true
    self.IsChecked = self.ResID == MountVM.CurRideResID and not MountVM.bRideProbationState
    -- 图标
    local RideCfg = RideCfgTable:FindCfgByKey(self.ResID)
    if RideCfg then
        self.Icon = RideCfg.MountIcon
    end
     -- 剧情保护
     if self.IsMountStory == 1 then
        self.ItemMountName = "???"
        self.IsShowBlack = false
        --self.Icon = nil
        self.IsShowIcon = false
    end

    -- 改变图标颜色
    if self.IsShowBlack == true then
        self.IconColor = "959595FF"
    else
        self.IconColor = "FFFFFFFF"
    end
    self:RefreshRedPoint()
end

function MountSlotVM:OnSelectedChange(IsSelected)
    self.IsSelect = IsSelected
end

function MountSlotVM:RefreshRedPoint()
	for k, v in pairs(MountVM.MountList) do 
		if v.ResID == self.ResID then
            local Flag = v.Flag
            local MountCustomIsNew = MountCustomMadeVM:MountIsNew(v.ResID)
			if self.Handbook then
                self.IsShowRedPoint = MountVM:IsNew(v.ResID) or MountCustomIsNew
                if MountCustomIsNew then
                    self.RedPointType = RedDotDefine.RedDotStyle.NormalStyle
                else
                    self.RedPointType = RedDotDefine.RedDotStyle.TextStyle
                end
            else
                self.IsShowRedPoint = MountVM:IsNew(v.ResID) or MountCustomIsNew
                if MountCustomIsNew then
                    self.RedPointType = RedDotDefine.RedDotStyle.NormalStyle
                else
                    self.RedPointType = RedDotDefine.RedDotStyle.TextStyle
                end
			end
		end
	end
end

return MountSlotVM