//
//  NSBezierPath+IAKBBezierPath.m
//  Keyboard
//
//  Created by tombp on 19/01/2017.
//  Copyright © 2017 tombp. All rights reserved.
//

#import "NSBezierPath+IAKBBezierPath.h"

@implementation NSBezierPath (IAKBBezierPath)

+(void)IA_DrawKey_L_Shape_UL:(NSPoint)pUL CE:(NSPoint)pCE CC:(NSPoint)pCC CS:(NSPoint)pCS LR:(NSPoint)pLR UR:(NSPoint)pUR
{
    float baseLen = pow((pow((pLR.x - pUR.x),2)+pow((pLR.y - pUR.y),2)),0.5);
    float aR = 0.06*baseLen;
    
    NSBezierPath *myPath = [NSBezierPath bezierPath];
    [myPath setLineWidth:1];
    [[NSColor blackColor] set];
    [myPath moveToPoint:NSMakePoint(pUL.x,pUL.y-aR)];
    [myPath lineToPoint:NSMakePoint(pCE.x, pCE.y+aR)];
    [myPath appendBezierPathWithArcWithCenter:NSMakePoint(pCE.x+aR,pCE.y+aR)
                                       radius:aR
                                   startAngle:180
                                     endAngle:270
                                    clockwise:NO];
    
    BOOL bEq = NO;
    if ((pCE.x == pCC.x) && (pCE.y == pCC.y)) {
        if ((pCE.x == pCS.x && pCE.y == pCS.y)) {
            bEq = YES;
        }
    }
    if (bEq) {
        
    }else
    {
        //if not retangle , need to draw more
        [myPath lineToPoint:NSMakePoint(pCC.x-aR, pCC.y)];
        [myPath appendBezierPathWithArcWithCenter:NSMakePoint(pCC.x-aR,pCC.y-aR)
                                           radius:aR
                                       startAngle:90
                                         endAngle:0
                                        clockwise:YES];
        [myPath lineToPoint:NSMakePoint(pCS.x, pCS.y+aR)];
        [myPath appendBezierPathWithArcWithCenter:NSMakePoint(pCS.x+aR,pCS.y+aR)
                                           radius:aR
                                       startAngle:180
                                         endAngle:270
                                        clockwise:NO];
        
    }
    [myPath lineToPoint:NSMakePoint(pLR.x-aR, pLR.y)];
    [myPath appendBezierPathWithArcWithCenter:NSMakePoint(pLR.x-aR,pLR.y+aR)
                                       radius:aR
                                   startAngle:270
                                     endAngle:360
                                    clockwise:NO];
    [myPath lineToPoint:NSMakePoint(pUR.x, pUR.y-aR)];
    [myPath appendBezierPathWithArcWithCenter:NSMakePoint(pUR.x-aR,pUR.y-aR)
                                       radius:aR
                                   startAngle:0
                                     endAngle:90
                                    clockwise:NO];
    [myPath lineToPoint:NSMakePoint(pUL.x+aR, pUL.y)];
    [myPath appendBezierPathWithArcWithCenter:NSMakePoint(pUL.x+aR,pUL.y-aR)
                                       radius:aR
                                   startAngle:90
                                     endAngle:180
                                    clockwise:NO];
    
    [[NSColor blackColor] set];
    [myPath stroke];
    [myPath closePath];
}

+(NSRect)getNineRectangleOutRectangle_Rect:(NSRect)mRect Index:(int)POS
{
    float x,y,w,h;
    x = mRect.origin.x;
    y = mRect.origin.y;
    w = mRect.size.width;
    h = mRect.size.height;
    float wInt = w*0.02;
    float hInt = h*0.02;
    float sw = (w - 4*wInt)/3;
    float sh = (h - 4*hInt)/3;
    
    NSRect mnewRect = NSMakeRect((x+((POS-1)%3+1)*wInt)+((POS-1)%3)*sw,    //通过商和余数关系返回各自的位置的矩形
                               y+(3-(POS-1)/3)*hInt+(2-(POS-1)/3)*sh,
                               sw,
                               sh);
    return mnewRect;
}
+(NSRect)getsameCenterXRectangle_Rect:(NSRect)mRect X:(float)xX
{
    float x,y,w,h;
    x = mRect.origin.x;
    y = mRect.origin.y;
    w = mRect.size.width;
    h = mRect.size.height;
    x = x+w*(1-xX)/2;
    y = y+h*(1-xX)/2;
    w = w*xX;
    h = h*xX;
    NSRect myRect = NSMakeRect(x,
                               y,
                               w,
                               h);
    return myRect;
}
+ (NSRect)getSquareInRect:(NSRect)rect
{
    float side = rect.size.width < rect.size.height?rect.size.width:rect.size.height;
    float org_x = rect.origin.x+rect.size.width/2-side/2;
    float org_y = rect.origin.y+rect.size.height/2-side/2;
    NSRect mynewRect = NSMakeRect(org_x, org_y, side, side);
    return mynewRect;
}

