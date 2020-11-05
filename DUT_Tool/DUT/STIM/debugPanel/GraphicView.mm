
#import "GraphicView.h"
#import "GraphicHeader.h"
#import "SKTGraphic.h"
#import "SKTGrid.h"
#import "SKTImage.h"
#import "SKTRenderingView.h"
#import "SKTToolPaletteController.h"
#import "SKTText.h"
#import "SKTTextFile.h"
#import "SKTButton.h"
#import "SKTSwitch.h"
#import "SKTSwitch1.h"
#import "SKTSwitch2.h"
#import "SKTSwitch4.h"


@interface GraphicView(SKTForwardDeclarations)
- (NSArray *)graphics;
- (void)stopEditing;
- (void)stopObservingGraphics:(NSArray *)graphics;

@end

@implementation GraphicView

// An override of the superclass' designated initializer.
- (id)initWithFrame:(NSRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        _graphicsContainer=nil;
        SKTDocumentGraphicsKey = @"graphics";
        _groupSelectable = NO;
        
    }
    return self;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onGroupSwitch:) name:@"buttongroupswitch" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hightLightRect:) name:@"buttonGroupHighlight" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedButtonColor:) name:@"selectedButtonColor" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearButtonSelect:) name:@"clearButtonSelectColor" object:nil];
}

- (void)dealloc {
    if (_graphicsContainer) {
        [_graphicsContainer release];
    }
    [self stopEditing];
    [super dealloc];
}

-(void)setGroupSelectable:(BOOL)groupSelectable{
    _groupSelectable = groupSelectable;
}
-(BOOL)GroupSelectable
{
    return _groupSelectable;
    
}

-(void)clearButtonSelect:(NSNotification*)nf
{
    [self setGroupSelectable:NO];
    NSDictionary *dic = [nf userInfo];
    NSArray *arr_selectedButton = [dic objectForKey:@"button"];
    for(int i=0;i<[arr_selectedButton count];i++)
    {
        int idf = (int)[[arr_selectedButton objectAtIndex:i] integerValue];
        SKTGraphic *mgraphic = nil;
        for(SKTGraphic *graphic in [self graphics])
        {
            if (([graphic identifier] == idf) && ([self isSwitchGraphic:graphic]))
            {
                mgraphic = graphic;
                if ([mgraphic isKindOfClass:[SKTButton class]]) {
                    
                    [self setNeedsDisplayInRect:[mgraphic drawingBounds]];
                }
                [mgraphic setValue:[NSColor whiteColor] forKey:@"_fillColor"];
                [self setNeedsDisplayInRect:[mgraphic drawingBounds]];
                
            }
        }
        
    }


}

-(void)selectedButtonColor:(NSNotification*)nf
{
    [self setGroupSelectable:YES];
//    NSDictionary *dic = [nf userInfo];
//    NSArray *arr_selectedButton = [dic objectForKey:@"button"];
//    for(int i=0;i<[arr_selectedButton count];i++)
//    {
//        int idf = (int)[[arr_selectedButton objectAtIndex:i] integerValue];
//        SKTGraphic *mgraphic = nil;
//        for(SKTGraphic *graphic in [self graphics])
//        {
//            if (([graphic identifier] == idf) && ([self isSwitchGraphic:graphic]))
//            {
//                mgraphic = graphic;
//                if ([mgraphic isKindOfClass:[SKTButton class]]) {
//                    
//                    [self setNeedsDisplayInRect:[mgraphic drawingBounds]];
//                }
//                [mgraphic setValue:[NSColor yellowColor] forKey:@"_fillColor"];
//                [self setNeedsDisplayInRect:[mgraphic drawingBounds]];
//                
//            }
//        }
//        
//    }
}
/////

