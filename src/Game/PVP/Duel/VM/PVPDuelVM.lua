local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local PVPDuelRoleVM = require("Game/PVP/Duel/VM/PVPDuelRoleVM")

---@class PVPDuelVM : UIViewModel
local PVPDuelVM = LuaClass(UIViewModel)

---Ctor
function PVPDuelVM:Ctor()

end

function PVPDuelVM:OnInit()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnInit函数
	--只初始化自身模块的数据，不能引用其他的同级模块
	self:ResetData()
end

function PVPDuelVM:OnBegin()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnBegin函数
	--可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）

	--其他Mgr、全局对象 建议在OnBegin函数里初始化

	--为了实现国际化，除日志外的需要翻译的字符串要通过"LSTR"函数获取
	--富文本的标签不用翻译，建议用RichTextUtil中封装的接口获取。
	-- self.LocalString = LSTR("中文")
	-- self.TextColor = "ff0000ff"
	-- self.ProfID = ProfType.PROF_TYPE_PALADIN
end

function PVPDuelVM:OnEnd()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnEnd函数
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
end

function PVPDuelVM:OnShutdown()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnShutdown函数
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
	self:ResetData()
end

function PVPDuelVM:ResetData()
	self.IsInviteDuel = nil
	self:SetNoCheckValueChange("IsInviteDuel", true)
	self.Inviter = PVPDuelRoleVM.New()
	self.Target = PVPDuelRoleVM.New()
	self.InviteTime = 0
	self.RemainTime = 0
end

function PVPDuelVM:SetInviteData(Data)
	self.IsInviteDuel = true
	local InviterID = MajorUtil.GetMajorRoleID()
	local TargetID = Data.TgtID
	self.Inviter:UpdateVM({ RoleID = InviterID })
	self.Target:UpdateVM({ RoleID = TargetID })
	self.InviteTime = math.floor(Data.InviteTime / 1000)
	local IniteTimeoutTime = _G.WolvesDenPierMgr:GetInviteTimeoutTime()
	self.RemainTime = IniteTimeoutTime - (TimeUtil.GetServerLogicTime() - self.InviteTime)
end

function PVPDuelVM:SetReceiveInviteData(Data)
	self.IsInviteDuel = false
	local InviterID = Data.RoleID
	local TargetID = MajorUtil.GetMajorRoleID()
	self.Inviter:UpdateVM({ RoleID = InviterID })
	self.Target:UpdateVM({ RoleID = TargetID })
	self.InviteTime = math.floor(Data.InviteTime / 1000)
	local IniteTimeoutTime = _G.WolvesDenPierMgr:GetInviteTimeoutTime()
	self.RemainTime = IniteTimeoutTime - (TimeUtil.GetServerLogicTime() - self.InviteTime)
end

function PVPDuelVM:SetRemainTime(Time)
	self.RemainTime = Time
end

function PVPDuelVM:GetInviter()
	return self.Inviter
end

function PVPDuelVM:GetTarget()
	return self.Target
end

function PVPDuelVM:GetInviterID()
	return self.Inviter and self.Inviter.RoleID or 0
end

function PVPDuelVM:GetTargetID()
	return self.Target and self.Target.RoleID or 0
end

--要返回当前类
return PVPDuelVM