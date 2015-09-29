
#import "MetaData.h"

@implementation MetaData


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"number" : @"number",
             @"numberOfElements" : @"numberOfElements",
             @"totalPages" : @"totalPages",
             @"size" : @"size",
             @"last" : @"last",
             @"totalElements" : @"totalElements",
             @"first" : @"first",
             @"date_last_updated": @"date_last_updated"
             };
}

+ (NSValueTransformer *)lastJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer *)firstJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

@end
