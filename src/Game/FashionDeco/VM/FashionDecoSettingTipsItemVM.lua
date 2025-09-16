---
--- Author: ccppeng
--- DateTime: 2024-10-29 10:32
--- Description:时尚配饰主面板 设置选择每一个条目
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local FashionDecoMgr = require("Game/FashionDeco/FashionDecoMgr")
local LSTR = _G.LSTR
---@class FashionDecoSettingTipsItemVM : UIViewModel
local FashionDecoSettingTipsItemVM = LuaClass(UIViewModel)

function FashionDecoSettingTipsItemVM:Ctor()
    self.bSelect = false
    self.Title = nil
    self.TitleColor = nil
    self.Index = nil
    self.bEditAble = false
    self.bIsClickMaskVisible = false
    self.bFirstSet = true
end

function FashionDecoSettingTipsItemVM:IsAutoUse()
    local result = self.ParentViewModel:IsAutoUse()
    return result or (not result and self.FashionDecorateAutoUseChooseType == FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLast)
end

function FashionDecoSettingTipsItemVM:CanClick()
    return self.ParentViewModel:IsAutoUse()
end

function FashionDecoSettingTipsItemVM:ProcessClickFailed()
    if self.bFirstSet == false then
        _G.MsgTipsUtil.ShowTips(LSTR(1030003))    --请先开启雨天自动穿戴
    else
        self.bFirstSet = false
    end
    
end

function FashionDecoSettingTipsItemVM:SetSelect(InSelect)
    if InSelect and self.FashionDecorateAutoUseChooseType == FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLike then
        if not FashionDecoMgr:CheckHasCollect() then
            _G.MsgTipsUtil.ShowTips(LSTR(1030004))--请先设置收藏手持配饰
            self.bSelect = false
            if self.bIsClickMaskVisible then
                self.TitleColor = "8c8c8c"
            else
                self.TitleColor = self.bSelect and "C9C08FFF" or "AFAFAFFF"
            end

            return self.bSelect;
        end
    end
    self.bSelect = InSelect

    if self.bIsClickMaskVisible then
        self.TitleColor = "8c8c8c"
    else
        self.TitleColor = self.bSelect and "C9C08FFF" or "AFAFAFFF"
    end

    return self.bSelect;
end

function FashionDecoSettingTipsItemVM:GetSelectedState()
    return self.bSelect;
end
function FashionDecoSettingTipsItemVM:OnSelectedItem()

    self.ParentViewModel:OnSelected(self.FashionDecorateAutoUseChooseType)
end

return FashionDecoSettingTipsItemVM