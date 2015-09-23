//
//  PriceListStore.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 18/09/15.
//  Copyright (c) 2015 XMDevelopments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CustomerStore, ProductStore;

@interface PriceListStore : NSManagedObject

@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * pricelist_code;
@property (nonatomic, retain) NSString * product_code;
@property (nonatomic, retain) NSSet *priceListCustomer;
@property (nonatomic, retain) ProductStore *priceListProduct;
@end

@interface PriceListStore (CoreDataGeneratedAccessors)

- (void)addPriceListCustomerObject:(CustomerStore *)value;
- (void)removePriceListCustomerObject:(CustomerStore *)value;
- (void)addPriceListCustomer:(NSSet *)values;
- (void)removePriceListCustomer:(NSSet *)values;

@end
