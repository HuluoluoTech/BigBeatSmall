cd protofiles
protoc --descriptor_set_out=login.pb login.proto
protoc --descriptor_set_out=header.pb header.proto
protoc --descriptor_set_out=enter.pb enter.proto