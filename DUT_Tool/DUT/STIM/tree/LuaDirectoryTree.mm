//
//  LuaDirectoryTree.m
//  LuaDebugPanel
//

//

#import "LuaDirectoryTree.h"
#import "AAPLSimpleNodeData.h"
#import "AAPLImageAndTextCell.h"
//#import <CoreLib/TestEngine.h>
//#import <CoreLib/SerialportEx.h>

//extern TestEngine * pTestEngine;
#pragma mark -

// It is best to #define strings to avoid making typing errors
//#define LOCAL_REORDER_PASTEBOARD_TYPE   @"MyCustomOutlineViewPboardType"
//#define COLUMNID_IS_EXPANDABLE          @"IsExpandableColumn"
#define COLUMNID_NAME                   @"NameColumn"
//#define COLUMNID_NODE_KIND              @"NodeKindColumn"
//#define COLUMID_IS_SELECTABLE           @"IsSelectableColumn"

#define NAME_KEY                        @"Name"
#define CHILDREN_KEY                    @"Children"
#define LUABASEPATH                    @"/vault/LuaDebugFiles"

#pragma mark -


@implementation LuaDirectoryTree
#pragma mark - NSTextViewDelegate (The required ones)
- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray<NSValue *> *)affectedRanges replacementStrings:(nullable NSArray<NSString *> *)replacementStrings
{
    m_isChange=YES;
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        // Load our initial outline view data from the "InitInfo" dictionary.
        m_isChange=NO;
        m_SelectFileName=nil;
        AAPLSimpleNodeData *childNodeData = [[AAPLSimpleNodeData alloc] initWithName:@"OVRoot"];
        childNodeData.container = YES;
        NSTreeNode *childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:childNodeData];
        _rootTreeNode =[childTreeNode retain];
        
            [[NSFileManager defaultManager] createDirectoryAtPath:LUABASEPATH withIntermediateDirectories:YES attributes:nil error:nil];
        
        [self treeNodeFrom:LUABASEPATH ParentNode:_rootTreeNode];
        
        
        assert(_rootTreeNode);
    }
    return self;
}

-(IBAction)RunSelectLuaFile:(id)sender
{
    NSFileManager * manager = [NSFileManager defaultManager];
    int err;
    if (m_SelectFileName==nil) {
        return;
    }
    if(![manager fileExistsAtPath:m_SelectFileName])
    {
        [self ShowAlter:@"Please Select Lua at frist."];
        return;
    }
    int runid=(int)[m_cbSocket indexOfSelectedItem];
    if (runid<0) {
        runid=0;
    }
//    CScriptEngine * se=(CScriptEngine*)[pTestEngine GetScripEngine:runid];
//    err=se ->DoFile([m_SelectFileName cStringUsingEncoding:NSUTF8StringEncoding]);
//    if (err)
//    {
//        [self ShowAlter:[NSString stringWithFormat:@"Save lua error:%s",lua_tostring(se->m_pLuaState, -1) ]];
//    }
}
-(IBAction)SaveSelectLuaFile:(id)sender
{
    NSError *error;
    NSFileManager * manager = [NSFileManager defaultManager];
    if (m_SelectFileName==nil) {
        return;
    }
    if(![manager fileExistsAtPath:m_SelectFileName])
    {
        [self ShowAlter:@"Please Select Lua at frist."];
        return;
    }
    NSLog(@"string:%@",[m_luaView string]);
    BOOL ret=[[m_luaView string] writeToFile:m_SelectFileName atomically:NO encoding:NSUTF8StringEncoding error:&error];
    if (!ret) {
        [self ShowAlter:@"Save lua error"];
    }else
    {
        m_isChange=NO;
    }
}
- (IBAction)addContainer:(id)sender {
    // Create a new model object, and insert it into our tree structure
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString *c_path;
    NSString *FilePath;
    NSTreeNode *node = [self getSelectionDirectoryNode];
//    AAPLSimpleNodeData *pnodedata=[node representedObject];
    NSString *ppath=[self getNodePath:node];
    int i=0;
    while (true) {
        c_path=[NSString stringWithFormat:@"New Container_%d",i];
        i++;
        FilePath=[ppath stringByAppendingPathComponent:c_path];
        if(![manager fileExistsAtPath:FilePath])
        {
            [manager createDirectoryAtPath:FilePath withIntermediateDirectories:YES attributes:nil error:nil];
            break;
        }
        
    }
    AAPLSimpleNodeData *childNodeData = [[AAPLSimpleNodeData alloc] initWithName:c_path];
    [self addNewDataToSelection:childNodeData];
}

