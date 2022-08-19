import os

protoc_login = 'protoc --python_out=./client ./protofiles/login.proto'
protoc_header = 'protoc --python_out=./client ./protofiles/header.proto'
enter_header = 'protoc --python_out=./client ./protofiles/enter.proto'
val = os.system(protoc_login)
val = os.system(protoc_header)
val = os.system(enter_header)

print("Generated Protocs Done!")