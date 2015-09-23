

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "Mantle.h"

@interface PriceList : MTLModel <MTLJSONSerializing>
/*!
 * PriceList product_code , the product code
 */
@property (nonatomic, strong)  NSString *product_code;
/*!
 * PriceList pricelist_code , the pricelist code
 */
@property (nonatomic, strong)  NSString *pricelist_code;
/*!
 * PriceList price , the pricelist price
 */
@property (nonatomic, strong)  NSNumber *price;
/*!
 * PriceList currency , the pricelist currency
 */
@property (nonatomic, strong)  NSString *currency;

@end
