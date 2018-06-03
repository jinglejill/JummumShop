//
//  BasketViewController.m
//  Jummum
//
//  Created by Thidaporn Kijkamjai on 22/2/2561 BE.
//  Copyright © 2561 Appxelent. All rights reserved.
//

#import "BasketViewController.h"
#import "NoteViewController.h"
#import "CreditCardAndOrderSummaryViewController.h"
#import "CustomTableViewCellOrder.h"
#import "CustomTableViewCellTotal.h"
#import "CustomTableViewCellNote.h"
#import "CustomTableViewHeaderFooterButton.h"
#import "CustomTableViewCellVoucherCode.h"
#import "Receipt.h"
#import "OrderTaking.h"
#import "OrderNote.h"
#import "Menu.h"
#import "Note.h"
#import "SpecialPriceProgram.h"
#import "Promotion.h"
#import "MenuType.h"


#import "Utility.h"
#import "Setting.h"
#import "OmiseSDK.h"
#import "JummumShop-Swift.h"


@interface BasketViewController ()
{
    NSMutableArray *_orderTakingList;
    OrderTaking *_orderTaking;
    OrderTaking *_copyOrderTaking;
    NSMutableArray *_menuList;
    NSString *_voucherCode;
    
    
    
    Promotion *_promotionUsed;
    float _netTotal;
    NSInteger _discountType;
    float _discountAmount;
    float _discountValue;
    
}
@end

@implementation BasketViewController
static NSString * const reuseIdentifierOrder = @"CustomTableViewCellOrder";
static NSString * const reuseIdentifierTotal = @"CustomTableViewCellTotal";
static NSString * const reuseIdentifierHeaderFooterButton = @"CustomTableViewHeaderFooterButton";
static NSString * const reuseIdentifierNote = @"CustomTableViewCellNote";
static NSString * const reuseIdentifierVoucherCode = @"CustomTableViewCellVoucherCode";


@synthesize tbvOrder;
@synthesize tbvTotal;
@synthesize branch;
@synthesize customerTable;
@synthesize voucherView;
@synthesize tbvTotalHeightConstant;


-(IBAction)unwindToBasket:(UIStoryboardSegue *)segue;
{
    [self.view endEditing:true];
    [tbvOrder reloadData];
    [tbvTotal reloadData];
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
    if(textField.tag == 1)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        return YES;
    }
    
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
        [self.view endEditing:YES];
        return YES;
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        _voucherCode = [Utility trimString:textField.text];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segNote"])
    {
        NoteViewController *vc = segue.destinationViewController;
        vc.noteList = [Note getNoteList];
        vc.orderTaking = _orderTaking;
        vc.branch = branch;
    }
    else if([[segue identifier] isEqualToString:@"segCreditCardAndOrderSummary"])
    {
        CreditCardAndOrderSummaryViewController *vc = segue.destinationViewController;
        vc.branch = branch;
        vc.customerTable = customerTable;        
    }
}

