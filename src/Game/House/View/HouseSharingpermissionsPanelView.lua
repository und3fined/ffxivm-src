--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-04 17:47:38
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-09-08 16:25:52
FilePath: \Script\Game\House\View\HouseSharingpermissionsPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MathUtil = require("Utils/MathUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")

---@class HouseSharingpermissionsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextHint UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseSharingpermissionsPanelView = LuaClass(UIView, true)

function HouseSharingpermissionsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextHint = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseSharingpermissionsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseSharingpermissionsPanelView:OnInit()
    self.TextTitle:SetText(HouseLocalDef.SharingPermissionTittle)
end

function HouseSharingpermissionsPanelView:OnDestroy()

end

function HouseSharingpermissionsPanelView:OnShow()
    local PermissionData = _G.HouseInfoMgr:GetHouseRoomatesPermission()
    if _G.HouseInfoMgr.Roommates and #_G.HouseInfoMgr.Roommates > 0 then
        self.Privilege = _G.HouseInfoMgr.Roommates[1].Privileges            --室友已排序 第一位为主角
    else
        FLOG_INFO("[HouseSharingpermissionsPanelView] RoommatesInitError")
        return
    end

    local PrivilegeTable =  MathUtil.DecodeUint(self.Privilege)
    local PrivilegeShowStr = ""
    for i, v in ipairs(PrivilegeTable) do
        if i == #PrivilegeTable then
            PrivilegeShowStr = PrivilegeShowStr .. PermissionData[v].PrivilegeName
        else
            PrivilegeShowStr = PrivilegeShowStr .. PermissionData[v].PrivilegeName .. "，"
        end
    end
    self.TextHint:SetText(PrivilegeShowStr)
end

function HouseSharingpermissionsPanelView:OnHide()

end

function HouseSharingpermissionsPanelView:OnRegisterUIEvent()

end

function HouseSharingpermissionsPanelView:OnRegisterGameEvent()

end

function HouseSharingpermissionsPanelView:OnRegisterBinder()

end

return HouseSharingpermissionsPanelView