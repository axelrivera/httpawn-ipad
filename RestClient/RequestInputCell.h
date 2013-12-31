//
//  RequestInputCell.h
//  RestClient
//
//  Created by Axel Rivera on 11/17/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RequestInputCellType) {
    RequestInputCellTypeHeader = 0,
    RequestInputCellTypeParameter
};

@interface RequestInputCell : UITableViewCell

@property (assign, nonatomic) RequestInputCellType inputType;
@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UITextField *valueTextField;
@property (strong, nonatomic) UISwitch *activeSwitch;
@property (strong, nonatomic) UIButton *inputButton;

@property (strong, nonatomic) RCRequestOption *requestOption;

- (instancetype)initWithType:(RequestInputCellType)inputType reuseIdentifier:(NSString *)reuseIdentifier;

@end
