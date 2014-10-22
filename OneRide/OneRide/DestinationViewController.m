//
//  DestinationViewController.m
//  OneRide
//
//  Created by Cory Levy on 8/3/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "DestinationViewController.h"
#import "API.h"
#import "ViewController.h"


@interface DestinationViewController ()

@end

@implementation UINavigationBar (CustomBar)

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
	
    if ([subview isKindOfClass:[UIImageView class]]) {
        [subview setClipsToBounds:YES];
    }
}

@end

@implementation DestinationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.placesSearchBar.backgroundImage = [UIImage new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self registerForNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self unregisterForNotifications];
}

- (IBAction)close:(id)sender
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView
#pragma mark Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    if (!cell)
		cell = [[UITableViewCell alloc] init];
	
	NSDictionary *location = [self.searchResultsArray objectAtIndex:indexPath.row];
	cell.textLabel.text = [location objectForKey:@"name"];
	cell.detailTextLabel.text = [[location objectForKey:@"location"] objectForKey:@"address"];
	
	cell.textLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:15];
	cell.detailTextLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:13];
	
    return cell;
}

#pragma mark Delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSDictionary *d = self.searchResultsArray[indexPath.row];
	NSString *lat = d[@"location"][@"lat"];
	NSString *lng = d[@"location"][@"lng"];
	NSString *name = d[@"name"];
	NSString *address = d[@"location"][@"address"];
	
	[self.delegate setDestination:name address:address lat:lat lng:lng];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Search Bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchTimer invalidate];
	[self performQuery];
	
	[self.placesSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    [self.searchTimer invalidate];
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
														target:self
													  selector:@selector(performQuery)
													  userInfo:nil
													   repeats:NO
						];
    
    [self.tableView reloadData];
}

- (void)performQuery
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.searchTimer invalidate];
	
	if ([self.placesSearchBar.text length] == 0)
		return;
	
	[API foursquareLocationsAtLat:self.userLat
						   andLng:self.userLng
						withQuery:self.placesSearchBar.text
						  success:^(NSArray *output) {
							  
							  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
							  self.searchResultsArray = [[NSMutableArray alloc] initWithArray:output];
							  [self.tableView reloadData];
							  
						  }
							error:nil
	 ];
}

#pragma mark - UIKeyboard

- (void)registerForNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
			   selector:@selector(keyboardShow:)
				   name:UIKeyboardWillShowNotification
				 object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)unregisterForNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardShow:(NSNotification*)note {
    NSDictionary *info = [note userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[note.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    keyboardTransitionAnimationCurve = keyboardTransitionAnimationCurve<<16;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(UIViewAnimationOptions)keyboardTransitionAnimationCurve
                     animations:^(void) {
                         
                         self.tableView.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
                         self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
						 
                     }
                     completion:nil
     ];
}

- (void)keyboardHide:(NSNotification*)note {
    NSDictionary *info = [note userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[note.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    keyboardTransitionAnimationCurve = keyboardTransitionAnimationCurve<<16;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(UIViewAnimationOptions)keyboardTransitionAnimationCurve
                     animations:^(void) {
                         
                         self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                         self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
                         
                     }
                     completion:nil
     ];
}


@end
