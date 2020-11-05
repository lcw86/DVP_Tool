//
//  GT_DUT.m
//  DUT
//
//  Created by Ryan on 11/13/15.

//

#import "GT_DUT.h"
extern int _slots;
extern NSMenu * menuInstr;
extern NSString * _pName;
@implementation GT_DUT

-(id)init
{
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(int)uixLoad:(id)sender
{
    id s = [(NSDictionary*)sender objectForKey:@"slots"];
    if(s)
        _slots = [s integerValue];
    s = [(NSDictionary*)sender objectForKey:@"name"];
    if(s)
        _pName = s;
    
    s= [sender valueForKey:@"menu_instr"];
    menuInstr = s;

    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    
//    [bundle loadNibNamed:@"MainMenu" owner:self topLevelObjects:nil];
//    if ([NSBundle loadNibNamed:@"DutBundle" owner:self]==FALSE)
//        return -1 ;
    
    //if ([bundle loadNibNamed:@"DutBundle" owner:self topLevelObjects:nil]==false) {
    if ([NSBundle loadNibNamed:@"DutBundle" owner:self]==FALSE){
        return -1;
    }
    return 0;
}

-(void)uixSetDelegate:(id)sender
{
    
}

@end
