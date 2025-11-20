--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-04 17:47:38
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-26 16:35:28
FilePath: \Script\Game\House\VM\HouseOthersInfoPanelViewVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local MathUtil = require("Utils/MathUtil")
local ProtoCS = require("Protocol/ProtoCS")
local HouseFlagCfg = require("TableCfg/HouseFlagCfg")
local UIBindableList = require("UI/UIBindableList")
local HouseInfoRoommateItemVM = require("Game/House/VM/Item/HouseInfoRoommateItemVM")

local HouseOthersInfoPanelViewVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR

function HouseOthersInfoPanelViewVM:Ctor()
    self.HouseID = 0
    self.BeLikeNum = 0
    self.RoommateList = {}
    self.HouseTagList = {}
    self.TextLocation = ""
    self.HouseType = 0
    self.TextHouseName = ""
    self.HouseResID = 0
    self.TextGreetingContent = ""
    self.TextLikes = ""
    self.EtherGid = nil
    self.WorldID = nil
    self.OwnerID = 0
    self.VisitSetting = nil
    self.Roommates = nil
    self.TextGreetingContentEmptyVisible = false
    self.TextNoTagVisible = false
    self.RoommateVisibility = true
    self.RoommateTableList = UIBindableList.New(HouseInfoRoommateItemVM)
    self.CanBrowser = false
    self.CanVisitEnter = false
    self.Addr = nil
    self.IconHouse = ""
    self.TeleportText = ""
end

function HouseOthersInfoPanelViewVM:UpdateVM(HouseInfo)
    if HouseInfo ~= nil then
        local BasicInfo = HouseInfo.Basic
        self.HouseType = BasicInfo.HouseType
        self.OwnerID = BasicInfo.OwnerID
        local Index = _G.HouseInfoMgr.GroupHouseMember[BasicInfo.OwnerID] and _G.HouseInfoMgr.GroupHouseMember[BasicInfo.OwnerID].Index or 1
        self.TextHouseName =_G.HouseInfoMgr:GetHouseNameStr(BasicInfo.Name, BasicInfo.Addr, self.HouseType, Index) 
        self.HouseResID = BasicInfo.HouseResID
        self.TextGreetingContent = BasicInfo.Greeting
        self.TextGreetingContentEmptyVisible = self.TextGreetingContent==""
        self.TextLikes = BasicInfo.BeLikeNum
        self.EtherGid = BasicInfo.EtherGid
        self.PicUrl = BasicInfo.PicUrl
        self.WorldID = BasicInfo.WorldID
        self.TextLocation = _G.HouseLandMgr:GetHouseAddrStr(BasicInfo.Addr, self.HouseResID, self.HouseType, Index)
        self.Addr = BasicInfo.Addr
        self.VisitSetting = BasicInfo.VisitSetting
        self.Roommates = HouseInfo.Roommates

        local Tags = MathUtil.DecodeUint(BasicInfo.Tags, HouseLocalDef.HouseTagNumLimit)
        local HouseTagList = {}
        for i = 1, #Tags do
            local TagID = Tags[i]
            local TagCfg = HouseFlagCfg:FindCfgByKey(TagID)
            local TagName = TagCfg and TagCfg.FlagName or ""
            if TagID > 0 then
                table.insert(HouseTagList, {
                    IconPath = string.format(HouseLocalDef.LocationHouseTagIconPath, TagID, TagID),
                    TagText = TagName
                })
            end
        end

        self.HouseTagList = HouseTagList
        self.TextNoTagVisible = #self.HouseTagList <= 0
        self.CanBrowser =  _G.HouseLandMgr.GetVisitPrivile(self.OwnerID, self.VisitSetting, self.Roommates, ProtoCS.HouseVisitSettingType.HouseVisitSettingType_Browser, BasicInfo.HouseType)
        self.CanVisitEnter =  _G.HouseLandMgr.GetVisitPrivile(self.OwnerID, self.VisitSetting, self.Roommates, ProtoCS.HouseVisitSettingType.HouseVisitSettingType_Enter, BasicInfo.HouseType)
        self.IconHouse = _G.HouseInfoMgr:GetHouseIconByHouseDetail(HouseInfo)
        self:UpdateTeleportText()
    end
end

function HouseOthersInfoPanelViewVM:UpdateRoommate()
    self.RoommateTableList:UpdateByValues(self.Roommates)
end

function HouseOthersInfoPanelViewVM:SetDolikeNum(Num)
    self.TextLikes = Num
end

function HouseOthersInfoPanelViewVM:UpdateTeleportText()
    if self.EtherGid and self.EtherGid ~= 0 then
        self.TeleportText = HouseLocalDef.HouseInfoStr.TeleportText
    else
        if _G.AutoPathMoveMgr:IsAutoPathMoveEnable() then
            self.TeleportText = HouseLocalDef.HouseInfoStr.WayFinding
        else
            self.TeleportText = HouseLocalDef.HouseInfoStr.TraceText
        end
    end
end

return HouseOthersInfoPanelViewVM
