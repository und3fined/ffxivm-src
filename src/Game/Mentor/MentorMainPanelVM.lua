local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MentorConditionItemViewVM = require("Game/Mentor/MentorConditionItemViewVM")
local MentorDefine = require("Game/Mentor/MentorDefine")
local TimeUtil = require("Utils/TimeUtil")
local UIViewID = require("Define/UIViewID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local UIViewMgr 
local MentorMgr

---@class MentorMainPanelVM : UIViewModel
local MentorMainPanelVM = LuaClass(UIViewModel)

---Ctor
function MentorMainPanelVM:Ctor()
	self.ConditionsVMList = UIBindableList.New(MentorConditionItemViewVM)
	self.TextTitle = nil
	self.ImgMentorIcon = nil
	self.TextTips = nil
	self.ImgAttitude = nil
	self.ExpirationVisible = false 
	self.ExpirationDayNum = 0
end

function MentorMainPanelVM:OnInit()
end

function MentorMainPanelVM:OnBegin()
	UIViewMgr = _G.UIViewMgr
	MentorMgr = _G.MentorMgr
end

function MentorMainPanelVM:OnEnd()

end

function MentorMainPanelVM:OnShutdown()

end

---ShowMentorView
---@param List table<ID, Finish>
---@param ViewShowType ProtoCS.GuideType
function MentorMainPanelVM:ShowMentorView(MentorType, List)
	if nil == MentorType then
		return
	end

	local IsFinish = true
	local ConditionsVMParamsList = {}

	for i = 1, #List do
		if not List[i].Finish then
			IsFinish = false
		end
		table.insert(ConditionsVMParamsList, { TextId = List[i].ID, Finish = List[i].Finish })
	end

	if 0 == #ConditionsVMParamsList then
		IsFinish = false
	end

	self.ConditionsVMList:UpdateByValues(ConditionsVMParamsList)
	self:SetPenalData(IsFinish, MentorType)
end

function MentorMainPanelVM:SetPenalData(IsFinish, MentorType)
	local ShowResource = MentorDefine.FinishTabs[MentorType]

	if not IsFinish then
		ShowResource = MentorDefine.ProceedTabs[MentorType]
	end

	if table.empty(ShowResource) then
		return
	end

	if MentorMgr.ResignTime ~= nil then
		local AfterDay = math.floor((TimeUtil.GetServerTime() - MentorMgr.ResignTime) / 86400)
		self.ExpirationVisible = AfterDay < MentorMgr.ResignCD
		if self.ExpirationVisible then
			self.ExpirationDayNum = MentorMgr.ResignCD - AfterDay
		end
	end

	self.TextTitle = ShowResource.TextTitle
	self.ImgMentorIcon = ShowResource.ImgMentorIcon
	self.TextTips = ShowResource.TextTips
	self.ImgAttitude = ShowResource.ImgAttitude

	UIViewMgr:ShowView( UIViewID.MentorMainPanel, { IsConfirm = IsFinish, ShowType = MentorType, IsCD = self.ExpirationVisible } )
end

-- 播放指导者认证成功动销界面
function MentorMainPanelVM:OpenMentorUnlockTips(ShowType)
	if ShowType == 0 then return end
	local Params = { 
		IsMentorTrigger = true,
		SysNotice = MentorDefine.FinishTabs[ShowType].MentorTypeText,
		SubSysNotice = _G.LSTR(760025),
		Icon = MentorDefine.FinishTabs[ShowType].UnlockIcon or "",
		IconMask = MentorDefine.FinishTabs[ShowType].UnlockIconMask or "",
	}
	MsgTipsUtil.ShowMentorTips(Params)
end

--要返回当前类
return MentorMainPanelVM