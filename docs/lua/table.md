LUA中最基本的结构是table，所以需要用table来描述[对象的属性]。
lua 中的 function 可以用来表示方法。
那么LUA中的类可以通过 table + function 模拟出来。

```lua
Account = {balance = 0}
function Account.withdraw (v)
    Account.balance = Account.balance - v
end
```

* 创建了一个新的函数，并且保存在Account对象的withdraw域内

```lua
Account.withdraw(100.00)
```

---

