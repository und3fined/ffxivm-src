---
--- Author: Administrator
--- DateTime: 2024-11-28 11:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")

local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ReportDefine = require("Game/Report/ReportDefine")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ReportItemVM = require("Game/Report/View/Item/ReportItemVM")
local UIBindableList = require("UI/UIBindableList")

local LSTR = _G.LSTR

---@class ReportWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnReport CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field MultilineInputBox CommMultilineInputBoxView
---@field TableView_16 UTableView
---@field TextPlayerName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ReportWinView = LuaClass(UIView, true)

function ReportWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnReport = nil
	--self.Comm2FrameM_UIBP = nil
	--self.MultilineInputBox = nil
	--self.TableView_16 = nil
	--self.TextPlayerName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ReportWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnReport)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.MultilineInputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ReportWinView:OnInit()
	self.ReportList = UIBindableList.New(ReportItemVM)
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableView_16 )
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(780001))
end

function ReportWinView:OnDestroy()

end

function ReportWinView:OnShow()
	self.SelectReasonID = 0
	self.MultilineInputBox:SetMaxNum(50)
	self.BtnCancel:SetText(LSTR(780025))   -- "我再看看"
	self.BtnReport:SetText(LSTR(780024))   -- "马上举报"
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(780001))  --"举  报"
	self.MultilineInputBox:SetHintText(LSTR(780026))  --"可补充详细描述，50字以内（可不填）"
	self.MultilineInputBox:SetText("")
	local Params = self.Params
	self:ReportingMaterialsReview(Params)

	self.ClientReportScene = self.Params.ReportGroupType
	self.AssembledParams = self:AssemblyPlayerInfoParam(Params)
	self:AssemblyReportee(self.AssembledParams)
	self.ReportList:UpdateByValues(self.ClientReportScene.Reasons)
	self.AdapterTableView:UpdateAll(self.ReportList)
end

function ReportWinView:OnHide()

end

function ReportWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, 		self.OnClickButtonCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnReport, 		self.OnClickButtonReport)
end

function ReportWinView:OnRegisterGameEvent()

end

function ReportWinView:OnRegisterBinder()

end

function ReportWinView:SetSelectItemVm(ViewMode)
	if ViewMode == nil then
		return 
	end
	if self.SelectViewMode ~= nil and self.SelectViewMode ~= ViewMode then
		self.SelectViewMode.Selected = false
	end
	self.SelectViewMode = ViewMode
	self.SelectReasonID = ViewMode.Selected and ViewMode.ReasonsID or 0

	local Reason = ReportDefine.ReportReasons[self.SelectReasonID]
	if Reason and Reason.Text == LSTR(780006) then --"其他"
		self.MultilineInputBox:SetHintText(LSTR(780027))
	else
		self.MultilineInputBox:SetHintText(LSTR(780026))
	end
end

function ReportWinView:OnClickButtonCancel()
	self:Hide()
end

function ReportWinView:OnClickButtonReport()
	local Reason = ReportDefine.ReportReasons[self.SelectReasonID]
	if Reason == nil then
		MsgTipsUtil.ShowTips(LSTR(780010))  -- "请选择一项举报理由"
		return
	end
	if Reason.Text == LSTR(780006) then     --"其他"
		local Des = self.MultilineInputBox:GetText()
		if CommonUtil.GetStrLen(Des) <= 0 then
			MsgTipsUtil.ShowTips(LSTR(780028))  -- "请输入描述后再举报"
			return
		elseif CommonUtil.GetStrLen(Des) <= 10 then
			MsgTipsUtil.ShowTips(string.format(LSTR(780029), "10") )  -- "请输入%s个字以上描述"
			return
		end
	end

	_G.ReportMgr:PlayerReportReq(self:AssemblyReportSeasonParam(Reason))
	self:Hide()
end

function ReportWinView:ReportingMaterialsReview(Params)
	if Params == nil or MajorUtil.GetMajorRoleVM() == nil or Params.ReportGroupType == nil then
		MsgTipsUtil.ShowTipsByID(355001)    --"举报参数错误"
		self:Hide()
		return
	end

	if Params.ReportGroupType ~= ReportDefine.ReportScene.LinkShell then
		if (Params.ReporteeRoleID or 0) == 0 or _G.RoleInfoMgr:FindRoleVM(Params.ReporteeRoleID, true) == nil then 
			MsgTipsUtil.ShowTipsByID(355001)    --"举报参数错误"
			self:Hide()
			return
		end
	end