- (IBAction)addLeaf:(id)sender {
    
    // Create a new model object, and insert it into our tree structure
    NSError *error;
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString *c_path;
    NSString *FilePath;
    NSTreeNode *node = [self getSelectionDirectoryNode];
//    AAPLSimpleNodeData *pnodedata=[node representedObject];
    NSString *ppath=[self getNodePath:node];
    int i=0;
    while (true) {
        c_path=[NSString stringWithFormat:@"new lua_%d.lua",i];
        i++;
        FilePath=[ppath stringByAppendingPathComponent:c_path];
        if(![manager fileExistsAtPath:FilePath])
        {
            [@"" writeToFile:FilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            break;
        }
        
    }
    AAPLSimpleNodeData *childNodeData = [[AAPLSimpleNodeData alloc] initWithName:c_path];
    childNodeData.container = NO;
    [self addNewDataToSelection:childNodeData];
    
//    AAPLSimpleNodeData *childNodeData = [[AAPLSimpleNodeData alloc] initWithName:@"New Leaf"];
//    childNodeData.container = NO;
//    [self addNewDataToSelection:childNodeData];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    // This message is sent whenever the selection changes
    if ([[_outlineView selectedRowIndexes] count] > 1) {
        //[selectionOutput setStringValue:@"Multiple Rows Selected"];
    } else if ([[_outlineView selectedRowIndexes] count] == 1) {
        // Grab the single selected row value
//        NSTreeNode *node = [_outlineView itemAtRow:[_outlineView selectedRow]];
        //AAPLSimpleNodeData *data = [node representedObject];
       // [selectionOutput setStringValue:[data name]];
    } else {
        //[selectionOutput setStringValue:@"Nothing Selected"];
    }
}
- (IBAction)deleteSelections:(id)sender {
    [_outlineView beginUpdates];
    [[_outlineView selectedRowIndexes] enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger row, BOOL *stop) {
        NSTreeNode *node = [_outlineView itemAtRow:row];
        NSTreeNode *parent = [node parentNode];
        NSMutableArray *childNodes = [parent mutableChildNodes];
        NSInteger index = [childNodes indexOfObject:node];
        [childNodes removeObjectAtIndex:index];
        if (parent == _rootTreeNode) {
            parent = nil; // NSOutlineView doesn't know about our root node, so we use nil
        }
        [_outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parent withAnimation:NSTableViewAnimationEffectFade | NSTableViewAnimationSlideLeft];
    }];
    [_outlineView endUpdates];
}
#pragma mark - NSOutlineViewDataSource (The required ones)

// The NSOutlineView uses 'nil' to indicate the root item. We return our root tree node for that case.
- (NSArray *)childrenForItem:(id)item {
    if (item == nil) {
        return [_rootTreeNode childNodes];
    } else {
        return [item childNodes];
    }
}

