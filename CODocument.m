//
//  CODocument.m
//  CoolOutliner
//
//  Created by Jan on 10.07.10.
//  Copyright __MyCompanyName__ 2010 . All rights reserved.
//

#import "CODocument.h"
#import "CONode.h"
#import "NSOutlineView+StateSaving.h"
#import "NSArray_ESExtensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"

NSString * const	CONodesPboardType = @"CONodesPboardType";

@implementation CODocument

@synthesize selectedNodes;

@synthesize tempExpandedItems;

- (id)init
{
    self = [super init];
    if (self) {
    
		[self setContents:[[NSMutableArray alloc] init]];
		[self setSelectedNodes:[NSArray array]];
    
    }
    return self;
}

- (void)dealloc
{
	[self setContents:nil];
	[self setSelectedNodes:nil];
	[super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"CODocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
	
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	[outlineView registerForDraggedTypes:[NSArray arrayWithObject:CONodesPboardType]];

	if ([self tempExpandedItems] != nil)
	{
		[outlineView restoreExpandedStateWithArray:[self tempExpandedItems]];
		[self setTempExpandedItems:nil];
	}
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
					   contents, @"contents",
					   [outlineView expandedItems], @"expandedItems",
					   nil];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:d];
	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
	// Note that we have only done the bare minimum here – if this was a shipping application, we should really check for errors and fill outError as appropriate, and check for typeName if we want to allow different types.
	
	NSDictionary *d = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	[self setContents:[d objectForKey:@"contents"]];

	// We have to defer expanding the items until the outlineView actually exists -> windowControllerDidLoadNib
	// If you have a better idea how to resolve this, fork this on github, apply your changes and send a pull request. 
	[self setTempExpandedItems:[d objectForKey:@"expandedItems"]];

	return YES;
}

- (void)setContents:(NSArray *)newContents;
{
	if (contents != newContents)
	{
		[contents autorelease];
		contents = [newContents mutableCopy];
	}
}

- (NSArray *)contents {
    if (!contents) {
        contents = [[NSMutableArray alloc] init];
    }
    return [[contents retain] autorelease];
}

/*
- (unsigned)countOfContents {
    if (!contents) {
        contents = [[NSMutableArray alloc] init];
    }
    return [contents count];
}

- (id)objectInContentsAtIndex:(unsigned)theIndex {
    if (!contents) {
        contents = [[NSMutableArray alloc] init];
    }
    return [contents objectAtIndex:theIndex];
}

- (void)getContents:(id *)objsPtr range:(NSRange)range {
    if (!contents) {
        contents = [[NSMutableArray alloc] init];
    }
    [contents getObjects:objsPtr range:range];
}

- (void)insertObject:(id)obj inContentsAtIndex:(unsigned)theIndex {
    if (!contents) {
        contents = [[NSMutableArray alloc] init];
    }
    [contents insertObject:obj atIndex:theIndex];
}

- (void)removeObjectFromContentsAtIndex:(unsigned)theIndex {
    if (!contents) {
        contents = [[NSMutableArray alloc] init];
    }
    [contents removeObjectAtIndex:theIndex];
}

- (void)replaceObjectInContentsAtIndex:(unsigned)theIndex withObject:(id)obj {
    if (!contents) {
        contents = [[NSMutableArray alloc] init];
    }
    [contents replaceObjectAtIndex:theIndex withObject:obj];
}
*/



- (IBAction)addGroup:(id)sender
{
	// NSTreeController inserts objects using NSIndexPath, so we need to calculate this first
	NSIndexPath *indexPath = nil;
	
	// If there is no selection, we will add a new group to the end of our contents array
	if (![treeController selectionIndexPath])
	{
		indexPath = [NSIndexPath indexPathWithIndex:[contents count]];
	}
	else
	{
		// We can't add nodes to leaf nodes
		if ([[[treeController selectedObjects] objectAtIndex:0] isLeaf])
		{
			NSBeep();
			return;
		}
		
		// Get the index path of the currently selected node, and then add the number its children to the path -
		// this will give us an index path which will allow us to add a node to the end of the currently selected
		// node's children array
		indexPath = [treeController selectionIndexPath];
		indexPath = [indexPath indexPathByAddingIndex:[[[[treeController selectedObjects]
														 objectAtIndex:0] children] count]];
	}
	
	// Create and add a new group node
	CONode *node = [[CONode alloc] init];
	// This is where you would add any code to customise the new node
	[treeController insertObject:node atArrangedObjectIndexPath:indexPath];
	[node release];
}

