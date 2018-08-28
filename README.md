# MRDependencyContainer
Simple Dependency Container.

### Why?
One of problems that we struggled with was the lack of control over modules initialisation. For example a service initialised in one part of the application required some dependency that was created in the another part. Also both services must be initialised after service *X* was initialised. 

In `MRDependencyContainer` you define a factory (`DependencyAssembler`) which creates the dependency. Then when the container is setup it uses Assemblers to build these dependencies. This way you have one place to register and create services and control when in the application lifecycle they are created.

## Features

* Very small and simple.
* Supports Obj-C
* Specialised classes to define a process of creating dependency ('DependencyAssembler').
* You decide when, in the application life cycle, services are created. 

## Installing

### CocoaPods

```ruby
pod 'MRDependencyContainer'
```

### Usage

#### Swift

A services registration and the container setup.

```swift
import MRDependencyContainer

let container = DependencyContainer()
        
let assembler = DefaultDependencyAssembler(type: TestService.self) { container -> TestService in
    return TestService()
})
container.register(assembler)

container.setup()

```

Resolving dependencies

```swift

let service = container.resolve() as TestService?

```

#### ObjC

```objc
@import MRDependencyContainer;

DependencyContainer container = [[DependencyContainer alloc] init];
        
DefaultLegacyDependencyAssembler *assembler = [DefaultLegacyDependencyAssembler createWithType:[TestService class] andBlock:^ id (DependencyContainer *container){
    return TestService();
}];

[container register:assembler];

[container setup];

```

Resolving dependencies

```objc

TestService *service = [container resolveByClass:TestService.class];

```


## Limitations
* Resolving dependencies by a protocol is not supported in Obj-C
* You cannot register a new assembler after container setup.

## License
MRDependencyContainer is available under the MIT license. See [LICENSE](LICENSE) for more information.

