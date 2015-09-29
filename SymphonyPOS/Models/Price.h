
#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "Mantle.h"

@interface Price : MTLModel <MTLJSONSerializing>
/*!
 * Price identifier , the price identifier
 */
@property (nonatomic, strong)  NSNumber *identifier;
/*!
 * Price currency , the price currency
 */
@property (nonatomic, strong)  NSString *currency;
/*!
 * Price itemNo , the price itemNo
 */
@property (nonatomic, strong)  NSString *itemNo;
/*!
 * Price priceListCode , the price code
 */
@property (nonatomic, strong)  NSString *priceListCode;
/*!
 * Price unitPrice , the price unitPrice
 */
@property (nonatomic, strong)  NSNumber *unitPrice;

@end
