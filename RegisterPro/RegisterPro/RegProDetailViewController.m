//
//  RegProDetailViewController.m
//  RegisterPro
//
//  Created by Greg Cober on 5/18/14.
//  Copyright (c) 2014 Greg Cober. All rights reserved.
//

#import "RegProDetailViewController.h"
#import "Transaction.h"

@interface RegProDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation RegProDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

static NSString *enteredtext; // used for the atm style input for amount
- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailsText.text = self.detailItem.details;
        double amount = [self.detailItem.amount doubleValue];
        amount = amount>=0?amount:-1*amount;
        self.transactionAmount.text = [NSString stringWithFormat:@"$%.2f", amount];

        // Let's set up our enteredtext as the amount text without the . and $ sign
        enteredtext = [[self.transactionAmount.text stringByReplacingOccurrencesOfString:@"$" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
        if([enteredtext doubleValue] == 0)
        {
            enteredtext = @"";
        }
        
        self.transactionDatePicker.date = self.detailItem.transactionDate;
        self.transactionType.selectedSegmentIndex = [self.detailItem.transactionType integerValue];
        
        // Let's add an autocomplete tableView to the description box
        CGRect autoCompleteFrame = CGRectMake(self.detailsText.frame.origin.x,
                                              self.detailsText.frame.origin.y + self.detailsText.frame.size.height,
                                              self.detailsText.frame.size.width,
                                              175);
        self.autocompleteTableView = [[UITableView alloc] initWithFrame:
                                 autoCompleteFrame style:UITableViewStylePlain];
        self.autocompleteTableView.delegate = self;
        self.autocompleteTableView.dataSource = self;
        self.autocompleteTableView.scrollEnabled = YES;
        self.autocompleteTableView.hidden = YES;// Hide it for now
        self.autocompleteTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.autocompleteTableView.layer.cornerRadius = 5.0f;
        self.autocompleteTableView.layer.masksToBounds = YES;
        self.autocompleteTableView.layer.borderWidth = 1.0f;
        [self.view addSubview:self.autocompleteTableView];
        
        // Let's create the array for past detailed values (get it from core data)
        if(!self.pastDetailDescriptionValuesDictionary)
        {
            self.pastDetailDescriptionValuesDictionary = [[NSMutableDictionary alloc] init];
        }
        [self.pastDetailDescriptionValuesDictionary removeAllObjects];
        NSManagedObjectContext *context = [self.detailItem managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        //    [request setResultType:NSDictionaryResultType];
        //    [request setPropertiesToFetch:@[@"amount"]];
        
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        if(objects == nil)
        {NSLog(@"Could not get transactions for past entries");}
        
        for(Transaction* item in objects)
        {
            if(item.details)
                [self.pastDetailDescriptionValuesDictionary setObject:item forKey:item.details];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Make the back button a cancel button
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem  = cancelButton;
    
    // Add the save button to the nav bar
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTransaction:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Let's add a done to the number pad for amount
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.window.frame.size.width, 50)];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    
    self.transactionAmount.inputAccessoryView = numberToolbar;
    self.transactionAmount.delegate = self;
    
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneWithNumberPad{
    [self.transactionAmount resignFirstResponder];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - UI Actions

- (IBAction)saveTransaction:(id)sender {
    self.detailItem.details = self.detailsText.text;
    self.detailItem.amount = [NSNumber numberWithDouble:[[self.transactionAmount.text stringByReplacingOccurrencesOfString:@"$" withString:@""] doubleValue]];
    self.detailItem.transactionType = [NSNumber numberWithInt:self.transactionType.selectedSegmentIndex];
    
    if([self.detailItem.transactionType integerValue] == 0)// COBER-TODO: USE CONSTANT
        self.detailItem.amount = [NSNumber numberWithDouble: -1*[self.detailItem.amount doubleValue]];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // Save the changes to the persistent store
    NSError *error = nil;
    NSManagedObjectContext *context = [self.detailItem managedObjectContext];
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    // If it's a new item let's delete it if the user click cancel
    if(self.editMode == TransactionDetailsEditModeNewItem)
    {
        NSManagedObjectContext *context = [self.detailItem managedObjectContext];
        [context deleteObject:self.detailItem];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Cober-todo: handle error
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveTransactionDate:(id)sender {
    NSDate *dateAtMidnight = self.transactionDatePicker.date;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                   fromDate:dateAtMidnight];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    dateAtMidnight = [calendar dateFromComponents:dateComponents];
    
    self.detailItem.transactionDate = dateAtMidnight;
}

- (IBAction)amountChanged:(UITextField *)sender {
//    NSString *amount = [sender.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
//    if([amount doubleValue] == 0)
//    {
//        sender.text = @"$0.00";
//    }
//    if(amount.length == 1)
//    {
//        sender.text = [NSString stringWithFormat:@"%1.2f", sender.text.doubleValue / 100];
//    }
//    if(sender.text.length == 2)
//    {
//        sender.text = [NSString stringWithFormat:@"%1.2f", sender.text.doubleValue / 10];
//    }
}

- (IBAction)transactionTypeChanged:(id)sender {
}

#pragma mark - Text field delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.detailsText)
    {
        self.autocompleteTableView.hidden = YES;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Amount field is being edited
    if(textField == self.transactionAmount)
    {
        if(range.length==1)
        {
            if(enteredtext.length>0)
                enteredtext = [enteredtext substringWithRange:NSMakeRange(0,enteredtext.length-1)];
        }
        else
        {
            if(enteredtext.length<9)
                enteredtext = [NSString stringWithFormat:@"%@%@",enteredtext,string];
        }
        double amountindecimal = [enteredtext doubleValue];
        double res=amountindecimal * pow(10, -2);
        NSString * neededstring = [NSString stringWithFormat:@"$%.2f",res];
        if([neededstring isEqualToString:@"$0.00"])
            enteredtext = @"0";
        textField.text = neededstring;
        return NO;
    }
    // Description field is being edited
    else if(textField == self.detailsText)
    {
        //self.autocompleteTableView.hidden = NO;
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring
                     stringByReplacingCharactersInRange:range withString:string];
        [self searchAutocompleteEntriesWithSubstring:substring];
        
        if(self.autocompleteValueArray.count > 0)
            self.autocompleteTableView.hidden = NO;
        else
            self.autocompleteTableView.hidden = YES;
        
        return YES;
    }
    return YES;
}

#pragma mark - Autocomplete for details
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Let's build our past items array form the past details fields

    
    // Put anything that starts with this substring into the autocompleteUrls array
    // The items in this array is what will show up in the table view
    if(!self.autocompleteValueArray)
        self.autocompleteValueArray = [[NSMutableArray alloc] init];
    [self.autocompleteValueArray removeAllObjects];
    NSArray *pastDetailDescriptionValueArray = [[self.pastDetailDescriptionValuesDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    for(NSString *key in pastDetailDescriptionValueArray) {
        NSRange substringRange = [key rangeOfString:substring];
        if (substringRange.location == 0) {
            [self.autocompleteValueArray addObject:key];
        }
    }
    [self.autocompleteTableView reloadData];
}

#pragma mark - UITableView datasource/delegate functions
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.autocompleteValueArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"AutoCompleteIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    NSString *details = [self.autocompleteValueArray objectAtIndex:indexPath.row];
    cell.textLabel.text = details;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.detailsText.text = [self.autocompleteValueArray objectAtIndex:indexPath.row];
    self.autocompleteTableView.hidden = YES;
}

@end
