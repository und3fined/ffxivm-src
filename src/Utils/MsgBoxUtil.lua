--
-- Author: anypkvcai
-- Date: 2020-10-27 15:48:45
-- Description:
--

-- 先不改成局部的，lua在UIViewMgr之前先加载了这个
-- local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType
local DefaultFontSize = 23
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")

---@class MsgBoxUtil
local MsgBoxUtil = {

}


---ShowMessageBoxQuick             			@已废弃 请用ShowMsgBoxTwoOp等接口
---@param Content string          			@弹窗内容
---@param ConfirmBtnText string   			@确认按钮
---@param CancelBtnText string       		@取消按钮
---@param ConfirmBtnCallback function 		@确认回调
---@param CancelBtnCallback function		@取消回调
---@param HideOnClick boolean				@点击蒙版是否关闭窗口
function MsgBoxUtil.MessageBox(Content, ConfirmBtnText, CancelBtnText, ConfirmBtnCallback, CancelBtnCallback, HideOnClick, ShowTime, HideCheckBoxNotAgain)
	local Params = {
		Content = Content,
		ConfirmBtnText = ConfirmBtnText,
		CancelBtnText = CancelBtnText, 
		ConfirmBtnCallback = ConfirmBtnCallback, 
		CancelBtnCallback = CancelBtnCallback,
		HideOnClick = HideOnClick,
		ShowTime = ShowTime,
		HideCheckBoxNotAgain = HideCheckBoxNotAgain,
	}
	_G.UIViewMgr:ShowView(UIViewID.MessageBox, Params)
end


local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local EBtnType = CommonBoxDefine.BtnType

---@class MsgBoxExParams 					@MsgBox额外内容参数包
---@field bUseCloseOnClick boolean			@是否点击按钮自动关闭弹窗，默认是
---@field TipsText string					@提示文本，默认为""且不显示
---@field MaskClickCB function				@点击背景遮罩回调。（和按钮选项一样，若bUseCloseOnClick == true，点击遮罩会响应回调并关闭弹窗）
---@field LeftTime number					@倒计时， 默认不显示
---@field bUseOnLeftTimeClose boolean		@倒计时为零是否自动关闭弹窗，默认是
---@field OnLeftTimeCB function				@倒计时为零回调（只触发一次）
---@field LeftTimeStrFmt string				@倒计时字符串格式
---@field HyperlinkClicked function			@超链接点击事件


