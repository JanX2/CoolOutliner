//
//  NSOutlineView+StateSaving.m
//  CoolOutliner
//
//  Created by Jan on 11.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSOutlineView+StateSaving.h"


@implementation NSOutlineView (StateSavingExtensions)
/* The following code is based on Jonathan Dann’s sample code posted here:
 * “NSOutlineView autosaving of expanded/collapsed”
 * http://www.cocoabuilder.com/archive/cocoa/199705-nsoutlineview-autosaving-of-expanded-collapsed-state.html
 */

/*
 These methods uses NSTreeNode and -representedObject, so it’s 10.5 only. 
 For 10.4 there is an undocumented method for the private class that
 NSTreeController used in 10.4 that does the same thing: -observedObject
 */


// The returned array can then be archived.
- (NSArray *)expandedItems;
{
	NSMutableArray *expandedItemsArray = [NSMutableArray array];
	NSInteger row, numberOfRows = [self numberOfRows];
	
	for (row = 0 ; row < numberOfRows ; row++)
	{
		id item = [self itemAtRow:row];
		if ([self isItemExpanded:item]) {
			// create an array of only the expanded items in the list
			[expandedItemsArray addObject:[item representedObject]]; 
			// If the items you use in the outline view are large 
			// this can significantly increase the size of your save files.
			// In this case you could add a unique identifier to your objects, 
			// store that and compare the IDs instead of using -isEqual: below.
		}
	}
	
	return [[expandedItemsArray copy] autorelease];
}


// Passing the (now unarchived) array to the method below will expand them again.
- (void)restoreExpandedStateWithArray:(NSArray *)array;
{
	NSInteger row, numberOfRows = [self numberOfRows];
	for (id savedItem in array) {
		for (row = 0 ; row < numberOfRows ; row++) {
			id item = [self itemAtRow:row];
			id realObject = [item representedObject];
			if ([realObject isEqual:savedItem]) {
				[self expandItem:item];
				numberOfRows = [self numberOfRows];
				break;
			}
		}
	}
}


// Saves the expanded state into the expandState key of the items.
// The items need to have the key to which the value is stored.
// This makes sense only, if the items are used in a single outline view at time. 
- (void)saveExpandedStateToItems;
{
	NSInteger row, numberOfRows = [self numberOfRows];
	
	for (row = 0 ; row < numberOfRows ; row++) {
		id item = [self itemAtRow:row];
		
		[[item representedObject] 
		 setValue:[NSNumber numberWithBool:[self isItemExpanded:item]]
		 forKey:@"expandState"];
	}
}


// Restores the expanded state from the expandState key of the items.
- (void)restoreExpandedStateFromItems;
{
	NSInteger row, numberOfRows = [self numberOfRows];
	
	for (row = 0 ; row < numberOfRows ; row++) {
		id item = [self itemAtRow:row];
		
		if ([[[item representedObject] valueForKey:@"expandState"] boolValue]) {
			[self expandItem:item];
			numberOfRows = [self numberOfRows];
		}
		
	}
}

@end
