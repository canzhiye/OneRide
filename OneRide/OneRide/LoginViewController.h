//
//  LoginViewController.h
//  OneRide
//
//  Created by Canzhi Ye on 8/18/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *uberUsernameTextfield;
@property (nonatomic, strong) IBOutlet UITextField *uberPasswordTextfield;

@property (nonatomic, strong) IBOutlet UITextField *sidecarUsernameTextfield;
@property (nonatomic, strong) IBOutlet UITextField *sidecarPasswordTextfield;

@property (nonatomic, strong) IBOutlet UITextField *summonUsernameTextfield;
@property (nonatomic, strong) IBOutlet UITextField *summonPasswordTextfield;

@property (nonatomic, strong) NSString *facebookToken;

@property (nonatomic, strong) NSString *userLat;
@property (nonatomic, strong) NSString *userLng;

-(IBAction)loginWithLyftPressed:(id)sender;

-(IBAction)dismiss;

@end
