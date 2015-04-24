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
	var strenuousness: Int32 = 0
	var duration: String = ""
	var water: String = ""
	var food: String = ""
	var tarmac: Double = 0
	var roads: Double = 0
	var trails: Double = 0
	var traces: String = ""
	var JSON: String = ""
}