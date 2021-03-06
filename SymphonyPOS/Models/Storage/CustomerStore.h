//
//  CustomerStore.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 30/09/15.
//  Copyright (c) 2015 XMDevelopments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CustomerStore : NSManagedObject

@property (nonatomic, retain) NSString * address1;
@property (nonatomic, retain) NSString * address2;
@property (nonatomic, retain) NSString * address3;
@property (nonatomic, retain) NSString * address4;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * priceCode;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * taxGroup;

@end
