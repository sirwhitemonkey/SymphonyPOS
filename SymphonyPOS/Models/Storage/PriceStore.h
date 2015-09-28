//
//  PriceStore.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 28/09/15.
//  Copyright (c) 2015 XMDevelopments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PriceStore : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSString * itemNo;
@property (nonatomic, retain) NSString * priceListCode;
@property (nonatomic, retain) NSDecimalNumber * unitPrice;
@property (nonatomic, retain) NSDate * saleStart;
@property (nonatomic, retain) NSDate * saleEnd;

@end
