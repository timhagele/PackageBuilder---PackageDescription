//
//  File.swift
//  
//
//  Created by Tim Hagele on 7/4/25.
//

import Foundation




internal extension Package {
	func printPackage () {
		print ( """
Package ( name: \( self.name )  ,

	products: [
		\( self.products.map { $0.description }.joined ( separator: " ,\n\t\t") ) ,
	] ,

	dependencies: [
		\( self.dependencies.map { $0.description }.joined ( separator: " ,\n\t\t") ) ,
	] ,

	targets: [

		\( self.targets.map { $0.description }.joined ( separator: " ,\n\n\t\t") ) ,

	] ,
	
)

"""
		)
	}
}
