---
--- Author: Administrator
--- DateTime: 2024-01-17 13:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local ChocoboNamecatCfg = require("TableCfg/ChocoboNamecatCfg")
local ChocoboNameWinVM = require("Game/Chocobo/Mating/VM/ChocoboNameWinVM")
local ProtoRes = require("Protocol/ProtoRes")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ChocoboNameCfg = require("TableCfg/ChocoboNameCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class ChocoboNameWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnCancel CommBtnMView
---@field BtnConfirm CommBtnMView
---@field BtnInfor CommInforBtnView
---@field BtnName1 UFButton
---@field BtnName2 UFButton
---@field ImgNameBg1 UFImage
---@field ImgNameBg2 UFImage
---@field ImgNameSelectBg1 UFImage
---@field ImgNameSelectBg2 UFImage
---@field Menu CommMenuView
---@field Spacer4Infor USpacer
---@field TableViewWords UTableView
---@field TextName UFTextBlock
---@field TextName1 UFTextBlock
---@field TextName2 UFTextBlock
---@field TextTitle UFTextBlock
---@field TextWord1 UFTextBlock
---@field TextWord2 UFTextBlock
---@field TextWords UFTextBlock
---@field AnimChangeMenu UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboNameWinView = LuaClass(UIView, true)

function ChocoboNameWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnConfirm = nil
	--self.BtnInfor = nil
	--self.BtnName1 = nil
	--self.BtnName2 = nil
	--self.ImgNameBg1 = nil
	--self.ImgNameBg2 = nil
	--self.ImgNameSelectBg1 = nil
	--self.ImgNameSelectBg2 = nil
	--self.Menu = nil
	--self.Spacer4Infor = nil
	--self.TableViewWords = nil
	--self.TextName = nil
	--self.TextName1 = nil
	--self.TextName2 = nil
	--self.TextTitle = nil
	--self.TextWord1 = nil
	--self.TextWord2 = nil
	--self.TextWords = nil
	--self.AnimChangeMenu = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboNameWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.BtnInfor)
	self:AddSubView(self.Menu)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboNameWinView:OnInit()
	self.Name1 =  0
	self.Name2 =  0
	self.IsSuc = false
	self.ViewModel = ChocoboNameWinVM.New()
	self.WordsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewWords, self.WorldSelected, true)
end

function ChocoboNameWinView:OnDestroy()

end

function ChocoboNameWinView:OnShow()
	self:InitConstInfo()

	UIUtil.SetIsVisible(self.TextTitle, true, false)
	if self.BG ~= nil and self.BG.FText_Title ~= nil then
		self.Bg:SetTitleText("")
		UIUtil.SetIsVisible(self.BG.FText_Title, true, false)
	end
	
	if self.Params ~= nil and self.Params.Source == ChocoboDefine.SOURCE.NPC then
		local ChildInfo = _G.ChocoboMgr:GetChocoboInfoByID(_G.ChocoboMainVM.CurSelectEntryID)
		if not ChildInfo then
			return
		end
		
		self.Name1 = ChildInfo.Name and ChildInfo.Name.Name1 or 0
		self.Name2 = ChildInfo.Name and ChildInfo.Name.Name2 or 0
		local Name1Text = ChocoboNameCfg:FindValue(self.Name1, "Name") or ""
		local Name2Text = ChocoboNameCfg:FindValue(self.Name2, "Name") or ""
		self.TextName1:SetText(Name1Text)
		self.TextName2:SetText(Name2Text)
	else
		self.TextName1:SetText("")
		self.TextName2:SetText("")
	end
	self.BtnConfirm:SetIsDisabledState(true, true)
	self:SetFirstNameEnable(true)
	self:UpdateNameCatItems()
	--self.WordsTableViewAdapter:SetSelectedIndex(1)
end

function ChocoboNameWinView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	---- LSTR string: 命名
	self.TextTitle:SetText(_G.LSTR(420133))
	-- LSTR string: 可选词语
	self.TextWords:SetText(_G.LSTR(420048))
	-- LSTR string: 竞赛名
	self.TextName:SetText(_G.LSTR(420049))
	-- LSTR string: 单词1：
	self.TextWord1:SetText(_G.LSTR(420050))
	-- LSTR string: 单词2（可不选）：
	self.TextWord2:SetText(_G.LSTR(420051))
	-- LSTR string: 确  定
	self.BtnConfirm:SetText(_G.LSTR(420134))
	-- LSTR string: 取  消
	self.BtnCancel:SetText(_G.LSTR(420135))
