//
//  RequestInputCell.h
//  RestClient
//
//  Created by Axel Rivera on 11/17/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestInputCell : UITableViewCell

@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UITextField *valueTextField;
@property (strong, nonatomic) UISwitch *activeSwitch;

@property (strong, nonatomic) RCRequestOption *requestOption;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
