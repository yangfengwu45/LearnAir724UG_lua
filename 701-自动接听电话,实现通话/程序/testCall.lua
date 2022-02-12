--- 模块功能：通话功能测试.
-- @author openLuat
-- @module call.testCall
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.20

module(...,package.seeall)
require"cc"
require"audio"
require"common"

--来电铃声播放协程ID
local coIncoming


--- “通话已建立”消息处理函数
-- @string num，建立通话的对方号码
-- @return 无
local function connected(num)
    log.info("testCall.connected")
    coIncoming = nil
    --通话中设置mic增益，必须在通话建立以后设置
    --audio.setMicGain("call",7)
    --通话中音量测试
    audio.setCallVolume(7);--音量设置为最大
    --通话中向对方播放TTS测试
    --audio.play(7,"TTS","通话中TTS测试",7,nil,true,2000)
    --110秒之后主动结束通话
    --sys.timerStart(cc.hangUp,110000,num)
end
--- “通话已结束”消息处理函数
-- @string discReason，通话结束原因值，取值范围如下：
--                                     "CHUP"表示本端调用cc.hungUp()接口主动挂断
--                                     "NO ANSWER"表示呼出后，到达对方，对方无应答，通话超时断开
--                                     "BUSY"表示呼出后，到达对方，对方主动挂断
--                                     "NO CARRIER"表示通话未建立或者其他未知原因的断开
--                                     nil表示没有检测到原因值
-- @return 无
local function disconnected(discReason)
    coIncoming = nil
    log.info("testCall.disconnected",discReason)
    audio.stop()
end

--- “来电”消息处理函数
-- @string num，来电号码
-- @return 无
local function incoming(num)
    log.info("testCall.incoming:"..num)
    
    if not coIncoming then
        coIncoming = sys.taskInit(function()
            --可以先播放完音乐
            -- audio.play(1,"FILE","/lua/call.mp3",i,function() sys.publish("PLAY_INCOMING_RING_IND") end)
            -- sys.waitUntil("PLAY_INCOMING_RING_IND")
            --接听来电
            cc.accept(num)
        end) 
    end
end

--- “通话中收到对方的DTMF”消息处理函数
-- @string dtmf，收到的DTMF字符
-- @return 无
local function dtmfDetected(dtmf)
    log.info("testCall.dtmfDetected",dtmf)
end
--订阅消息的用户回调函数
sys.subscribe("CALL_INCOMING",incoming)
sys.subscribe("CALL_CONNECTED",connected)
sys.subscribe("CALL_DISCONNECTED",disconnected)
cc.dtmfDetect(true)
sys.subscribe("CALL_DTMF_DETECT",dtmfDetected)



