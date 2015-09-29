

#import "PaymentViewController.h"


@interface PaymentViewController ()
@property (nonatomic,strong) APIManager *apiManager;
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@property (nonatomic,strong) NSNumber *subTotals;
@property (nonatomic,strong) NSNumber *salesPercentageTax;
@property (nonatomic,strong) NSNumber *grandTotals;
@property (nonatomic,strong) NSString *currency;
@property (nonatomic,strong) NSString *paymentType;
@property (nonatomic,strong) UIImage *signature;
@property (nonatomic,strong) DTDevices *dtdev;
@property BOOL scPresent;

@end

@implementation PaymentViewController
@synthesize apiManager = _apiManager;
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;
@synthesize subTotals = _subTotals;
@synthesize salesPercentageTax = _salesPercentageTax;
@synthesize grandTotals = _grandTotals;
@synthesize currency = _currency;
@synthesize paymentType = _paymentType;
@synthesize signature = _signature;
@synthesize dtdev = _dtdev;
@synthesize scPresent = _scPresent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = [persistenceManager getDataStore:PAYMENT_TYPE];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.pagingEnabled = NO;
    
     _apiManager = [[APIManager alloc]init];
    
    // Make snapping fast
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    _globalStore = [persistenceManager getGlobalStore];
    
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self.view setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    [self.tableView setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    
    NSDictionary *cashSales = [persistenceManager getDataStore:CASH_SALES];
    _currency = [cashSales objectForKey:@"currency"];
    _subTotals = [cashSales objectForKey:@"subTotals"];
    _salesPercentageTax = [cashSales objectForKey:@"salesPercentageTax"];
    _grandTotals = [cashSales objectForKey:@"grandTotals"];
    
    _paymentType = [persistenceManager getDataStore:PAYMENT_TYPE];
    
    if ([_paymentType isEqualToString:PAYMENT_CASH] ||
        [_paymentType isEqualToString:PAYMENT_EFTPOS]) {
        self.tableView.bounces = NO;
    } else {
        if ([persistenceManager getDataStore:PAYMENT_CREDITCARDSIGNATURE] != nil) {
            _signature = [persistenceManager getDataStore:PAYMENT_CREDITCARDSIGNATURE];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerNotifications];
    if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        [self lineaProConnect];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        [self lineaProDisconnect];
    }
    
}


#pragma  mark - LineaPro DT Device

