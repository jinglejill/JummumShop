//
//  LogInViewController.m
//  Jummum
//
//  Created by Thidaporn Kijkamjai on 17/2/2561 BE.
//  Copyright © 2561 Appxelent. All rights reserved.
//

#import "LogInViewController.h"
#import "TermsOfServiceViewController.h"
#import "CustomerKitchenViewController.h"
#import "MainTabBarController.h"
#import "MeViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


#import "LogIn.h"
#import "UserAccount.h"
#import "Setting.h"
#import "Utility.h"
#import "FacebookComment.h"


@interface LogInViewController ()
{
    FBSDKLoginButton *_loginButton;
    BOOL _faceBookLogIn;
    BOOL _appLogIn;
    BOOL _rememberMe;
    NSString *_username;
    NSMutableArray *allComments;
}
@end

@implementation LogInViewController
@synthesize txtEmail;
@synthesize txtPassword;
@synthesize btnRememberMe;
@synthesize btnLogIn;
@synthesize credentialsDb;
@synthesize imgVwValueHeight;
@synthesize lblOrBottom;
@synthesize imgVwLogoText;
@synthesize lblLogInTop;


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    imgVwValueHeight.constant = self.view.frame.size.width/375*255;
    float bottom = imgVwValueHeight.constant+20+30+11;
    lblOrBottom.constant = bottom;
    
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    float bottomPadding = window.safeAreaInsets.bottom;
    float topPadding = window.safeAreaInsets.top;
    _loginButton.center = self.view.center;
    CGRect frame = _loginButton.frame;
    frame.origin.y = self.view.frame.size.height - bottomPadding - bottom + 11;//frame.origin.y + 33;
    _loginButton.frame = frame;
    
    
    
    lblLogInTop.constant = 7 + bottomPadding;
    if(bottom+286+40>self.view.frame.size.height)
    {
        //hide jummum text
        imgVwLogoText.hidden = YES;
    }
}

- (IBAction)rememberMe:(id)sender
{
    _rememberMe = !_rememberMe;
    if(_rememberMe)
    {
        NSString *message = [Setting getValue:@"056m" example:@"◼︎ จำฉันไว้ในระบบ"];
        [btnRememberMe setTitle:message forState:UIControlStateNormal];
    }
    else
    {
        NSString *message = [Setting getValue:@"055m" example:@"◻︎ จำฉันไว้ในระบบ"];
        [btnRememberMe setTitle:message forState:UIControlStateNormal];
    }
}

- (IBAction)logIn:(id)sender
{

    txtEmail.text = [Utility trimString:txtEmail.text];
    txtPassword.text = [Utility trimString:txtPassword.text];
    [Utility setModifiedUser:txtEmail.text];
    
    
    UserAccount *userAccount = [[UserAccount alloc]init];
    userAccount.username = txtEmail.text;
    userAccount.password = [Utility hashTextSHA256:txtPassword.text];
    
    
    LogIn *logIn = [[LogIn alloc]initWithUsername:userAccount.username status:1 deviceToken:[Utility deviceToken]];
    [self.homeModel insertItems:dbUserAccountValidate withData:@[userAccount,logIn] actionScreen:@"validate userAccount"];
    [self loadingOverlayView];
    
}

- (IBAction)registerNow:(id)sender
{
    [self performSegueWithIdentifier:@"segRegisterNow" sender:self];
}

- (IBAction)forgotPassword:(id)sender
{
    [self performSegueWithIdentifier:@"segForgotPassword" sender:self];
}

-(IBAction)unwindToLogIn:(UIStoryboardSegue *)segue
{
    if([segue.sourceViewController isMemberOfClass:[TermsOfServiceViewController class]])
    {        
        [FBSDKAccessToken setCurrentAccessToken:nil];
    }
    else if([segue.sourceViewController isMemberOfClass:[MeViewController class]])
    {
        NSString *message = [Setting getValue:@"055m" example:@"◻︎ จำฉันไว้ในระบบ"];
        [btnRememberMe setTitle:message forState:UIControlStateNormal];
        _rememberMe = NO;
        
        
        txtEmail.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"rememberEmail"];
        txtPassword.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"rememberPassword"];
    }
    
    
    if (![FBSDKAccessToken currentAccessToken])
    {
        _faceBookLogIn = NO;
    }
    if(![[NSUserDefaults standardUserDefaults] integerForKey:@"logInSession"])
    {
        _appLogIn = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    [self setButtonDesign:btnLogIn];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"rememberMe"])
    {
        NSString *message = [Setting getValue:@"056m" example:@"◼︎ จำฉันไว้ในระบบ"];
        [btnRememberMe setTitle:message forState:UIControlStateNormal];
        _rememberMe = YES;
        
        
        txtEmail.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"rememberEmail"];
        txtPassword.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"rememberPassword"];
        
    }
    else
    {
        NSString *message = [Setting getValue:@"055m" example:@"◻︎ จำฉันไว้ในระบบ"];
        [btnRememberMe setTitle:message forState:UIControlStateNormal];
        _rememberMe = NO;
    }
    
    
    
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if(!error)
    {
        if ([FBSDKAccessToken currentAccessToken])
        {
            _faceBookLogIn = YES;
        }
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_faceBookLogIn)
    {
        [self insertUserLoginAndUserAccount];
    }
    else if(_appLogIn)
    {
        [self logIn:btnLogIn];
    }
}

