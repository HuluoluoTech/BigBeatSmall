In Lua, 
* any function is a closure. In a narrower sense, a closure is an anonymous function.
* Closures are first-class: they can be assigned to variables, passed to functions and returned from them.
* 闭包是由函数原型的引用和该函数所需访问的外部局部变量 upvalue 组成。
* upvalue 就是函数引用到的外部变量。

```lua
function simpleCounter()
   local i = 0
   return function () -- anonymous function
      i = i + 1
         return i
      end
   end
c1 = simpleCounter()
   print(c1()) --> 1
   print(c1()) --> 2
```


