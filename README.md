# DependencyContainer-iOS


Trivial Dependency Container for Memrise App.


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

let container = MRDependencyContainer()
        
let assembler = MRDefaultDependencyAssembler.createWithType(TestService.self, andBlock:{ (manager) -> AnyObject in
    return TestService()
})
container.registerAssembler(assembler, withName:"testService")

container.setup()

```

Resolving dependencies

```swift

let service = container.resolveByClass(TestService)

```

#### ObjC

```objc
@import DependencyContainer;

MRDependencyContainer container = [[MRDependencyContainer alloc] init];
        
MRDependencyAssembler *assembler = [MRDefaultDependencyAssembler createWithType:[TestService class] andBlock:^ id (MRDependencyContainer *container){
    return TestService();
}];
[container registerAssembler:assembler withName:"testService"];

[container setup];

```

Resolving dependencies

```objc

TestService *service = [container resolveByClass:TestService.class];

```