end

function ReportWinView:AssemblyPlayerInfoParam(Params)
	local AssembledParams = {}
	local ReporteeRoleVM = _G.RoleInfoMgr:FindRoleVM(Params.ReporteeRoleID, true) or {}
	local InformantRoleVM = MajorUtil.GetMajorRoleVM() or {}

	--必填
	AssembledParams.Reported = { OpenID = ReporteeRoleVM.OpenID, WorldID = ReporteeRoleVM.WorldID, RoleID = Params.ReporteeRoleID, RoleName = ReporteeRoleVM.Name }
	AssembledParams.Informant = { OpenID = InformantRoleVM.OpenID, WorldID = InformantRoleVM.WorldID, RoleID = MajorUtil.GetMajorRoleID(), RoleName = InformantRoleVM.Name }

	AssembledParams.ReportGroupID = tostring(Params.GroupID or "")
	AssembledParams.ReportGroupName = tostring(Params.GroupName or "")
	AssembledParams.PicUrlArray =  Params.PicUrlArray
	AssembledParams.VideoUrlArray =  Params.VideoUrlArray
	AssembledParams.VoiceUrlArray =  Params.VoiceUrlArray

	return AssembledParams
end

function ReportWinView:AssemblyReportee(AssembledParams)
	local ReportScene = self.ClientReportScene
	local TextPlayerName
	if ReportScene == ReportDefine.ReportScene.LinkShell then
		-- "举报对象：" 
		TextPlayerName = LSTR(780030) .. AssembledParams.ReportGroupName or ""
	else
		-- "举报玩家："
		TextPlayerName = LSTR(780003) .. (AssembledParams.Reported.RoleName or "")
	end
	self.TextPlayerName:SetText(TextPlayerName)
end

function ReportWinView:AssemblyReportSeasonParam(Reason)
	local ReportScene = self.ClientReportScene
	local ReasonsID = { Reason.ReasonID }
	local AssembledParams = self:AssemblyReportContent(Reason)
	AssembledParams.ReportCategory = math.floor(ReasonsID[1] / 100) 
	AssembledParams.ReportSeason = ReasonsID
	AssembledParams.ReportScene = ReportScene.SceneID
	AssembledParams.ReportEntrance = ReportScene.Entrance
	AssembledParams.ReportDesc = self.MultilineInputBox:GetText()
	return AssembledParams
end

function ReportWinView:AssemblyReportContent(Reason)
	local ReportScene = self.ClientReportScene
	local AssembledParams = self.AssembledParams
	local Params = self.Params or {}
	local ReportContentList = Params.ReportContentList or {}

	AssembledParams.ReportContent = Params.ReportContent or ""
	if ReportScene == ReportDefine.ReportScene.PersonalInfo then 
		if Reason == ReportDefine.ReportReasons[10] then
			AssembledParams.ReportContent = ReportContentList.Signature
		elseif Reason == ReportDefine.ReportReasons[11] then
			AssembledParams.ReportContent = ReportContentList.PetName
		end
		--有协议了补callback
	elseif ReportScene == ReportDefine.ReportScene.ArmyList then
		if Reason == ReportDefine.ReportReasons[13] then
			AssembledParams.ReportContent = ReportContentList.Abbreviation
		elseif Reason == ReportDefine.ReportReasons[15] then
			AssembledParams.ReportContent = ReportContentList.RecruitmentSlogan
		end
	elseif ReportScene == ReportDefine.ReportScene.ArmyInfo then 
		if Reason == ReportDefine.ReportReasons[13] then
			AssembledParams.ReportContent = ReportContentList.Abbreviation
		elseif Reason == ReportDefine.ReportReasons[14] then
			AssembledParams.ReportContent = ReportContentList.Announcement
		end
	elseif ReportScene == ReportDefine.ReportScene.LinkShell then 
		if Reason == ReportDefine.ReportReasons[16] then
			AssembledParams.ReportContent = ReportContentList.RecruitmentSlogan
		elseif Reason == ReportDefine.ReportReasons[14] then
			AssembledParams.ReportContent = ReportContentList.Announcement
		end
	elseif ReportScene == ReportDefine.ReportScene.Speech then
		--有协议了补callback
	end
	return AssembledParams
end

return ReportWinView