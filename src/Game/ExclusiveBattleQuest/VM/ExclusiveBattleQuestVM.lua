local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local ExclusiveBattleQuestInfoVM = require ("Game/ExclusiveBattleQuest/VM/ExclusiveBattleQuestInfoVM")

local LSTR

---@class ExclusiveBattleQuestVM : UIViewModel
local ExclusiveBattleQuestVM = LuaClass(UIViewModel)

---Ctor
function ExclusiveBattleQuestVM:Ctor()
	self.InfoVM = nil
end

function ExclusiveBattleQuestVM:OnInit()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnInit函数
	--只初始化自身模块的数据，不能引用其他的同级模块
    self.InfoVM = ExclusiveBattleQuestInfoVM.New()
end

function ExclusiveBattleQuestVM:OnBegin()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnBegin函数
	--可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）

	--其他Mgr、全局对象 建议在OnBegin函数里初始化
	LSTR = _G.LSTR

	--为了实现国际化，除日志外的需要翻译的字符串要通过"LSTR"函数获取
	--富文本的标签不用翻译，建议用RichTextUtil中封装的接口获取。
end

function ExclusiveBattleQuestVM:OnEnd()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnEnd函数
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
end

function ExclusiveBattleQuestVM:OnShutdown()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnShutdown函数
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
end

function ExclusiveBattleQuestVM:ShowInfo(Data)
    if not self.InfoVM then
        self.InfoVM = ExclusiveBattleQuestInfoVM.New()
    end

    self.InfoVM:UpdateVM(Data)
end

return ExclusiveBattleQuestVM