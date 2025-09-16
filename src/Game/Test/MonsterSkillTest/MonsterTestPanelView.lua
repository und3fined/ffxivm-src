---
--- Author: chaooren
--- DateTime: 2021-12-14 15:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local UIEventRegister = require("Register/UIEventRegister")
local MonsterCfg = require("TableCfg/MonsterCfg")
local CommAiCfg = require("TableCfg/CommAiCfg")
local CommAiSkillgroupCfg = require("TableCfg/CommAiSkillgroupCfg")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ActorManager = nil

---@class MonsterTestPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonClose UFButton
---@field ButtonKillMonster UFButton
---@field CloseText UTextBlock
---@field CloseText2 UTextBlock
---@field MonsterBtn UFButton
---@field MonsterIDText UEditableText
---@field MonsterList UFVerticalBox
---@field MonsterLoad UTextBlock
---@field MonsterSelectBtn UFButton
---@field MonsterSelectText UTextBlock
---@field SkillBtn UFButton
---@field SkillCast UTextBlock
---@field SkillIDText UEditableText
---@field SkillList UFVerticalBox
---@field SkillSelectBtn UFButton
---@field SkillSelectText UTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MonsterTestPanelView = LuaClass(UIView, true)

function MonsterTestPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonClose = nil
	--self.ButtonKillMonster = nil
	--self.CloseText = nil
	--self.CloseText2 = nil
	--self.MonsterBtn = nil
	--self.MonsterIDText = nil
	--self.MonsterList = nil
	--self.MonsterLoad = nil
	--self.MonsterSelectBtn = nil
	--self.MonsterSelectText = nil
	--self.SkillBtn = nil
	--self.SkillCast = nil
	--self.SkillIDText = nil
	--self.SkillList = nil
	--self.SkillSelectBtn = nil
	--self.SkillSelectText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MonsterTestPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MonsterTestPanelView:OnInit()
	ActorManager = _G.UE.UActorManager.Get()
	self.MonsterUIEventRegister = UIEventRegister.New()
	self.SkillUIEventRegister = UIEventRegister.New()
	self.MonsterSelectList = {}
	self.SkillSelectList = {}
end

function MonsterTestPanelView:OnDestroy()
	if nil ~= self.MonsterUIEventRegister then
		self.MonsterUIEventRegister:UnRegisterAll()
	end
	if nil ~= self.SkillUIEventRegister then
		self.SkillUIEventRegister:UnRegisterAll()
	end
end

function MonsterTestPanelView:OnShow()
	self.MonsterSelectText:SetText(_G.LSTR(1440017)) -- -
	self.SkillSelectText:SetText(_G.LSTR(1440017)) -- -
	self.MonsterLoad:SetText(_G.LSTR(1440018)) --加载
	self.SkillCast:SetText(_G.LSTR(1440019)) --释放
	self.CloseText:SetText(_G.LSTR(1440020)) --鲨了他们
	self.CloseText2:SetText(_G.LSTR(1440021)) --关闭
	self.MonsterSelectList = {}
	local AllMonsters = ActorManager:GetAllMonsters()
	local Length = AllMonsters:Length()
	for i = 1, Length do
		local Monster = AllMonsters:GetRef(i)
		local ResID = Monster:GetAttributeComponent().ResID
		self.MonsterSelectList[ResID] = 1
	end

	self.SkillSelectList = {}
end

function MonsterTestPanelView:OnHide()
	if nil ~= self.MonsterUIEventRegister then
		self.MonsterUIEventRegister:UnRegisterAll()
	end
	if nil ~= self.SkillUIEventRegister then
		self.SkillUIEventRegister:UnRegisterAll()
	end
end

function MonsterTestPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnCloseHandle)
	UIUtil.AddOnClickedEvent(self, self.MonsterBtn, self.OnMonsterBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.SkillBtn, self.OnSkillBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.MonsterSelectBtn, self.OnMonsterSelectBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.SkillSelectBtn, self.OnSkillSelectBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.ButtonKillMonster, self.OnButtonKillMonsterClicked)
end

function MonsterTestPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
end

function MonsterTestPanelView:OnRegisterBinder()

end

function MonsterTestPanelView:OnGameEventVisionEnter(Params)
	local EntityID = Params.ULongParam1
	if ActorUtil.IsMonster(EntityID) then
		local ResID = ActorUtil.GetActorResID(EntityID)
		if ResID then
			self.MonsterSelectList[ResID] = 1
			if UIUtil.IsVisible(self.MonsterList) then
				self:RebuildMonsterSelectList()
			end
		end
	end
end

function MonsterTestPanelView:OnGameEventVisionLeave(Params)
	local ActorType = Params.IntParam1
	if ActorType == _G.UE.EActorType.Monster then
		local ResID = Params.IntParam2
		if ResID then
			self.MonsterSelectList[ResID] = nil
			if UIUtil.IsVisible(self.MonsterList) then
				self:RebuildMonsterSelectList()
			end
		end
	end
end

function MonsterTestPanelView:OnButtonKillMonsterClicked()
	local ResID = tonumber(self.MonsterIDText:GetText())
	if ResID and ResID > 0 then
		--这里怎么kill monster?????
		-- local Cmd = ""
		-- _G.GMMgr:ReqGM0(Cmd)
	end
end

function MonsterTestPanelView:OnMonsterSelectClicked(Params)
	if Params then
		self.MonsterIDText:SetText(tostring(Params.ID))
		self.MonsterSelectText:SetText(tostring(Params.ID) .. (Params.Name or "???"))
	end
	self.SkillSelectText:SetText("--")
	UIUtil.SetIsVisible(self.MonsterList, false)
end

