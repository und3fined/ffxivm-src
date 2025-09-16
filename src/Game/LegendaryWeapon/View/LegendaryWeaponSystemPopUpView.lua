
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LegendaryWeaponSystemPopUpView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TextContent UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponSystemPopUpView = LuaClass(UIView, true)

function LegendaryWeaponSystemPopUpView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TextContent = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponSystemPopUpView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponSystemPopUpView:OnInit()

end

function LegendaryWeaponSystemPopUpView:OnDestroy()
	
end

function LegendaryWeaponSystemPopUpView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, Params.Icon)
	local SysNotice = Params.SysNotice
	local Tittle = string.split(SysNotice, "&")[1] or ""
	local Content = string.split(SysNotice, "&")[2] or ""
	self.TextTitle:SetText(Tittle)
	self.TextContent:SetText(Content)
	self:RegisterTimer(function()
		if self.Params == nil then
			return
		end
		self:Hide()
	 end, 3.8)
end

function LegendaryWeaponSystemPopUpView:OnHide()

end

function LegendaryWeaponSystemPopUpView:OnRegisterUIEvent()

end

function LegendaryWeaponSystemPopUpView:OnRegisterGameEvent()

end

function LegendaryWeaponSystemPopUpView:OnRegisterBinder()

end

return LegendaryWeaponSystemPopUpView