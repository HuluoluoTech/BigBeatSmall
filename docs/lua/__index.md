__index 元方法

实现继承。

```lua
local sup = {}
sup["a"] = 1
sup.__index = sup

local sub = {}
setmetatable(sub, sup)

print(sub.a) -- 如果sub没有，则从sup里找
```