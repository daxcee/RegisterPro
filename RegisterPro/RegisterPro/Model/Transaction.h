//
//  Transaction.h
//  RegisterPro
//
//  Created by Greg Cober on 5/18/14.
//  Copyright (c) 2014 Greg Cober. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Transaction : NSManagedObject

@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSNumber * transactionType;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSDate * transactionDate;

@end
