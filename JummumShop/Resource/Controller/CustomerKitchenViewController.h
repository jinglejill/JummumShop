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
- (IBAction)doAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnAction;

@property (strong, nonatomic) IBOutlet UITableView *tbvData;
@property (strong, nonatomic) CredentialsDb *credentialsDb;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segConPrintStatus;
@property (strong, nonatomic) IBOutlet UIImageView *imgBadge;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imgBadgeTrailing;
@property (strong, nonatomic) IBOutlet UIImageView *imgBadgeNew;
@property (strong, nonatomic) IBOutlet UIImageView *imgBadgeProcessing;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imgBadgeLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imgBadgeProcessingLeading;


-(IBAction)unwindToCustomerKitchen:(UIStoryboardSegue *)segue;
- (IBAction)printStatusChanged:(id)sender;
-(void)setReceiptList;
-(void)reloadTableView;



//- (IBAction)selectList:(id)sender;
//- (IBAction)goBack:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIButton *btnSelect;
@property (strong, nonatomic) IBOutlet UIButton *btnConnectPrinter;
@property (strong, nonatomic) IBOutlet UIImageView *imgPrinterStaus;

//- (IBAction)connectPrinter:(id)sender;

@end
