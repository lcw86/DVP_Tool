//
//  MobileRestoreVC.m
//  DUT_Tool
//
//  Created by ciwei luo on 2020/8/21.
//  Copyright © 2020 ___Intelligent Automation___. All rights reserved.
//

#import "MobileRestoreVC.h"
#import "GraphicHeader.h"
#import "LoadVC.h"


@interface MobileRestoreVC ()<LoadVCDelegate>
@property (assign) IBOutlet NSTextView *textView;
@property (nonatomic,strong) LoadVC *loadVC;

@end

@implementation MobileRestoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.loadVC = [LoadVC new];
    self.loadVC.loadVCDelegate = self;
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector
                                                     :@selector(getGGValue:) name
                                                     :kNotificationGGValue object
                                                     :nil] ;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

-(void)getGGValue:(NSNotification *)nf
{
    NSDictionary *dic = [nf userInfo];
    NSString *val = [dic objectForKey:@"KEY_GG"];
    [self OnLog:val];
    
}

-(void)OnLog:(NSString *)str
{
    if (!str) return;
    NSMutableString * pstr = [[_textView textStorage] mutableString];
    if ([str containsString:@"\n"])
    {
        [pstr appendFormat:@"%@",str];
    }
    else
    {
        [pstr appendFormat:@"%@\n",str];
    }
    NSRange range = NSMakeRange([pstr length]-1,0);
    [_textView scrollRangeToVisible:range];
}

- (IBAction)nonDiagsClick:(NSButton *)btn {
    NSString *fileCSV = [[NSBundle mainBundle] pathForResource:@"ChooseScript" ofType:@"plist"];
    NSMutableDictionary *listCsvName = [[NSMutableDictionary alloc]init];
    [listCsvName removeAllObjects];
    [listCsvName setDictionary:[NSDictionary dictionaryWithContentsOfFile:fileCSV]];
    if ([listCsvName valueForKey:@"MobileRestoreNonDiags_TEST"])
    {
        // [self m_btnButtonDisable];
        NSString *csvName = [listCsvName valueForKey:@"MobileRestoreNonDiags_TEST"];
        NSLog(@"%@",csvName);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             csvName,@"Load_Profile_Debug",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
    }
}



- (IBAction)enterDfuClick:(NSButton *)btn {
    NSString *fileCSV = [[NSBundle mainBundle] pathForResource:@"ChooseScript" ofType:@"plist"];
    NSMutableDictionary *listCsvName = [[NSMutableDictionary alloc]init];
    [listCsvName removeAllObjects];
    [listCsvName setDictionary:[NSDictionary dictionaryWithContentsOfFile:fileCSV]];
    if ([listCsvName valueForKey:@"MobileRestoreEnterDFU_TEST"])
    {
        // [self m_btnButtonDisable];
        NSString *csvName = [listCsvName valueForKey:@"MobileRestoreEnterDFU_TEST"];
        NSLog(@"%@",csvName);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             csvName,@"Load_Profile_Debug",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
    }
}

- (IBAction)restoreClick:(NSButton *)btn {
    // self p
    
    [self presentViewControllerAsModalWindow:self.loadVC];
    
}


- (IBAction)runFctClick:(NSButton *)btn {
    NSString *fileCSV = [[NSBundle mainBundle] pathForResource:@"ChooseScript" ofType:@"plist"];
    NSMutableDictionary *listCsvName = [[NSMutableDictionary alloc]init];
    [listCsvName removeAllObjects];
    [listCsvName setDictionary:[NSDictionary dictionaryWithContentsOfFile:fileCSV]];
    if ([listCsvName valueForKey:@"MobileRestoreFCT_TEST"])
    {
        // [self m_btnButtonDisable];
        NSString *csvName = [listCsvName valueForKey:@"MobileRestoreFCT_TEST"];
        NSLog(@"%@",csvName);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             csvName,@"Load_Profile_Debug",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
    }
}

//- (IBAction)closeClick:(NSButton *)btn {
//    [MRestoreWin close];
//}
- (IBAction)clearClick:(NSButton *)btn {
    [_textView setString:@""];
}

-(void)LoadVCApplyClickWithLoadMode:(LoadMode *)loadMode{

    //        /usr/local/bin/mobile_restore -l 0x14640000 -D /Users/gdlocal/RestorePackage/DFU.pr --bundle /Users/gdlocal/RestorePackage/CurrentBundle/Restore --variant "Factory - DFU" -T Diags -b --server http://spidercab:8080 -I /Users/gdlocal/RestorePackage/CurrentBundle/Restore/Firmware/all_flash/iBootData.j523.DEVELOPMENT.im4p --timeout 30
//
//    NSString * cmd1 = [NSString stringWithFormat:@"/usr/local/bin/mobile_restore -l %@ -D %@ --bundle %@ --variant \"Factory - DFU\" -T Diags -b --server http://spidercab:8080 -I %@ --timeout 30",loadMode.usbArr,loadMode.prFile,loadMode.diagsBinary,loadMode.iBootFile];
    
    ///usr/local/bin/mobile_restore -l 0x14710000 -D /Users/gdlocal/Library/Application\ Support/PurpleRestore/DFU.pr --bundle /Users/gdlocal/RestorePackage/CurrentBundle/Restore --variant "Factory - DFU" -F /Users/gdlocal/Desktop/diags/diag-J523.im4p -b --server http://spidercab:8080 -I /Users/gdlocal/RestorePackage/CurrentBundle/Restore/Firmware/all_flash/iBootData.j523.DEVELOPMENT.im4p --timeout 30
    
    
    NSString * cmd = [NSString stringWithFormat:@"/usr/local/bin/mobile_restore -l %@ -D %@ --bundle %@ --variant \"Factory - DFU\" -F %@ -b --server http://spidercab:8080 -I %@ --timeout 30",loadMode.usbArr,loadMode.prFile,loadMode.restoreFile,loadMode.diagsBinary,loadMode.iBootFile];
    
    [self terminalWithCmd:cmd];
    
    //        file1 = @"";
    //        file2 = @"";
    
    [NSThread sleepForTimeInterval:2];
    
    if (loadMode.isCheckDiagsRoot && loadMode.diagsRoot.length) {
        
        [self terminalWithCmd:[NSString stringWithFormat:@"usbfs -f %@",loadMode.diagsRoot]];
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [NSThread sleepForTimeInterval:5];
//            NSDictionary *cmdList = [self getJsonDatasWithFileName:@"diagsRootCmds.json"];
//            if (![cmdList objectForKey:@"DutCommands"]) {
//                return;
//            }
//
           // NSArray *arr = [cmdList objectForKey:@"DutCommands"];
            
//            for (NSString *command in arr){
                NSMutableDictionary* dicCmd = [NSMutableDictionary dictionary];
                [dicCmd setValue:@"usbfs -e" forKey:kSendDUTCmd];
                NSLog(@"===>: %@",dicCmd);
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDUTCmd object
                                                                          :nil userInfo
                                                                          :dicCmd] ;
                [NSThread sleepForTimeInterval:0.2];
                
//            }
            
        });

            
            
        }
    
}



