
#import <UIKit/UIKit.h>
#import "CustomerViewCell.h"
#import "CustomerStore.h"
#import "GlobalStore.h"

@interface CustomerViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) IBOutlet CustomerViewCell *customerViewCell;

@end
