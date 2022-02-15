--- 模块功能：socket客户端数据接收处理
-- @author openLuat
-- @module socketLongConnection.socketInMsg
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.28

module(...,package.seeall)

require "socketOutMsg"

--- socket客户端数据接收处理
-- @param socketClient，socket客户端对象
-- @return 处理成功返回true，处理出错返回false
-- @usage socketInMsg.proc(socketClient)
function proc(socketClient)
    local result,data
    while true do
        --超时等待60s 或者 有数据需要发送
        result,data = socketClient:recv(60000,"APP_SOCKET_SEND_DATA")
        --接收到数据
        if result then
            log.info("socketInMsg.proc",data)

            socketOutMsg.insertMsg(data);--返回接收的数据给服务器
        else
            break
        end
    end
	
    return result or data=="timeout" or data=="APP_SOCKET_SEND_DATA"
end
