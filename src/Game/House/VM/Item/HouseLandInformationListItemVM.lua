local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local ProtoCS = require("Protocol/ProtoCS")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")

---@class HouseLandInformationListItemVM : UIViewModel
local HouseLandInformationListItemVM = LuaClass(UIViewModel)

---Ctor
function HouseLandInformationListItemVM:Ctor()
    self.ImgItemBGIndex = 0
    self.IconMoneyVisible = nil
    self.TextTitle = ""
    self.TextInfo = ""
    self.IconMoney = nil
    self.Index = nil
    self.TextInfoColor = HouseLocalDef.LandInfoItemColor.Defalut
    self.TextTitleColor = HouseLocalDef.LandInfoItemColor.Defalut
    self.PanelVisible = nil
end

function HouseLandInformationListItemVM:UpdateVM(Params)
    if not Params then return end
        
    self.PanelVisible = true
    local LandInfo = Params.LandInfo
    local SelfHasJoinSelect = Params.SelfHasJoinSelect
    local ArmyHasJoinSelect = Params.ArmyHasJoinSelect
    local OnlyArmJoinSelect = ArmyHasJoinSelect and not SelfHasJoinSelect
    local ImgItemBGIndex = Params.Index % 2
    self.IconMoneyVisible = Params.Index == 1
    self.Index = Params.Index
    local TextInfoColor = HouseLocalDef.LandInfoItemColor.Defalut
    local TextTitleColor = HouseLocalDef.LandInfoItemColor.Defalut
    local TextTitle = HouseLocalDef.LandInfoStr[Params.Index] .. ":"
    local TextInfo = ""
    self.IconMoney = _G.ScoreMgr:GetScoreIconName(LandInfo.MoneyType)
    if Params.Index == 1 then
        TextInfo = LandInfo.Price
    elseif Params.Index == 2 then
        local EstateInfoCfg = require("TableCfg/EstateInfoCfg")
        local EstateName = ""
        if EstateInfoCfg ~= nil then
            local EstateInfo = EstateInfoCfg:FindCfgByKey(Params.ResidenceNumber) or {}
            EstateName = EstateInfo.EstateName
        end
        TextInfo = string.format(HouseLocalDef.LandInfoStr.Address, EstateName, Params.AreaNumber, LandInfo.LandNumber)
    elseif Params.Index == 3 then
        TextInfo = HouseLocalDef.LandSizeTypeStr[LandInfo.LandSize]
    elseif Params.Index == 4 then
        TextInfo = HouseLocalDef.LandInfoStr.CurPeriod .. HouseLocalDef.LandInfoStr[7 + LandInfo.BuyType]
    elseif Params.Index == 5 then
        TextInfo = LandInfo.ApplyCount
        if LandInfo.LandStatus == ProtoCS.LandStatusType.LandStatusType_Public then
            if not Params.HasJoinSelect then
                TextTitle = HouseLocalDef.LandInfoStr[7] .. ":"
                TextInfo = LandInfo.AwardNumber
                TextInfoColor = HouseLocalDef.LandInfoItemColor.Select
            elseif not SelfHasJoinSelect then
                TextTitle = HouseLocalDef.LandInfoStr.JoinPlayerName .. ":"
                local RoleID = LandInfo.Owner
                RoleInfoMgr:QueryRoleSimple(RoleID, function()
                    local RoleVM, IsValid = RoleInfoMgr:FindRoleVM(RoleID, true)
                    if RoleVM and RoleVM.RoleID == RoleID then
                        TextInfo = RoleVM.Name
                    end
                end, nil, true)
                TextInfoColor = HouseLocalDef.LandInfoItemColor.Select
            end
        end
    elseif Params.Index == 6 then
        self.PanelVisible = false
        TextInfo = LandInfo.ApplyNumber
        TextInfoColor = HouseLocalDef.LandInfoItemColor.Select
        if LandInfo.LandStatus == ProtoCS.LandStatusType.LandStatusType_Sale then
            if OnlyArmJoinSelect then
                TextInfo = LandInfo.GroupAplNumber
                TextTitle = HouseLocalDef.LandInfoStr.ArmSelectNumber
            end
        elseif LandInfo.LandStatus >= ProtoCS.LandStatusType.LandStatusType_Public then
            if LandInfo.ApplyNumber == LandInfo.AwardNumber then
                TextInfo = string.format(HouseLocalDef.LandInfoStr.Selected, LandInfo.ApplyNumber,
                    HouseLocalDef.LandInfoStr.Your)
                TextInfoColor = HouseLocalDef.LandInfoItemColor.Selected
                ImgItemBGIndex = 3
            end

            if LandInfo.ApplyNumber > 0 and LandInfo.ApplyNumber ~= LandInfo.AwardNumber then
                TextInfo = string.format(HouseLocalDef.LandInfoStr.UnSelected, LandInfo.ApplyNumber,
                    HouseLocalDef.LandInfoStr.Your)
                TextInfoColor = HouseLocalDef.LandInfoItemColor.Selected
                ImgItemBGIndex = 2
            end

            if LandInfo.GroupID > 0 then
                if LandInfo.GroupID == _G.ArmyMgr:GetArmyID() then
                    TextInfo = string.format(HouseLocalDef.LandInfoStr.Selected, LandInfo.ApplyNumber,
                    HouseLocalDef.LandInfoStr.YourTeam)
                    TextInfoColor = HouseLocalDef.LandInfoItemColor.Selected
                    ImgItemBGIndex = 3
                else
                    TextInfo = string.format(HouseLocalDef.LandInfoStr.UnSelected, LandInfo.ApplyNumber,
                    HouseLocalDef.LandInfoStr.YourTeam)
                    TextInfoColor = HouseLocalDef.LandInfoItemColor.Selected
                    ImgItemBGIndex = 2
                end
            end
        end

        for i, v in ipairs(_G.HouseLandMianPanelVM.LandSelectInfo) do
            if v.LandNumber == LandInfo.LandNumber and v.AreaNumber == LandInfo.AreaNumber and v.ResidenceNumber == LandInfo.ResidenceNumber then
                self.PanelVisible = true
                break
            end
        end
    elseif Params.Index == 7 then
        TextInfo = LandInfo.AwardNumber
        TextInfoColor = HouseLocalDef.LandInfoItemColor.Select
    elseif Params.Index == 8 then
        TextInfo = ""
        TextTitle = HouseLocalDef.LandInfoStr.BuildTips
        TextTitleColor = HouseLocalDef.LandInfoItemColor.BuildTips
        ImgItemBGIndex = 4
    end
    self.TextTitle = TextTitle
    self.TextInfo = TextInfo
    self.TextInfoColor = TextInfoColor
    self.TextTitleColor = TextTitleColor
    self.ImgItemBGIndex = ImgItemBGIndex
end

function HouseLandInformationListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Index == self.Index
end

return HouseLandInformationListItemVM
