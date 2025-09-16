
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local ScoreCfg = require("TableCfg/ScoreCfg")

---@class CurrencyConvertItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CurrencyConvertItemView = LuaClass(UIView, true)

function CurrencyConvertItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CurrencyConvertItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CurrencyConvertItemView:OnInit()

end

function CurrencyConvertItemView:OnDestroy()

end

function CurrencyConvertItemView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local Data = Params.Data
	if Data == nil then
		return
	end
	-- local SourceID = Data.SourceID
	-- local SourceValue = Data.SourceValue
	-- local DestID = Data.DestID
	-- local DestValue = Data.DestValue

	-- local SourceCfg = ScoreCfg:FindCfgByKey(SourceID)
	-- local DestCfg = ScoreCfg:FindCfgByKey(DestID)
	-- local TextDec = string.format("%d%s%s%s%d%s%s", SourceValue, SourceCfg.NameText, LSTR(1050057), "<span color=\"#d1ba8eFF\">", DestValue, "</>", DestCfg.NameText)
	self.RichTextContent:SetText(Data.TextDes)
end

function CurrencyConvertItemView:OnHide()
end

function CurrencyConvertItemView:OnRegisterUIEvent()

end

function CurrencyConvertItemView:OnRegisterGameEvent()

end

function CurrencyConvertItemView:OnRegisterBinder()

end

return CurrencyConvertItemView