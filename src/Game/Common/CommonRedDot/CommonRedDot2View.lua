---
--- Author: Administrator
--- DateTime: 2024-03-14 15:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local EventID = require("Define/EventID")
local RedDotItemVM = require("Game/CommonRedDot/VM/RedDotItemVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")

---@class CommonRedDot2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelNewYellow UFCanvasPanel
---@field PanelRedDot UFCanvasPanel
---@field PanelYellow UFCanvasPanel
---@field TextNewYellow1 UFTextBlock
---@field RedDotID int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonRedDot2View = LuaClass(UIView, true)

function CommonRedDot2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelNewYellow = nil
	--self.PanelRedDot = nil
	--self.PanelYellow = nil
	--self.TextNewYellow1 = nil
	--self.RedDotID = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonRedDot2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonRedDot2View:OnInit()
	self:InitData()
	if self.Binders == nil then
		self.Binders = {
			{ "IsVisible", UIBinderSetIsVisible.New(self, self.PanelRedDot)},
		}
	end
	-- 在OnInit设置，防止覆盖SetText进来的文本
	-- LSTR string:新
	self.TextNewYellow1:SetText(LSTR(1220001))
end

function CommonRedDot2View:InitData()
	if self.ItemVM == nil then
    	self.ItemVM = RedDotItemVM.New()
	end
end

function CommonRedDot2View:OnDestroy()

end

---@param InText string 红点文本
function CommonRedDot2View:SetRedDotText(InText)
	if self.ItemVM then
		self.ItemVM:SetRedDotText(InText)
	end
end

---@param InRedDotID number 节点ID 
---@param InRedDotName string 节点名 
---@param RedDotStyle RedDotDefine.RedDotStyle 红点样式 
---@param InText string 红点文本 
function CommonRedDot2View:SetRedDotData(InRedDotID, InRedDotName, InRedDotStyle, InText)
	if InRedDotID then
		self:SetRedDotIDByID(InRedDotID)
	elseif InRedDotName then
		self:SetRedDotNameByString(InRedDotName)
	end
	if InText then	
		self:SetRedDotText(InText)
	end
end

function CommonRedDot2View:OnShow()
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
	end
end

--- 动态添加的红点需要自己设置名字
function CommonRedDot2View:SetRedDotNameByString(RedDotName)
    self.RedDotName = RedDotName
    if self.ItemVM then
        self.ItemVM:UpdateNodeDataByName(self.RedDotName)
		---将需要进行数据更新的红点的VM加入Mgr的VMMap
		RedDotMgr:AddRedDotItemVM(self.ItemVM)
    else
        self:InitData()
    end
    
end

--- 设置红点ID
function CommonRedDot2View:SetRedDotIDByID(RedDotID)
    self.RedDotID = RedDotID
    local RedDotName = RedDotMgr:GetRedDotNameByID(self.RedDotID)
	self:SetRedDotNameByString(RedDotName)
end


---只有叶子节点和非红点树管理的节点可以修改
function CommonRedDot2View:SetRedDotNumByNumber(Num)
    if self.ItemVM  then
        self.ItemVM:SetNum(Num)
    end
    
end

function CommonRedDot2View:GetCurRedDotName()
    return self.RedDotName
end

function CommonRedDot2View:GetCurRedDotID()
    return self.RedDotID
end

function CommonRedDot2View:OnUpdateRedDot(RedDotNameList)
    if self.ItemVM and  self.RedDotName then
        for _, UpDateName in ipairs(RedDotNameList) do
            if UpDateName == self.RedDotName then
                self.ItemVM:UpdateNodeDataByName(self.RedDotName)
                return
            end
        end
    end
end

function CommonRedDot2View:ShowRedDot()
	---todo 如果有动效可以在这里处理
	if self.ItemVM then
        self.ItemVM:ShowRedDot()
    end
end

function CommonRedDot2View:HideRedDot()
	---todo 如果有动效可以在这里处理
	if self.ItemVM then
        self.ItemVM:HideRedDot()
    end
end

function CommonRedDot2View:SetText(InText)
	self.TextNewYellow1:SetText(InText)
end

function CommonRedDot2View:OnHide()
	---从Mgr的VMMap中移除对应的ItemVM
	if self.ItemVM then
		RedDotMgr:RemoveRedDotItemVM(self.ItemVM)
	end
end

function CommonRedDot2View:OnRegisterUIEvent()

end

function CommonRedDot2View:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.RedDotUpdate, self.OnUpdateRedDot)
end

function CommonRedDot2View:OnRegisterBinder()
	if self.ItemVM then
		self:RegisterBinders(self.ItemVM, self.Binders)
	end
end

---是否是自定义节点，自定义节点不走红点配置，不会触发默认隐藏，由对应系统控制
function CommonRedDot2View:SetIsCustomizeRedDot(IsCustomizeRedDot)
	self.IsCustomizeRedDot = IsCustomizeRedDot
end

function CommonRedDot2View:GetIsCustomizeRedDot()
	return self.IsCustomizeRedDot
end

---手动设置红点显隐，一般用于自定义节点
function CommonRedDot2View:SetRedDotUIIsShow(IsShow)
	if self.ItemVM then
		self.ItemVM:SetIsVisible(IsShow)
	end
end

return CommonRedDot2View