- (void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3
{
    NSDictionary *card=[_dtdev msProcessFinancialCard:track1 track2:track2];
    if(card && [card objectForKey:@"accountNumber"]!=nil && [[card objectForKey:@"expirationYear"] intValue]!=0){
        DebugLog(@"magneticCardData -> %@", card);
        NSString *accountNumber = [card objectForKey:@"accountNumber"];
        NSString *cardholderName = [card objectForKey:@"cardholderName"];
        NSString *expirationMonth = [card objectForKey:@"expirationMonth"];
        NSString *expirationYear = [card objectForKey:@"expirationYear"];
        NSString *cardType = [self creditCardType:accountNumber];
        
        if (cardType == nil) {
            [service showMessage:self loader:NO message:@"Credit card not supported at this time" error:YES   waitUntilCompleted:NO withCallBack:nil];
    
        } else {
            [persistenceManager setDataStore:PAYMENT_CREDITCARDTYPE value:cardType];
            RoundedButton *cardTypeBtn = nil;
            if ([cardType isEqualToString:@"Visa"]) {
                cardTypeBtn = (RoundedButton*)[self.creditCardViewCell viewWithTag:CARD_VISA];
            } else if ([cardType isEqualToString:@"MasterCard"]) {
                cardTypeBtn = (RoundedButton*)[self.creditCardViewCell viewWithTag:CARD_MASTERCARD];
            }else if ([cardType isEqualToString:@"AmericanExpress"]) {
                cardTypeBtn = (RoundedButton*)[self.creditCardViewCell viewWithTag:CARD_AMERICANEXPRESS];
            }
            cardTypeBtn.selected = YES;
            self.creditCardViewCell.cardHolderName.text = cardholderName;
            self.creditCardViewCell.creditCardNumber.text = accountNumber;
            self.creditCardViewCell.expiryDateMonth.text = expirationMonth;
            self.creditCardViewCell.expiryDateYear.text = expirationYear;
            
            int sound[]={2730,150,0,30,2730,150};
            [_dtdev playSound:100 beepData:sound length:sizeof(sound) error:nil];
        }
    }else{
        [service showMessage:self loader:NO message:@"Use a valid payment card" error:YES waitUntilCompleted:NO  withCallBack:nil];
    }
    
}

/*
-(uint16_t)crc16:(uint8_t *)data length:(int)length crc16:(uint16_t)crc16
{
    if(length==0) return 0;
    int i=0;
    while(length--)
    {
        crc16=(uint8_t)(crc16>>8)|(crc16<<8);
        crc16^=*data++;
        crc16^=(uint8_t)(crc16&0xff)>>4;
        crc16^=(crc16<<8)<<4;
        crc16^=((crc16&0xff)<<4)<<1;
        i++;
    }
    return crc16;
}


-(void)magneticCardEncryptedData:(int)encryption tracks:(int)tracks data:(NSData *)data
{
    DebugLog(@"Encrypted card data, tracks: %d, encryption: %d",tracks,encryption);
    
    NSString *decryptionKey = DECRYPTION_KEY;
    
    if(encryption==ALG_AES256 || encryption==ALG_EH_AES256)
    {
        NSData *decrypted=[data AESDecryptWithKey:[decryptionKey dataUsingEncoding:NSASCIIStringEncoding]];
        //basic check if the decrypted data is valid
        if(decrypted && decrypted.length && decrypted.bytes)
        {
            uint8_t *bytes=(uint8_t *)decrypted.bytes;
            for(int i=0;i<([decrypted length]-2);i++)
            {
                if(i>(4+16) && !bytes[i])
                {
                    uint16_t crc16=[self crc16:bytes length:(i+1) crc16:0];
                    uint16_t crc16Data=(bytes[i+1]<<8)|bytes[i+2];
                    
                    if(crc16==crc16Data)
                    {
                        int snLen=0;
                        for(snLen=0;snLen<16;snLen++)
                            if(!bytes[4+snLen])
                                break;
                        NSString *sn=[[NSString alloc] initWithBytes:&bytes[4] length:snLen encoding:NSASCIIStringEncoding];
                        //do something with that serial number
                        DebugLog(@"Serial number in encrypted packet: %@",sn);
                        
                        //crc matches, extract the tracks then
                        int dataLen=i;
                        //check for JIS card
                        if(bytes[4+16]==0xF5)
                        {
                        }else
                        {
                            int t1=-1,t2=-1,t3=-1,tend;
                            NSString *track1=nil,*track2=nil,*track3=nil;
                            //find the tracks offset
                            for(int j=(4+16);j<dataLen;j++)
                            {
                                if(bytes[j]==0xF1)
                                    t1=j;
                                if(bytes[j]==0xF2)
                                    t2=j;
                                if(bytes[j]==0xF3)
                                    t3=j;
                            }
                            if(t1!=-1)
                            {
                                if(t2!=-1)
                                    tend=t2;
                                else
                                    if(t3!=-1)
                                        tend=t3;
                                    else
                                        tend=dataLen;
                                track1=[[NSString alloc] initWithBytes:&bytes[t1+1] length:(tend-t1-1) encoding:NSASCIIStringEncoding];
                            }
                            if(t2!=-1)
                            {
                                if(t3!=-1)
                                    tend=t3;
                                else
                                    tend=dataLen;
                                track2=[[NSString alloc] initWithBytes:&bytes[t2+1] length:(tend-t2-1) encoding:NSASCIIStringEncoding];
                            }
                            if(t3!=-1)
                            {
                                tend=dataLen;
                                track3=[[NSString alloc] initWithBytes:&bytes[t3+1] length:(tend-t3-1) encoding:NSASCIIStringEncoding];
                            }
                            
                            //pass to the non-encrypted function to display tracks
                            [self magneticCardData:track1 track2:track2 track3:track3];
                        }
                        return;
                    }
                }
            }
        }else {
            [service showMessage:self message:@"Invalid payment card decryption" error:YES
                           withCallBack:nil];
        }
    }
}
 */

-(void)connectionState:(int)state {
    DebugLog(@"connectionState ->%d",state);
    switch (state) {
        case CONN_DISCONNECTED:
        case CONN_CONNECTING:
            [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
            [self.creditCardViewCell.dtConnectionState setImage:[UIImage imageNamed:@"disconnected"]];
            [self.creditCardViewCell.batteryBtn setHidden:YES];
            break;
        case CONN_CONNECTED:
        {
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            /*[displayText setText:[NSString stringWithFormat:@"PPad connected!\nSDK version: %d.%d\nHardware revision: %@\nFirmware revision: %@\nSerial number: %@",dtdev.sdkVersion/100,dtdev.sdkVersion%100,dtdev.hardwareRevision,dtdev.firmwareRevision,dtdev.serialNumber]];
             */
            [self.creditCardViewCell.dtConnectionState setImage:[UIImage imageNamed:@"connected"]];
            
            _scPresent=[_dtdev scInit:SLOT_MAIN error:nil];
            
            //since we work with AES encrypted or plain card data, make sure device is sending it
            [_dtdev emsrSetEncryption:ALG_EH_AES256 params:nil error:nil];
            //            [ppad sysLEDControl:0 pattern:0];
            //            [ppad sysLEDControl:1 pattern:0xFFFF];
            //            [ppad sysLEDControl:2 pattern:0xFFFF];
            //            [ppad sysLEDControl:3 pattern:0xFFFF];
            
            [self onUpdateBattery];
            
            //if we are connected to a device not supporting pin entry, but has bluetooth in, try to find something around to connect to
            //            if([dtdev getSupportedFeature:FEAT_PIN_ENTRY error:nil]!=FEAT_SUPPORTED && [dtdev getSupportedFeature:FEAT_BLUETOOTH error:nil]&BLUETOOTH_CLIENT)
            //                [self performSelectorOnMainThread:@selector(showBTController) withObject:nil waitUntilDone:false];
            
            // Enable magnetic card reader
            [_dtdev msEnable:nil];
            
            // Disable barcode scan
            [_dtdev barcodeStopScan:nil];
            break;
        }
    }
}


-(void)smartCardInserted:(SC_SLOTS)slot;{
    NSData *atr=[_dtdev scCardPowerOn:slot error:nil];
    
    if(atr) {
        if([_dtdev emvATRValidation:atr warmReset:false error:nil]){
            DebugLog(@"smartCardInserted valid");
            return;
        }
    } else {
        [service showMessage:self loader:NO message:@"The SmartCard inserted is inserted the wrong way or is non-EMV SmartCard" error:YES waitUntilCompleted:NO withCallBack:nil];
        
    }
    
}


-(void)smartCardRemoved {
    DebugLog(@"smartCardRemoved");
}

#pragma mark - Notifications

- (void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - IBActions
- (IBAction)next:(id)sender {
    [self.view endEditing:YES];
    if ([self validatePaymentEntries]) {
        if (!persistenceManager.offline) {
            [self checkConnection];
        } else {
            [self viewSubmitPage];
        }
    }
}

- (IBAction)paymentCreditCardType:(id)sender {
    DebugLog(@"paymentCreditCardType");
    switch (((UIButton*)sender).tag) {
        case CARD_VISA:
            [persistenceManager setDataStore:PAYMENT_CREDITCARDTYPE value:@"Visa"];
            break;
        case CARD_MASTERCARD:
            [persistenceManager setDataStore:PAYMENT_CREDITCARDTYPE value:@"MasterCard"];
            break;
        case CARD_AMERICANEXPRESS:
            [persistenceManager setDataStore:PAYMENT_CREDITCARDTYPE value:@"AmericanExpress"];
            break;
    }
}

#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)action clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (action.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [persistenceManager setDataStore:PAYMENT_TYPE value:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - APIManager
- (void) apiRequestError:(NSError *)error {
    DebugLog(@"apiRequestError -> %@",error);
    
    if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"OFFLINE: Change your payment type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Change" otherButtonTitles:nil,
                                 nil];
        action.tag = 1;
        [action showInView:[UIApplication sharedApplication].keyWindow];
        
    }
    
}

- (void)apiCheckConnnectionResponse:(Response *)response {
    [self viewSubmitPage];
}


#pragma mark - UITableView



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height =0.0f;
    NSString *paymentType = [persistenceManager getDataStore:PAYMENT_TYPE];
    if ([paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        height = self.creditCardViewCell.frame.size.height;
        
    } else if ([paymentType isEqualToString:PAYMENT_EFTPOS]) {
        height = self.eftposViewCell.frame.size.height;
        
    } else if ([paymentType isEqualToString:PAYMENT_CASH]) {
        height = self.cashViewCell.frame.size.height;
    }
    return height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=nil;
    NSDictionary *data= nil;
    if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        NSData * dataCreditCard = [[persistenceManager getKeyChain:_paymentType] dataUsingEncoding:NSUTF8StringEncoding];
        if (dataCreditCard) {
            data = [NSJSONSerialization JSONObjectWithData:dataCreditCard options:0 error:nil];
        }
    } else {
        data = [persistenceManager getDataStore:_paymentType];
    }
    
    if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"CreditCardViewCell"];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"CreditCardViewCell" owner:self options:nil];
            cell=self.creditCardViewCell;
            CreditCardViewCell *ccViewCell = (CreditCardViewCell*)cell;
            [ccViewCell.nextBtn setBackgroundColor:[service colorFromHexString:
                                                    [_themes objectForKey:@"button_submit"]]];
            ccViewCell.subTotals.text = [NSString stringWithFormat:@"%@ %.2f",_currency,[_subTotals floatValue]];
            ccViewCell.salesPercentageTax.text =[NSString stringWithFormat:@"%@ %.2f (%@%@)",_currency,
                                                 [_salesPercentageTax floatValue],
                                                 [_globalStore.sales_percentage_tax stringValue],@"%"];
            
            ccViewCell.grandTotals.text = [NSString stringWithFormat:@"%@ %.2f",_currency, ([_subTotals floatValue] -[_salesPercentageTax floatValue])];
            
            if (data) {
                NSString *decryptCard = nil;
                ccViewCell.cardHolderName.text = [data objectForKey:@"cardHolderName"];
                decryptCard = [ service decrypt:[data objectForKey:@"creditCardNumber"] key:[persistenceManager getKeyChain:PASSKEY]];
                
                decryptCard = [service trim:decryptCard];
                
                 ccViewCell.creditCardNumber.text = decryptCard;
                
                ccViewCell.expiryDateMonth.text = [data objectForKey:@"expMonth"];
                ccViewCell.expiryDateYear.text = [data objectForKey:@"expYear"];
                
                if (![service isEmptyString:[data objectForKey:@"securityCode"]]) {
                     NSString *decryptSecurityCode = [ service decrypt:[data objectForKey:@"securityCode"] key:[persistenceManager getKeyChain:PASSKEY]];
                    
                    decryptSecurityCode= [service trim:decryptSecurityCode];
                    ccViewCell.securityCode.text = decryptSecurityCode;
                }
                
                NSString *cardType = [persistenceManager getDataStore:PAYMENT_CREDITCARDTYPE];
                RoundedButton *cardTypeBtn = nil;
                if ([cardType isEqualToString:@"Visa"]) {
                    cardTypeBtn = (RoundedButton*)[self.creditCardViewCell viewWithTag:CARD_VISA];
                } else if ([cardType isEqualToString:@"MasterCard"]) {
                    cardTypeBtn = (RoundedButton*)[self.creditCardViewCell viewWithTag:CARD_MASTERCARD];
                }else if ([cardType isEqualToString:@"AmericanExpress"]) {
                    cardTypeBtn = (RoundedButton*)[self.creditCardViewCell viewWithTag:CARD_AMERICANEXPRESS];
                }
                cardTypeBtn.selected = YES;

           }
            NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            ccViewCell.provideSignature.attributedText = [[NSAttributedString alloc] initWithString:@"Or provide your signature:"
                                                                                         attributes:underlineAttribute];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(provideSignature)];
            tapGestureRecognizer.numberOfTapsRequired = 1;
            [ccViewCell.provideSignature addGestureRecognizer:tapGestureRecognizer];
            ccViewCell.provideSignature.userInteractionEnabled = YES;
        }
        
    } else if ([_paymentType isEqualToString:PAYMENT_EFTPOS]) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"EFTPOSViewCell"];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"EFTPOSViewCell" owner:self options:nil];
            cell=self.eftposViewCell;
            EFTPOSViewCell *eViewCell = (EFTPOSViewCell*)cell;
            [eViewCell.nextBtn setBackgroundColor:[service colorFromHexString:
                                                   [_themes objectForKey:@"button_submit"]]];
            
            [eViewCell.nextBtn setBackgroundColor:[service colorFromHexString:
                                                   [_themes objectForKey:@"button_submit"]]];
            eViewCell.subTotals.text = [NSString stringWithFormat:@"%@ %.2f",_currency,[_subTotals floatValue]];
            eViewCell.salesPercentageTax.text =[NSString stringWithFormat:@"%@ %.2f (%@%@)",_currency,
                                                [_salesPercentageTax floatValue],
                                                [_globalStore.sales_percentage_tax stringValue],@"%"];
            
            eViewCell.grandTotals.text = [NSString stringWithFormat:@"%@ %.2f",_currency, ([_subTotals floatValue] -[_salesPercentageTax floatValue])];
            
        }
        
    } else if ([_paymentType isEqualToString:PAYMENT_CASH]) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"CashViewCell"];
        if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"CashViewCell" owner:self options:nil];
            cell=self.cashViewCell;
            CashViewCell *cViewCell = (CashViewCell*)cell;
            ;
            [cViewCell.nextBtn setBackgroundColor:[service colorFromHexString:
                                                   [_themes objectForKey:@"button_submit"]]];
            cViewCell.subTotals.text = [NSString stringWithFormat:@"%@ %.2f",_currency,[_subTotals floatValue]];
            cViewCell.salesPercentageTax.text =[NSString stringWithFormat:@"%@ %.2f (%@%@)",_currency,
                                                [_salesPercentageTax floatValue],
                                                [_globalStore.sales_percentage_tax stringValue],@"%"];
            
            cViewCell.grandTotals.text = [NSString stringWithFormat:@"%@ %.2f",_currency, ([_subTotals floatValue] -[_salesPercentageTax floatValue])];
            if (data) {
                cViewCell.amountPaid.text = [data objectForKey:@"amountPaid"];
            }
            
        }
    }
    [cell.contentView setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    
    return cell;
}

