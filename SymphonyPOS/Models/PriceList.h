

#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "Mantle.h"

@interface PriceList : MTLModel <MTLJSONSerializing>

/*!
 * PriceList identifier , the pricelist identifier
 */
@property (nonatomic, strong)  NSNumber *identifier;
/*!
 * PriceList code , the pricelist code
 */
@property (nonatomic, strong)  NSString *code;
/*!
 * PriceList desc , the pricelist desc
 */
@property (nonatomic, strong)  NSString *desc;

@end
