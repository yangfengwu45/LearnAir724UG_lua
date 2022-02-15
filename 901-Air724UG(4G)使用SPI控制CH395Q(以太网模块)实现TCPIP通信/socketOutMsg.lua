--- 模块功能：socket客户端数据发送处理
-- @author openLuat
-- @module socketLongConnection.socketOutMsg
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.28


module(...,package.seeall)
--数据发送的消息队列
local msgQueue = {}

--往发送数据队列里面插入数据
function insertMsg(data)
    table.insert(msgQueue,{data=data})
    sys.publish("APP_SOCKET_SEND_DATA") --发布一个通知, 使得接收任务那里不再阻塞;
end

--- 去初始化“socket客户端数据发送”
-- @return 无
-- @usage socketOutMsg.unInit()
function unInit()
    while #msgQueue>0 do
        local outMsg = table.remove(msgQueue,1)
    end
end

--- socket客户端数据发送处理
-- @param socketClient，socket客户端对象
-- @return 处理成功返回true，处理出错返回false
-- @usage socketOutMsg.proc(socketClient)
function proc(socketClient)
    while #msgQueue>0 do
        local outMsg = table.remove(msgQueue,1)
        local result = socketClient:send(outMsg.data)
        if not result then return end
    end
    return true
end
