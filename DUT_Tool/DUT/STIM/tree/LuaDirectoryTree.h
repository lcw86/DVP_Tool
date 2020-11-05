//
//  LuaDirectoryTree.h
//  LuaDebugPanel
//

//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface LuaDirectoryTree : NSObject
{
    
    NSString *m_SelectFileName;
    IBOutlet NSTextView *m_luaView;
    IBOutlet NSSegmentedControl *m_scSelectAtion;
//    IBOutlet NSTextView *m_luaView;
    BOOL m_isChange;
    
    NSTreeNode *_rootTreeNode;
    NSArray *_draggedNodes;
    IBOutlet NSOutlineView *_outlineView;
    IBOutlet NSComboBox *m_cbSocket;
    
}
@end
