//
//  MainViewController.m
//  ConverterLab-App
//
//  Created by Admin on 16.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import "MainViewController.h"
#import "OFCoreDataManager.h"
#import "VisitCardCell.h"
#import "BankObject.h"
#import "CityObject.h"
#import "RegionObject.h"
#import "CurrencyObject.h"
#import "WebViewController.h"
#import "MapViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) NSMutableArray *citiesArray;
@property (strong, nonatomic) NSMutableArray *regionsArray;
@property (strong, nonatomic) NSMutableArray *banksArray;
@property (strong, nonatomic) NSMutableArray *searchedBanksArray;

@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISearchDisplayController *mySearchController;

@end

@implementation MainViewController

static NSString * const OFVisitCardCellIdentifier = @"tileCell";

dispatch_queue_t myQueue(){
    static dispatch_queue_t myQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    });
    return myQueue;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(revealSearchBarAction)];
    searchButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = searchButton;
    self.searchBar.hidden = YES;
    
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = self.view.center;
    indicator.color = [UIColor grayColor];
    indicator.hidesWhenStopped = YES;
    self.indicatorView = indicator;
    [self.view addSubview:self.indicatorView];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self showLoadingInProgress];
//    NSURL * resourseURL =
//    [NSURL URLWithString:@"http://resources.finance.ua/ua/public/currency-cash.json"];
//
////    if ([[UIApplication sharedApplication] canOpenURL:resourseURL]) {
//        [self downloadBankInformation];
//   // } else {
//        [self updateDataSource];
//   // }
    
   // [self downloadBankInformation];
   [self updateDataSource];

   // [self.tableView reloadData];
    
   OFCoreDataManager * coreDataManager = [OFCoreDataManager sharedInstance];
  NSLog(@"%@",[coreDataManager applicationDocumentsDirectory]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
   // [self showLoadingInProgress];
}

- (void)showLoadingInProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
       // [self.view bringSubviewToFront:self.loadingView];
        [self.indicatorView startAnimating];
    });
}

- (void)removeLoadingInProgressLable
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.loadingView) {
//            [self.loadingView removeFromSuperview];
//        }
       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
       [self.indicatorView stopAnimating];
    });
}

#pragma mark - Update properties
- (void)updateDataSource
{
    if (self.indicatorView.hidden) {
        [self showLoadingInProgress];
    }
    [self updateCitiesArray];
    [self updateRegionsArray];
    [self updateBanksArray];
    
    [self.tableView reloadData];
    [self removeLoadingInProgressLable];
}

- (void)updateCitiesArray
{
    OFCoreDataManager * coreDataManager = [OFCoreDataManager sharedInstance];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"City"];
    if (self.citiesArray) {
        [self.citiesArray removeAllObjects];
    }
    self.citiesArray =
    [[coreDataManager.managedObjectContext executeFetchRequest:fetchRequest
                                                         error:nil] mutableCopy];
}

- (void)updateRegionsArray
{
    OFCoreDataManager * coreDataManager = [OFCoreDataManager sharedInstance];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Region"];
    if (self.regionsArray) {
        [self.regionsArray removeAllObjects];
    }
    self.regionsArray=
    [[coreDataManager.managedObjectContext executeFetchRequest:fetchRequest
                                                         error:nil] mutableCopy];
}

-(void)updateBanksArray
{
    OFCoreDataManager * coreDataManager = [OFCoreDataManager sharedInstance];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bank"];
    if (self.banksArray) {
        [self.banksArray removeAllObjects];
    }
    self.banksArray =
    [[coreDataManager.managedObjectContext executeFetchRequest:fetchRequest
                                                         error:nil] mutableCopy];
    [self sortBanks];
}

- (void) sortBanks
{
    NSSortDescriptor * sortDescriptor;
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray * sortedArray = [self.banksArray sortedArrayUsingDescriptors:sortDescriptors];
    [self.banksArray removeAllObjects];
    self.banksArray = [sortedArray mutableCopy];
}

