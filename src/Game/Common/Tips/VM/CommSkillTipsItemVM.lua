local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")



---@class CommSkillTipsItemVM : UIViewModel
local CommSkillTipsItemVM = LuaClass(UIViewModel)


function CommSkillTipsItemVM:Ctor()
	self.Type = 0
	self.TextLeft = ""
	self.TextRight = ""
	self.RichTextContent = ""
end
 
function CommSkillTipsItemVM:OnInit()
end

function CommSkillTipsItemVM:OnBegin()
end

function CommSkillTipsItemVM:OnEnd()
end 

function CommSkillTipsItemVM:OnShutdown()
end

function CommSkillTipsItemVM:UpdateVM(Params)
	self.Type = Params.Type
	self.TextLeft = Params.TextLeft
	self.TextRight = Params.TextRight
	self.RichTextContent = Params.Text
end

function CommSkillTipsItemVM:IsEqualVM(Value)
	return self.Type == Value.Type
end

function CommSkillTipsItemVM:AdapterOnGetWidgetIndex()
	return self.Type
end

return CommSkillTipsItemVM