- (IBAction)addNote:(id)sender
{
	// We do not allow nodes to be added to the root - they can only be added to groups.
	// (If you want to allow notes to be added to the root, just get ride of these five lines.)
	if (![treeController selectionIndexPath])
	{
		NSBeep();
		return;
	}
	
	// We can't add nodes to leaf nodes
	// CHANGEME: Add node to parent instead
	if ([[[treeController selectedObjects] objectAtIndex:0] isLeaf])
	{
		NSBeep();
		return;
	}
	
	NSIndexPath *indexPath = [treeController selectionIndexPath];
	indexPath = [indexPath indexPathByAddingIndex:[[[[treeController selectedObjects]
													 objectAtIndex:0] children] count]];
	
	CONode *node = [[CONode alloc] initLeaf];
	// This is where you would add any code to customise the new node
	[treeController insertObject:node atArrangedObjectIndexPath:indexPath];
	[node release];
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	// Make sure we are responding to the correct outline view
	if ([notification object] != outlineView)
		return;
	
	// Deal with multiple selections
	NSMutableArray *newSelection = [NSMutableArray array];
	if ([[treeController selectedObjects] count] > 1)
	{
		NSEnumerator *enumerator = [[treeController selectedObjects] objectEnumerator];
		CONode *node;
		
		while (node = [enumerator nextObject])
		{
			if ([node isLeaf])
			{
				if (![newSelection containsObject:node])
					[newSelection addObject:node];
			}
			else
			{
				NSMutableArray *leafNodes = [[node allChildLeafs] mutableCopy];
				[leafNodes removeObjectsInArray:newSelection];
				[newSelection addObjectsFromArray:leafNodes];
				[leafNodes release];
			}
		}
	}
	else if ([[treeController selectedObjects] count] == 1)
	{
		CONode *node = [[treeController selectedObjects] objectAtIndex:0];
		[newSelection addObjectsFromArray:[node allChildLeafs]];
	}
	
	[self setSelectedNodes:newSelection];
	
	// If the selection changed to nothing, do nothing
	if ([[treeController selectedObjects] count] == 0)
		return;

	CONode *selectedNode = [[treeController selectedObjects] objectAtIndex:0];
	
	// Don't display the text of group nodes
	if (![selectedNode isLeaf])
		return;
	
	[textView setSelectedRange:NSMakeRange(0,0)];
	
	// Replace the text in the text view if it has changed
	if ([textView textStorage] != [selectedNode text])
		[[textView layoutManager] replaceTextStorage:[selectedNode text]];
	
	// Make sure the text view is in an editable state
	if (![textView isEditable])
		[textView setEditable:YES];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	// Make sure we are responding to the correct table view
	if ([notification object] != tableView)
		return;
	
	// If the selection changed to nothing, do nothing
	if ([[arrayController selectedObjects] count] == 0)
		return;
	
	CONode *selectedNode = [[arrayController selectedObjects] objectAtIndex:0];
	
	// Don't display the text of group nodes
	if (![selectedNode isLeaf])
		return;
	
	[textView setSelectedRange:NSMakeRange(0,0)];
	
	// Replace the text in the text view if it has changed
	if ([textView textStorage] != [selectedNode text])
		[[textView layoutManager] replaceTextStorage:[selectedNode text]];
	
	// Make sure the text view is in an editable state
	if (![textView isEditable])
		[textView setEditable:YES];
}


- (BOOL)outlineView:(NSOutlineView *)ov
		 writeItems:(NSArray *)items
	   toPasteboard:(NSPasteboard *)pboard;
{
	// Declare the types we are about to put on the pasteboard
	[pboard declareTypes:[NSArray arrayWithObject:CONodesPboardType] owner:self];
	
	// Archive the nodes for moving (we must set the data as we can drag to another document if we want)
	[pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:CONodesPboardType];
	
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov
				  validateDrop:(id <NSDraggingInfo>)info
				  proposedItem:(id)proposedParentItem
			proposedChildIndex:(NSInteger)proposedChildIndex;
{
	// Ensure the proposed drop index is valid
	if (proposedChildIndex == -1) // will be -1 if the mouse is hovering over a leaf node
		return NSDragOperationNone;

	// If we are dragging into the root (contents) - in which case
	// the item will be nil - we are fine
	if (proposedParentItem == nil)
		return NSDragOperationGeneric;
	
	NSPasteboard *pboard = [info draggingPasteboard];

	// Check drag types
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject:CONodesPboardType]])
	{
		NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:CONodesPboardType]];
		BOOL targetIsValid = YES;
		
		for (NSIndexPath *indexPath in draggedIndexPaths) {
			
			NSTreeNode *node = [treeController nodeAtIndexPath:indexPath];
			
			// We can only drag into folders
			if (!node.isLeaf) {
				
				// If we were dragged from a different outline view, we don't need to do any more checks - just accept
				if ([info draggingSource] != outlineView)
					return NSDragOperationGeneric;
				
				// Otherwise, we have to make sure the drop is valid
				
				// Don't allow a folder to be dragged inside itself or any of its descendants
				// (We check draggedNodes because we have to check the items that are currently there)
				if ([proposedParentItem isDescendantOfNode:node] || proposedParentItem == node) { 
					targetIsValid = NO;
					break;
				}
				
			}
		}
		
		// If we've got this far and the target is valid, we're good to go
		return targetIsValid ? NSDragOperationMove : NSDragOperationNone;
		
	}
	
	return NSDragOperationNone;
	
}

