import os

protoc_login = 'protoc --python_out=./client ./protofiles/login.proto'
val = os.system(protoc_login)
print(val)