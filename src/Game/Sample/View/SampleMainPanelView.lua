---
--- Author: anypkvcai
--- DateTime: 2022-09-19 19:32
--- Description:
---

-- 需要通过UIViewMgr:ShowView显示的界面 才需要配置ViewID和UIViewConfig 其他嵌套的子蓝图不用配置
--UI开发流程青参考下面wiki
--https://iwiki.woa.com/pages/viewpage.action?pageId=336458922

--UMG蓝图改名后，要重启编辑器，不然运行游戏可能有lua报错

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIViewMgr = require("UI/UIViewMgr")
local SampleConfig = require("Game/Sample/SampleConfig")

---@class SampleMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field PanelSample UFCanvasPanel
---@field TableViewTab UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SampleMainPanelView = LuaClass(UIView, true)

function SampleMainPanelView:Ctor()
	--下面代码是"CreateLuaFile"自动生成的 只包含IsVariable勾选了的控件 如果lua用不到的变量请不要勾选
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.PanelSample = nil
	--self.TableViewTab = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	self.CurrentPage = nil
end

function SampleMainPanelView:OnRegisterSubView()
	-- SubView是嵌套的子蓝图 下面代码是"CreateLuaFile"自动生成的 如果蓝图里子蓝图有增减 需要重新生成
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SampleMainPanelView:OnInit()
	--self.Params参数是ShowView时传递进来的，OnInit时还无法获取到

	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnItemSelectChanged, false)

	--Binder最好在OnInit函数中初始化 避免每次从缓存中获取时重复创建
	self.Binders = {

	}
end

function SampleMainPanelView:OnDestroy()

end

function SampleMainPanelView:OnShow()
	self.TableViewAdapter:UpdateAll(SampleConfig)
	self.TableViewAdapter:SetSelectedIndex(1)
end

function SampleMainPanelView:OnHide()
	self:RecycleCurrentPage()
end

function SampleMainPanelView:OnRegisterUIEvent()
	--UI事件只能在此注册
	--事件会自动反注册 UI事件在界面销毁时反注册 Game事件界面关闭时反注册，写错可能导致界面显示时事件重复注册
end

function SampleMainPanelView:OnRegisterGameEvent()
	--Game事件只能在此注册
	--事件会自动反注册 UI事件在界面销毁时反注册 Game事件界面关闭时反注册，写错可能导致界面显示时事件重复注册
end

function SampleMainPanelView:OnRegisterBinder()
	-- Binder在此注册 OnRegisterBinder函数调用顺序在OnInit之后 在OnShow之前

	--self:RegisterBinders(XXVM, self.Binders)
end

function SampleMainPanelView:RecycleCurrentPage()
	local CurrentPage = self.CurrentPage
	if nil ~= CurrentPage then
		--从UMG父窗口移除
		CurrentPage:RemoveFromParent()

		--放回缓存池 从Lua父窗口列表里移除
		UIViewMgr:RecycleView(CurrentPage)

		self.CurrentPage = nil
	end
end

---OnItemSelectChanged
---@param Index number
---@param ItemData any
---@param ItemView UIView
function SampleMainPanelView:OnItemSelectChanged(Index, ItemData, ItemView)
	self:RecycleCurrentPage()
	local BPName = ItemData.BPName
	self.CurrentPage = UIViewMgr:CreateViewByName(BPName, nil, self, true, false)

	--添加到UMG父窗口
	self.PanelSample:AddChildToCanvas(self.CurrentPage)
	self.CurrentPage:ShowView()
end

return SampleMainPanelView