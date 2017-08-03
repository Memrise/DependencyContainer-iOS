# DependencyContainer-iOS


Trivial Dependency Container.


## Installation

### CocoaPods

```ruby
pod 'DependencyContainer'
```

### Usage

#### Swift

Services registration & container setup.

```swift
import DependencyContainer

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
@import DependencyContainer;

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

