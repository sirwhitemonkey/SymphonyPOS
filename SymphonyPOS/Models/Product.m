
#import "Product.h"

@implementation Product

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"product_code" : @"product_code",
             @"product_name" : @"product_name",
             @"unit" : @"unit",
             @"image_url" : @"image_url",
             @"product_description" : @"product_description",
             @"pc_code" : @"pc_code"
             };
}


@end
