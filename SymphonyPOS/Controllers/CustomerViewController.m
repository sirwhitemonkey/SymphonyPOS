

#import "CustomerViewController.h"

@interface CustomerViewController ()
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray *customers;
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@property int page;
@property BOOL pageReached;

@end

@implementation CustomerViewController
@synthesize searchBar = _searchBar;
@synthesize customers = _customers;
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;
@synthesize page = _page;
@synthesize pageReached = _pageReached;

- (void)viewDidLoad {
    [super viewDidLoad];
    DebugLog(@"viewDidLoad");
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Customers";
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.pagingEnabled = NO;
    
    _customers = [NSMutableArray array];
    
    _globalStore = [persistenceManager getGlobalStore];
    
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self.view setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    [self.tableView setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    
     self.automaticallyAdjustsScrollViewInsets = NO;
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_searchBar) {
        for (UIView *view in self.view.subviews){
            if ([view isKindOfClass:[UISearchBar class]]) {
                _searchBar = (UISearchBar*)view;
                [_searchBar becomeFirstResponder];
                break;
            }
        }
    }
    [self registerNotifications];
    [self searchCustomers:@""];
    
}

- (BOOL)shouldAutorotate{
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#endif


#pragma mark - Notifications

- (void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - UITableView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _customers.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.customerViewCell.frame.size.height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"CustomerViewCell"];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CustomerViewCell" owner:self options:nil];
        cell=self.customerViewCell;
        [cell setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"table_simple_row"]]];
    }
    
   
    CustomerStore *customerStore = [_customers objectAtIndex:indexPath.row];
    CustomerViewCell *cViewCell = (CustomerViewCell*)cell;
    cViewCell.customer_code.text = customerStore.code;
    cViewCell.customer_description.text = customerStore.name;
    [service searchPatternInLabels: cViewCell.customer_description searchString:_searchBar.text];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerStore *customerStore = [_customers objectAtIndex:indexPath.row];
    _globalStore.customer_default_code = customerStore.code;
    [persistenceManager saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)scrollViewDidScroll: (UIScrollView*)scrollView{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
        if (!_pageReached) {
            _page++;
            [self searchCustomers:_searchBar.text];
        }
    }
    
}

#pragma mark - UISearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchCustomers:) object:searchText];
    //[self performSelector:@selector(searchCustomers:) withObject:searchText afterDelay:0.5];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    _page = 0;
    _pageReached = NO;
    [_customers removeAllObjects];
    [self.tableView reloadData];
    [self searchCustomers:_searchBar.text];
}

#pragma mark - Private methods
- (void) willEnterForegroundNotification {
    [service showPinView:self];
}

/*!
 * CustomerViewController customer's search
 */
/*
- (void) searchCustomers:(NSString*) searchString {
    if (![service isEmptyString:searchString]) {
        [service showMessage:self loader:YES message:@"Searching ..." error:NO waitUntilCompleted:YES withCallBack: ^ {
            [persistenceManager getCustomerStores:searchString completedCallback:^(NSArray *results){
                _customers = results;
                [service hideMessage:^ {
                    if ([_customers count] == 0) {
                        [service showMessage:self loader:NO message:@"No customers available" error:YES waitUntilCompleted:NO withCallBack:nil];
                    }
                    [self.tableView reloadData];
                }];
                
            }];
            
        }];
    }
}
 */
- (void) searchCustomers:(NSString*) searchString {
    NSArray *results = [persistenceManager getCustomerStores:searchString page:_page];
    if (results.count == 0) {
        if (_page == 0) {
            [service showMessage:self loader:NO message:@"No customers available" error:YES waitUntilCompleted:NO withCallBack:^ {
                [_customers removeAllObjects];
                [self.tableView reloadData];
            }];
        } else {
            _pageReached = YES;
        }
    } else {
        [_customers addObjectsFromArray:results];
        [self.tableView reloadData];
    }
}



@end
