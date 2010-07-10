//
//  CONode.h
//  CoolOutliner
//
//  Created by Jan on 10.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KBBaseNode.h"


@interface CONode : KBBaseNode
{
	NSString *description;
	NSTextStorage *text;
}

@property (retain) NSString *description;

- (void)setText:(id)newText;
- (NSTextStorage *)text;

@end