//
//  File.swift
//  
//
//  Created by Tim Hagele on 7/3/25.
//
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import Foundation
import Macro_Library
import Macros

#if canImport(Macro_Library)
import Macro_Library

let testMacros: [String: Macro.Type] = [
		"stringify": StringifyMacro.self,
]
#endif

final class Package_BuilderTests: XCTestCase {
		func testMacro() throws {
				#if canImport(Macro_Library)
				assertMacroExpansion(
						"""
						#stringify(a + b)
						""",
						expandedSource: """
						(a + b, "a + b")
						""",
						macros: testMacros
				)
				#else
				throw XCTSkip("macros are only supported when running tests for the host platform")
				#endif
		}

		func testMacroWithStringLiteral() throws {
				#if canImport ( Macro_Library )
				assertMacroExpansion(
						#"""
						#stringify("Hello, \(name)")
						"""#,
						expandedSource: #"""
						("Hello, \(name)", #""Hello, \(name)""#)
						"""#,
						macros: testMacros
				)
				#else
				throw XCTSkip("macros are only supported when running tests for the host platform")
				#endif
		}
}
