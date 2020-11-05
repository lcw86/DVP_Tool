

#import "SKTSwitch4.h"


@implementation SKTSwitch4
-(instancetype)init
{
    self=[super init];
    if (self) {
        [super setAngle:1];
    }
    return self;
}

- (BOOL)isDrawingFill {
    
    // You can't fill a line.
    return YES;
    
}


- (BOOL)isDrawingStroke {
    
    // You can't not stroke a line.
    return YES;
    
}
-(NSArray*)getSwitchPoint
{
    NSPoint point[6];
    CGFloat bx=[self bounds].origin.x;
    CGFloat by=[self bounds].origin.y;
    CGFloat bw=[self bounds].size.width;
    CGFloat bh=[self bounds].size.height;
    double r=[self strokeWidth]*3;//[self bounds].size.height>[self bounds].size.width?[self bounds].size.width:[self bounds].size.height;
//    r=r/30;
    if (self.direction==0) {
    
        if ([self bounds].size.height<[self bounds].size.width){
            double half_height = [self bounds].size.height/2;
            double quarter_height = [self bounds].size.height/4;
            double third_width = [self bounds].size.width/3;
            
            point[0]=NSMakePoint(bx, by+half_height);
            point[1]=NSMakePoint(bx+third_width, by+half_height);
            point[2]=NSMakePoint(bx+third_width*2, by+half_height+quarter_height);
            point[3]=NSMakePoint(bx+bw, by+half_height+quarter_height);
            point[4]=NSMakePoint(bx+third_width*2, by+quarter_height);
            point[5]=NSMakePoint(bx+bw, by+quarter_height);
        }else
        {
            double half_width = [self bounds].size.width/2;
            double quarter_width = [self bounds].size.width/4;
            double third_height = [self bounds].size.height/3;
            CGFloat sw_h=(bx+half_width)+half_width*2/3;//+[self strokeWidth]*3;
            if ([self state]==0)
            {
                sw_h=bx+half_width;
            }
            point[0]=NSMakePoint(bx+half_width, by);
            point[1]=NSMakePoint(bx+half_width, by+third_height);
            point[2]=NSMakePoint(bx+quarter_width,by+third_height*2+r);
            point[3]=NSMakePoint(bx+quarter_width,by+bh);
            point[4]=NSMakePoint(bx+quarter_width+half_width,by+third_height*2+r);
            point[5]=NSMakePoint(bx+quarter_width+half_width,by+bh);

        }
        
    }else{
        if ([self bounds].size.height<[self bounds].size.width){
            double half_height = [self bounds].size.height/2;
            double quarter_height = [self bounds].size.height/4;
            double third_width = [self bounds].size.width/3;

            point[0]=NSMakePoint(bx+bw, by+half_height);
            point[1]=NSMakePoint(bx+third_width*2, by+half_height);
            point[2]=NSMakePoint(bx+third_width-r,by+half_height+quarter_height);
            point[3]=NSMakePoint(bx,by+half_height+quarter_height);
            point[4]=NSMakePoint(bx+third_width-r,by+quarter_height);
            point[5]=NSMakePoint(bx,by+quarter_height);
        }else
        {
            double half_width = [self bounds].size.width/2;
            double quarter_width = [self bounds].size.width/4;
            double third_height = [self bounds].size.height/3;
            point[0]=NSMakePoint(bx+half_width, by+bh);
            point[1]=NSMakePoint(bx+half_width, by+third_height*2);
        
            point[2]=NSMakePoint(bx+quarter_width,by+third_height-r);
            point[3]=NSMakePoint(bx+quarter_width,by);
            point[4]=NSMakePoint(bx+quarter_width+half_width,by+third_height-r);
            point[5]=NSMakePoint(bx+quarter_width+half_width,by);

        }
    }
    return [NSArray arrayWithObjects:
            [NSValue valueWithPoint:point[0]],
            [NSValue valueWithPoint:point[1]],
            [NSValue valueWithPoint:point[2]],
            [NSValue valueWithPoint:point[3]],
            [NSValue valueWithPoint:point[4]],
            [NSValue valueWithPoint:point[5]],
            nil];
}
-(void)DrawRound:(NSBezierPath *)path Point:(NSPoint)point
{
//    double r=[self bounds].size.height>[self bounds].size.width?[self bounds].size.width:[self bounds].size.height;
//    r=r/10;
    double r=[self strokeWidth]*3;
    NSRect rect=NSMakeRect(point.x-r/2,point.y-r/2, r, r);
    [path appendBezierPathWithOvalInRect:rect];
}
- (NSBezierPath *)bezierPathForDrawing {
    NSArray *arrpoint=[self getSwitchPoint];
    double r=[self bounds].size.height>[self bounds].size.width?[self bounds].size.width:[self bounds].size.height;
    r=r/20;
//    if (r<=[self strokeWidth]+3)
    {
        r=[self strokeWidth]*3;
    }
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
    [path setLineWidth:[self strokeWidth]];
    if([self isDrawingFill])
    {
        [[self fillColor] set];
        [path fill];
    }
    [[self strokeColor] set];
    [path stroke];
    NSBezierPath *Ovalpath = [NSBezierPath bezierPath];
    NSBezierPath *linepath = [NSBezierPath bezierPath];
    
        [linepath setLineWidth:[self strokeWidth]*2];
    if ([self state]==1) {
        [[NSColor redColor] set];
        [linepath moveToPoint:[[arrpoint objectAtIndex:0] pointValue]];
        [linepath lineToPoint:[[arrpoint objectAtIndex:1] pointValue]];
        [linepath lineToPoint:[[arrpoint objectAtIndex:4] pointValue]];
        [linepath lineToPoint:[[arrpoint objectAtIndex:5] pointValue]];
        [self DrawRound:Ovalpath Point:[[arrpoint objectAtIndex:1] pointValue]];
        [self DrawRound:Ovalpath Point:[[arrpoint objectAtIndex:4] pointValue]];

    }else
    {
        [[NSColor blueColor] set];
        [linepath moveToPoint:[[arrpoint objectAtIndex:0] pointValue]];
        [linepath lineToPoint:[[arrpoint objectAtIndex:1] pointValue]];
        [linepath lineToPoint:[[arrpoint objectAtIndex:2] pointValue]];
        [linepath lineToPoint:[[arrpoint objectAtIndex:3] pointValue]];
        [self DrawRound:Ovalpath Point:[[arrpoint objectAtIndex:1] pointValue]];
        [self DrawRound:Ovalpath Point:[[arrpoint objectAtIndex:2] pointValue]];
    }
    [linepath stroke];
    [Ovalpath fill];
    NSBezierPath *offlinepath = [NSBezierPath bezierPath];
    [offlinepath setLineWidth:[self strokeWidth]];
    [[NSColor blackColor] set];
    if ([self state]==1)
    {
        [self DrawRound:offlinepath Point:[[arrpoint objectAtIndex:2] pointValue]];
        [offlinepath moveToPoint:[[arrpoint objectAtIndex:2] pointValue]];
        [offlinepath lineToPoint:[[arrpoint objectAtIndex:3] pointValue]];
    }else
    {
        [self DrawRound:offlinepath Point:[[arrpoint objectAtIndex:4] pointValue]];
        [offlinepath moveToPoint:[[arrpoint objectAtIndex:4] pointValue]];
        [offlinepath lineToPoint:[[arrpoint objectAtIndex:5] pointValue]];
    }
    [offlinepath stroke];
    [offlinepath fill];
    return nil;
}


//- (BOOL)isContentsUnderPoint:(NSPoint)point {
//    
//    // Just check to see if the point is in the path.
//    return [[self bezierPathForDrawing] containsPoint:point];
//
//}


@end
