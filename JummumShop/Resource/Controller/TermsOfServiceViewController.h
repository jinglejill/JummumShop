//
//  TermsOfServiceViewController.h
//  Jummum
//
//  Created by Thidaporn Kijkamjai on 3/4/2561 BE.
//  Copyright © 2561 Appxelent. All rights reserved.
//

#import "CustomViewController.h"
#import "CredentialsDb.h"
#import <WebKit/WebKit.h>


@interface TermsOfServiceViewController : CustomViewController
@property (strong, nonatomic) IBOutlet UIView *webViewContainer;
@property (strong, nonatomic) IBOutlet UIButton *btnAccept;
@property (strong, nonatomic) IBOutlet UIButton *btnDecline;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnAcceptWidthConstant;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnDeclineWidthConstant;
@property (nonatomic) NSString *username;
@property (strong, nonatomic) CredentialsDb *credentialsDb;
- (IBAction)goBack:(id)sender;
- (IBAction)acceptTos:(id)sender;
- (IBAction)declineTos:(id)sender;



@end
