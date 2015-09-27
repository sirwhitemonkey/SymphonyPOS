
#import <Foundation/Foundation.h>
#import "MTLModel.h"
#import "Mantle.h"

@interface Product : MTLModel <MTLJSONSerializing>
/*!
 * Product itemNo , the item no
 */
@property (nonatomic, strong)  NSString *itemNo;
/*!
 * Product upcCode , the upc code
 */
@property (nonatomic, strong)  NSString *upcCode;
/*!
 * Product identifier , the product identifier
 */
@property (nonatomic, strong)  NSNumber *identifier;
/*!
 * Product image_url , the product image url
 */
@property (nonatomic, strong)  NSString *image_url;
/*!
 * Product desc , the product description
 */
@property (nonatomic, strong)  NSString *desc;
/*!
 * Product stockUnit , the product stock unit
 */
@property (nonatomic, strong)  NSString *stockUnit;
/*!
 * Product inStock , the product in stock status
 */
@property (nonatomic, assign)  BOOL inStock;
/*!
 * Product notActive , the product inactive status
 */
@property (nonatomic, assign)  BOOL notActive;
@end
