//
//  RouteEditorCell.swift
//  RouteExtractor
//
//  Created by Ivan Dilchovski on 4/23/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Cocoa

class RouteEditorCell: NSTableCellView
{

	@IBOutlet weak var routeName: NSTextField!
	@IBOutlet weak var addressText: NSTextField!
	@IBOutlet weak var exitText: NSTextField!
	@IBOutlet weak var lengthText: NSTextField!
	@IBOutlet weak var ascentText: NSTextField!
	@IBOutlet weak var difficultyText: NSTextField!
	@IBOutlet weak var strenuousnessText: NSTextField!
	@IBOutlet weak var durationText: NSTextField!
	@IBOutlet weak var waterText: NSTextField!
	@IBOutlet weak var foodText: NSTextField!
	@IBOutlet weak var terraintTarmacText: NSTextField!
	@IBOutlet weak var terrainRoadText: NSTextField!
	@IBOutlet weak var terraintTrailText: NSTextField!
	@IBOutlet weak var trackText: NSTextField!
	
	
    override func drawRect(dirtyRect: NSRect)
	{
        super.drawRect(dirtyRect)
    }
    
}
