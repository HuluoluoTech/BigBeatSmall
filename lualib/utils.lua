-- debug utils

-- print masco
function print_mascot()
    print("\n\n Welcome to Game...\n\n")
end

-- package 的搜索路径
function package_path()
	local package_path = package.path
	print("package path: "..package.path)
end