---MakeMsgBoxParams             			@构建MsgBox参数包
---@param UIView UIView          			@调用者对象
---@param Title string   					@标题，默认为 ""
---@param Message string       				@文本信息，默认为 ""
---@param LeftCB function 					@左按钮回调
---@param MidCB function					@中间按钮回调
---@param RightCB function					@右按钮回调
---@param BtnUniformType number				@经典按钮风格枚举
---@param LeftBtnName string   				@左按钮名称，默认为国际化字符串 确认
---@param MidBtnName string   				@中间按钮名称，默认为国际化字符串 保持
---@param RightBtnName string   			@右按钮名称，默认为国际化字符串 取消
---@param Params MsgBoxExParams				@额外参数包
function MsgBoxUtil.MakeMsgBoxParams(UIView, Title, Message, LeftCB, MidCB, RightCB, BtnUniformType, LeftBtnName, MiddleBtnName, RightBtnName, Params)
	Params = Params or {}
	local Ret = {
		["UIView"] 				= UIView,
		["Title"] 				= Title,
		["Message"] 			= Message,
		["BtnUniformType"] 		= BtnUniformType,

		["BtnInfo"] = {
			["Name"] = {
				[EBtnType.Left] 	= LeftBtnName or CommonBoxDefine.BtnInitialName[EBtnType.Left],
				[EBtnType.Right] 	= RightBtnName or CommonBoxDefine.BtnInitialName[EBtnType.Right],
				[EBtnType.Middle] 	= MiddleBtnName or CommonBoxDefine.BtnInitialName[EBtnType.Middle],
			},

			["Callback"] = {
				[EBtnType.Left] 	= LeftCB,
				[EBtnType.Right] 	= RightCB,
				[EBtnType.Middle] 	= MidCB,
			},

			["Style"] = {
				[EBtnType.Left] 	= Params.LeftBtnStyle or CommBtnColorType.Normal,
				[EBtnType.Right] 	= Params.RightBtnStyle or CommBtnColorType.Recommend,
				[EBtnType.Middle] 	= Params.MidBtnStyle or CommBtnColorType.Recommend,
			},

			["CounterDown"] = {
				[EBtnType.Left] = Params.LeftBtnCD,
				[EBtnType.Right] = Params.RightBtnCD,
				[EBtnType.Middle] = Params.MidBtnCD,
			}
		},

		-- 处理额外内容
		["bUseCloseOnClick"] 	= Params.bUseCloseOnClick ~= false,
		["bUseTips"] 			= Params.TipsText ~= nil,
		["TipsText"] 			= Params.TipsText or "",
		["MaskClickCB"] 		= Params.MaskClickCB,
		["CloseClickCB"]		= Params.CloseClickCB,
		["LeftTime"] 			= Params.LeftTime,
		--倒计时，但点击OK按钮才开始倒计时；另外配置OnLeftTimeCB处理倒计时结束后做什么事情
		["bRightBtnBeginCountDown"] 	= Params.bRightBtnBeginCountDown,	
		["bUseLeftTime"] 		= Params.LeftTime ~= nil,
		["bUseOnLeftTimeClose"] = Params.bUseOnLeftTimeClose ~= false,
		["LeftTimeStrFmt"] 		= Params.LeftTimeStrFmt or "",
		["HyperlinkClicked"] 	= Params.HyperlinkClicked,
		["bUseNever"] 			= Params.bUseNever,
		["CloseBtnCallback"]	= Params.CloseBtnCallback, -- 因为界面的关闭按钮是个UIBP，需要另外做个回调
		["OnLeftTimeCB"] 		= Params.OnLeftTimeCB,

		["bHideOnClickBG"] 		= Params.bHideOnClickBG,
		["CostItemID"] 			= Params.CostItemID,
		["CostNum"] 			= Params.CostNum,

		["FontSize"]			= Params.FontSize or DefaultFontSize,
		["NeverMindText"]		= Params.NeverMindText or CommonBoxDefine.NeverMindText,
		["HideCloseBtn"]        = Params.HideCloseBtn,
		["ItemResID"]			= Params.ItemResID,
		["TextQuantity"] 		= Params.TextQuantity,
		["RightBtnOpState"] 	= Params.RightBtnOpState,
		["CostColor"] 			= Params.CostColor,
		["TextSpentTotal"] 		= Params.TextSpentTotal,
		["TextSpentTotalColor"] = Params.TextSpentTotalColor,
		["MoneyData"]           = Params.MoneyData,
	}

	return Ret
end

function MsgBoxUtil.ShowMsgBox(UIView ,Title, Message, Params)
	local BoxParams = MsgBoxUtil.MakeMsgBoxParams(UIView, Title, Message, nil, nil, nil, CommonBoxDefine.BtnUniformType.OneOpLeft, nil, nil, nil, Params)
	return _G.UIViewMgr:ShowView(UIViewID.CommonMsgBox, BoxParams)
end


---ShowMsgBoxTwoOp             				@显示双选弹窗
---@param UIView UIView          			@调用者对象
---@param Title string   					@标题，默认为 ""
---@param Message string       				@文本信息，默认为 ""
---@param RightCB function					@右按钮回调
---@param LeftCB function 					@左按钮回调
---@param RightBtnName string   			@右按钮名称，默认为国际化字符串 确认
---@param LeftBtnName string   				@左按钮名称，默认为国际化字符串 取消
---@param Params MsgBoxExParams				@额外参数包
---@param CallbackOnHide function | nil
function MsgBoxUtil.ShowMsgBoxTwoOp(UIView ,Title, Message, RightCB, LeftCB, LeftBtnName, RightBtnName, Params, CallbackOnHide)
	local BoxParams = MsgBoxUtil.MakeMsgBoxParams(UIView, Title, Message, LeftCB, nil, RightCB, CommonBoxDefine.BtnUniformType.TwoOp, LeftBtnName, nil, RightBtnName, Params)
	BoxParams.CallbackOnHide = CallbackOnHide
	return _G.UIViewMgr:ShowView(UIViewID.CommonMsgBox, BoxParams)
