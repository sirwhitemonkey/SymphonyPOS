
#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "Mantle.h"

@interface Customer : MTLModel <MTLJSONSerializing>
/*!
 * Customer customer_code , the customer code
 */
@property (nonatomic, strong)  NSString *customer_code;
/*!
 * Customer pricelist_code , the customer pricelist code
 */
@property (nonatomic, strong)  NSString *pricelist_code;
/*!
 * Customer customer-description , the customer description
 */
@property (nonatomic, strong)  NSString *customer_description;
/*!
 * Customer customer_default , the customer default code
 */
@property (nonatomic, assign)  BOOL customer_default;
/*!
 * Customer terms , the customer default terms
 */
@property (nonatomic, assign)  BOOL terms;
@end