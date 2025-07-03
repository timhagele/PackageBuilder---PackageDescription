// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport


//let SwiftSyntax         :  Target.Dependency   = .product 	( name: "SwiftSyntax" 								  , package: "swift-syntax" )

let platforms							: [ SupportedPlatform 	] = [ .macOS ( .v10_15 ) , .iOS ( .v13 ) ]




let package = builder.package

var builder: PackageBuilder {
	PackageBuilder (
		id: "Version 1.3" , platforms: platforms ) {
			Library ( id: "PackageBuilder"         , path: "Library" , dependencies: [ ] )
			Live    ( id: "PackageBuilder_Live"    , path: "Live"    , dependencies: [ "PackageBuilder" ] )
			Tests   ( id: "PackageBuilder_Tests"   , path: "Tests"   , dependencies: [ ] )
	}
}





// MARK: - PackageBuilder: Version 1.3
// _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_


public typealias pdPackage 					= Package
public typealias pdPlatforms 				= SupportedPlatform
public typealias pdProducts 				= Product
public typealias pdTarget		 				= Target

public protocol Addressable {
	var data : Data { get set }
}
public protocol Container: Addressable {
	var assets : [ Addressable ] { get }
}
public protocol Targetable: Addressable {
	func appendObjects 	( path : String , products : inout [ pdProducts ] , targets : inout [ pdTarget ] )
}

public struct Data {
	let id						: 	String
	var path					: 	String
	var dependencies	: [ pdTarget.Dependency ]
	public init ( id: String , path: String?, dependencies: [ pdTarget.Dependency ] ) {
		self.id = id
		self.path = path ?? id
		self.dependencies = dependencies
	}
}


extension Container {
	
	var containsMacros: Bool { self.assets.contains ( where: { $0 is Macro } ) }
	
	func initialize ( path: String , products: inout [ pdProducts ] , targets: inout [ pdTarget ] ) {
				
		for var asset in self.assets {
			asset.data.dependencies.append ( contentsOf: self.data.dependencies )
			
			if let folder = asset as? Container {
				folder.initialize ( path: "\( path )/\( asset.data.path )", products: &products , targets: &targets )
			}
			else if let target = asset as? Targetable {
				if var tests = target as? Tests , self.containsMacros { tests.appendMacroTestSupport() }
				target.appendObjects ( path: "\( path )/\( target.data.path )", products: &products, targets: &targets )
			}
		}
	}
}

public struct PackageBuilder: Container {
	private let swiftSyntaxPackage : Package.Dependency  = .package ( url: "https://github.com/apple/swift-syntax.git" , from: "600.0.0-latest" )
	public var data				: 	Data
	public let platforms	: [ pdPlatforms ]
	public var products		: [ pdProducts 	] = [ ]
	public var targets		: [ pdTarget 		] = [ ]
	public var assets			: [ Addressable ]
	
	public init ( id: String , platforms: [ pdPlatforms ] , @Folder _ folders: () -> [ Addressable ] ) {
		self.data = Data ( id: id , path: nil , dependencies: [ ] )
		self.platforms = platforms
		self.assets = folders()
		self.initialize ( path: id , products: &self.products , targets: &self.targets )
	}
	
	var package: pdPackage {
		pdPackage (
			name: self.data.id  // TODO: - make conditional - first present library/macro
			, defaultLocalization: nil
			, platforms: self.platforms
			, pkgConfig: nil
			, providers: nil
			, products: self.products
			, dependencies: [ self.swiftSyntaxPackage ] // TODO: - make conditional - presence of macro
			, targets: self.targets
			, swiftLanguageVersions: nil
			, cLanguageStandard: nil
			, cxxLanguageStandard: nil
		)
	}
}

@resultBuilder
public struct Folder		: Container {
	public var assets			: [ Addressable ]
	public var data				: Data
	
	public static func buildBlock ( _ components: Addressable... ) -> [ Addressable ] {
		components
	}
	public init ( name: String , dependencies: [ pdTarget.Dependency ] , @Folder _ assets: () -> [ Addressable ] ) {
		self.data = Data ( id: name , path: name , dependencies: dependencies )
		self.assets = assets()
	}
}

