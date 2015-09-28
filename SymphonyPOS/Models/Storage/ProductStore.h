//
//  ProductStore.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 28/09/15.
//  Copyright (c) 2015 XMDevelopments. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CartStore, PriceListStore;

@interface ProductStore : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSNumber * inStock;
@property (nonatomic, retain) NSString * itemNo;
@property (nonatomic, retain) NSNumber * notActive;
@property (nonatomic, retain) NSString * stockUnit;
@property (nonatomic, retain) NSString * upcCode;
@property (nonatomic, retain) NSSet *productCart;
@property (nonatomic, retain) NSSet *productPriceList;
@end

@interface ProductStore (CoreDataGeneratedAccessors)

- (void)addProductCartObject:(CartStore *)value;
- (void)removeProductCartObject:(CartStore *)value;
- (void)addProductCart:(NSSet *)values;
- (void)removeProductCart:(NSSet *)values;

- (void)addProductPriceListObject:(PriceListStore *)value;
- (void)removeProductPriceListObject:(PriceListStore *)value;
- (void)addProductPriceList:(NSSet *)values;
- (void)removeProductPriceList:(NSSet *)values;

@end
