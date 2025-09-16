---
--- Author: Administrator
--- DateTime: 2024-03-14 15:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RedDotItemVM = require("Game/CommonRedDot/VM/RedDotItemVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")

local ObjectPoolMgr = _G.ObjectPoolMgr

---@class CommonRedDotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelRedDot UFCanvasPanel
---@field PanelYellow UFCanvasPanel
---@field RedDotStyle int
---@field RedDotID int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field RedDotName string
local CommonRedDotView = LuaClass(UIView, true)

function CommonRedDotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelRedDot = nil
	--self.PanelYellow = nil
	--self.RedDotStyle = nil
	--self.RedDotID = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonRedDotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonRedDotView:OnInit()
	self:InitData()
end

function CommonRedDotView:InitData()
	--self.ItemVM = RedDotItemVM.New()
	if not self.ItemVM then
		self.ItemVM = ObjectPoolMgr:AllocObject(RedDotItemVM)
	end
	self.ItemVM:Reset()
	--- 支持蓝图初始配置
	if self.RedDotStyle then
		self:SetStyle(self.RedDotStyle)
	end
	if self.Binders == nil then
		self.Binders = {
			--{ "IsVisible", UIBinderSetIsVisible.New(self, self.PanelRedDot)},
			{ "RedDotStyle", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotStyleChange) },
			{ "Text", UIBinderValueChangedCallback.New(self, nil, self.OnTextChanged) },
			{ "Num", UIBinderValueChangedCallback.New(self, nil, self.OnNumChanged) },
			{ "IsShowMax", UIBinderValueChangedCallback.New(self, nil, self.OnIsShowMaxChanged) },
			{ "IsVisible", UIBinderValueChangedCallback.New(self, nil, self.OnIsVisibleChange)},
		}
	end
end

function CommonRedDotView:OnIsVisibleChange(IsVisible)
	UIUtil.SetIsVisible(self.PanelRedDot, IsVisible)
	if IsVisible and self.ItemVM then
		local RedDotStyle = self.ItemVM:GetRedDotStyle()
		self:AddSubRedDotViewByStyle(RedDotStyle)
	else
		self:ClearAllSubView()
	end
end

function CommonRedDotView:OnDestroy()
	ObjectPoolMgr:FreeObject(RedDotItemVM, self.ItemVM)
	self.ItemVM = nil
end

--- @param RedDotStyle RedDotDefine.RedDotStyle
function CommonRedDotView:SetStyle(RedDotStyle)
	if self.ItemVM then
		self.ItemVM:SetRedDotStyle(RedDotStyle)
	end
end

---@param InText string 红点文本
function CommonRedDotView:SetRedDotText(InText)
	if self.ItemVM then
		self.ItemVM:SetRedDotText(InText)
	end
end

---@param InRedDotID number 节点ID 
---@param InRedDotName string 节点名 
---@param RedDotStyle RedDotDefine.RedDotStyle 红点样式 
---@param InText string 红点文本 
function CommonRedDotView:SetRedDotData(InRedDotID, InRedDotName, InRedDotStyle, InText)
	if InRedDotID then
		self:SetRedDotIDByID(InRedDotID)
	elseif InRedDotName then
		self:SetRedDotNameByString(InRedDotName)
	end
	if InRedDotStyle then
		self:SetStyle(InRedDotStyle)
	end
	if InText then	
		self:SetRedDotText(InText)
	end

end

function CommonRedDotView:OnShow()
	if not self.IsCustomizeRedDot then
		--- 设置显示数据
		if self.RedDotID and self.RedDotID ~= 0 then
			local RedDotName = RedDotMgr:GetRedDotNameByID(self.RedDotID)
			if RedDotName then
				self.RedDotName = RedDotName
			end
		end
		self.ItemVM:UpdateNodeDataByName(self.RedDotName)
		---将需要进行数据更新的红点的VM加入Mgr的VMMap
		RedDotMgr:AddRedDotItemVM(self.ItemVM)
		---设置样式
		if self.ItemVM then
			local RedDotStyle = self.ItemVM:GetRedDotStyle()
			self:AddSubRedDotViewByStyle(RedDotStyle)
		else
			self:ClearAllSubView()
		end
	end
end


function CommonRedDotView:OnHide()
	---清理所有子红点UI
	self:ClearAllSubView()
	---从Mgr的VMMap中移除对应的ItemVM
	if self.ItemVM then
		RedDotMgr:RemoveRedDotItemVM(self.ItemVM)
	end