- (BOOL)outlineView:(NSOutlineView *)ov
		 acceptDrop:(id <NSDraggingInfo>)info
			   item:(id)proposedParentItem
		 childIndex:(NSInteger)proposedChildIndex;
{
	// Get the pasteboard
	NSPasteboard *pboard = [info draggingPasteboard];
	
	// Check the dragging type
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject:CONodesPboardType]])
	{
		BOOL draggingWithinWindow;
		NSTreeController *sourceTreeController;

		NSOutlineView *source = [info draggingSource];

		if (source == ov) {
			draggingWithinWindow = YES;
			sourceTreeController = treeController;
		}
		else {
			draggingWithinWindow = NO;
			// This is a bit of a hack: 
			// we as the outlineTableColumn of the source NSOutlineView 
			// for the NSTreeController it is bound to. 
			//NSArray *bindings = [[source outlineTableColumn] exposedBindings];
			//NSDictionary *valueInfo = [[source outlineTableColumn] infoForBinding:@"value"];
			sourceTreeController = [[[source outlineTableColumn] infoForBinding:@"value"] valueForKey:NSObservedObjectKey];		
		}
		
		// Read the data
		NSArray *droppedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:CONodesPboardType]];
		
		// Convert the index paths in droppedIndexPaths into the actual nodes
		NSMutableArray *draggedNodes = [NSMutableArray array];
		for (NSIndexPath *indexPath in droppedIndexPaths) {
			[draggedNodes addObject:[sourceTreeController nodeAtIndexPath:indexPath]];
		}
		
		NSIndexPath *targetIndexPath = nil;
		// Determine the index path of the drag target
		NSIndexPath *proposedParentIndexPath;
		if (proposedParentItem == nil) {
			// makes a NSIndexPath with length == 0
			proposedParentIndexPath = [[[NSIndexPath alloc] init] autorelease];
		}
		else {
			proposedParentIndexPath = [proposedParentItem indexPath];
		}
		targetIndexPath = [proposedParentIndexPath indexPathByAddingIndex:proposedChildIndex];
		
		
		// If dragged from self...
		if (draggingWithinWindow)
		{
			[treeController moveNodes:draggedNodes toIndexPath:targetIndexPath];
			
		}
		else {
			// The drag source is another window. 
			// We need to copy each representedObject to the destination.
			
			NSArray *newNodes = [draggedNodes valueForKey:@"representedObject"];
			
			// Add the new items (we do this backwards, otherwise they will end up in reverse order)
			for (CONode *thisNode in [newNodes reverseObjectEnumerator])
			{
				// We only want to copy in each item in the array once - if a folder
				// is open and the folder and its contents were selected and dragged,
				// we only want to drag the folder, of course.
				if (![thisNode isDescendantOfNodes:newNodes])
				{
					[treeController insertObject:[[thisNode copy] autorelease]
					   atArrangedObjectIndexPath:targetIndexPath];
					
					/*
					 // Set a unique ID that fits with this document if dragged from another document
					 if ([info draggingSource] != outlineView)
					 [[thisNode properties] setValue:[NSNumber
					 numberWithInt:[self uniqueID]] forKey:@"ID"];
					 */
				}
			}
			
		}
		
		// Make sure the proposed parent is expanded
		[ov expandItem:proposedParentItem];

		// Now go through the outline view and select any items that we just added (note that
		// we extend the selection only after selecting the first one, so that this replaces
		// any current selection).
		NSInteger i;
		BOOL extendSelection = NO;
		for (i = [ov rowForItem:proposedParentItem]; i < [ov numberOfRows]; i++)
		{
			if ([draggedNodes containsObject:[ov itemAtRow:i]])
			{
				[ov selectRow:i byExtendingSelection:extendSelection];
				extendSelection = YES;
			}
		}

		return YES;
		
	}
	
	return NO;

}

@end
