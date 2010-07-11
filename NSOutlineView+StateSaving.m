//
//  NSOutlineView+StateSaving.m
//  CoolOutliner
//
//  Created by Jan on 11.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSOutlineView+StateSaving.h"


@implementation NSOutlineView (StateSavingExtensions)

// The returned array can then be archived.
- (NSArray *)expandedItems;
{
	NSMutableArray *expandedItemsArray = [NSMutableArray array];
	NSUInteger row, numberOfRows = [self numberOfRows];
	
	for (row = 0 ; row < numberOfRows ; row++)
	{
		id item = [self itemAtRow:row];
		if ([self isItemExpanded:item]) {
			// create an array of only the expanded items in the list
			[expandedItemsArray addObject:[item representedObject]]; 
		}
	}
	
	return [[expandedItemsArray copy] autorelease];
}


/*
It uses NSTreeNode and -representedObject, so is 10.5 only. For 10.4
there is an undocumented method for the private class that
NSTreeController used in 10.4 that does the same thing, can't remember
the method name but it's on Scott Stevenson's blog somewhere, just
Google theococoa.com and NSTreeController.
 */

// Passing the (now unarchived) array to the method below will expand them again.
- (void)expandItems:(NSArray *)array;
{
	NSUInteger row, numberOfRows = [self numberOfRows];
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

@end
