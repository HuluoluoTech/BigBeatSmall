skynet.call
它会在内部生成一个唯一 session ，并向 address 提起请求，并阻塞等待对 session 的回应

skynet.send
把一条类别为 typename 的消息发送给 address

skynet.start(...)
每个 skynet 服务都必须有一个启动函数。你必须主动调用 skynet.start(function() ... end) 。

skynet.fork(func, ...) 
从功能上，它等价于 skynet.timeout(0, function() func(...) end) 但是比 timeout 高效一点。因为它并不需要向框架注册一个定时器。

skynet.address(address) 
用于把一个地址数字转换为一个可用于阅读的字符串。

skynet.register(name) 
可以为自己注册一个别名。

skynet.monitor 
给当前 skynet 进程设置一个全局的服务监控。

skynet.uniqueservice
只需要一个服务, 默认情况下，uniqueservice 是不跨节点的，如果你需要整个网络有唯一的服务，那么可以在调用 uniqueservice 的参数前加一个 true ，表示这是一个全局服务。
