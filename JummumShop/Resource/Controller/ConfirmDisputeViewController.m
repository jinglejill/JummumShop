//
//  ConfirmDisputeViewController.m
//  Jummum2
//
//  Created by Thidaporn Kijkamjai on 10/5/2561 BE.
//  Copyright © 2561 Appxelent. All rights reserved.
//

#import "ConfirmDisputeViewController.h"
#import "DisputeFormViewController.h"
#import "Setting.h"


@interface ConfirmDisputeViewController ()

@end

@implementation ConfirmDisputeViewController
@synthesize lblDisputeMessage;
@synthesize vwAlertHeight;
@synthesize lblDisputeMessageHeight;
@synthesize vwAlert;
@synthesize fromType;
@synthesize receipt;
@synthesize btnConfirm;
@synthesize btnCancel;


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    lblDisputeMessageHeight.constant = lblDisputeMessage.frame.size.height;
    vwAlertHeight.constant = 80+38+38+44+lblDisputeMessage.frame.size.height;
    [self setButtonDesign:btnConfirm];
    [self setButtonDesign:btnCancel];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    
    CGFloat red, green, blue, alpha;
    UIColor *color = self.view.backgroundColor;
    
    [color getRed: &red
            green: &green
             blue: &blue
            alpha: &alpha];
    NSLog(@"red = %f. Green = %f. Blue = %f. Alpha = %f",
          red,
          green,
          blue,
          alpha);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSString *strMessageHeader;
    NSString *strMessageSubTitle;
    if(fromType == 1)
    {
        strMessageHeader = [Setting getSettingValueWithKeyName:@"MessageHeaderCancel"];
        strMessageSubTitle = [Setting getSettingValueWithKeyName:@"MessageSubTitleCancel"];
    }
    else
    {
        strMessageHeader = [Setting getSettingValueWithKeyName:@"MessageHeaderDispute"];
        strMessageSubTitle = [Setting getSettingValueWithKeyName:@"MessageSubTitleDispute"];
    }
    UIFont *font = [UIFont fontWithName:@"Prompt-SemiBold" size:22];
    UIColor *color = cSystem4;
    NSDictionary *attribute = @{NSForegroundColorAttributeName:color ,NSFontAttributeName: font};
    NSMutableAttributedString *attrStringHeader = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n",strMessageHeader] attributes:attribute];
    
    
    UIFont *font2 = [UIFont fontWithName:@"Prompt-Regular" size:15];
    UIColor *color2 = cSystem4;
    NSDictionary *attribute2 = @{NSForegroundColorAttributeName:color2 ,NSFontAttributeName: font2};
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:strMessageSubTitle attributes:attribute2];
    
    
    [attrStringHeader appendAttributedString:attrString];
    
    
    
    lblDisputeMessage.attributedText = attrStringHeader;
    [lblDisputeMessage sizeToFit];
    
    
    vwAlert.layer.cornerRadius = 10;
    vwAlert.layer.masksToBounds = YES;
}

- (IBAction)yesDispute:(id)sender
{
    if(fromType == 1)
    {
        self.homeModel = [[HomeModel alloc]init];
        self.homeModel.delegate = self;
        
        
        [self loadingOverlayView];
        [self.homeModel downloadItems:dbReceipt withData:receipt];
    }
    else
    {
        [self performSegueWithIdentifier:@"segDisputeForm" sender:self];
    }
}

- (IBAction)noDispute:(id)sender
{
    [self performSegueWithIdentifier:@"segUnwindToOrderDetail" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segDisputeForm"])
    {
        DisputeFormViewController *vc = segue.destinationViewController;
        vc.fromType = fromType;
        vc.receipt = receipt;
    }
}

-(void)itemsDownloaded:(NSArray *)items
{
    if(self.homeModel.propCurrentDB == dbReceipt)
    {
        [self removeOverlayViews];
        NSMutableArray *receiptList = items[0];
        Receipt *downloadReceipt = receiptList[0];
        if(downloadReceipt.status == 5 || downloadReceipt.status == 6)
        {
            receipt.status = downloadReceipt.status;
            receipt.statusRoute = downloadReceipt.statusRoute;
            NSString *strMessage = downloadReceipt.status == 5?@"ร้านค้ากำลังปรุงอาหารให้คุณอยู่ค่ะ โปรดรอสักครู่นะคะ":@"อาหารได้ส่งถึงคุณแล้วค่ะ";
            [self showAlert:@"" message:strMessage method:@selector(noDispute:)];            
        }
        else
        {
            [self performSegueWithIdentifier:@"segDisputeForm" sender:self];
        }
    }
}
@end
