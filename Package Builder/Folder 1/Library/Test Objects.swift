//
//  File 2.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//

import Foundation



internal let SwiftSyntax			      : 	Target.Dependency 		= .product 	( name: "SwiftSyntax" 									, package: "swift-syntax" )
internal let SwiftCompilerPlugin		: 	Target.Dependency 		= .product 	( name: "SwiftCompilerPlugin" 					, package: "swift-syntax" )
internal let SwiftSyntaxMacros		  : 	Target.Dependency 		= .product 	( name: "SwiftSyntaxMacros" 						, package: "swift-syntax" )
internal let MacrosTestSupport	    : 	Target.Dependency 		= .product 	( name: "SwiftSyntaxMacrosTestSupport" 	, package: "swift-syntax" )
	
internal let SwiftSyntaxPackage	: Package.Dependency  = .package ( url: "https://github.com/apple/swift-syntax.git" , from: "600.0.0-latest" )
internal let MacroSupport 			: [ Target.Dependency ] = [ .byName ( name: "SwiftSyntaxMacros" ) , .byName ( name: "SwiftCompilerPlugin" ) ]

public struct SupportedPlatform { }
	
public struct Package {
	let name: String
	let defaultLocalization: String?
	let platforms: [ SupportedPlatform ]?
	let pkgConfig: String?
	let providers: [ String ]?
	let products: [ Product ]
	let dependencies: [ Package.Dependency ]
	let targets: [ Target ]
	let swiftLanguageVersions: [SwiftVersion]?
	let cLanguageStandard: String?
	let cxxLanguageStandard: String?
	
	public enum Dependency: CustomStringConvertible {
		case package ( url: String , from: String )
		public var description: String {
			switch self {
			case .package ( url: let url , from: let from ):
				".package ( url: \"\(url)\" , from: \"\(from)\" )"
			}
		}
	}
}
struct SwiftVersion { }
	
public enum Product: CustomStringConvertible {
	
		case library 		( name: String , targets: [ String ] )
		case executable ( name: String , targets: [ String ] )
	
	public var description: String {
		switch self {
		case .library ( name: let name , targets: let targets):
			".library ( name: \( name ) , targets: \(targets ) )"
		case .executable(let name, let targets):
			".executable ( name: \( name ) , targets: \(targets ) )"

		}
	}
}
	
public enum Target: CustomStringConvertible {
		
		case macro 						( name: String , dependencies: [ Self.Dependency ] , path: String )
		case target 					( name: String , dependencies: [ Self.Dependency ] , path: String )
		case testTarget 			( name: String , dependencies: [ Self.Dependency ] , path: String )
		case executableTarget ( name: String , dependencies: [ Self.Dependency ] , path: String )
		
	public var description: String {
		switch self {
			
		case .macro ( name: let name , dependencies: let dependencies , path: let path ):
			".macro ( name: \( name ) , dependencies: \( dependencies ) , path: \( path ) )"
		case .target ( name: let name , dependencies: let dependencies , path: let path ):
			".target ( name: \( name ) , dependencies: \( dependencies ) , path: \( path ) )"
		case .testTarget ( name: let name , dependencies: let dependencies , path: let path ):
			".testTarget ( name: \( name ) , dependencies: \( dependencies ) , path: \( path ) )"
		case .executableTarget ( name: let name , dependencies: let dependencies , path: let path ):
			".executableTarget ( name: \( name ) , dependencies: \( dependencies ) , path: \( path ) )"
		}
	}
	public enum Dependency: CustomStringConvertible {
			case byName 	( name: String )
			case product 	( name: String  , package: String )
			public var description: String {
				switch self {
				case .byName ( name: let name ):
					".byName ( name: \( name ) )"
				case .product ( name: let name , package: let package ):
					".product ( name: \( name ) , package: \( package ) )"
				}
			}
		}
	}

extension Target.Dependency:ExpressibleByStringLiteral {
	public init ( stringLiteral value: StringLiteralType ) {
		self = .byName ( name: value )
	}
}
