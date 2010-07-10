//
//  KBBaseNode.m
//  --------
//
//  Keith Blount 2005
//

#import "KBBaseNode.h"
#import "NSArray_Extensions.h"

@implementation KBBaseNode

/*************************** Init/Dealloc ***************************/

#pragma mark -
#pragma mark Init/Dealloc

- (id)init
{
	if (self = [super init])
	{
		[self setTitle:@"Untitled"];
		[self setProperties:[NSDictionary dictionary]];
		[self setChildren:[NSArray array]];
		[self setLeaf:NO];							// Container by default
	}
	return self;
}

- (id)initLeaf
{
	if (self = [self init])
	{
		[self setLeaf:YES];
	}
	return self;
}

- (void)dealloc
{
	[title release];
	[properties release];
	[children release];
	
	[super dealloc];
}

/*************************** Accessors ***************************/

#pragma mark -
#pragma mark Accessors

- (void)setTitle:(NSString *)newTitle
{
	[newTitle retain];
	[title release];
	title = newTitle;
}

- (NSString *)title
{
	return title;
}

- (void)setProperties:(NSDictionary *)newProperties
{
	if (properties != newProperties)
    {
        [properties autorelease];
        properties = [[NSMutableDictionary alloc] initWithDictionary:newProperties];
    }
}

- (NSMutableDictionary *)properties
{
	return properties;
}

- (void)setChildren:(NSArray *)newChildren
{
	if (children != newChildren)
    {
        [children autorelease];
        children = [[NSMutableArray alloc] initWithArray:newChildren];
    }
}

- (NSMutableArray *)children
{
	return children;
}

- (void)setLeaf:(BOOL)flag
{
	isLeaf = flag;
	if (isLeaf)
		[self setChildren:[NSArray arrayWithObject:self]];
	else
		[self setChildren:[NSArray array]];
}

- (BOOL)isLeaf
{
	return isLeaf;
}

/*************************** Utility Methods ***************************/

/* For sorting */
- (NSComparisonResult)compare:(KBBaseNode *)aNode
{
	// Just return the result of comparing the titles
	return [[[self title] lowercaseString] compare:[[aNode title] lowercaseString]];
}

/*************************** Drag'n'Drop Convenience Methods ***************************/

#pragma mark -
#pragma mark Drag'n'Drop Convenience Methods

- (id)parentFromArray:(NSArray *)array
{
	int i;
	id node;
	for (i=0; i<[array count]; i++)
	{
		node = [array objectAtIndex:i];
		
		if (node == self)	// If we are in the root array, return nil
			return nil;
		
		if ([[node children] containsObjectIdenticalTo:self])
			return node;
		
		if (![node isLeaf])
		{
			id innerNode = [self parentFromArray:[node children]];
			if (innerNode)
				return innerNode;
		}
	}
	return nil;
}

// Convenient recursive method
- (void)removeObjectFromChildren:(id)obj
{
	// Remove object from children or the children of any sub-nodes
	NSEnumerator *enumerator = [children objectEnumerator];
	id node = nil;
	
	while (node = [enumerator nextObject])
	{
		if(node == obj)
		{
			[children removeObjectIdenticalTo:obj];
			return;
		}
		
		if (![node isLeaf])
			[node removeObjectFromChildren:obj];
	}
}

- (NSArray *)descendants
{
	NSMutableArray *descendants = [NSMutableArray array];
	NSEnumerator *enumerator = [children objectEnumerator];
	id node = nil;
	while (node = [enumerator nextObject])
	{
		[descendants addObject:node];
		
		if (![node isLeaf])
			[descendants addObjectsFromArray:[node descendants]];	// Recursive - will go down the chain to get all
	}
	return descendants;
}

// This method is useful for generating a list of leaf-only nodes
- (NSArray *)allChildLeafs
{
	NSMutableArray *childLeafs = [NSMutableArray array];
	NSEnumerator *enumerator = [children objectEnumerator];
	id node = nil;
	while (node = [enumerator nextObject])
	{
		if ([node isLeaf])
			[childLeafs addObject:node];
		else
			[childLeafs addObjectsFromArray:[node allChildLeafs]];	// Recursive - will go down the chain to get all
	}
	return childLeafs;
}

- (NSArray *)groupChildren
{
	NSMutableArray *groupChildren = [NSMutableArray array];
	NSEnumerator *childEnumerator = [children objectEnumerator];
	KBBaseNode *child;
	while (child = [childEnumerator nextObject])
	{
		if (![child isLeaf])
			[groupChildren addObject:child];
	}
	return groupChildren;
}

- (BOOL)isDescendantOfOrOneOfNodes:(NSArray*)nodes
{
    // Returns YES if we are contained anywhere inside the array passed in, including inside sub-nodes.
    NSEnumerator *enumerator = [nodes objectEnumerator];
	id node = nil;
	
    while(node = [enumerator nextObject])
	{
		if (node == self) return YES;  // Found ourself
		
		// Check all sub-nodes
		if (![node isLeaf])
		{
			if ([self isDescendantOfOrOneOfNodes:[node children]])
				return YES;
		}
    }
	
	// Didn't find self inside any of the nodes passed in
    return NO;
}

