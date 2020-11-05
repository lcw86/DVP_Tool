//
//  MobileRestoreWin.m
//  DUT_Tool
//
//  Created by ciwei luo on 2020/8/20.
//  Copyright © 2020 ___Intelligent Automation___. All rights reserved.
//

#import "MobileRestoreWin.h"
#import "GraphicHeader.h"
#import "MobileRestoreVC.h"
#import "LoadVC.h"
@interface MobileRestoreWin ()<LoadVCDelegate>
//@property (nonatomic,strong)LoadWinC *loadWinC;
@end

@implementation MobileRestoreWin
//{
//    NSString *file1;
//    NSString *file2;
//}

- (void)windowDidLoad {
    [super windowDidLoad];
    
//    self.loadWinC = [[LoadWinC alloc]init];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
//    self.contentViewController = [[MobileRestoreVC alloc]init];
    LoadVC *loadVC = [[LoadVC alloc]init];
    loadVC.loadVCDelegate = self;
    loadVC.parentVC = self;
    self.contentViewController = loadVC;
      
}
-(void)commutionWithMainLine:(NSString *)notificationName
{
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
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dic deliverImmediately:YES];
    }
}
-(void)openSelectGroupApp
{
    
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    path = [NSString stringWithFormat:@"%@/SelectGroup.app",path];
    NSLog(@"===:::>>path : %@",path);
    [[NSWorkspace sharedWorkspace] launchApplication:path];
    
}
-(void)LoadVCApplyClickWithLoadMode:(LoadMode *)loadMode{
    NSString *prFileload = loadMode.prFile;
    NSString *restoreFile = loadMode.restoreFile ;
    NSString *diagsBinary = loadMode.diagsBinary;
    NSString *iBootFile = loadMode.iBootFile;
    NSString *usb = loadMode.usbArr;
    NSString *state = loadMode.isCheckDiagsRoot;
    NSString *diagsRoot = loadMode.diagsRoot;
    NSDictionary *dict = [self getJsonDatasWithFileName:@"restore.json"];
    NSString *filePath = dict[@"restoreFilePath"];
    NSString *notificationName = dict[@"notificationName"];
    
    NSString *content = [NSString stringWithFormat:@"click apply\n%@\n%@\n%@\n%@\n%@\n%@\n%@",prFileload,restoreFile,diagsBinary,iBootFile,state,diagsRoot,usb];
    
    [self cw_fileHandleWriteToFile:filePath content:content];
    
//    [self commutionWithMainLine:notificationName];
    
    [self openSelectGroupApp];

    
}

-(void)LoadVCEnterDiagsClickWithLoadMode:(LoadMode *)loadMode{
    NSString *prFileload = loadMode.prFile;
    NSString *restoreFile = loadMode.restoreFile ;
    NSString *diagsBinary = loadMode.diagsBinary;
    NSString *iBootFile = loadMode.iBootFile;
    NSString *usb = loadMode.usbArr;
    NSString *state = loadMode.isCheckDiagsRoot;
    NSString *diagsRoot = loadMode.diagsRoot;
    NSDictionary *dict = [self getJsonDatasWithFileName:@"restore.json"];
    NSString *filePath = dict[@"restoreFilePath"];
    NSString *notificationName = dict[@"notificationName"];
    
    NSString *content = [NSString stringWithFormat:@"click apply\n%@\n%@\n%@\n%@\n%@\n%@\n%@",prFileload,restoreFile,diagsBinary,iBootFile,state,diagsRoot,usb];
    
    [self cw_fileHandleWriteToFile:filePath content:content];
    
    
    NSString *fileCSV = [[NSBundle mainBundle] pathForResource:@"ChooseScript" ofType:@"plist"];
    NSMutableDictionary *listCsvName = [[NSMutableDictionary alloc]init];
    [listCsvName removeAllObjects];
    [listCsvName setDictionary:[NSDictionary dictionaryWithContentsOfFile:fileCSV]];
    if ([listCsvName valueForKey:@"MobileRestoreEnterDiags_TEST"])
    {
        // [self m_btnButtonDisable];
        NSString *csvName = [listCsvName valueForKey:@"MobileRestoreEnterDiags_TEST"];
        NSLog(@"%@",csvName);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             csvName,@"Load_Profile_Debug",nil];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
    }
    
}


