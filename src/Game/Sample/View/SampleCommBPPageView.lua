---
--- Author: anypkvcai
--- DateTime: 2023-03-30 21:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local FLOG_INFO = _G.FLOG_INFO

---@class SampleCommBPPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBtnHiden CommBtnSView
---@field CommBtnL CommBtnLView
---@field CommBtnLLongPress CommBtnLView
---@field CommBtnM CommBtnMView
---@field CommBtnS CommBtnSView
---@field CommBtnShow CommBtnSView
---@field CommBtnXL CommBtnXLView
---@field CommBtnXL2 CommBtnXLView
---@field CommDropDownList CommDropDownListView
---@field CommDropDownList2 CommDropDownListView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SampleCommBPPageView = LuaClass(UIView, true)

function SampleCommBPPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBtnHiden = nil
	--self.CommBtnL = nil
	--self.CommBtnLLongPress = nil
	--self.CommBtnM = nil
	--self.CommBtnS = nil
	--self.CommBtnShow = nil
	--self.CommBtnXL = nil
	--self.CommBtnXL2 = nil
	--self.CommDropDownList = nil
	--self.CommDropDownList2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SampleCommBPPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtnHiden)
	self:AddSubView(self.CommBtnL)
	self:AddSubView(self.CommBtnLLongPress)
	self:AddSubView(self.CommBtnM)
	self:AddSubView(self.CommBtnS)
	self:AddSubView(self.CommBtnShow)
	self:AddSubView(self.CommBtnXL)
	self:AddSubView(self.CommBtnXL2)
	self:AddSubView(self.CommDropDownList)
	self:AddSubView(self.CommDropDownList2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SampleCommBPPageView:OnInit()
	self.CommBtnXL2:SetIsEnabled(false)
end

function SampleCommBPPageView:OnDestroy()

end

function SampleCommBPPageView:OnShow()
	-- 只显示文字
	local ListData = { { Name = "Item1" }, { Name = "Item2" }, { Name = "Item3" }, { Name = "Item4" } }
	self.CommDropDownList:UpdateItems(ListData, 2)

	-- 显示图标和文字
	local IconPath = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Tree_Icon_Other2_png.UI_Comm_Tree_Icon_Other2_png'"
	local ListData2 = { { Name = "Item1", IconPath = IconPath }, { Name = "Item2", IconPath = IconPath }, { Name = "Item3", IconPath = IconPath }, { Name = "Item4", IconPath = IconPath } }
	self.CommDropDownList2:UpdateItems(ListData2, 3)
end

function SampleCommBPPageView:OnHide()

end

function SampleCommBPPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnL, self.OnClickCommBtnL)
	UIUtil.AddOnClickedEvent(self, self.CommBtnM, self.OnClickCommBtnM)
	UIUtil.AddOnClickedEvent(self, self.CommBtnS, self.OnClickCommBtnS)
	UIUtil.AddOnClickedEvent(self, self.CommBtnXL, self.OnClickCommBtnXL)

	UIUtil.AddOnClickedEvent(self, self.CommBtnShow, self.OnClickCommBtnShow)
	UIUtil.AddOnClickedEvent(self, self.CommBtnHiden, self.OnClickCommBtnHiden)

	UIUtil.AddOnLongPressedEvent(self, self.CommBtnLLongPress, self.OnLongPressedBtnL)

	UIUtil.AddOnSelectionChangedEvent(self, self.CommDropDownList, self.OnSelectionChangedDropDownList)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommDropDownList2, self.OnSelectionChangedDropDownList2)
end

function SampleCommBPPageView:OnRegisterGameEvent()

end

function SampleCommBPPageView:OnRegisterBinder()

end

function SampleCommBPPageView:OnClickCommBtnL()
	FLOG_INFO("OnClickCommBtnL")
end

function SampleCommBPPageView:OnClickCommBtnM()
	FLOG_INFO("OnClickCommBtnM")
end

function SampleCommBPPageView:OnClickCommBtnS()
	FLOG_INFO("OnClickCommBtnS")
end

function SampleCommBPPageView:OnClickCommBtnXL()
	FLOG_INFO("OnClickCommBtnXL")
end

function SampleCommBPPageView:OnLongPressedBtnL()
	FLOG_INFO("OnLongPressedBtnL")
end

function SampleCommBPPageView:OnSelectionChangedDropDownList(Index)
	FLOG_INFO("OnSelectionChangedDropDownList Index=%d ", Index)
end

function SampleCommBPPageView:OnSelectionChangedDropDownList2(Index)
	FLOG_INFO("OnSelectionChangedDropDownList2 Index=%d", Index)
end

function SampleCommBPPageView:OnClickCommBtnShow()
	UIUtil.SetIsVisible(self.CommDropDownList, true)
end

function SampleCommBPPageView:OnClickCommBtnHiden()
	UIUtil.SetIsVisible(self.CommDropDownList, false)
end

return SampleCommBPPageView