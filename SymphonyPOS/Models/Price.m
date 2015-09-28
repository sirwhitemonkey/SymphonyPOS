#import "Price.h"

@implementation Price

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"identifier" : @"id",
             @"currency" : @"currency",
             @"itemNo" : @"itemNo",
             @"priceListCode" : @"priceListCode",
             @"unitPrice" : @"unitPrice"
             };
}

@end
