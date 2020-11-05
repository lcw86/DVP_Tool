//
//  ButtonGroupConfigDelegate.m
//  LuaDebugPanel
//
//  Created by Rony on 11/20/17.
//  Copyright © 2017 Louis. All rights reserved.
//

#import "ButtonGroupConfigDelegate.h"

@implementation ButtonGroupConfigDelegate

-(id)init{
    if(self=[super init])
    {
        _dic_groupinfor = [[NSMutableDictionary alloc] init];
        _arr_groupname = [[NSMutableArray alloc] init];
        rClickedBtn = nil;
        rLastClickedBtn = nil;
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(onRightClick:)
//                                                     name:@"rightclickonbutton"
//                                                   object:nil] ;
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(onShowwindow:)
//                                                     name:@"showgroupconfigwindow"
//                                                   object:nil] ;
        point = NSMakePoint(800, 600);
    }
    return self;
}

-(void)dealloc
{
    if(_dic_groupinfor)
    {
        [_dic_groupinfor release];
        _dic_groupinfor = nil;
        [_arr_groupname release];
        _arr_groupname = nil;
        
    }
    [super dealloc];
}

-(void)onShowwindow:(NSNotification*)nf
{
    [mw center];
    
    //    NSPoint point = NSMakePoint(1000, 500);
    //    [mw setFrameTopLeftPoint:point];
    
    [mw makeKeyAndOrderFront:nil];
    [btnAddBtn setEnabled:NO];
    [btnDelBtn setEnabled:NO];
    [tiplabel setHidden:YES];
    [btnname setStringValue:@""];
}

-(void)onRightClick:(NSNotification*)nf
{
    NSDictionary *dic = [nf userInfo];
    rClickedBtn = [dic objectForKey:@"button"];
    //    [mw center];
    
    [mw setFrame:mw.frame display:YES];
    [mw makeKeyAndOrderFront:nil];
    [btnAddBtn setEnabled:YES];
    [btnDelBtn setEnabled:YES];
    [tiplabel setHidden:NO];
    [btnname setStringValue:[NSString stringWithFormat:@"btn_%ld",[rClickedBtn identifier]]];
    
   // fill color to RightClick button

    [[NSNotificationCenter defaultCenter]postNotificationName:@"resetRightClickColor" object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:rLastClickedBtn, @"button", nil]];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"rightClickColor" object:nil userInfo:dic];
    rLastClickedBtn = rClickedBtn;
}

-(IBAction)btnCreateGroup:(id)sender
{
    if([[tfname stringValue] length]==0)
    {
        NSRunAlertPanel(@"empty name", @"empty name", @"OK", nil, nil,nil);
        return;
    }
    if ([_dic_groupinfor objectForKey:[tfname stringValue]])
    {
        NSRunAlertPanel(@"duplicate name", @"duplicate name", @"OK", nil, nil,nil);
        return;
    }
    
    [_arr_groupname addObject:[tfname stringValue]];
    [_dic_groupinfor setObject:[NSMutableArray array] forKey:[tfname stringValue]];
    [tfname setStringValue:@""];
    [tv reloadData];

}

-(IBAction)btnDeleteGroup:(id)sender
{
    NSUInteger num = [_arr_groupname count];
    NSInteger selectrow = [tv selectedRow];
    if(selectrow == -1)
    {
        NSRunAlertPanel(@"pls select valid row", @"pls select", @"OK", nil, nil,nil);
        return;
    }
    if (selectrow+1>num)
    {
        NSRunAlertPanel(@"pls select valid row", @"pls select", @"OK", nil, nil,nil);
        return;
    }
    NSString *delename = [NSString stringWithString:[_arr_groupname objectAtIndex:selectrow]];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSArray alloc] init],@"selectedButton",[[NSArray alloc] initWithArray:[_dic_groupinfor objectForKey:delename]],@"deselectedButton", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"buttonGroupHighlight" object:nil userInfo:dic];
    
    [_dic_groupinfor removeObjectForKey:delename];
    [_arr_groupname removeObjectAtIndex:selectrow];
    [tv reloadData];

}

-(BOOL)buttonID:(NSInteger)id ExistedinGroup:(NSString*)groupname
{
    NSMutableArray *arrbtn = [_dic_groupinfor objectForKey:groupname];
    BOOL existed = false;
    for (NSInteger i=0;i<[arrbtn count];i++)
    {
        if([arrbtn[i] integerValue] == id)
        {
            existed = true;
            break;
        }
    }
    return existed;
}

-(void)removeBtnID:(NSInteger)id FromGroup:(NSString*)groupname
{
    NSMutableArray *arrbtn = [_dic_groupinfor objectForKey:groupname];
    for (NSInteger i=0;i<[arrbtn count];i++)
    {
        if([arrbtn[i] integerValue] == id)
        {
            [arrbtn removeObjectAtIndex:i];
            break;
        }
    }
    
}