- (BOOL)isDescendantOfNodes:(NSArray*)nodes
{
    // Returns YES if any node in the array passed in is an ancestor of ours.
    NSEnumerator *enumerator = [nodes objectEnumerator];
	id node = nil;
	
    while (node = [enumerator nextObject])
	{
		// Note that the only difference between this and isAnywhereInsideChildrenOfNodes: is that we don't check
		// to see if we are actually one of the items in the array passed in, only if we are one of their descendants.
		
		// Check sub-nodes
		if (![node isLeaf])
		{
			if ([self isDescendantOfOrOneOfNodes:[node children]])
				return YES;
		}
    }
	// Didn't find self inside any of the nodes passed in
	return NO;
}

- (NSIndexPath *)indexPathInArray:(NSArray *)array
{
	NSIndexPath *indexPath = nil;
	NSMutableArray *reverseIndexes = [NSMutableArray array];
	id parent, doc = self;
	int index;
	while (parent = [doc parentFromArray:array])
	{
		index = [[parent children] indexOfObjectIdenticalTo:doc];
		if (index == NSNotFound)
			return nil;
		
		[reverseIndexes addObject:[NSNumber numberWithInt:index]];
		doc = parent;
	}
	
	// If parent is nil, we should just be in the parent array
	index = [array indexOfObjectIdenticalTo:doc];
	if (index == NSNotFound)
		return nil;
	[reverseIndexes addObject:[NSNumber numberWithInt:index]];
	
	// Now build the index path
	NSEnumerator *re = [reverseIndexes reverseObjectEnumerator];
	NSNumber *indexNumber;
	while (indexNumber = [re nextObject])
	{
		if (indexPath == nil)
			indexPath = [NSIndexPath indexPathWithIndex:[indexNumber intValue]];
		else
			indexPath = [indexPath indexPathByAddingIndex:[indexNumber intValue]];
	}
	
	return indexPath;
}

/*************************** Archiving and Copying Support ***************************/

#pragma mark -
#pragma mark Archiving And Copying Support

- (NSArray *)mutableKeys
{
	return [NSArray arrayWithObjects:
		@"title",
		@"properties",
		@"isLeaf",			// NOTE isLeaf MUST come before children for initWithDictionary: to work properly!
		@"children", 
		nil];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [self init];
	NSEnumerator *keysToDecode = [[self mutableKeys] objectEnumerator];
	NSString *key;
	while (key = [keysToDecode nextObject])
	{
		if ([key isEqualToString:@"children"])
		{
			if ([[dictionary objectForKey:@"isLeaf"] boolValue])
				[self setChildren:[NSArray arrayWithObject:self]];
			else
			{
				// Get recursive!
				NSArray *dictChildren = [dictionary objectForKey:key];
				NSMutableArray *newChildren = [NSMutableArray array];
				int i, count = [dictChildren count];
				for (i=0; i<count; i++)
				{
					id newNode = [[[self class] alloc] initWithDictionary:[dictChildren objectAtIndex:i]];
					[newChildren addObject:newNode];
					[newNode release];
				}
				[self setChildren:newChildren];
			}
		}
		else
			[self setValue:[dictionary objectForKey:key] forKey:key];
	}
	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	NSEnumerator *keysToCode = [[self mutableKeys] objectEnumerator];
	NSString *key;
	while (key = [keysToCode nextObject])
	{
		// Convert all children to dictionaries too (note that we don't bother to look
		// at the children for leaf nodes, which should just hold a reference to self).
		if ([key isEqualToString:@"children"])
		{
			if (!isLeaf)
			{
				NSMutableArray *dictChildren = [NSMutableArray array];
				int i, count = [children count];
				for (i=0; i<count; i++)
					[dictChildren addObject:[[children objectAtIndex:i] dictionaryRepresentation]];
				[dictionary setObject:dictChildren forKey:key];
			}
		}
		else if ([self valueForKey:key])
			[dictionary setObject:[self valueForKey:key] forKey:key];
	}
	return dictionary;
}

- (id)initWithCoder:(NSCoder *)coder
{		
	self = [self init];	// Make sure all the instance variables are  initialised
	NSEnumerator *keysToDecode = [[self mutableKeys] objectEnumerator];
	NSString *key;
	while (key = [keysToDecode nextObject])
		[self setValue:[coder decodeObjectForKey:key] forKey:key];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{	
	NSEnumerator *keysToCode = [[self mutableKeys] objectEnumerator];
	NSString *key;
	while (key = [keysToCode nextObject])
		[coder encodeObject:[self valueForKey:key] forKey:key];
}

- (id)copyWithZone:(NSZone *)zone
{
	id newNode = [[[self class] allocWithZone:zone] init];
	
	NSEnumerator *keysToSet = [[self mutableKeys] objectEnumerator];
	NSString *key;
	while (key = [keysToSet nextObject])
		[newNode setValue:[self valueForKey:key] forKey:key];
	
	return newNode;
}

// Subclasses must override this for any non-object values
- (void)setNilValueForKey:(NSString *)key
{
	if ([key isEqualToString:@"isLeaf"])
		isLeaf = NO;
	else
		[super setNilValueForKey:key];
}

@end
