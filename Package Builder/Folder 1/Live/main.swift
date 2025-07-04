//
//  File.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//

import Foundation
import PackageBuilder
import Macro_Library
import Macros

var builder: PackageBuilder {
	PackageBuilder ( id: "Version 1.3" , platforms: [ ] ) {
		Folder ( name: "Folder 1" , dependencies: [ ] ) {
			Library ( id: "PackageBuilder"         , path: "Library" 	)
			Live    ( id: "PackageBuilder_Live"    , path: "Live"    	)
			Tests   ( id: "PackageBuilder_Tests"   , path: "Tests"   	)
			Macro   ( name: "Macros" , dependencies: [ "Macro" ] 	 		) {
				MacroLibrary 	( id: "Macro Library"   					      	)
				MacroExternal ( id: "Macro External"  					      	)
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
print ( #stringify( 1 + 4 ) )



//printTest()
//automatic connection to Macro_Library
//let _: [StringifyMacro] = [ ]


