//
//  OFCoreDataManager.h
//  ConverterLab-App
//
//  Created by Admin on 16.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface OFCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSMutableArray *citiesArray;
@property (strong, nonatomic) NSMutableArray *regionsArray;
@property (strong, nonatomic) NSMutableArray *banksArray;
@property (strong, nonatomic) NSMutableArray *searchedBanksArray;

+ (instancetype) sharedInstance;
- (void) saveContext;
- (NSURL *) applicationDocumentsDirectory;

- (void) downloadBankInformation;
- (void) updateDataPropertiesToMatchDataSource;

@end
