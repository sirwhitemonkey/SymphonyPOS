#import "GlobalItems.h"

@implementation GlobalItems


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"customer_default_code" : @"customer_default_code",
             @"my_custom_url" : @"my_custom_url",
             @"my_custom_logo" : @"my_custom_logo",
             @"themes" : @"themes",
             @"sales_percentage_tax" : @"sales_percentage_tax",
             @"prefix" : @"prefix",
             @"prefix_number_length" : @"prefix_number_length",
             @"last_order_number" : @"last_order_number"
             };
}
@end