-(void)loadView
{
    [super loadView];
    
    
    NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
    NSMutableArray *menuList = [Menu getMenuListWithOrderTakingList:currentOrderTakingList];
    
    
    for(Menu *item in menuList)
    {
        item.expand = 0;
        NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:item.menuID orderTakingList:currentOrderTakingList];
        for(OrderTaking *orderTaking in orderTakingList)
        {
            if(![Utility isStringEmpty:orderTaking.noteIDListInText] || orderTaking.takeAway)
            {
                item.expand = 1;
                break;
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    tbvOrder.delegate = self;
    tbvOrder.dataSource = self;
    [tbvOrder setSeparatorColor:[UIColor clearColor]];
    tbvOrder.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
    tbvTotal.delegate = self;
    tbvTotal.dataSource = self;
    [tbvTotal setSeparatorColor:[UIColor clearColor]];
    tbvTotal.scrollEnabled = NO;
    
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierOrder bundle:nil];
        [tbvOrder registerNib:nib forCellReuseIdentifier:reuseIdentifierOrder];
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
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
}

///tableview section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    if([tableView isEqual:tbvOrder])
    {
        return 1;
    }
    else if([tableView isEqual:tbvTotal])
    {
        return 1;
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:tbvOrder])
    {
        _orderTakingList = [OrderTaking getCurrentOrderTakingList];
        _menuList = [Menu getMenuListWithOrderTakingList:_orderTakingList];
        return [_menuList count];
    }
    else if([tableView isEqual:tbvTotal])
    {
        tbvTotalHeightConstant.constant = 78;
        return 1;
    }
    else
    {
        NSInteger menuID = tableView.tag;
        NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
        NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:menuID orderTakingList:currentOrderTakingList];
        return [orderTakingList count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    
    if([tableView isEqual:tbvOrder])
    {
        CustomTableViewCellOrder *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierOrder];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        
        Menu *menu = _menuList[item];
        cell.lblMenuName.text = menu.titleThai;
        cell.lblMenuName.tag = menu.menuID;
        
        
        NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
        NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:menu.menuID orderTakingList:currentOrderTakingList];
        float sumQuantity = [OrderTaking getSumQuantity:orderTakingList];
        NSString *strSumQuantity = [Utility formatDecimal:sumQuantity withMinFraction:0 andMaxFraction:0];
        cell.lblQuantity.text = strSumQuantity;
        
        
        
        float totalPrice = [OrderTaking getSumSpecialPrice:orderTakingList];
        NSString *strTotalPrice = [Utility formatDecimal:totalPrice withMinFraction:2 andMaxFraction:2];
        cell.lblTotalPrice.text = strTotalPrice;
        

        
        NSString *imageFileName = [Utility isStringEmpty:menu.imageUrl]?@"NoImage.jpg":menu.imageUrl;
        [self.homeModel downloadImageWithFileName:imageFileName completionBlock:^(BOOL succeeded, UIImage *image)
         {
             if (succeeded)
             {
                 cell.imgMenuPic.image = image;
             }
         }];
        cell.imgMenuPic.contentMode = UIViewContentModeScaleAspectFit;
        
        
        cell.tbvNote.tag = menu.menuID;
        cell.tbvNote.dataSource = self;
        cell.tbvNote.delegate = self;
        [cell.tbvNote setSeparatorColor:[UIColor clearColor]];
        [cell.tbvNote reloadData];
        
        {
            UINib *nib = [UINib nibWithNibName:reuseIdentifierNote bundle:nil];
            [cell.tbvNote registerNib:nib forCellReuseIdentifier:reuseIdentifierNote];
        }
        
        
        
        
        if(menu.expand)
        {
            cell.imgExpandCollapse.image = [UIImage imageNamed:@"collapse2.png"];
        }
        else
        {
            cell.imgExpandCollapse.image = [UIImage imageNamed:@"expand2.png"];
        }
        
        
        cell.stepperValue = sumQuantity;
        cell.btnDeleteQuantity.tag = 201;
        cell.btnAddQuantity.tag = 202;
        [cell.btnDeleteQuantity addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnAddQuantity addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else if([tableView isEqual:tbvTotal])
    {
        _orderTakingList = [OrderTaking getCurrentOrderTakingList];
        switch (item)
        {
            case 0:
            {
                CustomTableViewCellTotal *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTotal];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                
                NSString *strTitle = [NSString stringWithFormat:@"%ld รายการ",[_orderTakingList count]];
                NSString *strTotal = [Utility formatDecimal:[OrderTaking getSumSpecialPrice:_orderTakingList] withMinFraction:2 andMaxFraction:2];
                strTotal = [Utility addPrefixBahtSymbol:strTotal];
                cell.lblTitle.text = strTitle;
                cell.lblAmount.text = strTotal;
                cell.vwTopBorder.hidden = YES;
                
                return  cell;
            }
                break;
            default:
                break;
        }
    }
    else
    {
        NSInteger menuID = tableView.tag;
        
        {
            CustomTableViewCellNote *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierNote];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            cell.lblDishNo.text = [NSString stringWithFormat:@"จานที่ %ld",item+1];
            cell.txtNote.delegate = self;
            
            
        
            //note
            NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
            NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:menuID orderTakingList:currentOrderTakingList];
            OrderTaking *orderTaking;
            if([orderTakingList count]>0)
            {
                orderTaking = orderTakingList[item];
                
                
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
                cell.txtNote.attributedText = strAllNote;
                
                
                float sumNotePrice = [OrderNote getSumNotePriceWithOrderTakingID:orderTaking.orderTakingID];
                NSString *strSumNotePrice = [Utility formatDecimal:sumNotePrice withMinFraction:0 andMaxFraction:0];
                strSumNotePrice = [NSString stringWithFormat:@"+%@",strSumNotePrice];
                cell.lblTotalNotePrice.text = strSumNotePrice;
                if(sumNotePrice == 0)
                {
                    cell.lblTotalNotePrice.text = @"";
                }
            }
            [cell.longPressGestureRecognizer addTarget:self action:@selector(handleLongPress:)];
            [cell.txtNote addGestureRecognizer:cell.longPressGestureRecognizer];
            
            
            
            [cell.doubleTapGestureRecognizer addTarget:self action:@selector(handleDoubleTap:)];
            [cell.txtNote addGestureRecognizer:cell.doubleTapGestureRecognizer];
            cell.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
            [cell.singleTapGestureRecognizer addTarget:self action:@selector(handleSingleTap:)];
            [cell.txtNote addGestureRecognizer:cell.singleTapGestureRecognizer];
            cell.singleTapGestureRecognizer.numberOfTapsRequired = 1;
            [cell.singleTapGestureRecognizer requireGestureRecognizerToFail:cell.doubleTapGestureRecognizer];
            
            
            
            
            
            cell.btnDelete.tag = item;
            [cell.btnDelete addTarget:self action:@selector(deleteNote:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnDelete addTarget:self action:@selector(deleteNoteTouchDown:) forControlEvents:UIControlEventTouchDown];
            
            
            
            cell.btnTakeAway.tag = item;
            [cell.btnTakeAway addTarget:self action:@selector(takeAway:) forControlEvents:UIControlEventTouchUpInside];
            if(orderTaking.takeAway)
            {
                UIImage *image = [UIImage imageNamed:@"takeAway2.png"];
                [cell.btnTakeAway setBackgroundImage:image forState:UIControlStateNormal];
            }
            else
            {
                UIImage *image = [UIImage imageNamed:@"takeAwayGrayOut.png"];
                [cell.btnTakeAway setBackgroundImage:image forState:UIControlStateNormal];
            }
            
            
            return cell;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    
    if([tableView isEqual:tbvOrder])
    {
        Menu *menu = _menuList[item];
        
        
        
        NSString *strMenuName;
//        if(orderTaking.takeAway)
//        {
//            strMenuName = [NSString stringWithFormat:@"ใส่ห่อ %@",menu.titleThai];
//        }
//        else
        {
            strMenuName = menu.titleThai;
        }
        
        
        
        
        UIFont *fontMenuName = [UIFont systemFontOfSize:14.0];
        CGSize menuNameLabelSize = [self suggestedSizeWithFont:fontMenuName size:CGSizeMake(tbvOrder.frame.size.width - 70 - 68 - 8*2 - 16*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping forString:strMenuName];
        

        
        
        float height = menuNameLabelSize.height+11;
        height = height < 90? 90:height;
        
        
        
        NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
        NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:menu.menuID orderTakingList:currentOrderTakingList];
        height = menu.expand?height+([orderTakingList count])*44:height;
        
        
        return height;
        
    }
    else if([tableView isEqual:tbvTotal])
    {
        return 34;
//        return item == 1?56:26;
    }
    else
    {
        return 44;
    }
    
    return 0;
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
    

    if([tableView isEqual:tbvOrder])
    {
        Menu *menu = _menuList[item];
        menu.expand = !menu.expand;
        
        
        
        
        [tbvOrder reloadData];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if([tableView isEqual:tbvTotal])
    {
        CustomTableViewHeaderFooterButton *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifierHeaderFooterButton];
        
        
        [footerView.btnValue setTitle:@"CHECK OUT" forState:UIControlStateNormal];
        [footerView.btnValue addTarget:self action:@selector(checkOut:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
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

- (IBAction)unwindToMenuSelection:(id)sender
{
    [self performSegueWithIdentifier:@"segUnwindToMenuSelection" sender:self];
}

- (IBAction)deleteAll:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"ลบทั้งหมด"
                              style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
      {
          [OrderTaking removeCurrentOrderTakingList];
          [tbvOrder reloadData];
          [tbvTotal reloadData];
          
      }]];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"ยกเลิก"
                              style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
      {
      }]];
    
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)stepperValueChanged:(id)sender
{
    UIButton *button = sender;
    
    CGPoint point = [sender convertPoint:CGPointZero toView:tbvOrder];
    NSIndexPath *indexPath = [tbvOrder indexPathForRowAtPoint:point];
    CustomTableViewCellOrder *cell = [tbvOrder cellForRowAtIndexPath:indexPath];
    if(button.tag == 201)
    {
        NSInteger quantity = [cell.lblQuantity.text integerValue]-1;
        cell.lblQuantity.text = [Utility formatDecimal:quantity withMinFraction:0 andMaxFraction:0];
        
        
        //remove ordertaking
        NSInteger menuID = cell.lblMenuName.tag;
        NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
        NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:menuID orderTakingList:currentOrderTakingList];
        OrderTaking *lastOrderTaking = orderTakingList[[orderTakingList count]-1];
        [OrderTaking removeObject:lastOrderTaking];
        [currentOrderTakingList removeObject:lastOrderTaking];
        
        
        //remove orderNote
        NSMutableArray *orderNoteList = [OrderNote getOrderNoteListWithOrderTakingID:lastOrderTaking.orderTakingID];
        [OrderNote removeList:orderNoteList];
        
        

        [tbvOrder reloadData];
        [tbvTotal reloadData];
        [self blinkRemovedNotiView];
    }
    else if(button.tag == 202)
    {
        NSInteger quantity = [cell.lblQuantity.text integerValue]+1;
        cell.lblQuantity.text = [Utility formatDecimal:quantity withMinFraction:0 andMaxFraction:0];
        
        
        //add ordertaking
        NSInteger menuID = cell.lblMenuName.tag;
        Menu *menu = [Menu getMenu:menuID branchID:branch.branchID];
        SpecialPriceProgram *specialPriceProgram = [SpecialPriceProgram getSpecialPriceProgramTodayWithMenuID:menuID branchID:branch.branchID];
        float specialPrice = specialPriceProgram?specialPriceProgram.specialPrice:menu.price;
        
        
        NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
        OrderTaking *orderTaking = [[OrderTaking alloc]initWithBranchID:branch.branchID customerTableID:customerTable.customerTableID menuID:menuID quantity:1 specialPrice:specialPrice price:menu.price takeAway:0 noteIDListInText:@"" orderNo:0 status:1 receiptID:0];
        [OrderTaking addObject:orderTaking];
        [currentOrderTakingList addObject:orderTaking];

        
        
                
        [tbvOrder reloadData];
        [tbvTotal reloadData];
        [self blinkAddedNotiView];
    }

}

