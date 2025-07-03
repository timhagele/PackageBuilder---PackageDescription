//
//  PackageBuilder_1_3App.swift
//  PackageBuilder 1.3
//
//  Created by Tim Hagele on 7/3/25.
//

import SwiftUI
import Macro_External

@main
struct PackageBuilder_1_3App: App {
	init () {
		print ( #stringify ( 1 + 3 ) )
	}
    var body: some Scene {
        WindowGroup {
					Circle().frame ( width: 10 , height: 10 )
        }
    }
}
