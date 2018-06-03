//
//  CreditCardAndOrderSummaryViewController.m
//  Jummum
//
//  Created by Thidaporn Kijkamjai on 9/3/2561 BE.
//  Copyright © 2561 Appxelent. All rights reserved.
//

#import "CreditCardAndOrderSummaryViewController.h"
#import "SaveToCameraRollViewController.h"
#import "SelectPaymentMethodViewController.h"
#import "QRCodeScanTableViewController.h"
#import "CustomerTableSearchViewController.h"
#import "CustomTableViewCellCreditCard.h"
#import "CustomTableViewCellImageLabelRemove.h"
#import "CustomTableViewCellOrderSummary.h"
#import "CustomTableViewCellTotal.h"
#import "CustomTableViewCellVoucherCode.h"
#import "CustomTableViewHeaderFooterButton.h"
#import "CustomTableViewCellLabelLabel.h"
#import "CreditCard.h"
#import "SharedCurrentUserAccount.h"
#import "Menu.h"
#import "Receipt.h"
#import "OrderTaking.h"
#import "OrderNote.h"
#import "OmiseSDK.h"
#import "JummumShop-Swift.h"
#import "UserAccount.h"
#import "PromotionMenu.h"
#import "Promotion.h"
#import "UserPromotionUsed.h"
#import "Setting.h"
#import "MenuType.h"
#import "Message.h"
#import "RewardRedemption.h"
#import "UserRewardRedemptionUsed.h"


@interface CreditCardAndOrderSummaryViewController ()
{
    CreditCard *_creditCard;
    NSMutableArray *_orderTakingList;
    NSString *_voucherCode;
    
    float _netTotal;
    float _serviceChargeValue;
    float _vatValue;
    Promotion *_promotionUsed;
    float _discountValue;
    NSInteger _discountType;
    float _discountAmount;
    NSInteger _promotionOrRewardRedemption;//1=promotion,2=rewardRedemption
    Receipt *_receipt;
    
}
@end

@implementation CreditCardAndOrderSummaryViewController
static NSString * const reuseIdentifierCredit = @"CustomTableViewCellCreditCard";
static NSString * const reuseIdentifierImageLabelRemove = @"CustomTableViewCellImageLabelRemove";
static NSString * const reuseIdentifierOrderSummary = @"CustomTableViewCellOrderSummary";
static NSString * const reuseIdentifierTotal = @"CustomTableViewCellTotal";
static NSString * const reuseIdentifierVoucherCode = @"CustomTableViewCellVoucherCode";
static NSString * const reuseIdentifierHeaderFooterButton = @"CustomTableViewHeaderFooterButton";
static NSString * const reuseIdentifierLabelLabel = @"CustomTableViewCellLabelLabel";



@synthesize tbvData;
@synthesize voucherView;
@synthesize branch;
@synthesize customerTable;
@synthesize vwTopBorderPay;
@synthesize tbvTotal;
@synthesize tbvTotalHeightConstant;
@synthesize fromReceiptSummaryMenu;


-(IBAction)unwindToCreditCardAndOrderSummary:(UIStoryboardSegue *)segue
{
    if([segue.sourceViewController isMemberOfClass:[SelectPaymentMethodViewController class]])
    {
        SelectPaymentMethodViewController *vc = segue.sourceViewController;
        _creditCard = vc.creditCard;
        if(_creditCard.primaryCard)
        {
            _creditCard.saveCard = 1;
        }
        [tbvData reloadData];
    }
    else if([segue.sourceViewController isMemberOfClass:[CustomerTableSearchViewController class]])
    {
        CustomerTableSearchViewController *vc = segue.sourceViewController;
        customerTable = vc.customerTable;
        [tbvData reloadData];
    }
    else if([segue.sourceViewController isMemberOfClass:[QRCodeScanTableViewController class]])
    {
        QRCodeScanTableViewController *vc = segue.sourceViewController;
        customerTable = vc.customerTable;
        [tbvData reloadData];
    }
}

- (IBAction)goBack:(id)sender
{
    if(fromReceiptSummaryMenu)
    {
        [self performSegueWithIdentifier:@"segUnwindToBranchSearch" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"segUnwindToBasket" sender:self];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect toView:nil];
    
    CGSize kbSize = kbRect.size;
    
    
    
    // Assign new frame to your view
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         [self.view setFrame:CGRectMake(0,kbSize.height*-1,self.view.frame.size.width,self.view.frame.size.height)]; //here taken -110 for example i.e. your view will be scrolled to -110. change its value according to your requirement.
                     }
                     completion:nil
     ];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
                         [self.view layoutSubviews];
                     }
                     completion:nil
     ];
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag == 31)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField.tag == 31)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
        [self.view endEditing:YES];
        
        return YES;
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == 31)
    {

    }
    else
    {
        UIView *vwInvalid = [self.view viewWithTag:textField.tag+10];
        vwInvalid.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case 1:
        {
            _creditCard.firstName = [Utility trimString:textField.text];
        }
        break;
        case 2:
        {
            _creditCard.lastName = [Utility trimString:textField.text];
        }
        break;
        case 3:
        {
            _creditCard.creditCardNo = [Utility removeSpace:[Utility trimString:textField.text]];
        }
        break;
        case 4:
        {
            _creditCard.month = [textField.text integerValue];
        }
        break;
        case 5:
        {
            _creditCard.year = [textField.text integerValue];
        }
        break;
        case 6:
        {
            _creditCard.ccv = [Utility trimString:textField.text];
        }
        break;
        case 31:
        {
            _voucherCode = [Utility trimString:textField.text];
        }
            break;
        default:
        break;
    }    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    NSLog(@"self.view: %f,%f,%f,%f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
}