// Required methods.
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    // 'item' may potentially be nil for the root item.
    NSArray *children = [self childrenForItem:item];
    // This will return an NSTreeNode with our model object as the representedObject
    return children[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    // 'item' will always be non-nil. It is an NSTreeNode, since those are always the objects we give NSOutlineView.
    // We access our model object from it.
    AAPLSimpleNodeData *nodeData = [item representedObject];
    // We can expand items if the model tells us it is a container
    return nodeData.container;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    // 'item' may potentially be nil for the root item.
    NSArray *children = [self childrenForItem:item];
    return [children count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    id objectValue = nil;
    AAPLSimpleNodeData *nodeData = [item representedObject];
    
    // The return value from this method is used to configure the state of the items cell via setObjectValue:
    if ((tableColumn == nil) || [[tableColumn identifier] isEqualToString:COLUMNID_NAME]) {
        objectValue = nodeData.name;
    }
 /*
    else if ([[tableColumn identifier] isEqualToString:COLUMNID_IS_EXPANDABLE]) {
        // Here, object value will be used to set the state of a check box.
        BOOL isExpandable = nodeData.container && nodeData.expandable;
        objectValue = @(isExpandable);
    } else if ([[tableColumn identifier] isEqualToString:COLUMNID_NODE_KIND]) {
        objectValue = (nodeData.container ? @"Container" : @"Leaf");
    } else if ([[tableColumn identifier] isEqualToString:COLUMID_IS_SELECTABLE]) {
        // Again -- this object value will set the state of the check box.
        objectValue = @(nodeData.selectable);
    }
    */
    return objectValue;
}
-(void)ShowAlter:(NSString*)msg
{
    NSAlert * alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Lua Debug Error"];
    [alert setInformativeText:msg];
    [alert runModal];
    [alert release];
}
-(BOOL)RanamePAth:(NSString*)sourcefile TargetPath:(NSString*)targetpath
{
    NSError * err = NULL;
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL result = [manager moveItemAtPath:sourcefile toPath:targetpath error:&err];
    if(!result)
    {
        NSLog(@"Error: %@", err);
    }
    return result;
}

// Optional method: needed to allow editing.
- (void)outlineView:(NSOutlineView *)ov setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item  {
    AAPLSimpleNodeData *nodeData = [item representedObject];
    
    // Here, we manipulate the data stored in the node.
    NSString *p=[self getNodePath:item];
    NSString *t=[[p stringByDeletingLastPathComponent] stringByAppendingPathComponent:object];
    //if ((tableColumn == nil) || [[tableColumn identifier] isEqualToString:COLUMNID_NAME])
    if ([self RanamePAth:p TargetPath:t])
    {
        nodeData.name = object;
    }else
    {
        [self ShowAlter:@"Rename files error"];
    }
    /*
    else if ([[tableColumn identifier] isEqualToString:COLUMNID_IS_EXPANDABLE]) {
        nodeData.expandable = [object boolValue];
        if (!nodeData.expandable && [_outlineView isItemExpanded:item]) {
            [_outlineView collapseItem:item];
        }
    } else if ([[tableColumn identifier] isEqualToString:COLUMNID_NODE_KIND]) {
        // We don't allow editing of this column, so we should never actually get here.
    } else if ([[tableColumn identifier] isEqualToString:COLUMID_IS_SELECTABLE]) {
        nodeData.selectable = [object boolValue];
    }
     */
}

// We can return a different cell for each row, if we want
- (NSCell *)outlineView:(NSOutlineView *)ov dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // If we return a cell for the 'nil' tableColumn, it will be used as a "full width" cell and span all the columns
    if (tableColumn == nil)
    {
        AAPLSimpleNodeData *nodeData = [item representedObject];
        if (nodeData.container) {
            // We want to use the cell for the name column, but we could construct a new cell if we wanted to, or return a different cell for each row.
            return [[_outlineView tableColumnWithIdentifier:COLUMNID_NAME] dataCell];
        }
    }
    return [tableColumn dataCell];
}

// To get the "group row" look, we implement this method.
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    AAPLSimpleNodeData *nodeData = [item representedObject];
    return nodeData.container > 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
    // Query our model for the answer to this question
    AAPLSimpleNodeData *nodeData = [item representedObject];
    return nodeData.expandable;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    AAPLSimpleNodeData *nodeData = [item representedObject];
    if ((tableColumn == nil) || [[tableColumn identifier] isEqualToString:COLUMNID_NAME]) {
        // Make sure the image and text cell has an image.  If not, lazily fill in a random image
        if (nodeData.image == nil) {
            nodeData.image = [self randomIconImage];
        }
        // We know that the cell at this column is our image and text cell, so grab it
        AAPLImageAndTextCell *imageAndTextCell = (AAPLImageAndTextCell *)cell;
        // Set the image here since the value returned from outlineView:objectValueForTableColumn:... didn't specify the image part...
        imageAndTextCell.myImage = nodeData.image;
    }
//    else if ([[tableColumn identifier] isEqualToString:COLUMNID_IS_EXPANDABLE]) {
//        [cell setEnabled:nodeData.container];
//        // On Mac OS 10.5 and later, in willDisplayCell: we can dynamically set the contextual menu (right click menu) for a particular cell. If nothing is set, then the contextual menu for the NSOutlineView itself will be used. We will set a different menu for the "Expandable?" column, and leave the default one for everything else.
//        [cell setMenu:expandableColumnMenu];
//    }
}