end

function CommonRedDotView:OnRegisterUIEvent()

end

function CommonRedDotView:OnRegisterGameEvent()
    --self:RegisterGameEvent(EventID.RedDotUpdate, self.OnUpdateRedDot)
end

function CommonRedDotView:OnRegisterBinder()
	if self.ItemVM then
		self:RegisterBinders(self.ItemVM, self.Binders)
	end
end

---------------------------- ValueChange Start ----------------------------
function CommonRedDotView:OnRedDotStyleChange(InRedDotStyle)
	self:AddSubRedDotViewByStyle(InRedDotStyle)
end

function CommonRedDotView:OnTextChanged(Text)
	if self.NumTextRedDotView then
		self.NumTextRedDotView:OnTextChanged(Text)
	end
end

function CommonRedDotView:OnNumChanged(Num)
	if self.NumTextRedDotView then
		self.NumTextRedDotView:OnNumChanged(Num)
	end
end

function CommonRedDotView:OnIsShowMaxChanged(IsShowMax)
	if self.NumTextRedDotView then
		self.NumTextRedDotView:OnIsShowMaxChanged(IsShowMax)
	end
end

---------------------------- ValueChange end ----------------------------

function CommonRedDotView:AddSubRedDotViewByStyle(InRedDotStyle)
	---对应红点不显示时不加载任何子红点蓝图
	local IsVisible
	if self.ItemVM then
		IsVisible = self.ItemVM:GetIsVisible()
	end
	if not IsVisible then
		self:ClearAllSubView()
		return
	end

    if InRedDotStyle == RedDotDefine.RedDotStyle.NormalStyle then
		---删除数字文本红点
		if self.NumTextRedDotView ~= nil then
			self.PanelRedDot:RemoveChild(self.NumTextRedDotView)
			UIViewMgr:RecycleView(self.NumTextRedDotView)
			self.NumTextRedDotView = nil
		end
		---删除弱提醒样式红点
		if self.SecondRedDotView ~= nil then
			self.PanelRedDot:RemoveChild(self.SecondRedDotView)
			UIViewMgr:RecycleView(self.SecondRedDotView)
			self.SecondRedDotView = nil
		end
		if self.NormalRedDotView == nil then
			self.NormalRedDotView = UIViewMgr:CreateViewByName("Common/CommonRedDot/CommonSubNormalRedDot_UIBP", nil, self, true)
			if self.NormalRedDotView then
				self.PanelRedDot:AddChildToCanvas(self.NormalRedDotView)
				UIUtil.CanvasSlotSetSize(self.NormalRedDotView, _G.UE.FVector2D(60, 60))
			end
		end
	elseif InRedDotStyle == RedDotDefine.RedDotStyle.NumStyle or  InRedDotStyle == RedDotDefine.RedDotStyle.TextStyle then
		---删除普通红点
		if self.NormalRedDotView ~= nil then
			self.PanelRedDot:RemoveChild(self.NormalRedDotView)
			UIViewMgr:RecycleView(self.NormalRedDotView)
			self.NormalRedDotView = nil
		end
		---删除弱提醒样式红点
		if self.SecondRedDotView ~= nil then
			self.PanelRedDot:RemoveChild(self.SecondRedDotView)
			UIViewMgr:RecycleView(self.SecondRedDotView)
			self.SecondRedDotView = nil
		end
		if self.NumTextRedDotView == nil then
			--local Params = {VM = self.ItemVM}
			self.NumTextRedDotView = UIViewMgr:CreateViewByName("Common/CommonRedDot/CommonSubNumAndTextRedDot_UIBP", nil, self, true, false)
			if self.NumTextRedDotView then
				self.PanelRedDot:AddChildToCanvas(self.NumTextRedDotView)
				self.NumTextRedDotView:UIUpdataShowByVM(self.ItemVM)
				UIUtil.CanvasSlotSetSize(self.NumTextRedDotView, _G.UE.FVector2D(60, 60))
			end
		else
			self.NumTextRedDotView:UIUpdataShowByVM(self.ItemVM)
		end
	elseif InRedDotStyle == RedDotDefine.RedDotStyle.SecondStyle then
		---删除数字文本红点
		if self.NumTextRedDotView ~= nil then
			self.PanelRedDot:RemoveChild(self.NumTextRedDotView)
			UIViewMgr:RecycleView(self.NumTextRedDotView)
			self.NumTextRedDotView = nil
		end
		---删除普通红点
		if self.NormalRedDotView ~= nil then
			self.PanelRedDot:RemoveChild(self.NormalRedDotView)
			UIViewMgr:RecycleView(self.NormalRedDotView)
			self.NormalRedDotView = nil
		end
		if self.SecondRedDotView == nil then
			self.SecondRedDotView = UIViewMgr:CreateViewByName("Common/CommonRedDot/CommonSecondRedDot_UIBP", nil, self, true, false)
			if self.SecondRedDotView then
				self.PanelRedDot:AddChildToCanvas(self.SecondRedDotView)
				--self.SecondRedDotView:UIUpdataShowByVM(self.ItemVM)
				UIUtil.CanvasSlotSetSize(self.SecondRedDotView, _G.UE.FVector2D(60, 60))
			end
		end
	end