-(void)deleteNote:(id)sender
{
    UIButton *button = sender;
    NSInteger item = button.tag;
    CGPoint point = [sender convertPoint:CGPointZero toView:tbvOrder];
    NSIndexPath *indexPath = [tbvOrder indexPathForRowAtPoint:point];
    
    
    
    Menu *menu = _menuList[indexPath.item];
    NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
    NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:menu.menuID orderTakingList:currentOrderTakingList];
    OrderTaking *orderTaking = orderTakingList[item];
    
    

    NSMutableArray *orderNoteList = [OrderNote getOrderNoteListWithOrderTakingID:orderTaking.orderTakingID];
    [OrderNote removeList:orderNoteList];
    
    
    
    float takeAwayFee = orderTaking.takeAway?[[Setting getSettingValueWithKeyName:@"takeAwayFee"] floatValue]:0;
    SpecialPriceProgram *specialPriceProgram = [SpecialPriceProgram getSpecialPriceProgramTodayWithMenuID:menu.menuID branchID:branch.branchID];
    float specialPrice = specialPriceProgram?specialPriceProgram.specialPrice:menu.price;
    float sumNotePrice = [OrderNote getSumNotePriceWithOrderTakingID:orderTaking.orderTakingID];
    orderTaking.price = menu.price+sumNotePrice+takeAwayFee;
    orderTaking.specialPrice = specialPrice+sumNotePrice+takeAwayFee;
    orderTaking.modifiedUser = [Utility modifiedUser];
    orderTaking.modifiedDate = [Utility currentDateTime];
    
    [tbvOrder reloadData];
}

