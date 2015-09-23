#import "Customer.h"

@implementation Customer

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"pricelist_code" : @"pricelist_code",
             @"customer_code" : @"customer_code",
             @"customer_default" : @"default",
             @"terms" : @"terms",
             @"customer_description" : @"customer_description"
             };
}

+ (NSValueTransformer *)customer_defaultJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer *)termsJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

@end