-(void)loadView
{
    [super loadView];
    
    
    _promotionOrRewardRedemption = 1;
    NSMutableArray *orderTakingList = [OrderTaking getCurrentOrderTakingList];
    _orderTakingList = [OrderTaking createSumUpOrderTakingWithTheSameMenuAndNote:orderTakingList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    
    
    
    UserAccount *userAccount = [UserAccount getCurrentUserAccount];
    NSMutableDictionary *dicCreditCard = [[[NSUserDefaults standardUserDefaults] objectForKey:@"creditCard"] mutableCopy];
    if(dicCreditCard)
    {
        NSMutableArray *creditCardList = [dicCreditCard objectForKey:userAccount.username];
        if(creditCardList && [creditCardList count] > 0)
        {
            _creditCard = [CreditCard getPrimaryCard:creditCardList];
        }
        else
        {
            _creditCard = [[CreditCard alloc]init];
        }        
    }
    else
    {
        _creditCard = [[CreditCard alloc]init];
    }

    
    
    tbvData.delegate = self;
    tbvData.dataSource = self;
    tbvTotal.delegate = self;
    tbvTotal.dataSource = self;
    [tbvTotal setSeparatorColor:[UIColor clearColor]];
    tbvTotal.scrollEnabled = NO;
    

    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierCredit bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierCredit];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierImageLabelRemove bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierImageLabelRemove];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierOrderSummary bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierOrderSummary];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierLabelLabel bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierLabelLabel];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierTotal bundle:nil];
        [tbvTotal registerNib:nib forCellReuseIdentifier:reuseIdentifierTotal];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierHeaderFooterButton bundle:nil];
        [tbvTotal registerNib:nib forHeaderFooterViewReuseIdentifier:reuseIdentifierHeaderFooterButton];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierVoucherCode bundle:nil];
        [tbvTotal registerNib:nib forCellReuseIdentifier:reuseIdentifierVoucherCode];
    }
    
    

    
    [[NSBundle mainBundle] loadNibNamed:@"CustomViewVoucher" owner:self options:nil];
    [voucherView.btnDelete addTarget:self action:@selector(deleteVoucher:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
}

///tableview section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if([tableView isEqual:tbvData])
    {
//        return 2;
        return 3;
    }
    else if([tableView isEqual:tbvTotal])
    {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if([tableView isEqual:tbvData])
    {
        if(section == 0)
        {
            return 1;
        }
        else if(section == 1)
        {
            NSInteger selectCreditCard = 0;//has card saved
            UserAccount *userAccount = [UserAccount getCurrentUserAccount];
            NSMutableDictionary *dicCreditCard = [[[NSUserDefaults standardUserDefaults] objectForKey:@"creditCard"] mutableCopy];
            if(dicCreditCard)
            {
                NSMutableArray *creditCardList = [dicCreditCard objectForKey:userAccount.username];
                if(creditCardList && [creditCardList count] > 0)
                {
                    selectCreditCard = 1;
                }
            }
            
            if(!_creditCard.primaryCard && selectCreditCard)
            {
                return 3;
            }
            
            return 2;
        }
        else
        {
            return [_orderTakingList count]+1;
        }
    }
    else if([tableView isEqual:tbvTotal])
    {
        tbvTotalHeightConstant.constant = branch.serviceChargePercent > 0?230:204;
        return branch.serviceChargePercent > 0?6:5;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    
    if([tableView isEqual:tbvData])
    {
        if(section == 0)
        {
            CustomTableViewCellLabelLabel *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierLabelLabel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.lblText.text = branch.name;
            cell.lblText.font = [UIFont boldSystemFontOfSize:15];
            [cell.lblText sizeToFit];
            
            
            cell.lblTextWidthConstant.constant = cell.lblText.frame.size.width;
            if(customerTable)
            {
                cell.lblValue.text = [NSString stringWithFormat:@"เลขโต๊ะ: %@",customerTable.tableName];
                cell.lblValue.textColor = mGreen;
            }
            else
            {
                cell.lblValue.text = @"เลือกโต๊ะ";
                cell.lblValue.textColor = mRed;
            }
            
            
            return  cell;
        }
        else if(section == 1)
        {
            switch (item)
            {
                case 0:
                {
                    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"cell"];
                    if (!cell) {
                        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                    }
                    
                    
                    cell.textLabel.text = @"การชำระเงิน";
                    cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
                    
                    return cell;
                }
                    break;
                case 1:
                {
                    if(!_creditCard.primaryCard)
                    {
                        CustomTableViewCellCreditCard *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierCredit];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.txtFirstNameWidthConstant.constant = (cell.frame.size.width-16*3)/2;
                        cell.txtMonthWidthConstant.constant = (cell.frame.size.width-16*3)/2;
                        
                        
                        cell.txtFirstName.tag = 1;
                        cell.txtLastName.tag = 2;
                        cell.txtCardNo.tag = 3;
                        cell.txtMonth.tag = 4;
                        cell.txtYear.tag = 5;
                        cell.txtCCV.tag = 6;
                        cell.vwFirstName.tag = 11;
                        cell.vwLastName.tag = 12;
                        cell.vwCardNo.tag = 13;
                        cell.vwMonth.tag = 14;
                        cell.vwYear.tag = 15;
                        cell.vwCCV.tag = 16;
                        cell.imgCreditCardBrand.tag = 21;
                        
                        
                        cell.txtFirstName.delegate = self;
                        cell.txtLastName.delegate = self;
                        cell.txtCardNo.delegate = self;
                        cell.txtMonth.delegate = self;
                        cell.txtYear.delegate = self;
                        cell.txtCCV.delegate = self;
                        
                        
                        cell.vwFirstName.backgroundColor = [UIColor groupTableViewBackgroundColor];
                        cell.vwLastName.backgroundColor = [UIColor groupTableViewBackgroundColor];
                        cell.vwCardNo.backgroundColor = [UIColor groupTableViewBackgroundColor];
                        cell.vwMonth.backgroundColor = [UIColor groupTableViewBackgroundColor];
                        cell.vwYear.backgroundColor = [UIColor groupTableViewBackgroundColor];
                        cell.vwCCV.backgroundColor = [UIColor groupTableViewBackgroundColor];
                        
                        
                        cell.txtFirstName.text = _creditCard.firstName;
                        cell.txtLastName.text = _creditCard.lastName;
                        cell.txtCardNo.text = _creditCard.creditCardNo;
                        cell.txtMonth.text = _creditCard.month == 0?@"":[NSString stringWithFormat:@"%02ld",_creditCard.month];
                        cell.txtYear.text = _creditCard.year == 0?@"":[NSString stringWithFormat:@"%02ld",_creditCard.year];;
                        cell.txtCCV.text = _creditCard.ccv;
                        
                        
                        cell.swtSave.on = _creditCard.saveCard;
                        [cell.swtSave addTarget:self action:@selector(swtSaveDidChange:) forControlEvents:UIControlEventValueChanged];
                        [cell.txtCardNo addTarget:self action:@selector(txtCardNoDidChange:) forControlEvents:UIControlEventEditingChanged];
                        [cell.txtMonth addTarget:self action:@selector(txtMonthDidChange:) forControlEvents:UIControlEventEditingChanged];
                        [cell.txtYear addTarget:self action:@selector(txtYearDidChange:) forControlEvents:UIControlEventEditingChanged];
                        
                        
                        
                        NSInteger cardBrand = [OMSCardNumber brandForPan:_creditCard.creditCardNo];
                        switch (cardBrand)
                        {
                            case OMSCardBrandJCB:
                            {
                                cell.imgCreditCardBrand.hidden = NO;
                                cell.imgCreditCardBrand.image = [UIImage imageNamed:@"jcb.png"];
                            }
                                break;
                            case OMSCardBrandAMEX:
                            {
                                cell.imgCreditCardBrand.hidden = NO;
                                cell.imgCreditCardBrand.image = [UIImage imageNamed:@"americanExpress.png"];
                            }
                                break;
                            case OMSCardBrandVisa:
                            {
                                cell.imgCreditCardBrand.hidden = NO;
                                cell.imgCreditCardBrand.image = [UIImage imageNamed:@"visa.png"];
                            }
                                break;
                            case OMSCardBrandMasterCard:
                            {
                                cell.imgCreditCardBrand.hidden = NO;
                                cell.imgCreditCardBrand.image = [UIImage imageNamed:@"masterCard.png"];
                            }
                                break;
                            default:
                            {
                                cell.imgCreditCardBrand.hidden = YES;
                            }
                                break;
                        }
                        
                        return cell;
                    }
                    else
                    {
                        CustomTableViewCellImageLabelRemove *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierImageLabelRemove];
                        NSInteger cardBrand = [OMSCardNumber brandForPan:_creditCard.creditCardNo];
                        switch (cardBrand)
                        {
                            case OMSCardBrandJCB:
                            {
                                cell.imageView.image = [UIImage imageNamed:@"jcb.png"];
                            }
                                break;
                            case OMSCardBrandAMEX:
                            {
                                cell.imageView.image = [UIImage imageNamed:@"americanExpress.png"];
                            }
                                break;
                            case OMSCardBrandVisa:
                            {
                                cell.imageView.image = [UIImage imageNamed:@"visa.png"];
                            }
                                break;
                            case OMSCardBrandMasterCard:
                            {
                                cell.imageView.image = [UIImage imageNamed:@"masterCard.png"];
                            }
                                break;
                            default:
                                break;
                        }
                        
                        
                        
                        NSString *strCreditCardNo = [Utility hideCreditCardNo:_creditCard.creditCardNo];
                        cell.lblValue.text = strCreditCardNo;
                        cell.lblValue.font = [UIFont systemFontOfSize:15];
                        
                        
                        
                        
                        [cell.btnRemove setTitle:@">" forState:UIControlStateNormal];
                        [cell.btnRemove addTarget:self action:@selector(addCreditCard:) forControlEvents:UIControlEventTouchUpInside];
                        return cell;
                    }
                    
                }
                    break;
                case 2:
                {
                    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"cellValue1"];
                    if (!cell)
                    {
                        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellValue1"];
                    }
                    
                    
                    cell.textLabel.text = @"เลือกบัตรเครดิต";
                    cell.textLabel.font = [UIFont systemFontOfSize:15];
                    cell.detailTextLabel.text = @">";
                    cell.detailTextLabel.textColor = mGreen;
                    
                    
                    
                    return cell;
                }
                default:
                    break;
            }
        }
        else
        {
            if(item == 0)
            {
                UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"cell"];
                if (!cell)
                {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                }
                
                
                cell.textLabel.text = @"สรุปรายการอาหาร";
                cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
                
                return cell;
            }
            else
            {
                CustomTableViewCellOrderSummary *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierOrderSummary];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                
                OrderTaking *orderTaking = _orderTakingList[item-1];
                Menu *menu = [Menu getMenu:orderTaking.menuID branchID:branch.branchID];
                cell.lblQuantity.text = [Utility formatDecimal:orderTaking.quantity withMinFraction:0 andMaxFraction:0];
                
                
                //menu
                if(orderTaking.takeAway)
                {
                    UIFont *font = [UIFont systemFontOfSize:15];
                    NSDictionary *attribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSFontAttributeName: font};
                    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"ใส่ห่อ"
                                                                                                   attributes:attribute];
                    
                    NSDictionary *attribute2 = @{NSFontAttributeName: font};
                    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",menu.titleThai] attributes:attribute2];
                    
                    
                    [attrString appendAttributedString:attrString2];
                    cell.lblMenuName.attributedText = attrString;
                }
                else
                {
                    cell.lblMenuName.text = menu.titleThai;
                }
                CGSize menuNameLabelSize = [self suggestedSizeWithFont:cell.lblMenuName.font size:CGSizeMake(tbvData.frame.size.width - 75-28-2*16-2*8, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping forString:cell.lblMenuName.text];
                CGRect frame = cell.lblMenuName.frame;
                frame.size.width = menuNameLabelSize.width;
                frame.size.height = menuNameLabelSize.height;
                cell.lblMenuNameHeight.constant = menuNameLabelSize.height;
                cell.lblMenuName.frame = frame;
                
                
                
                //note
                NSMutableAttributedString *strAllNote;
                NSMutableAttributedString *attrStringRemove;
                NSMutableAttributedString *attrStringAdd;
                NSString *strRemoveTypeNote = [OrderNote getNoteNameListInTextWithOrderTakingID:orderTaking.orderTakingID noteType:-1];
                NSString *strAddTypeNote = [OrderNote getNoteNameListInTextWithOrderTakingID:orderTaking.orderTakingID noteType:1];
                if(![Utility isStringEmpty:strRemoveTypeNote])
                {
                    UIFont *font = [UIFont systemFontOfSize:11];
                    NSDictionary *attribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSFontAttributeName: font};
                    attrStringRemove = [[NSMutableAttributedString alloc] initWithString:@"ไม่ใส่" attributes:attribute];
                    
                    
                    UIFont *font2 = [UIFont systemFontOfSize:11];
                    NSDictionary *attribute2 = @{NSFontAttributeName: font2};
                    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",strRemoveTypeNote] attributes:attribute2];
                    
                    
                    [attrStringRemove appendAttributedString:attrString2];
                }
                if(![Utility isStringEmpty:strAddTypeNote])
                {
                    UIFont *font = [UIFont systemFontOfSize:11];
                    NSDictionary *attribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSFontAttributeName: font};
                    attrStringAdd = [[NSMutableAttributedString alloc] initWithString:@"เพิ่ม" attributes:attribute];
                    
                    
                    UIFont *font2 = [UIFont systemFontOfSize:11];
                    NSDictionary *attribute2 = @{NSFontAttributeName: font2};
                    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",strAddTypeNote] attributes:attribute2];
                    
                    
                    [attrStringAdd appendAttributedString:attrString2];
                }
                if(![Utility isStringEmpty:strRemoveTypeNote])
                {
                    strAllNote = attrStringRemove;
                    if(![Utility isStringEmpty:strAddTypeNote])
                    {
                        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:nil];
                        [strAllNote appendAttributedString:attrString];
                        [strAllNote appendAttributedString:attrStringAdd];
                    }
                }
                else
                {
                    if(![Utility isStringEmpty:strAddTypeNote])
                    {
                        strAllNote = attrStringAdd;
                    }
                    else
                    {
                        strAllNote = [[NSMutableAttributedString alloc]init];
                    }
                }
                cell.lblNote.attributedText = strAllNote;
                
                
                
                CGSize noteLabelSize = [self suggestedSizeWithFont:cell.lblNote.font size:CGSizeMake(tbvData.frame.size.width - 75-28-2*16-2*8, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping forString:[strAllNote string]];
                noteLabelSize.height = [Utility isStringEmpty:[strAllNote string]]?13.13:noteLabelSize.height;
                CGRect frame2 = cell.lblNote.frame;
                frame2.size.width = noteLabelSize.width;
                frame2.size.height = noteLabelSize.height;
                cell.lblNoteHeight.constant = noteLabelSize.height;
                cell.lblNote.frame = frame2;
                
                
                
                
                
                float totalAmount = orderTaking.specialPrice * orderTaking.quantity;
                NSString *strTotalAmount = [Utility formatDecimal:totalAmount withMinFraction:2 andMaxFraction:2];
                cell.lblTotalAmount.text = [Utility addPrefixBahtSymbol:strTotalAmount];
                
                
                return cell;
            }
        }
    }
    else if([tableView isEqual:tbvTotal])
    {
        
        switch (item)
        {
            case 0:
            {
                CustomTableViewCellTotal *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTotal];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                
                NSMutableArray *orderTakingList = [OrderTaking getCurrentOrderTakingList];
                NSString *strTitle = [NSString stringWithFormat:@"%ld รายการ",[orderTakingList count]];
                NSString *strTotal = [Utility formatDecimal:[OrderTaking getSumSpecialPrice:_orderTakingList] withMinFraction:2 andMaxFraction:2];
                strTotal = [Utility addPrefixBahtSymbol:strTotal];
                cell.lblTitle.text = strTitle;
                cell.lblAmount.text = strTotal;
                cell.vwTopBorder.hidden = NO;
                
                return  cell;
            }
                break;
            case 1:
            {
                //voucher code
                CustomTableViewCellVoucherCode *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierVoucherCode];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;


                cell.txtVoucherCode.tag = 31;
                cell.txtVoucherCode.delegate = self;
                cell.txtVoucherCode.text = @"";
                cell.btnConfirmVoucherCodeWidthConstant.constant = (self.view.frame.size.width - 16*2 - 8)/2;
                [cell.btnConfirmVoucherCode addTarget:self action:@selector(confirmVoucherCode:) forControlEvents:UIControlEventTouchUpInside];

                return cell;

            }
                break;
            case 2:
            {
                //after discount - no promoCode
                CustomTableViewCellTotal *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTotal];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;


                NSString *strTitle = branch.priceIncludeVat?@"ยอดรวม (รวม Vat)":@"ยอดรวม";
                float totalAmount = [OrderTaking getSumSpecialPrice:_orderTakingList];
                NSString *strTotal = [Utility formatDecimal:totalAmount withMinFraction:2 andMaxFraction:2];
                strTotal = [Utility addPrefixBahtSymbol:strTotal];
                cell.lblTitle.text = strTitle;
                cell.lblAmount.text = strTotal;
                cell.vwTopBorder.hidden = YES;

                return  cell;
            }
                break;
            case 3:
            {
                //service charge
                if(branch.serviceChargePercent > 0)
                {
                    //after discount
                    CustomTableViewCellTotal *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTotal];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;


                    NSString *strServiceCharge = [Utility formatDecimal:branch.serviceChargePercent withMinFraction:0 andMaxFraction:2];
                    NSString *strTitle = [NSString stringWithFormat:@"Service charge %@%%",strServiceCharge];
                    float totalAmount = [OrderTaking getSumSpecialPrice:_orderTakingList];
                    float serviceChargeValue;
                    if(branch.priceIncludeVat)
                    {
                        totalAmount = totalAmount / ((branch.percentVat+100)*0.01);
                        serviceChargeValue = branch.serviceChargePercent * totalAmount * 0.01;
                    }
                    else
                    {
                        serviceChargeValue = branch.serviceChargePercent * totalAmount * 0.01;
                    }

                    serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                    _serviceChargeValue = serviceChargeValue;
                    NSString *strTotal = [Utility formatDecimal:serviceChargeValue withMinFraction:2 andMaxFraction:2];
                    strTotal = [Utility addPrefixBahtSymbol:strTotal];
                    cell.lblTitle.text = strTitle;
                    cell.lblAmount.text = strTotal;
                    cell.vwTopBorder.hidden = YES;
                    cell.lblTitle.font = [UIFont systemFontOfSize:15];
                    cell.lblAmount.font = [UIFont systemFontOfSize:15];
                    cell.lblAmount.textColor = [UIColor darkGrayColor];
                    
                    
                    return  cell;
                }
                else
                {
                    //vat
                    CustomTableViewCellTotal *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTotal];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;


                    NSString *strPercentVat = [Utility formatDecimal:branch.percentVat withMinFraction:0 andMaxFraction:2];
                    strPercentVat = [NSString stringWithFormat:@"Vat %@%%",strPercentVat];
                    float totalAmount = [OrderTaking getSumSpecialPrice:_orderTakingList];
                    float serviceChargeValue;
                    float vatAmount;
                    if(branch.priceIncludeVat)
                    {
                        totalAmount = totalAmount / ((branch.percentVat+100)*0.01);
                        serviceChargeValue = branch.serviceChargePercent * totalAmount * 0.01;
                        serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                        vatAmount = totalAmount * branch.percentVat * 0.01;
                    }
                    else
                    {
                        serviceChargeValue = branch.serviceChargePercent * totalAmount * 0.01;
                        serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                        vatAmount = (totalAmount+serviceChargeValue)*branch.percentVat/100;
                    }

                    vatAmount = roundf(vatAmount*100)/100;
                    _vatValue = vatAmount;
                    NSString *strAmount = [Utility formatDecimal:vatAmount withMinFraction:2 andMaxFraction:2];
                    strAmount = [Utility addPrefixBahtSymbol:strAmount];
                    cell.lblTitle.text = branch.percentVat==0?@"Vat":strPercentVat;
                    cell.lblAmount.text = strAmount;
                    cell.vwTopBorder.hidden = YES;
                    cell.lblTitle.font = [UIFont systemFontOfSize:15];
                    cell.lblAmount.font = [UIFont systemFontOfSize:15];
                    cell.lblAmount.textColor = [UIColor darkGrayColor];
                    
                    
                    return cell;
                }
            }
                break;
            case 4:
            {
                if(branch.serviceChargePercent > 0)
                {
                    //vat
                    CustomTableViewCellTotal *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTotal];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;


                    NSString *strPercentVat = [Utility formatDecimal:branch.percentVat withMinFraction:0 andMaxFraction:2];
                    strPercentVat = [NSString stringWithFormat:@"Vat %@%%",strPercentVat];
                    float totalAmount = [OrderTaking getSumSpecialPrice:_orderTakingList];
                    float serviceChargeValue;
                    float vatAmount;
                    if(branch.priceIncludeVat)
                    {
                        totalAmount = totalAmount / ((branch.percentVat+100)*0.01);
                        serviceChargeValue = branch.serviceChargePercent * totalAmount * 0.01;
                        serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                        vatAmount = totalAmount * branch.percentVat * 0.01;
                    }
                    else
                    {
                        serviceChargeValue = branch.serviceChargePercent * totalAmount * 0.01;
                        serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                        vatAmount = (totalAmount+serviceChargeValue)*branch.percentVat/100;
                    }

                    vatAmount = roundf(vatAmount*100)/100;
                    _vatValue = vatAmount;
                    NSString *strAmount = [Utility formatDecimal:vatAmount withMinFraction:2 andMaxFraction:2];
                    strAmount = [Utility addPrefixBahtSymbol:strAmount];
                    cell.lblTitle.text = branch.percentVat==0?@"Vat":strPercentVat;
                    cell.lblAmount.text = strAmount;
                    cell.vwTopBorder.hidden = YES;
                    cell.lblTitle.font = [UIFont systemFontOfSize:15];
                    cell.lblAmount.font = [UIFont systemFontOfSize:15];
                    cell.lblAmount.textColor = [UIColor darkGrayColor];
                    
                    
                    return cell;
                }
                else
                {
                    //net total
                    CustomTableViewCellTotal *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTotal];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;


                    float totalAmount = [OrderTaking getSumSpecialPrice:_orderTakingList];
                    float serviceChargeValue;
                    float vatAmount;
                    if(branch.priceIncludeVat)
                    {
                        totalAmount = totalAmount / ((branch.percentVat+100)*0.01);
                        serviceChargeValue = branch.serviceChargePercent * totalAmount * 0.01;
                        serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                        vatAmount = totalAmount * branch.percentVat * 0.01;
                    }
                    else
                    {
                        serviceChargeValue = branch.serviceChargePercent * totalAmount * 0.01;
                        serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                        vatAmount = (totalAmount+serviceChargeValue)*branch.percentVat/100;
                    }

                    vatAmount = roundf(vatAmount*100)/100;
                    float netTotalAmount = totalAmount+serviceChargeValue+vatAmount;
                    NSString *strAmount = [Utility formatDecimal:netTotalAmount withMinFraction:2 andMaxFraction:2];
                    strAmount = [Utility addPrefixBahtSymbol:strAmount];
                    cell.lblTitle.text = @"ยอดรวมทั้งสิ้น";
                    cell.lblAmount.text = strAmount;
                    cell.vwTopBorder.hidden = YES;
                    _netTotal = netTotalAmount;
