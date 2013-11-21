//
//  RequestInputCell.m
//  RestClient
//
//  Created by Axel Rivera on 11/17/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RequestInputCell.h"

#import <UIView+AutoLayout.h>

@interface RequestInputCell () <UITextFieldDelegate>

@end

@implementation RequestInputCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.opaque = NO;
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;

        _nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _nameTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _nameTextField.placeholder = @"Name";
        _nameTextField.text = @"";
        _nameTextField.delegate = self;

        _nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _nameTextField.returnKeyType = UIReturnKeyDefault;

        [self.contentView addSubview:_nameTextField];

        _valueTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _valueTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _valueTextField.placeholder = @"Value";
        _valueTextField.text = @"";
        _valueTextField.delegate = self;

        _valueTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _valueTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _valueTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _valueTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _valueTextField.returnKeyType = UIReturnKeyDefault;

        [self.contentView addSubview:_valueTextField];

        _activeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        _activeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        [_activeSwitch addTarget:self action:@selector(activeAction:) forControlEvents:UIControlEventValueChanged];

        [self.contentView addSubview:_activeSwitch];
        
    }
    return self;
}

- (void)updateConstraints
{

    [self.activeSwitch autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
    [self.activeSwitch autoCenterInSuperviewAlongAxis:ALAxisHorizontal];

    [self.nameTextField autoSetDimension:ALDimensionHeight toSize:37.0];
    [self.nameTextField autoSetDimension:ALDimensionWidth toSize:170.0];
    [self.nameTextField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0];
    [self.nameTextField autoCenterInSuperviewAlongAxis:ALAxisHorizontal];

    [self.valueTextField autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.nameTextField];
    [self.valueTextField autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.nameTextField withOffset:10.0];
    [self.valueTextField autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.activeSwitch withOffset:-10.0];
    [self.valueTextField autoCenterInSuperviewAlongAxis:ALAxisHorizontal];

    [super updateConstraints];
}

#pragma mark - Public Methods

- (void)setRequestOption:(RCRequestOption *)requestOption
{
    _requestOption = requestOption;
    self.nameTextField.text = requestOption.objectName;
    self.valueTextField.text = requestOption.objectValue;
    self.activeSwitch.on = requestOption.isOn;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Private Methods

- (void)activeAction:(UISwitch *)aSwitch
{
    if (self.requestOption) {
        self.requestOption.on = aSwitch.on;
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *resultStr = nil;

    if ([string length] > 0) {
        resultStr = [textField.text stringByAppendingString:string];
    } else {
        NSInteger len = [textField.text length];
        if (len > 1) {
            resultStr = [textField.text substringWithRange:NSMakeRange(0, len - 1)];
        } else {
            resultStr = @"";
        }
    }

    if (self.requestOption) {
        if (textField == self.nameTextField) {
            self.requestOption.objectName = resultStr;
        } else if (textField == self.valueTextField) {
            self.requestOption.objectValue = resultStr;
        }
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (self.requestOption) {
        if (textField == self.nameTextField) {
            self.requestOption.objectName = @"";
        } else if (textField == self.valueTextField) {
            self.requestOption.objectValue = @"";
        }
    }

    return YES;
}

@end
