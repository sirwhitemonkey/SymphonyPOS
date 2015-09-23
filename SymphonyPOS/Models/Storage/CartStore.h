//
//  CartStore.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 18/09/15.
//  Copyright (c) 2015 XMDevelopments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProductStore;

@interface CartStore : NSManagedObject

@property (nonatomic, retain) NSString * cart_code;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) ProductStore *cartProduct;

@end