//                    cell.lblAmount.font = [UIFont boldSystemFontOfSize:16];


                    return cell;
                }
            }
                break;
            case 5:
            {
                //net total
                CustomTableViewCellTotal *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTotal];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;


                float totalAmount = [OrderTaking getSumSpecialPrice:_orderTakingList];
                float serviceChargeValue;
                float vatAmount;
                if(branch.priceIncludeVat)
                {
                    totalAmount = totalAmount / ((branch.percentVat+100)*0.01);
                    serviceChargeValue = branch.serviceChargePercent * totalAmount * 0.01;
                    serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                    vatAmount = totalAmount * branch.percentVat * 0.01;
                }
                else
                {
                    serviceChargeValue = branch.serviceChargePercent * totalAmount * 0.01;
                    serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                    vatAmount = (totalAmount+serviceChargeValue)*branch.percentVat/100;
                }

                vatAmount = roundf(vatAmount*100)/100;
                float netTotalAmount = totalAmount+serviceChargeValue+vatAmount;
                NSString *strAmount = [Utility formatDecimal:netTotalAmount withMinFraction:2 andMaxFraction:2];
                strAmount = [Utility addPrefixBahtSymbol:strAmount];
                cell.lblTitle.text = @"ยอดรวมทั้งสิ้น";
                cell.lblAmount.text = strAmount;
                cell.vwTopBorder.hidden = YES;
                _netTotal = netTotalAmount;


                return cell;
            }
                break;
            default:
                break;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    
    if([tableView isEqual:tbvData])
    {
        if(section == 0)
        {
            return 44;
        }
        else if(section == 1)
        {
            if(item == 0)
            {
                return 44;
            }
            else if(item == 1)
            {
                if(!_creditCard.primaryCard)
                {
                    return 272;
                }
                else
                {
                    return 44;
                }
            }
            else
            {
                return 44;
            }
        }
        else
        {
            if(item == 0)
            {
                return 44;
            }
            else
            {
                //load order มาโชว์
                OrderTaking *orderTaking = _orderTakingList[item-1];
                Menu *menu = [Menu getMenu:orderTaking.menuID branchID:branch.branchID];
                
                NSString *strMenuName;
                if(orderTaking.takeAway)
                {
                    strMenuName = [NSString stringWithFormat:@"ใส่ห่อ %@",menu.titleThai];
                }
                else
                {
                    strMenuName = menu.titleThai;
                }
                
                
                //note
                NSMutableAttributedString *strAllNote;
                NSMutableAttributedString *attrStringRemove;
                NSMutableAttributedString *attrStringAdd;
                NSString *strRemoveTypeNote = [OrderNote getNoteNameListInTextWithOrderTakingID:orderTaking.orderTakingID noteType:-1];
                NSString *strAddTypeNote = [OrderNote getNoteNameListInTextWithOrderTakingID:orderTaking.orderTakingID noteType:1];
                if(![Utility isStringEmpty:strRemoveTypeNote])
                {
                    UIFont *font = [UIFont systemFontOfSize:11];
                    NSDictionary *attribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSFontAttributeName: font};
                    attrStringRemove = [[NSMutableAttributedString alloc] initWithString:@"ไม่ใส่" attributes:attribute];
                    
                    
                    UIFont *font2 = [UIFont systemFontOfSize:11];
                    NSDictionary *attribute2 = @{NSFontAttributeName: font2};
                    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",strRemoveTypeNote] attributes:attribute2];
                    
                    
                    [attrStringRemove appendAttributedString:attrString2];
                }
                if(![Utility isStringEmpty:strAddTypeNote])
                {
                    UIFont *font = [UIFont systemFontOfSize:11];
                    NSDictionary *attribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSFontAttributeName: font};
                    attrStringAdd = [[NSMutableAttributedString alloc] initWithString:@"เพิ่ม" attributes:attribute];
                    
                    
                    UIFont *font2 = [UIFont systemFontOfSize:11];
                    NSDictionary *attribute2 = @{NSFontAttributeName: font2};
                    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",strAddTypeNote] attributes:attribute2];
                    
                    
                    [attrStringAdd appendAttributedString:attrString2];
                }
                if(![Utility isStringEmpty:strRemoveTypeNote])
                {
                    strAllNote = attrStringRemove;
                    if(![Utility isStringEmpty:strAddTypeNote])
                    {
                        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:nil];
                        [strAllNote appendAttributedString:attrString];
                        [strAllNote appendAttributedString:attrStringAdd];
                    }
                }
                else
                {
                    if(![Utility isStringEmpty:strAddTypeNote])
                    {
                        strAllNote = attrStringAdd;
                    }
                    else
                    {
                        strAllNote = [[NSMutableAttributedString alloc]init];
                    }
                }
                
                
                
                UIFont *fontMenuName = [UIFont systemFontOfSize:14.0];
                UIFont *fontNote = [UIFont systemFontOfSize:11.0];
                
                
                
                CGSize menuNameLabelSize = [self suggestedSizeWithFont:fontMenuName size:CGSizeMake(tbvData.frame.size.width - 75-28-2*16-2*8, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping forString:strMenuName];//153 from storyboard
                CGSize noteLabelSize = [self suggestedSizeWithFont:fontNote size:CGSizeMake(tbvData.frame.size.width - 75-28-2*16-2*8, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping forString:[strAllNote string]];
                noteLabelSize.height = [Utility isStringEmpty:[strAllNote string]]?13.13:noteLabelSize.height;
                
                
                float height = menuNameLabelSize.height+noteLabelSize.height+8+8+2;
                return height;
            }
        }
    }
    else if([tableView isEqual:tbvTotal])
    {
        return item == 1?56:26;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([tableView isEqual:tbvData])
    {
        if (section == 0)
        {
            return 8;
        }
        return tableView.sectionHeaderHeight;
    }
    else
    {
        return CGFLOAT_MIN;
    }
    return CGFLOAT_MIN;
}

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    [cell setSeparatorInset:UIEdgeInsetsMake(16, 16, 16, 16)];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    if(section == 0 && item == 0)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:
         [UIAlertAction actionWithTitle:@"QR code"
                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
          {
              [self performSegueWithIdentifier:@"segQRCodeScanTable" sender:self];
              
          }]];
        [alert addAction:
         [UIAlertAction actionWithTitle:@"ค้นหา"
                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
          {
              [self performSegueWithIdentifier:@"segCustomerTableSearch" sender:self];
          }]];
        [alert addAction:
         [UIAlertAction actionWithTitle:@"ยกเลิก"
                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
          {
              
              
          }]];
        
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if(section == 1 && item == 1)
    {
        if(_creditCard.primaryCard)
        {
            [self performSegueWithIdentifier:@"segSelectPaymentMethod" sender:self];
        }
    }
    else if(section == 1 && item == 2)
    {
        UserAccount *userAccount = [UserAccount getCurrentUserAccount];
        NSMutableDictionary *dicCreditCard = [[[NSUserDefaults standardUserDefaults] objectForKey:@"creditCard"] mutableCopy];
        NSMutableArray *creditCardList;
        if(!dicCreditCard)
        {
            dicCreditCard = [[NSMutableDictionary alloc]init];
            creditCardList = [[NSMutableArray alloc]init];
        }
        else
        {
            creditCardList = [dicCreditCard objectForKey:userAccount.username];
            creditCardList = [creditCardList mutableCopy];
            if(!creditCardList)
            {
                creditCardList = [[NSMutableArray alloc]init];
            }
        }
        
        [CreditCard clearPrimaryCard:_creditCard creditCardList:creditCardList];
        [self performSegueWithIdentifier:@"segSelectPaymentMethod" sender:self];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if([tableView isEqual:tbvTotal])
    {
        CustomTableViewHeaderFooterButton *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifierHeaderFooterButton];
        
        
        [footerView.btnValue setTitle:@"ชำระเงิน" forState:UIControlStateNormal];
        [footerView.btnValue addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        return footerView;
    }
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if([tableView isEqual:tbvTotal])
    {
        float height = 44;
        return height;
    }
    return 0;
}

