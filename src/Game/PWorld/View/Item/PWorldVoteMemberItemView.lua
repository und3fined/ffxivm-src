--[[
Author: jususchen jususchen@tencent.com
Date: 2024-07-12 10:12:26
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-08-15 11:42:50
FilePath: \Script\Game\PWorld\View\Item\PWorldVoteMemberItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetProfIcon   = require("Binder/UIBinderSetProfIcon")
local UIBinderSetText       = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible  = require("Binder/UIBinderSetIsVisible")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PWorldVoteMemberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field ImgBar_1 UFImage
---@field ImgJob UFImage
---@field ImgSelect UFImage
---@field PanelExpelItem UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---@field TextPlayerNaer UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimSelectIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldVoteMemberItemView = LuaClass(UIView, true)

function PWorldVoteMemberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.ImgBar_1 = nil
	--self.ImgJob = nil
	--self.ImgSelect = nil
	--self.PanelExpelItem = nil
	--self.PanelSelect = nil
	--self.TextPlayerNaer = nil
	--self.AnimIn = nil
	--self.AnimSelectIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldVoteMemberItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldVoteMemberItemView:OnInit()
	self.RoleBinders = {
		-- { "Prof", UIBinderSetProfIcon.New(self, self.ImgJob) },
		{ "Name", UIBinderSetText.New(self, self.TextPlayerNaer) },
    }

    self.Binders = {
        { "Selected",                   UIBinderSetIsVisible.New(self, self.PanelSelect) },
        { "Selected",                   UIBinderValueChangedCallback.New(self, nil, function (_, V)
            if V then
                self:PlayAnimation(self.AnimSelectIn)
            end
        end) },
		{ "Opacity",                    UIBinderSetRenderOpacity.New(self, self.PanelExpelItem) },
        { "Prof", UIBinderSetProfIcon.New(self, self.ImgJob) },
    }
end

function PWorldVoteMemberItemView:OnRegisterGameEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnClickButtonItem)
end

function PWorldVoteMemberItemView:OnRegisterBinder()
	self.VM = self.Params and self.Params.Data or nil
    if not self.VM then
        return
    end

    self:RegisterBinders(_G.RoleInfoMgr:FindRoleVM(self.VM.MemRoleID), self.RoleBinders)
    self:RegisterBinders(self.VM, self.Binders)
end

function PWorldVoteMemberItemView:OnClickButtonItem()
    if self.VM then
        if self.VM.MVPVoteEnable == false then
            return
        end
    end

    local Adapter = self.Params and self.Params.Adapter or nil
    if nil == Adapter then
        return
    end

    Adapter:SetSelectedIndex(self.Params.Index)
end

function PWorldVoteMemberItemView:OnSelectChanged(IsSelected)
    if not self.VM then
        return
    end

    self.VM:SetSelected(IsSelected)
end

return PWorldVoteMemberItemView