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
    self.IsMountLike = MountVM:IsFlagSet(self.Mount.Flag, ProtoCS.MountFlagBitmap.MountFlagLike)
    self.IsCustomMadeEnabled = _G.MountMgr:IsCustomMadeEnabled(self.ResID)

    local RideCfg = _G.MountMgr:GetRideCfg(self.ResID)
    if RideCfg then
        self.Icon = RideCfg.MountIcon
    end
    self:RefreshRedPoint()
end

--- 针对坐骑图鉴的图标状态更新
function MountSlotVM:UpdateArchiveData(Mount)
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
    self.NumVisible = false
    self.IsMask = self.IsMountNotOwn
    self.IsWearable = self.IsChecked

    -- 图标
    local RideCfg = _G.MountMgr:GetRideCfg(self.ResID)
    if RideCfg then
        self.Icon = RideCfg.MountIcon
    end

    -- 剧情保护
    if self.IsMountStory == 1 then
        self.ItemMountName = "???"
        self.IsShowBlack = false
        self.Icon = "Texture2D'/Game/UI/Texture/Chocobo/UI_Mount_Icon_Hide.UI_Mount_Icon_Hide'"
        self.IsShowIcon = false
    end

    -- 改变图标颜色
    if self.IsShowBlack == true then
        self.IconColor = "959595FF"
    else
        self.IconColor = "FFFFFFFF"
    end

    --红点相关
    self:RefreshRedPoint()
    self.RedDotStyle = RedDotDefine.RedDotStyle.SecondStyle
    if self.IsShowRedPoint ~= nil and self.IsShowRedPoint then
        local RedDotName = MountCustomMadeVM:GetRedDotName(self.ResID)
        if RedDotName == "" then
            RedDotName = MountVM:GetRedDotName(self.ResID)
        end
        self.RedDotName = RedDotName
    else
        self.RedDotName = ""
    end
end

function MountSlotVM:OnSelectedChange(IsSelected)
    self.IsSelect = IsSelected
end

function MountSlotVM:OnSelectChanged(IsSelected)
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