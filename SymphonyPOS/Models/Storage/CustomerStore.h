//
//  CustomerStore.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 18/09/15.
//  Copyright (c) 2015 XMDevelopments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PriceListStore;

@interface CustomerStore : NSManagedObject

@property (nonatomic, retain) NSString * customer_code;
@property (nonatomic, retain) NSNumber * customer_default;
@property (nonatomic, retain) NSString * customer_description;
@property (nonatomic, retain) NSString * pricelist_code;
@property (nonatomic, retain) NSNumber * terms;
@property (nonatomic, retain) PriceListStore *customerPriceList;

@end
