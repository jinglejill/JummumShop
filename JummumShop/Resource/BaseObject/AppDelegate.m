//
//  AppDelegate.m
//  Eventoree
//
//  Created by Thidaporn Kijkamjai on 8/4/2560 BE.
//  Copyright © 2560 Appxelent. All rights reserved.
//

#import "AppDelegate.h"
#import "LogInViewController.h"
#import "CustomerKitchenViewController.h"
#import "OrderDetailViewController.h"
#import "HomeModel.h"
#import "Utility.h"
#import "PushSync.h"
#import "Receipt.h"
#import "SharedCurrentUserAccount.h"
#import <objc/runtime.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <UserNotifications/UserNotifications.h>


#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)



@interface AppDelegate (){
    HomeModel *_homeModel;
}
//printer part*******
@property (nonatomic, copy) NSString *portName;
@property (nonatomic, copy) NSString *portSettings;
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *macAddress;

@property (nonatomic) StarIoExtEmulation emulation;
@property (nonatomic) BOOL               cashDrawerOpenActiveHigh;
@property (nonatomic) NSInteger          allReceiptsSettings;
@property (nonatomic) NSInteger          selectedIndex;
@property (nonatomic) LanguageIndex      selectedLanguage;
@property (nonatomic) PaperSizeIndex     selectedPaperSize;

- (void)loadParam;
//*******
@end

extern BOOL globalRotateFromSeg;



@implementation AppDelegate
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (void)photoUploaded
{
    
}

void myExceptionHandler(NSException *exception)
{
    
    NSString *stackTrace = [[[exception callStackSymbols] valueForKey:@"description"] componentsJoinedByString:@"\\n"];
    stackTrace = [NSString stringWithFormat:@"%@,%@\\n%@\\n%@",[Utility modifiedUser],[Utility deviceToken],exception.reason,stackTrace];
//    NSLog(@"Stack Trace callStackSymbols: %@", stackTrace);
    
    [[NSUserDefaults standardUserDefaults] setValue:stackTrace forKey:@"exception"];
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //printer part*******
    [self loadParam];
    
    _selectedIndex     = 0;
    _selectedLanguage  = LanguageIndexEnglish;
    _selectedPaperSize = PaperSizeIndexThreeInch;
    //*******
    
    UIBarButtonItem *barButtonAppearance = [UIBarButtonItem appearance];
    [barButtonAppearance setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault]; // Change to your colour
    
    
    

    _homeModel = [[HomeModel alloc]init];
    _homeModel.delegate = self;
    
    
    globalRotateFromSeg = NO;
    
    // Override point for customization after application launch.
    NSString *strplistPath = [[NSBundle mainBundle] pathForResource:@"Property List" ofType:@"plist"];
    
    // read property list into memory as an NSData  object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:strplistPath];
    NSError *strerrorDesc = nil;
    NSPropertyListFormat plistFormat;
    
    // convert static property list into dictionary object
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&plistFormat error:&strerrorDesc];
    if (!temp)
    {
        NSLog(@"Error reading plist: %@, format: %lu", strerrorDesc, (unsigned long)plistFormat);
    }
    else
    {
        // assign values        
        [Utility setPingAddress:[temp objectForKey:@"PingAddress"]];
        [Utility setDomainName:[temp objectForKey:@"DomainName"]];
        [Utility setSubjectNoConnection:[temp objectForKey:@"SubjectNoConnection"]];
        [Utility setDetailNoConnection:[temp objectForKey:@"DetailNoConnection"]];
        [Utility setDetailNoConnection:[temp objectForKey:@"DetailNoConnection"]];
        [Utility setKey:[temp objectForKey:@"Key"]];
        
        
        
    }
    
    
    
    //write exception of latest app crash to log file
    NSSetUncaughtExceptionHandler(&myExceptionHandler);
    NSString *stackTrace = [[NSUserDefaults standardUserDefaults] stringForKey:@"exception"];
    if(!stackTrace)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"exception"];
    }
    else if(![stackTrace isEqualToString:@""])
    {
        [_homeModel insertItems:dbWriteLog withData:stackTrace actionScreen:@"Logging"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"exception"];
    }
    
    
    //push notification
    {
        if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0"))
        {
      
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
             {
                 if( !error )
                 {
                     [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                     NSLog( @"Push registration success." );
                 }
                 else
                 {
                     NSLog( @"Push registration FAILED" );
                     NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                     NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
                 }
             }];
            
            
            UNNotificationAction *notificationAction1 = [UNNotificationAction actionWithIdentifier:@"Print"
                                                                                             title:@"Print"
                                                                                           options:UNNotificationActionOptionForeground];
            UNNotificationAction *notificationAction2 = [UNNotificationAction actionWithIdentifier:@"View"
                                                                                             title:@"View"
                                                                                           options:UNNotificationActionOptionForeground];
            UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:@"Print"                                                                                                     actions:@[notificationAction1,notificationAction2] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];


            // Register the notification categories.
            UNUserNotificationCenter* center2 = [UNUserNotificationCenter currentNotificationCenter];
            center2.delegate = self;
            [center2 setNotificationCategories:[NSSet setWithObjects:notificationCategory,nil]];
            
        
        }
        else
        {
            UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [application registerUserNotificationSettings:settings];
            [application registerForRemoteNotifications];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        
        
        
        
        

    }
    
    
    //load shared at the begining of everyday
    NSDictionary *todayLoadShared = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"todayLoadShared"];
    NSString *strCurrentDate = [Utility dateToString:[Utility currentDateTime] toFormat:@"yyyy-MM-dd"];
    NSString *alreadyLoaded = [todayLoadShared objectForKey:strCurrentDate];
    if(!alreadyLoaded)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObject:@"1" forKey:strCurrentDate] forKey:@"todayLoadShared"];
    }
    
    
    #if (TARGET_OS_SIMULATOR)
        NSString *token = @"simulator";
        [[NSUserDefaults standardUserDefaults] setValue:token forKey:TOKEN];
    #endif


    //facebook
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    
    return YES;
}

