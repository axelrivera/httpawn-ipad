//
//  SelectViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/29/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "SelectViewController.h"

@interface SelectViewController ()

@end

@implementation SelectViewController

- (instancetype)init
{
    self = [super initWithNibName:@"SelectViewController" bundle:nil];
    if (self) {
        self.title = @"Select";
    }
    return self;
}

- (instancetype)initWithDataSource:(NSArray *)dataSource
{
    self = [self init];
    if (self) {
        _dataSource = dataSource;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self.delegate respondsToSelector:@selector(selectViewControllerDidCancel:)]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(dismissAction:)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector Methods

- (void)dismissAction:(id)sender
{
    [self.delegate selectViewControllerDidCancel:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    BOOL isSelected = NO;
    NSString *textStr = nil;

    if (indexPath.row == 0) {
        textStr = @"None";
    }  else {
        RCSelect *select = self.dataSource[indexPath.row - 1];
        textStr = select.selectName;
        isSelected = select.isSelected;
    }

    cell.textLabel.text = textStr;

    if (isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RCSelect *select = nil;
    if (indexPath.row > 0) {
        select = self.dataSource[indexPath.row - 1];
    }

    [self.delegate selectViewController:self didSelectObject:select];
}

@end
