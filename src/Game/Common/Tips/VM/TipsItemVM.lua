local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LSTR

---@class TipsItemVM : UIViewModel
local TipsItemVM = LuaClass(UIViewModel)

---Ctor
function TipsItemVM:Ctor()
	self.IsSelected = false
	self.IconVisible = false
	self.Icon = nil
	self.ArrowVisible = false
	self.TextName = nil
end

function TipsItemVM:OnInit()
    self.RichTextContent = ""
    self.RichTextTitle = ""
end

function TipsItemVM:OnBegin()
	LSTR = _G.LSTR
end

function TipsItemVM:OnEnd()
end

function TipsItemVM:OnShutdown()
end

function TipsItemVM:AdapterOnGetWidgetIndex()
	return self.WidgetIndex
end

function TipsItemVM:UpdateVM(Value)
	self.IsSelected = Value.IsSelected
	self.IconVisible = Value.Icon ~= nil and true or false
	self.Icon = Value.Icon ~= nil and Value.Icon or nil
	self.ArrowVisible = Value.ClickedGoBtn ~= nil and true or false
	self.TextName = Value.TextName
end

--要返回当前类
return TipsItemVM