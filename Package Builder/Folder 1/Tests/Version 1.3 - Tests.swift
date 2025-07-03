//
//  Versioin 1.3.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//

import XCTest
import PackageBuilder

final class Version_1_3: XCTestCase {
	var builder: PackageBuilder {
		PackageBuilder ( id: "Version 1.3" , platforms: [ ] ) {
			Folder(name: "Folder 1", dependencies: [ ] ) {
				Library ( id: "PackageBuilder"         , path: "Library" , dependencies: [ ] )
				Live    ( id: "PackageBuilder_Live"    , path: "Live"    , dependencies: [ "PackageBuilder" ] )
				Tests   ( id: "PackageBuilder_Tests"   , path: "Tests"   , dependencies: [ "Macro External" ] )
				Macro   ( name: "Macros" , dependencies: [ ] ) {
					MacroLibrary 	( id: "Macro Library"  , path: nil       , dependencies: [ ] )
					MacroExternal ( id: "Macro External" , path: nil       , dependencies: [ ] )
				}
			}
		}
	}


    func testExample() throws {
			print ( "\n\n" )

			print ( self.builder.products.map ( { $0.description } ).joined(separator: "\n\n") )
			print ( "\n\n" )
			print ( self.builder.targets.map ( { $0.description } ).joined(separator: "\n\n") )
			
    }

}
