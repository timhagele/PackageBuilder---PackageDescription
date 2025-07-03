//
//  Versioin 1.3.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//

import XCTest
import PackageBuilder
import Foundation
import Swift



final class Version_1_3: XCTestCase {
	var builder: PackageBuilder {
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


	func testExample() throws {
		print ( "\n\n" )
		print ( self.builder.products.map ( { $0.description } ).joined ( separator: "\n\n" ) )
		print ( "\n\n" )
		print ( self.builder.targets.map ( { $0.description } ).joined ( separator: "\n\n" ) )
		print ( "\n\n" )
	}
	func test_TestsReceiveAutomaticDependencyToLibrariesLocatedInsideSameFolder () throws {
		if builder.targets [ 2 ].description.contains ( ".byName ( name: PackageBuilder )" ) {
		} else { throw URLError ( .badURL ) }
	}
	func test_TestsReceiveAutomaticDependencyToBothMacroLibrariesLocatedInsideSameFolder () throws {
		if builder.targets [ 2 ].description.contains ( ".byName ( name: Macro Library )" )
		&& builder.targets [ 2 ].description.contains ( ".byName ( name: Macro External )" ) { }
		else { throw URLError ( .badURL ) }
	}
	func test_TestsDoNotReceiveAutomaticDependencyToLibrariesLocatedOutsideOfSameFolder () throws {
		if builder.targets[ 6 ].description.contains ( "dependencies: [] " ) { }
		else { throw URLError ( .badURL ) }
	}
	func test_FolderDependenciesAreDistributedToEverFolderAsset () throws {
		let count = builder.targets
			.map { $0.description.contains ( "!@!" ) }
			.filter { $0 == false }
			.count
		if count == 1 { }
		else { throw URLError ( .badURL ) }
	}
	
	var macroSupport: String = ".product ( name: SwiftSyntaxMacros , package: swift-syntax ), .product ( name: SwiftCompilerPlugin , package: swift-syntax )"
	func test_MacroLibraryReceivesMacroSupport () throws {
		if builder.targets[ 3 ].description.contains ( macroSupport ) { }
		else { throw URLError ( .badURL ) }
	}
	
	func test_MacroExternalReceivesAutomaticDependencyOnLibraryCounterpart () throws {
		if builder.targets[ 4 ].description.contains ( ".byName ( name: Macro Library )" ) { }
		else { throw URLError ( .badURL ) }
	}
}
