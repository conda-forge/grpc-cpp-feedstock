# this test assumes it is being run in examples/python/helloworld,
# after having generated the helloworld_pb2{,_grpc} modules (see meta.yaml)
import grpc
import helloworld_pb2
import helloworld_pb2_grpc

# run this a couple times because it happens randomly, see
# https://github.com/conda-forge/grpc-cpp-feedstock/issues/281
for _ in range(1000):
    with grpc.insecure_channel('localhost:50051') as channel:
        stub = helloworld_pb2_grpc.GreeterStub(channel)
        response = stub.SayHello(helloworld_pb2.HelloRequest(name='you'))
