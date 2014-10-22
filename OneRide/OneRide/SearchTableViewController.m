//
//  SearchTableViewController.m
//  OneRide
//
//  Created by Cory Levy on 8/3/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "SearchTableViewController.h"

@interface SearchTableViewController ()

@end

@implementation SearchTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Search Bar
- (void)search:(NSString*)text {
    if(text.length == 0) {
    } else {
    }
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.searchTimer invalidate];
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(performQuery:) userInfo:nil repeats:NO];
    
    [self search:text];
    [self.tableView reloadData];
}
-(void)performQuery:(id)sender {
    UISearchBar *searchBar = (UISearchBar*)sender;
    
    [self.searchTimer invalidate];
    //search foursquare api
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        if ([searchBar.text length] > 3) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id= AU4NCQVOW4X4NJ1YEKEH4WB01QD4BSPRT4J5Z2BBH5OJUXTE&client_secret=ASNL05HH40ZSWMBXGIUTYN4E0UP5ZXTOTZOY1GKWVDEDCZXB&v=20140803&ll=37.7,-122&query=%@",searchBar.text]]];
            NSError *error = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            dispatch_sync(dispatch_get_main_queue(), ^{
                // parse the response
                NSLog(@"responseDict %@", responseDict);
            });
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    });
}
@end