- (IBAction)backToBasket:(id)sender
{
    [self performSegueWithIdentifier:@"segUnwindToBasket" sender:self];
}

- (void)pay:(id)sender
{
    
    //validate
    [self.view endEditing:YES];
    
    //customerTable
    if(!customerTable)
    {
        [self blinkAlertMsg:@"กรุณาระบุเลขโต๊ะ"];
        return;
    }
    
    
    
    //credit card
    if([Utility isStringEmpty:_creditCard.firstName])
    {
        [self blinkAlertMsg:@"กรุณาใส่ชื่อ"];
        UIView *vwInvalid = [self.view viewWithTag:11];
        vwInvalid.backgroundColor = mRed;
        return;
    }
    if([Utility isStringEmpty:_creditCard.lastName])
    {
        [self blinkAlertMsg:@"กรุณาใส่นามสกุล"];
        UIView *vwInvalid = [self.view viewWithTag:12];
        vwInvalid.backgroundColor = mRed;
        return;
    }
    if(![OMSCardNumber validate:_creditCard.creditCardNo])
    {
        [self blinkAlertMsg:@"หมายเลขบัตรเครดิตไม่ถูกต้อง"];
        UIView *vwInvalid = [self.view viewWithTag:13];
        vwInvalid.backgroundColor = mRed;
        return;
    }
    if(_creditCard.month < 1 || _creditCard.month > 12)
    {
        [self blinkAlertMsg:@"เดือนไม่ถูกต้อง กรุณาใส่เดือนระหว่าง 01 ถึง 12"];
        UIView *vwInvalid = [self.view viewWithTag:14];
        vwInvalid.backgroundColor = mRed;
        return;
    }
    if([[NSString stringWithFormat:@"%ld",_creditCard.year] length] < 4)
    {
        [self blinkAlertMsg:@"ปีไม่ถูกต้อง กรุณาใส่ปีจำนวน 4 หลัก"];
        UIView *vwInvalid = [self.view viewWithTag:15];
        vwInvalid.backgroundColor = mRed;
        return;
    }
    NSString *strExpiredDate = [NSString stringWithFormat:@"%04ld%02ld01 00:00:00",_creditCard.year,_creditCard.month];
    NSDate *expireDate = [Utility stringToDate:strExpiredDate fromFormat:@"yyyyMMdd HH:mm:ss"];
    if(![Utility isExpiredDateValid:expireDate])
    {
        [self blinkAlertMsg:@"บัตรใบนี้หมดอายุแล้ว"];
        UIView *vwInvalid = [self.view viewWithTag:15];
        vwInvalid.backgroundColor = mRed;
        return;
    }
    if([_creditCard.ccv length] < 3)
    {
        [self blinkAlertMsg:@"กรุณาใส่รหัสความปลอดภัย 3 หลัก"];
        UIView *vwInvalid = [self.view viewWithTag:16];
        vwInvalid.backgroundColor = mRed;
        return;
    }
    
    
    UIButton *btnPay = (UIButton *)sender;
    btnPay.enabled = NO;
    [self loadWaitingView];
    
    
    
    NSString *strCreditCardName = [NSString stringWithFormat:@"%@ %@",_creditCard.firstName,_creditCard.lastName];
    OMSTokenRequest *request = [[OMSTokenRequest alloc]initWithName:strCreditCardName number:_creditCard.creditCardNo expirationMonth:_creditCard.month expirationYear:_creditCard.year securityCode:_creditCard.ccv city:@"" postalCode:@""];



    NSString *publicKey = [Setting getSettingValueWithKeyName:@"PublicKey"];
    OMSSDKClient *client = [[OMSSDKClient alloc]initWithPublicKey:publicKey];
    [client sendRequest:request callback:^(OMSToken * _Nullable token, NSError * _Nullable error) {
        //
        if(!error)
        {
            NSLog(@"%@",[token tokenId]);




            //update nsuserdefault _creditcard
            if(_creditCard.saveCard)
            {
                UserAccount *userAccount = [UserAccount getCurrentUserAccount];
                NSMutableDictionary *dicCreditCard = [[[NSUserDefaults standardUserDefaults] objectForKey:@"creditCard"] mutableCopy];
                NSMutableArray *creditCardList;
                if(!dicCreditCard)
                {
                    dicCreditCard = [[NSMutableDictionary alloc]init];
                    creditCardList = [[NSMutableArray alloc]init];
                }
                else
                {
                    creditCardList = [dicCreditCard objectForKey:userAccount.username];
                    creditCardList = [creditCardList mutableCopy];
                    if(!creditCardList)
                    {
                        creditCardList = [[NSMutableArray alloc]init];
                    }
                }



                [CreditCard updatePrimaryCard:_creditCard creditCardList:creditCardList];

            }




            UserAccount *userAccount = [UserAccount getCurrentUserAccount];
            Receipt *receipt = [[Receipt alloc]initWithBranchID:branch.branchID customerTableID:customerTable.customerTableID memberID:userAccount.userAccountID servingPerson:0 customerType:4 openTableDate:[Utility currentDateTime] cashAmount:0 cashReceive:0 creditCardType:[self getCreditCardType:_creditCard.creditCardNo] creditCardNo:_creditCard.creditCardNo creditCardAmount:_netTotal transferDate:[Utility notIdentifiedDate] transferAmount:0 remark:@"" discountType:_discountType discountAmount:_discountAmount discountValue:_discountValue discountReason:@"" serviceChargePercent:branch.serviceChargePercent serviceChargeValue:_serviceChargeValue priceIncludeVat:branch.priceIncludeVat vatPercent:branch.percentVat vatValue:_vatValue status:2 statusRoute:@"" receiptNoID:@"" receiptNoTaxID:@"" receiptDate:[Utility currentDateTime] mergeReceiptID:0];



            //paymentmethod,discount,receiptno
            NSMutableArray *orderTakingList = [OrderTaking getCurrentOrderTakingList];
            NSMutableArray *orderNoteList = [OrderNote getOrderNoteListWithOrderTakingList:orderTakingList];
            orderTakingList = [OrderTaking updateStatus:0 orderTakingList:orderTakingList];



            if(_promotionOrRewardRedemption == 1)
            {
                UserPromotionUsed *userPromotionUsed = [[UserPromotionUsed alloc]initWithUserAccountID:userAccount.userAccountID promotionID:_promotionUsed.promotionID receiptID:0];
                [self.homeModel insertItems:dbOmiseCheckOut withData:@[[token tokenId],@(_netTotal*100),receipt,orderTakingList,orderNoteList,userPromotionUsed,@(_promotionOrRewardRedemption)] actionScreen:@"call omise checkout at server"];
            }
            else
            {
                UserRewardRedemptionUsed *userRewardRedemptionUsed = [[UserRewardRedemptionUsed alloc]initWithUserAccountID:userAccount.userAccountID rewardRedemptionID:_promotionUsed.rewardRedemptionID receiptID:0];
                [self.homeModel insertItems:dbOmiseCheckOut withData:@[[token tokenId],@(_netTotal*100),receipt,orderTakingList,orderNoteList,userRewardRedemptionUsed] actionScreen:@"call omise checkout at server"];
            }
        }
        else
        {
            [self showAlert:@"" message:@"การจ่ายด้วยบัตรเครดิตขัดข้อง กรุณาติดต่อเจ้าหน้าที่ที่เกี่ยวข้อง"];
        }
    }];
}

