//
//  PriceListStore.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 30/09/15.
//  Copyright (c) 2015 XMDevelopments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PriceListStore : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * identifier;

@end
