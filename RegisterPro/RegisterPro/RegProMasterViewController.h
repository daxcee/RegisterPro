//
//  RegProMasterViewController.h
//  RegisterPro
//
//  Created by Greg Cober on 5/18/14.
//  Copyright (c) 2014 Greg Cober. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegProDetailViewController;

#import <CoreData/CoreData.h>

@interface RegProMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) RegProDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
