//
//  File.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//

import Foundation
@testable import PackageBuilder
@testable import Macros

var builder: PackageBuilder {
	PackageBuilder ( id: "Version 1.3" , platforms: [ ] , dependencies: {
		Package.Dependency.package(url: "URL", from: "URL")
	} , assets: {
		Folder ( name: "Folder 1" , dependencies: [ "!@!@!@!@!@!" ] ) {
			Library ( id: "PackageBuilder"         , path: "Library" 	)
			Live    ( id: "PackageBuilder_Live"    , path: "Live"    	)
			Tests   ( id: "PackageBuilder_Tests"   , path: "Tests"   	)
			Macro   ( name: "Macros" 															 		) {
				MacroLibrary 	( id: "Macro Library"   					      	)
				MacroExternal ( id: "Macro External"  					      	)
				Library ( id: "Nested Library" , path: nil , dependencies: [ ] )
				Tests ( id: "Nested Test" )
				Live 	( id: "Nested Live" )
			}
		}
	} )
}


let package = builder.package

package.printPackage()
//automatic connection to Macro Externals
//print ( #stringify( 1 + 4 ) )