#pragma  mark - UITextField
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [service setPlaceHolder:textField error:NO];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        if (textField.tag == 0) { // Cardholder name
            NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHA_CHARACTERS] invertedSet];
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            return [string isEqualToString:filtered];
        }
        
        if (textField.tag == 1) { // Credit card number
            if (finalString.length <= 19 ) {
                return YES;
            }
        }
        
        if (textField.tag == 2) { // Exp. date month
            if (finalString.length <= 2 && [finalString integerValue] <= 12) {
                return YES;
            }
        }
        
        if (textField.tag == 3) { // Exp. date year
            if (finalString.length <= 4) {
                return YES;
            }
        }
        
        if (textField.tag == 4) { // Security code
            if (finalString.length <= 3) {
                return YES;
            }
        }
    }
    else if ([_paymentType isEqualToString:PAYMENT_CASH]) {
        float amountPaid = [finalString floatValue];
        self.cashViewCell.balance.text = [NSString stringWithFormat:@"%@ %.2f",_currency,
                                          ([_grandTotals floatValue] - amountPaid)];
        return YES;
    }
    return NO;
}


#pragma mark - SignatureViewControllerDelegate
- (void) didSignatureFinished:(SignatureViewController *)controller image:(UIImage *)image {
    [controller dismissViewControllerAnimated:YES completion:nil];
    _signature = image;
    if (!_signature) {
        [persistenceManager removeDataStore:PAYMENT_CREDITCARDSIGNATURE];
    } else {
        [persistenceManager setDataStore:PAYMENT_CREDITCARDSIGNATURE value:_signature];
    }
}

