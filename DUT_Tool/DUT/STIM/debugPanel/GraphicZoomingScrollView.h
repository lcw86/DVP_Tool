//
//  GraphicZoomingScrollView.h
//  GraphicZoomingScrollView
//

//

#import <Cocoa/Cocoa.h>

extern NSString *GraphicZoomingScrollViewFactor;

@interface GraphicZoomingScrollView : NSScrollView {
    @private
    NSPopUpButton *_factorPopUpButton;
    CGFloat _factor;
}
@end
