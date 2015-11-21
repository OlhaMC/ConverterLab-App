//
//  Currency.h
//  ConverterLab-App
//
//  Created by Admin on 18.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BankObject;

@interface CurrencyObject : NSManagedObject

@property (nonatomic, retain) NSString * abbreviation;
@property (nonatomic, retain) NSNumber * ask;
@property (nonatomic, retain) NSNumber * bid;
@property (nonatomic, retain) BankObject *exchangeRateInBank;

@end
