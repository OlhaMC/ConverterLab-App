//
//  Region.h
//  ConverterLab-App
//
//  Created by Admin on 18.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BankObject;

@interface RegionObject : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * regionId;
@property (nonatomic, retain) NSMutableSet *banksInRegion;
@end

@interface RegionObject (CoreDataGeneratedAccessors)

- (void)addBanksInRegionObject:(BankObject *)value;
- (void)removeBanksInRegionObject:(BankObject *)value;
- (void)addBanksInRegion:(NSSet *)values;
- (void)removeBanksInRegion:(NSSet *)values;

@end
