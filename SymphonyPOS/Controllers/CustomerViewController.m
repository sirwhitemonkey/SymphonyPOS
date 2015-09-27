

#import "CustomerViewController.h"

@interface CustomerViewController ()
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) NSArray *customers;
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@end

@implementation CustomerViewController
@synthesize searchBar = _searchBar;
@synthesize customers = _customers;
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;

- (void)viewDidLoad {
    [super viewDidLoad];
    DebugLog(@"viewDidLoad");
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Customers";
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.pagingEnabled = NO;
    
    _globalStore = [persistenceManager getGlobalStore];
    
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self.view setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    [self.tableView setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    
     self.automaticallyAdjustsScrollViewInsets = NO;
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cViewCell.customer_code.text = customerStore.customer_code;
    cViewCell.customer_description.text = customerStore.customer_description;
    [service searchPatternInLabels: cViewCell.customer_description searchString:_searchBar.text];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerStore *customerStore = [_customers objectAtIndex:indexPath.row];
    _globalStore.customer_default_code = customerStore.customer_code;
    [persistenceManager saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



#pragma mark - UISearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchCustomers:) object:searchText];
    [self performSelector:@selector(searchCustomers:) withObject:searchText afterDelay:0.5];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Private methods
- (void) willEnterForegroundNotification {
    [service showPinView:self];
}

/*!
 * CustomerViewController customer's search
 */
- (void) searchCustomers:(NSString*) searchString {
    _customers = [persistenceManager getCustomerStores:searchString];
    [self.tableView reloadData];
}




@end
