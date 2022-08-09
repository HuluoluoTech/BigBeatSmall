-- debug utils

-- package 的搜索路径
function package_path()
	local package_path = package.path
	print("package path: "..package.path)
end
