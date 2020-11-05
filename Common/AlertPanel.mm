//
//  AlertPanel.m
//  UI
//
//  Created by ZL-Pro on 2017/7/13.
//
//
#import "AlertPanel.h"

@implementation NSAlert (NSRunAlertPanelEx)
-(void)RunAlertPanel:(NSMutableDictionary *)dic
{
    long ret = [self runModal];
    [dic setValue:[NSNumber numberWithLong:ret] forKey:@"return"];
    
}
@end

#define defaultButtonV 1
#define alternateButtonV 0
#define otherButtonV -1

NSInteger NSRunAlertPanelEx(NSString *title, NSString *msgFormat, NSString *defaultButton, NSString *alternateButton, NSString *otherButton, ...)
{
    va_list arguments;
    va_start(arguments,msgFormat);
    NSString *outout = [[NSString alloc] initWithFormat:msgFormat arguments:arguments];
    va_end(arguments);
    NSAlert *alter=[[NSAlert alloc] init];
    [alter setMessageText:title];
    [alter setInformativeText:outout];
    [alter setAlertStyle:NSWarningAlertStyle];
    int m=0;
    if (defaultButton!=nil) {
        [alter addButtonWithTitle:defaultButton];
        m=1;
    }
    if (otherButton!=nil) {
        [alter addButtonWithTitle:otherButton];
        m+=2;
    }
    if (alternateButton!=nil) {
        [alter addButtonWithTitle:alternateButton];
        m+=4;
    }
    NSInteger n=0;
    if ([[NSThread currentThread] isMainThread]) {
        n=(NSInteger)[alter runModal];
    }else {
        NSMutableDictionary * dic=[NSMutableDictionary dictionary];
        [alter performSelectorOnMainThread:@selector(RunAlertPanel:) withObject:dic waitUntilDone:YES];
        n=[[dic valueForKey:@"return"] intValue];
    }
    [alter release];
    [outout release];
    switch (m) {
        case 0:
        case 1:
            return defaultButtonV;
            break;
        case 2:
            return otherButtonV;
            break;
        case 3:
            if (n==1000)
                return defaultButtonV;
            else
                return otherButtonV;
            break;
        case 4:
            return alternateButtonV;
            break;
        case 5:
            if (n==1000)
                return defaultButtonV;
            else
                return alternateButtonV;
            break;
        case 6:
            if (n==1000)
                return otherButtonV;
            else
                return alternateButtonV;
            break;
        default:
            if (n==1000) {
                return defaultButtonV;
            }else if (n==1001)
            {
                return otherButtonV;
            }else if (n==1002){
                return alternateButtonV;
            }
            break;
    }
    return n;
}