-(NSString*)getNodePath:(NSTreeNode*)node
{
    if (node==nil) {
        return LUABASEPATH;
    }
    if (node ==_rootTreeNode) {
        return LUABASEPATH;
    }
    AAPLSimpleNodeData *nodeData = [node representedObject];
    NSString *str1=nodeData.name;
    NSString *str2=nodeData.name;
    while (node.parentNode)
    {
        node=node.parentNode;
        
        if (node==nil) {
            return str1;
        }else if (node ==_rootTreeNode)
        {
            return [LUABASEPATH stringByAppendingPathComponent:str1];
        }
        else
        {
            nodeData = [node representedObject];
            str2=nodeData.name;
            str1=[str2 stringByAppendingPathComponent:str1];
        }
    }
    return str1;
}
- (BOOL)outlineView:(NSOutlineView *)ov shouldSelectItem:(id)item {
    // Control selection of a particular item.
    NSError *error;
    BOOL result=NO;
        if (m_isChange)
        {
        NSAlert * alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Lua Debug Error"];
        [alert setInformativeText:@"lua file don't save,are you sure leave?"];
        [alert addButtonWithTitle:@"Leave"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Save"];
        NSModalResponse r=[alert runModal];
        if (r==1000) {
            return NO;
        }else if (r==1002)
        {
            [self SaveSelectLuaFile:nil];
        }
        [alert release];
    }
    
    AAPLSimpleNodeData *nodeData = [item representedObject];
    if(nodeData.container)
    {
        return YES;
    }else{
        NSUInteger se=[m_scSelectAtion selectedSegment];
        if (m_SelectFileName) {
            [m_SelectFileName release];
        }
        m_SelectFileName=[[self getNodePath:item] retain];
        [m_luaView setEditable:YES];
        NSString *str=[NSString stringWithContentsOfFile:m_SelectFileName encoding:NSUTF8StringEncoding error:&error];
        NSMutableString *text = [[NSMutableString alloc] initWithString:str];
        NSAttributedString * theString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r",text]];
        [[m_luaView textStorage] setAttributedString: theString];
        [theString release];
        [text release];
        [m_luaView setEditable:NO];
        m_isChange=NO;
        result=YES;
        
        if (se==1)
        {
            [m_luaView setEditable:YES];
            result=YES;
        }
        if (se==0)
        {
            [self RunSelectLuaFile:nil];
            result=YES;
        }
        return YES;
    }
    return result;
}

- (BOOL)outlineView:(NSOutlineView *)ov shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // We want to allow tracking for all the button cells, even if we don't allow selecting that particular row.
    if ([cell isKindOfClass:[NSButtonCell class]]) {
        // We can also take a peek and make sure that the part of the cell clicked is an area that is normally tracked. Otherwise, clicking outside of the checkbox may make it check the checkbox
        NSRect cellFrame = [_outlineView frameOfCellAtColumn:[[_outlineView tableColumns] indexOfObject:tableColumn] row:[_outlineView rowForItem:item]];
        NSUInteger hitTestResult = [cell hitTestForEvent:[NSApp currentEvent] inRect:cellFrame ofView:_outlineView];
        if ((hitTestResult & NSCellHitTrackableArea) != 0) {
            return YES;
        } else {
            return NO;
        }
    } else {
        // Only allow tracking on selected rows. This is what NSTableView does by default.
        return [_outlineView isRowSelected:[_outlineView rowForItem:item]];
    }
}

/* In 10.7 multiple drag images are supported by using this delegate method. */
- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item {
    return (id <NSPasteboardWriting>)[item representedObject];
}

/* Setup a local reorder. */
- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems {
    _draggedNodes = draggedItems;
//    [session.draggingPasteboard setData:[NSData data] forType:LOCAL_REORDER_PASTEBOARD_TYPE];
}

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    // If the session ended in the trash, then delete all the items
    if (operation == NSDragOperationDelete) {
        [_outlineView beginUpdates];
        
        [_draggedNodes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id node, NSUInteger index, BOOL *stop) {
            id parent = [node parentNode];
            NSMutableArray *children = [parent mutableChildNodes];
            NSInteger childIndex = [children indexOfObject:node];
            [children removeObjectAtIndex:childIndex];
            [_outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:childIndex] inParent:parent == _rootTreeNode ? nil : parent withAnimation:NSTableViewAnimationEffectFade];
        }];
        
        [_outlineView endUpdates];
    }
    
    _draggedNodes = nil;
}

- (BOOL)treeNode:(NSTreeNode *)treeNode isDescendantOfNode:(NSTreeNode *)parentNode {
    while (treeNode != nil) {
        if (treeNode == parentNode) {
            return YES;
        }
        treeNode = [treeNode parentNode];
    }
    return NO;
}

