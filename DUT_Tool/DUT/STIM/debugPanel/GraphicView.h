
#import <Cocoa/Cocoa.h>

@class SKTGraphic, SKTGrid;

@interface GraphicView : NSView {
    @private
    NSString *SKTDocumentGraphicsKey;// = @"graphics";
//    void *m_graphics;
//    NSImage *m_backgrounpimage;
    NSView *_editingView;
    NSRect _editingViewFrame;
    CGFloat _oldReservedThicknessForRulerAccessoryView;

}

@property (retain) NSObject *graphicsContainer;
@property (copy) NSPrintInfo *printInfo;
-(void)bin:(NSObject *)graphicsContainer;
- (NSSize)canvasSize;
@property(nonatomic) BOOL groupSelectable;
@end

/*
 <codex>
 <abstract></abstract>
 </codex>
 */

