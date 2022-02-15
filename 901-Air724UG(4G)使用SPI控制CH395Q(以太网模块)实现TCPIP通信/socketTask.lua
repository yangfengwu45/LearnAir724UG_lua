--- 模块功能：socket长连接功能测试.
-- 与服务器连接成功后
--
-- 每隔10秒钟发送一次"heart data\r\n"字符串到服务器
--
-- 每隔20秒钟发送一次"location data\r\n"字符串到服务器
--
-- 与服务器断开连接后，会自动重连
-- @author openLuat
-- @module socketLongConnection.testSocket1
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.27
module(..., package.seeall)
require "link"
require "socket"
require "socketOutMsg"
require "socketInMsg"
require "http"
local ready = false


pmd.ldoset(15,pmd.LDO_VLCD) --咱使用了GPIO2和GPIO3, 把其引脚电压设置为输出3.几伏

--- socket连接是否处于激活状态
-- @return 激活状态返回true，非激活状态返回false
-- @usage socketTask.isReady()
function isReady()
    return ready
end
local date = {
    mode = 1, -- 1表示客户端；2表示服务器；默认为1
    intPin = pio.P0_2, -- 以太网芯片中断通知引脚
    rstPin = pio.P0_3, -- 复位以太网芯片引脚
    powerFunc=function ( state )
        if state then --下面是使用了GPIO7引脚控制了模组的TX引脚选择SPI模式;咱直接把TX接GND了,就是直接SPI模式了.所以不需要使用引脚控制了
            -- local setGpioFnc_TX = pins.setup(pio.P0_7, 0)
            -- pmd.ldoset(15, pmd.LDO_VMMC)
        else
            -- pmd.ldoset(0, pmd.LDO_VMMC)
            -- local setGpioFnc_TX = pins.setup(pio.P0_7, 1)
        end
    end,
    spi = {spi.SPI_1, 0, 0, 8, 800000} -- SPI通道参数，id,cpha,cpol,dataBits,clock，默认spi.SPI_1,0,0,8,800000
}

-- 启动socket客户端任务
sys.taskInit(function()
    local retryConnectCnt = 0

    sys.wait(6000)
    link.openNetwork(link.CH395, date)
    while true do
        if not socket.isReady() then
            retryConnectCnt = 0
            -- 等待网络环境准备就绪，超时时间是5分钟
            sys.waitUntil("IP_READY_IND", 300000)
        end
        if socket.isReady() then
            -- 创建一个socket tcp客户端
            local socketClient = socket.tcp()
            -- 阻塞执行socket connect动作，直至成功
            if socketClient:connect("192.168.1.93", "8888") then
                retryConnectCnt = 0
                ready = true

                -- 循环处理接收和发送的数据
                while true   do
                    if not socketInMsg.proc(socketClient) then
                        log.error("socketTask.socketInMsg.proc error")
                        break
                    end
                    if not socketOutMsg.proc(socketClient) then
                        log.error("socketTask.socketOutMsg proc error")
                        break
                    end
                end
                socketOutMsg.unInit()

                ready = false
            else
                retryConnectCnt = retryConnectCnt + 1
            end
            -- 断开socket连接
            log.info('socket close')
            socketClient:close()
            if retryConnectCnt >= 5 then
                link.shut()
                retryConnectCnt = 0
            end
            sys.wait(5000)
        else
            link.closeNetWork()
            sys.wait(20000)
            link.openNetwork(link.CH395, date)
        end
    end
end)
