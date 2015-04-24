//
//  RouteEditorCell.swift
//  RouteExtractor
//
//  Created by Ivan Dilchovski on 4/23/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Cocoa


@objc
protocol JSONHandler
{
	func displayJSON(json: String, cell: RouteEditorCell)
}

class RouteEditorCell: NSTableCellView
{
	var delegate: JSONHandler?
	
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
	
	@IBAction func genJSON(sender: NSButton)
	{
		var json = "{\n"
		
		if routeName.stringValue != ""
		{
			json += "\t\"name\": \"\(routeName.stringValue)\",\n"
		}
		
		if addressText.stringValue != ""
		{
			json += "\t\"link\": \"\(addressText.stringValue)\",\n"
		}
		
		json += "\t\"length\": \(lengthText.doubleValue),\n"
		json += "\t\"ascent\": \(ascentText.doubleValue),\n"
		
		if difficultyText.stringValue != ""
		{
			var diffs = difficultyText.stringValue.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
			diffs.removeAtIndex(0)
			diffs.removeLast()
			
			json += "\t\"difficulty\": [\n"
			for (index, diff) in enumerate(diffs)
			{
				json += "\t\t\"\(diff)\""
				if index < (diffs.count - 1)
				{
					json += ","
				}
				
				json += "\n"
			}
			json += "\t],\n"
		}
		
		if strenuousnessText.doubleValue > 0
		{
			json += "\t\"strenuousness\": \(strenuousnessText.doubleValue),\n"
		}
		
		if durationText.stringValue != ""
		{
			json += "\t\"duration\": \"\(durationText.stringValue)\",\n"
		}
		
		if waterText.stringValue != ""
		{
			json += "\t\"water\": \"\(waterText.stringValue)\",\n"
		}
		
		if foodText.stringValue != ""
		{
			json += "\t\"food\": \"\(foodText.stringValue)\",\n"
		}
		
		if terraintTarmacText.stringValue != "" || terrainRoadText.stringValue != "" || terraintTrailText.stringValue != ""
		{
			json += "\t\"terrains\": [\n"
			
			if terraintTarmacText.stringValue != ""
			{
				json += "\t\t{\n"
				json += "\t\t\t\"terrain\": \"асфалт\",\n"
				json += "\t\t\t\"length\": \(terraintTarmacText.doubleValue)\n"
				json += "\t\t}"
				
				if terrainRoadText.stringValue != "" || terraintTrailText.stringValue != ""
				{
					json += ","
				}
				
				json += "\n"
			}
			
			if terrainRoadText.stringValue != ""
			{
				json += "\t\t{\n"
				json += "\t\t\t\"terrain\": \"черни пътища\",\n"
				json += "\t\t\t\"length\": \(terrainRoadText.doubleValue)\n"
				json += "\t\t}"
				
				if terraintTrailText.stringValue != ""
				{
					json += ","
				}
				
				json += "\n"
			}
			
			if terraintTrailText.stringValue != ""
			{
				json += "\t\t{\n"
				json += "\t\t\t\"terrain\": \"пътеки\",\n"
				json += "\t\t\t\"length\": \(terraintTrailText.doubleValue)\n"
				json += "\t\t}\n"
			}
			
			json += "\t],\n"
		}
		
		if trackText.stringValue != ""
		{
			json += "\t\"traces\": [\"\(trackText.stringValue)\"]\n"
		}
		
		json +=  "}"
		
		delegate?.displayJSON(json, cell: self)
	}
	
    override func drawRect(dirtyRect: NSRect)
	{
        super.drawRect(dirtyRect)
    }
	
}
