//
//  OfflineSalesStore+CoreDataProperties.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 27/09/15.
//  Copyright © 2015 XMDevelopments. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "OfflineSalesStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface OfflineSalesStore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *carts;
@property (nullable, nonatomic, retain) NSString *customer_code;
@property (nullable, nonatomic, retain) NSString *invoice_no;
@property (nullable, nonatomic, retain) NSString *payment_type;

@end

NS_ASSUME_NONNULL_END