end
  
---ShowMsgBoxOneOpRight             		@显示单选确定风格弹窗
---@param UIView UIView          			@调用者对象
---@param Title string   					@标题，默认为 ""
---@param Message string       				@文本信息，默认为 ""
---@param Callback function					@按钮回调
---@param BtnName string   					@按钮名称，默认为国际化字符串 确认
---@param Params MsgBoxExParams				@额外参数包
function MsgBoxUtil.ShowMsgBoxOneOpRight(UIView, Title, Message, Callback, BtnName, Params)
	local BoxParams = MsgBoxUtil.MakeMsgBoxParams(UIView, Title, Message, nil, nil, Callback, CommonBoxDefine.BtnUniformType.OneOpRight, nil, nil, BtnName, Params)
	return _G.UIViewMgr:ShowView(UIViewID.CommonMsgBox, BoxParams)
end

---ShowLongMsgBoxOneOpRight             	@显示单选确定风格弹窗
---@param UIView UIView          			@调用者对象
---@param Title string   					@标题，默认为 ""
---@param Message string       				@文本信息，默认为 ""
---@param Callback function					@按钮回调
---@param BtnName string   					@按钮名称，默认为国际化字符串 确认
---@param Params MsgBoxExParams				@额外参数包
function MsgBoxUtil.ShowLongMsgBoxOneOpRight(UIView, Title, Message, Callback, BtnName, Params)
	local BoxParams = MsgBoxUtil.MakeMsgBoxParams(UIView, Title, Message, nil, nil, Callback, CommonBoxDefine.BtnUniformType.OneOpRight, nil, nil, BtnName, Params)
	return _G.UIViewMgr:ShowView(UIViewID.CommonLongMsgBox, BoxParams)
end

---ShowMsgBoxOneOpLeft             			@显示单选取消风格弹窗
---@param UIView UIView          			@调用者对象
---@param Title string   					@标题，默认为 ""
---@param Message string       				@文本信息，默认为 ""
---@param Callback function					@按钮回调
---@param BtnName string   					@按钮名称，默认为国际化字符串 取消
---@param Params MsgBoxExParams				@额外参数包
function MsgBoxUtil.ShowMsgBoxOneOpLeft(UIView, Title, Message, Callback, BtnName, Params)
	local BoxParams = MsgBoxUtil.MakeMsgBoxParams(UIView, Title, Message, Callback, nil, nil, CommonBoxDefine.BtnUniformType.OneOpLeft, BtnName, nil, nil, Params)
	_G.UIViewMgr:ShowView(UIViewID.CommonMsgBox, BoxParams)
end

---ShowMsgBoxThreeOp             			@显示三选弹窗
---@param UIView UIView          			@调用者对象
---@param Title string   					@标题，默认为 ""
---@param Message string       				@文本信息，默认为 ""
---@param LeftCB function 					@左按钮回调
---@param MidCB function					@中间按钮回调
---@param RightCB function					@右按钮回调
---@param LeftBtnName string   				@左按钮名称，默认为国际化字符串 确认
---@param MidBtnName string   				@中间按钮名称，默认为国际化字符串 保持
---@param RightBtnName string   			@右按钮名称，默认为国际化字符串 取消
---@param Params MsgBoxExParams				@额外参数包
function MsgBoxUtil.ShowMsgBoxThreeOp(UIView, Title, Message, RightCB, MidCB, LeftCB, LeftBtnName, MiddleBtnName, RightBtnName, Params)
	local BoxParams = MsgBoxUtil.MakeMsgBoxParams(UIView, Title, Message, LeftCB, MidCB, RightCB, CommonBoxDefine.BtnUniformType.ThreeOp, LeftBtnName, MiddleBtnName, RightBtnName, Params)
	_G._G.UIViewMgr:ShowView(UIViewID.CommonMsgBox, BoxParams)
end