- (BOOL)_dragIsLocalReorder:(id <NSDraggingInfo>)info {
    // It is a local drag if the following conditions are met:
    if ([info draggingSource] == _outlineView) {
        // We were the source
        if (_draggedNodes != nil) {
            // Our nodes were saved off
            //if ([[info draggingPasteboard] availableTypeFromArray:@[LOCAL_REORDER_PASTEBOARD_TYPE]] != nil)
            {
                // Our pasteboard marker is on the pasteboard
                return YES;
            }
        }
    }
    return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)childIndex {
    // To make it easier to see exactly what is called, uncomment the following line:
    //    NSLog(@"outlineView:validateDrop:proposedItem:%@ proposedChildIndex:%ld", item, (long)childIndex);
    
    // This method validates whether or not the proposal is a valid one.
    // We start out by assuming that we will do a "generic" drag operation, which means we are accepting the drop. If we return NSDragOperationNone, then we are not accepting the drop.
    NSDragOperation result = NSDragOperationGeneric;
    
    if (false)//([self onlyAcceptDropOnRoot])
    {
        // We are going to accept the drop, but we want to retarget the drop item to be "on" the entire outlineView
        [_outlineView setDropItem:nil dropChildIndex:NSOutlineViewDropOnItemIndex];
    } else {
        // Check to see what we are proposed to be dropping on
        NSTreeNode *targetNode = item;
        // A target of "nil" means we are on the main root tree
        if (targetNode == nil) {
            targetNode = _rootTreeNode;
        }
        AAPLSimpleNodeData *nodeData = [targetNode representedObject];
        if (nodeData.container) {
            // See if we allow dropping "on" or "between"
            if (childIndex == NSOutlineViewDropOnItemIndex) {
                //if (![self allowOnDropOnContainer])
                {
                    // Refuse to drop on a container if we are not allowing that
                    result = NSDragOperationNone;
                }
            } else {
                //if (![self allowBetweenDrop])
                {
                    // Refuse to drop between an item if we are not allowing that
                    result = NSDragOperationNone;
                }
            }
        } else {
            // The target node is not a container, but a leaf. See if we allow dropping on a leaf. If we don't, refuse the drop (we may get called again with a between)
//            if (childIndex == NSOutlineViewDropOnItemIndex && ![self allowOnDropOnLeaf]) {
//                result = NSDragOperationNone;
//            }
        }
        
        // If we are allowing the drop, we see if we are draggng from ourselves and dropping into a descendent, which wouldn't be allowed...
        if (result != NSDragOperationNone) {
            // Indicate that we will animate the drop items to their final location
            info.animatesToDestination = YES;
            if ([self _dragIsLocalReorder:info]) {
                if (targetNode != _rootTreeNode) {
                    for (NSTreeNode *draggedNode in _draggedNodes) {
                        if ([self treeNode:targetNode isDescendantOfNode:draggedNode]) {
                            // Yup, it is, refuse it.
                            result = NSDragOperationNone;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // To see what we decide to return, uncomment this line
    //    NSLog(result == NSDragOperationNone ? @" - Refusing drop" : @" + Accepting drop");
    
    return result;
}

- (void)_performInsertWithDragInfo:(id <NSDraggingInfo>)info parentNode:(NSTreeNode *)parentNode childIndex:(NSInteger)childIndex {
    // NSOutlineView's root is nil
    id outlineParentItem = parentNode == _rootTreeNode ? nil : parentNode;
    NSMutableArray *childNodeArray = [parentNode mutableChildNodes];
    NSInteger outlineColumnIndex = [[_outlineView tableColumns] indexOfObject:[_outlineView outlineTableColumn]];
    
    // Enumerate all items dropped on us and create new model objects for them
    NSArray *classes = @[[AAPLSimpleNodeData class]];
    __block NSInteger insertionIndex = childIndex;
    [info enumerateDraggingItemsWithOptions:0 forView:_outlineView classes:classes searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        AAPLSimpleNodeData *newNodeData = (AAPLSimpleNodeData *)draggingItem.item;
        // Wrap the model object in a tree node
        NSTreeNode *treeNode = [NSTreeNode treeNodeWithRepresentedObject:newNodeData];
        // Add it to the model
        [childNodeArray insertObject:treeNode atIndex:insertionIndex];
        [_outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:insertionIndex] inParent:outlineParentItem withAnimation:NSTableViewAnimationEffectGap];
        // Update the final frame of the dragging item
        NSInteger row = [_outlineView rowForItem:treeNode];
        draggingItem.draggingFrame = [_outlineView frameOfCellAtColumn:outlineColumnIndex row:row];
        
        // Insert all children one after another
        insertionIndex++;
    }];
    
}

- (void)_performDragReorderWithDragInfo:(id <NSDraggingInfo>)info parentNode:(NSTreeNode *)newParent childIndex:(NSInteger)childIndex {
    // We will use the dragged nodes we saved off earlier for the objects we are actually moving
    NSAssert(_draggedNodes != nil, @"_draggedNodes should be valid");
    
    NSMutableArray *childNodeArray = [newParent mutableChildNodes];
    
    // We want to enumerate all things in the pasteboard. To do that, we use a generic NSPasteboardItem class
    NSArray *classes = @[[NSPasteboardItem class]];
    __block NSInteger insertionIndex = childIndex;
    [info enumerateDraggingItemsWithOptions:0 forView:_outlineView classes:classes searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        // We ignore the draggingItem.item -- it is an NSPasteboardItem. We only care about the index. The index is deterministic, and can directly be used to look into the initial array of dragged items.
        NSTreeNode *draggedTreeNode = _draggedNodes[index];
        
        // Remove this node from its old location
        NSTreeNode *oldParent = [draggedTreeNode parentNode];
        NSMutableArray *oldParentChildren = [oldParent mutableChildNodes];
        NSInteger oldIndex = [oldParentChildren indexOfObject:draggedTreeNode];
        [oldParentChildren removeObjectAtIndex:oldIndex];
        // Tell the table it is going away; make it pop out with NSTableViewAnimationEffectNone, as we will animate the draggedItem to the final target location.
        // Don't forget that NSOutlineView uses 'nil' as the root parent.
        [_outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:oldIndex] inParent:oldParent == _rootTreeNode ? nil : oldParent withAnimation:NSTableViewAnimationEffectNone];
        
        // Insert this node into the new location and new parent
        if (oldParent == newParent) {
            // Moving it from within the same parent! Account for the remove, if it is past the oldIndex
            if (insertionIndex > oldIndex) {
                insertionIndex--; // account for the remove
            }
        }
        [childNodeArray insertObject:draggedTreeNode atIndex:insertionIndex];
        
        // Tell NSOutlineView about the insertion; let it leave a gap for the drop animation to come into place
        [_outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:insertionIndex] inParent:newParent == _rootTreeNode ? nil : newParent withAnimation:NSTableViewAnimationEffectGap];
        
        insertionIndex++;
    }];
    
    // Now that the move is all done (according to the table), update the draggingFrames for the all the items we dragged. -frameOfCellAtColumn:row: gives us the final frame for that cell
    NSInteger outlineColumnIndex = [[_outlineView tableColumns] indexOfObject:[_outlineView outlineTableColumn]];
    [info enumerateDraggingItemsWithOptions:0 forView:_outlineView classes:classes searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        NSTreeNode *draggedTreeNode = _draggedNodes[index];
        NSInteger row = [_outlineView rowForItem:draggedTreeNode];
        draggingItem.draggingFrame = [_outlineView frameOfCellAtColumn:outlineColumnIndex row:row];
    }];
    
}

