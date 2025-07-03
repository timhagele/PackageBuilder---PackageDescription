//
//  Versioin 1.3.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//

import XCTest
@testable import PackageBuilder
import Foundation
import Swift



final class Version_1_3: XCTestCase {
	var builder1: PackageBuilder {
		PackageBuilder ( id: "Version 1.3" , platforms: [ ] ) {
			Folder(name: "Folder 1", dependencies: [ "!@!" ] ) {
				Library ( id: "PackageBuilder"         , path: "Library" , dependencies: [ ] )
				Live    ( id: "PackageBuilder_Live"    , path: "Live"    , dependencies: [ ] )
				Tests   ( id: "PackageBuilder_Tests"   , path: "Tests"   , dependencies: [ ] )
				Macro   ( name: "Macros" , dependencies: [ ] ) {
					MacroLibrary 	( id: "Macro Library"  , path: nil       , dependencies: [ ] )
					MacroExternal ( id: "Macro External" , path: nil       , dependencies: [ ] )
				}
				Folder ( name: "Folder 2" , dependencies: [ ] ) {
					Tests ( id: "Test Target 2" , path: nil , dependencies: [  ] )
				}
			}
			Folder ( name: "Folder 3" , dependencies: [ ] ) {
				Tests ( id: "Test Target 3", path: nil , dependencies: [  ] )
			}
		}
		
	}
	var builder2: PackageBuilder {
		PackageBuilder ( id: "Version 1.3" , platforms: [ ] ) {
			Folder ( name: "Folder 3" , dependencies: [ ] ) {
				Tests ( id: "Test Target 3", path: nil , dependencies: [  ] )
			}
		}
	}
	


	func testExample() throws {
		print ( "\n\n" )
		print ( self.builder1.products.map ( { $0.description } ).joined ( separator: "\n\n" ) )
		print ( "\n\n" )
		print ( self.builder1.targets.map ( { $0.description } ).joined ( separator: "\n\n" ) )
		print ( "\n\n" )
	}
	func test_TestsReceiveAutomaticDependencyToLibrariesLocatedInsideSameFolder () throws {
		if builder1.targets [ 2 ].description.contains ( ".byName ( name: PackageBuilder )" ) {
		} else { throw URLError ( .badURL ) }
	}
	func test_TestsReceiveAutomaticDependencyToBothMacroLibrariesLocatedInsideSameFolder () throws {
		if builder1.targets [ 2 ].description.contains ( ".byName ( name: Macro Library )" )
		&& builder1.targets [ 2 ].description.contains ( ".byName ( name: Macro External )" ) { }
		else { throw URLError ( .badURL ) }
	}
	func test_TestsDoNotReceiveAutomaticDependencyToLibrariesLocatedOutsideOfSameFolder () throws {
		if builder1.targets[ 6 ].description.contains ( "dependencies: [] " ) { }
		else { throw URLError ( .badURL ) }
	}
	func test_FolderDependenciesAreDistributedToEverFolderAsset () throws {
		let count = builder1.targets
			.map { $0.description.contains ( "!@!" ) }
			.filter { $0 == false }
			.count
		if count == 1 { }
		else { throw URLError ( .badURL ) }
	}
	
	var macroSupport: String = ".product ( name: SwiftSyntaxMacros , package: swift-syntax ), .product ( name: SwiftCompilerPlugin , package: swift-syntax )"
	func test_MacroLibraryReceivesMacroSupport () throws {
		if builder1.targets[ 3 ].description.contains ( macroSupport ) { }
		else { throw URLError ( .badURL ) }
	}
	
	func test_MacroExternalReceivesAutomaticDependencyOnLibraryCounterpart () throws {
		if builder1.targets[ 4 ].description.contains ( ".byName ( name: Macro Library )" ) { }
		else { throw URLError ( .badURL ) }
	}
	func test_builderAutomaticallyImportsMacroSupportWhenMacroPresent () throws {
	
		if builder1.dependencies [ 0 ].description == ".package ( url: \"https://github.com/apple/swift-syntax.git\" , from: \"600.0.0-latest\" )" {}
		else { throw URLError ( .badURL ) }
	}
	
	func test_builderDoesNotImportMacroSupportWhenNoMacrosPresent () throws {
		if builder2.dependencies.isEmpty {}
		else { throw URLError ( .badURL ) }
	}
	
}
