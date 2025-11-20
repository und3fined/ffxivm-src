---
--- Author: zerodeng
--- DateTime: 2025-05-29 16:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local AdventureCompletionItem02View = require("Game/Adventure/AdventureItem/AdventureCompletionItem02View")


---@class WorldExploraAdventureItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGet CommBtnSView
---@field BtnGo CommBtnSView
---@field ImgTextIcon UFImage
---@field PanelUnFinishAlreadyGet UFCanvasPanel
---@field RedDot CommonRedDot2View
---@field RichTextDescription URichTextBox
---@field SpacerMainPanel USpacer
---@field TableViewReward UTableView
---@field TextContent UFTextBlock
---@field TextUnFinishAlreadyGet UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraAdventureItemView = LuaClass(AdventureCompletionItem02View, true)

function WorldExploraAdventureItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGet = nil
	--self.BtnGo = nil
	--self.ImgTextIcon = nil
	--self.PanelUnFinishAlreadyGet = nil
	--self.RedDot = nil
	--self.RichTextDescription = nil
	--self.SpacerMainPanel = nil
	--self.TableViewReward = nil
	--self.TextContent = nil
	--self.TextUnFinishAlreadyGet = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraAdventureItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGet)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

return WorldExploraAdventureItemView