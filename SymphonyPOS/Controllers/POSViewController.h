
#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "Product.h"
#import "ProductViewCell.h"
#import "UILabel+FormattedText.h"
#import "GlobalStore.h"
#import "CustomerStore.h"
#import "FilteredProductViewCell.h"
#import "QtyViewController.h"
#import "DTDevices.h"

@interface POSViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate,UIActionSheetDelegate,APIManagerDelegate,
QtyViewContollerDelegate>

@property (nonatomic,strong) IBOutlet ProductViewCell *productViewCell;
@property (nonatomic,strong) IBOutlet FilteredProductViewCell *filteredProductViewCell;
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *customer;
@property (nonatomic,strong) IBOutlet UILabel *switchCustomer;
@property (nonatomic,strong) IBOutlet UILabel *subTotals;
@property (nonatomic,strong) IBOutlet UILabel *salesPercentageTax;
@property (nonatomic,strong) IBOutlet UILabel *grandTotals;
@property (nonatomic,strong) IBOutlet UILabel *logout;
@property (nonatomic,strong) IBOutlet UILabel *user;
@property (nonatomic,strong) IBOutlet RoundedButton *cashSalesBtn;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *syncBtn;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *logoutBtn;
@property (nonatomic, strong) IBOutlet UIImageView *dtConnectionState;
@property (nonatomic, strong) IBOutlet UIButton *batteryBtn;



- (IBAction) sync:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)barcode:(id)sender;
- (IBAction)removeToCart:(id)sender;
- (IBAction) cashSales:(id)sender;

@end
