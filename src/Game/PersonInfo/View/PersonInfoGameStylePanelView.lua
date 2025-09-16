---
--- Author: xingcaicao
--- DateTime: 2023-04-21 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GameStyleCfg = require("TableCfg/GameStyleCfg")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local Json = require("Core/Json")

local MaxGameStyleCount = PersonInfoDefine.MaxGameStyleCount

---@class PersonInfoGameStylePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnSave CommBtnLView
---@field FrameL Comm2FrameLView
---@field TableViewChosenStyle UTableView
---@field TableViewStyle UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoGameStylePanelView = LuaClass(UIView, true)

function PersonInfoGameStylePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnSave = nil
	--self.FrameL = nil
	--self.TableViewChosenStyle = nil
	--self.TableViewStyle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoGameStylePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.FrameL)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoGameStylePanelView:OnInit()
	self.TableAdapterStyle = UIAdapterTableView.CreateAdapter(self, self.TableViewStyle)
	self.TableAdapterChosen = UIAdapterTableView.CreateAdapter(self, self.TableViewChosenStyle)

	self.Binders = {
		{ "AllGameStyleVMList", 	UIBinderUpdateBindableList.New(self, self.TableAdapterStyle) },
		{ "MyTempGameStyleVMList", 	UIBinderUpdateBindableList.New(self, self.TableAdapterChosen) },
		{ "StrGameStyleSet", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedGameStyleSet) },
		{ "StrGameStyleMyTempSet", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedTempSet) },
	}

	self:InitLSTR()
end

function PersonInfoGameStylePanelView:InitLSTR()
	self.FrameL.FText_Title:SetText(_G.LSTR(620108))
	self.TextStyle:SetText(_G.LSTR(620049))

	self.BtnCancel:SetText(_G.LSTR(10003))
	self.BtnSave:SetText(_G.LSTR(10002))
end

function PersonInfoGameStylePanelView:OnDestroy()

end

function PersonInfoGameStylePanelView:OnShow()
	self.BtnSave:SetIsEnabled(false)
end

function PersonInfoGameStylePanelView:OnHide()
    PersonInfoVM.StrGameStyleMyTempSet = "[]" 
    PersonInfoVM.MyTempGameStyleVMList:Clear()
end

function PersonInfoGameStylePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickButtonSave)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickButtonCancel)
end

function PersonInfoGameStylePanelView:OnRegisterGameEvent()

end

function PersonInfoGameStylePanelView:OnRegisterBinder()
	---更新所有风格列表
	self:UpdateAllGameStyleList()

	self:RegisterBinders(PersonInfoVM, self.Binders)
end

function PersonInfoGameStylePanelView:OnValueChangedTempSet(StrSet)
	if nil == StrSet then
		self.BtnSave:SetIsEnabled(false)
		return
	end

	self.BtnSave:SetIsEnabled(StrSet ~= PersonInfoVM.StrGameStyleSet)

    local IDList = Json.decode(StrSet)
	self:UpdateMyGameStyleSetList(IDList or {})
end

---更新所有风格列表
function PersonInfoGameStylePanelView:UpdateAllGameStyleList( )
    if nil == PersonInfoVM.RoleVM or PersonInfoVM.AllGameStyleVMList:Length() > 0 then
        return
    end

    local CfgList = GameStyleCfg:GetGameStyleList() or {}
    PersonInfoVM.AllGameStyleVMList:UpdateByValues(table.clone(CfgList))
end

function PersonInfoGameStylePanelView:UpdateMyGameStyleSetList( IDList )
    local Data = {}
	local Num = math.min(MaxGameStyleCount, PersonInfoVM.AllGameStyleVMList:Length())

    for i = 1, Num do
		local Info = {}
		local ID = IDList[i]
		if ID then
			Info = table.clone(GameStyleCfg:GetGameStyleCfg(ID) or {})
		end

		table.insert(Data, Info)
	end

    PersonInfoVM.MyTempGameStyleVMList:UpdateByValues(Data)
end

---更新风格设置列表
function PersonInfoGameStylePanelView:OnValueChangedGameStyleSet(StrSet)
	local IDList = {}

	for _, v in ipairs(PersonInfoVM.CurGameStyleVMList:GetItems()) do
		table.insert(IDList, v.ID)
	end

	self:UpdateMyGameStyleSetList(IDList)

	PersonInfoVM.StrGameStyleMyTempSet = StrSet 
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function PersonInfoGameStylePanelView:OnClickButtonSave()
	self.BtnSave:SetIsEnabled(false)
	PersonInfoVM:SaveGameStyle()

	self:OnClickButtonCancel()
end

function PersonInfoGameStylePanelView:OnClickButtonCancel()
	self:Hide()
end

return PersonInfoGameStylePanelView