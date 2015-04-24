//
//  MainViewController.swift
//  RouteExtractor
//
//  Created by Ivan Dilchovski on 4/23/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Cocoa

extension String {
	func stripCharactersInSet(chars: [Character]) -> String {
		return String(filter(self) {find(chars, $0) == nil})
	}
}

class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, JSONHandler
{

	@IBOutlet weak var urlField: NSTextField!
	@IBOutlet var extractText: NSTextView!
	@IBOutlet weak var tableView: NSTableView!

	private var routes = [RouteModel]()
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		let url = NSURL(string: "http://www.mtb-bg.com/index.php/trails/gpstracks?q=%2Findex.php%2Ftrails%2Fgpstracks&start=30")!
		let session = NSURLSession.sharedSession()
		let loadDataTask = session.dataTaskWithURL(url, completionHandler: self.extractRouteAddresses)

		loadDataTask.resume()
    }
	
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int
	{
		return self.routes.count
	}
 
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
	{
		switch tableColumn!.identifier
		{
			case Constants.Keys.kColumnIdrouteEditor:
				let route = self.routes[row]
				var cellView = tableView.makeViewWithIdentifier(Constants.Keys.kCellIdrouteEditor, owner: self) as! RouteEditorCell
				
				cellView.routeName.stringValue = route.name
				cellView.addressText.stringValue = route.address
				cellView.exitText.stringValue = route.startPoint
				cellView.lengthText.stringValue = "\(route.distance)"
				cellView.ascentText.stringValue = "\(route.ascent)"
				cellView.difficultyText.stringValue = ""
				for diff in route.difficulty
				{
					cellView.difficultyText.stringValue += "\(diff) "
				}
				cellView.strenuousnessText.stringValue = "\(route.strenuousness)"
				cellView.durationText.stringValue = route.duration
				cellView.waterText.stringValue = route.water
				cellView.foodText.stringValue = route.food
				cellView.terraintTarmacText.stringValue = ""
				cellView.terrainRoadText.stringValue = ""
				cellView.terraintTrailText.stringValue = ""
				if route.tarmac > 0
				{
					cellView.terraintTarmacText.stringValue = "\(route.tarmac)"
				}
				if route.roads > 0
				{
					cellView.terrainRoadText.stringValue = "\(route.roads)"
				}
				if route.trails > 0
				{
					cellView.terraintTrailText.stringValue = "\(route.trails)"
				}
				cellView.trackText.stringValue = route.traces
				
				cellView.delegate = self
				
				return cellView
			
			default:
				let route = self.routes[row]
				var cellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
				cellView.textField?.stringValue = route.JSON
				cellView.textField?.editable = true
				return cellView
		}
	}
	
	func displayJSON(json: String, cell: RouteEditorCell)
	{
		let index = tableView.rowForView(cell)
		routes[index].JSON = json
		tableView.reloadData()
	}
	
	private func extractRouteAddresses(data: NSData!, response: NSURLResponse!, error: NSError!)
	{
		if let responseError = error
		{
			println("Error getting HTML for route addresses: \(error?.localizedDescription)")
		} else
		{
			let htmlString = NSString(data: data, encoding: NSUTF8StringEncoding)!
			let option = CInt(HTML_PARSE_NOERROR.value | HTML_PARSE_RECOVER.value)
			var err : NSError?
			
			var parser = HTMLParser(html: htmlString as String, encoding: NSUTF8StringEncoding, option: option, error: &err)
			
			if err != nil
			{
				println("Error parsing HTML for route addresses: \(err)")
			} else
			{
				if let body = parser.body
				{
					func extractRouteFromNodes(path: [HTMLNode])
					{
						for node in path
						{
							for addrNode in node.findChildTags("a")
							{
								let href = addrNode.getAttributeNamed("href")
								let routeAddr = "http://www.mtb-bg.com\(href)"
								self.loadRouteFromAddress(routeAddr)
							}
						}
					}
					if let path = body.xpath("//*[@id=\"mainbody\"]/table/tr[2]/td/form/table/tr[@class=\"sectiontableentry1\"]")
					{
						extractRouteFromNodes(path)
					}
					if let path = body.xpath("//*[@id=\"mainbody\"]/table/tr[2]/td/form/table/tr[@class=\"sectiontableentry2\"]")
					{
						extractRouteFromNodes(path)
					}
				}
			}
		}
	}
	
	private func loadRouteFromAddress(address: String)
	{
		let route = RouteModel()
		route.address = address
		
		let url = NSURL(string: address)!
		
		let session = NSURLSession.sharedSession()
		let loadDataTask = session.dataTaskWithURL(url) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
//			println(address)
			if let responseError = error
			{
				println("Error getting HTML for route: \(error?.localizedDescription)")
			} else
			{
				let htmlString = NSString(data: data, encoding: NSUTF8StringEncoding)!
				let option = CInt(HTML_PARSE_NOERROR.value | HTML_PARSE_RECOVER.value | HTML_PARSE_NOWARNING.value)
				var err : NSError?
				
				var parser = HTMLParser(html: htmlString as String, encoding: NSUTF8StringEncoding, option: option, error: &err)
				
				if err != nil
				{
					println("Error parsing HTML for route: \(err)")
				} else
				{
					if let body = parser.body
					{
						if let trackPath = body.xpath("//div[@id=\"mainbody\"]/table[2]/tr[1]/td/table/tbody/tr[2]/td/p[2]/a")
						{
							for node in trackPath
							{
								let href = node.getAttributeNamed("href")
								route.traces = "http://www.mtb-bg.com\(href)"
							}
						} else if let trackPath = body.xpath("//div[@id=\"mainbody\"]/table[2]/tr[1]/td/table/tbody/tr[2]/td/p[3]/a")
						{
							for node in trackPath
							{
								let href = node.getAttributeNamed("href")
								route.traces = "http://www.mtb-bg.com\(href)"
							}
						}
						
						if let titlePath = body.xpath("//div[@id=\"mainbody\"]/table[1]/tr[1]/td/a/text()")
						{
							for node in titlePath
							{
								let components = node.rawContents.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!isEmpty($0)})
								route.name = join(" ", components)
							}
						}

						if let path = body.xpath("//div[@id=\"mainbody\"]/table[2]/tr[1]/td/table/tbody/tr[2]/td/p/span/text()")
						{
							var titles = [String]()
							for node in path
							{
								let components = node.rawContents.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!isEmpty($0)})
								let title = join(" ", components)
								titles.append(title)
							}
							
							titles.insert("Ниво на техническа трудност:", atIndex: 3)
							titles.insert("Физическо натоварване:", atIndex: 4)
							
							if let last = titles.last
							{
								if last.rangeOfString("Терен", options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
								{
									titles.removeLast()
								}
							}
							if var afterSpan = body.xpath("//div[@id=\"mainbody\"]/table[2]/tr[1]/td/table/tbody/tr[2]/td/p/text()")
							{
								var newAfterSpan = [String]()
								for node in afterSpan
								{
									if node.rawContents != " "
									{
										let components = node.rawContents.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!isEmpty($0)})
										let nodeString = join(" ", components)
										if nodeString.rangeOfString("- асфалт", options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
										{
											titles.append("Асфалт:")
										} else if nodeString.rangeOfString("- черни", options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
										{
											titles.append("Черни пътища:")
										} else if nodeString.rangeOfString("- пътеки", options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
										{
											titles.append("Пътеки:")
										}
										newAfterSpan.append(nodeString)
									}
								}
								for (index, node) in enumerate(titles)
								{
									if index >= newAfterSpan.count
									{
										continue
									}
									let alphabet: [Character] = [" ", ",", "=", "-", ":", "(", ")", "а", "б", "в", "г", "д", "е", "ж", "з", "и", "й", "к", "л", "м", "н", "о", "п", "р", "с", "т", "у","ф", "х", "ц", "ч", "ш", "щ", "ъ", "ь", "ю", "я"]
									var components = node.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!isEmpty($0)})
									let spanString = join(" ", components)
									var afterSpanString = newAfterSpan[index]
//									println("\(spanString) \(afterSpanString)")
									
									switch(spanString)
									{
										case "Изходна точка:":
											route.startPoint = afterSpanString
										case "Дължина:":
											let stripped = afterSpanString.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil).stripCharactersInSet(alphabet)
											route.distance = (stripped as NSString).doubleValue
										case "Изкачване", "Денивелация  (изкачване):", "Денивелация":
											let stripped = afterSpanString.stripCharactersInSet(alphabet)
											route.ascent = (stripped as NSString).doubleValue
										case "Ниво на техническа трудност:":
											let stripped = afterSpanString.stripCharactersInSet(Array(alphabet[1..<alphabet.count]))
											route.difficulty = stripped.componentsSeparatedByString(",")
										case "Физическо натоварване:":
											let stripped = afterSpanString.lowercaseString.stripCharactersInSet(alphabet)
											route.strenuousness = (stripped as NSString).intValue
										case "Продължителност:":
											route.duration = afterSpanString
										case "Вода:":
											route.water = afterSpanString
										case "Храна:":
											route.food = afterSpanString
										case "Асфалт:":
											let stripped = afterSpanString.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil).stripCharactersInSet(alphabet)
											route.tarmac = (stripped as NSString).doubleValue
										case "Черни пътища:":
											let stripped = afterSpanString.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil).stripCharactersInSet(alphabet)
											route.roads = (stripped as NSString).doubleValue
										case "Пътеки:":
											let stripped = afterSpanString.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil).stripCharactersInSet(alphabet)
											route.trails = (stripped as NSString).doubleValue
										default: ()
									}
								}
								
								self.routes.append(route)
								
								dispatch_async(dispatch_get_main_queue(), { () -> Void in
									self.tableView.reloadData()
								})
							}
						}
					}
				}
			}
			println()
		}
		loadDataTask.resume()
	}
	
}
