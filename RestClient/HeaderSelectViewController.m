//
//  HeaderSelectViewController.m
//  RestClient
//
//  Created by Axel Rivera on 12/24/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "HeaderSelectViewController.h"

#import "RCPredefinedHeader.h"

@interface HeaderSelectViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) RCPredefinedHeader *currentHeader;
@property (strong, nonatomic) NSString *currentValue;

@end

@implementation HeaderSelectViewController

- (id)init
{
    self = [super initWithNibName:@"HeaderSelectViewController" bundle:nil];
    if (self) {
        self.title = @"Common Headers";
        _dataSource = [RCPredefinedHeader allPredefinedHeaders];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.preferredContentSize = CGSizeMake(320.0, 640.0);

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(dismissAction:)];


    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveAction:)];

    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;

    if ([self.dataSource count] > 0) {
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
        self.currentHeader = self.dataSource[0];
        self.currentValue = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector Methods

- (void)saveAction:(id)sender
{
    if (self.saveBlock) {
        NSString *name = self.currentHeader.headerName;
        NSString *value = self.currentValue;
        self.saveBlock(name, value);
    }
}

- (void)dismissAction:(id)sender
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (section == 0) {
        rows = 1;
    } else {
        if (IsEmpty(self.currentHeader.headerValues)) {
            rows = 1;
        } else {
            rows = [self.currentHeader.headerValues count];
        }
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *PickerIdentifier = @"PickerCell";
    static NSString *EmptyIdentifier = @"EmptyCell";

    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PickerIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PickerIdentifier];
            cell.accessoryView = self.pickerView;
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }

    if (IsEmpty(self.currentHeader.headerValues)) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EmptyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }

        cell.textLabel.text = @"No Values";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }

    NSString *textStr = self.currentHeader.headerValues[indexPath.row];

    cell.textLabel.text = textStr;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        return;
    }

    if (IsEmpty(self.currentHeader.headerValues)) {
        return;
    }

    NSIndexPath *oldIndexPath = nil;
    NSInteger oldIndex = [self.currentHeader.headerValues indexOfObject:self.currentValue];

    if (oldIndex >= 0) {
        oldIndexPath = [NSIndexPath indexPathForRow:oldIndex inSection:1];
    }

    if (oldIndexPath && indexPath.row == oldIndexPath.row) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.currentValue = self.currentHeader.headerValues[indexPath.row];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.currentValue = nil;
        }
    } else {
        UITableViewCell *oldCell = nil;
        if (oldIndexPath) {
            oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        }

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        if (oldCell) {
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }

        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentValue = self.currentHeader.headerValues[indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    if (indexPath.section == 0) {
        height = self.pickerView.bounds.size.height;
    }
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 0) {
        title = @"Header Names";
    } else {
        title = @"Header Values";
    }
    return title;
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.dataSource count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    RCPredefinedHeader *header = self.dataSource[row];
    return header.headerName;
}

#pragma mark - UIPickerViewDelegate Methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.currentHeader = self.dataSource[row];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.currentValue = nil;
}

@end