#pragma mark - Private methods
/*!
 * PaymentViewController checking the connection
 */
- (void) checkConnection {
   
    _apiManager.delegate = self;
    AFHTTPRequestOperation *checkConnection = [_apiManager checkConnection];
    if (checkConnection) {
        [checkConnection start];
    }
}

/*!
 * PaymentViewController validating the payment entries
 */
- (BOOL) validatePaymentEntries {
    BOOL validate = true;
    NSDictionary *data = nil;
    BOOL dialog = false;
    if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        
        if ([service isEmptyString:self.creditCardViewCell.cardHolderName.text]) {
            [service setPlaceHolder:self.creditCardViewCell.cardHolderName error:YES];
            validate = false;
        }
        if ([service isEmptyString:self.creditCardViewCell.creditCardNumber.text]) {
            [service setPlaceHolder:self.creditCardViewCell.creditCardNumber error:YES];
            validate = false;
            
        } else {
            NSString *creditCardNumber = self.creditCardViewCell.creditCardNumber.text;
            
            if (![self creditCardValidator:creditCardNumber]) {
                validate = false;
            
                if (!dialog) {
                    [service showMessage:self  loader:NO message:@"Invalid credit card number" error:YES waitUntilCompleted:NO  withCallBack:nil];
                    dialog  = true;
                }
                
            }
        }
        if ([service isEmptyString:self.creditCardViewCell.expiryDateMonth.text]) {
            [service setPlaceHolder:self.creditCardViewCell.expiryDateMonth error:YES];
            validate = false;
        }
        if ([service isEmptyString:self.creditCardViewCell.expiryDateYear.text] ||
            self.creditCardViewCell.expiryDateYear.text.length < 4) {
            [service setPlaceHolder:self.creditCardViewCell.expiryDateYear error:YES];
             validate =false;
            if (!dialog) {
                [service showMessage:self loader:NO message:@"Invalid year (i.e 2016)"
                                      error:YES waitUntilCompleted:NO withCallBack:nil];
                dialog = true;
            }
        }
        if (_signature == nil && [service isEmptyString:self.creditCardViewCell.securityCode.text]) {
            [service setPlaceHolder:self.creditCardViewCell.securityCode error:YES];
            
            validate = false;
            if (!dialog) {
                [service showMessage: self loader:NO message:@"Provide security code or signature"
                                      error:YES waitUntilCompleted:NO withCallBack:nil];
            }
        }
        if (validate) {
            NSString *signatureData = nil;
            if (_signature != nil) {
                signatureData = [UIImagePNGRepresentation(_signature)
                                 base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            }
            NSString *creditCardNumber = self.creditCardViewCell.creditCardNumber.text;
            NSString *securityCode = self.creditCardViewCell.securityCode.text;
           creditCardNumber = [service encrypt:creditCardNumber key:[persistenceManager getKeyChain:PASSKEY]];
            
            if (![service isEmptyString:self.creditCardViewCell.securityCode.text]) {
                securityCode = [service encrypt:securityCode key:[persistenceManager getKeyChain:PASSKEY]];
            }
            
            data = [[NSDictionary alloc] initWithObjectsAndKeys:self.creditCardViewCell.cardHolderName.text, @"cardHolderName",
                    creditCardNumber,@"creditCardNumber",
                    self.creditCardViewCell.expiryDateMonth.text, @"expMonth",
                    self.creditCardViewCell.expiryDateYear.text, @"expYear",
                    securityCode, @"securityCode",
                    signatureData, @"signature",
                    [persistenceManager getDataStore:PAYMENT_CREDITCARDTYPE],@"paymentCreditCardType",nil];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:nil];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [persistenceManager setKeyChain:_paymentType value:jsonString];
        }
    }
    else if ([_paymentType isEqualToString:PAYMENT_CASH]) {
        
        if ([service isEmptyString:self.cashViewCell.amountPaid.text]) {
            [service setPlaceHolder:self.cashViewCell.amountPaid error:YES];
            validate = false;
        } else {
            float amountPaid = [self.cashViewCell.amountPaid.text floatValue];
            if (amountPaid < [_grandTotals floatValue]) {
                [service showMessage:self loader:NO message:@"Pay the 'Grand Total' amount" error:YES  waitUntilCompleted:NO withCallBack:nil];
                validate = false;
            }
            if (validate) {
                float balance = [self.cashViewCell.amountPaid.text floatValue] - [_grandTotals floatValue];
                data = [[NSDictionary alloc] initWithObjectsAndKeys:self.cashViewCell.amountPaid.text, @"amountPaid",
                        [NSString stringWithFormat:@"%.2f",balance] ,@"balance",nil];
                [persistenceManager setDataStore:_paymentType value:data];
            }
        }
    }
    return  validate;
}

