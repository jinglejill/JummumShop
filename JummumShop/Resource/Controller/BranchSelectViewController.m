//
//  BranchSelectViewController.m
//  FFD
//
//  Created by Thidaporn Kijkamjai on 7/2/2561 BE.
//  Copyright © 2561 Appxelent. All rights reserved.
//

#import "BranchSelectViewController.h"
#import "LogInViewController.h"
#import "CredentialsDb.h"
#import "Device.h"
#import "PushSync.h"


//extern NSArray *globalMessage;
@interface BranchSelectViewController ()
{
    NSInteger _selectedIndexPicker;
    CredentialsDb *_credentialsDb;
}
@end

@implementation BranchSelectViewController
@synthesize credentialsDbList;
@synthesize pickerVw;
@synthesize btnOk;
@synthesize txtBranch;
@synthesize progressBar;


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CredentialsDb *credentialsDb = credentialsDbList[_selectedIndexPicker];
    textField.text = credentialsDb.name;
    [pickerVw selectRow:_selectedIndexPicker inComponent:0 animated:NO];
}

-(void)loadView
{
    [super loadView];

    
    [pickerVw removeFromSuperview];
    txtBranch.delegate = self;
    txtBranch.inputView = pickerVw;
    pickerVw.delegate = self;
    pickerVw.dataSource = self;
    pickerVw.showsSelectionIndicator = YES;
    
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"])
    {
        NSString *dbName = [[NSUserDefaults standardUserDefaults] stringForKey:BRANCH];
        NSString *branchName = [CredentialsDb getNameWithDbName:dbName credentialsDbList:credentialsDbList];
        _selectedIndexPicker = [CredentialsDb getSelectedIndexWithDbName:dbName credentialsDbList:credentialsDbList];
        txtBranch.text = branchName;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    {
        CGRect frame = progressBar.frame;
        frame.size.width = self.view.frame.size.width-200;
        progressBar.frame = frame;
    }
    progressBar.center = self.view.center;
    
    {
        CGRect frame = progressBar.frame;
        frame.origin.y = self.view.frame.size.height-20;
        progressBar.frame = frame;
    }
    
    [self.view addSubview:progressBar];
    [self setButtonDesign:btnOk];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    // Handle the selection
    
    if([txtBranch isFirstResponder])
    {
        _selectedIndexPicker = row;
        CredentialsDb *credentialsDb = credentialsDbList[row];
        txtBranch.text = credentialsDb.name;
        [txtBranch resignFirstResponder];
    }
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([txtBranch isFirstResponder])
    {
        return [credentialsDbList count];
    }
    
    return 0;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strText = @"";
    if([txtBranch isFirstResponder])
    {
        CredentialsDb *credentialsDb = credentialsDbList[row];
        strText = credentialsDb.name;
    }
    
    return strText;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *strText = @"";
    if([txtBranch isFirstResponder])
    {
        CredentialsDb *credentialsDb = credentialsDbList[row];
        strText = credentialsDb.name;
    }
    
    UILabel *label = [[UILabel alloc]init];
    label.text = strText;
    label.font = [UIFont fontWithName:@"Prompt-Regular" size:15.0f];
    
    
    return label;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.view.frame.size.width;
}

- (IBAction)okAction:(id)sender
{
    NSString *dbName = [[NSUserDefaults standardUserDefaults] stringForKey:BRANCH];
    _credentialsDb = credentialsDbList[_selectedIndexPicker];
    [Utility setBranchID:_credentialsDb.branchID];
    
    
    if(![dbName isEqualToString:_credentialsDb.dbName])
    {
        [[NSUserDefaults standardUserDefaults] setValue:_credentialsDb.dbName forKey:BRANCH];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"logInUsername"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"logInPassword"];
        [[NSUserDefaults standardUserDefaults] setBool:0 forKey:@"rememberMe"];
    }
    
    


    //insert device for pushNotification to update data in the same branch, so delete deviceToken that stay in other db(เพราะได้ switch มาใช้ branch นี้แล้ว)
    Device *device = [[Device alloc]init];
    device.deviceToken = [Utility deviceToken];
    device.remark = [self deviceName];
    [self.homeModel insertItems:dbDevice withData:device actionScreen:@"Add device in branchSelect screen"];

}

-(void)itemsInserted
{
    [self downloadData];
}

- (void)downloadData
{
    [self.homeModel downloadItems:dbMasterWithProgressBar];
}

- (void)itemsDownloaded:(NSArray *)items
{
    if([items count] == 0)
    {
        NSString *title = @"Warning";
        NSString *message = @"Memory fail";
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message                                                                    preferredStyle:UIAlertControllerStyleAlert];
        
        
        NSMutableAttributedString *attrStringTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [attrStringTitle addAttribute:NSFontAttributeName
                                value:[UIFont fontWithName:@"Prompt-SemiBold" size:22]
                                range:NSMakeRange(0, title.length)];
        [attrStringTitle addAttribute:NSForegroundColorAttributeName
                                value:cSystem4
                                range:NSMakeRange(0, title.length)];
        [alert setValue:attrStringTitle forKey:@"attributedTitle"];
        
        
        NSMutableAttributedString *attrStringMsg = [[NSMutableAttributedString alloc] initWithString:message];
        [attrStringMsg addAttribute:NSFontAttributeName
                              value:[UIFont fontWithName:@"Prompt-Regular" size:15]
                              range:NSMakeRange(0, message.length)];
        [attrStringTitle addAttribute:NSForegroundColorAttributeName
                                value:cSystem4
                                range:NSMakeRange(0, title.length)];
        [alert setValue:attrStringMsg forKey:@"attributedMessage"];
        
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                        {
                                            
                                        }];
        [alert addAction:defaultAction];
        dispatch_async(dispatch_get_main_queue(),^ {
            [self presentViewController:alert animated:YES completion:nil];
            
            
            UIFont *font = [UIFont fontWithName:@"Prompt-SemiBold" size:15];
            UIColor *color = cSystem1;
            NSDictionary *attribute = @{NSForegroundColorAttributeName:color ,NSFontAttributeName: font};
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"OK" attributes:attribute];
            
            UILabel *label = [[defaultAction valueForKey:@"__representer"] valueForKey:@"label"];
            label.attributedText = attrString;
            
        } );
        return;
    }


    [Utility itemsDownloaded:items];
    [self removeOverlayViews];//อาจ มีการเรียกจากหน้า customViewController


    [self performSegueWithIdentifier:@"segSignIn" sender:self];
}

- (void)downloadProgress:(float)percent
{
    progressBar.progress = percent;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LogInViewController *vc = segue.destinationViewController;
    vc.credentialsDb = _credentialsDb;
}
@end
