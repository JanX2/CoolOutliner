//
//  NSArray_Extensions.h
//
//  Copyright (c) 2001-2002, Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (KBExtensions)
- (BOOL)containsObjectIdenticalTo:(id)object;
- (BOOL)containsAnyObjectsIdenticalTo:(NSArray *)objects;
- (NSIndexSet *)indexesOfObjects:(NSArray *)objects;
@end

@interface NSMutableArray (KBExtensions)
- (void)insertObjectsFromArray:(NSArray *)array atIndex:(int)index;
@end

