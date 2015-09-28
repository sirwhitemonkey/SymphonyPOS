//
//  GlobalStore.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 28/09/15.
//  Copyright (c) 2015 XMDevelopments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GlobalStore : NSManagedObject

@property (nonatomic, retain) NSString * customer_default_code;
@property (nonatomic, retain) NSString * customer_default_code_copy;
@property (nonatomic, retain) NSNumber * days_sync_interval;
@property (nonatomic, retain) NSString * event;
@property (nonatomic, retain) NSNumber * last_order_number;
@property (nonatomic, retain) NSNumber * logout_event;
@property (nonatomic, retain) NSNumber * minutes_monitor_server;
@property (nonatomic, retain) NSString * my_custom_logo;
@property (nonatomic, retain) NSString * my_custom_url;
@property (nonatomic, retain) NSString * prefix;
@property (nonatomic, retain) NSNumber * prefix_number_length;
@property (nonatomic, retain) NSNumber * qty_event;
@property (nonatomic, retain) NSNumber * sales_percentage_tax;
@property (nonatomic, retain) NSNumber * sync_event;
@property (nonatomic, retain) NSString * terminal_code;
@property (nonatomic, retain) NSString * terminal_name;
@property (nonatomic, retain) NSString * themes;

@end
