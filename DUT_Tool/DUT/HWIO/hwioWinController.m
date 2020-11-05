//
//  hwioWinController.m
//  hwio_Test
//
//  Created by RyanGao on 2019/6/18.
//  Copyright © 2019 RyanGao. All rights reserved.
//

#import "hwioWinController.h"
#import "RegexKitLite.h"

@interface hwioWinController ()

@end

@implementation hwioWinController


-(instancetype)init
{
    self = [super init];
    if (self)
    {
        cellArray = [[NSMutableArray alloc]init];
    }
    return self;
}


-(int)loadHwioTableFile
{
    
    NSString *luapath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    if ([luapath containsString:@"/tools"]) {
        luapath = [luapath stringByDeletingLastPathComponent];
    }
    luapath = [[luapath stringByAppendingPathComponent:@"LuaDriver/Driver/hw/HWIO.lua"] stringByResolvingSymlinksInPath];
    NSString * luaCont = [NSString stringWithContentsOfFile:luapath encoding:NSUTF8StringEncoding error:nil];
    
    NSRange range_io_start = [luaCont rangeOfString:@"HWIO.MeasureTable"];
    NSRange range_io_end = [luaCont rangeOfString:@"return HWIO"];
    NSRange range_io;
    range_io.location = range_io_start.location+range_io_start.length;
    range_io.length = range_io_end.location-range_io_start.location-range_io_start.length;
    NSString * io_con = [luaCont substringWithRange:range_io];
    
    NSArray *arrayCont = [io_con componentsSeparatedByString:@"\n"];
    for (NSString *str in arrayCont)
    {
        if (str)
        {
            str =  [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([str length] >3 &&[str isNotEqualTo:@""])
            {
                if ([[str substringWithRange:NSMakeRange(0, 2)] isNotEqualTo:@"--"] && ![str containsString:@"HWIO.critical"])
                {
                    
                    NSString *pattern = @"IO\\s*=";
                    //1.1将正则表达式设置为OC规则
                    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
                    //2.利用规则测试字符串获取匹配结果
                    NSArray *results = [regular matchesInString:str options:0 range:NSMakeRange(0, str.length)];
                    [regular release];
                    
                    if (results.count)
                    {
                        str = [NSString stringWithFormat:@"\t\t\t\t%@",str];
                    }
                    
//                    if ([str containsString:@"IO="] || [str containsString:@"IO ="] || [str containsString:@"IO  ="] || [str containsString:@"IO   ="] ||[str containsString:@"IO    ="]) {
//                        str = [NSString stringWithFormat:@"\t\t\t\t%@",str];
//                    }
                    [cellArray addObject:str];
                }
            }
        }
    }
//    NSLog(@"%@",luapath);
//    NSLog(@"%@",luaCont);
    
    
    
//    [cellArray addObject:@"aaaaaaaaaaaaaaaaa"];
//    [cellArray addObject:@"cccccccc"];
//    [cellArray addObject:@"bbbbbbbbbbbbbbb"];
//    [cellArray addObject:@"eeeeeeeeeeeeeeeeeeeee"];
//    [cellArray addObject:@"44444444444444444444444444"];
//    [cellArray addObject:@"aaaaaaaaaadfgwerwerwerwerweraaaaaaa"];
//    [cellArray addObject:@"4fsdfsdfsdfdgdfg"];

    
    
    
    return 0;
}

-(void)awakeFromNib
{
    [cmdControlList setTarget:self];
    [cmdControlList setDoubleAction:@selector(DblClickOnTableView:)];
    
    [self loadHwioTableFile];
    
    [m_scrollView setHasHorizontalScroller:YES];
    [m_scrollView setHasVerticalScroller:YES];
    
}




-(NSString *) channel_number:(NSString *)ch
{
    NSString* temp =@"";
    if ([ch isEqualToString:@"AI1"])
    {
        temp = @"A";
    }
    else if ([ch isEqualToString:@"AI2"])
    {
        temp = @"B";
    }
    else if ([ch isEqualToString:@"AI3"])
    {
        temp = @"C";
    }
    else if ([ch isEqualToString:@"AI4"])
    {
        temp = @"D";
    }
    else if ([ch isEqualToString:@"AI5"])
    {
        temp = @"E";
    }
    else if ([ch isEqualToString:@"AI6"])
    {
        temp = @"F";
    }
    else if ([ch isEqualToString:@"AI7"])
    {
        temp = @"G";
    }
    else
    {
        temp = @"H";
    }
    
    return temp;
}

-(NSString *)aiCommand:(NSString *)ch
{
    NSString * option = @"nor";
    NSString * channel = [self channel_number:ch];
    NSString * adc_range = @"10V";
    int sample_rate = 10000;
    int count = 1;
    int measue_time = 150;
    
    NSString *cmd = [NSString stringWithFormat:@"[444555666]adc read(%@,%@,%@,%d,%d,%d)",option,channel,adc_range,sample_rate,count,measue_time];
    return cmd;
    
}

-(NSString *)frequenceCommand
{
    
    int door_v = 300;
    NSString *cmd = [NSString stringWithFormat:@"[444555666]frequency measure(-fdv,%d,200)",door_v];
    return cmd;
}

-(NSString *)convertCmd:(NSArray *)arrayIO with:(NSString *)ioname
{
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:@""];
    for (NSString *sub in arrayIO)
    {
        NSArray *s = [sub componentsSeparatedByString:@","];
        if ([s count]>1)
        {
            NSString *io = [s[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *status = [s[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [cmd appendString:[NSString stringWithFormat:@"bit%@=%@,",io,status]];
        }
        
    }
    NSString *cmdIO =[NSString stringWithFormat:@"[123]%@(%zd,%@,,)",ioname,[arrayIO count],cmd];
    cmdIO = [cmdIO stringByReplacingOccurrencesOfString:@",,," withString:@""];
    [cmd release];
    return cmdIO;
}


-(NSString *) cmdRealyIO:(NSString *)str
{
    NSString *pattern = @"[0-9]+\\s*,\\s*[0-9]+";
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSMutableArray *arrayIO = [[NSMutableArray alloc]init];
    for (NSTextCheckingResult *result in results)
    {
        //NSLog(@" %@",[str substringWithRange:result.range]);
        [arrayIO addObject:[str substringWithRange:result.range]];
    }
    if ( [arrayIO count] == 0)
    {
        [regular release];
        [arrayIO release];
        return @"click is wrong!!!";
    }
    
    NSString *pattern0 = @"CH\\s*=";
    NSRegularExpression *regular0 = [[NSRegularExpression alloc] initWithPattern:pattern0 options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results0 = [regular0 matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    
    if (results0.count)
    {
        //for AI measurement
        NSString *regexString1 = @"IO\\s*=\\s*\\{\\s*(\\{\\s*.*?\\s*\\})\\s*\\}";
        NSString *regexString2 = @"EXIO\\s*=\\s*\\{\\s*(\\{\\s*.*?\\s*\\})\\s*\\}";
        NSString *regexString3 = @"EXIO_DISCONNECT\\s*=\\s*\\{\\s*(\\{\\s*.*?\\s*\\})\\s*\\}";
        NSString *matchedStr1 = [str stringByMatching:regexString1 capture:1L];
        NSString *matchedStr2 = [str stringByMatching:regexString2 capture:1L];
        NSString *matchedStr3 = [str stringByMatching:regexString3 capture:1L];
        
        NSString *regexString4 = @"CH\\s*=\\s*\"\\s*(AI\\d+)\\s*\"";
        NSString *results4 = [str stringByMatching:regexString4 capture:1L];
        
        NSString *regexString5 = @"CH\\s*=\\s*\"\\s*(\\w*_\\w*)\\s*\"";
        NSString *results5 = [str stringByMatching:regexString5 capture:1L];
        
        NSArray *results1=nil;
        NSArray *results2=nil;
        NSArray *results3=nil;
        
        if (matchedStr1)
        {
            results1 = [regular matchesInString:matchedStr1 options:0 range:NSMakeRange(0, matchedStr1.length)];
        }
        if (matchedStr2)
        {
            results2 = [regular matchesInString:matchedStr2 options:0 range:NSMakeRange(0, matchedStr2.length)];
        }
        if (matchedStr3)
        {
            results3 = [regular matchesInString:matchedStr3 options:0 range:NSMakeRange(0, matchedStr3.length)];
        }
        
        //NSLog(@"%@    | %@   |   %@",matchedStr1,matchedStr2,matchedStr3);
        
        NSMutableString *cmdIO = [[[NSMutableString alloc]initWithString:@""] autorelease];
        if (results1)
        {
            if (arrayIO)
            {
                [arrayIO removeAllObjects];
            }
            for (NSTextCheckingResult *result in results1)
            {
                [arrayIO addObject:[matchedStr1 substringWithRange:result.range]];
            }
            
            [cmdIO appendString: [self convertCmd:arrayIO with:@"io set"]];
            
        }
        if (results2)
        {
            if (arrayIO)
            {
                [arrayIO removeAllObjects];
            }
            for (NSTextCheckingResult *result in results2)
            {
                [arrayIO addObject:[matchedStr2 substringWithRange:result.range]];
            }
            
            [cmdIO appendString:@";"];
            [cmdIO appendString: [self convertCmd:arrayIO with: @"exio set"]];
            
            // NSLog(@"---2--%@",cmdIO);
            
        }
        
        if (results4)
        {
            [cmdIO appendString:@";"];
            [cmdIO appendString:[self aiCommand:results4]];
        }
        
        if (results5)
        {
            [cmdIO appendString:@";"];
            [cmdIO appendString:[self frequenceCommand]];
        }
        
        if (results3)
        {
            if (arrayIO)
            {
                [arrayIO removeAllObjects];
            }
            for (NSTextCheckingResult *result in results3)
            {
                [arrayIO addObject:[matchedStr3 substringWithRange:result.range]];
            }
            
            [cmdIO appendString:@";"];
            [cmdIO appendString:[self convertCmd:arrayIO with:@"exio set"]];
            
        }
        
        //NSLog(@"===%@====",cmdIO);
        [arrayIO release];
        [regular release];
        [regular0 release];
        
        return cmdIO;
    }
    else
    {
        //for relay
        
        NSMutableString *cmd = [[NSMutableString alloc] initWithString:@""];
        for (NSString *sub in arrayIO)
        {
            NSArray *s = [sub componentsSeparatedByString:@","];
            if ([s count]>1)
            {
                NSString *io = [s[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *status = [s[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [cmd appendString:[NSString stringWithFormat:@"bit%@=%@,",io,status]];
            }
            
        }
        
        NSString *pattern2 = @"EXIO\\s*=";
        NSRegularExpression *regular2 = [[NSRegularExpression alloc] initWithPattern:pattern2 options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results2 = [regular2 matchesInString:str options:0 range:NSMakeRange(0, str.length)];
        
        
        NSString * ioname= @"io set";
        if (results2.count)
        {
            ioname= @"exio set";
        }
        NSString *cmdIO =[NSString stringWithFormat:@"[123]%@(%zd,%@,,)",ioname,[arrayIO count],cmd];
        cmdIO = [cmdIO stringByReplacingOccurrencesOfString:@",,," withString:@""];
        
        
        [arrayIO release];
        [cmd release];
        [regular0 release];
        [regular release];
        [regular2 release];
        return cmdIO;
    }
}

-(NSString *) cmdRealyIO_no_use:(NSString *)str
{
    NSString *pattern = @"[0-9]+\\s*,\\s*[0-9]+";
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    NSMutableArray *arrayIO = [[NSMutableArray alloc]init];
    for (NSTextCheckingResult *result in results)
    {
        //NSLog(@" %@",[str substringWithRange:result.range]);
        [arrayIO addObject:[str substringWithRange:result.range]];
    }
    if ( [arrayIO count] == 0)
    {
        [regular release];
        [arrayIO release];
        return @"click is wrong!!!";
    }
   
    NSMutableString *cmd = [[NSMutableString alloc] initWithString:@""];
    for (NSString *sub in arrayIO)
    {
        NSArray *s = [sub componentsSeparatedByString:@","];
        if ([s count]>1)
        {
            NSString *io = [s[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *status = [s[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [cmd appendString:[NSString stringWithFormat:@"bit%@=%@,",io,status]];
        }
        
    }
    
    NSString *pattern2 = @"EXIO\\s*=";
    NSRegularExpression *regular2 = [[NSRegularExpression alloc] initWithPattern:pattern2 options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results2 = [regular2 matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    
    NSString * ioname= @"io set";
    if (results2.count)
    {
        ioname= @"exio set";
    }
    NSString *cmdIO =[NSString stringWithFormat:@"[123]%@(%zd,%@,,)",ioname,[arrayIO count],cmd];
    cmdIO = [cmdIO stringByReplacingOccurrencesOfString:@",,," withString:@""];
    
    [regular release];
    [arrayIO release];
    [cmd release];
    [regular2 release];
    
    return cmdIO;
}


-(void)DblClickOnTableView:(id)sender
{
    NSInteger row = [cmdControlList selectedRow];
    if (row<0) return;
    NSString *name = [[cellArray objectAtIndex:row]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //NSLog(@"id : %zd  %@", [m_label tag],[self cmdRealyIO:name]);
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setValue:[self cmdRealyIO:name] forKey:@"cmds"] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HWIO_CMD" object
                                                              :nil userInfo
                                                              :dic] ;
}

-(void)dealloc
{
    [cellArray removeAllObjects];
    [cellArray release];
    [super dealloc];
    NSLog(@"---dealloc--");
}

- (void)windowDidLoad {
    [super windowDidLoad];
   
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
        return (int)[cellArray count];
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    
    return YES;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return [cellArray objectAtIndex:rowIndex];
}

-(void)hwioMainWinClose
{
    [hwioMainWin close];
    [self dealloc];
}

-(void)sethwioMainWinTitle:(NSString *)title withID:(int)iID
{
    
    hwioMainWin.title = title;
    [m_label setStringValue:[NSString stringWithFormat:@"Xavier %d",iID+1]];
    hwioMainWin.backgroundColor = [NSColor lightGrayColor];
   
    //NSLog(@"---%@",[m_label stringValue]);
}
- (IBAction)btClickBatt:(NSButton *)sender
{
    NSString *value = [m_batt stringValue];
    if (value)
    {
        int ret = [value intValue] *1000;
        NSString *cmd = [NSString stringWithFormat:@"[123]dac set(a,%d)",ret];
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [dic setValue:cmd forKey:@"cmds"] ;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HWIO_CMD" object
                                                                  :nil userInfo
                                                                  :dic] ;
    }
    
}

- (IBAction)btClickUSB:(NSButton *)sender
{
    NSString *value = [m_usb stringValue];
    if (value)
    {
        int ret = ([value intValue] *1000-1221)/4;
        NSString *cmd = [NSString stringWithFormat:@"[123]dac set(d,%d)",ret];
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [dic setValue:cmd forKey:@"cmds"] ;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HWIO_CMD" object
                                                                  :nil userInfo
                                                                  :dic] ;
    }
    
}
- (IBAction)btClickEload:(NSButton *)sender
{

    
}
- (IBAction)btClickUSBRect:(NSButton *)sender
{
    
}
- (IBAction)btClickFreq:(NSButton *)sender
{
}


@end

