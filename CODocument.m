//
//  CODocument.m
//  CoolOutliner
//
//  Created by Jan on 10.07.10.
//  Copyright __MyCompanyName__ 2010 . All rights reserved.
//

#import "CODocument.h"
#import "CONode.h"

@implementation CODocument

@synthesize contents;

- (id)init
{
    self = [super init];
    if (self) {
    
		contents = [[NSArray alloc] init];
    
    }
    return self;
}

- (void)dealloc
{
	[contents release];
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
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

/*
- (void)setContents:(NSArray *)newContents;
{
	if (contents != newContents)
	{
		[contents autorelease];
		contents = [[NSMutableArray alloc] initWithArray:newContents];
	}
}

- (NSMutableArray *)contents;
{
	return contents;
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
@end
