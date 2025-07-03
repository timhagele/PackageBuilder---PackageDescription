//
//  File.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//

import Foundation


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
	func initialize ( path: String , products: inout [ pdProducts ] , targets: inout [ pdTarget ] ) {
		
		let macroTestsSupport: pdTarget.Dependency? = self.assets.contains ( where: { $0 is Macro } ) ? MacrosTestSupport : nil
		for var asset in self.assets {
			asset.data.dependencies.append ( contentsOf: self.data.dependencies )
			
			if let folder = asset as? Container {
				folder.initialize ( path: "\( path )/\( asset.data.path )", products: &products , targets: &targets )
			}
			else if var target = asset as? Targetable {
				if target is Tests , let macroTestsSupport { target.data.dependencies.append ( macroTestsSupport ) }
				target.appendObjects ( path: "\( path )/\( target.data.path )", products: &products, targets: &targets )
			}
		}
	}
}

public struct PackageBuilder: Container {
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
			, dependencies: [ SwiftSyntaxPackage ] // TODO: - make conditional - presence of macro
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
	
	public var data : Data
	
	public init ( id: String , path: String? , dependencies: [ pdTarget.Dependency ] ) {
		var macroSupport: [ pdTarget.Dependency ] =  MacroSupport
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
	public var data : Data

	public init ( id: String , path: String? , dependencies: [ pdTarget.Dependency ] ) {
		self.data = Data ( id: id , path: path , dependencies: dependencies )
	}
	
	public func appendObjects ( path: String , products: inout [ pdProducts ] , targets: inout [ pdTarget ] ) {
		targets.append ( .testTarget ( name: self.data.id , dependencies: self.data.dependencies , path: path ) )
	}
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
