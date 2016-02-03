//
//  OFCoreDataManager.m
//  ConverterLab-App
//
//  Created by Admin on 16.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import "OFCoreDataManager.h"
#import "BankObject.h"
#import "CityObject.h"
#import "RegionObject.h"
#import "CurrencyObject.h"

@implementation OFCoreDataManager

#pragma mark - Life cycle

+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.olhaf.ConverterLab_App" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ConverterLab_App" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ConverterLab_App.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
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
                           [self updateDataPropertiesToMatchDataSource];
                           UIAlertView * alert =
                           [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Information is NOT updated!"
                                                     delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                           [alert show];
                       });
                   }
               } else {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [self updateDataPropertiesToMatchDataSource];
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
    
    [self updateDataPropertiesToMatchDataSource];
}

- (void)createCitiesArray: (NSDictionary*)jsonDictionary
{
    NSDictionary *citiesDictionary= jsonDictionary[@"cities"];
    NSArray *cityKeys = [citiesDictionary allKeys];
    
    for (NSString *key in cityKeys) {
        CityObject *cityObject =
        [NSEntityDescription insertNewObjectForEntityForName:@"City"
                                      inManagedObjectContext:self.managedObjectContext];
        
        cityObject.cityId = key;
        cityObject.name = [citiesDictionary objectForKey:key];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Can't save cities array - %@ %@", error, [error localizedDescription]);
    }
}

- (void)createRegionsArray: (NSDictionary*)jsonDictionary
{
    NSDictionary *regionsDictionary = jsonDictionary[@"regions"];
    NSArray *regionsKeys = [regionsDictionary allKeys];
    
    for (NSString *key in regionsKeys) {
        RegionObject * regionObject =
        [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                      inManagedObjectContext:self.managedObjectContext];
        
        regionObject.regionId = key;
        regionObject.name = [regionsDictionary objectForKey:key];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Can't save regions array - %@ %@", error, [error localizedDescription]);
    }
}

- (void)createBanksArray: (NSDictionary*)jsonDictionary
{
    NSArray *allOrganizations = jsonDictionary[@"organizations"];
    
    for (NSDictionary *organization in allOrganizations) {
        
        if ([organization[@"orgType"] integerValue] == 1) {
            BankObject *bankObject =
            [NSEntityDescription insertNewObjectForEntityForName:@"Bank"
                                          inManagedObjectContext:self.managedObjectContext];
            
            bankObject.title = organization[@"title"];
            bankObject.address = organization[@"address"];
            
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
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Can't save banks array - %@ %@", error, [error localizedDescription]);
    }
}

- (void)createCurrencyExchangeRatesForBank: (BankObject*)bankObject
                           usingDictionary: (NSDictionary*)organization {

    NSDictionary *currencyDictionary = organization[@"currencies"];
    NSArray *keysArray = [currencyDictionary allKeys];
    
    for (NSString *key in keysArray) {
        CurrencyObject *typeOfCurrency =
        [NSEntityDescription insertNewObjectForEntityForName:@"Currency"
                                      inManagedObjectContext:self.managedObjectContext];
        
        typeOfCurrency.abbreviation = key;
        NSDictionary *ratesDictionary = [currencyDictionary objectForKey:key];
        typeOfCurrency.bid = @([[ratesDictionary objectForKey:@"bid"] doubleValue]);
        typeOfCurrency.ask = @([[ratesDictionary objectForKey:@"ask"] doubleValue]);
        
        typeOfCurrency.exchangeRateInBank = bankObject;
        [bankObject.exRatesOfCurrencies addObject:typeOfCurrency];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
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

#pragma mark - Delete data
- (void)deleteOldDataFromDataSource
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"City"];
    self.citiesArray =[[self.managedObjectContext executeFetchRequest:fetchRequest
                                                                error:nil] mutableCopy];
    
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Region"];
    self.regionsArray=[[self.managedObjectContext executeFetchRequest:fetchRequest
                                                                error:nil] mutableCopy];
    
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bank"];
    self.banksArray =[[self.managedObjectContext executeFetchRequest:fetchRequest
                                                               error:nil] mutableCopy];
    
    for (BankObject *bank in self.banksArray) {
        [self.managedObjectContext deleteObject:bank];
    }
    for (CityObject *city in self.citiesArray) {
        [self.managedObjectContext deleteObject:city];
    }
    for (RegionObject *region in self.regionsArray) {
        [self.managedObjectContext deleteObject:region];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Can't delete DB - %@ %@", error, [error localizedDescription]);
    }
    NSLog(@"Old DB is deleted");
}

#pragma mark - Update properties
- (void)updateDataPropertiesToMatchDataSource
{
    [self updateCitiesArray];
    [self updateRegionsArray];
    [self updateBanksArray];
    NSLog(@"Properties are updated");
}

- (void)updateCitiesArray
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"City"];
    if (self.citiesArray) {
        [self.citiesArray removeAllObjects];
    }
    self.citiesArray =[[self.managedObjectContext executeFetchRequest:fetchRequest
                                                                error:nil] mutableCopy];
    NSLog(@"Cities - %ld", self.citiesArray.count);
}

- (void)updateRegionsArray
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Region"];
    if (self.regionsArray) {
        [self.regionsArray removeAllObjects];
    }
    self.regionsArray=[[self.managedObjectContext executeFetchRequest:fetchRequest
                                                                error:nil] mutableCopy];
    NSLog(@"Regions - %ld", self.regionsArray.count);
}

-(void)updateBanksArray
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Bank"];
    if (self.banksArray) {
        [self.banksArray removeAllObjects];
    }
    self.banksArray =[[self.managedObjectContext executeFetchRequest:fetchRequest
                                                               error:nil] mutableCopy];
    [self sortBanks];
    NSLog(@"Banks - %ld", self.banksArray.count);
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




@end
