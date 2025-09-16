---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginNewAllSeverItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextSever UFTextBlock
---@field SelectFontSize int
---@field NormalFontSize int
---@field SelectColor string
---@field NormalColor string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewAllSeverItemView = LuaClass(UIView, true)

function LoginNewAllSeverItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextSever = nil
	--self.SelectFontSize = nil
	--self.NormalFontSize = nil
	--self.SelectColor = nil
	--self.NormalColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewAllSeverItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewAllSeverItemView:OnInit()

end

function LoginNewAllSeverItemView:OnDestroy()

end

function LoginNewAllSeverItemView:OnShow()
    local Params = self.Params
    if nil == Params then return end

    ---@type ServerGroupItemVM
    local ServerGroupItemVM = Params.Data
    if nil == ServerGroupItemVM then return end

    self.TextSever:SetText(ServerGroupItemVM.Name)
end

function LoginNewAllSeverItemView:OnHide()

end

function LoginNewAllSeverItemView:OnRegisterUIEvent()

end

function LoginNewAllSeverItemView:OnRegisterGameEvent()

end

function LoginNewAllSeverItemView:OnRegisterBinder()

end

function LoginNewAllSeverItemView:OnSelectChanged(IsSelected)
    --_G.FLOG_INFO("[LoginNewAllSeverItemView:OnSelectChanged] %s IsSelected:%s", self.TextSever:GetText(), IsSelected and "Ture" or "false")
    --UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
    if IsSelected then
        self:StopAnimation(self.AnimUnchecked)
        self:PlayAnimation(self.AnimChecked)
    else
        self:StopAnimation(self.AnimChecked)
        self:PlayAnimation(self.AnimUnchecked)
    end

    if IsSelected then
        UIUtil.TextBlockSetFontSize(self.TextSever, self.SelectFontSize)
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextSever, self.SelectColor)
    else
        UIUtil.TextBlockSetFontSize(self.TextSever, self.NormalFontSize)
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextSever, self.NormalColor)
    end
end

return LoginNewAllSeverItemView