end

--- 动态添加的红点需要自己设置名字
function CommonRedDotView:SetRedDotNameByString(RedDotName)
    self.RedDotName = RedDotName
    if self.ItemVM then
        self.ItemVM:UpdateNodeDataByName(self.RedDotName)
		---将需要进行数据更新的红点的VM加入Mgr的VMMap，无法确定改名时是否被显示，先添加
		RedDotMgr:AddRedDotItemVM(self.ItemVM)
    else
        self:InitData()
    end
    
end

--- 设置红点ID
function CommonRedDotView:SetRedDotIDByID(RedDotID)
    self.RedDotID = RedDotID
    local RedDotName = RedDotMgr:GetRedDotNameByID(self.RedDotID)
	self:SetRedDotNameByString(RedDotName)
end


---只有叶子节点和非红点树管理的节点可以修改
function CommonRedDotView:SetRedDotNumByNumber(Num)
    if self.ItemVM  then
        self.ItemVM:SetNum(Num)
    end
    
end

function CommonRedDotView:GetCurRedDotName()
    return self.RedDotName
end

function CommonRedDotView:GetCurRedDotID()
    return self.RedDotID
end

function CommonRedDotView:OnUpdateRedDot(RedDotNameList)
    if self.ItemVM and  self.RedDotName and _G.UE.UCommonUtil.IsObjectValid(self.PanelRedDot) then
        for _, UpDateName in ipairs(RedDotNameList) do
            if UpDateName == self.RedDotName then
                self.ItemVM:UpdateNodeDataByName(self.RedDotName)
                return
            end
        end
    end
end

function CommonRedDotView:HideRedDot()
    if self.ItemVM then
        self.ItemVM:HideRedDot()
    end
end

function CommonRedDotView:ShowRedDot()
    if self.ItemVM then
        self.ItemVM:ShowRedDot()
    end
end

---是否是自定义节点，自定义节点不走红点配置，不会触发默认隐藏，由对应系统控制
function CommonRedDotView:SetIsCustomizeRedDot(IsCustomizeRedDot)
	self.IsCustomizeRedDot = IsCustomizeRedDot
end

function CommonRedDotView:GetIsCustomizeRedDot()
	return self.IsCustomizeRedDot
end

---手动设置红点显隐，一般用于自定义节点
function CommonRedDotView:SetRedDotUIIsShow(IsShow)
	if self.ItemVM then
		self.ItemVM:SetIsVisible(IsShow)
	end
end

function CommonRedDotView:SetSecondRedDotText(InText)
	if self.SecondRedDotView then
		self.SecondRedDotView:SetRedDotText(InText)
	end
end

function CommonRedDotView:ClearAllSubView()
	---删除数字文本红点
	if self.NumTextRedDotView ~= nil then
		self.PanelRedDot:RemoveChild(self.NumTextRedDotView)
		UIViewMgr:RecycleView(self.NumTextRedDotView)
		self.NumTextRedDotView = nil
	end
	---删除普通红点
	if self.NormalRedDotView ~= nil then
		self.PanelRedDot:RemoveChild(self.NormalRedDotView)
		UIViewMgr:RecycleView(self.NormalRedDotView)
		self.NormalRedDotView = nil
	end
	---删除弱提醒样式红点
	if self.SecondRedDotView ~= nil then
		self.PanelRedDot:RemoveChild(self.SecondRedDotView)
		UIViewMgr:RecycleView(self.SecondRedDotView)
		self.SecondRedDotView = nil
	end
end

return CommonRedDotView