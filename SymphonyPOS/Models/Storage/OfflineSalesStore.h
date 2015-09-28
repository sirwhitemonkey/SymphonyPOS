//
//  OfflineSalesStore.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 28/09/15.
//  Copyright (c) 2015 XMDevelopments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OfflineSalesStore : NSManagedObject

@property (nonatomic, retain) NSString * carts;
@property (nonatomic, retain) NSString * customer_code;
@property (nonatomic, retain) NSString * invoice_no;
@property (nonatomic, retain) NSString * payment_type;

@end
