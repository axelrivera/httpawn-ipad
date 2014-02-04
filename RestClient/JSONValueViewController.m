//
//  JSONValueViewController.m
//  RestClient
//
//  Created by Axel Rivera on 1/10/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "JSONValueViewController.h"

@interface JSONValueViewController () <UIActionSheetDelegate>

- (BOOL)showKey;
- (NSArray *)dataArray;

@end

@implementation JSONValueViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _objectType = RCJSONObjectTypeObject;
        _parentType = RCJSONObjectTypeObject;
        _object = nil;
        self.title = [RCJSONObject titleForObjectType:_objectType];
    }
    return self;
}

- (instancetype)initWithObjectType:(RCJSONObjectType)objectType parentType:(RCJSONObjectType)parentType;
{
    self = [self init];
    if (self) {
        _objectType = objectType;
        _parentType = parentType;
        self.title = [RCJSONObject titleForObjectType:objectType];
    }
    return self;
}

- (instancetype)initWithObject:(RCJSONObject *)object temporaryKey:(NSString *)temporaryKey
{
    self = [self initWithObjectType:object.objectType parentType:[object parentType]];
    if (self) {
        _object = object;
        _temporaryKey = temporaryKey;
    }
    return self;
}

- (instancetype)initWithObject:(RCJSONObject *)object
{
    return [self initWithObject:object temporaryKey:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGFloat height = 200.0;
    if (self.object) {
        height = 250.0;
    }

    self.preferredContentSize = CGSizeMake(320.0, height);

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(dismissAction:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveAction:)];

    if (self.temporaryKey || [self showKey]) {
        self.keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 30.0)];
        self.keyTextField.placeholder = @"Enter Key Name";
        self.keyTextField.contentVerticalAlignment = UIViewContentModeCenter;
        self.keyTextField.keyboardType = UIKeyboardTypeASCIICapable;
        self.keyTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.keyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    }

    if (self.objectType == RCJSONObjectTypeNumber || self.objectType == RCJSONObjectTypeString) {
        self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 200, 30.0)];
        self.valueTextField.placeholder = @"Enter Value";
        self.valueTextField.contentVerticalAlignment = UIViewContentModeCenter;
        self.valueTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.valueTextField.autocorrectionType = UITextAutocorrectionTypeNo;

        if (self.objectType == RCJSONObjectTypeNumber) {
            self.valueTextField.keyboardType = UIKeyboardTypeDecimalPad;
        } else {
            self.valueTextField.keyboardType = UIKeyboardTypeAlphabet;
        }
    } else if (self.objectType == RCJSONObjectTypeBoolean) {
        self.booleanSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"True", @"False" ]];
        [self.booleanSegmentedControl setWidth:75.0 forSegmentAtIndex:0];
        [self.booleanSegmentedControl setWidth:75.0 forSegmentAtIndex:1];
        self.booleanSegmentedControl.selectedSegmentIndex = 0;
    }

    if (self.object) {
        if ([self showKey]) {
            self.keyTextField.text = self.object.objectKey;
        }

        if (self.objectType == RCJSONObjectTypeNumber || self.objectType == RCJSONObjectTypeString) {
            NSString *valueStr = nil;

            if (self.objectType == RCJSONObjectTypeString) {
                valueStr = self.object.objectValue;
            } else if (self.objectType == RCJSONObjectTypeNumber) {
                valueStr = [self.object.objectValue stringValue];
            }
            self.valueTextField.text = valueStr;
        } else if (self.objectType == RCJSONObjectTypeBoolean) {
            BOOL boolValue = [self.object.objectValue boolValue];
            self.booleanSegmentedControl.selectedSegmentIndex = boolValue == YES ? 0 : 1;
        }
    }

    self.dataSource = [self dataArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (BOOL)showKey
{
    return self.parentType == RCJSONObjectTypeArray ? NO : YES;
}

- (NSArray *)dataArray
{
    NSMutableArray *array = [@[] mutableCopy];
    NSMutableDictionary *dictionary = [@{} mutableCopy];
    
    NSMutableArray *section = [@[] mutableCopy];
    if (self.temporaryKey) {
        dictionary = [@{ @"textStr" : @"Key", @"type" : @"key", @"valueStr" : self.temporaryKey } mutableCopy];
        [section addObject:dictionary];
    } else {
        if ([self showKey]) {
            dictionary = [@{ @"textStr" : @"Key", @"type" : @"key" } mutableCopy];
            [section addObject:dictionary];
        }
    }
    
    NSString *type = @"value";
    NSString *subtype = nil;
    if (self.objectType == RCJSONObjectTypeString) {
        subtype = @"string";
    } else if (self.objectType == RCJSONObjectTypeNumber) {
        subtype = @"number";
    } else if (self.objectType == RCJSONObjectTypeBoolean) {
        subtype = @"boolean";
    } else {
        type = nil;
    }
    
    if (type) {
        dictionary = [@{ @"textStr" : @"Value", @"type" : type } mutableCopy];
        if (subtype) {
            dictionary[@"subtype"] = subtype;
        }
        
        [section addObject:dictionary];
    }
    
    [array addObject:section];
    
    if (self.object) {
        dictionary = [@{ @"textStr" : @"Delete", @"type" : @"delete" } mutableCopy];
        [array addObject:@[ dictionary ]];
    }

//    switch (self.objectType) {
//        case RCJSONObjectTypeArray:
//        {
//            if ([self showKey]) {
//                rows = 1;
//            } else {
//                rows = 0;
//            }
//        }
//            break;
//        case RCJSONObjectTypeObject:
//        case RCJSONObjectTypeNull:
//            rows = 1;
//            break;
//        case RCJSONObjectTypeString:
//        case RCJSONObjectTypeNumber:
//        case RCJSONObjectTypeBoolean:
//            rows = 2;
//            break;
//        default:
//            break;
//    }

    return array;
}

#pragma mark - Selector Methods

- (void)dismissAction:(id)sender
{
    [self.delegate JSONValueViewControllerDidCancel:self];
}

- (void)saveAction:(id)sender
{
    [self.view endEditing:YES];

    NSCharacterSet *emptyCharacters = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSString *key = nil;

    if ([self showKey]) {
        key = [self.keyTextField.text stringByTrimmingCharactersInSet:emptyCharacters];

        if (IsEmpty(key)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"JSON Object"
                                                                message:@"Key cannot be empty."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }

    id value = nil;

    if (self.object) {
        switch (self.objectType) {
            case RCJSONObjectTypeString:
            case RCJSONObjectTypeNumber:
            {
                NSString *valueStr = [self.valueTextField.text stringByTrimmingCharactersInSet:emptyCharacters];
                if (IsEmpty(valueStr)) {
                    if (self.objectType == RCJSONObjectTypeNumber) {
                        value = @0;
                    } else {
                        value = @"";
                    }
                } else {
                    if (self.objectType == RCJSONObjectTypeNumber) {
                        value = (NSNumber *)[NSDecimalNumber decimalNumberWithString:valueStr];
                    } else {
                        value = valueStr;
                    }
                }
            }
                break;
            case RCJSONObjectTypeBoolean:
            {
                NSInteger selectedIndex = self.booleanSegmentedControl.selectedSegmentIndex;
                BOOL boolValue = selectedIndex == 0 ? YES : NO;
                value = [NSNumber numberWithBool:boolValue];
            }
                break;
            default:
                break;
        }

        self.object.objectKey = key;
        if (value) {
            self.object.objectValue = value;
        }

        [self.delegate JSONValueViewControllerDidFinish:self];
    } else {
        switch (self.objectType) {
            case RCJSONObjectTypeString:
            case RCJSONObjectTypeNumber:
            {
                NSString *valueStr = [self.valueTextField.text stringByTrimmingCharactersInSet:emptyCharacters];
                if (IsEmpty(valueStr)) {
                    if (self.objectType == RCJSONObjectTypeNumber) {
                        value = @0;
                    } else {
                        value = @"String";
                    }
                } else {
                    if (self.objectType == RCJSONObjectTypeNumber) {
                        value = (NSNumber *)[NSDecimalNumber decimalNumberWithString:valueStr];
                    } else {
                        value = valueStr;
                    }
                }
            }
                break;
            case RCJSONObjectTypeObject:
            case RCJSONObjectTypeArray:
                value = [@[] mutableCopy];
                break;
            case RCJSONObjectTypeBoolean:
            {
                NSInteger selectedIndex = self.booleanSegmentedControl.selectedSegmentIndex;
                BOOL boolValue = selectedIndex == 0 ? YES : NO;
                value = [NSNumber numberWithBool:boolValue];
            }
                break;
            case RCJSONObjectTypeNull:
                value = [NSNull null];
                break;
            default:
                break;
        }

        [self.delegate JSONValueViewController:self didFinishWithObjectType:self.objectType key:key value:value];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section == 0) {
//        switch (self.objectType) {
//            case RCJSONObjectTypeArray:
//            {
//                if ([self showKey]) {
//                    rows = 1;
//                } else {
//                    rows = 0;
//                }
//            }
//                break;
//            case RCJSONObjectTypeObject:
//            case RCJSONObjectTypeNull:
//                rows = 1;
//                break;
//            case RCJSONObjectTypeString:
//            case RCJSONObjectTypeNumber:
//            case RCJSONObjectTypeBoolean:
//                rows = 2;
//                break;
//            default:
//                break;
//        }
//    } else if (section == 1) {
//        rows = 1;
//    }
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *ValueIdentifier = @"ValueCell";
    static NSString *DeleteIdentifier = @"DeleteCell";

    NSDictionary *dictionary = self.dataSource[indexPath.section][indexPath.row];
    NSString *type = dictionary[@"type"];

    if ([type isEqualToString:@"delete"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DeleteIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DeleteIdentifier];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor redColor];
        }

        cell.textLabel.text = @"Delete";
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryNone;

        return cell;
    }

    if ([type isEqualToString:@"key"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryView = self.keyTextField;
        }
        
        NSString *value = dictionary[@"valueStr"];
        if (value) {
            self.keyTextField.text = value;
            self.keyTextField.userInteractionEnabled = NO;
        }

        cell.textLabel.text = dictionary[@"textStr"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }

    if ([type isEqualToString:@"value"]) {
        NSString *subtype = dictionary[@"subtype"];

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ValueIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ValueIdentifier];
            
            if (subtype) {
                if ([subtype isEqualToString:@"boolean"]) {
                    cell.accessoryView = self.booleanSegmentedControl;
                } else {
                    cell.accessoryView = self.valueTextField;
                }
            }
        }

        cell.textLabel.text = dictionary[@"textStr"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1 && indexPath.row == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([self.delegate respondsToSelector:@selector(JSONValueViewControllerShouldDeleteObject:)]) {
            [self.delegate JSONValueViewControllerShouldDeleteObject:self.object];
        }
    }
}

@end