+(int)DrawArcCCW_PS:(NSPoint)pST PE:(NSPoint)pEN PJ:(NSPoint)pJU
{
    float k,b,y_line;
    if (pEN.x == pST.x) {
        if (pEN.y == pST.y || pJU.x == pEN.x) {
            return -1;
        }else if(  (pEN.x -pJU.x)*(pEN.y-pST.y) > 0){
            return 1;
        }else if(  (pEN.x -pJU.x)*(pEN.y-pST.y) < 0){
            return 0;
        }else{    //never come to here
            return -1;
        }
    }else{
        k = (pEN.y -pST.y)/(pEN.x -pST.x);
        b = pEN.y - k*pEN.x;
        y_line = k*pJU.x+b;
        if(pJU.y == y_line){
            return -1;   //three point at one line
        }else{
            if (k == 0) {
                if ((pEN.x-pST.x)*(y_line - pJU.y)>0) {
                    return 1;
                }else if ((pEN.x-pST.x)*(y_line - pJU.y)<0){
                    return 0;
                }else{  //never come to here
                    return -1;
                }
            }else if (k < 0 ){ // handle k > 0 condition  //k > 0 && k < 0 can combine
                if ((pEN.y-pST.y)*(y_line-pJU.y) > 0){    //combine (pEN.y-pST.y)*(y_line-pJU.y)*k > 0
                    return 1;
                }else if((pEN.y-pST.y)*(y_line-pJU.y) < 0){
                    return 0;
                }else{ // never come to here
                    return -1;
                }
            }else if (k > 0){
                if ((pEN.y-pST.y)*(y_line-pJU.y) < 0){
                    return 1;
                }else if((pEN.y-pST.y)*(y_line-pJU.y) > 0){
                    return 0;
                }else{ // never come to here
                    return -1;
                }
            }else{ // never come to here
                return -1;
            }
        }
    }
}


