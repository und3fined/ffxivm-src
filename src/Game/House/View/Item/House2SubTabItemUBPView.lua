
local CommMenuChildItemView = require("Game/Common/Menu/CommMenuChildItemView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class House2SubTabItemUBPView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconLock UFImage
---@field ImgSelect UFImage
---@field RedDot CommonRedDotView
---@field TextSubTab UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local House2SubTabItemUBPView = LuaClass(CommMenuChildItemView, true)

function House2SubTabItemUBPView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconLock = nil
	--self.ImgSelect = nil
	--self.RedDot = nil
	--self.TextSubTab = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function House2SubTabItemUBPView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function House2SubTabItemUBPView:OnInit()
    self.IsSelected = nil
    self.Binders = {
        {"Name", UIBinderSetText.New(self, self.TextSubTab)},
    }
end

function House2SubTabItemUBPView:RefreshShowColor()
	local Params = self.Params
	if nil == Params then return end

    local LinearColor
    if self.IsSelected then
        LinearColor = _G.UE.FLinearColor.FromHex("5A4224")
    else
        LinearColor = _G.UE.FLinearColor.FromHex("878075")
    end

    if LinearColor then
        self.TextSubTab:SetColorAndOpacity(LinearColor)
    end
end

function House2SubTabItemUBPView:InitTab(Params)
end

function House2SubTabItemUBPView:SetReddotShowByData(Data)
	if Data.RedDotID then
		self.RedDot:SetRedDotIDByID(Data.RedDotID)
	end
end

function House2SubTabItemUBPView:UpdateItem(Data)
	if nil == Data then return end
	self:SetReddotShowByData(Data)
	
	UIUtil.SetIsVisible(self.IconLock, not Data.IsUnLock)
end

return House2SubTabItemUBPView