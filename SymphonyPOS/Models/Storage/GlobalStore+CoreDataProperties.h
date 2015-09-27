//
//  GlobalStore+CoreDataProperties.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 27/09/15.
//  Copyright © 2015 XMDevelopments. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GlobalStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface GlobalStore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *customer_default_code;
@property (nullable, nonatomic, retain) NSString *customer_default_code_copy;
@property (nullable, nonatomic, retain) NSNumber *days_sync_interval;
@property (nullable, nonatomic, retain) NSString *event;
@property (nullable, nonatomic, retain) NSNumber *last_order_number;
@property (nullable, nonatomic, retain) NSNumber *logout_event;
@property (nullable, nonatomic, retain) NSNumber *minutes_monitor_server;
@property (nullable, nonatomic, retain) NSString *my_custom_logo;
@property (nullable, nonatomic, retain) NSString *my_custom_url;
@property (nullable, nonatomic, retain) NSString *prefix;
@property (nullable, nonatomic, retain) NSNumber *prefix_number_length;
@property (nullable, nonatomic, retain) NSNumber *qty_event;
@property (nullable, nonatomic, retain) NSNumber *sales_percentage_tax;
@property (nullable, nonatomic, retain) NSNumber *sync_event;
@property (nullable, nonatomic, retain) NSString *terminal_code;
@property (nullable, nonatomic, retain) NSString *terminal_name;
@property (nullable, nonatomic, retain) NSString *themes;

@end

NS_ASSUME_NONNULL_END
