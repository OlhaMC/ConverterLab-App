//
//  Bank.h
//  ConverterLab-App
//
//  Created by Admin on 18.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CityObject;
@class RegionObject;
@class CurrencyObject;

@interface BankObject : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * bankId;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * phone;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) CityObject *cityOfBank;
@property (nonatomic, retain) NSMutableSet *exRatesOfCurrencies;
@property (nonatomic, retain) RegionObject *regionOfBank;
@end

@interface BankObject (CoreDataGeneratedAccessors)

- (void)addExRatesOfCurrenciesObject:(CurrencyObject *)value;
- (void)removeExRatesOfCurrenciesObject:(CurrencyObject *)value;
- (void)addExRatesOfCurrencies:(NSSet *)values;
- (void)removeExRatesOfCurrencies:(NSSet *)values;

@end