---ShowMsgBoxOneOpRightMustClick  @显示单选确定风格弹窗，只能点击关闭
---@param UIView UIView          			@调用者对象
---@param Title string   					@标题，默认为 ""
---@param Message string       				@文本信息，默认为 ""
---@param Callback function					@按钮回调
---@param BtnName string   					@按钮名称，默认为国际化字符串 确认
---@param Params MsgBoxExParams				@额外参数包
function MsgBoxUtil.ShowMsgBoxOneOpRightMustClick(UIView, Title, Message, Callback, BtnName, Params)
	local BoxParams = MsgBoxUtil.MakeMsgBoxParams(UIView, Title, Message, nil, nil, Callback, CommonBoxDefine.BtnUniformType.OneOpRight, nil, nil, BtnName, Params)
	_G.UIViewMgr:ShowView(UIViewID.CommonMsgBoxMustClick, BoxParams)
end

---CloseMsgBox             					@关闭弹窗
function MsgBoxUtil.CloseMsgBox()
	_G._G.UIViewMgr:HideView(UIViewID.CommonMsgBox)
end


function MsgBoxUtil.MakeCostBoxParams(UIView, Title, Message, ConsumeItemID, ConsumeNum, CostItemID, CostNum, LeftCB, RightCB, 
															LeftBtnName, RightBtnName, CostStyle, Params)
	Params = Params or {}
	local Ret = {
		["UIView"] 				= UIView,
		["Title"] 				= Title,
		["Message"] 			= Message,
		["CostStyle"] 			= CostStyle,

		["ConsumeItemID"] 		= ConsumeItemID,
		["ConsumeNum"] 			= ConsumeNum,

		["CostItemID"] 			= ConsumeItemID,
		["CostNum"] 			= ConsumeNum,

		["BtnInfo"] = {
			["Name"] = {
				[EBtnType.Left] 	= LeftBtnName or CommonBoxDefine.BtnInitialName[EBtnType.Left],
				[EBtnType.Right] 	= RightBtnName or CommonBoxDefine.BtnInitialName[EBtnType.Right],
			},

			["Callback"] = {
				[EBtnType.Left] 	= LeftCB,
				[EBtnType.Right] 	= RightCB,
			},

			["Style"] = {
				[EBtnType.Left] 	= Params.LeftBtnStyle or CommBtnColorType.Normal,
				[EBtnType.Right] 	= Params.RightBtnStyle or CommBtnColorType.Normal,
			},

			["CounterDown"] = {
				[EBtnType.Left] = Params.LeftBtnCD,
				[EBtnType.Right] = Params.RightBtnCD,
			}
		},
	}

	return Ret
end

function MsgBoxUtil.ShowCostBox(UIView, Title, ConsumeItemID, ConsumeNum, CostItemID, CostNum, CB, BtnName, Params)
	local BoxParams = MsgBoxUtil.MakeCostBoxParams(UIView, Title, "", ConsumeItemID, ConsumeNum, CostItemID, CostNum, 
														nil, CB , "", BtnName, CommonBoxDefine.CostStyle.Cost, Params)
	_G._G.UIViewMgr:ShowView(UIViewID.CommonCostBox, BoxParams)
end

function MsgBoxUtil.ShowCostBoxInstead(UIView, Title, ConsumeItemID, ConsumeNum, CB, BtnName, Params)
	local BoxParams = MsgBoxUtil.MakeCostBoxParams(UIView, Title, "", ConsumeItemID, ConsumeNum, nil, nil, 
														nil, CB , "", BtnName, CommonBoxDefine.CostStyle.Instead, Params)
	_G._G.UIViewMgr:ShowView(UIViewID.CommonCostBox, BoxParams)
end

function MsgBoxUtil.ShowCostBoxSimple(UIView, Title, Message, ConsumeItemID, ConsumeNum, LeftCB, RightCB, LeftBtnName, RightBtnName, Params)
	local BoxParams = MsgBoxUtil.MakeCostBoxParams(UIView, Title, Message, ConsumeItemID, ConsumeNum, nil, nil, 
														LeftCB, RightCB , LeftBtnName, RightBtnName, CommonBoxDefine.CostStyle.Simple, Params)
	_G._G.UIViewMgr:ShowView(UIViewID.CommonCostBox, BoxParams)
end

return MsgBoxUtil