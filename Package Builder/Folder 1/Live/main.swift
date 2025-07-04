//
//  File.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//

import Foundation
import PackageBuilder
//import Macro_Library
//import Macros

var builder: PackageBuilder {
	PackageBuilder ( id: "Version 1.3" , platforms: [ ] ) {
		Folder(name: "Folder 1", dependencies: [ ] ) {
			Library ( id: "PackageBuilder"         , path: "Library" , dependencies: [ ] )
			Live    ( id: "PackageBuilder_Live"    , path: "Live"    , dependencies: [ ] )
			Tests   ( id: "PackageBuilder_Tests"   , path: "Tests"   , dependencies: [ ] )
			Macro   ( name: "Macros" , dependencies: [ "MACROMACROMACROMACROMACRO" ] ) {
				MacroLibrary 	( id: "Macro Library"  , path: nil       , dependencies: [ ] )
				MacroExternal ( id: "Macro External" , path: nil       , dependencies: [ ] )
			}
			Folder(name: "Folder 2", dependencies: [ "alksdjfh;laksdfkasdjf;asdfd" ] ) {
				Library ( id: "PackageBuilder"         , path: "Library" , dependencies: [ ] )
			}
		}
	}
}


let a = builder


print ( a.products.compactMap ( { $0.description  } ).joined ( separator: "\n\n" ) )
print () ; print ()
print ( a.targets.compactMap ( { $0.description  } ).joined ( separator: "\n\n" ) )
print () ; print ()

//automatic connection to Macro Externals
//print ( #stringify( 1 + 4 ) )


////automatic connection to Macro_Library
//let _: [StringifyMacro] = [ ]


