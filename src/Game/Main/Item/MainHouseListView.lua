--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-15 10:37:10
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-18 20:00:13
FilePath: \Script\Game\Main\Item\MainHouseListView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: skysong
--- DateTime: 2025-05-16 16:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MainHouseListVM = require("Game/Main/VM/MainHouseListVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MainPanelVM = require("Game/Main/MainPanelVM")
local MainPanelConfig = require("Game/Main/MainPanelConfig")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

---@class MainHouseListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold UToggleButton
---@field ImgDown UFImage
---@field ImgUp UFImage
---@field TableView UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainHouseListView = LuaClass(UIView, true)

function MainHouseListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold = nil
	--self.ImgDown = nil
	--self.ImgUp = nil
	--self.TableView = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainHouseListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainHouseListView:OnInit()
    self.AdapterButtonList = UIAdapterTableView.CreateAdapter(self, self.TableView)  ---@type UIAdapterTableView
    self.Binders = {
        { "ButtonList", UIBinderUpdateBindableList.New(self, self.AdapterButtonList) },
        { "bToggleCheck", UIBinderSetIsVisible.New(self, self.TableView, true)},
        { "bToggleCheck", UIBinderValueChangedCallback.New(self, nil, function(_, V)
            V = V or false
            self.BtnFold:SetCheckedState(V and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.Unchecked)
            MainPanelVM:SetFunctionVisible(V, MainPanelConfig.TopRightInfoType.House)
        end)},
    }
end

function MainHouseListView:OnDestroy()

end

function MainHouseListView:OnShow()
    MainHouseListVM.bToggleCheck = not (_G.HousingMgr.HouseID > 0)

    MainHouseListVM:UpdateButtonLayout()
    self:UpdateDecoratePrivilege()
end

function MainHouseListView:OnHide()

end

function MainHouseListView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnFold, self.OnToggleBtnFold)
end

function MainHouseListView:OnToggleBtnFold()
    MainHouseListVM:Toggle()

    self:UpdateDecoratePrivilege()
end

function MainHouseListView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ShowDecorateView, self.ShowDecorateView)
    self:RegisterGameEvent(EventID.HouseMemberPrivilegeChangeNtf, self.OnHouseMemberPrivilegeChangeNtf)
    self:RegisterGameEvent(EventID.HouseShareUpdate, self.OnHouseShareUpdate)
    self:RegisterGameEvent(EventID.HouseBeDissolveRoomNtf, self.HouseBeDissolveRoomNtf)
    self:RegisterGameEvent(EventID.HouseInviteReplyRsp, self.OnHouseInviteReplyRsp)
    self:RegisterGameEvent(EventID.ArmySelfPermisstionToc, self.OnArmySelfPermisstionToc)
end

function MainHouseListView:OnRegisterBinder()
    self:RegisterBinders(MainHouseListVM, self.Binders)
end

function MainHouseListView:UpdateDecoratePrivilege()
    local IsVisible = _G.HousingMgr.HouseID > 0
    if not IsVisible then
        MainHouseListVM:SetDecorateIsVisible(false)
        return
    end
    
    if _G.HousingMgr.HouseID == _G.HousingMgr:GetOwnHouseID() or _G.HousingMgr.HouseID == _G.HousingMgr:GetArmyPersonalHouseID() then
        MainHouseListVM:SetDecorateIsVisible(true)
    elseif _G.HousingMgr.HouseID == _G.HousingMgr:GetSharedHouseID() then
        -- 查询权限
        local Callback = function(Basic, Roommates)
            local HasDecoratePrivilege = false

            local PlayerRoleID = MajorUtil.GetMajorRoleID()
            if PlayerRoleID == Basic.OwnerID then
                HasDecoratePrivilege = true
            else
                -- 检查当前玩家是否有装修权限
                for i, Roommate in pairs(Roommates) do
                    if Roommate.RoleID == PlayerRoleID then
                        local DecorateBit = 1 << ProtoCS.HousePrivilgeType.HousePrivilgeType_EditDecorate
                        -- 检查权限位是否被设置
                        if Roommate.Privileges & DecorateBit ~= 0 then
                            HasDecoratePrivilege = true
                            break
                        end
                    end
                end
            end

            MainHouseListVM:SetDecorateIsVisible(HasDecoratePrivilege)
        end
        _G.HouseInfoMgr:QueryHouseDetail(_G.HousingMgr.HouseID, Callback)
    elseif _G.HousingMgr.HouseID == _G.HousingMgr:GetArmyHouseID() then
        local IsPremission = _G.ArmyMgr:GetSelfIsHavePermisstion(ProtoRes.GroupPermissionType.PermissionTypeEstateFixtures)
        MainHouseListVM:SetDecorateIsVisible(IsPremission)
    end
end

function MainHouseListView:ShowDecorateView(Params)
    if not Params.Enable then
        MainHouseListVM.bToggleCheck = true
        MainHouseListVM:SetDecorateIsVisible(false)
        return
    end

    MainHouseListVM.bToggleCheck = false
    self:UpdateDecoratePrivilege()
end

function MainHouseListView:OnHouseMemberPrivilegeChangeNtf(Params)
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    if MajorRoleID == Params.RoommateID and _G.HousingMgr.HouseID == Params.HouseID then
        local DecorateBit = 1 << ProtoCS.HousePrivilgeType.HousePrivilgeType_EditDecorate
        local HasDecoratePrivilege = false
        if Params.Privileges & DecorateBit ~= 0 then
            HasDecoratePrivilege = true
        end
        MainHouseListVM:SetDecorateIsVisible(HasDecoratePrivilege)
    end
end

function MainHouseListView:OnHouseShareUpdate(Params)
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    if MajorRoleID == Params.RoommateID and _G.HousingMgr.HouseID == Params.HouseID then
        MainHouseListVM:SetDecorateIsVisible(false)
    end
end

function MainHouseListView:HouseBeDissolveRoomNtf(Params)
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    if MajorRoleID == Params.RoommateID and _G.HousingMgr.HouseID == Params.HouseID then
        MainHouseListVM:SetDecorateIsVisible(false)
    end
end

function MainHouseListView:OnHouseInviteReplyRsp(Params)
    if Params.Reply then
        if _G.HousingMgr.HouseID == Params.HouseID then
            self:UpdateDecoratePrivilege()
        end
    end
end

function MainHouseListView:OnArmySelfPermisstionToc()
    self:UpdateDecoratePrivilege()
end

return MainHouseListView