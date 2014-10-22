//
//  SettingsViewController.m
//  OneRide
//
//  Created by Cory Levy on 8/2/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)close:(id)sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView
#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 3;
	}
	return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"";
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
	if (!cell)
		cell = [[UITableViewCell alloc] init];
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
		
			cell.textLabel.text = @"Lyft";
		
		} else if (indexPath.row == 1) {
		
			cell.textLabel.text = @"Summon";
		
		} else if (indexPath.row == 2) {
			
			cell.textLabel.text = @"Sidecar";
		
		}
	}
	
	return cell;
}

#pragma mark Delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
		
			// Lyft
			if ([self isLoggedInWithService:@"lyft"]) {
				
				// Log out
				
			} else {
				
				// Log in
				
			}
			
		} else if (indexPath.row == 1) {
			
			// Summon
			if ([self isLoggedInWithService:@"summon"]) {
				
				// Log out
				
			} else {
				
				// Log in
				
			}
			
		} else if (indexPath.row == 1) {
			
			// Sidecar
			if ([self isLoggedInWithService:@"sidecar"]) {
				
				// Log out
				
			} else {
				
				// Log in
				
			}
			
		}
	}
}

#pragma mark - Helpers

- (BOOL)isLoggedInWithService:(NSString*)service
{
	return YES;
}

@end
