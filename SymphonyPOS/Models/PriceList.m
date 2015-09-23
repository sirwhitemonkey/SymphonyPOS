
#import "PriceList.h"

@implementation PriceList

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"product_code" : @"product_code",
             @"pricelist_code" : @"pricelist_code",
             @"price" : @"price",
             @"currency" : @"currency"
             };
}

@end
