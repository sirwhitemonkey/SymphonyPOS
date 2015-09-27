//
//  CustomerStore+CoreDataProperties.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 27/09/15.
//  Copyright © 2015 XMDevelopments. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CustomerStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomerStore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *priceCode;
@property (nullable, nonatomic, retain) NSString *currency;
@property (nullable, nonatomic, retain) NSString *group;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *taxGroup;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSNumber *identifier;
@property (nullable, nonatomic, retain) NSString *address1;
@property (nullable, nonatomic, retain) NSString *address2;
@property (nullable, nonatomic, retain) NSString *address3;
@property (nullable, nonatomic, retain) NSString *address4;
@property (nullable, nonatomic, retain) PriceListStore *customerPriceList;

@end

NS_ASSUME_NONNULL_END
