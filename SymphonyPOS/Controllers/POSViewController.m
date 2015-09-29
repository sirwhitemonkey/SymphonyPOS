
#import "POSViewController.h"

@interface POSViewController ()
@property (nonatomic,strong) APIManager *apiManager;
@property (nonatomic,strong) NSArray *products;
@property (nonatomic,strong) NSString *archivedSearchStrings;
@property (nonatomic,strong)  NSIndexPath *itemSelectedIndexPath;
@property (nonatomic,weak)  UISearchBar *searchBar;
@property (nonatomic,assign) BOOL onSearchProduct;
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) CustomerStore *customerStore;
@property (nonatomic,strong) NSDictionary *themes;
@property (nonatomic,strong) DTDevices *dtdev;
@property (nonatomic,strong) NSTimer *clearTimer;
@property (nonatomic,strong) NSTimer *mfTimer;
@property (nonatomic,strong) NSTimer *mfLedTimer;
@property BOOL scPresent;
@property int position;
@property BOOL centering;
@property (nonatomic,assign) long currentRow;
@property BOOL deviceConnected;
@end


@implementation POSViewController
@synthesize apiManager = _apiManager;
@synthesize searchBar = _searchBar;
@synthesize products = _products;
@synthesize archivedSearchStrings = _archivedSearchStrings;

@synthesize centering = _centering;
@synthesize currentRow = _currentRow;
@synthesize itemSelectedIndexPath = _itemSelectedIndexPath;
@synthesize onSearchProduct = _onSearchProduct;
@synthesize globalStore = _globalStore;
@synthesize customerStore = _customerStore;
@synthesize themes = _themes;
@synthesize dtdev = _dtdev;
@synthesize clearTimer = _clearTimer;
@synthesize mfTimer = _mfTimer;
@synthesize mfLedTimer = _mfLedTimer;
@synthesize scPresent = _scPresent;
@synthesize deviceConnected = _deviceConnected;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DebugLog(@"viewDidLoad");
    [self initialiseSettings];

    self.navigationController.navigationBarHidden = NO;
    
    UIImageView *titleView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    UIImageView *headerTitleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    titleView.contentMode = UIViewContentModeScaleAspectFit;
    [headerTitleView addSubview:titleView];

    self.navigationItem.titleView = headerTitleView;
     _apiManager = [[APIManager alloc]init];
    [_apiManager syncImage:titleView url:_globalStore.my_custom_logo];
    
    
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
     [self.view setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
     [self.tableView setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
     [self.cashSalesBtn setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"button_submit"]]];
    
     self.navigationItem.hidesBackButton = YES;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.pagingEnabled = NO;
    
    // Make snapping fast
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.switchCustomer.attributedText = [[NSAttributedString alloc] initWithString:@"Switch"
                                                             attributes:underlineAttribute];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchDefaultCustomer)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.switchCustomer addGestureRecognizer:tapGestureRecognizer];
    self.switchCustomer.userInteractionEnabled = YES;
    
    
    [self updateEvents];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self lineaProDisconnect];
   
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self lineaProConnect];
    [self initialiseSettings];
    [self searchProducts:@""];
    
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
    [self initialiseSettings];
    [self onUpdateBattery];
    

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


#pragma mark - IBActions
- (IBAction)sync:(id)sender {
    DebugLog(@"sync");
    [self viewSyncPage];
}

- (IBAction)logout:(id)sender {
    DebugLog(@"logout");
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Clears  all the current sessions, transactions and settings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:nil,
                             nil];
    action.tag = 1;
    [action showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction) barcode:(id)sender  {
    DebugLog(@"barcode");
    [self.view endEditing:YES];
}

- (IBAction)removeToCart:(id)sender {
    DebugLog(@"removeToCart");
    [self.view endEditing:YES];
    _currentRow = ((UIButton*)sender).tag;
    CartStore *cartStore = [_products objectAtIndex:_currentRow];
    [persistenceManager removeCartStore:cartStore.cart_code];
    [self searchProducts:@""];
}

- (IBAction)cashSales:(id)sender {
    if ([[persistenceManager getCartStores] count] == 0) {
        [service showMessage:self loader:NO message:@"No carts available"   error:YES
          waitUntilCompleted:NO withCallBack:nil];
    } else {
        self.navigationItem.title = @"Quick Order";
        [self viewPaymentCustomerPage];
    }
}

#pragma mark - UITableView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
     [self.view endEditing:YES];
}

