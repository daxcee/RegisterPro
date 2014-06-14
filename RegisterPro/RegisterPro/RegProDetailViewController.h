//
//  RegProDetailViewController.h
//  RegisterPro
//
//  Created by Greg Cober on 5/18/14.
//  Copyright (c) 2014 Greg Cober. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    TransactionDetailsEditModeEditExisting = 0,
    TransactionDetailsEditModeNewItem
};

typedef enum
{
    TransactionViewValidationValid = 0,
    TransactionViewValidationInvalidDescription,
    TransactionViewValidationInvalidAmount
}TransactionViewValidationType;

@class Transaction;
@interface RegProDetailViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Transaction *detailItem;

@property (assign, nonatomic) int editMode;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) UITableView *autocompleteTableView;
@property (strong, nonatomic) NSMutableArray *autocompleteValueArray;
@property (strong, nonatomic) NSMutableDictionary *pastDetailDescriptionValuesDictionary;

@property (weak, nonatomic) IBOutlet UITextField *detailsText;
@property (weak, nonatomic) IBOutlet UITextField *transactionAmount;
- (IBAction)saveTransaction:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transactionType;
@property (weak, nonatomic) IBOutlet UIDatePicker *transactionDatePicker;

- (IBAction)saveTransactionDate:(UITextField *)sender;
- (IBAction)amountChanged:(id)sender;
- (IBAction)transactionTypeChanged:(id)sender;
@end
