//
//  File.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//

import Foundation
import PackageBuilder


var builder: PackageBuilder {
	PackageBuilder ( id: "Package Name" , platforms: [ ] ) {
		
		Folder ( name: "Folder 1" 		, dependencies: [ "@@@@@@@@@@@" ] ) {
			Macro ( name: "Macro Path" 	, dependencies: [ ] ) {
				MacroLibrary  ( id: "Macro Library 1"  , path: nil , dependencies: [ ] )
				MacroExternal ( id: "Macro External 1" , path: nil , dependencies: [ ] )
			}
			
			Folder ( name: "Folder 2"	, dependencies: [ ] ) {
				Library ( id: "Library 1" , path: nil , dependencies: [ "!!!!!!!!!!!" ] )
				Live		( id: "Live 1" 		, path: nil , dependencies: [ ] )
				Tests 	( id: "Tests 1"		, path: nil , dependencies: [ ] )
			}
			
			Folder ( name: "Folder 3" , dependencies: [ ] ) {
				
				Library ( id: "Library 2" 		 , path: nil , dependencies: [ ] )
				Live		( id: "Live 2" 				 , path: nil , dependencies: [ ] )
				Tests 	( id: "Tests 2" 			 , path: nil , dependencies: [ ] )
				Macro 	( name: "Macro Path 2" , dependencies: [ ] ) {
					MacroLibrary  ( id: "Macro Library 2" 	, path: nil , dependencies: [ ] )
					MacroExternal ( id: "Macro External 2" 	, path: nil , dependencies: [ ] )
				}
			}
		}
	}
}


let a = builder


print ( a.products.compactMap ( { $0.description  } ).joined ( separator: "\n\n" ) )
print () ; print () 
print ( a.targets.compactMap ( { $0.description  } ).joined ( separator: "\n\n" ) )
