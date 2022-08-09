各个服务的说明

* gateway
用来处理客户端链接的服务， 一个node可以开多个gateway。

* login
登录服务， 一个node可以开多个login。

* agent
每个客户端对弈一个agent，负责角色的数据加载，存储，逻辑等。 agent必须和客户端链接（gateway）处在同一个node。

* agentmgr
记录每个agent，避免重复登录一个账号。

* nodemgr
每个节点对应一个，用于管理该节点和监控

* scene
场景服务，处理战斗逻辑服务，每局游戏由一个scene服务负责。

