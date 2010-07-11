//
//  CODocument.h
//  CoolOutliner
//
//  Created by Jan on 10.07.10.
//  Copyright __MyCompanyName__ 2010 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface CODocument : NSDocument
{
	IBOutlet NSOutlineView *outlineView;
	IBOutlet NSTableView *tableView;
	IBOutlet NSTextView *textView;
	IBOutlet NSTreeController *treeController;
	IBOutlet NSArrayController *arrayController;
	
	NSArray *contents;
	
	NSArray *tempExpandedItems;
}

@property (copy) NSArray *contents;
@property (copy) NSArray *tempExpandedItems;

- (IBAction)addGroup:(id)sender;
- (IBAction)addNote:(id)sender;

@end