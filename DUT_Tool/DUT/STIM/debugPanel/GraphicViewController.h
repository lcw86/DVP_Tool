//
//  GraphicViewController.h
//  documentViewTest
//


//

#import <Cocoa/Cocoa.h>
#import "GraphicView.h"
#import "SKTZoomingScrollView.h"

@interface GraphicViewController : NSViewController
{
    
    IBOutlet SKTZoomingScrollView *_zoomingScrollView;
    IBOutlet GraphicView *graphicview;
    NSArray *m_graphics;
    NSImage *m_backgrounpimage;
    CGFloat _zoomFactor;

}
- (NSArray *)graphics;
- (NSImage *)backgrounpimage;
@property (copy) NSString* path;
+ (GraphicViewController *)newGraphicView:(NSString*)path;
@end
