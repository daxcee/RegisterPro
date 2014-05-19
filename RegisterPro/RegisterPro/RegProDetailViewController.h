//
//  RegProDetailViewController.h
//  RegisterPro
//
//  Created by Greg Cober on 5/18/14.
//  Copyright (c) 2014 Greg Cober. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Transaction;
@interface RegProDetailViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) Transaction *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *detailsText;
@property (weak, nonatomic) IBOutlet UITextField *transactionDate;
@property (weak, nonatomic) IBOutlet UITextField *transactionAmount;
- (IBAction)saveTransaction:(id)sender;
@end