#ifdef __IPHONE_9_0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options {

    [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];

    return YES;
}
#else
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];

    return YES;
}
#endif


-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //Called when a notification is delivered to a foreground app.
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"notification is delivered to a foreground app: %@", userInfo);
    
    
    NSDictionary *myAps = [userInfo objectForKey:@"aps"];
    NSString *categoryIdentifier = [myAps objectForKey:@"category"];
    if([categoryIdentifier isEqualToString:@"cancelOrder"])
    {
        NSNumber *receiptID = [myAps objectForKey:@"receiptID"];
        _homeModel = [[HomeModel alloc]init];
        _homeModel.delegate = self;
        [_homeModel downloadItems:dbJummumReceiptUpdate withData:receiptID];
    }
    else if([categoryIdentifier isEqualToString:@"printKitchenBill"])
    {
        NSNumber *receiptID = [myAps objectForKey:@"receiptID"];
        [_homeModel downloadItems:dbJummumReceipt withData:receiptID];
    }
}


-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    //Called to let your app know which action was selected by the user for a given notification.
    
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSDictionary *myAps = [userInfo objectForKey:@"aps"];
    NSString *categoryIdentifier = [myAps objectForKey:@"category"];
    if([categoryIdentifier isEqualToString:@"printKitchenBill"])
    {
        if([response.actionIdentifier isEqualToString:@"Print"])
        {
            NSNumber *receiptID = [myAps objectForKey:@"receiptID"];
            _homeModel = [[HomeModel alloc]init];
            _homeModel.delegate = self;
            [_homeModel downloadItems:dbJummumReceiptPrint withData:receiptID];
            return;
        }
    }
    
    if([categoryIdentifier isEqualToString:@"cancelOrder"])//for all update receipt status when cancel or dispute order
    {
        NSNumber *receiptID = [myAps objectForKey:@"receiptID"];
        _homeModel = [[HomeModel alloc]init];
        _homeModel.delegate = self;
        [_homeModel downloadItems:dbJummumReceiptUpdate withData:receiptID];
    }
    else if([categoryIdentifier isEqualToString:@"printKitchenBill"])//for after paid for order
    {
        NSNumber *receiptID = [myAps objectForKey:@"receiptID"];
        [_homeModel downloadItems:dbJummumReceipt withData:receiptID];
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"token---%@", token);
    
    
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //    NSLog([error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if(application.applicationState == UIApplicationStateInactive) {
        
        NSLog(@"Inactive");
        
        //Show the view with the content of the push
        
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else if (application.applicationState == UIApplicationStateBackground) {
        
        NSLog(@"Background");
        
        //Refresh the local model
        
        completionHandler(UIBackgroundFetchResultNewData);
        

        NSLog(@"Received notification: %@", userInfo);
        
        
        
        
        NSDictionary *myAps = [userInfo objectForKey:@"aps"];
        NSString *categoryIdentifier = [myAps objectForKey:@"category"];
        if([categoryIdentifier isEqualToString:@"cancelOrder"])//for all update receipt status when cancel or dispute order
        {
            NSNumber *receiptID = [myAps objectForKey:@"receiptID"];
            _homeModel = [[HomeModel alloc]init];
            _homeModel.delegate = self;
            [_homeModel downloadItems:dbJummumReceiptUpdate withData:receiptID];
        }
        else if([categoryIdentifier isEqualToString:@"printKitchenBill"])//for after paid for order
        {
            NSNumber *receiptID = [myAps objectForKey:@"receiptID"];
            [_homeModel downloadItems:dbJummumReceipt withData:receiptID];
        }
        
    } else {
        
        NSLog(@"Active");
        
        //Show an in-app banner
        
        completionHandler(UIBackgroundFetchResultNewData);
        
        
        NSDictionary *myAps = [userInfo objectForKey:@"aps"];
        NSString *categoryIdentifier = [myAps objectForKey:@"category"];
        if([categoryIdentifier isEqualToString:@"cancelOrder"])//for all update receipt status when cancel or dispute order
        {
            NSNumber *receiptID = [myAps objectForKey:@"receiptID"];
            _homeModel = [[HomeModel alloc]init];
            _homeModel.delegate = self;
            [_homeModel downloadItems:dbJummumReceiptUpdate withData:receiptID];
        }
        else if([categoryIdentifier isEqualToString:@"printKitchenBill"])//for after paid for order
        {
            NSNumber *receiptID = [myAps objectForKey:@"receiptID"];
            [_homeModel downloadItems:dbJummumReceipt withData:receiptID];
        }
    }
}

