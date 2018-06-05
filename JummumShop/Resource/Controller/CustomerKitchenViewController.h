//
//  CustomerKitchenViewController.h
//  FFD
//
//  Created by Thidaporn Kijkamjai on 15/3/2561 BE.
//  Copyright © 2561 Appxelent. All rights reserved.
//

#import "CustomViewController.h"
#import "CredentialsDb.h"


@interface CustomerKitchenViewController : CustomViewController<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
- (IBAction)goBack:(id)sender;
- (IBAction)doAction:(id)sender;
- (IBAction)selectList:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnAction;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
@property (strong, nonatomic) CredentialsDb *credentialsDb;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segConPrintStatus;
@property (strong, nonatomic) IBOutlet UIButton *btnConnectPrinter;
@property (strong, nonatomic) IBOutlet UIImageView *imgPrinterStaus;
@property (strong, nonatomic) IBOutlet UIButton *btnBadge;
@property (strong, nonatomic) IBOutlet UIButton *btnSelect;


-(IBAction)unwindToCustomerKitchen:(UIStoryboardSegue *)segue;
- (IBAction)printStatusChanged:(id)sender;
- (IBAction)connectPrinter:(id)sender;
-(void)setReceiptList;

@end
