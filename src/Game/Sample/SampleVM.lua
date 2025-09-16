--
-- Author: anypkvcai
-- Date: 2022-09-19 14:50
-- Description:
--

--全局的ViewModel需要在UIViewModelConfig中配置, 具体说明参考下面wiki
--https://iwiki.woa.com/pages/viewpage.action?pageId=1066338863


--ViewModel是用来存储UI需要显示的数据，尽量不要处理和UI显示无关的逻辑。
--ViewModel中数据变化时，会调用绑定Binder的OnValueChanged函数来更新UI。
--UIViewModel所有成员变量都会创建为UIBindableProperty，所以UIViewModel不应该包含非UI要显示的属性。
--UIViewModel包含一个BindableProperties列表，Key值是PropertyName，Value值是UIBindableProperty
--使用类变量时和普通变量一样使用，UIViewModel会自动创建UIBindableProperty
--更多UIViewModel介绍请参考下面wiki
--https://iwiki.woa.com/pages/viewpage.action?pageId=858296043

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local SampleTableViewItemVM = require("Game/Sample/VM/SampleTableViewItemVM")

local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender

local LSTR

---@class SampleVM : UIViewModel
local SampleVM = LuaClass(UIViewModel)

---Ctor
function SampleVM:Ctor()
	self.LocalString = nil
	self.TextColor = nil
	self.ProfID = nil
	self.GenderID = nil
	self.IsVisible = nil
end

function SampleVM:OnInit()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnInit函数
	--只初始化自身模块的数据，不能引用其他的同级模块
end

function SampleVM:OnBegin()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnBegin函数
	--可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）

	--其他Mgr、全局对象 建议在OnBegin函数里初始化
	LSTR = _G.LSTR

	--为了实现国际化，除日志外的需要翻译的字符串要通过"LSTR"函数获取
	--富文本的标签不用翻译，建议用RichTextUtil中封装的接口获取。
	self.LocalString = LSTR("中文")
	self.TextColor = "ff0000ff"
	self.ProfID = ProfType.PROF_TYPE_PALADIN
	self.GenderID = RoleGender.GENDER_FEMALE
	self.IsVisible = false

	self.TableViewData = UIBindableList.New(SampleTableViewItemVM)
end

function SampleVM:OnEnd()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnEnd函数
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
end

function SampleVM:OnShutdown()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnShutdown函数
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
end

function SampleVM:UpdateTableViewData(Data)
	self.TableViewData:UpdateByValues(Data, nil, true)
end

--要返回当前类
return SampleVM