- (void)itemsUpdated
{
    
}

- (void)itemsInserted
{
    
}

- (void)itemsDeleted
{
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)itemsDownloaded:(NSArray *)items
{
    if(_homeModel.propCurrentDB == dbMaster)
    {
        [Utility itemsDownloaded:items];
        {
            SEL s = NSSelectorFromString(@"loadViewProcess");
            [self.vc performSelector:s];
        }
        {
            SEL s = NSSelectorFromString(@"removeOverlayViews");
            [self.vc performSelector:s];
        }
    }
    else if(_homeModel.propCurrentDB == dbJummumReceipt)
    {
        for(NSArray *itemList in items)
        {
            for(NSObject *object in itemList)
            {
                [Utility addObjectIfNotDuplicate:object];
            }
        }
        
    
        if([self.vc isKindOfClass:[CustomerKitchenViewController class]])
        {
            CustomerKitchenViewController *vc = (CustomerKitchenViewController *)self.vc;
            [vc reloadTableView];
        }
        else if([self.vc isKindOfClass:[OrderDetailViewController class]])
        {
            OrderDetailViewController *vc = (OrderDetailViewController *)self.vc;
            [vc.tbvData reloadData];
        }
    }
    else if(_homeModel.propCurrentDB == dbJummumReceiptPrint)
    {
        for(NSArray *itemList in items)
        {
            for(NSObject *object in itemList)
            {
                [Utility addObjectIfNotDuplicate:object];
            }
        }
        
        
        Receipt *receipt = items[0][0];
        if([self.vc isKindOfClass:[CustomerKitchenViewController class]])
        {
            CustomerKitchenViewController *vc = (CustomerKitchenViewController *)self.vc;
            [vc reloadTableView];
            
            
            //************Print kitchen bill
            NSMutableArray *receiptListPrint = [[NSMutableArray alloc]init];
            [receiptListPrint addObject:receipt];
            [vc printReceiptKitchenBill:receiptListPrint];
            //************
        }
        else if([self.vc isKindOfClass:[OrderDetailViewController class]])
        {
            OrderDetailViewController *vc = (OrderDetailViewController *)self.vc;
            [vc.tbvData reloadData];
        }
    }
    else if(_homeModel.propCurrentDB == dbJummumReceiptUpdate)
    {
        NSMutableArray *receiptList = items[0];
        NSMutableArray *disputeList = items[3];
        if([disputeList count] > 0)
        {
            NSMutableArray *dataList = [[NSMutableArray alloc]init];
            [dataList addObject:disputeList];
            [Utility addToSharedDataList:dataList];
        }
        if([receiptList count] > 0)
        {
            Receipt *receipt = receiptList[0];
            [Receipt updateStatus:receipt];
            
            
            if([self.vc isMemberOfClass:[CustomerKitchenViewController class]])
            {
                CustomerKitchenViewController *vc = (CustomerKitchenViewController *)self.vc;
                [vc reloadTableView];
            }
            else if([self.vc isMemberOfClass:[OrderDetailViewController class]])
            {
                OrderDetailViewController *vc = (OrderDetailViewController *)self.vc;
                [vc.tbvData reloadData];
            }
        }
        
    }
}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        SEL s = NSSelectorFromString(@"loadingOverlayView");
                                        [self.vc performSelector:s];
                                        [_homeModel downloadItems:dbMaster];
                                    }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self.vc presentViewController:alert animated:YES completion:nil];
    });
}

