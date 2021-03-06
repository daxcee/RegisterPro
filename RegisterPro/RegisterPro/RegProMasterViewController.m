//
//  RegProMasterViewController.m
//  RegisterPro
//
//  Created by Greg Cober on 5/18/14.
//  Copyright (c) 2014 Greg Cober. All rights reserved.
//

#import "RegProMasterViewController.h"

#import "RegProDetailViewController.h"
#import "Transaction.h"
@interface RegProMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, strong) Transaction *newlyCreatedTransactionForDetailsView;
@end

@implementation RegProMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (RegProDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // Let's send some test parse data
//    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
//    testObject[@"foo"] = @"bar";
//    [testObject saveInBackground];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Let's see if we need to create a user
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Balance $%.2f", [self getTransactionTotal]]];
}

#pragma mark - Parse delegate methods
// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    // We logged in a user so let's dismiss the login/register view controller
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    //[self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

#pragma mark - Misc
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Transaction *transaction = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    NSDate* todayAtMidgnight = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                   fromDate:todayAtMidgnight];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    todayAtMidgnight = [calendar dateFromComponents:dateComponents];
    
    transaction.transactionDate = todayAtMidgnight;
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Now let's load the detail view for the added transaction
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.detailViewController.detailItem = transaction;
        self.detailViewController.editMode = TransactionDetailsEditModeNewItem;
    }
    else
    {
        self.newlyCreatedTransactionForDetailsView = transaction;
    }
    
    [self performSegueWithIdentifier:@"showDetail" sender:self];

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Cober-todo: handle error
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        Transaction *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        Transaction *object;
        // If the index path is nil it means that a cell was not selected, for now we can interpret
        // this as meaning that a new item was created
        
        
        // If we have an index path we can get the object from the fetchedResultsController
        
        if(indexPath)
            object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        else if(self.newlyCreatedTransactionForDetailsView)
        {
            // Let's use the newlyCreated object and then clear it
            object = self.newlyCreatedTransactionForDetailsView;
            self.newlyCreatedTransactionForDetailsView = nil;
            
            // Let's set the edit mode to new
            [[segue destinationViewController] setEditMode:TransactionDetailsEditModeNewItem];
        }
        [[segue destinationViewController] setDetailItem:object];
        
    }
}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if(section == 0)
//    {
//        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 40)];
//        [headerView setBackgroundColor:[UIColor lightGrayColor]];
//        
//        UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, 140, 40)];
//        labelText.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
//        [headerView addSubview:labelText];
//        
//        UILabel *labelAmount = [[UILabel alloc] initWithFrame:CGRectMake(200.0, 0.0, 120, 40)];
//        labelText.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
//        [headerView addSubview:labelAmount];
//        
//        labelText.text = @"Balance";
//        labelAmount.text = [NSString stringWithFormat:@"$%.2f", [self getTransactionTotal]];
//        
//        return headerView;
//    }
//    return nil;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if(section == 0)
//        return 40;
//    else
//        return 10;
//}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Transaction *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
    NSString *dateString = [formatter stringFromDate:item.transactionDate];
    return dateString;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"transactionDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections". Cober-todo: I'd like to add the date as a section
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"transactionDate" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }

    [self.navigationItem setTitle:[NSString stringWithFormat:@"Balance $%.2f", [self getTransactionTotal]]];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Balance $%.2f", [self getTransactionTotal]]];    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

#pragma mark - Configure Cells, Accessory Views and actions

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Transaction *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.details;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.2f", [object.amount doubleValue]];

    // Let's set the color of the transaction amount based on it's clear status, and then by whether
    // or not it's a deposit or withdrawal
    if(![object.cleared boolValue])
    {
        if([object.amount doubleValue] < 0)
            cell.detailTextLabel.textColor = [UIColor redColor];
        else
            cell.detailTextLabel.textColor = [UIColor blueColor];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else
    {
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.textColor = [UIColor grayColor];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    
    // Check if the transaction is cleared and add the button
    if([object.cleared boolValue])
    {
        cell.accessoryView = [self makeClearedButton];

    }
    else
    {
        cell.accessoryView = [self makeUnclearedButton];

    }
}

- (UIButton *) makeClearedButton
{
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"check-on.png" ] forState:UIControlStateNormal];
    
    [button addTarget: self
               action: @selector(clearedButtonTapped:withEvent:)
     forControlEvents: UIControlEventTouchUpInside];
    
    return ( button );
}

- (UIButton *) makeUnclearedButton
{
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"check-off.png" ] forState:UIControlStateNormal];
    
    [button addTarget: self
               action: @selector(clearedButtonTapped:withEvent:)
     forControlEvents: UIControlEventTouchUpInside];
    
    return ( button );
}

- (void) clearedButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    // Get the index path that was tapped
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    int row = indexPath.row;
    if ( indexPath == nil )
        return;
    
    // Clear or unclear the transaction
    Transaction *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if([object.cleared boolValue])// Object is cleared, we are un-clearing it
    {
        // Update the accesory view/button
        [((UIButton *)button) setImage:[UIImage imageNamed:@"check-off.png"] forState:UIControlStateNormal];
        object.cleared = [NSNumber numberWithBool:NO];
        
        // Update the text color
        UITableViewCell* cell = [self.tableView.dataSource tableView:self.tableView cellForRowAtIndexPath:indexPath];
        if([object.amount doubleValue] < 0)
            cell.detailTextLabel.textColor = [UIColor redColor];
        else
            cell.detailTextLabel.textColor = [UIColor blueColor];
        
        // Make main text black
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else// Object is un-cleared, we are clearing it
    {
        // Update the accesory view/button
        [((UIButton *)button) setImage:[UIImage imageNamed:@"check-on.png"] forState:UIControlStateNormal];
        object.cleared = [NSNumber numberWithBool:YES];
        
        // Update the text color
        UITableViewCell* cell = [self.tableView.dataSource tableView:self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.textColor = [UIColor grayColor];
    }

    // Save the item to the persistent store
    NSError *error;
    [[object managedObjectContext] save:&error];
    if(error)
    {
        // Cober-todo: log error
    }
}

-(double)getTransactionTotal
{
    double total = 0.0;
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
//    [request setResultType:NSDictionaryResultType];
//    [request setPropertiesToFetch:@[@"amount"]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if(objects == nil)
    {NSLog(@"Could not get transaction total");}
    
    for(Transaction* item in objects)
    {
        total+=[item.amount doubleValue];
    }
    
    return total;
}

@end