- (BOOL)outlineView:(NSOutlineView *)ov acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)childIndex {
    NSTreeNode *targetNode = item;
    // A target of "nil" means we are on the main root tree
    if (targetNode == nil) {
        targetNode = _rootTreeNode;
    }
    AAPLSimpleNodeData *nodeData = [targetNode representedObject];
    
    // Determine the parent to insert into and the child index to insert at.
    if (!nodeData.container) {
        // If our target is a leaf, and we are dropping on it
        if (childIndex == NSOutlineViewDropOnItemIndex) {
            // If we are dropping on a leaf, we will have to turn it into a container node
            nodeData.container = YES;
            nodeData.expandable = YES;
            childIndex = 0;
        } else {
            // We will be dropping on the item's parent at the target index of this child, plus one
            NSTreeNode *oldTargetNode = targetNode;
            targetNode = [targetNode parentNode];
            childIndex = [[targetNode childNodes] indexOfObject:oldTargetNode] + 1;
        }
    } else {
        if (childIndex == NSOutlineViewDropOnItemIndex) {
            // Insert it at the start, if we were dropping on it
            childIndex = 0;
        }
    }
    
    // Group all insert or move animations together
    [_outlineView beginUpdates];
    // If the source was ourselves, we use our dragged nodes and do a reorder
    if ([self _dragIsLocalReorder:info]) {
        [self _performDragReorderWithDragInfo:info parentNode:targetNode childIndex:childIndex];
    } else {
        [self _performInsertWithDragInfo:info parentNode:targetNode childIndex:childIndex];
    }
    [_outlineView endUpdates];
    
    // Return YES to indicate we were successful with the drop. Otherwise, it would slide back the drag image.
    return YES;
}

/* Multi-item dragging destiation support.
 */
