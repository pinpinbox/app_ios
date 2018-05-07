//
//  RecentBrowseTableViewController.m
//  wPinpinbox
//
//  Created by David on 1/19/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "RecentBrowseTableViewController.h"
#import "RecentBrowseTableViewCell.h"
#import <CoreData/CoreData.h>
#import "MZUtility.h"
#import "wTools.h"

@interface RecentBrowseTableViewController ()
@property (strong) NSMutableArray *browseArray;
@end

@implementation RecentBrowseTableViewController

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector: @selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromHomeVC = NO;
    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                 forKey: @"fromHomeVC"];
    [defaults synchronize];
    
    
    // Fetch the data from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName: @"Browse"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"browseDate" ascending: NO];
    [fetchRequest setSortDescriptors: @[sortDescriptor]];
    
    self.browseArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSLog(@"self.browseArray.count: %lu", (unsigned long)self.browseArray.count);
    
    
    for (int i = 0; i < self.browseArray.count; i++) {
        NSManagedObject *browseData = [self.browseArray objectAtIndex: i];
        NSLog(@"%d data", i + 1);
        NSLog(@"albumId: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"albumId"]]);
        NSLog(@"author: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"author"]]);
        NSLog(@"descriptionInfo: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"descriptionInfo"]]);
        NSLog(@"imageFolderName: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"imageFolderName"]]);
        NSLog(@"title: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"title"]]);
        NSLog(@"browseDate: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"browseDate"]]);
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"self.browseArray.count: %lu", (unsigned long)self.browseArray.count);
    return self.browseArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath:indexPath];
    
    RecentBrowseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"
                                                                      forIndexPath: indexPath];
    
    // Configure the cell...
    
    NSManagedObject *browseData = [self.browseArray objectAtIndex: indexPath.row];
    
    NSString *imageFolderName = [browseData valueForKey: @"imageFolderName"];
    NSLog(@"imageFolderName: %@", imageFolderName);
    
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent: imageFolderName];
    NSLog(@"docDirectoryPath: %@", docDirectoryPath);
    
    NSString *fileName = [NSString stringWithFormat: @"%d.jpg", 0];
    NSString *imagePath = [docDirectoryPath stringByAppendingPathComponent: fileName];
    
    
    //cell.browseImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (![imagePath isKindOfClass: [NSNull class]]) {
        if (![imagePath isEqualToString: @""]) {
            cell.browseImageView.image = [UIImage imageWithContentsOfFile: imagePath];
            
        } else {
            NSLog(@"imagePath is empty");
            cell.browseImageView.image = [UIImage imageNamed: @"origin.jpg"];
        }
    } else {
        NSLog(@"imagePath is nil");
        cell.browseImageView.image = [UIImage imageNamed: @"origin.jpg"];
    }
    
    cell.titleLabel.text = [browseData valueForKey: @"title"];
    
    cell.descriptionTextView.textContainer.maximumNumberOfLines = 4;
    cell.descriptionTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.descriptionTextView.text = [browseData valueForKey: @"descriptionInfo"];
    cell.descriptionTextView.userInteractionEnabled = NO;
    cell.authorLabel.text = [browseData valueForKey: @"author"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *browseData = [self.browseArray objectAtIndex: indexPath.row];
    NSString *albumId = [browseData valueForKey: @"albumId"];
    [wTools ReadBookalbumid: albumId userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
