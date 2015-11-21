//
//  VisitCardCell.h
//  ConverterLab-App
//
//  Created by Admin on 17.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitCardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameTitle;
@property (weak, nonatomic) IBOutlet UILabel *cityTitle;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberTitle;
@property (weak, nonatomic) IBOutlet UILabel *addressTitle;

@property (weak, nonatomic) IBOutlet UIButton *linkButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end
