---
--- Author: Administrator
--- DateTime: 2023-11-21 20:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CardsRewardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field CardsNumber CardsNumberItemView
---@field ImgCardBG UFImage
---@field ImgFrame UFImage
---@field ImgFrame_Silver UFImage
---@field ImgIcon UFImage
---@field ImgRace UFImage
---@field ImgStar UFImage
---@field PanelCard UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field TextCardName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsRewardItemView = LuaClass(UIView, true)

function CardsRewardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.CardsNumber = nil
	--self.ImgCardBG = nil
	--self.ImgFrame = nil
	--self.ImgFrame_Silver = nil
	--self.ImgIcon = nil
	--self.ImgRace = nil
	--self.ImgStar = nil
	--self.PanelCard = nil
	--self.PanelContent = nil
	--self.TextCardName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsRewardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CardsNumber)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsRewardItemView:OnInit()

end

function CardsRewardItemView:OnDestroy()

end

function CardsRewardItemView:OnShow()

end

function CardsRewardItemView:OnHide()

end

function CardsRewardItemView:OnRegisterUIEvent()

end

function CardsRewardItemView:OnRegisterGameEvent()

end

function CardsRewardItemView:OnRegisterBinder()

end

return CardsRewardItemView