+(void)IA_PreProcessPoints:(NSPoint*)pXX Len:(int*)nLen
{
    int myLen = *nLen;
    NSPoint pPT;
    NSPoint cPT;
    NSPoint nPT;
    int drawArcCCW;
    for (int i = 0; i < myLen; i++) {
        cPT = *(pXX+(myLen+i)%myLen);
        pPT = *(pXX+(myLen+i-1)%myLen);
        nPT = *(pXX+(myLen+i+1)%myLen);
        drawArcCCW = [self DrawArcCCW_PS:pPT PE:nPT PJ:cPT];
        if (drawArcCCW ==-1) {
            for(int j = 0;i+j+1 < myLen;j++){
                *(pXX+i+j) = *(pXX+(myLen+i+j+1)%myLen);
            }
            *nLen = *nLen -1;
            [self IA_PreProcessPoints:pXX Len:nLen];
            break;
        }
    }
}
+(NSBezierPath*)IA_L_Shape:(NSPoint*)mypXX Len:(int)mynLen AR:(CGFloat)aR
{
    NSPoint pXX[6];
    int nLen = mynLen;
    for (int i= 0; i< mynLen; i++) {
        pXX[i] = *(mypXX+i);
    }
    [self IA_PreProcessPoints:pXX Len:&nLen];     //remove the point when three point on one line
    NSPoint pPT;
    NSPoint cPT;
    NSPoint nPT;
    NSPoint drawPT_ST;
    NSPoint drawPT_EN;
    NSBezierPath *myPath = [NSBezierPath bezierPath];
    [myPath setLineWidth:1];
    [[NSColor blackColor] set];
    //    [myPath moveToPoint:*pXX];
    int drawArcCCW ;
    int prePoint_drawArcCCW =0 ;
    for (int i = 0; i < nLen; i++) {
        cPT = *(pXX+(nLen+i)%nLen);
        pPT = *(pXX+(nLen+i-1)%nLen);
        nPT = *(pXX+(nLen+i+1)%nLen);
        drawArcCCW = [self DrawArcCCW_PS:pPT PE:nPT PJ:cPT];
        if(drawArcCCW == 1){
            if(cPT.x ==pPT.x){
                if (cPT.y > pPT.y) {
                    drawPT_ST = NSMakePoint(pPT.x, pPT.y+aR);
                    drawPT_EN = NSMakePoint(cPT.x, cPT.y-aR);
                    //                    [myPath moveToPoint:drawPT_ST];
                    [myPath lineToPoint:drawPT_EN];
                    [myPath appendBezierPathWithArcWithCenter:NSMakePoint(cPT.x+aR,cPT.y-aR)
                                                       radius:aR
                                                   startAngle:180
                                                     endAngle:90
                                                    clockwise:YES];
                    
                    
                }else if(cPT.y < pPT.y){
                    drawPT_ST = NSMakePoint(pPT.x, pPT.y-aR);
                    drawPT_EN = NSMakePoint(cPT.x, cPT.y+aR);
                    //                    [myPath moveToPoint:drawPT_ST];
                    [myPath lineToPoint:drawPT_EN];
                    [myPath appendBezierPathWithArcWithCenter:NSMakePoint(cPT.x-aR,cPT.y+aR)
                                                       radius:aR
                                                   startAngle:0
                                                     endAngle:270
                                                    clockwise:YES];
                }else{
                    
                }
            }else if(cPT.y == pPT.y){
                if (cPT.x > pPT.x){
                    drawPT_ST = NSMakePoint(pPT.x+aR, pPT.y);
                    drawPT_EN = NSMakePoint(cPT.x-aR, cPT.y);
                    //                    [myPath moveToPoint:drawPT_ST];
                    [myPath lineToPoint:drawPT_EN];
                    [myPath appendBezierPathWithArcWithCenter:NSMakePoint(cPT.x-aR,cPT.y-aR)
                                                       radius:aR
                                                   startAngle:90
                                                     endAngle:0
                                                    clockwise:YES];
                }else if(cPT.x < pPT.x){
                    drawPT_ST = NSMakePoint(pPT.x-aR, pPT.y);
                    drawPT_EN = NSMakePoint(cPT.x+aR, cPT.y);
                    [myPath moveToPoint:drawPT_ST];
                    [myPath lineToPoint:drawPT_EN];
                    [myPath appendBezierPathWithArcWithCenter:NSMakePoint(cPT.x+aR,cPT.y+aR)
                                                       radius:aR
                                                   startAngle:270
                                                     endAngle:180
                                                    clockwise:YES];
                }else{
                    
                }
            }else{
                
            }
        }else if(drawArcCCW==0){
            if(cPT.x ==pPT.x){
                if (cPT.y > pPT.y) {
                    drawPT_ST = NSMakePoint(pPT.x, pPT.y+aR);
                    drawPT_EN = NSMakePoint(cPT.x, cPT.y-aR);
                }else if(cPT.y < pPT.y){
                    drawPT_ST = NSMakePoint(pPT.x, pPT.y-aR);
                    drawPT_EN = NSMakePoint(cPT.x, cPT.y+aR);
                }else{
                    
                }
            }else if(cPT.y == pPT.y){
                if (cPT.x > pPT.x){
                    drawPT_ST = NSMakePoint(pPT.x+aR, pPT.y);
                    drawPT_EN = NSMakePoint(cPT.x-aR, cPT.y);
                    //                    [myPath moveToPoint:drawPT_ST];
                    [myPath lineToPoint:drawPT_EN];
                    [myPath appendBezierPathWithArcWithCenter:NSMakePoint(cPT.x-aR,cPT.y+aR)
                                                       radius:aR
                                                   startAngle:270
                                                     endAngle:0
                                                    clockwise:NO];
                    
                }else if(cPT.x < pPT.x){
                    drawPT_ST = NSMakePoint(pPT.x-aR, pPT.y);
                    drawPT_EN = NSMakePoint(cPT.x+aR, cPT.y);
                }else{
                    
                }
            }else{
                
            }
        }else if(drawArcCCW == -1){
            printf("aaa");
            if(prePoint_drawArcCCW != -1){
                
            }
        }
    }

    [myPath closePath];
    return myPath;
}

@end
