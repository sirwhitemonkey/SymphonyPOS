//
//  ProductStore+CoreDataProperties.h
//  SymphonyPOS
//
//  Created by Rommel Sumpo on 27/09/15.
//  Copyright © 2015 XMDevelopments. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ProductStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductStore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSNumber *identifier;
@property (nullable, nonatomic, retain) NSString *image_url;
@property (nullable, nonatomic, retain) NSNumber *inStock;
@property (nullable, nonatomic, retain) NSString *itemNo;
@property (nullable, nonatomic, retain) NSNumber *notActive;
@property (nullable, nonatomic, retain) NSString *stockUnit;
@property (nullable, nonatomic, retain) NSString *upcCode;
@property (nullable, nonatomic, retain) NSSet<CartStore *> *productCart;
@property (nullable, nonatomic, retain) NSSet<PriceListStore *> *productPriceList;

@end

@interface ProductStore (CoreDataGeneratedAccessors)

- (void)addProductCartObject:(CartStore *)value;
- (void)removeProductCartObject:(CartStore *)value;
- (void)addProductCart:(NSSet<CartStore *> *)values;
- (void)removeProductCart:(NSSet<CartStore *> *)values;

- (void)addProductPriceListObject:(PriceListStore *)value;
- (void)removeProductPriceListObject:(PriceListStore *)value;
- (void)addProductPriceList:(NSSet<PriceListStore *> *)values;
- (void)removeProductPriceList:(NSSet<PriceListStore *> *)values;

@end

NS_ASSUME_NONNULL_END