- (void)outlineView:(NSOutlineView *)outlineView updateDraggingItemsForDrag:(id <NSDraggingInfo>)draggingInfo {
    // If the source is ourselves, then don't do anything. If it isn't, we update things
    if (![self _dragIsLocalReorder:draggingInfo]) {
        // We will be doing an insertion; update the dragging items to have an appropriate image
        NSArray *classes = @[[AAPLSimpleNodeData class]];
        
        // Create a copied temporary cell to draw to images
        NSTableColumn *tableColumn = [_outlineView outlineTableColumn];
        AAPLImageAndTextCell *tempCell = [[tableColumn dataCell] copy];
        
        // Calculate a base frame for new cells
        NSRect cellFrame = NSMakeRect(0, 0, [tableColumn width], [outlineView rowHeight]);
        
        // Subtract out the intercellSpacing from the width only. The rowHeight is sans-spacing
        cellFrame.size.width -= [outlineView intercellSpacing].width;
        
        [draggingInfo enumerateDraggingItemsWithOptions:0 forView:_outlineView classes:classes searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
            AAPLSimpleNodeData *newNodeData = (AAPLSimpleNodeData *)draggingItem.item;
            // Wrap the model object in a tree node
            NSTreeNode *treeNode = [NSTreeNode treeNodeWithRepresentedObject:newNodeData];
            draggingItem.draggingFrame = cellFrame;
            
            draggingItem.imageComponentsProvider = ^(void) {
                // Setup the cell with this temporary data
                id objectValue = [self outlineView:outlineView objectValueForTableColumn:tableColumn byItem:treeNode];
                [tempCell setObjectValue:objectValue];
                [self outlineView:outlineView willDisplayCell:tempCell forTableColumn:tableColumn item:treeNode];
                // Ask the table for the image components from that cell
                return (NSArray *)[tempCell draggingImageComponentsWithFrame:cellFrame inView:outlineView];
            };
        }];
    }
}


#pragma mark -

/* On Mac OS 10.5 and above, NSTableView and NSOutlineView have better contextual menu support. We now see a highlighted item for what was clicked on, and can access that item to do particular things (such as dynamically change the menu, as we do here!). Each of the contextual menus in the nib file have the delegate set to be the AppController instance. In menuNeedsUpdate, we dynamically update the menus based on the currently clicked upon row/column pair.
 */
- (void)menuNeedsUpdate:(NSMenu *)menu {
    NSInteger clickedRow = [_outlineView clickedRow];
    id item = nil;
    AAPLSimpleNodeData *nodeData = nil;
    BOOL clickedOnMultipleItems = NO;
    
    if (clickedRow != -1) {
        // If we clicked on a selected row, then we want to consider all rows in the selection. Otherwise, we only consider the clicked on row.
        item = [_outlineView itemAtRow:clickedRow];
        nodeData = [item representedObject];
        clickedOnMultipleItems = [_outlineView isRowSelected:clickedRow] && ([_outlineView numberOfSelectedRows] > 1);
    }
    
//    if (menu == outlineViewContextMenu) {
//        NSMenuItem *menuItem = [menu itemAtIndex:0];
//        if (nodeData != nil) {
//            if (clickedOnMultipleItems) {
//                // We could walk through the selection and note what was clicked on at this point
//                [menuItem setTitle:[NSString stringWithFormat:@"You clicked on %ld items!", (long)[_outlineView numberOfSelectedRows]]];
//            } else {
//                [menuItem setTitle:[NSString stringWithFormat:@"You clicked on: '%@'", nodeData.name]];
//            }
//            [menuItem setEnabled:YES];
//        } else {
//            [menuItem setTitle:@"You didn't click on any rows..."];
//            [menuItem setEnabled:NO];
//        }
//        [deleteSelectedItemsMenuItem setEnabled:[_outlineView selectedRow] != -1];
//    } else if (menu == expandableColumnMenu) {
//        NSMenuItem *menuItem = [menu itemAtIndex:0];
//        if (!clickedOnMultipleItems && (nodeData != nil)) {
//            // The item will be enabled only if it is a group
//            [menuItem setEnabled:nodeData.container];
//            // Check it if it is expandable
//            [menuItem setState:nodeData.expandable ? 1 : 0];
//        } else {
//            [menuItem setEnabled:NO];
//        }
//    }
}

- (IBAction)expandableMenuItemAction:(id)sender {
    // The tag of the clicked row contains the item that was clicked on
    NSInteger clickedRow = [_outlineView clickedRow];
    NSTreeNode *treeNode = [_outlineView itemAtRow:clickedRow];
    AAPLSimpleNodeData *nodeData = [treeNode representedObject];
    // Flip the expandable state,
    nodeData.expandable = !nodeData.expandable;
    // Refresh that row (since its state has changed)
    [_outlineView setNeedsDisplayInRect:[_outlineView rectOfRow:clickedRow]];
    // And collopse it if we can no longer expand it
    if (!nodeData.expandable && [_outlineView isItemExpanded:treeNode]) {
        [_outlineView collapseItem:treeNode];
    }
}

