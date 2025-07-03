//
//  File.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//

import Foundation


// MARK: - PackageBuilder: Version 1.3
// _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
/*
** The author disclaims copyright to this source code.  In place of
** a legal notice, here is a blessing:
**
**    May you do good and not evil.
**    May you find forgiveness for yourself and forgive others.
**    May you share freely, never taking more than you give.
**
// Tests and Executable (Live) Targets will receive an automatic dependency to all Library/Macro inside of the same Folder/Container
*/


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
public protocol SharableLibrary {
	var exportedDependencies: [ String ] { get }
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
	
	func initialize ( path: String? , products: inout [ pdProducts ] , targets: inout [ pdTarget ] , macroSupport: inout Bool ) {
		let localLibraries = self.assets .compactMap { $0 as? SharableLibrary } .flatMap { $0.exportedDependencies } // maps ( libraries || Macro External || Macro Library )

		for var asset in self.assets {
			
			if asset is Macro  { macroSupport = true } // Import Swift Syntax into Library as a Package.Dependency
			asset.data.dependencies.append ( contentsOf: self.data.dependencies ) //asset inherits all user-defined-folder dependencies
			
			if !( asset is SharableLibrary ) { // Filters to only ( Executables and Tests targets )
				let transformed: [ pdTarget.Dependency ] = localLibraries.map { .byName ( name: $0 ) } // from string to Target.Dependency
				asset.data.dependencies.append ( contentsOf: transformed ) // Executables and Tests targets receive automatic dependencies to all Libraries && Macro Library && Macro External within same Folder/Container
			}

			if let folder = asset as? Container {
				folder.initialize ( path: "\( path != nil ? "\( path! )/" : "" )\( asset.data.path )" , products: &products , targets: &targets , macroSupport: &macroSupport ) // The current function for nested Folders/Containers
			}
			else if var target = asset as? Targetable {
				if var tests = target as? Tests , self.containsMacros { tests.appendMacroTestSupport() ; target = tests } // Tests receive Macro Support ( only if macro present inside same Folder/Container )
				target.appendObjects ( path: "\( path != nil ? "\( path! )/" : "" )\( target.data.path )" , products: &products , targets: &targets ) // Targets and products retrieved after all mutations finished...sent to PackageBuilder
			}
		}
	}
}

public struct PackageBuilder: Container {
	private let swiftSyntaxPackage : Package.Dependency  = .package ( url: "https://github.com/apple/swift-syntax.git" , from: "600.0.0-latest" )
	public var data				   : Data
	private var macroSupport : Bool = false
	public let platforms	   : [ pdPlatforms ]
	public var products		   : [ pdProducts  ] = [ ]
	public var targets		   : [ pdTarget 	 ] = [ ]
	public var assets			   : [ Addressable ]
	private var dependencies : [ Package.Dependency ] = [ ]
	
	
	public init ( id: String , platforms: [ pdPlatforms ] , @Folder _ folders: () -> [ Addressable ] ) {
		self.data = Data ( id: id , path: nil , dependencies: [ ] )
		self.platforms = platforms
		self.assets = folders ( )
		self.initialize ( path: nil , products: &self.products , targets: &self.targets , macroSupport: &self.macroSupport )
		if self.macroSupport { self.dependencies.append ( swiftSyntaxPackage ) }
	}
	
	var package: pdPackage {
		pdPackage (
			name: self.data.id  // TODO: - make conditional - first present library/macro
			, defaultLocalization: nil
			, platforms: self.platforms
			, pkgConfig: nil
			, providers: nil
			, products: self.products
			, dependencies: self.dependencies
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
public struct Macro 		: Container , SharableLibrary {
	public var exportedDependencies: [ String ] { self.assets.compactMap { ( $0 is MacroLibrary || $0 is MacroExternal || $0 is Library ) ? $0.data.id : nil } }
	
	public var assets			: [ Addressable ]
	public var data				: Data
	var libraryName				: pdTarget.Dependency { .byName ( name: self.assets[ 0 ].data.id ) }
	var externalName			: pdTarget.Dependency { .byName ( name: self.assets[ 1 ].data.id ) }
	
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

public struct MacroExternal : Targetable {
	public var data : Data
	
	public init ( id: String , path: String? , dependencies: [ pdTarget.Dependency ] ) {
		self.data = Data ( id: id , path: path , dependencies: dependencies )
	}
	
	public func appendObjects ( path: String , products: inout [ pdProducts ] , targets: inout [ pdTarget ] ) {
		products.append ( .library ( name: data.id , targets: [ data.id ] ) )
		targets.append 	( .target ( name: self.data.id , dependencies: self.data.dependencies, path: path ) )
	}
}

public struct Library : SharableLibrary , Targetable {
	public var exportedDependencies: [ String ] { [ self.data.id ] }
	
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