-(void)onGroupSwitch:(NSNotification*)nf
{
    NSDictionary *dic = [nf userInfo];
    NSArray *arrbtn = [dic objectForKey:@"button"];
    NSInteger state = [[dic objectForKey:@"state"] integerValue];
    for(int i=0;i<[arrbtn count];i++)
    {
        int idf = (int)[[arrbtn objectAtIndex:i] integerValue];
        SKTGraphic *graphic = (SKTGraphic*)[self getSktGraphicByID:idf];
        if (graphic){
            NSDictionary *dic_userInfor = [NSDictionary dictionaryWithObjectsAndKeys:@(state),GraphicStateNotification,@(idf),GraphicIdentifierNotification,[graphic prefix],GraphicPrefixNotification,[self GetTextFileContent:graphic],GraphicButtonBlindTextFileNotification,nil];
            if ([graphic isKindOfClass:[SKTButton class]]) {
                [self setNeedsDisplayInRect:[graphic drawingBounds]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:GraphicCilckNotification object:nil userInfo:dic_userInfor];
        }
    }
}

-(BOOL)isSwitchGraphic:(SKTGraphic*)gh
{
    if ([gh isKindOfClass:[SKTSwitch class]])
         return YES;
    if ([gh isKindOfClass:[SKTSwitch1 class]])
        return YES;
    if ([gh isKindOfClass:[SKTSwitch2 class]])
        return YES;
    if ([gh isKindOfClass:[SKTSwitch4 class]])
        return YES;
    return NO;
}

-(SKTGraphic *)getSktGraphicByID:(int)identifier
{
    for(SKTGraphic *graphic in [self graphics])
    {
        if (([graphic identifier] == identifier) && ([self isSwitchGraphic:graphic]))
        {
            return graphic;
        }
    }
    return nil;
}

#pragma mark *** Bindings ***


- (NSArray *)graphics {
    return [_graphicsContainer graphics];
    
}
- (NSImage *)backgrounpimage {
    return [_graphicsContainer backgrounpimage];
}
- (NSSize)canvasSize
{
    NSSize canvasSize = [self.printInfo paperSize];
    canvasSize.width -= ([self.printInfo leftMargin] + [self.printInfo rightMargin]);
    canvasSize.height -= ([self.printInfo topMargin] + [self.printInfo bottomMargin]);
    return canvasSize;
    
}
-(void)bin:(NSObject *)graphicsContainer
{
    _graphicsContainer=[graphicsContainer retain];
    [self setNeedsDisplay:YES];
}
#pragma mark *** Drawing ***

// An override of the NSView method.
- (void)drawRect:(NSRect)rect {
    NSImage *image=[self backgrounpimage];
    
    if (image) {
        //if (_bounds.size.width==rect.size.width)
        {
            [image drawInRect:_bounds];
        }
//        else
//        {
//            [[NSColor whiteColor] set];
//            NSRectFill(rect);
//        }
    }else
    {
        [[NSColor whiteColor] set];
        NSRectFill(rect);
    }
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    NSArray *graphics = [self graphics];
    NSInteger graphicCount = [graphics count];
    for (NSInteger index = graphicCount - 1; index>=0; index--)
    {
        SKTGraphic *graphic = [graphics objectAtIndex:index];
        NSRect graphicDrawingBounds = [graphic drawingBounds];
        if (NSIntersectsRect(rect, graphicDrawingBounds))
        {
            [currentContext saveGraphicsState];
            [NSBezierPath clipRect:NSMakeRect(graphicDrawingBounds.origin.x, graphicDrawingBounds.origin.y-graphicDrawingBounds.size.height*0.25, graphicDrawingBounds.size.width, graphicDrawingBounds.size.height*1.25)];
            [graphic drawContentsInView:self isBeingCreateOrEdited:NO];
            [currentContext restoreGraphicsState];

        }
    }
}

- (void)setFrame:(NSRect)newrect
{
    [super setFrame:newrect];
}
// An override of the NSView method.
- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}
-(SKTGraphic *)getGraphicInPoint:(NSPoint)point
{
    NSArray *graphics = [self graphics];
    for (SKTGraphic *graphic in graphics)
    {
        if (NSPointInRect(point, [graphic drawingBounds]))
        {
            return graphic;
        }
    }
    return nil;
}
- (void)mouseMoved:(NSEvent *)event
{
    // NSLog(@"mouseMoved in,%d\n",__LINE__);
    NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    if ([self getGraphicInPoint:mouseLocation]) {
//         NSLog(@"mouseMoved in,%d",__LINE__);
        NSCursor *cursor = [NSCursor pointingHandCursor];
        [cursor set];
    }else
    {
//        NSLog(@"mouseMoved out,%d",__LINE__);
        NSCursor *cursor = [NSCursor arrowCursor];
        [cursor set];
    }
}
- (void)mouseDown:(NSEvent *)event
{
    NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    SKTGraphic *graphic=[self getGraphicInPoint:mouseLocation];
    if (graphic) {
        NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedLong:[graphic state]],GraphicStateNotification,
                              [NSNumber numberWithUnsignedLong:[graphic identifier]],GraphicIdentifierNotification,
                              [graphic prefix],GraphicPrefixNotification,
                              [self GetTextFileContent:graphic],GraphicButtonBlindTextFileNotification,
                              nil];
        
        if ([event clickCount]>1 && [graphic isKindOfClass:[SKTTextFile class]]) {
            [self startEditingGraphic:graphic];
        }
        if ([graphic isKindOfClass:[SKTButton class]]) {
            [self setNeedsDisplayInRect:[graphic drawingBounds]];
        }
        //NSLog(@"%@",self.identifier);
        // if _groupSelectable == YES, add button to group ,or change the button state
        
        if (_groupSelectable == YES) {
            [notifCenter postNotificationName:@"addButtonToGroup" object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:graphic,@"button", nil]];
            [self setSelectedButtonColor:graphic];

        }else{
            [notifCenter postNotificationName:GraphicCilckNotification object:graphic userInfo:dic];
            
        }
    }
}
////////
-(void)setSelectedButtonColor:(SKTGraphic*) mgraphic
{
    NSUInteger idf = [mgraphic identifier];
    for(SKTGraphic *graphic in [self graphics])
    {
        if (([graphic identifier] == idf) && ([self isSwitchGraphic:graphic]))
        {
           
            if ([graphic isKindOfClass:[SKTButton class]]) {
                
                [self setNeedsDisplayInRect:[graphic drawingBounds]];
            }
            [graphic setValue:[NSColor yellowColor] forKey:@"_fillColor"];
            [self setNeedsDisplayInRect:[graphic drawingBounds]];
            
        }
    }
}