-(void)scrollViewWillEndDragging:(UIScrollView*)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint*)targetContentOffset {
    // Variables
    CGPoint offset              = (*targetContentOffset);
    NSIndexPath* indexPath      = [self.tableView indexPathForRowAtPoint:(*targetContentOffset)];   // Get index path for target row
    long numberOfRow = [self tableView:(UITableView *)scrollView numberOfRowsInSection:(NSInteger)indexPath.section];
    
  
    // Row at *targetContentOffset
    CGRect rowRect      = [self.tableView rectForRowAtIndexPath:indexPath];
    
    // temporary assign
    _itemSelectedIndexPath = indexPath;
    CGRect targetRect   = rowRect;
    
    
    // Next Row
    if (indexPath.row < numberOfRow - 1 ){
        NSIndexPath *nextPath   = [NSIndexPath indexPathForRow: indexPath.row + 1 inSection: indexPath.section];
        CGRect nextRowRect      = [self.tableView rectForRowAtIndexPath: nextPath];
        
        // Compare distance
        if (fabs(offset.y - CGRectGetMinY(nextRowRect)) < fabs(offset.y - CGRectGetMinY(rowRect))){
            targetRect          = nextRowRect;
            _itemSelectedIndexPath   = nextPath;
        }
    }
    
    // Centering
    offset = targetRect.origin;
    if (self.centering){
        offset.y -= (self.tableView.bounds.size.height * 0.5 - targetRect.size.height * 0.5);
    }
    
    // Assign return value
    (*targetContentOffset) = offset;
    
    // Snap speed
    float currentOffset = self.tableView.contentOffset.y;
    float rowH = targetRect.size.height;
    static const float thresholdDistanceCoef  = 0.25;
    if (fabs(currentOffset - (*targetContentOffset).y) > rowH * thresholdDistanceCoef){
        self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    } else {
        self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.tableView selectRowAtIndexPath: _itemSelectedIndexPath animated: YES scrollPosition:UITableViewScrollPositionNone];
    
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _products.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height=0;
    if (_onSearchProduct) {
        height = self.filteredProductViewCell.frame.size.height;
    } else {
        height = self.productViewCell.frame.size.height;
    }
    return height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=nil;
    
    
    if (_onSearchProduct) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"FilteredProductViewCell"];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"FilteredProductViewCell" owner:self options:nil];
            cell=self.filteredProductViewCell;
            [cell setBackgroundColor:[service colorFromHexString:
                                                  [_themes objectForKey:@"table_simple_row"]]];
        }
    } else {
        cell=[tableView dequeueReusableCellWithIdentifier:@"ProductViewCell"];
        if (cell==nil) {
            [[NSBundle mainBundle] loadNibNamed:@"ProductViewCell" owner:self options:nil];
            cell=self.productViewCell;
        }
    }
    
    ProductStore *productStore;
    
    if (_onSearchProduct) {
        
        productStore=[_products objectAtIndex:indexPath.row];
        
        FilteredProductViewCell *fpViewCell = (FilteredProductViewCell*)cell;
        fpViewCell.product_name.text = productStore.desc;
        [service searchPatternInLabels:fpViewCell.product_name searchString:_archivedSearchStrings];
    } else {
        
        if (indexPath.row % 2) {
            
            cell.contentView.backgroundColor = [service colorFromHexString:[_themes objectForKey:@"table_even_row"]];
        } else {
            cell.contentView.backgroundColor = [service colorFromHexString:[_themes objectForKey:@"table_odd_row"]];
        }

        CartStore *cartStore=[_products objectAtIndex:indexPath.row];
        productStore = cartStore.cartProduct;
        
        ProductViewCell *pViewCell = (ProductViewCell*)cell;
         pViewCell.product_name.text = productStore.desc;
         pViewCell.product_description.text = productStore.desc;
         pViewCell.unit.text = productStore.stockUnit;
        
        
        PriceStore *priceStore = [persistenceManager getPriceStore:_customerStore.priceCode
                                                      itemNo:productStore.itemNo];
        
         pViewCell.unit_price.text = [NSString stringWithFormat:@"%@ %.2f",priceStore.currency,[priceStore.unitPrice floatValue]];
        [service boxInputStyling:pViewCell.qty];
        pViewCell.qty.text = [cartStore.qty stringValue];
        pViewCell.qty.tag = indexPath.row;
        pViewCell.total.text = [NSString stringWithFormat:@"%@ %.2f", priceStore.currency,
                                ([cartStore.qty integerValue] * [priceStore.unitPrice floatValue])];
        
        pViewCell.removeToCart.tag = indexPath.row;
         [ pViewCell.removeToCart setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"button_remove"]]];
      
        [_apiManager syncImage:pViewCell.image_url url:productStore.image_url];
        
  
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_onSearchProduct) {
        ProductStore *productStore = [_products objectAtIndex:indexPath.row];
        NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
        BOOL qtyEvent = [settings boolForKey:@"qtyEvent"];
        if (qtyEvent) {
            [self viewQtyPage:productStore];
        } else {
            [self setToCart:productStore qty:[NSNumber numberWithInt:1]];
        }
    }
}