- (IBAction)useGroupGrowLook:(id)sender {
    // We simply need to redraw things.
    [_outlineView setNeedsDisplay:YES];
}
-(NSTreeNode*)getSelectionDirectoryNode
{
    NSTreeNode *selectedNode;
    // We are inserting as a child of the last selected node. If there are none selected, insert it as a child of the treeData itself
    if ([_outlineView selectedRow] != -1) {
        selectedNode = [_outlineView itemAtRow:[_outlineView selectedRow]];
        AAPLSimpleNodeData *data = [selectedNode representedObject];
        if (data) {
            if (!data.container) {
                selectedNode=[selectedNode parentNode];
            }
        }
    } else {
        selectedNode = _rootTreeNode;
    }
    return selectedNode;
}
-(NSTreeNode*)getSelectionNode
{
    NSTreeNode *selectedNode;
    // We are inserting as a child of the last selected node. If there are none selected, insert it as a child of the treeData itself
    if ([_outlineView selectedRow] != -1) {
        selectedNode = [_outlineView itemAtRow:[_outlineView selectedRow]];
    } else {
        selectedNode = _rootTreeNode;
    }
    return selectedNode;
}
- (void)addNewDataToSelection:(AAPLSimpleNodeData *)newChildData {
    NSTreeNode *selectedNode;
    // We are inserting as a child of the last selected node. If there are none selected, insert it as a child of the treeData itself
    if ([_outlineView selectedRow] != -1) {
        selectedNode = [_outlineView itemAtRow:[_outlineView selectedRow]];
    } else {
        selectedNode = _rootTreeNode;
    }
    
    // If the selected node is a container, use its parent. We access the underlying model object to find this out.
    // In addition, keep track of where we want the child.
    NSInteger childIndex;
    NSTreeNode *parentNode;
    
    AAPLSimpleNodeData *nodeData = [selectedNode representedObject];
    if (nodeData.container) {
        // Since it was already a container, we insert it as the first child
        childIndex = 0;
        parentNode = selectedNode;
    } else {
        // The selected node is not a container, so we use its parent, and insert after the selected node
        parentNode = [selectedNode parentNode];
        childIndex = [[parentNode childNodes] indexOfObject:selectedNode ] + 1; // + 1 means to insert after it.
    }
    
    // Use the new 10.7 API to update the tree directly in an animated fashion
    [_outlineView beginUpdates];
    
    // Now, create a tree node for the data and insert it as a child and tell the outlineview about our new insertion
    NSTreeNode *childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:newChildData];
    [[parentNode mutableChildNodes] insertObject:childTreeNode atIndex:childIndex];
    // NSOutlineView uses 'nil' as the root parent
    if (parentNode == _rootTreeNode) {
        parentNode = nil;
    }
    [_outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:childIndex] inParent:parentNode withAnimation:NSTableViewAnimationEffectFade];
    
    [_outlineView endUpdates];
    
    NSInteger newRow = [_outlineView rowForItem:childTreeNode];
    if (newRow >= 0) {
        [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:NO];
        NSInteger column = 0;
        // With "full width" cells, there is no column
        if (newChildData.container ) {
            column = -1;
        }
        [_outlineView editColumn:column row:newRow withEvent:nil select:YES];
    }
}

- (NSImage *)randomIconImage {
    return nil;
}
-(void)treeNodeFrom:(NSString*)Path ParentNode:(NSTreeNode*)parentnode
{
    NSTreeNode *childTreeNode;
    NSString *FilePath;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir, valid = [manager fileExistsAtPath:Path isDirectory:&isDir];
    if(!isDir)
    {
        NSLog(@"%@",Path);
        return;
    }else
    {
        
    }
    NSString *home = [Path stringByExpandingTildeInPath];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:home];
    NSString *filename;
    while (filename = [direnum nextObject])
    {
        NSArray *att=[filename pathComponents];
        if ( [att count]>1) {
            continue;
        }
        FilePath=[Path stringByAppendingPathComponent:filename];
        valid = [manager fileExistsAtPath:FilePath isDirectory:&isDir];
        if(isDir)
        {
            AAPLSimpleNodeData *childNodeData = [[AAPLSimpleNodeData alloc] initWithName:filename];
            childNodeData.container = YES;
            childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:childNodeData];
            [[parentnode mutableChildNodes] addObject:childTreeNode];
            [self treeNodeFrom:FilePath ParentNode:childTreeNode];

        }else
        {
            if([[filename pathExtension] isEqualToString:@"lua"])
            {
                AAPLSimpleNodeData *childNodeData = [[AAPLSimpleNodeData alloc] initWithName:filename];
                childNodeData.container = NO;
                childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:childNodeData];
                [[parentnode mutableChildNodes] addObject:childTreeNode];
            }
        }
        // fullfilename=[NSString stringWithFormat:@"%@/%@",Path,filename ];
       // [self pintfiles:filename];
    }
}


@end