-(void)swtSaveDidChange:(id)sender
{
    UISwitch *swtSave = sender;
    _creditCard.saveCard = swtSave.on;
}

-(void)txtCardNoDidChange:(id)sender
{
    UITextField *txtCardNo = sender;
    NSInteger cardBrand = [OMSCardNumber brandForPan:txtCardNo.text];
    UIImageView *imgCreditCardBrand = [self.view viewWithTag:21];
    switch (cardBrand)
    {
        case OMSCardBrandJCB:
        {
            imgCreditCardBrand.hidden = NO;
            imgCreditCardBrand.image = [UIImage imageNamed:@"jcb.png"];
        }
            break;
        case OMSCardBrandAMEX:
        {
            imgCreditCardBrand.hidden = NO;
            imgCreditCardBrand.image = [UIImage imageNamed:@"americanExpress.png"];
        }
            break;
        case OMSCardBrandVisa:
        {
            imgCreditCardBrand.hidden = NO;
            imgCreditCardBrand.image = [UIImage imageNamed:@"visa.png"];
        }
            break;
        case OMSCardBrandMasterCard:
        {
            imgCreditCardBrand.hidden = NO;
            imgCreditCardBrand.image = [UIImage imageNamed:@"masterCard.png"];
        }
            break;
        default:
        {
            imgCreditCardBrand.hidden = YES;
        }
            break;
    }
    
    txtCardNo.text = [OMSCardNumber format:txtCardNo.text];
}

