//
//  PriceListStore+CoreDataProperties.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 27/09/15.
//  Copyright © 2015 XMDevelopments. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PriceListStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface PriceListStore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSNumber *identifier;
@property (nullable, nonatomic, retain) NSSet<CustomerStore *> *priceListCustomer;
@property (nullable, nonatomic, retain) ProductStore *priceListProduct;

@end

@interface PriceListStore (CoreDataGeneratedAccessors)

- (void)addPriceListCustomerObject:(CustomerStore *)value;
- (void)removePriceListCustomerObject:(CustomerStore *)value;
- (void)addPriceListCustomer:(NSSet<CustomerStore *> *)values;
- (void)removePriceListCustomer:(NSSet<CustomerStore *> *)values;

@end

NS_ASSUME_NONNULL_END
