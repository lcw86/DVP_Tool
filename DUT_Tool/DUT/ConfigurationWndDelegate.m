//
//  ConfigurationWndDelegate.m
//  DUT
//

//

#import "ConfigurationWndDelegate.h"

@implementation ConfigurationWndDelegate

-(void)awakeFromNib
{
}

-(IBAction)btOK:(id)sender
{
    for (id key in [dicTableView keyEnumerator])
    {
        [dicConfiguration setValue:[dicTableView valueForKey:key] forKey:key];
    }
    [winMain endSheet:winConfiguration returnCode:NSModalResponseOK];
}

-(NSMutableDictionary*)configReturn
{
    return dicConfiguration;
}

-(IBAction)btCancel:(id)sender
{
     [winMain endSheet:winConfiguration returnCode:NSModalResponseCancel];
}

-(void)InitCtrls:(NSMutableDictionary *)dic withSolts:(int)number withFuncs:(int)funsNum;
{
    dicConfiguration = dic;
    
    if (dicTableView) {
        [dicTableView release];
    }
    dicTableView = [[NSMutableDictionary alloc] initWithDictionary:dic copyItems:YES];
    m_Solts = number;
    m_funcs = funsNum;
    [tableView reloadData];
}

#pragma table view datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    return m_funcs;
}

/* This method is required for the "Cell Based" TableView, and is optional for the "View Based" TableView. If implemented in the latter case, the value will be set to the view at a given row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView).
 */
- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([[tableColumn identifier] isEqualToString:@"index"])
    {
        return [NSNumber numberWithLong:row];
    }
    else
    {
        id v = [dicTableView valueForKey:[NSString stringWithFormat:@"%@%ld0",[tableColumn identifier],row]];
        if (!v) {
            v=@"None";
        }
        return v;
    }
}

/* NOTE: This method is not called for the View Based TableView.
 */
- (void)tableView:(NSTableView *)tableView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSLog(@"Set object");
    if (![[tableColumn identifier] isEqualToString:@"index"])
    {
        NSArray *aBasePorts = [object componentsSeparatedByString:@":"];
        
        if ([aBasePorts count] < 2)
        {
            NSLog(@"return ..%@",object);
            return;
        }
        
        int port = (int)[[aBasePorts objectAtIndex:2]integerValue];
        
        NSLog(@"port:%d",port);
        
        NSMutableArray *m_array = [[NSMutableArray alloc]initWithArray:aBasePorts];
        
        for (int i = 0; i < m_Solts; i++)
        {
            [m_array replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%d",port]];
            [dicTableView setObject:[m_array componentsJoinedByString:@":"] forKey:[NSString stringWithFormat:@"%@%ld%d",[tableColumn identifier],row,i]];
            port++;
        }
        
        [m_array release];
        NSLog(@"port:%d",port);
    }
}

@end
