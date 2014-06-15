//
//  Transaction.h
//  RegisterPro
//
//  Created by Greg Cober on 6/14/14.
//  Copyright (c) 2014 Greg Cober. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Transaction : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSDate * transactionDate;
@property (nonatomic, retain) NSNumber * transactionType;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSNumber * cleared;

@end