- (void) connectionFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility subjectNoConnection]
                                                                   message:[Utility detailNoConnection]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //                                                              exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self.vc presentViewController:alert animated:YES completion:nil];
    } );
}

//printer part******
- (void)loadParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults registerDefaults:[NSDictionary dictionaryWithObject:@""                           forKey:@"portName"]];
    [userDefaults registerDefaults:[NSDictionary dictionaryWithObject:@""                           forKey:@"portSettings"]];
    [userDefaults registerDefaults:[NSDictionary dictionaryWithObject:@""                           forKey:@"modelName"]];
    [userDefaults registerDefaults:[NSDictionary dictionaryWithObject:@""                           forKey:@"macAddress"]];
    [userDefaults registerDefaults:[NSDictionary dictionaryWithObject:@(StarIoExtEmulationStarPRNT) forKey:@"emulation"]];
    [userDefaults registerDefaults:[NSDictionary dictionaryWithObject:@YES                          forKey:@"cashDrawerOpenActiveHigh"]];
    [userDefaults registerDefaults:[NSDictionary dictionaryWithObject:@0x00000007                   forKey:@"allReceiptsSettings"]];
    
    _portName                 = [userDefaults stringForKey :@"portName"];
    _portSettings             = [userDefaults stringForKey :@"portSettings"];
    _modelName                = [userDefaults stringForKey :@"modelName"];
    _macAddress               = [userDefaults stringForKey :@"macAddress"];
    _emulation                = [userDefaults integerForKey:@"emulation"];
    _cashDrawerOpenActiveHigh = [userDefaults boolForKey   :@"cashDrawerOpenActiveHigh"];
    _allReceiptsSettings      = [userDefaults integerForKey:@"allReceiptsSettings"];
}

+ (NSString *)getPortName {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return delegate.portName;
}

+ (void)setPortName:(NSString *)portName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    delegate.portName = portName;
    
    [userDefaults setObject:delegate.portName forKey:@"portName"];
    
    [userDefaults synchronize];
}

+ (NSString*)getPortSettings {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return delegate.portSettings;
}

+ (void)setPortSettings:(NSString *)portSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    delegate.portSettings = portSettings;
    
    [userDefaults setObject :delegate.portSettings forKey:@"portSettings"];
    
    [userDefaults synchronize];
}

+ (NSString *)getModelName {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return delegate.modelName;
}

+ (void)setModelName:(NSString *)modelName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    delegate.modelName = modelName;
    
    [userDefaults setObject:delegate.modelName forKey:@"modelName"];
    
    [userDefaults synchronize];
}

+ (NSString *)getMacAddress {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return delegate.macAddress;
}

+ (void)setMacAddress:(NSString *)macAddress {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    delegate.macAddress = macAddress;
    
    [userDefaults setObject:delegate.macAddress forKey:@"macAddress"];
    
    [userDefaults synchronize];
}

+ (StarIoExtEmulation)getEmulation {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return delegate.emulation;
}

+ (void)setEmulation:(StarIoExtEmulation)emulation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    delegate.emulation = emulation;
    
    [userDefaults setInteger:delegate.emulation forKey:@"emulation"];
    
    [userDefaults synchronize];
}

+ (BOOL)getCashDrawerOpenActiveHigh {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return delegate.cashDrawerOpenActiveHigh;
}

+ (void)setCashDrawerOpenActiveHigh:(BOOL)activeHigh {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    delegate.cashDrawerOpenActiveHigh = activeHigh;
    
    [userDefaults setInteger:delegate.cashDrawerOpenActiveHigh forKey:@"cashDrawerOpenActiveHigh"];
    
    [userDefaults synchronize];
}

+ (NSInteger)getAllReceiptsSettings {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return delegate.allReceiptsSettings;
}

+ (void)setAllReceiptsSettings:(NSInteger)allReceiptsSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    delegate.allReceiptsSettings = allReceiptsSettings;
    
    [userDefaults setInteger:delegate.allReceiptsSettings forKey:@"allReceiptsSettings"];
    
    [userDefaults synchronize];
}

+ (NSInteger)getSelectedIndex {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return delegate.selectedIndex;
}

+ (void)setSelectedIndex:(NSInteger)index {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    delegate.selectedIndex = index;
}

+ (LanguageIndex)getSelectedLanguage {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return delegate.selectedLanguage;
}

+ (void)setSelectedLanguage:(LanguageIndex)index {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    delegate.selectedLanguage = index;
}

+ (PaperSizeIndex)getSelectedPaperSize {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    return delegate.selectedPaperSize;
}

+ (void)setSelectedPaperSize:(PaperSizeIndex)index {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    delegate.selectedPaperSize = index;
}
@end
