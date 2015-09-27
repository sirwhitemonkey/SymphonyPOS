
#import <Foundation/Foundation.h>

#import "MTLModel.h"
#import "Mantle.h"

@interface DataDefaults : MTLModel <MTLJSONSerializing>
/*!
 * GlobalItems my_custom_url , the customer custom url
 */
@property (nonatomic, strong)  NSString *my_custom_url;
/*!
 * GlobalItems my_custom_logo , the customer custom logo
 */
@property (nonatomic, strong)  NSString *my_custom_logo;
/*!
 * GlobalItems themes , the customer custom themes
 */
@property (nonatomic, strong)  NSDictionary *themes;
/*!
 * GlobalItems customer_default_code , the customer default code
 */
@property (nonatomic, strong)  NSString *customer_default_code;
/*!
 * GlobalItems prefix , the invoice prefix
 */
@property (nonatomic, strong)  NSString *prefix;
/*!
 * GlobalItems prefix_number_length , the invoice prefix number length
 */
@property (nonatomic, strong)  NSNumber *prefix_number_length;
/*!
 * GlobalItems last_order_number , the invoice last order number
 */
@property (nonatomic, strong)  NSNumber *last_order_number;
/*!
 * GlobalItems sales_percentage_tax , the sales percentage tax
 */
@property (nonatomic, strong)  NSNumber *sales_percentage_tax;

@end