- (void)deleteNoteTouchDown:(id)sender
{
    UIButton *button = sender;
    [button setImage:[UIImage imageNamed:@"remove light color.png"] forState:UIControlStateNormal];
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [button setImage:[UIImage imageNamed:@"remove.png"] forState:UIControlStateNormal];
    });
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:tbvOrder];
    NSIndexPath * tappedIP = [tbvOrder indexPathForRowAtPoint:point];
    CustomTableViewCellOrder *cell = [tbvOrder cellForRowAtIndexPath:tappedIP];

    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"คัดลอก"
                              style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
      {
        
          Menu *menu = _menuList[tappedIP.item];
          NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
          NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:menu.menuID orderTakingList:currentOrderTakingList];
          
          
          {
              CGPoint point = [gestureRecognizer locationInView:cell.tbvNote];
              NSIndexPath * tappedIP = [cell.tbvNote indexPathForRowAtPoint:point];
              _copyOrderTaking = orderTakingList[tappedIP.item];
          }
          
          
      }]];
    
    [alert addAction:
     [UIAlertAction actionWithTitle:@"ยกเลิก"
                              style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
      {
      }]];
    
    UIAlertAction *pasteHowTo = [UIAlertAction actionWithTitle:@"Double tap at note to paste"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction *action)
                                 {
                                 }];
    [pasteHowTo setValue:[UIColor grayColor] forKey:@"titleTextColor"];
    [alert addAction:pasteHowTo];
    
    

    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:tbvOrder];
    NSIndexPath * tappedIP = [tbvOrder indexPathForRowAtPoint:point];
    CustomTableViewCellOrder *cell = [tbvOrder cellForRowAtIndexPath:tappedIP];
    
    
    Menu *menu = _menuList[tappedIP.item];
    NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
    NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:menu.menuID orderTakingList:currentOrderTakingList];
    OrderTaking *orderTaking;
    {
        CGPoint point = [gestureRecognizer locationInView:cell.tbvNote];
        NSIndexPath * tappedIP = [cell.tbvNote indexPathForRowAtPoint:point];
        orderTaking = orderTakingList[tappedIP.item];
    }
    
    
    
    if(_copyOrderTaking && ![orderTaking isEqual:_copyOrderTaking])
    {
        //remove current note
        NSMutableArray *currentOrderNoteList = [OrderNote getOrderNoteListWithOrderTakingID:orderTaking.orderTakingID];
        [OrderNote removeList:currentOrderNoteList];
        
        
        //add note
        NSMutableArray *orderNoteList = [OrderNote getOrderNoteListWithOrderTakingID:_copyOrderTaking.orderTakingID];
        for(OrderNote *item in orderNoteList)
        {
            OrderNote *orderNote = [item copy];
            orderNote.orderNoteID = [OrderNote getNextID];
            orderNote.orderTakingID = orderTaking.orderTakingID;
            [OrderNote addObject:orderNote];
        }
        
        
        
        
        //update note id list in text
        orderTaking.noteIDListInText = [OrderNote getNoteIDListInTextWithOrderTakingID:orderTaking.orderTakingID];
        
        
        //update ordertaking price
        float takeAwayFee = orderTaking.takeAway?[[Setting getSettingValueWithKeyName:@"takeAwayFee"] floatValue]:0;
        SpecialPriceProgram *specialPriceProgram = [SpecialPriceProgram getSpecialPriceProgramTodayWithMenuID:menu.menuID branchID:branch.branchID];
        float specialPrice = specialPriceProgram?specialPriceProgram.specialPrice:menu.price;
        float sumNotePrice = [OrderNote getSumNotePriceWithOrderTakingID:orderTaking.orderTakingID];
        orderTaking.price = menu.price+sumNotePrice+takeAwayFee;
        orderTaking.specialPrice = specialPrice+sumNotePrice+takeAwayFee;
        orderTaking.modifiedUser = [Utility modifiedUser];
        orderTaking.modifiedDate = [Utility currentDateTime];
        
        [tbvOrder reloadData];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:tbvOrder];
    NSIndexPath * tappedIP = [tbvOrder indexPathForRowAtPoint:point];
    CustomTableViewCellOrder *cell = [tbvOrder cellForRowAtIndexPath:tappedIP];

    
    
    Menu *menu = _menuList[tappedIP.item];
    NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
    NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:menu.menuID orderTakingList:currentOrderTakingList];
    {
        CGPoint point = [gestureRecognizer locationInView:cell.tbvNote];
        NSIndexPath * tappedIP = [cell.tbvNote indexPathForRowAtPoint:point];
        _orderTaking = orderTakingList[tappedIP.item];
    }

    
    
    if([_copyOrderTaking isEqual:_orderTaking])
    {
        _copyOrderTaking = nil;
    }
    [self performSegueWithIdentifier:@"segNote" sender:self];
}