- (void)deleteOldDataFromDataSource
{
    OFCoreDataManager * coreDataManager = [OFCoreDataManager sharedInstance];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"City"];
    self.citiesArray =
    [[coreDataManager.managedObjectContext executeFetchRequest:fetchRequest
                                                         error:nil] mutableCopy];

    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Region"];
    self.regionsArray=
    [[coreDataManager.managedObjectContext executeFetchRequest:fetchRequest
                                                         error:nil] mutableCopy];

    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bank"];
    self.banksArray =
    [[coreDataManager.managedObjectContext executeFetchRequest:fetchRequest
                                                         error:nil] mutableCopy];
    
    for (BankObject *bank in self.banksArray) {
        [coreDataManager.managedObjectContext deleteObject:bank];
    }
    for (CityObject *city in self.citiesArray) {
        [coreDataManager.managedObjectContext deleteObject:city];
    }
    for (RegionObject *region in self.regionsArray) {
        [coreDataManager.managedObjectContext deleteObject:region];
    }

    NSError *error = nil;
    if (![coreDataManager.managedObjectContext save:&error])
    {
        NSLog(@"Can't delete DB - %@ %@", error, [error localizedDescription]);
    }
}

#pragma mark - Download data
- (NSURLSessionConfiguration *) getSessionConfiguration
{
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 30.0f;
    configuration.timeoutIntervalForResource = 60.0f;
    return configuration;
}

- (void) downloadBankInformation
{
    [self showLoadingInProgress];
    NSURL * resourseURL =
    [NSURL URLWithString:@"http://resources.finance.ua/ua/public/currency-cash.json"];
    NSURLSession * session = [NSURLSession sessionWithConfiguration: [self getSessionConfiguration]];
    
    NSURLSessionTask * getDataForURLTask =
    [session dataTaskWithURL:resourseURL
           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
               
               if ([response respondsToSelector:@selector(statusCode)])
               {
                   if ([(NSHTTPURLResponse *) response statusCode] == 200)
                   {
                       NSDictionary *jsonDictionary =
                       [self createDictionaryFromData:data];
                       
                       if (jsonDictionary)
                       {
                           [self deleteOldDataFromDataSource];
                           [self createDataBaseFromDictionary:jsonDictionary];
                       }
                   } else {
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self updateDataSource];
                          // [self removeLoadingInProgressLable];
                           UIAlertView * alert =
                           [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Information is NOT updated!"
                                                     delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                           [alert show];
                       });
                   }
               } else {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       //[self removeLoadingInProgressLable];
                       [self updateDataSource];
                       UIAlertView * alert =
                       [[UIAlertView alloc] initWithTitle:@"URL is unavailable"
                                                  message:@"Information is NOT updated!"
                                                 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                       [alert show];
                   });
               }
           }];
    
    [getDataForURLTask resume];

}

- (NSDictionary*)createDictionaryFromData: (NSData*) data
{
    NSError *parseJsonError = nil;
    
    NSDictionary *jsonDict =
    [NSJSONSerialization JSONObjectWithData:data
                                    options:NSJSONReadingAllowFragments
                                      error:&parseJsonError];
    if (!parseJsonError)
    {
        return jsonDict;
    }
    return nil;
}

- (void)createDataBaseFromDictionary: (NSDictionary*)jsonDictionary
{
    [self createCitiesArray:jsonDictionary];
    [self createRegionsArray:jsonDictionary];
    
    [self updateCitiesArray];
    [self updateRegionsArray];
    
    [self createBanksArray:jsonDictionary];
    
    [self updateDataSource];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self removeLoadingInProgressLable];
//        [self.tableView reloadData];
//    });
}

- (void)createCitiesArray: (NSDictionary*)jsonDictionary
{
    OFCoreDataManager *coreDataManager = [OFCoreDataManager sharedInstance];
    
    NSDictionary *citiesDictionary= jsonDictionary[@"cities"];
    NSArray *cityKeys = [citiesDictionary allKeys];

    for (NSString *key in cityKeys) {
        CityObject *cityObject =
        [NSEntityDescription insertNewObjectForEntityForName:@"City"
                                      inManagedObjectContext:
         coreDataManager.managedObjectContext];
        
        cityObject.cityId = key;
        cityObject.name = [citiesDictionary objectForKey:key];
    }

    NSError *error = nil;
    if (![coreDataManager.managedObjectContext save:&error])
    {
        NSLog(@"Can't save cities array - %@ %@", error, [error localizedDescription]);
    }
}