-(NSInteger)getCreditCardType:(NSString *)creditCardNo
{
    NSInteger creditCardType = 0;
    NSInteger cardBrand = [OMSCardNumber brandForPan:creditCardNo];
    switch (cardBrand)
    {
        case OMSCardBrandJCB:
        {
            creditCardType = 2;
        }
            break;
        case OMSCardBrandAMEX:
        {
            creditCardType = 1;
        }
            break;
        case OMSCardBrandVisa:
        {
            creditCardType = 5;
        }
            break;
        case OMSCardBrandMasterCard:
        {
            creditCardType = 3;
        }
            break;
        default:
        {
            creditCardType = 0;
        }
            break;
    }
    return creditCardType;
}

-(void)txtMonthDidChange:(id)sender
{
    UITextField *txtMonth = sender;
    if([txtMonth.text length] == 2)
    {
        UITextField *txtYear = [self.view viewWithTag:5];
        [txtYear becomeFirstResponder];
    }
}

-(void)txtYearDidChange:(id)sender
{
    UITextField *txtYear = sender;
    if([txtYear.text length] == 4)
    {
        UITextField *txtCCV = [self.view viewWithTag:6];
        [txtCCV becomeFirstResponder];
    }
}

-(void)itemsInsertedWithReturnData:(NSArray *)items
{
    [self removeWaitingView];
    [OrderTaking removeCurrentOrderTakingList];
    
    
    [Utility addToSharedDataList:items];
    NSMutableArray *receiptList = items[0];
    Receipt *receipt = receiptList[0];
    _receipt = receipt;
    [self.homeModel insertItems:dbPushReminder withData:@[branch,receipt] actionScreen:@"push reminder"];
    [self performSegueWithIdentifier:@"segSaveToCameraRoll" sender:self];
}

-(void)alertMsg:(NSString *)msg
{
    [self removeWaitingView];
    
    [self showAlert:@"" message:msg];
}

-(void)segueToBranchSearch
{
    [self performSegueWithIdentifier:@"segUnwindToBranchSearch" sender:self];
}