end

function ChocoboNameWinView:OnHide()
	-- 处理界面意外关闭情况
	if not self.Params or not self.Params.Source then
		return
	end
	
	if self.IsSuc then
		return
	end
	
	if self.Params.Source ~= ChocoboDefine.SOURCE.TASK then
		return
	end

	_G.EventMgr:SendEvent(_G.EventID.ChocoboNameTaskRevert)
end

function ChocoboNameWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.Menu, self.OnSelectionChangedCommMenu)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnClickBtnConfirm)

	UIUtil.AddOnClickedEvent(self, self.BtnName1, self.OnClickBtnName1)
	UIUtil.AddOnClickedEvent(self, self.BtnName2, self.OnClickBtnName2)
end

function ChocoboNameWinView:OnRegisterGameEvent()

end

function ChocoboNameWinView:OnRegisterBinder()
	self.Binders = {
		{ "WordList", UIBinderUpdateBindableList.New(self, self.WordsTableViewAdapter) },
	}

	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ChocoboNameWinView:OnSelectionChangedCommMenu(Index)
	self:PlayAnimation(self.AnimChangeMenu)
	self.ViewModel:UpdateItem(Index)
	self.WordsTableViewAdapter:SetSelectedIndex(1)
end

function ChocoboNameWinView:UpdateNameCatItems()
	local OpenListData = {}
	local Cfgs = ChocoboNamecatCfg:FindAllCfg()
	if Cfgs ~= nil then 
		for _,V in pairs(Cfgs) do
			if V.SortId ~= nil and V.SortId > 0 then
				local Data = {}
				Data.Key = V.ID
				Data.Name = V.Name
				table.insert(OpenListData,Data) 
			end   
        end
	end

	self.Menu:UpdateItems(OpenListData)
	self.Menu:SetSelectedIndex(1)
end

function ChocoboNameWinView:OnClickBtnCancel()
	self:Hide()
end

