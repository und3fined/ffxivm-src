--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-04 17:47:38
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-13 15:30:13
FilePath: \Script\Game\House\View\Item\HouseInfoHomeownerItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: muyanli
--- DateTime: 2025-06-06 11:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")

---@class HouseInfoHomeownerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommHead CommHeadView
---@field ImgArmy UFImage
---@field ImgHeadBG UFImage
---@field TextName UFTextBlock
---@field TextTittle UFTextBlock
---@field HeadBG SlateBrush
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoHomeownerItemView = LuaClass(UIView, true)

function HouseInfoHomeownerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommHead = nil
	--self.ImgArmy = nil
	--self.ImgHeadBG = nil
	--self.TextName = nil
	--self.TextTittle = nil
	--self.HeadBG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoHomeownerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommHead)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoHomeownerItemView:OnInit()

end

function HouseInfoHomeownerItemView:OnDestroy()

end

function HouseInfoHomeownerItemView:OnShow()

end

function HouseInfoHomeownerItemView:OnHide()

end

function HouseInfoHomeownerItemView:OnRegisterUIEvent()

end

function HouseInfoHomeownerItemView:OnRegisterGameEvent()

end

function HouseInfoHomeownerItemView:OnRegisterBinder()

end

function HouseInfoHomeownerItemView:SetArmy(ArmyName, TotemIconPath, EmblemIconPath, ColorHex)
    self.TextName:SetText(ArmyName)
    UIUtil.SetIsVisible(self.ImgArmy, true)
    UIUtil.ImageSetBrushFromAssetPath(self.CommHead.ImageIcon, TotemIconPath)
    UIUtil.SetIsVisible(self.CommHead.ImgFrame, false)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgArmy, EmblemIconPath)
    UIUtil.ImageSetBrushTintColorHex(self.ImgArmy, ColorHex)
end

function HouseInfoHomeownerItemView:UpdateView(OwnerName, RoleID, Tittle)
	self.OwnerID = RoleID
	self.TextTittle:SetText(Tittle)
    if RoleID then
        self:SetRoleInfo(RoleID)
    end
end

function HouseInfoHomeownerItemView:SetRoleInfo(RoleID)
    RoleInfoMgr:QueryRoleSimple(RoleID, function()
        local RoleVM, IsValid = RoleInfoMgr:FindRoleVM(RoleID, true)
        if RoleVM and self.OwnerID == RoleID then
            self.TextName:SetText(RoleVM.Name)
			self.CommHead:SetInfo(RoleID)
        end
    end, nil, true)
end

return HouseInfoHomeownerItemView