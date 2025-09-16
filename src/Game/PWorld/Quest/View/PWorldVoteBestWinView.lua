--[[
Author: v_hggzhang
Date: 2023-05-16 17:28
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-11 11:48:04
FilePath: \Script\Game\PWorld\Quest\View\PWorldVoteBestWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PWorldVoteBestWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonThroughFrameS_UIBP CommonThroughFrameSView
---@field PanelBest UFCanvasPanel
---@field TableViewPlayer UTableView
---@field TableViewPlayer02 UTableView
---@field TextChooseOne UFTextBlock
---@field TextCloseTips_1 UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldVoteBestWinView = LuaClass(UIView, true)

function PWorldVoteBestWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonThroughFrameS_UIBP = nil
	--self.PanelBest = nil
	--self.TableViewPlayer = nil
	--self.TableViewPlayer02 = nil
	--self.TextChooseOne = nil
	--self.TextCloseTips_1 = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldVoteBestWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonThroughFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end


local TeamDefine = require("Game/Team/TeamDefine")
local TeamVoteType = TeamDefine.VoteType;

local GetUIConfig = function(Type)
	local Cfg = {
		[TeamVoteType.BEST_PLAYER] = {
			Title = "BEST_PLAYER_TITLE",
			SubTitle = "BEST_PLAYER_CONTENT",
		},
		[TeamVoteType.EXPEL_PLAYER] = {
			Title = "EXPEL_PLAYER_TITLE",
			SubTitle = "EXPEL_PLAYER_CONTENT",
		}
	}

	local PWorldHelper = require("Game/PWorld/PWorldHelper")
	return {
		Title = PWorldHelper.GetPWorldText(Cfg[Type].Title),
		SubTitle = PWorldHelper.GetPWorldText(Cfg[Type].SubTitle),
	}
end

function PWorldVoteBestWinView:OnPostInit()
	self.MemAdp = UIAdapterTableView.CreateAdapter(self, self.TableViewPlayer, self.OnTableItemSelected, true, false)
	self.MemAdp2 = UIAdapterTableView.CreateAdapter(self, self.TableViewPlayer02, self.OnTableItemSelected, true, false)

	self.Binders = {
        { "MatchMems",				UIBinderUpdateBindableList.New(self, self.MemAdp)},
		{ "MatchMems",				UIBinderUpdateBindableList.New(self, self.MemAdp2)},
		{ "BestPlayerIDVoted", UIBinderValueChangedCallback.New(self, nil, function(_, NewValue)
			self.CommonThroughFrameS_UIBP.BtnCheck2:SetIsEnabled(NewValue and true or false, false)
		end)},
		{ "MatchMemCount", UIBinderValueChangedCallback.New(self, nil, self.OnMatchMemCountChanged)},
    }

	self.ExpelBinders = {
        { "MatchMems",       UIBinderUpdateBindableList.New(self, self.MemAdp) },
		{ "MatchMems",				UIBinderUpdateBindableList.New(self, self.MemAdp2)},
		{ "ExpelPlayerIDVoted", UIBinderValueChangedCallback.New(self, nil, function(_, NewValue)
			self.CommonThroughFrameS_UIBP.BtnCheck2:SetIsEnabled(NewValue and true or false, false)
		end)},
		{ "MatchMemCount", UIBinderValueChangedCallback.New(self, nil, self.OnMatchMemCountChanged)},
    }

	UIUtil.SetIsVisible(self.CommonThroughFrameS_UIBP.Panel1Btn, false)
	UIUtil.SetIsVisible(self.CommonThroughFrameS_UIBP.Panel2Btn, true)
	UIUtil.SetIsVisible(self.CommonThroughFrameS_UIBP.Panel3Btn, false)
end

function PWorldVoteBestWinView:OnShow()
	if self.Params == nil then
		_G.FLOG_ERROR("PWorldVoteBestWinView MUST SPECIFY ITS PARAMS AND SHOWTYPE!")
		return
	end

	self.MemAdp:ClearSelectedItem()

	_G.UIViewMgr:HideView(_G.UIViewID.PWorldQuestMenu)
	
	if self.Params.ShowType == TeamVoteType.BEST_PLAYER then
		_G.PWorldTeamVM:SetVoteBestPlayer(nil)
		_G.PWorldTeamVM:ClearMembersSelection()
		self.CommonThroughFrameS_UIBP.BtnClose2:SetText(_G.LSTR(1320191))
		self.CommonThroughFrameS_UIBP.BtnCheck2:SetText(_G.LSTR(1320192))
	elseif self.Params.ShowType == TeamVoteType.EXPEL_PLAYER then
		_G.PWorldTeamVM:SetExpelPlayer(nil)
		_G.PWorldTeamVM:ClearMatchMembersSelection()
		self.CommonThroughFrameS_UIBP.BtnClose2:SetText(_G.LSTR(1320174))
		self.CommonThroughFrameS_UIBP.BtnCheck2:SetText(_G.LSTR(1320175))
	end

	local Cfg = GetUIConfig(self.Params.ShowType)
	self.CommonThroughFrameS_UIBP.TextTitle:SetText(Cfg.Title)
	self.TextChooseOne:SetText(Cfg.SubTitle)
end

function PWorldVoteBestWinView:OnHide()
	_G.SidebarMgr:TryOpenSidebarMainWin()
end

function PWorldVoteBestWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommonThroughFrameS_UIBP.BtnCheck2, self.OnClickOKButton)
	UIUtil.AddOnClickedEvent(self, self.CommonThroughFrameS_UIBP.BtnClose2, self.OnPanel2LeftButtonClick)
end

function PWorldVoteBestWinView:OnRegisterBinder()
	if _G.PWorldTeamVM == nil or self.Params == nil then
		return
	end

	if self.Params.ShowType == TeamVoteType.BEST_PLAYER then
		self:RegisterBinders(_G.PWorldTeamVM, self.Binders)
	elseif self.Params.ShowType == TeamVoteType.EXPEL_PLAYER then
		self:RegisterBinders(_G.PWorldTeamVM, self.ExpelBinders)
	end
end

function PWorldVoteBestWinView:OnClickOKButton()
	-- VOTE BEST PALYER
	if self and self.Params and _G.PWorldTeamVM.BestPlayerIDVoted and self.Params.ShowType == TeamVoteType.BEST_PLAYER then
		_G.PWorldTeamMgr:ReqPWVoteMVP(_G.PWorldTeamVM.BestPlayerIDVoted)
	end

	-- VOTE PLAYER TO EXPEL
	if self and self.Params and _G.PWorldTeamVM.ExpelPlayerIDVoted and self.Params.ShowType == TeamVoteType.EXPEL_PLAYER then
		_G.PWorldTeamMgr:ReqPWVoteStartExile(_G.PWorldTeamVM.ExpelPlayerIDVoted)
	end
end

function PWorldVoteBestWinView:OnClickCancel()
	self:Hide()
end

function PWorldVoteBestWinView:OnClickFold()
	self:Hide()
end

function PWorldVoteBestWinView:OnPanel2LeftButtonClick()
	self:Hide()
end

function PWorldVoteBestWinView:OnMatchMemCountChanged(NewCount)
	local bShow4 = NewCount == nil or NewCount <= 4
	UIUtil.SetIsVisible(self.TableViewPlayer, not bShow4)
	UIUtil.SetIsVisible(self.TableViewPlayer02, bShow4)
end

function PWorldVoteBestWinView:OnTableItemSelected(_, ItemVM)
	if self.Params.ShowType == TeamVoteType.BEST_PLAYER then
		_G.PWorldTeamVM:SetVoteBestPlayer(ItemVM.MemRoleID)
	elseif self.Params.ShowType == TeamVoteType.EXPEL_PLAYER then 
		_G.PWorldTeamVM:SetExpelPlayer(ItemVM.MemRoleID)
	end
end

return PWorldVoteBestWinView