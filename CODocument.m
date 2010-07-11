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
		[newSelection addObjectsFromArray:[[[treeController selectedObjects]
											objectAtIndex:0] allChildLeafs]];
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
	// Save the list of items (don't need to retain as it's just used temporarily while the drag occurs)
	// (Note that we have to convert this to the observed object because we are using NSTreeController)
	draggedNodes = [items valueForKey:@"representedObject"];
	
	// Declare the types we are about to put on the pasteboard
	[pboard declareTypes:[NSArray arrayWithObject:CONodesPboardType] owner:self];
	
	// Archive the nodes for moving (we must set the data as we can drag to another document if we want)
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:draggedNodes];
	[pboard setData:data forType:CONodesPboardType];
	
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov
				  validateDrop:(id <NSDraggingInfo>)info
				  proposedItem:(id)item
			proposedChildIndex:(NSInteger)index;
{
	NSPasteboard *pboard = [info draggingPasteboard];
	
	// Convert item to something useful (because we are using NSTreeController)
	CONode *proposedItem = [item representedObject];
	
	// Check drag types
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject:CONodesPboardType]])
	{
		// Ensure the proposed drop index is valid
		if (index == -1)
			return NSDragOperationNone;
		
		// If we are dragging into the root (contents) - in which case
		// the item will be nil - we are fine
		if (!proposedItem)
			return NSDragOperationGeneric;
		
		// We can only drag into folders
		if (![proposedItem isLeaf])
		{
			// If we were dragged from a different outline view, we don't need to do any more checks - just accept
			if ([info draggingSource] != outlineView)
				return NSDragOperationGeneric;
			
			// Otherwise, we have to make sure the drop is valid
			
			// Don't allow a folder to be dragged inside itself or any of its descendants
			// (We check draggedNodes because we have to check the items that are currently there)
			if ([proposedItem isDescendantOfOrOneOfNodes:draggedNodes])
				return NSDragOperationNone;
			
			// If we've got this far, we're good to go
			return NSDragOperationGeneric;
		}
	}
	return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)ov
		 acceptDrop:(id <NSDraggingInfo>)info
			   item:(id)targetItem
		 childIndex:(NSInteger)index;
{
	NSUInteger i, n;
	NSPasteboard *pboard = [info draggingPasteboard]; // Get the pasteboard
	CONode *targetNode = [targetItem representedObject];
	NSMutableArray *targetArray = (targetItem) ? [targetNode children] : contents;
	
	// Check the dragging type
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject:CONodesPboardType]])
	{
		// Read the data
		NSData *data = [pboard dataForType:CONodesPboardType];
		NSArray *newNodes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
		// Add the new items (we do this backwards, otherwise they will end up in reverse order)
		for (CONode *thisNode in [newNodes reverseObjectEnumerator])
		{
			// We only want to copy in each item in the array once - if a folder
			// is open and the folder and its contents were selected and dragged,
			// we only want to drag the folder, of course.
			if (![thisNode isDescendantOfNodes:newNodes])
			{
				[targetArray insertObject:thisNode atIndex:index];
				
				// For some reason, when using an NSTreeController, it is vital to refresh the data,
				// otherwise we get strange effects.
				if (targetItem)
					[outlineView reloadItem:targetItem reloadChildren:[ov isItemExpanded:targetItem]];
				else
					[outlineView reloadData];
				
				/*
				// Set a unique ID that fits with this document if dragged from another document
				if ([info draggingSource] != outlineView)
					[[thisNode properties] setValue:[NSNumber
																	   numberWithInt:[self uniqueID]] forKey:@"ID"];
				 */
			}
		}
		
		// Now delete the originals if dragged from self
		if ([info draggingSource] == ov)
		{
			for (CONode *thisNode in draggedNodes)
			{
				// First, try deleting them from the root folder
				[contents removeObject:thisNode];
				
				// In case this didn’t work, check all the subfolders
				for (CONode *aNode in draggedNodes)
				{
					if(![aNode isLeaf])
						[aNode removeObjectFromChildren:thisNode];
				}
			}
			
			// Reload the outline view
			[outlineView reloadData];
		}
		
		// Make sure target item is expanded
		if (targetItem)
			[ov expandItem:targetItem];
		
		// Now go through the outline view and select any items that we just added (note that
		// we extend the selection only after selecting the first one, so that this replaces
		// any current selection).
		BOOL extendSelection = NO;
		for (i = [outlineView rowForItem:targetItem]; i < [outlineView numberOfRows]; i++)
		{
			if ([newNodes containsObject:[[ov itemAtRow:i] representedObject]])
			{
				[outlineView selectRow:i byExtendingSelection:extendSelection];
				extendSelection = YES;
			}
		}
		return YES;
		
	}
	return NO;
	
}

/*
#pragma mark -
#pragma mark NSOutlineView Hacks for Drag and Drop

- (BOOL) outlineView:(NSOutlineView *)ov
	isItemExpandable:(id)item 
{ return NO; }

- (int)    outlineView:(NSOutlineView *)ov
numberOfChildrenOfItem:(id)item
{ return 0; }

- (id)   outlineView:(NSOutlineView *)ov
			   child:(NSInteger)index
			  ofItem:(id)item 
{ return nil; }

- (id)        outlineView: (NSOutlineView *)ov
objectValueForTableColumn:(NSTableColumn*)col
				   byItem:(id)item 
{ return nil; }
*/

@end
