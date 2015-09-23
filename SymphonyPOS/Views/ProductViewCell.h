
#import <UIKit/UIKit.h>
#import "RoundedButton.h"

@interface ProductViewCell : UITableViewCell
@property(nonatomic,strong) IBOutlet UILabel *product_name;
@property(nonatomic,strong) IBOutlet UILabel *unit_price;
@property(nonatomic,strong) IBOutlet UILabel *unit;
@property(nonatomic,strong) IBOutlet UILabel *product_description;
@property(nonatomic,strong) IBOutlet UILabel *total;
@property(nonatomic,strong) IBOutlet UIImageView *image_url;
@property (nonatomic,strong) IBOutlet RoundedButton *removeToCart;

@property(nonatomic,strong) IBOutlet UITextField *qty;
@end
