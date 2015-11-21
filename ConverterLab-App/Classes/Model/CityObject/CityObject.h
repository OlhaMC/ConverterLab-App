//
//  City.h
//  ConverterLab-App
//
//  Created by Admin on 18.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BankObject;

@interface CityObject : NSManagedObject

@property (nonatomic, retain) NSString * cityId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSMutableSet *banksInCity;
@end

@interface CityObject (CoreDataGeneratedAccessors)

- (void)addBanksInCityObject:(BankObject *)value;
- (void)removeBanksInCityObject:(BankObject *)value;
- (void)addBanksInCity:(NSSet *)values;
- (void)removeBanksInCity:(NSSet *)values;

@end