-(void)terminalWithCmd:(NSString *)cmd{
    
    
    NSTask * task = [[NSTask alloc]init];
    [task setLaunchPath:@"/bin/bash"];
    
    
    //        /usr/local/bin/mobile_restore -l 0x14640000 -D /Users/gdlocal/RestorePackage/DFU.pr --bundle /Users/gdlocal/RestorePackage/CurrentBundle/Restore --variant "Factory - DFU" -T Diags -b --server http://spidercab:8080 -I /Users/gdlocal/RestorePackage/CurrentBundle/Restore/Firmware/all_flash/iBootData.j523.DEVELOPMENT.im4p --timeout 30
    //
    //    NSString * cmd1 = [NSString stringWithFormat:@"/usr/local/bin/mobile_restore -l %@ -D %@ --bundle %@ --variant \"Factory - DFU\" -T Diags -b --server http://spidercab:8080 -I %@ --timeout 30",loadMode.usbArr,loadMode.prFile,loadMode.diagsBinary,loadMode.iBootFile];
    
    ///usr/local/bin/mobile_restore -l 0x14710000 -D /Users/gdlocal/Library/Application\ Support/PurpleRestore/DFU.pr --bundle /Users/gdlocal/RestorePackage/CurrentBundle/Restore --variant "Factory - DFU" -F /Users/gdlocal/Desktop/diags/diag-J523.im4p -b --server http://spidercab:8080 -I /Users/gdlocal/RestorePackage/CurrentBundle/Restore/Firmware/all_flash/iBootData.j523.DEVELOPMENT.im4p --timeout 30
    
//
//    NSString * cmd1 = [NSString stringWithFormat:@"/usr/local/bin/mobile_restore -l %@ -D %@ --bundle %@ --variant \"Factory - DFU\" -F %@ -b --server http://spidercab:8080 -I %@ --timeout 30",loadMode.usbArr,loadMode.prFile,loadMode.restoreFile,loadMode.diagsBinary,loadMode.iBootFile];
//
//
//    NSMutableString *cmd = [[NSMutableString alloc]initWithString:cmd1];
//    if (loadMode.isCheckDiagsRoot) {
//        [cmd appendString:[NSString stringWithFormat:@"\nusbfs -f %@",loadMode.diagsRoot]];
//    }
    NSArray * args = [NSArray arrayWithObjects:@"-c", cmd, nil];
    [task setArguments:args];
    NSPipe * readPipe = [NSPipe pipe];
    //NSFileHandle *readHandle = [readPipe fileHandleForReading];
    [task setStandardOutput:readPipe];
    [task setStandardError:readPipe];
    
    [task launch];
    
    NSMutableString * pstr = [[_textView textStorage] mutableString];
    [pstr appendFormat:@"%@\n",cmd];
    
    //
    [[task.standardOutput fileHandleForReading]setReadabilityHandler:^(NSFileHandle * file){
        NSMutableData * data = [[NSMutableData alloc] init];
        NSData * readData = [file availableData];
        NSString * strippedString;
        if ([readData length] > 0) {
            [data appendData:readData];
            strippedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableString * pstr = [[_textView textStorage] mutableString];
                [pstr appendFormat:@"%@\n",strippedString];
                NSRange range = NSMakeRange([pstr length]-1,0);
                [_textView scrollRangeToVisible:range];
            });
            
            //                [text appendString:strippedString];
            //                NSLog(@"%@",text);
        }
    }];
    
    [task waitUntilExit];
    
    
}


-(id)getJsonDatasWithFileName:(NSString *)file{
    
    NSString *configfile = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    // NSString *configfile = [[NSBundle mainBundle] pathForResource:@"Property List.plist" ofType:nil];
    
    //    NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
    //    NSString *eCodePath=[desktopPath stringByDeletingLastPathComponent];
    //    NSString *configfile=[eCodePath stringByAppendingPathComponent:@"pinList.json"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:configfile]) {
        
        return nil;
    }
    NSString* items = [NSString stringWithContentsOfFile:configfile encoding:NSUTF8StringEncoding error:nil];
    if (items.length<10) {
        return nil;
    }
    NSData *data= [items dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    return jsonObject;
}

@end