/*!
 * PaymentViewController navigate to submit page
 */
- (void) viewSubmitPage {
    self.navigationItem.title = [persistenceManager getDataStore:PAYMENT_TYPE];
    [self performSegueWithIdentifier:@"SubmitSegue" sender:self];
}

/*!
 * PaymentViewController validating the credit cards
 */
- (BOOL) creditCardValidator:(NSString*)creditCardNumber {
    
    int luhn = 0;
    
    for (int i=0;i<[creditCardNumber length];i++){
        
        NSUInteger count = [creditCardNumber length]-1; // Prevents Bounds Error and makes characterAtIndex easier to read
        
        int doubled = [[NSNumber numberWithUnsignedChar:[creditCardNumber characterAtIndex:count-i]] intValue]
        - kMagicSubtractionNumber;
        
        if (i % 2) {
            doubled = doubled*2;
        }
        
        NSString *double_digit = [NSString stringWithFormat:@"%d",doubled];
        
        if ([[NSString stringWithFormat:@"%d",doubled] length] > 1){
            luhn = luhn + [[NSNumber numberWithUnsignedChar:[double_digit characterAtIndex:0]] intValue]-kMagicSubtractionNumber;
            
            luhn = luhn + [[NSNumber numberWithUnsignedChar:[double_digit characterAtIndex:1]] intValue]-kMagicSubtractionNumber;
        }
        else{
            luhn = luhn + doubled;
        }
        
    }
    
    // If Luhn/10's Remainder is Equal to Zero, the number is valid
    if (luhn%10 == 0) {
        NSString *paymentCreditCardType =[persistenceManager getDataStore:PAYMENT_CREDITCARDTYPE];
        
        if ([creditCardNumber length] > 1 && [ creditCardNumber characterAtIndex:0] == '4') {
            if ([paymentCreditCardType isEqualToString:@"Visa"]) {
                return YES;
            }
        }
        else if ([creditCardNumber length] > 1 && [creditCardNumber characterAtIndex:0] == '5' && ([creditCardNumber characterAtIndex:1] == '1'  || [creditCardNumber characterAtIndex:1] == '2' || [creditCardNumber characterAtIndex:1] == '5')) {
            if ([paymentCreditCardType isEqualToString:@"MasterCard"]) {
                return YES;
            }
        }
        else if ([creditCardNumber length] > 1 && [creditCardNumber characterAtIndex:0] == '3' && ([creditCardNumber characterAtIndex:1] == '4' || [creditCardNumber characterAtIndex:1] == '7')){
            if ([paymentCreditCardType isEqualToString:@"AmericanExpress"]) {
                return YES;
            }
        }
        return NO;
    }
    else {
        return NO;
    }
}

