--author : haialexzhou
--brief : 逆波兰式（Reverse Polish notation，RPN，或后缀表达式）生成器，用于解析条件表达式, 如："~66|((99|123)&(456|789))"

local LuaClass = require ("Core/LuaClass")
local ProtoRes = require ("Protocol/ProtoRes")

--模拟一个栈结构
local RPNStack = LuaClass()

function RPNStack:Ctor()
    self.StackList = {}
end  
  
function RPNStack:Reset()
    self:Ctor()
end
  
function RPNStack:Pop()
    if #self.StackList == 0 then  
        return
    end
      
    return table.remove(self.StackList)
end  
  
function RPNStack:Push(T)
    table.insert(self.StackList, T)
end  
  
function RPNStack:Count()
    return #self.StackList
end

function RPNStack:Empty()
    return #self.StackList == 0
end

function RPNStack:Top()
    if #self.StackList == 0 then
        return nil
    end

    return self.StackList[#self.StackList]
end

--表达式节点
local BS_UNIT_DIGIT <const> = ProtoRes.bs_unit_type.BS_UNIT_DIGIT
local BS_UNIT_OPER <const> = ProtoRes.bs_unit_type.BS_UNIT_OPER

local CreateExpNode = function(NodeType, Digit, Oper)
    return {
        NodeType = NodeType or BS_UNIT_DIGIT,
        Digit = Digit or 0,
        Oper = Oper or "",
    }
end

--逆波兰式生成器
local RPNGenerator = LuaClass()
RPNGenerator.RPNExpressionCache = {}
--解析表达式(中缀表达式)
local function _ParseExpression(ExpressionString)
    local NodeList = {}
    if (not ExpressionString) then
        return NodeList
    end

    local bIsDigit = false
    local Digit = 0

    -- 比for + string.sub的方式快一点
    for Char in string.gmatch(ExpressionString, ".") do
        if (Char ~= ' ') then
            if (Char >= '0' and Char <= '9') then
                if not bIsDigit then
                    bIsDigit = true
                    Digit = 0
                end
                Digit = Digit * 10 + Char - '0'
            else
                if bIsDigit then
                    local Node = CreateExpNode(BS_UNIT_DIGIT, Digit)
                    table.insert(NodeList, Node)
                    bIsDigit = false
                end
                
                if (Char == '&' or Char == '|' or Char == '~' or Char == '(' or Char == ')') then
                    local Node = CreateExpNode(BS_UNIT_OPER, nil, Char)
                    table.insert(NodeList, Node)
                end
                
            end
        end
    end

    if bIsDigit then
        local Node = CreateExpNode(BS_UNIT_DIGIT, Digit)
        table.insert(NodeList, Node)
    end

    return NodeList
end

--生成逆波兰式(后缀表达式)
local function _GenerateRPNExpression(ExpressionString)
    if RPNGenerator.RPNExpressionCache[ExpressionString] then
        return RPNGenerator.RPNExpressionCache[ExpressionString]
    end

    local RPNNodeList = {}
    local NodeList = _ParseExpression(ExpressionString)
    local OperStack = RPNStack.New()

    for _, Node in ipairs(NodeList) do
        if (Node.NodeType == ProtoRes.bs_unit_type.BS_UNIT_DIGIT) then
            table.insert(RPNNodeList, Node)
        else
            local Oper = Node.Oper
            if (Oper == '(') then
                OperStack:Push(Node)

            elseif (Oper == '&' or Oper == '|') then
                while(not OperStack:Empty())
                do
                    local TopNode = OperStack:Top()
                    if (TopNode.Oper ~= '(') then
                        table.insert(RPNNodeList, TopNode)
                        OperStack:Pop()
                    else
                        break
                    end
                end
                OperStack:Push(Node)

            elseif (Oper == '~') then
                while(not OperStack:Empty())
                do
                    local TopNode = OperStack:Top()
                    if (TopNode.Oper == '~') then
                        table.insert(RPNNodeList, TopNode)
                        OperStack:Pop()
                    else
                        break
                    end
                end
                OperStack:Push(Node)

            elseif (Oper == ')') then
                while(not OperStack:Empty())
                do
                    local TopNode = OperStack:Top()
                    if (TopNode.Oper ~= '(') then
                        table.insert(RPNNodeList, TopNode)
                        OperStack:Pop()
                    else
                        break
                    end
                end
                OperStack:Pop()
            end
        end
    end


    while(not OperStack:Empty())
    do
        table.insert(RPNNodeList, OperStack:Top())
        OperStack:Pop()
    end

    RPNGenerator.RPNExpressionCache[ExpressionString] = RPNNodeList
    return RPNNodeList
end


--执行逆波兰式，返回执行结果
--ExpressionString 表达式字符串
--BoolFunc: 返回值是bool的函数
function RPNGenerator:ExecuteRPNBoolExpression(ExpressionString, Executor, Target, BoolFunc)
    if (not ExpressionString) then
        return false
    end
    local Expression = tonumber(ExpressionString)
    if (Expression ~= nil) then
        return BoolFunc(Executor, Target, Expression)
    end

    local RPNNodeList = _GenerateRPNExpression(ExpressionString) -- 这里可以直接获取到cache的逆波兰式，不用重新生成
    local ExecStack = RPNStack.New() --存放函数执行结果
    for _, Node in ipairs(RPNNodeList) do
        if (Node.NodeType == ProtoRes.bs_unit_type.BS_UNIT_DIGIT) then
            local Result = BoolFunc(Executor, Target, Node.Digit)
            ExecStack:Push(Result)

        elseif (Node.NodeType == ProtoRes.bs_unit_type.BS_UNIT_OPER) then
            if (Node.Oper == '~') then
                local Result = ExecStack:Pop()
                ExecStack:Push(not Result)

            elseif (Node.Oper == '&') then
                local Result1 = ExecStack:Pop()
                local Result2 = ExecStack:Pop()
                ExecStack:Push(Result1 and Result2)

            elseif (Node.Oper == '|') then
                local Result1 = ExecStack:Pop()
                local Result2 = ExecStack:Pop()
                ExecStack:Push(Result1 or Result2)
            end
        end
    end

    return ExecStack:Top()
end

--执行逆波兰式，返回执行结果
--ExpressionString 表达式字符串
--ListFunc: 返回值是List的函数，目前不支持逻辑关系，只返回第一个ID对应的List
function RPNGenerator:ExecuteRPNListExpression(ExpressionString, Executor, TargetList, ListFunc)
    local RPNNodeList = _GenerateRPNExpression(ExpressionString)
    local ExecStack = RPNStack.New() --存放函数执行结果
    for _, Node in ipairs(RPNNodeList) do
        if (Node.NodeType == ProtoRes.bs_unit_type.BS_UNIT_DIGIT) then
            local Result = ListFunc(Node.Digit, TargetList, Executor)
            ExecStack:Push(Result)

        elseif (Node.NodeType == ProtoRes.bs_unit_type.BS_UNIT_OPER) then
            if (Node.Oper == '~') then
                ExecStack:Pop()
                ExecStack:Push({}) --不取任何值

            elseif (Node.Oper == '&' or Node.Oper == '|') then
                local Result = ExecStack:Pop()
                ExecStack:Pop()
                ExecStack:Push(Result) --只取第一个List
            end
        end
    end

    return ExecStack:Top()
end

function RPNGenerator:ClearCache()
    self.RPNExpressionCache = {}
end

return RPNGenerator