---
--- Author: xingcaicao
--- DateTime: 2024-12-04 20:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
local TeamRecruitCfg = require("TableCfg/TeamRecruitCfg")
local TeamRecruitTypeCfg = require("TableCfg/TeamRecruitTypeCfg")

---@class ChatMsgTeamRecruitItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgBanner UFImage
---@field ImgIcon UFImage
---@field ImgStarTagLeft UFImage
---@field ImgStarTagRight UFImage
---@field ImgTaskLimit UFImage
---@field TableViewProf UTableView
---@field TextDesc UFTextBlock
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatMsgTeamRecruitItemView = LuaClass(UIView, true)

function ChatMsgTeamRecruitItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgBanner = nil
	--self.ImgIcon = nil
	--self.ImgStarTagLeft = nil
	--self.ImgStarTagRight = nil
	--self.ImgTaskLimit = nil
	--self.TableViewProf = nil
	--self.TextDesc = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatMsgTeamRecruitItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatMsgTeamRecruitItemView:OnInit()
	self.TableAdapterProf = UIAdapterTableView.CreateAdapter(self, self.TableViewProf)
end

function ChatMsgTeamRecruitItemView:OnDestroy()

end

function ChatMsgTeamRecruitItemView:OnShow()

end

function ChatMsgTeamRecruitItemView:OnHide()
	self.RecruitID = nil 
	self.TableAdapterProf:ReleaseAllItem(true)
end

function ChatMsgTeamRecruitItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickButtonClick)
end

function ChatMsgTeamRecruitItemView:OnRegisterGameEvent()

end

function ChatMsgTeamRecruitItemView:OnRegisterBinder()

end

---@param Data cschatc.TeamRecruitMessage @队伍招募超链接数据信息
---@param IsMajor boolean @是否为主角发送的消息
function ChatMsgTeamRecruitItemView:RefreshUI(Data, IsMajor)
	if nil == Data then
		self.RecruitID = nil 
		return
	end

	self.RecruitID = Data.ID

	-- 方向图标
	UIUtil.SetIsVisible(self.ImgStarTagLeft, not IsMajor)
	UIUtil.SetIsVisible(self.ImgStarTagRight, IsMajor)

	-- 任务设置
	local ImgTaskLimit = self.ImgTaskLimit
	local TaskLimitIcon = TeamRecruitUtil.GetTaskLimitIcon(Data.TaskLimit)
	if string.isnilorempty(TaskLimitIcon) then
		UIUtil.SetIsVisible(ImgTaskLimit, false)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.ImgTaskLimit, TaskLimitIcon)
		UIUtil.SetIsVisible(ImgTaskLimit, true)
	end

	-- 招募信息
	local Cfg = TeamRecruitCfg:FindCfgByKey(Data.ResID)
	if Cfg then
        local TypeInfo = TeamRecruitTypeCfg:GetRecruitTypeInfo(Cfg.TypeID)
		if TypeInfo then
			-- 招募类型Icon
			UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, TypeInfo.Icon)

			-- Banner图
			UIUtil.ImageSetBrushFromAssetPath(self.ImgBanner, TypeInfo.ChatBanner)

			-- 副本描述
			local Desc = TeamRecruitUtil.IsRecruitUnlocked(Data.ResID) and (Cfg.TaskName or "") or "???"
			self.TextDesc:SetText(Desc)
		end
	end

	-- 职业Icon列表
	local ProfList = {}
	local CurMemNum = 0
	local IconIDs = Data.IconIDs or {}
	local MemLocList = Data.LocList or {}

	for k, v in ipairs(MemLocList) do
		local Icon = nil
		local IconID = IconIDs[k]
		if IconID then
			Icon = TeamRecruitUtil.GetRecruitMemIcon(IconID)
		end

		local HasRole = v == 1
		if HasRole then
			CurMemNum = CurMemNum + 1
		end

		table.insert(ProfList, { Icon = Icon, HasRole = HasRole})
	end

	self.TableAdapterProf:UpdateAll(ProfList)

	-- 人数信息 
	local NumText = string.format("%s/%s", CurMemNum, #ProfList)
	self.TextNum:SetText(NumText)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatMsgTeamRecruitItemView:OnClickButtonClick()
	_G.TeamRecruitMgr:ShowRecruitDetailView(self.RecruitID, {FailTipID=301013})
end

return ChatMsgTeamRecruitItemView