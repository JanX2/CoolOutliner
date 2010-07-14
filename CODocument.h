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
	
	NSMutableArray *contents;
	NSArray *selectedNodes;
}

- (void)setContents:(NSArray *)newContents;
- (NSArray *)contents;
/*
- (unsigned)countOfContents;
- (id)objectInContentsAtIndex:(unsigned)theIndex;
- (void)getContents:(id *)objsPtr range:(NSRange)range;
- (void)insertObject:(id)obj inContentsAtIndex:(unsigned)theIndex;
- (void)removeObjectFromContentsAtIndex:(unsigned)theIndex;
- (void)replaceObjectInContentsAtIndex:(unsigned)theIndex withObject:(id)obj;
*/

@property (copy) NSArray *selectedNodes;

- (IBAction)addGroup:(id)sender;
- (IBAction)addNote:(id)sender;

@end