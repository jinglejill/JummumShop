//
//  CreditCardViewController.h
//  Jummum
//
//  Created by Thidaporn Kijkamjai on 4/4/2561 BE.
//  Copyright © 2561 Appxelent. All rights reserved.
//

#import "CustomViewController.h"

@interface CreditCardViewController : CustomViewController<UITableViewDelegate,UITableViewDataSource>
- (IBAction)goBack:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tbvData;

@end