#pragma mark - QtyViewControllerDelegate
- (void)qtyDidCompleted:(QtyViewController*)controller qty:(NSNumber *)qty productStore:(ProductStore *)productStore{
    [controller dismissViewControllerAnimated:NO completion:nil];
    [self setToCart:productStore qty:qty];
    if (_deviceConnected) {
        [_dtdev barcodeStartScan:nil];
    }
}

#pragma mark - SyncViewControllerDelegate
- (void)syncDidCompleted:(SyncViewController *)controller {
    DebugLog(@"syncDidCompleted");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) syncDidError:(SyncViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UISearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchProducts:) object:searchText];
    [self performSelector:@selector(searchProducts:) withObject:searchText afterDelay:0.5];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}



#pragma mark - UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ( [finalString length] <= 3 ) {
        CartStore *cartStore = [_products objectAtIndex:textField.tag];
        cartStore = [persistenceManager getCartStore:cartStore.cart_code];
        if (cartStore) {
            [persistenceManager updateCartStore:cartStore.cart_code qty: [NSNumber numberWithLong:[finalString integerValue]]];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchProducts:) object:@""];
        [self performSelector:@selector(searchProducts:) withObject:@"" afterDelay:2.0];

        return YES;
    }
    return NO;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
    _currentRow  = textField.tag;
}



#pragma mark - Notifications

