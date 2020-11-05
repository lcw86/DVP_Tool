//
//  GraphicZoomingScrollView.m
//  GraphicZoomingScrollView
//

//

#import "GraphicZoomingScrollView.h"


// The name of the binding supported by this class, in addition to the ones whose support is inherited from NSView.
NSString *GraphicZoomingScrollViewFactor = @"factor";

// Default labels and values for the menu items that will be in the popup button that we build.
static NSString * const GraphicZoomingScrollViewLabels[] = {@"10%", @"25%", @"50%", @"75%", @"100%", @"125%", @"150%", @"200%", @"400%", @"800%", @"1600%"};
static const CGFloat GraphicZoomingScrollViewFactors[] = {0.1f, 0.25f, 0.5f, 0.75f, 1.0f, 1.25f, 1.5f, 2.0f, 4.0f, 8.0f, 16.0f};
static const NSInteger GraphicZoomingScrollViewPopUpButtonItemCount = sizeof(GraphicZoomingScrollViewLabels) / sizeof(NSString *);


@implementation GraphicZoomingScrollView


- (void)validateFactorPopUpButton {
    if (!_factorPopUpButton) {

	// Create the popup button and configure its appearance. The initial size doesn't matter.
        _factorPopUpButton = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
	NSPopUpButtonCell *factorPopUpButtonCell = [_factorPopUpButton cell];
        [factorPopUpButtonCell setArrowPosition:NSPopUpArrowAtBottom];
        [factorPopUpButtonCell setBezelStyle:NSShadowlessSquareBezelStyle];
        [_factorPopUpButton setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];

        // Populate it and size it to fit the just-added menu item cells.
        for (NSInteger index = 0; index<GraphicZoomingScrollViewPopUpButtonItemCount; index++) {
            [_factorPopUpButton addItemWithTitle:NSLocalizedStringFromTable(GraphicZoomingScrollViewLabels[index], @"GraphicZoomingScrollView", nil)];
            [[_factorPopUpButton itemAtIndex:index] setRepresentedObject:[NSNumber numberWithDouble:GraphicZoomingScrollViewFactors[index]]];
        }
        [_factorPopUpButton sizeToFit];
        [self addSubview:_factorPopUpButton];
	[_factorPopUpButton release];

    }

}


#pragma mark *** Bindings ***


- (void)setFactor:(CGFloat)factor {

    //The default implementation of key-value binding is informing this object that the value to which our "factor" property is bound has changed. Record the value, and apply the zoom factor by fooling with the bounds of the clip view that every scroll view has. (We leave its frame alone.)
    _factor = factor;
    NSView *clipView = [[self documentView] superview];
    NSSize clipViewFrameSize = [clipView frame].size;
    [clipView setBoundsSize:NSMakeSize((clipViewFrameSize.width / factor), (clipViewFrameSize.height / factor))];
    
}


// An override of the NSObject(NSKeyValueBindingCreation) method.
- (void)bind:(NSString *)bindingName toObject:(id)observableObject withKeyPath:(NSString *)observableKeyPath options:(NSDictionary *)options {
    
    // For the one binding that this class recognizes, automatically bind the zoom factor popup button's value to the same object...
    if ([bindingName isEqualToString:GraphicZoomingScrollViewFactor]) {
	[self validateFactorPopUpButton];
	[_factorPopUpButton bind:NSSelectedObjectBinding toObject:observableObject withKeyPath:observableKeyPath options:options];
    }

    // ...but still use NSObject's default implementation, which will send _this_ object -setFactor: messages (via key-value coding) whenever the bound-to value changes, for whatever reason, including the user changing it with the zoom factor popup button. Also, NSView supports a few simple bindings of its own, and there's no reason to get in the way of those.
    [super bind:bindingName toObject:observableObject withKeyPath:observableKeyPath options:options];
    
}


// An override of the NSObject(NSKeyValueBindingCreation) method.
- (void)unbind:(NSString *)bindingName {
    
    // Undo what we did in our override of -bind:toObject:withKeyPath:options:.
    [super unbind:bindingName];
    if ([bindingName isEqualToString:GraphicZoomingScrollViewFactor]) {
	[_factorPopUpButton unbind:NSSelectedObjectBinding];
    }

}


#pragma mark *** View Customization ***


// An override of the NSScrollView method.
- (void)tile {

    // This class lives to put a popup button next to a horizontal scroll bar.
    NSAssert([self hasHorizontalScroller], @"GraphicZoomingScrollView doesn't support use without a horizontal scroll bar.");

    // Do NSScrollView's regular tiling, and find out where it left the horizontal scroller.
    [super tile];
    NSScroller *horizontalScroller = [self horizontalScroller];
    NSRect horizontalScrollerFrame = [horizontalScroller frame];

    // Place the zoom factor popup button to the left of where the horizontal scroller will go, creating it first if necessary, and leaving its width alone.
    [self validateFactorPopUpButton];
    NSRect factorPopUpButtonFrame = [_factorPopUpButton frame];
    factorPopUpButtonFrame.origin.x = horizontalScrollerFrame.origin.x;
    factorPopUpButtonFrame.origin.y = horizontalScrollerFrame.origin.y;
    factorPopUpButtonFrame.size.height = horizontalScrollerFrame.size.height;
    [_factorPopUpButton setFrame:factorPopUpButtonFrame];

    // Adjust the scroller's frame to make room for the zoom factor popup button next to it.
    horizontalScrollerFrame.origin.x += factorPopUpButtonFrame.size.width;
    horizontalScrollerFrame.size.width -= factorPopUpButtonFrame.size.width;
    [horizontalScroller setFrame:horizontalScrollerFrame];
    
}


@end
