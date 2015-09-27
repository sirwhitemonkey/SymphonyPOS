//
//  ProductStore.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 27/09/15.
//  Copyright © 2015 XMDevelopments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CartStore, PriceListStore;

NS_ASSUME_NONNULL_BEGIN

@interface ProductStore : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "ProductStore+CoreDataProperties.h"
