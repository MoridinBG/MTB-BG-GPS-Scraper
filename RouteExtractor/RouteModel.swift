//
//  RouteModel.swift
//  RouteExtractor
//
//  Created by Ivan Dilchovski on 4/23/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Foundation

class RouteModel
{
	var name: String = ""
	var address: String = ""
	var startPoint: String = ""
	var distance: Double = 0
	var ascent: Double = 0
	var difficulty: [String] = [String]()
	var strenuousness: Double = 0
	var duration: String = ""
	var water: String = ""
	var food: String = ""
	var terrain: [[String:Double]] = [[String:Double]]()
	var traces: String = ""
	var JSON: String = ""
}