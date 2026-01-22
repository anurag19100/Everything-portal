# Shared Components

This directory contains shared code, configurations, and protocol definitions used across multiple services.

## Directory Structure

```
shared/
├── proto/              # gRPC protocol definitions
├── libraries/          # Shared code libraries
└── configs/           # Shared configuration files
```

## Protocol Buffers (gRPC)

### Overview

Protocol Buffer definitions for service-to-service communication via gRPC.

### Available Proto Files

#### product.proto
Defines the Product service and message types for product management operations.

**Service**: `ProductService`
- GetProduct
- ListProducts
- CreateProduct
- UpdateProduct
- DeleteProduct

**Messages**:
- Product
- GetProductRequest/Response
- ListProductsRequest/Response
- CreateProductRequest
- UpdateProductRequest
- DeleteProductRequest/Response

#### common.proto
Common message types and services used across multiple services.

**Services**:
- HealthService - Common health check interface

**Messages**:
- HealthCheckRequest/Response
- ErrorResponse
- PageRequest/PageInfo

### Generating Code

#### For Java (Spring Boot):

Add to `pom.xml`:
```xml
<dependency>
    <groupId>net.devh</groupId>
    <artifactId>grpc-spring-boot-starter</artifactId>
    <version>2.15.0.RELEASE</version>
</dependency>
```

Add protobuf plugin:
```xml
<plugin>
    <groupId>org.xolstice.maven.plugins</groupId>
    <artifactId>protobuf-maven-plugin</artifactId>
    <version>0.6.1</version>
    <configuration>
        <protocArtifact>com.google.protobuf:protoc:3.21.7:exe:${os.detected.classifier}</protocArtifact>
        <pluginId>grpc-java</pluginId>
        <pluginArtifact>io.grpc:protoc-gen-grpc-java:1.51.0:exe:${os.detected.classifier}</pluginArtifact>
        <protoSourceRoot>${project.basedir}/../../shared/proto</protoSourceRoot>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>compile</goal>
                <goal>compile-custom</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

Generate:
```bash
cd apps/backend/java-service
mvn clean compile
```

#### For Go:

Install protoc compiler and Go plugins:
```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

Generate:
```bash
protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    shared/proto/*.proto
```

#### For Python:

Install dependencies:
```bash
pip install grpcio grpcio-tools
```

Generate:
```bash
python -m grpc_tools.protoc \
    -I./shared/proto \
    --python_out=./apps/backend/python-service/app/grpc \
    --grpc_python_out=./apps/backend/python-service/app/grpc \
    shared/proto/*.proto
```

### Using gRPC Services

#### Java Server Example:

```java
@GrpcService
public class ProductGrpcService extends ProductServiceGrpc.ProductServiceImplBase {

    @Override
    public void getProduct(GetProductRequest request, StreamObserver<ProductResponse> responseObserver) {
        Product product = productService.findById(request.getId());

        ProductResponse response = ProductResponse.newBuilder()
            .setProduct(product)
            .build();

        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }
}
```

#### Java Client Example:

```java
@Service
public class ProductClient {

    @GrpcClient("product-service")
    private ProductServiceGrpc.ProductServiceBlockingStub productServiceStub;

    public Product getProduct(Long id) {
        GetProductRequest request = GetProductRequest.newBuilder()
            .setId(id)
            .build();

        ProductResponse response = productServiceStub.getProduct(request);
        return response.getProduct();
    }
}
```

#### Go Client Example:

```go
conn, err := grpc.Dial("java-service:9090", grpc.WithInsecure())
if err != nil {
    log.Fatal(err)
}
defer conn.Close()

client := pb.NewProductServiceClient(conn)
response, err := client.GetProduct(context.Background(), &pb.GetProductRequest{
    Id: 1,
})
```

#### Python Client Example:

```python
import grpc
from app.grpc import product_pb2, product_pb2_grpc

channel = grpc.insecure_channel('java-service:9090')
stub = product_pb2_grpc.ProductServiceStub(channel)

response = stub.GetProduct(product_pb2.GetProductRequest(id=1))
print(response.product)
```

## Shared Libraries

Place reusable code libraries here that are used by multiple services.

### Examples:

- Authentication utilities
- Common validators
- Date/time helpers
- Error handling utilities
- Logging formatters

### Structure:

```
libraries/
├── javascript/         # Shared JavaScript/TypeScript code
│   ├── validators/
│   └── utils/
├── python/            # Shared Python code
│   ├── validators/
│   └── utils/
├── java/              # Shared Java code
│   └── common/
└── go/                # Shared Go code
    └── common/
```

## Shared Configs

Common configuration files used across services.

### Examples:

- Environment variable templates
- ESLint/Prettier configurations
- TypeScript configurations
- Testing configurations

## Best Practices

1. **Version Control**: Use semantic versioning for proto files
2. **Backward Compatibility**: Avoid breaking changes in proto definitions
3. **Documentation**: Document all proto messages and services
4. **Testing**: Test generated code with all target languages
5. **Code Generation**: Automate code generation in CI/CD pipeline
6. **Naming**: Follow protobuf style guide for naming conventions
7. **Organization**: Group related messages and services together
8. **Comments**: Add comments to explain complex types and fields

## References

- [Protocol Buffers Guide](https://developers.google.com/protocol-buffers)
- [gRPC Documentation](https://grpc.io/docs/)
- [gRPC Spring Boot Starter](https://github.com/yidongnan/grpc-spring-boot-starter)