- (void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification{
    
    if (_products.count == 0) {
        return;
    }
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    [self.tableView setContentInset:contentInsets];
    [self.tableView setScrollIndicatorInsets:contentInsets];
    
    
    NSIndexPath *currentRowIndex = [NSIndexPath indexPathForRow:_currentRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:currentRowIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [self.tableView setContentInset:contentInsets];
    [self.tableView setScrollIndicatorInsets:contentInsets];
}

#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)action clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (action.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [persistenceManager clearCache];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma  mark - LineaPro DT Device

-(void)connectionState:(int)state {
    DebugLog(@"connectionState ->%d",state);
    switch (state) {
        case CONN_DISCONNECTED:
        case CONN_CONNECTING:
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
            [self.dtConnectionState setImage:[UIImage imageNamed:@"disconnected"]];
            [self.batteryBtn setHidden:YES];
            _deviceConnected = NO;
            break;
        case CONN_CONNECTED:
        {
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            /*[displayText setText:[NSString stringWithFormat:@"PPad connected!\nSDK version: %d.%d\nHardware revision: %@\nFirmware revision: %@\nSerial number: %@",dtdev.sdkVersion/100,dtdev.sdkVersion%100,dtdev.hardwareRevision,dtdev.firmwareRevision,dtdev.serialNumber]];
             */
            [self.dtConnectionState setImage:[UIImage imageNamed:@"connected"]];
            
            _scPresent=[_dtdev scInit:SLOT_MAIN error:nil];
            //since we work with AES encrypted or plain card data, make sure device is sending it
            [_dtdev emsrSetEncryption:ALG_EH_AES256 params:nil error:nil];
            //            [ppad sysLEDControl:0 pattern:0];
            //            [ppad sysLEDControl:1 pattern:0xFFFF];
            //            [ppad sysLEDControl:2 pattern:0xFFFF];
            //            [ppad sysLEDControl:3 pattern:0xFFFF];
            
            
            //if we are connected to a device not supporting pin entry, but has bluetooth in, try to find something around to connect to
            //            if([dtdev getSupportedFeature:FEAT_PIN_ENTRY error:nil]!=FEAT_SUPPORTED && [dtdev getSupportedFeature:FEAT_BLUETOOTH error:nil]&BLUETOOTH_CLIENT)
            //                [self performSelectorOnMainThread:@selector(showBTController) withObject:nil waitUntilDone:false];
            
            NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
            NSString *scanMode = [settings objectForKey:@"scanMode"];
            [_dtdev barcodeSetScanMode:[scanMode intValue] error:nil];
            [persistenceManager setDataStore:SCAN_MODE value:scanMode];
            
            // Enable barcode scan
            [_dtdev barcodeStartScan:nil];
            
            // Disable the magnetic card reader
            [_dtdev msDisable:nil];
            
            [self onUpdateBattery];
            _deviceConnected = YES;
            
            
            break;
        }
    }
}

-(void)barcodeData:(NSString *)barcode type:(int)type{
    //[service showAlert:@"Barcode" message:[NSString stringWithFormat:@"Type: %@\nBarcode: %@",[_dtdev barcodeType2Text:type],barcode]];
    [self.view endEditing:YES];
    ProductStore *productStore = [persistenceManager getProductStoreByUpcCode:barcode];
    if (productStore == nil) {
        [service showMessage:self loader:NO message:@"Pc code of this item not available" error:YES
          waitUntilCompleted:NO withCallBack:nil];
    } else {
        NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
        BOOL qtyEvent = [settings boolForKey:@"qtyEvent"];
        if (qtyEvent) {
            [self viewQtyPage:productStore];
        } else {
            [self setToCart:productStore qty:[NSNumber numberWithInt:1]];
        }
    }
}


#pragma mark - Private methods
- (void) willEnterForegroundNotification {
    [service showPinView:self];
    
    [self updateEvents];
    [self lineaProConnect];
       
    
}

- (void) didEnterBackgroundNotification {
    [self lineaProDisconnect];
}

/*!
 * POSViewController updating the events (i.e sync and logout)
 */
- (void) updateEvents {
    
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    BOOL syncEvent = [settings boolForKey:@"syncEvent"];
    if (syncEvent) {
        self.navigationItem.leftBarButtonItem = self.syncBtn;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    BOOL logoutEvent = [settings boolForKey:@"logoutEvent"];
    if (logoutEvent) {
        self.navigationItem.rightBarButtonItem = self.logoutBtn;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

/*!
 * POSViewController searching the products
 */
- (void) searchProducts:(NSString*) searchString {
    _archivedSearchStrings = searchString;
    _onSearchProduct = false;
    if (![service isEmptyString:_archivedSearchStrings]) {
        _onSearchProduct = true;
        _products = [persistenceManager getProductStores:searchString];

    } else {
         _products = [persistenceManager getCartStores];
    }
    [self finaliseGrandTotals];
    [self.tableView reloadData];
}

/*!
 * POSViewController switching the customer
 */
- (void)switchDefaultCustomer {
    DebugLog(@"switchDefaultCustomer");
    self.navigationItem.title = @"Quick Order";
    [self viewCustomerPage];
}

/*!
 * POSViewController initialisation
 */
- (void) initialiseSettings {
    _globalStore = [persistenceManager getGlobalStore];
    _customerStore = [persistenceManager getCustomerStore:_globalStore.customer_default_code];
    self.customer.text = _customerStore.name;
}

/*!
 * POSViewController finalising the grand totals
 */
- (void)finaliseGrandTotals {
    float spTax = [_globalStore.sales_percentage_tax floatValue];
    self.salesPercentageTax.text = @"";
    self.subTotals.text = @"";
    self.grandTotals.text = @"";
    float subTotals = 0;
    NSString *currency;
    NSArray *cartStores = [persistenceManager getCartStores];
    for (CartStore *cartStore in cartStores) {
        ProductStore *productStore = cartStore.cartProduct;
        
        PriceStore *priceStore = [persistenceManager getPriceStore:_customerStore.priceCode itemNo:productStore.itemNo];
        subTotals += ([priceStore.unitPrice floatValue] * (float)[cartStore.qty integerValue]);
        if ([service isEmptyString:currency]) {
            currency = priceStore.currency;
        }
    }
    currency = (!currency ? @"" : currency);
    self.subTotals.text = [NSString stringWithFormat:@"%@ %.2f",currency,subTotals];
    float salesPercentTaxTotals = (subTotals *  (spTax/100));
    
    self.salesPercentageTax.text =[NSString stringWithFormat:@"%@ %.2f (%@%@)",currency,salesPercentTaxTotals,[_globalStore.sales_percentage_tax stringValue],@"%"];
    self.grandTotals.text = [NSString stringWithFormat:@"%@ %.2f",currency, (subTotals-salesPercentTaxTotals)];
    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:subTotals], @"subTotals",
                          [NSNumber numberWithDouble:salesPercentTaxTotals],@"salesPercentageTax",
                          [NSNumber numberWithDouble:(subTotals-salesPercentTaxTotals)], @"grandTotals",
                          currency, @"currency",nil];
    
    [persistenceManager setDataStore:CASH_SALES value:data];
}

/*!
 * POSViewController navigate to customer page
 */
- (void ) viewCustomerPage {
    [self performSegueWithIdentifier:@"CustomerSegue" sender:self];
}

/*!
 * POSViewController navigate to payment customer page
 */
- (void) viewPaymentCustomerPage {
    [self performSegueWithIdentifier:@"PaymentCustomerSegue" sender:self];
}

/*!
 * POSViewController linea pro device connect
 */
- (void) lineaProConnect {
    DebugLog(@"lineaProConnect");
    _dtdev=[DTDevices sharedDevice];
    [_dtdev addDelegate:self];
    [_dtdev connect ];

}

/*!
 * POSViewController linea pro device disconnect
 */
- (void) lineaProDisconnect {
    DebugLog(@"lineaProDisconnect");
    [_dtdev removeDelegate:self];
    [_dtdev disconnect];
}

/*!
 * POSViewController linea pro device battery updates
 */
- (void) onUpdateBattery {
    DebugLog(@"onUpdateBattery");
    int percent;
    float voltage;
    
    
    if([_dtdev getBatteryCapacity:&percent voltage:&voltage error:nil]) {
        [self.batteryBtn setHidden:NO];
        [self.batteryBtn setTitle:[NSString stringWithFormat:@"%.2fv, %d%%",voltage,percent]
                         forState:UIControlStateNormal];
        
        DebugLog(@"onUpdateBatterty -> battery info %d",percent);
        
        if(percent<10) {
            [self.batteryBtn setBackgroundImage:[UIImage imageNamed:@"batt_info_0"] forState:UIControlStateNormal];
        }
        else if(percent<40) {
            [self.batteryBtn setBackgroundImage:[UIImage imageNamed:@"batt_info_25"] forState:UIControlStateNormal];
        }
        else if(percent<60) {
            [self.batteryBtn setBackgroundImage:[UIImage imageNamed:@"batt_info_50"] forState:UIControlStateNormal];
        }
        else if(percent<80) {
            [self.batteryBtn setBackgroundImage:[UIImage imageNamed:@"batt_info_75"] forState:UIControlStateNormal];
        }
        else {
            [self.batteryBtn setBackgroundImage:[UIImage imageNamed:@"batt_info_100"] forState:UIControlStateNormal];
        }

    } else {
        [self.batteryBtn setHidden:YES];
        
    }

}

/*!
 * POSViewController  setting the cart's purchased
 */
- (void)setToCart:(ProductStore*)productStore qty:(NSNumber*)qty{
    CartStore *cartStore = [persistenceManager getCartByProductStore:productStore.itemNo];
    if (!cartStore) {
        [persistenceManager setCartStore:qty productStore:productStore];
    } else {
        long qtyPurchased = [cartStore.qty longValue] + [qty integerValue];
        [persistenceManager updateCartStore:cartStore.cart_code qty:[NSNumber numberWithLong:qtyPurchased]];
    }
    [self searchProducts:@""];
    _searchBar.text = @"";
    
    if (!_deviceConnected) {
        [_searchBar becomeFirstResponder];
    }
    for (int idx=0;idx<_products.count;idx++) {
        cartStore  = _products[idx];
        if (cartStore.cartProduct.itemNo == productStore.itemNo) {
            _currentRow = idx;
            break;
        }
    }
    NSIndexPath *currentRowIndex = [NSIndexPath indexPathForRow:_currentRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:currentRowIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

/*!
 * POSViewController navigate to Qty page
 */
- (void) viewQtyPage:(ProductStore*)productStore {
    QtyViewController *controller = (QtyViewController*)[persistenceManager getView:@"QtyViewController"];
    controller.delegate =self;
    [controller initialise:productStore];
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:controller animated:NO completion: nil];
    if (_deviceConnected) {
        [_dtdev barcodeStopScan:nil];
    }
}

/*!
 * POSViewController navigate to sync page
 */
- (void) viewSyncPage {
    SyncViewController *controller = (SyncViewController*)[persistenceManager getView:@"SyncViewController"];
    controller.delegate = self;
    controller.settings = NO;
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:controller animated:NO completion: ^ {
        [controller sync];
    }];
}


@end
