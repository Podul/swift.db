# swift.db

[![CI Status](https://img.shields.io/travis/Podul/swift.db.svg?style=flat)](https://travis-ci.org/Podul/swift.db)
[![Version](https://img.shields.io/cocoapods/v/swift.db.svg?style=flat)](https://cocoapods.org/pods/swift.db)
[![License](https://img.shields.io/cocoapods/l/swift.db.svg?style=flat)](https://cocoapods.org/pods/swift.db)
[![Platform](https://img.shields.io/cocoapods/p/swift.db.svg?style=flat)](https://cocoapods.org/pods/swift.db)

## Requirements
* iOS 10.0+
* Xcode 10.2+
* Swift 5+

## Installation
### CocoaPods

```ruby
pod 'swift.db '~> '0.1.2'
```
### Swift Package Manager
`0.1.2` 开始支持 `Swift Package Manager`
```swift
dependencies: [
    .package(url: "https://github.com/podul/swift.db", from: "0.1.2")
]
```

## 使用方法
1. 需要创建遵守`DataBaseModel`协议的模型，你可以使用一些基础类型(e.g.`Int` `String` `Float`)，也可以使用`Text` `Integer`等数据库支持的类型。
```swift
struct Model: DataBaseModel {
    var id: Primary = 0
    var name: String = "name"
    var text: Text? = "text"
    ...
}
```

2. 创建并打开数据库
```swift
DB.Manager.open(db: "dbname.sqlite3", create: Model.self)
```

3. 数据库操作
```swift
DB.Manager.insert(model)
DB.Manager.delete(model)
DB.Manager.update(model)
DB.Manager.query(model)
...
```

## Author

Podul, ylpodul@163.com

## License

swift.db is available under the MIT license. See the LICENSE file for more info.
