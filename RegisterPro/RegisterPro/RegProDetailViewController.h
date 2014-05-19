//
//  RegProDetailViewController.h
//  RegisterPro
//
//  Created by Greg Cober on 5/18/14.
//  Copyright (c) 2014 Greg Cober. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegProDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
