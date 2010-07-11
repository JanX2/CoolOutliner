//
//  CONode.m
//  CoolOutliner
//
//  Created by Jan on 10.07.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CONode.h"


@implementation CONode

@synthesize description;

- (id)init
{
	if (self = [super init])
	{
		title = [[NSString alloc] initWithString:@"Untitled"];
		description = [[NSString alloc] initWithString:@"- No description -"];
		text = [[NSTextStorage alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[description release];
	[text release];
	[super dealloc];
}

/*
 Note that setText: can accept an NSTextStorage, an NSAttributedString, an
 NSMutableAttributedString, or a simple NSString – any will work. (This is a nifty tip I picked up from
 an article over at www.projectomega.org.)
 */
- (void)setText:(id)newText
{
	if ([newText isKindOfClass:[NSAttributedString class]])
		[text replaceCharactersInRange:NSMakeRange(0,[text length])
				  withAttributedString:newText];
	else
		[text replaceCharactersInRange:NSMakeRange(0,[text length]) withString:newText];
}

- (NSTextStorage *)text
{
	return text;
}


- (NSArray *)mutableKeys
{
	return [[super mutableKeys] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:
															   @"description",
															   @"text",
															   nil]];
}

@end
