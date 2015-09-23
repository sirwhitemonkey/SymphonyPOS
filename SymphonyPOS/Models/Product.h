
#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "Mantle.h"

@interface Product : MTLModel <MTLJSONSerializing>
/*!
 * Product product_code , the product code
 */
@property (nonatomic, strong)  NSString *product_code;
/*!
 * Product product_name , the product name
 */
@property (nonatomic, strong)  NSString *product_name;
/*!
 * Product unit , the product unit
 */
@property (nonatomic, strong)  NSString *unit;
/*!
 * Product image_url , the product image url
 */
@property (nonatomic, strong)  NSString *image_url;
/*!
 * Product product_description , the product description
 */
@property (nonatomic, strong)  NSString *product_description;
/*!
 * Product pc_code , the product barcode code
 */
@property (nonatomic, strong)  NSString *pc_code;

@end