@resultBuilder
public struct Macro 		: Container {
	public var assets			: [ Addressable ]
	public var data				: Data
	
	public static func buildBlock ( _ library: MacroLibrary , _ external: MacroExternal ) -> ( library: MacroLibrary , external: MacroExternal ) {
		return ( library: library , external: external )
	}
	
	public init ( name: String , dependencies: [ pdTarget.Dependency ] , @Macro _ assets: () -> ( library: MacroLibrary , external: MacroExternal ) ) {
		self.data = Data ( id: name , path: name , dependencies: [ ] )
		let externalDependents: pdTarget.Dependency = .byName ( name: assets().library.data.id )
		var external: MacroExternal = assets().external
		external.data.dependencies.append ( externalDependents )
		self.assets = [ assets().library , external ]
	}
}

public struct MacroLibrary : Targetable {
	private let SwiftCompilerPlugin	:  Target.Dependency   = .product 	( name: "SwiftCompilerPlugin" , package: "swift-syntax" )
	private let SwiftSyntaxMacros	  :  Target.Dependency   = .product 	( name: "SwiftSyntaxMacros" 	, package: "swift-syntax" )
	public var data : Data
	
	public init ( id: String , path: String? , dependencies: [ pdTarget.Dependency ] ) {
		var macroSupport: [ pdTarget.Dependency ] = [ self.SwiftSyntaxMacros , self.SwiftCompilerPlugin ]
		macroSupport.append ( contentsOf: dependencies )
		self.data = Data ( id: id , path: path , dependencies: macroSupport )
	}
	
	public func appendObjects ( path: String , products: inout [ pdProducts ] , targets: inout [ pdTarget ] ) {
		targets.append ( .macro ( name: self.data.id , dependencies: self.data.dependencies , path: path ) )
	}
}

public struct MacroExternal	: Targetable {
	public var data : Data
	
	public init ( id: String , path: String? , dependencies: [ pdTarget.Dependency ] ) {
		self.data = Data ( id: id , path: path , dependencies: dependencies )
	}
	
	public func appendObjects ( path: String , products: inout [ pdProducts ] , targets: inout [ pdTarget ] ) {
		products.append ( .library ( name: data.id , targets: [ data.id ] ) )
		targets.append 	( .target ( name: self.data.id , dependencies: self.data.dependencies, path: path ) )
	}
}

public struct Library : Targetable {
	public var data : Data
	
	public init ( id: String , path: String? , dependencies: [ pdTarget.Dependency ] ) {
		self.data = Data ( id: id , path: path , dependencies: dependencies )
	}
	
	public func appendObjects ( path: String , products: inout [ pdProducts ] , targets: inout [ pdTarget ] ) {
		products.append ( .library ( name: data.id , targets: [ data.id ] ) )
		targets.append 	( .target ( name: self.data.id , dependencies: self.data.dependencies , path: path ) )
	}
}

public struct Tests : Targetable {
	private let macrosTestSupport : Target.Dependency = .product ( name: "SwiftSyntaxMacrosTestSupport" , package: "swift-syntax" )

	public var data : Data

	public init ( id: String , path: String? , dependencies: [ pdTarget.Dependency ] ) {
		self.data = Data ( id: id , path: path , dependencies: dependencies )
	}
	
	public func appendObjects ( path: String , products: inout [ pdProducts ] , targets: inout [ pdTarget ] ) {
		targets.append ( .testTarget ( name: self.data.id , dependencies: self.data.dependencies , path: path ) )
	}
	mutating func appendMacroTestSupport () { self.data.dependencies.append ( self.macrosTestSupport ) }
}

public struct Live : Targetable {
	public var data : Data
	
	public init ( id: String , path: String? , dependencies: [ pdTarget.Dependency ] ) {
		self.data = Data ( id: id , path: path , dependencies: dependencies )
	}
	
	public func appendObjects ( path: String , products: inout [ pdProducts ] , targets: inout [ pdTarget ] ) {
		products.append ( .executable ( name: data.id , targets: [ data.id ] ) )
		targets.append 	( .executableTarget ( name: self.data.id , dependencies: self.data.dependencies , path: path ) )

	}
}





