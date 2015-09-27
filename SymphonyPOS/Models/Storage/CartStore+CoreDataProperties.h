//
//  CartStore+CoreDataProperties.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 27/09/15.
//  Copyright © 2015 XMDevelopments. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CartStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface CartStore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *cart_code;
@property (nullable, nonatomic, retain) NSNumber *qty;
@property (nullable, nonatomic, retain) ProductStore *cartProduct;

@end

NS_ASSUME_NONNULL_END
