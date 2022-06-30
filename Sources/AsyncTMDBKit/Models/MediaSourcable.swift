//
//  File.swift
//  
//
//  Created by Shane Whitehead on 30/6/2022.
//

import Foundation

public protocol MediaSourcable {
	var posterPath: String? { get }
	var backdropPath: String? { get }
}
