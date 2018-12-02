![alt text](https://github.com/GeekTree0101/Vetty/blob/master/res/logo.png)

[![CI Status](https://img.shields.io/travis/Geektree0101/Vetty.svg?style=flat)](https://travis-ci.org/Geektree0101/Vetty)
[![Version](https://img.shields.io/cocoapods/v/Vetty.svg?style=flat)](https://cocoapods.org/pods/Vetty)
[![License](https://img.shields.io/cocoapods/l/Vetty.svg?style=flat)](https://cocoapods.org/pods/Vetty)
[![Platform](https://img.shields.io/cocoapods/p/Vetty.svg?style=flat)](https://cocoapods.org/pods/Vetty)

## Feature
Link: https://github.com/GeekTree0101/Vetty/projects/2

## Usage
<br /><br />

### Make a model
<br />

```swift
class User: VettyProtocol { // <--- STEP1: Inherit VettyProtocol
    
    var uniqueKey: VettyIdentifier {
        return userId // <--- STEP2: return model uniqueKey
    }
    
    var userId: Int = -1
    var username: String = ""
    var profileURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case username = "login"
        case profileURL = "avatar_url"
    }
    
    func commitSubModelIfNeeds() { // <---- STEP3: (Optional) 
        // Will pass, user model doen't has VettyProtocol Sub-Model
    }
}
```
<br /><br />

### Commit
<br />

1. Directly commit model
```swift
let userIdForVetty: VettyIdentifier = Vetty.shared.commit(user)
```

2. Using Reactive Extension
```swift
let userIdForVettyObservable: Observable<VettyIdentifier> =
  Observable.just(user)
            .asObservable()
            .map({ $0.map({ $0 as VettyProtocol }) })
            .commits(ignoreSubModel: false)
```
<br /><br />


### READ
<br />

> Directly read model object from Vetty
```swift
let user: User? = Vetty.shared.read(type: User.self, uniqueKey: 12345)

```
<br /><br />

### Model Observable
<br />

```swift
let userObservable: Observable<User?> = Vetty.rx.model(type: User.self, uniqueKey: 12345)
```
<br /><br />

### Mutating
<br />

1. Directly Mutating
```swift
guard let user = Vetty.shared.read(type: User.self, uniqueKey: 12345) else { return }
user.profileURL = URL(string: "https://avatars1.githubusercontent.com/u/19504988?s=460&v=4")
Vetty.shared.commit(user, ignoreSubModel: true)
```
<br /><br />

2. Using Observable Extension
```swift
let observable: Observable<User?> = Vetty.rx.model(type: User.self, uniqueKey: 12345)
Observable.just(URL(string: "https://avatars1.githubusercontent.com/u/19504988?s=460&v=4"))
          .mutate(with: observable,
                  { user, newURL -> User? in
                      user?.profileURL = newURL
                      return user
            })
            .disposed(by: disposeBag)
```
<br /><br />

## Advanced
<br /><br />


### Sub-Model Observable from Root-Model Observable
<br />

```swift
let repoObservable = Vetty.rx.model(type: Repository.self, uniqueKey: repoId)
        
let userObservable = repoObservable
            .filterNil()
            .map { $0.user?.uniqueKey }
            .filterNil()
            .take(1)
            .flatMap { Vetty.rx.model(type: User.self, uniqueKey: $0) }
```
<br /><br />

### Ignore Sub-Model Mutating
<br />

```swift
let observable: Observable<User?> = Vetty.rx.model(type: User.self, uniqueKey: 12345)
Observable.just(URL(string: "https://avatars1.githubusercontent.com/u/19504988?s=460&v=4"))
          .mutate(with: observable,
                  ignoreSubModel: true) <--- Default is true!
                  { user, newURL -> User? in
                      user?.profileURL = newURL
                      return user
            })
            .disposed(by: disposeBag)
```
<br /><br />

### Non-Ignore Sub-Model with Latest Sub-Model
<br />

> Model Example, Repository has User(Sub-Model) property!
```swift

class Repository: VettyProtocol {
    
    var uniqueKey: VettyIdentifier {
        return id
    }
    
    var id: Int = -1
    var user: User?
    var repositoryName: String?
    var desc: String?
    var isPrivate: Bool = false
    var isForked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case user = "owner"
        case repositoryName = "full_name"
        case desc = "description"
        case isPrivate = "private"
        case isForked = "fork"
    }
    
    func commitSubModelIfNeeds() {
        
        Vetty.shared.commitIfNeeds(user)
    }
}

class User: VettyProtocol {
    
    var uniqueKey: VettyIdentifier {
        return userId
    }
    
    var userId: Int = -1
    var username: String = ""
    var profileURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case username = "login"
        case profileURL = "avatar_url"
    }
    
    func commitSubModelIfNeeds() {
        
    }
}

```

<br />

If you don't wanna update user model(sub-model) than you just should set ignoreSubModel as True.
But, If uou should update repository model(root-model) with latest user model from vetty 
than you just follow under the example.

<br />


```swift
let observable: Observable<Repository?> = Vetty.rx.model(type: Repository.self, uniqueKey: "repo-23")
Observable.just("New Repository Description")
          .mutate(with: observable,
                  ignoreSubModel: false) 
                  { repo, newDesc -> Repository? in
                      
                      if let userId = repo.user?.userId, 
                      let latestUser = Vetty.shared.read(type: User.self, uniqueKey: userId) {
                        repo.user = latestUser
                      }
                      
                      repo?.desc = newDesc
                      return repo
            })
            .disposed(by: disposeBag)
```

<br /><br />

## Installation

Vetty is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Vetty'
```

## Author

Geektree0101, h2s1880@gmail.com

## License

Vetty is available under the MIT license. See the LICENSE file for more info.
