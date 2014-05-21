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
        //self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
        self.detailDescriptionLabel.text = self.detailItem.details;
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
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
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
    return YES;
}

@end
