
#import "Product.h"

@implementation Product

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"identifier" : @"id",
             @"itemNo" : @"itemNo",
             @"upcCode" : @"upcCode",
             @"inStock" : @"inStock",
             @"image_url" : @"image_url",
             @"notActive" : @"notActive",
             @"desc" : @"desc",
             @"stockUnit" : @"stockunit"
             };
}

+ (NSValueTransformer *)inStockJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (NSValueTransformer *)notActiveJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}


@end
