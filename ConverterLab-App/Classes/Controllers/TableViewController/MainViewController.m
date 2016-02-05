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

@property (strong, nonatomic) OFCoreDataManager *coreDataManager;

@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) UISearchController *mySearchController;

@end

@implementation MainViewController

static NSString * const OFVisitCardCellIdentifier = @"tileCell";

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mySearchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.mySearchController.searchResultsUpdater = self;
    self.mySearchController.searchBar.delegate = self;
    self.mySearchController.dimsBackgroundDuringPresentation = NO;
    
    self.tableView.tableHeaderView = self.mySearchController.searchBar;
    //self.navigationController.navigationItem.titleView = self.mySearchController.searchBar;
    [self.mySearchController.searchBar sizeToFit];
    self.definesPresentationContext = YES;
    //self.navigationController.hidesBarsWhenKeyboardAppears = YES;
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(revealSearchBarAction)];
    searchButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = searchButton;
    self.mySearchController.searchBar.hidden = YES;
   // self.mySearchController.searchBar.text = @"ужгород";
    
    /*CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.mySearchController.searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;*/
//    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithCustomView: self.mySearchController.searchBar];
//    searchButton.tintColor = [UIColor whiteColor];
//    self.navigationItem.rightBarButtonItem = searchButton;
//    self.mySearchController.searchBar.hidden = NO;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = self.view.center;
    indicator.color = [UIColor grayColor];
    indicator.hidesWhenStopped = YES;
    self.indicatorView = indicator;
    [self.view addSubview:self.indicatorView];
    
    self.coreDataManager = [OFCoreDataManager sharedInstance];
    
    //[self downloadInformation];
  // [self.coreDataManager updateDataPropertiesToMatchDataSource];
    [self updateBankInformationOnScreen];
    
   OFCoreDataManager * coreDataManager = [OFCoreDataManager sharedInstance];
  NSLog(@"%@",[coreDataManager applicationDocumentsDirectory]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showLoadingInProgress
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.indicatorView startAnimating];
}

- (void)removeLoadingInProgressLable
{
   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
   [self.indicatorView stopAnimating];
}

#pragma mark - Update Banks Information
- (void) downloadInformation {
    [self.coreDataManager downloadBankInformation];
}
- (void)updateBankInformationOnScreen
{
    [self.coreDataManager updateDataPropertiesToMatchDataSource];
    
    [self.tableView reloadData];
    [self removeLoadingInProgressLable];
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self filterBanksArrayForSearchText:searchString];
    [self.tableView reloadData];
}
/*
- (void)searchForText:(NSString*)searchString {
    
    NSString *trimmedString =
    [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *searchWordsArray =
    [[NSArray alloc] initWithArray:[trimmedString componentsSeparatedByString:@" "]];
    
    NSMutableArray *subpredicatesArray = [NSMutableArray array];
    for (NSString *word in searchWordsArray) {
        NSPredicate *predicateItem = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",word];
        [subpredicatesArray addObject:predicateItem];
    }
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicatesArray];
    NSArray *filteredArray = [self.notesArray filteredArrayUsingPredicate:compoundPredicate];
    self.filteredNotesArray = filteredArray;
}*/

- (void)filterBanksArrayForSearchText:(NSString*)searchString {

    NSString *trimmedString =
    [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *searchItemsArray =
    [[NSArray alloc] initWithArray:[trimmedString componentsSeparatedByString:@" "]];
    
    NSMutableArray *matchingBanksArray = [NSMutableArray array];
    NSMutableArray *allBanks = self.coreDataManager.banksArray;
    for (BankObject *bank in allBanks) {
        
        NSString *fullBankName = [self getFullNameForBank:bank];
        bool matchesAll = YES;
        
        for (NSString *word in searchItemsArray) {
            if (![fullBankName localizedCaseInsensitiveContainsString:word]) {
                matchesAll = NO;
                break;
            }
        }
        
        if (matchesAll) {
            [matchingBanksArray addObject:bank];
        }
    }
    
    self.coreDataManager.searchedBanksArray = matchingBanksArray;
}

- (NSString*)getFullNameForBank: (BankObject*)bank
{
    CityObject *city = bank.cityOfBank;
    RegionObject *region = bank.regionOfBank;
   // NSLog(@"Link - %@", bank.link);
    
    return [NSString stringWithFormat:@"%@ %@ %@ %@",
                                      bank.title, city.name, region.name, bank.link];
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
    if (self.mySearchController.active) {
        return self.coreDataManager.searchedBanksArray.count;
    } else {
        return self.coreDataManager.banksArray.count;
    }
}

- (void)configureTileCell:(VisitCardCell*)cell atIndexPath: (NSIndexPath*)indexPath forTableView:(UITableView*)tableView {
    
    BankObject *bank = nil;
    if (self.mySearchController.active) {
        bank = [self.coreDataManager.searchedBanksArray objectAtIndex:indexPath.section];
    } else {
        bank = [self.coreDataManager.banksArray objectAtIndex:indexPath.section];
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
    self.navigationController.navigationItem.titleView = self.mySearchController.searchBar;
    self.mySearchController.searchBar.hidden = NO;
    [self.mySearchController.searchBar becomeFirstResponder];
}

- (IBAction)linkButtonAction:(UIButton*)sender{
    
    BankObject *bank;
    if ([self.mySearchController isActive]) {
        bank = [self.coreDataManager.searchedBanksArray objectAtIndex:sender.tag];
    } else {
        bank = [self.coreDataManager.banksArray objectAtIndex:sender.tag];
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
        bank = [self.coreDataManager.searchedBanksArray objectAtIndex:sender.tag];
    } else {
        bank = [self.coreDataManager.banksArray objectAtIndex:sender.tag];
    }
    
    MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
    mapViewController.title = @"Map location";
    mapViewController.bank = bank;
    
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (IBAction)callButtonAction:(UIButton*)sender {
    BankObject *bank;
    if ([self.mySearchController isActive]) {
        bank = [self.coreDataManager.searchedBanksArray objectAtIndex:sender.tag];
    } else {
        bank = [self.coreDataManager.banksArray objectAtIndex:sender.tag];
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