-(BOOL)cw_fileHandleWriteToFile:(NSString *)filePath content:(NSString *)content
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
  
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        
    }
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
//    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
//
//    [fh seekToEndOfFile];
//    [fh writeData:[[NSString stringWithFormat:@"%@\n",content]  dataUsingEncoding:NSUTF8StringEncoding]];
//    [fh closeFile];
    return YES;
}

-(id)getJsonDatasWithFileName:(NSString *)file{
    
    NSString *configfile = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    // NSString *configfile = [[NSBundle mainBundle] pathForResource:@"Property List.plist" ofType:nil];
    
    //    NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)lastObject];
    //    NSString *eCodePath=[desktopPath stringByDeletingLastPathComponent];
    //    NSString *configfile=[eCodePath stringByAppendingPathComponent:@"pinList.json"];
    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:configfile]) {
//        [MyEexception RemindException:@"check fail" Information:@"not found file"];
//        [NSApp terminate:nil];
//
//    }
    NSString* items = [NSString stringWithContentsOfFile:configfile encoding:NSUTF8StringEncoding error:nil];
    if (items.length<10) {
        return nil;
    }
    NSData *data= [items dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//    effDict = jsonObject;
    return jsonObject;
}

//-(void)awakeFromNib
//{

//    MRestoreWin.backgroundColor = [NSColor whiteColor];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector
//                                                     :@selector(getGGValue:) name
//                                                     :kNotificationGGValue object
//                                                     :nil] ;
    
//}


//- (IBAction)non_diagClick:(NSButton *)btn {
//    NSString *fileCSV = [[NSBundle mainBundle] pathForResource:@"ChooseScript" ofType:@"plist"];
//    NSMutableDictionary *listCsvName = [[NSMutableDictionary alloc]init];
//    [listCsvName removeAllObjects];
//    [listCsvName setDictionary:[NSDictionary dictionaryWithContentsOfFile:fileCSV]];
//    if ([listCsvName valueForKey:@"MobileRestoreNonDiags_TEST"])
//    {
//        // [self m_btnButtonDisable];
//        NSString *csvName = [listCsvName valueForKey:@"MobileRestoreNonDiags_TEST"];
//        NSLog(@"%@",csvName);
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
//                             csvName,@"Load_Profile_Debug",nil];
//        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
//    }
//}
//
//- (IBAction)restoreClick:(NSButton *)btn {
//   // self p
//  
//    
//    if( ![_loadWinC.window isVisible])
//    {
//        _loadWinC=[[LoadWinC alloc]initWithWindowNibName:@"LoadWinC"];
//        [_loadWinC.window orderFront:nil];
//    }
//    
//}
//
//
//- (IBAction)runFctClick:(NSButton *)btn {
//    NSString *fileCSV = [[NSBundle mainBundle] pathForResource:@"ChooseScript" ofType:@"plist"];
//    NSMutableDictionary *listCsvName = [[NSMutableDictionary alloc]init];
//    [listCsvName removeAllObjects];
//    [listCsvName setDictionary:[NSDictionary dictionaryWithContentsOfFile:fileCSV]];
//    if ([listCsvName valueForKey:@"MobileRestoreFCT_TEST"])
//    {
//        // [self m_btnButtonDisable];
//        NSString *csvName = [listCsvName valueForKey:@"MobileRestoreFCT_TEST"];
//        NSLog(@"%@",csvName);
//        
//        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
//                             csvName,@"Load_Profile_Debug",nil];
//        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kNotificationOnLoadProfile object:nil userInfo:dic deliverImmediately:YES];
//    }
//}
//
//- (IBAction)closeClick:(NSButton *)btn {
//    [MRestoreWin close];
//}
//- (IBAction)clearClick:(NSButton *)btn {
//    [textView setString:@""];
//}
//
//
//-(void)GGWinClose
//{
//    [MRestoreWin close];
//    [super dealloc];
//}
//
//-(void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [super dealloc];
//}
//
//-(void)getGGValue:(NSNotification *)nf
//{
//    NSDictionary *dic = [nf userInfo];
//    NSString *val = [dic objectForKey:@"KEY_GG"];
//    [self OnLog:val];
//    
//}
//
//-(void)OnLog:(NSString *)str
//{
//    if (!str) return;
//    NSMutableString * pstr = [[textView textStorage] mutableString];
//    if ([str containsString:@"\n"])
//    {
//        [pstr appendFormat:@"%@",str];
//    }
//    else
//    {
//        [pstr appendFormat:@"%@\n",str];
//    }
//    NSRange range = NSMakeRange([pstr length]-1,0);
//    [textView scrollRangeToVisible:range];
//}

@end