- (void)createRegionsArray: (NSDictionary*)jsonDictionary
{
    OFCoreDataManager *coreDataManager = [OFCoreDataManager sharedInstance];
    
    NSDictionary *regionsDictionary = jsonDictionary[@"regions"];
    NSArray *regionsKeys = [regionsDictionary allKeys];

    for (NSString *key in regionsKeys) {
        RegionObject * regionObject =
        [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                      inManagedObjectContext:
         coreDataManager.managedObjectContext];
        
        regionObject.regionId = key;
        regionObject.name = [regionsDictionary objectForKey:key];
    }

    NSError *error = nil;
    if (![coreDataManager.managedObjectContext save:&error])
    {
        NSLog(@"Can't save regions array - %@ %@", error, [error localizedDescription]);
    }
}

- (void)createBanksArray: (NSDictionary*)jsonDictionary
{
    OFCoreDataManager *coreDataManager = [OFCoreDataManager sharedInstance];
    
    NSArray *allOrganizations = jsonDictionary[@"organizations"];

    for (NSDictionary *organization in allOrganizations) {
        
        if ([organization[@"orgType"] integerValue] == 1) {
            BankObject *bankObject =
            [NSEntityDescription insertNewObjectForEntityForName:@"Bank"
                                          inManagedObjectContext:
             coreDataManager.managedObjectContext];
            
            bankObject.title = organization[@"title"];
            bankObject.address = organization[@"address"];
            
            //NSString *stringNumber = organization[@"phone"];
           // NSInteger intNumber = [stringNumber longLongValue];
            NSInteger intNumber = [organization[@"phone"] longLongValue];
            NSNumber *number=[NSNumber numberWithLongLong:intNumber];
            bankObject.phone = number;
            
            bankObject.link = organization[@"link"];
            bankObject.bankId = organization[@"id"];
            
            [self createCurrencyExchangeRatesForBank:bankObject
                                     usingDictionary:organization];
            
            [self setRelationshipsForBank: bankObject
                          usingDictionary: organization];
        }
    }
    
    NSError *error = nil;
    if (![coreDataManager.managedObjectContext save:&error])
    {
        NSLog(@"Can't save banks array - %@ %@", error, [error localizedDescription]);
    }
}

- (void)createCurrencyExchangeRatesForBank: (BankObject*)bankObject
                           usingDictionary: (NSDictionary*)organization {
    
    OFCoreDataManager *coreDataManager = [OFCoreDataManager sharedInstance];
    NSDictionary *currencyDictionary = organization[@"currencies"];
    NSArray *keysArray = [currencyDictionary allKeys];
    
    for (NSString *key in keysArray) {
        CurrencyObject *typeOfCurrency =
        [NSEntityDescription insertNewObjectForEntityForName:@"Currency"
                                      inManagedObjectContext:
         coreDataManager.managedObjectContext];
        
        typeOfCurrency.abbreviation = key;
        NSDictionary *ratesDictionary = [currencyDictionary objectForKey:key];
        typeOfCurrency.bid = @([[ratesDictionary objectForKey:@"bid"] doubleValue]);
        typeOfCurrency.ask = @([[ratesDictionary objectForKey:@"ask"] doubleValue]);
        
        typeOfCurrency.exchangeRateInBank = bankObject;
        [bankObject.exRatesOfCurrencies addObject:typeOfCurrency];
    }
    
    NSError *error = nil;
    if (![coreDataManager.managedObjectContext save:&error])
    {
        NSLog(@"Can't save currency objects - %@ %@", error, [error localizedDescription]);
    }
}

- (void)setRelationshipsForBank: (BankObject*)bankObject
                usingDictionary: (NSDictionary*)organization {
    
    NSString *bankCityId = organization[@"cityId"];
    NSString *bankRegionId = organization[@"regionId"];
    
    for (CityObject *city in self.citiesArray) {
        if ([city.cityId isEqualToString: bankCityId]) {
            bankObject.cityOfBank = city;
            [city.banksInCity addObject:bankObject];
            break;
        }
    }
    
    for (RegionObject *region in self.regionsArray) {
        if ([region.regionId isEqualToString: bankRegionId]) {
            bankObject.regionOfBank = region;
            [region.banksInRegion addObject:bankObject];
            break;
        }
    }
}

