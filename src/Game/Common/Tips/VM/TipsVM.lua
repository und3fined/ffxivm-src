local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local LSTR

---@class TipsVM : UIViewModel
local TipsVM = LuaClass(UIViewModel)

---Ctor
function TipsVM:Ctor()
	self.TextName = nil		--标题
	self.Content = nil		--内容
	self.DataList = UIBindableList.New()
	self.ResID = nil
end

function TipsVM:OnInit()
end

function TipsVM:OnBegin()
	LSTR = _G.LSTR
end

function TipsVM:OnEnd()
end

function TipsVM:OnShutdown()
end

function TipsVM:UpdateVM(VM)
	self.DataList = VM.DataList
	self.DataList2 = VM.DataList2
	self.TextName = VM.TextName
	self.Content = VM.Content
end

--要返回当前类
return TipsVM