-(IBAction)onAddBtnto:(id)sender
{
    NSUInteger num = [_arr_groupname count];
    NSInteger selectrow = [tv selectedRow];
    if(selectrow == -1)
    {
        NSRunAlertPanel(@"pls select valid row", @"pls select", @"OK", nil, nil,nil);
        return;
    }
    if (selectrow+1>num)
    {
        NSRunAlertPanel(@"pls select valid row", @"pls select", @"OK", nil, nil,nil);
        return;
    }
    NSString *selectGroupName = [NSString stringWithString:[_arr_groupname objectAtIndex:selectrow]];
    NSMutableArray *arrbtn = [_dic_groupinfor objectForKey:selectGroupName];
    if (![self buttonID:[rClickedBtn identifier] ExistedinGroup:selectGroupName])
    {
       
        [arrbtn addObject:[NSNumber numberWithInteger:[rClickedBtn identifier]]];
        [tv reloadData];
        [btnname setStringValue:[NSString stringWithFormat:@"btn_%ld added into group:%@ successfully!",[rClickedBtn identifier],selectGroupName]];
    }else{
        [btnname setStringValue:[NSString stringWithFormat:@"btn_%ld already existed in group:%@!",[rClickedBtn identifier],selectGroupName]];
    }
    [self setSelectedButtonsColor];
}



-(IBAction)onRemoveBtnFrom:(id)sender
{
    NSUInteger num = [_arr_groupname count];
    NSInteger selectrow = [tv selectedRow];
    if(selectrow == -1)
    {
        NSRunAlertPanel(@"pls select valid row", @"pls select", @"OK", nil, nil,nil);
        return;
    }
    if (selectrow+1>num)
    {
        NSRunAlertPanel(@"pls select valid row", @"pls select", @"OK", nil, nil,nil);
        return;
    }
    NSString *selectGroupName = [NSString stringWithString:[_arr_groupname objectAtIndex:selectrow]];
    if (![self buttonID:[rClickedBtn identifier] ExistedinGroup:selectGroupName])
    {
        [btnname setStringValue:[NSString stringWithFormat:@"btn_%ld was not in group:%@!",[rClickedBtn identifier],selectGroupName]];
        
    }else{
        [self resetRemoveButtonColor:selectGroupName];
        [self removeBtnID:[rClickedBtn identifier] FromGroup:selectGroupName];
        [tv reloadData];
        [btnname setStringValue:[NSString stringWithFormat:@"btn_%ld is removed from group:%@ successfully!",[rClickedBtn identifier],selectGroupName]];
        
    }
    
}


/**
 when a button is removed from selected row,reset its color fill white.

 @param groupname the removed button group name
 */
-(void)resetRemoveButtonColor:(NSString*) groupname
{
    /* change button color */
    NSMutableArray *arr_selectedButton = [_dic_groupinfor objectForKey:groupname];
    NSMutableArray *arr_deselectedButton = [[NSMutableArray alloc]init];
    NSMutableArray *arrbtn = [_dic_groupinfor objectForKey:groupname];
    for (NSInteger i=0;i<[arrbtn count];i++)
    {
        if([arrbtn[i] integerValue] == [rClickedBtn identifier])
        {
            [arr_deselectedButton addObject:[arrbtn objectAtIndex:i]];
            [arr_selectedButton removeObject:[arrbtn objectAtIndex:i]];
            break;
        }
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:arr_selectedButton,@"selectedButton",arr_deselectedButton,@"deselectedButton", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"buttonGroupHighlight" object:nil userInfo:dic];
    
}

/**
 set selected buttons fill color.
 
 */
-(void)setSelectedButtonsColor
{
    /* get tv selectedrow, then get the selected buttons's id*/
    NSUInteger num = [_arr_groupname count]; // row count
    NSUInteger selectrow = [tv selectedRow];
    NSArray *arr_selectedButton;
    
    if (selectrow >= num) {
        arr_selectedButton = [[NSArray alloc] init];
    }else{
        arr_selectedButton = [_dic_groupinfor objectForKey:[_arr_groupname objectAtIndex:selectrow]];
    }
    NSMutableArray *arr_deselectedButton = [[NSMutableArray alloc]init];
    for (int i = 0; i < num; i++) {
        if (i == selectrow) {
            continue;
        }
        [arr_deselectedButton setArray:[_dic_groupinfor objectForKey:[_arr_groupname objectAtIndex:i]]];
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:arr_selectedButton,@"selectedButton",arr_deselectedButton,@"deselectedButton", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"buttonGroupHighlight" object:nil userInfo:dic];
    
    
}

-(IBAction)btnSwitch:(id)sender
{
    NSUInteger num = [_arr_groupname count];
    NSUInteger selectrow = [tv selectedRow];
    
    if (selectrow>num)
    {
        NSRunAlertPanel(@"pls select valid row", @"pls select", @"OK", nil, nil,nil);
        return;
    }
    NSArray *arr_btn = [_dic_groupinfor objectForKey:[_arr_groupname objectAtIndex:selectrow]];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@(1-[sender state]),@"state",arr_btn,@"button", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"buttongroupswitch" object:nil userInfo:dic];
}

#pragma mark Delegate method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    return [_arr_groupname count];
}



- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *groupname = [_arr_groupname objectAtIndex:row];
    
    if ([[tableColumn identifier] isEqualToString:@"GroupName"])
    {
        return groupname;
    }else{
        return [[_dic_groupinfor objectForKey:groupname] componentsJoinedByString:@","];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSLog(@"tv selected changed");
    //    int row = (int)[tv selectedRow];
    
    
    [self setSelectedButtonsColor];
}


@end