#pragma mark - SearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {

    [self filterContentForSearchText:searchString];

    [self.mySearchController.searchResultsTableView reloadData];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchString {

    NSString *trimmedString =
    [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *searchItemsArray =
    [[NSArray alloc] initWithArray:[trimmedString componentsSeparatedByString:@" "]];
    
    NSMutableArray *matchingBanksArray = [NSMutableArray array];
    NSMutableArray *allBanks = self.banksArray;
    for (BankObject *bank in allBanks) {
        
        NSString *fullBankName = [self getFullNameForBank:bank];
        bool matchesAll = YES;
        
        for (NSString *word in searchItemsArray) {
            if (![fullBankName containsString:word]) {
                matchesAll = NO;
                break;
            }
        }
        
        if (matchesAll) {
            [matchingBanksArray addObject:bank];
        }
    }
    
    self.searchedBanksArray = matchingBanksArray;
}

- (NSString*)getFullNameForBank: (BankObject*)bank
{
    CityObject *city = bank.cityOfBank;
    RegionObject *region = bank.regionOfBank;
    
    return [NSString stringWithFormat:@"%@ %@ %@", bank.title, city.name, region.name];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    self.searchBar.hidden = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VisitCardCell * cell =
    [self.tableView dequeueReusableCellWithIdentifier: OFVisitCardCellIdentifier];
    
    if (!cell)
    {
        cell = [[VisitCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OFVisitCardCellIdentifier];
    }
    
    [self configureTileCell:cell atIndexPath:indexPath forTableView:tableView];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.mySearchController.searchResultsTableView) {
        return self.searchedBanksArray.count;
    } else {
        return self.banksArray.count;
    }
}

- (void)configureTileCell:(VisitCardCell*)cell atIndexPath: (NSIndexPath*)indexPath forTableView:(UITableView*)tableView {
    
    BankObject *bank = nil;
    if (tableView == self.mySearchController.searchResultsTableView) {
        bank = [self.searchedBanksArray objectAtIndex:indexPath.section];
    } else {
        bank = [self.banksArray objectAtIndex:indexPath.section];
    }

    cell.nameTitle.text = bank.title;
    cell.addressTitle.text = bank.address;
    if (!bank.phone) {
        cell.phoneNumberTitle.text = @"Unavailable";
    } else {
    cell.phoneNumberTitle.text =
    [NSString stringWithFormat:@"0%lld",[bank.phone longLongValue]];
    }

    CityObject *cityOfBank = bank.cityOfBank;
    RegionObject *regionOfBank = bank.regionOfBank;
    
    cell.cityTitle.text =
    [NSString stringWithFormat:@"%@,\n%@", regionOfBank.name, cityOfBank.name];
    
    cell.linkButton.tag = indexPath.section;
    cell.mapButton.tag = indexPath.section;
    cell.callButton.tag = indexPath.section;
    cell.detailsButton.tag = indexPath.section;

    [cell.contentView sizeToFit];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
    static VisitCardCell * sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        sizingCell =
        [tableView dequeueReusableCellWithIdentifier:OFVisitCardCellIdentifier];
    });
    [self configureTileCell: sizingCell atIndexPath: indexPath forTableView:tableView];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell: (VisitCardCell*) sizingCell
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
}

#pragma mark - IBActions
- (void)revealSearchBarAction {
    self.searchBar.hidden = NO;
    [self.searchBar becomeFirstResponder];
}

- (IBAction)linkButtonAction:(UIButton*)sender{
    
    BankObject *bank;
    if ([self.mySearchController isActive]) {
        bank = [self.searchedBanksArray objectAtIndex:sender.tag];
    } else {
        bank = [self.banksArray objectAtIndex:sender.tag];
    }
    
    WebViewController * webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
    webViewController.title = bank.title;
    
    NSString *stringURL = bank.link;
    NSURL *bankURL = [NSURL URLWithString:stringURL];
    webViewController.bankLinkURL = bankURL;
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)mapButtonAction:(UIButton*)sender {
    BankObject *bank;
    if ([self.mySearchController isActive]) {
        bank = [self.searchedBanksArray objectAtIndex:sender.tag];
    } else {
        bank = [self.banksArray objectAtIndex:sender.tag];
    }
    
    MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
    mapViewController.title = @"Map location";
    mapViewController.bank = bank;
    
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (IBAction)callButtonAction:(UIButton*)sender {
    BankObject *bank;
    if ([self.mySearchController isActive]) {
        bank = [self.searchedBanksArray objectAtIndex:sender.tag];
    } else {
        bank = [self.banksArray objectAtIndex:sender.tag];
    }
    
    NSString *phoneNumber = [NSString stringWithFormat:@"tel://+380%@",bank.phone];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    } else {
        UIAlertView * alert =
        [[UIAlertView alloc] initWithTitle:@"Unavailable"
                                   message:@"Can't call bank phone number."
                                  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    };
    
}

@end