-(void)addCreditCard:(id)sender
{
    [self performSegueWithIdentifier:@"segSelectPaymentMethod" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segSelectPaymentMethod"])
    {
        SelectPaymentMethodViewController *vc = segue.destinationViewController;
        vc.creditCard = _creditCard;
    }
    else if([[segue identifier] isEqualToString:@"segQRCodeScanTable"])
    {
        QRCodeScanTableViewController *vc = segue.destinationViewController;
        vc.fromCreditCardAndOrderSummaryMenu = 1;
        vc.customerTable = customerTable;
    }
    else if([[segue identifier] isEqualToString:@"segCustomerTableSearch"])
    {
        CustomerTableSearchViewController *vc = segue.destinationViewController;
        vc.fromCreditCardAndOrderSummaryMenu = 1;
        vc.branch = branch;
        vc.customerTable = customerTable;
    }
    else if([[segue identifier] isEqualToString:@"segSaveToCameraRoll"])
    {
        SaveToCameraRollViewController *vc = segue.destinationViewController;
        vc.receipt = _receipt;
    }
}

- (void)confirmVoucherCode:(id)sender
{
    //เช็คว่า voucher valid มั๊ย
    [self loadingOverlayView];
    [self.view endEditing:YES];
    UserAccount *userAccount = [UserAccount getCurrentUserAccount];
    [self.homeModel downloadItems:dbPromotion withData:@[_voucherCode,userAccount,branch,@([OrderTaking getSumSpecialPrice:_orderTakingList])]];

}

-(void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    NSMutableArray *promotionList = items[0];
    NSMutableArray *warningMsgList = items[1];
    NSMutableArray *typeList = items[2];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    CustomTableViewCellVoucherCode *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

    
    
    float totalPriceGetDiscount = 0;
    Message *warningMsg = warningMsgList[0];
    if(![Utility isStringEmpty:warningMsg.text])
    {
        [self blinkAlertMsg:warningMsg.text];
        return;
    }


    Promotion *promotion = promotionList[0];
    float totalAmount = [OrderTaking getSumSpecialPrice:_orderTakingList];
    if(promotion.allowDiscountForAllMenuType)
    {
        totalPriceGetDiscount = totalAmount;
    }
    else
    {
        for(OrderTaking *item in _orderTakingList)
        {
            Menu *menu = [Menu getMenu:item.menuID];
            MenuType *menuType = [MenuType getMenuType:menu.menuTypeID];
            //เช็คว่า เมนูที่สั่งได้ส่วนลดมั๊ย
            if(menuType.allowDiscount && (item.specialPrice == item.price))
            {
                totalPriceGetDiscount += item.quantity * item.specialPrice;
            }
        }
    }



    if(totalPriceGetDiscount == 0)
    {
        [self blinkAlertMsg:@"โค้ดที่ใส่ไม่สามารถใช้กับเมนูที่คุณเลือก"];
    }
    else
    {
        cell.txtVoucherCode.hidden = YES;
        cell.btnConfirmVoucherCode.hidden = YES;


        voucherView.hidden = NO;
        CGRect frame = voucherView.frame;
        frame.origin.x = 0;
        frame.origin.y = cell.txtVoucherCode.frame.origin.y;
        frame.size.width = self.view.frame.size.width;
        frame.size.height = 32;
        voucherView.frame = frame;
        [cell addSubview:voucherView];
        NSLog(@"voucherView: %f,%f,%f,%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);


        if(promotion.discountType == 1) //baht
        {
            _discountType = 1;
            voucherView.lblVoucherCode.text = [NSString stringWithFormat:@"คูปองส่วนลด %@",cell.txtVoucherCode.text];
            [voucherView.lblVoucherCode sizeToFit];
            voucherView.lblVoucherCodeWidthConstant.constant = voucherView.lblVoucherCode.frame.size.width;
            _discountValue = totalPriceGetDiscount < promotion.discountAmount?totalPriceGetDiscount:promotion.discountAmount;
            if(promotion.moreDiscountToGo != -1)
            {
                _discountValue = _discountValue > promotion.moreDiscountToGo?promotion.moreDiscountToGo:_discountValue;
            }
            voucherView.lblDiscountAmount.text = [Utility formatDecimal:_discountValue withMinFraction:2 andMaxFraction:2];
            voucherView.lblDiscountAmount.text = [Utility addPrefixBahtSymbol:voucherView.lblDiscountAmount.text];
            voucherView.lblDiscountAmount.text = [NSString stringWithFormat:@"-%@",voucherView.lblDiscountAmount.text];


            NSString *strTotalAmountNet = [Utility formatDecimal:totalAmount-_discountValue withMinFraction:2 andMaxFraction:2];
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
                CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];
                cell.lblAmount.text = [Utility addPrefixBahtSymbol:strTotalAmountNet];
            }
            _discountAmount = _discountValue;
        }
        else//2 = percent
        {
            _discountType = 2;
            _discountAmount = promotion.discountAmount;
            _discountValue = totalPriceGetDiscount * promotion.discountAmount * 0.01;
            _discountValue = floorf(_discountValue * 100) * 0.01;
            if(promotion.moreDiscountToGo != -1)
            {
                _discountValue = _discountValue > promotion.moreDiscountToGo?promotion.moreDiscountToGo:_discountValue;
            }
            



            voucherView.lblVoucherCode.text = [NSString stringWithFormat:@"คูปองส่วนลด %@",cell.txtVoucherCode.text];
            [voucherView.lblVoucherCode sizeToFit];
            voucherView.lblVoucherCodeWidthConstant.constant = voucherView.lblVoucherCode.frame.size.width;
            voucherView.lblDiscountAmount.text = [Utility formatDecimal:_discountValue withMinFraction:2 andMaxFraction:2];
            voucherView.lblDiscountAmount.text = [Utility addPrefixBahtSymbol:voucherView.lblDiscountAmount.text];
            voucherView.lblDiscountAmount.text = [NSString stringWithFormat:@"-%@",voucherView.lblDiscountAmount.text];


            NSString *strTotalAmountNet = [Utility formatDecimal:totalAmount-_discountValue withMinFraction:2 andMaxFraction:2];
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
                CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];
                cell.lblAmount.text = [Utility addPrefixBahtSymbol:strTotalAmountNet];
            }
        }

        
        Message *type = typeList[0];
        _promotionOrRewardRedemption = [type.text integerValue];
        _promotionUsed = promotion;        
    }


    //after discount, vat,service charge,net total
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
        CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

        float afterDiscount = totalAmount-_discountValue;
        NSString *strAfterDiscount = [Utility formatDecimal:afterDiscount withMinFraction:2 andMaxFraction:2];
        strAfterDiscount = [Utility addPrefixBahtSymbol:strAfterDiscount];
        cell.lblAmount.text = strAfterDiscount;
    }
    if(branch.serviceChargePercent > 0)
    {
        {
            //service charge
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
            CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

            float afterDiscount = totalAmount-_discountValue;
            float serviceChargeValue;
            if(branch.priceIncludeVat)
            {
                afterDiscount = afterDiscount / ((branch.percentVat+100)*0.01);
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
            }
            else
            {
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
            }

            serviceChargeValue = roundf(serviceChargeValue * 100)/100;
            NSString *strTotal = [Utility formatDecimal:serviceChargeValue withMinFraction:2 andMaxFraction:2];
            strTotal = [Utility addPrefixBahtSymbol:strTotal];
            cell.lblAmount.text = strTotal;
            cell.lblTitle.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.textColor = [UIColor darkGrayColor];
        }
        {
            //vat
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
            CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

            float afterDiscount = totalAmount-_discountValue;
            float serviceChargeValue;
            float vatAmount;
            if(branch.priceIncludeVat)
            {
                afterDiscount = afterDiscount / ((branch.percentVat+100)*0.01);
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = afterDiscount * branch.percentVat * 0.01;
            }
            else
            {
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = (afterDiscount+serviceChargeValue)*branch.percentVat/100;
            }

            vatAmount = roundf(vatAmount*100)/100;
            NSString *strAmount = [Utility formatDecimal:vatAmount withMinFraction:2 andMaxFraction:2];
            strAmount = [Utility addPrefixBahtSymbol:strAmount];
            cell.lblAmount.text = strAmount;
            cell.lblTitle.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.textColor = [UIColor darkGrayColor];
        }
        {
            //net total amount
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:5 inSection:0];
            CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

            float afterDiscount = totalAmount-_discountValue;
            float serviceChargeValue;
            float vatAmount;
            if(branch.priceIncludeVat)
            {
                afterDiscount = afterDiscount / ((branch.percentVat+100)*0.01);
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = afterDiscount * branch.percentVat * 0.01;
            }
            else
            {
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = (afterDiscount+serviceChargeValue)*branch.percentVat/100;
            }

            vatAmount = roundf(vatAmount*100)/100;
            _vatValue = vatAmount;
            _serviceChargeValue = serviceChargeValue;
            float netTotalAmount = afterDiscount+serviceChargeValue+vatAmount;
            NSString *strAmount = [Utility formatDecimal:netTotalAmount withMinFraction:2 andMaxFraction:2];
            strAmount = [Utility addPrefixBahtSymbol:strAmount];
            cell.lblAmount.text = strAmount;
            _netTotal = netTotalAmount;
        }
    }
    else
    {
        {
            //vat
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
            CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

            float afterDiscount = totalAmount-_discountValue;
            float serviceChargeValue;
            float vatAmount;
            if(branch.priceIncludeVat)
            {
                afterDiscount = afterDiscount / ((branch.percentVat+100)*0.01);
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = afterDiscount * branch.percentVat * 0.01;
            }
            else
            {
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = (afterDiscount+serviceChargeValue)*branch.percentVat/100;
            }

            vatAmount = roundf(vatAmount*100)/100;
            NSString *strAmount = [Utility formatDecimal:vatAmount withMinFraction:2 andMaxFraction:2];
            strAmount = [Utility addPrefixBahtSymbol:strAmount];
            cell.lblAmount.text = strAmount;
            cell.lblTitle.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.textColor = [UIColor darkGrayColor];
        }
        {
            //net total amount
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
            CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

            float afterDiscount = totalAmount-_discountValue;
            float serviceChargeValue;
            float vatAmount;
            if(branch.priceIncludeVat)
            {
                afterDiscount = afterDiscount / ((branch.percentVat+100)*0.01);
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = afterDiscount * branch.percentVat * 0.01;
            }
            else
            {
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = (afterDiscount+serviceChargeValue)*branch.percentVat/100;
            }

            vatAmount = roundf(vatAmount*100)/100;
            _vatValue = vatAmount;
            _serviceChargeValue = serviceChargeValue;
            float netTotalAmount = afterDiscount+serviceChargeValue+vatAmount;
            NSString *strAmount = [Utility formatDecimal:netTotalAmount withMinFraction:2 andMaxFraction:2];
            strAmount = [Utility addPrefixBahtSymbol:strAmount];
            cell.lblAmount.text = strAmount;
            _netTotal = netTotalAmount;
        }
    }

}

