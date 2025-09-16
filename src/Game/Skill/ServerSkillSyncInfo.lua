local LuaClass = require("Core/LuaClass")

local ServerSkillSyncInfo = LuaClass()


function ServerSkillSyncInfo:Ctor()
    --存储被修正的技能消耗信息
    --{SkillID = {Attr1 = {Min, Value}, {Attr2 = {Min, Value}}}}
    self.SkillCostList = {}

    --技能吟唱急速修正列表
    --当吟唱开始时，根据列表中技能急速值进行修正
    --{SkillID = Value}
    self.ReviseSkillSingList = {}

    --技能急速修正列表，虚拟吟唱用
    self.ReviseSkillActionList = {}

end







return ServerSkillSyncInfo