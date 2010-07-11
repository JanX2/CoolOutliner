//
//  NSOutlineView+StateSaving.h
//  CoolOutliner
//
//  Created by Jan on 11.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSOutlineView (StateSavingExtensions) 

- (NSArray *)expandedItems;
- (void)restoreExpandedStateWithArray:(NSArray *)array;

@end
