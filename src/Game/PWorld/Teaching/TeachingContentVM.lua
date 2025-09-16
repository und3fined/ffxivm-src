local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local PWorldTeachingProjectItemViewVM = require("Game/Pworld/Teaching/Item/PWorldTeachingProjectItemViewVM")
local ProtoRes = require("Protocol/ProtoRes")
local TeachingType = require("Game/Pworld/Teaching/TeachingType")

local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO
local TeachingMgr = _G.TeachingMgr

local TeachingContentVM = LuaClass(UIViewModel)

function TeachingContentVM:Ctor()
    self.Content = ""
    self.TableViewProjectVMList = UIBindableList.New(PWorldTeachingProjectItemViewVM)

    self.ItemList = nil
    self.CurrentItem = 0
end

function TeachingContentVM:OnBegin()

end

function TeachingContentVM:UpdateContent(InteractiveID)
    local ItemInfo = TeachingMgr:FindItemInfo(InteractiveID)
    if ItemInfo == nil then
        FLOG_INFO("TeachingContentVM Invalid InteractiveID:%d", InteractiveID)
        return
    end

    self.CurrentItem = 1
    self.Content = ItemInfo.Content
    self.ItemList = ItemInfo.ItemList

    -- 初始化State
    for i = 1, #self.ItemList do
        if i == self.CurrentItem then
            self.ItemList[i].State = TeachingType.Item_State.Ongoing
        else
            self.ItemList[i].State = TeachingType.Item_State.UnOpened
        end
    end

    -- 刷新VMList
    self:RefreshContent()
end

function TeachingContentVM:RefreshContent()
	self.TableViewProjectVMList:UpdateByValues(self.ItemList)
end

function TeachingContentVM:UpdateItemState(UIType, ResultType)
    if UIType == ProtoRes.action_change_ui_type.ACTION_CHANGE_UI_TYPE_SPECIAL_TRAINING_SIGN then
		if ResultType == ProtoRes.action_challenge_result_type.ACTION_CHALLENGE_RESULT_TYPE_PASS then           -- 通过挑战
            --FLOG_INFO("TeachingContentVM GoToNextItem")
            self:GoToNextItem()
		elseif ResultType == ProtoRes.action_challenge_result_type.ACTION_CHALLENGE_RESULT_TYPE_FAILED then     -- 未通过挑战
            --FLOG_INFO("TeachingContentVM ChallengeFailed")
            self:ChallengeFailed()
		elseif ResultType == ProtoRes.action_challenge_result_type.ACTION_CHALLENGE_RESULT_TYPE_PASS_ALL then   -- 通过全部挑战
            --FLOG_INFO("TeachingContentVM ChallengeSuccess")
            self:CompletedAllItem()
		end
    end
end

function TeachingContentVM:GoToNextItem()
    local LastItem = self.ItemList[self.CurrentItem]
    if LastItem then
        LastItem.State = TeachingType.Item_State.Completed
    end

    self.CurrentItem = self.CurrentItem + 1

    local NewItem = self.ItemList[self.CurrentItem]
    if NewItem then
        NewItem.State = TeachingType.Item_State.Ongoing
    end
end

function TeachingContentVM:ChallengeFailed()
    TeachingMgr:OnShowMainWindow()
    TeachingMgr:FinishCurrentChallenge()
end

function TeachingContentVM:CompletedAllItem()
    for _,Item in ipairs(self.ItemList) do
        Item.State = TeachingType.Item_State.Completed
    end
    TeachingMgr:OnShowMainWindow()
    TeachingMgr:FinishCurrentChallenge()
end

return TeachingContentVM