//
//  DetailViewController.h
//  ConverterLab-App
//
//  Created by Admin on 05.02.16.
//  Copyright (c) 2016 OlhaF. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BankObject;

@interface DetailViewController : UITableViewController

@property (strong, nonatomic) BankObject *pickedBank;

@end