-(void)deleteVoucher:(id)sender
{
    [voucherView removeFromSuperview];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    CustomTableViewCellVoucherCode *cell = [tbvTotal cellForRowAtIndexPath:indexPath];
    cell.txtVoucherCode.hidden = NO;
    cell.btnConfirmVoucherCode.hidden = NO;
    cell.txtVoucherCode.text = @"";
    _promotionUsed = nil;



    //after discount, vat,service charge,net total
    float totalAmount = [OrderTaking getSumSpecialPrice:_orderTakingList];
    _discountType = 0;
    _discountAmount = 0;
    _discountValue = 0;
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
        CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

        float afterDiscount = totalAmount-_discountValue;
        NSString *strAfterDiscount = [Utility formatDecimal:afterDiscount withMinFraction:2 andMaxFraction:2];
        strAfterDiscount = [Utility addPrefixBahtSymbol:strAfterDiscount];
        cell.lblAmount.text = strAfterDiscount;
    }
    if(branch.serviceChargePercent > 0)
    {
        {
            //service charge
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
            CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

            float afterDiscount = totalAmount-_discountValue;
            float serviceChargeValue;
            if(branch.priceIncludeVat)
            {
                afterDiscount = afterDiscount / ((branch.percentVat+100)*0.01);
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
            }
            else
            {
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
            }

            serviceChargeValue = roundf(serviceChargeValue * 100)/100;
            NSString *strTotal = [Utility formatDecimal:serviceChargeValue withMinFraction:2 andMaxFraction:2];
            strTotal = [Utility addPrefixBahtSymbol:strTotal];
            cell.lblAmount.text = strTotal;
            cell.lblTitle.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.textColor = [UIColor darkGrayColor];
        }
        {
            //vat
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
            CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

            float afterDiscount = totalAmount-_discountValue;
            float serviceChargeValue;
            float vatAmount;
            if(branch.priceIncludeVat)
            {
                afterDiscount = afterDiscount / ((branch.percentVat+100)*0.01);
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = afterDiscount * branch.percentVat * 0.01;
            }
            else
            {
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = (afterDiscount+serviceChargeValue)*branch.percentVat/100;
            }

            vatAmount = roundf(vatAmount*100)/100;
            NSString *strAmount = [Utility formatDecimal:vatAmount withMinFraction:2 andMaxFraction:2];
            strAmount = [Utility addPrefixBahtSymbol:strAmount];
            cell.lblAmount.text = strAmount;
            cell.lblTitle.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.textColor = [UIColor darkGrayColor];
        }
        {
            //net total amount
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:5 inSection:0];
            CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

            float afterDiscount = totalAmount-_discountValue;
            float serviceChargeValue;
            float vatAmount;
            if(branch.priceIncludeVat)
            {
                afterDiscount = afterDiscount / ((branch.percentVat+100)*0.01);
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = afterDiscount * branch.percentVat * 0.01;
            }
            else
            {
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = (afterDiscount+serviceChargeValue)*branch.percentVat/100;
            }

            vatAmount = roundf(vatAmount*100)/100;
            _vatValue = vatAmount;
            _serviceChargeValue = serviceChargeValue;
            float netTotalAmount = afterDiscount+serviceChargeValue+vatAmount;
            NSString *strAmount = [Utility formatDecimal:netTotalAmount withMinFraction:2 andMaxFraction:2];
            strAmount = [Utility addPrefixBahtSymbol:strAmount];
            cell.lblAmount.text = strAmount;
            _netTotal = netTotalAmount;
        }
    }
    else
    {
        {
            //vat
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
            CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

            float afterDiscount = totalAmount-_discountValue;
            float serviceChargeValue;
            float vatAmount;
            if(branch.priceIncludeVat)
            {
                afterDiscount = afterDiscount / ((branch.percentVat+100)*0.01);
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = afterDiscount * branch.percentVat * 0.01;
            }
            else
            {
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = (afterDiscount+serviceChargeValue)*branch.percentVat/100;
            }

            vatAmount = roundf(vatAmount*100)/100;
            NSString *strAmount = [Utility formatDecimal:vatAmount withMinFraction:2 andMaxFraction:2];
            strAmount = [Utility addPrefixBahtSymbol:strAmount];
            cell.lblAmount.text = strAmount;
            cell.lblTitle.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.font = [UIFont systemFontOfSize:15];
            cell.lblAmount.textColor = [UIColor darkGrayColor];
        }
        {
            //net total amount
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
            CustomTableViewCellTotal *cell = [tbvTotal cellForRowAtIndexPath:indexPath];

            float afterDiscount = totalAmount-_discountValue;
            float serviceChargeValue;
            float vatAmount;
            if(branch.priceIncludeVat)
            {
                afterDiscount = afterDiscount / ((branch.percentVat+100)*0.01);
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = afterDiscount * branch.percentVat * 0.01;
            }
            else
            {
                serviceChargeValue = branch.serviceChargePercent * afterDiscount * 0.01;
                serviceChargeValue = roundf(serviceChargeValue * 100)/100;
                vatAmount = (afterDiscount+serviceChargeValue)*branch.percentVat/100;
            }

            vatAmount = roundf(vatAmount*100)/100;
            _vatValue = vatAmount;
            _serviceChargeValue = serviceChargeValue;
            float netTotalAmount = afterDiscount+serviceChargeValue+vatAmount;
            NSString *strAmount = [Utility formatDecimal:netTotalAmount withMinFraction:2 andMaxFraction:2];
            strAmount = [Utility addPrefixBahtSymbol:strAmount];
            cell.lblAmount.text = strAmount;
            _netTotal = netTotalAmount;
        }
    }
}

@end