/*!
 * PaymentViewController getting the credit card type
 */
- (NSString*) creditCardType :(NSString*)creditCardNumber {
    NSString *type;
    if ([creditCardNumber length] > 1 && [ creditCardNumber characterAtIndex:0] == '4') {
        type =@"Visa";
    }
    else if ([creditCardNumber length] > 1 && [creditCardNumber characterAtIndex:0] == '5' && ([creditCardNumber characterAtIndex:1] == '1'  || [creditCardNumber characterAtIndex:1] == '2' || [creditCardNumber characterAtIndex:1] == '5')) {
        type=@"MasterCard";
    }
    else if ([creditCardNumber length] > 1 && [creditCardNumber characterAtIndex:0] == '3' && ([creditCardNumber characterAtIndex:1] == '4' || [creditCardNumber characterAtIndex:1] == '7')){
        type = @"AmericanExpress";
    }
    return type;
    
}

/*!
 * PaymentViewController navigating to signature page
 */
- (void) provideSignature {
    DebugLog(@"provideSignature");
    SignatureViewController *controller = (SignatureViewController*)[persistenceManager getView:@"SignatureViewController"];
    controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) willEnterForegroundNotification {
    [service showPinView:self];
    if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        [self lineaProConnect];
    }
}


- (void) didEnterBackgroundNotification {
    if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
        [self lineaProDisconnect];
    }
}

