

#import "EnterKey.h"

#define EnterKeyMinHandle 9
NSString *EnterKeypoint = @"EnterKeypoint";
@implementation EnterKey

- (instancetype)init
{
    self = [super init];
    if (self) {
        midPoint=NSZeroPoint;
    }
    return self;
}
- (void)setBounds:(NSRect)bounds
{
    CGFloat Ratewidth=0.5;
    CGFloat Rateheight=0.5;
    
    if (NSEqualPoints(midPoint,NSZeroPoint))
    {
        midPoint.x=bounds.origin.x+bounds.size.width/2;
        midPoint.y=bounds.origin.y+bounds.size.height/2;
    }else{
        if ([self bounds].origin.x<midPoint.x && [self bounds].size.width>0) {
            Ratewidth=(midPoint.x-[self bounds].origin.x)/[self bounds].size.width;
        }
        if ([self bounds].origin.y<midPoint.y && [self bounds].size.height>0) {
            Rateheight=(midPoint.y-[self bounds].origin.y)/[self bounds].size.height;
        }
        midPoint.x=bounds.origin.x+bounds.size.width*Ratewidth;
        midPoint.y=bounds.origin.y+bounds.size.height*Rateheight;
    }
    [super setBounds:bounds];
}
- (void)drawHandlesInView:(NSView *)view {
    
    // Draw handles at the corners and on the sides.
    [super drawHandlesInView:view];
    [self drawHandleInView:view atPoint:midPoint];
}
- (id)initWithProperties:(NSDictionary *)properties
{
    id Self=[super initWithProperties:properties];
    NSString *boundsString = [properties objectForKey:EnterKeypoint];
    if ([boundsString isKindOfClass:[NSString class]]) {
        midPoint = NSPointFromString(boundsString);
    }else
    {
        midPoint.x=[self bounds].origin.x+[self bounds].size.width/2;
        midPoint.y=[self bounds].origin.y+[self bounds].size.height/2;
    }
    return Self;
}
- (NSInteger)handleUnderPoint:(NSPoint)point {
    
    // Check handles at the corners and on the sides.
    NSInteger handle = SKTGraphicNoHandle;
    handle=[super handleUnderPoint:point];
    if (handle == SKTGraphicNoHandle) {
        if ([self isHandleAtPoint:midPoint underPoint:point]) {
            handle = EnterKeyMinHandle;
        }
    }
    return handle;
    
}
- (NSInteger)resizeByMovingHandle:(NSInteger)handle toPoint:(NSPoint)point
{
    if (handle==EnterKeyMinHandle) {
        if (NSPointInRect(point, [self bounds])) {
            midPoint=point;
            [self setNeedDisplay:YES];
        }
        return handle;
    }else
    {
        return [super resizeByMovingHandle:handle toPoint:point];
    }
}

- (NSBezierPath *)bezierPathForDrawing {

    // Simple.
    CGFloat radius =5;
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSRect rect=[self bounds];
    [path moveToPoint:NSMakePoint(rect.origin.x+radius,rect.origin.y)];
    
    [path appendBezierPathWithArcFromPoint:NSMakePoint(rect.origin.x+rect.size.width, rect.origin.y)
                                   toPoint:NSMakePoint(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height)
                                    radius:radius];
    
    [path appendBezierPathWithArcFromPoint:NSMakePoint(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height)
                                   toPoint:NSMakePoint(midPoint.x, rect.origin.y+rect.size.height)
                                    radius:radius];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(midPoint.x, rect.origin.y+rect.size.height)
                                   toPoint:midPoint
                                    radius:radius];
    [path appendBezierPathWithArcFromPoint:midPoint
                                   toPoint:NSMakePoint(rect.origin.x,midPoint.y)
                                    radius:radius];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(rect.origin.x,midPoint.y)
                                   toPoint:rect.origin
                                    radius:radius];
    [path appendBezierPathWithArcFromPoint:rect.origin
                                   toPoint:NSMakePoint(rect.origin.x+rect.size.width, rect.origin.y)
                                    radius:radius];
    [path closePath];
    [path setLineWidth:[self strokeWidth]];
    [path stroke];
    return path;

}


@end
