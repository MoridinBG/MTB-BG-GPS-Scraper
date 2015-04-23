//
//  MainViewController.swift
//  RouteExtractor
//
//  Created by Ivan Dilchovski on 4/23/15.
//  Copyright (c) 2015 TechLight. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{

	@IBOutlet weak var urlField: NSTextField!
	@IBOutlet var extractText: NSTextView!
	@IBOutlet weak var tableView: NSTableView!

	private var routes = [RouteModel]()
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		let url = NSURL(string: "http://mtb-bg.com/index.php/trails/gpstracks?q=%2Findex.php%2Ftrails%2Fgpstracks")!
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
				var cellView = tableView.makeViewWithIdentifier(Constants.Keys.kCellIdrouteEditor, owner: self) as! RouteEditorCell
				let route = self.routes[row]
				cellView.routeName.stringValue = "Hello world"
				return cellView
			
			case Constants.Keys.kColumnIdrouteJSON:
				var cellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
				return cellView
			
			default:
				var cellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
				return cellView
		}
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
								//										let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!isEmpty($0)})
								//										let condensed =  join(" ", components)
								let routeAddr = "www.mtb-bg.com" + addrNode.getAttributeNamed("href")
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
//						extractRouteFromNodes(path)
					}
				}
			}
		}
	}
	
	private func loadRouteFromAddress(address: String)
	{
		println(address)
		let route = RouteModel()
		route.address = address
		routes.append(route)
		
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			self.tableView.reloadData()
		})
		
		let url = NSURL(string: "http://" + address)!
		
		let session = NSURLSession.sharedSession()
		let loadDataTask = session.dataTaskWithURL(url) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
			if let responseError = error
			{
				println("Error getting HTML for route: \(error?.localizedDescription)")
			} else
			{
				let htmlString = NSString(data: data, encoding: NSUTF8StringEncoding)!
				let option = CInt(HTML_PARSE_NOERROR.value | HTML_PARSE_RECOVER.value)
				var err : NSError?
				
				var parser = HTMLParser(html: htmlString as String, encoding: NSUTF8StringEncoding, option: option, error: &err)
				
				if err != nil
				{
					println("Error parsing HTML for route: \(err)")
				} else
				{
					if let body = parser.body
					{
						if let path = body.xpath("//table[@class=\"mceItemTable\"]/tbody/tr[2]/td/p/text()")
						{
							for node in path
							{
//								println(node.rawContents)
							}
						}
					}
				}
			}
		}
		
		loadDataTask.resume()
	}
	
}