- (void) lineaProConnect {
    DebugLog(@"lineaProConnect");
    _dtdev=[DTDevices sharedDevice];
    [_dtdev addDelegate:self];
    [_dtdev connect ];
    
}

- (void) lineaProDisconnect {
    DebugLog(@"lineaProDisconnect");
    [_dtdev removeDelegate:self];
    [_dtdev disconnect];
}

- (void) onUpdateBattery {
    DebugLog(@"onUpdateBattery");
    int percent;
    float voltage;
    
    
    if([_dtdev getBatteryCapacity:&percent voltage:&voltage error:nil]) {
        [self.creditCardViewCell.batteryBtn setHidden:NO];
        [self.creditCardViewCell.batteryBtn setTitle:[NSString stringWithFormat:@"%.2fv, %d%%",voltage,percent]
                                            forState:UIControlStateNormal];
        
        DebugLog(@"onUpdateBatterty -> battery info %d",percent);
        
        if(percent<10) {
            [self.creditCardViewCell.batteryBtn setBackgroundImage:[UIImage imageNamed:@"batt_info_0"] forState:UIControlStateNormal];
        }
        else if(percent<40) {
            [self.creditCardViewCell.batteryBtn setBackgroundImage:[UIImage imageNamed:@"batt_info_25"] forState:UIControlStateNormal];
        }
        else if(percent<60) {
            [self.creditCardViewCell.batteryBtn setBackgroundImage:[UIImage imageNamed:@"batt_info_50"] forState:UIControlStateNormal];
        }
        else if(percent<80) {
            [self.creditCardViewCell.batteryBtn setBackgroundImage:[UIImage imageNamed:@"batt_info_75"] forState:UIControlStateNormal];
        }
        else {
            [self.creditCardViewCell.batteryBtn setBackgroundImage:[UIImage imageNamed:@"batt_info_100"] forState:UIControlStateNormal];
        }
        
    } else {
        [self.creditCardViewCell.batteryBtn setHidden:YES];
        
    }
    
}


@end
