--[[
Author: jususchen jususchen@tencent.com
Date: 2024-07-11 14:06:24
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-11 14:57:49
FilePath: \Script\Game\PWorld\Item\PWorldVoteExpelItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")

---@class PWorldVoteExpelItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field ImgBar_1 UFImage
---@field ImgJob UFImage
---@field ImgSelect UFImage
---@field PanelExpelItem UFCanvasPanel
---@field TextPlayerNaer UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldVoteExpelItemView = LuaClass(UIView, true)

function PWorldVoteExpelItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.ImgBar_1 = nil
	--self.ImgJob = nil
	--self.ImgSelect = nil
	--self.PanelExpelItem = nil
	--self.TextPlayerNaer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldVoteExpelItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldVoteExpelItemView:OnInit()
	self.RoleBinders = {
		{ "Prof",	UIBinderSetProfIcon.New(self, self.ImgJob) },
		{ "Name",	UIBinderSetText.New(self, self.TextPlayerNaer) },
    }
	self.Binders = {
        { "Selected",	UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "Opacity",	UIBinderSetRenderOpacity.New(self, self.PanelExpelItem) },
    }
end

function PWorldVoteExpelItemView:OnDestroy()

end

function PWorldVoteExpelItemView:OnShow()

end

function PWorldVoteExpelItemView:OnHide()

end

function PWorldVoteExpelItemView:OnRegisterUIEvent()

end

function PWorldVoteExpelItemView:OnRegisterGameEvent()

end

function PWorldVoteExpelItemView:OnRegisterBinder()
	-- local Params = self.Params
    -- if not Params then
    --     return
    -- end

    -- self.VM = Params.Data
    -- if not self.VM then
    --     return
    -- end

    -- self:RegisterBinders(_G.RoleInfoMgr:FindRoleVM(self.VM.MemRoleID), self.RoleBinders)
    -- self:RegisterBinders(self.VM, self.Binders)
end

function PWorldVoteExpelItemView:OnSelectChanged(IsSelected)
	-- if self.VM then
	-- 	self.VMSetSelected(IsSelected)
	-- end
end

return PWorldVoteExpelItemView