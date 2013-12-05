//
//  SettingsViewController.m
//  RestClient
//
//  Created by Axel Rivera on 12/2/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)init
{
    self = [super initWithNibName:@"SettingsViewController" bundle:nil];
    if (self) {
        self.title = @"Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(dismissAction:)];

    self.timeoutStepper = [[UIStepper alloc] initWithFrame:CGRectZero];
    self.timeoutStepper.continuous = YES;
    self.timeoutStepper.minimumValue = kRCSettingsTimeoutIntervalMinValue;
    self.timeoutStepper.maximumValue = kRCSettingsTimeoutIntervalMaxValue;
    self.timeoutStepper.value = [[RCSettings defaultSettings] timeoutInterval];
    self.timeoutStepper.stepValue = 1;
    [self.timeoutStepper addTarget:self action:@selector(timeoutChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector Methods

- (void)dismissAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchAction:(UISwitch *)mySwitch
{
    NSInteger section = -1;
    NSInteger row = -1;
    if (mySwitch.tag >= 100 && mySwitch.tag < 200) {
        section = 0;
        row = mySwitch.tag - 100;
    } else {
        section = 1;
        row = mySwitch.tag - 200;
    }

    RCSettings *settings = [RCSettings defaultSettings];

    if (section == 0) {
        if (row == 0) {
            [settings setEnableCookies:[mySwitch isOn]];
        } else if (row == 1) {
            [settings setAllowInvalidSSL:[mySwitch isOn]];
        }
    } else if (section == 1) {
        if (row == 0) {
            [settings setUsePrettyPrintResponse:[mySwitch isOn]];
        } else if (row == 1) {
            [settings setApplySyntaxHighlighting:[mySwitch isOn]];
        } else if (row == 2) {
            [settings setIncludeLineNumbers:[mySwitch isOn]];
        }
    }
}

- (void)timeoutChanged:(UISlider *)slider
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];

    CGFloat value = slider.value;
    cell.textLabel.text = [NSString stringWithFormat:@"Timeout interval: %.0f s", value];
    [[RCSettings defaultSettings] setTimeoutInterval:value];
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
        rows = 3;
    } else {
        rows = 3;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *SliderIdentifier = @"SliderCell";

    if (indexPath.section == 0 && indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SliderIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SliderIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.accessoryView = self.timeoutStepper;
        }

        CGFloat value = [[RCSettings defaultSettings] timeoutInterval];
        cell.textLabel.text = [NSString stringWithFormat:@"Timeout interval: %.0f s", value];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];

        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [mySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

        cell.accessoryView = mySwitch;
    }
    
    UISwitch *mySwitch = (UISwitch *)cell.accessoryView;

    RCSettings *settings = [RCSettings defaultSettings];

    NSString *textStr = nil;
    BOOL isOn = NO;

    if (indexPath.section == 0) {
        mySwitch.tag = 100 + indexPath.row;
        if (indexPath.row == 0) {
            textStr = @"Store and send cookies automatically";
            isOn = [settings enableCookies];
        } else {
            textStr = @"Allow self-signed and unverified SSL certificates";
            isOn = [settings allowInvalidSSL];
        }
    } else {
        mySwitch.tag = 200 + indexPath.row;
        if (indexPath.row == 0) {
            textStr = @"Show pretty-print response";
            isOn = [settings usePrettyPrintResponse];
        } else if (indexPath.row == 1) {
            textStr = @"Apply syntax highlighting";
            isOn = [settings applySyntaxHighlighting];
        } else {
            textStr = @"Include line numbers";
            isOn = [settings includeLineNumbers];
        }
    }

    cell.textLabel.text = textStr;

    mySwitch.on = isOn;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 0) {
        title = @"Requests";
    } else {
        title = @"Response Output";
    }
    return title;
}

@end
