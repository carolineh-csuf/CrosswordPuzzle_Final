//
//  Array2D.swift
//  TestFocus
//
//  Created by Caroline Ha on 4/5/23.
//

import Foundation

open class Array2D<T> {
	
	open var columns: Int
	open var rows: Int
	open var matrix: [T]
	
	public init(columns: Int, rows: Int, defaultValue: T) {
		self.columns = columns
		self.rows = rows
		matrix = Array(repeating: defaultValue, count: columns * rows)
	}
	
	open subscript(column: Int, row: Int) -> T {
		get {
			return matrix[columns * row + column]
		}
		set {
			matrix[columns * row + column] = newValue
		}
	}
	
	open func columnCount() -> Int {
		return self.columns
	}
	
	open func rowCount() -> Int {
		return self.rows
	}
}