function MonsterTestPanelView:OnSkillSelectClicked(Params)
	if Params then
		self.SkillIDText:SetText(tostring(Params.ID))
		self.SkillSelectText:SetText(tostring(Params.ID) .. (Params.Name or "???"))
	end
	UIUtil.SetIsVisible(self.SkillList, false)
end

function MonsterTestPanelView:RegisterMonsterSelectList(Widget, Params)
	self.MonsterUIEventRegister:Register(self, self.OnMonsterSelectClicked, "OnClicked", Widget, Params)
end

function MonsterTestPanelView:RegisterSkillSelectList(Widget, Params)
	self.SkillUIEventRegister:Register(self, self.OnSkillSelectClicked, "OnClicked", Widget, Params)
end

function MonsterTestPanelView:OnCloseHandle()
    UIViewMgr:HideView(UIViewID.MonsterSkillTest)
end

function MonsterTestPanelView:OnMonsterBtnClicked()
	local Cmd = "cell monster create " .. self.MonsterIDText:GetText()
	_G.GMMgr:ReqGM0(Cmd)
end

function MonsterTestPanelView:OnSkillBtnClicked()
	local Cmd = "cell skill monster " .. self.SkillIDText:GetText()
	_G.GMMgr:ReqGM0(Cmd)
end

function MonsterTestPanelView:RebuildMonsterSelectList()

	if nil ~= self.MonsterUIEventRegister then
		self.MonsterUIEventRegister:UnRegisterAll()
	end

	self.MonsterList:ClearChildren()
	local bShowList = false
	for key, _ in pairs(self.MonsterSelectList) do
		bShowList = true

		local TextBlock = _G.NewObject(_G.UE.UFTextBlock.StaticClass(), self)
		local Button = _G.NewObject(_G.UE.UFButton.StaticClass(), self)
		Button:SetContent(TextBlock)
		Button:SetBackgroundColor(_G.UE.FLinearColor(0, 0, 0, 1))

		self.MonsterList:AddChildToVerticalBox(Button)

		local MonsterName = MonsterCfg:FindValue(key, "Name")
		local MonsterText = tostring(key) .. "(" .. (MonsterName or "???") .. ")"
		TextBlock:SetText(MonsterText)
		local Font = TextBlock.Font
		Font.Size = 16
		TextBlock:SetFont(Font)

		self:RegisterMonsterSelectList(Button, {ID = key, Name = MonsterName})
	end
	UIUtil.SetIsVisible(self.MonsterList, bShowList)
end

function MonsterTestPanelView:OnMonsterSelectBtnClicked()
	UIUtil.SetIsVisible(self.SkillList, false)
		if nil ~= self.SkillUIEventRegister then
			self.SkillUIEventRegister:UnRegisterAll()
		end
	if UIUtil.IsVisible(self.MonsterList) then
		UIUtil.SetIsVisible(self.MonsterList, false)
		if nil ~= self.MonsterUIEventRegister then
			self.MonsterUIEventRegister:UnRegisterAll()
		end
		return
	end

	self:RebuildMonsterSelectList()
end

function MonsterTestPanelView:RebuildSkillSelectList(ResID)
	if nil ~= self.SkillUIEventRegister then
		self.SkillUIEventRegister:UnRegisterAll()
	end
	self.SkillList:ClearChildren()
	local bShowList = false
	if ResID and ResID > 0 then
		local SkillList = self:GetSkillListByResID(ResID)
		for key, _ in pairs(SkillList) do
			bShowList = true

			local SkillName = SkillMainCfg:GetSkillName(key)

			local TextBlock = _G.NewObject(_G.UE.UFTextBlock.StaticClass(), self)
			local Button = _G.NewObject(_G.UE.UFButton.StaticClass(), self)
			Button:SetContent(TextBlock)
			Button:SetBackgroundColor(_G.UE.FLinearColor(0, 0, 0, 1))

			self.SkillList:AddChildToVerticalBox(Button)

			local SkillText = tostring(key) .. "(" .. (SkillName or "???") .. ")"
			TextBlock:SetText(SkillText)
			local Font = TextBlock.Font
			Font.Size = 16
			TextBlock:SetFont(Font)

			self:RegisterSkillSelectList(Button, {ID = key, Name = SkillName})
		end
	end
	UIUtil.SetIsVisible(self.SkillList, bShowList)
end

function MonsterTestPanelView:OnSkillSelectBtnClicked()
	UIUtil.SetIsVisible(self.MonsterList, false)
		if nil ~= self.MonsterUIEventRegister then
			self.MonsterUIEventRegister:UnRegisterAll()
		end
	if UIUtil.IsVisible(self.SkillList) then
		UIUtil.SetIsVisible(self.SkillList, false)
		if nil ~= self.SkillUIEventRegister then
			self.SkillUIEventRegister:UnRegisterAll()
		end
		return
	end

	local ResID = tonumber(self.MonsterIDText:GetText())
	self:RebuildSkillSelectList(ResID)
end

function MonsterTestPanelView:GetSkillListByResID(ResID)
	local SkillList = {}
	local AICfgID = MonsterCfg:FindValue(ResID, "AITableID")
	if AICfgID and AICfgID > 0 then
		local DefaultGroupID = CommAiCfg:FindValue(AICfgID, "DefaultGroup")
		if DefaultGroupID and DefaultGroupID > 0 then
			local Cfg = CommAiSkillgroupCfg:FindCfgByKey(DefaultGroupID)
			for _, value in ipairs(Cfg.Normals) do
				SkillList[value] = 1
			end
			for _, value in ipairs(Cfg.Abilities) do
				SkillList[value] = 1
			end
			for _, value in ipairs(Cfg.Battles) do
				if value.ID > 0 then
					SkillList[value.ID] = 1
				end
			end
		end
	end

	return SkillList
end

return MonsterTestPanelView