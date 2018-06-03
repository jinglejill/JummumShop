//
//  DisputeFormViewController.h
//  Jummum2
//
//  Created by Thidaporn Kijkamjai on 12/5/2561 BE.
//  Copyright © 2561 Appxelent. All rights reserved.
//

#import "CustomViewController.h"
#import "Receipt.h"


@interface DisputeFormViewController : CustomViewController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
@property (strong, nonatomic) IBOutlet UITableView *tbvAction;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerVw;



@property (nonatomic) NSInteger fromType;
@property (nonatomic) Receipt *receipt;
- (IBAction)goBack:(id)sender;
@end
