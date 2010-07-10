//
//  KBBaseNode.h
//  ------------
//
//	Keith Blount 2005
//
//  Multi-purpose node object for use with NSOutlineView and compatible with NSTreeController. Can be used as-is or
//	subclassed to add custom model attributes. Provides convenience methods for checking validitity of drag-and-drop
//	and cleaning up afterwards, and makes subclassing easy by providing convenience methods that make overriding
//	coding and copying methods in subclasses unnecessary.
//
//	Subclasses that add new variables *must* override -mutableKeys, adding the keys for the added variables.
//	If any of the variables are not objects (eg. ints, bools etc), the subclass must also override -setNilValueForKey:.
//	By overriding these two methods, there is no need for subclasses to override -initWithCoder:, -encodeWithCoder: or
//	-copyWithZone: - all of this will be handled by the superclass using the keys returned by -mutableKeys.
//

#import <Cocoa/Cocoa.h>

@interface KBBaseNode : NSObject <NSCoding, NSCopying>
{
	NSString *title;
	NSMutableDictionary *properties;
	NSMutableArray *children;
	BOOL isLeaf;
}

/* inits a leaf node (-init initialises a group node by default) */
- (id)initLeaf;

/*************************** Accessors ***************************/

- (void)setTitle:(NSString *)newTitle;
- (NSString *)title;
- (void)setProperties:(NSDictionary *)newProperties;
- (NSMutableDictionary *)properties;

- (void)setChildren:(NSArray *)newChildren;
- (NSMutableArray *)children;

- (void)setLeaf:(BOOL)flag;
- (BOOL)isLeaf;

/*************************** Utility Methods ***************************/

/* For sorting */
- (NSComparisonResult)compare:(KBBaseNode *)aNode;

/*************************** Archiving/Copying Support ***************************/

/* Subclasses should override this method to maintain support for archiving and copying */
- (NSArray *)mutableKeys;

/* Methods for converting the node to a simple dictionary, for XML support (note that all
   instance variables must be property lists type for the dictionary to be written out as XML, though) */
- (NSDictionary *)dictionaryRepresentation;
- (id)initWithDictionary:(NSDictionary *)dictionary;

/*************************** Drag'n'Drop Convenience Methods ***************************/

/*	Finds the parent of the receiver from the nodes contained in the array */
- (id)parentFromArray:(NSArray *)array;

/*	Searches children and children of all sub-nodes to remove given object */
- (void)removeObjectFromChildren:(id)obj;

/* Generates an array of all descendants */
- (NSArray *)descendants;

/*	Generates an array of all leafs in children and children of all sub-nodes */
- (NSArray *)allChildLeafs;

/*	Returns only the children that are group nodes (used by browser for showing only groups, for instance) */
- (NSArray *)groupChildren;

/*	Returns YES if self is contained anywhere inside the children or children of sub-nodes of the nodes contained
	inside the given array */
- (BOOL)isDescendantOfOrOneOfNodes:(NSArray*)nodes;

/* Returns YES if self is a descendent of any of the nodes in the given array */
- (BOOL)isDescendantOfNodes:(NSArray*)nodes;

/* Returns the index path of within the given array - useful for dragging and dropping */
- (NSIndexPath *)indexPathInArray:(NSArray *)array;

@end