//facebook
-(void)insertUserLoginAndUserAccount
{
    NSLog(@"insert user log in");
//    if(_faceBookLogIn)
    {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"location,email,name,first_name,gender,age_range,birthday,friends,likes"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error)
             {
                 
                 NSLog(@"fetched user:%@", result);
                 NSLog(@"birthday:%@",result[@"birthday"]);
                 NSDate *birthday = [Utility stringToDate:result[@"birthday"] fromFormat:@"dd/MM/yyyy"];
                 
                 //1.insert userlogin
                 //2.insert useraccount if not exist
                 NSString *modifiedUser = [NSString stringWithFormat:@"%@",result[@"id"]];
                 [Utility setModifiedUser:modifiedUser];
                 LogIn *logIn = [[LogIn alloc]initWithUsername:result[@"id"] status:1 deviceToken:[Utility deviceToken]];
                 UserAccount *userAccount = [[UserAccount alloc]initWithUsername:result[@"id"] password:txtPassword.text deviceToken:[Utility deviceToken] fullName:result[@"name"] nickName:@"" birthDate:birthday email:result[@"email"] phoneNo:@"" lineID:@"" roleID:0];
                 [self.homeModel insertItems:dbLogInUserAccount withData:@[logIn,userAccount] actionScreen:@"insert login and useraccount if not exist in logIn screen"];
                 [self loadingOverlayView];
             }
             else
             {
                 NSString *message = [Setting getValue:@"057m" example:@"There is problem with facebook login, please try again"];
                 [self showAlert:@"" message:message];
                 NSLog(@"test error: %@",error.description);
             }
         }];
    }
}

//app logIn
-(void)itemsInsertedWithReturnData:(NSArray *)items;
{
    [self removeOverlayViews];
    if(self.homeModel.propCurrentDBInsert == dbUserAccountValidate)
    {
        if([items count] > 0 && [items[0] count] == 0)
        {
            NSString *message = [Setting getValue:@"058m" example:@"อีเมล/พาสเวิร์ด ไม่ถูกต้อง"];
            [self showAlert:@"" message:message];
        }
        else
        {
            //insert useraccount,receipt,ordertaking,ordernote,menu to sharedObject
            NSMutableArray *userAccountList = items[0];
            [UserAccount setCurrentUserAccount:userAccountList[0]];
            [Utility addToSharedDataList:items];
            
    
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"logInSession"];
            [[NSUserDefaults standardUserDefaults] setInteger:_rememberMe forKey:@"rememberMe"];
            if(_rememberMe)
            {
                [[NSUserDefaults standardUserDefaults] setValue:txtEmail.text forKey:@"rememberEmail"];
                [[NSUserDefaults standardUserDefaults] setValue:txtPassword.text forKey:@"rememberPassword"];
            }
            
            
            
            //show terms of service
            NSDictionary *dicTosAgree = [[NSUserDefaults standardUserDefaults] valueForKey:@"tosAgree"];
            if(dicTosAgree)
            {
                NSString *username;
                {
                    username = txtEmail.text;
                    NSNumber *tosAgree = [dicTosAgree objectForKey:username];
                    if(!tosAgree)
                    {
                        [self performSegueWithIdentifier:@"segTermsOfService" sender:self];
                    }
                    else
                    {                        
                        [self performSegueWithIdentifier:@"segCustomerKitchen" sender:self];
                    }
                }
            }
            else
            {
                [self performSegueWithIdentifier:@"segTermsOfService" sender:self];
            }
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segTermsOfService"])
    {
        TermsOfServiceViewController *vc = segue.destinationViewController;
        vc.credentialsDb = credentialsDb;
        if(_faceBookLogIn)
        {
            vc.username = [[FBSDKAccessToken currentAccessToken] userID];
        }
        else
        {
            vc.username = txtEmail.text;
        }
    }
    else if([segue.identifier isEqualToString:@"segCustomerKitchen"])
    {
        MainTabBarController *vc = segue.destinationViewController;
        vc.credentialsDb = credentialsDb;
    }
}


@end

