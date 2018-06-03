//
//  TosAndPrivacyPolicyViewController.h
//  Jummum
//
//  Created by Thidaporn Kijkamjai on 3/4/2561 BE.
//  Copyright © 2561 Appxelent. All rights reserved.
//

#import "CustomViewController.h"
#import <WebKit/WebKit.h>


@interface TosAndPrivacyPolicyViewController : CustomViewController
@property (strong, nonatomic) IBOutlet UIView *webViewContainer;
@property (strong, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (nonatomic) NSInteger pageType;
- (IBAction)goBack:(id)sender;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *webViewContainerTrailing;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *webViewContainerBottom;
@end