function ChocoboNameWinView:OnClickBtnConfirm()
	if self.Name1 == nil or self.Params == nil or self.Params.Source == nil then
		return
	end

	local Source = self.Params.Source
	local ChocoboID = 0
	local Gender = (self.Params.Gender or 0)  -- 明确 Gender 默认值

	if Source == ChocoboDefine.SOURCE.SEQUENCE then
		ChocoboID = _G.ChocoboMainVM:GetCurChildID()
		if ChocoboID <= 0 then
			return
		end
		_G.ChocoboMgr:ReqMatingReceive(ChocoboID, { Name1 = self.Name1, Name2 = self.Name2 })

	elseif Source == ChocoboDefine.SOURCE.TASK then
		-- 直接领养（无弹窗）
		_G.ChocoboMgr:GetNewbieChocoboReq(Gender, {
			Name1 = self.Name1,
			Name2 = self.Name2
		})
	elseif Source == ChocoboDefine.SOURCE.ADOPT then
		local function OnConfirm()
			_G.ChocoboMgr:AdoptReq(Gender, {
				Name1 = self.Name1,
				Name2 = self.Name2
			})
		end

		local CostCfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GlobalCfgChocoboAdoptCost, "Value")
		local Cost = (CostCfg and type(CostCfg[1]) == "number") and CostCfg[1] or 2000
		
		local TitleText = _G.LSTR(420183)
		local ContentText = string.format(_G.LSTR(420182), tostring(Cost))
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(
				self,
				TitleText,  -- 标题
				ContentText,  -- 内容
				OnConfirm,        -- 确认回调
				nil,       -- 取消回调
				_G.LSTR(10003),   -- 确认按钮文本
				_G.LSTR(10002),   -- 取消按钮文本
				{
					CostItemID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE,
					CostNum = Cost
				}
		)
	elseif Source == ChocoboDefine.SOURCE.NPC then
		ChocoboID = _G.ChocoboMainVM.CurRaceEntryID or 0
		if ChocoboID <= 0 then
			return
		end

		local function OnConfirm()
			local Name1Text = ChocoboNameCfg:FindValue(self.Name1, "Name") or ""
			local Name2Text = ChocoboNameCfg:FindValue(self.Name2, "Name") or ""
			local TipsContent = string.format(_G.LSTR(420177), Name1Text .. Name2Text)
			MsgTipsUtil.ShowTips(TipsContent)
			_G.ChocoboMgr:RenameReq({
				ID = ChocoboID,
				Name = { Name1 = self.Name1, Name2 = self.Name2 }
			})
		end

		local CostCfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GlobalCfgChocoboRenameCost, "Value")
		local Cost = (CostCfg and type(CostCfg[1]) == "number") and CostCfg[1] or 2000
		
		local ScoreValue = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
		if ScoreValue < Cost then
			-- LSTR string: 你拥有的金碟币不足
			MsgTipsUtil.ShowTips(_G.LSTR(420179))
			return
		end

		local ChildInfo = _G.ChocoboMgr:GetChocoboInfoByID(_G.ChocoboMainVM.CurSelectEntryID)
		if ChildInfo then
			local RacerName1 = ChildInfo.Name and ChildInfo.Name.Name1 or 0
			local RacerName2 = ChildInfo.Name and ChildInfo.Name.Name2 or 0

			local NameChanged = (self.Name1 ~= RacerName1) or (self.Name2 ~= RacerName2)
			if not NameChanged then
				-- LSTR string: 您还未修改竞赛陆行鸟的名字
				MsgTipsUtil.ShowTips(_G.LSTR(420186))
				return
			end
		end
		
		local TitleText = _G.LSTR(420178)
		local Name1Text = ChocoboNameCfg:FindValue(self.Name1, "Name") or ""
		local Name2Text = ChocoboNameCfg:FindValue(self.Name2, "Name") or ""
		local ContentText = string.format(_G.LSTR(420176), Name1Text .. Name2Text, tostring(Cost))
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(
				self,
				TitleText,  -- 标题
				ContentText,  -- 内容
				OnConfirm,        -- 确认回调
				nil,       -- 取消回调
				_G.LSTR(10003),   -- 确认按钮文本
				_G.LSTR(10002),   -- 取消按钮文本
				{
					CostItemID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE,
					CostNum = Cost
				}
		)
	end
end


function ChocoboNameWinView:OnClickBtnName1()
	self:SetFirstNameEnable(true)
end

function ChocoboNameWinView:OnClickBtnName2()
	self:SetFirstNameEnable(false)
end

function ChocoboNameWinView:WorldSelected(Index, ItemData, ItemView, IsByClick)
	local IsChangeRacerName = false
	if self.Params ~= nil and self.Params.Source == ChocoboDefine.SOURCE.NPC then
		IsChangeRacerName = true
	end
	
	if IsChangeRacerName and not IsByClick then
		return
	end
	
	local TextWord = ItemData.TextWord
	local NameID = ItemData.ID
	if self.FirstName then
		self.Name1 = NameID
		self.TextName1:SetText(TextWord)
		self.BtnConfirm:SetIsNormalState(true)
	else
		if self.Name2 == NameID then
			self.Name2 = 0
			TextWord = ""
			ItemData:SetSelect(false)
		else
			self.Name2 = NameID
		end
		self.TextName2:SetText(TextWord)
	end

	if IsChangeRacerName then
		local ChildInfo = _G.ChocoboMgr:GetChocoboInfoByID(_G.ChocoboMainVM.CurSelectEntryID)
		if ChildInfo then
			local RacerName1 = ChildInfo.Name and ChildInfo.Name.Name1 or 0
			local RacerName2 = ChildInfo.Name and ChildInfo.Name.Name2 or 0

			local NameChanged = (self.Name1 ~= RacerName1) or (self.Name2 ~= RacerName2)
			if NameChanged then
				self.BtnConfirm:SetIsNormalState(true)
			else
				self.BtnConfirm:SetIsDisabledState(true, true)
			end
		end
	end
end

function ChocoboNameWinView:SetFirstNameEnable(Enable)
	self.FirstName = Enable
	UIUtil.SetIsVisible(self.ImgNameSelectBg1,Enable)
	UIUtil.SetIsVisible(self.ImgNameSelectBg2,not Enable)
	self.WordsTableViewAdapter:CancelSelected()
end

return ChocoboNameWinView