-(void)checkOut:(id)sender
{    
    [self performSegueWithIdentifier:@"segCreditCardAndOrderSummary" sender:self];
}

-(void)takeAway:(id)sender
{
    UIButton *button = sender;
    NSInteger item = button.tag;
    CGPoint point = [sender convertPoint:CGPointZero toView:tbvOrder];
    NSIndexPath *indexPath = [tbvOrder indexPathForRowAtPoint:point];
    
    
    
    Menu *menu = _menuList[indexPath.item];
    NSMutableArray *currentOrderTakingList = [OrderTaking getCurrentOrderTakingList];
    NSMutableArray *orderTakingList = [OrderTaking getOrderTakingListWithMenuID:menu.menuID orderTakingList:currentOrderTakingList];
    OrderTaking *orderTaking = orderTakingList[item];
    
    
    
    
    orderTaking.takeAway = !orderTaking.takeAway;
    float takeAwayFee = orderTaking.takeAway?branch.takeAwayFee:0;
    SpecialPriceProgram *specialPriceProgram = [SpecialPriceProgram getSpecialPriceProgramTodayWithMenuID:menu.menuID branchID:branch.branchID];
    float specialPrice = specialPriceProgram?specialPriceProgram.specialPrice:menu.price;
    float sumNotePrice = [OrderNote getSumNotePriceWithOrderTakingID:orderTaking.orderTakingID];
    orderTaking.price = menu.price+sumNotePrice+takeAwayFee;
    orderTaking.specialPrice = specialPrice+sumNotePrice+takeAwayFee;
    orderTaking.modifiedUser = [Utility modifiedUser];
    orderTaking.modifiedDate = [Utility currentDateTime];

    

    if(orderTaking.takeAway)
    {
        UIImage *image = [UIImage imageNamed:@"takeAway2.png"];
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
    else
    {
        UIImage *image = [UIImage imageNamed:@"takeAwayGrayOut.png"];
        [button setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    [tbvTotal reloadData];
}
@end
