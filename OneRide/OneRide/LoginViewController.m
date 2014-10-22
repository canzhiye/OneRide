//
//  LoginViewController.m
//  OneRide
//
//  Created by Canzhi Ye on 8/18/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "LoginViewController.h"
#import "API.h"
#import "AppDelegate.h"

#import <FacebookSDK/FacebookSDK.h>

#define kUberUsernameTextfieldTag 0
#define kUberPasswordTextfieldTag 1

#define kSidecarUsernameTextfieldTag 2
#define kSidecarPasswordTextfieldTag 3

#define kSummonUsernameTextfieldTag 4
#define kSummonPasswordTextfieldTag 5

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"facebookLoggedIn" object:nil];
    
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [self updateUI];
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)updateUI {
    UIButton *lyftButton = (UIButton*)[self.view viewWithTag:999];
    [lyftButton setTitle:@"Already Logged Into Lyft" forState:UIControlStateNormal];
    lyftButton.userInteractionEnabled = NO;
    
    self.facebookToken = FBSession.activeSession.accessTokenData.accessToken;
}

-(IBAction)dismiss {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [API loginWithUberUsename:self.uberUsernameTextfield.text uberPassword:self.uberPasswordTextfield.text facebookToken:self.facebookToken lat:kLat andLng:kLng success:^(NSDictionary *output) {
        //Yay
        NSLog(@"Login succes: %@",output);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [self dismissViewControllerAnimated:YES completion:^{
            NSMutableDictionary *authDict = [[NSMutableDictionary alloc]init];
            if (output[@"lyft"][@"token"]) {
                [authDict setObject:output[@"lyft"][@"token"] forKey:@"lyft_token"];
            }
            
            if (output[@"lyft"][@"id"]) {
                [authDict setObject:output[@"lyft"][@"id"] forKey:@"lyft_id"];
            }
            
            if (output[@"uber"][@"token"]) {
                [authDict setObject:output[@"uber"][@"token"] forKey:@"uber_token"];
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAuth" object:authDict];
        }];
    } error:^(NSError *error) {
        //Error
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        NSLog(@"Login error: %@",error);
    }];
}
#pragma mark login 

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case kUberUsernameTextfieldTag:
            [self.uberPasswordTextfield becomeFirstResponder];
            break;
        case kSidecarUsernameTextfieldTag:
            [self.sidecarPasswordTextfield becomeFirstResponder];
            break;
        case kSummonUsernameTextfieldTag:
            [self.summonPasswordTextfield becomeFirstResponder];
            break;
        default:
            [textField resignFirstResponder];
            break;
    }
    
    return YES;
}

-(IBAction)loginWithLyftPressed:(id)sender {
    //retrieve facebook access token
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
             
             if (!error) {
                 self.facebookToken = session.accessTokenData.accessToken;
             }
         }];
    }
}

#pragma mark memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