- (void)rightMouseDown:(NSEvent *)event
{
    NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    SKTGraphic *graphic=[self getGraphicInPoint:mouseLocation];
    if(graphic == nil)
        return;
    if([self isSwitchGraphic:graphic])
    {
        NSNotificationCenter* notiCenter = [NSNotificationCenter defaultCenter];
        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                              self,@"view",
                              graphic,@"button",nil];
        [notiCenter postNotificationName:@"rightclickonbutton" object:nil userInfo:dic];
    }
}

-(NSString*)GetTextFileContent:(SKTGraphic*)graphic
{
    NSString *str = [NSString stringWithFormat:@"N/A"];
    NSArray *graphics = [self graphics];
    if ([graphic isKindOfClass:[SKTButton class]]) {
        for (SKTGraphic *allgraphic in graphics)
        {
            if ([allgraphic isKindOfClass:[SKTTextFile class]]) {
                if ([graphic identifier] == [allgraphic identifier]) {
                    str = [allgraphic GetTextFileString];
                    return str;
                }
            }
        }
    }
    return  str;
}

- (void)startEditingGraphic:(SKTGraphic *)graphic {
    
    SKTGraphic *_editingGraphic;


    // It's the responsibility of invokers to not invoke this method when editing has already been started.

    // Can the graphic even provide an editing view?
    _editingView = [[graphic newEditingViewWithSuperviewBounds:[self bounds]] retain];
    if (_editingView) {
        
        // Keep a pointer to the graphic around so we can ask it to draw its "being edited" look, and eventually send it a -finalizeEditingView: message.
        _editingGraphic = [graphic retain];
        
        // If the editing view adds a ruler accessory view we're going to remove it when editing is done, so we have to remember the old reserved accessory view thickness so we can restore it. Otherwise there will be a big blank space in the ruler.
        _oldReservedThicknessForRulerAccessoryView = [[[self enclosingScrollView] horizontalRulerView] reservedThicknessForAccessoryView];
        
        // Make the editing view a subview of this one. It was the graphic's job to make sure that it was created with the right frame and bounds.
        [self addSubview:_editingView];
        
        // Make the editing view the first responder so it takes key events and relevant menu item commands.
        [[self window] makeFirstResponder:_editingView];
        
        // Get notified if the editing view's frame gets smaller, because we may have to force redrawing when that happens. Record the view's frame because it won't be available when we get the notification.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplayForEditingViewFrameChangeNotification:) name:NSViewFrameDidChangeNotification object:_editingView];
        _editingViewFrame = [_editingView frame];
        [_editingView release];
        _editingView = nil;
        // Give the graphic being edited a chance to draw one more time. In Sketch, SKTText draws a focus ring.
        [self setNeedsDisplayInRect:[_editingGraphic drawingBounds]];
        
    }
}

- (void)stopEditing{
    
    // Make it harmless to invoke this method unnecessarily.
    if (_editingView) {
        [_editingView release];
        _editingView = nil;
    }
    
}

- (void)setNeedsDisplayForEditingViewFrameChangeNotification:(NSNotification *)viewFrameDidChangeNotification {
    
    // If the editing view got smaller we have to redraw where it was or cruft will be left on the screen. If the editing view got larger we might be doing some redundant invalidation (not a big deal), but we're not doing any redundant drawing (which might be a big deal). If the editing view actually moved then we might be doing substantial redundant drawing, but so far that wouldn't happen in Sketch.
    // In Sketch this prevents cruft being left on the screen when the user 1) creates a great big text area and fills it up with text, 2) sizes the text area so not all of the text fits, 3) starts editing the text area but doesn't actually change it, so the text area hasn't been automatically resized and the text editing view is actually bigger than the text area, and 4) deletes so much text in one motion (Select All, then Cut) that the text editing view suddenly becomes smaller than the text area. In every other text editing situation the text editing view's invalidation or the fact that the SKTText's "drawingBounds" changes is enough to cause the proper redrawing.
    NSRect newEditingViewFrame = [[viewFrameDidChangeNotification object] frame];
    [self setNeedsDisplayInRect:NSUnionRect(_editingViewFrame, newEditingViewFrame)];
    _editingViewFrame = newEditingViewFrame;
    
}


// An override of the NSResponder method.
- (BOOL)acceptsFirstResponder {

    // This view can of course handle lots of action messages.
    return YES;

}


// An override of the NSView method.
- (BOOL)isFlipped {

    // Put (0, 0) at the top-left of the view.
    return YES;

}


// An override of the NSView method.
- (BOOL)isOpaque {

    // Our override of -drawRect: always draws a background.
    return YES;

}

@end
