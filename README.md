Like all wrapper-libraries, halfway through its creation, i was familiar enough with the orginal library to justify not needing it.
But it is good to finish what I start, I suppose. 



PackageDescription cannot import Custom Libraries, easily.
This Library must be Copied&Pasted, everytime, onto the package.swift file...

With the Library...

```
let package: Package = PackageBuilder ( id: "Version 1.3" , platforms: platforms ) {
Folder ( name: "Folder 1" , dependencies: [ ] ) {
		Library ( id: "PackageBuilder" , path: "Library" , dependencies: [ ] )
		Live    ( id: "PackageBuilder_Live" , path: "Live" , dependencies: [ ] )
		Tests   ( id: "PackageBuilder_Tests" , path: "Tests" , dependencies: [ ] )
		Macro   ( name: "Macros" , dependencies: [ ] ) {
			MacroLibrary 	( id: "Macro Library" , path: nil , dependencies: [ ] )
			MacroExternal ( id: "Macros" , path: nil , dependencies: [ ] )
		}
	}
}.package
```

Without the library...

```
let package2: Package = Package ( name: "Version 1.3"
	, platforms: platforms
	, products: [
		.library ( name: "PackageBuilder" , targets: [ "PackageBuilder" ] ) ,
		.executable ( name: "PackageBuilder_Live" , targets: ["PackageBuilder_Live"] ) ,
		.library ( name: "Macro External" , targets: ["Macro External"] )
	] 
	, dependencies: [
		.package ( url: "https://github.com/apple/swift-syntax.git" , from: "600.0.0-latest" )
	] ,
	targets: [ 
		.target ( name: "PackageBuilder" , dependencies: [ ], path: "Folder 1/Library" ),
		.executableTarget ( name: "PackageBuilder_Live" , dependencies: [ "PackageBuilder" ,  "Macro Library"  , "Macro External" ] , path: "Folder 1/Live" ),
		.testTarget ( name: "PackageBuilder_Tests" , dependencies: [ "PackageBuilder" , "Macro Library" ,  "Macro External" , .product ( name: "SwiftSyntaxMacrosTestSupport" , package: "swift-syntax" ) ] , path: "Folder 1/Tests" ),
		.macro ( name: "Macro Library" , dependencies: [.product ( name: "SwiftSyntaxMacros" , package: "swift-syntax" ), .product ( name: "SwiftCompilerPlugin" , package: "swift-syntax" ), ] , path: "Folder 1/Macros/Macro Library" ),
		.target ( name: "Macro External" , dependencies: [.byName ( name: "Macro Library" ) ] , path: "Folder 1/Macros/Macro External" ),
	]
	, swiftLanguageVersions: [ ] )
```
import PackageDescription contains many features unencapsulated in theis wrapper library.
